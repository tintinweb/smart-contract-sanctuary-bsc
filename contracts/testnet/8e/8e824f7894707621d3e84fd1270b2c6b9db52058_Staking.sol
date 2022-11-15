/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

//////////////////////////////////////////////////////////////////////////
//  Staking Contract for Kichee Tokens                                  //
//  Rewards will be calculated based on the staking time                //
//  Reward percentage is fixed                                          //
//  User can stake between minimum and maximum limit                    //
//  Multiple staking will per address is identified by the staing ID    //
//  Staking rewards and pools are managed in this smart contract only   //
//////////////////////////////////////////////////////////////////////////

contract Staking {
    //Variable for staking logic
    uint256 public stakeId = 0;
    uint256 public totalStakedAmount = 0;
    address[] public stakersAddresses;
    uint256 public rewardMultiplier;
    uint256 public perDayRewardPercent;
    uint256 public minimumTokensToStake;
    uint256 public maximumTokensToStake;
    address public owner;
    uint256 public lockingTime;
    uint256 public penaltyMultiplier;
    uint256 public APY;
    uint256 public PenaltyPercentage;

    IERC20 public stakingToken;
    
    constructor(address _owner, address _stakeTokenAddress) {
        owner = _owner;
        stakingToken = IERC20(_stakeTokenAddress);
    }

    //Mappings for staking logic
    mapping (uint256 => address) public addressByStakeId;
    mapping (uint256 => uint256) public amountByStakeId;
    mapping (uint256 => uint256) public timeByStakeId;
    mapping(address => uint) public balanceOf;
    mapping(uint256 => bool) public flagByStakeId;
    mapping(address => uint256) public currentTotalStakesByAddress;
    mapping(address=> uint256) public userWalletBalance;
    mapping(address => uint256) public totalUnstakedByAddress;
    mapping(address => uint256) public totalEarnedRewards;
    mapping(address => mapping(uint256 => uint256)) public allStakeIdByAddress;
    mapping(address => uint256) public numberOfStakesByAdd;

    //Admin functions 
    modifier ownerOnly(){
            require(msg.sender == owner,"Not the owner");
            _;
    }

    function setMinimum(uint256 _minimumTokensToStake) external ownerOnly returns(bool){
        minimumTokensToStake = _minimumTokensToStake;
        return true;
    }

    function setMax(uint256 _maximumTokensToStake) external ownerOnly returns(bool){
        maximumTokensToStake = _maximumTokensToStake;
        return true;
    }

    function setMultiplier(uint256 _rewardMultiplier) external ownerOnly returns(bool){
        rewardMultiplier = _rewardMultiplier;
        return true;
    }

    function withdrawTokensAdmin(uint256 _amount) external ownerOnly returns(bool){
        stakingToken.transferFrom(address(this), msg.sender, _amount);
        return true;
    }

    function setlockingTime(uint256 _lockingTime) external ownerOnly returns(bool){
        lockingTime = _lockingTime;
        return true;
    }

    function SetPenaltyMultiplier(uint256 _penaltyMultiplier) external ownerOnly returns(bool){
        penaltyMultiplier = _penaltyMultiplier;
        return true;
    }

    function setAPY(uint256 _APY) external ownerOnly returns(bool){
        APY = _APY;
        return true;
    }

    function setPenaltyPercentage(uint256 _PenaltyPercentage) external ownerOnly returns(bool){
        PenaltyPercentage = _PenaltyPercentage;
        return true;
    }

    //function to stake tokens 
    function stakeTokens(uint256 _numberOfTokens) external returns(bool){
        require(_numberOfTokens >= minimumTokensToStake, "Tokens should be more than minimum limit");
        require(currentTotalStakesByAddress[msg.sender] <= maximumTokensToStake, "Tokens should be less than maximum limit per address");
        stakingToken.transferFrom(msg.sender, address(this), _numberOfTokens);
        stakeId += 1;
        numberOfStakesByAdd[msg.sender] = numberOfStakesByAdd[msg.sender] + 1;
        allStakeIdByAddress[msg.sender][numberOfStakesByAdd[msg.sender]] = stakeId;
        addressByStakeId[stakeId] = msg.sender;
        amountByStakeId[stakeId] = _numberOfTokens;
        timeByStakeId[stakeId] = block.timestamp;
        balanceOf[msg.sender] += _numberOfTokens;
        currentTotalStakesByAddress[msg.sender] += _numberOfTokens;
        stakersAddresses.push(msg.sender);
        return true;
    }

    //withdraw staked tokens
    function unstakeTokens(uint256 _stakeId) external returns(bool){
        require(msg.sender ==  addressByStakeId[_stakeId], "Invalid user or stake Id");
        require(flagByStakeId[_stakeId] != true, "Tokens already withdrawn");
        require(block.timestamp > timeByStakeId[_stakeId] + lockingTime, "Wait for the token unlock time");
        uint256 reward = amountByStakeId[_stakeId] * rewardMultiplier * (block.timestamp - timeByStakeId[_stakeId])/3600;   //multipler will be divided by 1000 in net step, in 3 decimals
        userWalletBalance[msg.sender] += amountByStakeId[_stakeId] + reward/100000;
        currentTotalStakesByAddress[msg.sender] -= amountByStakeId[_stakeId] + reward/100000;
        totalUnstakedByAddress[msg.sender] += amountByStakeId[_stakeId] + reward/100000;
        totalEarnedRewards[msg.sender] += reward/100000;
        return true;
    }

    //withdraw staked tokens
    function unstakeTokenssWithPenalty(uint256 _stakeId) external returns(bool){
        require(msg.sender ==  addressByStakeId[_stakeId], "Invalid user or stake Id");
        require(flagByStakeId[_stakeId] != true, "Tokens already withdrawn");
        uint256 penalty = amountByStakeId[_stakeId] * penaltyMultiplier * (block.timestamp - timeByStakeId[_stakeId])/3600; //multipler will be divided by 1000 in net step, in 3 decimals
        userWalletBalance[msg.sender] += amountByStakeId[_stakeId] - penalty/100000;
        currentTotalStakesByAddress[msg.sender] -= amountByStakeId[_stakeId] - penalty/100000;
        totalUnstakedByAddress[msg.sender] += amountByStakeId[_stakeId] - penalty/100000;
        return true;
    }

    //withdraw staked tokens
    function withdrawFromWallet(uint256 _amount) external returns(bool){
        require(userWalletBalance[msg.sender] <= _amount, "Insufficient Balance");
        require(userWalletBalance[msg.sender] > 0, "Require non zero balance");
        stakingToken.transfer(msg.sender, _amount);
        userWalletBalance[msg.sender] -= _amount;
        return true;
    }

    function checkWalletBalance(address _userAddress) external view returns(uint256){
        return userWalletBalance[_userAddress];
    }

    //check amount by stakeId
    function checkCurrentByStakeId(uint256 _stakeId) external view returns(uint256 _totalAmount) {
        _totalAmount = (amountByStakeId[_stakeId] * rewardMultiplier * (block.timestamp - timeByStakeId[_stakeId])/3600)/100000;
    }

    // To get list of all stake holders
    function getAllStakeHolders() public view returns(address[] memory){
        return stakersAddresses;
    }

    //Get staker adress by ID 
    function getStakerAddressById(uint256 _userId) public view returns(address){
        return addressByStakeId[_userId];
    }

    //Get total current staked tokens by address
    function getTotalStakedTokensByAddress(address _address) public view returns(uint256){
        return currentTotalStakesByAddress[_address];
    }

    //Get total stake details by address
    function getAllStakesByAddress(address _address) public view returns(uint256[] memory _stakeId , uint256[] memory _amountByStakeId, uint256[] memory _timeByStakeId , bool[] memory _flagByStakeId){
        for(uint256 i=0; i <numberOfStakesByAdd[_address]; i ++){
            uint256 stakeIdNow = allStakeIdByAddress[_address][i];
            _stakeId[i] = stakeIdNow;
            _amountByStakeId[i] = amountByStakeId[stakeIdNow];
            _timeByStakeId[i] = timeByStakeId[stakeIdNow];
            _flagByStakeId[i] = flagByStakeId[stakeIdNow];
        }
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}