/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

// SPDX-License-Identifier:UNLICENSED
pragma solidity 0.8.13;

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

interface IStakeable{
    function getStakedAmount(address user) external view returns(uint);
    function isStaker(address user) external view returns(bool);
    function getTotalParticipants() external view returns(uint256);
    function getParticipantsByTierId(uint256 tierId, uint256 poolLevel) external view returns(uint256);
    function isAllocationEligible(uint256 participationEndTime) external view returns(bool);
    function getTierIdFromUser(address sender) external view returns(uint, uint);
}

contract claimableContract {
    //staking contract
    IStakeable public stakingContract;

    // reward token contract
    IERC20Metadata public rewardToken;

    uint256 public totalSupply;
    uint256 public totalSoldToken;
    uint256 public tokenBalance;
    uint256 public listingTime;
    uint256 public totalParticipants;
    uint256 public participationEndTime;
    uint256 public roundOneStartTime;
    uint256 public roundOneEndTime;
    uint256 public fcfsStartTime;
    uint256 public vestingTime;
    uint256 public claimSlots;
    bool public roundOneStatus;
    bool public isAllocationEnd;
    bool public isFCFSAllocationEnd;
    bool public isCompleted;
    address public admin;
    bool public claimStatus;


    struct poolDetail{
        uint256 tierLevel;
        uint256 poolLevel;
        uint256 poolWeight;
        uint256 allocatedAmount;
        uint256 participants;
    }

    mapping(uint256 => mapping( uint256 => poolDetail)) public tierDetails;
    mapping(uint256 => mapping (uint256 => uint256)) internal tierParticipantCount;


    event TokenBuyed(address user,uint256 tierId,uint256 amount);
    event TokenWithdrawn(address user,uint256 tierId, uint256 pool, uint256 amount);
    event participationCompleted(uint256 endTime);
    event ClaimStatus(bool status);
    event Participate(address user,uint256 tierid);
    event AllocationRoundOneEnds(uint256 allocationEndTime);
    event AllocationRoundTwoEnds(uint256 tokenBalance);

    struct userDetail{
        uint256 buyedToken;
        uint256 remainingTokenToBuy;
        uint256 tokenToSend;
        uint256 nextVestingTime;
        bool frTokenBuyed;
    }

    mapping(address => bool) internal participants;

    address[] participant;
   
    mapping(address => userDetail) userDetails;

    constructor (IStakeable _stakingContract, IERC20Metadata _rewardToken, uint256 _totalsupply, uint256[] memory tierWeights, uint256 _listingTime, uint256 _claimSlots, uint256 _vestingTime, uint256 _roundOneStartTime,uint256 _roundOneEndTime,uint256 _fcfsStartTime) {
        admin = msg.sender;        
        stakingContract = _stakingContract;
        rewardToken = _rewardToken;
        totalSupply = _totalsupply * 10 ** rewardToken.decimals();
        uint256 k;
        for(uint256 i = 1; i <= 6; i++){
            for(uint256 j = 1; j <= 3; j++) {
                tierDetails[i][j].tierLevel = i;
                tierDetails[i][j].poolLevel = j;
                tierDetails[i][j].poolWeight = tierWeights[k];
                k++;
            }
        }

        listingTime = _listingTime * 3600;
        roundOneStartTime = _roundOneStartTime * 3600;
        roundOneEndTime = _roundOneEndTime * 3600;
        fcfsStartTime = _fcfsStartTime * 3600;
        claimSlots = _claimSlots;
        vestingTime = _vestingTime * 1 days;
    }

    modifier onlyOwner {
        require(msg.sender == admin, "Ownable: caller is not the owner");
        _;
    }

    function setClaimStatus(bool status) external onlyOwner returns(bool) {
        claimStatus = status;
        emit ClaimStatus(status);
        return true;
    }

    function getTierAllocatedAmount() external view returns(poolDetail[] memory) {
        poolDetail[] memory allocationDetails = new poolDetail[](18);
        uint256 k;
        for(uint256 i = 1; i <= 6; i++){
            for(uint256 j = 1; j <= 3; j++) {
                allocationDetails[k].tierLevel = tierDetails[i][j].tierLevel;
                allocationDetails[k].poolLevel = tierDetails[i][j].poolLevel;
                allocationDetails[k].poolWeight = tierDetails[i][j].poolWeight;
                allocationDetails[k].allocatedAmount = tierDetails[i][j].allocatedAmount;
                allocationDetails[k].participants = tierDetails[i][j].participants;
                k++;
            }
        }
        return allocationDetails;
    }

    function allocation(address[] memory accounts) external onlyOwner {
        require(!isAllocationEnd, "allocation already initiated");
        totalParticipants = stakingContract.getTotalParticipants();
        require(totalParticipants != 0, "allocation can't happen if there is no participants");
        participant = accounts;

        for(uint8 i = 0; i < accounts.length; i++) {
            participants[accounts[i]] = true;
            (uint256 tierLevel, uint256 pool) = stakingContract.getTierIdFromUser(accounts[i]);
            tierParticipantCount[tierLevel][pool] += 1;

        }
        for(uint8 i = 1; i <= 6; i++){
            for(uint8 j = 1; j <= 3; j++) {
                tierDetails[i][j].participants = stakingContract.getParticipantsByTierId(i, j);
                if(tierDetails[i][j].participants == 0){
                    tierDetails[i][j].allocatedAmount = 0;
                }
                else{
                    tierDetails[i][j].allocatedAmount = (totalSupply *  tierDetails[i][j].poolWeight) / 100;
                    tierDetails[i][j].allocatedAmount = tierDetails[i][j].allocatedAmount / tierParticipantCount[i][j];
                }
            }
        }
        roundOneStartTime = block.timestamp + roundOneStartTime;
        roundOneEndTime = roundOneStartTime + roundOneEndTime;
        fcfsStartTime = roundOneEndTime + fcfsStartTime;
        roundOneStatus = true ;
        isAllocationEnd = true;
        participationEndTime = block.timestamp;
        emit AllocationRoundOneEnds(block.timestamp);
    }

    function allocationRoundTwo() external onlyOwner {   

        require(block.timestamp >= roundOneEndTime, "allocation can't happen until roundOne end");
        require(!isFCFSAllocationEnd, "allocation roundTwo already initiated");
        tokenBalance = totalSupply - totalSoldToken;
        isFCFSAllocationEnd = true;
        emit AllocationRoundTwoEnds(tokenBalance);

    }

    function getAllocation(address account) external view returns(uint) {
        require(stakingContract.isAllocationEligible(participationEndTime), "not eligible");
        (uint256 tierId, uint256 pool) = stakingContract.getTierIdFromUser(account);
        return tierDetails[tierId][pool].allocatedAmount;

    }

    function getUserDetails(address sender) external view returns(uint,uint) {

        return (userDetails[sender].buyedToken,userDetails[sender].tokenToSend);

    }

    function getNextVestingTime(address account) external view returns(uint) {
        return userDetails[account].nextVestingTime;
    }

    function buyToken(uint256 amount) external returns(bool) {
        require(stakingContract.isStaker(msg.sender), "you must stake first to buy tokens");
        require(participants[msg.sender], "User doesn't have access to buy tokens");
        require(!isCompleted, "Insufficient tokens");
        require(roundOneStatus && block.timestamp >= roundOneStartTime, "round one not yet started");

        (uint256 tierId, uint256 pool) = stakingContract.getTierIdFromUser(msg.sender);
        if(block.timestamp <= roundOneEndTime) {
            if(userDetails[msg.sender].buyedToken == 0 && !userDetails[msg.sender].frTokenBuyed){
                userDetails[msg.sender].remainingTokenToBuy = tierDetails[tierId][pool].allocatedAmount;
            }
            require(amount <= userDetails[msg.sender].remainingTokenToBuy, "amount should be lesser than allocated amount");
            userDetails[msg.sender].remainingTokenToBuy -= amount;
            totalSoldToken += amount;
            userDetails[msg.sender].buyedToken += amount;
            userDetails[msg.sender].tokenToSend += amount;
            if(userDetails[msg.sender].remainingTokenToBuy == 0) {
                userDetails[msg.sender].frTokenBuyed == true; 
            }
            emit TokenBuyed(msg.sender, tierId, amount);
            return true;
        } else {
            require(tokenBalance >= 0, "Insufficient Tokens");
            require(block.timestamp >= fcfsStartTime, "First come first serve still not start");
            require(amount <= tokenBalance, "amount should be lesser than allocated amount");
            totalSoldToken += amount;
            tokenBalance -= amount;
            if(tokenBalance == 0) {
                isCompleted = true;
            }
            userDetails[msg.sender].buyedToken += amount;
            userDetails[msg.sender].tokenToSend += amount;
            emit TokenBuyed(msg.sender, tierId, amount);            
            return true;
        }
    }

    function claimToken() external returns(bool) {
        require(claimStatus, "can't claim before enable cliam status");
        require(userDetails[msg.sender].tokenToSend > 0, "Insufficient amount to cliam");

        (uint256 tierId, uint256 pool) = stakingContract.getTierIdFromUser(msg.sender);

        require(block.timestamp >= userDetails[msg.sender].nextVestingTime, "can't cliam token until reaching vesting time");
        uint256 amountToBeSend = userDetails[msg.sender].buyedToken / claimSlots;
        rewardToken.transfer(msg.sender, amountToBeSend);
        userDetails[msg.sender].tokenToSend -= amountToBeSend;
        userDetails[msg.sender].nextVestingTime = block.timestamp + vestingTime;
        emit TokenWithdrawn(msg.sender, tierId, pool, amountToBeSend);
        return true;

    }
    
    function setTokenListingTime(uint256 time) external onlyOwner {
       listingTime = block.timestamp + (time * 3600);
    }

    function setroundOneStartTime(uint256 time) external onlyOwner {
       roundOneStartTime = block.timestamp + (time * 3600);
    }
    
    function setroundOneEndTime(uint256 time) external onlyOwner {
       roundOneEndTime = block.timestamp + (time * 3600);
    }
    
    function setFCFSStartTime(uint256 time) external onlyOwner {
       fcfsStartTime = block.timestamp + (time * 3600);
    }

    function setVestingTime(uint256 time) external onlyOwner {
        vestingTime = block.timestamp + (time * 1 days);
    }

}