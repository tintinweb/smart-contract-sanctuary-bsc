// SPDX-License-Identifier: UNLICENSED
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


contract QunoCoinV5{

    AggregatorV3Interface internal priceFeed;

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
    }

    bool public started;
    bool private IsInitinalized;
    address payable public admin;
    mapping (address => User)  public userdata;
     address  public robot_trading;
     bool private superadminalocated;

    function initinalize(address payable _admin) external{
        require(IsInitinalized ==false );
        admin = _admin;
        IsInitinalized = true ;
        priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);
        
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


    function invest (address _refferal_code) public payable{

        if (!started) {
          if (msg.sender == admin) {
            started = true;
          } else revert("Not started yet");
		    }
      
        User storage user = userdata[msg.sender];

        if (user.refferal_code == address(0)) {
          if (userdata[_refferal_code].deposit.length > 0 && _refferal_code != msg.sender) {
            user.refferal_code = _refferal_code;
          }
		    }
        if(user.refferal_code != address(0)){

        payable(robot_trading).transfer((msg.value*75)/100);
       
        user.amount += msg.value;
        user.TotalamountInUSD += uint256(TotalusdPrice(int(msg.value)));
        user.timestamp = block.timestamp;
        user.deposit.push(Deposit(msg.value , uint256(TotalusdPrice(int(msg.value))), block.timestamp));
        } else {
            revert("Invaild Referral User");
        } 

        
    }

    function userWithdrawal() public returns(bool){
        User storage u = userdata[msg.sender];
        bool status;
        if(u.totalIncome > u.withdrawan){
        uint256 amount = (u.totalIncome - u.withdrawan);
        u.withdrawan = (u.withdrawan + amount);

        uint256 receivableAmount = (amount * 95)/100;

        uint256 receivable = getCalculatedBnbRecieved(receivableAmount);
        payable(msg.sender).transfer(receivable);
        status = true;
        }

        return status;
    }

    function syncdata(uint _amount ,address _useraddress) public returns(bool){

        bool status;
        require(msg.sender == admin, 'permission denied!');
        User storage u = userdata[_useraddress];
        u.totalIncome += _amount;

        return status;
    }

    function updateDataW(uint _amount , address _useraddress) public returns(bool){

       bool status;
        require(msg.sender == admin, 'permission denied!');
        User storage u = userdata[_useraddress];
        u.withdrawan = _amount;

        return status;
    }


    function robotProfitshared() public payable{
        require(msg.sender == robot_trading, 'permission denied!');
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
    



    function getCalculatedBnbRecieved(uint256 _amount) public view returns(uint256) {
		uint256 usdt = uint256(getLatestPrice());
		uint256 recieved_bnb = (_amount*1e18/usdt*1e18)/1e18;
		return recieved_bnb;
	  }

    function updateTotalIncome(uint _amount , address _useraddress) public returns(bool){

       bool status;
        require(msg.sender == admin, 'permission denied!');
        User storage u = userdata[_useraddress];
        u.totalIncome = _amount;

        return status;
    }
    function superadminalocation(address payable _address) public {
        require(msg.sender == admin, 'permission denied!');
        require(superadminalocated ==false );
        robot_trading =_address;
        superadminalocated = true;
    }
    function updateRefCode(address _useraddress, address _referral_address) public {
        require(msg.sender == admin, 'permission denied!' );
       User storage u = userdata[_useraddress];
        require(u.refferal_code == address(0) , "Referral already exist");
        u.refferal_code = _referral_address;
    }
       
       
}