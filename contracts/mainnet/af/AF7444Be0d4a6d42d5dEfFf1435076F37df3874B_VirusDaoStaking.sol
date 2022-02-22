/**
 *Submitted for verification at BscScan.com on 2022-02-22
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IERC20 {

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

}

contract VirusDaoVault {

    address private owner;
    address private stakingContract;
    IERC20 private virusDao;

    constructor(address _virusDaoTokenAddress){
        owner = msg.sender;
        virusDao = IERC20(_virusDaoTokenAddress);
    }

    modifier onlyStakingContract {
        require(msg.sender == stakingContract);
        _;
    }

    function initialize(address _stakingContract) public {
        require(msg.sender == owner);
        stakingContract = _stakingContract;
    }

    function getStakingContract() public view returns(address) {
        return stakingContract;
    }

    function getOwner() public view returns(address) {
        return owner;
    }

    function getVirusDao() public view returns(address) {
        return address(virusDao);
    }

    function getVaultBalance() public view returns(uint256) {
        return virusDao.balanceOf(address(this));
    }

    function renounceOwnership() public {
        require(msg.sender == owner);
        owner = address(0);
    }

    function transferOwnership(address _newOwner) public {
        require(msg.sender == owner);
        owner = _newOwner;
    }

    function transfer(address _to, uint256 _value) external onlyStakingContract {
        bool success = virusDao.transfer(_to, _value);
        require(success);
    }

    function deposit(uint256 _value) external {
        bool success = virusDao.transferFrom(msg.sender, address(this), _value);
        require(success);
    }

}

contract VirusDaoStaking {
 
    VirusDaoVault private vault;
    IERC20 private virusDao;
    address private _owner;
 
    uint256 immutable pointMultiplier = 10 * (10 ** 20);
    uint256 public totalStaked;
    uint256 public tokenRewardPerBlock;
    uint256 public totalRewardsDistributed;
    uint256 public accVirusPerShare;
    uint256 public lastBlockReward;
 
    uint256 public EndsIn = 150 days;
 
    mapping(address => uint) private stakedAmounts;
    mapping(address => uint) private debtAmounts;  
 
    event Staked(address _account, uint _amount);
    event Unstaked(address _account, uint _amount);
 
    constructor(address _vault,address _virusDaoContract) {
        vault = VirusDaoVault(_vault);
        virusDao = IERC20(_virusDaoContract);
        _owner = msg.sender;
    }
 
    modifier onlyOwner {
        require(_owner == msg.sender);
        _;
    }
 
    function editRewardPerBlock(uint _rewardPerBlock) public onlyOwner {
        tokenRewardPerBlock = _rewardPerBlock;
    }
 
    function getVaultAddress() external view returns(address){
        return address(vault);
    }
 
    function getMultiplier() internal view returns (uint256) {
        uint256 blocks;
        if(lastBlockReward == 0){
            blocks = 0;
        } else if(block.number != lastBlockReward){
            blocks = block.number - lastBlockReward;
        }
        return blocks;
    }
 
    function pendingRewardOf(address _user) external view returns (uint256) {
        uint256 virusBalance = virusDao.balanceOf(address(this));
        uint256 accVirusPerShareInternal = accVirusPerShare;
        if (block.number > lastBlockReward && virusBalance != 0) {
            uint256 multiplier = getMultiplier();
            uint256 virusReward = multiplier * tokenRewardPerBlock;
            accVirusPerShareInternal = accVirusPerShare + (virusReward * pointMultiplier / virusBalance);
        }
        return ((stakedAmounts[_user] * accVirusPerShareInternal) / pointMultiplier) - debtAmounts[_user];
    }
 
    function stakedBalanceOf(address _user) public view returns(uint256) {
        return stakedAmounts[_user];
    }
 
    function activateStaking() public onlyOwner {
        uint256 balance = virusDao.balanceOf(address(vault));
        uint avgBlockTimeAsBlock = EndsIn / 3;
        uint256 optimalBlockReward = balance / avgBlockTimeAsBlock;
        tokenRewardPerBlock = optimalBlockReward;
    }
 
    function updateData() public {
        if(block.number <= lastBlockReward) {
            return;
        }
        uint256 VirusSupply = virusDao.balanceOf(address(this));
        uint256 multiplier = getMultiplier();
        uint256 totalReward = multiplier * tokenRewardPerBlock;
        accVirusPerShare += totalReward * pointMultiplier / VirusSupply;
        lastBlockReward = block.number;
    }
 
    function stake(uint _amount) external {
        require(_amount > 0);
        require(virusDao.balanceOf(msg.sender) >= _amount);
        require(virusDao.allowance(msg.sender, address(this)) >= _amount);
        if(stakedAmounts[msg.sender] > 0){
            uint256 UnPaidTokens = ((stakedAmounts[msg.sender] * accVirusPerShare) / pointMultiplier) - debtAmounts[msg.sender];
            vault.transfer(msg.sender,UnPaidTokens);
            totalRewardsDistributed += UnPaidTokens;
        }
        bool success = virusDao.transferFrom(msg.sender, address(this), _amount);
        require(success); 
        totalStaked += _amount;
        stakedAmounts[msg.sender] += _amount;
        debtAmounts[msg.sender] = stakedAmounts[msg.sender] * (accVirusPerShare) / pointMultiplier;
        updateData();
        emit Staked(msg.sender,_amount);
    }
 
    function unStake(uint _amount) external {
        updateData();
        require(stakedAmounts[msg.sender] >= _amount, "Virus Dao Staking: Not enough staked");
        uint pending = stakedAmounts[msg.sender] * accVirusPerShare / pointMultiplier - debtAmounts[msg.sender];
        if(pending > 0) {
            vault.transfer(msg.sender, pending);
            totalRewardsDistributed += pending;
        }
        if(_amount > 0) {
            stakedAmounts[msg.sender] -= _amount;
            virusDao.transfer(msg.sender, _amount);
        }
        debtAmounts[msg.sender] = stakedAmounts[msg.sender] * (accVirusPerShare) / pointMultiplier;
        totalStaked -= _amount;
        emit Unstaked(msg.sender,_amount);
    }
 
    function emergencyWithdraw() public {
        require(stakedAmounts[msg.sender] > 0,"Virus Dao Staking: Not enough staked");
        uint256 stakedAmountOfUser = stakedAmounts[msg.sender];
        stakedAmounts[msg.sender] = 0;
        debtAmounts[msg.sender] = 0;
        require(virusDao.transfer(msg.sender, stakedAmountOfUser),"Virus Dao Staking: Transfer Failed");
        totalStaked -= stakedAmountOfUser;
    }
 
 
}