/**
 *Submitted for verification at BscScan.com on 2022-02-13
*/

// SPDX-License-Identifier: none
pragma solidity ^0.8.11;
/**     
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }
  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }
  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a); 
    return c;
  }
}

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
interface BEP20{
    function totalSupply() external view returns (uint theTotalSupply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract Ownable {
  address public owner;  
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor() {
    owner = msg.sender;
  }
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
}



contract AnheraBSC is Ownable {  
    PriceConsumerV3 priceConsumerV3 = new PriceConsumerV3();
    uint public priceOfBNB = priceConsumerV3.getThePrice();
    uint public tokenPrice         = 5;
    uint public tokenPriceDecimal  = 2;
    address public tokenAddr       = 0xFD8d946352609a86Fd4689764FB13e21FD34a2bA;
    BEP20 token; 
    address contractAddress = address(this);
    constructor() {
        token = BEP20(tokenAddr);
    }
    using SafeMath for uint256;       
    event DepositAt(address user, uint tariff, uint amount);    

    function deposit(uint _tariff, uint _amount) external payable {
        address sender = msg.sender;
        uint amount   = _amount * 10**18;
        token.approve(contractAddress, amount);
        token.transferFrom(sender, contractAddress, amount);
        emit DepositAt(msg.sender, _tariff, msg.value);
    }

    function buyTokenWithBNB() external payable {
      token = BEP20(tokenAddr);
      uint tariff = 0;
      require(msg.value >= 0);
      
      uint tokenVal = (msg.value * priceOfBNB* 10**tokenPriceDecimal) /(tokenPrice*100000000) ;

      token.transfer(msg.sender, tokenVal);

      emit DepositAt(msg.sender, tariff, tokenVal);
    } 


    function buyTokenWithBUSD(uint busdAmount) external {
      BEP20 sendtoken    = BEP20(tokenAddr);
      busdAmount         = busdAmount * 10**18;
      BEP20 receiveToken = BEP20(0x72478b6F67364e73ebE93e979A8be3901EA9E5A0);///Testnet
      uint tariff        = 0;
      uint tokenVal      = (busdAmount* 10**tokenPriceDecimal ) /tokenPrice;

      require(sendtoken.balanceOf(address(this)) >= tokenVal, "Insufficient contract balance");
      require(receiveToken.balanceOf(msg.sender) >= busdAmount, "Insufficient user balance");
      receiveToken.transferFrom(msg.sender, contractAddress, busdAmount);
      sendtoken.transfer(msg.sender, tokenVal);
      emit DepositAt(msg.sender, tariff, tokenVal);
    } 

    function withdrawalToAddress(address payable _to, address _token, uint _amount) external{
        require(msg.sender == owner);
        require(_amount != 0, "Zero amount error");
        BEP20 tokenObj;
        uint amount   = _amount * 10**18;
        tokenObj = BEP20(_token);
        tokenObj.transfer(_to, amount);
    }

    function tokenInBNB(uint amount) public view returns (uint) {
        uint tokenVal = ( amount * priceOfBNB* 10**tokenPriceDecimal) /(tokenPrice*100000000);
        return (tokenVal);
    }
    function tokenInBUSD(uint amount) public view returns (uint) {
        amount        = amount * 10**18;
        uint tokenVal = (amount * 10**tokenPriceDecimal ) /tokenPrice ;
        return (tokenVal);
    }
    /*
    like tokenPrice = 0.05
    setBuyPrice = 5
    tokenPriceDecimal= 2
    */
    // Set buy price  
    function setBuyPrice(uint _price, uint _decimal) public {
      require(msg.sender == owner, "Only owner");
      tokenPrice        = _price;
      tokenPriceDecimal = _decimal;
    }

    function transferOwnership(address _to) public {
        require(msg.sender == owner, "Only owner");
        address oldOwner  = owner;
        owner = _to;
        emit OwnershipTransferred(oldOwner,_to);
    }
}