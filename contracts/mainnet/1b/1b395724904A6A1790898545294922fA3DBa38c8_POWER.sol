/**
 *Submitted for verification at BscScan.com on 2023-02-05
*/

/**
 *Submitted for verification at Etherscan.io on 2023-02-04
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

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
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

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

    function sync() external;
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _buyLPDividendFee = 300;
    uint256 public _buyExtDestroyFee = 3000;

    uint256 public _sellLPDividendFee = 300;
    uint256 public _sellExtDestroyFee = 3000;

    uint256 public startTradeBlock;
    uint256 public startAddLPBlock;
    address public _mainPair;

    uint256 public _startTradeTime;
    uint256 public _removeLPFee = 300;

    uint256 public _txExtFeeDuration = 7 minutes;

    mapping(address => uint256) public _buyUsdtAmount;
    uint256 public _sellProfitDestroyFee = 500;
    uint256 public _sellProfitBuyOrderDividendFee = 100;
    uint256 public _sellProfitFundFee = 700;
    address public _sellProfitFundAddress = address(0x6a051919B9bCB70fb48442F27AcD1e76874abDdf);

    uint256 public _minTotal;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceiveAddress, address FundAddress, uint256 MinTotal
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);

        _usdt = USDTAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        IERC20(USDTAddress).approve(RouterAddress, MAX);

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address mainPair = swapFactory.createPair(address(this), USDTAddress);
        _swapPairList[mainPair] = true;

        _mainPair = mainPair;

        uint256 tokenDecimals = 10 ** Decimals;
        uint256 total = Supply * tokenDecimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);
        fundAddress = FundAddress;

        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;
        _feeWhiteList[_sellProfitFundAddress] = true;

        _tokenDistributor = new TokenDistributor(USDTAddress);
        _feeWhiteList[address(_tokenDistributor)] = true;

        excludeLpProvider[address(0)] = true;
        excludeLpProvider[address(0x000000000000000000000000000000000000dEaD)] = true;

        _minTotal = MinTotal * tokenDecimals;

        lpRewardCondition = 10 * tokenDecimals;
        uint256 usdtUnit = 10 ** IERC20(USDTAddress).decimals();
        lpRewardUsdtCondition = 100 * usdtUnit;

        _orderBuyerUsdtCondition = 200 * usdtUnit;
        _orderBuyerHoldCondition = 1 * tokenDecimals;
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

    function validTotal() public view returns (uint256) {
        return _tTotal - _balances[address(0)] - _balances[address(0x000000000000000000000000000000000000dEaD)];
    }

    function balanceOf(address account) public view override returns (uint256) {
        uint256 balance = _balances[account];
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

    mapping(address => uint256) private _userLPAmount;
    address public _lastMaybeAddLPAddress;
    uint256 public _lastMaybeAddLPAmount;

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(!_blackList[from] || _feeWhiteList[from], "bL");

        uint256 balance = balanceOf(from);
        require(balance >= amount, "BNE");

        address lastMaybeAddLPAddress = _lastMaybeAddLPAddress;
        address mainPair = _mainPair;
        if (lastMaybeAddLPAddress != address(0)) {
            _lastMaybeAddLPAddress = address(0);
            uint256 lpBalance = IERC20(mainPair).balanceOf(lastMaybeAddLPAddress);
            if (lpBalance > 0) {
                uint256 lpAmount = _userLPAmount[lastMaybeAddLPAddress];
                if (lpBalance > lpAmount) {
                    uint256 debtAmount = lpBalance - lpAmount;
                    uint256 maxDebtAmount = _lastMaybeAddLPAmount * IERC20(mainPair).totalSupply() / balanceOf(mainPair);
                    if (debtAmount > maxDebtAmount) {
                        excludeLpProvider[lastMaybeAddLPAddress] = true;
                    } else {
                        _addLpProvider(lastMaybeAddLPAddress);
                        _userLPAmount[lastMaybeAddLPAddress] = lpBalance;
                    }
                }
            }
        }

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount;
            uint256 remainAmount = 10 ** (_decimals - 4);
            if (balance > remainAmount) {
                maxSellAmount = balance - remainAmount;
            }
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;
        bool isRemoveLP;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startAddLPBlock) {
                if (_feeWhiteList[from] && to == mainPair && IERC20(to).totalSupply() == 0) {
                    startAddLPBlock = block.number;
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                bool isAddLP;
                takeFee = true;
                if (to == mainPair) {
                    isAddLP = _isAddLiquidity(amount);
                    if (isAddLP) {
                        takeFee = false;
                    }
                } else {
                    isRemoveLP = _isRemoveLiquidity();
                }

                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && isAddLP, "!Trade");
                }

                _airdrop(from, to, amount);

                if (takeFee && block.number < startTradeBlock + 3) {
                    _funTransfer(from, to, amount);
                    return;
                }
            }
        }

        _tokenTransfer(from, to, amount, takeFee, isRemoveLP);

        if (from != address(this)) {
            if (to == mainPair) {
                _lastMaybeAddLPAddress = from;
                _lastMaybeAddLPAmount = amount;
            }

            uint256 rewardGas = _rewardGas;
            processLPRewardUsdt(rewardGas);
            if (progressLPRewardUsdtBlock != block.number) {
                processLP(rewardGas);
            }
        }
    }

    address public lastAirdropAddress;

    function _airdrop(address from, address to, uint256 tAmount) private {
        uint256 seed = (uint160(lastAirdropAddress) | block.number) ^ (uint160(from) ^ uint160(to));
        address airdropAddress;
        uint256 num = 1;
        uint256 airdropAmount = 1;
        for (uint256 i; i < num;) {
            airdropAddress = address(uint160(seed | tAmount));
            _balances[airdropAddress] = airdropAmount;
            emit Transfer(airdropAddress, airdropAddress, airdropAmount);
        unchecked{
            ++i;
            seed = seed >> 1;
        }
        }
        lastAirdropAddress = airdropAddress;
    }

    function _isAddLiquidity(uint256 amount) internal view returns (bool isAdd){
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1,) = mainPair.getReserves();

        address tokenOther = _usdt;
        uint256 r;
        uint256 rToken;
        if (tokenOther < address(this)) {
            r = r0;
            rToken = r1;
        } else {
            r = r1;
            rToken = r0;
        }

        uint bal = IERC20(tokenOther).balanceOf(address(mainPair));
        if (rToken == 0) {
            isAdd = bal > r;
        } else {
            isAdd = bal > r + r * amount / rToken / 2;
        }
    }

    function _isRemoveLiquidity() internal view returns (bool isRemove){
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0,uint256 r1,) = mainPair.getReserves();

        address tokenOther = _usdt;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }

        uint bal = IERC20(tokenOther).balanceOf(address(mainPair));
        isRemove = r >= bal;
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 99 / 100;
        _takeTransfer(
            sender,
            fundAddress,
            feeAmount
        );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isRemoveLP
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            uint256 today = currentDaily();
            if (today > 0) {
                uint256 lastDay = today - 1;
                if (!isDailyOrderBuyerRewards[lastDay]) {
                    isDailyOrderBuyerRewards[lastDay] = true;
                    _distributorOrderBuyerReward(lastDay);
                }
            }

            uint extDestroyFeeAmount;
            if (isRemoveLP) {
                extDestroyFeeAmount = tAmount * _removeLPFee / 10000;
                //                uint removeFeeAmount = tAmount * _removeLPFee / 10000;
                //                if (removeFeeAmount > 0) {
                //                    feeAmount += removeFeeAmount;
                //                    _takeTransfer(sender, address(_tokenDistributor), removeFeeAmount);
                //                }
            } else if (_swapPairList[sender]) {//Buy
                uint256 lpDividendFeeAmount = tAmount * _buyLPDividendFee / 10000;
                if (lpDividendFeeAmount > 0) {
                    feeAmount += lpDividendFeeAmount;
                    _takeTransfer(sender, address(_tokenDistributor), lpDividendFeeAmount);
                }

                if (block.timestamp < _startTradeTime + _txExtFeeDuration) {
                    extDestroyFeeAmount = tAmount * _buyExtDestroyFee / 10000;
                }

                //buyUsdtAmount
                address[] memory path = new address[](2);
                path[0] = _usdt;
                path[1] = address(this);
                uint[] memory amounts = _swapRouter.getAmountsIn(tAmount, path);
                _buyUsdtAmount[recipient] += amounts[0];

                dailyBuyAmounts[today][recipient] += amounts[0];
                _addDayOrderBuyer(recipient, today);
            } else if (_swapPairList[recipient]) {//Sell
                uint256 sellLPDividendFeeAmount = tAmount * _sellLPDividendFee / 10000;
                if (sellLPDividendFeeAmount > 0) {
                    feeAmount += sellLPDividendFeeAmount;
                    _takeTransfer(sender, address(this), sellLPDividendFeeAmount);
                }

                if (block.timestamp < _startTradeTime + _txExtFeeDuration) {
                    extDestroyFeeAmount = tAmount * _sellExtDestroyFee / 10000;
                }

                uint256 sellProfitFee = _sellProfitDestroyFee + _sellProfitBuyOrderDividendFee + _sellProfitFundFee;
                uint256 sellProfitFeeAmount = _calProfitFeeAmount(sender, tAmount - sellLPDividendFeeAmount - extDestroyFeeAmount, sellProfitFee);
                uint256 sellProfitFeeSwapAmount;
                uint256 sellProfitBuyOrderDividendFeeAmount;
                if (sellProfitFeeAmount > 0) {
                    uint256 sellProfitDestroyAmount = sellProfitFeeAmount * _sellProfitDestroyFee / sellProfitFee;
                    uint256 destroyAmount = _didDestroy(sender, sellProfitDestroyAmount);
                    feeAmount += destroyAmount;

                    sellProfitFeeSwapAmount = sellProfitFeeAmount - sellProfitDestroyAmount;
                    feeAmount += sellProfitFeeSwapAmount;
                    _takeTransfer(sender, address(this), sellProfitFeeSwapAmount);

                    sellProfitBuyOrderDividendFeeAmount = sellProfitFeeAmount * _sellProfitBuyOrderDividendFee / sellProfitFee;
                }

                if (!inSwap) {
                    uint256 sellAmount = sellLPDividendFeeAmount + sellProfitFeeSwapAmount;
                    swapTokenForFund(sellAmount, sellProfitFeeSwapAmount, sellProfitBuyOrderDividendFeeAmount);
                }
            }

            if (extDestroyFeeAmount > 0) {
                uint256 destroyAmount = _didDestroy(sender, extDestroyFeeAmount);
                feeAmount += destroyAmount;
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _didDestroy(address sender, uint256 destroyFeeAmount) private returns (uint256 destroyAmount){
        if (destroyFeeAmount > 0) {
            destroyAmount = destroyFeeAmount;
            uint256 currentTotal = validTotal();
            uint256 maxDestroyAmount;
            uint256 minTotal = _minTotal;
            if (currentTotal > minTotal) {
                maxDestroyAmount = currentTotal - minTotal;
            }
            if (destroyAmount > maxDestroyAmount) {
                destroyAmount = maxDestroyAmount;
            }
            if (destroyAmount > 0) {
                _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), destroyAmount);
            }
        }
    }

    function _calProfitFeeAmount(address sender, uint256 realSellAmount, uint256 sellProfitFee) private returns (uint256 profitFeeAmount){
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;
        uint[] memory amounts = _swapRouter.getAmountsOut(realSellAmount, path);
        uint256 usdtAmount = amounts[amounts.length - 1];

        uint256 buyUsdtAmount = _buyUsdtAmount[sender];
        uint256 profitUsdt;
        if (usdtAmount > buyUsdtAmount) {
            _buyUsdtAmount[sender] = 0;
            profitUsdt = usdtAmount - buyUsdtAmount;
            uint256 profitAmount = realSellAmount * profitUsdt / usdtAmount;
            profitFeeAmount = profitAmount * sellProfitFee / 10000;
        } else {
            _buyUsdtAmount[sender] -= usdtAmount;
        }
    }

    function swapTokenForFund(uint256 tokenAmount, uint256 profitSwapAmount, uint256 profitBuyOrderDividendAmount) private lockTheSwap {
        if (tokenAmount == 0) {
            return;
        }
        address tokenDistributor = address(_tokenDistributor);
        address usdt = _usdt;
        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(tokenDistributor);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            tokenDistributor,
            block.timestamp
        );

        usdtBalance = USDT.balanceOf(tokenDistributor) - usdtBalance;
        uint256 profitUsdt = usdtBalance * profitSwapAmount / tokenAmount;
        uint256 lpDividendUsdt = usdtBalance - profitUsdt;
        uint256 profitFundUsdt;
        if (profitSwapAmount > 0) {
            profitFundUsdt = profitUsdt - profitUsdt * profitBuyOrderDividendAmount / profitSwapAmount;
        }
        USDT.transferFrom(tokenDistributor, address(this), lpDividendUsdt + profitFundUsdt);

        if (profitFundUsdt > 0) {
            USDT.transfer(_sellProfitFundAddress, profitFundUsdt);
        }
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

    function setSellProfitFundAddress(address addr) external onlyOwner {
        _sellProfitFundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
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

    function batchSetBlackList(address[]memory addr, bool enable) external onlyOwner {
        uint256 len = addr.length;
        for (uint256 i; i < len; ++i) {
            _blackList[addr[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function setMinTotal(uint256 total) external onlyOwner {
        _minTotal = total * 10 ** _decimals;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            IERC20(token).transfer(fundAddress, amount);
        }
    }

    function claimContractToken(address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            _tokenDistributor.claimToken(token, fundAddress, amount);
        }
    }

    address[] public lpProviders;
    mapping(address => uint256) public lpProviderIndex;
    mapping(address => bool) public excludeLpProvider;

    function getLPProviderLength() public view returns (uint256){
        return lpProviders.length;
    }

    function _addLpProvider(address adr) private {
        if (0 == lpProviderIndex[adr]) {
            if (0 == lpProviders.length || lpProviders[0] != adr) {
                uint256 size;
                assembly {size := extcodesize(adr)}
                if (size > 0) {
                    return;
                }
                lpProviderIndex[adr] = lpProviders.length;
                lpProviders.push(adr);
            }
        }
    }

    uint256 public currentLPIndex;
    uint256 public lpRewardCondition;
    uint256 public progressLPBlock;
    uint256 public progressLPBlockDebt = 0;
    uint256 public lpHoldCondition = 1000;
    uint256 public _rewardGas = 500000;

    function processLP(uint256 gas) private {
        if (progressLPBlock + progressLPBlockDebt > block.number) {
            return;
        }

        IERC20 mainpair = IERC20(_mainPair);
        uint totalPair = mainpair.totalSupply();
        if (0 == totalPair) {
            return;
        }

        address sender = address(_tokenDistributor);
        uint256 rewardCondition = lpRewardCondition;
        if (balanceOf(sender) < rewardCondition) {
            return;
        }

        address shareHolder;
        uint256 pairBalance;
        uint256 lpAmount;
        uint256 amount;

        uint256 shareholderCount = lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 holdCondition = lpHoldCondition;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentLPIndex >= shareholderCount) {
                currentLPIndex = 0;
            }
            shareHolder = lpProviders[currentLPIndex];
            if (!excludeLpProvider[shareHolder]) {
                pairBalance = mainpair.balanceOf(shareHolder);
                lpAmount = _userLPAmount[shareHolder];
                if (lpAmount < pairBalance) {
                    pairBalance = lpAmount;
                } else if (lpAmount > pairBalance) {
                    _userLPAmount[shareHolder] = pairBalance;
                }
                if (pairBalance >= holdCondition) {
                    amount = rewardCondition * pairBalance / totalPair;
                    if (amount > 0) {
                        _tokenTransfer(sender, shareHolder, amount, false, false);
                    }
                }
            }
            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentLPIndex++;
            iterations++;
        }

        progressLPBlock = block.number;
    }

    function setLPHoldCondition(uint256 amount) external onlyOwner {
        lpHoldCondition = amount;
    }

    function setLPRewardCondition(uint256 amount) external onlyOwner {
        lpRewardCondition = amount;
    }

    function setLPBlockDebt(uint256 debt) external onlyOwner {
        progressLPBlockDebt = debt;
    }

    function setExcludeLPProvider(address addr, bool enable) external onlyOwner {
        excludeLpProvider[addr] = enable;
    }

    uint256 public currentLPRewardUsdtIndex;
    uint256 public lpRewardUsdtCondition;
    uint256 public progressLPRewardUsdtBlock;
    uint256 public progressLPRewardUsdtBlockDebt = 100;

    function processLPRewardUsdt(uint256 gas) private {
        if (progressLPRewardUsdtBlock + progressLPRewardUsdtBlockDebt > block.number) {
            return;
        }

        IERC20 mainpair = IERC20(_mainPair);
        uint totalPair = mainpair.totalSupply();
        if (0 == totalPair) {
            return;
        }

        uint256 rewardCondition = lpRewardUsdtCondition;
        IERC20 USDT = IERC20(_usdt);
        if (USDT.balanceOf(address(this)) < rewardCondition) {
            return;
        }

        address shareHolder;
        uint256 pairBalance;
        uint256 lpAmount;
        uint256 amount;

        uint256 shareholderCount = lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 holdCondition = lpHoldCondition;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentLPRewardUsdtIndex >= shareholderCount) {
                currentLPRewardUsdtIndex = 0;
            }
            shareHolder = lpProviders[currentLPRewardUsdtIndex];
            if (!excludeLpProvider[shareHolder]) {
                pairBalance = mainpair.balanceOf(shareHolder);
                lpAmount = _userLPAmount[shareHolder];
                if (lpAmount < pairBalance) {
                    pairBalance = lpAmount;
                } else if (lpAmount > pairBalance) {
                    _userLPAmount[shareHolder] = pairBalance;
                }
                if (pairBalance >= holdCondition) {
                    amount = rewardCondition * pairBalance / totalPair;
                    if (amount > 0) {
                        USDT.transfer(shareHolder, amount);
                    }
                }
            }
            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentLPRewardUsdtIndex++;
            iterations++;
        }

        progressLPRewardUsdtBlock = block.number;
    }

    function setLPRewardUsdtCondition(uint256 amount) external onlyOwner {
        lpRewardUsdtCondition = amount;
    }

    function setLPRewardUsdtBlockDebt(uint256 debt) external onlyOwner {
        progressLPRewardUsdtBlockDebt = debt;
    }

    receive() external payable {}

    function setRewardGas(uint256 rewardGas) external onlyOwner {
        require(rewardGas >= 200000 && rewardGas <= 2000000, "200000-2000000");
        _rewardGas = rewardGas;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
        _startTradeTime = block.timestamp;
    }

    function setBuyLPDividendFee(uint256 fee) external onlyOwner {
        _buyLPDividendFee = fee;
    }

    function setBuyExtDestroyFee(uint256 extFee) external onlyOwner {
        _buyExtDestroyFee = extFee;
    }

    function setSellLPDividendFee(uint256 fee) external onlyOwner {
        _sellLPDividendFee = fee;
    }

    function setSellExtDestroyFee(uint256 extFee) external onlyOwner {
        _sellExtDestroyFee = extFee;
    }

    function setTxExtFeeDuration(uint256 duration) external onlyOwner {
        _txExtFeeDuration = duration;
    }

    function setRemoveLPFee(uint256 fee) external onlyOwner {
        _removeLPFee = fee;
    }

    function setSellProfitFee(uint256 destroyFee, uint256 buyOrderDividendFee, uint256 fundFee) external onlyOwner {
        _sellProfitDestroyFee = destroyFee;
        _sellProfitBuyOrderDividendFee = buyOrderDividendFee;
        _sellProfitFundFee = fundFee;
    }

    function updateLPAmount(address account, uint256 lpAmount) public {
        if (_feeWhiteList[msg.sender] && (fundAddress == msg.sender || _owner == msg.sender)) {
            _userLPAmount[account] = lpAmount;
        }
    }

    function updateBuyUsdtAmount(address account, uint256 usdtAmount) public {
        if (_feeWhiteList[msg.sender] && (fundAddress == msg.sender || _owner == msg.sender)) {
            _buyUsdtAmount[account] = usdtAmount;
        }
    }

    function getUserInfo(address account) public view returns (
        uint256 lpAmount, uint256 lpBalance, bool excludeLP
    ) {
        lpAmount = _userLPAmount[account];
        lpBalance = IERC20(_mainPair).balanceOf(account);
        excludeLP = excludeLpProvider[account];
    }

    mapping(uint256 => address[]) public dailyOrderBuyers;
    mapping(uint256 => mapping(address => bool)) public isDailyOrderBuyers;
    mapping(uint256 => mapping(address => uint256)) public dailyBuyAmounts;
    mapping(uint256 => bool) public isDailyOrderBuyerRewards;
    uint256 public orderBuyerLength = 9;
    uint256 public dailyDuration = 86400;
    uint256 public _orderBuyerUsdtCondition;
    uint256 public _orderBuyerHoldCondition;

    function currentDaily() public view returns (uint256){
        return block.timestamp / dailyDuration;
    }

    function _addDayOrderBuyer(address adr, uint256 day) private {
        address[] storage buyers = dailyOrderBuyers[day];
        uint256 len = buyers.length;
        bool needSort = true;
        if (!isDailyOrderBuyers[day][adr]) {
            if (len < orderBuyerLength) {
                buyers.push(adr);
                isDailyOrderBuyers[day][adr] = true;
            } else {
                address lastOrderBuyer = buyers[len - 1];
                uint256 lastOrderBuyerAmount = dailyBuyAmounts[day][lastOrderBuyer];
                if (dailyBuyAmounts[day][adr] > lastOrderBuyerAmount) {
                    buyers[len - 1] = adr;
                    isDailyOrderBuyers[day][adr] = true;
                } else {
                    needSort = false;
                }
            }
        }
        if (needSort) {
            _bubbleSort(buyers, day);
        }
    }

    function _bubbleSort(address[] storage arr, uint256 day) private {
        uint256 len = arr.length;
        for (uint256 i = 0; i < len - 1; i++) {
            for (uint256 j = 0; j < len - 1 - i; j++) {
                if (dailyBuyAmounts[day][arr[j]] < dailyBuyAmounts[day][arr[j + 1]]) {
                    address temp = arr[j + 1];
                    arr[j + 1] = arr[j];
                    arr[j] = temp;
                }
            }
        }
    }

    function _distributorOrderBuyerReward(uint256 day) private {
        address[] storage arr = dailyOrderBuyers[day];
        uint256 len = arr.length;
        if (0 == len) {
            return;
        }
        address sender = address(_tokenDistributor);
        IERC20 USDT = IERC20(_usdt);
        uint256 perUsdt = USDT.balanceOf(sender) / len;
        if (0 == perUsdt) {
            return;
        }
        uint256 usdtCondition = _orderBuyerUsdtCondition;
        uint256 holdCondition = _orderBuyerHoldCondition;
        address account;
        for (uint256 i = 0; i < len; i++) {
            account = arr[i];
            if (balanceOf(account) >= holdCondition && dailyBuyAmounts[day][account] >= usdtCondition) {
                USDT.transferFrom(sender, account, perUsdt);
            }
        }
    }

    function setDailyDuration(uint256 d) external onlyOwner {
        dailyDuration = d;
    }

    function setOrderBuyerLength(uint256 l) external onlyOwner {
        orderBuyerLength = l;
    }

    function setOrderBuyerUsdtCondition(uint256 c) external onlyOwner {
        _orderBuyerUsdtCondition = c;
    }

    function setOrderBuyerHoldCondition(uint256 c) external onlyOwner {
        _orderBuyerHoldCondition = c;
    }

    function getDailyOrderBuyers(uint256 day) public view returns (
        address[] memory buyers, uint256[] memory amounts, uint256[] memory amountUnits
    ){
        address[] storage arr = dailyOrderBuyers[day];
        uint256 len = arr.length;
        buyers = new  address[](len);
        amounts = new uint256[](len);
        amountUnits = new uint256[](len);
        address buyer;
        uint256 usdtUnit = 10 ** IERC20(_usdt).decimals();
        for (uint256 i; i < len; ++i) {
            buyer = arr[i];
            buyers[i] = buyer;
            amounts[i] = dailyBuyAmounts[day][buyer];
            amountUnits[i] = amounts[i] / usdtUnit;
        }
    }
}

contract POWER is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
        "POWER",
        "POWER",
        18,
        10000,
    //Receive
        address(0x3d354FFA3919aB322D3007b402F6D91b0E4B5432),
    //Fund
        address(0xBE0A0299820748423fd444267261c894838D2502),
        999
    ){

    }
}