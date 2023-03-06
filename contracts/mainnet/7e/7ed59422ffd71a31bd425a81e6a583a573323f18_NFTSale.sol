/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

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
        require(_owner == msg.sender, "!o");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "n0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IInvitorToken {
    function bindInvitor(address account, address invitor) external;
}

interface INFT {
    function batchMint(address to, uint256 num) external;
}

abstract contract AbsPreSale is Ownable {
    struct SaleInfo {
        uint256 priceUsdt;
        uint256 qty;
        uint256 saleNum;
        uint256 maxBuyNum;
        address nftAddress;
    }

    struct UserInfo {
        uint256 buyAmount;
        uint256 teamAmount;
        uint256 inviteReward;
        uint256 claimedAmount;
    }

    address public _cashAddress;
    address private _tokenAddress;
    address private _usdtAddress;

    SaleInfo[] private _saleInfo;
    mapping(address => UserInfo) private _userInfo;

    mapping(uint256 => mapping(address => uint256)) public _teamNum;

    bool private _pauseBuy = false;

    uint256 public _totalAmount;
    uint256 public _totalInviteAmount;

    mapping(address => address) public _invitor;
    mapping(address => address[]) public _binder;
    uint256 public _inviteLength = 20;
    uint256 public _inviteFee = 1000;
    uint256 public _inviteRewardUsdt;
    uint256 public constant _feeDivFactor = 10000;

    mapping(uint256 => mapping(address => uint256)) public _buyNum;

    ISwapFactory public _factory;
    address public _invitorToken;

    constructor(
        address RouteAddress, address TokenAddress, address USDTAddress,
        address InvitorToken, address CashAddress,
        address LargeNFT, address littleNFT
    ){
        _factory = ISwapFactory(ISwapRouter(RouteAddress).factory());

        _usdtAddress = USDTAddress;
        _tokenAddress = TokenAddress;
        _invitorToken = InvitorToken;
        _cashAddress = CashAddress;

        uint256 usdtUnit = 10 ** IERC20(USDTAddress).decimals();

        _saleInfo.push(SaleInfo(500 * usdtUnit, 300, 0, 1, LargeNFT));
        _saleInfo.push(SaleInfo(200 * usdtUnit, 2000, 0, 1, littleNFT));

        _inviteRewardUsdt = 2 * usdtUnit;
    }

    function buy(uint256 saleId, address invitor) external {
        require(!_pauseBuy, "pauseBuy");
        address account = msg.sender;
        require(tx.origin == account, "origin");

        SaleInfo storage sale = _saleInfo[saleId];
        require(sale.qty > sale.saleNum, "qty");

        uint256 buyNum = _buyNum[saleId][account];
        require(sale.maxBuyNum > buyNum, "maxNum");
        _buyNum[saleId][account] = buyNum + 1;

        sale.saleNum += 1;

        UserInfo storage userInfo = _userInfo[account];
        uint256 inviteLength = _inviteLength;

        if (userInfo.buyAmount == 0) {
            if (_userInfo[invitor].buyAmount > 0) {
                _invitor[account] = invitor;
                _binder[invitor].push(account);

                IInvitorToken invitorToken = IInvitorToken(_invitorToken);
                invitorToken.bindInvitor(account, invitor);

                for (uint256 i; i < inviteLength;) {
                    if (address(0) == invitor) {
                        break;
                    }
                    _teamNum[i][invitor] += 1;
                    invitor = _invitor[invitor];
                unchecked{
                    ++i;
                }
                }
            }
        }

        uint256 usdtAmount = sale.priceUsdt;
        address tokenAddress = _tokenAddress;
        uint256 tokenAmount = tokenAmountOut(usdtAmount, tokenAddress);
        userInfo.buyAmount += tokenAmount;

        _totalAmount += tokenAmount;

        _takeToken(tokenAddress, account, address(this), tokenAmount);

        uint256 cashAmount = tokenAmount;

        address current = account;
        uint256 inviteAmount;
        for (uint256 i = 0; i < inviteLength;) {
            invitor = _invitor[current];
            if (address(0) == invitor) {
                break;
            }

            if (0 == i) {
                inviteAmount = tokenAmount * _inviteFee / _feeDivFactor;
            } else if (1 == i) {
                inviteAmount = tokenAmount * _inviteRewardUsdt / usdtAmount;
            }

            _totalInviteAmount += inviteAmount;
            cashAmount -= inviteAmount;
            UserInfo storage invitorInfo = _userInfo[invitor];
            invitorInfo.teamAmount += tokenAmount;
            invitorInfo.inviteReward += inviteAmount;
            current = invitor;
        unchecked{
            ++i;
        }
        }

        _giveToken(tokenAddress, _cashAddress, cashAmount);
        INFT(sale.nftAddress).batchMint(account, 1);
    }

    function claimReward() external {
        address account = msg.sender;
        UserInfo storage userInfo = _userInfo[account];
        uint256 pendingToken = userInfo.inviteReward - userInfo.claimedAmount;
        require(pendingToken > 0, "n Reward");
        userInfo.claimedAmount += pendingToken;
        _giveToken(_tokenAddress, account, pendingToken);
    }

    function tokenAmountOut(uint256 usdtAmount, address tokenAddress) public view returns (uint256){
        address usdtAddress = _usdtAddress;
        if (usdtAddress == tokenAddress) {
            return usdtAmount;
        }
        address lpAddress = _factory.getPair(usdtAddress, tokenAddress);
        uint256 tokenBalance = IERC20(tokenAddress).balanceOf(lpAddress);
        uint256 usdtBalance = IERC20(usdtAddress).balanceOf(lpAddress);
        require(tokenBalance > 0 && usdtBalance > 0, "noUPool");
        return usdtAmount * tokenBalance / usdtBalance;
    }

    function _giveToken(address tokenAddress, address account, uint256 tokenNum) private {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(this)) >= tokenNum, "c token n enough");
        token.transfer(account, tokenNum);
    }

    function _takeToken(address tokenAddress, address sender, address receiver, uint256 tokenNum) private {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(sender)) >= tokenNum, "token n enough");
        token.transferFrom(sender, receiver, tokenNum);
    }

    function getAllSaleInfo() external view returns (
        uint256[] memory priceUsdt, uint256[] memory tokenAmount,
        uint256[] memory qty, uint256[] memory saleNum, uint256[] memory maxBuyNum,
        address[] memory nft
    ) {
        uint256 len = _saleInfo.length;
        priceUsdt = new uint256[](len);
        tokenAmount = new uint256[](len);
        qty = new uint256[](len);
        saleNum = new uint256[](len);
        maxBuyNum = new uint256[](len);
        nft = new address[](len);
        for (uint256 i; i < len; i++) {
            SaleInfo storage sale = _saleInfo[i];
            priceUsdt[i] = sale.priceUsdt;
            tokenAmount[i] = tokenAmountOut(priceUsdt[i], _tokenAddress);
            qty[i] = sale.qty;
            saleNum[i] = sale.saleNum;
            maxBuyNum[i] = sale.maxBuyNum;
            nft[i] = sale.nftAddress;
        }
    }

    function getUserAllSaleInfo(address account) external view returns (
        uint256[] memory buyNum
    ) {
        uint256 len = _saleInfo.length;
        buyNum = new uint256[](len);
        for (uint256 i; i < len; i++) {
            buyNum[i] = _buyNum[i][account];
        }
    }

    function shopInfo() external view returns (
        address usdtAddress, uint256 usdtDecimals, string memory usdtSymbol,
        address tokenAddress, uint256 tokenDecimals, string memory tokenSymbol,
        bool pauseBuy
    ){
        usdtAddress = _usdtAddress;
        usdtDecimals = IERC20(usdtAddress).decimals();
        usdtSymbol = IERC20(usdtAddress).symbol();
        tokenAddress = _tokenAddress;
        tokenDecimals = IERC20(tokenAddress).decimals();
        tokenSymbol = IERC20(tokenAddress).symbol();
        pauseBuy = _pauseBuy;
    }

    function getBinderLength(address account) external view returns (uint256){
        return _binder[account].length;
    }

    function getUserInfo(address account) external view returns (
        uint256 buyAmount,
        uint256 teamAmount,
        uint256 inviteReward,
        uint256 claimedAmount,
        address invitor,
        uint256 binder0Length,
        uint256 binder1Length,
        uint256 tokenBalance,
        uint256 tokenAllowance
    ){
        UserInfo storage userInfo = _userInfo[account];
        buyAmount = userInfo.buyAmount;
        teamAmount = userInfo.teamAmount;
        inviteReward = userInfo.inviteReward;
        claimedAmount = userInfo.claimedAmount;
        invitor = _invitor[account];
        binder0Length = _teamNum[0][account];
        binder1Length = _teamNum[1][account];
        tokenBalance = IERC20(_tokenAddress).balanceOf(account);
        tokenAllowance = IERC20(_tokenAddress).allowance(account, address(this));
    }

    receive() external payable {}

    function setTokenAddress(address adr) external onlyOwner {
        _tokenAddress = adr;
    }

    function setUsdtAddress(address adr) external onlyOwner {
        _usdtAddress = adr;
    }

    function setInvitorToken(address adr) external onlyOwner {
        _invitorToken = adr;
    }

    function setCashAddress(address adr) external onlyOwner {
        _cashAddress = adr;
    }

    function setPauseBuy(bool pause) external onlyOwner {
        _pauseBuy = pause;
    }

    function setInviteFee(uint256 fee) external onlyOwner {
        _inviteFee = fee;
    }

    function setInviteRewardUsdt(uint256 amount) external onlyOwner {
        _inviteRewardUsdt = amount;
    }

    function setInviteLength(uint256 len) external onlyOwner {
        _inviteLength = len;
    }

    function setQty(uint256 sid, uint256 price) external onlyOwner {
        _saleInfo[sid].qty = price;
    }

    function setPrice(uint256 sid, uint256 price) external onlyOwner {
        _saleInfo[sid].priceUsdt = price;
    }

    function setMaxBuyNum(uint256 sid, uint256 max) external onlyOwner {
        _saleInfo[sid].maxBuyNum = max;
    }

    function setNFT(uint256 sid, address nft) external onlyOwner {
        _saleInfo[sid].nftAddress = nft;
    }

    function claimBalance(address to, uint256 amount) external onlyOwner {
        address payable addr = payable(to);
        addr.transfer(amount);
    }

    function claimToken(address erc20Address, address to, uint256 amount) external onlyOwner {
        IERC20 erc20 = IERC20(erc20Address);
        erc20.transfer(to, amount);
    }
}

contract NFTSale is AbsPreSale {
    constructor() AbsPreSale(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //Matic
        address(0xCC42724C6683B7E57334c4E856f4c9965ED682bD),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
    //InvitorToken,MAM
        address(0x3103217dA3DEd1B7C56618709C93c42765D08Ec7),
    //Cash
        address(0x7215D45c1e6BB542fA5e53971FDB78C37Ad68934),
    //LargeNFT
        address(0x3F35F1EBFBdecA6f3A9dFb772e7A52e19866F666),
    //littleNFT
        address(0xBFC1ef96784dC7e3d7329aeCdfe9f9353A986b48)
    ){

    }
}