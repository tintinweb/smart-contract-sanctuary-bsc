/**
 *Submitted for verification at BscScan.com on 2022-11-29
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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract AbsSale is Ownable {
    struct SaleInfo {
        uint256 usdtAmount;
        uint256 saleNum;
    }

    struct UserInfo {
        uint256 buyUsdt;
        uint256 inviteUsdt;
    }

    address public _cashAddress;
    address private _usdtAddress;

    SaleInfo private _saleInfo;
    mapping(address => UserInfo) private _userInfo;

    bool private _pauseBuy = false;

    uint256 private _totalUsdt;
    uint256 private _totalInviteUsdt;

    mapping(address => address) public _invitor;
    mapping(address => address[]) public _binder;
    uint256 public _inviteLength = 10;
    mapping(uint256 => uint256) public _inviteFee;
    uint256 public constant _feeDivFactor = 10000;

    uint256 public _totalAccount;

    constructor(
        address USDTAddress, address CashAddress
    ){
        _usdtAddress = USDTAddress;
        _cashAddress = CashAddress;

        uint256 usdtUnit = 10 ** IERC20(USDTAddress).decimals();

        _saleInfo = SaleInfo(300 * usdtUnit, 0);

        _inviteFee[0] = 80 * usdtUnit;
        _inviteFee[1] = 40 * usdtUnit;
        for (uint256 i = 2; i < 17; ++i) {
            _inviteFee[i] = 20 * usdtUnit;
        }
    }

    function buy(address invitor) external {
        require(!_pauseBuy, "pauseBuy");
        address account = msg.sender;

        UserInfo storage userInfo = _userInfo[account];
        require(userInfo.buyUsdt == 0, "bought");

        if (_userInfo[invitor].buyUsdt > 0) {
            _invitor[account] = invitor;
            _binder[invitor].push(account);
        }
        _totalAccount++;

        SaleInfo storage sale = _saleInfo;
        uint256 usdtAmount = sale.usdtAmount;
        sale.saleNum += 1;

        userInfo.buyUsdt += usdtAmount;

        _totalUsdt += usdtAmount;

        _takeToken(_usdtAddress, account, address(this), usdtAmount);

        uint256 cashAmount = usdtAmount;

        uint256 len = _inviteLength;
        address current = account;
        for (uint256 i = 0; i < len; ++i) {
            invitor = _invitor[current];
            if (address(0) == invitor) {
                break;
            }
            uint256 inviteUsdt = _inviteFee[i];
            _totalInviteUsdt += inviteUsdt;
            cashAmount -= inviteUsdt;
            UserInfo storage invitorInfo = _userInfo[invitor];
            invitorInfo.inviteUsdt += inviteUsdt;
            _giveToken(_usdtAddress, invitor, inviteUsdt);

            current = invitor;
        }

        _giveToken(_usdtAddress, _cashAddress, cashAmount);
    }

    function _giveToken(address tokenAddress, address account, uint256 tokenNum) private {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(this)) >= tokenNum, "shop token not enough");
        token.transfer(account, tokenNum);
    }

    function _takeToken(address tokenAddress, address sender, address receiver, uint256 tokenNum) private {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(sender)) >= tokenNum, "token not enough");
        token.transferFrom(sender, receiver, tokenNum);
    }

    function saleInfo() external view returns (
        uint256 priceUsdt, uint256 saleNum
    ) {
        SaleInfo storage sale = _saleInfo;
        priceUsdt = sale.usdtAmount;
        saleNum = sale.saleNum;
    }

    function shopInfo() external view returns (
        address usdtAddress, uint256 usdtDecimals, string memory usdtSymbol,
        bool pauseBuy, uint256 totalUsdt, uint256 totalInviteUsdt
    ){
        usdtAddress = _usdtAddress;
        usdtDecimals = IERC20(usdtAddress).decimals();
        usdtSymbol = IERC20(usdtAddress).symbol();
        pauseBuy = _pauseBuy;
        totalUsdt = _totalUsdt;
        totalInviteUsdt = _totalInviteUsdt;
    }

    receive() external payable {}

    function setUsdtAddress(address adr) external onlyOwner {
        _usdtAddress = adr;
    }

    function setCashAddress(address adr) external onlyOwner {
        _cashAddress = adr;
    }

    function setPauseBuy(bool pause) external onlyOwner {
        _pauseBuy = pause;
    }

    function setInviteFee(uint256 i, uint256 fee) external onlyOwner {
        _inviteFee[i] = fee;
    }

    function setInviteLength(uint256 len) external onlyOwner {
        _inviteLength = len;
    }

    function setPrice(uint256 priceUsdt) external onlyOwner {
        _saleInfo.usdtAmount = priceUsdt;
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
        uint256 buyUsdt,
        uint256 inviteUsdt,
        address invitor,
        uint256 usdtBalance,
        uint256 usdtAllowance
    ){
        UserInfo storage userInfo = _userInfo[account];
        buyUsdt = userInfo.buyUsdt;
        inviteUsdt = userInfo.inviteUsdt;
        invitor = _invitor[account];
        usdtBalance = IERC20(_usdtAddress).balanceOf(account);
        usdtAllowance = IERC20(_usdtAddress).allowance(account, address(this));
    }
}

contract VipSale is AbsSale {
    constructor() AbsSale(
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
    //Cash
        address(0xC431ec33903a2676124D63bcCF61a4815DB1d1f2)
    ){

    }
}