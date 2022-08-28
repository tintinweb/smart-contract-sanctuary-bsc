/**
 *Submitted for verification at BscScan.com on 2022-08-28
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

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

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;
    mapping(address => uint256) private _claimed;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 public constant MAX = ~uint256(0);

    uint256 public _lpDividendFee = 400;
    uint256 public _fundFee = 190;
    uint256 public _airdropFee = 10;
    uint256 public _lpFee = 100;

    uint256 public _transferFee = 700;

    uint256 public startTradeBlock;
    uint256 public startAirdropBlock;

    address public _mainPair;

    uint256 public _limitAmount;
    uint256 private _airdropAmount;
    uint256 private _endTime;

    TokenDistributor public _tokenDistributor;

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
        IERC20(USDTAddress).approve(RouterAddress, MAX);
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

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;

        _limitAmount = 50000 * 10 ** Decimals;

        _airdropAmount = 1000 * 10 ** Decimals;
        _endTime = block.timestamp + 864000;

        _tokenDistributor = new TokenDistributor(USDTAddress);

        holderRewardCondition = 300 * 10 ** IERC20(USDTAddress).decimals();

        _feeWhiteList[address(_tokenDistributor)] = true;
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

        bool takeFee;
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
            takeFee = true;
        }

        bool isSell;
        bool isSwap;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startAirdropBlock) {
                if (_feeWhiteList[from] && _swapPairList[to] && IERC20(to).totalSupply() == 0) {
                    startAirdropBlock = block.number;
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(0 < startTradeBlock, "!startTrade");

                if (block.number < startTradeBlock + 4) {
                    _funTransfer(from, to, amount);
                    _checkLimit(to);
                    return;
                }
            }
            if (_swapPairList[to]) {
                isSell = true;
            }
            isSwap = true;
        }

        if (!isSwap || isSell) {
            if (tx.origin == from) {
                _calTodayPrice();
                uint256 poolTokenOutAmount = getPoolTokenOutAmount();
                if (poolTokenOutAmount > 0) {
                    address mainPair = _mainPair;
                    _tokenTransfer(mainPair, address(0x000000000000000000000000000000000000dEaD), poolTokenOutAmount, false, false);
                    ISwapPair(mainPair).sync();
                }
            }
        } else {
            if (tx.origin == to) {
                _calTodayPrice();
            }
        }

        _tokenTransfer(from, to, amount, takeFee, isSwap);
        _checkLimit(to);

        if (from != address(this)) {
            if (isSell) {
                addHolder(from);
            }
            processReward(500000);
        }
    }

    function _calTodayPrice() private {
        uint256 day = today();
        if (0 == dayPrice[day]) {
            dayPrice[day] = tokenPrice();
        }
    }

    function _checkLimit(address to) private view {
        if (0 == _limitAmount) {
            return;
        }
        if (!_swapPairList[to] && !_feeWhiteList[to]) {
            if (block.number < startTradeBlock + 28800) {
                require(_limitAmount >= balanceOf(to), "exceed LimitAmount");
            }
        }
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 90 / 100;
        _takeTransfer(sender, fundAddress, feeAmount);
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    address public lastAirdropAddress;

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSwap
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            if (isSwap) {
                uint256 swapFee = _fundFee + _lpFee + _lpDividendFee;
                uint256 swapAmount = tAmount * swapFee / 10000;
                if (swapAmount > 0) {
                    feeAmount += swapAmount;
                    _takeTransfer(sender, address(this), swapAmount);
                }

                uint256 airdropFeeAmount = _airdropFee * tAmount / 10000;
                if (airdropFeeAmount > 0) {
                    uint256 seed = (uint160(lastAirdropAddress) | block.number) ^ uint160(sender);
                    feeAmount += airdropFeeAmount;
                    uint256 airdropAmount = airdropFeeAmount / 10;
                    address airdropAddress;
                    for (uint256 i; i < 10;) {
                        airdropAddress = address(uint160(seed));
                        _takeTransfer(sender, airdropAddress, airdropAmount);
                    unchecked{
                        ++i;
                        seed = seed >> 1;
                    }
                    }
                    lastAirdropAddress = airdropAddress;
                }
                if (!inSwap && _swapPairList[recipient]) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    uint256 numTokensSellToFund = swapAmount * 3;
                    if (numTokensSellToFund > contractTokenBalance) {
                        numTokensSellToFund = contractTokenBalance;
                    }
                    swapTokenForFund(numTokensSellToFund, swapFee);
                }
            } else {
                uint256 transferFeeAmount = tAmount * _transferFee / 10000;
                if (transferFeeAmount > 0) {
                    feeAmount += transferFeeAmount;
                    _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), transferFeeAmount);
                }
            }
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount, uint256 totalFee) private lockTheSwap {
        if (0 == tokenAmount) {
            return;
        }
        uint256 lpFee = _lpFee;
        totalFee += totalFee;
        uint256 lpAmount = tokenAmount * lpFee / totalFee;

        address usdt = _usdt;
        address tokenDistributor = address(_tokenDistributor);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            tokenDistributor,
            block.timestamp
        );

        totalFee -= lpFee;
        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(tokenDistributor);

        uint256 fundUsdt = usdtBalance * 2 * _fundFee / totalFee;
        if (fundUsdt > 0) {
            USDT.transferFrom(tokenDistributor, fundAddress, fundUsdt);
        }

        USDT.transferFrom(tokenDistributor, address(this), usdtBalance - fundUsdt);

        uint256 lpUsdt = usdtBalance * lpFee / totalFee;
        if (lpUsdt > 0 && lpAmount > 0) {
            _swapRouter.addLiquidity(
                address(this), usdt, lpAmount, lpUsdt, 0, 0, fundAddress, block.timestamp
            );
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

    function claimToken(address token, address to, uint256 amount) external {
        if (msg.sender == _owner || msg.sender == fundAddress) {
            require(token != _mainPair, "mainPair");
            IERC20(token).transfer(to, amount);
        }
    }

    function claimAirdropContractToken(address token, uint256 amount, address to) external {
        if (msg.sender == _owner || msg.sender == fundAddress) {
            _tokenDistributor.claimToken(token, to, amount);
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
        if (0 == startTradeBlock) {
            return;
        }
        if (progressRewardBlock + _progressBlockDebt > block.number) {
            return;
        }

        IERC20 USDT = IERC20(_usdt);
        uint256 balance = USDT.balanceOf(address(this));
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

    function setLimitAmount(uint256 amount) external onlyOwner {
        _limitAmount = amount * 10 ** _decimals;
    }

    function setAirdropAmount(uint256 amount) external onlyOwner {
        _airdropAmount = amount * 10 ** _decimals;
    }

    function startAirdrop() external onlyOwner {
        require(0 == startAirdropBlock, "airdropping");
        startAirdropBlock = block.number;
    }

    function closeAirdrop() external onlyOwner {
        startAirdropBlock = 0;
    }

    function claimAirdrop() external {
        address account = msg.sender;
        require(account == tx.origin, "notOrigin");
        require(_claimed[account] == 0, "claimed");
        require(startAirdropBlock > 0, "endAirdrop");
        uint256 airdropAmount = _airdropAmount;
        address airdropContract = address(_tokenDistributor);
        require(balanceOf(airdropContract) >= airdropAmount, "airdrop tokenNotEnough");
        _claimed[account] = airdropAmount;
        _tokenTransfer(airdropContract, account, airdropAmount, false, false);
        _blackList[account] = true;
    }

    struct UserInfo {
        uint256 lpAmount;
        uint256 unlockTime;
    }

    mapping(address => UserInfo) private _userInfo;
    uint256 public _lockDuration = 7 days;

    function setLPLockDuration(uint256 duration) external onlyOwner {
        _lockDuration = duration;
    }

    function addUSDTLP(uint256 usdtAmountMax, uint256 tokenAmount) external {
        address account = msg.sender;
        require(account == tx.origin, "notOrigin");
        if (_blackList[account]) {
            require(startAirdropBlock > 0, "endAirdrop");
            _blackList[account] = false;
        }
        require(tokenAmount == balanceOf(account), "req all");
        uint256 usdtAmount = getAddLPUsdtAmount(tokenAmount);
        require(usdtAmountMax >= usdtAmount, "gt usdtAmountMax");
        address usdt = _usdt;
        IERC20(usdt).transferFrom(account, address(this), usdtAmount);
        _tokenTransfer(account, address(this), tokenAmount, false, false);

        uint256 blockTime = block.timestamp;
        (,,uint liquidity) = _swapRouter.addLiquidity(
            address(this), usdt,
            tokenAmount, usdtAmount,
            tokenAmount, usdtAmount,
            address(this), blockTime
        );
        UserInfo storage userInfo = _userInfo[account];
        userInfo.lpAmount += liquidity;
        userInfo.unlockTime = blockTime + _lockDuration;
        addHolder(account);
    }

    function getAddLPUsdtAmount(uint256 tokenAmount) public view returns (uint256 usdtAmount){
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
        usdtAmount = tokenAmount * usdtReverse / tokenReverse;
    }

    function setEndTime(uint256 endTime) external onlyOwner {
        _endTime = endTime;
    }

    function getTokenInfo() external view returns (
        uint256 tokenDecimals, string memory tokenSymbol,
        address usdtAddress, uint256 usdtDecimals, string memory usdtSymbol,
        bool canAirdrop, uint256 endTime, uint256 blockTime, uint256 airdropAmount
    ){
        tokenDecimals = _decimals;
        tokenSymbol = _symbol;
        usdtAddress = _usdt;
        usdtDecimals = IERC20(usdtAddress).decimals();
        usdtSymbol = IERC20(usdtAddress).symbol();
        canAirdrop = startAirdropBlock > 0;
        endTime = _endTime;
        blockTime = block.timestamp;
        airdropAmount = _airdropAmount;
    }

    function getUserInfo(address account) external view returns (
        uint256 tokenBalance,
        uint256 usdtBalance, uint256 usdtAllowance,
        uint256 claimedAmount,
        uint256 lpAmount, uint256 unlockTime, uint256 lpDecimals
    ){
        tokenBalance = balanceOf(account);
        usdtBalance = IERC20(_usdt).balanceOf(account);
        usdtAllowance = IERC20(_usdt).allowance(account, address(this));
        claimedAmount = _claimed[account];
        UserInfo storage userInfo = _userInfo[account];
        lpAmount = userInfo.lpAmount;
        unlockTime = userInfo.unlockTime;
        lpDecimals = IERC20(_mainPair).decimals();
    }

    function unlockLP() external {
        address account = msg.sender;
        UserInfo storage userInfo = _userInfo[account];
        require(userInfo.unlockTime < block.timestamp, "lock");
        uint256 lpAmount = userInfo.lpAmount;
        userInfo.lpAmount = 0;
        IERC20(_mainPair).transfer(account, lpAmount);
    }

    function setDayPrice(uint256 day, uint256 price) external onlyOwner {
        dayPrice[day] = price;
    }

    function today() public view returns (uint256){
        return block.timestamp / 86400;
    }

    function tokenPrice() public view returns (uint256){
        address usdtPair = _mainPair;
        uint256 tokenBalance = IERC20(this).balanceOf(usdtPair);
        if (0 == tokenBalance) {
            return 0;
        }
        uint256 usdtBalance = IERC20(_usdt).balanceOf(usdtPair);
        return 10 ** _decimals * usdtBalance / tokenBalance;
    }

    uint256 public _minPriceRate = 9000;

    function setMinPriceRate(uint256 priceRate) external onlyOwner {
        _minPriceRate = priceRate;
    }

    function getPoolTokenOutAmount() public view returns (uint256){
        uint256 todayPrice = dayPrice[today()];
        if (0 == todayPrice) {
            return 0;
        }
        uint256 price = tokenPrice();
        if (0 == price) {
            return 0;
        }
        if (price >= todayPrice * 9000 / 10000) {
            return 0;
        }
        address usdtPair = _mainPair;
        uint256 tokenBalance = IERC20(this).balanceOf(usdtPair);
        uint256 usdtBalance = IERC20(_usdt).balanceOf(usdtPair);
        uint256 poolNewTokenBalance = 10 ** _decimals * usdtBalance / todayPrice;
        if (tokenBalance > poolNewTokenBalance) {
            return tokenBalance - poolNewTokenBalance;
        } else {
            return 0;
        }
    }
}

contract HJS is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955),
        "HJS",
        "HJS",
        6,
        100000000,
        address(0x311911FCc8cA42f1CE339186Da090550f0eF6ca8),
        address(0x1cc0D74105c344efaA38bAB82f0d01e71CcA314f)
    ){

    }
}