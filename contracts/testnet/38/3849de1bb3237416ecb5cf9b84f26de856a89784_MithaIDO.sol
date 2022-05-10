/**
 *Submitted for verification at BscScan.com on 2022-05-10
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
        function isAllocationEligible(uint256 participationEndTime) external view returns(bool);
        function getTierIdFromUser(address sender) external view returns(uint256, uint256);

    }

    contract MithaIDO is IStakeable {

        IERC20Metadata public stakingToken;
        address public owner; 
        address public signer;
        uint256 public totalStaked;
        uint8 decimals;

        event ProjectInitiated(address indexed token);

        enum tierLevel {Null,BRONZE,SILVER,GOLD,PLATINUM }
        
        mapping(tierLevel => mapping(uint => uint)) tierParticipants;


        struct User {
            tierLevel tierId;
            uint256 poolLevel;
            uint256 stakeAmount;
            uint256 rewards;
            uint256 intialStakingTime;
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

        mapping (address => User) internal Users;
        mapping (uint256 => uint256) internal poolLimits;
        mapping (uint256 => mapping(uint256 => uint256)) internal poolRewardAmounts;
        mapping (uint256 => bool) internal usedNonce;

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

            poolLimits[1] = 15 days;
            poolLimits[2] = 30 days;
            poolLimits[3] = 60 days;
            poolLimits[4] = 180 days;

            poolRewardAmounts[1][1] = 10000 * 10 ** decimals;
            poolRewardAmounts[1][2] = 20000 * 10 ** decimals;
            poolRewardAmounts[1][3] = 40000 * 10 ** decimals;
            poolRewardAmounts[1][4] = 80000 * 10 ** decimals;

            poolRewardAmounts[2][1] = 20000 * 10 ** decimals;
            poolRewardAmounts[2][2] = 30000 * 10 ** decimals;
            poolRewardAmounts[2][3] = 60000 * 10 ** decimals;
            poolRewardAmounts[2][4] = 100000 * 10 ** decimals;

            poolRewardAmounts[3][1] = 40000 * 10 ** decimals;
            poolRewardAmounts[3][2] = 60000 * 10 ** decimals;
            poolRewardAmounts[3][3] = 80000 * 10 ** decimals;
            poolRewardAmounts[3][4] = 120000 * 10 ** decimals;

            poolRewardAmounts[4][1] = 80000 * 10 ** decimals;
            poolRewardAmounts[4][1] = 120000 * 10 ** decimals;
            poolRewardAmounts[4][1] = 160000 * 10 ** decimals;
            poolRewardAmounts[4][1] = 240000 * 10 ** decimals;

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

        function getTier(uint amount) internal view returns(uint8){

            if(amount >= 250 * 10 ** decimals  && amount < 1000 * 10 ** decimals){
                return 1;
            }
            else if(amount >= 1000 * 10 ** decimals && amount < 3000 * 10 ** decimals){
                return 2;
            }
            else if(amount >= 3000 * 10 ** decimals && amount < 10000 * 10 ** decimals){
                return 3;
            }
            else if(amount >= 10000 * 10 ** decimals ) {
                return 4;
            }
            else {
                return 0;
            }
        }

        function stake(uint256 amount, uint256 _stakePool, Sign memory sign) external {
            require(_stakePool > 0 && _stakePool <= 4, "Pool value must me greater than 0/less than 3");
            require(!usedNonce[sign.nonce], "Nonce : Invalid Nonce");
            usedNonce[sign.nonce] = true;
            require(amount >= 250 * 10 ** decimals, "amount must be greater then or equal to minimum value");
            uint256 tier = getTier(amount);
            require(!Users[msg.sender].isStaker,"staking already enabled");
            verifySign(msg.sender, amount, tier, _stakePool, sign);
            Users[msg.sender].tierId = tierLevel(tier);
            Users[msg.sender].poolLevel = _stakePool;
            Users[msg.sender].isStaker = true;
            Users[msg.sender].stakeAmount = amount;
            Users[msg.sender].intialStakingTime = block.timestamp;
            tierParticipants[tierLevel(Users[msg.sender].tierId)][_stakePool] += 1;
            _stake(amount);
        }
        
        function _stake(uint256 amount) internal {
            totalStaked += amount;
            stakingToken.transferFrom(msg.sender, address(this), amount);
            emit Stake(msg.sender,amount);
        }

        function unStake(uint256 amount, Sign memory sign) external {
            verifySign(msg.sender, amount, uint(Users[msg.sender].tierId), Users[msg.sender].poolLevel, sign);

            require(Users[msg.sender].stakeAmount >= amount, "amount must be less than stake amount");
            require(Users[msg.sender].stakeAmount - amount >= 250 * 10 ** decimals, "amount must greater than minAmount");
            Users[msg.sender].rewards += this.getReward(msg.sender);
            require(!Users[msg.sender].isUnstakeInitiated,"you have already a unstake initiated");

            require(block.timestamp >= Users[msg.sender].intialStakingTime + poolLimits[Users[msg.sender].poolLevel], "staking timeLimit is not reached");
        
            Users[msg.sender].unstakeAmount += amount;
            Users[msg.sender].stakeAmount -= amount;
            uint256 currentTier = uint256(Users[msg.sender].tierId);
            Users[msg.sender].tierId = tierLevel(getTier(Users[msg.sender].stakeAmount));
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
            Users[msg.sender].unstakeLimit = 0;
            Users[msg.sender].unstakeAmount -= _unstakeAmount;
            Users[msg.sender].withdrawStakedAmount += _unstakeAmount;
            Users[msg.sender].withdrawRewardAmount += _rewardAmount;
            Users[msg.sender].rewards = 0;
            emit Withdraw(msg.sender, _unstakeAmount);
        }

        function emergencyWithdraw(Sign calldata sign) external {
            require(Users[msg.sender].isStaker,"Withdraw: account must be stake some amount");
            require(!usedNonce[sign.nonce], "Nonce : Invalid Nonce");
            usedNonce[sign.nonce] = true;           
            verifySign(msg.sender, Users[msg.sender].stakeAmount, uint256(tierLevel(Users[msg.sender].tierId)), Users[msg.sender].poolLevel, sign);
            uint amount = Users[msg.sender].stakeAmount;
            tierParticipants[tierLevel(Users[msg.sender].tierId)][Users[msg.sender].poolLevel] -= 1;
            stakingToken.transfer(msg.sender,amount);
            Users[msg.sender].withdrawStakedAmount += amount;
            Users[msg.sender].isStaker = false;
            Users[msg.sender].stakeAmount = 0;
            emit Withdraw(msg.sender, amount);
        }

        function getDetails(address sender) external view returns(User memory) {
            return Users[sender];
        }

        function getStakedAmount(address sender) external override view returns(uint){
            return Users[sender].stakeAmount;
        }

        function getReward(address account) external view returns(uint256) {
            uint256 totalParticipants;
            uint256 rewardAmount;
            if(Users[account].isStaker) {
                totalParticipants = this.getParticipantsByTierId(uint256(Users[account].tierId), Users[account].poolLevel);   
                rewardAmount = poolRewardAmounts[uint256(Users[account].tierId)][Users[account].poolLevel] /totalParticipants;
                return rewardAmount;
            }
            else return 0;
        } 

        function getTotalParticipants() external override view returns(uint256){
            uint256 total;
            for(uint i = 1; i <= 4; i++){
                for(uint j = 1; j <= 4; j++) {
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

        function getTierIdFromUser(address account) external override view returns(uint tierId, uint poolLevel) {
            return (uint(Users[account].tierId), Users[account].poolLevel);
        }

        function isStaker(address user) external override view returns(bool){
            return Users[user].isStaker;
        }

    }