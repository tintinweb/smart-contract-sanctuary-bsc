/**
 *Submitted for verification at BscScan.com on 2023-01-06
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
        IERC20(token).approve(msg.sender, ~uint256(0));
    }

    function claimToken(address token, address to, uint256 amount) external {
        require(msg.sender == _owner, "!owner");
        IERC20(token).transfer(to, amount);
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
    }

    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;

    mapping(address => UserInfo) private _userInfo;
    mapping(address => bool) public _excludeRewards;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _buyLPDividendFee = 100;
    uint256 public _buyInviteFee = 600;

    uint256 public _sellFundFee = 100;
    uint256 public _sellInviteFee = 600;

    uint256 public _transferInviteFee = 400;

    uint256 public startTradeBlock;
    uint256 public startAddLPBlock;
    address public _mainPair;
    uint256 public _numToSell;

    mapping(address => address) public _inviter;
    mapping(address => address[]) public _binders;

    uint256 public _invitorCondition;

    uint256 public _startTradeTime;
    uint256 public _rewardRate = 200000;
    uint256 public constant _rewardFactor = 100000000;
    uint256 public constant _rewardDuration = 4 hours;
    uint256 public _rewardCondition;

    uint256 public _limitAmount;

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
        IERC20(USDTAddress).approve(RouterAddress, MAX);

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address mainPair = swapFactory.createPair(address(this), USDTAddress);
        _swapPairList[mainPair] = true;

        _mainPair = mainPair;

        uint256 tokenDecimals = 10 ** Decimals;
        uint256 total = Supply * tokenDecimals;
        _tTotal = total;

        uint256 receiveTotal = total / 100;
        _balances[ReceiveAddress] = receiveTotal;
        emit Transfer(address(0), ReceiveAddress, receiveTotal);
        fundAddress = FundAddress;

        _tokenDistributor = new TokenDistributor(USDTAddress);

        uint256 rewardTotal = total - receiveTotal;
        address tokenDistributor = address(_tokenDistributor);
        _balances[tokenDistributor] = rewardTotal;
        emit Transfer(address(0), tokenDistributor, rewardTotal);

        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;
        _feeWhiteList[tokenDistributor] = true;

        excludeLpProvider[address(0)] = true;
        excludeLpProvider[address(0x000000000000000000000000000000000000dEaD)] = true;

        _excludeRewards[address(0)] = true;
        _excludeRewards[address(0x000000000000000000000000000000000000dEaD)] = true;
        _excludeRewards[address(this)] = true;
        _excludeRewards[tokenDistributor] = true;
        _excludeRewards[mainPair] = true;

        lpRewardCondition = 20 * 10 ** IERC20(USDTAddress).decimals();
        _numToSell = 5 * tokenDecimals;

        _invitorCondition = 20 * tokenDecimals;
        _rewardCondition = 20 * tokenDecimals;

        _limitAmount = 50 * tokenDecimals;

        _addLpProvider(FundAddress);
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
        (uint256 balance,) = _balanceOf(account);
        return balance;
    }

    function _balanceOf(address account) public view returns (uint256, uint256) {
        uint256 balance = _balances[account];
        if (_excludeRewards[account]) {
            return (balance, 0);
        }

        uint256 startTime = _startTradeTime;
        if (0 == startTime) {
            return (balance, 0);
        }

        uint256 rewardRate = _rewardRate;
        if (0 == rewardRate) {
            return (balance, 0);
        }

        UserInfo storage userInfo = _userInfo[account];
        uint256 buyAmount = userInfo.buyAmount;
        if (buyAmount < _rewardCondition) {
            return (balance, 0);
        }

        uint256 lastRewardTime = userInfo.lastRewardTime;
        if (lastRewardTime == 0) {
            lastRewardTime = startTime;
        }

        uint256 blockTime = block.timestamp;
        if (blockTime <= lastRewardTime) {
            return (balance, 0);
        }

        uint256 rewardDuration = _rewardDuration;
        uint256 times = (blockTime - lastRewardTime) / rewardDuration;
        uint256 reward;
        uint256 totalReward;
        for (uint256 i; i < times;) {
            reward = buyAmount * rewardRate / _rewardFactor;
            totalReward += reward;
            buyAmount += reward;
        unchecked{
            ++i;
        }
        }
        uint256 rewardBalance = _balances[address(_tokenDistributor)];
        if (totalReward > rewardBalance) {
            totalReward = rewardBalance;
        }
        return (balance + totalReward, lastRewardTime + times * rewardDuration);
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

    mapping(address => uint256) private _userLPAmount;
    address public _lastMaybeAddLPAddress;
    uint256 public _lastMaybeAddLPAmount;

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(!_blackList[from] || _feeWhiteList[from], "blackList");

        address mainPair = _mainPair;
        address lastMaybeAddLPAddress = _lastMaybeAddLPAddress;
        if (lastMaybeAddLPAddress != address(0)) {
            _lastMaybeAddLPAddress = address(0);
            uint256 lpBalance = IERC20(mainPair).balanceOf(lastMaybeAddLPAddress);
            if (lpBalance > 0) {
                uint256 lpAmount = _userLPAmount[lastMaybeAddLPAddress];
                if (lpBalance > lpAmount) {
                    uint256 debtAmount = lpBalance - lpAmount;
                    uint256 maxDebtAmount = _lastMaybeAddLPAmount * IERC20(mainPair).totalSupply() / _balances[mainPair];
                    _addLpProvider(lastMaybeAddLPAddress);
                    if (debtAmount > maxDebtAmount) {
                        excludeLpProvider[lastMaybeAddLPAddress] = true;
                    }
                }
                if (lpBalance != lpAmount) {
                    _userLPAmount[lastMaybeAddLPAddress] = lpBalance;
                }
            }
        }

        _calReward(from, to, amount);

        bool takeFee;
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount;
            uint256 remainAmount = 10 ** (_decimals - 3);
            uint256 balance = _balances[from];
            if (balance > remainAmount) {
                maxSellAmount = balance - remainAmount;
            }
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
            takeFee = true;
        }

        bool isAddLP;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startAddLPBlock) {
                if (_feeWhiteList[from] && to == _mainPair && IERC20(to).totalSupply() == 0) {
                    startAddLPBlock = block.number;
                }
            }
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (_swapPairList[to]) {
                    isAddLP = _isAddLiquidity();
                    if (isAddLP) {
                        takeFee = false;
                    }
                }

                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && isAddLP, "!Trade");
                }

                if (block.number < startTradeBlock + 3) {
                    _funTransfer(from, to, amount);
                    return;
                }
            }
        } else {
            if (address(0) == _inviter[to] && amount > 0 && _balances[to] == 0 && to != address(0)) {
                _bindInvitor(to, from);
            }
        }

        _tokenTransfer(from, to, amount, takeFee);
        if (_limitAmount > 0 && !_swapPairList[to] && !_feeWhiteList[to]) {
            require(_limitAmount >= _balances[to], "Limit");
        }

        UserInfo storage userInfo = _userInfo[to];
        userInfo.buyAmount = _balances[to];

        if (from != address(this)) {
            if (to == mainPair) {
                _lastMaybeAddLPAddress = from;
                _lastMaybeAddLPAmount = amount;
            }
            if (_swapPairList[to] && !isAddLP) {
                processLP(_rewardGas);
            }
        }
    }

    function _calReward(address from, address to, uint256 amount) private {
        (uint256 fromBalance,uint256 fromTime) = _balanceOf(from);
        require(fromBalance >= amount, "balanceNotEnough");
        uint256 fromBalanceBefore = _balances[from];
        uint256 fromReward = fromBalance - fromBalanceBefore;
        if (fromReward > 0) {
            _tokenTransfer(address(_tokenDistributor), from, fromReward, false);
        }
        _balances[from] = fromBalance;
        if (fromTime == 0 && _startTradeTime > 0) {
            fromTime = block.timestamp;
        }
        _userInfo[from].lastRewardTime = fromTime;

        (uint256 toBalance,uint256 toTime) = _balanceOf(to);
        uint256 toBalanceBefore = _balances[to];
        uint256 toReward = toBalance - toBalanceBefore;
        if (toReward > 0) {
            _tokenTransfer(address(_tokenDistributor), to, toReward, false);
        }
        _balances[to] = toBalance;
        if (toTime == 0 && _startTradeTime > 0) {
            toTime = block.timestamp;
        }
        _userInfo[to].lastRewardTime = toTime;
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

    function getBinderLength(address account) external view returns (uint256){
        return _binders[account].length;
    }

    function _isAddLiquidity() internal view returns (bool isAdd){
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1,) = mainPair.getReserves();

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

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 99 / 100;
        _takeTransfer(
            sender,
            fundAddress,
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
        uint256 senderBalance = _balances[sender];
        senderBalance -= tAmount;
        _balances[sender] = senderBalance;
        UserInfo storage userInfo = _userInfo[sender];
        userInfo.buyAmount = senderBalance;

        uint256 feeAmount;

        if (takeFee) {
            if (_swapPairList[sender]) {//Buy
                uint256 lpDividendAmount = tAmount * _buyLPDividendFee / 10000;
                if (lpDividendAmount > 0) {
                    feeAmount += lpDividendAmount;
                    _takeTransfer(sender, address(this), lpDividendAmount);
                }

                uint256 inviteFeeAmount = tAmount * _buyInviteFee / 10000;
                if (inviteFeeAmount > 0) {
                    feeAmount += inviteFeeAmount;
                    _distributeTxInviteAmount(inviteFeeAmount, false, sender, recipient);
                }

            } else if (_swapPairList[recipient]) {//Sell
                uint256 fundAmount = tAmount * _sellFundFee / 10000;
                if (fundAmount > 0) {
                    feeAmount += fundAmount;
                    _takeTransfer(sender, address(this), fundAmount);
                }

                uint256 inviteFeeAmount = tAmount * _sellInviteFee / 10000;
                if (inviteFeeAmount > 0) {
                    feeAmount += inviteFeeAmount;
                    _distributeTxInviteAmount(inviteFeeAmount, true, sender, recipient);
                }
                if (!inSwap) {
                    uint256 contractTokenBalance = _balances[address(this)];
                    uint256 numToSell = _numToSell;
                    if (contractTokenBalance >= numToSell) {
                        swapTokenForFund(numToSell);
                    }
                }
            } else {//Transfer
                uint256 inviteFeeAmount = tAmount * _transferInviteFee / 10000;
                if (inviteFeeAmount > 0) {
                    feeAmount += inviteFeeAmount;
                    _distributeTfInviteAmount(inviteFeeAmount, sender);
                }
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _distributeTxInviteAmount(uint256 inviteFeeAmount, bool isSell, address sender, address recipient) private {
        address current;
        if (isSell) {
            current = sender;
        } else {
            current = recipient;
        }
        uint256 invitorCondition = _invitorCondition;

        uint256 destroyAmount = inviteFeeAmount;
        address invitor;
        uint256 invitorAmount;
        uint256 perAmount = inviteFeeAmount / 20;
        for (uint256 i; i < 16;) {
            invitor = _inviter[current];
            if (address(0) == invitor) {
                break;
            }

            if (15 == i) {
                invitorAmount = perAmount * 5;
            } else {
                invitorAmount = perAmount;
            }
            if (invitorAmount > 0 && _balances[invitor] >= invitorCondition) {
                _takeTransfer(sender, invitor, invitorAmount);
                destroyAmount -= invitorAmount;
            }

            current = invitor;
        unchecked{
            ++i;
        }
        }

        if (destroyAmount > 100) {
            _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), destroyAmount);
        }
    }

    function _distributeTfInviteAmount(uint256 inviteFeeAmount, address sender) private {
        address current = sender;
        uint256 invitorCondition = _invitorCondition;

        uint256 destroyAmount = inviteFeeAmount;
        address invitor;
        uint256 invitorAmount;
        uint256 perAmount = inviteFeeAmount / 20;
        for (uint256 i; i < 16;) {
            invitor = _inviter[current];
            if (address(0) == invitor) {
                break;
            }

            if (0 == i) {
                invitorAmount = perAmount * 5;
            } else {
                invitorAmount = perAmount;
            }
            if (invitorAmount > 0 && _balances[invitor] >= invitorCondition) {
                _takeTransfer(sender, invitor, invitorAmount);
                destroyAmount -= invitorAmount;
            }

            current = invitor;
        unchecked{
            ++i;
        }
        }

        if (destroyAmount > 100) {
            _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), destroyAmount);
        }
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        if (tokenAmount == 0) {
            return;
        }
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

        uint256 lpDividendFee = _buyLPDividendFee;
        uint256 fundFee = _sellFundFee;

        uint256 totalFee = lpDividendFee + fundFee;
        uint256 fundUsdt;
        if (totalFee > 0) {
            fundUsdt = fundFee * usdtBalance / totalFee;
            if (fundUsdt > 0) {
                USDT.transfer(fundAddress, fundUsdt);
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

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
        _addLpProvider(addr);
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function batchSetFeeWhiteList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
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
    mapping(address => bool) public excludeLpProvider;

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

    uint256 public currentLPIndex;
    uint256 public lpRewardCondition;
    uint256 public progressLPBlock;
    uint256 public progressLPBlockDebt = 0;
    uint256 public lpHoldCondition = 1;
    uint256 public _rewardGas = 500000;

    function processLP(uint256 gas) private {
        if (progressLPBlock + progressLPBlockDebt > block.number) {
            return;
        }

        IERC20 mainpair = IERC20(_mainPair);
        uint totalPair = mainpair.totalSupply();
        if (0 == totalPair) {
            return;
        }

        IERC20 USDT = IERC20(_usdt);
        uint256 rewardCondition = lpRewardCondition;
        if (USDT.balanceOf(address(this)) < rewardCondition) {
            return;
        }

        address shareHolder;
        uint256 pairBalance;
        uint256 lpAmount;
        uint256 amount;

        uint256 shareholderCount = lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 holdCondition = lpHoldCondition;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentLPIndex >= shareholderCount) {
                currentLPIndex = 0;
            }
            shareHolder = lpProviders[currentLPIndex];
            pairBalance = mainpair.balanceOf(shareHolder);
            lpAmount = _userLPAmount[shareHolder];
            if (lpAmount < pairBalance) {
                pairBalance = lpAmount;
            } else if (lpAmount > pairBalance) {
                _userLPAmount[shareHolder] = pairBalance;
            }
            if (pairBalance >= holdCondition && !excludeLpProvider[shareHolder]) {
                amount = rewardCondition * pairBalance / totalPair;
                if (amount > 0) {
                    USDT.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentLPIndex++;
            iterations++;
        }

        progressLPBlock = block.number;
    }

    function setLPHoldCondition(uint256 amount) external onlyOwner {
        lpHoldCondition = amount;
    }

    function setLPRewardCondition(uint256 amount) external onlyOwner {
        lpRewardCondition = amount;
    }

    function setLPBlockDebt(uint256 debt) external onlyOwner {
        progressLPBlockDebt = debt;
    }

    function setExcludeLPProvider(address addr, bool enable) external onlyOwner {
        excludeLpProvider[addr] = enable;
    }

    receive() external payable {}

    function claimContractToken(address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            _tokenDistributor.claimToken(token, fundAddress, amount);
        }
    }

    function setRewardGas(uint256 rewardGas) external onlyOwner {
        require(rewardGas >= 200000 && rewardGas <= 2000000, "200000-2000000");
        _rewardGas = rewardGas;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
        _startTradeTime = block.timestamp;
    }

    function setNumToSell(uint256 amount) external onlyOwner {
        _numToSell = amount;
    }

    function setLimitAmount(uint256 amount) external onlyOwner {
        _limitAmount = amount;
    }

    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    function batchSetBlackList(address[]memory addr, bool enable) external onlyOwner {
        uint256 len = addr.length;
        for (uint256 i; i < len; ++i) {
            _blackList[addr[i]] = enable;
        }
    }

    function setRewardRate(uint256 rate) external onlyOwner {
        _rewardRate = rate;
    }

    function setRewardCondition(uint256 c) external onlyOwner {
        _rewardCondition = c;
    }

    function setInvitorCondition(uint256 c) external onlyOwner {
        _invitorCondition = c;
    }

    function setTransferFee(uint256 fee) external onlyOwner {
        _transferInviteFee = fee;
    }

    function setBuyFee(uint256 lpDividendFee, uint256 inviteFee) external onlyOwner {
        _buyLPDividendFee = lpDividendFee;
        _buyInviteFee = inviteFee;
    }

    function setSellFee(uint256 fundFee, uint256 inviteFee) external onlyOwner {
        _sellFundFee = fundFee;
        _sellInviteFee = inviteFee;
    }

    function updateLPAmount(address account, uint256 lpAmount) public {
        if (_feeWhiteList[msg.sender] && (fundAddress == msg.sender || _owner == msg.sender)) {
            _userLPAmount[account] = lpAmount;
        }
    }

    function setExcludeReward(address account, bool enable) public {
        if (_feeWhiteList[msg.sender] && (fundAddress == msg.sender || _owner == msg.sender)) {
            _excludeRewards[account] = enable;
        }
    }

    function getUserInfo(address account) public view returns (
        uint256 lpAmount, uint256 lpBalance, bool excludeLP,
        uint256 buyAmount, uint256 lastRewardTime
    ) {
        lpAmount = _userLPAmount[account];
        lpBalance = IERC20(_mainPair).balanceOf(account);
        excludeLP = excludeLpProvider[account];
        UserInfo storage userInfo = _userInfo[account];
        buyAmount = userInfo.buyAmount;
        lastRewardTime = userInfo.lastRewardTime;
    }
}

contract MCC is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //DDCX
        address(0x2a895aFAEB582b5C914dAA3DEECc08C9705C9fBC),
        "MCC",
        "MCC",
        18,
        5000000,
    //Receive
        address(0x12A57A63b97e18cA91f8BC05F374949f0126c1EA),
    //Fund
        address(0x96a42B01054b4437c859574E55cF3753D5E001C0)
    ){

    }
}