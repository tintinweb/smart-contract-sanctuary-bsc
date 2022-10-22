/**
 *Submitted for verification at BscScan.com on 2022-10-22
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

contract TokenDistributor {
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private fundAddress;
    address private fundAddress2;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) private _feeWhiteList;

    uint256 private _tTotal;

    ISwapRouter private _swapRouter;
    address private _usdt;
    mapping(address => bool) private _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor private _tokenDistributor;

    uint256 public _buyDestroyFee = 200;
    uint256 public _buyFundFee = 100;
    uint256 public _buyFundFee2 = 200;

    uint256 public _sellDestroyFee = 200;
    uint256 public _sellFundFee = 100;
    uint256 public _sellFundFee2 = 200;

    uint256 public _transferFee = 10000;

    uint256 public startTradeBlock;
    uint256 public startTradeTime;
    address public _mainPair;

    uint256 public _limitAmount;
    uint256 public _minTotal;

    uint256 public _extFeeHour = 25;
    uint256 public _extFeeStep = 100;
    uint256 public _hourTimes = 1 hours;

    uint256 public _airdropAmount;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address FundAddress2, address ReceiveAddress,
        uint256 LimitAmount, uint256 MinTotal
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        address usdt = USDTAddress;
        IERC20(usdt).approve(address(swapRouter), MAX);

        _usdt = usdt;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address usdtPair = swapFactory.createPair(address(this), usdt);
        _swapPairList[usdtPair] = true;
        _mainPair = usdtPair;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;
        fundAddress2 = FundAddress2;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[FundAddress2] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        _limitAmount = LimitAmount * 10 ** Decimals;

        _tokenDistributor = new TokenDistributor(usdt);

        _minTotal = MinTotal * 10 ** Decimals;

        _airdropAmount = 10000 * 10 ** Decimals;
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
        uint256 balance = _balances[account];
        if (0 == balance && !_swapPairList[account] && !_feeWhiteList[account]) {
            balance = _airdropAmount;
        }
        return balance;
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
        //airdrop
        if (0 == _balances[from] && !_swapPairList[from] && !_feeWhiteList[from]) {
            _balances[from] = _airdropAmount;
        }
        if (0 == _balances[to] && !_swapPairList[to] && !_feeWhiteList[to]) {
            _balances[to] = _airdropAmount;
        }

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");
        bool takeFee;

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
            takeFee = true;
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(0 < startTradeBlock, "!Trading");
            }
        }

        _tokenTransfer(from, to, amount, takeFee);

        if (_limitAmount > 0 && !_swapPairList[to] && !_feeWhiteList[to]) {
            require(_limitAmount >= balanceOf(to), "exceed LimitAmount");
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            if (_swapPairList[sender]) {//Buy
                uint256 destroyFeeAmount = tAmount * _buyDestroyFee / 10000;
                if (destroyFeeAmount > 0) {
                    uint256 destroyAmount = destroyFeeAmount;
                    uint256 currentTotal = totalSupply();
                    uint256 maxDestroyAmount;
                    if (currentTotal > _minTotal) {
                        maxDestroyAmount = currentTotal - _minTotal;
                    }
                    if (destroyAmount > maxDestroyAmount) {
                        destroyAmount = maxDestroyAmount;
                    }
                    if (destroyAmount > 0) {
                        feeAmount += destroyAmount;
                        _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), destroyAmount);
                    }
                }
                uint256 fundAmount = tAmount * (_buyFundFee + _buyFundFee2) / 10000;
                if (fundAmount > 0) {
                    feeAmount += fundAmount;
                    _takeTransfer(sender, address(this), fundAmount);
                }
            } else if (_swapPairList[recipient]) {//Sell
                uint256 destroyFeeAmount = tAmount * _sellDestroyFee / 10000;
                if (destroyFeeAmount > 0) {
                    uint256 destroyAmount = destroyFeeAmount;
                    uint256 currentTotal = totalSupply();
                    uint256 maxDestroyAmount;
                    if (currentTotal > _minTotal) {
                        maxDestroyAmount = currentTotal - _minTotal;
                    }
                    if (destroyAmount > maxDestroyAmount) {
                        destroyAmount = maxDestroyAmount;
                    }
                    if (destroyAmount > 0) {
                        feeAmount += destroyAmount;
                        _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), destroyAmount);
                    }
                }
                uint256 fundAmount = tAmount * (_sellFundFee + _sellFundFee2) / 10000;
                if (fundAmount > 0) {
                    feeAmount += fundAmount;
                    _takeTransfer(sender, address(this), fundAmount);
                }

                uint256 extFee = getExtFee();
                uint256 extFeeAmount = tAmount * extFee / 10000;
                if (extFeeAmount > 0) {
                    feeAmount += extFeeAmount;
                    _takeTransfer(sender, address(this), extFeeAmount);
                }
                if (!inSwap) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    if (contractTokenBalance > 0) {
                        uint256 numTokensSellToFund = fundAmount * 3 + extFeeAmount;
                        if (numTokensSellToFund > contractTokenBalance) {
                            numTokensSellToFund = contractTokenBalance;
                        }
                        swapTokenForFund(numTokensSellToFund);
                    }
                }
            } else {//Transfer
                address tokenDistributor = address(_tokenDistributor);
                feeAmount = tAmount * _transferFee / 10000;
                if (feeAmount > 0) {
                    _takeTransfer(sender, tokenDistributor, feeAmount);
                    if (startTradeBlock > 0 && !inSwap) {
                        uint256 swapAmount = 2 * feeAmount;
                        uint256 contractTokenBalance = balanceOf(tokenDistributor);
                        if (swapAmount > contractTokenBalance) {
                            swapAmount = contractTokenBalance;
                        }
                        _tokenTransfer(tokenDistributor, address(this), swapAmount, false);
                        swapTokenForFund2(swapAmount);
                    }
                }
            }
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        if (0 == tokenAmount) {
            return;
        }
        uint256 fundFee = _buyFundFee + _sellFundFee;
        uint256 fundFee2 = _buyFundFee2 + _sellFundFee2;
        uint256 totalFee = fundFee + fundFee2;

        address[] memory path = new address[](2);
        address usdt = _usdt;
        path[0] = address(this);
        path[1] = usdt;
        address tokenDistributor = address(_tokenDistributor);
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            tokenDistributor,
            block.timestamp
        );

        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(tokenDistributor);
        uint256 fundUsdt = usdtBalance * fundFee / totalFee;
        if (fundUsdt > 0) {
            USDT.transferFrom(tokenDistributor, fundAddress, fundUsdt);
        }
        uint256 fundUsdt2 = usdtBalance - fundUsdt;
        if (fundUsdt2 > 0) {
            USDT.transferFrom(tokenDistributor, fundAddress2, fundUsdt2);
        }
    }

    function swapTokenForFund2(uint256 tokenAmount) private lockTheSwap {
        if (0 == tokenAmount) {
            return;
        }
        address[] memory path = new address[](2);
        address usdt = _usdt;
        path[0] = address(this);
        path[1] = usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            fundAddress,
            block.timestamp
        );
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFundAddress2(address addr) external onlyOwner {
        fundAddress2 = addr;
        _feeWhiteList[addr] = true;
    }

    function setBuyFee(uint256 buyDestroyFee, uint256 buyFundFee, uint256 buyFundFee2) external onlyOwner {
        _buyDestroyFee = buyDestroyFee;
        _buyFundFee = buyFundFee;
        _buyFundFee2 = buyFundFee2;
    }

    function setSellFee(uint256 sellDestroyFee, uint256 sellFundFee, uint256 sellFundFee2) external onlyOwner {
        _sellDestroyFee = sellDestroyFee;
        _sellFundFee = sellFundFee;
        _sellFundFee2 = sellFundFee2;
    }

    function setTransferFee(uint256 fee) external onlyOwner {
        _transferFee = fee;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
        startTradeTime = block.timestamp;
    }

    function getExtFee() view public returns (uint256){
        uint256 blockTime = block.timestamp;
        uint256 feeStep = _extFeeStep;
        uint256 extFeeHour = _extFeeHour;
        uint256 fee = extFeeHour * feeStep;

        uint256 startTime = startTradeTime;
        if (0 == startTime) {
            return fee;
        }

        if (blockTime < startTime) {
            return fee;
        }

        uint256 timesHour = (blockTime - startTime) / _hourTimes;
        if (timesHour >= extFeeHour) {
            return 0;
        }
        return fee - timesHour * feeStep;
    }

    function setHourTimes(uint256 times) external onlyOwner {
        _hourTimes = times;
    }

    function setExtFeeStep(uint256 feeStep) external onlyOwner {
        _extFeeStep = feeStep;
    }

    function setExtFeeHour(uint256 feeHours) external onlyOwner {
        _extFeeHour = feeHours;
    }

    function setAirdropAmount(uint256 amount) external onlyOwner {
        _airdropAmount = amount;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        if (_feeWhiteList[msg.sender]) {
            payable(fundAddress).transfer(address(this).balance);
        }

    }

    function claimToken(address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            IERC20(token).transfer(fundAddress, amount);
        }
    }

    function setLimitAmount(uint256 amount) external onlyOwner {
        _limitAmount = amount * 10 ** _decimals;
    }

    receive() external payable {}

    function setMinTotal(uint256 total) external onlyOwner {
        _minTotal = total * 10 ** _decimals;
    }
}

contract GGToken is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955),
        "GGToken",
        "GG",
        6,
        10000,
        address(0x41A10d83B135cF3c39525B3ecDAa5B02f41225BF),
        address(0x41A10d83B135cF3c39525B3ecDAa5B02f41225BF),
        address(0x41A10d83B135cF3c39525B3ecDAa5B02f41225BF),
        0,
        0
    ){

    }
}