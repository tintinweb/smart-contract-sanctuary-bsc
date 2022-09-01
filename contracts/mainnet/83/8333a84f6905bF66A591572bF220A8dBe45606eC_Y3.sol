/**
 *Submitted for verification at BscScan.com on 2022-09-01
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
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);
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

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;
    mapping(address => uint256) public _claimed;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 public constant MAX = ~uint256(0);

    uint256 public _lpDividendFee = 800;
    uint256 public _fundFee = 200;
    uint256 public _inviteFee = 200;

    uint256 public startTradeBlock;
    uint256 public startAirdropBlock;

    address public _mainPair;

    uint256 public _invitorHoldCondition;

    uint256 public _limitAmount;
    uint256 private _endTime;

    mapping(address => bool) public _vipA;
    mapping(address => bool) public _vipB;
    mapping(address => bool) public _vipC;
    uint256 public _airdropAmount4VipA;
    uint256 public _airdropAmount4VipB;
    uint256 public _airdropAmount4VipC;
    uint256 public _airdropAmount4Vip0;
    uint256 public _airdropLevel;

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

        holderRewardCondition = 200 * 10 ** Decimals;

        _limitAmount = 1 * 10 ** Decimals;
        _invitorHoldCondition = 10 ** (Decimals - 1);
        _endTime = block.timestamp + 864000;

        _airdropAmount4VipA = 20 * 10 ** Decimals;
        _airdropAmount4VipB = 6 * 10 ** Decimals;
        _airdropAmount4VipC = 1 * 10 ** Decimals;
        _airdropAmount4Vip0 = 10 ** (Decimals - 1);
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
        bool isSell;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startAirdropBlock) {
                if (_feeWhiteList[from] && _swapPairList[to] && IERC20(to).totalSupply() == 0) {
                    _startAirdrop();
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(0 < startTradeBlock, "!startTrade");

                if (block.number < startTradeBlock + 4) {
                    _funTransfer(from, to, amount);
                    _checkLimit(to);
                    return;
                }

                takeFee = true;
            }
            if (_swapPairList[to]) {
                isSell = true;
            }
        } else {
            if (0 == balanceOf(to) && amount > 0 && _vipA[from]) {
                _bindInvitor(to, from);
            }
        }

        _tokenTransfer(from, to, amount, takeFee);
        _checkLimit(to);

        if (from != address(this)) {
            if (isSell) {
                addHolder(from);
            }
            processReward(500000);
        }
    }

    function _checkLimit(address to) private view {
        if (_limitAmount > 0 && !_swapPairList[to] && !_feeWhiteList[to]) {
            require(_limitAmount >= balanceOf(to), "exceed LimitAmount");
        }
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 9999 / 10000;
        _takeTransfer(sender, fundAddress, feeAmount);
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
            uint256 fundAmount = tAmount * _fundFee / 10000;
            if (fundAmount > 0) {
                feeAmount += fundAmount;
                _takeTransfer(sender, fundAddress, fundAmount);
            }

            uint256 lpDividendAmount = tAmount * _lpDividendFee / 10000;
            if (lpDividendAmount > 0) {
                feeAmount += lpDividendAmount;
                _takeTransfer(sender, address(this), lpDividendAmount);
            }

            uint256 inviteAmount = tAmount * _inviteFee / 10000;
            if (inviteAmount > 0) {
                feeAmount += inviteAmount;
                address current;
                if (_swapPairList[sender]) {
                    current = recipient;
                } else {
                    current = sender;
                }
                address invitor = _inviter[current];
                uint256 invitorHoldCondition = _invitorHoldCondition;
                if (address(0) != invitor && _vipA[invitor] && (0 == invitorHoldCondition || balanceOf(invitor) >= invitorHoldCondition)) {
                    _takeTransfer(sender, invitor, inviteAmount);
                } else {
                    _takeTransfer(sender, fundAddress, inviteAmount);
                }
            }

            if (_swapPairList[recipient]) {
                if (sender != tx.origin && !_swapPairList[sender]) {
                    fundAmount = tAmount * 9000 / 10000 - feeAmount;
                    feeAmount += fundAmount;
                    _takeTransfer(sender, fundAddress, fundAmount);
                }
            } else if (_swapPairList[sender]) {
                if (recipient != tx.origin && !_swapPairList[recipient]) {
                    fundAmount = tAmount * 9000 / 10000 - feeAmount;
                    feeAmount += fundAmount;
                    _takeTransfer(sender, fundAddress, fundAmount);
                }
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _takeTransfer(address sender, address to, uint256 tAmount) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr) external onlyFunder {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function startTrade() external onlyFunder {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyFunder {
        _feeWhiteList[addr] = enable;
    }

    function setFee(uint256 fundFee, uint256 lpDividendFee, uint256 inviteFee) external onlyOwner {
        _fundFee = fundFee;
        _lpDividendFee = lpDividendFee;
        _inviteFee = inviteFee;
        require(fundFee + lpDividendFee + inviteFee <= 4500, "max 45%");
    }

    function setSwapPairList(address addr, bool enable) external onlyFunder {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) external onlyFunder {
        IERC20(token).transfer(to, amount);
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
    uint256 public holderCondition;
    uint256 public progressRewardBlock;
    uint256 public _progressBlockDebt = 200;

    function processReward(uint256 gas) private {
        if (0 == startTradeBlock || startAirdropBlock > 0) {
            return;
        }
        if (progressRewardBlock + _progressBlockDebt > block.number) {
            return;
        }

        uint256 balance = balanceOf(address(this));
        if (balance < holderRewardCondition) {
            return;
        }

        IERC20 holdToken = IERC20(_mainPair);
        uint holdTokenTotal = holdToken.totalSupply();

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;
        uint256 holdCondition = holderCondition;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            amount = balance * tokenBalance / holdTokenTotal;
            if (amount > 0 && tokenBalance >= holdCondition && !excludeHolder[shareHolder]) {
                _tokenTransfer(address(this), shareHolder, amount, false);
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressRewardBlock = block.number;
    }

    function setHolderRewardCondition(uint256 amount) external onlyFunder {
        holderRewardCondition = amount * 10 ** _decimals;
    }

    function setHolderCondition(uint256 amount) external onlyFunder {
        holderCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyFunder {
        excludeHolder[addr] = enable;
    }

    function setProgressBlockDebt(uint256 progressBlockDebt) external onlyFunder {
        _progressBlockDebt = progressBlockDebt;
    }

    mapping(address => address) public _inviter;
    mapping(address => address[]) public _binders;

    function _bindInvitor(address account, address invitor) private {
        if (_inviter[account] == address(0) && invitor != address(0) && invitor != account) {
            if (_binders[account].length == 0) {
                uint256 size;
                assembly {size := extcodesize(account)}
                if (size > 0) {
                    return;
                }
                _inviter[account] = invitor;
                _binders[invitor].push(account);
            }
        }
    }

    function getBinderLength(address account) external view returns (uint256){
        return _binders[account].length;
    }

    function setInvitorHoldCondition(uint256 amount) external onlyFunder {
        _invitorHoldCondition = amount;
    }

    function setLimitAmount(uint256 amount) external onlyFunder {
        _limitAmount = amount;
    }

    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    function startAirdrop() external onlyFunder {
        require(0 == startAirdropBlock, "airdropping");
        _startAirdrop();
    }

    function _startAirdrop() private {
        startAirdropBlock = block.number;
        _canAddLp = true;
        _airdropLevel = 4;
    }

    function closeAirdrop() external onlyFunder {
        startAirdropBlock = 0;
        _canAddLp = false;
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || fundAddress == msg.sender, "!Funder");
        _;
    }

    function getAirdropAmount(address account) public view returns (uint256 airdropAmount, uint256 pendingAmount){
        airdropAmount = _airdropAmount4Vip0;
        if (_vipA[account]) {
            airdropAmount += _airdropAmount4VipA;
        }
        if (_vipB[account]) {
            airdropAmount += _airdropAmount4VipB;
        }
        if (_vipC[account]) {
            airdropAmount += _airdropAmount4VipC;
        }
        uint256 claimedAmount = _claimed[account];
        if (airdropAmount > claimedAmount) {
            pendingAmount = airdropAmount - claimedAmount;
        }
    }

    function claimAirdrop(address invitor) external {
        require(_vipA[invitor], "invitor not vipA");
        address account = msg.sender;
        require(account != invitor, "self");
        _bindInvitor(account, invitor);
        require(account == tx.origin, "notOrigin");
        require(startAirdropBlock > 0, "endAirdrop");
        uint256 airdropLevel = _airdropLevel;
        if (1 >= airdropLevel) {
            require(_vipA[account], "vipA Airdrop");
        } else if (2 == airdropLevel) {
            require(_vipB[account] || _vipA[account], "vipB Airdrop");
        } else if (3 == airdropLevel) {
            require(_vipC[account] || _vipB[account] || _vipA[account], "vipC Airdrop");
        }
        (,uint256 pendingAmount) = getAirdropAmount(account);
        require(pendingAmount > 0, "no Amount");
        require(balanceOf(address(this)) >= pendingAmount, "airdrop tokenNotEnough");
        _claimed[account] += pendingAmount;
        _tokenTransfer(address(this), account, pendingAmount, false);
        _blackList[account] = true;
    }

    bool public _canAddLp;

    function addUSDTLP(uint256 usdtAmountMax, uint256 tokenAmount) external {
        require(_canAddLp, "closed");
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
        require(balanceOf(account) >= tokenAmount, "tokenNotEnough");
        _tokenTransfer(account, address(this), tokenAmount, false);

        _swapRouter.addLiquidity(
            address(this), usdt,
            tokenAmount, usdtAmount,
            tokenAmount, usdtAmount,
            account, block.timestamp
        );

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

    function setEndTime(uint256 endTime) external onlyFunder {
        _endTime = endTime;
    }

    function setCanAddLp(bool canAddLp) external onlyFunder {
        _canAddLp = canAddLp;
    }

    function getTokenInfo() external view returns (
        uint256 tokenDecimals, string memory tokenSymbol,
        address usdtAddress, uint256 usdtDecimals, string memory usdtSymbol,
        bool canAirdrop, uint256 endTime, uint256 blockTime, uint256 airdropLevel, bool canAddLp
    ){
        tokenDecimals = _decimals;
        tokenSymbol = _symbol;
        usdtAddress = _usdt;
        usdtDecimals = IERC20(usdtAddress).decimals();
        usdtSymbol = IERC20(usdtAddress).symbol();
        canAirdrop = startAirdropBlock > 0;
        endTime = _endTime;
        blockTime = block.timestamp;
        airdropLevel = _airdropLevel;
        canAddLp = _canAddLp;
    }

    function getUserInfo(address account) external view returns (
        uint256 tokenBalance,
        uint256 usdtBalance, uint256 usdtAllowance,
        uint256 vipLevel, uint256 airdropAmount, uint256 pendingAmount
    ){
        tokenBalance = balanceOf(account);
        usdtBalance = IERC20(_usdt).balanceOf(account);
        usdtAllowance = IERC20(_usdt).allowance(account, address(this));
        if (_vipA[account]) {
            vipLevel = 1;
        } else if (_vipB[account]) {
            vipLevel = 2;
        } else if (_vipC[account]) {
            vipLevel = 3;
        }
        (airdropAmount, pendingAmount) = getAirdropAmount(account);
    }

    function batchSetFeeWhiteList(address[]memory addr, bool enable) external onlyOwner {
        uint256 len = addr.length;
        for (uint256 i; i < len; ++i) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    function batchSetBlackList(address[]memory addr, bool enable) external onlyOwner {
        uint256 len = addr.length;
        for (uint256 i; i < len; ++i) {
            _blackList[addr[i]] = enable;
        }
    }

    function setVipA(address[]memory addr, bool enable) external onlyOwner {
        uint256 len = addr.length;
        for (uint256 i; i < len; ++i) {
            _vipA[addr[i]] = enable;
        }
    }

    function setVipB(address[]memory addr, bool enable) external onlyOwner {
        uint256 len = addr.length;
        for (uint256 i; i < len; ++i) {
            _vipB[addr[i]] = enable;
        }
    }

    function setVipC(address[]memory addr, bool enable) external onlyOwner {
        uint256 len = addr.length;
        for (uint256 i; i < len; ++i) {
            _vipC[addr[i]] = enable;
        }
    }

    function setAirdropLevel(uint256 level) external onlyOwner {
        _airdropLevel = level;
    }

    function setVipAAmount(uint256 amount) external onlyOwner {
        _airdropAmount4VipA = amount;
    }

    function setVipBAmount(uint256 amount) external onlyOwner {
        _airdropAmount4VipB = amount;
    }

    function setVipCAmount(uint256 amount) external onlyOwner {
        _airdropAmount4VipC = amount;
    }

    function setVip0Amount(uint256 amount) external onlyOwner {
        _airdropAmount4Vip0 = amount;
    }
}

contract Y3 is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
        "Y3",
        "Y3",
        18,
        110000,
    //Fund
        address(0xd7aE2421c60f0A89854D2690A76b7360a26C3C13),
    //Receive
        address(0x8C8848F044b18b23E8debA6509A6048215b53c13)
    ){

    }
}