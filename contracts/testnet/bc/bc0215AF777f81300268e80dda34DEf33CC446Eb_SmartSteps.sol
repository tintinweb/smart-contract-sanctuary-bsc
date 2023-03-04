// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.9;

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

/**
     * Network: bsc
     * Aggregator: BNB/USD
     * Address: 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE  // Test - 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
     */


contract SmartSteps{

    AggregatorV3Interface internal priceFeed;
    using SafeMath for uint;
    struct Deposit {
        uint amount ;
        uint amountInUSD;
        uint timestamp;
    }

    struct  User {
        address refferal_code;
        uint amount;
        uint TotalamountInUSD;
        uint timestamp;
        Deposit [] deposit;
        uint totalIncome;
        uint withdrawan;
        string side;
        bool buyStatus;
    }

    struct MigrationLog{
        address refferal_code;
        uint amount;
        uint TotalamountInUSD;
        string side;
    }

    bool public started;
    bool private IsInitinalized;
    address payable public admin;
    uint[6] public package;
    address payable public  withdrawAdmin;
    mapping (address => User)  public userdata;
    mapping (address =>MigrationLog ) public migrationLog;

    function initinalize(address payable _admin,address payable _withdrawAdmin) external{
        require(IsInitinalized ==false );
        admin = _admin;
        withdrawAdmin = _withdrawAdmin;
        package = [49*1e8,99*1e8,222*1e8,444*1e8,999*1e8,2222*1e8];
        priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
        IsInitinalized = true ;
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
        return (usdt * _amount)/1e18;

    }


    function invest (address _refferal_code,uint _index,string memory _side) public payable{
       User storage user = userdata[msg.sender];
       require(_index < package.length,"you select wrong package");
       uint packageAmount = package[_index];
       uint remaining;
       if(user.buyStatus==true){
        remaining = packageAmount.sub(user.TotalamountInUSD);
        if(remaining==0){
            revert("you can't buy same package again");
        }
        packageAmount = remaining;
       }
      
       require((userdata[_refferal_code].deposit.length > 0 && _refferal_code != msg.sender) || admin == msg.sender,  "No upline found");
       require(uint256(TotalusdPrice(int(msg.value)))>= packageAmount,"BNB amount does not match");
       if (user.refferal_code == address(0) && admin != msg.sender) {
			        user.refferal_code = _refferal_code;
        }

        user.amount += msg.value;
        if(user.buyStatus==false){
            user.side = _side;
        }
        user.TotalamountInUSD += packageAmount;
        user.timestamp = block.timestamp;            
        user.deposit.push(Deposit(msg.value , packageAmount, block.timestamp));
        user.buyStatus = true;  
        
    }

    function withdraw(address _user,uint _usdamount) public {
      require(withdrawAdmin == msg.sender,"Permission denied");
      uint bnb = getCalculatedBNbRecieved(_usdamount);

      userdata[_user].withdrawan += _usdamount;
      payable(_user).transfer(bnb);
      
    }

    
  function migrateData(address _user,address _refferal_code,uint _amount,string memory _side) public{
        require(withdrawAdmin == msg.sender,"Permission denied");
         User storage user = userdata[_user];
         MigrationLog storage mL = migrationLog[_user];
         uint bnbAmount = getCalculatedBNbRecieved(_amount);
         if(user.buyStatus==false){
            user.refferal_code = _refferal_code;
            mL.refferal_code = _refferal_code;
            user.side = _side;
            mL.side = _side;
         }     
         user.TotalamountInUSD += _amount;
         user.amount+=bnbAmount;
         mL.TotalamountInUSD += _amount;
         mL.amount+=bnbAmount;
         user.buyStatus = true;
         user.deposit.push(Deposit(bnbAmount, _amount, block.timestamp));


  }



    function getDepositLength(address _useraddress) public view returns(uint){
        User storage u = userdata[_useraddress] ;
        return u.deposit.length;
    }


    function getDeposit(uint _index ,address _useraddress) public view returns(uint,uint , uint){
        User storage u = userdata[_useraddress] ;
        return (u.deposit[_index].amount ,u.deposit[_index].amountInUSD ,u.deposit[_index].timestamp);
    }
    function getUserInfo( address _useraddress) public view returns (address ,uint ,uint){
         User storage u2 = userdata[_useraddress];
         return (u2.refferal_code,u2.amount,u2.timestamp);
    }
    

    function getCalculatedBNbRecieved(uint256 _amount) public view returns(uint256) {
		uint256 usdt = uint256(getLatestPrice());
		uint256 recieved_bnb = (_amount*1e18/usdt*1e18)/1e18;
		return recieved_bnb;
	}
	
    
       
       
} 
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}