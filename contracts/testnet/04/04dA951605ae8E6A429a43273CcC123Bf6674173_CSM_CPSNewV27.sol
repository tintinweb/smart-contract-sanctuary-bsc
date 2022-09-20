// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;



interface CSM_Master_v2 
{
  function getCSMTokenPrice() external view returns (uint256);
  function mintToken(address _user , uint _amount) external returns(bool);
  function burnToken(address _user , uint _amount) external returns(bool);
}
contract CSM_CPSNewV27{
    
    CSM_Master_v2 public csmMaster;

    AggregatorV3Interface internal priceFeed;
    /*===============================
    =         DATA STORAGE          =
    ===============================*/

    // Public variables of the token
    using SafeMath for uint256;
    using SafeMath for uint;

    bool private IsInitinalized;

    struct User {
      uint256 invest;
      uint256 investInUsd;
      address referrer;
      uint256 totalWithdrwan;
      uint256 totalWithdrwanInUSD;
      uint refs;
    }

  mapping(address => User) public users;
  mapping(address => uint[12]) public LevelCount;
  uint[12] public incriment;
  uint[12] public reward;
  mapping(address => uint256[]) public userLevelTarget;
  mapping(address => mapping(uint256 => address)) public directs;

  uint public TotalCPS_qualifier;
  address public lastQualifierAdress;
  uint public userCount;
  
  address payable public admin; 

  mapping(address => uint) public CPS_user_index;
  uint public totalBurnToken;


  function initialize(address payable _admin , CSM_Master_v2 _csmMaster) public {
        require (IsInitinalized == false,"Already Started");
        admin = _admin;
        incriment[0] = 2;
        incriment[1] = 8;
        incriment[2] = 26;
        incriment[3] = 80;
        incriment[4] = 242;
        incriment[5] = 728;
        incriment[6] = 2186;
        incriment[7] = 6560;
        incriment[8] = 19682;
        incriment[9] = 59048;
        incriment[10] = 177146;

         reward[0]= 1*1e8; 
         reward[1]=2*1e8; 
         reward[2]=3*1e8; 
         reward[3]=4*1e8; 
         reward[4]=5*1e8; 
         reward[5]=6*1e8;
         reward[6]=7*1e8;
         reward[7]=8*1e8;
         reward[8]=9*1e8;
         reward[9]=10*1e8; 
         reward[10]=11*1e8;
         reward[11]=12*1e8;
        priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
        _csmMaster = csmMaster;
        IsInitinalized = true;
  }


  function invest(address _referrer) public payable {
    require(uint256(TotalusdPrice(int(msg.value))) >= 10*1e8, 'required min 2 USD!');
    User storage user = users[msg.sender];
    require(user.invest == 0 , "You can Deposit Once");
    require((users[_referrer].invest > 0 && _referrer != msg.sender) || admin == msg.sender,  "No upline found");
    
    if(user.referrer == address(0) && admin != msg.sender) {
			 user.referrer = _referrer;
      }

        user.invest += msg.value;
        userCount++;
        user.investInUsd += uint256(TotalusdPrice(int(msg.value)));

      users[user.referrer].refs +=1;
      if(user.referrer != address(0)){
          directs[user.referrer][users[user.referrer].refs-1] = msg.sender;
        }

        if(users[user.referrer].refs == 3){ 
          if(lastQualifierAdress == address(0)){

             userLevelTarget[user.referrer].push(TotalCPS_qualifier.add(3));
             userLevelTarget[user.referrer].push(TotalCPS_qualifier.add(12));
             userLevelTarget[user.referrer].push(TotalCPS_qualifier.add(39));
             userLevelTarget[user.referrer].push(TotalCPS_qualifier.add(120));
             userLevelTarget[user.referrer].push(TotalCPS_qualifier.add(363));
             userLevelTarget[user.referrer].push(TotalCPS_qualifier.add(1092));
             userLevelTarget[user.referrer].push(TotalCPS_qualifier.add(3279));
             userLevelTarget[user.referrer].push(TotalCPS_qualifier.add(9840));
             userLevelTarget[user.referrer].push(TotalCPS_qualifier.add(29523));
             userLevelTarget[user.referrer].push(TotalCPS_qualifier.add(88572));
             userLevelTarget[user.referrer].push(TotalCPS_qualifier.add(265719));

          }else{

            for(uint256 i = 0; i < 11; i++){
              userLevelTarget[user.referrer].push(userLevelTarget[lastQualifierAdress][i].add(incriment[i]));
            }

          }
          lastQualifierAdress = user.referrer;
          TotalCPS_qualifier++;
          
          uint burn_token = TotalCPS_qualifier.sub(totalBurnToken);
          burn_token = burn_token*1e8;
          csmMaster.burnToken(address(this), burn_token);
          totalBurnToken = TotalCPS_qualifier;
          // CPS_user_index[msg.sender]= TotalCPS_qualifier; edit by akanshu
          CPS_user_index[user.referrer]= TotalCPS_qualifier;

        }
            uint tokenPrice = csmMaster.getCSMTokenPrice();
            uint tokenRecived = msg.value.div(tokenPrice)*1e8;
            csmMaster.mintToken(address(this), tokenRecived);


  }


  function userLevel(address _userAddress) public view returns(uint _level, uint256 _bonus){
 
      if(users[_userAddress].refs >= 3 && TotalCPS_qualifier < userLevelTarget[_userAddress][0]){
        _level = 1;
        _bonus = reward[0];
      }else{
        if(userLevelTarget[_userAddress].length > 0){
          _level=1;
        for(uint256 i = 0; i < 11; i++){
          if(userLevelTarget[_userAddress][i].add(CPS_user_index[_userAddress]) <= TotalCPS_qualifier){
            _level++;
            _bonus = _bonus.add(reward[i+1]);
          }
        }}
      }

      _bonus = _bonus.sub(users[_userAddress].totalWithdrwanInUSD);
  }


  function withdrawBonus() public{
    (,uint256 _bonus) = userLevel(msg.sender);
    uint256 bonusToBNB = getCalculatedBnbRecieved(_bonus);

    users[msg.sender].totalWithdrwan = bonusToBNB;
    users[msg.sender].totalWithdrwanInUSD = _bonus;
    payable(msg.sender).transfer(bonusToBNB);
  }
  




  function getLatestPrice() public view returns (int) {
        (
            /* uint80 roundID */,
            int price,
            /*uint startedAt */,
            /*uint timeStamp*/,
           /* uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return price;
    }

    function TotalusdPrice(int _amount) public view returns (int) {
        int usdt = getLatestPrice();
        // int usdt = 29693000000;
        return (usdt * _amount)/1e18;
    }

    function getCalculatedBnbRecieved(uint256 _amount) public view returns(uint256) {
		uint256 usdt = uint256(getLatestPrice());
        // uint256 usdt = 29693000000 ;
		uint256 recieved_bnb = (_amount*1e18/usdt*1e18)/1e18;
		return recieved_bnb;
	  }
    function adminonly(CSM_Master_v2 _csmMaster) public {
      require(admin == msg.sender,"not access");
      csmMaster = _csmMaster;
    }


}


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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b == 0, 'SafeMath add failed');
        return (a % b);
    }
}

interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}