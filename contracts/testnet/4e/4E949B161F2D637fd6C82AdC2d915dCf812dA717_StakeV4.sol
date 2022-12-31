/**
 *Submitted for verification at BscScan.com on 2022-12-30
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
contract StakeV4 is Context, Ownable {

    uint256 private T_DAY = 300;// 86400;
    uint256 private T_WEEK = 600;// 604800;
    uint256 private T_MONTH = 300;// 2592000; // 60 * 60 * 24 * 30(days)

    uint256 private RATE_DIVIDER = 10000;
    uint256 private BLA_DECIMALS = 1000000000; // 10^9

    IERC20 BLUE_ART = IERC20(0x2F93088D4747314E8AEf0334d12A2029473D32A5);

    uint256 contractDebt = 0;
    bool isStakingOpen = true;
    uint256 minStakeAmount = 1000;
    uint256 maxStakeAmount = 200000;

    event Staked(address staker, uint256 amount /* in BLA */);
    event StakeUpdated(address staker, uint256 amount /* in BLA */);
    event Withdrawed(address staker, uint256 amount /* in BLA */);
    event ForceWithdrawed(address staker, uint256 amount /* in BLA */);
    
    struct User {
        uint8 stakeType;
        uint256 stakedAmount; 
        uint256 startDate; 
        uint256 endDate;
    }
    struct Stake {
        uint8 id; 
        uint256 rate;
        uint256 duration; 
    }
    
    mapping(address => User) private _userInfo;
    mapping(address => bool) private _isStaked;
    mapping(uint256 => Stake) private _stakeInfo; 

    constructor() {
        _stakeInfo[0] = Stake({id: 0, rate: 35, duration: T_WEEK});
        _stakeInfo[1] = Stake({id: 1, rate: 200, duration: T_MONTH});
        _stakeInfo[2] = Stake({id: 2, rate: 800, duration: T_MONTH * 3}); // three months

        _owner = _msgSender();
    }

    // public
    function stake(uint256 token_amount, uint8 stake_type) external {
        require(isStakingOpen,"ERROR: Staking is closed. You can only withdraw.");
        require(stake_type <= 2 && stake_type >= 0, "ERROR: Invalid stake type.");
        address senderUser = _msgSender();

        require(_isStaked[senderUser] == false, "ERROR: User already staked.");
        require(token_amount >= minStakeAmount && token_amount <= maxStakeAmount, "ERROR: Invalid stake amount.");

        uint256 parsedTokenAmount = token_amount * BLA_DECIMALS;

        _isStaked[senderUser] = true;

        bool success = BLUE_ART.transferFrom(senderUser, address(this), parsedTokenAmount);
        require(success, "ERROR: BLA staking failed.");

        contractDebt += calcReward(parsedTokenAmount, stake_type);

        _userInfo[senderUser] = User({
            stakeType: stake_type,
            stakedAmount: token_amount,
            startDate: block.timestamp,
            endDate: block.timestamp + _stakeInfo[stake_type].duration
        });

        emit Staked(senderUser, token_amount);
    }
    function withdraw() public {
        address senderUser = _msgSender();
        User memory user = _userInfo[senderUser];

        require(_isStaked[senderUser], "ERROR: You are not participated.");
        require(user.stakedAmount > 0, "ERROR: Zero staked tokens.");
        require(user.endDate < block.timestamp, "ERROR: Stake time is not over yet.");

        _isStaked[senderUser] = false;
        _userInfo[senderUser] = User({
            stakedAmount: 0,
            stakeType: 0,
            startDate: 0,
            endDate: 0
        });

        uint256 reward = calcReward(user.stakedAmount * BLA_DECIMALS, _stakeInfo[user.stakeType].rate);
        contractDebt -= reward;

        bool success = BLUE_ART.transfer(senderUser, reward);
        require(success, "ERROR: BLA withdrawing failed.");

        emit Withdrawed(senderUser, reward);
    }
    function forceWithdraw() external {
        address senderUser = _msgSender();
        User memory user = _userInfo[senderUser];

        uint256 _endDate = user.endDate;
        uint256 _stakedAmount = user.stakedAmount;

        require(_isStaked[senderUser], "ERROR: You are not participated.");
        require(_stakedAmount > 0, "ERROR: Zero staked tokens.");

        if(_endDate < block.timestamp) {            
            withdraw();
        } else {             
            _isStaked[senderUser] = false;
            _userInfo[senderUser] = User({
                stakedAmount: 0,
                stakeType: 0,
                startDate: 0,
                endDate: 0
            });

            uint256 parsedStakedAmount = _stakedAmount*BLA_DECIMALS;
            contractDebt -= parsedStakedAmount;

            bool success = BLUE_ART.transfer(senderUser, parsedStakedAmount);
            require(success, "ERROR: BLA withdrawing failed.");

            emit ForceWithdrawed(senderUser, _stakedAmount);
        }
    }
    function calcReward(uint256 staked_amount, uint256 profit_rate) public view returns (uint256) {
        uint256 reward = (staked_amount * profit_rate) / RATE_DIVIDER;
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
    function getStakeInfo() external view returns(Stake[3] memory) {return [_stakeInfo[0], _stakeInfo[1], _stakeInfo[2]];}
    function getContractDebt() external view returns (uint256) {return contractDebt;}
    function getIsStakingOpen() external view returns (bool   ) {return isStakingOpen;}
    function getMinStakeAmount() external view returns (uint256) {return minStakeAmount;}
    function getMaxStakeAmount() external view returns (uint256) {return maxStakeAmount;}
    function getContractBalance() external view returns (uint256) {return BLUE_ART.balanceOf(address(this));}
    function getUserInfo(address user_addr) external view returns (User memory){return _userInfo[user_addr];}

    // only owner
    function setMinStakeAmount(uint256 min_stake_amount) external onlyOwner {
        minStakeAmount = min_stake_amount;
    }
    function setMaxStakeAmount(uint256 max_stake_amount) external onlyOwner {
        maxStakeAmount = max_stake_amount;
    }
    function setProfitRate(uint8 new_profit_rate, uint8 stake_type) external onlyOwner {
        require(stake_type <= 2 && stake_type >= 0, "ERROR: Invalid stake type.");
        _stakeInfo[stake_type].rate = new_profit_rate;
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