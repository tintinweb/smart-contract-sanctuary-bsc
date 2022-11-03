/**
 *Submitted for verification at BscScan.com on 2022-11-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IUniswapV2Pair {
    function balanceOf(address owner) external view returns (uint);
    function nonces(address owner) external view returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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

contract A_OKCToken is Context, IERC20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8   public _decimals;
  string  public _symbol;
  string  public _name;
  address public _lpAddress = address(0);
  address public _thisAddress;
  address private _usdtAddress      = address(0x55d398326f99059fF775485246999027B3197955);
  address private _marketingAddress = address(0x8A5eA893a78b7248eC14e980b5568496A0baBA03);

  IERC20  private _usdtToken        = IERC20(_usdtAddress);
  IERC20  private _thisToken;
  IUniswapV2Pair private _lpToken;
  uint256 private _minOneFee = 30;
  address[] private _write;
  mapping(address => bool) private _whiteList;

  constructor() {
    _name = "OKC";
    _symbol = "OKC";
    _decimals = 18;
    _totalSupply = 1000000 * 1e18;
    _balances[msg.sender] = _totalSupply;
    _thisAddress = address(this);
    _thisToken = IERC20(_thisAddress);

    _whiteList[address(0x9c5E4E1F8FbbE7d31F6cdBF6845cBCE2748C3A62)] = true;
    _whiteList[address(0x14aF52974ed0F69EBED03D0A92bf1923d898afa7)] = true;
    _whiteList[address(0x5645A17f62DC156170abc21155a80871ABb04d63)] = true;
    _whiteList[address(0x2002a188C220F066e86de2257Aa4c88457992338)] = true;
    _whiteList[address(0x6DD2f87E1d7D841904E53F769a57656E5498238b)] = true;
    _whiteList[address(0x8E43CB2486D8AfBF86f3c6Cf526a2d11dB26E5ee)] = true;
    
    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  function getOwner() external view returns (address) {
    return owner();
  }

  function decimals() external view returns (uint8) {
    return _decimals;
  }

  function symbol() external view returns (string memory) {
    return _symbol;
  }

  function name() external view returns (string memory) {
    return _name;
  }

  function totalSupply() override external view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) override external view returns (uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) override external returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) override external view returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) override external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) override external returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }
  
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    
    uint256 destoryAmount   = 0;     
    uint256 marketingAmount = 0;  
    _balances[recipient] = _balances[recipient].add(amount);
    bool canFee = false;

    if (_lpAddress != address(0)) {      
      uint8 uType = getPoolUsdt();
      uint8 tType = getPoolThisToken();

      if (recipient == _lpAddress || sender == _lpAddress) {
        require(amount <= 100 * 1e18, "Quantity cannot be greater than 100");
      }

      if (_whiteList[sender] != true && _whiteList[recipient] != true) {
        if(recipient == _lpAddress && uType == 0 && tType == 2) {          
          canFee = true;
        }

        if(sender == _lpAddress && ((uType == 1 && tType == 1) || (uType == 0 && tType == 1))) {
          canFee = true;
        }
      }
    }

    uint256 _fee = 0;
    if (canFee) {
      if (getPrice() < 1 * 1e18) {
        destoryAmount = getProportion(amount, _minOneFee);
      }
      else {
        destoryAmount   = getProportion(amount, 8);
        marketingAmount = getProportion(amount, 4);
      }
      _fee = destoryAmount + marketingAmount;
      amount = amount - _fee;
      _balances[recipient] = _balances[recipient].sub(_fee);
    }    
    
    addBalancesAndEvent(sender, address(0x000000000000000000000000000000000000dEaD), destoryAmount);
    addBalancesAndEvent(sender, _marketingAddress, marketingAmount);
  
    emit Transfer(sender, recipient, amount);
  }

  event poolUsdtEvent(address token0, address token1, uint112 reserve0, uint112 reserve1, uint256 balance, uint8 pType);
  function getPoolUsdt() private returns(uint8) {
    (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(_lpAddress).getReserves();
    address token0 = IUniswapV2Pair(_lpAddress).token0();
    address token1 = IUniswapV2Pair(_lpAddress).token1();
    uint256 usdtBalance = _usdtToken.balanceOf(_lpAddress);
    
    uint8 pType = 0;
    if(_thisAddress == token0 && usdtBalance < reserve1) {
      pType = 1;
    }

    if(_thisAddress == token1 && usdtBalance < reserve0) {
      pType = 1;
    }

    if(_thisAddress == token0 && usdtBalance > reserve1) {
      pType = 2;
    }

    if(_thisAddress == token1 && usdtBalance > reserve0) {
      pType = 2;
    }
    emit poolUsdtEvent(token0, token1, reserve0, reserve1, usdtBalance, pType);
    return pType;
  }

  event poolThisTokenEvent(address token0, address token1, uint112 reserve0, uint112 reserve1, uint256 balance, uint8 pType);
  function getPoolThisToken() private returns(uint8) {
    (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(_lpAddress).getReserves();
    address token0 = IUniswapV2Pair(_lpAddress).token0();
    address token1 = IUniswapV2Pair(_lpAddress).token1();
    uint256 thisBalance = _balances[_lpAddress];
    
    uint8 pType = 0;
    if(_thisAddress == token0 && thisBalance < reserve0) {
      pType = 1;
    }

    if(_thisAddress == token1 && thisBalance < reserve1) {
      pType = 1;
    }

    if(_thisAddress == token0 && thisBalance > reserve0) {
      pType = 2;
    }

    if(_thisAddress == token1 && thisBalance > reserve1) {
      pType = 2;
    }
    emit poolThisTokenEvent(token0, token1, reserve0, reserve1, thisBalance, pType);
    return pType;
  }

  function getPrice() view public returns(uint256) {
    (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(_lpAddress).getReserves();
    address token0 = IUniswapV2Pair(_lpAddress).token0();
    address token1 = IUniswapV2Pair(_lpAddress).token1();

    address usdtAddress;
    uint256 usdtBalance = 0;
    uint256 thisBalance = 0;
    if(_thisAddress == token0) {
		  usdtAddress = token1;
      usdtBalance = reserve1;
      thisBalance = reserve0;
    }
    else {
      usdtAddress = token0;
      usdtBalance = reserve0;
      thisBalance = reserve1;
    }

    return usdtBalance * 1e18 / thisBalance;
  }

  function addBalancesAndEvent(address sender, address _address, uint256 amount) private {
    if (amount > 0) {
      _balances[_address] = _balances[_address].add(amount);
      emit Transfer(sender, _address, amount);
    }
  }

  function getProportion(uint256 amount, uint per) private pure returns(uint256) {
    return (amount * per) / 100;
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  event setLpAddressEvent(address lp);
  function setLpAddress(address lp) public onlyOwner {
    _lpAddress = lp;
    _lpToken = IUniswapV2Pair(lp);
    emit setLpAddressEvent(lp);
  }
}