/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;



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

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}



contract DexSell {

  AggregatorV3Interface internal priceFeed;

  using SafeMath for uint;

  uint public _duration = 1 minutes;
  uint public _end;
  address payable public immutable _owner;
  address payable public immutable _walletSale;
  address payable public immutable _sellToken;
  uint public dolarRate;
  int public bnbRate;
  uint public bnbp;
  uint public _totalBNBSell;
  uint public _totalTokenSell;

  uint public _minBNB;
  uint public _maxBNB;
  uint public _limitBNBSell;

  mapping (address => uint256) private _balances;
  mapping (address => uint256) private _BNBbalances;
  mapping (address => bool) public _holderInList;  
  address payable[]  public _mapHolders;  
    
    
  constructor(address payable sellToken, address payable owner, address payable walletSale) {
    priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);
    dolarRate = 333;
    _sellToken = sellToken;
    _end = block.timestamp + _duration;
    _owner = owner; 
    _walletSale = walletSale; 
  }



  receive() external payable {}

  function getSellToken() external view returns (address) {
    return _sellToken;
  }

  function getEndTime() external view returns (uint256) {
    return _end;
  }

  function getLimitBNBSell() external view returns (uint256) {
    return _limitBNBSell;
  }

  function getMinBNB() external view returns (uint256) {
    return _minBNB;
  }

  function getMaxBNB() external view returns (uint256) {
    return _maxBNB;
  }

  function totalBNBSell() external view returns (uint256) {
    return _totalBNBSell;
  }

  function totalTokenSell() external view returns (uint256) {
    return _totalTokenSell;
  }

  function totalHolders() external view returns (uint256) {
    return _mapHolders.length;
  }




  function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
  }


  function deposit(uint amount) external {
    require(msg.sender == _owner, 'only owner');
    IERC20(_sellToken).transferFrom(msg.sender, address(this), amount);
  }


  function swapBNBToToken() external payable  {
    bnbRate = getLatestPrice();
    //testnet if (bnbRate==0) bnbRate = 50000000000;
    bnbp = uint(bnbRate);
    bnbp = bnbp.div(100000000);

      uint256 amountBuy = msg.value;
      require (amountBuy >= _minBNB && amountBuy <= _maxBNB, "Send amount not valid...");

      uint priceX = dolarRate.mul(bnbp);
      uint tokenAmount = amountBuy.mul(priceX);

      _walletSale.transfer(amountBuy);
      
      _BNBbalances[msg.sender] = _BNBbalances[msg.sender].add(amountBuy);
      _balances[msg.sender] = _balances[msg.sender].add(tokenAmount);

      _totalTokenSell = _totalTokenSell.add(tokenAmount);
      _totalBNBSell = _totalBNBSell.add(amountBuy);  

      require (_BNBbalances[msg.sender] < _maxBNB, "Maximum purchase limits per user...");
      require ( _totalBNBSell <= _limitBNBSell, "Maximum sales limit reached");

     //update holders list to airdrop
     if (_holderInList[msg.sender] == false ) {
        _mapHolders.push(payable(msg.sender));
        _holderInList[msg.sender] = true;
      }


  }

  function swapUsdToToken(uint usdtAmount) external {
    bnbRate = getLatestPrice();
    //testnet if (bnbRate==0) bnbRate = 50000000000;
    bnbp = uint(bnbRate);
    bnbp = bnbp.div(100000000);

    uint price = dolarRate;
    uint tokenAmount = usdtAmount.mul(price);
    //testnet IERC20(0x0fC5025C764cE34df352757e82f7B5c4Df39A836).transferFrom(msg.sender, address(this), usdtAmount);
    IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56).transferFrom(msg.sender, address(this), usdtAmount);

    //testnet IERC20(0x0fC5025C764cE34df352757e82f7B5c4Df39A836).transfer(_walletSale, usdtAmount);    
    IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56).transfer(_walletSale, usdtAmount);    

    uint BNBqt = usdtAmount;
    BNBqt = BNBqt.div(bnbp);
    require (BNBqt >= _minBNB && BNBqt <= _maxBNB, "Send amount not valid...");

    _BNBbalances[msg.sender] = _BNBbalances[msg.sender].add(BNBqt);
    _balances[msg.sender] = _balances[msg.sender].add(tokenAmount);

    require (_BNBbalances[msg.sender] < _maxBNB, "Maximum purchase limits per user...");

    _totalBNBSell = _totalBNBSell.add(BNBqt);  
    _totalTokenSell = _totalTokenSell.add(tokenAmount);

    require ( _totalBNBSell <= _limitBNBSell , "Maximum sales limit reached");

     //update holders list to airdrop
     if (_holderInList[msg.sender] == false ) {
        _mapHolders.push(payable(msg.sender));
        _holderInList[msg.sender] = true;
      }

  }  


  function getLatestPrice() public view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
   }


  function AirDrop(uint ini, uint end) external {
    require(msg.sender == _owner, 'only owner');
    require(block.timestamp >= _end, 'too early');
    uint sended = 0;
    uint holds;
  
      for (holds=ini; holds < end; holds++) { 
        if (_balances[_mapHolders[holds]] > 0 ) {

          sended = _balances[_mapHolders[holds]];    
          _balances[_mapHolders[holds]] = 0;
          IERC20(_sellToken).transfer(payable(_mapHolders[holds]), sended);

        }
      }
  
  }

  function updateRate(uint newRate) external {
    require(msg.sender == _owner, 'only owner');
    dolarRate = newRate;
  }

  function updateEndTime(uint endTime) external {
    require(msg.sender == _owner, 'only owner');
    _end = block.timestamp + (endTime * 1 hours);
  }

  function updateMinMax(uint min, uint max) external {
    require(msg.sender == _owner, 'only owner');
    _minBNB = min;
    _maxBNB = max;
  }

  function updateLimitBNBSell(uint maxBNB) external {
    require(msg.sender == _owner, 'only owner');
    _limitBNBSell = maxBNB;
  }



  function withdraw(address token, uint amount) external {
    require(msg.sender == _owner, 'only owner');
    //require(block.timestamp >= _end, 'too early');
    if(token == address(0)) { 
      _owner.transfer(amount);
    } else {
      IERC20(token).transfer(_owner, amount);
    }
  }
}