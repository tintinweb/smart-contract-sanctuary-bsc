/**
 *Submitted for verification at BscScan.com on 2022-03-26
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.9;
interface IVestingImportable {
    struct ImportedSale {
        uint256 bnbSpent;
        address spentBy;
    }

    function setAddressCredit(address _address, uint256 _bnbamount) external;
    function setAddressCredits(ImportedSale[] memory _sales) external;
}

contract Vesting is Ownable, IVestingImportable {

    using SafeMath for uint;

    bool public claimOpen;

    uint256 public tgeReleasePercent;
    uint256 public tokensPerBNB;
    uint256 public timeDenominator;

    address public token;
    address public oracle;

    address[] public team;

    address payable public teamWallet;
    address public EmergencyAddress;

    mapping(address => Sale) public Sales;

    event Imported (address _address, uint _bnbAmount);
    event Claimed (address _claimant, uint _tokenAmount);

    bool private tgeClaimedByOneAddress;

    struct Sale {
        uint256 bnbSpent;
        bool tgeDistributed;
        uint256 lastClaimTime;
        uint256 amountClaimed;
    }

    constructor(address _token, bool _isTestnet) {
        EmergencyAddress = msg.sender;
        team = [msg.sender];
        teamWallet = payable(msg.sender);
        oracle = msg.sender;

        setToken(_token);

        tokensPerBNB = 0;
        tgeReleasePercent = 5;
        claimOpen = false;

        // denominator = 24 * 60 * 60 * (100 - tge%) / day%
        if (_isTestnet) {
            timeDenominator = 1900; //over 1900 second period (will release 0.5% every second after TGE at 5%)
        }
        else {
            timeDenominator = 4104000;  // over 47.5 day period (will release 2% ever day after TGE at 5%)
        }
    }

    function claim() public {
        require(claimOpen, "Claiming was not opened yet");
        require(tokensPerBNB > 0, "Token price not set");

        uint256 totalAllocation = getAddressTokenAllocation(msg.sender);
        uint256 amount = claimableTokenAmount(msg.sender);

        if (!Sales[msg.sender].tgeDistributed) {
            Sales[msg.sender].amountClaimed = 0; // initialize with zero to add later
            Sales[msg.sender].tgeDistributed = true;
            tgeClaimedByOneAddress = true;
        }
        else {
            require(Sales[msg.sender].amountClaimed < totalAllocation, "No more tokens to claim");
        }

        Sales[msg.sender].amountClaimed += amount;
        Sales[msg.sender].lastClaimTime = block.timestamp;

        IERC20 _erc20 = IERC20(token);
        _erc20.transfer(msg.sender, amount);

        emit Claimed ( msg.sender, amount );
    }
    function toggleClaim() public onlyTeam {
        claimOpen = !claimOpen;
    }

    function claimableTokenAmount(address _address) public view returns (uint256) {
        uint256 totalAllocation = getAddressTokenAllocation(_address);

        if (!Sales[_address].tgeDistributed) {
            // [tgeReleasePercent]% is released directly after TGE
            return totalAllocation.mul(tgeReleasePercent).div(100);
        }
        else {
            // [100 - tgeReleasePercent]% is released every second across [timeDenominator]s;
            uint256 vestedAmount = totalAllocation.mul(100 - tgeReleasePercent).div(100);
            uint256 lastClaimTime = Sales[_address].lastClaimTime;

            uint256 secondsPassed = block.timestamp - lastClaimTime;
            uint256 claimableAmount = secondsPassed.mul(vestedAmount.div(timeDenominator));

            if (claimableAmount >= (totalAllocation - Sales[_address].amountClaimed)) {
                claimableAmount = totalAllocation - Sales[_address].amountClaimed;
            }

            return claimableAmount;
        }
    }

    function getAddressBNBSpent(address _address) public view returns (uint256) {
        return Sales[_address].bnbSpent;
    }
    function getAddressTokenAllocation(address _address) public view returns (uint256) {
        return getAddressBNBSpent(_address)
            .mul(tokensPerBNB) // spent * tokens per bnb => total allocation
            .div(10 ** 18);    // take decimals of bnb into account (18 decimals always)
    }

    function withdrawToken(address _tokenaddress) public onlyEmergency {
        IERC20 _token = IERC20(_tokenaddress);
        _token.transfer(msg.sender, _token.balanceOf(address(this)));
    }
    function withdrawBNB() public onlyEmergency {
        payable(msg.sender).transfer(address(this).balance);
    }

    function setOracle(address _oracle) public onlyOwner {
        oracle = _oracle;
    }
    function setTeam(address[] memory _team) public onlyOwner {
        team = _team;
    }
    function setEmergency(address _newEmergency) external onlyOwner {
        EmergencyAddress = _newEmergency;
    }
    function setTeamWallet(address _newTeamWallet) external onlyOwner {
        teamWallet = payable(_newTeamWallet);
    }

    function setToken(address _tokenaddress) public onlyOwner {
        token = _tokenaddress;
    }
    function setTokensPerBNB(uint256 _tokensPerBNB) public onlyOwner {
        // in wei!
        tokensPerBNB = _tokensPerBNB;
    }
    function setTgeReleasePercent(uint256 _tgeReleasePercent) public onlyOwner {
        require(!tgeClaimedByOneAddress, "Can't change TGE percentage after a claim was made");
        tgeReleasePercent = _tgeReleasePercent;
    }

    function setAddressCredit(address _address, uint256 _bnbamount) public onlyOracle {
        Sales[_address].bnbSpent = _bnbamount;
        emit Imported ( _address, _bnbamount );
    }
    function setAddressCredits(ImportedSale[] memory _sales) public onlyOracle {
        for ( uint256 x=0; x< _sales.length ; x++ ){
            Sales[_sales[x].spentBy].bnbSpent = _sales[x].bnbSpent;
            emit Imported ( _sales[x].spentBy, _sales[x].bnbSpent );
        }
    }

    function secondReleasePercent() public view returns (uint256) {
        return (100 - tgeReleasePercent).mul(10**9).div(timeDenominator);
    }

    modifier onlyEmergency() {
        require(msg.sender == EmergencyAddress, "Emergency Only");
        _;
    }
    modifier onlyOracle() {
        require(msg.sender == oracle, "Oracle only");
        _;
    }
    modifier onlyTeam() {
        bool check;
        for (uint8 x = 0; x < team.length; x++) {
            if (team[x] == msg.sender) check = true;
        }
        require(check == true, "Team Only");
        _;
    }
}