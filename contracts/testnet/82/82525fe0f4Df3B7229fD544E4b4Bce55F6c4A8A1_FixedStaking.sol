// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;
import "./IERC20.sol";
import "./ownable.sol";
import "./launchpad.sol";
import "./idoToken.sol";

contract FixedStaking is Ownable {
    struct UserStake {
        address user;
        uint256 amount;
        uint64 stakeTime;
        uint64 lockedfor;
        bool unstakecomp;
        uint64 lastClaimed;
    }
    UserStake[] userStake;  // Can make this public to unpublic
    uint64 public lockperiod = 1 minutes;
    IERC20 public stakedToken;  // Address to add while deploying contract
    IERC20 public rewardToken;  // Address to add while deploying contract
    address public launchpadAddress; // Address will be updated by the owner of launchpad
    IERC20 public idoToken;          // Address to add while deploying contract
    uint256 public totalStaked;
    uint256 public aprPercent;  // Update by the owner
    uint256 public minStake = 0; // Update by the owner
    uint256 public maxStake = 100000000000 * 1e18 * 1e18; // Update by the owner
    uint256 public idoMulti = 1000000000000000000; // Update by the owner
    uint256 per;
    uint256 public contractEnd = 100000000000000 * 1e18 * 1e18; // Update by the owner
    uint256 public totalRewardTokens = 0;

    // Fees and Penalty
    uint256 public stakeFeePercent = 0;
    uint256 public unStakeFeePercent = 0;
    uint256 public collectedFees;
    uint256 public collectedPenalty;
    uint256 public penaltyPercent = 2500000000000000000;


    
    mapping(address => uint) public Userstaked;
    mapping(address => uint) public idoBalance;
    mapping(address => uint) public idoTransfer;
    mapping(address => uint) public pendingRewards;
    
    constructor(IERC20 _rewardToken, IERC20 _stakedToken, IERC20 _idoToken) {
        rewardToken = _rewardToken;
        stakedToken = _stakedToken;
        idoToken = _idoToken;
    }

    // Staking Fucntion for the user
    function stake(uint256 _amount) external {
        if (contractEnd != 0) {
            require(contractEnd > block.timestamp, "Staking has been Stop" );
        }
        require(minStake <= _amount && maxStake >= _amount, "Could not stake this amount");
        if (stakeFeePercent > 0) {
            uint256 fee = _amount * stakeFeePercent / 100000000000000000000;
            _amount = _amount - fee;
            collectedFees = collectedFees + fee;
        }
        userStake.push(UserStake(msg.sender, _amount,uint64(block.timestamp),lockperiod, false, uint64(block.timestamp)));
        stakedToken.transferFrom(msg.sender, address(this), _amount);
        Userstaked[msg.sender] = Userstaked[msg.sender] + _amount;
        idoBalance[msg.sender] = idoBalance[msg.sender] + (_amount * idoMulti / 1000000000000000000);
        IDO(address(idoToken)).mint(address(this), (_amount * idoMulti / 1000000000000000000));
        totalStaked = totalStaked + _amount;
    }

    // New Unstake function

    function unStake(uint _amount) external {
        require(checkUserValid(msg.sender) != 0, "Not a Valid User");
        require(_amount > 0, "Can't Unstake 0");
        require(idoBalance[msg.sender] >= (_amount * idoMulti / 1000000000000000000), "Unstake failed! User dont haveSUFFICIENT IDO Token");

        address _user = msg.sender;
        pendingClaim(_user);
        uint256 initialAmount = _amount;
        uint256 tempAmount = _amount;
        uint256 unstaked = 0;
        uint256[500] memory unstakeFrom;
        uint256 j = 0;
        uint256[500] memory unstakeFromPenalty;
        uint256 jp = 0;
        for(uint256 i=0;i<userStake.length;i++){
            if(tempAmount <= 0){
                break;
            }
            if(userStake[i].user == _user && userStake[i].unstakecomp == false){
                if(userStake[i].stakeTime + userStake[i].lockedfor <= block.timestamp){ // unstake without penalty
                    if(userStake[i].amount <= tempAmount){
                        tempAmount -= userStake[i].amount;
                        unstakeFrom[j] = i;
                        j++;
                        unstakeFrom[j] = userStake[i].amount;
                        j++;
                        unstaked += userStake[i].amount;
                    }else{
                        unstakeFrom[j] = i;
                        j++;
                        unstakeFrom[j] = tempAmount;
                        j++;
                        unstaked += tempAmount;
                        tempAmount = 0;
                    }

                }else{ // unstake with penalty
                    if(userStake[i].amount <= tempAmount){
                        tempAmount -= userStake[i].amount;
                        unstakeFromPenalty[jp] = i;
                        jp++;
                        unstakeFromPenalty[jp] = userStake[i].amount;
                        jp++;
                        unstaked += userStake[i].amount;
                    }else{
                        unstakeFromPenalty[jp] = i;
                        jp++;
                        unstakeFromPenalty[jp] = tempAmount;
                        jp++;
                        unstaked += tempAmount;
                        tempAmount = 0;
                    }
                }
            }
        }
        uint256 tempPenalty = 0;
        require(tempAmount == 0, "Not Enough token staked");
        for(uint256 i = 0;i<j;i++){
            uint256 ind = unstakeFrom[i];
            i++;
            userStake[ind].amount -= unstakeFrom[i];
            if (userStake[ind].amount == 0) {
                userStake[ind].unstakecomp = true;
            }
        }
        for(uint256 i = 0;i<jp;i++){
            uint256 ind = unstakeFromPenalty[i];
            i++;
            userStake[ind].amount -= unstakeFromPenalty[i];
            uint256 penalty = unstakeFromPenalty[i] * penaltyPercent / 100000000000000000000;
            collectedPenalty = collectedPenalty + penalty;
            tempPenalty += penalty;
            if (userStake[ind].amount == 0) {
                userStake[ind].unstakecomp = true;
            }
        }
        _amount -= tempPenalty;
        if (unStakeFeePercent > 0) {
            uint256 fee = _amount * unStakeFeePercent / 100000000000000000000;
            _amount = _amount - fee;
            collectedFees = collectedFees + fee;
            
        }
        idoBalance[msg.sender] = idoBalance[msg.sender] - (initialAmount * idoMulti / 1000000000000000000); 
        IDO(address(idoToken)).burn(address(this), (_amount * idoMulti / 1000000000000000000));
        stakedToken.transfer(msg.sender, _amount);
        Userstaked[msg.sender] = Userstaked[msg.sender] - initialAmount;
        totalStaked = totalStaked - initialAmount;
    }

    // Internal function to know how much pending rewards are there
    function pendingClaim(address _user) internal {
        uint256 userStakedIn = 0;
        uint256 claimReward = 0;
        uint64 userStakedTime = 0;
        userStakedIn = getStakeValue(msg.sender);  // We can use direct the userstaked mapping also
        userStakedTime = getStakeTime(msg.sender);
        uint256 currentTimeTemp = block.timestamp;
        if (contractEnd < block.timestamp) {
            currentTimeTemp = 0;
            currentTimeTemp = contractEnd;
        }
        uint temp = currentTimeTemp - userStakedTime; 
        claimReward = getRewardValue(userStakedIn) * temp;
        pendingRewards[msg.sender] = claimReward + pendingRewards[msg.sender];
        updateClaimed(msg.sender);
    }

    // For the user to know how much token can be unstake this is for the frontend
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
    // Internal function to the contract to know how much user has staked in
    function getStakeValue(address _user) internal returns (uint256) {
        uint256 userClaimable = 0;
        for(uint256 i = 0; i < userStake.length; i++) {
            if (userStake[i].user == _user && userStake[i].unstakecomp == false) {
                userClaimable = userClaimable + userStake[i].amount;
            }
        }
        return userClaimable;
    }
   // Internal function to the contract to know at what time user as started the stake
    function getStakeTime(address _user) internal returns (uint64) {
        uint64 userTime = 0;
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
    // Internal function to check valid user or no
    function checkUserValid(address _user) internal returns (uint256) {
        uint256 count = 0;
            for(uint256 i = 0; i < userStake.length; i++) {
                if (userStake[i].user == _user && userStake[i].unstakecomp == false) {
                    count = count + 1;
                }
            }
        return count;
    }
    // Internal function which update the time when user has claimed so it help to the next calculation time period
    function updateClaimed(address _user) internal {
        for(uint256 i = 0; i < userStake.length; i++) {
            if (userStake[i].user == _user && userStake[i].unstakecomp == false) {
                 userStake[i].lastClaimed = uint64(block.timestamp);
            }
        }
    }

    function depositeRewardToken(uint256 _amount) public onlyOwner{
        require(_amount > 0, "Can't deposite zero tokens");
        require(rewardToken.transferFrom(msg.sender,address(this),_amount), "Tranfer failed");
        totalRewardTokens += _amount;
    }

    function withdrawRewardToken(uint _amount) public onlyOwner {
        require(_amount < totalRewardTokens, "Cannot withraw more than the total Reward tokens");
        require(contractEnd < block.timestamp, "Contract is not ended yet!");
        require(rewardToken.transferFrom(address(this), msg.sender, _amount), "Failed to transfer");
        totalRewardTokens -= _amount;
    }

    // User function to know how much token user has earn and can withdraw
    function getClaim(address _user) public view returns(uint) {
        uint256 userStakedIn = 0;
        uint256 claimReward = 0;
        uint64 userStakedTime = 0;
        uint256 userClaimable = 0;
        for(uint256 i = 0; i < userStake.length; i++) {
            if (userStake[i].user == _user && userStake[i].unstakecomp == false) {
                userClaimable = userClaimable + userStake[i].amount;
            }
        }
        userStakedIn = userClaimable;  // We can use direct the userstaked mapping also
        uint64 userTime = 0;
        for(uint256 i = 0; i < userStake.length; i++) {
                if (userStake[i].user == _user && userStake[i].unstakecomp == false) {
                    userTime = userStake[i].lastClaimed;
                    if (userTime == 0) {
                        i = userStake.length + 1;
                    }
                }
        }
        userStakedTime = userTime;
        uint256 currentTimeTemp = block.timestamp;
        if (contractEnd < block.timestamp) {
            currentTimeTemp = 0;
            currentTimeTemp = contractEnd;
        }
        uint temp = currentTimeTemp - userStakedTime; 
        uint256 reward = 0; 
        userStakedIn = userStakedIn / 1e18;
        uint _feePercent = per * 1e18;
        reward = userStakedIn * ((_feePercent / 31557600) / 100);
        claimReward = reward * temp;
        claimReward = claimReward + pendingRewards[_user];
        return claimReward;
    }

    // For user to claim the reward and take it to his weallet
    function claim() external {
        uint256 userStakedIn = 0;
        uint256 claimReward = 0;
        uint256 rewardInContract = 0;
        uint64 userStakedTime = 0;
        userStakedIn = getStakeValue(msg.sender);  // We can use direct the userstaked mapping also
        userStakedTime = getStakeTime(msg.sender);
        uint256 currentTimeTemp = block.timestamp;
        if (contractEnd < block.timestamp) {
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
        require(rewardInContract >= claimReward, "INSUFFICIENT reward tokens in contract");
        require(rewardToken.transfer(msg.sender, claimReward), "Transfer Failed");
        updateClaimed(msg.sender);
        pendingRewards[msg.sender] = 0;

    }
    // Internal function to know the per second APR to calculate
    function getRewardValue(uint _amount) internal returns(uint256) {
        uint256 reward = 0; 
        _amount = _amount / 1e18;
        uint _feePercent = per * 1e18;
        reward = _amount * ((_feePercent / 31557600) / 100);
        return reward;
    } 

    // User function where IDO token gets transfer to Launchpad
    function transferIDOToken(uint256 _amount) external {
        address _user = msg.sender;
        require(checkUserValid(_user) != 0, "Not a Valid User");
        require(idoBalance[_user] >= _amount, "Transfering more than you have");
        require(idoToken.transfer(launchpadAddress, _amount), "Transfer failed");
        idoTransfer[_user] = idoTransfer[_user] + _amount;
        idoBalance[_user] = idoBalance[_user] - _amount;
        launchpad(launchpadAddress).updateIDOInfoLaunch(address(this), _user, _amount);
    }

    // Contract to contract updation
    function updateIDOInfoStaking(address _user) external {
        uint tempValueFun;
        tempValueFun = launchpad(launchpadAddress).getIDOTransferred(_user  );
        idoTransfer[_user] = idoTransfer[_user] - tempValueFun;
        idoBalance[_user] = idoBalance[_user] + tempValueFun;
    }

    // For user to know how much token has been transfered
    function getIDOTransferred(address _user) external view returns (uint256) {
        return idoTransfer[_user];
    }


    // ALl the Owner function Starts from here

    function setAPR(uint256 _per) external onlyOwner {
        require(_per != 0, "APR can't be set as ZERO");
        per = _per;
        aprPercent = _per;
    }

    function setIDORatio(uint256 _idoratio) external onlyOwner {
        require(_idoratio != 0, "IDORatio can't set as ZERO");
        idoMulti = _idoratio;
        // idoMulti = idoMulti / 1000000000000000000;
    }

    function changeRewardToken(IERC20 _rewardToken) external onlyOwner {
        rewardToken = _rewardToken;
    }

    function updateLaunchpad(address _launchpadAddress) external onlyOwner {
        launchpadAddress = _launchpadAddress;
    }

    function updateMax(uint _max) external onlyOwner {
        maxStake = _max; 
    }

    function updateMin(uint _min) external onlyOwner {
        minStake = _min; 
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