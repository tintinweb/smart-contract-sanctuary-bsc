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

interface IToken {
    function bindInvitor(address account, address invitor) external;

    function _inviter(address account) external view returns (address);

    function getBinderLength(address account) external view returns (uint256);

    function _binders(address account, uint256 index) external view returns (address);
}

abstract contract AbsPreSale is Ownable {
    struct SaleInfo {
        uint256 price;
        uint256 tokenAmount;
        uint256 qty;
        uint256 saleNum;
    }

    struct UserInfo {
        uint256 buyUsdtAmount;
        uint256 buyTokenAmount;
        uint256 claimedAmount;
        uint256 inviteUsdt;
    }

    address public _usdtAddress;
    address public _cashAddress;
    address private _tokenAddress;

    SaleInfo[] private _saleInfo;
    mapping(address => UserInfo) private _userInfo;

    bool private _pauseBuy = false;
    bool private _pauseClaim = true;

    uint256 private _totalUsdt;
    uint256 private _totalToken;
    uint256 private _totalInviteUsdt;

    uint256 public _releaseStartTime;
    uint256 public _releaseDuration = 100 days;
    uint256 public _inviteFee = 2000;
    uint256 public _totalAccount;

    constructor(address UsdtAddress, address TokenAddress, address CashAddress){
        _tokenAddress = TokenAddress;
        _usdtAddress = UsdtAddress;
        _cashAddress = CashAddress;

        uint256 usdtUnit = 10 ** IERC20(UsdtAddress).decimals();
        uint256 tokenUnit = 10 ** IERC20(TokenAddress).decimals();

        _saleInfo.push(SaleInfo(100 * usdtUnit, 12000 * tokenUnit, 1000, 0));
        _saleInfo.push(SaleInfo(200 * usdtUnit, 25000 * tokenUnit, 500, 0));
        _saleInfo.push(SaleInfo(500 * usdtUnit, 65000 * tokenUnit, 200, 0));
        _saleInfo.push(SaleInfo(1000 * usdtUnit, 135000 * tokenUnit, 100, 0));
        _saleInfo.push(SaleInfo(2000 * usdtUnit, 280000 * tokenUnit, 50, 0));
        _saleInfo.push(SaleInfo(5000 * usdtUnit, 725000 * tokenUnit, 20, 0));
        _saleInfo.push(SaleInfo(10000 * usdtUnit, 1500000 * tokenUnit, 10, 0));
    }

    function buy(uint256 saleId, address invitor) external {
        require(!_pauseBuy, "pauseBuy");

        address account = msg.sender;
        UserInfo storage userInfo = _userInfo[account];

        IToken token = IToken(_tokenAddress);
        if (userInfo.buyUsdtAmount == 0) {
            _totalAccount++;
            token.bindInvitor(account, invitor);
        }

        SaleInfo storage sale = _saleInfo[saleId];
        require(sale.qty > sale.saleNum, "no qty");
        sale.saleNum += 1;

        uint256 price = sale.price;
        uint256 tokenAmount = sale.tokenAmount;

        userInfo.buyTokenAmount += tokenAmount;
        userInfo.buyUsdtAmount += price;

        _totalUsdt += price;
        _totalToken += tokenAmount;

        address usdtAddress = _usdtAddress;
        _takeToken(usdtAddress, account, address(this), price);
        invitor = token._inviter(account);
        uint256 inviteUsdt;
        if (address(0) != invitor) {
            UserInfo storage invitorInfo = _userInfo[invitor];
            if (invitorInfo.buyUsdtAmount > 0) {
                inviteUsdt = price * _inviteFee / 10000;
                _totalInviteUsdt += inviteUsdt;
                invitorInfo.inviteUsdt += inviteUsdt;
                _giveToken(usdtAddress, invitor, inviteUsdt);
            }
        }
        _giveToken(usdtAddress, _cashAddress, price - inviteUsdt);
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

    function getReleaseAmount(uint256 amount) public view returns (uint256 releaseAmount){
        uint256 startTime = _releaseStartTime;
        if (0 == startTime) {
            return 0;
        }
        uint256 blockTime = block.timestamp;
        if (startTime >= blockTime) {
            return 0;
        }
        uint256 duration = blockTime - startTime;
        uint256 maxDuration = _releaseDuration;
        if (duration > maxDuration) {
            duration = maxDuration;
        }
        return amount * duration / maxDuration;
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
        uint256[] memory qtyNum, uint256[] memory saleNum
    ) {
        uint256 len = _saleInfo.length;
        prices = new uint256[](len);
        tokenNum = new uint256[](len);
        qtyNum = new uint256[](len);
        saleNum = new uint256[](len);
        for (uint256 i; i < len; i++) {
            SaleInfo storage sale = _saleInfo[i];
            prices[i] = sale.price;
            tokenNum[i] = sale.tokenAmount;
            qtyNum[i] = sale.qty;
            saleNum[i] = sale.saleNum;
        }
    }

    function shopInfo() external view returns (
        address usdtAddress, uint256 usdtDecimals, string memory usdtSymbol,
        address tokenAddress, uint256 tokenDecimals, string memory tokenSymbol,
        bool pauseBuy, bool pauseClaim,
        uint256 totalUsdt, uint256 totalToken, uint256 totalInviteUsdt
    ){
        usdtAddress = _usdtAddress;
        usdtDecimals = IERC20(usdtAddress).decimals();
        usdtSymbol = IERC20(usdtAddress).symbol();
        tokenAddress = _tokenAddress;
        tokenDecimals = IERC20(tokenAddress).decimals();
        tokenSymbol = IERC20(tokenAddress).symbol();
        pauseBuy = _pauseBuy;
        pauseClaim = _pauseClaim;
        totalUsdt = _totalUsdt;
        totalToken = _totalToken;
        totalInviteUsdt = _totalInviteUsdt;
    }

    function getUserInfo(address account) external view returns (
        uint256 pendingReward, uint256 releaseAmount,
        uint256 usdtBalance, uint256 usdtAllowance,
        uint256 buyUsdtAmount, uint256 buyTokenAmount,
        uint256 claimedAmount, uint256 inviteUsdt
    ){
        (pendingReward, releaseAmount) = getPendingReward(account);
        usdtBalance = IERC20(_usdtAddress).balanceOf(account);
        usdtAllowance = IERC20(_usdtAddress).allowance(account, address(this));
        UserInfo storage userInfo = _userInfo[account];
        buyUsdtAmount = userInfo.buyUsdtAmount;
        buyTokenAmount = userInfo.buyTokenAmount;
        claimedAmount = userInfo.claimedAmount;
        inviteUsdt = userInfo.inviteUsdt;
    }

    function getPendingReward(address account) public view returns (uint256 pendingReward, uint256 releaseAmount){
        UserInfo storage userInfo = _userInfo[account];
        uint256 claimedAmount = userInfo.claimedAmount;
        releaseAmount = getReleaseAmount(userInfo.buyTokenAmount);
        if (releaseAmount > claimedAmount) {
            pendingReward = releaseAmount - claimedAmount;
        }
    }

    receive() external payable {}

    function addSale(uint256 usdtAmount, uint256 tokenAmount, uint256 qty) external onlyOwner {
        _saleInfo.push(SaleInfo(usdtAmount, tokenAmount, qty, 0));
    }

    function setPrice(uint256 saleId, uint256 price) external onlyOwner {
        _saleInfo[saleId].price = price;
    }

    function setTokenAmount(uint256 saleId, uint256 tokenAmount) external onlyOwner {
        _saleInfo[saleId].tokenAmount = tokenAmount;
    }

    function setQty(uint256 saleId, uint256 qty) external onlyOwner {
        _saleInfo[saleId].qty = qty;
    }

    function startClaim() external onlyOwner {
        _pauseClaim = false;
        _releaseStartTime = block.timestamp;
    }

    function setReleaseStartTime(uint256 time) external onlyOwner {
        _releaseStartTime = time;
    }

    function setReleaseDuration(uint256 duration) external onlyOwner {
        _releaseDuration = duration;
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

    function claimBalance() external {
        address payable addr = payable(_cashAddress);
        addr.transfer(address(this).balance);
    }

    function claimToken(address erc20Address) external onlyOwner {
        IERC20 erc20 = IERC20(erc20Address);
        erc20.transfer(_cashAddress, erc20.balanceOf(address(this)));
    }
}

contract RTHSale is AbsPreSale {
    constructor() AbsPreSale(
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
    //RTH
        address(0x81881C1A3049FFd0dC8EeA547297cE389A1f8250),
    //Cash
        address(0xE83Be1C851860Dce4a60A9EEE598370A4f923818)
    ){

    }
}