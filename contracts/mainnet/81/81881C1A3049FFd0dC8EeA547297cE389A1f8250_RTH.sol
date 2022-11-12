/**
 *Submitted for verification at BscScan.com on 2022-11-12
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

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
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

abstract contract AbsToken is IERC20, Ownable {
    struct UserInfo {
        uint256 buyAmount;
        uint256 lastRewardTime;
        uint256 rewardRate;
        uint256 buyUsdt;
        bool activeReward;
    }

    uint256 public _initRewardRate = 50;
    uint256 public _addRewardRate = 25;
    uint256 public _maxRewardRate = 200;
    uint256 public _addRewardRateCondition;
    uint256 public _endRewardTime;
    uint256 public _endFeeTime;

    mapping(address => UserInfo) private _userInfo;
    mapping(address => bool) public _excludeReward;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;

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

    uint256 public _buyFundFee = 200;
    uint256 public _buyInviteFee = 1000;

    uint256 public _sellDestroyFee = 1000;
    uint256 public _sellFundFee = 790;
    uint256 public _sellAirdropFee = 10;

    uint256 public _transferFee = 1300;

    uint256 public startTradeBlock;
    address public _mainPair;

    mapping(uint256 => uint256) public dayPrice;
    uint256 public _destroyPoolPriceRate = 9000;
    uint256 public _destroyPoolRate = 2000;
    uint256 public _addSellFeePriceRate = 9000;
    uint256 public _addSellFeePriceRateStep = 100;
    uint256 public _addSellFeeStep = 100;
    uint256 public _addSellFeeMax = 1200;

    mapping(uint256 => uint256) public dayUpPriceTimes;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceiveAddress, address FundAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);

        _usdt = USDTAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address mainPair = swapFactory.createPair(address(this), USDTAddress);
        _swapPairList[mainPair] = true;
        _mainPair = mainPair;

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

        _excludeReward[address(0)] = true;
        _excludeReward[address(0x000000000000000000000000000000000000dEaD)] = true;
        _excludeReward[address(this)] = true;

        _addRewardRateCondition = 500 * 10 ** IERC20(USDTAddress).decimals();
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
        if (!_swapPairList[account] && !_feeWhiteList[account]) {
            UserInfo storage userInfo = _userInfo[account];
            uint256 lastRewardTime = userInfo.lastRewardTime;
            uint256 buyAmount = userInfo.buyAmount;
            uint256 rewardRate = userInfo.rewardRate;
            uint256 blockTime = block.timestamp;
            uint256 endRewardTime = _endRewardTime;
            if (blockTime > lastRewardTime && lastRewardTime < endRewardTime) {
                if (blockTime > endRewardTime) {
                    blockTime = endRewardTime;
                }
                uint256 reward = buyAmount * rewardRate * (blockTime - lastRewardTime) / 1 days / 10000;
                balance += reward;
            }
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
        //calReward
        uint256 balance = balanceOf(from);
        _balances[from] = balance;
        _userInfo[from].lastRewardTime = block.timestamp;

        require(balance >= amount, "balanceNotEnough");

        bool takeFee;
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 999 / 1000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
            if (block.timestamp < _endFeeTime || 0 == _endFeeTime) {
                takeFee = true;
            }
        }

        uint256 day = today();
        uint256 price = tokenPrice();
        if (price > 0) {
            uint256 todayPrice = dayPrice[day];
            if (0 == todayPrice) {
                dayPrice[day] = price;
            } else if (!_swapPairList[from]) {//not buy
                if (dayUpPriceTimes[day] == 0 && price < todayPrice * _destroyPoolPriceRate / 10000) {
                    address mainPair = _mainPair;
                    uint256 poolTokenOutAmount = _destroyPoolRate * balanceOf(mainPair) / 10000;
                    if (poolTokenOutAmount > 0) {
                        _tokenTransfer(mainPair, address(0x000000000000000000000000000000000000dEaD), poolTokenOutAmount, false);
                        ISwapPair(mainPair).sync();
                    }
                    dayUpPriceTimes[day] = block.timestamp;
                }
            }

            //cal buyUsdt
            if (_swapPairList[from]) {
                UserInfo storage userInfo = _userInfo[to];
                if (!userInfo.activeReward) {
                    uint256 buyUsdt = userInfo.buyUsdt;
                    address[] memory path = new address[](2);
                    path[0] = _usdt;
                    path[1] = address(this);
                    uint[] memory amounts = _swapRouter.getAmountsIn(amount, path);
                    uint256 usdtAmount = amounts[0];
                    buyUsdt += usdtAmount;
                    userInfo.buyUsdt = buyUsdt;
                    if (buyUsdt >= _addRewardRateCondition) {
                        address invitor = _inviter[to];
                        if (invitor != address(0)) {
                            userInfo.activeReward = true;
                            UserInfo storage invitorInfo = _userInfo[invitor];
                            uint256 maxRate = _maxRewardRate;
                            uint256 rewardRate = invitorInfo.rewardRate;
                            if (rewardRate == 0) {
                                rewardRate = _initRewardRate;
                            }
                            if (rewardRate < maxRate) {
                                rewardRate += _addRewardRate;
                                _balances[invitor] = balanceOf(invitor);
                                invitorInfo.lastRewardTime = block.timestamp;
                                invitorInfo.rewardRate = rewardRate;
                            }
                        }
                    }
                }
            }
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startTradeBlock) {
                require(_feeWhiteList[from] || _feeWhiteList[to], "!Trading");
                if (to == _mainPair && IERC20(to).totalSupply() == 0) {
                    startTradeBlock = block.number;
                    uint256 endTime = block.timestamp + 730 days;
                    _endRewardTime = endTime;
                    _endFeeTime = endTime;
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (block.number < startTradeBlock + 3) {
                    _funTransfer(from, to, amount);
                    return;
                }
            }
        } else {
            if (address(0) == _inviter[to] && amount > 0 && from != to) {
                _maybeInvitor[to][from] = true;
            }
            if (address(0) == _inviter[from] && amount > 0 && from != to) {
                if (_maybeInvitor[from][to] && _binders[from].length == 0) {
                    _bindInvitor(from, to);
                }
            }
        }

        _tokenTransfer(from, to, amount, takeFee);
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        subAmount(sender, tAmount);
        uint256 feeAmount = tAmount * 99 / 100;
        _takeTransfer(
            sender,
            fundAddress,
            feeAmount
        );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function subAmount(address sender, uint256 tAmount) private {
        uint256 balance = _balances[sender] - tAmount;
        _balances[sender] = balance;
        UserInfo storage userInfo = _userInfo[sender];
        uint256 buyAmount = userInfo.buyAmount;
        if (buyAmount > balance) {
            userInfo.buyAmount = balance;
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        subAmount(sender, tAmount);
        uint256 feeAmount;

        if (takeFee) {
            if (_swapPairList[sender]) {//buy
                uint256 inviterAmount = tAmount * _buyInviteFee / 10000;
                feeAmount += inviterAmount;
                address invitor = _inviter[recipient];
                if (address(0) == invitor) {
                    invitor = fundAddress;
                }
                _takeTransfer(sender, invitor, inviterAmount);

                uint256 buyFundAmount = tAmount * _buyFundFee / 10000;
                feeAmount += buyFundAmount;
                _takeTransfer(sender, address(this), buyFundAmount);
            } else if (_swapPairList[recipient]) {//sell
                uint256 destroyFeeAmount = tAmount * _sellDestroyFee / 10000;
                feeAmount += destroyFeeAmount;
                _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), destroyFeeAmount);

                uint256 sellAirdropAmount = tAmount * _sellAirdropFee / 10000;
                feeAmount += sellAirdropAmount;
                _airdrop(sender, sellAirdropAmount);

                uint256 sellFundAmount = tAmount * _sellFundFee / 10000;

                uint256 addSellFee = getAddSellFee();
                uint256 addSellFeeAmount = tAmount * addSellFee / 10000;

                uint256 allSellFundAmount = addSellFeeAmount + sellFundAmount;
                feeAmount += allSellFundAmount;

                _takeTransfer(sender, address(this), allSellFundAmount);

                if (!inSwap) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    allSellFundAmount += sellFundAmount;
                    if (addSellFeeAmount == 0) {
                        allSellFundAmount += sellFundAmount;
                    }

                    if (allSellFundAmount > contractTokenBalance) {
                        allSellFundAmount = contractTokenBalance;
                    }
                    swapTokenForFund(allSellFundAmount);
                }
            } else {//transfer
                feeAmount = _transferFee * tAmount / 10000;
                _takeTransfer(sender, address(this), feeAmount);
            }
        }
        _addAmount(sender, recipient, tAmount - feeAmount, _swapPairList[sender]);
    }

    address public lastAirdropAddress;

    function _airdrop(address sender, uint256 airdropFeeAmount) private {
        if (airdropFeeAmount > 0) {
            uint256 seed = (uint160(lastAirdropAddress) | block.number) ^ uint160(sender);
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
    }

    function getAddSellFee() public view returns (uint256){
        uint256 todayPrice = dayPrice[today()];
        uint256 price = tokenPrice();
        uint256 priceRate = price * 10000 / todayPrice;
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

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;
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
        _addAmount(sender, to, tAmount, false);
    }

    function _addAmount(
        address sender,
        address to,
        uint256 tAmount,
        bool buy
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
        if (buy) {
            _balances[to] = balanceOf(to);
            UserInfo storage userInfo = _userInfo[to];
            userInfo.lastRewardTime = block.timestamp;
            userInfo.buyAmount += tAmount;
            if (userInfo.rewardRate == 0) {
                userInfo.rewardRate = _initRewardRate;
            }
        }
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
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

    function setDayPrice(uint256 day, uint256 price) external onlyOwner {
        dayPrice[day] = price;
    }

    function setDayUpPriceTime(uint256 day, uint256 time) external onlyOwner {
        dayUpPriceTimes[day] = time;
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

    function setEndRewardTime(uint256 time) external onlyOwner {
        _endRewardTime = time;
    }

    function setEndFeeTime(uint256 time) external onlyOwner {
        _endFeeTime = time;
    }

    function setRewardRateCondition(uint256 amount) external onlyOwner {
        _addRewardRateCondition = amount;
    }

    function today() public view returns (uint256){
        return block.timestamp / 86400;
    }

    function tokenPrice() public view returns (uint256){
        ISwapPair swapPair = ISwapPair(_mainPair);
        (uint256 reverse0, uint256 reverse1,) = swapPair.getReserves();
        uint256 usdtReverse;
        uint256 tokenReverse;
        if (_usdt < address(this)) {
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

    mapping(address => address) public _inviter;
    mapping(address => address[]) public _binders;
    mapping(address => bool) public _inProject;
    mapping(address => mapping(address => bool)) public _maybeInvitor;

    function bindInvitor(address account, address invitor) public {
        address caller = msg.sender;
        require(_inProject[caller], "notProj");
        _bindInvitor(account, invitor);
    }

    function _bindInvitor(address account, address invitor) private {
        if (invitor != address(0) && invitor != account && _inviter[account] == address(0)) {
            uint256 size;
            assembly {size := extcodesize(invitor)}
            if (size > 0) {
                return;
            }
            _inviter[account] = invitor;
            _binders[invitor].push(account);
        }
    }

    function setInProject(address adr, bool enable) external onlyOwner {
        _inProject[adr] = enable;
    }

    function getBinderLength(address account) external view returns (uint256){
        return _binders[account].length;
    }

    function setExcludeReward(address account, bool enable) external onlyOwner {
        _balances[account] = balanceOf(account);
        _userInfo[account].lastRewardTime = block.timestamp;
        _excludeReward[account] = enable;
    }

    function getUserInfo(address account) public view returns (
        uint256 buyAmount,
        uint256 lastRewardTime,
        uint256 rewardRate,
        uint256 buyUsdt,
        bool activeReward,
        uint256 balance,
        uint256 _balance
    ){
        UserInfo storage userInfo = _userInfo[account];
        buyAmount = userInfo.buyAmount;
        lastRewardTime = userInfo.lastRewardTime;
        rewardRate = userInfo.rewardRate;
        buyUsdt = userInfo.buyUsdt;
        activeReward = userInfo.activeReward;
        balance = balanceOf(account);
        _balance = _balances[account];
    }

    function getTokenInfo() public view returns (
        uint256 price,
        uint256 todayPrice,
        uint256 addSellFee,
        uint256 todayPriceUpTime,
        uint256 endFeeTime,
        uint256 endRewardTime
    ){
        price = tokenPrice();
        todayPrice = dayPrice[today()];
        addSellFee = getAddSellFee();
        endFeeTime = _endFeeTime;
        endRewardTime = _endRewardTime;
        todayPriceUpTime = dayUpPriceTimes[today()];
    }
}

contract RTH is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
        "Rebuild The Home",
        "RTH",
        18,
        224000000,
    //Receive
        address(0xD907a939F92E477fC2a6eeD6a9f02A05a56b9851),
    //Fund
        address(0x502A9C05Eef9bcaBc206BD52e9F5b9fF769ec623)
    ){

    }
}