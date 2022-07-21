/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

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
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IToken {
    function bindInvitor(address account, address invitor) external;

    function _inviter(address account) external view returns (address);

    function getBinderLength(address account) external view returns (uint256);

    function _binders(address account, uint256 index) external view returns (address);

    function addPartner(address adr) external;

    function addAdvancedPartner(address adr) external;
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
        uint256 inviteTokenAmount;
        uint256 claimedTokenAmount;
        uint256 saleInviteAccount;
        bool salePartnerAdded;
        uint256 saleInviteAdvancedAccount;
        bool saleAdvancedPartnerAdded;
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
    uint256 public _inviteFee = 10;
    uint256 private _totalUsdt;
    uint256 private _totalToken;

    uint256 public salePartnerAddCondition = 10;
    uint256 public saleAdvancedPartnerAddCondition = 10;

    constructor(address USDTAddress, address TokenAddress, address CashAddress){
        _usdtAddress = USDTAddress;
        _tokenAddress = TokenAddress;
        _cashAddress = CashAddress;

        uint256 usdtDecimals = 10 ** IERC20(USDTAddress).decimals();
        uint256 tokenDecimals = 10 ** IERC20(TokenAddress).decimals();

        _saleInfo.push(SaleInfo(18 * usdtDecimals, 180 * tokenDecimals, 10000, 0));
        _saleInfo.push(SaleInfo(180 * usdtDecimals, 1800 * tokenDecimals, 2000, 0));

        _endTime = block.timestamp + 864000;
    }

    function buy(uint256 saleId, address invitor) external {
        require(!_pauseBuy, "pauseBuy");
        address account = msg.sender;
        SaleInfo storage sale = _saleInfo[saleId];

        IToken token = IToken(_tokenAddress);

        UserInfo storage userInfo = _userInfo[account];
        if (userInfo.buyNum == 0) {
            if (_userInfo[invitor].buyNum > 0) {
                token.bindInvitor(account, invitor);
            }
        }

        require(sale.qty > sale.saleNum, "soldOut");
        require(_maxBuyNum > userInfo.buyNum, "gt maxBuyNum");
        sale.saleNum += 1;

        userInfo.buyNum += 1;
        uint256 price = sale.price;
        uint256 tokenNum = sale.tokenNum;
        userInfo.buyAmount += price;
        userInfo.buyTokenAmount += tokenNum;
        _totalToken += tokenNum;

        invitor = token._inviter(account);
        if (address(0) != invitor) {
            UserInfo storage invitorInfo = _userInfo[invitor];
            uint256 inviteToken = tokenNum * _inviteFee / 100;
            invitorInfo.inviteTokenAmount += inviteToken;
            _totalToken += inviteToken;
            if (0 == saleId) {
                invitorInfo.saleInviteAccount += 1;
                if (invitorInfo.saleInviteAccount >= salePartnerAddCondition && !invitorInfo.salePartnerAdded) {
                    invitorInfo.salePartnerAdded = true;
                    token.addPartner(invitor);
                }
            } else {
                invitorInfo.saleInviteAdvancedAccount += 1;
                if (invitorInfo.saleInviteAdvancedAccount >= saleAdvancedPartnerAddCondition && !invitorInfo.saleAdvancedPartnerAdded) {
                    invitorInfo.saleAdvancedPartnerAdded = true;
                    token.addAdvancedPartner(invitor);
                }
            }
        }

        _takeToken(_usdtAddress, account, price);
        _totalUsdt += price;
    }

    function claim() external {
        address account = msg.sender;
        require(!_pauseClaim, "pauseClaim");
        UserInfo storage userInfo = _userInfo[account];
        uint256 pendingToken = userInfo.buyTokenAmount + userInfo.inviteTokenAmount - userInfo.claimedTokenAmount;
        userInfo.claimedTokenAmount += pendingToken;
        _giveToken(account, pendingToken);
    }

    function _giveToken(address account, uint256 tokenNum) private {
        IERC20 token = IERC20(_tokenAddress);
        require(token.balanceOf(address(this)) > tokenNum, "shop token balance not enough");
        token.transfer(account, tokenNum);
    }

    function _takeToken(address tokenAddress, address account, uint256 tokenNum) private {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(account)) > tokenNum, "token balance not enough");
        token.transferFrom(account, _cashAddress, tokenNum);
    }

    function allSaleInfo() external view returns (
        uint256[] memory price, uint256[] memory tokenNum,
        uint256[] memory qty, uint256[] memory saleNum
    ) {
        uint256 len = _saleInfo.length;
        price = new uint256[](len);
        tokenNum = new uint256[](len);
        qty = new uint256[](len);
        saleNum = new uint256[](len);
        for (uint256 i; i < len; i++) {
            SaleInfo memory sale = _saleInfo[i];
            price[i] = sale.price;
            tokenNum[i] = sale.tokenNum;
            qty[i] = sale.qty;
            saleNum[i] = sale.saleNum;
        }
    }

    function shopInfo() external view returns (
        address tokenAddress,
        uint256 maxBuyNum, uint256 timestamp,
        bool pauseBuy, bool pauseClaim,
        uint256 endTime,
        uint256 tokenDecimals, string memory tokenSymbol,
        uint256 totalUsdt, uint256 totalToken,
        address usdtAddress, uint256 usdtDecimals, string memory usdtSymbol
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

    function setCashAddress(address adr) external onlyOwner {
        _cashAddress = adr;
    }

    function setPauseBuy(bool pause) external onlyOwner {
        _pauseBuy = pause;
    }

    function setPauseClaim(bool pause) external onlyOwner {
        _pauseClaim = pause;
    }

    function setInviteFee(uint256 fee) external onlyOwner {
        _inviteFee = fee;
    }

    function setSaleAdvancedPartnerAddCondition(uint256 num) external onlyOwner {
        saleAdvancedPartnerAddCondition = num;
    }

    function setSalePartnerAddCondition(uint256 num) external onlyOwner {
        salePartnerAddCondition = num;
    }

    function setQty(uint256 saleId, uint256 qty) external onlyOwner {
        _saleInfo[saleId].qty = qty;
    }

    function setPrice(uint256 saleId, uint256 price, uint256 tokenNum) external onlyOwner {
        _saleInfo[saleId].price = price;
        _saleInfo[saleId].tokenNum = tokenNum * 10 ** IERC20(_tokenAddress).decimals();
    }

    function setEndTime(uint256 endTime) external onlyOwner {
        _endTime = endTime;
    }

    function setMaxBuyNum(uint256 max) external onlyOwner {
        _maxBuyNum = max;
    }

    function claimBalance() external {
        address payable addr = payable(_cashAddress);
        addr.transfer(address(this).balance);
    }

    function claimToken(address erc20Address) external onlyOwner {
        IERC20 erc20 = IERC20(erc20Address);
        erc20.transfer(_cashAddress, erc20.balanceOf(address(this)));
    }

    function getUserInfo(address account) external view returns (
        uint256 buyNum,
        uint256 buyAmount,
        uint256 buyTokenAmount,
        uint256 inviteTokenAmount,
        uint256 claimedTokenAmount,
        uint256 balance,
        uint256 allowance
    ){
        UserInfo storage userInfo = _userInfo[account];
        buyNum = userInfo.buyNum;
        buyAmount = userInfo.buyAmount;
        buyTokenAmount = userInfo.buyTokenAmount;
        inviteTokenAmount = userInfo.inviteTokenAmount;
        claimedTokenAmount = userInfo.claimedTokenAmount;
        balance = IERC20(_usdtAddress).balanceOf(account);
        allowance = IERC20(_usdtAddress).allowance(account, address(this));
    }

    function getUserExtInfo(address account) external view returns (
        uint256 saleInviteAccount,
        bool salePartnerAdded,
        uint256 saleInviteAdvancedAccount,
        bool saleAdvancedPartnerAdded
    ){
        UserInfo storage userInfo = _userInfo[account];
        saleInviteAccount = userInfo.saleInviteAccount;
        salePartnerAdded = userInfo.salePartnerAdded;
        saleInviteAdvancedAccount = userInfo.saleInviteAdvancedAccount;
        saleAdvancedPartnerAdded = userInfo.saleAdvancedPartnerAdded;
    }
}

contract SRSCSale is AbsPreSale {
    constructor() AbsPreSale(
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
    //Token
        address(0xA177CE15C46a13b5626D3e5d44766657Fc6eDeA8),
    //Cash
        address(0xF8fE88Db8A8B61f71bF00cCC8DCe914F10163F27)
    ){

    }
}