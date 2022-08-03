/**
 *Submitted for verification at BscScan.com on 2022-08-03
*/

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

// SPDX-License-Identifier:MIT

// BEP20 token standard interface
interface IBEP20 {
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `_account`.
     */
    function balanceOf(address _account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's _account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one _account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the _account sending and
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

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an _account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner _account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any _account other than the owner.
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new _account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    /**
     * @dev set the owner for the first time.
     * Can only be called by the contract or deployer.
     */
    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

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
     * by making the `nonReentrant` function external, and make it call a
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

// Main Contract
contract CINQMiner is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    IBEP20 token = IBEP20(0x8DFb025853e10184036ec64cAEE471cB6EC3949c);
    uint256 public treasure;
    uint256 public totalDeposit;

    struct UserInfo{
        uint256 deposit;
        uint256 balance;
        uint256 claim;

        uint256 lastDeposit;
        uint256 lastClaim;
        uint256 lastCompound;
    }
    mapping(address => UserInfo) public userInfos;
    mapping(address => address) public referrals;

    struct Ref {
        uint number;
        uint256 refReward;
    }
    mapping(address => Ref) public refInfos;
 
    constructor() {}

    function deposit(uint256 amount, address ref) public nonReentrant {
        
        token.transferFrom(msg.sender, address(this), amount);
        totalDeposit = totalDeposit.add(amount);
        
        if(referrals[msg.sender] == address(0) && ref != address(0) && userInfos[ref].balance > 0){
            referrals[msg.sender] = ref;
            refInfos[ref].number =  refInfos[ref].number.add(1);
        }

        address yourRef = referrals[msg.sender];
        if(yourRef != address(0) && userInfos[yourRef].balance > 0){
            userInfos[yourRef].balance = userInfos[yourRef].balance.add(amount.div(100)); // 1% referral
            refInfos[yourRef].refReward = refInfos[yourRef].refReward.add(amount.div(100));
        }

        UserInfo storage info = userInfos[msg.sender];

        if( info.balance > 0 
            && block.timestamp >= max3(info.lastDeposit, info.lastClaim, info.lastCompound).add(1 days)
            &&info.balance <= info.deposit.mul(360).div(100))
        {
            info.balance = info.balance.mul(105).div(100); // Compound 5%
            info.lastCompound = block.timestamp;
        }

        info.deposit = info.deposit.add(amount);
        info.balance = info.balance.add(amount);
        info.lastDeposit = block.timestamp;
    }


    function compound() public nonReentrant {        
        UserInfo storage info = userInfos[msg.sender];
        require(info.balance > 0, "You havent deposited before"); 
        require(info.balance <= info.deposit.mul(360).div(100), "Maximum is 360%");
        require(block.timestamp >= max3(info.lastDeposit, info.lastClaim, info.lastCompound).add(1 days), "You only claim or compound once every 24 hours");

        uint256 amount = info.balance.mul(5).div(100);
        info.balance = info.balance.add(amount); // Compound 5%
        info.lastCompound = block.timestamp;

        address yourRef = referrals[msg.sender];
        if(yourRef != address(0) && userInfos[yourRef].balance > 0){
            userInfos[yourRef].balance = userInfos[yourRef].balance.add(amount.div(10)); // 10% of compounding amount
        }
    }

    function claim() public nonReentrant {        
        UserInfo storage info = userInfos[msg.sender];
        require(info.balance > 0, "You havent deposited before");
        require(info.claim <= info.deposit.mul(360).div(100), "Maximum is 360%");
        require(block.timestamp >= max3(info.lastDeposit, info.lastClaim, info.lastCompound).add(1 days), "You only claim or compound once every 24 hours");

        uint256 amount = claimableAmount(msg.sender);
        require(amount > 0, "Nothing to claim");
        token.transfer(msg.sender, amount);

        info.balance = info.balance.sub(amount);
        info.claim = info.claim.add(amount);
        info.lastClaim = block.timestamp;
    }

    function nextClaimOrCompound(address account) public view returns(uint256){
        UserInfo memory info = userInfos[account];
        return max3(info.lastDeposit, info.lastClaim, info.lastCompound).add(1 days);
    }

    function claimableAmount(address account) public view returns(uint256){
        UserInfo memory info = userInfos[account];
        if(info.balance == 0) return 0;
        if(info.claim >= info.deposit.mul(360).div(100)) return 0;
        if(block.timestamp < max3(info.lastDeposit, info.lastClaim, info.lastCompound).add(1 days)) return 0;

        uint256 claimPercent;
        uint daysSinceLastClaim = (block.timestamp.sub(info.lastClaim)).div(1 days);
        if(daysSinceLastClaim == 0){
            claimPercent = 0;
        }else if(daysSinceLastClaim == 1){
            claimPercent = 25;
        }else if(daysSinceLastClaim == 2){
            claimPercent = 50;
        }else if(daysSinceLastClaim == 3){
            claimPercent = 75;
        }else if(daysSinceLastClaim == 4){
            claimPercent = 100;
        }else if(daysSinceLastClaim == 5){
            claimPercent = 150;
        }else if(daysSinceLastClaim == 6){
            claimPercent = 200;
        }else{
            claimPercent = 500;
        }

        uint256 amount = info.balance.mul(claimPercent).div(10000);
        return amount;
    }

    function compoundableAmount(address account) public view returns(uint256){
        UserInfo memory info = userInfos[account];
        if(info.balance == 0) return 0;
        if(info.balance >= info.deposit.mul(360).div(100)) return 0;
        if(block.timestamp < max3(info.lastDeposit, info.lastClaim, info.lastCompound).add(1 days)) return 0;

        uint256 amount = info.balance.mul(5).div(100);
        return amount;
    }

    function addRewardTreasure(uint256 amount) public {
        token.transferFrom(msg.sender, address(this), amount);
        treasure = treasure.add(amount);
    }

    function emergencyWithdrawTreasure(uint256 amount) public onlyOwner{
        require(amount <= treasure, "Exceed treasure amount");
        treasure = treasure.sub(amount);
        token.transfer(msg.sender, amount);
    }

    function max2(uint256 a, uint256 b) internal pure returns(uint256){
        return a > b ? a : b;
    }

    function max3(uint256 a, uint256 b, uint256 c) internal pure returns(uint256){
        uint256 max_ab = max2(a, b);
        return max2(max_ab, c);
    }
}


library SafeMath {
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
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
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
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
        require(b != 0, errorMessage);
        return a % b;
    }
}