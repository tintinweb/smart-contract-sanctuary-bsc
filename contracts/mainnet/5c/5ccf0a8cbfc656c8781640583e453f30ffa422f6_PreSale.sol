/**
 *Submitted for verification at BscScan.com on 2023-01-09
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

interface INFT {
    function batchMint(address to, uint256 property, uint256 num) external;

    function balanceOf(address owner) external view returns (uint256 balance);
}

interface IToken {
    function nftReward(address account) external view returns (uint256);
}

abstract contract AbsPreSale is Ownable {
    struct UserInfo {
        uint256 buyAmount;
        uint256 buyTokenAmount;
        uint256 claimedTokenAmount;
        uint256 nftInviteIndex;
    }

    uint256 private _qty = 3000;//总额度
    uint256 private _soldAmount;//已售卖数量
    uint256 private _pricePerSale;
    uint256 private _tokenAmountPerSale;

    //收款地址
    address public _cashAddress;
    address private _tokenAddress;
    address private _usdtAddress;

    address public _nftAddress;

    mapping(address => UserInfo) private _userInfo;
    address[] public _userList;
    bool private _pauseBuy = false;
    bool private _pauseClaim = false;

    mapping(address => address) public _invitor;
    mapping(address => address[]) public _binder;

    uint256 private _totalUsdt;
    uint256 private _totalToken;
    uint256 private _totalClaimedToken;

    uint256 private _nftCondition = 10;
    uint256 private _nftTotal = 100;
    uint256 private _nftIndex;
    uint256 public _nftType = 5;

    constructor(address CashAddress, address USDTAddress, address TokenAddress, address NFTAddress){
        _cashAddress = CashAddress;
        _usdtAddress = USDTAddress;
        _tokenAddress = TokenAddress;
        _nftAddress = NFTAddress;
        _pricePerSale = 100 * 10 ** IERC20(USDTAddress).decimals();
        _tokenAmountPerSale = 30000 * 10 ** IERC20(TokenAddress).decimals();
    }

    function buy(address invitor) external {
        require(!_pauseBuy, "pauseBuy");
        address account = msg.sender;
        UserInfo storage userInfo = _userInfo[account];
        require(0 == userInfo.buyAmount, "bought");

        uint256 amount = _pricePerSale;
        //剩余额度
        uint256 remain = _qty - _soldAmount;
        require(remain > 0, "sold out");

        _userList.push(account);

        //增加地址购买数量
        userInfo.buyAmount = amount;
        uint256 buyTokenAmount = _tokenAmountPerSale;
        userInfo.buyTokenAmount = buyTokenAmount;
        _totalToken += buyTokenAmount;
        _totalUsdt += amount;

        //增加总销售
        _soldAmount += 1;

        UserInfo storage invitorInfo = _userInfo[invitor];
        if (invitorInfo.buyAmount > 0) {
            _invitor[account] = invitor;
            _binder[invitor].push(account);
            invitorInfo.nftInviteIndex += 1;
            if (invitorInfo.nftInviteIndex >= _nftCondition) {
                if (_nftIndex < _nftTotal) {
                    invitorInfo.nftInviteIndex = 0;
                    _giveNFT(invitor);
                }
            }
        }

        _takeToken(_usdtAddress, account, _cashAddress, amount);
    }

    function _giveNFT(address invitor) private {
        uint256 nftType = _nftIndex % _nftType;
        INFT(_nftAddress).batchMint(invitor, nftType + 1, 1);
    unchecked{
        ++_nftIndex;
    }
    }

    function claim() external {
        require(!_pauseClaim, "pauseClaim");
        address account = msg.sender;
        UserInfo storage userInfo = _userInfo[account];

        uint256 pendingToken = userInfo.buyTokenAmount - userInfo.claimedTokenAmount;
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
        uint256 qty, uint256 soldAmount,
        uint256 pricePerSale, uint256 tokenAmountPerSale,
        bool pauseBuy, bool pauseClaim,
        uint256 nftCondition, uint256 nftIndex, uint256 nftTotal
    ) {
        qty = _qty;
        soldAmount = _soldAmount;
        pricePerSale = _pricePerSale;
        tokenAmountPerSale = _tokenAmountPerSale;
        pauseBuy = _pauseBuy;
        pauseClaim = _pauseClaim;
        nftCondition = _nftCondition;
        nftIndex = _nftIndex;
        nftTotal = _nftTotal;
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
        uint256 claimedTokenAmount,
        uint256 nftInviteIndex,
        uint256 usdtBalance,
        uint256 usdtAllowance,
        uint256 nftNum,
        uint256 nftReward,
        uint256 binderLength
    ) {
        UserInfo storage userInfo = _userInfo[account];
        buyAmount = userInfo.buyAmount;
        buyTokenAmount = userInfo.buyTokenAmount;
        claimedTokenAmount = userInfo.claimedTokenAmount;
        nftInviteIndex = userInfo.nftInviteIndex;
        usdtBalance = IERC20(_usdtAddress).balanceOf(account);
        usdtAllowance = IERC20(_usdtAddress).allowance(account, address(this));
        nftNum = INFT(_nftAddress).balanceOf(account);
        nftReward = IToken(_tokenAddress).nftReward(account);
        binderLength = _binder[account].length;
    }

    function getBinderLength(address account) public view returns (uint256){
        return _binder[account].length;
    }

    function getUserListLength() public view returns (uint256){
        return _userList.length;
    }

    receive() external payable {}

    function setQty(uint256 qty) external onlyOwner {
        _qty = qty;
    }

    function setAmountPerSale(uint256 amount) external onlyOwner {
        _tokenAmountPerSale = amount;
    }

    function setPricePerSale(uint256 amount) external onlyOwner {
        _pricePerSale = amount;
    }

    function setNftCondition(uint256 c) external onlyOwner {
        _nftCondition = c;
    }

    function setNftType(uint256 t) external onlyOwner {
        _nftType = t;
    }

    function setNftTotal(uint256 t) external onlyOwner {
        _nftTotal = t;
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
        address[] memory userList
    ){
        uint256 recordLen = _userList.length;
        if (0 == length) {
            length = recordLen;
        }
        returnCount = length;

        userList = new address[](length);
        uint256 index = 0;
        for (uint256 i = start; i < start + length; i++) {
            if (i >= recordLen) {
                return (index, userList);
            }
            userList[index] = _userList[i];
            index++;
        }
    }
}

contract PreSale is AbsPreSale {
    constructor() AbsPreSale(
    //Cash
        address(0xCF9FcF4fC7d7a5ED28a98fec8F434C1eE041506e),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
    //Token,Rabbit Round
        address(0x15055B0181c7546bb8aa77AC592531E73BE5E4cb),
    //NFT
        address(0x2a311c09C6b93c36422Ba2e8ce5dc1CDb2328e39)
    ){

    }
}