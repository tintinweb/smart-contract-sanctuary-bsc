/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

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
    address private _owner;

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

abstract contract AbsPreSale is Ownable {
    uint256 private _qty = 1000;
    uint256 private _soldCount;
    uint256 private _perTokenAmount;
    uint256 private _price;

    address private _usdtAddress;
    address public _cashAddress;
    address private _tokenAddress;

    bool private _pauseBuy = true;
    bool private _pauseClaim = true;

    struct UserInfo {
        uint256 paidUsdt;
        uint256 pendingToken;
        uint256 claimedToken;
    }

    mapping(address => UserInfo) private _userInfo;

    constructor(address UsdtAddress, address CashAddress, address TokenAddress){
        _usdtAddress = UsdtAddress;
        _cashAddress = CashAddress;
        _tokenAddress = TokenAddress;

        _perTokenAmount = 150 * 10 ** IERC20(TokenAddress).decimals();

        uint256 usdtDecimals = 10 ** IERC20(UsdtAddress).decimals();
        _price = 150 * usdtDecimals;
    }

    function buy() external {
        require(!_pauseBuy, "pauseBuy");
        address account = msg.sender;
        _soldCount += 1;
        require(_qty >= _soldCount, "notQty");

        uint256 price = _price;
        IERC20(_usdtAddress).transferFrom(account, _cashAddress, price);

        UserInfo storage userInfo = _userInfo[account];
        userInfo.paidUsdt += price;
        userInfo.pendingToken += _perTokenAmount;
    }

    function info() external view returns (uint256, uint256, uint256, uint256, bool, bool) {
        return (_price, _perTokenAmount, _qty, _soldCount, _pauseBuy, _pauseClaim);
    }

    function infoExt() external view returns (
        address usdt, uint256 usdtDecimals, string memory usdtSymbol,
        address token, uint256 tokenDecimals, string memory tokenSymbol
    ) {
        usdt = _usdtAddress;
        usdtDecimals = IERC20(usdt).decimals();
        usdtSymbol = IERC20(usdt).symbol();
        token = _tokenAddress;
        tokenDecimals = IERC20(token).decimals();
        tokenSymbol = IERC20(token).symbol();
    }

    function getUserInfo(address account) external view returns (
        uint256 paidUsdt, uint256 pendingToken, uint256 claimedToken
    ) {
        UserInfo storage userInfo = _userInfo[account];
        paidUsdt = userInfo.paidUsdt;
        pendingToken = userInfo.pendingToken;
        claimedToken = userInfo.claimedToken;
    }

    function claim() external {
        require(!_pauseClaim, "pauseClaim");
        address account = msg.sender;
        UserInfo storage userInfo = _userInfo[account];
        uint256 pendingToken = userInfo.pendingToken;
        userInfo.pendingToken = 0;
        userInfo.claimedToken += pendingToken;
        IERC20(_tokenAddress).transfer(account, pendingToken);
    }

    receive() external payable {}

    function claimBalance(uint256 amount, address to) external onlyOwner {
        payable(to).transfer(amount);
    }

    function withdrawToken(address token, uint256 amount, address to) external onlyOwner {
        IERC20 erc20 = IERC20(token);
        erc20.transfer(to, amount);
    }

    function setCashAddress(address cashAddress) external onlyOwner {
        _cashAddress = cashAddress;
    }

    function setUsdtAddress(address usdtAddress) external onlyOwner {
        _usdtAddress = usdtAddress;
    }

    function setTokenAddress(address tokenAddress) external onlyOwner {
        _tokenAddress = tokenAddress;
    }

    function setPerTokenAmount(uint256 amount) external onlyOwner {
        _perTokenAmount = amount * 10 ** IERC20(_tokenAddress).decimals();
    }

    function setPauseBuy(bool pauseBuy) external onlyOwner {
        _pauseBuy = pauseBuy;
    }

    function setPauseClaim(bool pauseClaim) external onlyOwner {
        _pauseClaim = pauseClaim;
    }

    function setQty(uint256 qty) external onlyOwner {
        _qty = qty;
    }

    function setPrice(uint256 price) external onlyOwner {
        _price = price * 10 ** IERC20(_usdtAddress).decimals();
    }
}

contract PreSale is AbsPreSale {
    constructor() AbsPreSale(
        address(0x55d398326f99059fF775485246999027B3197955),
        address(0x6Ed37787FecBf669aAE0177774066461C793BBf0),
        address(0x55d398326f99059fF775485246999027B3197955)
    ){

    }
}