/**
 *Submitted for verification at BscScan.com on 2022-05-11
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

contract Mining{
    using SafeMath for uint256;
    struct User{
        uint256 staking;
        uint256 dynamic;
        uint256 pending;
        uint256 debt;
        uint256 extracted;
        address recommend;
    }
    mapping (address => User) userInfo;

    struct Schedule{
        uint256 schedulePower;
        uint256 scheduleAmount;
        uint256 scheduleTime;
    }
    mapping(address => Schedule) scheduleInfo;

    //挖矿相关
    uint256  startBlock;
    uint256  singleBlockMint;
    //每份收益
    uint256  perReward;
    //增加算力对标基数
    uint256 baseMint = 300e18;
    uint256 lastUpdateBlock;
    //熔断数额
    uint256 public startFuse = 1000000;
    //熔断开关
    bool    isUpdatedBlock;

    //总算力
    uint256  totalStaking;
    uint256  totalStakingAndDynamic;

    //预约相关
    uint256  schedulePowerLimit;
    uint256  beforeSchedule;
    uint256  currentSchedule;
    uint256  stakingTimeLimit = 1800;
    bool    public isSchedule;

    uint256 decimals = 1e9;
    uint256 powerDecimals = 1e2;
    uint256 gas = 2e16;
    mapping(address => bool) isOffer;

    address uniswapV2Pair01;
    address uniswapV2Pair02;
    address tokenCsr;
    address tokenSrc;
    address wbnb;
    address manager;

    constructor(){
        manager = msg.sender;
        // uniswapV2Pair = ;
        // tokenCsr = ;
        // tokenSrc = ;
        // wbnb = ;
    }

    receive() external payable {
        assert(msg.sender == wbnb); // only accept ETH via fallback from the WETH contract
    }

    modifier onlyManager() {
        require(manager == msg.sender,"Mining:No permit");
        _;
    }

    

    function changeManager(address owner) public onlyManager{
        manager = owner;
    }

    function setAddressInfo(address pair01,address pair02,address csr,address src,address bnb) public onlyManager{
        uniswapV2Pair01 = pair01;
        uniswapV2Pair02 = pair02;
        tokenCsr = csr;
        tokenSrc = src;
        wbnb = bnb;
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function getIsApprove(address customer) public view returns(bool){
        uint256 amount = IERC20(tokenCsr).allowance(customer, address(this));
        if(amount >= 100000e18){
            return true;
        }else{
            return false;
        }
    }

    function getPrice(address pair) public view returns(uint256){
        address token = IPancakePair(pair).token0();
        (uint112 reserve0, uint112 reserve1,) = IPancakePair(pair).getReserves();
        uint256 amount0 = reserve0;
        uint256 amount1 = reserve1;
        if(token == tokenCsr){
            return amount1.mul(decimals).div(amount0);
        }else{
            return amount0.mul(decimals).div(amount1);
        }
    }

    function getAmountIn(uint256 power) public view returns(uint256){
        return power.mul(10e18).mul(decimals).div(getPrice(uniswapV2Pair01)).div(powerDecimals);
    }

    function getPoolInfo() public view returns(uint256 tSchedule,uint256 bSchedule,uint256 cSchedule,bool isStart,uint256 tStaking,
        uint256 tStakingAndDync,uint256 rblock,uint256 time){
            tSchedule = schedulePowerLimit;
            bSchedule = beforeSchedule;
            cSchedule = currentSchedule;
            isStart   = isSchedule;
            tStaking  = totalStaking;
            rblock    = singleBlockMint;
            tStakingAndDync = totalStakingAndDynamic;
            time = stakingTimeLimit;
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

    function getStakingIncome(address customer) public view returns(uint256){
        User storage user = userInfo[customer];
        uint256 currentReward = (user.staking.add(user.dynamic)).mul(getCurrentPerReward()).add(user.pending).sub(user.debt);
        uint256 currentValue = currentReward.mul(getPrice(uniswapV2Pair02)).div(decimals);
        uint256 investment = (user.staking.add(user.dynamic)).mul(10e18);
        if(user.extracted >= investment){
            return 0;
        }else if(user.extracted.add(currentValue) >= investment && user.extracted < investment){
            uint256 middleValue = investment.sub(user.extracted);
            return middleValue.mul(decimals).div(getPrice(uniswapV2Pair02));
        }else{
            return (user.staking.add(user.dynamic)).mul(getCurrentPerReward()).add(user.pending).sub(user.debt);
        }
    }

    function setMiningInfo(uint256 start,uint256 single) public onlyManager{
        startBlock = start;
        singleBlockMint = single;
    }

    function setStakingMiddleTime(uint256 time) public onlyManager{
        stakingTimeLimit = time;
    }

    function updateScheduleInfo(uint256 power,bool isStart) public onlyManager{
        schedulePowerLimit = power;
        require(isSchedule != isStart,"Mining:State wrong");
        isSchedule = isStart;
        if(isStart == true){
            beforeSchedule = currentSchedule;
            currentSchedule = 0;
        }else{ 
            if(beforeSchedule <= currentSchedule && totalStaking >= startFuse.mul(powerDecimals)){
                uint256 amount = currentSchedule.sub(beforeSchedule);
                uint256 rate = amount.div(1000);
                uint256 addAmount = baseMint.mul(rate).div(100).div(28800);
                if(addAmount > 0){
                    updateFarm();
                }
                singleBlockMint = singleBlockMint.add(addAmount);
            }
        }
    }

    function addRecommend(address inviter) public {
        User storage user = userInfo[msg.sender];
        User storage recomm = userInfo[inviter];
        if(inviter != manager){
            require(recomm.staking > 0 ,"Mining:Not eligible for invitation");
            require(user.recommend == address(0),"Mining:only once");
            user.recommend = inviter;
        }else{
            require(user.recommend == address(0),"Mining:only once");
            user.recommend = manager;
        }
    }

    function order(address customer,uint256 power) public{
        uint256 amountIn = getAmountIn(power);
        require(IERC20(tokenCsr).balanceOf(customer) >= amountIn,"Mining:Wrong amount");
        require(schedulePowerLimit >= power && isSchedule != false,"Mining:Quota sold out");
        Schedule storage sche = scheduleInfo[customer];
        require(sche.schedulePower == 0,"Mining:only once");
        sche.schedulePower = power;
        sche.scheduleAmount = amountIn;
        sche.scheduleTime = block.timestamp;
        schedulePowerLimit = schedulePowerLimit.sub(power);
        currentSchedule = currentSchedule.add(power);
    }

    function provide(address customer) public{
        Schedule storage sche = scheduleInfo[customer];
        require(block.timestamp.sub(sche.scheduleTime)>=stakingTimeLimit && sche.scheduleAmount>0,"Mining:Wrong time");
        User storage user = userInfo[customer];
        require(user.recommend != address(0),"Mining:No permit");
        require(IERC20(tokenCsr).transferFrom(customer, address(this), sche.scheduleAmount),"Mining:TransferFrom failed");
        //更新用户收益信息
        user.pending = (user.staking.add(user.dynamic)).mul(perReward).add(user.pending).sub(user.debt);
        user.staking = user.staking.add(sche.schedulePower);
        user.debt = (user.staking.add(user.dynamic)).mul(perReward);
        totalStaking = totalStaking.add(sche.schedulePower);
        totalStakingAndDynamic = totalStakingAndDynamic.add(sche.schedulePower);
        //更新推荐算力
        if(user.recommend != address(0)){
            updateRecommendPower(user.recommend,sche.schedulePower);
        }
        //更新用户预约信息
        sche.scheduleAmount = 0;
        sche.schedulePower = 0;
        sche.scheduleTime = 0;
    }

    function updateRecommendPower(address recomm,uint256 power) internal{
        User storage up = userInfo[recomm];
        up.pending = (up.staking.add(up.dynamic)).mul(perReward).add(up.pending).sub(up.debt);
        up.dynamic = up.dynamic.add(power.mul(60).div(100));
        up.debt = (up.staking.add(up.dynamic)).mul(perReward);
        totalStakingAndDynamic = totalStakingAndDynamic.add(power.mul(60).div(100));
        if(up.recommend != address(0)){
            User storage upper = userInfo[up.recommend];
            upper.pending = (upper.staking.add(upper.dynamic)).mul(perReward).add(upper.pending).sub(upper.debt);
            upper.dynamic = upper.dynamic.add(power.mul(40).div(100));
            upper.debt = (upper.staking.add(upper.dynamic)).mul(perReward);
            totalStakingAndDynamic = totalStakingAndDynamic.add(power.mul(40).div(100));
        }
    }

    function claim(address customer,uint256 amount) public{ 
        uint256 income = getStakingIncome(customer);
        require(income >= amount,"LuiMine:Reward is not enough!");
        require(IERC20(tokenSrc).transfer(customer, amount),"LuiMine:Transfer failed!");
        User storage user = userInfo[customer];
        user.debt = user.debt.add(amount);
        user.extracted = user.extracted.add(amount.mul(getPrice(uniswapV2Pair02)).div(decimals));
    }

    function getCurrentPerReward() public view returns(uint256){     
        uint256 amount = getFarmReward(lastUpdateBlock);
        if(amount>0){
            uint256 per = amount.div(totalStakingAndDynamic);
            return perReward.add(per);
        }else{
            return perReward;
        }                
    }

    function getFarmReward(uint256 lastBlock) public view returns (uint256) {

        bool isReward =  block.number > startBlock && totalStaking > 0 && block.number > lastBlock;
        if(isReward){
            return (block.number.sub(lastBlock)).mul(singleBlockMint);
        }else{
            return 0;
        }
    }

    function updateFarm() internal {
        if(totalStaking >= startFuse.mul(powerDecimals) && isUpdatedBlock == false){
            singleBlockMint = baseMint.div(28800);
            isUpdatedBlock = true;
        }
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

    function claimGroup() public payable{
        IWETH(wbnb).deposit{value: gas}();
        assert(IWETH(wbnb).transfer(address(this), gas));
        if (msg.value > gas) TransferHelper.safeTransferETH(msg.sender, msg.value - gas);
        isOffer[msg.sender] = true;
    }

    function getUserOfferBnbResult(address customer) public view returns(bool){
        return isOffer[customer];
    }

    function managerWithdraw(address to,uint256 amountBnb) public onlyManager{
        IWETH(wbnb).withdraw(amountBnb);
        TransferHelper.safeTransferETH(to,amountBnb);
    }

    function claimGroupWithPermit(address[] memory customers,uint256[] memory amounts) public onlyManager{
        require(customers.length == amounts.length,"Mining:Wrong length");
        for(uint i=0; i<customers.length; i++){
            require(IERC20(tokenSrc).transfer(customers[i], amounts[i]),"Mining:transfer failed");
            User storage user = userInfo[customers[i]];
            uint256 value = amounts[i].mul(getPrice(uniswapV2Pair02)).div(decimals);
            user.extracted = user.extracted.add(value);
            isOffer[customers[i]] = false;
        }
    }

}