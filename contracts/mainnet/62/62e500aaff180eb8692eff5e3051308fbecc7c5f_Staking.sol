/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

interface IERC20 {
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract Staking is Ownable, ReentrancyGuard {
    
    struct user{
        uint256 id;
        uint256 totalStakedBalance;
        uint256 totalClaimedRewards;
        uint256 createdTime;
    }

    struct stakePool{
        uint256 id;
        uint256 duration;
        uint256 withdrawalFee;
        uint256 unstakeFee;
        uint256 earlyUnstakePenalty;
        uint256 stakedTokens;
        uint256 claimedRewards;
        uint256 status; //1: created, 2: active, 3: cancelled
        uint256 createdTime;
    }

    stakePool[] public stakePoolArray;

    struct userStake{
        uint256 id;
        uint256 stakePoolId;
	    uint256 stakeBalance;
    	uint256 totalClaimedRewards;
    	uint256 lastClaimedTime;
        uint256 status; //0 : Unstaked, 1 : Staked
        address owner;
    	uint256 createdTime;
        uint256 lockedTime;
        uint256 unlockTime;
        uint256 lockDuration;
    }

    userStake[] public userStakeArray;

    mapping (uint256 => stakePool) public stakePoolsById;
    mapping (uint256 => userStake) public userStakesById;

    mapping (address => uint256[]) public userStakeIds;
    mapping (address => userStake[]) public userStakeLists;

    mapping (address => user) public users;

    mapping (uint256 => uint256) public apys;

    uint256 public totalInjectedRewardsSupply;
    uint256 public totalStakedBalance;
    uint256 public totalClaimedBalance;
  
    uint256 public magnitude = 100000000;

    uint256 public userIndex;
    uint256 public poolIndex;
    uint256 public stakeIndex;

    bool public isPaused;

    address public baseTokenAddress;
    IERC20 stakeToken = IERC20(baseTokenAddress);

    address public rewardTokensAddress;
    IERC20 rewardToken = IERC20(rewardTokensAddress);

    modifier unpaused {
      require(isPaused == false);
      _;
    }

    modifier paused {
      require(isPaused == true);
      _;
    }

    uint256[] _durationArray = [30,60,90,180];
    uint256[] _withdrawalFeeArray = [20,20,20,20];
    uint256[] _unstakePenaltyArray = [20,20,20,20];
    
    constructor() {
        address _baseTokenAddress = 0x7C5E8A22a4e8f9dA2797a9e30E9d64aBF5493C43; 
        address _rewardTokensAddress = 0x7C5E8A22a4e8f9dA2797a9e30E9d64aBF5493C43;

        baseTokenAddress = _baseTokenAddress;
        rewardTokensAddress = _rewardTokensAddress;
        
        stakeToken = IERC20(baseTokenAddress);
        rewardToken = IERC20(rewardTokensAddress);

        for(uint256 i = 0; i < _durationArray.length; i++){
            addStakePool(
                _durationArray[i], // Duration in days
                _withdrawalFeeArray[i], // Withdrawal fees percentage
                _unstakePenaltyArray[i] // Early unstake penalty
            );
        }
        apys[30] = 30;
        apys[60] = 60;
        apys[90] = 90;
        apys[180] = 180;
    }
    
    function addStakePool(uint256 _duration, uint256 _withdrawalFee, uint256 _unstakePenalty) public onlyOwner returns (bool){

        stakePool memory stakePoolDetails;
        
        stakePoolDetails.id = poolIndex;
        stakePoolDetails.duration = _duration;
        stakePoolDetails.withdrawalFee = _withdrawalFee;
        stakePoolDetails.earlyUnstakePenalty = _unstakePenalty;
        
        stakePoolDetails.createdTime = block.timestamp;
       
        stakePoolArray.push(stakePoolDetails);
        stakePoolsById[poolIndex++] = stakePoolDetails;

        return true;
    }

    function getAPY(uint256 _lockDuration) public view returns (uint256){
        return apys[_lockDuration];
    }

    
    function getDPR(uint256 _lockDuration) public view returns (uint256){
        uint256 apy = getAPY(_lockDuration);
        uint256 dpr = (apy * magnitude) / 365;
        return dpr;
    }

    function getStakePoolDetailsById(uint256 _stakePoolId) public view returns(stakePool memory){
        return (stakePoolArray[_stakePoolId]);
    }

    function stake(uint256 _stakePoolId, uint256 _amount) unpaused external returns (bool) {
        stakePool memory stakePoolDetails = stakePoolsById[_stakePoolId];

        require(stakeToken.allowance(msg.sender, address(this)) >= _amount,'Tokens not approved for transfer');
        
        bool success = stakeToken.transferFrom(msg.sender, address(this), _amount);
        require(success, "Token Transfer failed.");

        userStake memory userStakeDetails;

        uint256 userStakeid = stakeIndex++;
        userStakeDetails.id = userStakeid;
        userStakeDetails.stakePoolId = _stakePoolId;
        userStakeDetails.stakeBalance = _amount;
        userStakeDetails.status = 1;
        userStakeDetails.owner = msg.sender;
        userStakeDetails.createdTime = block.timestamp;
        userStakeDetails.unlockTime = block.timestamp + (stakePoolDetails.duration * 1 days);
        userStakeDetails.lockDuration = stakePoolDetails.duration;
        userStakeDetails.lockedTime = block.timestamp;
        userStakesById[userStakeid] = userStakeDetails;
    
        uint256[] storage userStakeIdsArray = userStakeIds[msg.sender];
    
        userStakeIdsArray.push(userStakeid);
        userStakeArray.push(userStakeDetails);
    
        userStake[] storage userStakeList = userStakeLists[msg.sender];
        userStakeList.push(userStakeDetails);
        
        user memory userDetails = users[msg.sender];

        if(userDetails.id == 0){
            userDetails.id = ++userIndex;
            userDetails.createdTime = block.timestamp;
        }

        userDetails.totalStakedBalance += _amount;

        users[msg.sender] = userDetails;

        stakePoolDetails.stakedTokens += _amount;
    
        stakePoolArray[_stakePoolId] = stakePoolDetails;
        
        stakePoolsById[_stakePoolId] = stakePoolDetails;

        totalStakedBalance = totalStakedBalance + _amount;
        
        return true;
    }

    function restake(uint256 _stakeId) nonReentrant unpaused external returns (bool){
        userStake memory userStakeDetails = userStakesById[_stakeId];
      
        require(userStakeDetails.owner == msg.sender,"You don't own this stake");
        require(userStakeDetails.status == 1,"You have already unstaked");

        userStakeDetails.lockedTime = block.timestamp;
        userStakeDetails.unlockTime = userStakeDetails.lockDuration * 1 days;

        userStakesById[_stakeId] = userStakeDetails;
        updateStakeArray(_stakeId);

        return true; 
    }

    function unstake(uint256 _stakeId) nonReentrant external returns (bool){
        userStake memory userStakeDetails = userStakesById[_stakeId];
        uint256 stakePoolId = userStakeDetails.stakePoolId;
        uint256 stakeBalance = userStakeDetails.stakeBalance;
        
        require(userStakeDetails.owner == msg.sender,"You don't own this stake");
        require(userStakeDetails.status == 1,"You have already unstaked");
        
        stakePool memory stakePoolDetails = stakePoolsById[stakePoolId];

        uint256 unstakableBalance;
  
        uint256 claimableRewards;
        uint256 earlyUnstakePenaltyAmount;

        if(isStakeLocked(_stakeId) && isPaused == false){
            claimableRewards = getUnclaimedRewards(_stakeId);
            earlyUnstakePenaltyAmount = (claimableRewards * stakePoolDetails.earlyUnstakePenalty)/100;
          
            unstakableBalance = stakeBalance - (stakeBalance * stakePoolDetails.withdrawalFee)/(100) + (claimableRewards - earlyUnstakePenaltyAmount);
           
        }else{
            unstakableBalance = stakeBalance;
        }

        userStakeDetails.status = 0;

        userStakesById[_stakeId] = userStakeDetails;

        stakePoolDetails.stakedTokens = stakePoolDetails.stakedTokens - stakeBalance;

        userStakesById[_stakeId] = userStakeDetails;

        user memory userDetails = users[msg.sender];
        userDetails.totalStakedBalance =   userDetails.totalStakedBalance - stakeBalance;

        users[msg.sender] = userDetails;

        stakePoolsById[stakePoolId] = stakePoolDetails;

        updateStakeArray(_stakeId);

        totalStakedBalance =  totalStakedBalance - stakeBalance;

        require(stakeToken.balanceOf(address(this)) >= unstakableBalance, "Insufficient contract token balance");
        
        bool success;

        success = stakeToken.transfer(msg.sender, unstakableBalance);
        require(success, "Token Transfer failed.");

        success = false;

        if(earlyUnstakePenaltyAmount > 0 && stakeToken.balanceOf(address(this)) > 0){
            success = rewardToken.transfer(owner(), earlyUnstakePenaltyAmount);
            require(success, "Token Transfer failed.");
        }

        return true;
    }

    function isStakeLocked(uint256 _stakeId) public view returns (bool) {
        userStake memory userStakeDetails = userStakesById[_stakeId];
        if(block.timestamp < userStakeDetails.unlockTime){
            return true;
        }else{
            return false;
        }
    }

    function getStakePoolIdByStakeId(uint256 _stakeId) public view returns(uint256){
        userStake memory userStakeDetails = userStakesById[_stakeId];
        return userStakeDetails.stakePoolId;
    }

    function getUserStakeIds() public view returns(uint256[] memory){
        return (userStakeIds[msg.sender]);
    }

    function getUserStakeIdsByAddress(address _userAddress) public view returns(uint256[] memory){
         return(userStakeIds[_userAddress]);
    }

    
    function getUserAllStakeDetails() public view returns(userStake[] memory){
        return (userStakeLists[msg.sender]);
    }

    function getUserAllStakeDetailsByAddress(address _userAddress) public view returns(userStake[] memory){
        return (userStakeLists[_userAddress]);
    }

    function getUserStakeOwner(uint256 _stakeId) public view returns (address){
        userStake memory userStakeDetails = userStakesById[_stakeId];
        return userStakeDetails.owner;
    }

    function getUserStakeBalance(uint256 _stakeId) public view returns (uint256){
        userStake memory userStakeDetails = userStakesById[_stakeId];
        return userStakeDetails.stakeBalance;
    }
    
    function getUnclaimedRewards(uint256 _stakeId) public view returns (uint256){
        userStake memory userStakeDetails = userStakeArray[_stakeId];
        uint256 stakePoolId = userStakeDetails.stakePoolId;

        stakePool memory stakePoolDetails = stakePoolsById[stakePoolId];
        uint256 stakeApr = getDPR(stakePoolDetails.duration);

        uint applicableRewards = (userStakeDetails.stakeBalance * stakeApr)/(magnitude * 100); //divided by 10000 to handle decimal percentages like 0.1%
        uint unclaimedRewards = (applicableRewards * getElapsedTime(_stakeId));

        return unclaimedRewards; 
    }

    function getElapsedTime(uint256 _stakeId) public view returns(uint256){
        userStake memory userStakeDetails = userStakesById[_stakeId];
        uint256 lapsedDays;

        if(block.timestamp > userStakeDetails.unlockTime){  
            lapsedDays = userStakeDetails.lockDuration;
        } else{
            lapsedDays = ((block.timestamp - userStakeDetails.lockedTime)/3600)/24; //3600 seconds per hour so: lapsed days = lapsed time * (3600seconds /24hrs)
        }
        return lapsedDays;  
    }
    
    function getTotalUnclaimedRewards(address _userAddress) public view returns (uint256){
        uint256[] memory stakeIds = getUserStakeIdsByAddress(_userAddress);
        uint256 totalUnclaimedRewards;
        for(uint256 i = 0; i < stakeIds.length; i++) {
            userStake memory userStakeDetails = userStakesById[stakeIds[i]];
            if(userStakeDetails.status == 1){
                totalUnclaimedRewards += getUnclaimedRewards(stakeIds[i]);
            }
        }
        return totalUnclaimedRewards;
    }

    
    function getAllPoolDetails() public view returns(stakePool[] memory){
        return (stakePoolArray);
    }

    function claimRewards(uint256 _stakeId) nonReentrant unpaused public returns (bool){
        
        address userStakeOwner = getUserStakeOwner(_stakeId);
        require(userStakeOwner == msg.sender,"You don't own this stake");

        userStake memory userStakeDetails = userStakesById[_stakeId];
        uint256 stakePoolId = userStakeDetails.stakePoolId;

        require(userStakeDetails.status == 1, "You can not claim after unstaked");
        require(isStakeLocked(_stakeId) == false,"You can not withdraw");
        
        stakePool memory stakePoolDetails = stakePoolsById[stakePoolId];

        uint256 unclaimedRewards = getUnclaimedRewards(_stakeId);
        
        userStakeDetails.totalClaimedRewards = userStakeDetails.totalClaimedRewards + unclaimedRewards;
        userStakeDetails.lastClaimedTime = block.timestamp;
        userStakeDetails.lockedTime = block.timestamp;

       
        userStakeDetails.unlockTime = userStakeDetails.lockedTime + (stakePoolDetails.duration * 1 days);
        
        userStakesById[_stakeId] = userStakeDetails;
        updateStakeArray(_stakeId);

        totalClaimedBalance += unclaimedRewards;

        user memory userDetails = users[msg.sender];
        userDetails.totalClaimedRewards  +=  unclaimedRewards;

        users[msg.sender] = userDetails;

        require(rewardToken.balanceOf(address(this)) >= unclaimedRewards, "Insufficient contract reward token balance");

        if(rewardToken.decimals() < stakeToken.decimals()){
            unclaimedRewards = unclaimedRewards * (10**(stakeToken.decimals() - rewardToken.decimals()));
        }else if(rewardToken.decimals() > stakeToken.decimals()){
            unclaimedRewards = unclaimedRewards / (10**(rewardToken.decimals() - stakeToken.decimals()));
        }

        bool success = rewardToken.transfer(msg.sender, unclaimedRewards);
        require(success, "Token Transfer failed.");

        return true;
    }

    function updateStakeArray(uint256 _stakeId) internal {
        userStake[] storage userStakesArray = userStakeLists[msg.sender];
        
        for(uint i = 0; i < userStakesArray.length; i++){
            userStake memory userStakeFromArrayDetails = userStakesArray[i];
            if(userStakeFromArrayDetails.id == _stakeId){
                userStake memory userStakeDetails = userStakesById[_stakeId];
                userStakesArray[i] = userStakeDetails;
            }
        }
    }

    function getUserDetails(address _userAddress) external view returns (user memory){
        user memory userDetails = users[_userAddress];
        return(userDetails);
    }
    
    function pauseStake(bool _pauseStatus) public onlyOwner(){
        isPaused = _pauseStatus;
    }
    
    function injectRewardsSupply(uint256 _amount) public {
        require(rewardToken.allowance(msg.sender, address(this)) >= _amount,'Tokens not approved for transfer');
        
        bool success = rewardToken.transferFrom(msg.sender, address(this), _amount);
        require(success, "Token Transfer failed.");
        totalInjectedRewardsSupply += _amount;
    }

    function withdrawContractETH() public onlyOwner paused returns(bool){
        bool success;
        (success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");

        return true;
    }

    function withdrawInjectedRewardSupply(uint256 _amount) public onlyOwner paused returns(bool){
        bool success;
        
        require(_amount <= totalInjectedRewardsSupply,"Can not withdraw more than injected supply");
        success = rewardToken.transfer(msg.sender, _amount);
        require(success, "Token Transfer failed.");

        totalInjectedRewardsSupply -= _amount;
        return true;
    }

    function recoverERC20(address _tokenAddress, uint256 _tokenAmount) public paused onlyOwner {
        IERC20(_tokenAddress).transfer(msg.sender, _tokenAmount);
    }

    receive() external payable {}
}