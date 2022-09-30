/**
 *Submitted for verification at BscScan.com on 2022-09-30
*/

// SPDX-License-Identifier: none
pragma solidity ^0.8.8;

interface AggregatorV3Interface {

  function decimals() external view returns (uint);
  function description() external view returns (string memory);
  function version() external view returns (uint);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.

  function latestRoundData()
    external
    view
    returns (
      uint roundId,
      uint answer,
      uint startedAt,
      uint updatedAt,
      uint answeredInRound
    );

}
contract PriceConsumerV3 {

    AggregatorV3Interface internal priceFeed;

    constructor() {
        //priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE); // Mainnet BNB/USD
        priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526); // Testnet BNB/USD
    }


    function getThePrice() public view returns (uint) {
        (
            uint roundID, 
            uint price,
            uint startedAt,
            uint timeStamp,
            uint answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }
}

interface BEP20 {
    function totalSupply() external view returns (uint theTotalSupply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract ZHEPIDO{
    
    PriceConsumerV3 priceConsumerV3 = new PriceConsumerV3();
    uint public priceOfBNB = priceConsumerV3.getThePrice();
    
  struct Tariff {
    uint time;
    uint percent;
  }
  
  struct Deposit {
    uint tariff;
    uint amount;
    uint at;
  }
  
  struct Investor {
    bool registered;
   Deposit[] deposits;
    uint invested;
    uint paidAt;
    uint withdrawn;
  }
 
    
  uint public MIN_DEPOSIT_BUSD = 1 ;
  
  //address public buyTokenAddr = 0x955792c0841F398f7225A12d3DdD8433915c833E;  //MAINNET
  address public buyTokenAddr = 0x66C1598Eb59B0FD2c41Da404C2332035188F2B67; // TESTNET
  
  uint public tokenPrice         = 10;
  uint public tokenPriceDecimal  = 2;
  event OwnershipTransferred(address);
  
  address public owner = msg.sender;
  
  
  uint public totalInvestors;
  uint public totalInvested;
  uint public totalWithdrawal;
  address public contractAddr = address(this);
  
  mapping (address => Investor) public investors;
  event DepositAt(address user, uint tariff, uint amount);
  event Reinvest(address user, uint tariff, uint amount);
  event Withdraw(address user, uint amount);
  


  
  
  constructor() {
    
  }


  
  function buyTokenWithBNB() external payable {
    BEP20 token = BEP20(buyTokenAddr);
    require(msg.value >= 0);
     
     
    uint tokenVal = (msg.value * priceOfBNB* 10**tokenPriceDecimal) /(tokenPrice*100000000) ;
    investors[msg.sender].invested += tokenVal;
    totalInvested += tokenVal;
    
   
    
    token.transfer(msg.sender, tokenVal);
    
    emit DepositAt(msg.sender, 0, tokenVal);
  
  } 
  
   function buyTokenWithBUSD(uint busdAmount) external {
        require( (busdAmount >= (MIN_DEPOSIT_BUSD*1000000000000000000)), "Minimum limit is 1");
        BEP20 sendtoken    = BEP20(buyTokenAddr);
        //BEP20 receiveToken = BEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);///Mainnet
        BEP20 receiveToken = BEP20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);///Testnet
        
        uint tokenVal = (busdAmount* 10**tokenPriceDecimal) / tokenPrice ; 
        
        require(sendtoken.balanceOf(address(this)) >= tokenVal, "Insufficient contract balance");
        require(receiveToken.balanceOf(msg.sender) >= busdAmount, "Insufficient user balance");
      
        receiveToken.transferFrom(msg.sender, contractAddr, busdAmount);
        investors[msg.sender].invested += tokenVal;
        totalInvested += tokenVal;
       
        sendtoken.transfer(msg.sender, tokenVal);
        emit DepositAt(msg.sender, 0, tokenVal);
  
  } 
  
  function myTariff() public view returns (uint) {
      
      uint tariff = investors[msg.sender].deposits[0].tariff;
      return tariff;
    
    }
  function usd_price() public view returns (uint) {
      return priceOfBNB;
  }
  
    function myTotalInvestment() public view returns (uint) {
        Investor storage investor = investors[msg.sender];
        uint amount = investor.invested;
        return amount;
    }
  
    function tokenInBNB(uint amount) public view returns (uint) {
        uint tokenVal = (amount * priceOfBNB* 10**tokenPriceDecimal) /(tokenPrice*100000000*1000000000000000000) ;
        return (tokenVal);
    }
  
    function tokenInBUSD(uint amount) public view returns (uint) {
        uint tokenVal = (amount * 10**tokenPriceDecimal ) /(tokenPrice*1000000000000000000) ;
        return (tokenVal);
    }
    /*
    like tokenPrice = 0.0000000001
    setBuyPrice = 1 
    tokenPriceDecimal= 10
    */
    // Set buy price  
    function setBuyPrice(uint _price, uint _decimal) public {
      require(msg.sender == owner, "Only owner");
      tokenPrice        = _price;
      tokenPriceDecimal = _decimal;
    }
    
    
    // Set buy price decimal i.e. 
    function setMinBusd(uint _busdAmt) public {
      require(msg.sender == owner, "Only owner");
      MIN_DEPOSIT_BUSD = _busdAmt;
    }
    // Owner Token Withdraw    
    // Only owner can withdraw token 
    function withdrawToken(address tokenAddress, address to, uint amount) public returns(bool) {
        require(msg.sender == owner, "Only owner");
        require(to != address(0), "Cannot send to zero address");
        BEP20 _token = BEP20(tokenAddress);
        _token.transfer(to, amount);
        return true;
    }
    
    // Owner BNB Withdraw
    // Only owner can withdraw BNB from contract
    function withdrawBNB(address payable to, uint amount) public returns(bool) {
        require(msg.sender == owner, "Only owner");
        require(to != address(0), "Cannot send to zero address");
        to.transfer(amount);
        return true;
    }
    
    // Ownership Transfer
    // Only owner can call this function
    function transferOwnership(address to) public returns(bool) {
        require(msg.sender == owner, "Only owner");
        require(to != address(0), "Cannot transfer ownership to zero address");
        owner = to;
        emit OwnershipTransferred(to);
        return true;
    }
    // BNB Price Update
    // Only owner can call this function
    function bnbpriceChange() public returns(bool) {
        require(msg.sender == owner, "Only owner");
        priceOfBNB = priceConsumerV3.getThePrice();
        return true;
    }
}