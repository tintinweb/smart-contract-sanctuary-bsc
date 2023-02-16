/**
 *Submitted for verification at BscScan.com on 2023-02-16
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

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

interface ISwapPair {
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function token0() external view returns (address);

    function sync() external;
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
        require(newOwner != address(0), "new 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenDistributor {
    address public _owner;

    constructor(address token) {
        _owner = msg.sender;
        IERC20(token).approve(msg.sender, uint256(~uint256(0)));
    }

    function claimToken(
        address token,
        address to,
        uint256 amount
    ) external {
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
    address public nftAddress =
        address(0x1631093BFFe72a962d6199405d07748e68666666);

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
    // buy 3% 1.5NFT 1.5addLP
    // sell 3% 1.5NFT 1.5addLP
    uint256 public _buyNFTFee = 150;
    uint256 public _sellNFTFee = 150;
    uint256 public _buyLpFee = 150;
    uint256 public _sellLpFee = 150;

    // S:SR:SSR=2:3:5
    uint256 public _nftSRate = 2000;
    uint256 public _nftSSRate = 3000;

    uint256 public startTradeBlock;
    uint256 public startAddLPBlock;

    address public _mainPair;

    TokenDistributor public _tokenDistributor;
    TokenDistributor public _nftSDistributor;
    TokenDistributor public _nftSSDistributor;
    TokenDistributor public _nftSSSDistributor;

    uint256 public _numToSell;

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
        _allowances[address(this)][RouterAddress] = MAX;
        IERC20(USDTAddress).approve(RouterAddress, MAX);

        _usdt = USDTAddress;
        _swapRouter = swapRouter;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDTAddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10**Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;

        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[
            address(0x000000000000000000000000000000000000dEaD)
        ] = true;
        _feeWhiteList[
            address(0x48eb9a8e3279345ef7B1e85DdEfb22f888737727)
        ] = true;

        _tokenDistributor = new TokenDistributor(USDTAddress);

        _nftSDistributor = new TokenDistributor(USDTAddress);
        _nftSSDistributor = new TokenDistributor(USDTAddress);
        _nftSSSDistributor = new TokenDistributor(USDTAddress);

        _numToSell = 1000 * 10**Decimals;
        nftRewardCondition = 100 * 10**IERC20(USDTAddress).decimals();

        excludeNFTHolder[address(0)] = true;
        excludeNFTHolder[
            address(0x000000000000000000000000000000000000dEaD)
        ] = true;
        excludeHolder[address(0)] = true;
        excludeHolder[address(this)] = true;
        excludeHolder[
            address(0x000000000000000000000000000000000000dEaD)
        ] = true;

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

    uint256 public rewardGas = 500000;

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(!_blackList[from] || _feeWhiteList[from], "blackList");

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = (balance * 99999) / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;
        bool isRemoveLP;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startAddLPBlock) {
                if (
                    _feeWhiteList[from] &&
                    to == _mainPair &&
                    IERC20(to).totalSupply() == 0
                ) {
                    startAddLPBlock = block.number;
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (0 == startTradeBlock) {
                    require(
                        0 < startAddLPBlock && _swapPairList[to],
                        "!startTrade"
                    );
                }

                takeFee = true;
                bool isAdd;
                if (_swapPairList[to]) {
                    isAdd = _isAddLiquidity();
                    if (isAdd) {
                        takeFee = false;
                    }
                } else {
                    isRemoveLP = _isRemoveLiquidity();
                }
            }
        }

        _tokenTransfer(from, to, amount, takeFee, isRemoveLP);

        if (from != address(this)) {
            if (0 == startTradeBlock) {
                return;
            }
            uint256 blockNum = block.number;
            processGoldNFT(rewardGas);
            if (processGoldNFTBlock != blockNum) {
                processSilverNFT(rewardGas);
                if (processSilverNFTBlock != blockNum) {
                    processCopperNFT(rewardGas);
                }
            }
        }

        if (from != address(this)) {
            if (_swapPairList[to]) {
                addHolder(from);
            }
            processLP(rewardGas);
        }
    }

    function _isAddLiquidity() internal view returns (bool isAdd) {
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint256 r0, uint256 r1, ) = mainPair.getReserves();

        address tokenOther = _usdt;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }

        uint256 bal = IERC20(tokenOther).balanceOf(address(mainPair));
        isAdd = bal > r;
    }

    function _isRemoveLiquidity() internal view returns (bool isRemove) {
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint256 r0, uint256 r1, ) = mainPair.getReserves();

        address tokenOther = _usdt;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }

        uint256 bal = IERC20(tokenOther).balanceOf(address(mainPair));
        isRemove = r >= bal;
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
                swapAmount = (tAmount * (_sellNFTFee + _sellLpFee)) / 10000;
            } else if (_swapPairList[sender]) {
                //Buy
                swapAmount = (tAmount * (_buyNFTFee + _buyLpFee)) / 10000;
            } else {
                swapAmount = (tAmount * (_sellNFTFee + _sellLpFee)) / 10000;
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
        uint256 swapFee = (_buyNFTFee + _buyLpFee + _sellNFTFee + _sellLpFee);
        uint256 lpFee = _buyLpFee + _sellLpFee;
        uint256 lpAmount = (tokenAmount * lpFee) / (2 * swapFee);

        address[] memory path = new address[](2);
        path[0] = address(this);
        address usdt = _usdt;
        path[1] = usdt;
        address tokenDistributor = address(_tokenDistributor);
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            tokenDistributor,
            block.timestamp
        );

        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(tokenDistributor);
        USDT.transferFrom(tokenDistributor, address(this), usdtBalance);

        swapFee = swapFee - (lpFee / 2);

        uint256 nftUsdt = (usdtBalance * (_buyNFTFee + _sellNFTFee)) / swapFee;

        if (lpAmount > 0) {
            uint256 lpUSDT = usdtBalance - nftUsdt;
            if (lpUSDT > 0) {
                _swapRouter.addLiquidity(
                    _usdt,
                    address(this),
                    lpUSDT,
                    lpAmount,
                    0,
                    0,
                    fundAddress,
                    block.timestamp
                );
            }
        }

        uint256 sUsdt = (nftUsdt * _nftSRate) / 10000;
        if (sUsdt > 0) {
            USDT.transfer(address(_nftSDistributor), sUsdt);
        }

        uint256 ssUsdt = (nftUsdt * _nftSSRate) / 10000;
        if (ssUsdt > 0) {
            USDT.transfer(address(_nftSSDistributor), ssUsdt);
        }

        nftUsdt = nftUsdt - sUsdt - ssUsdt;
        if (nftUsdt > 0) {
            USDT.transfer(address(_nftSSSDistributor), nftUsdt);
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

    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    function batchSetFeeWhiteList(address[] memory addr, bool enable)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    function batchSetBlackList(address[] memory addr, bool enable)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < addr.length; i++) {
            _blackList[addr[i]] = enable;
        }
    }

    function setBuyFee(uint256 nftFee, uint256 lpFee) external onlyOwner {
        _buyNFTFee = nftFee;
        _buyLpFee = lpFee;
    }

    function setSellFee(uint256 nftFee, uint256 lpFee) external onlyOwner {
        _sellNFTFee = nftFee;
        _sellLpFee = lpFee;
    }

    function setNFTRate(uint256 sRate, uint256 ssRate) external onlyOwner {
        _nftSRate = sRate;
        _nftSSRate = ssRate;
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
        uint256 totalNFT = nft._totalAmount(category);
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
        uint256 totalNFT = nft._totalAmount(category);
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
        uint256 totalNFT = nft._totalAmount(category);
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

    // lp
    address[] private holders;
    mapping(address => uint256) holderIndex;
    mapping(address => bool) excludeHolder;
    uint256 private lpIndex;
    uint256 private processLPBlock;
    uint256 public waitLPBlock = 28800;
    uint256 public lpRadio = 130;

    function processLP(uint256 gas) private {
        if (processLPBlock + waitLPBlock > block.number) {
            return;
        }
        // finish 24h TODO

        IERC20 LP = IERC20(_mainPair);
        uint256 balance = LP.balanceOf(address(this));

        if (balance <= 0) {
            return;
        }

        IERC20 holdToken = IERC20(_mainPair);

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (lpIndex >= shareholderCount) {
                lpIndex = 0;
                processLPBlock = block.number;
                return;
            }
            shareHolder = holders[lpIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance > 0 && !excludeHolder[shareHolder]) {
                amount = (tokenBalance * lpRadio) / 10000;
                if (amount > 0 && amount < balance) {
                    LP.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            lpIndex++;
            iterations++;
        }
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

    //设置NFT 种类对应的 起始编号，也就是开头，property=1 R，property=2 SR，property=3 SSR
    function setBaseId(uint256 property, uint256 baseId) external onlyOwner {
        _baseId[property] = baseId;
    }

    function setRewardGas(uint256 gas) external onlyOwner {
        rewardGas = gas;
    }

    function setWaitLPBlock(uint256 _waitLPBlock) external onlyOwner {
        waitLPBlock = _waitLPBlock;
    }

    function setLpRadio(uint256 radio) external onlyOwner {
        lpRadio = radio;
    }
}

contract SARMAT is AbsToken {
    constructor()
        AbsToken(
            //SwapRouter
            address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
            //USDT
            address(0x55d398326f99059fF775485246999027B3197955),
            //名称
            "sarmat",
            //符号
            "sarmat",
            //精度
            18,
            //总量
            100000000,
            //营销钱包
            address(0x6DD846207E462c450223C3eaE2f834Ac48505554),
            //代币接收
            address(0x6DD846207E462c450223C3eaE2f834Ac48505554)
        )
    {}
}