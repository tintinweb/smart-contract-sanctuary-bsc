/**
 *Submitted for verification at BscScan.com on 2022-10-03
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

    function token1() external view returns (address);
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

abstract contract AbsSale is Ownable {
    struct SaleInfo {
        uint256 price;
        uint256 duration;
    }

    struct UserInfo {
        uint256 amount;
        uint256 endTime;
    }

    address public _cashAddress;
    address private _tokenAddress;
    address private _usdtAddress;
    ISwapFactory public _factory;

    SaleInfo[] private _saleInfo;
    mapping(address => UserInfo) private _userInfo;

    uint256 private _totalToken;
    uint256 public constant MAX = ~uint256(0);

    constructor(address SwapRouter, address USDTAddress, address TokenAddress, address CashAddress){
        _factory = ISwapFactory(ISwapRouter(SwapRouter).factory());
        _usdtAddress = USDTAddress;
        _tokenAddress = TokenAddress;
        _cashAddress = CashAddress;

        uint256 usdtUnit = 10 ** IERC20(USDTAddress).decimals();

        _saleInfo.push(SaleInfo(3 * usdtUnit, 1 days));
        _saleInfo.push(SaleInfo(20 * usdtUnit, 30 days));
        _saleInfo.push(SaleInfo(60 * usdtUnit, 365 days));
        _saleInfo.push(SaleInfo(100 * usdtUnit, MAX));
    }

    function buy(uint256 saleId, uint256 maxTokenAmount) external {
        address account = msg.sender;
        SaleInfo storage sale = _saleInfo[saleId];
        UserInfo storage userInfo = _userInfo[account];
        uint256 endTime = userInfo.endTime;
        require(endTime != MAX, "Max");
        if (sale.duration == MAX) {
            userInfo.endTime = MAX;
        } else {
            if (endTime == 0) {
                userInfo.endTime = block.timestamp + sale.duration;
            } else {
                userInfo.endTime = endTime + sale.duration;
            }
        }

        uint256 price = sale.price;
        uint256 tokenAmount = getTokenAmount(price);
        require(maxTokenAmount >= tokenAmount, "maxAmount");
        if (tokenAmount == 0) {
            require(price == 0, "no tokenAmount");
        }
        userInfo.amount += tokenAmount;
        _totalToken += tokenAmount;
        _takeToken(_tokenAddress, account, price);
    }

    function addUserVipTime(address account, uint256 time) external onlyOwner {
        UserInfo storage userInfo = _userInfo[account];
        uint256 endTime = userInfo.endTime;
        require(endTime != MAX, "Max");
        if (time == MAX) {
            userInfo.endTime = MAX;
        } else {
            if (endTime == 0) {
                userInfo.endTime = block.timestamp + time;
            } else {
                userInfo.endTime = endTime + time;
            }
        }
    }

    function _takeToken(address tokenAddress, address account, uint256 tokenNum) private {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(account)) >= tokenNum, "token balance not enough");
        token.transferFrom(account, _cashAddress, tokenNum);
    }

    function allSales() external view returns (
        uint256[] memory usdtPrice, uint256[] memory tokenPrice, uint256[] memory duration
    ){
        uint256 len = getSaleLength();
        usdtPrice = new uint256[](len);
        tokenPrice = new uint256[](len);
        duration = new uint256[](len);
        for (uint256 i; i < len;) {
            (usdtPrice[i], tokenPrice[i], duration[i]) = getSaleInfo(i);
        unchecked{
            ++i;
        }
        }
    }

    function getSaleLength() public view returns (uint256){
        return _saleInfo.length;
    }

    function getSaleInfo(uint256 sid) public view returns (
        uint256 usdtPrice, uint256 tokenPrice, uint256 duration
    ) {
        SaleInfo storage sale = _saleInfo[sid];
        usdtPrice = sale.price;
        tokenPrice = getTokenAmount(usdtPrice);
        duration = sale.duration;
    }

    function shopInfo() external view returns (
        address usdtAddress, uint256 usdtDecimals, string memory usdtSymbol,
        address tokenAddress, uint256 tokenDecimals, string memory tokenSymbol,
        uint256 timestamp, uint256 totalToken
    ){
        usdtAddress = _usdtAddress;
        usdtDecimals = IERC20(usdtAddress).decimals();
        usdtSymbol = IERC20(usdtAddress).symbol();

        tokenAddress = _tokenAddress;
        tokenDecimals = IERC20(tokenAddress).decimals();
        tokenSymbol = IERC20(tokenAddress).symbol();

        timestamp = block.timestamp;
        totalToken = _totalToken;
    }

    receive() external payable {}

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
        _factory = ISwapFactory(ISwapRouter(adr).factory());
    }

    function setPrice(uint256 saleId, uint256 price) external onlyOwner {
        _saleInfo[saleId].price = price;
    }

    function setDuration(uint256 saleId, uint256 duration) external onlyOwner {
        _saleInfo[saleId].duration = duration;
    }

    function claimBalance(address to) external onlyOwner {
        address payable addr = payable(to);
        addr.transfer(address(this).balance);
    }

    function claimToken(address erc20Address, address to, uint256 amount) external onlyOwner {
        IERC20 erc20 = IERC20(erc20Address);
        erc20.transfer(to, amount);
    }

    function getUserInfo(address account) external view returns (
        uint256 amount,
        uint256 endTime,
        uint256 tokenBalance,
        uint256 tokenAllowance,
        uint256 blockTime
    ){
        UserInfo storage userInfo = _userInfo[account];
        amount = userInfo.amount;
        endTime = userInfo.endTime;
        tokenBalance = IERC20(_tokenAddress).balanceOf(account);
        tokenAllowance = IERC20(_tokenAddress).allowance(account, address(this));
        blockTime = block.timestamp;
    }

    function getTokenAmount(uint256 usdtAmount) public view returns (uint256 tokenAmount){
        address usdtAddress = _usdtAddress;
        address tokenAddress = _tokenAddress;
        address pairAddress = _factory.getPair(usdtAddress, tokenAddress);
        if (address(0) != pairAddress) {
            ISwapPair swapPair = ISwapPair(pairAddress);
            (uint256 reserve0, uint256 reserve1,) = swapPair.getReserves();
            uint256 usdtReserve;
            uint256 tokenReserve;
            if (usdtAddress < tokenAddress) {
                usdtReserve = reserve0;
                tokenReserve = reserve1;
            } else {
                usdtReserve = reserve1;
                tokenReserve = reserve0;
            }
            if (0 != usdtReserve) {
                tokenAmount = usdtAmount * tokenReserve / usdtReserve;
            }
        }
    }
}

contract VipSale is AbsSale {
    constructor() AbsSale(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
    //Token
        address(0xF328b529dc7f5f865D9aBC84DEEbF02a72Fcc4a5),
    //Cash
        address(0x000000000000000000000000000000000000dEaD)
    ){

    }
}