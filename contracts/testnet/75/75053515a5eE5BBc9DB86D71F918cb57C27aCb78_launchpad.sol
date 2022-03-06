// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;
import "./Fixed.sol";
import "./ownable.sol";
import "./IERC20.sol";
import "./idoToken.sol";


contract launchpad is Ownable {
    struct UserStake {
        address user;
        uint256 amount;
        uint256 stakeTime;
        uint256 lockedfor;
        bool unstakecomp;
        uint256 lastClaimed;
    }
    
    UserStake[] userStake;  
    address[] public transferBackIDOAddress;
    uint256 public lockperiod = 3 minutes;
    IERC20 public stakedToken;
    IERC20 public rewardToken;
    IERC20 public idoToken;
    uint256 public totalStaked;
    uint256 public aprPercent;
    uint256 public minStake = 0;
    uint256 public maxStake = 100000000000 * 1e18 * 1e18;
    uint256 public idoMulti = 1;
    uint256 public tier1 = 200000 * 1e18;
    uint256 public tier2 = 500000 * 1e18;
    uint256 public tier3 = 1000000 * 1e18;
    uint256 public tierPercent1 = 12500000000000000000;
    uint256 public tierPercent2 = 17500000000000000000;
    uint256 public tierPercent3 = 22500000000000000000;
    uint256 per;
    uint256 public contractEnd;

    // Fees and Penalty
    uint256 public stakeFeePercent = 0;
    uint256 public unStakeFeePercent = 0;
    uint256 public collectedFees;
    uint256 public collectedPenalty;
    uint256 public penaltyPercent = 2500000000000000000;


    
    mapping(address => uint) public Userstaked;
    mapping(address => uint) public idoBalance;
    mapping(address => uint) public idoTransfer;
    mapping(address => uint) public tierLevel;
    mapping(address => uint) public tierPercent;
    mapping(address => uint) public idoTransferTemp;
    mapping(address => uint) public pendingRewards;
    
    constructor(IERC20 _rewardToken, IERC20 _stakedToken, IERC20 _idoToken) {
        rewardToken = _rewardToken;
        stakedToken = _stakedToken;
        idoToken = _idoToken;
    }


    function stake(uint256 _amount) external {
        if (contractEnd != 0) {
            require(contractEnd > block.timestamp, "Staking has been Stop" );
        }
        require(minStake < _amount && maxStake >= _amount, "Could not stake this amount");
        if (stakeFeePercent > 0) {
            uint256 fee = _amount * stakeFeePercent / 100000000000000000000;
            _amount = _amount - fee;
            collectedFees = collectedFees + fee;
        }
        userStake.push(UserStake(msg.sender, _amount,uint256(block.timestamp),lockperiod, false, uint256(block.timestamp)));
        stakedToken.transferFrom(msg.sender, address(this), _amount);
        Userstaked[msg.sender] = Userstaked[msg.sender] + _amount;
        idoBalance[msg.sender] = idoBalance[msg.sender] + (_amount * idoMulti);
        IDO(address(idoToken)).mint(address(this), (_amount * idoMulti));
        totalStaked = totalStaked + _amount;
    }

    function unStake(uint256 _amount) external {
        require(checkUserValid(msg.sender) != 0, "Not a Valid User");
        require(_amount > 0, "Can't Unstake 0");
        require(idoBalance[msg.sender] >= (_amount * idoMulti), "Unstake failed! User dont have SUFFICIENT IDO Token");
        require(checkUserValid(msg.sender) != 0, "Not a Valid User");
        uint256 tempwithdraw = 0;
        uint256 checkwithdraw = 0;
        address _user = msg.sender;
        pendingClaim(_user);
        
        for(uint256 i = 0; i < userStake.length; i++) {
            if (checkwithdraw < _amount) {
                if (userStake[i].user == _user && userStake[i].unstakecomp == false) {          
                    if (userStake[i].stakeTime + userStake[i].lockedfor <= block.timestamp) {           // Normal Unstake without Penalty
                       if(userStake[i].amount >= _amount) {
                           tempwithdraw = tempwithdraw + _amount;
                           userStake[i].amount = userStake[i].amount - _amount;
                           idoBalance[msg.sender] = idoBalance[msg.sender] - (_amount * idoMulti); 
                           IDO(address(idoToken)).burn(address(this), (_amount * idoMulti));
                           checkwithdraw = tempwithdraw;
                           if (userStake[i].amount == 0) {
                               userStake[i].unstakecomp = true;
                           }
                        }  
                    } else {                                                            // This part of code get executed when user unstake before unlock
                        if(userStake[i].amount >= _amount) {
                            // For the user with penalty for withdrwaing before unlock
                            // amount 1000000000000000000000 * 2500000000000000000 / 100
                            // 1000 * 2.5 / 100
                            uint256 penalty = _amount * penaltyPercent / 100000000000000000000;
                            collectedPenalty = collectedPenalty + penalty;
                            uint256 tempamout = _amount - penalty;
                            tempwithdraw = tempwithdraw + tempamout;
                            userStake[i].amount = userStake[i].amount - _amount;
                            idoBalance[msg.sender]       = idoBalance[msg.sender] - (_amount * idoMulti);
                            IDO(address(idoToken)).burn(address(this), (_amount * idoMulti));
                            if (userStake[i].amount == 0) {
                                userStake[i].unstakecomp = true;
                            }
                            checkwithdraw = checkwithdraw + _amount;
                        }
                    }
                }
            }
        }
        require(tempwithdraw > 0, "Nothing to unstake");
        if (unStakeFeePercent > 0) {
            uint256 fee = tempwithdraw * unStakeFeePercent / 100000000000000000000;
            tempwithdraw = tempwithdraw - fee;
            collectedFees = collectedFees + fee;
        }
        stakedToken.transfer(msg.sender, tempwithdraw);
        Userstaked[msg.sender] = Userstaked[msg.sender] - _amount;
        totalStaked = totalStaked - _amount;
    }

    function pendingClaim(address _user) internal {
        uint256 userStakedIn = 0;
        uint256 claimReward = 0;
        uint256 userStakedTime = 0;
        userStakedIn = getStakeValue(msg.sender);  // We can use direct the userstaked mapping also
        userStakedTime = getStakeTime(msg.sender);
        uint256 currentTimeTemp = block.timestamp;
        if (contractEnd > block.timestamp) {
            currentTimeTemp = 0;
            currentTimeTemp = contractEnd;
        }
        uint temp = currentTimeTemp - userStakedTime; 
        claimReward = getRewardValue(userStakedIn) * temp;
        pendingRewards[msg.sender] = claimReward + pendingRewards[msg.sender];
        updateClaimed(msg.sender);
    }

    function getUnstake(address _user) public view returns (uint256) {
        uint256 userStakeable = 0;
        for(uint256 i = 0; i < userStake.length; i++) {
            if (userStake[i].user == _user && userStake[i].unstakecomp == false) {
                if (userStake[i].stakeTime + userStake[i].lockedfor <= block.timestamp) {
                    userStakeable = userStakeable + userStake[i].amount;
                }
            }
        }
        return userStakeable;
    }

    function getStakeValue(address _user) internal returns (uint256) {
        uint256 userClaimable = 0;
        for(uint256 i = 0; i < userStake.length; i++) {
            if (userStake[i].user == _user && userStake[i].unstakecomp == false) {
                userClaimable = userClaimable + userStake[i].amount;
            }
        }
        return userClaimable;
    }
    
    function getStakeTime(address _user) internal returns (uint256) {
        uint256 userTime = 0;
        for(uint256 i = 0; i < userStake.length; i++) {
                if (userStake[i].user == _user && userStake[i].unstakecomp == false) {
                    userTime = userStake[i].lastClaimed;
                    if (userTime == 0) {
                        i = userStake.length + 1;
                    }
                }
        }
        return userTime;
    }

    function checkUserValid(address _user) internal returns (uint256) {
        uint256 count = 0;
            for(uint256 i = 0; i < userStake.length; i++) {
                if (userStake[i].user == _user && userStake[i].unstakecomp == false) {
                    count = count + 1;
                }
            }
        return count;
    }

    function updateClaimed(address _user) internal {
        for(uint256 i = 0; i < userStake.length; i++) {
            if (userStake[i].user == _user && userStake[i].unstakecomp == false) {
                 userStake[i].lastClaimed = uint256(block.timestamp);
            }
        }
    }

    function getClaim(address _user) public view returns(uint) {
        uint256 userStakedIn = 0;
        uint256 claimReward = 0;
        uint256 userStakedTime = 0;
        uint256 userClaimable = 0;
        for(uint256 i = 0; i < userStake.length; i++) {
            if (userStake[i].user == _user && userStake[i].unstakecomp == false) {
                userClaimable = userClaimable + userStake[i].amount;
            }
        }
        userStakedIn = userClaimable;  // We can use direct the userstaked mapping also
        uint256 userTime = 0;
        for(uint256 i = 0; i < userStake.length; i++) {
                if (userStake[i].user == _user && userStake[i].unstakecomp == false) {
                    userTime = userStake[i].lastClaimed;
                    if (userTime == 0) {
                        i = userStake.length + 1;
                    }
                }
        }
        userStakedTime = userTime;
        // userStakedIn = getRewardValue(Userstaked[msg.sender]);
        uint256 currentTimeTemp = block.timestamp;
        if (contractEnd > block.timestamp) {
            currentTimeTemp = 0;
            currentTimeTemp = contractEnd;
        }
        uint temp = currentTimeTemp - userStakedTime; 
        // require(userStakedIn != 0, "No Rewards");
        uint256 reward = 0; 
        userStakedIn = userStakedIn / 1e18;
        uint _feePercent = per * 1e18;
        reward = userStakedIn * ((_feePercent / 31557600) / 100);
        // return reward;
        claimReward = reward * temp;
        claimReward = claimReward + pendingRewards[_user];
        return claimReward;
    }

    function claim() external {
        uint256 userStakedIn = 0;
        uint256 claimReward = 0;
        uint256 rewardInContract = 0;
        uint256 userStakedTime = 0;
        userStakedIn = getStakeValue(msg.sender);  // We can use direct the userstaked mapping also
        userStakedTime = getStakeTime(msg.sender);
        // userStakedIn = getRewardValue(Userstaked[msg.sender]);
        uint256 currentTimeTemp = block.timestamp;
        if (contractEnd > block.timestamp) {
            currentTimeTemp = 0;
            currentTimeTemp = contractEnd;
        }
        uint temp = currentTimeTemp - userStakedTime;
        claimReward = getRewardValue(userStakedIn) * temp;
        claimReward = claimReward + pendingRewards[msg.sender];
        require(claimReward != 0, "No Rewards to Claim");
        uint256 rewardTokenBalance = rewardToken.balanceOf(address(this));
        if (rewardToken == stakedToken){
            rewardInContract = rewardTokenBalance - totalStaked;
        }
        require(rewardInContract >= claimReward, "INSUFFICIENT Token to Transfer");
        require(rewardToken.transfer(msg.sender, claimReward), "Transfer Failed");
        updateClaimed(msg.sender);
        pendingRewards[msg.sender] = 0;


    }

    function getRewardValue(uint _amount) internal returns(uint256) {
        // require(_amount != 0, "No Rewards");
        uint256 reward = 0; 
        _amount = _amount / 1e18;
        uint _feePercent = per * 1e18;
        reward = _amount * ((_feePercent / 31557600) / 100);
        return reward;
    }

    function transferIDOToken(uint256 _amount) external {
        address _user = msg.sender;
        require(checkUserValid(_user) != 0, "Not a Valid User");
        require(idoBalance[_user] >= _amount, "Transfering more than you have");
        require(idoToken.transfer(address(this), _amount), "Transfer failed");
        idoTransfer[_user] = idoTransfer[_user] + _amount;
        idoBalance[_user] = idoBalance[_user] - (_amount);
        updateTier(_user);
        
    }

    function updateIDOInfoLaunch(address updateContract, address _user) external {
        idoTransfer[_user] = idoTransfer[_user] + FixedStaking(updateContract).getIDOTransferred(_user);
        updateTier(_user);
    }

    function transferBackIDOToken(uint256 _pool, uint256 _amount) external {
        // uint256 backIDO = transferBackIDOAddress[_pool].getIDOTransfereds(msg.sender);  // for fetching token from staking contract
        address _user = msg.sender;
        require(idoTransfer[_user]>= _amount, "No sufficient tokens");
        if (transferBackIDOAddress[_pool] == address(this)) {
            require(idoToken.transfer(transferBackIDOAddress[_pool], _amount), "Transfer Failed");
            idoTransfer[_user] = idoTransfer[_user] - _amount;
            idoBalance[_user] = idoBalance[_user] + (_amount);
            updateTier(_user);
        } else {
            require(idoToken.transfer(transferBackIDOAddress[_pool], _amount), "Transfer Failed");
            idoTransfer[_user] = idoTransfer[_user] - _amount;
            idoTransferTemp[_user] = _amount;
            FixedStaking(transferBackIDOAddress[_pool]).updateIDOInfoStaking(_user);
            idoTransferTemp[_user] = 0;

        }
    }

    function getIDOTransferredTemp(address _user) public view returns (uint256) {
        return idoTransferTemp[_user];
    }
    function getTier(address _user) public view returns (uint256) {
        uint256 count = 0;
        if (idoTransfer[_user] >= tier1) {
            count = 1;
        }
        if (idoTransfer[_user] >= tier2) {
            count = 2;
        }
        if (idoTransfer[_user] >= tier3) {
            count = 3;
        }
        return count;
    }

    function updateTier(address _user) public {
        if(idoTransfer[_user] >= tier1) {
            if (idoTransfer[_user] >= tier1) {
                tierLevel[_user] = tier1;
                tierPercent[_user] = tierPercent1;
            } 
            if (idoTransfer[_user] >= tier2) {
                tierLevel[_user] = tier2;
                tierPercent[_user] = tierPercent2;
            }
            if (idoTransfer[_user] >= tier3) {
                tierLevel[_user] = tier3;
                tierPercent[_user] = tierPercent3;
            }
        }
    }
    

    function setAPR(uint256 _per) external onlyOwner {
        require(_per != 0, "APR can't set as ZERO");
        per = _per;
        // aprPercent = _per * 12;
    }

    function setIDORatio(uint256 _idoratio) external onlyOwner {
        require(_idoratio != 0, "IDORatio can't set as ZERO");
        idoMulti = _idoratio;
    }

    function changeRewardToken(IERC20 _rewardToken) external onlyOwner {
        rewardToken = _rewardToken;
    } 

    function updateMax(uint _max) external onlyOwner {
        maxStake = _max; 
    }

    function updateMin(uint _min) external onlyOwner {
        minStake = _min; 
    }
    function updateTierValue1(uint _tier1) external onlyOwner {
        tier1 = _tier1; 
    }
    function updateTierValue2(uint _tier2) external onlyOwner {
        tier2 = _tier2; 
    }
    function updateTierValue3(uint _tier3) external onlyOwner {
        tier3 = _tier3; 
    }
    function updateTierPercent1(uint _tierPercent1) external onlyOwner {
        tierPercent1 = _tierPercent1; 
    }
    function updateTierPercent2(uint _tierPercent2) external onlyOwner {
        tierPercent2 = _tierPercent2; 
    }
    function updateTierPercent3(uint _tierPercent3) external onlyOwner {
        tierPercent3 = _tierPercent3; 
    }

    function updateTransferBackAddress(uint256 _poolId, address _pooladdress) external onlyOwner {
        transferBackIDOAddress[_poolId] = _pooladdress;
    }

    function addTransferBackAddress(address _pooladdress) external onlyOwner {
        transferBackIDOAddress.push(_pooladdress);
    }

    function updatePenaltyPercent(uint _penaltyPercent) external onlyOwner {
        penaltyPercent = _penaltyPercent; 
    }

    function setStakeFee(uint256 fee) external onlyOwner {
        stakeFeePercent = fee;
    }

    function setUnstakeFee(uint256 fee) external onlyOwner {
        unStakeFeePercent = fee;
    }

    function withdrawFees() external onlyOwner {
        stakedToken.transfer(msg.sender, collectedFees);
        collectedFees = 0;
    }

    function withdrawPenalty() external onlyOwner {
        stakedToken.transfer(msg.sender, collectedPenalty);
        collectedFees = 0;
    }
    function setContractEnd(uint256 _time) external onlyOwner {
        contractEnd = _time;
    }

    function updateIDOTokenAddress(IERC20 _idoaddress) external onlyOwner {
        idoToken = _idoaddress;
    }


}