/**
 *Submitted for verification at BscScan.com on 2022-10-08
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
        require(newOwner != address(0), "new is 0");
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

interface IBtcNFT {
    function totalSupply() external view returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address owner);
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address public _mintPool;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 public constant MAX = ~uint256(0);

    uint256 public _buyDestroyFee = 290;
    uint256 public _buyAirdropFee = 10;
    uint256 public _buyMintPoolFee = 200;

    uint256 public _sellNFTFee = 100;
    uint256 public _sellFundFee = 190;
    uint256 public _sellAirdropFee = 10;
    uint256 public _sellMintPoolFee = 600;
    uint256 public _sellLPDividendFee = 200;

    uint256 public startTradeBlock;

    address public _mainPair;

    TokenDistributor public _tokenDistributor;
    uint256 public _minTotal;

    uint256 public _wTimes = 100;

    address public _btcNFTAddress;

    mapping(uint256 => uint256) public dayPrice;
    uint256 public checkCanBuyDelay = 28800;
    uint256 public maxPriceRate = 110;

    uint256 public checkLimitDuration = 28800;
    uint256 public _limitAmount;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address ReceiveAddress, uint256 MinTotal, address BtcNFTAddress
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

        fundAddress = FundAddress;
        _btcNFTAddress = BtcNFTAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        _tokenDistributor = new TokenDistributor(USDTAddress);

        holderRewardCondition = 100 * 10 ** IERC20(USDTAddress).decimals();
        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;

        _minTotal = MinTotal * 10 ** Decimals;

        _addHolder(ReceiveAddress);

        //BTCNFT
        btcNftRewardCondition = 100 * 10 ** IERC20(USDTAddress).decimals();
        _btcNftHolderCondition = 10 * 10 ** Decimals;
        excludeBtcNFTHolder[address(0)] = true;
        excludeBtcNFTHolder[address(0x000000000000000000000000000000000000dEaD)] = true;

        _limitAmount = 100 * 10 ** IERC20(USDTAddress).decimals();
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
        return _tTotal - balanceOf(address(0)) - balanceOf(address(0x000000000000000000000000000000000000dEaD));
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
            uint256 maxSellAmount = balance * 9999 / 10000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        if (_swapPairList[from]) {
            if (tx.origin == to) {
                uint256 day = today();
                if (0 == dayPrice[day]) {
                    dayPrice[day] = tokenPrice();
                }
            }
            _checkCanBuy(to);
        } else {
            if (tx.origin == from) {
                uint256 day = today();
                if (0 == dayPrice[day]) {
                    dayPrice[day] = tokenPrice();
                }
            }
        }

        bool takeFee;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(0 < startTradeBlock && block.number >= startTradeBlock + _wTimes, "!Trade");
                takeFee = true;
            }
        }

        _tokenTransfer(from, to, amount, takeFee);
        _checkLimit(to);

        if (from != address(this)) {
            if (_swapPairList[to]) {
                addHolder(from);
            }
            processReward(500000);
            uint256 blockNum = block.number;
            if (processRewardBlock != blockNum) {
                processBtcNFT(500000);
            }
        }
    }

    function _checkLimit(address to) private view {
        if (0 == startTradeBlock || block.number >= startTradeBlock + checkLimitDuration) {
            return;
        }
        uint256 limitAmount = _limitAmount;
        if (limitAmount > 0 && !_swapPairList[to] && !_feeWhiteList[to]) {
            address[] memory path = new address[](2);
            path[0] = _usdt;
            path[1] = address(this);
            uint[] memory amounts = _swapRouter.getAmountsOut(limitAmount, path);
            uint256 calBuyAmount = amounts[amounts.length - 1];
            require(calBuyAmount >= balanceOf(to), "Limit");
        }
    }

    function _checkCanBuy(address to) private view {
        if (0 == startTradeBlock || block.number <= startTradeBlock + checkCanBuyDelay) {
            return;
        }
        if (_feeWhiteList[to]) {
            return;
        }
        uint256 todayPrice = dayPrice[today()];
        if (0 == todayPrice) {
            return;
        }
        uint256 price = tokenPrice();
        uint256 priceRate = price * 100 / todayPrice;
        require(priceRate <= maxPriceRate, "maxPriceRate");
    }

    address public lastAirdropAddress;

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            uint256 airdropFeeAmount;
            uint256 mintPoolFeeAmount;
            if (_swapPairList[sender]) {//Buy
                uint256 destroyFeeAmount = _buyDestroyFee * tAmount / 10000;
                if (destroyFeeAmount > 0) {
                    uint256 destroyAmount = destroyFeeAmount;
                    uint256 currentTotal = validTotal();
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

                airdropFeeAmount = _buyAirdropFee * tAmount / 10000;
                mintPoolFeeAmount = _buyMintPoolFee * tAmount / 10000;
            } else {//Sell
                airdropFeeAmount = _sellAirdropFee * tAmount / 10000;
                mintPoolFeeAmount = _sellMintPoolFee * tAmount / 10000;

                uint256 swapFee = _sellNFTFee + _sellFundFee + _sellLPDividendFee;
                uint256 swapAmount = tAmount * swapFee / 10000;
                if (swapAmount > 0) {
                    feeAmount += swapAmount;
                    _takeTransfer(sender, address(this), swapAmount);
                }
                if (!inSwap) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    uint256 numTokensSellToFund = swapAmount * 3;
                    if (numTokensSellToFund > contractTokenBalance) {
                        numTokensSellToFund = contractTokenBalance;
                    }
                    swapTokenForFund(numTokensSellToFund, swapFee);
                }
            }

            if (airdropFeeAmount > 0) {
                uint256 seed = (uint160(lastAirdropAddress) | block.number) ^ uint160(sender);
                feeAmount += airdropFeeAmount;
                uint256 airdropAmount = airdropFeeAmount / 5;
                address airdropAddress;
                for (uint256 i; i < 5;) {
                    airdropAddress = address(uint160(seed));
                    _takeTransfer(sender, airdropAddress, airdropAmount);
                unchecked{
                    ++i;
                    seed = seed >> 1;
                }
                }
                lastAirdropAddress = airdropAddress;
            }

            if (mintPoolFeeAmount > 0) {
                feeAmount += mintPoolFeeAmount;
                _takeTransfer(sender, _mintPool, mintPoolFeeAmount);
            }
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount, uint256 swapFee) private lockTheSwap {
        if (0 == tokenAmount) {
            return;
        }
        address usdt = _usdt;
        address tokenDistributor = address(_tokenDistributor);
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
        uint256 nftUsdt = usdtBalance * _sellNFTFee / swapFee;
        USDT.transferFrom(tokenDistributor, address(this), usdtBalance - nftUsdt);

        uint256 fundUsdt = usdtBalance * _sellFundFee / swapFee;
        USDT.transfer(fundAddress, fundUsdt);
    }

    function _takeTransfer(address sender, address to, uint256 tAmount) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
        _addHolder(to);
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
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

    function getLPHolderLength() external view returns (uint256){
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
    uint256 public processRewardBlock;
    uint256 public processRewardBlockDebt = 200;

    function processReward(uint256 gas) public {
        if (processRewardBlock + processRewardBlockDebt > block.number) {
            return;
        }

        IERC20 USDT = IERC20(_usdt);
        address sender = address(this);
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

        processRewardBlock = block.number;
    }

    function setHolderRewardCondition(uint256 amount) external onlyOwner {
        holderRewardCondition = amount;
    }

    function setProcessRewardBlockDebt(uint256 blockDebt) external onlyOwner {
        processRewardBlockDebt = blockDebt;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

    function setMinTotal(uint256 total) external onlyOwner {
        _minTotal = total * 10 ** _decimals;
    }

    function setMintPool(address mintPool) external onlyOwner {
        _mintPool = mintPool;
        _feeWhiteList[mintPool] = true;
    }

    function setWTimes(uint256 blockNum) external onlyOwner {
        _wTimes = blockNum;
    }

    function batchSetFeeWhiteList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    address[] private _holders;
    mapping(address => uint256) private _holderIndex;

    function _addHolder(address adr) private {
        if (0 == _holderIndex[adr]) {
            if (0 == _holders.length || _holders[0] != adr) {
                _holderIndex[adr] = _holders.length;
                _holders.push(adr);
            }
        }
    }

    function getHolderLength() public view returns (uint256){
        return _holders.length;
    }

    function getTotalInfo() external view returns (
        uint256 tokenDecimals, uint256 usdtDecimals, uint256 holderLength,
        uint256 invitorHoldConditionAmount,
        uint256 price, uint256 lpValue, uint256 valTotal, uint256 total
    ){
        tokenDecimals = _decimals;
        usdtDecimals = IERC20(_usdt).decimals();
        holderLength = getHolderLength();
        invitorHoldConditionAmount = 0;
        uint256 lpU = IERC20(_usdt).balanceOf(_mainPair);
        lpValue = lpU * 2;
        uint256 lpTokenAmount = balanceOf(_mainPair);
        if (lpTokenAmount > 0) {
            price = 10 ** _decimals * lpU / lpTokenAmount;
        }
        total = totalSupply();
        valTotal = validTotal();
    }

    function setBtcNFTAddress(address addr) external onlyOwner {
        _btcNFTAddress = addr;
    }

    //BTCNFT
    uint256 public currentBtcNFTIndex;
    uint256 public btcNftRewardCondition;
    uint256 public _btcNftHolderCondition;
    uint256 public progressBtcNFTBlock;
    mapping(address => bool) public excludeBtcNFTHolder;
    uint256 public progressBtcNFTBlockDebt = 200;
    uint256 public _btcNftBaseId = 1;

    uint256 public _btcRewardUsdt;

    function processBtcNFT(uint256 gas) private {
        if (progressBtcNFTBlock + progressBtcNFTBlockDebt > block.number) {
            return;
        }
        IBtcNFT btcNft = IBtcNFT(_btcNFTAddress);
        uint totalNFT = btcNft.totalSupply();
        if (0 == totalNFT) {
            return;
        }
        address tokenDistributor = address(_tokenDistributor);
        IERC20 USDT = IERC20(_usdt);
        uint256 tokenBalance = USDT.balanceOf(tokenDistributor);
        if (tokenBalance < btcNftRewardCondition) {
            return;
        }

        uint256 amount = tokenBalance / totalNFT;
        if (100 > amount) {
            return;
        }
        uint256 totalRewardAmount;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 nftBaseId = _btcNftBaseId;
        uint256 btcNftHolderCondition = _btcNftHolderCondition;

        while (gasUsed < gas && iterations < totalNFT) {
            if (currentBtcNFTIndex >= totalNFT) {
                currentBtcNFTIndex = 0;
            }
            address shareHolder = btcNft.ownerOf(nftBaseId + currentBtcNFTIndex);
            if (!excludeBtcNFTHolder[shareHolder] && balanceOf(shareHolder) >= btcNftHolderCondition) {
                totalRewardAmount += amount;
                USDT.transferFrom(tokenDistributor, shareHolder, amount);
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentBtcNFTIndex++;
            iterations++;
        }

        progressBtcNFTBlock = block.number;
        if (totalRewardAmount > 0) {
            _btcRewardUsdt += totalRewardAmount;
        }
    }

    function setBtcNFTRewardCondition(uint256 amount) external onlyOwner {
        btcNftRewardCondition = amount;
    }

    function setBtcNFTHoldCondition(uint256 amount) external onlyOwner {
        _btcNftHolderCondition = amount;
    }

    function setBtcExcludeNFTHolder(address addr, bool enable) external onlyOwner {
        excludeBtcNFTHolder[addr] = enable;
    }

    function setProgressBtcNFTBlockDebt(uint256 blockDebt) external onlyOwner {
        progressBtcNFTBlockDebt = blockDebt;
    }

    function setBtcNftBaseId(uint256 baseId) external onlyOwner {
        _btcNftBaseId = baseId;
    }

    function setCheckCanBuyDelay(uint256 blockNum) external onlyOwner {
        checkCanBuyDelay = blockNum;
    }

    function setMaxPriceRate(uint256 priceRate) external onlyOwner {
        maxPriceRate = priceRate;
    }

    function setLimitAmount(uint256 amount) external onlyOwner {
        _limitAmount = amount * 10 ** IERC20(_usdt).decimals();
    }

    function setCheckLimitDuration(uint256 blockNum) external onlyOwner {
        checkLimitDuration = blockNum;
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
}

contract AMTDAO is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
        "AMTDAO",
        "AMTDAO",
        18,
        21000,
    //Fund
        address(0x683A1C9344288413D0A2D1F19d8120A3B224e243),
    //Receive
        address(0x89451135a0B871E441C63867F0F4e0eb5934F82f),
        210,
    //BTCNFT
        address(0x6477F5D55E8cd3a9a2d85DccF6B3aB09AAc47547)
    ){

    }
}