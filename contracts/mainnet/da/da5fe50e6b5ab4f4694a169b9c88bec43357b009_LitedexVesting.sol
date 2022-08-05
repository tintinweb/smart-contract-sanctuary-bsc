/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

pragma solidity 0.8.9;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity 0.8.9;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() external onlyOwner returns(bool) {
        _transferOwnership(address(0));
        return true;
    }

    function transferOwnership(address newOwner) external onlyOwner returns(bool) {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
        return true;
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library SafeBEP20 {
    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        require(token.approve(spender, value));
    }
}

pragma solidity 0.8.9;

contract LitedexVesting is Ownable {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    address[] private vip;
    address private tokenAddress;
    uint256 private totalReward;
    uint256 private rewardBalance;
    uint private globalRate;
    bool private isStopped = true;

    struct vesting{
        uint typeVesting;
        uint256 totalVesting;
        uint256 lastClaim;
        uint256 totalClaim;
        bool isWhitelisted;
    }

    mapping(address => vesting) private vestingData;

    modifier isWhitelist(){
        (bool status) = vestingData[msg.sender].isWhitelisted; 
        require(status, "You don't have any authorize to claim");
        _;
    }

    constructor(address _tokenAddress, uint _initGlobalRate){
        tokenAddress = _tokenAddress;
        globalRate = _initGlobalRate;
    }

    event RewardsAdded(uint256 rewards, uint256 time);
    event RewardsRemoved(uint256 rewards, uint256 time);
    event SetGlobalRate(uint256 newGlobalRate);

    // Read Function
    function getTypeVesting(address _account) external view returns(uint){
        (uint typeVesting) = vestingData[_account].typeVesting;
        return typeVesting;
    }

    function getGlobalRate() external view returns(uint){
        return globalRate;
    }
    
    function getAllowedVesting(address _account) external view returns(uint256){
        (uint allowedVesting) = _allowedClaim(_account);
        return allowedVesting;
    }
    function getTotalClaim(address _account) external view returns(uint256){
        (uint totalClaim) = vestingData[_account].totalClaim;
        return totalClaim;
    }
    function getStatusVesting(address _account) external view returns(bool){
        (bool statusVesting) = vestingData[_account].isWhitelisted;
        return statusVesting;
    }
    function getTotalVesting(address _account) external view returns(uint256){
        (uint totalVesting) = vestingData[_account].totalVesting;
        return totalVesting;
    }

    function getTotalReward() external view returns(uint256){
        return totalReward;
    }

    function getRewardBalance() external view returns(uint256){
        return rewardBalance;
    }

    function supportedVipAddress() external view returns(address[] memory){
        return vip;
    }

    function vestings(address _account) external view returns(
        address Account, uint TypeVesting, uint256 TotalVesting, uint256 LastClaim, uint256 TotalClaim, bool IsWhitelisted
    ){
        address account = _account;
        (   uint typeVesting,
            uint256 totalVesting,
            uint256 lastClaim,
            uint256 totalClaim,
            bool isWhitelisted
        ) = (   vestingData[account].typeVesting,
                vestingData[account].totalVesting,
                vestingData[account].lastClaim,
                vestingData[account].totalClaim,
                vestingData[account].isWhitelisted
        );
        return (account, typeVesting, totalVesting, lastClaim, totalClaim, isWhitelisted);
    }

    // Ownership Function
    function addVipAddress(address _vipAddress) external onlyOwner {
        require(_vipAddress != address(0), "_vipAddress is zero address");
        require(isStopped, "Migration is running");
        vip.push(_vipAddress);
    }

    function removeVipAddress(address _vipAddress) external onlyOwner {
        require(_vipAddress != address(0), "_vipAddress is zero address");
        require(isStopped, "Migration is running");
        uint index;
        for(uint i=0;i<vip.length;i++){
            if(vip[i] == _vipAddress){
                index = i;
            }
        }
        delete vip[index];
    }

    function addReward(uint256 _rewardAmount) external onlyOwner _hasAllowance(msg.sender, _rewardAmount) returns (bool) {
        require(_rewardAmount > 0, "Reward must be positive");
        require(isStopped, "Migration is started");
        totalReward = totalReward.add(_rewardAmount);
        rewardBalance = rewardBalance.add(_rewardAmount);
        if (!_payMe(msg.sender, _rewardAmount)) {
            return false;
        }
        emit RewardsAdded(_rewardAmount, block.timestamp);
        return true;
    }
    
    function removeReward(uint256 _rewardAmount) external onlyOwner returns (bool) {
        require(_rewardAmount > 0, "Reward must be positive");
        require(isStopped, "Migration is started");
        if (_payDirect(msg.sender, _rewardAmount)) {
            totalReward = totalReward.sub(_rewardAmount);
            rewardBalance = rewardBalance.sub(_rewardAmount);
        }
        emit RewardsRemoved(_rewardAmount, block.timestamp);
        return true;
    }

    function redeemVip(uint _id, uint256 _amount) external onlyOwner {
        require(isStopped, "Migration is running");
        IBEP20 BEP20Interface = IBEP20(vip[_id]);
        BEP20Interface.safeTransfer(msg.sender, _amount);
    }

    function setWhitelist(address _account, uint _typeVesting, uint256 _totalVesting) external onlyOwner {
        require(_account != address(0), "Account is zero address");
        vestingData[_account].typeVesting = _typeVesting;
        vestingData[_account].totalVesting = _totalVesting;
        vestingData[_account].isWhitelisted = true;
    }

    function setStatusVip(address _account, bool _status) external onlyOwner {
        require(_account != address(0), "Account is zero address");
        vestingData[_account].isWhitelisted = _status;
    }

    function setStatusContract(bool _status) external onlyOwner {
        isStopped = _status;
    }

    function setGlobalRate(uint _newGlobalRate) external onlyOwner {
        require(_newGlobalRate > 0, "GlobalRate is 0");
        globalRate = _newGlobalRate;

        emit SetGlobalRate(_newGlobalRate);
    }

    // Public Function
    function claim() external isWhitelist returns(bool) {
        require(!isStopped, "Migration is closed");
        (uint256 allowed) = (_allowedClaim(msg.sender));
        require(allowed > 0, "Has Claim");
        if(!_payMe(msg.sender, allowed)){
            return false;
        }
        if(_payDirect(msg.sender, allowed)){
            rewardBalance = rewardBalance.sub(allowed);
            vestingData[msg.sender].totalClaim = vestingData[msg.sender].totalClaim.add(allowed);
            vestingData[msg.sender].lastClaim = block.number;
        }
        return true;
    }

    // Private Function
    function _allowedClaim(address _account) private view returns(uint256){
        (uint256 totalVesting, uint256 totalClaim) = (
            vestingData[_account].totalVesting,
            vestingData[_account].totalClaim
        );
        uint256 earning = totalVesting.mul(globalRate).div(100);
        return (totalClaim < earning) ? earning.sub(totalClaim) : 0;
    }

    function _payMe(address _payer, uint256 _amount) private returns (bool) {
        return _payTo(_payer, address(this), _amount);
    }

    function _payTo(
        address _allower,
        address _receiver,
        uint256 _amount
    ) private _hasAllowance(_allower, _amount) returns (bool) {
        address _caller;
        if(msg.sender == address(owner())){
            _caller = tokenAddress;
        }else{
            (uint typeVesting) = vestingData[msg.sender].typeVesting;
            _caller = vip[typeVesting];
        }
        
        IBEP20 BEP20Interface = IBEP20(_caller);
        BEP20Interface.safeTransferFrom(_allower, _receiver, _amount);
        return true;
    }

    function _payDirect(address _to, uint256 _amount) private returns (bool) {
        IBEP20 BEP20Interface = IBEP20(tokenAddress);
        BEP20Interface.safeTransfer(_to, _amount);
        return true;
    }

    modifier _hasAllowance(address _allower, uint256 _amount) {
        // Make sure the allower has provided the right allowance.
        address _caller;
        if(msg.sender == address(owner())){
            _caller = tokenAddress;
        }else{
            (uint typeVesting) = vestingData[msg.sender].typeVesting;
            _caller = vip[typeVesting];
        }
        IBEP20 BEP20Interface = IBEP20(_caller);
        uint256 _ourAllowance = BEP20Interface.allowance(_allower, address(this));
        require(_amount <= _ourAllowance, "Make sure to add enough allowance");
        
        _;
    }
}