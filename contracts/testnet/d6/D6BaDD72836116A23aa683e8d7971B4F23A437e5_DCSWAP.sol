/**
 *Submitted for verification at BscScan.com on 2023-03-10
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IBEP20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
  constructor ()  { }

  function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
  }

  function _msgData() internal view returns (bytes memory) {
    this; 
    return msg.data;
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


contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor ()  {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

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

contract DCSWAP is Context, Ownable {
    
    using SafeMath for uint256;
    uint256 public totalUSDT=0;
    uint256 public totalBNB=0;
   
    bool public  hasStart=true;
    address[]  public _useraddress;
    uint256 public airdrop = 10;
    uint256 public rewards=5;     
    uint256 public dropTokens=0;     
    uint256 public dropLimit=500000000 * 10**18;     
    address[]  public _airaddress;

    uint256 public endDate=block.timestamp.add(30 days);
    uint256 public startDate=block.timestamp;
    uint256 public refferalPercentage = 1000;
    uint256 public refferalDivider = 10000;
    uint256 public tokenPerUsdBNB=2000;
    uint256 public tokenPerUsdUSDT=2000;
    uint256 public BNBbuyLimit = 0.000001 ether;
    uint256 public USDTbuyLimit = 0.0001 ether;

    uint256 public DIVIDER = 10000;
    AggregatorV3Interface public priceFeedBnb;
    AggregatorV3Interface public priceFeedUSDT;
    address public USDT = 0x337610d27c682E347C9cD60BD4b3b107C9d34dDd; // TUSD Testnet 
    address public TOKEN = 0x1572604ed2728f18dFf1c2fC0c12DE4D1509BDbF; // TESTNET
    IBEP20 public token=IBEP20(TOKEN);    
    constructor(address _tokenAddress){
      TOKEN = _tokenAddress;
      priceFeedBnb = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526); // testnet
      // 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE  mainnet BNB/USD
      priceFeedUSDT = AggregatorV3Interface(0xEca2605f0BCF2BA5966372C99837b1F182d3D620); // testnet
      // 0xB97Ad0E74fa7d920791E90258A6E2085088b4320 // mainnet USDT/USD
    }

    function toggleSale(bool _sale) external onlyOwner returns (bool){
        hasStart=_sale;
        return true;
    }


   function getLatestPriceBnb() public view returns (uint256) {
        (,int price,,,) = priceFeedBnb.latestRoundData();
        return uint256(price).div(1e8);
    }
    
    function getLatestPriceUSDT() public view returns (uint256) {
        (,int price,,,) = priceFeedUSDT.latestRoundData();
        return uint256(price).div(1e8);
    }    


  /**
   * @dev Returns the bep token owner.
   */
   function buyToken(address _currency , uint256 _amount,address _refferalAddress) public payable{
        require(hasStart,"Sale is not started");
        require(block.timestamp>startDate,"Sale has not stared yet!");
        require(block.timestamp<endDate,"Sale Completed"); 
       
        if(_currency==USDT){ 
            require(_amount > 0,"Amount must be greater then zero");
            require(USDTbuyLimit >= _amount,"Amount must be greater then given range");
            uint256 numberOfTokens=bnbToToken(_amount,USDT);
            require(numberOfTokens <= token.balanceOf(address(this)),"Insufficient Funds for Transfer");
            if(_refferalAddress != address(0)){
                uint256 refferAmount = numberOfTokens.mul(refferalPercentage).div(refferalDivider);
                token.transfer(_refferalAddress, refferAmount);    
            }
            IBEP20(USDT).transferFrom(msg.sender,owner(), _amount);
            token.transfer(msg.sender, numberOfTokens);
            totalUSDT=totalUSDT.add(_amount);
        }else{  
            require(msg.value > 0,"Amount must be greater then zero");
            require(BNBbuyLimit >= msg.value,"Amount must be greater then given range");
            uint256 numberOfTokens=bnbToToken(msg.value,address(this));        
            require(numberOfTokens <= token.balanceOf(address(this)),"Insufficient Funds for Transfer");
            if(_refferalAddress != address(0)){
                uint256 refferAmount = numberOfTokens.mul(refferalPercentage).div(refferalDivider);
                token.transfer(_refferalAddress, refferAmount);    
            }            
            payable(owner()).transfer(msg.value);
            token.transfer(msg.sender, numberOfTokens);
            totalBNB=totalBNB.add(_amount);
        } 
        if(!checkExitsAddress(msg.sender)){
            _useraddress.push(msg.sender);
         }     
   }
     

    // CHANGE REFFERAL PERCENTAGE
    function setRefferalPercentage(uint256 _refferalPercentage) public onlyOwner {
        require(_refferalPercentage>0,"Percentage should be greater then zero");
        require(_refferalPercentage<=refferalDivider,"Percentage should less then current divider");
        refferalPercentage = _refferalPercentage;
    }

  // to change Price of the token
    function changePrice(uint256 _tpuBNB,uint256 _tpuUSDT ) external onlyOwner{
        tokenPerUsdBNB = _tpuBNB;
        tokenPerUsdUSDT=_tpuUSDT;
    }
    
    
    function checkExitsAddress(address _userAdd) private view returns (bool){
       bool found=false;
        for (uint i=0; i<_useraddress.length; i++) {
            if(_useraddress[i]==_userAdd){
                found=true;
                break;
            }
        }
        return found;
    }
    // to check number of token for given BNB
    function bnbToToken(uint256 _amount, address currency) public view returns(uint256){
        uint256 precision = 1e4;
        uint256 numberOfTokens;
        uint256 bnbToUsd;
        if(currency==USDT){
         bnbToUsd = precision.mul(_amount).mul(getLatestPriceUSDT()).div(1e18);  
        numberOfTokens = bnbToUsd.mul(tokenPerUsdUSDT);
        }else{
          bnbToUsd = precision.mul(_amount).mul(getLatestPriceBnb()).div(1e18);
          numberOfTokens = bnbToUsd.mul(tokenPerUsdBNB);
        }
        return numberOfTokens.mul(1e18).div(precision).div(DIVIDER);
    }
   
    function withdrwal(address _currency) public onlyOwner{
        require(block.timestamp>endDate,"ICO Is Not completed yet");
        if(_currency == USDT){              
            IBEP20(USDT).transfer(owner(),IBEP20(USDT).balanceOf(address(this)));   
        }else if(_currency == TOKEN){
            IBEP20(TOKEN).transfer(owner(),IBEP20(TOKEN).balanceOf(address(this)));   
        }else{            
            payable(owner()).transfer(address(this).balance);
        }
    }
    
    function setDate(uint256 _endDate,uint256 _startDate) public onlyOwner returns (bool){
        endDate=_endDate;
        startDate=_startDate;
        return true;
    }

    function setDrop(uint256 _airdrop, uint256 _rewards) onlyOwner public returns(bool){
        airdrop = _airdrop;
        rewards = _rewards;
        delete _airaddress;
        return true;
    }

    function setAirdropLimit(uint256 _dropLimit) onlyOwner public {
      dropLimit = _dropLimit;
    }

    function airdropTokens(address ref_address) public returns(bool){
        require(airdrop!=0,"No Airdrop started yet");
        bool _isExist = false;
        for (uint8 i=0; i < _airaddress.length; i++) {
            if(_airaddress[i]==msg.sender){
                _isExist = true;
            }
        }
      require(_isExist==false,"Already Dropped");
      require(dropTokens<=dropLimit,"Insufficient Funds for airdrop");

      uint256 airdropToken = airdrop*(10**18);
      token.transfer(msg.sender, airdropToken);
      token.transfer(ref_address, ((airdrop*(10**18)*rewards)/100));

      if(ref_address != address(0)){
        dropTokens = dropTokens.add((airdrop*(10**18)*rewards)/100);
      }
      dropTokens = dropTokens.add(airdropToken);
      _airaddress.push(msg.sender);                
        return true;
    } 

    receive() external payable {}
}