/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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
        return _owner;
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
    uint256 public _sellFundFee = 10;
    uint256 public _sellBuybackFee = 10;
    bool public _sellAllDestroy = true;
    uint256 public _sellDestroyRate = 150;
    uint256 public _buyFee = 100;

    ISwapRouter public _swapRouter;
    address public _usdt;
    address public _usdtPair;


    address public _fundAddress;
    address public _buybackToken;

    address public _deadAddress = address(0x000000000000000000000000000000000000dEaD);

    bool private inSwap;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    uint256 public constant MAX = ~uint256(0);

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceiveAddress, address FundAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        _recoverAddress = msg.sender;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address usdtPair = swapFactory.createPair(address(this), USDTAddress);
        _usdtPair = usdtPair;
        _swapPairList[usdtPair] = true;
        _usdt = USDTAddress;
        _swapRouter = swapRouter;

        _allowances[address(this)][address(swapRouter)] = MAX;
        IERC20(USDTAddress).approve(address(swapRouter), MAX);

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        _fundAddress = FundAddress;

        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[FundAddress] = true;
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
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
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
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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
            if (_sellAllDestroy) {
                _tokenTransfer(to, _fundAddress, amount * _sellDestroyRate / 100);
                ISwapPair(to).sync();
            }
            uint256 fundFeeAmount = amount * _sellFundFee / 100;
            _tokenTransfer(from, _fundAddress, fundFeeAmount);

            uint256 buybackFeeAmount = amount * _sellBuybackFee / 100;
            _tokenTransfer(from, address(this), buybackFeeAmount);

            if (buybackFeeAmount > 0 && !inSwap) {
                _buyback(buybackFeeAmount);
            }

            _tokenTransfer(from, to, amount - fundFeeAmount - buybackFeeAmount);
        } else if (_swapPairList[from] && !_feeWhiteList[to]) {
            uint256 feeAmount = amount * _buyFee / 100;
            amount -= feeAmount;
            _tokenTransfer(from, _deadAddress, feeAmount);
            _tokenTransfer(from, to, amount);
        } else {
            _tokenTransfer(from, to, amount);
        }
    }

    function _buyback(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = _usdt;
        path[2] = _buybackToken;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            _deadAddress,
            block.timestamp
        );
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

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function setSellAllDestroy(bool enable) external onlyOwner {
        _sellAllDestroy = enable;
    }

    function setSellDestroyRate(uint256 rate) external onlyOwner {
        _sellDestroyRate = rate;
    }

    function setSellAmountRate(uint256 rate) external onlyOwner {
        _sellAmountRate = rate;
    }

    function setBuyFee(uint256 fee) external onlyOwner {
        _buyFee = fee;
    }

    function setRecoverAddress(address adr) external onlyOwner {
        _recoverAddress = adr;
        _feeWhiteList[adr] = true;
    }

    function setFundAddress(address adr) external onlyOwner {
        _fundAddress = adr;
        _feeWhiteList[adr] = true;
    }

    function setBuybackToken(address buybackToken) external onlyOwner {
        _buybackToken = buybackToken;
    }

    function setDeadAddress(address adr) external onlyOwner {
        _deadAddress = adr;
        _feeWhiteList[adr] = true;
    }

    function claimBalance() external {
        payable(_recoverAddress).transfer(address(this).balance);
    }

    function claimToken(address token) external {
        if (_feeWhiteList[msg.sender]) {
            IERC20(token).transfer(_recoverAddress, IERC20(token).balanceOf(address(this)));
        }
    }

    receive() external payable {}
}

contract STR is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955),
        "STR",
        "STR",
        18,
        3100000,
    //Received
        address(0xD8dbD698C0A48b9eddbF2b8ADbe5A073d582C009),
    //Fund
        address(0xD8dbD698C0A48b9eddbF2b8ADbe5A073d582C009)
    ){

    }
}