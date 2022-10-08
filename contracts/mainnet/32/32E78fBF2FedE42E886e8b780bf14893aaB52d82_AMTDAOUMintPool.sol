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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface ISwapFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IBTCNFT {
    function balanceOf(address owner) external view returns (uint256 balance);
}

interface IInvitorToken {
    function bindInvitor(address account, address invitor) external;

    function _inviter(address account) external view returns (address);

    function getBinderLength(address account) external view returns (uint256);

    function _teamNum(address account) external view returns (uint256);

    function _binders(address account, uint256 index) external view returns (address);

    function _teamAmount(address account) external view returns (uint256);
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

interface IRandom {
    function randomInt(address account) external view returns (uint256);
}

interface IResonancePool {
    function addAmount(address account, uint256 amount) external;
}

interface IMintToken {
    function mint(address account, uint256 amount) external;
}

abstract contract AbsMintPool is Ownable {
    struct UserInfo {
        uint256 amount;
        uint256 lastRewardTime;
        uint256 rewardBalance;
        uint256 claimedReward;
        uint256 inviteReward;
        uint256 claimedInviteReward;
        uint256 teamAmount;
        bool pushActiveBinder;
    }

    struct OtherToken {
        //其他代币合约
        address tokenAddress;
        //USDT的比例
        uint256 usdtRate;
        //销毁代币的比例
        uint256 burnRate;
    }

    ISwapRouter public _swapRouter;
    ISwapFactory public _factory;

    address private _usdtAddress;
    uint256 public _usdtBuybackRate = 4000;
    address public _buybackTokenAddress;
    address public _cashAddress;
    address public _ethReceiver;
    address private _burnTokenAddress;
    OtherToken[] private _otherTokens;

    uint256 public _rewardRate = 6000;
    uint256 public _EUSDRate = 3000;
    address private _rewardToken;
    address private _EUSDAddress;
    address private _ethAddress;

    mapping(address => UserInfo) private _userInfo;
    mapping(address => address[]) public _activeBinder;

    uint256 private _minAmount;
    uint256 private _maxAmount;

    mapping(uint256 => uint256) public _inviteFee;

    uint256 public _dailyDuration = 86400;
    uint256 public _dailyRate = 200;

    uint256[2][] private _multipleRate;

    bool private _pause;

    address[] public _userList;
    mapping(address => uint256) public _userIndex;

    uint256 public _usdtAmountUnit;
    uint256 public _inviteLength = 30;

    uint256 public constant _feeDivFactor = 10000;

    address public _deadAddress = address(0x000000000000000000000000000000000000dEaD);

    address public _randomAddress;
    address  public _invitorToken;
    address public _btcNFTAddress;
    address public _resonancePool;

    uint256 public _totalRewardBalance;
    mapping(uint256 => uint256) public _dailyReward;
    mapping(address => uint256) public _totalBurnAmount;

    constructor(
        address RouteAddress, address RandomAddress,
        address UsdtAddress, address BuybackTokenAddress, address BurnTokenAddress,
        address OtherToken1, address OtherToken2,
        address RewardToken, address EUSDAddress, address ETHAddress,
        address InvitorToken, address BtcNFTAddress, address ResonancePool,
        address CashAddress, address ETHReceiver
    ){
        ISwapRouter swapRouter = ISwapRouter(RouteAddress);
        _swapRouter = swapRouter;
        _factory = ISwapFactory(swapRouter.factory());
        _randomAddress = RandomAddress;
        _usdtAddress = UsdtAddress;
        _buybackTokenAddress = BuybackTokenAddress;
        _burnTokenAddress = BurnTokenAddress;
        _EUSDAddress = EUSDAddress;
        _ethAddress = ETHAddress;

        IERC20(UsdtAddress).approve(address(swapRouter), ~uint256(0));

        uint256 usdtDecimals = 10 ** IERC20(UsdtAddress).decimals();
        _minAmount = 100 * usdtDecimals;
        _maxAmount = 1000 * usdtDecimals;

        _usdtAmountUnit = 100 * usdtDecimals;

        _multipleRate.push([uint256(8), 10]);
        _multipleRate.push([uint256(7), 10]);
        _multipleRate.push([uint256(6), 10]);
        _multipleRate.push([uint256(5), 10]);
        _multipleRate.push([uint256(4), 700]);
        _multipleRate.push([uint256(3), 800]);
        _multipleRate.push([uint256(2), 8460]);

        _inviteFee[0] = 1000;
        _inviteFee[1] = 500;
        _inviteFee[2] = 300;
        _inviteFee[3] = 100;
        for (uint256 i = 4; i < 30;) {
            _inviteFee[i] = 50;
        unchecked{
            ++i;
        }
        }

        _otherTokens.push(OtherToken(
                OtherToken1, 5000, 2000
            )
        );

        _otherTokens.push(OtherToken(
                OtherToken2, 5000, 0
            )
        );

        _rewardToken = RewardToken;
        _invitorToken = InvitorToken;
        _btcNFTAddress = BtcNFTAddress;
        _resonancePool = ResonancePool;
        _cashAddress = CashAddress;
        _ethReceiver = ETHReceiver;
    }

    //maxOtherTokenAmount
    function buy(uint256 index, uint256 amount, uint256 maxBurnAmount, address otherTokenAddress, uint256 maxOtherTokenAmount) external {
        require(!_pause, "Pause");

        amount = amount / _usdtAmountUnit * _usdtAmountUnit;
        require(amount >= _minAmount, "minAmount");
        require(amount <= _maxAmount, "maxAmount");

        address account = msg.sender;
        require(account == tx.origin, "notOrigin");

        UserInfo storage userInfo = _userInfo[account];
        if (userInfo.amount == 0) {
            userInfo.lastRewardTime = block.timestamp;
            _addUser(account);
        }

        IInvitorToken invitorToken = IInvitorToken(_invitorToken);
        address invitor = invitorToken._inviter(account);
        if (!userInfo.pushActiveBinder) {
            if (address(0) != invitor) {
                _activeBinder[invitor].push(account);
                userInfo.pushActiveBinder = true;
            }
        }

        _calInviteReward(account, amount, invitorToken);

        userInfo.amount += amount;
        _takeAmount(account, index, amount, maxBurnAmount, otherTokenAddress, maxOtherTokenAmount);

        uint256 randomInt = IRandom(_randomAddress).randomInt(account);
        uint256 multiple = _randomMultiple(randomInt % 10000);
        uint256 rewardAmount = amount * multiple;
        userInfo.rewardBalance += rewardAmount;

        _totalRewardBalance += rewardAmount;
    }

    function _calInviteReward(address account, uint256 amount, IInvitorToken invitorToken) private {
        uint256 inviteLength = _inviteLength;
        uint256 inviteReward;
        uint256 feeDivFactor = _feeDivFactor;
        UserInfo storage invitorInfo;
        address invitor = invitorToken._inviter(account);
        uint256 activeBinderLength;
        IBTCNFT btcNFT = IBTCNFT(_btcNFTAddress);
        for (uint256 i; i < inviteLength;) {
            if (invitor == address(0)) {
                break;
            }
            activeBinderLength = _activeBinder[invitor].length;
            if (i >= activeBinderLength && i < 10) {
                if (btcNFT.balanceOf(invitor) > 0) {
                    activeBinderLength = 10;
                }
            }
            if (activeBinderLength > i) {
                invitorInfo = _userInfo[invitor];
                if (invitorInfo.amount > 0) {
                    inviteReward = amount * _inviteFee[i] / feeDivFactor;
                    invitorInfo.inviteReward += inviteReward;
                    invitorInfo.teamAmount += amount;
                }
            }
            invitor = invitorToken._inviter(invitor);
        unchecked{
            ++i;
        }
        }
    }

    function _takeAmount(
        address account, uint256 index, uint256 amount, uint256 maxBurnAmount, address otherTokenAddress, uint256 maxOtherTokenAmount
    ) private {
        OtherToken storage otherToken = _otherTokens[index];
        require(otherToken.tokenAddress == otherTokenAddress, "invalid Other");

        uint256 feeDivFactor = _feeDivFactor;
        uint256 usdtAmount = amount * otherToken.usdtRate / feeDivFactor;

        uint256 buybackUsdt = usdtAmount * _usdtBuybackRate / feeDivFactor;
        uint256 cashUsdt = usdtAmount - buybackUsdt;
        _takeToken(_usdtAddress, account, address(this), usdtAmount);
        _giveToken(_usdtAddress, _cashAddress, cashUsdt);

        uint256 burnUsdt = amount * otherToken.burnRate / feeDivFactor;
        if (burnUsdt > 0) {
            uint256 burnTokenAmount = tokenAmountOut(burnUsdt, _burnTokenAddress);
            require(burnTokenAmount <= maxBurnAmount, "gt maxBurnAmount");
            _takeToken(_burnTokenAddress, account, _deadAddress, burnTokenAmount);
            _totalBurnAmount[_burnTokenAddress] += burnTokenAmount;
        }

        uint256 otherTokenAmount = tokenAmountOut(amount - usdtAmount - burnUsdt, otherTokenAddress);
        require(otherTokenAmount <= maxOtherTokenAmount, "gt maxOtherTokenAmount");
        _takeToken(otherTokenAddress, account, _deadAddress, otherTokenAmount);

        address[] memory path = new address[](2);
        path[0] = _usdtAddress;
        path[1] = _buybackTokenAddress;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            buybackUsdt, 0, path, _deadAddress, block.timestamp
        );
    }

    function _randomMultiple(uint256 random) view private returns (uint256){
        uint256 len = _multipleRate.length;
        require(len > 0, "not set multipleRate");
        uint256 rateNum;
        for (uint256 i = 0; i < len;) {
            rateNum += _multipleRate[i][1];
            if (rateNum > random) {
                return _multipleRate[i][0];
            }
        unchecked{
            ++i;
        }
        }
        return 1;
    }

    function claimInviteReward() external {
        address account = msg.sender;
        UserInfo storage userInfo = _userInfo[account];
        uint256 inviteReward = userInfo.inviteReward;
        uint256 claimedInviteReward = userInfo.claimedInviteReward;
        uint256 pendingInviteReward = inviteReward - claimedInviteReward;
        userInfo.claimedInviteReward += pendingInviteReward;
        userInfo.rewardBalance -= pendingInviteReward;
        _claimReward(account, pendingInviteReward);
    }

    function claimReward() external {
        address account = msg.sender;
        uint256 pendingUsdt = _getPendingUsdt(account);
        if (pendingUsdt > 0) {
            UserInfo storage userInfo = _userInfo[account];
            userInfo.rewardBalance -= pendingUsdt;
            userInfo.claimedReward += pendingUsdt;
            uint256 blockTime = block.timestamp;
            require(blockTime >= userInfo.lastRewardTime + _dailyDuration, "notRewardTime");
            userInfo.lastRewardTime = blockTime;
            _claimReward(account, pendingUsdt);
        }
    }

    function _claimReward(address account, uint256 pendingUsdt) private {
    unchecked{
        if (_totalRewardBalance > pendingUsdt) {
            _totalRewardBalance -= pendingUsdt;
        } else {
            _totalRewardBalance = 0;
        }
        _dailyReward[block.timestamp / 86400] += pendingUsdt;
    }
        address rewardToken = _rewardToken;
        uint256 feeDivFactor = _feeDivFactor;
        uint256 rewardUsdt = pendingUsdt * _rewardRate / feeDivFactor;
        uint256 pendingReward = tokenAmountOut(rewardUsdt, rewardToken);
        _giveToken(rewardToken, account, pendingReward);

        uint256 EUSDUsdt = pendingUsdt * _EUSDRate / feeDivFactor;
        IResonancePool(_resonancePool).addAmount(account, EUSDUsdt);
        IMintToken(_EUSDAddress).mint(_resonancePool, EUSDUsdt);

        uint256 pendingETH = tokenAmountOut(pendingUsdt - rewardUsdt - EUSDUsdt, _ethAddress);
        _giveToken(_ethAddress, _ethReceiver, pendingETH);
    }

    function _takeToken(address tokenAddress, address account, address to, uint256 amount) private {
        if (0 == amount) {
            return;
        }
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(account) >= amount, "token not enough");
        token.transferFrom(account, to, amount);
    }

    function _giveToken(address tokenAddress, address account, uint256 amount) private {
        if (0 == amount) {
            return;
        }
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(this)) >= amount, "pool token not enough");
        token.transfer(account, amount);
    }

    function _getPendingUsdt(address account) private view returns (uint256 pendingUsdt){
        UserInfo storage userInfo = _userInfo[account];
        uint256 rewardBalance = userInfo.rewardBalance;
        uint256 timestamp = block.timestamp;
        uint256 lastRewardTime = userInfo.lastRewardTime;
        uint256 rewardDuration;
        uint256 dailyDuration = _dailyDuration;
        if (timestamp > lastRewardTime) {
            rewardDuration = timestamp - lastRewardTime;
            if (rewardDuration > dailyDuration) {
                rewardDuration = dailyDuration;
            }
        }
        return rewardBalance * _dailyRate / _feeDivFactor * rewardDuration / dailyDuration;
    }

    function _addUser(address adr) private {
        if (0 == _userIndex[adr]) {
            if (0 == _userList.length || _userList[0] != adr) {
                _userIndex[adr] = _userList.length;
                _userList.push(adr);
            }
        }
    }

    receive() external payable {}

    function getActiveBinderList(address account, uint256 start, uint256 length) public view returns (
        uint256 returnLen, address[] memory binders, uint256[] memory binderAmounts, uint256[] memory binderCounts
    ){
        uint256 binderLength = _activeBinder[account].length;
        if (0 == length) {
            length = binderLength;
        }
        returnLen = length;

        binders = new address[](length);
        binderAmounts = new uint256[](length);
        binderCounts = new uint256[](length);

        uint256 index = 0;
        for (uint256 i = start; i < start + length; ++i) {
            if (i >= binderLength)
                return (index, binders, binderAmounts, binderCounts);
            address binder = _activeBinder[account][i];
            binders[index] = binder;
            binderAmounts[index] = _userInfo[binder].amount;
            binderCounts[index] = _activeBinder[binder].length;
            ++index;
        }
    }

    function getUserListLength() public view returns (uint256){
        return _userList.length;
    }

    function setBuybackTokenAddress(address buybackTokenAddress) external onlyOwner {
        _buybackTokenAddress = buybackTokenAddress;
    }

    function setUsdtAddress(address usdtAddress) external onlyOwner {
        _usdtAddress = usdtAddress;
        _usdtAmountUnit = 100 * 10 ** IERC20(usdtAddress).decimals();
        IERC20(usdtAddress).approve(address(_swapRouter), ~uint256(0));
    }

    function setBurnTokenAddress(address burnTokenAddress) external onlyOwner {
        _burnTokenAddress = burnTokenAddress;
    }

    function setEUSDAddress(address EUSDAddress) external onlyOwner {
        _EUSDAddress = EUSDAddress;
    }

    function setCashAddress(address cashAddress) external onlyOwner {
        _cashAddress = cashAddress;
    }

    function setEthReceiver(address ethReceiver) external onlyOwner {
        _ethReceiver = ethReceiver;
    }

    function setETHAddress(address ETHAddress) external onlyOwner {
        _ethAddress = ETHAddress;
    }

    function setDeadAddress(address deadAddress) external onlyOwner {
        _deadAddress = deadAddress;
    }

    function setRandomAddress(address randomAddress) external onlyOwner {
        _randomAddress = randomAddress;
    }

    function setBtcNFTAddress(address nftAddress) external onlyOwner {
        _btcNFTAddress = nftAddress;
    }

    function setRewardToken(address rewardToken) external onlyOwner {
        _rewardToken = rewardToken;
    }

    function setResonancePool(address resonancePool) external onlyOwner {
        _resonancePool = resonancePool;
    }

    function setInvitorToken(address invitorToken) external onlyOwner {
        _invitorToken = invitorToken;
    }

    function setLimit(uint256 minAmount, uint256 maxAmount) external onlyOwner {
        _minAmount = minAmount * 10 ** IERC20(_usdtAddress).decimals();
        _maxAmount = maxAmount * 10 ** IERC20(_usdtAddress).decimals();
    }

    function setPause(bool pause) external onlyOwner {
        _pause = pause;
    }

    function setDailyDuration(uint256 duration) external onlyOwner {
        _dailyDuration = duration;
    }

    function setDailyRate(uint256 dailyRate) external onlyOwner {
        _dailyRate = dailyRate;
    }

    function setUsdtBuybackRate(uint256 usdtBuybackRate) external onlyOwner {
        _usdtBuybackRate = usdtBuybackRate;
    }

    function setRewardRate(uint256 rewardRate) external onlyOwner {
        _rewardRate = rewardRate;
    }

    function setEUSDRate(uint256 EUSDRate) external onlyOwner {
        _EUSDRate = EUSDRate;
    }

    function setInviteFee(uint256 level, uint256 fee) external onlyOwner {
        _inviteFee[level] = fee;
    }

    function setMultipleRate(uint256[2][] memory multipleRate) external onlyOwner {
        _multipleRate = multipleRate;
    }

    function setInviteLength(uint256 length) external onlyOwner {
        _inviteLength = length;
    }

    function tokenAmountOut(uint256 usdtAmount, address tokenAddress) public view returns (uint256){
        address usdtAddress = _usdtAddress;
        address lpAddress = _factory.getPair(usdtAddress, tokenAddress);
        uint256 tokenBalance = IERC20(tokenAddress).balanceOf(lpAddress);
        uint256 usdtBalance = IERC20(usdtAddress).balanceOf(lpAddress);
        return usdtAmount * tokenBalance / usdtBalance;
    }

    function getAmountOuts(uint256 usdtAmount) public view returns (
        uint256[] memory usdtOutAmounts, uint256[] memory burnTokenAmounts, uint256[] memory otherTokenAmounts
    ){
        uint256 len = _otherTokens.length;
        usdtOutAmounts = new uint256[](len);
        burnTokenAmounts = new uint256[](len);
        otherTokenAmounts = new uint256[](len);
        OtherToken storage otherToken;
        uint256 usdtOutAmount;
        uint256 burnUsdt;
        uint256 otherUsdt;
        for (uint256 i; i < len; ++i) {
            otherToken = _otherTokens[i];

            usdtOutAmount = usdtAmount * otherToken.usdtRate / _feeDivFactor;
            usdtOutAmounts[i] = usdtOutAmount;

            burnUsdt = usdtAmount * otherToken.burnRate / _feeDivFactor;
            burnTokenAmounts[i] = tokenAmountOut(burnUsdt, _burnTokenAddress);

            otherUsdt = usdtAmount - usdtOutAmount - burnUsdt;
            otherTokenAmounts[i] = tokenAmountOut(otherUsdt, otherToken.tokenAddress);
        }
    }

    function setOtherToken(address[] memory otherTokens, uint256[] memory usdtRates, uint256[] memory burnRates) external onlyOwner {
        delete _otherTokens;
        uint256 len = otherTokens.length;
        for (uint256 i; i < len;) {
            _otherTokens.push(OtherToken(
                    otherTokens[i], usdtRates[i], burnRates[i])
            );
        unchecked{
            ++i;
        }
        }
    }

    function addOtherToken(address otherToken, uint256 usdtRate, uint256 burnRate) external onlyOwner {
        _otherTokens.push(OtherToken(
                otherToken, usdtRate, burnRate
            )
        );
    }

    function claimBalance(uint256 amount, address to) external onlyOwner {
        payable(to).transfer(amount);
    }

    function claimToken(address token, uint256 amount, address to) external onlyOwner {
        IERC20(token).transfer(to, amount);
    }

    function getPoolInfo() external view returns (
        address usdtAddress, uint256 usdtDecimals, string memory usdtSymbol,
        address burnTokenAddress, uint256 burnTokenDecimals, string memory burnTokenSymbol,
        uint256 minAmount, uint256 maxAmount, bool pause, uint256 totalBurnAmount
    ){
        usdtAddress = _usdtAddress;
        usdtDecimals = IERC20(usdtAddress).decimals();
        usdtSymbol = IERC20(usdtAddress).symbol();
        burnTokenAddress = _burnTokenAddress;
        burnTokenDecimals = IERC20(burnTokenAddress).decimals();
        burnTokenSymbol = IERC20(burnTokenAddress).symbol();
        minAmount = _minAmount;
        maxAmount = _maxAmount;
        pause = _pause;
        totalBurnAmount = _totalBurnAmount[burnTokenAddress];
    }

    function getRewardTokenInfo() external view returns (
        address rewardTokenAddress, uint256 rewardTokenDecimals, string memory rewardTokenSymbol,
        address EUSDAddress, uint256 EUSDDecimals, string memory EUSDSymbol,
        address ETHAddress, uint256 ETHDecimals, string memory ETHSymbol
    ){
        rewardTokenAddress = _rewardToken;
        rewardTokenDecimals = IERC20(rewardTokenAddress).decimals();
        rewardTokenSymbol = IERC20(rewardTokenAddress).symbol();
        EUSDAddress = _EUSDAddress;
        EUSDDecimals = IERC20(EUSDAddress).decimals();
        EUSDSymbol = IERC20(EUSDAddress).symbol();
        ETHAddress = _ethAddress;
        ETHDecimals = IERC20(ETHAddress).decimals();
        ETHSymbol = IERC20(ETHAddress).symbol();
    }

    function getOtherTokens() external view returns (
        address[] memory tokenAddress, uint256[] memory tokenDecimals, string[] memory tokenSymbol
    ){
        uint256 len = _otherTokens.length;
        tokenAddress = new address[](len);
        tokenDecimals = new uint256[](len);
        tokenSymbol = new string[](len);
        OtherToken storage otherToken;
        for (uint256 i; i < len; ++i) {
            otherToken = _otherTokens[i];
            tokenAddress[i] = otherToken.tokenAddress;
            tokenDecimals[i] = IERC20(tokenAddress[i]).decimals();
            tokenSymbol[i] = IERC20(tokenAddress[i]).symbol();
        }
    }

    function getMultipleRate() external view returns (uint256[2][] memory multipleRate){
        multipleRate = _multipleRate;
    }

    function getUserInfo(address account) external view returns (
        uint256 amount,
        uint256 rewardBalance,
        uint256 claimedReward,
        uint256 inviteReward,
        uint256 claimedInviteReward,
        uint256 teamAmount,
        uint256 activeBinderLength,
        uint256 level,
        bool pushActiveBinder
    ){
        UserInfo storage userInfo = _userInfo[account];
        amount = userInfo.amount;
        rewardBalance = userInfo.rewardBalance;
        claimedReward = userInfo.claimedReward;
        inviteReward = userInfo.inviteReward;
        claimedInviteReward = userInfo.claimedInviteReward;
        teamAmount = userInfo.teamAmount;
        activeBinderLength = _activeBinder[account].length;
        level = activeBinderLength;
        if (level > _inviteLength) {
            level = _inviteLength;
        }
        if (level < 10) {
            if (IBTCNFT(_btcNFTAddress).balanceOf(account) > 0) {
                level = 10;
            }
        }
        pushActiveBinder = userInfo.pushActiveBinder;
    }

    function getUserExtInfo(address account) external view returns (
        uint256 lastRewardTime, uint256 nextClaimCountdown, uint256 pendingReward,
        uint256 usdtBalance, uint256 usdtAllowance,
        uint256 burnTokenBalance, uint256 burnTokenAllowance,
        uint256[] memory otherTokenBalances
    ){
        UserInfo storage userInfo = _userInfo[account];
        lastRewardTime = userInfo.lastRewardTime;
        uint256 claimTime = lastRewardTime + _dailyDuration;
        uint256 blockTime = block.timestamp;
        if (claimTime > blockTime) {
            nextClaimCountdown = claimTime - blockTime;
        }
        pendingReward = _getPendingUsdt(account);
        usdtBalance = IERC20(_usdtAddress).balanceOf(account);
        usdtAllowance = IERC20(_usdtAddress).allowance(account, address(this));
        burnTokenBalance = IERC20(_burnTokenAddress).balanceOf(account);
        burnTokenAllowance = IERC20(_burnTokenAddress).allowance(account, address(this));
        uint256 len = _otherTokens.length;
        otherTokenBalances = new uint256[](len);
        for (uint256 i; i < len; ++i) {
            otherTokenBalances[i] = IERC20(_otherTokens[i].tokenAddress).balanceOf(account);
        }
    }
}

contract AMTDAOUMintPool is AbsMintPool {
    constructor() AbsMintPool(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //RandomAddress
        address(0x1Ac50AeA37ef499a8024572893c25B31B9778214),
    //UsdtAddress
        address(0x55d398326f99059fF775485246999027B3197955),
    //BuybackTokenAddress
        address(0x75f93F70f4Eeaf2De2dF3b9e27236b1623f1DbCd),
    //BurnTokenAddress
        address(0x75f93F70f4Eeaf2De2dF3b9e27236b1623f1DbCd),
    //OtherToken1
        address(0x71203107aE3D34cC2aca910Cd3D78418FC16DB4b),
    //OtherToken2
        address(0x2655F820f36485D747C48B2f0Eb88045be002A9f),
    //RewardToken
        address(0x75f93F70f4Eeaf2De2dF3b9e27236b1623f1DbCd),
    //EUSD
        address(0x5Af900C177153d84fB84ddc6C5978F3112c7662F),
    //ETHAddress
        address(0x2170Ed0880ac9A755fd29B2688956BD959F933F8),
    //InvitorToken
        address(0x71203107aE3D34cC2aca910Cd3D78418FC16DB4b),
    //NFTAddress
        address(0x6477F5D55E8cd3a9a2d85DccF6B3aB09AAc47547),
    //ResonancePool
        address(0x1C665974b1CA2b195b8acA58077Da97F02F913dD),
    //CashAddress
        address(0x3Fa5FC8f37D18883fA3b2Bbf85b2Cd7e2744D890),
    //ETHReceiver
        address(0x10a9c7A4424E25Ff52474173C26055c60c9E5bd3)
    ){

    }
}