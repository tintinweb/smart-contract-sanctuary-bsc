/**
 *Submitted for verification at BscScan.com on 2022-12-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.7;

interface IBEP20 {
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

abstract contract Context { 

  function _msgSender() internal view returns (address) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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

abstract contract Ownable is Context {
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

contract UnityMetaToken is Context, IBEP20, Ownable {
  using SafeMath for uint256;
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;
  mapping(address => bool) public allowedTransfer;
  mapping(address => bool) public is_AntiBotBlackListed;
  uint256 public basePercent = 1;
  uint256 private _totalSupply;
  uint256 private _totalBurning;
  uint256 private _maxBurning;
  uint8 private _decimals;
  uint256 public maxBuyLimit;
  uint256 public maxSellLimit;
  uint256 public maxWalletLimit;
  string private _symbol;
  string private _name;
  constructor()  {
        _name = 'UnityMeta Token';
        _symbol = 'UMT';   
        _decimals = 18;
		_totalSupply = 99000 * 10 ** _decimals;
        _maxBurning = 9000 * 10 ** _decimals; 
        maxBuyLimit = 10000 * 10 ** _decimals; 
        maxSellLimit = 10000 * 10 ** _decimals; 
        maxWalletLimit = 10000 * 10 ** _decimals; 
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

  function getOwner() external view override returns (address) {
    return owner();
  }

  function decimals() external view override returns (uint8) {
    return _decimals;
  }
  
  function symbol() external view override returns (string memory) {
    return _symbol;
  }

  function name() external view override returns (string memory) {
    return _name;
  }

  function totalBurning() external view returns (uint256) {
    return _totalBurning;
  }

  function maxBurning() external view returns (uint256) {
    return _maxBurning;
  }

  function totalSupply() external view override returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) external view override returns (uint256) {
    return _balances[account];
  }
  
  function viewAntiBotStatus(address account) external view returns (bool) {
    return is_AntiBotBlackListed[account];
  }

  function viewAntiBotTransferStatus(address account) external view returns (bool) {
    return allowedTransfer[account];
  }
    function updateIsBlacklisted(address account, bool state) external onlyOwner 
    {
        is_AntiBotBlackListed[account] = state;
    }

    function bulkIsBlacklisted(address[] memory accounts, bool state) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            is_AntiBotBlackListed[accounts[i]] = state;
        }
    }

    function updateAllowedTransfer(address account, bool state) external onlyOwner {
        allowedTransfer[account] = state;
    }    

    function bulkupdateAllowedTransfer(address[] memory accounts, bool state) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            allowedTransfer[accounts[i]] = state;
        }
    }

    function updateMaxBurning(uint256 burnAmount) external onlyOwner 
    {
        uint256 burnToken = burnAmount  * 10 **_decimals;
        if(burnToken < _totalSupply)
        {
            _maxBurning = burnToken;
        }
    }

    function updateMaxTxLimit(uint256 maxBuy, uint256 maxSell) external onlyOwner 
    {
        maxBuyLimit = maxBuy * 10 **_decimals;
        maxSellLimit = maxSell * 10 **_decimals;
    }

    function updateMaxWalletlimit(uint256 amount) external onlyOwner {
        maxWalletLimit = amount * 10**_decimals;
    }

  function _burnToken(uint256 amount) private view returns (uint256)  
  {
    uint256 burnAmount = amount.mul(basePercent).div(1000);
    return burnAmount;
  }

  function transfer(address recipient, uint256 amount) external override returns (bool) 
  {    
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
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

  function _transfer(address sender, address recipient, uint256 amount) internal 
  {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");   
    require(!is_AntiBotBlackListed[sender] && !is_AntiBotBlackListed[recipient], "Bot are blocked");
    require(!allowedTransfer[sender] && !allowedTransfer[recipient], "Transfer not allowed");
    require(amount <= maxBuyLimit, "You are exceeding maxBuyLimit");
    require(_balances[recipient] + amount <= maxWalletLimit,"Receiver are exceeding maxWalletLimit");
   
    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    uint256 transferAmount = amount;
	if( _totalBurning < _maxBurning)
    {
        uint256 tokensToBurn = _burnToken(amount);
        _totalBurning = _totalBurning.add(tokensToBurn);
        _totalSupply = _totalSupply.sub(tokensToBurn);
		transferAmount = amount.sub(tokensToBurn);
    }
	_balances[recipient] = _balances[recipient].add(transferAmount);
    emit Transfer(sender, recipient, transferAmount);
  }
  
  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }
  
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }
  
  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
  }

    //Use this in case BNB are sent to the contract by mistake
    function rescueBNB(uint256 weiAmount) external onlyOwner {
        require(address(this).balance >= weiAmount, "insufficient BNB balance");
        payable(msg.sender).transfer(weiAmount);
    }

    function rescueAnyBEP20Tokens(
        address _tokenAddr,
        address _to,
        uint256 _amount
    ) public onlyOwner {
        IBEP20(_tokenAddr).transfer(_to, _amount);
    }
}