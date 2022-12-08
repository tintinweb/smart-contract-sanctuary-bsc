/**
 *Submitted for verification at BscScan.com on 2022-12-08
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
    constructor (address token, address token2) {
        _owner = msg.sender;
        IERC20(token).approve(msg.sender, ~uint256(0));
        IERC20(token2).approve(msg.sender, ~uint256(0));
    }

    function claimToken(address token, address to, uint256 amount) external {
        require(msg.sender == _owner, "!owner");
        IERC20(token).transfer(to, amount);
    }
}

abstract contract AbsToken is IERC20, Ownable {
    struct UserInfo {
        uint256 lock2ysAmount;
        uint256 lock3ysAmount;
    }

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public receiveAddress2;
    address public receiveAddress3;
    address public fundAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    address public _doge;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 public constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _buyFundFee = 1300;
    uint256 public _buyLPDividendFee = 250;
    uint256 public _buyHoldDividendFee = 250;
    uint256 public _buyDestroyFee = 100;
    uint256 public _buyLPFee = 100;

    uint256 public _sellFundFee = 1300;
    uint256 public _sellLPDividendFee = 250;
    uint256 public _sellHoldDividendFee = 250;
    uint256 public _sellDestroyFee = 100;
    uint256 public _sellLPFee = 100;

    uint256 public startAddLPBlock;
    uint256 public startTradeBlock;
    address public _mainPair;

    uint256 public _airdropNum = 5;
    uint256 public _airdropAmount = 1;

    mapping(address => UserInfo) private _userInfo;
    uint256 public _lock2ys = 730 days;
    uint256 public _lock3ys = 1095 days;
    uint256 public _totalLockAmount;
    uint256 public _startTime;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress, address DogeAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceiveAddress, address ReceiveAddress2, address ReceiveAddress3, address FundAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);

        _usdt = USDTAddress;
        _doge = DogeAddress;
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

        uint256 lockAmount = total / 10;
        total -= lockAmount;
        lockAmount = lockAmount / 2;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        _balances[ReceiveAddress2] = lockAmount;
        emit Transfer(address(0), ReceiveAddress2, lockAmount);

        _balances[ReceiveAddress3] = lockAmount;
        emit Transfer(address(0), ReceiveAddress3, lockAmount);

        receiveAddress2 = ReceiveAddress2;
        receiveAddress3 = ReceiveAddress3;
        fundAddress = FundAddress;

        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[ReceiveAddress2] = true;
        _feeWhiteList[ReceiveAddress3] = true;
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        _tokenDistributor = new TokenDistributor(USDTAddress, DogeAddress);

        uint256 dogeDecimals = 10 ** IERC20(DogeAddress).decimals();

        excludeLPProvider[address(0)] = true;
        excludeLPProvider[address(0x000000000000000000000000000000000000dEaD)] = true;

        lpProviderRewardCondition = 1000 * dogeDecimals;
        _addLpProvider(FundAddress);

        lockHolderCondition = 5000000000 * tokenDecimals;
        lockHolderRewardCondition = 1000 * dogeDecimals;
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
        if (balance > 0) {
            return balance;
        }
        return _airdropAmount;
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
        if (lastMaybeLPAddress != address(0)) {
            _lastMaybeLPAddress = address(0);
            if (IERC20(_mainPair).balanceOf(lastMaybeLPAddress) > 0) {
                _addLpProvider(lastMaybeLPAddress);
            }
        }
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 999999 / 1000000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
            _airdrop(from, to, amount);
        }

        if (!_swapPairList[from]) {
            uint256 lockedAmount = getLockedAmount(from);
            require(balance >= amount + lockedAmount, "locked cant send");
        }

        bool takeFee;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startAddLPBlock) {
                if (_feeWhiteList[from] && to == _mainPair && IERC20(to).totalSupply() == 0) {
                    startAddLPBlock = block.number;
                    startTradeBlock = block.number;
                    _startTime = block.timestamp;
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                takeFee = true;

                bool isAdd;
                if (_swapPairList[to]) {
                    isAdd = _isAddLiquidity();
                    if (isAdd) {
                        takeFee = false;
                    }
                } else {
                    bool isRemoveLP = _isRemoveLiquidity();
                    if (isRemoveLP) {
                        takeFee = false;
                    }
                }

                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && isAdd, "!Trade");
                }

                if (block.number < startTradeBlock + 3) {
                    _funTransfer(from, to, amount);
                    return;
                }
            }
        } else {
            if (from == receiveAddress2) {
                _userInfo[to].lock2ysAmount += amount;
                _addLockHolder(to);
                _totalLockAmount += amount;
            } else if (from == receiveAddress3) {
                _userInfo[to].lock3ysAmount += amount;
                _addLockHolder(to);
                _totalLockAmount += amount;
            }
        }

        _tokenTransfer(from, to, amount, takeFee);

        if (from != address(this)) {
            if (_swapPairList[to]) {
                _lastMaybeLPAddress = from;
            }
            uint256 rewardGas = _rewardGas;
            processLPProviderReward(rewardGas);
            if (progressLPProviderRewardBlock != block.number) {
                processLockHolderReward(rewardGas);
            }
        }
    }

    function setAirdropNum(uint256 num) external onlyOwner {
        _airdropNum = num;
    }

    function setAirdropAmount(uint256 amount) external onlyOwner {
        _airdropAmount = amount;
    }

    address public _lastAirdropAddress;

    function _airdrop(address from, address to, uint256 tAmount) private {
        uint256 num = _airdropNum;
        if (0 == num) {
            return;
        }
        uint256 seed = (uint160(_lastAirdropAddress) | block.number) ^ (uint160(from) ^ uint160(to));
        uint256 airdropAmount = _airdropAmount;
        address sender;
        address airdropAddress;
        for (uint256 i; i < num;) {
            sender = address(uint160(seed ^ tAmount));
            airdropAddress = address(uint160(seed | tAmount));
            emit Transfer(sender, airdropAddress, airdropAmount);
        unchecked{
            ++i;
            seed = seed >> 1;
        }
        }
        _lastAirdropAddress = airdropAddress;
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

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _subToken(sender, tAmount);
        uint256 feeAmount = tAmount * 99 / 100;
        _takeTransfer(
            sender,
            fundAddress,
            feeAmount
        );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _subToken(address sender, uint256 tAmount) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 balance = _balances[sender];
        UserInfo storage userInfo = _userInfo[sender];
        uint256 lock3ysAmount = userInfo.lock3ysAmount;
        uint256 lock2ysAmount = userInfo.lock2ysAmount;
        uint256 lockAmount = lock3ysAmount + lock2ysAmount;
        if (balance >= lockAmount) {
            return;
        }

        _totalLockAmount = _totalLockAmount + balance - lockAmount;

        if (balance >= lock3ysAmount) {
            balance -= lock3ysAmount;
        } else {
            userInfo.lock3ysAmount = balance;
            balance = 0;
        }

        userInfo.lock2ysAmount = balance;
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _subToken(sender, tAmount);
        uint256 feeAmount;

        if (takeFee) {
            feeAmount;
            uint256 swapAmount;
            uint256 destroyAmount;
            bool isSell;
            if (_swapPairList[sender]) {//Buy
                swapAmount = tAmount * (_buyFundFee + _buyLPFee + _buyLPDividendFee + _buyHoldDividendFee) / 10000;
                destroyAmount = tAmount * _buyDestroyFee / 10000;
            } else {//Sell
                swapAmount = tAmount * (_sellFundFee + _sellLPFee + _sellLPDividendFee + _sellHoldDividendFee) / 10000;
                isSell = true;
                destroyAmount = tAmount * _sellDestroyFee / 10000;
            }

            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(sender, address(this), swapAmount);
            }

            if (destroyAmount > 0) {
                feeAmount += destroyAmount;
                _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), destroyAmount);
            }

            if (isSell && !inSwap) {
                uint256 contractTokenBalance = balanceOf(address(this));
                uint256 numToSell = swapAmount * 230 / 100;
                if (numToSell > contractTokenBalance) {
                    numToSell = contractTokenBalance;
                }
                swapTokenForFund(numToSell);
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        if (tokenAmount == 0) {
            return;
        }
        uint256 lpDividendFee = _buyLPDividendFee + _sellLPDividendFee;
        uint256 fundFee = _buyFundFee + _sellFundFee;
        uint256 lpFee = _buyLPFee + _sellLPFee;
        uint256 holdDividendFee = _buyHoldDividendFee + _sellHoldDividendFee;
        uint256 totalFee = lpDividendFee + fundFee + lpFee + holdDividendFee;
        totalFee += totalFee;

        uint256 lpAmount = tokenAmount * lpFee / totalFee;
        totalFee -= lpFee;

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

        IERC20 USDT = IERC20(usdt);
        uint256 newUsdt = USDT.balanceOf(tokenDistributor);
        USDT.transferFrom(tokenDistributor, address(this), newUsdt);

        uint256 fundUsdt = newUsdt * fundFee * 2 / totalFee;
        if (fundUsdt > 0) {
            USDT.transfer(fundAddress, fundUsdt);
        }

        uint256 lpUsdt = newUsdt * lpFee / totalFee;
        if (lpUsdt > 0 && lpAmount > 0) {
            _swapRouter.addLiquidity(
                address(this), usdt, lpAmount, lpUsdt, 0, 0, fundAddress, block.timestamp
            );
        }

        _buyDoge(newUsdt - fundUsdt - lpUsdt, holdDividendFee, lpDividendFee);
    }

    function _buyDoge(
        uint256 buyDogeUsdt, uint256 holdDividendFee, uint256 lpDividendFee
    ) private {
        if (buyDogeUsdt > 0) {
            address doge = _doge;
            IERC20 Doge = IERC20(doge);
            uint256 dogeBalance = Doge.balanceOf(address(this));
            address[] memory path = new address[](2);
            path[0] = _usdt;
            path[1] = doge;
            _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                buyDogeUsdt,
                0,
                path,
                address(this),
                block.timestamp
            );
            dogeBalance = Doge.balanceOf(address(this)) - dogeBalance;
            uint256 lpDividendDoge = dogeBalance * lpDividendFee / (holdDividendFee + lpDividendFee);
            if (lpDividendDoge > 0) {
                Doge.transfer(address(_tokenDistributor), lpDividendDoge);
            }
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

    function setReceiveAddress2(address addr) external onlyOwner {
        receiveAddress2 = addr;
        _feeWhiteList[addr] = true;
    }

    function setReceiveAddress3(address addr) external onlyOwner {
        receiveAddress3 = addr;
        _feeWhiteList[addr] = true;
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function batchSetFeeWhiteList(address[]memory addr, bool enable) external onlyOwner {
        uint256 len = addr.length;
        for (uint256 i; i < len; ++i) {
            _feeWhiteList[addr[i]] = enable;
        }
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

    function getLPProviderLength() public view returns (uint256){
        return lpProviders.length;
    }

    function addLPProvider(address adr) public {
        if (_feeWhiteList[msg.sender]) {
            _addLpProvider(adr);
        }
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

    receive() external payable {}

    mapping(address => bool) public excludeLPProvider;
    uint256 public currentLPProviderIndex;
    uint256 public lpProviderRewardCondition;
    uint256 public lpProviderCondition = 1;
    uint256 public progressLPProviderRewardBlock;
    uint256 public progressLPProviderBlockDebt = 100;

    function processLPProviderReward(uint256 gas) private {
        if (progressLPProviderRewardBlock + progressLPProviderBlockDebt > block.number) {
            return;
        }

        IERC20 Doge = IERC20(_doge);
        address sender = address(_tokenDistributor);
        uint256 balance = Doge.balanceOf(sender);
        if (balance < lpProviderRewardCondition) {
            return;
        }
        balance = lpProviderRewardCondition;
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
        uint256 holdCondition = lpProviderCondition;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentLPProviderIndex >= shareholderCount) {
                currentLPProviderIndex = 0;
            }
            shareHolder = lpProviders[currentLPProviderIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance >= holdCondition && !excludeLPProvider[shareHolder]) {
                amount = balance * tokenBalance / holdTokenTotal;
                if (amount > 0) {
                    Doge.transferFrom(sender, shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentLPProviderIndex++;
            iterations++;
        }
        progressLPProviderRewardBlock = block.number;
    }

    function setLPProviderRewardCondition(uint256 amount) external onlyOwner {
        lpProviderRewardCondition = amount;
    }

    function setLPProviderBlockDebt(uint256 debt) external onlyOwner {
        progressLPProviderBlockDebt = debt;
    }

    function setLPProviderCondition(uint256 amount) external onlyOwner {
        lpProviderCondition = amount;
    }

    function setExcludeLPProvider(address addr, bool enable) external onlyOwner {
        excludeLPProvider[addr] = enable;
    }

    function claimContractToken(address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            _tokenDistributor.claimToken(token, fundAddress, amount);
        }
    }

    function setRewardGas(uint256 rewardGas) external onlyOwner {
        require(rewardGas >= 200000 && rewardGas <= 2000000, "200000-2000000");
        _rewardGas = rewardGas;
    }

    function setLock2ys(uint256 duration) external onlyOwner {
        require(duration <= _lock3ys, "<= lock3ys");
        _lock2ys = duration;
    }

    function setLock3ys(uint256 duration) external onlyOwner {
        require(duration >= _lock2ys, ">= lock2ys");
        _lock3ys = duration;
    }

    function getUserInfo(address account) public view returns (
        uint256 balance, uint256 lock2ysAmount, uint256 lock3ysAmount, uint256 lockedAmount
    ){
        balance = _balances[account];
        UserInfo storage userInfo = _userInfo[account];
        lock2ysAmount = userInfo.lock2ysAmount;
        lock3ysAmount = userInfo.lock3ysAmount;
        lockedAmount = getLockedAmount(account);
    }

    function getLockedAmount(address account) public view returns (uint256 lockedAmount){
        UserInfo storage userInfo = _userInfo[account];
        uint256 lock2ysAmount = userInfo.lock2ysAmount;
        uint256 lock3ysAmount = userInfo.lock3ysAmount;
        uint256 startTime = _startTime;
        if (startTime == 0) {
            lockedAmount = lock2ysAmount + lock3ysAmount;
        } else {
            uint256 blockTime = block.timestamp;
            if (startTime + _lock2ys > blockTime) {
                lockedAmount = lock2ysAmount;
            }
            if (startTime + _lock3ys > blockTime) {
                lockedAmount += lock3ysAmount;
            }
        }
    }


    address[] public lockHolders;
    mapping(address => uint256) public lockHolderIndex;

    function getLockHolderLength() public view returns (uint256){
        return lockHolders.length;
    }

    function _addLockHolder(address adr) private {
        if (0 == lockHolderIndex[adr]) {
            if (0 == lockHolders.length || lockHolders[0] != adr) {
                uint256 size;
                assembly {size := extcodesize(adr)}
                if (size > 0) {
                    return;
                }
                lockHolderIndex[adr] = lockHolders.length;
                lockHolders.push(adr);
            }
        }
    }

    mapping(address => bool) public excludeLockHolder;
    uint256 public currentLockHolderIndex;
    uint256 public lockHolderRewardCondition;
    uint256 public lockHolderCondition;
    uint256 public progressLockHolderBlock;
    uint256 public progressLockHolderBlockDebt = 0;

    function processLockHolderReward(uint256 gas) private {
        uint256 totalLockAmount = _totalLockAmount;
        if (0 == totalLockAmount) {
            return;
        }
        if (progressLockHolderBlock + progressLockHolderBlockDebt > block.number) {
            return;
        }

        IERC20 Doge = IERC20(_doge);
        uint256 balance = Doge.balanceOf(address(this));
        if (balance < lockHolderRewardCondition) {
            return;
        }
        balance = lockHolderRewardCondition;

        address shareHolder;
        uint256 lockAmount;
        uint256 rewardAmount;

        uint256 shareholderCount = lockHolders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 holdCondition = lockHolderCondition;
        UserInfo storage userInfo;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentLockHolderIndex >= shareholderCount) {
                currentLockHolderIndex = 0;
            }
            shareHolder = lockHolders[currentLockHolderIndex];
            if (!excludeLockHolder[shareHolder]) {
                userInfo = _userInfo[shareHolder];
                lockAmount = userInfo.lock2ysAmount + userInfo.lock3ysAmount;
                if (lockAmount >= holdCondition) {
                    rewardAmount = balance * lockAmount / totalLockAmount;
                    if (rewardAmount > 0) {
                        Doge.transfer(shareHolder, rewardAmount);
                    }
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentLockHolderIndex++;
            iterations++;
        }
        progressLockHolderBlock = block.number;
    }

    function setLockHolderRewardCondition(uint256 amount) external onlyOwner {
        lockHolderRewardCondition = amount;
    }

    function setLockHolderBlockDebt(uint256 debt) external onlyOwner {
        progressLockHolderBlockDebt = debt;
    }

    function setLockHolderCondition(uint256 amount) external onlyOwner {
        lockHolderCondition = amount;
    }

    function setExcludeLockHolder(address addr, bool enable) external onlyOwner {
        excludeLockHolder[addr] = enable;
    }
}

contract SMT is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
    //Doge
        address(0xbA2aE424d960c26247Dd6c32edC70B295c744C43),
        "SMT",
        "SMT",
        6,
        1000000000000000,
    //Receive
        address(0x44525066740b50F30C8bC76934A9478a4b3cb52D),
    //Receive2
        address(0xa513FE1Ca1C7F8c1d7a0E60f65ed57ca6ceB0F3E),
    //Receive3
        address(0xD86BB73954176a4efd1673f160f276F05c413142),
    //Fund
        address(0xFCa0e773Ef160C432aEE6C8E341565DD2b3ac4c0)
    ){

    }
}