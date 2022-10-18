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

interface ISwapRouter {
    function WETH() external pure returns (address);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
}

abstract contract AbsPreSale is Ownable {
    struct SaleInfo {
        uint256 price;
        uint256 saleNum;
    }

    struct UserInfo {
        uint256 buyBNBAmount;
        uint256 buyTokenAmount;
        uint256 claimedAmount;
        bool isOverflow;
    }

    address public _usdtAddress;
    address public _cashAddress;
    address private _tokenAddress;

    SaleInfo[] private _saleInfo;
    mapping(address => UserInfo) private _userInfo;

    bool private _pauseBuy = false;
    bool private _pauseClaim = true;

    uint256 private _totalBNB;
    uint256 private _qtyBNB;
    uint256 private _tokenAmountPerBNB;

    uint256 public _overflowReleaseDuration = 90 days;
    uint256 public _overflowReleaseMin = 5000;
    uint256 public _overflowReleaseMax = 25000;
    uint256 public constant _divFactor = 10000;
    uint256 public _overflowReleaseStartTime;

    address public _swapRouter;

    constructor(address UsdtAddress, address TokenAddress, address CashAddress, address SwapRouter){
        _tokenAddress = TokenAddress;
        _usdtAddress = UsdtAddress;
        _cashAddress = CashAddress;
        _swapRouter = SwapRouter;

        uint256 bnbUnit = 1 ether;
        uint256 tokenUnit = 10 ** IERC20(TokenAddress).decimals();

        _saleInfo.push(SaleInfo(1 * bnbUnit, 0));
        _saleInfo.push(SaleInfo(2 * bnbUnit, 0));
        _saleInfo.push(SaleInfo(3 * bnbUnit, 0));

        _qtyBNB = 1002 * bnbUnit;
        _tokenAmountPerBNB = 1497005 * tokenUnit;
    }

    function buy(uint256 saleId) external payable {
        require(!_pauseBuy, "pauseBuy");
        address account = msg.sender;
        UserInfo storage userInfo = _userInfo[account];
        require(userInfo.buyBNBAmount == 0, "bought");

        SaleInfo storage sale = _saleInfo[saleId];
        uint256 price = sale.price;
        require(msg.value >= price, "invalid value");

        uint256 qtyBNB = _qtyBNB;
        uint256 totalBNB = _totalBNB;
        if (qtyBNB > totalBNB) {
            require(qtyBNB >= totalBNB + price, "no qty");
            uint256 tokenAmount = price * _tokenAmountPerBNB / 1 ether;
            userInfo.buyTokenAmount = tokenAmount;
        } else {
            userInfo.isOverflow = true;
        }

        sale.saleNum += 1;
        userInfo.buyBNBAmount = price;

        _cashAddress.call{value : price}("");
        _totalBNB += price;
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

    function getReleaseRate() public view returns (uint256 rate){
        uint256 startTime = _overflowReleaseStartTime;
        if (0 == startTime) {
            return 0;
        }
        uint256 blockTime = block.timestamp;
        if (startTime >= blockTime) {
            return 0;
        }
        uint256 duration = blockTime - startTime;
        uint256 maxDuration = _overflowReleaseDuration;
        if (duration > maxDuration) {
            duration = maxDuration;
        }
        uint256 min = _overflowReleaseMin;
        uint256 margin = _overflowReleaseMax - min;
        return min + margin * duration / maxDuration;
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
        uint256 bnbUnit = 1 ether;
        for (uint256 i; i < len; i++) {
            SaleInfo storage sale = _saleInfo[i];
            prices[i] = sale.price;
            tokenNum[i] = prices[i] * _tokenAmountPerBNB / bnbUnit;
            saleNum[i] = sale.saleNum;
        }
    }

    function shopInfo() external view returns (
        address tokenAddress, uint256 tokenDecimals, string memory tokenSymbol,
        uint256 qtyBNB, uint256 totalBNB, uint256 tokenAmountPerBNB,
        bool pauseBuy, bool pauseClaim
    ){
        tokenAddress = _tokenAddress;
        tokenDecimals = IERC20(tokenAddress).decimals();
        tokenSymbol = IERC20(tokenAddress).symbol();
        qtyBNB = _qtyBNB;
        totalBNB = _totalBNB;
        tokenAmountPerBNB = _tokenAmountPerBNB;
        pauseBuy = _pauseBuy;
        pauseClaim = _pauseClaim;

    }

    function getUserInfo(address account) external view returns (
        uint256 pendingReward, uint256 releaseRate,
        uint256 balance, uint256 buyBNBAmount,
        uint256 buyTokenAmount, uint256 claimedAmount,
        bool isOverflow
    ){
        (pendingReward, releaseRate) = getPendingReward(account);
        balance = account.balance;
        UserInfo storage userInfo = _userInfo[account];
        buyBNBAmount = userInfo.buyBNBAmount;
        buyTokenAmount = userInfo.buyTokenAmount;
        claimedAmount = userInfo.claimedAmount;
        isOverflow = userInfo.isOverflow;
    }

    function getPendingReward(address account) public view returns (uint256 pendingReward, uint256 releaseRate){
        UserInfo storage userInfo = _userInfo[account];
        uint256 claimedAmount = userInfo.claimedAmount;
        if (claimedAmount > 0) {
            return (0, 0);
        }
        if (!userInfo.isOverflow) {
            pendingReward = userInfo.buyTokenAmount;
            releaseRate = 10000;
        } else {
            releaseRate = getReleaseRate();
            if (releaseRate > 0) {
                uint256 bnbAmount = userInfo.buyBNBAmount * releaseRate / _divFactor;
                ISwapRouter swapRouter = ISwapRouter(_swapRouter);
                address[] memory path = new address[](3);
                path[0] = swapRouter.WETH();
                path[1] = _usdtAddress;
                path[2] = _tokenAddress;
                uint256[] memory amountOuts = swapRouter.getAmountsOut(bnbAmount, path);
                pendingReward = amountOuts[amountOuts.length - 1];
            }
        }
    }

    receive() external payable {}

    function addSale(uint256 bnbAmount) external onlyOwner {
        _saleInfo.push(SaleInfo(bnbAmount, 0));
    }

    function setPrice(uint256 saleId, uint256 price) external onlyOwner {
        _saleInfo[saleId].price = price;
    }

    function startClaim() external onlyOwner {
        _pauseClaim = false;
        _overflowReleaseStartTime = block.timestamp;
    }

    function setReleaseStartTime(uint256 time) external onlyOwner {
        _overflowReleaseStartTime = time;
    }

    function setMinRate(uint256 minRate) external onlyOwner {
        _overflowReleaseMin = minRate;
    }

    function setMaxRate(uint256 maxRate) external onlyOwner {
        _overflowReleaseMax = maxRate;
    }

    function setReleaseDuration(uint256 duration) external onlyOwner {
        _overflowReleaseDuration = duration;
    }

    function setQtyBNB(uint256 qty) external onlyOwner {
        _qtyBNB = qty;
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

    function setSwapRouter(address adr) external onlyOwner {
        _swapRouter = adr;
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

contract QMPPreSale is AbsPreSale {
    constructor() AbsPreSale(
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
    //QMP
        address(0xf925Ea6BB50E03BDb6c56EFaC85ED870E50cb623),
    //Cash
        address(0x6A89FCCAE4d627903108308B251e869812E8eF2E),
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E)
    ){

    }
}