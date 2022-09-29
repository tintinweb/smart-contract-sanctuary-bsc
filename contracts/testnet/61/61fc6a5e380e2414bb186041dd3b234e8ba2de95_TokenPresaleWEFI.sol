/**
 *Submitted for verification at BscScan.com on 2022-09-28
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface ITokenVestingWEFI {
    function createVestingSchedule(address _beneficiary, uint256 _start, uint256 _cliff, uint256 _duration, uint256 _slicePeriodSeconds, uint256 _amount) external;
}

contract TokenPresaleWEFI is Ownable, ReentrancyGuard {
    IERC20 public immutable tokenAddress;
    uint256 public tokenPriceInWei;
    uint8 private _tokenDecimals = 18;

    uint8 public referralCommissionPercentage = 12;
    mapping(address => uint256) private _referralAddressToCode;
    mapping(uint256 => address) private _referralCodeToAddress;
    uint256 referralCodeCount = 10000;

    ITokenVestingWEFI public vestingContractAddress;
    uint256 buyerVestingCliff;
    uint256 buyerVestingStart;
    uint256 buyerVestingDuration;
    uint256 buyerVestingSlicePeriodSeconds;
    uint256 referrerVestingCliff;
    uint256 referrerVestingStart;
    uint256 referrerVestingDuration;
    uint256 referrerVestingSlicePeriodSeconds;

    event TokenSold(address, uint256);
    event TokenPriceChanged(uint256, uint256);
    event ReferralCommissionChanged(uint256, uint256);
    event ReferralCodeGenerated(address, uint256);
    event ReferralCommissionSent(address, uint256);
    event BuyerVestingScheduleChanged(uint256, uint256, uint256, uint256);
    event ReferrerVestingScheduleChanged(uint256, uint256, uint256, uint256);
    event VestingContractAddressChanged(address, address);

    constructor(address _tokenAddress, uint256 _tokenPriceInWei, address _vestingContractAddress) {
        require(_tokenAddress != address(0x0));
        tokenAddress = IERC20(_tokenAddress);
        tokenPriceInWei = _tokenPriceInWei;

        vestingContractAddress = ITokenVestingWEFI(_vestingContractAddress);
        buyerVestingCliff = buyerVestingStart = buyerVestingDuration = buyerVestingSlicePeriodSeconds = 1;
        referrerVestingCliff = referrerVestingStart = referrerVestingDuration = referrerVestingSlicePeriodSeconds = 1;
    }

    function generateReferralCode(address accountAddress) public returns (bool){
        require(_referralAddressToCode[accountAddress] != 0, "TokenPresaleWEFI: referral code already generated");
        
        referralCodeCount = referralCodeCount + 7;
        _referralAddressToCode[accountAddress] = referralCodeCount;
        _referralCodeToAddress[referralCodeCount] = accountAddress;
        
        emit ReferralCodeGenerated(accountAddress, referralCodeCount);
        return true;
    }

    function showReferralCode(address referrer) external view returns (uint256){
        return _referralAddressToCode[referrer];
    }

    function changeReferralCommissionPercentage(uint8 newPercentage) external onlyOwner returns (bool) {
        uint256 oldPercentage = referralCommissionPercentage;
        referralCommissionPercentage = newPercentage;

        emit ReferralCommissionChanged(oldPercentage, newPercentage);
        return true;
    }

    function changeTokenPrice(uint256 newPrice) external onlyOwner returns (bool)
    {
        require(newPrice > 0, "TokenPresaleWEFI: token price must be greater than 0 wei");

        uint256 oldPrice = tokenPriceInWei;
        tokenPriceInWei = newPrice;

        emit TokenPriceChanged(oldPrice, newPrice);
        return true;
    }

    function changeVestingContractAddress(address newContractAddress) external onlyOwner returns (bool)
    {
        require(newContractAddress != address(0), "TokenPresaleWEFI: new contract address is the zero address");
        address oldContractAddress = address(vestingContractAddress);
        vestingContractAddress = ITokenVestingWEFI(newContractAddress);

        emit VestingContractAddressChanged(oldContractAddress, newContractAddress);
        return true;
    }

    function changeBuyerVestingSchedule(uint256 _buyerVestingCliff, uint256 _buyerVestingStart, uint256 _buyerVestingDuration, uint256 _buyerVestingSlicePeriodSeconds) external onlyOwner returns (bool) {
        buyerVestingCliff = _buyerVestingCliff;
        buyerVestingStart = _buyerVestingStart;
        buyerVestingDuration = _buyerVestingDuration;
        buyerVestingSlicePeriodSeconds = _buyerVestingSlicePeriodSeconds;

        emit BuyerVestingScheduleChanged(_buyerVestingCliff, _buyerVestingStart, _buyerVestingDuration, _buyerVestingSlicePeriodSeconds);
        return true;
    }

    function changeReferrerVestingSchedule(uint256 _referrerVestingCliff, uint256 _referrerVestingStart, uint256 _referrerVestingDuration, uint256 _referrerVestingSlicePeriodSeconds) external onlyOwner returns (bool) {
        referrerVestingCliff = _referrerVestingCliff;
        referrerVestingStart = _referrerVestingStart;
        referrerVestingDuration = _referrerVestingDuration;
        referrerVestingSlicePeriodSeconds = _referrerVestingSlicePeriodSeconds;

        emit ReferrerVestingScheduleChanged(_referrerVestingCliff, _referrerVestingStart, _referrerVestingDuration, _referrerVestingSlicePeriodSeconds);
        return true;
    }

    function getBuyerVestingSchedule() external view returns (uint256, uint256, uint256, uint256)
    {
        return (buyerVestingCliff, buyerVestingStart, buyerVestingDuration, buyerVestingSlicePeriodSeconds);
    }

    function getReferrerVestingSchedule() external view returns (uint256, uint256, uint256, uint256)
    {
        return (referrerVestingCliff, referrerVestingStart, referrerVestingDuration, referrerVestingSlicePeriodSeconds);
    }

    function buyToken(uint256 referralCode) external payable nonReentrant returns (bool) {
        _buyToken(referralCode);

        return true;
    }

    function _buyToken(uint256 referralCode) private {
        require(msg.value >= 1 wei, "TokenPresaleWEFI: sent BNB amount must be greater than 0 wei");

        address buyer = _msgSender();
        if(_referralAddressToCode[buyer] == 0){ generateReferralCode(buyer); }
        address referrer = _referralCodeToAddress[referralCode];
        uint256 contractTokenBalance = getContractTokenBalance();
        uint256 buyableTokens = _buyableTokens();
        uint256 commissionedTokens = 0;

        if(referrer != address(0)){ commissionedTokens = _commissionedTokens(buyableTokens); }
        require(contractTokenBalance >= (buyableTokens+commissionedTokens), "TokenPresaleWEFI: buyable/commissioned token amount exceeds presale contract balance");
        _sendToBuyerVesting(buyer, buyableTokens);
        if(referrer != address(0)){ _sendToReferrerVesting(referrer, commissionedTokens); }
    }

    function _buyableTokens() private view returns (uint256) {
        uint256 buyableTokens = (msg.value * 10**_tokenDecimals) / tokenPriceInWei;
        
        return buyableTokens;
    }

    function _commissionedTokens(uint256 buyableTokens) private view returns (uint256) {
        uint256 commissionedTokens = ((buyableTokens*referralCommissionPercentage)/100);
        
        return commissionedTokens;
    }

    function _sendToBuyerVesting(address beneficiary, uint256 amount) private {
        require(tokenAddress.approve(address(vestingContractAddress), amount), "TokenPresaleWEFI: token WEFI approve to vesting contract not succeeded");

        vestingContractAddress.createVestingSchedule(beneficiary, buyerVestingStart, buyerVestingCliff, buyerVestingDuration, buyerVestingSlicePeriodSeconds, amount);
        emit TokenSold(beneficiary, amount);
    }

    function _sendToReferrerVesting(address beneficiary, uint256 amount) private {
        require(tokenAddress.approve(address(vestingContractAddress), amount), "TokenPresaleWEFI: token WEFI approve to vesting contract not succeeded");

        vestingContractAddress.createVestingSchedule(beneficiary, referrerVestingStart, referrerVestingCliff, referrerVestingDuration, referrerVestingSlicePeriodSeconds, amount);
        emit ReferralCommissionSent(beneficiary, amount);
    }

    function getContractBnbBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function withdrawBnbBalance() external onlyOwner returns (bool) {

        bool sent = payable(owner()).send(address(this).balance);
        require(sent, "Failed to send ETH");

        return true;
    }

    function getContractTokenBalance() public view returns (uint256) {
        return tokenAddress.balanceOf(address(this));
    }

    function withdrawContractTokenBalance(uint256 amount) external nonReentrant onlyOwner returns (bool)
    {
        require(getContractTokenBalance() >= amount, "TokenVestingWEFI: not enough withdrawable funds");
        require(tokenAddress.transfer(owner(), amount), "TokenPresaleWEFI: token WEFI transfer to owner not succeeded");

        return true;
    }

    function getCurrentTime() external view returns (uint256) {
        return block.timestamp;
    }

    receive() external payable {
        _buyToken(0);
    }

    fallback() external payable {
        _buyToken(0);
    }
}