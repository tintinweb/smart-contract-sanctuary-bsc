/**
 *Submitted for verification at BscScan.com on 2022-12-23
*/

// SPDX-License-Identifier: none
pragma solidity ^0.8.12;
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
        priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE); // Mainnet BNB/USD
        //priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526); // Testnet BNB/USD
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

contract MetaSocialityStaking is Ownable {   
    BEP20 token; 
    uint public MIN_DEPOSIT_BUSD = 1 ;
    
    address public tokenAddr = 0x237EE7E111bb52034e3e3c95a12F7b6645Bf192c; //mainnet
    address public tokenOwnerAddr = 0x82C985Db0dc47f5431E5cAFc6c2352910c87C86e; //testnet
    address contractAddress = address(this);
    uint public tokenPrice         = 1;
    uint public tokenPriceDecimal  = 0;

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

    mapping (address => Investor) public investors;

    Tariff[] public tariffs;
    uint public totalInvested;
    address public contractAddr = address(this);
    constructor() {
        token = BEP20(tokenAddr);
        tariffs.push(Tariff(300 * 28800, 300));
        tariffs.push(Tariff(35  * 28800, 157));
        tariffs.push(Tariff(30  * 28800, 159));
        tariffs.push(Tariff(25  * 28800, 152));
        tariffs.push(Tariff(18  * 28800, 146));
    }
    using SafeMath for uint256;       
    event TokenAddressChaged(address tokenChangedAddress);    
    event DepositAt(address user, uint tariff, uint amount);  
    event DepositBNBAt(address user, uint tariff, uint amount,uint bnbAmt);    
    function deposit(uint _tariff, uint _amount) external payable {
        address sender = msg.sender;
        uint amount   = _amount * 10**18;
        token.approve(contractAddress, amount);
        token.transferFrom(sender, contractAddress, amount);
        emit DepositAt(msg.sender, _tariff, msg.value);
    }
    function withdrawalToAddress(address _to, address _token, uint _amount) external{
        require(msg.sender == owner, "Only owner");
        require(_amount != 0, "Zero amount error");
        BEP20 tokenObj;
        uint amount   = _amount * 10**18;
        tokenObj = BEP20(_token);
        tokenObj.transfer(_to, amount);
    }

   function withdrawalBnb(address payable _to, uint _amount) external{
        require(msg.sender == owner, "Only owner");
        require(_amount != 0, "Zero amount error");
        
        _to.transfer(_amount);
    }

    function transferOwnership(address _to) public {
        require(msg.sender == owner, "Only owner");
        address oldOwner  = owner;
        owner = _to;
        emit OwnershipTransferred(oldOwner,_to);
    }
    function changeToken(address _tokenAdd) public {
        require(msg.sender == owner, "Only owner");
        tokenAddr = _tokenAdd;
        token     = BEP20(tokenAddr);
        emit TokenAddressChaged(_tokenAdd);
    }

    function changeTokenOwnerAddr(address _tokenOwnerAddr) public {
        require(msg.sender == owner, "Only owner");
        tokenOwnerAddr = _tokenOwnerAddr;
    }

    // Set buy price decimal i.e. 
    function setMinBusd(uint _busdAmt) public {
      require(msg.sender == owner, "Only owner");
      MIN_DEPOSIT_BUSD = _busdAmt;
    }

    function updateTokenPrice(uint _tokenPrice,uint _tokenPriceDecimal) public {
      require(msg.sender == owner, "Only owner");
      tokenPrice = _tokenPrice;
      tokenPriceDecimal = _tokenPriceDecimal;
    }

    function buyTokenWithBUSD(uint busdAmount) external {
            require( (busdAmount >= (MIN_DEPOSIT_BUSD*1000000000000000000)), "Minimum limit is 1");
            BEP20 sendtoken    = BEP20(tokenAddr);
            //BEP20 receiveToken = BEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);///Mainnet
            BEP20 receiveToken = BEP20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);///Testnet
            
            uint tariff = 0;
            require(tariff < tariffs.length);
            uint tokenVal = (busdAmount* 10**tokenPriceDecimal) / tokenPrice ; 
            
            require(token.balanceOf(tokenOwnerAddr) >= tokenVal, "Insufficient contract balance");
            require(receiveToken.balanceOf(msg.sender) >= busdAmount, "Insufficient user balance");
            receiveToken.transferFrom(msg.sender, contractAddr, busdAmount);
            investors[msg.sender].invested += tokenVal;
            totalInvested += tokenVal;
            investors[msg.sender].deposits.push(Deposit(tariff, tokenVal, block.timestamp));
            token.transferFrom(tokenOwnerAddr,contractAddr, tokenVal);
            emit DepositAt(msg.sender, tariff, tokenVal);
    
    } 

    function tokenInBNB(uint amount) public view returns (uint) {
        uint tokenVal = (amount * priceOfBNB* 10**tokenPriceDecimal) /(tokenPrice*100000000*1000000000000000000) ;
        return (tokenVal);
    }
  
    function tokenInBUSD(uint amount) public view returns (uint) {
        uint tokenVal = (amount * 10**tokenPriceDecimal ) /(tokenPrice*1000000000000000000) ;
        return (tokenVal);
    }
}