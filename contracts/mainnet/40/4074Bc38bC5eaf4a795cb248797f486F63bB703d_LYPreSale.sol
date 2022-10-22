/**
 *Submitted for verification at BscScan.com on 2022-10-22
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

abstract contract AbsPreSale is Ownable {
    struct SaleInfo {
        uint256 tokenAmount;
        uint256 saleNum;
    }

    struct PriceInfo {
        uint256 time;
        uint256 price;
    }

    struct ReleaseInfo {
        uint256 time;
        uint256 rate;
    }

    struct UserInfo {
        uint256 buyTokenAmount;
        uint256 inviteRewardAmount;
        uint256 teamNum;
        uint256 teamAmount;
        uint256 teamRewardAmount;
        uint256 claimedAmount;
    }

    address private _usdtAddress;
    address public _cashAddress;
    address private _tokenAddress;

    SaleInfo[] private _saleInfo;
    PriceInfo[] private _priceInfo;
    ReleaseInfo[] private _releaseInfo;
    mapping(address => UserInfo) private _userInfo;

    mapping(address => address) public _invitor;
    mapping(address => address[]) public _binder;
    mapping(address => address[]) public _activeBinder;

    mapping(uint256 => uint256) public _inviteFee;

    bool private _pauseBuy = false;
    bool private _pauseClaim = true;

    uint256 public _teamRewardCondition;
    uint256 public _teamRewardAmount;

    uint256 public _totalInviteReward;
    uint256 public _totalTeamRewardAmount;

    uint256 public constant _feeDivFactor = 10000;
    uint256 public _inviteLength = 7;

    constructor(address UsdtAddress, address TokenAddress, address CashAddress){
        _tokenAddress = TokenAddress;
        _usdtAddress = UsdtAddress;
        _cashAddress = CashAddress;

        uint256 usdtUnit = 10 ** IERC20(UsdtAddress).decimals();
        uint256 tokenUnit = 10 ** IERC20(TokenAddress).decimals();

        _saleInfo.push(SaleInfo(100 * tokenUnit, 0));
        _saleInfo.push(SaleInfo(300 * tokenUnit, 0));
        _saleInfo.push(SaleInfo(500 * tokenUnit, 0));
        _saleInfo.push(SaleInfo(1000 * tokenUnit, 0));

        uint256 blockTime = block.timestamp;
        _priceInfo.push(PriceInfo(0, 1 * usdtUnit));
        _priceInfo.push(PriceInfo(blockTime + 30 days, 120 * usdtUnit / 100));
        _priceInfo.push(PriceInfo(blockTime + 60 days, 140 * usdtUnit / 100));

        _inviteFee[0] = 700;
        _inviteFee[1] = 600;
        _inviteFee[2] = 500;
        _inviteFee[3] = 400;
        _inviteFee[4] = 300;
        _inviteFee[5] = 200;
        _inviteFee[6] = 100;

        _teamRewardCondition = 100000 * usdtUnit;
        _teamRewardAmount = 5000 * tokenUnit;
    }

    function bindInvitor(address invitor) external {
        address account = msg.sender;
        require(invitor != account, "Self");
        require(address(0) == _invitor[account], "Bind");
        require(_userInfo[account].buyTokenAmount == 0, "!New");

        require(_userInfo[invitor].buyTokenAmount > 0, "!Invitor");
        _invitor[account] = invitor;
        _binder[invitor].push(account);
    }

    function buy(uint256 saleId) external {
        require(!_pauseBuy, "pauseBuy");
        address account = msg.sender;
        UserInfo storage userInfo = _userInfo[account];
        require(userInfo.buyTokenAmount == 0, "bought");

        SaleInfo storage sale = _saleInfo[saleId];
        sale.saleNum += 1;
        uint256 tokenAmount = sale.tokenAmount;
        userInfo.buyTokenAmount = tokenAmount;

        uint256 price = getPrice();
        require(price > 0, "unset price");
        uint256 usdtAmount = tokenAmount * price / (10 ** IERC20(_tokenAddress).decimals());
        _takeToken(_usdtAddress, account, address(this), usdtAmount);

        address invitor = _invitor[account];
        if (invitor == address(0)) {
            _giveToken(_usdtAddress, _cashAddress, usdtAmount);
            return;
        }
        _activeBinder[invitor].push(account);

        uint256 inviteLength = _inviteLength;
        UserInfo storage invitorInfo;
        uint256 totalInviteReward = 0;
        uint256 totalTeamRewardAmount = 0;

        uint256 inviteReward;
        uint256 activeBinderLength;
        uint256 teamRewardCondition = _teamRewardCondition;
        uint256 teamRewardAmount = _teamRewardAmount;
        for (uint256 i; i < inviteLength;) {
            activeBinderLength = _activeBinder[invitor].length;
            if (activeBinderLength > i) {
                invitorInfo = _userInfo[invitor];
                inviteReward = usdtAmount * _inviteFee[i] / _feeDivFactor;
                totalInviteReward += inviteReward;
                invitorInfo.inviteRewardAmount += inviteReward;
                invitorInfo.teamAmount += usdtAmount;
                invitorInfo.teamNum += 1;
                _giveToken(_usdtAddress, invitor, inviteReward);
                if (invitorInfo.teamAmount >= teamRewardCondition && invitorInfo.teamRewardAmount == 0) {
                    totalTeamRewardAmount += teamRewardAmount;
                    invitorInfo.teamRewardAmount = teamRewardAmount;
                }
            }
            invitor = _invitor[invitor];
            if (invitor == address(0)) {
                break;
            }
        unchecked{
            ++i;
        }
        }

        _totalInviteReward += totalInviteReward;
        _totalTeamRewardAmount += totalTeamRewardAmount;
        _giveToken(_usdtAddress, _cashAddress, usdtAmount - totalInviteReward);
    }

    function claim() external {
        require(!_pauseClaim, "pauseClaim");
        address account = msg.sender;
        (uint256 pendingReward,) = getPendingReward(account);
        if (0 == pendingReward) {
            return;
        }
        _giveToken(_tokenAddress, account, pendingReward);
        UserInfo storage userInfo = _userInfo[account];
    unchecked{
        userInfo.claimedAmount += pendingReward;
    }
    }

    function getPrice() public view returns (uint256 price){
        uint256 blockTime = block.timestamp;
        uint256 len = _priceInfo.length;
        PriceInfo storage priceInfo;
        for (uint256 i = len; i > 0;) {
        unchecked{
            --i;
        }
            priceInfo = _priceInfo[i];
            if (blockTime >= priceInfo.time) {
                return priceInfo.price;
            }
        }
    }

    function getReleaseRate() public view returns (uint256 rate){
        uint256 blockTime = block.timestamp;
        uint256 len = _releaseInfo.length;
        ReleaseInfo storage info;
        for (uint256 i = len; i > 0;) {
        unchecked{
            --i;
        }
            info = _releaseInfo[i];
            if (blockTime >= info.time) {
                return info.rate;
            }
        }
    }

    function _giveToken(address tokenAddress, address account, uint256 tokenNum) private {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(this)) >= tokenNum, "shop balance not enough");
        token.transfer(account, tokenNum);
    }

    function _takeToken(address tokenAddress, address account, address receiver, uint256 tokenNum) private {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(account) >= tokenNum, "balance not enough");
        token.transferFrom(account, receiver, tokenNum);
    }

    function allSaleInfo() external view returns (
        uint256[] memory prices, uint256[] memory tokenNum,
        uint256[] memory saleNum
    ) {
        uint256 len = _saleInfo.length;
        prices = new uint256[](len);
        tokenNum = new uint256[](len);
        saleNum = new uint256[](len);
        uint256 price = getPrice();
        uint256 tokenUnit = 10 ** IERC20(_tokenAddress).decimals();
        for (uint256 i; i < len; i++) {
            SaleInfo storage sale = _saleInfo[i];
            tokenNum[i] = sale.tokenAmount;
            prices[i] = tokenNum[i] * price / tokenUnit;
            saleNum[i] = sale.saleNum;
        }
    }

    function shopInfo() external view returns (
        address usdtAddress, uint256 usdtDecimals, string memory usdtSymbol,
        address tokenAddress, uint256 tokenDecimals, string memory tokenSymbol,
        bool pauseBuy, bool pauseClaim, uint256 price
    ){
        usdtAddress = _usdtAddress;
        usdtDecimals = IERC20(usdtAddress).decimals();
        usdtSymbol = IERC20(usdtAddress).symbol();
        tokenAddress = _tokenAddress;
        tokenDecimals = IERC20(tokenAddress).decimals();
        tokenSymbol = IERC20(tokenAddress).symbol();
        pauseBuy = _pauseBuy;
        pauseClaim = _pauseClaim;
        price = getPrice();
    }

    function getUserInfo(address account) external view returns (
        uint256 inviteLevel, uint256 inviteRewardAmount, uint256 teamAmount,
        uint256 pendingReward, uint256 pendingRelease,
        address invitor, uint256 usdtBalance, uint256 uadtAllowance
    ){
        inviteLevel = getInviteLevel(account);
        UserInfo storage userInfo = _userInfo[account];
        inviteRewardAmount = userInfo.inviteRewardAmount;
        teamAmount = userInfo.teamAmount;
        invitor = _invitor[account];
        usdtBalance = IERC20(_usdtAddress).balanceOf(account);
        uadtAllowance = IERC20(_usdtAddress).allowance(account, address(this));
        (pendingReward, pendingRelease) = getPendingReward(account);
    }

    function getInviteLevel(address account) public view returns (uint256 level){
        level = _activeBinder[account].length;
        uint256 maxLevel = _inviteLength;
        if (level > maxLevel) {
            level = maxLevel;
        }
    }

    function getPendingReward(address account) public view returns (uint256 pendingReward, uint256 pendingRelease){
        UserInfo storage userInfo = _userInfo[account];
        uint256 totalReward = userInfo.buyTokenAmount + userInfo.teamRewardAmount;
        uint256 releaseRate = getReleaseRate();
        uint256 releaseAmount = totalReward * releaseRate / _feeDivFactor;
        if (releaseAmount > totalReward) {
            releaseAmount = totalReward;
        }
        uint256 claimedAmount = userInfo.claimedAmount;
        if (releaseAmount > claimedAmount) {
        unchecked{
            pendingReward = releaseAmount - claimedAmount;
        }
        }
        pendingRelease = totalReward - releaseAmount;
    }

    function getUserExtInfo(address account) external view returns (
        uint256 buyTokenAmount, uint256 teamNum, uint256 teamRewardAmount,
        uint256 claimedAmount, uint256 binderLen, uint256 activeBindLen
    ){
        UserInfo storage userInfo = _userInfo[account];
        buyTokenAmount = userInfo.buyTokenAmount;
        teamNum = userInfo.teamNum;
        teamRewardAmount = userInfo.teamRewardAmount;
        claimedAmount = userInfo.claimedAmount;
        binderLen = _binder[account].length;
        activeBindLen = _activeBinder[account].length;
    }

    function getPriceInfo(uint256 i) external view returns (uint256 time, uint256 price){
        PriceInfo storage info = _priceInfo[i];
        time = info.time;
        price = info.price;
    }

    function getReleaseInfo(uint256 i) external view returns (uint256 time, uint256 rate){
        ReleaseInfo storage info = _releaseInfo[i];
        time = info.time;
        rate = info.rate;
    }

    receive() external payable {}

    function addSale(uint256 tokenAmount) external onlyOwner {
        _saleInfo.push(SaleInfo(tokenAmount, 0));
    }

    function setTokenAmount(uint256 saleId, uint256 tokenNum) external onlyOwner {
        _saleInfo[saleId].tokenAmount = tokenNum;
    }

    function addPriceInfo(uint256 time, uint256 price) external onlyOwner {
        _priceInfo.push(PriceInfo(time, price));
    }

    function setPrice(uint256 i, uint256 time, uint256 price) external onlyOwner {
        PriceInfo storage info = _priceInfo[i];
        info.time = time;
        info.price = price;
    }

    function startClaim() external onlyOwner {
        _pauseClaim = false;
        uint256 blockTime = block.timestamp;
        _releaseInfo.push(ReleaseInfo(0, 2000));
        _releaseInfo.push(ReleaseInfo(blockTime + 30 days, 4000));
        _releaseInfo.push(ReleaseInfo(blockTime + 60 days, 6000));
        _releaseInfo.push(ReleaseInfo(blockTime + 90 days, 8000));
        _releaseInfo.push(ReleaseInfo(blockTime + 120 days, 10000));
    }

    function setRelease(uint256 i, uint256 time, uint256 rate) external onlyOwner {
        ReleaseInfo storage info = _releaseInfo[i];
        info.time = time;
        info.rate = rate;
    }

    function setTokenAddress(address adr) external onlyOwner {
        _tokenAddress = adr;
    }

    function setUsdtAddress(address adr) external onlyOwner {
        _usdtAddress = adr;
    }

    function setCashAddress(address adr) external onlyOwner {
        _cashAddress = adr;
    }

    function setPauseBuy(bool pause) external onlyOwner {
        _pauseBuy = pause;
    }

    function setPauseClaim(bool pause) external onlyOwner {
        _pauseClaim = pause;
    }

    function setTeamRewardCondition(uint256 condition) external onlyOwner {
        _teamRewardCondition = condition;
    }

    function setTeamRewardAmount(uint256 amount) external onlyOwner {
        _teamRewardAmount = amount;
    }

    function claimBalance() external {
        address payable addr = payable(_cashAddress);
        addr.transfer(address(this).balance);
    }

    function claimToken(address erc20Address) external onlyOwner {
        IERC20 erc20 = IERC20(erc20Address);
        erc20.transfer(_cashAddress, erc20.balanceOf(address(this)));
    }
}

contract LYPreSale is AbsPreSale {
    constructor() AbsPreSale(
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
    //LY
        address(0x5C2f101C07723a044A72b0764d4fc07B5281eFaf),
    //Cash
        address(0xbD218407b718A4ed959CDa5a421d7dE9876C1616)
    ){

    }
}