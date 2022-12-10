/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.16;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
}
contract Context {
    function _msgSender() internal view returns (address payable) {return payable(msg.sender);}
    function _msgData() internal view returns (bytes memory) {this; return msg.data;}
}
contract Ownable is Context {
    address public _owner;
    event OwnershipTransferred(address indexed previousOwner,address indexed newOwner);
    function owner() public view returns (address) {return _owner;}
    modifier onlyOwner() {require(_owner == _msgSender(), "Ownable: caller is not the owner");_;}
    function renounceOwnership() public virtual onlyOwner {emit OwnershipTransferred(_owner, address(0));_owner = address(0);}
    function transferOwnership(address newOwner) public virtual onlyOwner {require(newOwner != address(0),"Ownable new owner is the zero address");emit OwnershipTransferred(_owner, newOwner);_owner = newOwner;}
}
contract StakeV3 is Context, Ownable {
    uint256 private BLA_DECIMALS = 1000000000; // 10^9
    uint256 private WEEK_SEC = 604800;
    uint256 private DAY_SEC = 86400;
    uint256 private rateDivider = 10000;

    IERC20 BLUE_ART = IERC20(0x2F93088D4747314E8AEf0334d12A2029473D32A5);

    uint256 profitRate = 75; // 0.75%
    uint256 contractDebt = 0;
    bool isStakingOpen = true;
    uint256 minStakeAmount = 1000;
    uint256 maxStakeAmount = 200000;
    uint256 stakingDuration = 604800;

    event Staked(address staker, uint256 amount /* in BLA */);
    event StakeUpdated(address staker, uint256 amount /* in BLA */);
    event Withdraw(address staker, uint256 amount /* in BLA */);
    struct Stake {
        uint256 stakedAmount; 
        uint256 startDate; 
        uint256 endDate;
    }
    mapping(address => Stake) private _stakers;
    mapping(address => bool) private _isStaked;
    constructor() {
        _owner = _msgSender();
    }

    // public
    function stake(uint256 token_amount) external {
        require(isStakingOpen,"ERROR: Staking is closed. You can only withdraw.");

        address senderUser = _msgSender();

        require(_isStaked[senderUser] == false, "ERROR: User already staked.");
        require(token_amount >= minStakeAmount && token_amount <= maxStakeAmount, "ERROR: Invalid stake amount.");

        uint256 parsedTokenAmount = token_amount * BLA_DECIMALS;

        _isStaked[senderUser] = true;

        bool success = BLUE_ART.transferFrom(senderUser, address(this), parsedTokenAmount);
        require(success, "ERROR: BLA staking failed.");

        contractDebt += calcReward(parsedTokenAmount);

        _stakers[senderUser] = Stake({
            stakedAmount: token_amount,
            startDate: block.timestamp,
            endDate: block.timestamp + stakingDuration
        });

        emit Staked(senderUser, token_amount);
    }
    function withdraw() external {
        address senderUser = _msgSender();
        Stake memory stakeInfo = _stakers[senderUser];

        require(_isStaked[senderUser], "ERROR: You are not participated.");
        require(stakeInfo.stakedAmount > 0, "ERROR: Zero staked tokens.");
        require(stakeInfo.endDate < block.timestamp, "ERROR: Stake time is not over yet.");

        _isStaked[senderUser] = false;
        _stakers[senderUser] = Stake({
            stakedAmount: 0,
            startDate: 0,
            endDate: 0
        });

        uint256 reward = calcReward(stakeInfo.stakedAmount * BLA_DECIMALS);
        contractDebt -= reward;

        bool success = BLUE_ART.transfer(senderUser, reward);
        require(success, "ERROR: BLA withdrawing failed.");

        emit Withdraw(senderUser, reward);
    }
    function updateStakeDuration() external {
        address senderUser = _msgSender();
        Stake memory stakeInfo = _stakers[senderUser];

        uint256 _endDate = stakeInfo.endDate;
        uint256 _startDate = stakeInfo.startDate;
        uint256 _stakedAmount = stakeInfo.stakedAmount;

        require(_isStaked[senderUser], "ERROR: You are not participated.");
        require(_stakedAmount > 0, "ERROR: Zero staked tokens.");

        uint256 reward = calcReward(_stakedAmount);

        if(_endDate < block.timestamp) {            
            _stakers[senderUser] = Stake({
                stakedAmount: reward,
                startDate: _startDate,
                endDate: block.timestamp + WEEK_SEC
            });
            emit StakeUpdated(senderUser, reward);
        } else {
            uint256 leftTime = _endDate - block.timestamp;
                
            _stakers[senderUser] = Stake({
                stakedAmount: reward,
                startDate: _startDate,
                endDate: block.timestamp + WEEK_SEC + leftTime
            });
        }
        emit StakeUpdated(senderUser, reward);
    }

    function calcReward(uint256 staked_amount) public view returns (uint256) {
        uint256 reward = (staked_amount * profitRate) / rateDivider;
        uint256 total = reward + staked_amount;

        return total;
    }
    function getContractDeptStatus() external view returns (uint256) {
        if (contractDebt > BLUE_ART.balanceOf(address(this))) {
            return contractDebt - BLUE_ART.balanceOf(address(this));
        } else {
            return 0;
        }
    }
    function getProfitRate() external view returns (uint256) {return profitRate;}
    function getRateDivider() external view returns (uint256) {return rateDivider;}
    function getContractDebt() external view returns (uint256) {return contractDebt;}
    function getIsStakingOpen() external view returns (bool   ) {return isStakingOpen;}
    function getMinStakeAmount() external view returns (uint256) {return minStakeAmount;}
    function getMaxStakeAmount() external view returns (uint256) {return maxStakeAmount;}
    function getStakingDuration() external view returns (uint256) {return stakingDuration;}
    function getContractBalance() external view returns (uint256) {return BLUE_ART.balanceOf(address(this));}
    function getStakeInfo(address user_addr) external view returns (Stake memory){return _stakers[user_addr];}

    // only owner
    function setStakingDuration(uint256 new_staking_duration)external onlyOwner {
        stakingDuration = new_staking_duration;
    }
    function setProfitRate(uint256 new_profit_rate) external onlyOwner {
        profitRate = new_profit_rate;
    }
    function setMinStake(uint256 min_stake_amount) external onlyOwner {
        minStakeAmount = min_stake_amount;
    }
    function setMaxStake(uint256 max_stake_amount) external onlyOwner {
        maxStakeAmount = max_stake_amount;
    }
    function setRateDivider(uint256 new_rate_divider) external onlyOwner {
        rateDivider = new_rate_divider;
    }
    function openStaking() external onlyOwner {
        require(isStakingOpen == false, "Stake is already open.");

        isStakingOpen = true;
    }
    function closeStaking() external onlyOwner {
        require(isStakingOpen == true, "Stake is already closed.");

        isStakingOpen = false;
    }
    function returnBLATokens() external onlyOwner {
        uint256 contractBalance = BLUE_ART.balanceOf(address(this));

        bool success = BLUE_ART.transfer(owner(), contractBalance);
        require(success, "Error: Returning contracts BLA tokens.");
    }
    function destroyContract() external onlyOwner {
        // only for protection purpose
        selfdestruct(payable(owner()));
    }
}