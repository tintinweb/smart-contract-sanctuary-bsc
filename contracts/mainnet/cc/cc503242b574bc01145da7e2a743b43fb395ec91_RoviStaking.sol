// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Initializable.sol";
import "./PausableUpgradeable.sol";
import "./AccessControlEnumerableUpgradeable.sol";
import "./ERC2771ContextUpgradeable.sol";
import "./IERC20.sol";

contract RoviStaking is
    Initializable,
    ERC2771ContextUpgradeable,
    AccessControlEnumerableUpgradeable,
    PausableUpgradeable
{
    event Staked(address indexed sender, uint256 indexed stakedAmount);
    event Reward(address indexed sender, uint256 indexed totalRewardGiven, uint256 rewardGiven, uint256 indexed timestamp);
    event Unstaked(address indexed sender, uint256 indexed unstakedAmount, uint256 indexed timestamp);
    
    struct Stake {
        uint256 stakedAmount;
        uint256 startTime;
        uint256 rewardsGiven;
    }

    address public feePoolAddress;
    uint16 public feeCommission;
    uint16 public rewardCommission;

    mapping(address => Stake[]) public stakeBalances;
    uint256 public totalStakeBalance;
    uint256 public totalRewardsGiven;

    IERC20 stakingToken;
    IERC20 rewardToken;
    
    function initialize(address trustedForwarder_, address stakeToken_, address rewardToken_,
        address feePoolAddress_, uint16 feeCommission_, uint16 rewardCommission_) public initializer {
        __Stake_init(
           trustedForwarder_,
           stakeToken_,
           rewardToken_,
           feePoolAddress_,
           feeCommission_,
           rewardCommission_
        );
    }

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant PARAMETER_UPDATER_ROLE = keccak256("PARAMETER_UPDATER_ROLE");

    function __Stake_init(
        address trustedForwarder_, address stakeToken_, address rewardToken_, 
        address feePoolAddress_, uint16 feeCommission_, uint16 rewardCommission_
    ) internal onlyInitializing {
        __AccessControlEnumerable_init();
        __Pausable_init();
        __Context_init();
        __Stake_init_unchained(stakeToken_, rewardToken_, feePoolAddress_, feeCommission_, rewardCommission_);
        __ERC2771Context_init(trustedForwarder_);
    }

    function __Stake_init_unchained(address stakeToken_, address rewardToken_,
        address feePoolAddress_, uint16 feeCommission_, uint16 rewardCommission_) internal onlyInitializing {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(PARAMETER_UPDATER_ROLE, _msgSender());
        stakingToken = IERC20(stakeToken_);
        rewardToken  = IERC20(rewardToken_);
        feePoolAddress = feePoolAddress_;
        feeCommission = feeCommission_;
        rewardCommission = rewardCommission_;
    }

    function stake(uint256 amount) public whenNotPaused {
        require(amount > 0, "deposit amount should be more than 0");
        require(stakingToken.balanceOf(_msgSender()) >= amount, "Insufficient Balance");

        stakeBalances[_msgSender()].push(Stake(amount, block.timestamp, 0));

        unchecked {
            totalStakeBalance += amount;
        }
        stakingToken.transferFrom(_msgSender(), address(this), amount);
        emit Staked(_msgSender(), amount);
    }

    function claimReward(uint256 idx) public whenNotPaused {
        (uint256 reward, uint256 rewardsGiven) = calculateClaim(_msgSender(), idx);

        require(reward > rewardsGiven, "Insufficient Reward");
        uint256 rewardToPay = reward - rewardsGiven;

        transferReward(idx, rewardToPay);
    }

    function transferReward(uint256 idx, uint256 rewardToPay) internal {
        
        require(rewardToken.balanceOf(address(this)) > rewardToPay, "Insufficient balance to pay reward");
        
        unchecked {
           stakeBalances[_msgSender()][idx].rewardsGiven += rewardToPay;
        }
        uint256 commission = rewardToPay * rewardCommission / 100;

        require(rewardToken.transfer(feePoolAddress, commission), "Reward: Commission Transfer Failed");
        
        require(rewardToken.transfer(_msgSender(), rewardToPay - commission), "Reward: Transfer Failed");
        
        unchecked {
            totalRewardsGiven += rewardToPay;
        }
        emit Reward(_msgSender(), stakeBalances[_msgSender()][idx].rewardsGiven, rewardToPay, block.timestamp);
    }

    function unstake(uint256 idx) public whenNotPaused{
        Stake memory stak = stakeBalances[_msgSender()][idx];
        require(stak.stakedAmount > 0, "Invalid Index");

        (uint256 reward, uint256 rewardsGiven) = calculateClaim(_msgSender(), idx);

        if(reward > rewardsGiven)
        {
            uint256 rewardToPay = reward - rewardsGiven;
            transferReward(idx, rewardToPay);
        }

        require(stakingToken.balanceOf(address(this)) >= stak.stakedAmount, "InsufficientBalance to unstake");
        uint256 commission;
        unchecked {
            commission = stak.stakedAmount * feeCommission / 100;
        }

        require(stakingToken.transfer(feePoolAddress, commission), "Unstake: Commission Transfer Failed");
        require(stakingToken.transfer(_msgSender(), stak.stakedAmount - commission), "Unstake: Transfer Failed");
        
        //delete stakeBalances[_msgSender()][idx];

        //instead of deleting the object at index, we are exchanging with last element in array and pop last element.
        stakeBalances[_msgSender()][idx]= stakeBalances[_msgSender()][stakeBalances[_msgSender()].length - 1];
        stakeBalances[_msgSender()].pop();
        totalStakeBalance -= stak.stakedAmount;

        emit Unstaked(_msgSender(), stak.stakedAmount, block.timestamp);
    }

    function stakedLength(address user) external  view returns(uint256) {
        return stakeBalances[user].length;
    }

    function calculateClaim(address user, uint256 idx) public view returns(uint256, uint256) {
        Stake memory stak = stakeBalances[user][idx];
        require(stak.stakedAmount > 0, "Invalid Index");

        uint256 timeDuration = block.timestamp - stak.startTime;
        //uint256 days = timeDuration/86400;
        uint256 reward;
        
        if(timeDuration <= 90 days)
        {
            unchecked {
                reward = (stak.stakedAmount * 24) / 100;
            }
        }
        else if(timeDuration <= 180 days)
        {
            unchecked {
                reward = (stak.stakedAmount * 48) / 100;
            }
        }
        else 
        {
            unchecked {
                reward = (stak.stakedAmount * 76) / 100;
            }
        }

        unchecked {
            reward = (reward * timeDuration) / (365 days);
            return (reward, stak.rewardsGiven);
        }
        
    }
    function pause() public onlyRole(PAUSER_ROLE) whenNotPaused {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) whenPaused {
        _unpause();
    }

    function _msgSender() internal view virtual override(ContextUpgradeable, ERC2771ContextUpgradeable) returns (address sender) {
        return ERC2771ContextUpgradeable._msgSender();
    }

    function _msgData() internal view virtual override(ContextUpgradeable, ERC2771ContextUpgradeable) returns (bytes calldata) {
        return ERC2771ContextUpgradeable._msgData();
    }

    function updateTrustedForwarder(address forwarder) public onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _trustedForwarder = forwarder;
    }

    function updateFeeCommission(uint16 feeCommission_) public onlyRole(PARAMETER_UPDATER_ROLE)
    {
        feeCommission = feeCommission_;
    }
   
    function updateRewardCommission(uint16 rewardCommission_) public onlyRole(PARAMETER_UPDATER_ROLE)
    {
        rewardCommission = rewardCommission_;
    }

   function updateFeePoolAddress(address feePoolAddress_) public onlyRole(PARAMETER_UPDATER_ROLE)
    {
        feePoolAddress = feePoolAddress_;
    }

    function withdrawFromStakeToken(address to, uint256 amount) public onlyRole(DEFAULT_ADMIN_ROLE)
    {
        stakingToken.transfer(to, amount);
    }

    function withdrawFromRewardToken(address to, uint256 amount) public onlyRole(DEFAULT_ADMIN_ROLE)
    {
        rewardToken.transfer(to, amount);
    }

    function updateRewardTokenAddress(address rewardToken_) public onlyRole(DEFAULT_ADMIN_ROLE)
    {
        rewardToken  = IERC20(rewardToken_);
    }

    uint256[100] private __gap;
}