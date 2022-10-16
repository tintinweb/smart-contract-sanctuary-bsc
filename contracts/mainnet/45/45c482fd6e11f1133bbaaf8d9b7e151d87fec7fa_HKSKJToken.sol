/**
 *Submitted for verification at BscScan.com on 2022-10-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

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

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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
    address private _owner;

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
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private fundAddress;
    address private lpDividendAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    address private usdtPair;
    address private mainPair;

    uint256 private startTradeBlock;
    mapping(address => bool) private _feeWhiteList;
    mapping(address => bool) private _blackList;

    uint256 private _tTotal;

    ISwapRouter private _swapRouter;
    address private usdt;

    uint256 public _fundFee;
    uint256 public _lpDividendFee;

    uint256 private limitAmount;

    constructor (string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply, uint256 FundFee, uint256 LPDividendFee, uint256 LimitAmount){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        usdt = address(0x55d398326f99059fF775485246999027B3197955);

        mainPair = ISwapFactory(_swapRouter.factory()).createPair(address(this), _swapRouter.WETH());
        usdtPair = ISwapFactory(_swapRouter.factory()).createPair(address(this), usdt);

        address account = msg.sender;

        _tTotal = Supply * 10 ** _decimals;
        _balances[account] = _tTotal;
        emit Transfer(address(0), account, _tTotal);

        fundAddress = account;
        lpDividendAddress = account;

        _fundFee = FundFee;
        _lpDividendFee = LPDividendFee;

        _feeWhiteList[account] = true;
        _feeWhiteList[address(this)] = true;

        limitAmount = LimitAmount * 10 ** _decimals;
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

    function totalSupply() external view override returns (uint256) {
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
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "Transfer from the zero address");
        require(to != address(0), "Transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        require(!_blackList[from], "Transfer from the blackList address");

        bool takeFee = false;

        if (from == usdtPair || from == mainPair || to == usdtPair || to == mainPair) {
            if (0 == startTradeBlock) {
                require(_feeWhiteList[from] || _feeWhiteList[to] || from == address(_swapRouter) || to == address(_swapRouter), "Trade not start");
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to] && from != address(_swapRouter) && to != address(_swapRouter)) {
                takeFee = true;

                if (block.number <= startTradeBlock + 2) {
                    if (to != usdtPair && to != mainPair) {
                        _blackList[to] = true;
                    }
                }
            }
        }
        _tokenTransfer(from, to, amount, takeFee);

        if (to != mainPair && to != usdtPair && !_feeWhiteList[to] && to != address(_swapRouter)) {
            require(limitAmount >= balanceOf(to), "exceed LimitAmount");
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;

        uint256 feeAmount = 0;
        if (takeFee) {
            uint256 fundAmount = tAmount * _fundFee / 100;
            feeAmount += fundAmount;
            _takeTransfer(
                sender,
                fundAddress,
                fundAmount
            );
            uint256 lpDividendAmount = tAmount * _lpDividendFee / 100;
            feeAmount += lpDividendAmount;
            _takeTransfer(
                sender,
                lpDividendAddress,
                lpDividendAmount
            );
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function isFeeWhiteList(address addr) external view returns (bool){
        return _feeWhiteList[addr];
    }

    function isBlackList(address addr) external view returns (bool){
        return _blackList[addr];
    }

    function getFundAddress() external view returns (address){
        return fundAddress;
    }

    function getLPDividendAddress() external view returns (address){
        return lpDividendAddress;
    }

    function getFundFee() external view returns (uint256) {
        return _fundFee;
    }

    function getLPDividendFee() external view returns (uint256) {
        return _lpDividendFee;
    }

    function getLimitAmount() external view returns (uint256) {
        return limitAmount;
    }

    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setLPDividendAddress(address addr) external onlyOwner {
        lpDividendAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFundFee(uint256 fee) external onlyOwner {
        _fundFee = fee;
    }

    function setLPDividendFee(uint256 fee) external onlyOwner {
        _lpDividendFee = fee;
    }

    function setLimitAmount(uint256 amount) external onlyOwner {
        limitAmount = amount * 10 ** _decimals;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "had start trade");
        startTradeBlock = block.number;
    }

    receive() external payable {}

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external {
        IERC20(token).transfer(fundAddress, amount);
    }

}

contract HKSKJToken is AbsToken {
    constructor() AbsToken(
        "HKSKJ",
        "HKSKJ",
        9,
        100000,
        1,
        1,
        10
    ){

    }
}