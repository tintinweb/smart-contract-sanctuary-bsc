/**
 *Submitted for verification at BscScan.com on 2022-09-19
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
        uint256 price;
        uint256 tokenNum;
        uint256 qty;
        uint256 saleNum;
    }

    struct UserInfo {
        uint256 buyNum;
        uint256 buyAmount;
        uint256 buyTokenAmount;
        uint256 claimedTokenAmount;
    }

    address public _cashAddress;
    address private _tokenAddress;
    address private _usdtAddress;

    SaleInfo[] private _saleInfo;
    mapping(address => UserInfo) private _userInfo;

    uint256 private _maxBuyNum = 1;

    bool private _pauseBuy = false;
    bool private _pauseClaim = true;

    uint256 private _endTime;
    uint256 private _totalUsdt;
    uint256 private _totalToken;

    constructor(address USDTAddress, address TokenAddress, address CashAddress){
        _usdtAddress = USDTAddress;
        _tokenAddress = TokenAddress;
        _cashAddress = CashAddress;

        uint256 usdtDecimals = 10 ** IERC20(USDTAddress).decimals();
        uint256 tokenDecimals = 10 ** IERC20(TokenAddress).decimals();

        _saleInfo.push(SaleInfo(200 * usdtDecimals, 100 * tokenDecimals, 550, 0));

        _endTime = block.timestamp + 864000;
    }

    function buy(uint256 saleId) external {
        require(!_pauseBuy, "pauseBuy");
        address account = msg.sender;

        SaleInfo storage sale = _saleInfo[saleId];
        require(sale.qty > sale.saleNum, "soldOut");

        UserInfo storage userInfo = _userInfo[account];
        require(_maxBuyNum > userInfo.buyNum, "gt maxBuyNum");

        sale.saleNum += 1;

        userInfo.buyNum += 1;
        uint256 price = sale.price;
        uint256 tokenNum = sale.tokenNum;
        userInfo.buyAmount += price;
        userInfo.buyTokenAmount += tokenNum;
        _totalToken += tokenNum;

        _takeToken(_usdtAddress, account, price);
        _totalUsdt += price;
    }

    function claim() external {
        address account = msg.sender;
        require(!_pauseClaim, "pauseClaim");
        UserInfo storage userInfo = _userInfo[account];
        uint256 pendingToken = userInfo.buyTokenAmount - userInfo.claimedTokenAmount;
        if (pendingToken > 0) {
            userInfo.claimedTokenAmount += pendingToken;
            _giveToken(account, pendingToken);
        }
    }

    function _giveToken(address account, uint256 tokenNum) private {
        IERC20 token = IERC20(_tokenAddress);
        require(token.balanceOf(address(this)) >= tokenNum, "shop token balance not enough");
        token.transfer(account, tokenNum);
    }

    function _takeToken(address tokenAddress, address account, uint256 tokenNum) private {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(account)) >= tokenNum, "token balance not enough");
        token.transferFrom(account, _cashAddress, tokenNum);
    }

    function getSaleLength() external view returns (uint256){
        return _saleInfo.length;
    }

    function getSaleInfo(uint256 sid) external view returns (
        uint256 price, uint256 tokenNum,
        uint256 qty, uint256 saleNum
    ) {
        SaleInfo memory sale = _saleInfo[sid];
        price = sale.price;
        tokenNum = sale.tokenNum;
        qty = sale.qty;
        saleNum = sale.saleNum;
    }

    function shopInfo() external view returns (
        address usdtAddress, uint256 usdtDecimals, string memory usdtSymbol,
        address tokenAddress, uint256 tokenDecimals, string memory tokenSymbol,
        uint256 maxBuyNum, bool pauseBuy, bool pauseClaim,
        uint256 endTime, uint256 timestamp,
        uint256 totalUsdt, uint256 totalToken
    ){
        tokenAddress = _tokenAddress;
        maxBuyNum = _maxBuyNum;
        timestamp = block.timestamp;
        pauseBuy = _pauseBuy;
        pauseClaim = _pauseClaim;
        endTime = _endTime;
        tokenDecimals = IERC20(tokenAddress).decimals();
        tokenSymbol = IERC20(tokenAddress).symbol();
        totalUsdt = _totalUsdt;
        totalToken = _totalToken;
        usdtAddress = _usdtAddress;
        usdtDecimals = IERC20(usdtAddress).decimals();
        usdtSymbol = IERC20(usdtAddress).symbol();
    }

    receive() external payable {}

    function setTokenAddress(address adr) external onlyOwner {
        _tokenAddress = adr;
    }

    function setUsdtAddress(address adr) external onlyOwner {
        _usdtAddress = adr;
    }

    function setPauseBuy(bool pause) external onlyOwner {
        _pauseBuy = pause;
    }

    function setPauseClaim(bool pause) external onlyOwner {
        _pauseClaim = pause;
    }

    function setQty(uint256 saleId, uint256 qty) external onlyOwner {
        _saleInfo[saleId].qty = qty;
    }

    function setPrice(uint256 saleId, uint256 price, uint256 tokenNum) external onlyOwner {
        _saleInfo[saleId].price = price * 10 ** IERC20(_usdtAddress).decimals();
        _saleInfo[saleId].tokenNum = tokenNum * 10 ** IERC20(_tokenAddress).decimals();
    }

    function setEndTime(uint256 endTime) external onlyOwner {
        _endTime = endTime;
    }

    function setMaxBuyNum(uint256 max) external onlyOwner {
        _maxBuyNum = max;
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
        uint256 buyNum,
        uint256 buyAmount,
        uint256 buyTokenAmount,
        uint256 claimedTokenAmount,
        uint256 balance,
        uint256 allowance
    ){
        UserInfo storage userInfo = _userInfo[account];
        buyNum = userInfo.buyNum;
        buyAmount = userInfo.buyAmount;
        buyTokenAmount = userInfo.buyTokenAmount;
        claimedTokenAmount = userInfo.claimedTokenAmount;
        balance = IERC20(_usdtAddress).balanceOf(account);
        allowance = IERC20(_usdtAddress).allowance(account, address(this));
    }
}

contract BCakePreSale is AbsPreSale {
    constructor() AbsPreSale(
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
    //Token
        address(0xCA7BE6d8B90130353e2eF851Ab1373050EAAf2BD),
    //Cash
        address(0x7a27270AF3C76c6Ecf0Efa82554742370C28Ed59)
    ){

    }
}