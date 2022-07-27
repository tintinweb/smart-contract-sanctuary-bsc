/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

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
}

interface ISwapFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface ISwapPair {
    function sync() external;
}

interface IRandom {
    function randomInt(address account) external view returns (uint256);
}

interface INFT {
    function batchMint(address to, uint256 property, uint256 num) external;
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

abstract contract AbsMintPool is Ownable {
    struct UserInfo {
        uint256 amount;
        uint256 lastRewardTime;
        uint256 rewardBalance;
        uint256 claimedReward;
        uint256 inviteReward;
        uint256 claimedInviteReward;
        uint256 teamAmount;
    }

    ISwapFactory public _factory;
    address private _usdtAddress;
    address public _buybackLPAddress;

    mapping(address => UserInfo) private _userInfo;

    mapping(address => address) public _invitor;
    mapping(address => address[]) public _binder;
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
    address public _defaultInvitor = address(0xd1B5932707AddC2C12c18a843195Fe4FE7aC823e);
    uint256 public _usdtRate = 2000;

    address[] private _otherToken;
    mapping(address => bool) public _isOtherToken;
    address[] private _rewardToken;
    mapping(address => bool) public _isRewardToken;
    address private _inviteRewardToken;
    address public _deadAddress = address(0x000000000000000000000000000000000000dEaD);
    mapping(uint256 => mapping(address => uint256)) public _teamNum;
    address public _randomAddress;
    address public _nftAddress;

    constructor(
        address RouteAddress, address RandomAddress,
        address UsdtAddress, address BuybackTokenAddress,
        address OtherToken1, address OtherToken2,
        address RewardToken1, address RewardToken2,
        address InviteRewardToken, address NFTAddress
    ){
        _factory = ISwapFactory(ISwapRouter(RouteAddress).factory());
        _randomAddress = RandomAddress;
        _usdtAddress = UsdtAddress;
        _buybackLPAddress = _factory.getPair(UsdtAddress, BuybackTokenAddress);
        require(address(0) != _buybackLPAddress, "notBuybackLPAddress");

        uint256 usdtDecimals = 10 ** IERC20(UsdtAddress).decimals();
        _minAmount = 200 * usdtDecimals;
        _maxAmount = 1000 * usdtDecimals;

        _usdtAmountUnit = 100 * usdtDecimals;

        _multipleRate.push([uint256(8), 200]);
        _multipleRate.push([uint256(7), 300]);
        _multipleRate.push([uint256(6), 400]);
        _multipleRate.push([uint256(5), 600]);
        _multipleRate.push([uint256(4), 700]);
        _multipleRate.push([uint256(3), 800]);
        _multipleRate.push([uint256(2), 7000]);

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

        _otherToken.push(OtherToken1);
        _isOtherToken[OtherToken1] = true;
        _otherToken.push(OtherToken2);
        _isOtherToken[OtherToken2] = true;

        _rewardToken.push(RewardToken1);
        _isRewardToken[RewardToken1] = true;
        _rewardToken.push(RewardToken2);
        _isRewardToken[RewardToken2] = true;

        _inviteRewardToken = InviteRewardToken;
        _nftAddress = NFTAddress;
    }

    function bindInvitor(address invitor) external {
        address account = msg.sender;
        require(address(0) == _invitor[account], "Bind");
        UserInfo storage invitorInfo = _userInfo[invitor];
        require(invitor != account, "inviteSelf");
        require(_defaultInvitor != account, "defaultInvitor");
        require(_userInfo[account].amount == 0, "invalid account");
        require(invitor == _defaultInvitor || invitorInfo.amount > 0, "invalid invitor");
        _invitor[account] = invitor;
        _binder[invitor].push(account);
    }

    //maxOtherTokenAmount
    function buy(uint256 amount, address otherTokenAddress, uint256 maxOtherTokenAmount) external {
        require(!_pause, "Pause");

        amount = amount / _usdtAmountUnit * _usdtAmountUnit;
        require(amount >= _minAmount, "minAmount");
        require(amount <= _maxAmount, "maxAmount");

        address account = msg.sender;
        require(account == tx.origin, "notOrigin");
        address invitor = _invitor[account];
        require(address(0) != invitor || account == _defaultInvitor, "notBind");

        UserInfo storage userInfo = _userInfo[account];
        uint256 inviteLength = _inviteLength;
        if (userInfo.amount == 0) {
            userInfo.lastRewardTime = block.timestamp;
            _activeBinder[invitor].push(account);
            _addUser(account);
            for (uint256 i; i < inviteLength;) {
                if (address(0) == invitor) {
                    break;
                }
                _teamNum[i][invitor] += 1;
                invitor = _invitor[invitor];
            unchecked{
                ++i;
            }
            }
        }

        uint256 inviteReward;
        uint256 feeDivFactor = _feeDivFactor;
        UserInfo storage invitorInfo;
        invitor = _invitor[account];
        uint256 activeBinderLength;
        for (uint256 i; i < inviteLength;) {
            activeBinderLength = _activeBinder[invitor].length;
            if (activeBinderLength > i) {
                invitorInfo = _userInfo[invitor];
                inviteReward = amount * _inviteFee[i] / feeDivFactor;
                invitorInfo.inviteReward += inviteReward;
                invitorInfo.teamAmount += amount;
            }
            invitor = _invitor[invitor];
        unchecked{
            ++i;
        }
        }

        userInfo.amount += amount;
        _takeAmount(account, amount, otherTokenAddress, maxOtherTokenAmount);

        uint256 randomInt = IRandom(_randomAddress).randomInt(account);
        uint256 multiple = _randomMultiple(randomInt % 10000);
        uint256 rewardAmount = amount * multiple;
        userInfo.rewardBalance += rewardAmount;
        INFT(_nftAddress).batchMint(account, multiple, 1);
    }

    function _takeAmount(address account, uint256 amount, address otherTokenAddress, uint256 maxOtherTokenAmount) private {
        require(_isOtherToken[otherTokenAddress], "notOtherToken");
        uint256 usdtAmount = amount * _usdtRate / _feeDivFactor;
        address lpAddress = _buybackLPAddress;
        _takeToken(_usdtAddress, account, lpAddress, usdtAmount);
        ISwapPair(lpAddress).sync();
        uint256 otherTokenAmount = tokenAmountOut(amount - usdtAmount, otherTokenAddress);
        require(otherTokenAmount <= maxOtherTokenAmount, "gt maxOtherTokenAmount");
        _takeToken(otherTokenAddress, account, _deadAddress, otherTokenAmount);
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
        uint256 pendingInviteTokenAmount = tokenAmountOut(pendingInviteReward, _inviteRewardToken);
        _giveToken(_inviteRewardToken, account, pendingInviteTokenAmount);
    }

    function claimReward(address rewardToken) external {
        require(_isRewardToken[rewardToken], "notRewardToken");
        address account = msg.sender;
        uint256 pendingUsdt = _getPendingUsdt(account);
        if (pendingUsdt > 0) {
            UserInfo storage userInfo = _userInfo[account];
            userInfo.rewardBalance -= pendingUsdt;
            userInfo.claimedReward += pendingUsdt;
            uint256 pendingReward = tokenAmountOut(pendingUsdt, rewardToken);
            uint256 blockTime = block.timestamp;
            require(blockTime >= userInfo.lastRewardTime + _dailyDuration, "notRewardTime");
            userInfo.lastRewardTime = blockTime;
            _giveToken(rewardToken, account, pendingReward);
        }
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

    function getBinderLength(address account) public view returns (uint256){
        return _binder[account].length;
    }

    function setBuybackTokenAddress(address buybackTokenAddress) external onlyOwner {
        _buybackLPAddress = _factory.getPair(_usdtAddress, buybackTokenAddress);
        require(address(0) != _buybackLPAddress, "notBuybackLPAddress");
    }

    function setUsdtAddress(address usdtAddress) external onlyOwner {
        _usdtAddress = usdtAddress;
        _usdtAmountUnit = 100 * 10 ** IERC20(usdtAddress).decimals();
    }

    function setDeadAddress(address deadAddress) external onlyOwner {
        _deadAddress = deadAddress;
    }

    function setRandomAddress(address randomAddress) external onlyOwner {
        _randomAddress = randomAddress;
    }

    function setNftAddress(address nftAddress) external onlyOwner {
        _nftAddress = nftAddress;
    }

    function setInviteRewardToken(address inviteRewardToken) external onlyOwner {
        _inviteRewardToken = inviteRewardToken;
    }

    function setDefaultInvitor(address defaultInvitor) external onlyOwner {
        _defaultInvitor = defaultInvitor;
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

    function setUsdtRate(uint256 usdtRate) external onlyOwner {
        _usdtRate = usdtRate;
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

    function getAmountOuts(uint256 usdtAmount, address tokenAddress) public view returns (uint256 usdtOutAmount, uint256 tokenOutAmount){
        usdtOutAmount = usdtAmount * _usdtRate / _feeDivFactor;
        tokenOutAmount = tokenAmountOut(usdtAmount - usdtOutAmount, tokenAddress);
    }

    function setOtherToken(address[] memory otherTokens) external onlyOwner {
        uint256 len = _otherToken.length;
        for (uint256 i; i < len;) {
            _isOtherToken[_otherToken[i]] = false;
        unchecked{
            ++i;
        }
        }
        _otherToken = otherTokens;
        len = otherTokens.length;
        for (uint256 i; i < len;) {
            _isOtherToken[otherTokens[i]] = true;
        unchecked{
            ++i;
        }
        }
    }

    function setRewardToken(address[] memory rewardTokens) external onlyOwner {
        uint256 len = _rewardToken.length;
        for (uint256 i; i < len;) {
            _isRewardToken[_rewardToken[i]] = false;
        unchecked{
            ++i;
        }
        }
        _rewardToken = rewardTokens;
        len = rewardTokens.length;
        for (uint256 i; i < len;) {
            _isRewardToken[rewardTokens[i]] = true;
        unchecked{
            ++i;
        }
        }
    }

    function claimBalance(uint256 amount, address to) external onlyOwner {
        payable(to).transfer(amount);
    }

    function claimToken(address token, uint256 amount, address to) external onlyOwner {
        IERC20(token).transfer(to, amount);
    }

    function getPoolInfo() external view returns (
        address usdtAddress, uint256 usdtDecimals, string memory usdtSymbol,
        uint256 minAmount, uint256 maxAmount, bool pause,
        address inviteRewardToken, uint256 inviteRewardTokenDecimals, string memory inviteRewardTokenSymbol
    ){
        usdtAddress = _usdtAddress;
        usdtDecimals = IERC20(usdtAddress).decimals();
        usdtSymbol = IERC20(usdtAddress).symbol();
        minAmount = _minAmount;
        maxAmount = _maxAmount;
        pause = _pause;
        inviteRewardToken = _inviteRewardToken;
        inviteRewardTokenDecimals = IERC20(inviteRewardToken).decimals();
        inviteRewardTokenSymbol = IERC20(inviteRewardToken).symbol();
    }

    function getOtherTokens() external view returns (
        address[] memory tokenAddress, uint256[] memory tokenDecimals, string[] memory tokenSymbol
    ){
        uint256 len = _otherToken.length;
        tokenAddress = new address[](len);
        tokenDecimals = new uint256[](len);
        tokenSymbol = new string[](len);
        for (uint256 i; i < len; ++i) {
            tokenAddress[i] = _otherToken[i];
            tokenDecimals[i] = IERC20(tokenAddress[i]).decimals();
            tokenSymbol[i] = IERC20(tokenAddress[i]).symbol();
        }
    }

    function getRewardTokens() external view returns (
        address[] memory tokenAddress, uint256[] memory tokenDecimals, string[] memory tokenSymbol
    ){
        uint256 len = _rewardToken.length;
        tokenAddress = new address[](len);
        tokenDecimals = new uint256[](len);
        tokenSymbol = new string[](len);
        for (uint256 i; i < len; ++i) {
            tokenAddress[i] = _rewardToken[i];
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
        uint256 teamNum
    ){
        UserInfo storage userInfo = _userInfo[account];
        amount = userInfo.amount;
        rewardBalance = userInfo.rewardBalance;
        claimedReward = userInfo.claimedReward;
        inviteReward = userInfo.inviteReward;
        claimedInviteReward = userInfo.claimedInviteReward;
        teamAmount = userInfo.teamAmount;
        activeBinderLength = _activeBinder[account].length;
        uint256 level = activeBinderLength;
        if (level > _inviteLength) {
            level = _inviteLength;
        }
        for (uint256 i; i < level; ++i) {
            teamNum += _teamNum[i][account];
        }
    }

    function getUserExtInfo(address account) external view returns (
        uint256 lastRewardTime, uint256 nextClaimCountdown, uint256 pendingReward,
        uint256 usdtBalance, uint256 usdtAllowance
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
    }
}

contract UMintPool is AbsMintPool {
    constructor() AbsMintPool(
    //SwapRouteAddress
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //RandomAddress
        address(0x1Ac50AeA37ef499a8024572893c25B31B9778214),
    //UsdtAddress
        address(0x55d398326f99059fF775485246999027B3197955),
    //BuybackTokenAddress
        address(0x3516c549c8D87AAA73d0FA4E904ec219Ff928B6C),
    //OtherToken1
        address(0xc5f327228A87fccdd2B337536aa55d9d9dbf0612),
    //OtherToken2
        address(0x693D516B3347A1f2145B5FcF4ce21d261800C921),
    //RewardToken1
        address(0x693D516B3347A1f2145B5FcF4ce21d261800C921),
    //RewardToken2
        address(0x3516c549c8D87AAA73d0FA4E904ec219Ff928B6C),
    //InviteRewardToken
        address(0x693D516B3347A1f2145B5FcF4ce21d261800C921),
    //NFTAddress
        address(0x46586f463f5689f977FC2b1d2e26996601861925)
    ){

    }
}