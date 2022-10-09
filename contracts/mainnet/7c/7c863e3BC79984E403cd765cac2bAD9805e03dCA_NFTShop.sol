/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface INFT {
    function totalSupply() external view returns (uint256);

    function batchMint(address to, uint256 num) external;

    function balanceOf(address owner) external view returns (uint256 balance);
}

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

abstract contract AbsShop is Ownable {
    struct SaleInfo {
        address nftAddress;
        uint256 price;
        uint256 qty;
        uint256 soldNum;
    }

    SaleInfo[] private _saleInfo;
    address private _usdt;
    address private _token;
    address public _cash;

    ISwapRouter public _swapRouter;
    ISwapFactory public _factory;
    bool private _pauseBuy;

    constructor(address RouterAddress, address USDTAddress, address TokenAddress, address CashAddress){
        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _swapRouter = swapRouter;
        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        _factory = swapFactory;

        _usdt = USDTAddress;
        _token = TokenAddress;
        _cash = CashAddress;
    }

    function buy(uint256 saleId, uint256 num, uint256 maxToken) external {
        require(!_pauseBuy, "pauseBuy");

        address account = msg.sender;
        require(tx.origin == account, "no origin");

        SaleInfo storage saleInfo = _saleInfo[saleId];
        require(saleInfo.qty >= saleInfo.soldNum + num, "no qty");

        uint256 unitUsdtTokenAmount = getUnitUsdtTokenAmount();
        require(unitUsdtTokenAmount > 0, "tokenPrice 0");

        saleInfo.soldNum += num;
        uint256 usdtAmount = saleInfo.price * num;
        uint256  tokenAmount= usdtAmount * unitUsdtTokenAmount / (10 ** IERC20(_usdt).decimals());
        require(maxToken >= tokenAmount, "maxToken");
        _takeToken(_token, account, tokenAmount);
        _takeToken(_usdt, account, usdtAmount);

        INFT(saleInfo.nftAddress).batchMint(account, num);
    }

    function _takeToken(address tokenAddress, address account, uint256 tokenNum) private {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(account)) >= tokenNum, "token balance not enough");
        token.transferFrom(account, _cash, tokenNum);
    }

    function getSaleInfo(uint256 saleId) public view returns (
        address nftAddress,
        uint256 price,
        uint256 priceUsdt,
        uint256 qty,
        uint256 soldNum
    ){
        SaleInfo storage saleInfo = _saleInfo[saleId];
        nftAddress = saleInfo.nftAddress;
        priceUsdt = saleInfo.price;
        price = getUnitUsdtTokenAmount() * priceUsdt / (10 ** IERC20(_usdt).decimals());
        qty = saleInfo.qty;
        soldNum = saleInfo.soldNum;
    }

    function getSaleLength() public view returns (uint256){
        return _saleInfo.length;
    }

    function allSaleInfo() external view returns (
        address[] memory nftAddress,
        uint256[] memory price,
        uint256[] memory priceUsdt,
        uint256[] memory qty,
        uint256[] memory soldNum
    ){
        uint256 len = _saleInfo.length;
        nftAddress = new address[](len);
        price = new uint256[](len);
        priceUsdt = new uint256[](len);
        qty = new uint256[](len);
        soldNum = new uint256[](len);
        for (uint256 i = 0; i < len; ++i) {
            (nftAddress[i], price[i], priceUsdt[i], qty[i], soldNum[i]) = getSaleInfo(i);
        }
    }

    function getBaseInfo() public view returns (
        bool pauseBuy,
        address usdtAddress, uint256 usdtDecimals, string memory usdtSymbol,
        address tokenAddress, uint256 tokenDecimals, string memory tokenSymbol
    ){
        pauseBuy = _pauseBuy;
        usdtAddress = _usdt;
        usdtDecimals = IERC20(usdtAddress).decimals();
        usdtSymbol = IERC20(usdtAddress).symbol();
        tokenAddress = _token;
        tokenDecimals = IERC20(tokenAddress).decimals();
        tokenSymbol = IERC20(tokenAddress).symbol();
    }

    function getUserInfo(address account) public view returns (
        uint256 usdtBalance, uint256 usdtAllowance,
        uint256 tokenBalance, uint256 tokenAllowance,
        uint256[] memory nftBalances
    ){
        usdtBalance = IERC20(_usdt).balanceOf(account);
        usdtAllowance = IERC20(_usdt).allowance(account, address(this));
        tokenBalance = IERC20(_token).balanceOf(account);
        tokenAllowance = IERC20(_token).allowance(account, address(this));
        uint256 len = getSaleLength();
        nftBalances = new uint256[](len);
        for (uint256 i; i < len; ++i) {
            nftBalances[i] = INFT(_saleInfo[i].nftAddress).balanceOf(account);
        }
    }

    function setToken(address tokenAddress) external onlyOwner {
        _token = tokenAddress;
    }

    function setUsdt(address usdtAddress) external onlyOwner {
        _usdt = usdtAddress;
    }

    function setPause(bool pause) external onlyOwner {
        _pauseBuy = pause;
    }

    function addSaleInfo(
        address nftAddress,
        uint256 price,
        uint256 qty
    ) external onlyOwner {
        _saleInfo.push(SaleInfo(nftAddress, price, qty, 0));
    }

    function setPrice(
        uint256 saleId,
        uint256 price
    ) external onlyOwner {
        SaleInfo storage saleInfo = _saleInfo[saleId];
        saleInfo.price = price;
    }

    function setQty(
        uint256 saleId,
        uint256 qty
    ) external onlyOwner {
        SaleInfo storage saleInfo = _saleInfo[saleId];
        saleInfo.qty = qty;
    }

    function setNFTAddress(
        uint256 saleId,
        address nftAddress
    ) external onlyOwner {
        SaleInfo storage saleInfo = _saleInfo[saleId];
        saleInfo.nftAddress = nftAddress;
    }

    function claimBalance(address to, uint256 amount) external onlyOwner {
        payable(to).transfer(amount);
    }

    function claimToken(address token, address to, uint256 amount) external onlyOwner {
        IERC20(token).transfer(to, amount);
    }

    function getTokenPrice() public view returns (uint256){
        address pairAddress = _factory.getPair(_usdt, _token);
        if (address(0) == pairAddress) {
            return 0;
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
        if (0 == tokenReverse) {
            return 0;
        }
        return 10 ** IERC20(_token).decimals() * usdtReverse / tokenReverse;
    }

    function getUnitUsdtTokenAmount() public view returns (uint256){
        address pairAddress = _factory.getPair(_usdt, _token);
        if (address(0) == pairAddress) {
            return 0;
        }
        ISwapPair swapPair = ISwapPair(pairAddress);
        (uint256 reverse0, uint256 reverse1,) = swapPair.getReserves();
        address usdt = _usdt;
        uint256 usdtReverse;
        uint256 tokenReverse;
        if (usdt < _token) {
            usdtReverse = reverse0;
            tokenReverse = reverse1;
        } else {
            usdtReverse = reverse1;
            tokenReverse = reverse0;
        }
        if (0 == usdtReverse) {
            return 0;
        }
        return 10 ** IERC20(_usdt).decimals() * tokenReverse / usdtReverse;
    }
}

contract NFTShop is AbsShop {
    constructor() AbsShop(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
    //Token
        address(0xdF763AeAa9D46C1fb3F033fFB2E093AaA6F4cb04),
    //Cash
        address(0x85547aa64ef9F1AB93bf140F7201f7Cd48D79731)
    ){

    }
}