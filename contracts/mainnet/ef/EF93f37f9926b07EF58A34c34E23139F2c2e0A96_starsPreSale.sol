/**
 *Submitted for verification at BscScan.com on 2022-08-30
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

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

abstract contract AbsPreSale is Ownable {
    struct UserInfo {
        uint256 buyAmount;
        uint256 totalTokenAmount;
        uint256 claimedTokenAmount;
    }

    uint256 private _qty;
    uint256 private _soldAmount;
    uint256 private _minAmount;
    uint256 private _maxAmount;
    uint256 private _tokenAmountPerUsdt;
    uint256 private _soldTokenAmount;
    bool private _pauseBuy;
    bool private _pauseClaim = true;
    uint256 private _endTime;

    address private _usdtAddress;
    address private _tokenAddress;
    address public _cashAddress;
    uint256 public _usdtUnit;

    mapping(address => UserInfo) private _userInfo;
    uint256 public _inviteFee = 7;
    uint256 public _totalInviteUsdt;
    uint256 public _invitorBuyCondition;

    constructor(address UsdtAddress, address TokenAddress, address CashAddress){
        _usdtAddress = UsdtAddress;
        _tokenAddress = TokenAddress;
        _cashAddress = CashAddress;

        uint256 usdtUnit = 10 ** IERC20(UsdtAddress).decimals();
        _qty = 500000 * usdtUnit;
        _minAmount = 30 * usdtUnit;
        _maxAmount = 300 * usdtUnit;
        _usdtUnit = usdtUnit;

        _tokenAmountPerUsdt = 40 * 10 ** IERC20(TokenAddress).decimals();
        _endTime = block.timestamp + 864000;

        _invitorBuyCondition = 300 * usdtUnit;
    }

    function buy(uint256 amount, address invitor) external {
        require(!_pauseBuy, "pauseBuy");
        uint256 usdtUnit = _usdtUnit;
        amount = amount / usdtUnit;
        amount = amount * usdtUnit;

        uint256 remain = _qty - _soldAmount;
        require(remain > 0, "soldOut");
        if (remain > amount) {
            require(amount >= _minAmount, "lt min");
        } else {
            amount = remain;
        }
        require(amount <= _maxAmount, "gt max");

        address account = msg.sender;
        UserInfo storage userInfo = _userInfo[account];
        require(userInfo.buyAmount == 0, "bought");

        uint256 cashUsdt = amount;
        if (_userInfo[invitor].buyAmount >= _invitorBuyCondition) {
            uint256 invitorUsdt = cashUsdt * _inviteFee / 100;
            cashUsdt -= invitorUsdt;
            _takeToken(_usdtAddress, account, invitor, invitorUsdt);
            _totalInviteUsdt += invitorUsdt;
            _bindInvitor(account, invitor);
        }
        _takeToken(_usdtAddress, account, _cashAddress, cashUsdt);

        uint256 tokenAmount = _tokenAmountPerUsdt * amount / usdtUnit;

        userInfo.buyAmount += amount;
        userInfo.totalTokenAmount = tokenAmount;

        _soldAmount += amount;
        _soldTokenAmount += tokenAmount;
    }

    function claim() external {
        require(!_pauseClaim, "pauseClaim");
        address account = msg.sender;
        UserInfo storage userInfo = _userInfo[account];
        uint256 pendingTokenAmount = userInfo.totalTokenAmount - userInfo.claimedTokenAmount;
        require(pendingTokenAmount > 0, "noToken");
        userInfo.claimedTokenAmount += pendingTokenAmount;
        _giveToken(_tokenAddress, account, pendingTokenAmount);
    }

    function _takeToken(address tokenAddress, address account, address to, uint256 amount) private {
        if (0 == amount) {
            return;
        }
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(account) >= amount, "token not enough");
        token.transferFrom(account, to, amount);
    }

    function _giveToken(address tokenAddress, address account, uint256 amount) private {
        if (0 == amount) {
            return;
        }
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(this)) >= amount, "pool token not enough");
        token.transfer(account, amount);
    }

    function getSaleInfo() external view returns (
        uint256 qty,
        uint256 soldAmount,
        uint256 minAmount,
        uint256 maxAmount,
        uint256 tokenAmountPerUsdt,
        uint256 soldTokenAmount,
        bool pauseBuy,
        bool pauseClaim,
        uint256 endTime,
        uint256 blockTime
    ) {
        qty = _qty;
        soldAmount = _soldAmount;
        minAmount = _minAmount;
        maxAmount = _maxAmount;
        tokenAmountPerUsdt = _tokenAmountPerUsdt;
        soldTokenAmount = _soldTokenAmount;
        pauseBuy = _pauseBuy;
        pauseClaim = _pauseClaim;
        endTime = _endTime;
        blockTime = block.timestamp;
    }

    function getTokenInfo() external view returns (
        address usdtAddress,
        uint256 usdtDecimals,
        string memory usdtSymbol,
        address tokenAddress,
        uint256 tokenDecimals,
        string memory tokenSymbol
    ) {
        usdtAddress = _usdtAddress;
        usdtDecimals = IERC20(usdtAddress).decimals();
        usdtSymbol = IERC20(usdtAddress).symbol();
        tokenAddress = _tokenAddress;
        tokenDecimals = IERC20(tokenAddress).decimals();
        tokenSymbol = IERC20(tokenAddress).symbol();
    }

    function getUserInfo(address account) external view returns (
        uint256 buyAmount,
        uint256 totalTokenAmount,
        uint256 claimedTokenAmount,
        uint256 usdtBalance,
        uint256 usdtAllowance
    ) {
        UserInfo storage userInfo = _userInfo[account];
        buyAmount = userInfo.buyAmount;
        totalTokenAmount = userInfo.totalTokenAmount;
        claimedTokenAmount = userInfo.claimedTokenAmount;
        usdtBalance = IERC20(_usdtAddress).balanceOf(account);
        usdtAllowance = IERC20(_usdtAddress).allowance(account, address(this));
    }

    receive() external payable {}

    function setQty(uint256 qty) external onlyOwner {
        _qty = qty * _usdtUnit;
    }

    function setMin(uint256 min) external onlyOwner {
        _minAmount = min * _usdtUnit;
    }

    function setMax(uint256 max) external onlyOwner {
        _maxAmount = max * _usdtUnit;
    }

    function setTokenAmountPerUsdt(uint256 tokenAmountPerUsdt) external onlyOwner {
        _tokenAmountPerUsdt = tokenAmountPerUsdt * 10 ** IERC20(_tokenAddress).decimals();
    }

    function setPauseBuy(bool pause) external onlyOwner {
        _pauseBuy = pause;
    }

    function setPauseClaim(bool pause) external onlyOwner {
        _pauseClaim = pause;
    }

    function setTokenAddress(address tokenAddress) external onlyOwner {
        _tokenAddress = tokenAddress;
    }

    function setUsdtAddress(address usdtAddress) external onlyOwner {
        _usdtAddress = usdtAddress;
        _usdtUnit = 10 ** IERC20(usdtAddress).decimals();
    }

    function setEndTime(uint256 endTime) external onlyOwner {
        _endTime = endTime;
    }

    function setInviteFee(uint256 inviteFee) external onlyOwner {
        _inviteFee = inviteFee;
    }

    function setInvitorBuyCondition(uint256 invitorBuyCondition) external onlyOwner {
        _invitorBuyCondition = invitorBuyCondition;
    }

    function claimBalance(address to, uint256 amount) external onlyOwner {
        address payable addr = payable(to);
        addr.transfer(amount);
    }

    function claimToken(address erc20Address, address to, uint256 amount) external onlyOwner {
        IERC20 erc20 = IERC20(erc20Address);
        erc20.transfer(to, amount);
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
}

contract starsPreSale is AbsPreSale {
    constructor() AbsPreSale(
    //usdt
        address(0x55d398326f99059fF775485246999027B3197955),
    //token
        address(0x55d71d9A5a5311D15db9464B32e53ADf0442a6B8),
    //cash
        address(0x2BFB3Df1E0306EFd251433418B2Efb1d8E09b91d)
    ){

    }
}