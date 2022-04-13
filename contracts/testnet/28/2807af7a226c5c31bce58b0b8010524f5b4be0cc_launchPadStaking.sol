/**
 *Submitted for verification at BscScan.com on 2022-04-13
*/

// SPDX-License-Identifier: UNLICENSED
    pragma solidity ^0.8.4;

    interface IERC20 {
        function totalSupply() external view returns (uint256);
        function balanceOf(address account) external view returns (uint256);
        function transfer(address recipient, uint256 amount) external returns (bool);
        function allowance(address owner, address spender) external view returns (uint256);
        function approve(address spender, uint256 amount) external returns (bool);
        function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);
    }

    interface IERC20Metadata is IERC20 {

        function decimals() external view returns (uint8);

    }

    interface IStakeable {

        function getStakedAmount(address user) external view returns(uint);
        function isStaker(address user) external view returns(bool);
        function getTotalParticipants() external view returns(uint256);
        function getParticipantsByTierId(uint256 tierId, uint256 poolLevel) external view returns(uint256);
        function isAllocationEligible(uint participationEndTime) external view returns(bool);
        function getTierIdFromUser(address sender) external view returns(uint, uint);
        function isWhiteListaddress(address account) external view returns(bool);

    }

    contract launchPadStaking is IStakeable {

        IERC20Metadata public stakingToken;
        address public owner; 
        address public signer;
        uint256 public totalStaked;
        uint8 decimals;

        event ProjectInitiated(address indexed token);

        enum tierLevel {Null,BRONZE,SILVER,GOLD,PLATINUM,EMERALD,DIAMOND}
        
        mapping(tierLevel => mapping(uint => uint)) tierParticipants;

        uint256 fee = 10;


        struct poolDetails {
            uint256 poolLevel;
            uint256 poolRewardPercent;
            uint256 poolLimit;
        }

        struct User {
            tierLevel tierId;
            uint256 poolLevel;
            uint256 stakeAmount;
            uint256 rewards;
            uint256 intialStakingTime;
            uint256 lastStakedTime;
            bool isStaker;
            bool isUnstakeInitiated;
            uint256 unstakeAmount;
            uint256 unstakeInitiatedTime;
            uint256 unstakeLimit;
            uint256 withdrawStakedAmount;
            uint256 withdrawRewardAmount;
        } 

        struct Sign {
            uint8 v;
            bytes32 r;
            bytes32 s;
            uint256 nonce;
        }

        mapping (address => User) private Users;
        mapping(uint256 => poolDetails) private pool;
        mapping(uint256 => bool) private usedNonce;
        mapping(address => bool) private isWhitelist;
        address[] private whiteListes;
        uint256 private whitelistCount;


        event Stake(address user, uint amount);
        event Unstake(address user, uint unstakedAmount);
        event Withdraw(address user, uint withdrawAmount);
        event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
        event SignerAddressUpdated(address indexed previousSigner, address indexed newSigner);

        constructor (IERC20Metadata _stakingToken){
            stakingToken = _stakingToken;
            owner = msg.sender;
            signer = msg.sender;
            decimals = stakingToken.decimals();

            pool[1].poolLevel = 1;
            pool[1].poolRewardPercent = 15;
            pool[1].poolLimit = 0;
            
            pool[2].poolLevel = 2;
            pool[2].poolRewardPercent = 50;
            pool[2].poolLimit = 180 days;
            
            pool[3].poolLevel = 3;
            pool[3].poolRewardPercent = 100;
            pool[3].poolLimit = 360 days;
        }


        modifier onlyOwner() {
            require(owner == msg.sender, "Ownable: caller is not the owner");
            _;
        }

        modifier onlySigner() {
            require(signer == msg.sender, "Ownable: caller is not the signer");
            _;
        }

        function transferOwnership(address newOwner) external onlyOwner returns(bool){
            require(newOwner != address(0), "Ownable: new owner is the zero address");
            address oldOwner = owner;
            owner = newOwner;
            emit OwnershipTransferred(oldOwner, newOwner);
            return true;
        }

        function setSignerAddress(address newSigner) external onlySigner {
            require(newSigner != address(0), "Ownable: new signer is the zero address");
            address oldSigner = signer;
            signer = newSigner;
            emit SignerAddressUpdated(oldSigner, newSigner);
        }

        function verifySign(address caller, uint256 amount, uint tier, uint256 _stakePool, Sign memory sign) internal view {
            bytes32 hash = keccak256(abi.encodePacked(this, caller, amount, tier, _stakePool, sign.nonce));
            require(signer == ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)), sign.v, sign.r, sign.s), "Owner sign verification failed");

        }
        
        function getTotalStaked() external view returns(uint256){
            return totalStaked;
        }
        
        function isWhiteListaddress(address account) external override view returns(bool) {
            return isWhitelist[account];
        }

        function updateTier(uint amount) internal view returns(uint8){

            if(amount >= 1000 * 10 ** decimals  && amount < 3000 * 10 ** decimals){
                return 1;
            }
            else if(amount >= 3000 * 10 ** decimals && amount < 6000 * 10 ** decimals){
                return 2;
            }
            else if(amount >= 6000 * 10 ** decimals && amount < 12000 * 10 ** decimals){
                return 3;
            }
            else if(amount >= 12000 * 10 ** decimals && amount < 25000 * 10 ** decimals){
                return 4;
            }
            else if(amount >= 25000 * 10 ** decimals && amount < 60000 * 10 ** decimals ){
                return 5;
            }
            else if(amount >= 60000 * 10 ** decimals) {
                return 6;
            }
            else {
                return 0;
            }
        }

        function stake(uint256 amount, uint256 _stakePool, Sign memory sign) external {
            require(_stakePool > 0 && _stakePool <= 3, "Pool value must me greater than 0/less than 3");
            require(!usedNonce[sign.nonce], "Nonce : Invalid Nonce");
            usedNonce[sign.nonce] = true;
            require(amount >= 1000 * 10 ** decimals, "amount must be greater then or equal to minimum value");
            uint256 tier = updateTier(amount);
            require(!Users[msg.sender].isStaker,"staking already enabled");
            verifySign(msg.sender, amount, tier, _stakePool, sign);
            Users[msg.sender].tierId = tierLevel(tier);
            Users[msg.sender].poolLevel = _stakePool;
            Users[msg.sender].isStaker = true;
            Users[msg.sender].stakeAmount += amount;
            Users[msg.sender].intialStakingTime = block.timestamp;
            Users[msg.sender].lastStakedTime = block.timestamp;
            tierParticipants[tierLevel(Users[msg.sender].tierId)][_stakePool] += 1;
            _stake(amount);
        }
        
        function _stake(uint256 amount) internal {
            updateReward();
            totalStaked += amount;
            stakingToken.transferFrom(msg.sender, address(this), amount);
            emit Stake(msg.sender,amount);
        }

        function unStake(uint256 amount, Sign memory sign) external {
            verifySign(msg.sender, amount, uint(Users[msg.sender].tierId), Users[msg.sender].poolLevel, sign);
            updateReward();
            require(!Users[msg.sender].isUnstakeInitiated,"you have already a unstake initiated");

            if(Users[msg.sender].poolLevel == 1) {
                Users[msg.sender].unstakeLimit = block.timestamp + 5 days;
            }
            else if(Users[msg.sender].poolLevel == 2) {
                require(block.timestamp >= Users[msg.sender].intialStakingTime + pool[2].poolLimit, "staking timeLimit is not reached");
            }
            else if(Users[msg.sender].poolLevel == 3) {
                require(block.timestamp >= Users[msg.sender].intialStakingTime + pool[3].poolLimit, "staking timeLimit is not reached");
            }
        
            Users[msg.sender].unstakeAmount += amount;
            Users[msg.sender].stakeAmount -= amount;
            uint256 currentTier = uint256(Users[msg.sender].tierId);
            Users[msg.sender].tierId = tierLevel(updateTier(Users[msg.sender].stakeAmount));
            updateParticipants(currentTier);

            Users[msg.sender].isStaker = Users[msg.sender].stakeAmount != 0 ? true : false;
            Users[msg.sender].intialStakingTime = Users[msg.sender].stakeAmount != 0 ? block.timestamp : 0;
            Users[msg.sender].isUnstakeInitiated = true;
            totalStaked -= amount;
            Users[msg.sender].unstakeInitiatedTime = block.timestamp;
            Users[msg.sender].poolLevel = Users[msg.sender].stakeAmount != 0 ? Users[msg.sender].poolLevel : 0;
            emit Unstake(msg.sender, amount);
        }

        function updateParticipants(uint256 tierId) internal {
            if(Users[msg.sender].tierId != tierLevel(tierId)) {
                tierParticipants[tierLevel(tierId)][Users[msg.sender].poolLevel] -= 1;
                tierParticipants[Users[msg.sender].tierId][Users[msg.sender].poolLevel] += 1;
            }
        }

        function withdraw(Sign calldata sign) external {
            require(!usedNonce[sign.nonce], "Nonce : Invalid Nonce");
            usedNonce[sign.nonce] = true;
            verifySign(msg.sender, Users[msg.sender].unstakeAmount, uint256(tierLevel(Users[msg.sender].tierId)), Users[msg.sender].poolLevel, sign);
            require(Users[msg.sender].isUnstakeInitiated,"you should initiate unstake first");
            require(block.timestamp >= Users[msg.sender].unstakeLimit,"cant withdraw before unstake listed days");
            uint _unstakeAmount = Users[msg.sender].unstakeAmount;
            uint _rewardAmount = Users[msg.sender].rewards;
            uint amount = _unstakeAmount + _rewardAmount;
            stakingToken.transfer(msg.sender, amount);
            Users[msg.sender].isUnstakeInitiated = false;
            Users[msg.sender].stakeAmount = 0;
            Users[msg.sender].unstakeLimit = 0;
            Users[msg.sender].unstakeAmount -= _unstakeAmount;
            Users[msg.sender].withdrawStakedAmount += _unstakeAmount;
            Users[msg.sender].withdrawRewardAmount += _rewardAmount;
            Users[msg.sender].rewards = 0;
            emit Withdraw(msg.sender, _unstakeAmount);
        }

        function emergencyWithdraw(Sign calldata sign) external {
            require(!usedNonce[sign.nonce], "Nonce : Invalid Nonce");
            usedNonce[sign.nonce] = true;           
            verifySign(msg.sender, Users[msg.sender].stakeAmount, uint256(tierLevel(Users[msg.sender].tierId)), Users[msg.sender].poolLevel, sign);
            require(Users[msg.sender].isStaker,"Withdraw: account must be stake some amount");
            uint amount = Users[msg.sender].stakeAmount;
            if(Users[msg.sender].poolLevel > 1) {
                amount = amount * fee / 100;
            }
            Users[msg.sender].isStaker = false;
            Users[msg.sender].stakeAmount = 0;
            Users[msg.sender].rewards = 0;
            Users[msg.sender].poolLevel = 0;
            tierParticipants[tierLevel(Users[msg.sender].tierId)][Users[msg.sender].poolLevel] -= 1;
            Users[msg.sender].tierId = tierLevel.Null;
            Users[msg.sender].withdrawStakedAmount += amount;
            stakingToken.transfer(msg.sender,amount);
            delete Users[msg.sender];
            emit Withdraw(msg.sender, amount);
        }

        function getDetails(address sender) external view returns(User memory) {
            return Users[sender];
        }

        function getStakedAmount(address sender) external override view returns(uint){
            return Users[sender].stakeAmount;
        }
             

        function getRewards(address account) external view returns(uint256) {
            if(Users[account].isStaker) {
                uint256 stakeAmount = Users[account].stakeAmount;
                uint256 timeDiff;
                require(block.timestamp >= Users[account].intialStakingTime, "Time exceeds");
                unchecked {
                    timeDiff = block.timestamp - Users[account].intialStakingTime;
                }
                uint256 rewardRate = pool[Users[account].poolLevel].poolRewardPercent;
                uint256 rewardAmount = ((stakeAmount * rewardRate ) * timeDiff / 365 days) / 100 ;
                return rewardAmount;
            }
            else return 0;
        }

        function getTotalParticipants() external override view returns(uint256){
            uint256 total;
            for(uint i = 1; i <= 6; i++){
                for(uint j = 1; j <= 3; j++) {
                    total += tierParticipants[tierLevel(i)][j];
                }
            }
            return total;
        }
        
        function getParticipantsByTierId(uint256 tierId, uint256 poolLevel) external override view returns(uint256){
            return tierParticipants[tierLevel(tierId)][poolLevel];
        }

        function isAllocationEligible(uint participationEndTime) external override view returns(bool){
            if(Users[msg.sender].intialStakingTime <= participationEndTime){
                return true;
            }
            return false;
        }

        function getTierIdFromUser(address account) external override view returns(uint tierId, uint poolLevel){
            return (uint(Users[account].tierId), Users[account].poolLevel);
        }

        function addToWhiteList(address account) external onlyOwner returns(bool) {
            require(account != address(0), "WhiteList: addrss shouldn't be zero");
            require(!isWhitelist[account],"WhileList: account already whiteListed");
            whiteListes.push(account);
            isWhitelist[account] = true;
            whitelistCount += 1; 
            return true;
        }
        
        function removeFromWhiteList(address account) external onlyOwner returns(bool) {
            require(account != address(0), "WhiteList: addrss shouldn't be zero");
            require(isWhitelist[account],"WhileList: account already removed from whiteList");
            isWhitelist[account] = false;
            whitelistCount -= 1; 
            return true;
        }

        function getWhiteList() external view returns(address[] memory) {
            address[] memory accounts = new address[] (whitelistCount);
            for(uint256 i = 0; i < whiteListes.length ; i++) {
            if(isWhitelist[whiteListes[i]]) {
                accounts[i] = whiteListes[i];
            }
        }
        return ( accounts);
        }

        function isStaker(address user) external override view returns(bool){
            return Users[user].isStaker;
        }

        function updateReward() internal returns(bool) {
            uint256 stakeAmount = Users[msg.sender].stakeAmount;
            uint256 timeDiff;
            require(block.timestamp >= Users[msg.sender].intialStakingTime, "Time exceeds");
            unchecked {
                timeDiff = block.timestamp - Users[msg.sender].intialStakingTime;
            }
            uint256 rewardRate = pool[Users[msg.sender].poolLevel].poolRewardPercent;
            Users[msg.sender].rewards = ((stakeAmount * rewardRate) * timeDiff / 365 days) / 100;
            return true;
        }

    }