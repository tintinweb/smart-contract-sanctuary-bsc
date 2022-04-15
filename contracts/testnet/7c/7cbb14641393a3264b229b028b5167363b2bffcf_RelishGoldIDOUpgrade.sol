/**
 *Submitted for verification at BscScan.com on 2022-04-15
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

contract RelishGoldIDOUpgrade{

    PriceConsumerV3 priceConsumerV3 = new PriceConsumerV3();
    uint public priceOfBNB = priceConsumerV3.getThePrice();

  struct Tariff {
    uint time;
    uint percent;
  }
  
  struct Deposit {
    uint tariff;
    uint amount;
    bytes32 opType;
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
   
  //address public buyTokenAddr = 0x3f5241b0f8949e123728a6246e655698F6398f42; // mainnet 
  address public buyTokenAddr = 0xC1303592B7cf958eecbcbEC6D370506835Ec86a0; // mainnet 
  uint public tokenPrice         = 67;
  uint public tokenPriceDecimal  = 100;
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

  event DepositAt(address user, uint tariff, uint amount, bytes32 opType);
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
  
    function buyOrSellWithWithBUSD(uint inputAmount,bytes32 opType) external {
        require(opType=="buy" || opType=="sell","Invalid Operation");
        // 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56 - mainnet busd
        // 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee -  testnet busd 
        BEP20 outputToken    = (opType=="buy") ?  BEP20(buyTokenAddr) : BEP20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);
        BEP20 inputToken = (opType=="buy") ? BEP20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee) : BEP20(buyTokenAddr);/// mainnet
        
        uint tariff = 0;
        require(inputAmount>0,"Minimum 1 required");
        require(tariff < tariffs.length);
        inputAmount = inputAmount*(10**18);
    	uint outputAmount = (opType=="buy") ? (inputAmount*tokenPriceDecimal)/tokenPrice :  (inputAmount*tokenPrice)/tokenPriceDecimal ;
    	require(outputToken.balanceOf(address(this)) >= outputAmount, "Insufficient contract balance");
    	require(inputToken.balanceOf(msg.sender) >= inputAmount, "Insufficient user balance");
		register();
		inputToken.transferFrom(msg.sender, contractAddr, inputAmount);
        if(opType=="buy") {
            investors[msg.sender].tokenInvested += outputAmount;
        }
        else {
            investors[msg.sender].busdInvested += outputAmount;
        }
		  
		investors[msg.sender].deposits.push(Deposit(tariff, outputAmount, opType, block.number));
		outputToken.transfer(msg.sender, outputAmount);
		emit DepositAt(msg.sender, tariff, outputAmount,opType);
	} 


    function SelWithBNB(uint inputAmount, address payable msgSender) external {
        require(msgSender==msg.sender,"Invalid Address");
        BEP20 inputToken = BEP20(buyTokenAddr);
        require(inputToken.balanceOf(msg.sender) >= inputAmount, "Insufficient user balance");
        uint tariff = 0;
        require(inputAmount >= 0,"Invalid Amount");
        register();
        uint outputAmount = (inputAmount * (tokenPrice*100000000)) / (priceOfBNB * tokenPriceDecimal);
        //uint tokenVal = (msg.value * priceOfBNB* tokenPriceDecimal) /(tokenPrice*100000000) ;
        
        investors[msg.sender].bnbInvested += outputAmount;
        
        investors[msg.sender].deposits.push(Deposit(tariff, outputAmount,"sell", block.number));
        
        inputToken.transfer(contractAddr, inputAmount);
        msgSender.transfer(outputAmount);
        
        emit DepositAt(msg.sender, tariff, outputAmount, "sell");
    
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


}