/**
 *Submitted for verification at BscScan.com on 2022-11-25
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
        uint256 usdtAmount;
        uint256 tokenAmount;
        uint256 saleNum;
    }

    struct UserInfo {
        uint256 buyNum;
        uint256 buyUsdt;
        uint256 buyAmount;
        uint256 inviteUsdt;
    }

    address public _cashAddress;
    address private _tokenAddress;
    address private _usdtAddress;

    SaleInfo private _saleInfo;
    mapping(address => UserInfo) private _userInfo;

    uint256 private _maxBuyNum = 1;

    bool private _pauseBuy = false;

    uint256 private _totalUsdt;
    uint256 private _totalInviteUsdt;
    uint256 private _totalToken;

    mapping(address => address) public _invitor;
    mapping(address => address[]) public _binder;
    uint256 public _inviteLength = 2;
    mapping(uint256 => uint256) public _inviteFee;
    uint256 public constant _feeDivFactor = 10000;

    uint256 public _totalAccount;

    constructor(
        address USDTAddress, address TokenAddress, address CashAddress
    ){
        _usdtAddress = USDTAddress;
        _tokenAddress = TokenAddress;
        _cashAddress = CashAddress;

        uint256 usdtUnit = 10 ** IERC20(USDTAddress).decimals();
        uint256 tokenUnit = 10 ** IERC20(TokenAddress).decimals();

        _saleInfo = SaleInfo(32 * usdtUnit, 320 * tokenUnit, 0);

        _inviteFee[0] = 3000;
        _inviteFee[1] = 2000;
    }

    function buy(address invitor) external {
        require(!_pauseBuy, "pauseBuy");
        address account = msg.sender;

        UserInfo storage userInfo = _userInfo[account];
        uint256 buyNum = userInfo.buyNum;
        require(_maxBuyNum > buyNum, "> maxNum");

        if (buyNum == 0) {
            if (_userInfo[invitor].buyNum > 0) {
                _invitor[account] = invitor;
                _binder[invitor].push(account);
            }
            _totalAccount++;
        }

        SaleInfo storage sale = _saleInfo;
        uint256 usdtAmount = sale.usdtAmount;
        uint256 tokenAmount = sale.tokenAmount;
        sale.saleNum += 1;

        userInfo.buyNum += 1;
        userInfo.buyUsdt += usdtAmount;
        userInfo.buyAmount += tokenAmount;

        _totalToken += tokenAmount;
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
            uint256 inviteUsdt = usdtAmount * _inviteFee[i] / _feeDivFactor;
            _totalInviteUsdt += inviteUsdt;
            cashAmount -= inviteUsdt;
            UserInfo storage invitorInfo = _userInfo[invitor];
            invitorInfo.inviteUsdt += inviteUsdt;
            _giveToken(_usdtAddress, invitor, inviteUsdt);

            current = invitor;
        }

        _giveToken(_usdtAddress, _cashAddress, cashAmount);
        _giveToken(_tokenAddress, account, tokenAmount);
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
        uint256 priceUsdt, uint256 tokenAmount, uint256 saleNum
    ) {
        SaleInfo storage sale = _saleInfo;
        priceUsdt = sale.usdtAmount;
        tokenAmount = sale.tokenAmount;
        saleNum = sale.saleNum;
    }

    function shopInfo() external view returns (
        address usdtAddress, uint256 usdtDecimals, string memory usdtSymbol,
        address tokenAddress, uint256 tokenDecimals, string memory tokenSymbol,
        bool pauseBuy, uint256 maxBuyNum
    ){
        usdtAddress = _usdtAddress;
        usdtDecimals = IERC20(usdtAddress).decimals();
        usdtSymbol = IERC20(usdtAddress).symbol();
        tokenAddress = _tokenAddress;
        tokenDecimals = IERC20(tokenAddress).decimals();
        tokenSymbol = IERC20(tokenAddress).symbol();
        pauseBuy = _pauseBuy;
        maxBuyNum = _maxBuyNum;
    }

    function shopExtInfo() external view returns (
        uint256 totalUsdt, uint256 totalInviteUsdt, uint256 totalToken
    ){
        totalUsdt = _totalUsdt;
        totalInviteUsdt = _totalInviteUsdt;
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

    function setPauseBuy(bool pause) external onlyOwner {
        _pauseBuy = pause;
    }

    function setInviteFee(uint256 i, uint256 fee) external onlyOwner {
        _inviteFee[i] = fee;
    }

    function setInviteLength(uint256 len) external onlyOwner {
        _inviteLength = len;
    }

    function setPrice(uint256 priceUsdt, uint256 tokenAmount) external onlyOwner {
        _saleInfo.usdtAmount = priceUsdt;
        _saleInfo.tokenAmount = tokenAmount;
    }

    function setMaxBuyNum(uint256 max) external onlyOwner {
        _maxBuyNum = max;
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
        uint256 buyNum,
        uint256 buyUsdt,
        uint256 buyAmount,
        uint256 inviteUsdt,
        address invitor,
        uint256 usdtBalance,
        uint256 usdtAllowance
    ){
        UserInfo storage userInfo = _userInfo[account];
        buyNum = userInfo.buyNum;
        buyUsdt = userInfo.buyUsdt;
        buyAmount = userInfo.buyAmount;
        inviteUsdt = userInfo.inviteUsdt;
        invitor = _invitor[account];
        usdtBalance = IERC20(_usdtAddress).balanceOf(account);
        usdtAllowance = IERC20(_usdtAddress).allowance(account, address(this));
    }
}

contract TLBCSale is AbsPreSale {
    constructor() AbsPreSale(
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
    //TLBC Token
        address(0xEa4542C465b969f1bE9ea37022C2EC412885e888),
    //Cash
        address(0xE29C0932475E80645148Fa47049604160929712e)
    ){

    }
}