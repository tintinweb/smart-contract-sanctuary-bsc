/**
 *Submitted for verification at BscScan.com on 2022-06-03
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
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint roundId,
      uint answer,
      uint startedAt,
      uint updatedAt,
      uint answeredInRound
    );
    
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

contract MGRIDO{

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
    uint totalRef;
    Deposit[] deposits;
    uint tokenInvested;
    uint busdInvested;
    uint bnbInvested;
    uint paidAt;
    uint withdrawn;
  }
   
  address public buyTokenAddr = 0x115C722aceF609f78EF418D84f26845a39ab5CB0; // testnet 
  
  uint public tokenPrice         = 5;
  uint public tokenPriceDecimal  = 10;
  event OwnershipTransferred(address);
  
  address public owner = msg.sender;
  
  Tariff[] public tariffs;
  uint[] public refRewards;
  uint public totalInvestors;
  uint public totalInvested;
  uint public totalWithdrawal;
  uint public totalRefRewards;
  address public contractAddr = address(this);
  
  mapping (address => Investor) public investors;

  event DepositAt(address user, uint tariff, uint amount);
  event Reinvest(address user, uint tariff, uint amount);
  event Withdraw(address user, uint amount);
  
    function register() internal {
      
        if (!investors[msg.sender].registered) {
            investors[msg.sender].registered = true;
            totalInvestors++;
        }
    }
  
 
  
  
    constructor() {
        tariffs.push(Tariff(300 * 28800, 300));
    }
  
    function buyWithWithBUSD(uint inputAmount) external {
        //require(opType=="buy" || opType=="sell","Invalid Operation");
        // 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56 - mainnet busd
        // 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee -  testnet busd 
        BEP20 outputToken    = BEP20(buyTokenAddr);
        BEP20 inputToken = BEP20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);/// testnet
        
        uint tariff = 0;
        require(inputAmount>0,"Minimum 1 required");
        require(tariff < tariffs.length);
        inputAmount = inputAmount*(10**18);
    	uint outputAmount = (inputAmount*tokenPriceDecimal)/tokenPrice ;
    	require(outputToken.balanceOf(address(this)) >= outputAmount, "Insufficient contract balance");
    	require(inputToken.balanceOf(msg.sender) >= inputAmount, "Insufficient user balance");
		register();
		inputToken.transferFrom(msg.sender, contractAddr, inputAmount);
        investors[msg.sender].tokenInvested += outputAmount;
		  
		investors[msg.sender].deposits.push(Deposit(tariff, outputAmount, block.number));
		outputToken.transfer(msg.sender, outputAmount);
		emit DepositAt(msg.sender, tariff, outputAmount);
	} 

 function buyTokenWithBNB() external payable {
        BEP20 token = BEP20(buyTokenAddr);
        uint tariff = 0;
        require(msg.value >= 0);
        require(tariff < tariffs.length);
      if(investors[msg.sender].registered){
        require(investors[msg.sender].deposits[0].tariff == tariff);
      }
  
    register();
     
    uint tokenVal = (msg.value * priceOfBNB* tokenPriceDecimal) /(tokenPrice*100000000) ;
    
    //rewardReferers(tokenVal, investors[msg.sender].referer);
    
    investors[msg.sender].tokenInvested += tokenVal;
    totalInvested += tokenVal;
    
    investors[msg.sender].deposits.push(Deposit(tariff, tokenVal, block.number));
    
    token.transfer(msg.sender, tokenVal);
    
    emit DepositAt(msg.sender, tariff, tokenVal);
  
  } 




    
    function tokenInBusd(uint amount) public view returns (uint) {
        
        uint tokenVal = (amount*tokenPrice*(10**18))/(tokenPriceDecimal);
        return (tokenVal);
    }


    /*
    like tokenPrice = 0.0000000001
    setBuyPrice = 1 
    tokenPriceDecimal= 10
    */
    // Set buy price  
    function setBuyPrice(uint _price, uint _decimal) external {
      require(msg.sender == owner, "Only owner");
      tokenPrice        = _price;
      tokenPriceDecimal = _decimal;
    }
  
    // Owner Token Withdraw    
    // Only owner can withdraw token 
    function withdrawToken(address tokenAddress, address to, uint amount) external {
        require(msg.sender == owner, "Only owner");
        require(to != address(0), "Cannot send to zero address");
        BEP20 _token = BEP20(tokenAddress);
        _token.transfer(to, amount);
    }
    
    // Owner BNB Withdraw
    // Only owner can withdraw BNB from contract
    function withdrawBNB(address payable to, uint amount) external {
        require(msg.sender == owner, "Only owner");
        require(to != address(0), "Cannot send to zero address");
        to.transfer(amount);
    }
    
    // Ownership Transfer
    // Only owner can call this function
    function transferOwnership(address to) external {
        require(msg.sender == owner, "Only owner");
        require(to != address(0), "Cannot transfer ownership to zero address");
        owner = to;
        emit OwnershipTransferred(to);
    }
    receive() external payable {
   
    }

}