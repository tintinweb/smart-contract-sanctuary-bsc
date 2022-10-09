/**
 *Submitted for verification at BscScan.com on 2022-10-09
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

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

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
    address public _owner;
    constructor (address token) {
        _owner = msg.sender;
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }

    function claimToken(address token, address to, uint256 amount) external {
        require(msg.sender == _owner, "not owner");
        IERC20(token).transfer(to, amount);
    }
}

interface INFT {
    function _totalAmount(uint256) external view returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address owner);
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address public _removeLPFeeReceiver;
    address public nftAddress = address(0x9D8821E4bC4C1Cb9f9e69E28da53f86091c23b1e);

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

    uint256 public constant MAX = ~uint256(0);

    uint256 public _buyFundFee = 200;
    uint256 public _buyLPDividendFee = 200;
    uint256 public _buyNFTFee = 200;

    uint256 public _sellFundFee = 200;
    uint256 public _sellLPDividendFee = 200;
    uint256 public _sellNFTFee = 200;

    uint256 public _removeLPFee = 5000;

    uint256 public _nftSRate = 2000;
    uint256 public _nftSSRate = 3000;

    uint256 public startTradeBlock;
    uint256 public startAddLPBlock;

    address public _mainPair;

    TokenDistributor public _tokenDistributor;
    TokenDistributor public _nftSDistributor;
    TokenDistributor public _nftSSDistributor;
    TokenDistributor public _nftSSSDistributor;

    uint256 public _limitAmount;

    uint256 public _numToSell;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address ReceiveAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _allowances[address(this)][RouterAddress] = MAX;

        _usdt = USDTAddress;
        _swapRouter = swapRouter;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDTAddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        _removeLPFeeReceiver = ReceiveAddress;
        fundAddress = FundAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;
        _feeWhiteList[address(0x5a5260FE654f4064c0eF72Bc07d6cDBDd48ae601)] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;

        _tokenDistributor = new TokenDistributor(USDTAddress);
        _nftSDistributor = new TokenDistributor(USDTAddress);
        _nftSSDistributor = new TokenDistributor(USDTAddress);
        _nftSSSDistributor = new TokenDistributor(USDTAddress);

        holderRewardCondition = 100 * 10 ** IERC20(USDTAddress).decimals();

        _numToSell = 1 * 10 ** Decimals;
        _limitAmount = 1 * 10 ** Decimals;

        nftRewardCondition = holderRewardCondition;
        excludeNFTHolder[address(0)] = true;
        excludeNFTHolder[address(0x000000000000000000000000000000000000dEaD)] = true;

        //编号开头
        _baseId[1] = 100001;
        _baseId[2] = 200001;
        _baseId[3] = 300001;
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

    mapping(uint256 => uint256) public dayPrice;

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(!_blackList[from] || _feeWhiteList[from], "blackList");

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;
        bool isRemoveLP;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startAddLPBlock) {
                if (_feeWhiteList[from] && to == _mainPair && IERC20(to).totalSupply() == 0) {
                    startAddLPBlock = block.number;
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && _swapPairList[to], "!startTrade");
                }

                takeFee = true;

                if (_swapPairList[from]) {
                    isRemoveLP = _isRemoveLiquidity();
                }

                if (block.number < startTradeBlock + 4) {
                    _funTransfer(from, to, amount);
                    _checkLimit(to);
                    return;
                }
            }
        }

        _tokenTransfer(from, to, amount, takeFee, isRemoveLP);
        _checkLimit(to);

        if (from != address(this)) {
            if (_swapPairList[to]) {
                addHolder(from);
            }
            if (0 == startTradeBlock) {
                return;
            }
            processReward(500000);
            uint256 blockNum = block.number;
            if (progressRewardBlock != blockNum) {
                processGoldNFT(500000);
                if (processGoldNFTBlock != blockNum) {
                    processSilverNFT(500000);
                    if (processSilverNFTBlock != blockNum) {
                        processCopperNFT(500000);
                    }
                }
            }
        }
    }

    function _checkLimit(address to) private view {
        if (0 == startTradeBlock) {
            return;
        }
        if (_limitAmount > 0 && !_swapPairList[to] && !_feeWhiteList[to]) {
            require(_limitAmount >= balanceOf(to), "exceed LimitAmount");
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
        _takeTransfer(sender, fundAddress, feeAmount);
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
            uint256 swapAmount;
            bool isSell;
            if (isRemoveLP) {
                feeAmount = tAmount * _removeLPFee / 10000;
                _takeTransfer(sender, _removeLPFeeReceiver, feeAmount);
            } else if (_swapPairList[sender]) {//Buy
                swapAmount = tAmount * (_buyFundFee + _buyLPDividendFee + _buyNFTFee) / 10000;
            } else {
                swapAmount = tAmount * (_sellFundFee + _sellLPDividendFee + _sellNFTFee) / 10000;
                isSell = true;
            }

            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(sender, address(this), swapAmount);
            }
            if (!inSwap && isSell) {
                uint256 contractTokenBalance = balanceOf(address(this));
                uint256 numTokensSellToFund = _numToSell;
                if (contractTokenBalance >= numTokensSellToFund) {
                    swapTokenForFund(numTokensSellToFund);
                }
            }
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
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

        uint256 fundFee = _buyFundFee + _sellFundFee;
        uint256 nftFee = _buyNFTFee + _sellNFTFee;
        uint256 totalFee = fundFee + _buyLPDividendFee + _sellLPDividendFee + nftFee;

        uint256 fundUsdt = usdtBalance * fundFee / totalFee;
        if (fundUsdt > 0) {
            USDT.transfer(fundAddress, fundUsdt);
        }

        uint256 nftUsdt = usdtBalance * nftFee / totalFee;
        uint256 sUsdt = nftUsdt * _nftSRate / 10000;
        if (sUsdt > 0) {
            USDT.transfer(address(_nftSDistributor), sUsdt);
        }

        uint256 ssUsdt = nftUsdt * _nftSSRate / 10000;
        if (ssUsdt > 0) {
            USDT.transfer(address(_nftSSDistributor), ssUsdt);
        }

        nftUsdt = nftUsdt - sUsdt - ssUsdt;
        if (nftUsdt > 0) {
            USDT.transfer(address(_nftSSSDistributor), nftUsdt);
        }
    }

    function _takeTransfer(address sender, address to, uint256 tAmount) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setRemoveLPFeeReceiver(address addr) external onlyOwner {
        _removeLPFeeReceiver = addr;
        _feeWhiteList[addr] = true;
    }

    function setNFTAddress(address addr) external onlyOwner {
        nftAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    function closeTrade() external onlyOwner {
        startTradeBlock = 0;
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

    function claimContractToken(address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            _tokenDistributor.claimToken(token, fundAddress, amount);
        }
    }

    receive() external payable {}

    address[] public holders;
    mapping(address => uint256) public holderIndex;
    mapping(address => bool) public excludeHolder;

    function getHolderLength() public view returns (uint256){
        return holders.length;
    }

    function addHolder(address adr) private {
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                uint256 size;
                assembly {size := extcodesize(adr)}
                if (size > 0) {
                    return;
                }
                holderIndex[adr] = holders.length;
                holders.push(adr);
            }
        }
    }

    uint256 public currentIndex;
    uint256 public holderRewardCondition;
    uint256 public progressRewardBlock;
    uint256 public _progressBlockDebt = 200;

    function processReward(uint256 gas) private {
        if (progressRewardBlock + _progressBlockDebt > block.number) {
            return;
        }

        address sender = address(this);
        IERC20 USDT = IERC20(_usdt);
        uint256 balance = USDT.balanceOf(sender);
        if (balance < holderRewardCondition) {
            return;
        }

        IERC20 holdToken = IERC20(_mainPair);
        uint holdTokenTotal = holdToken.totalSupply();

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
            if (tokenBalance > 0 && !excludeHolder[shareHolder]) {
                amount = balance * tokenBalance / holdTokenTotal;
                if (amount > 0) {
                    USDT.transfer(shareHolder, amount);
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

    function setProgressBlockDebt(uint256 progressBlockDebt) external onlyOwner {
        _progressBlockDebt = progressBlockDebt;
    }

    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    function batchSetFeeWhiteList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    function batchSetBlackList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _blackList[addr[i]] = enable;
        }
    }

    function setBuyFee(uint256 fundFee, uint256 lpDividendFee, uint256 nftFee) external onlyOwner {
        _buyFundFee = fundFee;
        _buyLPDividendFee = lpDividendFee;
        _buyNFTFee = nftFee;
    }

    function setSellFee(uint256 fundFee, uint256 lpDividendFee, uint256 nftFee) external onlyOwner {
        _sellFundFee = fundFee;
        _sellLPDividendFee = lpDividendFee;
        _sellNFTFee = nftFee;
    }

    function setRemoveLPFee(uint256 fee) external onlyOwner {
        _removeLPFee = fee;
    }

    function setNFTRate(uint256 sRate, uint256 ssRate) external onlyOwner {
        _nftSRate = sRate;
        _nftSSRate = ssRate;
    }

    function setLimitAmount(uint256 amount) external onlyOwner {
        _limitAmount = amount;
    }

    function setNumToSell(uint256 amount) external onlyOwner {
        _numToSell = amount;
    }

    uint256 public nftRewardCondition;
    uint256 public processNFTBlockDebt = 200;
    mapping(address => bool) public excludeNFTHolder;
    //property => baseId,种类对应的编号开头，例如1=>100001
    mapping(uint256 => uint256) public _baseId;

    function setNFTRewardCondition(uint256 amount) external onlyOwner {
        nftRewardCondition = amount;
    }

    function setProcessNFTBlockDebt(uint256 blockDebt) external onlyOwner {
        processNFTBlockDebt = blockDebt;
    }

    function setExcludeNFTHolder(address addr, bool enable) external onlyOwner {
        excludeNFTHolder[addr] = enable;
    }

    uint256 public currentGoldNFTIndex;
    uint256 public processGoldNFTBlock;

    function processGoldNFT(uint256 gas) private {
        if (processGoldNFTBlock + processNFTBlockDebt > block.number) {
            return;
        }
        INFT nft = INFT(nftAddress);
        uint256 category = 3;
        uint totalNFT = nft._totalAmount(category);
        if (0 == totalNFT) {
            return;
        }
        IERC20 USDT = IERC20(_usdt);
        address sender = address(_nftSSSDistributor);
        uint256 tokenBalance = USDT.balanceOf(sender);
        if (tokenBalance < nftRewardCondition) {
            return;
        }

        uint256 amount = tokenBalance / totalNFT;
        if (0 == amount) {
            return;
        }

        address shareHolder;
        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 nftBaseId = _baseId[category];

        while (gasUsed < gas && iterations < totalNFT) {
            if (currentGoldNFTIndex >= totalNFT) {
                currentGoldNFTIndex = 0;
            }
            shareHolder = nft.ownerOf(nftBaseId + currentGoldNFTIndex);
            if (!excludeNFTHolder[shareHolder]) {
                USDT.transferFrom(sender, shareHolder, amount);
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentGoldNFTIndex++;
            iterations++;
        }

        processGoldNFTBlock = block.number;
    }

    uint256 public currentSilverNFTIndex;
    uint256 public processSilverNFTBlock;

    function processSilverNFT(uint256 gas) private {
        if (processSilverNFTBlock + processNFTBlockDebt > block.number) {
            return;
        }
        INFT nft = INFT(nftAddress);
        uint256 category = 2;
        uint totalNFT = nft._totalAmount(category);
        if (0 == totalNFT) {
            return;
        }
        IERC20 USDT = IERC20(_usdt);
        address sender = address(_nftSSDistributor);
        uint256 tokenBalance = USDT.balanceOf(sender);
        if (tokenBalance < nftRewardCondition) {
            return;
        }

        uint256 amount = tokenBalance / totalNFT;
        if (0 == amount) {
            return;
        }

        address shareHolder;
        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 nftBaseId = _baseId[category];

        while (gasUsed < gas && iterations < totalNFT) {
            if (currentSilverNFTIndex >= totalNFT) {
                currentSilverNFTIndex = 0;
            }
            shareHolder = nft.ownerOf(nftBaseId + currentSilverNFTIndex);
            if (!excludeNFTHolder[shareHolder]) {
                USDT.transferFrom(sender, shareHolder, amount);
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentSilverNFTIndex++;
            iterations++;
        }

        processSilverNFTBlock = block.number;
    }

    uint256 public currentCopperNFTIndex;
    uint256 public processCopperNFTBlock;

    function processCopperNFT(uint256 gas) private {
        if (processCopperNFTBlock + processNFTBlockDebt > block.number) {
            return;
        }

        INFT nft = INFT(nftAddress);
        uint256 category = 1;
        uint totalNFT = nft._totalAmount(category);
        if (0 == totalNFT) {
            return;
        }
        IERC20 USDT = IERC20(_usdt);
        address sender = address(_nftSDistributor);
        uint256 tokenBalance = USDT.balanceOf(sender);
        if (tokenBalance < nftRewardCondition) {
            return;
        }

        uint256 amount = tokenBalance / totalNFT;
        if (0 == amount) {
            return;
        }

        address shareHolder;
        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 nftBaseId = _baseId[category];

        while (gasUsed < gas && iterations < totalNFT) {
            if (currentCopperNFTIndex >= totalNFT) {
                currentCopperNFTIndex = 0;
            }
            shareHolder = nft.ownerOf(nftBaseId + currentCopperNFTIndex);
            if (!excludeNFTHolder[shareHolder]) {
                USDT.transferFrom(sender, shareHolder, amount);
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentCopperNFTIndex++;
            iterations++;
        }

        processCopperNFTBlock = block.number;
    }

    //设置NFT 种类对应的 起始编号，也就是开头，property=1 SSS，property=2 SS，property=3 S
    function setBaseId(uint256 property, uint256 baseId) external onlyOwner {
        _baseId[property] = baseId;
    }
}

contract JC is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
    //名称
        "JC",
    //符号
        "JC",
    //精度
        6,
    //总量
        10000,
    //营销钱包
        address(0xE98b28455c5C31983A5cC382A77E1756441D1469),
    //代币接收
        address(0x234F340C3e34A6D63157af0D5232482B679c3f22)
    ){

    }
}