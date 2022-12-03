/**
 *Submitted for verification at BscScan.com on 2022-12-02
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.16;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
contract Context {
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view returns (bytes memory) {
        this;  // silence state mutability warning without generating bytecode - see httpsgithub.comethereumsolidityissues2691
        return msg.data;
    }
}
contract Ownable is Context {
    address public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
} 
contract StakeV2 is Context, Ownable {
    uint private _rateDivider = 1_000;
    uint BLA_DECIMALS = 1_000_000_000; // 10^9 

    IERC20 BLUE_ART = IERC20(0x2F93088D4747314E8AEf0334d12A2029473D32A5);
    address private _POOL_ADDRESS = address(this);
    //address private _POOL_ADDRESS = 0xc122b8B41F2e8D1F38bfbCE0D690D172F9e88d74;

    uint profitRate = 5; // 0.5%
    uint contractDebt = 0; 
    bool isStakingOpen = true;
    uint minStakeAmount = 1000;
    uint maxStakeAmount = 10000;
    uint stakingDuration = 120; // -> 2 munites (2 * 60)
    // 604800; -> 7 Days (7 * 24 * 60 * 60)

    event Staked(address staker, uint amount /* in BLA */);
    event Withdraw(address staker, uint amount /* in BLA */);

    struct Stake {
        uint stakedAmount;
        uint startDate;
        uint endDate;
    }
    mapping(address => Stake) private _stakers;
    mapping(address => bool) private _isStaked;

    constructor() {
        _owner = _msgSender();
    }
// public
    function stake(uint token_amount) external {
        require(isStakingOpen, "ERROR: Staking is closed. You can only withdraw");

        address msgSender = _msgSender();
        
        require(_isStaked[msgSender] == false, "ERROR: User already staked.");
        require(token_amount >= minStakeAmount && token_amount <= maxStakeAmount, "ERROR: Invalid stake amount");

        uint parsedTokenAmount = token_amount*BLA_DECIMALS;
        bool success = BLUE_ART.transferFrom(msgSender, _POOL_ADDRESS, parsedTokenAmount);
        require(success, "ERROR: BLA staking failed.");

        contractDebt += calcReward(parsedTokenAmount);

        _stakers[msgSender] = Stake({
            stakedAmount: token_amount,
            startDate: block.timestamp,
            endDate: block.timestamp + stakingDuration
        });

        _isStaked[_msgSender()] = true;

        emit Staked(_msgSender(), token_amount);
    }
    function withdraw() external {
        address msgSender = _msgSender();
        Stake memory stakeInfo = _stakers[msgSender];

        require(_isStaked[msgSender], "ERROR: You are not participated.");
        require(stakeInfo.stakedAmount > 0, "ERROR: Zero staked tokens");
        require(stakeInfo.endDate < block.timestamp, "ERROR: Stake time is not over yet." );

        uint reward = calcReward(stakeInfo.stakedAmount*BLA_DECIMALS);
        bool success = BLUE_ART.transfer(_msgSender(), reward);
        require(success, "ERROR: BLA withdrawing failed.");

        contractDebt -= reward;
        _stakers[_msgSender()] = Stake({stakedAmount: 0, startDate: 0, endDate: 0});
        _isStaked[_msgSender()] = false;
        emit Withdraw(_msgSender(), reward);
    }
    function calcReward(uint staked_amount) public view returns(uint) {
        uint reward = (staked_amount*profitRate) / _rateDivider;
        uint total = reward + staked_amount;

        return total;        
    }
    function getContractDeptStatus() external view returns(uint) {
        if(contractDebt > BLUE_ART.balanceOf(address(this))) {
            return contractDebt - BLUE_ART.balanceOf(address(this));
        }
        else {return 0;}
    }
    function getProfitRate() external view returns(uint) {return profitRate;}
    function getRateDivider() external view returns(uint) {return _rateDivider;}
    function getContractDept() external view returns(uint) {return contractDebt;}
    function getIsStakingOpen() external view returns(bool) {return isStakingOpen;}
    function getMinStakeAmount() external view returns(uint) {return minStakeAmount;}
    function getMaxStakeAmount() external view returns(uint) {return maxStakeAmount;}
    function getStakingDuration() external view returns(uint) {return stakingDuration;}
    function getContractBalance() external view returns(uint) {return BLUE_ART.balanceOf(address(this));}
    function getStakeInfo(address user_addr) external view returns(Stake memory) {return _stakers[user_addr];}
// only owner
    function setStakingDuration(uint new_staking_duration) external onlyOwner {
        stakingDuration = new_staking_duration;
    }
    function setProfitRate(uint new_profit_rate) external onlyOwner {
        profitRate = new_profit_rate;
    }
    function setMinStake(uint min_stake_amount) external onlyOwner {
        minStakeAmount = min_stake_amount;
    }
    function setMaxStake(uint max_stake_amount) external onlyOwner {
        maxStakeAmount = max_stake_amount;
    }
    function setRateDivider(uint new_rate_divider) external onlyOwner {
        _rateDivider = new_rate_divider;
    } 
    function setPoolAddress(address new_pool_addr) external onlyOwner {
        _POOL_ADDRESS = new_pool_addr;
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
        uint contractBalance = BLUE_ART.balanceOf(address(this));

        bool success = BLUE_ART.transfer(owner(), contractBalance);
        require(success, "Error when returning contract tokens.");
    }
    function destroyContract() external onlyOwner {
        // only for protection purpose
        selfdestruct(payable(owner()));
    }
}