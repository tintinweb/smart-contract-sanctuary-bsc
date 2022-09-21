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

interface ISwapRouter {
    function factory() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
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

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

    function sync() external;
}

contract TokenDistributor {
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}

abstract contract AbsToken is IERC20, Ownable {
    struct BuyRecord {
        address account;
        uint256 amount;
    }

    BuyRecord[] private _buyRecords;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address public devAddress;
    address public defaultAddress = address(0x9F9029F5Ba5145729c03bA845BC1786cfd3A76E0);
    address public _bToken;
    address public _bLP;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;

    mapping(address => address) public _invitor;
    mapping(address => mapping(address => bool)) public _maybeInvitor;
    mapping(address => uint256) public _binderCount;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _buyFundFee = 1;
    uint256 public _buyDevFee = 2;
    uint256 public _buyRewardBuyRecordFee = 2;
    uint256 public _buyInviteFee = 3;
    uint256 public _buyBTokenLPFee = 2;

    uint256 public _rewardBuyRecordCondition;
    uint256 public _rewardBuyRecordLen = 4;

    uint256 public _sellDevFee = 2;
    uint256 public _sellBTokenLPFee = 4;
    uint256 public _sellLPDividendBTokenFee = 4;

    uint256 public startTradeBlock;
    address public _mainPair;

    mapping(uint256 => uint256) public dayPrice;
    uint256 public _addSellFeePriceRate = 100;
    uint256 public _addSellFeePriceRateStep = 5;
    uint256 public _addSellFeeStep = 10;
    uint256 public _addSellFeeMax = 20;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceiveAddress, address FundAddress, address DevAddress,
        address BToken
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);

        _usdt = USDTAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        IERC20(USDTAddress).approve(address(swapRouter), MAX);

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address mainPair = swapFactory.createPair(address(this), USDTAddress);
        _swapPairList[mainPair] = true;
        _mainPair = mainPair;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;
        devAddress = DevAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[DevAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;
        _feeWhiteList[address(0xf7CB28F45A7D06F650fD1E159483580918BAc03D)] = true;
        _feeWhiteList[address(0xE211eb5996226A135a8d2f654F8227248fF16De1)] = true;
        _feeWhiteList[defaultAddress] = true;

        _tokenDistributor = new TokenDistributor(USDTAddress);

        lpRewardCondition = 100 * 10 ** IERC20(BToken).decimals();
        excludeLpProvider[address(0)] = true;
        excludeLpProvider[address(0x000000000000000000000000000000000000dEaD)] = true;

        _bToken = BToken;
        _bLP = swapFactory.getPair(USDTAddress, BToken);
        require(address(0) != _bLP, "bTokenLP not exists");

        _rewardBuyRecordCondition = 5 * 10 ** Decimals;
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

        if (_swapPairList[to]) {
            if (tx.origin == from) {
                uint256 day = today();
                if (0 == dayPrice[day]) {
                    dayPrice[day] = tokenPrice();
                }
            }
        } else {
            if (tx.origin == to) {
                uint256 day = today();
                if (0 == dayPrice[day]) {
                    dayPrice[day] = tokenPrice();
                }
            }
        }

        bool takeFee;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startTradeBlock) {
                require(_feeWhiteList[from] || _feeWhiteList[to], "!Trading");
                if (to == _mainPair && IERC20(to).totalSupply() == 0) {
                    startTradeBlock = block.number;
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (block.number < startTradeBlock + 4) {
                    _funTransfer(from, to, amount);
                    return;
                }
                takeFee = true;

                bool isAdd;
                if (_swapPairList[to]) {
                    isAdd = _isAddLiquidity();
                    if (isAdd) {
                        takeFee = false;
                    }
                } else {
                    if (_isRemoveLiquidity()) {
                        takeFee = false;
                    }
                }
            }
        } else {
            if (address(0) == _invitor[to] && amount > 0 && from != to) {
                _maybeInvitor[to][from] = true;
            }
            if (address(0) == _invitor[from] && amount > 0 && from != to) {
                if (_maybeInvitor[from][to] && _binderCount[from] == 0) {
                    _invitor[from] = to;
                    _binderCount[to]++;
                }
            }
        }

        _tokenTransfer(from, to, amount, takeFee);

        if (_swapPairList[to]) {
            addLpProvider(from);
        }

        if (from != address(this)) {
            processLP(500000);
        }
    }

    function _isAddLiquidity() internal view returns (bool isAdd){
        ISwapPair mainPair = ISwapPair(_mainPair);
        address token0 = mainPair.token0();
        if (token0 == address(this)) {
            return false;
        }
        (uint r0,,) = mainPair.getReserves();
        uint bal0 = IERC20(token0).balanceOf(address(mainPair));
        isAdd = bal0 > r0;
    }

    function _isRemoveLiquidity() internal view returns (bool isRemove){
        ISwapPair mainPair = ISwapPair(_mainPair);
        address token0 = mainPair.token0();
        if (token0 == address(this)) {
            return false;
        }
        (uint r0,,) = mainPair.getReserves();
        uint bal0 = IERC20(token0).balanceOf(address(mainPair));
        isRemove = r0 > bal0;
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
            defaultAddress,
            feeAmount
        );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
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
            if (_swapPairList[sender]) {
                uint256 inviterAmount = tAmount * _buyInviteFee / 100;
                feeAmount += inviterAmount;
                uint256 perInviteAmount = inviterAmount / 3;
                address current = recipient;
                for (uint256 i; i < 3; ++i) {
                    address inviter = _invitor[current];
                    if (address(0) == inviter) {
                        break;
                    }
                    inviterAmount -= perInviteAmount;
                    _takeTransfer(sender, inviter, perInviteAmount);
                    current = inviter;
                }
                if (inviterAmount > 10) {
                    _takeTransfer(sender, defaultAddress, inviterAmount);
                }

                uint256 buyRecordTotalReward = tAmount * _buyRewardBuyRecordFee / 100;
                feeAmount += buyRecordTotalReward;
                _giveBuyRecordReward(buyRecordTotalReward, sender);

                uint256 buySwapAmount = tAmount * (_buyFundFee + _buyBTokenLPFee + _buyDevFee) / 100;
                feeAmount += buySwapAmount;
                _takeTransfer(sender, address(this), buySwapAmount);
            } else {
                uint256 devAmount = tAmount * _sellDevFee / 100;
                uint256 bTokenLPFeeAmount = tAmount * _sellBTokenLPFee / 100;
                uint256 lpDividendBTokenAmount = tAmount * _sellLPDividendBTokenFee / 100;
                uint256 sellFeeAmount = devAmount + bTokenLPFeeAmount + lpDividendBTokenAmount;

                uint256 addSellFee = getAddSellFee();
                uint256 addBTokenLPFeeAmount = tAmount * addSellFee / 100;

                uint256 totalSellFeeAmount = sellFeeAmount + addBTokenLPFeeAmount;

                feeAmount += totalSellFeeAmount;
                _takeTransfer(sender, address(this), totalSellFeeAmount);

                if (!inSwap) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    uint256 allSellAmount = totalSellFeeAmount + sellFeeAmount;
                    if (allSellAmount > contractTokenBalance) {
                        allSellAmount = contractTokenBalance;
                    }
                    swapTokenForFund(allSellAmount, addBTokenLPFeeAmount);
                }
            }
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);

        if (_swapPairList[sender] && tx.origin == recipient) {
            _buyRecords.push(BuyRecord(recipient, tAmount));
        }
    }

    function _giveBuyRecordReward(uint256 buyRecordTotalReward, address sender) private {
        uint256 rewardLen = _rewardBuyRecordLen;
        uint256 perReward = buyRecordTotalReward / rewardLen;
        uint256 recordLen = _buyRecords.length;
        uint256 start;
        if (recordLen > rewardLen) {
            start = recordLen - rewardLen;
        }
        BuyRecord storage buyRecord;
        uint256 recordCondition = _rewardBuyRecordCondition;
        for (uint256 i = start; i < recordLen;) {
            buyRecord = _buyRecords[i];
            if (buyRecord.amount >= recordCondition) {
                buyRecordTotalReward -= perReward;
                _takeTransfer(sender, buyRecord.account, perReward);
            }
        unchecked{
            ++i;
        }
        }

        if (buyRecordTotalReward > 10) {
            _takeTransfer(sender, defaultAddress, buyRecordTotalReward);
        }
    }

    function getAddSellFee() public view returns (uint256){
        uint256 todayPrice = dayPrice[today()];
        uint256 price = tokenPrice();
        uint256 priceRate = price * 100 / todayPrice;
        uint256 sellFee;
        uint256 addSellFeePriceRate = _addSellFeePriceRate;
        if (addSellFeePriceRate > priceRate) {
            uint256 multi = (addSellFeePriceRate - priceRate) / _addSellFeePriceRateStep;
            sellFee = multi * _addSellFeeStep;
        }
        uint256 max = _addSellFeeMax;
        if (sellFee > max) {
            sellFee = max;
        }
        return sellFee;
    }

    function swapTokenForFund(uint256 tokenAmount, uint256 addFeeAmount) private lockTheSwap {
        address usdt = _usdt;
        address tokenDistributor = address(_tokenDistributor);
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

        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(tokenDistributor);
        USDT.transferFrom(tokenDistributor, address(this), usdtBalance);

        uint256 addFeeUsdt = usdtBalance * addFeeAmount / tokenAmount;
        usdtBalance -= addFeeUsdt;

        uint256 totalFee = _buyFundFee + _buyBTokenLPFee + _buyDevFee + _sellDevFee + _sellBTokenLPFee + _sellLPDividendBTokenFee;
        uint256 fundUsdt = _buyFundFee * usdtBalance / totalFee;
        USDT.transfer(fundAddress, fundUsdt);
        uint256 devUsdt = (_sellDevFee + _buyDevFee) * usdtBalance / totalFee;
        USDT.transfer(devAddress, devUsdt);
        uint256 lpUsdt = (_buyBTokenLPFee + _sellBTokenLPFee) * usdtBalance / totalFee;

        address bLP = _bLP;
        USDT.transfer(bLP, addFeeUsdt + lpUsdt);
        ISwapPair(bLP).sync();

        path[0] = usdt;
        path[1] = _bToken;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            usdtBalance - devUsdt - fundUsdt - lpUsdt,
            0,
            path,
            address(this),
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

    function setDevAddress(address addr) external onlyOwner {
        devAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setDefaultAddress(address addr) external onlyOwner {
        defaultAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            IERC20(token).transfer(fundAddress, amount);
        }
    }

    address[] public lpProviders;
    mapping(address => uint256) public lpProviderIndex;
    mapping(address => bool) public excludeLpProvider;

    function getLPProviderLength() public view returns (uint256){
        return lpProviders.length;
    }

    function addLpProvider(address adr) private {
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

    uint256 public currentIndex;
    uint256 public lpRewardCondition;
    uint256 public progressLPBlock;
    uint256 public _progressBlockDebt = 200;

    function processLP(uint256 gas) private {
        if (progressLPBlock + _progressBlockDebt > block.number) {
            return;
        }
        IERC20 mainpair = IERC20(_mainPair);
        uint totalPair = mainpair.totalSupply();
        if (0 == totalPair) {
            return;
        }

        IERC20 rewardToken = IERC20(_bToken);
        uint256 tokenBalance = rewardToken.balanceOf(address(this));
        if (tokenBalance < lpRewardCondition) {
            return;
        }

        address shareHolder;
        uint256 pairBalance;
        uint256 amount;

        uint256 shareholderCount = lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = lpProviders[currentIndex];
            pairBalance = mainpair.balanceOf(shareHolder);
            if (pairBalance > 0 && !excludeLpProvider[shareHolder]) {
                amount = tokenBalance * pairBalance / totalPair;
                if (amount > 0) {
                    rewardToken.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressLPBlock = block.number;
    }

    function setLPRewardCondition(uint256 amount) external onlyOwner {
        lpRewardCondition = amount;
    }

    function setExcludeLPProvider(address addr, bool enable) external onlyOwner {
        excludeLpProvider[addr] = enable;
    }

    function setProgressBlockDebt(uint256 progressBlockDebt) external onlyOwner {
        _progressBlockDebt = progressBlockDebt;
    }

    function setDayPrice(uint256 day, uint256 price) external onlyOwner {
        dayPrice[day] = price;
    }

    function setFeePriceRate(uint256 rate) external onlyOwner {
        _addSellFeePriceRate = rate;
    }

    function setPriceRateStep(uint256 step) external onlyOwner {
        _addSellFeePriceRateStep = step;
    }

    function setAddFeeStep(uint256 step) external onlyOwner {
        _addSellFeeStep = step;
    }

    function setMaxFee(uint256 max) external onlyOwner {
        _addSellFeeMax = max;
    }

    function today() public view returns (uint256){
        return block.timestamp / 86400;
    }

    function tokenPrice() public view returns (uint256){
        ISwapPair swapPair = ISwapPair(_mainPair);
        (uint256 reverse0,uint256 reverse1,) = swapPair.getReserves();
        address token0 = swapPair.token0();
        uint256 usdtReverse;
        uint256 tokenReverse;
        if (_usdt == token0) {
            usdtReverse = reverse0;
            tokenReverse = reverse1;
        } else {
            usdtReverse = reverse1;
            tokenReverse = reverse0;
        }
        if (0 == tokenReverse) {
            return 0;
        }
        return 10 ** _decimals * usdtReverse / tokenReverse;
    }

    receive() external payable {}

    function getBuyRecordLength() external view returns (uint256){
        return _buyRecords.length;
    }

    function getBuyRecord(uint256 i) external view returns (address account, uint256 amount){
        BuyRecord storage buyRecord = _buyRecords[i];
        account = buyRecord.account;
        amount = buyRecord.amount;
    }
}

contract COS is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955),
        "COS",
        "COS",
        18,
        310000,
    //Received
        address(0x04815ed7e41FD72AfA7e32796eb6169B7642dE54),
    //Fund
        address(0x7Acd503b064c0C2e9c502bF6F7421F2aC159CE06),
    //Dev
        address(0xd3aC8942aBb150f55C6727BA6b49744E4BA3C516),
    //BToken
        address(0x6E5C234A7e3Fc6c5183E99317C006F41ED371e33)
    ){

    }
}