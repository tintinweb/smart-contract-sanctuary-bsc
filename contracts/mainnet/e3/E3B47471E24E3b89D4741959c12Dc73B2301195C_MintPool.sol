/**
 *Submitted for verification at BscScan.com on 2022-10-09
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
}

interface ISwapFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

    function sync() external;
}

abstract contract Ownable {
    address private _owner;

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

abstract contract AbsPool is Ownable {
    struct MinterLevel {
        uint256 level;
        uint256 price;
        uint256 rewardRate;
    }

    struct Pool {
        uint256 duration;
        uint256 price;
        uint256 rewardPerAmountPerDay;
        uint256 totalAmount;
    }

    struct UserInfo {
        uint256 minterLevel;
        uint256 minterLevelIndex;
        uint256 buyMinterBinderLength;
        uint256 buyMinterInviteReward;

        bool isPartner;
        uint256 buyMinterPartnerReward;

        uint256 minterEndTime;
        uint256 activeRecordIndex;
        uint256 mintClaimedReward;

        uint256 mintBinderLength;
        uint256 mintInviteAmount;
        uint256 mintLastInviteRewardTime;
        uint256 mintInviteClaimedReward;

        uint256 teamAccount;
    }

    struct Record {
        uint256 amount;
        uint256 rewardPerAmountPerDay;
        uint256 start;
        uint256 end;
        uint256 lastRewardTime;
        uint256 claimedReward;
    }

    Pool private _pool;
    mapping(address => Record[]) private _userRecords;
    mapping(address => UserInfo) private _userInfos;
    bool private _pause;

    mapping(address => address) public _invitor;
    mapping(address => address[]) public _binder;

    uint256 public _teamLength = 20;

    uint256 public constant _feeDivFactor = 10000;

    uint256 public constant MAX = ~uint256(0);

    address private _usdt;
    address private _token;

    ISwapRouter public _swapRouter;
    ISwapFactory public _factory;

    MinterLevel[] private _minterLevels;
    uint256 public _buyMinterInviteFee = 7000;
    uint256 public _buyMinterPlatformFee = 2000;
    uint256 public _buyMinterBusinessFee = 700;
    uint256 public _buyMinterPartnerFee = 300;

    uint256 public _buyMinterInviteLength = 7;
    mapping(uint256 => uint256) public _buyMinterInviteFees;

    uint256 private _partnerPrice;

    uint256 public _mintInviteLength = 13;
    mapping(uint256 => uint256) public _mintInviteFees;

    address public _defaultInvitor = address(0x5Fc93E9407C96aFdf80090289bbe7fECC0Fa7a53);

    address public _buyMinterPlatformAddress = address(0x759fe7A4F17323Af5d61e976bD2fBB605c9160FE);
    address public _buyMinterBusinessAddress = address(0x2F602809e0E18b0bc48913f912A00EDa5D24eF1A);
    address public _buyMinterDefaultPartnerAddress = address(0xB8C0d6455F89ca26C03887DEd0cf2E47B8Fa1cA3);
    address public _buyMinterDefaultInvitor = address(0xB8C0d6455F89ca26C03887DEd0cf2E47B8Fa1cA3);

    address public _buyPartnerReceiveAddress = address(0x85547aa64ef9F1AB93bf140F7201f7Cd48D79731);

    address public _mintReceiveAddress = address(0x85547aa64ef9F1AB93bf140F7201f7Cd48D79731);

    uint256 public _maxActiveRecordLen = 10;

    uint256 private _totalMinter;

    address public _mintOverRewardAddress = address(0xB8C0d6455F89ca26C03887DEd0cf2E47B8Fa1cA3);

    uint256 private _totalPartner;
    uint256 private _totalMintReward;
    uint256 private _totalInviteReward;

    constructor(address RouterAddress, address USDTAddress, address TokenAddress){
        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _swapRouter = swapRouter;
        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        _factory = swapFactory;

        _usdt = USDTAddress;
        _token = TokenAddress;

        _buyMinterInviteFees[0] = 3000;
        _buyMinterInviteFees[1] = 1500;
        for (uint256 i = 2; i < 7;) {
            _buyMinterInviteFees[i] = 500;
        unchecked{
            ++i;
        }
        }

        _mintInviteFees[0] = 3000;
        _mintInviteFees[1] = 1500;
        for (uint256 i = 2; i < 14;) {
            _mintInviteFees[i] = 500;
        unchecked{
            ++i;
        }
        }

        uint256 usdtUnit = 10 ** IERC20(USDTAddress).decimals();
        _partnerPrice = 3000 * usdtUnit;
        _pool = Pool(365 days, 100 * usdtUnit, 10 ** IERC20(TokenAddress).decimals() / 100 / _feeDivFactor, 0);

        _minterLevels.push(MinterLevel(1, 50 * usdtUnit, 5000));
        _minterLevels.push(MinterLevel(2, 100 * usdtUnit, 6000));
        _minterLevels.push(MinterLevel(3, 500 * usdtUnit, 8000));
        _minterLevels.push(MinterLevel(4, 1000 * usdtUnit, 10000));
    }

    function bindInvitor(address invitor) external {
        address account = msg.sender;
        require(_defaultInvitor != account, "defaultInvitor");
        require(invitor != account, "self");
        require(address(0) != invitor, "invitor 0");
        require(address(0) == _invitor[account], "Bind");
        require(_userInfos[account].minterLevel == 0, "minter");
        require(_binder[account].length == 0, "had binders");
        require(_userInfos[invitor].minterLevel > 0 || invitor == _defaultInvitor, "invitor invalid");
        _invitor[account] = invitor;
        _binder[invitor].push(account);
        uint256 len = _teamLength;
        for (uint256 i; i < len;) {
            if (address(0) == invitor) {
                break;
            }
            _userInfos[invitor].teamAccount += 1;
            invitor = _invitor[invitor];
        unchecked{
            ++i;
        }
        }
    }

    function buyMinter(uint256 minterId) external {
        address account = msg.sender;
        _claimMintReward(account);
        address invitor = _invitor[account];
        require(address(0) != invitor || account == _defaultInvitor, "notBind");
        MinterLevel storage minterLevel = _minterLevels[minterId];
        UserInfo storage userInfo = _userInfos[account];
        uint256 oldLevel = userInfo.minterLevel;
        if (0 == oldLevel) {
            _userInfos[invitor].buyMinterBinderLength += 1;
            _totalMinter += 1;
        }
        uint256 newLevel = minterLevel.level;
        require(newLevel > oldLevel, "lte oldLevel");
        userInfo.minterLevel = newLevel;
        userInfo.minterLevelIndex = minterId;
        uint256 price = minterLevel.price;
        address usdt = _usdt;
        _takeToken(usdt, account, address(this), price);
        
        uint256 platformAmount = price * _buyMinterPlatformFee / _feeDivFactor;
        _giveToken(usdt, _buyMinterPlatformAddress, platformAmount);
        
        uint256 businessAmount = price * _buyMinterBusinessFee / _feeDivFactor;
        _giveToken(usdt, _buyMinterBusinessAddress, businessAmount);
        
        uint256 totalInviteAmount = price * _buyMinterInviteFee / _feeDivFactor;
        uint256 len = _buyMinterInviteLength;
        UserInfo storage invitorInfo;
        for (uint256 i; i < len;) {
            if (address(0) == invitor) {
                break;
            }
            invitorInfo = _userInfos[invitor];
            if (invitorInfo.buyMinterBinderLength > i) {
                uint256 inviteAmount = price * _buyMinterInviteFees[i] / _feeDivFactor;
                totalInviteAmount -= inviteAmount;
                invitorInfo.buyMinterInviteReward += inviteAmount;
                _giveToken(usdt, invitor, inviteAmount);
            }
            invitor = _invitor[invitor];
        unchecked{
            ++i;
        }
        }
        _giveToken(usdt, _buyMinterDefaultInvitor, totalInviteAmount);
        
        uint256 partnerAmount = price * _buyMinterPartnerFee / _feeDivFactor;
        len = _teamLength;
        invitor = _invitor[account];
        for (uint256 i; i < len;) {
            if (address(0) == invitor) {
                break;
            }
            invitorInfo = _userInfos[invitor];
            if (invitorInfo.isPartner) {
                invitorInfo.buyMinterPartnerReward += partnerAmount;
                _giveToken(usdt, invitor, partnerAmount);
                partnerAmount = 0;
                break;
            }
            invitor = _invitor[invitor];
        unchecked{
            ++i;
        }
        }
        _giveToken(usdt, _buyMinterDefaultPartnerAddress, partnerAmount);
    }

    function buyPartner() external {
        address account = msg.sender;
        UserInfo storage userInfo = _userInfos[account];
        require(userInfo.minterLevel > 0, "not Minter");
        require(!userInfo.isPartner, "isPartner");
        userInfo.isPartner = true;
        _takeToken(_usdt, account, _buyPartnerReceiveAddress, _partnerPrice);
        _totalPartner++;
    }

    function _giveToken(address tokenAddress, address account, uint256 amount) private {
        if (0 == amount) {
            return;
        }
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(this)) >= amount, "pool token not enough");
        token.transfer(account, amount);
    }

    function _takeToken(address tokenAddress, address from, address to, uint256 tokenNum) private {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(from)) >= tokenNum, "token balance not enough");
        token.transferFrom(from, to, tokenNum);
    }

    function mint(uint256 amount, uint256 maxTokenAmount) external {
        require(!_pause, "Pause");
        require(amount > 0, "amount 0");

        address account = msg.sender;
        UserInfo storage userInfo = _userInfos[account];
        require(userInfo.minterLevel > 0, "not Minter");

        address usdt = _usdt;
        _takeMintAmount(account, amount, usdt, maxTokenAmount);

        _claimMintReward(account);
        uint256 userRecordLen = _userRecords[account].length;
        require(userInfo.activeRecordIndex + _maxActiveRecordLen > userRecordLen, "maxActiveRecordLen");
        _claimMintInviteReward(account);

        uint256 blockTime = block.timestamp;
        uint256 endTime = blockTime + _pool.duration;
        userInfo.minterEndTime = endTime;
        
        amount = amount * _feeDivFactor;
        _pool.totalAmount += amount;
        address invitor = _invitor[account];
        UserInfo storage invitorInfo = _userInfos[invitor];
        if (userRecordLen == 0) {
            invitorInfo.mintBinderLength += 1;
        }

        _addRecord(account, amount, blockTime, endTime);

        uint256 len = _mintInviteLength;
        for (uint256 i; i < len;) {
            if (address(0) == invitor) {
                break;
            }
            invitorInfo = _userInfos[invitor];
            
            if (invitorInfo.mintBinderLength > i && invitorInfo.minterEndTime > blockTime) {
                _claimMintInviteReward(invitor);
                invitorInfo.mintInviteAmount += amount * _mintInviteFees[i] / _feeDivFactor;
                invitorInfo.mintLastInviteRewardTime = blockTime;
            }
            invitor = _invitor[invitor];
        unchecked{
            ++i;
        }
        }
    }

    function _takeMintAmount(address account, uint256 amount, address usdt, uint256 maxTokenAmount) private {
        (,uint256 usdtPrice) = getTokenPrice();
        require(usdtPrice > 0, "usdtPrice 0");
        uint256 usdtAmount = _pool.price * amount;
        uint256 tokenAmount = usdtAmount * usdtPrice / (10 ** IERC20(usdt).decimals());
        require(maxTokenAmount >= tokenAmount, "gt maxTokenAmount");
        address receiver = _mintReceiveAddress;
        _takeToken(usdt, account, receiver, usdtAmount);
        _takeToken(_token, account, receiver, tokenAmount);
    }

    function _addRecord(address account, uint256 amount, uint256 blockTime, uint256 endTime) private {
        _userRecords[account].push(
            Record(amount, _pool.rewardPerAmountPerDay, blockTime, endTime, blockTime, 0)
        );
    }

    function claimMintReward() external {
        address account = msg.sender;
        _claimMintReward(account);
    }

    function claimMintInviteReward() external {
        address account = msg.sender;
        _claimMintInviteReward(account);
    }

    function claimReward() external {
        address account = msg.sender;
        _claimMintReward(account);
        _claimMintInviteReward(account);
    }
    
    function _claimMintReward(address account) private {
        UserInfo storage userInfo = _userInfos[account];
        uint256 recordLen = _userRecords[account].length;
        uint256 blockTime = block.timestamp;
        uint256 activeRecordIndex = userInfo.activeRecordIndex;
        Record storage record;
        uint256 rewardRate = _minterLevels[userInfo.minterLevelIndex].rewardRate;

        uint256 pendingReward;
        for (uint256 i = activeRecordIndex; i < recordLen;) {
            record = _userRecords[account][i];
            uint256 lastRewardTime = record.lastRewardTime;
            uint256 endTime = record.end;
            if (lastRewardTime < endTime && lastRewardTime < blockTime) {
                if (endTime > blockTime) {
                    endTime = blockTime;
                } else {
                    activeRecordIndex = i + 1;
                }
                record.lastRewardTime = endTime;
                uint256 reward = record.amount * record.rewardPerAmountPerDay * (endTime - lastRewardTime) / 1 days;
                record.claimedReward += reward * rewardRate / _feeDivFactor;
                pendingReward += reward;
            }
        unchecked{
            ++i;
        }
        }
        userInfo.activeRecordIndex = activeRecordIndex;
        if (pendingReward > 0) {
            _totalMintReward += pendingReward;
            uint256 realReward = pendingReward * rewardRate / _feeDivFactor;
            userInfo.mintClaimedReward += realReward;
            _giveToken(_token, account, realReward);
            if (pendingReward > realReward) {
                uint256 overReward = pendingReward - realReward;
                _giveToken(_token, _mintOverRewardAddress, overReward);
            }
        }
    }
    
    function _claimMintInviteReward(address account) private {
        UserInfo storage userInfo = _userInfos[account];
        uint256 blockTime = block.timestamp;
        uint256 mintEndTime = userInfo.minterEndTime;
        uint256 lastRewardTime = userInfo.mintLastInviteRewardTime;

        if (lastRewardTime >= blockTime) {
            return;
        }

        if (lastRewardTime >= mintEndTime) {
            return;
        }
        uint256 inviteAmount = userInfo.mintInviteAmount;
        if (0 == inviteAmount) {
            return;
        }
        if (mintEndTime > blockTime) {
            mintEndTime = blockTime;
        } else {
            userInfo.mintInviteAmount = 0;
        }
        userInfo.mintLastInviteRewardTime = mintEndTime;
        uint256 pendingReward = inviteAmount * _pool.rewardPerAmountPerDay * (mintEndTime - lastRewardTime) / 1 days;
        _totalInviteReward += pendingReward;

        uint256 levelIndex = userInfo.minterLevelIndex;
        uint256 realReward = pendingReward * _minterLevels[levelIndex].rewardRate / _feeDivFactor;
        userInfo.mintInviteClaimedReward += realReward;
        _giveToken(_token, account, realReward);
        if (pendingReward > realReward) {
            uint256 overReward = pendingReward - realReward;
            _giveToken(_token, _mintOverRewardAddress, overReward);
        }
    }

    function getMinterLevels() public view returns (
        uint256[] memory level,
        uint256[] memory price,
        uint256[] memory rewardRate
    ){
        uint256 len = _minterLevels.length;
        level = new uint256[](len);
        price = new uint256[](len);
        rewardRate = new uint256[](len);
        for (uint256 i; i < len; ++i) {
            (level[i], price[i], rewardRate[i]) = getMinterLevel(i);
        }
    }

    function getMinterLevelLength() public view returns (uint256){
        return _minterLevels.length;
    }

    function getMinterLevel(uint256 i) public view returns (
        uint256 level,
        uint256 price,
        uint256 rewardRate
    ){
        MinterLevel storage minterLevel = _minterLevels[i];
        level = minterLevel.level;
        price = minterLevel.price;
        rewardRate = minterLevel.rewardRate;
    }

    function poolInfo() public view returns (
        uint256 duration, uint256 price,
        uint256 rewardPerAmountPerDay, uint256 totalAmount,
        uint256 partnerPrice, uint256 totalMinter,
        uint256 totalPartner, uint256 totalMintReward, uint256 totalInviteReward
    ){
        duration = _pool.duration;
        price = _pool.price;
        rewardPerAmountPerDay = _pool.rewardPerAmountPerDay;
        totalAmount = _pool.totalAmount;
        partnerPrice = _partnerPrice;
        totalMinter = _totalMinter;
        totalPartner = _totalPartner;
        totalMintReward = _totalMintReward;
        totalInviteReward = _totalInviteReward;
    }

    function getRecords(
        address account,
        uint256 start,
        uint256 length
    ) external view returns (
        uint256 returnCount,
        uint256[] memory amount,
        uint256[] memory rewardPerAmountPerDay,
        uint256[] memory startTime,
        uint256[] memory endTime,
        uint256[] memory lastRewardTime,
        uint256[] memory claimedRewards,
        uint256[] memory totalRewards
    ){
        uint256 recordLen = _userRecords[account].length;
        if (0 == length) {
            length = recordLen;
        }
        returnCount = length;

        amount = new uint256[](length);
        rewardPerAmountPerDay = new uint256[](length);
        startTime = new uint256[](length);
        endTime = new uint256[](length);
        lastRewardTime = new uint256[](length);
        claimedRewards = new uint256[](length);
        totalRewards = new uint256[](length);
        uint256 index = 0;
        for (uint256 i = start; i < start + length; i++) {
            if (i >= recordLen) {
                return (index, amount, rewardPerAmountPerDay, startTime, endTime, lastRewardTime, claimedRewards, totalRewards);
            }
            (amount[index], rewardPerAmountPerDay[index], startTime[index], endTime[index], lastRewardTime[index], claimedRewards[index]) = getRecord(account, i);
            totalRewards[index] = getPendingReward(account, i);
            index++;
        }
    }

    function getRecord(address account, uint256 i) public view returns (
        uint256 amount,
        uint256 rewardPerAmountPerDay,
        uint256 startTime,
        uint256 endTime,
        uint256 lastRewardTime,
        uint256 claimedReward
    ){
        Record storage record = _userRecords[account][i];
        amount = record.amount;
        rewardPerAmountPerDay = record.rewardPerAmountPerDay;
        startTime = record.start;
        endTime = record.end;
        lastRewardTime = record.lastRewardTime;
        claimedReward = record.claimedReward;
    }

    function getPendingReward(address account, uint256 i) public view returns (uint256 pendingReward){
        Record storage record = _userRecords[account][i];
        uint256 start = record.start;
        uint256 end = record.end;
        uint256 blockTime = block.timestamp;
        if (end > blockTime) {
            end = blockTime;
        }
        if (end > start) {
            uint256 reward = record.amount * record.rewardPerAmountPerDay * (end - start) / 1 days;
            uint256 lastReward = record.amount * record.rewardPerAmountPerDay * (record.lastRewardTime - start) / 1 days;
            if (reward > lastReward) {
                uint256 levelIndex = _userInfos[account].minterLevelIndex;
                pendingReward = (reward - lastReward) * _minterLevels[levelIndex].rewardRate / _feeDivFactor;
            }
        }
    }

    function getBaseInfo() external view returns (
        address usdtAddress, uint256 usdtDecimals, string memory usdtSymbol,
        address tokenAddress, uint256 tokenDecimals, string memory tokenSymbol,
        bool pause, uint256 tokenPrice, uint256 tokenAmountPerUsdt, uint blockTime
    ){
        usdtAddress = _usdt;
        usdtDecimals = IERC20(usdtAddress).decimals();
        usdtSymbol = IERC20(usdtAddress).symbol();
        tokenAddress = _token;
        tokenDecimals = IERC20(tokenAddress).decimals();
        tokenSymbol = IERC20(tokenAddress).symbol();
        pause = _pause;
        (tokenPrice, tokenAmountPerUsdt) = getTokenPrice();
        blockTime = block.timestamp;
    }

    function getUserInfo(address account) external view returns (
        uint256 usdtBalance,
        uint256 usdtAllowance,
        uint256 tokenBalance,
        uint256 tokenAllowance,
        uint256 teamAccount,
        uint256 binderLength,
        bool isPartner,
        uint256 partnerReward
    ){
        usdtBalance = IERC20(_usdt).balanceOf(account);
        usdtAllowance = IERC20(_usdt).allowance(account, address(this));
        tokenBalance = IERC20(_token).balanceOf(account);
        tokenAllowance = IERC20(_token).allowance(account, address(this));
        UserInfo storage userInfo = _userInfos[account];
        teamAccount = userInfo.teamAccount;
        binderLength = _binder[account].length;
        isPartner = userInfo.isPartner;
        partnerReward = userInfo.buyMinterPartnerReward;
    }

    function getUserMinterInfo(address account) external view returns (
        uint256 minterLevel,
        uint256 minterLevelIndex,
        uint256 minterRewardRate,
        uint256 minterEndTime,
        uint256 recordLen,
        uint256 activeRecordIndex,
        uint256 mintClaimedReward,
        uint256 pendingMintReward
    ){
        UserInfo storage userInfo = _userInfos[account];
        minterLevel = userInfo.minterLevel;
        minterLevelIndex = userInfo.minterLevelIndex;
        if (minterLevel > 0) {
            minterRewardRate = _minterLevels[minterLevelIndex].rewardRate;
        }
        minterEndTime = userInfo.minterEndTime;
        recordLen = _userRecords[account].length;
        activeRecordIndex = userInfo.activeRecordIndex;
        mintClaimedReward = userInfo.mintClaimedReward;
        pendingMintReward = getPendingMintReward(account);
    }

    function getPendingMintReward(address account) public view returns (uint256 realReward){
        UserInfo storage userInfo = _userInfos[account];
        uint256 recordLen = _userRecords[account].length;
        uint256 blockTime = block.timestamp;
        uint256 activeRecordIndex = userInfo.activeRecordIndex;
        Record storage record;
        uint256 pendingReward;
        for (uint256 i = activeRecordIndex; i < recordLen;) {
            record = _userRecords[account][i];
            uint256 lastRewardTime = record.lastRewardTime;
            uint256 endTime = record.end;
            if (lastRewardTime < endTime && lastRewardTime < blockTime) {
                if (endTime > blockTime) {
                    endTime = blockTime;
                } else {
                    activeRecordIndex = i + 1;
                }
                pendingReward += record.amount * record.rewardPerAmountPerDay * (endTime - lastRewardTime) / 1 days;
            }
        unchecked{
            ++i;
        }
        }
        if (pendingReward > 0) {
            uint256 levelIndex = userInfo.minterLevelIndex;
            realReward = pendingReward * _minterLevels[levelIndex].rewardRate / _feeDivFactor;
        }
    }

    function getUserInviteInfo(address account) external view returns (
        uint256 buyMinterBinderLength,
        uint256 buyMinterInviteReward,
        uint256 buyMinterInviteLevel,
        uint256 mintBinderLength,
        uint256 mintInviteInviteLevel,
        uint256 mintInviteAmount,
        uint256 mintLastInviteRewardTime,
        uint256 mintInviteClaimedReward,
        uint256 pendingMintInviteReward,
        address invitor
    ){
        UserInfo storage userInfo = _userInfos[account];
        buyMinterBinderLength = userInfo.buyMinterBinderLength;
        buyMinterInviteReward = userInfo.buyMinterInviteReward;
        buyMinterInviteLevel = buyMinterBinderLength;
        if (buyMinterInviteLevel > _buyMinterInviteLength) {
            buyMinterInviteLevel = _buyMinterInviteLength;
        }
        mintBinderLength = userInfo.mintBinderLength;
        mintInviteInviteLevel = mintBinderLength;
        if (mintInviteInviteLevel > _mintInviteLength) {
            mintInviteInviteLevel = _mintInviteLength;
        }
        mintInviteAmount = userInfo.mintInviteAmount;
        mintLastInviteRewardTime = userInfo.mintLastInviteRewardTime;
        mintInviteClaimedReward = userInfo.mintInviteClaimedReward;
        pendingMintInviteReward = getPendingMintInviteReward(account);
        invitor = _invitor[account];
    }

    function getPendingMintInviteReward(address account) public view returns (uint256 realReward){
        UserInfo storage userInfo = _userInfos[account];
        uint256 blockTime = block.timestamp;
        uint256 mintEndTime = userInfo.minterEndTime;
        uint256 lastRewardTime = userInfo.mintLastInviteRewardTime;
        
        if (lastRewardTime >= blockTime) {
            return 0;
        }
        
        if (lastRewardTime >= mintEndTime) {
            return 0;
        }
        uint256 inviteAmount = userInfo.mintInviteAmount;
        if (0 == inviteAmount) {
            return 0;
        }
        if (mintEndTime > blockTime) {
            mintEndTime = blockTime;
        } else {

        }
        uint256 pendingReward = inviteAmount * _pool.rewardPerAmountPerDay * (mintEndTime - lastRewardTime) / 1 days;
        uint256 levelIndex = userInfo.minterLevelIndex;
        realReward = pendingReward * _minterLevels[levelIndex].rewardRate / _feeDivFactor;
    }

    function getBinderLength(address account) public view returns (uint256){
        return _binder[account].length;
    }

    function claimToken(address tokenAddress, address to, uint256 amount) external onlyOwner {
        IERC20(tokenAddress).transfer(to, amount);
    }

    function claimBalance(address to, uint256 amount) external onlyOwner {
        address payable addr = payable(to);
        addr.transfer(amount);
    }

    function setPause(bool p) external onlyOwner {
        _pause = p;
    }

    function setBuyMinterInviteFees(uint256 i, uint256 fee) external onlyOwner {
        _buyMinterInviteFees[i] = fee;
    }

    function setMintInviteFees(uint256 i, uint256 fee) external onlyOwner {
        _mintInviteFees[i] = fee;
    }

    function setTeamLength(uint256 len) external onlyOwner {
        _teamLength = len;
    }

    function setMintInviteLength(uint256 len) external onlyOwner {
        _mintInviteLength = len;
    }

    function setBuyMinterInviteLength(uint256 len) external onlyOwner {
        _buyMinterInviteLength = len;
    }

    function setToken(address tokenAddress) external onlyOwner {
        _token = tokenAddress;
    }

    function setUsdt(address usdtAddress) external onlyOwner {
        _usdt = usdtAddress;
    }

    function setDefaultInvitor(address defaultInvitor) external onlyOwner {
        _defaultInvitor = defaultInvitor;
    }

    function setPoolReward(uint256 reward) external onlyOwner {
        _pool.rewardPerAmountPerDay = reward / _feeDivFactor;
    }

    function setPoolPrice(uint256 price) external onlyOwner {
        _pool.price = price * 10 ** IERC20(_usdt).decimals();
    }

    function setPoolDuration(uint256 duration) external onlyOwner {
        if (_pool.totalAmount > 0) {
            require(duration > _pool.duration, "longer");
        }
        _pool.duration = duration;
    }

    function addMinterLevel(uint256 level, uint256 price, uint256 rewardRate) external onlyOwner {
        _minterLevels.push(MinterLevel(level, price * 10 ** IERC20(_usdt).decimals(), rewardRate));
    }

    function addMinterPrice(uint256 i, uint256 price) external onlyOwner {
        _minterLevels[i].price = price * 10 ** IERC20(_usdt).decimals();
    }

    function addMinterRewardRate(uint256 i, uint256 rewardRate) external onlyOwner {
        _minterLevels[i].rewardRate = rewardRate;
    }

    function setBuyMinterInviteFee(uint256 fee) external onlyOwner {
        _buyMinterInviteFee = fee;
    }

    function setBuyMinterPlatformFee(uint256 fee) external onlyOwner {
        _buyMinterPlatformFee = fee;
    }

    function setBuyMinterBusinessFee(uint256 fee) external onlyOwner {
        _buyMinterBusinessFee = fee;
    }

    function setBuyMinterPartnerFee(uint256 fee) external onlyOwner {
        _buyMinterPartnerFee = fee;
    }

    function setPartnerPrice(uint256 price) external onlyOwner {
        _partnerPrice = price * 10 ** IERC20(_usdt).decimals();
    }

    function setMaxActiveRecordLen(uint256 len) external onlyOwner {
        _maxActiveRecordLen = len;
    }

    function setBuyMinterPlatformAddress(address adr) external onlyOwner {
        _buyMinterPlatformAddress = adr;
    }

    function setBuyMinterBusinessAddress(address adr) external onlyOwner {
        _buyMinterBusinessAddress = adr;
    }

    function setBuyMinterDefaultPartnerAddress(address adr) external onlyOwner {
        _buyMinterDefaultPartnerAddress = adr;
    }

    function setBuyMinterDefaultInvitor(address adr) external onlyOwner {
        _buyMinterDefaultInvitor = adr;
    }

    function setBuyPartnerReceiveAddress(address adr) external onlyOwner {
        _buyPartnerReceiveAddress = adr;
    }

    function setMintReceiveAddress(address adr) external onlyOwner {
        _mintReceiveAddress = adr;
    }

    function setMintOverRewardAddress(address adr) external onlyOwner {
        _mintOverRewardAddress = adr;
    }

    function getTokenPrice() public view returns (uint256 tokenPrice, uint256 tokenAmountPerUsdt){
        address pairAddress = _factory.getPair(_usdt, _token);
        if (address(0) == pairAddress) {
            return (0, 0);
        }
        ISwapPair swapPair = ISwapPair(pairAddress);
        (uint256 reverse0, uint256 reverse1,) = swapPair.getReserves();
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
        if (0 != tokenReverse) {
            tokenPrice = 10 ** IERC20(_token).decimals() * usdtReverse / tokenReverse;
        }
        if (0 != usdtReverse) {
            tokenAmountPerUsdt = 10 ** IERC20(_usdt).decimals() * tokenReverse / usdtReverse;
        }
    }
}

contract MintPool is AbsPool {
    constructor() AbsPool(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
    //Token
        address(0xdF763AeAa9D46C1fb3F033fFB2E093AaA6F4cb04)
    ){

    }
}