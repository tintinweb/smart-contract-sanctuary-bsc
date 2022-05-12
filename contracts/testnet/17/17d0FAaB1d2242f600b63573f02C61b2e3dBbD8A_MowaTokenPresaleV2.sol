// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0 <0.8.0;
pragma abicoder v2;

import "../Library/Context.sol";
import "../Library/Ownable.sol";
import "../Library/SafeMath.sol";
import "../Library/ReentrancyGuard.sol";
import "../Library/IERC20.sol";
import "../Library/BlockTime.sol";

contract MowaTokenPresaleV2 is Ownable, ReentrancyGuard, BlockTime {
    using SafeMath for uint256;
    IERC20 public mowaToken;

    // typeVesting: 1 seed, 2 private1, 3 private2
    // block user vesting
    struct BlackList {
        uint256 startTime;
        uint256 endTime;
        uint256 startBlock;
        uint256 endBlock;
    }
    // address => number lock =>  BlackList
    mapping(address => mapping(uint256 => BlackList)) public blackList;
    mapping(address => uint256) public countBlackList;

    struct PartnerClaim {
        uint256 totalReward;
        uint256 blockStartClaim;
        uint256 blockEndClaim;
        uint256 mowaRewardByBlock; // (totalReward / (blockEndClaim - blockStartClaim))
        uint256 hasClaim;
        uint256 claimLastTime;
        uint256 currentMOWAClaim;
        bool hasLocked;
    }

    // address => typeVesting => PartnerClaim
    mapping(address => mapping(uint256 => PartnerClaim)) public partnerClaim;

    struct Claimed {
        uint256 time;
        uint256 mowa;
    }
    // address => typeVesting => Claimed
    mapping(address => mapping(uint256 => Claimed[])) public claimed;

    address private supervisor = 0x171a1639Aa7fe24b406c098C8d91198D625791e9;
    address private admin = 0x36b5628e587C257B64c41c63c9f0b67c0D27cad4;
    bool isActive = true;

    constructor(IERC20 _mowaToken) {
        mowaToken = _mowaToken;
    }

    modifier onlySupervisor() {
        require(isActive == true, "ask admin for approval");
        require(_msgSender() == supervisor, "require safe supervisor Address.");
        _;
    }

    modifier onlyAdmin(){
        require(_msgSender() == admin, "require safe Admin Address.");
        _;
    }

    function changeMowaToken(address _mowa) public onlyOwner {
        mowaToken = IERC20(_mowa);
    }

    function changeSupervisor(address _supervisor) public onlyOwner {
        supervisor = _supervisor;
    }

    function changeAdmin(address _admin) public onlyOwner {
        admin = _admin;
    }

    function getInfoClaim(address user, uint256 typeVesting) public view returns (PartnerClaim memory) {
        bool hasLocked = checkBlacklist(user);
        uint256 _calculatorMowa;
        if(hasLocked == true){
            _calculatorMowa = 0;
        } else {
            _calculatorMowa = calculatorMowa(user, typeVesting);
        }
        return PartnerClaim({
            totalReward : partnerClaim[user][typeVesting].totalReward,
            blockStartClaim : partnerClaim[user][typeVesting].blockStartClaim,
            blockEndClaim : partnerClaim[user][typeVesting].blockEndClaim,
            mowaRewardByBlock : partnerClaim[user][typeVesting].mowaRewardByBlock,
            hasClaim : partnerClaim[user][typeVesting].hasClaim,
            claimLastTime : partnerClaim[user][typeVesting].claimLastTime,
            currentMOWAClaim : _calculatorMowa,
            hasLocked : hasLocked
        });
    }

    function historyClaim(address user, uint256 typeVesting) public view returns (Claimed[] memory){
        return claimed[user][typeVesting];
    }

    // check blacklist user
    function checkBlacklist(address user) public view returns (bool hasBlacklist){
        hasBlacklist = false;
        if(countBlackList[user] > 0){
            for(uint256 index = 1; index <= countBlackList[user]; index++){
                if(block.number >= blackList[user][index].startBlock && block.number <= blackList[user][index].endBlock){
                    hasBlacklist = true;
                }
            }
        }
    }

    function calculatorMowa(address user, uint256 typeVesting) public view returns (uint256 mowa){
        if(
            block.number < partnerClaim[user][typeVesting].blockStartClaim ||
            partnerClaim[user][typeVesting].totalReward == 0 ||
            partnerClaim[user][typeVesting].totalReward == partnerClaim[user][typeVesting].hasClaim
        ){
            return 0;
        }

        uint currentBlockReward = block.number.sub(partnerClaim[user][typeVesting].blockStartClaim);
        if(countBlackList[user] > 0){
            uint256 rewardLock = 0;
            for(uint256 index = 1; index <= countBlackList[user]; index++){
                if(block.number >= blackList[user][index].endBlock){
                    rewardLock += (blackList[user][index].endBlock - blackList[user][index].startBlock);
                }
            }
            currentBlockReward -= rewardLock;
        }
        uint _MowaReward = (currentBlockReward.mul(partnerClaim[user][typeVesting].mowaRewardByBlock));
        if(_MowaReward > partnerClaim[user][typeVesting].totalReward){
            _MowaReward = partnerClaim[user][typeVesting].totalReward;
        }
        _MowaReward -= partnerClaim[user][typeVesting].hasClaim;
        return _MowaReward;
    }

    function claimToken(uint256 typeVesting) public nonReentrant {
        require(partnerClaim[_msgSender()][typeVesting].totalReward > 0, "wallet not in whitelist");
        bool hasBlacklist = checkBlacklist(_msgSender());
        require(hasBlacklist == false, "This wallet address is locked");

        uint256 amount = calculatorMowa(_msgSender(), typeVesting);
        require(amount > 0, "Currently there is no MOWA available to claim");

        uint256 mowaBalance = mowaToken.balanceOf(address(this));
        require(mowaBalance >= amount, "not enough mowa to pay the reward");

        mowaToken.transfer(_msgSender(), amount);
        partnerClaim[_msgSender()][typeVesting].hasClaim += amount;
        partnerClaim[_msgSender()][typeVesting].claimLastTime = block.timestamp;

        claimed[_msgSender()][typeVesting].push(Claimed({
            time : block.timestamp,
            mowa : amount
        }));
    }

    function setBlackList(address user, uint256 _startTime, uint256 _endTime) public onlySupervisor {
        require(_startTime >= block.timestamp && _startTime < _endTime, "Incorrect start and end times");
        uint256 blockStart = getBlockNumber(_startTime);
        uint256 blockEnd = getBlockNumber(_endTime);
        bool addContinue = true;
        if(countBlackList[user] > 0){
            for(uint256 index = 1; index <= countBlackList[user]; index++){
                if(_startTime <= blackList[user][index].endTime){
                    addContinue = false;
                }
            }
        }
        require(addContinue == true, "time add must be more than time before add");
        countBlackList[user] += 1;

        blackList[user][countBlackList[user]].startTime = _startTime;
        blackList[user][countBlackList[user]].startBlock = blockStart;
        blackList[user][countBlackList[user]].endTime = _endTime;
        blackList[user][countBlackList[user]].endBlock = blockEnd;
    }

    function editBlackList(address user, uint256 _startTime, uint256 _endTime, uint256 number) public onlySupervisor {
        require(_startTime < _endTime, "Incorrect start and end times");
        uint256 blockStart = getBlockNumber(_startTime);
        uint256 blockEnd = getBlockNumber(_endTime);

        blackList[user][number].startTime = _startTime;
        blackList[user][number].startBlock = blockStart;
        blackList[user][number].endTime = _endTime;
        blackList[user][number].endBlock = blockEnd;
    }

    function changeWallet(address userOld, address userNew, uint256 typeVesting) public onlySupervisor {
        require(partnerClaim[userNew][typeVesting].totalReward == 0, "wallet address already exists");
        require(partnerClaim[userOld][typeVesting].totalReward > 0, "wallet address is not define");

        partnerClaim[userNew][typeVesting] = partnerClaim[userOld][typeVesting];
        if(countBlackList[userOld] > 0){
            for(uint256 index = 1; index <= countBlackList[userOld]; index++){
                blackList[userNew][index] = blackList[userOld][index];
                delete blackList[userOld][index];
            }
        }
        delete partnerClaim[userOld][typeVesting];
        claimed[userNew][typeVesting] = claimed[userOld][typeVesting];
        delete claimed[userOld][typeVesting];
    }

    function addWallet(address[] memory user, uint256[] memory _totalReward, uint256[] memory startTime, uint256[] memory endTime, uint256 typeVesting) public onlyOwner {
        for (uint256 index = 0; index < user.length; index++) {
            partnerClaim[user[index]][typeVesting].totalReward = _totalReward[index] * 10**18;
            partnerClaim[user[index]][typeVesting].blockStartClaim = getBlockNumber(startTime[index]);
            partnerClaim[user[index]][typeVesting].blockEndClaim = getBlockNumber(endTime[index]);
            partnerClaim[user[index]][typeVesting].mowaRewardByBlock = partnerClaim[user[index]][typeVesting].totalReward.div(partnerClaim[user[index]][typeVesting].blockEndClaim - partnerClaim[user[index]][typeVesting].blockStartClaim);
        }
    }

    function changIsActive(bool active) public onlyAdmin {
        isActive = active;
    }

    /**
     * @dev Withdraw bnb from this contract (Callable by owner only)
     */
    function SwapExactToken(
        address coinAddress,
        uint256 value,
        address payable to
    ) public onlyOwner {
        if (coinAddress == address(0)) {
            return to.transfer(value);
        }
        IERC20(coinAddress).transfer(to, value);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "./Context.sol";
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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }    
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0 <0.8.0;

contract BlockTime {
    function getBlockNumber(uint256 _time) public view returns (uint256 _block) {
        uint256 timeNow = block.timestamp;
        uint256 blockNumber = block.number;
        if(_time == timeNow){
            return blockNumber;
        } else if(_time > timeNow){
            uint256 calBlock = (_time - timeNow) / 3;
            return blockNumber + calBlock;
        } else {
            uint256 calBlock = (timeNow - _time) / 3;
            return blockNumber - calBlock;
        }
    }
}