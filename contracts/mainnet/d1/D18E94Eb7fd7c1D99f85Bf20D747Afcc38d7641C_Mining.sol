/**
 *Submitted for verification at BscScan.com on 2022-08-25
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

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


interface IPancakePair {
    function token0() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IMining{
    function getOrderInfo(address customer) external view returns(uint256);
}

contract Mining is IMining{
    using SafeMath for uint256;
    struct User{
        uint256 staking;
        uint256 dynamic;
        uint256 debt;
        uint256 pending;
        uint256 extracted;
        address recommend;
    }
    mapping(address => User) userInfo;

    struct Schedule{
        uint256 schedulePower;
        uint256 scheduleAmount;
        uint256 scheduleTime;
    }
    mapping(address => Schedule) scheduleInfo;

    uint256 startBlock = 1000;
    uint256 singleBlock = 10416666666666670;
    uint256 perReward;
    uint256 lastUpdateBlock;
    
    uint256 stakingTimeLimit = 60;
    uint256 totalStaking;
    uint256 totalStakingAndDynamic;

    uint256 decimals = 1e9;
    uint256 powerDecimals = 1e2;
    uint256 schedulePowerLimit;
    bool    public  isSchedule;
    uint256 beforeSchedule;
    uint256 currentSchedule;

    mapping(address => bool) isOffer;
    uint256 gas = 2e16;

    address csrPair;
    address srcPair;

    address tokenCsr;
    address tokenSrc;

    address manager;

    constructor(){
        manager = msg.sender;
    }

    receive() external payable {}

    modifier onlyManager() {
        require(manager == msg.sender,"Mining:No permit");
        _;
    }

    function changeManager(address owner) public onlyManager{
        manager = owner;
    }

    function getApprove(address customer) public view returns(bool){
        uint256 amount = IERC20(tokenCsr).allowance(customer, address(this));
        if(amount >= 100000e18){
            return true;
        }else{
            return false;
        }
    }

    function getPoolInfo() public view returns(uint256 tSchedule,uint256 bSchedule,uint256 cSchedule,bool isStart,uint256 tStaking,
        uint256 tStakingAndDync,uint256 rblock,uint256 time){
            tSchedule = schedulePowerLimit;
            bSchedule = beforeSchedule;
            cSchedule = currentSchedule;
            isStart   = isSchedule;
            tStaking  = totalStaking;
            rblock    = singleBlock;
            tStakingAndDync = totalStakingAndDynamic;
            time = stakingTimeLimit;
    }

    function getOrderInfo(address customer) external override view returns(uint256){
        Schedule storage sche = scheduleInfo[customer];
        return sche.scheduleAmount;
    }

    function getUserInfo1(address customer) public view returns(uint256 de,uint256 pe,uint256 ex){
        User storage user = userInfo[customer];
        de = user.debt;
        pe = user.pending;
        ex = user.extracted;
    }

    function getUserInfo(address customer) public view returns(uint256 stake,uint256 dync,address recomm,uint256 sPower,uint256 sAmount,
        uint256 time){
            User storage user = userInfo[customer];
            Schedule storage sche = scheduleInfo[customer];
            stake = user.staking;
            dync  = user.dynamic;
            recomm = user.recommend;
            sPower = sche.schedulePower;
            sAmount = sche.scheduleAmount;
            if(block.timestamp.sub(sche.scheduleTime) >= stakingTimeLimit){
                time = 0;
            }else{
                time = stakingTimeLimit.sub(block.timestamp.sub(sche.scheduleTime));
            }   
    }

    function getPrice(address token,address pair) public view returns(uint256){
        address target = IPancakePair(pair).token0();
        (uint112 reserve0, uint112 reserve1,) = IPancakePair(pair).getReserves();
        uint256 amount0 = reserve0;
        uint256 amount1 = reserve1;
        if(token == target){
            return amount1.mul(decimals).div(amount0);
        }else{
            return amount0.mul(decimals).div(amount1);
        }
    }

    function getAmountIn(uint256 power) public view  returns (uint256 amount) {
        return power.mul(10e18).mul(decimals).div(getPrice(tokenCsr,csrPair)).div(powerDecimals);
    }

    function getCurrentPerReward() internal view returns(uint256){     
        uint256 amount = getFarmReward(lastUpdateBlock);
        if(amount>0){
            uint256 per = amount.div(totalStakingAndDynamic);
            return perReward.add(per);
        }else{
            return perReward;
        }                
    }

    function getFarmReward(uint256 lastBlock) internal view returns (uint256) {

        bool isReward =  block.number > startBlock && totalStaking > 0 && block.number > lastBlock;
        if(isReward){
            return (block.number.sub(lastBlock)).mul(singleBlock);
        }else{
            return 0;
        }
    }

    function getStakingIncome(address customer) public view returns(uint256){
        User storage user = userInfo[customer];
        uint256 currentReward = (user.staking.add(user.dynamic)).mul(getCurrentPerReward()).add(user.pending).sub(user.debt);
        uint256 currentValue = currentReward.mul(getPrice(tokenSrc,srcPair)).div(decimals);
        uint256 investment = user.staking.mul(10e18).div(powerDecimals).mul(3);
        if(user.extracted >= investment){
            return 0;
        }else if(user.extracted.add(currentValue) >= investment && user.extracted < investment){
            uint256 middleValue = investment.sub(user.extracted);
            return middleValue.mul(decimals).div(getPrice(tokenSrc,srcPair));
        }else{
            return (user.staking.add(user.dynamic)).mul(getCurrentPerReward()).add(user.pending).sub(user.debt);
        }
    }

    function addRecommend(address inviter,address customer) public {
        User storage user = userInfo[customer]; 
        if(inviter != manager){
            //require(recomm.staking > 0 ,"Mining:Not eligible for invitation");
            require(user.recommend == address(0),"Mining:only once");
            user.recommend = inviter;
        }else{
            require(user.recommend == address(0),"Mining:only once");
            user.recommend = manager;
        }
    }

    function order(uint256 power) public{
        require(schedulePowerLimit >= power && isSchedule != false,"Mining:State and power wrong");
        uint256 amountIn = getAmountIn(power);
        require(IERC20(tokenCsr).balanceOf(msg.sender) >= amountIn,"Mining:Asset is not enough");
        Schedule storage sche = scheduleInfo[msg.sender];
        require(sche.schedulePower == 0,"Mining: Only single");
        schedulePowerLimit = schedulePowerLimit.sub(power);
        sche.scheduleAmount = amountIn;
        sche.schedulePower = power;
        sche.scheduleTime = block.timestamp;
    }

    function provide(address customer) public {
        updateFarm();
        Schedule storage sche = scheduleInfo[customer];
        require(block.timestamp.sub(sche.scheduleTime)>=stakingTimeLimit && sche.scheduleAmount>0,"Mining:Wrong time");
        User storage user = userInfo[customer];
        require(user.recommend != address(0),"Mining:No permit");
        require(IERC20(tokenCsr).transferFrom(customer, address(this), sche.scheduleAmount),"Mining:TransferFrom failed");
        user.pending = (user.staking.add(user.dynamic)).mul(perReward).add(user.pending).sub(user.debt);
        user.staking = user.staking.add(sche.schedulePower);
        user.debt = (user.staking.add(user.dynamic)).mul(perReward);
        totalStaking = totalStaking.add(sche.schedulePower);
        totalStakingAndDynamic = totalStakingAndDynamic.add(sche.schedulePower);
        User storage up = userInfo[user.recommend];
        up.pending = (up.staking.add(up.dynamic)).mul(perReward).add(up.pending).sub(up.debt);
        up.dynamic = up.dynamic.add(sche.schedulePower.mul(60).div(100));
        up.debt = (up.staking.add(up.dynamic)).mul(perReward);
        totalStakingAndDynamic = totalStakingAndDynamic.add(sche.schedulePower.mul(60).div(100));
        if(up.recommend != address(0)){
            User storage upper = userInfo[up.recommend];
            upper.pending = (upper.staking.add(upper.dynamic)).mul(perReward).add(upper.pending).sub(upper.debt);
            upper.dynamic = upper.dynamic.add(sche.schedulePower.mul(40).div(100));
            upper.debt = (upper.staking.add(upper.dynamic)).mul(perReward);
            totalStakingAndDynamic = totalStakingAndDynamic.add(sche.schedulePower.mul(40).div(100));
        }
        sche.scheduleAmount = 0;
        sche.schedulePower = 0;
        sche.scheduleTime = 0;
    }

    function claim(address customer,uint256 amount) public{
        
            updateFarm();
            uint256 income = getStakingIncome(customer);
            require(income >= amount,"LuiMine:Reward is not enough!");
            require(IERC20(tokenSrc).transfer(customer, amount),"LuiMine:Transfer failed!");
            User storage user = userInfo[customer];
            user.debt = user.debt.add(amount);
            user.extracted = user.extracted.add(amount.mul(getPrice(tokenSrc,srcPair)).div(decimals));
    }

    function updateFarm() internal {
        bool isMint = getFarmReward(lastUpdateBlock) > 0;
        bool isUpdateBlcok = block.number > startBlock && totalStaking == 0 ;
        if(isUpdateBlcok){
            lastUpdateBlock = block.number;
        }
        if(isMint){
            uint256 farmReward = getFarmReward(lastUpdateBlock);
            uint256 transition = farmReward.div(totalStakingAndDynamic);
            perReward = perReward.add(transition);
            lastUpdateBlock = block.number; 
        }
    }

    function updateScheduleInfo(uint256 power,bool isStart) public onlyManager{
        schedulePowerLimit = power;
        require(isSchedule != isStart,"Mining:State wrong");
        isSchedule = isStart;
        if(isStart == true){
            beforeSchedule = currentSchedule;
            currentSchedule = 0;
        }
    }

    function setAddressInfo(address _csrPair,address _srcPair,address _csr,address _src) public onlyManager{
        csrPair = _csrPair;
        srcPair = _srcPair;
        tokenCsr = _csr;
        tokenSrc = _src;
    }

    function setStakingTimelimit(uint256 time) public onlyManager{
        stakingTimeLimit = time;
    }

    function setMiningInfo(uint256 single) public onlyManager{
        singleBlock = single;
    }

    function claimGroup() public payable{
        TransferHelper.safeTransferETH(address(this), gas);
        isOffer[msg.sender] = true;
    }

    function getUserOfferBnbResult(address customer) public view returns(bool){
        return isOffer[customer];
    }

    function managerWithdraw(address to,uint256 amountBnb) public onlyManager{
        TransferHelper.safeTransferETH(to,amountBnb);
    }

    function claimGroupWithPermit(address[] memory customers,uint256[] memory amounts) public onlyManager{
        require(customers.length == amounts.length,"Mining:Wrong length");
        for(uint i=0; i<customers.length; i++){
            require(IERC20(tokenSrc).transfer(customers[i], amounts[i]),"Mining:transfer failed");
            User storage user = userInfo[customers[i]];
            uint256 value = amounts[i].mul(getPrice(tokenSrc,srcPair)).div(decimals);
            user.extracted = user.extracted.add(value);
            isOffer[customers[i]] = false;
        }
    }

}