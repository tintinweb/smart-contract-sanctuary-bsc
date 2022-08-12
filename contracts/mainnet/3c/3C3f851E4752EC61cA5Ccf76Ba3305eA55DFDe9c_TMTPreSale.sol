/**
 *Submitted for verification at BscScan.com on 2022-08-12
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

    function _teamNum(address account) external view returns (uint256);

    function _binders(address account, uint256 index) external view returns (address);

    function _teamAmount(address account) external view returns (uint256);
}

interface INFT {
    function batchMint(address to, uint256 num) external;
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
        uint256 activeBinder;
        uint256 ethNFTCondition;
        uint256 ethNFTNum;
        uint256 ethNFTBinder;
        uint256 btcNFTCondition;
        uint256 btcNFTNum;
        uint256 teamNum;
        uint256 teamSaleU;
    }

    address public _cashAddress;
    address private _tokenAddress;
    address private _usdtAddress;

    SaleInfo[] private _saleInfo;
    mapping(address => UserInfo) private _userInfo;

    uint256 private _maxBuyNum = 1;

    bool public _pauseBind = true;
    bool private _pauseBuy = false;
    bool private _pauseClaim = true;

    uint256 private _endTime;
    uint256 private _totalUsdt;
    uint256 private _totalToken;

    uint256 private _ethNFTCondition = 5;
    uint256 private _btcNFTCondition = 10;

    address private _defaultInvitor;
    address public _ethNFTAddress;
    address public _btcNFTAddress;
    address[] public _userList;

    constructor(
        address USDTAddress, address TokenAddress, address CashAddress,
        address ETHNFTAddress, address BTCNFTAddress, address DefaultInvitor
    ){
        _usdtAddress = USDTAddress;
        _tokenAddress = TokenAddress;
        _cashAddress = CashAddress;
        _ethNFTAddress = ETHNFTAddress;
        _btcNFTAddress = BTCNFTAddress;
        _defaultInvitor = DefaultInvitor;

        uint256 usdtDecimals = 10 ** IERC20(USDTAddress).decimals();
        uint256 tokenDecimals = 10 ** IERC20(TokenAddress).decimals();

        _saleInfo.push(SaleInfo(100 * usdtDecimals, 166 * tokenDecimals, 10843, 0));
        _saleInfo.push(SaleInfo(100 * usdtDecimals, 125 * tokenDecimals, 76800, 0));

        _endTime = block.timestamp + 864000;
    }

    function bindInvitor(address invitor) external {
        require(!_pauseBind, "pauseBind");
        address account = msg.sender;
        require(_defaultInvitor != account, "defaultInvitor");
        require(invitor != account, "inviteSelf");
        require(_userInfo[account].buyNum == 0, "buyNum gt 0");
        if (!_pauseBuy) {
            require(invitor == _defaultInvitor || _userInfo[invitor].buyNum > 0, "invitor buyNum =0");
        }

        IToken token = IToken(_tokenAddress);
        require(address(0) == token._inviter(account), "Bind");
        require(0 == token.getBinderLength(account), "had Binders");
        token.bindInvitor(account, invitor);
    }

    function buy(uint256 saleId) external {
        require(!_pauseBuy, "pauseBuy");
        address account = msg.sender;
        IToken token = IToken(_tokenAddress);
        address invitor = token._inviter(account);
        require(address(0) != invitor || account == _defaultInvitor, "notBind");

        SaleInfo storage sale = _saleInfo[saleId];
        UserInfo storage userInfo = _userInfo[account];

        require(sale.qty > sale.saleNum, "soldOut");
        if (saleId > 0) {
            require(_saleInfo[saleId - 1].qty == _saleInfo[saleId - 1].saleNum, "last not end");
        }
        require(_maxBuyNum > userInfo.buyNum, "gt maxBuyNum");
        sale.saleNum += 1;

        if (userInfo.buyNum == 0) {
            _userList.push(account);
        }

        userInfo.buyNum += 1;
        uint256 price = sale.price;
        uint256 tokenNum = sale.tokenNum;
        userInfo.buyAmount += price;
        userInfo.buyTokenAmount += tokenNum;
        _totalToken += tokenNum;
        
        if (userInfo.buyNum == 1 && invitor != address(0)) {
            UserInfo storage invitorInfo = _userInfo[invitor];
            require(invitorInfo.buyNum > 0 || _defaultInvitor == invitor, "invalid invitor");
            invitorInfo.activeBinder += 1;
            invitorInfo.ethNFTCondition += 1;
            if (invitorInfo.ethNFTCondition >= _ethNFTCondition) {
                invitorInfo.ethNFTCondition = 0;
                invitorInfo.ethNFTNum += 1;
                INFT(_ethNFTAddress).batchMint(invitor, 1);
                if (invitorInfo.ethNFTNum == 1) {
                    address indirectInvitor = token._inviter(invitor);
                    if (indirectInvitor != address(0)) {
                        UserInfo storage indirectInvitorInfo = _userInfo[indirectInvitor];
                        require(indirectInvitorInfo.buyNum > 0 || _defaultInvitor == indirectInvitor, "invalid indirectInvitor");
                        indirectInvitorInfo.ethNFTBinder += 1;
                        indirectInvitorInfo.btcNFTCondition += 1;
                        if (indirectInvitorInfo.btcNFTCondition >= _btcNFTCondition) {
                            indirectInvitorInfo.btcNFTCondition = 0;
                            indirectInvitorInfo.btcNFTNum += 1;
                            INFT(_btcNFTAddress).batchMint(indirectInvitor, 1);
                        }
                    }
                }
            }
            for (uint256 i; i < 20;) {
                if (invitor == address(0)) {
                    break;
                }
                _userInfo[invitor].teamNum += 1;
                _userInfo[invitor].teamSaleU += price;
                invitor = token._inviter(invitor);
            unchecked{
                ++i;
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
        uint256 pendingToken = userInfo.buyTokenAmount - userInfo.claimedTokenAmount;
        require(pendingToken > 0, "no pendingToken");
        userInfo.claimedTokenAmount += pendingToken;
        _giveToken(account, pendingToken);
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

    function getShopExtInfo() external view returns (
        uint256 ethNFTCondition, uint256 btcNFTCondition,
        address defaultInvitor
    ){
        ethNFTCondition = _ethNFTCondition;
        btcNFTCondition = _btcNFTCondition;
        defaultInvitor = _defaultInvitor;
    }

    receive() external payable {}

    function setTokenAddress(address adr) external onlyOwner {
        _tokenAddress = adr;
    }

    function setEthNFTAddress(address adr) external onlyOwner {
        _ethNFTAddress = adr;
    }

    function setBtcNFTAddress(address adr) external onlyOwner {
        _btcNFTAddress = adr;
    }

    function setUsdtAddress(address adr) external onlyOwner {
        _usdtAddress = adr;
    }

    function setPauseBuy(bool pause) external onlyOwner {
        _pauseBuy = pause;
    }

    function setPauseBind(bool pause) external onlyOwner {
        _pauseBind = pause;
    }

    function setPauseClaim(bool pause) external onlyOwner {
        _pauseClaim = pause;
    }

    function setEthNFTCondition(uint256 num) external onlyOwner {
        _ethNFTCondition = num;
    }

    function setBtcNFTCondition(uint256 num) external onlyOwner {
        _btcNFTCondition = num;
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

    function getUserExtInfo(address account) external view returns (
        uint256 activeBinder,
        uint256 ethNFTCondition,
        uint256 ethNFTNum,
        uint256 ethNFTBinder,
        uint256 btcNFTCondition,
        uint256 btcNFTNum,
        uint256 saleTeamNum,
        address invitor,
        uint256 tokenTeamNum,
        uint256 teamTokenAmount,
        uint256 teamSaleU
    ){
        UserInfo storage userInfo = _userInfo[account];
        activeBinder = userInfo.activeBinder;
        ethNFTCondition = userInfo.ethNFTCondition;
        ethNFTNum = userInfo.ethNFTNum;
        ethNFTBinder = userInfo.ethNFTBinder;
        btcNFTCondition = userInfo.btcNFTCondition;
        btcNFTNum = userInfo.btcNFTNum;
        saleTeamNum = userInfo.teamNum;
        invitor = IToken(_tokenAddress)._inviter(account);
        tokenTeamNum = IToken(_tokenAddress)._teamNum(account);
        teamTokenAmount = IToken(_tokenAddress)._teamAmount(account);
        teamSaleU = userInfo.teamSaleU;
    }

    function getBinderList(address account, uint256 start, uint256 length) public view returns (
        uint256 returnLen, address[] memory binders, uint256[] memory binderEthNFTNum, uint256[] memory binderTokenAmount
    ){
        IToken token = IToken(_tokenAddress);
        uint256 binderLength = token.getBinderLength(account);
        if (0 == length) {
            length = binderLength;
        }
        returnLen = length;

        binders = new address[](length);
        binderEthNFTNum = new uint256[](length);
        binderTokenAmount = new uint256[](length);

        IERC20 erc20 = IERC20(_tokenAddress);

        uint256 index = 0;
        address binder;
        for (uint256 i = start; i < start + length; ++i) {
            if (i >= binderLength)
                return (index, binders, binderEthNFTNum, binderTokenAmount);
            binder = token._binders(account, i);
            binders[index] = binder;
            binderEthNFTNum[index] = _userInfo[binder].ethNFTNum;
            binderTokenAmount[index] = erc20.balanceOf(binder);
            ++index;
        }
    }

    function getUserListLength() public view returns (uint256){
        return _userList.length;
    }

    function getUserList(uint256 start, uint256 length) external view returns (
        uint256 returnLen, address[] memory users,
        uint256[] memory teamSaleUs, uint256[] memory saleBTCNFTNums
    ){
        uint256 userLength = getUserListLength();
        if (0 == length) {
            length = userLength;
        }
        returnLen = length;

        users = new address[](length);
        teamSaleUs = new uint256[](length);
        saleBTCNFTNums = new uint256[](length);
        uint256 index = 0;
        for (uint256 i = start; i < start + length; ++i) {
            if (i >= userLength)
                return (index, users, teamSaleUs, saleBTCNFTNums);
            address user = _userList[i];
            users[index] = user;
            teamSaleUs[index] = _userInfo[user].teamSaleU;
            saleBTCNFTNums[index] = _userInfo[user].btcNFTNum;
            ++index;
        }
    }
}

contract TMTPreSale is AbsPreSale {
    constructor() AbsPreSale(
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
    //Token
        address(0x71203107aE3D34cC2aca910Cd3D78418FC16DB4b),
    //Cash
        address(0x1267eD2A1c489674809552E557b2773C27830E3d),
    //ethNFT
        address(0xB7dC2FD542Fb373255CB4c493b51808F1b2F18e7),
    //btcNFT
        address(0x6477F5D55E8cd3a9a2d85DccF6B3aB09AAc47547),
    //Default Invitor
        address(0xC210f09eFff87e88d189e0c8D80513fF55f80DB3)
    ){

    }
}