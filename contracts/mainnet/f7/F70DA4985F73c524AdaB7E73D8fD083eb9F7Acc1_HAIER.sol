/**
 *Submitted for verification at BscScan.com on 2023-03-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

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
        require(_owner == msg.sender, "!o");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "n0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface ISwapPair {
    function sync() external;
}

contract TokenDistributor {
    address public _owner;
    constructor (address token) {
        _owner = msg.sender;
        IERC20(token).approve(msg.sender, ~uint256(0));
    }

    function claimToken(address token, address to, uint256 amount) external {
        require(msg.sender == _owner, "!o");
        IERC20(token).transfer(to, amount);
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address public fundAddress2;
    address public fundAddress3;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public _buyDestroyFee = 0;
    uint256 public _buyFundFee = 50;
    uint256 public _buyFundFee2 = 45;
    uint256 public _buyFundFee3 = 0;
    uint256 public _buyLPFee = 100;
    uint256 public _buyHolderFee = 195;

    uint256 public _sellDestroyFee = 0;
    uint256 public _sellFundFee = 50;
    uint256 public _sellFundFee2 = 45;
    uint256 public _sellFundFee3 = 0;
    uint256 public _sellLPFee = 100;
    uint256 public _sellHolderFee = 195;

    uint256 public _transferFee = 0;

    uint256 public startTradeBlock;
    uint256 public startBWBlock;
    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;
    mapping(address => bool) public _bWList;
    mapping(address => bool) public _excludeRewardList;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 public _rTotal;

    mapping(address => bool) public _swapPairList;

    uint256 public _limitAmount;
    uint256 public _txLimitAmount;

    uint256  public _aprPerTime = 82545;
    uint256  public _aprDuration = 1 hours;
    uint256 private constant AprDivBase = 100000000;
    uint256 public _lastRewardTime;
    bool public _autoApy;

    TokenDistributor public immutable _tokenDistributor;
    address public immutable _usdt;
    address public immutable _mainPair;
    ISwapRouter public immutable _swapRouter;

    bool private inSwap;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouteAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceivedAddress, address FundAddress, address FundAddress2, address FundAddress3,
        uint256 LimitAmount, uint256 TxLimitAmount
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouteAddress);
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        IERC20(USDTAddress).approve(address(swapRouter), MAX);

        _usdt = USDTAddress;
        address usdtPair = ISwapFactory(swapRouter.factory()).createPair(address(this), USDTAddress);
        _swapPairList[usdtPair] = true;
        _excludeRewardList[usdtPair] = true;
        _excludeRewardList[address(this)] = true;
        _mainPair = usdtPair;

        uint256 tTotal = Supply * 10 ** Decimals;
        uint256 base = AprDivBase * 100;
        uint256 rTotal = MAX / base - (MAX / base % tTotal);
        _rOwned[ReceivedAddress] = rTotal;
        _tOwned[ReceivedAddress] = tTotal;
        emit Transfer(address(0), ReceivedAddress, tTotal);
        _rTotal = rTotal;
        _tTotal = tTotal;

        fundAddress = FundAddress;
        fundAddress2 = FundAddress2;
        fundAddress3 = FundAddress3;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[FundAddress2] = true;
        _feeWhiteList[FundAddress3] = true;
        _feeWhiteList[ReceivedAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        _tokenDistributor = new TokenDistributor(USDTAddress);
        _feeWhiteList[address(_tokenDistributor)] = true;
        _excludeRewardList[address(_tokenDistributor)] = true;

        _limitAmount = LimitAmount * 10 ** Decimals;
        _txLimitAmount = TxLimitAmount * 10 ** Decimals;
    }

    function calApy() public {
        if (!_autoApy) {
            return;
        }
        uint256 total = _tTotal;
        uint256 maxTotal = _rTotal;
        if (total == maxTotal) {
            return;
        }
        uint256 blockTime = block.timestamp;
        uint256 lastRewardTime = _lastRewardTime;
        uint256 aprDuration = _aprDuration;
        if (blockTime < lastRewardTime + aprDuration) {
            return;
        }
        uint256 deltaTime = blockTime - lastRewardTime;
        uint256 times = deltaTime / aprDuration;
        uint256 aprPerTime = _aprPerTime;

        for (uint256 i; i < times;) {
            total = total * (AprDivBase + aprPerTime) / AprDivBase;
            if (total > maxTotal) {
                total = maxTotal;
                break;
            }
        unchecked{
            ++i;
        }
        }
        _tTotal = total;
        _lastRewardTime = lastRewardTime + times * aprDuration;
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
        return _tTotal - balanceOf(address(0)) - balanceOf(address(0x000000000000000000000000000000000000dEaD));
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_excludeRewardList[account]) {
            return _tOwned[account];
        }
        return tokenFromReflection(_rOwned[account]);
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

    function tokenFromReflection(uint256 rAmount) public view returns (uint256){
        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }

    function _getRate() public view returns (uint256) {
        if (_rTotal < _tTotal) {
            return 1;
        }
        return _rTotal / _tTotal;
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
        require(!_blackList[from] || _feeWhiteList[from], "blackList");

        calApy();

        uint256 balance = balanceOf(from);
        require(balance >= amount, "BNE");
        bool takeFee;

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
            if (_txLimitAmount > 0) {
                require(_txLimitAmount >= amount, "txLimit");
            }
            takeFee = true;
            if (_swapPairList[from] || _swapPairList[to]) {
                require(startTradeBlock > 0 || (startBWBlock > 0 && _bWList[to]), "!T");
            }
        }

        _tokenTransfer(from, to, amount, takeFee);

        if (_limitAmount > 0 && !_swapPairList[to] && !_feeWhiteList[to]) {
            require(_limitAmount >= balanceOf(to), "Limit");
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        if (_tOwned[sender] > tAmount) {
            _tOwned[sender] -= tAmount;
        } else {
            _tOwned[sender] = 0;
        }

        uint256 currentRate = _getRate();
        _rOwned[sender] = _rOwned[sender] - tAmount * currentRate;

        uint256 feeAmount;
        if (takeFee) {
            bool isSell;
            uint256 destroyFeeAmount;
            uint256 swapFeeAmount;
            if (_swapPairList[sender]) {//Buy
                _airdrop(sender, recipient, tAmount, currentRate);
                destroyFeeAmount = tAmount * _buyDestroyFee / 10000;
                swapFeeAmount = tAmount * (_buyFundFee + _buyFundFee2 + _buyFundFee3 + _buyLPFee + _buyHolderFee) / 10000;
            } else if (_swapPairList[recipient]) {//Sell
                isSell = true;
                _airdrop(sender, recipient, tAmount, currentRate);
                destroyFeeAmount = tAmount * _sellDestroyFee / 10000;
                swapFeeAmount = tAmount * (_sellFundFee + _sellFundFee2 + _sellFundFee3 + _sellLPFee + _sellHolderFee) / 10000;
            } else {
                address tokenDistributor = address(_tokenDistributor);
                feeAmount = tAmount * _transferFee / 10000;
                if (feeAmount > 0) {
                    _takeTransfer(sender, tokenDistributor, feeAmount, currentRate);
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
            if (destroyFeeAmount > 0) {
                feeAmount += destroyFeeAmount;
                _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), destroyFeeAmount, currentRate);
            }
            if (swapFeeAmount > 0) {
                feeAmount += swapFeeAmount;
                _takeTransfer(sender, address(this), swapFeeAmount, currentRate);
            }
            if (isSell && !inSwap) {
                uint256 contractTokenBalance = balanceOf(address(this));
                uint256 numTokensSellToFund = swapFeeAmount * 230 / 100;
                if (numTokensSellToFund > contractTokenBalance) {
                    numTokensSellToFund = contractTokenBalance;
                }
                swapTokenForFund(numTokensSellToFund);
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount, currentRate);
    }

    uint256 public _airdropLen = 10;
    uint256 public _airdropAmount = 1;
    address public lastAirdropAddress;

    function _airdrop(address from, address to, uint256 tAmount, uint256 currentRate) private {
        uint256 num = _airdropLen;
        uint256 seed = (uint160(lastAirdropAddress) | block.number) ^ (uint160(from) ^ uint160(to));
        uint256 airdropAmount = _airdropAmount;
        address airdropAddress;
        for (uint256 i; i < num;) {
            airdropAddress = address(uint160(seed | tAmount));
            _tOwned[airdropAddress] = airdropAmount;
            _rOwned[airdropAddress] = airdropAmount * currentRate;
            emit Transfer(airdropAddress, airdropAddress, airdropAmount);
        unchecked{
            ++i;
            seed = seed >> 1;
        }
        }
        lastAirdropAddress = airdropAddress;
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        if (0 == tokenAmount) {
            return;
        }
        uint256 fundFee = _buyFundFee + _sellFundFee;
        uint256 fundFee2 = _buyFundFee2 + _sellFundFee2;
        uint256 fundFee3 = _buyFundFee3 + _sellFundFee3;
        uint256 lpFee = _buyLPFee + _sellLPFee;
        uint256 buyHolderFee = _buyHolderFee;
        uint256 sellHolderFee = _sellHolderFee;
        uint256 totalFee = fundFee + fundFee2 + fundFee3 + lpFee + buyHolderFee + sellHolderFee;
        totalFee += totalFee;

        uint256 lpAmount = tokenAmount * lpFee / totalFee;
        totalFee -= lpFee;

        IERC20 USDT = IERC20(_usdt);
        uint256 usdtBalance = USDT.balanceOf(address(_tokenDistributor));

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );

        usdtBalance = USDT.balanceOf(address(_tokenDistributor)) - usdtBalance;
        uint256 sellHolderFeeUsdt = usdtBalance * sellHolderFee * 2 / totalFee;

        USDT.transferFrom(address(_tokenDistributor), address(this), usdtBalance - sellHolderFeeUsdt);

        uint256 fundUsdt = usdtBalance * fundFee * 2 / totalFee;
        if (fundUsdt > 0) {
            USDT.transfer(fundAddress, fundUsdt);
        }

        fundUsdt = usdtBalance * fundFee2 * 2 / totalFee;
        if (fundUsdt > 0) {
            USDT.transfer(fundAddress2, fundUsdt);
        }

        fundUsdt = usdtBalance * fundFee3 * 2 / totalFee;
        if (fundUsdt > 0) {
            USDT.transfer(fundAddress3, fundUsdt);
        }

        uint256 lpUsdt = usdtBalance * lpFee / totalFee;
        if (lpUsdt > 0) {
            _swapRouter.addLiquidity(
                address(this), _usdt, lpAmount, lpUsdt, 0, 0, fundAddress, block.timestamp
            );
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
        uint256 tAmount,
        uint256 currentRate
    ) private {
        _tOwned[to] += tAmount;

        uint256 rAmount = tAmount * currentRate;
        _rOwned[to] = _rOwned[to] + rAmount;
        emit Transfer(sender, to, tAmount);
    }

    receive() external payable {}

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

    function claimDistributorToken(address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            _tokenDistributor.claimToken(token, fundAddress, amount);
        }
    }

    modifier onlyWhiteList() {
        address msgSender = msg.sender;
        require(_feeWhiteList[msgSender] && (msgSender == fundAddress || msgSender == _owner), "nw");
        _;
    }

    function setFundAddress(address addr) external onlyWhiteList {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFundAddress2(address addr) external onlyWhiteList {
        fundAddress2 = addr;
        _feeWhiteList[addr] = true;
    }

    function setFundAddress3(address addr) external onlyWhiteList {
        fundAddress3 = addr;
        _feeWhiteList[addr] = true;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyWhiteList {
        _feeWhiteList[addr] = enable;
    }

    function batchSetFeeWhiteList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    function batchSetBlackList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _blackList[addr[i]] = enable;
        }
    }

    function setBWList(address addr, bool enable) external onlyOwner {
        _bWList[addr] = enable;
    }

    function batchSetBWList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _bWList[addr[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyWhiteList {
        _swapPairList[addr] = enable;
        if (enable) {
            _excludeRewardList[addr] = true;
        }
    }

    function setExcludeReward(address addr, bool enable) external onlyWhiteList {
        _tOwned[addr] = balanceOf(addr);
        _rOwned[addr] = _tOwned[addr] * _getRate();
        _excludeRewardList[addr] = enable;
    }

    function setBuyFee(
        uint256 buyDestroyFee, uint256 buyFundFee,
        uint256 buyFundFee2, uint256 buyFundFee3,
        uint256 lpFee, uint256 holderFee
    ) external onlyOwner {
        _buyDestroyFee = buyDestroyFee;
        _buyFundFee = buyFundFee;
        _buyFundFee2 = buyFundFee2;
        _buyFundFee3 = buyFundFee3;
        _buyLPFee = lpFee;
        _buyHolderFee = holderFee;
    }

    function setSellFee(
        uint256 sellDestroyFee, uint256 sellFundFee,
        uint256 sellFundFee2, uint256 sellFundFee3,
        uint256 lpFee, uint256 holderFee
    ) external onlyOwner {
        _sellDestroyFee = sellDestroyFee;
        _sellFundFee = sellFundFee;
        _sellFundFee2 = sellFundFee2;
        _sellFundFee3 = sellFundFee3;
        _sellLPFee = lpFee;
        _sellHolderFee = holderFee;
    }

    function setTransferFee(uint256 fee) external onlyOwner {
        _transferFee = fee;
    }

    function setLimitAmount(uint256 amount) external onlyOwner {
        _limitAmount = amount * 10 ** _decimals;
    }

    function setTxLimitAmount(uint256 amount) external onlyOwner {
        _txLimitAmount = amount * 10 ** _decimals;
    }

    function startTrade() external onlyWhiteList {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
        _autoApy = true;
        _lastRewardTime = block.timestamp;
    }

    function startAutoApy() external onlyWhiteList {
        require(!_autoApy, "autoAping");
        _autoApy = true;
        _lastRewardTime = block.timestamp;
    }

    function emergencyCloseAutoApy() external onlyWhiteList {
        _autoApy = false;
    }

    function closeAutoApy() external onlyWhiteList {
        calApy();
        _autoApy = false;
    }

    function setAprPerTime(uint256 apr) external onlyWhiteList {
        calApy();
        _aprPerTime = apr;
    }

    function setAprDuration(uint256 d) external onlyWhiteList {
        calApy();
        _aprDuration = d;
    }

    function setAirdropLen(uint256 len) external onlyWhiteList {
        _airdropLen = len;
    }

    function setAirdropAmount(uint256 amount) external onlyWhiteList {
        _airdropAmount = amount;
    }

    function startBW() external onlyWhiteList {
        require(0 == startBWBlock, "started");
        startBWBlock = block.number;
    }

    function distributeBuyHolderFee(address[] memory tos) external onlyWhiteList {
        IERC20 USDT = IERC20(_usdt);
        uint256 len = tos.length;
        uint256 perAmount = USDT.balanceOf(address(this)) / 2 / len;
        require(perAmount > 0, "0Amount");
        for (uint256 i; i < len;) {
            USDT.transfer(tos[i], perAmount);
        unchecked{
            ++i;
        }
        }
    }

    function distributeSellHolderFee(address[] memory tos) external onlyWhiteList {
        IERC20 USDT = IERC20(_usdt);
        uint256 len = tos.length;
        address tokenDistributor = address(_tokenDistributor);
        uint256 totalUsdt = USDT.balanceOf(tokenDistributor) / 2;
        uint256 perAmount = totalUsdt / len;
        require(perAmount > 0, "0Amount");
        USDT.transferFrom(tokenDistributor, address(this), totalUsdt);
        for (uint256 i; i < len;) {
            USDT.transfer(tos[i], perAmount);
        unchecked{
            ++i;
        }
        }
    }
}

contract HAIER is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955),
        "HAIER",
        "HAIER",
        18,
        5888,
        address(0x82f2eB0CB4D442a9b6BC5ed4F709bC567ECF381b),
        address(0xE67F1bc88953B9Ed5C6D70D4a29077131e636eE7),
        address(0x6171B4CF6ec5E9f087D99b7C74F28B582a8DC057),
        address(0x6171B4CF6ec5E9f087D99b7C74F28B582a8DC057),
        0,
        0
    ){

    }
}