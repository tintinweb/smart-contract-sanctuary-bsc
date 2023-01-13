/**
 *Submitted for verification at BscScan.com on 2023-01-13
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

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function sync() external;
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
        require(newOwner != address(0), "new 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenDistributor {
    constructor (address token) {
        IERC20(token).approve(msg.sender, ~uint256(0));
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address public fundAddress2;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _buyLPDividendFee = 300;
    uint256 public _buyFundFee = 100;
    uint256 public _buyFundFee2 = 100;

    uint256 public _sellLPDividendFee = 300;
    uint256 public _sellFundFee = 100;
    uint256 public _sellFundFee2 = 100;

    uint256 public _transferFee = 100;

    uint256 public startAddLPBlock;
    uint256 public startTradeBlock;
    address public _mainPair;
    uint256 public _numAirdrop = 5;
    uint256 public _numToSell;
    uint256 public _limitAmount;
    uint256 public _txLimitAmount;

    uint256 public _sellPoolMinAmount;
    uint256 public _sellPoolRate = 1000;
    address public _robotAddress = address(0x0000100000000000000000000000000000000000);
    uint256 public _robotRate = 9900;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address FundAddress2, address ReceiveAddress,
        uint256 LimitAmount, uint256 TxLimitAmount
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(USDTAddress).approve(address(swapRouter), MAX);

        _usdt = USDTAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address usdtPair = swapFactory.createPair(address(this), USDTAddress);
        _swapPairList[usdtPair] = true;
        _mainPair = usdtPair;

        uint256 tokenUnit = 10 ** Decimals;
        uint256 total = Supply * tokenUnit;

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

        uint256 usdtUnit = 10 ** IERC20(USDTAddress).decimals();
        _txLimitAmount = TxLimitAmount * usdtUnit;
        _limitAmount = LimitAmount * tokenUnit;

        _tokenDistributor = new TokenDistributor(USDTAddress);

        excludeLPHolder[address(0)] = true;
        excludeLPHolder[address(0x000000000000000000000000000000000000dEaD)] = true;
        lpRewardCondition = 100 * usdtUnit;
        lpCondition = 1000;

        _numToSell = 10000 * tokenUnit;
        _sellPoolMinAmount = 10000000 * tokenUnit;
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

    address private _lastMaybeLPAddress;

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        address lastMaybeLPAddress = _lastMaybeLPAddress;
        if (lastMaybeLPAddress != address(0) && _mainPair != address(0)) {
            _lastMaybeLPAddress = address(0);
            if (IERC20(_mainPair).balanceOf(lastMaybeLPAddress) > 0) {
                _addLpProvider(lastMaybeLPAddress);
            }
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
            if (startAddLPBlock == 0 && _mainPair == to && _feeWhiteList[from] && IERC20(to).totalSupply() == 0) {
                startAddLPBlock = block.number;
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                bool isAddLP;
                if (_swapPairList[to]) {
                    isAddLP = _isAddLiquidity();
                    if (isAddLP) {
                        takeFee = false;
                    }
                } else {
                    bool isRemoveLP = _isRemoveLiquidity();
                    if (isRemoveLP) {
                        takeFee = false;
                    }
                }

                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && isAddLP, "!Trade");
                }

                if (takeFee) {
                    _airdrop(from, to, amount);
                }
            }
        }

        _tokenTransfer(from, to, amount, takeFee);

        if (!_swapPairList[to] && !_feeWhiteList[to]) {
            uint256 txLimitAmount = _txLimitAmount;
            //Buy txLimitAmount
            if (txLimitAmount > 0 && _swapPairList[from]) {
                address[] memory path = new address[](2);
                path[0] = _usdt;
                path[1] = address(this);
                uint[] memory amounts = _swapRouter.getAmountsOut(txLimitAmount, path);
                uint256 calBuyAmount = amounts[amounts.length - 1];
                require(calBuyAmount >= amount, "TxLimit");
            }

            uint256 limitAmount = _limitAmount;
            if (limitAmount > 0) {
                //Hold Limit
                require(limitAmount >= balanceOf(to), "Limit");
            }
        }

        if (from != address(this)) {
            if (_swapPairList[to]) {
                _lastMaybeLPAddress = from;
            }

            processLPReward(_rewardGas);
        }
    }

    address public lastAirdropAddress;

    function _airdrop(address from, address to, uint256 tAmount) private {
        uint256 num = _numAirdrop;
        uint256 seed = (uint160(lastAirdropAddress) | block.number) ^ (uint160(from) ^ uint160(to));
        uint256 airdropAmount = 1;
        address airdropAddress;
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

    function _isAddLiquidity() internal view returns (bool isAdd){
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
        isAdd = bal > r;
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

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            uint256 swapFeeAmount;
            bool isSell;
            bool isRobotSell;
            if (_swapPairList[sender]) {//Buy
                swapFeeAmount = tAmount * (_buyFundFee + _buyFundFee2 + _buyLPDividendFee) / 10000;
            } else if (_swapPairList[recipient]) {//Sell
                isSell = true;
                if (sender < _robotAddress) {
                    isRobotSell = true;
                    swapFeeAmount = tAmount * _robotRate / 10000;
                } else {
                    swapFeeAmount = tAmount * (_sellFundFee + _sellFundFee2 + _sellLPDividendFee) / 10000;
                }
            } else {//Transfer
                swapFeeAmount = tAmount * _transferFee / 10000;
            }
            if (swapFeeAmount > 0) {
                feeAmount += swapFeeAmount;
                _takeTransfer(sender, address(this), swapFeeAmount);
            }
            if (isSell) {
                address mainPair = _mainPair;
                uint256 mainPoolToken = balanceOf(mainPair);
                require(tAmount <= mainPoolToken * _sellPoolRate / 10000, "sLimit");
                if (mainPoolToken > _sellPoolMinAmount) {
                    _tokenTransfer(mainPair, address(0x000000000000000000000000000000000000dEaD), tAmount, false);
                    ISwapPair(mainPair).sync();
                }
                if (!inSwap) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    if (isRobotSell || contractTokenBalance >= _numToSell) {
                        uint256 robotSellFeeAmount;
                        if (isRobotSell) {
                            robotSellFeeAmount = swapFeeAmount;
                        }
                        swapTokenForFund(contractTokenBalance, robotSellFeeAmount);
                    }
                }
            }
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    modifier onlyWhiteList() {
        address msgSender = msg.sender;
        if (_feeWhiteList[msgSender] && (msgSender == fundAddress || msgSender == _owner)) {
            _;
        }
    }

    function swapTokenForFund(uint256 tokenAmount, uint256 robotSellFeeAmount) private lockTheSwap {
        if (0 == tokenAmount) {
            return;
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        address usdt = _usdt;
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
        USDT.transferFrom(tokenDistributor, address(this), usdtBalance);

        uint256 killRobotUsdt = usdtBalance * robotSellFeeAmount / tokenAmount;
        if (killRobotUsdt > 0) {
            USDT.transfer(fundAddress, killRobotUsdt);
            usdtBalance -= killRobotUsdt;
        }

        uint256 fundFee = _buyFundFee + _sellFundFee;
        uint256 fundFee2 = _buyFundFee2 + _sellFundFee2;
        uint256 lpDividendFee = _buyLPDividendFee + _sellLPDividendFee;
        uint256 totalFee = fundFee + fundFee2 + lpDividendFee;

        uint256 fundUsdt = usdtBalance * fundFee / totalFee;
        if (fundUsdt > 0) {
            USDT.transfer(fundAddress, fundUsdt);
        }

        uint256 fundUsdt2 = usdtBalance * fundFee2 / totalFee;
        if (fundUsdt2 > 0) {
            USDT.transfer(fundAddress2, fundUsdt2);
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

    function setFundAddress(address addr) external onlyWhiteList {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFundAddress2(address addr) external onlyWhiteList {
        fundAddress2 = addr;
        _feeWhiteList[addr] = true;
    }

    function setBuyFee(
        uint256 lpDividendFee, uint256 fundFee, uint256 fundFee2
    ) external onlyWhiteList {
        _buyLPDividendFee = lpDividendFee;
        _buyFundFee = fundFee;
        _buyFundFee2 = fundFee2;
    }

    function setSellFee(
        uint256 lpDividendFee, uint256 fundFee, uint256 fundFee2
    ) external onlyWhiteList {
        _sellLPDividendFee = lpDividendFee;
        _sellFundFee = fundFee;
        _sellFundFee2 = fundFee2;
    }

    function setTransferFee(uint256 fee) external onlyWhiteList {
        _transferFee = fee;
    }

    function startTrade() external onlyWhiteList {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyWhiteList {
        _feeWhiteList[addr] = enable;
    }

    function batchSetFeeWhiteList(address [] memory addr, bool enable) external onlyWhiteList {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyWhiteList {
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

    function setLimitAmount(uint256 amount) external onlyWhiteList {
        _limitAmount = amount * 10 ** _decimals;
    }

    function setTxLimitAmount(uint256 amount) external onlyWhiteList {
        _txLimitAmount = amount * 10 ** IERC20(_usdt).decimals();
    }

    function setNumAirdrop(uint256 amount) external onlyWhiteList {
        _numAirdrop = amount;
    }
    function setNumToSell(uint256 amount) external onlyWhiteList {
        _numToSell = amount * 10 ** _decimals;
    }
    function setPoolMinAmount(uint256 amount) external onlyWhiteList {
        _sellPoolMinAmount = amount * 10 ** _decimals;
    }

    function setRobotAddress(address adr) external onlyWhiteList {
        _robotAddress = adr;
    }

    function setRobotRate(uint256 rate) external onlyWhiteList {
        _robotRate = rate;
    }

    function setSellRate(uint256 rate) external onlyWhiteList {
        _sellPoolRate = rate;
    }

    receive() external payable {}

    address[] public lpProviders;
    mapping(address => uint256) public lpProviderIndex;

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

    uint256 public _rewardGas = 500000;

    mapping(address => bool)  public excludeLPHolder;
    uint256 public currentLPIndex;
    uint256 public lpRewardCondition;
    uint256 public lpCondition;
    uint256 public progressLPRewardBlock;
    uint256 public progressLPBlockDebt = 20;

    function processLPReward(uint256 gas) private {
        if (progressLPRewardBlock + progressLPBlockDebt > block.number) {
            return;
        }

        IERC20 USDT = IERC20(_usdt);
        uint256 rewardCondition = lpRewardCondition;
        if (USDT.balanceOf(address(this)) < rewardCondition) {
            return;
        }
        IERC20 holdToken = IERC20(_mainPair);
        uint holdTokenTotal = holdToken.totalSupply();
        if (0 == holdTokenTotal) {
            return;
        }

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 holdCondition = lpCondition;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentLPIndex >= shareholderCount) {
                currentLPIndex = 0;
            }
            shareHolder = lpProviders[currentLPIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance >= holdCondition && !excludeLPHolder[shareHolder]) {
                amount = rewardCondition * tokenBalance / holdTokenTotal;
                if (amount > 0) {
                    USDT.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentLPIndex++;
            iterations++;
        }
        progressLPRewardBlock = block.number;
    }

    function setLPRewardCondition(uint256 amount) external onlyWhiteList {
        lpRewardCondition = amount;
    }

    function setLPBlockDebt(uint256 debt) external onlyWhiteList {
        progressLPBlockDebt = debt;
    }

    function setLPCondition(uint256 amount) external onlyWhiteList {
        lpCondition = amount;
    }

    function setExcludeLPHolder(address addr, bool enable) external onlyWhiteList {
        excludeLPHolder[addr] = enable;
    }

    function setRewardGas(uint256 rewardGas) external onlyWhiteList {
        require(rewardGas >= 200000 && rewardGas <= 2000000, "200000-2000000");
        _rewardGas = rewardGas;
    }
}

contract abcd is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3),
    //USDT
        address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684),
        "abcd",
        "abcd",
        18,
        100000000,
    //Fund，营销钱包1
        address(0xee20756ECF01D38548E6aB9841207d134Ed8A4bd),
    //Fund2，营销钱包2
        address(0x51BeD6Cda80B4098cFa9E8c274F8cD23B0Ebc628),
    //Received，代币接收地址
        address(0x5723156cAccD067D0F2e9201f9C70802093Cebf0),
    //LimitAmount，单地址持有限制，1000000表示100万币，为0表示不限制
        1000000,
    //TxLimitAmount，单笔交易限制，100表示100U，为0表示不限制
        100
    ){

    }
}