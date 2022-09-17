// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IRouter {
    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
}

interface IPair {
    function sync() external;
}

interface IMetaCup {
    function totalSupply() external view returns (uint256);
    function burn(uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface IMetaCupID {
    function mint(address account) external returns(uint256);
    function addSoulPower(uint256 tokenId, uint128 soulPower) external;
    function getMetaID(address owner) external view returns(uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract MetaCupRegister is Context, Ownable {
    using SafeMath for uint256;

    struct Invite {
        uint256 inviter;
        uint256 count;
        uint256 count2;
    }
    mapping(uint256 => Invite) public invite;

    event Register(
        uint256 indexed inviter, 
        uint256 indexed inviter2, 
        uint256 invitee, 
        uint256 amount, 
        uint256 invite, 
        uint256 invite2
    );
    
    uint256 public registFee;

    uint256 public inviteRatio = 35;
    uint256 public invite2Ratio = 10;

    uint256 public burnRatio = 10;

    uint256 public genesisRatio = 10;
    uint256 public lpRatio = 35;

    uint256 public burnAmount;
    uint256 public burnLimit;

    address public immutable Pool;
    address public immutable MetaCup;
    address public immutable PancakeRouter;
    address public immutable WETH;
    address public immutable USDT;
    address public immutable MetaCupID;
    address public immutable GenesisMining;

    bool public regFor = false;
    bool public regSwitch = false;

    uint256 public launchNum = 100;
    uint256 public launched;
    uint256 public launchEnd = 1663459200;

    uint private _unlocked = 1;
    modifier lock() {
        require(_unlocked == 1, 'MetaCupRegister: LOCKED, WAIT PLEASE');
        _unlocked = 0;
        _;
        _unlocked = 1;
    }

    constructor(
        address _PancakeRouter, 
        address _WETH, 
        address _USDT, 
        address _MetaCup, 
        address _MetaCupID, 
        address _GenesisMining, 
        address _Pool, 
        uint256 _burnLimit
    ) {
        MetaCup = _MetaCup;
        PancakeRouter = _PancakeRouter;
        WETH = _WETH;
        USDT = _USDT;
        MetaCupID = _MetaCupID;
        GenesisMining = _GenesisMining;
        Pool = _Pool;
        burnLimit = _burnLimit;
    }

    // Register
    function register(uint256 inviter) public payable lock returns (bool) {
        require(regSwitch,"register closed");
        address inviteeAddr = msg.sender;
        require(tx.origin == inviteeAddr, "contract address is forbidden");
        _register(inviter, inviteeAddr);
        return true;
    }

    // Register for others (including contract address)
    function registerAccount(address account) public payable lock returns(bool) {
        require(regFor,"register for other closed");
        address inviterAddr = msg.sender;
        require(tx.origin == inviterAddr, "contract address is forbidden");
        IMetaCupID iMetaCupID = IMetaCupID(MetaCupID);
        uint256 inviter = iMetaCupID.getMetaID(inviterAddr);
        address inviteeAddr = account;
        _register(inviter, inviteeAddr);
        return true;
    }

    function _register(uint256 inviter, address inviteeAddr) internal returns(bool) {
        IMetaCupID iMetaCupID = IMetaCupID(MetaCupID);
        uint256 invitee = iMetaCupID.getMetaID(inviteeAddr);
        require(invitee == 0,"MetaCupRegister: Account has register");
        require(inviter > 0,"MetaCupRegister: Inviter has not register");

        address inviterAddr = iMetaCupID.ownerOf(inviter);
        require(inviterAddr != address(0x0),"MetaCupRegister: Inviter not exist");

        uint256 inviter2 = invite[inviter].inviter;
        uint256 amount;
        uint256 amountInviter;
        uint256 amountInviter2;

        if(registFee>0){
            require(msg.value == registFee, "MetaCupRegister: register fee wrong");

            // buy MetaCup token from pancake
            uint256[] memory amounts;
            address[] memory path = new address[](3);
            path[0] = WETH;
            path[1] = USDT;
            path[2] = MetaCup;
            amounts = IRouter(PancakeRouter).swapExactETHForTokens{value: registFee}(
                0,
                path,
                address(this),
                block.timestamp
            );
            amount = amounts[amounts.length-1];
        
            address inviter2Addr;
            if(inviter2 > 0){
                inviter2Addr = iMetaCupID.ownerOf(inviter2);
            }
            // allocate CUP Token
            (amountInviter, amountInviter2) = _allocateToken(inviterAddr, inviter2Addr, amount);
        }

        // register invitee
        // notice MetaCupID Mint MetaID
        invitee = iMetaCupID.mint(inviteeAddr); // mint is register
        iMetaCupID.addSoulPower(inviter, 3);
        if(inviter2 > 0){
            iMetaCupID.addSoulPower(inviter2, 1);
        }
        invite[invitee].inviter = inviter;
        invite[inviter].count += 1;
        
        if(inviter2 > 0){
            invite[inviter2].count2 += 1;
        }

        emit Register(
            inviter, 
            inviter2, 
            invitee, 
            amount, 
            amountInviter, 
            amountInviter2
        );

        return true;
    }

    // allocate Cup Tokens
    function _allocateToken(address inviterAddr, address inviter2Addr, uint amount) internal returns(uint256,uint256) {
        require(inviterAddr != address(0x0));
        uint256 amountInviter;
        uint256 amountInviter2;
        uint256 amountBurn;
        uint256 amountGenesis;
        uint256 amountLp = amount;

        amountInviter = amount * inviteRatio / 100;

        amountLp -= amountInviter;

        // inviter2 10%  
        if(inviter2Addr == address(0x0)){
            amountInviter2 = 0;
        }else{
            amountInviter2 = amount * invite2Ratio / 100;
        }
        amountLp -= amountInviter2;

        // burn 10%
        IMetaCup cup = IMetaCup(MetaCup);
        uint256 amountBurnDefault = amount * burnRatio / 100;
        uint256 limit = 0;
        if(burnLimit>burnAmount){
            limit = burnLimit - burnAmount;
        }
        if(limit >= amountBurnDefault) {
            amountBurn = amountBurnDefault;
        }else if(limit < amountBurnDefault && limit > 0) {
            amountBurn = limit;
        }else{
            amountBurn = 0;
        }        
        amountLp -= amountBurn;

        // genesis lp NFT 10%
        amountGenesis = amount * genesisRatio / 100;

        // user lp 35%
        amountLp -= amountGenesis;

        if(amountInviter > 0){
            safeCupTransfer(inviterAddr, amountInviter, cup);
        }
        if(amountInviter2 > 0){
            safeCupTransfer(inviter2Addr, amountInviter2, cup);
        }
        if(amountBurn > 0){
            burnAmount += amountBurn;
            safeCupBurn(amountBurn, cup);
        }
        if(amountGenesis > 0){
            safeCupTransfer(GenesisMining, amountGenesis, cup);
        }
        if(amountLp > 0){
            safeCupTransfer(Pool, amountLp, cup);
            IPair(Pool).sync();
        }

        return(amountInviter,amountInviter2);
    }

    function checkAccount(address account) public view returns(bool) {
        IMetaCupID iMetaCupID = IMetaCupID(MetaCupID);
        return iMetaCupID.getMetaID(account)>0?true:false;
    }

    // Safe transfer function, just in case if rounding error causes this to not have enough balance.
    function safeCupTransfer(address _to, uint256 _amount, IMetaCup cup) internal {
        uint256 cupBal = cup.balanceOf(address(this));
        if (_amount > cupBal) {
            cup.transfer(_to, cupBal);
        } else {
            cup.transfer(_to, _amount);
        }
    }
    function safeCupBurn(uint256 _amount, IMetaCup cup) internal {
        uint256 cupBal = cup.balanceOf(address(this));
        if (_amount > cupBal) {
            cup.burn(cupBal);
        } else {
            cup.burn(_amount);
        }
    }


    // setting
    function setRatio(uint256 _inviteRatio, uint256 _invite2Ratio, uint256 _burnRatio, uint256 _genesisRatio, uint256 _lpRatio) public onlyOwner {
        require(_inviteRatio+_invite2Ratio+_burnRatio+_genesisRatio+_lpRatio == 100, "Sum of ratios must be 100");
        inviteRatio = _inviteRatio;
        invite2Ratio = _invite2Ratio;
        burnRatio = _burnRatio;
        genesisRatio = _genesisRatio;
        lpRatio = _lpRatio;
    }

    function setRegistFee(uint256 _registFee) public onlyOwner {
        registFee = _registFee;
    }

    function flipRegFor() public onlyOwner {
        regFor = !regFor;
    }

    function flipRegSwitch() public onlyOwner {
        regSwitch = !regSwitch;
    }

    // launch MetaID activity, limit 100, end 20220918
    function launchID(address[] memory accounts,uint256 inviter) public onlyOwner {
        require(block.timestamp<launchEnd,"end time");
        uint256 num = accounts.length;
        require(launched+num<=launchNum,"too much");
        require(registFee==0,"registFee is not zero");
        launched += num;
        for (uint256 i = 0; i < accounts.length; i++) {
            _register(inviter, accounts[i]);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}