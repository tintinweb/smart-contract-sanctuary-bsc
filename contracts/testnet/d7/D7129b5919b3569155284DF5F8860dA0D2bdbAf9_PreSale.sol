/**
 *Submitted for verification at BscScan.com on 2023-01-03
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
    struct UserInfo {
        uint256 buyAmount;
        uint256 buyTokenAmount;
        uint256 claimedTokenAmount;
        uint256 teamNum;
        uint256 inviteReward;
        uint256 claimedInviteReward;
    }

    uint256 private _qty = 10 ether;
    uint256 private _soldAmount;
    uint256 private _minAmount = 1 ether / 10;
    uint256 private _maxAmount = 5 ether / 10;
    uint256 private _tokenAmountPerBNB;

    address public _cashAddress;
    address public _tokenAddress;

    mapping(address => UserInfo) private _userInfo;
    bool private _pauseBuy = false;
    bool private _pauseClaim = true;

    uint256 public _inviteFee = 300;
    uint256 public _inviteFee1 = 200;

    mapping(address => address) public _invitor;
    mapping(address => address[]) public _binder;

    uint256 public _totalReward;
    uint256 public _totalClaimedReward;

    uint256 public _totalToken;
    uint256 public _totalClaimedToken;

    constructor(address CashAddress, address TokenAddress){
        _cashAddress = CashAddress;
        _tokenAddress = TokenAddress;
        _tokenAmountPerBNB = 500000 * 10 ** IERC20(TokenAddress).decimals();
    }

    function buy(address invitor) external payable {
        require(!_pauseBuy, "pauseBuy");
        address account = msg.sender;
        UserInfo storage userInfo = _userInfo[account];
        require(0 == userInfo.buyAmount, "bought");

        uint256 value = msg.value;
        uint256 amount = value;

        uint256 remain = _qty - _soldAmount;
        require(remain > 0, "sold out");

        if (remain > amount) {
            require(amount >= _minAmount, "lt min");
        } else {
            uint256 returnValue = value - remain;
            account.call{value : returnValue}("");
            amount = remain;
        }

        require(amount <= _maxAmount, "gt max");

        userInfo.buyAmount = amount;
        uint256 buyTokenAmount = _tokenAmountPerBNB * amount / 1 ether;
        userInfo.buyTokenAmount = buyTokenAmount;
        _totalToken += buyTokenAmount;

        _soldAmount += amount;

        uint256 cashAmount = amount;

        UserInfo storage invitorInfo = _userInfo[invitor];
        if (invitorInfo.buyAmount > 0) {
            _invitor[account] = invitor;
            _binder[invitor].push(account);
            invitorInfo.teamNum += 1;

            uint256 inviteReward = amount * _inviteFee / 10000;
            invitorInfo.inviteReward += inviteReward;
            cashAmount -= inviteReward;
            _totalReward += inviteReward;

            invitor = _invitor[invitor];
            invitorInfo = _userInfo[invitor];
            if (invitorInfo.buyAmount > 0) {
                invitorInfo.teamNum += 1;

                uint256 inviteReward1 = amount * _inviteFee1 / 10000;
                invitorInfo.inviteReward += inviteReward1;
                cashAmount -= inviteReward1;
                _totalReward += inviteReward1;
            }
        }

        _cashAddress.call{value : cashAmount}("");
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

    function claimReward() external {
        address account = msg.sender;
        UserInfo storage userInfo = _userInfo[account];

        uint256 pendingInviteReward = userInfo.inviteReward - userInfo.claimedInviteReward;
        require(pendingInviteReward > 0, "no reward");

        require(address(this).balance >= pendingInviteReward, "balance not enough");
        userInfo.claimedInviteReward += pendingInviteReward;
        account.call{value : pendingInviteReward}("");

        _totalClaimedReward += pendingInviteReward;
    }

    function _giveToken(address tokenAddress, address account, uint256 tokenNum) private {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(this)) >= tokenNum, "token balance not enough");
        token.transfer(account, tokenNum);
    }

    function getSaleInfo() external view returns (
        uint256 qty, uint256 soldAmount,
        uint256 minAmount, uint256 maxAmount,
        uint256 tokenAmountPerBNB,
        uint256 inviteFee, uint256 inviteFee1,
        bool pauseBuy, bool pauseClaim
    ) {
        qty = _qty;
        soldAmount = _soldAmount;
        minAmount = _minAmount;
        maxAmount = _maxAmount;
        tokenAmountPerBNB = _tokenAmountPerBNB;
        inviteFee = _inviteFee;
        inviteFee1 = _inviteFee1;
        pauseBuy = _pauseBuy;
        pauseClaim = _pauseClaim;
    }

    function getUserInfo(address account) external view returns (
        uint256 buyAmount,
        uint256 buyTokenAmount,
        uint256 claimedTokenAmount,
        uint256 teamNum,
        uint256 inviteReward,
        uint256 claimedInviteReward,
        uint256 balance,
        address invitor,
        uint256 binderLength
    ) {
        UserInfo storage userInfo = _userInfo[account];
        buyAmount = userInfo.buyAmount;
        buyTokenAmount = userInfo.buyTokenAmount;
        claimedTokenAmount = userInfo.claimedTokenAmount;
        teamNum = userInfo.teamNum;
        inviteReward = userInfo.inviteReward;
        claimedInviteReward = userInfo.claimedInviteReward;
        balance = account.balance;
        invitor = _invitor[account];
        binderLength = _binder[account].length;
    }

    receive() external payable {}

    function setQty(uint256 qty) external onlyOwner {
        _qty = qty;
    }

    function setMin(uint256 min) external onlyOwner {
        _minAmount = min;
    }

    function setMax(uint256 max) external onlyOwner {
        _maxAmount = max;
    }

    function setAmountPerBNB(uint256 amount) external onlyOwner {
        _tokenAmountPerBNB = amount;
    }

    function setInviteFee(uint256 fee) external onlyOwner {
        _inviteFee = fee;
    }

    function setInviteFee1(uint256 fee) external onlyOwner {
        _inviteFee1 = fee;
    }

    function setTokenAddress(address adr) external onlyOwner {
        _tokenAddress = adr;
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
}

contract PreSale is AbsPreSale {
    constructor(address cmAddr, address TokenAddr) AbsPreSale(
        cmAddr,
        TokenAddr
    ){

    }
}