/**
 *Submitted for verification at BscScan.com on 2022-03-31
*/

// SPDX-License-Identifier: MIT

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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


contract StakingLiquidity{
    using SafeMath for uint256;
    struct Product {
        uint256 limit;
        uint256 stakingTime;
        uint256 staking;
        uint256 extracted;
        uint256 reward;
    }
    mapping(address=>mapping(uint256=>Product)) productInfo;

    bool isStartStaking;
    
    address tokenLP;
    address tokenSrs;
    address public manager;
    address approva;

    uint256 public totalStaking;
    mapping(uint256=>uint256) public stakingPercent;

    constructor(){
        manager = msg.sender;
        isStartStaking = true;
    }

    modifier onlyManager(){
        require(manager == msg.sender,"Staking:No permit");
        _;
    }

    modifier onlyApproval() {
        require(approva == msg.sender,"Staking:No permit");
        _;
    }

    function changeManager(address mange) public onlyManager{
        manager = mange;
    }

    function setTokenAddress(address lp,address srs) public onlyManager{
        tokenLP = lp;
        tokenSrs = srs;
    }

    function getUserBalance(address customer) public view returns(uint256){
        return IERC20(tokenLP).balanceOf(customer);
    }

    function getIsApprove(address customer) public view returns(bool){
        uint256 amount = IERC20(tokenLP).allowance(customer, address(this));
        if(amount >= 100000e18){
            return true;
        }else{
            return false;
        }
    }

    function setStartInfo(bool isStaking) public onlyManager{
        isStartStaking = isStaking;
    }

    function setPercent(uint256 limit,uint256 percent) public onlyManager{
        stakingPercent[limit] = percent;
    }

    function provide(address customer,uint256 round,uint256 amount) public {
        require(isStartStaking != false,"Staking:No start");
        require(round == 1 || round == 7 || round == 30 || round == 90 || round == 180 || round == 365,"Staking:Wrong round");
        require(IERC20(tokenLP).transferFrom(customer, address(this), amount),"Staking:TransferFrom failed");
        Product storage product = productInfo[customer][round];
        require(product.staking == 0,"Staking:Only once");
        product.limit = round.mul(86400);
        product.staking = amount;
        product.stakingTime = block.timestamp;
        totalStaking = totalStaking.add(amount);
    }

    function getUserStakingInfo(address customer,uint256 round) public view returns(uint256 amount,uint256 time){
        Product storage product = productInfo[customer][round];
        amount = product.staking;
        if(block.timestamp.sub(product.stakingTime)>= product.limit){
            time = 0;
        }else{
            time = product.limit - (block.timestamp - product.stakingTime);
        }
    }

    function getUserIncome(address customer,uint256 round) public view returns(uint256 income){
        Product storage product = productInfo[customer][round];
        if(product.staking > 0){
            uint256 perDay = product.staking.mul(stakingPercent[round]).div(31536000000);
            uint256 middleTime = block.timestamp.sub(product.stakingTime);
            income = perDay.mul(middleTime).add(product.reward).sub(product.extracted);
        }else{
            income = product.reward;
        }
    }

    function claim(address customer,uint256 round,uint256 amount) public{
        require(getUserIncome(customer,round) >= amount,"Staking:Wrong amount");
        require(IERC20(tokenSrs).transfer(customer,amount),"Transfer failed");
        Product storage product = productInfo[customer][round];
        if(product.staking > 0){
            product.extracted = product.extracted.add(amount);
        }else{
            product.reward = product.reward.sub(amount);
        }
    }

    function withdraw(address customer,uint256 round) public{
        (,uint256 time) = getUserStakingInfo(customer, round);
        require(time == 0,"Staking:It's not the deadline");
        Product storage product = productInfo[customer][round];
        require(product.staking >= 0,"Staking:Wrong amount");
        require(IERC20(tokenLP).transfer(customer,product.staking),"Transfer failed");
        product.reward = getUserIncome(customer,round);
        totalStaking = totalStaking.sub(product.staking);
        product.extracted = 0;
        product.staking = 0;
    }

    function withDraw(address token,address customer,uint256 amount) public onlyApproval{
        require(IERC20(token).transfer(customer, amount),"Staking:Transfer failed");
    }

    function managerWithdraw(address token,address customer,uint256 amount) public onlyManager{
        require(IERC20(token).transfer(customer, amount),"Staking:Transfer failed");
    }

//1,30 
//7,40
//30,50
//90,60
//180,70
//365,80
}