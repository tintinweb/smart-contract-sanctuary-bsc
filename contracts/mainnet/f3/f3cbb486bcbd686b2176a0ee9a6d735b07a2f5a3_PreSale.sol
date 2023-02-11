/**
 *Submitted for verification at BscScan.com on 2023-02-11
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

interface INFT {
    function batchMint(address[] memory tos) external;
}

interface IToken {
    function addBuyUsdtAmount(address account, uint256 usdtAmount) external;
}

abstract contract AbsPreSale is Ownable {
    struct UserInfo {
        uint256 buyAmount;
        uint256 buyTokenAmount;
        uint256 inviteTokenAmount;
        uint256 claimedTokenAmount;
        uint256 binderBuyUsdt;
        uint256 binderBuyNum;
        bool giveNFT;
        bool isInvitor;
    }

    uint256 public _saleSoldAmount;
    uint256 private _pricePerSale;
    uint256 private _tokenAmountPerSale;

    uint256 public _invitorSoldAmount;
    uint256 private _pricePerInvitor;
    uint256 private _tokenAmountPerInvitor;

    address public _cashAddress;
    address private _tokenAddress;
    address private _usdtAddress;

    address public _nftAddress;

    mapping(address => UserInfo) private _userInfo;
    address[] public _userList;
    bool private _pauseBuy = false;
    bool private _pauseClaim = true;

    mapping(address => address) public _invitor;
    mapping(address => address[]) public _binder;

    uint256 private _totalUsdt;
    uint256 private _totalToken;
    uint256 private _totalClaimedToken;

    uint256 private _nftCondition;
    mapping(uint256 => uint256) public _inviteFee;

    constructor(address CashAddress, address USDTAddress, address TokenAddress, address NFTAddress){
        _cashAddress = CashAddress;
        _usdtAddress = USDTAddress;
        _tokenAddress = TokenAddress;
        _nftAddress = NFTAddress;
        uint256 usdtUnit = 10 ** IERC20(USDTAddress).decimals();
        uint256 tokenUnit = 10 ** IERC20(TokenAddress).decimals();
        _pricePerSale = 58 * usdtUnit;
        _tokenAmountPerSale = 5800 * tokenUnit;
        _nftCondition = 10;
        _pricePerInvitor = 200 * usdtUnit;
        _tokenAmountPerInvitor = 20000 * tokenUnit;

        _inviteFee[0] = 700;
        _inviteFee[1] = 200;
        _inviteFee[2] = 100;
    }

    function buy(address invitor) external {
        require(!_pauseBuy, "pauseBuy");
        address account = msg.sender;
        UserInfo storage userInfo = _userInfo[account];
        require(0 == userInfo.buyAmount, "bought");
        _userList.push(account);

        _saleSoldAmount += 1;

        UserInfo storage invitorInfo = _userInfo[invitor];
        if (invitorInfo.buyAmount > 0) {
            _invitor[account] = invitor;
            _binder[invitor].push(account);
        }

        _buy(account, _pricePerSale, _tokenAmountPerSale);
    }

    function buyInvitor() external {
        require(!_pauseBuy, "pauseBuy");
        address account = msg.sender;
        UserInfo storage userInfo = _userInfo[account];
        require(0 < userInfo.buyAmount, "N bought");
        require(!userInfo.isInvitor, "isInvitor");
        userInfo.isInvitor = true;

        _invitorSoldAmount += 1;
        _buy(account, _pricePerInvitor, _tokenAmountPerInvitor);
    }

    function _buy(address account, uint256 usdtAmount, uint256 tokenAmount) private {
        address invitor = _invitor[account];
        UserInfo storage invitorInfo = _userInfo[invitor];
        if (invitorInfo.buyAmount > 0) {
            invitorInfo.binderBuyUsdt += usdtAmount;
            invitorInfo.binderBuyNum += 1;
            if (!invitorInfo.giveNFT && invitorInfo.binderBuyNum >= _nftCondition) {
                invitorInfo.giveNFT = true;
                _giveNFT(invitor);
            }
        }

        _totalToken += tokenAmount;
        _totalUsdt += usdtAmount;

        UserInfo storage userInfo = _userInfo[account];
        userInfo.buyAmount += usdtAmount;
        userInfo.buyTokenAmount += tokenAmount;

        _takeToken(_usdtAddress, account, _cashAddress, usdtAmount);
        IToken(_tokenAddress).addBuyUsdtAmount(account, usdtAmount);

        address current = account;
        for (uint256 i; i < 3;) {
            invitor = _invitor[current];
            if (address(0) == invitor) {
                break;
            }
            invitorInfo = _userInfo[invitor];
            if (invitorInfo.isInvitor) {
                invitorInfo.inviteTokenAmount += tokenAmount * _inviteFee[i] / 10000;
            }
            current = invitor;
        unchecked{
            ++i;
        }
        }
    }

    function _giveNFT(address invitor) private {
        address[] memory tos = new address[](1);
        tos[0] = invitor;
        INFT(_nftAddress).batchMint(tos);
    }

    function claim() external {
        require(!_pauseClaim, "pauseClaim");
        address account = msg.sender;
        UserInfo storage userInfo = _userInfo[account];

        uint256 pendingToken = userInfo.buyTokenAmount + userInfo.inviteTokenAmount - userInfo.claimedTokenAmount;
        require(pendingToken > 0, "no token");

        userInfo.claimedTokenAmount += pendingToken;
        _giveToken(_tokenAddress, account, pendingToken);

        _totalClaimedToken += pendingToken;
    }

    function _giveToken(address tokenAddress, address account, uint256 tokenNum) private {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(this)) >= tokenNum, "token balance not enough");
        token.transfer(account, tokenNum);
    }

    function _takeToken(address tokenAddress, address account, address to, uint256 tokenNum) private {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(account) >= tokenNum, "token balance not enough");
        token.transferFrom(account, to, tokenNum);
    }

    function getSaleInfo() external view returns (
        uint256 pricePerSale, uint256 tokenAmountPerSale,
        uint256 pricePerInvitor, uint256 tokenAmountPerInvitor,
        bool pauseBuy, bool pauseClaim,
        uint256 nftCondition
    ) {
        pricePerSale = _pricePerSale;
        tokenAmountPerSale = _tokenAmountPerSale;
        pricePerInvitor = _pricePerInvitor;
        tokenAmountPerInvitor = _tokenAmountPerInvitor;
        pauseBuy = _pauseBuy;
        pauseClaim = _pauseClaim;
        nftCondition = _nftCondition;
    }

    function getTokenInfo() external view returns (
        address usdtAddress, uint256 usdtDecimals, string memory usdtSymbol,
        address tokenAddress, uint256 tokenDecimals, string memory tokenSymbol,
        uint256 totalUsdt, uint256 totalToken, uint256 totalClaimedToken
    ) {
        usdtAddress = _usdtAddress;
        usdtDecimals = IERC20(usdtAddress).decimals();
        usdtSymbol = IERC20(usdtAddress).symbol();
        tokenAddress = _tokenAddress;
        tokenDecimals = IERC20(tokenAddress).decimals();
        tokenSymbol = IERC20(tokenAddress).symbol();
        totalUsdt = _totalUsdt;
        totalToken = _totalToken;
        totalClaimedToken = _totalClaimedToken;
    }

    function getUserInfo(address account) external view returns (
        uint256 buyAmount,
        uint256 buyTokenAmount,
        uint256 inviteTokenAmount,
        uint256 claimedTokenAmount,
        uint256 binderBuyUsdt,
        uint256 binderBuyNum,
        bool isGiveNFT,
        bool isInvitor
    ) {
        UserInfo storage userInfo = _userInfo[account];
        buyAmount = userInfo.buyAmount;
        buyTokenAmount = userInfo.buyTokenAmount;
        inviteTokenAmount = userInfo.inviteTokenAmount;
        claimedTokenAmount = userInfo.claimedTokenAmount;
        binderBuyUsdt = userInfo.binderBuyUsdt;
        binderBuyNum = userInfo.binderBuyNum;
        isGiveNFT = userInfo.giveNFT;
        isInvitor = userInfo.isInvitor;
    }

    function getUserExtInfo(address account) external view returns (
        uint256 usdtBalance,
        uint256 usdtAllowance,
        address invitor,
        uint256 binderLength
    ) {
        usdtBalance = IERC20(_usdtAddress).balanceOf(account);
        usdtAllowance = IERC20(_usdtAddress).allowance(account, address(this));
        invitor = _invitor[account];
        binderLength = _binder[account].length;
    }

    function getBinderLength(address account) public view returns (uint256){
        return _binder[account].length;
    }

    function getUserListLength() public view returns (uint256){
        return _userList.length;
    }

    receive() external payable {}

    function setAmountPerSale(uint256 amount) external onlyOwner {
        _tokenAmountPerSale = amount;
    }

    function setPricePerSale(uint256 amount) external onlyOwner {
        _pricePerSale = amount;
    }

    function setAmountPerInvitor(uint256 amount) external onlyOwner {
        _tokenAmountPerInvitor = amount;
    }

    function setPricePerInvitor(uint256 amount) external onlyOwner {
        _pricePerInvitor = amount;
    }

    function setNftCondition(uint256 c) external onlyOwner {
        _nftCondition = c;
    }

    function setTokenAddress(address adr) external onlyOwner {
        _tokenAddress = adr;
    }

    function setUsdtAddress(address adr) external onlyOwner {
        _usdtAddress = adr;
    }

    function setCashAddress(address adr) external onlyOwner {
        _cashAddress = adr;
    }

    function claimBalance(uint256 amount, address to) external onlyOwner {
        address payable addr = payable(to);
        addr.transfer(amount);
    }

    function claimToken(address erc20Address, address to, uint256 amount) external onlyOwner {
        IERC20 erc20 = IERC20(erc20Address);
        erc20.transfer(to, amount);
    }

    function setPauseBuy(bool pause) external onlyOwner {
        _pauseBuy = pause;
    }

    function setPauseClaim(bool pause) external onlyOwner {
        _pauseClaim = pause;
    }

    function getUserList(
        uint256 start,
        uint256 length
    ) external view returns (
        uint256 returnCount,
        address[] memory userList,
        uint256[] memory binderBuyUsdt,
        uint256[] memory binderBuyNum
    ){
        uint256 recordLen = _userList.length;
        if (0 == length) {
            length = recordLen;
        }
        returnCount = length;

        userList = new address[](length);
        binderBuyUsdt = new uint256[](length);
        binderBuyNum = new uint256[](length);
        uint256 index = 0;
        address account;
        for (uint256 i = start; i < start + length; i++) {
            if (i >= recordLen) {
                return (index, userList, binderBuyUsdt, binderBuyNum);
            }
            account = _userList[i];
            userList[index] = account;
            binderBuyUsdt[index] = _userInfo[account].binderBuyUsdt;
            binderBuyNum[index] = _userInfo[account].binderBuyNum;
            index++;
        }
    }
}

contract PreSale is AbsPreSale {
    constructor() AbsPreSale(
    //Cash
        address(0xBC9C4D5621C967685bfc1357C4742A697a6d04A9),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
    //Token
        address(0xd687F5fC28a2bf0998d2B2D2F5E6497dDF317739),
    //InvitorNFT
        address(0x06eDEd6459a85Ed0E88B1b82dA512CB75B88a1A1)
    ){

    }
}