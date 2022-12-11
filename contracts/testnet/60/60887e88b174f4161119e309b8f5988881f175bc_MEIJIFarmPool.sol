/**
 *Submitted for verification at BscScan.com on 2022-12-10
*/

/**
 *Submitted for verification at BscScan.com on 2021-11-19
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.9;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity 0.8.9;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity 0.8.9;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library SafeERC20 {
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(token.approve(spender, value));
    }
}

pragma solidity 0.8.9;

contract MEIJIFarmPool is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public tokenAddress;
    address public rewardTokenAddress;
    uint256 public stakedTotal;
    uint256 public stakedBalance;
    uint256 public rewardBalance;
    uint256 public totalReward;
    uint256 public startingBlock;
    uint256 public endingBlock;
    uint256 public period;
    uint256 public accShare;
    uint256 public lastRewardBlock;
    uint256 public totalParticipants;
    uint256 public lockDuration;
    bool public isPaused;
    uint256 public constant blocksPerHour = 1200;

    IERC20 public ERC20Interface;

    struct Deposits {
        uint256 amount;
        uint256 initialStake;
        uint256 latestClaim;
        uint256 userAccShare;
        uint256 currentPeriod;
        uint256 latestStakeTime;
    }

    struct periodDetails {
        uint256 period;
        uint256 accShare;
        uint256 rewPerBlock;
        uint256 startingBlock;
        uint256 endingBlock;
        uint256 rewards;
    }

    mapping(address => Deposits) private deposits;
    mapping(address => bool) public isPaid;
    mapping(address => bool) public hasStaked;
    mapping(uint256 => periodDetails) public endAccShare;

    event NewPeriodSet(
        uint256 period,
        uint256 startBlock,
        uint256 endBlock,
        uint256 lockDuration,
        uint256 rewardAmount
    );
    event PeriodExtended(uint256 period, uint256 endBlock, uint256 rewards);
    event Staked(
        address indexed token,
        address indexed staker_,
        uint256 stakedAmount_
    );
    event PaidOut(
        address indexed token,
        address indexed rewardToken,
        address indexed staker_,
        uint256 amount_,
        uint256 reward_
    );

    constructor(address _tokenAddress, address _rewardTokenAddress) Ownable() {
        require(_tokenAddress != address(0), "Zero token address");
        tokenAddress = _tokenAddress;
        require(_rewardTokenAddress != address(0), "Zero reward token address");
        rewardTokenAddress = _rewardTokenAddress;
        isPaused = true;
    }

    /*
        -   To set the start and end blocks for each period
    */

    function setStartEnd(uint256 _start, uint256 _end) private {
        require(totalReward > 0, "Add rewards for this period");
        startingBlock = _start;
        endingBlock = _end;
        period++;
        isPaused = false;
        lastRewardBlock = _start;
    }

    function addReward(uint256 _rewardAmount)
        private
        _hasAllowance(msg.sender, _rewardAmount, rewardTokenAddress)
        returns (bool)
    {
        totalReward = totalReward.add(_rewardAmount);
        rewardBalance = rewardBalance.add(_rewardAmount);
        if (!_payMe(msg.sender, _rewardAmount, rewardTokenAddress)) {
            return false;
        }
        return true;
    }

    /*
        -   To reset the contract at the end of each period.
    */

    function reset() private {
        require(block.number > endingBlock, "Wait till end of this period");
        updateShare();
        endAccShare[period] = periodDetails(
            period,
            accShare,
            rewPerBlock(),
            startingBlock,
            endingBlock,
            rewardBalance
        );
        totalReward = 0;
        stakedBalance = 0;
        isPaused = true;
    }

    function resetAndsetStartEndBlock(
        uint256 _rewardAmount,
        uint256 _start,
        uint256 _end,
        uint256 _lockDuration
    ) external onlyOwner returns (bool) {
        require(
            _start > currentBlock(),
            "Start should be more than current block"
        );
        require(_end > _start, "End block should be greater than start");
        require(_rewardAmount > 0, "Reward must be positive");
        reset();
        bool rewardAdded = addReward(_rewardAmount);
        require(rewardAdded, "Rewards error");
        setStartEnd(_start, _end);
        lockDuration = _lockDuration;
        totalParticipants = 0;
        emit NewPeriodSet(period, _start, _end, _lockDuration, _rewardAmount);
        return true;
    }

    /*
        -   Function to update rewards and state parameters
    */

    function updateShare() private {
        if (block.number <= lastRewardBlock) {
            return;
        }
        if (stakedBalance == 0) {
            lastRewardBlock = block.number;
            return;
        }

        uint256 noOfBlocks;

        if (block.number >= endingBlock) {
            noOfBlocks = endingBlock.sub(lastRewardBlock);
        } else {
            noOfBlocks = block.number.sub(lastRewardBlock);
        }

        uint256 rewards = noOfBlocks.mul(rewPerBlock());

        accShare = accShare.add((rewards.mul(1e6).div(stakedBalance)));
        if (block.number >= endingBlock) {
            lastRewardBlock = endingBlock;
        } else {
            lastRewardBlock = block.number;
        }
    }

    function rewPerBlock() public view returns (uint256) {
        if (totalReward == 0 || rewardBalance == 0) return 0;
        uint256 rewardperBlock = totalReward.div(
            (endingBlock.sub(startingBlock))
        );
        return (rewardperBlock);
    }

    function stake(uint256 amount)
        external
        _hasAllowance(msg.sender, amount, tokenAddress)
        returns (bool)
    {
        require(!isPaused, "Contract is paused");
        require(
            block.number >= startingBlock && block.number < endingBlock,
            "Invalid period"
        );
        require(amount > 0, "Can't stake 0 amount");
        return (_stake(msg.sender, amount));
    }

    function _stake(address from, uint256 amount) private returns (bool) {
        updateShare();

        if (!hasStaked[from]) {
            deposits[from] = Deposits(
                amount,
                block.number,
                block.number,
                accShare,
                period,
                block.timestamp
            );
            totalParticipants = totalParticipants.add(1);
            hasStaked[from] = true;
        } else {
            if (deposits[from].currentPeriod != period) {
                bool renew_ = _renew(from);
                require(renew_, "Error renewing");
            } else {
                bool claim = _claimRewards(from);
                require(claim, "Error paying rewards");
            }

            uint256 userAmount = deposits[from].amount;

            deposits[from] = Deposits(
                userAmount.add(amount),
                block.number,
                block.number,
                accShare,
                period,
                block.timestamp
            );
        }
        stakedBalance = stakedBalance.add(amount);
        stakedTotal = stakedTotal.add(amount);
        if (!_payMe(from, amount, tokenAddress)) {
            return false;
        }
        emit Staked(tokenAddress, from, amount);
        return true;
    }

    function userDeposits(address from)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        if (hasStaked[from]) {
            return (
                deposits[from].amount,
                deposits[from].initialStake,
                deposits[from].latestClaim,
                deposits[from].currentPeriod,
                deposits[from].latestStakeTime
            );
        } else {
            return (0, 0, 0, 0, 0);
        }
    }

    function fetchUserShare(address from) public view returns (uint256) {
        require(hasStaked[from], "No stakes found for user");
        if (stakedBalance == 0) {
            return 0;
        }
        require(
            deposits[from].currentPeriod == period,
            "Please renew in the active valid period"
        );
        uint256 userAmount = deposits[from].amount;
        require(userAmount > 0, "No stakes available for user"); //extra check
        return 1;
    }

    function claimRewards() public returns (bool) {
        require(fetchUserShare(msg.sender) > 0, "No stakes found for user");
        return (_claimRewards(msg.sender));
    }

    function _claimRewards(address from) private returns (bool) {
        uint256 userAccShare = deposits[from].userAccShare;
        updateShare();
        uint256 amount = deposits[from].amount;
        uint256 rewDebt = amount.mul(userAccShare).div(1e6);
        uint256 rew = (amount.mul(accShare).div(1e6)).sub(rewDebt);
        require(rew > 0, "No rewards generated");
        require(rew <= rewardBalance, "Not enough rewards in the contract");
        deposits[from].userAccShare = accShare;
        deposits[from].latestClaim = block.number;
        rewardBalance = rewardBalance.sub(rew);
        bool payRewards = _payDirect(from, rew, rewardTokenAddress);
        require(payRewards, "Rewards transfer failed");
        emit PaidOut(tokenAddress, rewardTokenAddress, from, amount, rew);
        return true;
    }

    function renew() public returns (bool) {
        require(!isPaused, "Contract paused");
        require(hasStaked[msg.sender], "No stakings found, please stake");
        require(
            deposits[msg.sender].currentPeriod != period,
            "Already renewed"
        );
        require(
            block.number > startingBlock && block.number < endingBlock,
            "Wrong time"
        );
        return (_renew(msg.sender));
    }

    function _renew(address from) private returns (bool) {
        updateShare();
        if (viewOldRewards(from) > 0) {
            bool claimed = claimOldRewards();
            require(claimed, "Error paying old rewards");
        }
        deposits[from].currentPeriod = period;
        deposits[from].initialStake = block.number;
        deposits[from].latestClaim = block.number;
        deposits[from].userAccShare = accShare;
        stakedBalance = stakedBalance.add(deposits[from].amount);
        totalParticipants = totalParticipants.add(1);
        return true;
    }

    function viewOldRewards(address from) public view returns (uint256) {
        require(!isPaused, "Contract paused");
        require(hasStaked[from], "No stakings found, please stake");

        if (deposits[from].currentPeriod == period) {
            return 0;
        }

        uint256 userPeriod = deposits[from].currentPeriod;

        uint256 accShare1 = endAccShare[userPeriod].accShare;
        uint256 userAccShare = deposits[from].userAccShare;

        if (deposits[from].latestClaim >= endAccShare[userPeriod].endingBlock)
            return 0;
        uint256 amount = deposits[from].amount;
        uint256 rewDebt = amount.mul(userAccShare).div(1e6);
        uint256 rew = (amount.mul(accShare1).div(1e6)).sub(rewDebt);

        require(rew <= rewardBalance, "Not enough rewards");

        return (rew);
    }

    function claimOldRewards() public returns (bool) {
        require(!isPaused, "Contract paused");
        require(hasStaked[msg.sender], "No stakings found, please stake");
        require(
            deposits[msg.sender].currentPeriod != period,
            "Already renewed"
        );

        uint256 userPeriod = deposits[msg.sender].currentPeriod;

        uint256 accShare1 = endAccShare[userPeriod].accShare;
        uint256 userAccShare = deposits[msg.sender].userAccShare;

        require(
            deposits[msg.sender].latestClaim <
                endAccShare[userPeriod].endingBlock,
            "Already claimed old rewards"
        );
        uint256 amount = deposits[msg.sender].amount;
        uint256 rewDebt = amount.mul(userAccShare).div(1e6);
        uint256 rew = (amount.mul(accShare1).div(1e6)).sub(rewDebt);

        require(rew <= rewardBalance, "Not enough rewards");
        deposits[msg.sender].latestClaim = endAccShare[userPeriod].endingBlock;
        rewardBalance = rewardBalance.sub(rew);
        bool paidOldRewards = _payDirect(msg.sender, rew, rewardTokenAddress);
        require(paidOldRewards, "Error paying");
        emit PaidOut(tokenAddress, rewardTokenAddress, msg.sender, amount, rew);
        return true;
    }

    function calculate(address from) public view returns (uint256) {
        if (fetchUserShare(from) == 0) return 0;
        return (_calculate(from));
    }

    function _calculate(address from) private view returns (uint256) {
        uint256 userAccShare = deposits[from].userAccShare;
        uint256 currentAccShare = accShare;
        //Simulating updateShare() to calculate rewards
        if (block.number <= lastRewardBlock) {
            return 0;
        }
        if (stakedBalance == 0) {
            return 0;
        }

        uint256 noOfBlocks;

        if (block.number >= endingBlock) {
            noOfBlocks = endingBlock.sub(lastRewardBlock);
        } else {
            noOfBlocks = block.number.sub(lastRewardBlock);
        }

        uint256 rewards = noOfBlocks.mul(rewPerBlock());

        uint256 newAccShare = currentAccShare.add(
            (rewards.mul(1e6).div(stakedBalance))
        );
        uint256 amount = deposits[from].amount;
        uint256 rewDebt = amount.mul(userAccShare).div(1e6);
        uint256 rew = (amount.mul(newAccShare).div(1e6)).sub(rewDebt);
        return (rew);
    }

    function emergencyWithdraw() external returns (bool) {
        require(
            currentBlock() >
                deposits[msg.sender].initialStake.add(
                    lockDuration.mul(blocksPerHour)
                ),
            "Can't withdraw before lock duration"
        );
        require(hasStaked[msg.sender], "No stakes available for user");
        require(!isPaid[msg.sender], "Already Paid");
        return (_withdraw(msg.sender, deposits[msg.sender].amount));
    }

    function _withdraw(address from, uint256 amount) private returns (bool) {
        updateShare();
        deposits[from].amount = deposits[from].amount.sub(amount);
        if (!isPaused && deposits[from].currentPeriod == period) {
            stakedBalance = stakedBalance.sub(amount);
        }
        bool paid = _payDirect(from, amount, tokenAddress);
        require(paid, "Error during withdraw");
        if (deposits[from].amount == 0) {
            isPaid[from] = true;
            hasStaked[from] = false;
            if (deposits[from].currentPeriod == period) {
                totalParticipants = totalParticipants.sub(1);
            }
            delete deposits[from];
        }
        return true;
    }

    function withdraw(uint256 amount) external returns (bool) {
        require(
            currentBlock() >
                deposits[msg.sender].initialStake.add(
                    lockDuration.mul(blocksPerHour)
                ),
            "Can't withdraw before lock duration"
        );
        require(amount <= deposits[msg.sender].amount, "Wrong value");
        if (deposits[msg.sender].currentPeriod == period) {
            if (calculate(msg.sender) > 0) {
                bool rewardsPaid = claimRewards();
                require(rewardsPaid, "Error paying rewards");
            }
        }

        if (viewOldRewards(msg.sender) > 0) {
            bool oldRewardsPaid = claimOldRewards();
            require(oldRewardsPaid, "Error paying old rewards");
        }
        return (_withdraw(msg.sender, amount));
    }

    function extendPeriod(uint256 rewardsToBeAdded)
        external
        onlyOwner
        returns (bool)
    {
        require(
            currentBlock() > startingBlock && currentBlock() < endingBlock,
            "Invalid period"
        );
        require(rewardsToBeAdded > 0, "Zero rewards");
        bool addedRewards = _payMe(
            msg.sender,
            rewardsToBeAdded,
            rewardTokenAddress
        );
        require(addedRewards, "Error adding rewards");
        endingBlock = endingBlock.add(rewardsToBeAdded.div(rewPerBlock()));
        totalReward = totalReward.add(rewardsToBeAdded);
        rewardBalance = rewardBalance.add(rewardsToBeAdded);
        emit PeriodExtended(period, endingBlock, rewardsToBeAdded);
        return true;
    }

    function currentBlock() public view returns (uint256) {
        return (block.number);
    }

    function _payMe(
        address payer,
        uint256 amount,
        address token
    ) private returns (bool) {
        return _payTo(payer, address(this), amount, token);
    }

    function _payTo(
        address allower,
        address receiver,
        uint256 amount,
        address token
    ) private returns (bool) {
        // Request to transfer amount from the contract to receiver.
        // contract does not own the funds, so the allower must have added allowance to the contract
        // Allower is the original owner.
        ERC20Interface = IERC20(token);
        ERC20Interface.safeTransferFrom(allower, receiver, amount);
        return true;
    }

    function _payDirect(
        address to,
        uint256 amount,
        address token
    ) private returns (bool) {
        require(
            token == tokenAddress || token == rewardTokenAddress,
            "Invalid token address"
        );
        ERC20Interface = IERC20(token);
        ERC20Interface.safeTransfer(to, amount);
        return true;
    }

    modifier _hasAllowance(
        address allower,
        uint256 amount,
        address token
    ) {
        // Make sure the allower has provided the right allowance.
        require(
            token == tokenAddress || token == rewardTokenAddress,
            "Invalid token address"
        );
        ERC20Interface = IERC20(token);
        uint256 ourAllowance = ERC20Interface.allowance(allower, address(this));
        require(amount <= ourAllowance, "Make sure to add enough allowance");
        _;
    }
}