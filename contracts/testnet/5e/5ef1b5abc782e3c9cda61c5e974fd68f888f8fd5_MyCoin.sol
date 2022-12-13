/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-12
*/

pragma solidity 0.5.16;

interface IMyCoin {
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

interface IBTC {
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function balanceOf(address account) external view returns (uint256);
}

interface ISBTC {
  function getBurnedAndMinted() external view returns (uint256,uint256);
}

interface IOracle {
  function getCurrentPrice() external view returns (uint256);
}

interface IgCoin {
  function inDAO(address a) external view returns (bool);
}

contract Context {
  constructor () internal { 
  }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
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

  constructor () internal {
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

contract MyCoin is Context, IMyCoin, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) public userGain;
  mapping (address => uint256) private lastTransfer;
  mapping (address => uint256) private _balances;
  mapping (address => bool) public excluded;  
  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint256 private backedSupply;

  uint256 private mintedProfits = 1e19;
  uint256 private burnedTokens = 1e19;
  uint256 private gain = 100000000;
  uint256 private tokenPrice = 100;
  uint256 private prevPrice = tokenPrice;
  uint256 private btcToLBtcRatio = 1000;

  uint8 private transferFee = 5;  
  uint8 private _decimals;
  string private _symbol;
  string private _name;
  bool private paused = false;
  bool private rebalance = false;
  address dao = address(0x0);

  IBTC public BITCOIN;
  IgCoin public gCoin;
  IOracle private myOracle;
  ISBTC private SBTC; 

  constructor() public {
    _name = "MyCoin";
    _symbol = "COIN";
    _decimals = 18;
    _totalSupply = 3000000000000000000;
    _balances[msg.sender] = _totalSupply;
    initContracts(0xb90b3521579a407F4863B1D07dEE5C0685729D78, 0x6ce8dA28E2f864420840cF74474eFf5fD80E65B8, 0x6ce8dA28E2f864420840cF74474eFf5fD80E65B8,0x6ce8dA28E2f864420840cF74474eFf5fD80E65B8,0x6ce8dA28E2f864420840cF74474eFf5fD80E65B8);
    prevPrice = getCurrentPrice();
    excluded[address(this)] = true;
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

  function excludeAddr(address account, bool setting) public onlyOwner {
    excluded[account] = setting;
  }

  function setOracle(address setting) public onlyOwner {
     myOracle = IOracle(setting);
  }

  function setTransferFee(uint8 _transferFee) public onlyOwner {
    require(_transferFee <= 50);
    transferFee = _transferFee;
  }

  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) external view returns (uint256) {
    return getNewBalance(account);
  }

  function initContracts(address a1, address a2, address a3, address a4, address a5) public onlyOwner {
    myOracle = IOracle(a1);
    SBTC = ISBTC(a2);
    BITCOIN = IBTC(a3);
    gCoin = IgCoin(a4);
    dao = a5;
  }

  function currentBalance(address account) external view returns (uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }

  function getRedempPrice() internal view returns (uint256) {
    uint256 maxPrice = 1000000 * btcToLBtcRatio;
    if(backedSupply > 0) {
      uint256 price = 1000000 * BITCOIN.balanceOf(address(this)) / backedSupply;
      if(price > maxPrice) return maxPrice;
      return price;
    }
    return maxPrice;
  }

  function redeem(uint256 tokenAmount) public {
    require(tokenAmount > 0);
    require(backedSupply > 0);
    require(BITCOIN.balanceOf(address(this)) > 0);
    uint256 price = getRedempPrice();
    _balances[_msgSender()].sub(tokenAmount);
    uint256 btcAmount = 1000000 * tokenAmount / price;
    uint256 fee = btcAmount * (1000 - transferFee) / 1000;
    BITCOIN.transfer(_msgSender(), btcAmount.sub(fee));
    BITCOIN.transfer(dao, fee);
    backedSupply = backedSupply.sub(tokenAmount);
    _totalSupply = _totalSupply.sub(tokenAmount);
  }

  function create(uint256 btcAmount) public {
    require(btcAmount > 0);
    uint256 balanceBefore = BITCOIN.balanceOf(address(this));
    BITCOIN.transferFrom(_msgSender(), address(this), btcAmount);
    uint256 balanceAfter = BITCOIN.balanceOf(address(this));
    uint256 diff = SafeMath.sub(balanceAfter, balanceBefore);
    require(diff > 0); 
    uint256 amount =  diff * getRedempPrice() * (1000 - transferFee) / (1000 * 1000000);
    uint256 fee = diff * (1000 - transferFee) / 1000;
    _mint(_msgSender(), amount);
    BITCOIN.transfer(dao, fee);
    backedSupply = backedSupply.add(amount);
    _totalSupply = _totalSupply.add(amount);
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
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

  function setTokenPrice(uint256 newTokenPrice) public onlyOwner {
    tokenPrice = newTokenPrice;
  } 

  function getCurrentPrice() public view returns (uint256) {
    return myOracle.getCurrentPrice();
    //return tokenPrice;
  }

  function getNewBalance(address account) internal view returns (uint256) {
    if(userGain[account] == 0) return _balances[account];
    if(!excluded[account] && !paused) {
      return _balances[account] * getGain() / (userGain[account]);
    }
    return _balances[account];
  }

  function m_to_b_ratio() internal view returns (uint256) {
    (uint256 burnedTokens_s, uint256 mintedProfits_s) = SBTC.getBurnedAndMinted();
    return (mintedProfits + mintedProfits_s) * 10 / (burnedTokens + burnedTokens_s);
  }

  function b_to_m_ratio() internal view returns (uint256) {
    (uint256 burnedTokens_s, uint256 mintedProfits_s) = SBTC.getBurnedAndMinted();
    return (burnedTokens + burnedTokens_s) * 10 / (mintedProfits + mintedProfits_s);
  }

  function decreaseGain(uint256 _gain) public view returns (uint256) {
    if(mintedProfits >= burnedTokens && gain > _gain) {
      uint256 X = 10000 - (5 * m_to_b_ratio() ** 3) / 1000;
      uint256 Y = 200 - _gain * 200 / gain;
      for(uint256 i = 0; i < Y; i++) _gain = _gain * X / 10000;
    }
    return _gain; 
  }

  function increaseGain(uint256 _gain) public view returns (uint256) {
    if(burnedTokens > mintedProfits && _gain > gain) {
      uint256 newGain;
      uint256 X = 10000 + (5 * b_to_m_ratio() ** 3) / 1000;
      uint256 Y = 200 * _gain / gain - 200; 
      for(uint256 i = 0; i < Y; i++) newGain = _gain * X / 10000;
      _gain = (newGain > _gain * 2) ? _gain * 2 : newGain;
    }
    return _gain; 
  }

  function getGain() internal view returns (uint256) {
    uint256 _gain = gain * getCurrentPrice() / prevPrice;
    if(rebalance) {
      if(mintedProfits >= burnedTokens) {
        _gain = decreaseGain(_gain);
      } else if(burnedTokens > mintedProfits) {
        _gain = increaseGain(_gain);
      } 
    }
    return _gain;
  }

  function update() public {
    uint256 currentPrice = getCurrentPrice();
    gain = getGain();
    prevPrice = currentPrice;
  }

  function calcBalance(address account) public {
    update();
    _balances[account] = getNewBalance(account);
    userGain[account] = gain;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    update();

    if(!paused) {
      if(!excluded[sender]) {
        _balances[sender] = getNewBalance(sender);
        userGain[sender] = gain;
      }

      if(!excluded[recipient]) {
        _balances[recipient] = getNewBalance(recipient);
        userGain[recipient] = gain;     
      }
    }

    uint256 _fee = amount - amount * (1000 - transferFee )/1000;
    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
	  _balances[recipient] = _balances[recipient].add(amount);

    if(!excluded[recipient] && !paused) {
      _burn(recipient, _fee);
    }
    
    emit Transfer(sender, recipient, amount);
  }
  
  function destroy(uint256 amount) external {
    address account = _msgSender();
    require(account != address(0), "BEP20: burn from the zero address");
    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");
    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    burnedTokens = burnedTokens.add(amount);
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function burn(uint256 amount) public returns (bool) {
    _burn(_msgSender(), amount);
    return true;
  }

  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");
    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");
    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function getGlobals() external view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
    return (gain, gain * getCurrentPrice() / prevPrice, getGain(), prevPrice, transferFee, m_to_b_ratio(), b_to_m_ratio(), getRedempPrice());
  }

  function getUser(address a) external view returns (uint256, uint256, uint256) {
    return (_balances[a], userGain[a], excluded[a] ? 1 : 0 );
  }

  /* not needed */

  function getDecreaseVariables() public view returns (uint256, uint256) {
    uint256 _gain = gain * getCurrentPrice() / prevPrice;
    uint256 X = 10000 - (5 * m_to_b_ratio() ** 3) / 1000;
    uint256 Y = 200 - _gain * 200 / gain;
    return (X, Y);
  }

  function getIncreaseVariables() public view returns (uint256, uint256) {
    uint256 _gain = gain * getCurrentPrice() / prevPrice;
    uint256 X = 10000 + (5 * b_to_m_ratio() ** 3) / 1000;
    uint256 Y = 200 * _gain / gain - 200; 
    return (X, Y);
  } 


}