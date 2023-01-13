/**
 *Submitted for verification at BscScan.com on 2023-01-13
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
        address tokenAddress;
        uint256 price;
        uint256 tokenAmount;
        uint256 qty;
        uint256 inviteFee;
        address cashAddress;
        bool pauseBuy;
        bool pauseClaim;
        uint256 saleNum;
        uint256 totalUsdt;
        uint256 totalInviteUsdt;
        uint256 totalTokenAmount;
    }

    struct UserInfo {
        uint256 buyUsdt;
        uint256 buyTokenAmount;
        uint256 claimedTokenAmount;
        uint256 teamUsdt;
        uint256 inviteUsdt;
    }

    address private _usdtAddress;

    SaleInfo[] private _saleInfo;
    mapping(address => uint256) private _userBuyNum;
    mapping(uint256 => mapping(address => UserInfo)) private _userInfo;

    mapping(address => address) public _invitor;
    mapping(address => address[]) public _binder;
    uint256 public constant _feeDivFactor = 10000;

    constructor(
        address USDTAddress
    ){
        _usdtAddress = USDTAddress;
    }

    function buy(uint256 saleId, address invitor) external {
        SaleInfo storage sale = _saleInfo[saleId];
        require(!sale.pauseBuy, "pauseBuy");
        require(sale.qty > sale.saleNum, "soldOut");

        address account = msg.sender;
        UserInfo storage userInfo = _userInfo[saleId][account];
        require(userInfo.buyTokenAmount == 0, "bought");

        if (0 == _userBuyNum[account]) {
            if (_userBuyNum[invitor] > 0) {
                _invitor[account] = invitor;
                _binder[invitor].push(account);
            }
        }
        _userBuyNum[account] += 1;

        uint256 usdtAmount = sale.price;
        uint256 tokenAmount = sale.tokenAmount;

        userInfo.buyUsdt += usdtAmount;
        userInfo.buyTokenAmount += tokenAmount;

        sale.saleNum += 1;
        sale.totalTokenAmount += tokenAmount;
        sale.totalUsdt += usdtAmount;

        address usdtAddress = _usdtAddress;
        _takeToken(usdtAddress, account, address(this), usdtAmount);

        uint256 cashAmount = usdtAmount;

        invitor = _invitor[account];
        if (address(0) != invitor) {
            UserInfo storage invitorInfo = _userInfo[saleId][invitor];
            invitorInfo.teamUsdt += usdtAmount;

            uint256 inviteUsdt = usdtAmount * sale.inviteFee / _feeDivFactor;
            sale.totalInviteUsdt += inviteUsdt;
            cashAmount -= inviteUsdt;
            invitorInfo.inviteUsdt += inviteUsdt;
            _giveToken(usdtAddress, invitor, inviteUsdt);
        }

        _giveToken(usdtAddress, sale.cashAddress, cashAmount);
    }

    function claim(uint256 saleId) external {
        SaleInfo storage sale = _saleInfo[saleId];
        require(!sale.pauseClaim, "pauseClaim");

        address account = msg.sender;
        UserInfo storage userInfo = _userInfo[saleId][account];
        uint256 pendingToken = userInfo.buyTokenAmount - userInfo.claimedTokenAmount;
        require(pendingToken > 0, "nAmount");
        userInfo.claimedTokenAmount += pendingToken;
        _giveToken(sale.tokenAddress, account, pendingToken);
    }

    function _giveToken(address tokenAddress, address account, uint256 tokenNum) private {
        if (0 == tokenNum) {
            return;
        }
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(this)) >= tokenNum, "shop token ne");
        token.transfer(account, tokenNum);
    }

    function _takeToken(address tokenAddress, address sender, address receiver, uint256 tokenNum) private {
        if (0 == tokenNum) {
            return;
        }
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(sender)) >= tokenNum, "token ne");
        token.transferFrom(sender, receiver, tokenNum);
    }

    function baseInfo() external view returns (
        address usdtAddress, uint256 usdtDecimals, string memory usdtSymbol,
        uint256 saleLength
    ){
        usdtAddress = _usdtAddress;
        usdtDecimals = IERC20(usdtAddress).decimals();
        usdtSymbol = IERC20(usdtAddress).symbol();
        saleLength = _saleInfo.length;
    }

    receive() external payable {}

    function addSale(
        address tokenAddress,
        uint256 price,
        uint256 tokenAmount,
        uint256 qty,
        uint256 inviteFee,
        address cashAddress
    ) external onlyOwner {
        require(tokenAmount > 0, "tokenAmount 0");
        _saleInfo.push(SaleInfo({
        tokenAddress : tokenAddress,
        price : price,
        tokenAmount : tokenAmount,
        qty : qty,
        inviteFee : inviteFee,
        cashAddress : cashAddress,
        pauseBuy : false,
        pauseClaim : true,
        saleNum : 0,
        totalUsdt : 0,
        totalInviteUsdt : 0,
        totalTokenAmount : 0
        }));
    }

    function setUsdtAddress(address adr) external onlyOwner {
        _usdtAddress = adr;
    }

    function setTokenAddress(uint256 saleId, address adr) external onlyOwner {
        _saleInfo[saleId].tokenAddress = adr;
    }

    function setCashAddress(uint256 saleId, address adr) external onlyOwner {
        _saleInfo[saleId].cashAddress = adr;
    }

    function setPauseBuy(uint256 saleId, bool pause) external onlyOwner {
        _saleInfo[saleId].pauseBuy = pause;
    }

    function setPauseClaim(uint256 saleId, bool pause) external onlyOwner {
        _saleInfo[saleId].pauseClaim = pause;
    }

    function setInviteFee(uint256 saleId, uint256 fee) external onlyOwner {
        _saleInfo[saleId].inviteFee = fee;
    }

    function setQty(uint256 saleId, uint256 qty) external onlyOwner {
        require(qty >= _saleInfo[saleId].saleNum, "< saleNum");
        _saleInfo[saleId].qty = qty;
    }

    function setPrice(uint256 saleId, uint256 price) external onlyOwner {
        _saleInfo[saleId].price = price;
    }

    function setTokenAmount(uint256 saleId, uint256 amount) external onlyOwner {
        require(amount > 0, "amount 0");
        _saleInfo[saleId].tokenAmount = amount;
    }

    function claimBalance(address to, uint256 amount) external onlyOwner {
        address payable addr = payable(to);
        addr.transfer(amount);
    }

    function claimToken(address erc20Address, address to, uint256 amount) external onlyOwner {
        IERC20 erc20 = IERC20(erc20Address);
        erc20.transfer(to, amount);
    }

    function getBinderLength(address account) external view returns (uint256){
        return _binder[account].length;
    }

    function getUserInfo(address account) external view returns (
        address invitor,
        uint256 binderLength,
        uint256 buyNum,
        uint256 usdtBalance,
        uint256 usdtAllowance
    ){
        invitor = _invitor[account];
        binderLength = _binder[account].length;
        buyNum = _userBuyNum[account];
        usdtBalance = IERC20(_usdtAddress).balanceOf(account);
        usdtAllowance = IERC20(_usdtAddress).allowance(account, address(this));
    }

    function getSaleInfo(uint256 saleId) public view returns (
        uint256 price, bool pauseBuy,
        uint256 tokenAmount, uint256 tokenDecimals, string memory tokenSymbol,
        uint256 qty, uint256 saleNum
    ) {
        SaleInfo storage sale = _saleInfo[saleId];
        price = sale.price;
        pauseBuy = sale.pauseBuy;
        tokenAmount = sale.tokenAmount;
        address tokenAddress = sale.tokenAddress;
        tokenDecimals = IERC20(tokenAddress).decimals();
        tokenSymbol = IERC20(tokenAddress).symbol();
        qty = sale.qty;
        saleNum = sale.saleNum;
    }

    function getSaleInfoList(uint256 start, uint256 len) external view returns (
        uint256 returnLen,
        uint256[] memory price, bool[] memory pauseBuy,
        uint256[] memory tokenAmount, uint256[] memory tokenDecimals, string[] memory tokenSymbol,
        uint256[] memory qty, uint256[] memory saleNum
    ){
        if (0 == len || len > _saleInfo.length - start) {
            len = _saleInfo.length - start;
        }
        returnLen = len;

        price = new uint256[](len);
        pauseBuy = new bool[](len);
        tokenAmount = new uint256[](len);
        tokenDecimals = new uint256[](len);
        tokenSymbol = new string[](len);
        qty = new uint256[](len);
        saleNum = new uint256[](len);

        uint256 index = 0;
        for (uint256 i = start; i < start + len; ++i) {
            if (i >= _saleInfo.length) {
                return (index, price, pauseBuy, tokenAmount, tokenDecimals, tokenSymbol, qty, saleNum);
            }
            (price[index], pauseBuy[index],
            tokenAmount[index], tokenDecimals[index], tokenSymbol[index],
            qty[index], saleNum[index]) = getSaleInfo(i);
            ++index;
        }
    }

    function getSaleExtInfo(uint256 saleId) public view returns (
        address tokenAddress, uint256 inviteFee, address cashAddress,
        uint256 totalUsdt, uint256 totalInviteUsdt, uint256 totalTokenAmount,
        bool pauseClaim
    ){
        SaleInfo storage sale = _saleInfo[saleId];
        tokenAddress = sale.tokenAddress;
        inviteFee = sale.inviteFee;
        cashAddress = sale.cashAddress;
        totalUsdt = sale.totalUsdt;
        totalInviteUsdt = sale.totalInviteUsdt;
        totalTokenAmount = sale.totalTokenAmount;
        pauseClaim = sale.pauseClaim;
    }

    function getSaleExtInfoList(uint256 start, uint256 len) external view returns (
        uint256 returnLen,
        address[] memory tokenAddress, uint256[] memory inviteFee, address[] memory cashAddress,
        uint256[] memory totalUsdt, uint256[] memory totalInviteUsdt, uint256[] memory totalTokenAmount,
        bool[] memory pauseClaim
    ){
        if (0 == len || len > _saleInfo.length - start) {
            len = _saleInfo.length - start;
        }
        returnLen = len;

        tokenAddress = new address[](len);
        inviteFee = new uint256[](len);
        cashAddress = new address[](len);
        totalUsdt = new uint256[](len);
        totalInviteUsdt = new uint256[](len);
        totalTokenAmount = new uint256[](len);
        pauseClaim = new bool[](len);

        uint256 index = 0;
        for (uint256 i = start; i < start + len; ++i) {
            if (i >= _saleInfo.length) {
                return (index, tokenAddress, inviteFee, cashAddress, totalUsdt, totalInviteUsdt, totalTokenAmount, pauseClaim);
            }
            (tokenAddress[index], inviteFee[index], cashAddress[index],
            totalUsdt[index], totalInviteUsdt[index], totalTokenAmount[index],
            pauseClaim[index]) = getSaleExtInfo(i);
            ++index;
        }
    }

    function getUserSaleInfo(address account, uint256 saleId) public view returns (
        uint256 buyUsdt, uint256 buyTokenAmount, uint256 claimedTokenAmount,
        uint256 teamUsdt, uint256 inviteUsdt
    ){
        UserInfo storage userInfo = _userInfo[saleId][account];
        buyUsdt = userInfo.buyUsdt;
        buyTokenAmount = userInfo.buyTokenAmount;
        claimedTokenAmount = userInfo.claimedTokenAmount;
        teamUsdt = userInfo.teamUsdt;
        inviteUsdt = userInfo.inviteUsdt;
    }

    function getUserSaleInfoList(address account, uint256 start, uint256 len) external view returns (
        uint256 returnLen,
        uint256[] memory buyUsdt, uint256[] memory buyTokenAmount, uint256[] memory claimedTokenAmount,
        uint256[] memory teamUsdt, uint256[] memory inviteUsdt
    ){
        if (0 == len || len > _saleInfo.length - start) {
            len = _saleInfo.length - start;
        }
        returnLen = len;

        buyUsdt = new uint256[](len);
        buyTokenAmount = new uint256[](len);
        claimedTokenAmount = new uint256[](len);
        teamUsdt = new uint256[](len);
        inviteUsdt = new uint256[](len);

        uint256 index = 0;
        for (uint256 i = start; i < start + len; ++i) {
            if (i >= _saleInfo.length) {
                return (index, buyUsdt, buyTokenAmount, claimedTokenAmount, teamUsdt, inviteUsdt);
            }
            (buyUsdt[index], buyTokenAmount[index], claimedTokenAmount[index],
            teamUsdt[index], inviteUsdt[index]) = getUserSaleInfo(account, i);
            ++index;
        }
    }
}

contract IDOS is AbsPreSale {
    constructor() AbsPreSale(
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955)
    ){

    }
}