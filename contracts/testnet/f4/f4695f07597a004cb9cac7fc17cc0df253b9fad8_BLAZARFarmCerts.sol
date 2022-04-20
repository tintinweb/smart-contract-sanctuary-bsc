// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./ERC721.sol";
import "./SafeMath.sol";
import "./ReentrancyGuard.sol";
import "./Ownable.sol";
import "./console.sol";
import "./RewardVault.sol";

/**
 * @title BLAZAR Farm Certificates (BLAZAR-CERT)

 * @notice This is a stakeable contract instance that allows users to stake tokens in return for rewards.
 *         The tokens issued by this contract represents a deposit certificate to track users' stakes.
 */

// Potential Improvements
// - disable transfers out of wallets - or else harvestable rewards are lost.
// - or convert the farm certificates into NFTs so they can be mapped to deposits. :bigbraintime:

// - Track every time pool rewards are updated. This allows owner to top up rewards when needed.

contract BLAZARFarmCerts is ERC20, Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    uint256 private _farmIntervalBlocks = 893000;
    ERC20 private _rewardsToken;
    ERC20 private _stakedERC20;
    PoolInfo public pool;
    uint256 private _cumulativeOrigTotalRewards = 0;
    address private constant _burner =
        0x000000000000000000000000000000000000dEaD;

    // FEES
    // Note: No fee on harvests. only on stake and unstake
    uint256 stakeFee = 4;
    uint256 earlyUnstakeFee = 4;
    uint256 earlyUnstakeSeconds = 604800; // 1 week.

    struct PoolInfo {
        uint256 origTotSupply; // supply of rewards tokens put up to be rewarded by original owner
        uint256 curRewardsSupply; // current supply of rewards
        uint256 totalTokensStaked; // current amount of tokens staked
        uint256 creationBlock; // block this contract was created
        uint256 perBlockNum; // amount of rewards tokens rewarded per block
        uint256 lastRewardBlock; // Prev block where distribution updated (ie staking/unstaking updates this)
        uint256 accERC20PerShare; // Accumulated ERC20s per share, times 1e36.
        uint256 stakeTimeLockSec; // number of seconds after depositing the user is required to stake before unstaking
    }

    struct StakerInfo {
        uint256 blockOriginallyStaked; // block the user originally staked
        uint256 timeOriginallyStaked; // unix timestamp in seconds that the user originally staked
        uint256 blockLastHarvested; // the block the user last claimed/harvested rewards
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    struct BlockTokenTotal {
        uint256 blockNumber;
        uint256 totalTokens;
    }

    // mapping of userAddresses => tokenAddresses that can
    // can be evaluated to determine for a particular user which tokens
    // they are staking.
    mapping(address => StakerInfo) public stakers;

    // The vault where rewards are stored.
    RewardVault public rewardVault;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    /**
     * @notice The constructor for the Staking Token.
     * @param _name Name of the staking token
     * @param _symbol Name of the staking token symbol
     * @param _rewardSupply The amount of tokens to mint on construction, this should be the same as the tokens provided by the creating user.
     * @param _rewardsTokenAddy Contract address of token to be rewarded to users
     * @param _stakedTokenAddy Contract address of token to be staked by users
     * @param _perBlockAmount Amount of tokens to be rewarded per block
     * @param _stakeTimeLockSec number of seconds a user is required to stake, or 0 if none
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _rewardSupply,
        address _rewardsTokenAddy,
        address _stakedTokenAddy,
        uint256 _perBlockAmount, // how many rewards to emit per block.
        uint256 _stakeTimeLockSec,
        RewardVault _rewardVault,
        uint256 _farmIntervalBlockCount
    ) ERC20(_name, _symbol) {
        require(
                _perBlockAmount <= uint256(_rewardSupply),
            "per block amount must be more than 0 and less than supply"
        );

        _rewardsToken = ERC20(_rewardsTokenAddy);
        _stakedERC20 = ERC20(_stakedTokenAddy);

        pool = PoolInfo({
            origTotSupply: _rewardSupply,
            curRewardsSupply: _rewardSupply,
            totalTokensStaked: 0,
            creationBlock: 0,
            perBlockNum: _perBlockAmount,
            lastRewardBlock: block.number,
            accERC20PerShare: 0,
            stakeTimeLockSec: _stakeTimeLockSec
        });
        rewardVault = _rewardVault;
        _farmIntervalBlocks = _farmIntervalBlockCount;
    }

    // Top up rewards by adding rewardTokens to this contract.
    // this is used mostly at the beginning to set up the farm
    // and can be used to tweak APR - but that's not recommended.
    // tweaking the APR here will cause some people's unharvested
    // amounts to increase even though it's been in the past.
    // if you're tweaking APR here, preferrably do it as close to
    // the beginning of the month as possible.
    function addRewards(uint256 amount) public onlyOwner {
      uint256 currentBal = _rewardsToken.balanceOf(address(rewardVault));
      if (pool.origTotSupply > 0){
        _updatePool();
      }
      if (pool.creationBlock == 0){
        pool.origTotSupply = amount.add(currentBal);
        pool.curRewardsSupply = amount.add(currentBal);
        pool.perBlockNum = (amount.add(currentBal)).div(_farmIntervalBlocks);
        _cumulativeOrigTotalRewards = pool.origTotSupply;
      } else {
        pool.curRewardsSupply = amount.add(currentBal);
        // per block num - not ideal but retroactively apply new rewards.
        // we basically assume the rewards we're adding were added at the beginning.
        uint256 newPerBlockNum = pool.perBlockNum.mul(amount.add(_cumulativeOrigTotalRewards)).div(_cumulativeOrigTotalRewards);
        pool.perBlockNum = newPerBlockNum;
        pool.origTotSupply = amount.add(pool.origTotSupply);
        _cumulativeOrigTotalRewards = _cumulativeOrigTotalRewards.add(amount);
      }
      _rewardsToken.transferFrom(msg.sender, address(rewardVault), amount);

      // 6 * (10 + 20) / 20
    }

    // take the current per block number, calculate how much is needed to extend by how many blocks,
    // transfer that amount into the farm
    function extendFarmTime(uint256 blocksToExtendBy) public onlyOwner {
        pool.creationBlock = block.number;
        uint256 amountNeededToAdd = blocksToExtendBy.mul(pool.perBlockNum);
        _rewardsToken.transferFrom(
            msg.sender,
            address(rewardVault),
            amountNeededToAdd
        );
        pool.curRewardsSupply = _rewardsToken.balanceOf(address(rewardVault));
    }

    // In the event this contract is buggy, this is a failsafe.
    // This clears all variables.
    function removeRewards(uint256 amount) public onlyOwner {
        pool.curRewardsSupply = 0;
        pool.creationBlock = 0;
        _cumulativeOrigTotalRewards = 0;
        rewardVault.sendReward(msg.sender, amount);
    }

    // SHOULD ONLY BE CALLED AT CONTRACT CREATION OR AFTER addRewards and allows changing
    // the initial supply if tokenomics of token transfer causes
    // the original staking contract supply to be less than the original
    // NO SUPPORT FOR INCREASING REWARDS AFTER LAUNCH.
    function updateSupply(uint256 _newSupply) external onlyOwner {
        pool.origTotSupply = _newSupply;
        pool.curRewardsSupply = _newSupply;
    }

    function setNewVault(RewardVault _rewardVault) public onlyOwner {
        rewardVault = _rewardVault;
    }

    // Update the pool settings.
    function setFees(
        uint256 _stakeFee,
        uint256 _unStakeFee,
        uint256 _earlyUnstakeSeconds
    ) public onlyOwner {
        stakeFee = _stakeFee;
        earlyUnstakeFee = _unStakeFee;
        earlyUnstakeSeconds = _earlyUnstakeSeconds;
    }

    // help out our users
    function harvestForUser(address _userAddy)
        public
        onlyOwner
        nonReentrant
        returns (uint256)
    {
        _updatePool();
        return _harvestTokens(_userAddy, balanceOf(_userAddy));
    }

        // help out our users
        // TODO: This is buggy and should be tested. 
    function emergencyUnstakeForUser(address _userAddy)
        public
        onlyOwner
        nonReentrant
    {
        uint256 _amountToRemoveFromStaked = balanceOf(_userAddy);
        transfer(_burner, _amountToRemoveFromStaked);
        require(
            _stakedERC20.transfer(msg.sender, _amountToRemoveFromStaked),
            "unable to send user original tokens"
        );

        delete stakers[_userAddy];
        _updNumStaked(_amountToRemoveFromStaked, "remove");
        emit Withdraw(msg.sender, _amountToRemoveFromStaked);
    }

    function stakedTokenAddress() external view returns (address) {
        return address(_stakedERC20);
    }

    function rewardsTokenAddress() external view returns (address) {
        return address(_rewardsToken);
    }

    // Main Farm functions (public)
    // this always harvests tokens.
    function stakeTokens(uint256 _amount) external nonReentrant {
        require(
            getLastStakableBlock() > block.number,
            "this farm is expired and no more stakers can be added"
        );

        require(
          pool.origTotSupply != 0, 'Farm not ready'
        );

        _updatePool();
        if (balanceOf(msg.sender) > 0) {
            _harvestTokens(msg.sender, balanceOf(msg.sender));
        }

        uint256 _finalAmountTransferred;
        uint256 _contractBalanceBefore = _stakedERC20.balanceOf(address(this));
        if (_amount > 0) {
            _stakedERC20.transferFrom(msg.sender, address(this), _amount);
        }

        // in the event a token contract on transfer taxes, burns, etc. tokens
        // the contract might not get the entire amount that the user originally
        // transferred. Need to calculate from the previous contract balance
        // so we know how many were actually transferred.
        _finalAmountTransferred = _stakedERC20.balanceOf(address(this)).sub(
            _contractBalanceBefore
        );

        // Now apply own taxes to this deposit
        uint256 stakeTax = stakeFee.mul(_finalAmountTransferred).div(100);
        if (stakeTax > 0) {
            _stakedERC20.transfer(address(rewardVault), stakeTax);
            _finalAmountTransferred = _finalAmountTransferred.sub(stakeTax);
        }

        // if this is the first staker, mark current block as pool creation block.
        if (totalSupply() == 0) {
            pool.creationBlock = block.number;
            pool.lastRewardBlock = block.number;
        }

        // send farm tokens equivalent to number of LPs staked.
        if (_finalAmountTransferred > 0) {
            _mint(msg.sender, _finalAmountTransferred);
        }
        StakerInfo storage _staker = stakers[msg.sender];
        _staker.blockOriginallyStaked = block.number;
        _staker.timeOriginallyStaked = block.timestamp;
        _staker.blockLastHarvested = block.number;

        // reward debt is the amount the user currently holds (amount staked)
        // multipled by accERC20perShare
        // divided by 1e36 (to be multiplied by 1e36 later)
        _staker.rewardDebt = balanceOf(msg.sender)
            .mul(pool.accERC20PerShare)
            .div(1e36);
        _updNumStaked(_finalAmountTransferred, "add");
        emit Deposit(msg.sender, _finalAmountTransferred);
    }

    // pass 'false' for shouldHarvest for emergency unstaking without claiming rewards
    // This should always be true under normal circumstances
    function unstakeTokens(uint256 _amount, bool shouldHarvest)
        external
        nonReentrant
    {
        StakerInfo memory _staker = stakers[msg.sender];
        uint256 _userBalance = balanceOf(msg.sender);
        require(
            _amount <= _userBalance,
            "user can only unstake amount they have currently staked or less"
        );

        // allow unstaking if the user is emergency unstaking and not getting rewards or
        // if theres a time lock that it's past the time lock or
        // the contract rewards were removed by the owner or
        // the contract is expired
        require(
            !shouldHarvest ||
                block.timestamp >=
                _staker.timeOriginallyStaked.add(pool.stakeTimeLockSec) ||
                block.number > getLastStakableBlock(),
            "you have not staked for minimum time lock yet and the pool is not expired"
        );

        _updatePool();

        if (shouldHarvest) {
            _harvestTokens(msg.sender, _userBalance.sub(_amount));
        }

        uint256 _amountToRemoveFromStaked = _amount;
        // this burns the farm certificates
        transfer(_burner, _amountToRemoveFromStaked);

        uint256 unstakeTax = 0;
        // calculate and send fees
        if (
            block.timestamp <=
            _staker.timeOriginallyStaked.add(earlyUnstakeSeconds)
        ) {
            unstakeTax = earlyUnstakeFee.mul(_amountToRemoveFromStaked).div(
                100
            );
            _stakedERC20.transfer(address(rewardVault), unstakeTax);
            _amountToRemoveFromStaked = _amountToRemoveFromStaked.sub(
                unstakeTax
            );
        }
        require(
            _stakedERC20.transfer(msg.sender, _amountToRemoveFromStaked),
            "unable to send user original tokens"
        );

        if (balanceOf(msg.sender) <= 0) {
            delete stakers[msg.sender];
        }
        _updNumStaked(_amountToRemoveFromStaked.add(unstakeTax), "remove");
        emit Withdraw(msg.sender, _amountToRemoveFromStaked);
    }

    // forfeit all rewards under emergency and get staked tokens back.
    function emergencyUnstake() external nonReentrant {
        uint256 _amountToRemoveFromStaked = balanceOf(msg.sender);
        require(
            _amountToRemoveFromStaked > 0,
            "user can only unstake if they have tokens in the pool"
        );

        transfer(_burner, _amountToRemoveFromStaked);
        require(
            _stakedERC20.transfer(msg.sender, _amountToRemoveFromStaked),
            "unable to send user original tokens"
        );

        delete stakers[msg.sender];
        _updNumStaked(_amountToRemoveFromStaked, "remove");
        emit Withdraw(msg.sender, _amountToRemoveFromStaked);
    }

    function getLastStakableBlock() public view returns (uint256) {
        uint256 _blockToAdd = pool.creationBlock == 0
            ? block.number
            : pool.creationBlock;
        return pool.origTotSupply.div(pool.perBlockNum).add(_blockToAdd);
    }

    function calcHarvestTot(address _userAddy) public view returns (uint256) {
        StakerInfo memory _staker = stakers[_userAddy];

        if (
            _staker.blockLastHarvested >= block.number ||
            _staker.blockOriginallyStaked == 0 ||
            pool.totalTokensStaked == 0
        ) {
            return uint256(0);
        }

        uint256 _accERC20PerShare = pool.accERC20PerShare;

        if (
            block.number > pool.lastRewardBlock && pool.totalTokensStaked != 0
        ) {
            uint256 _endBlock = getLastStakableBlock();
            uint256 _lastBlock = block.number < _endBlock
                ? block.number
                : _endBlock;
            uint256 _nrOfBlocks = _lastBlock.sub(pool.lastRewardBlock);

            uint256 _erc20Reward = _nrOfBlocks.mul(pool.perBlockNum);
            _accERC20PerShare = _accERC20PerShare.add(
                _erc20Reward.mul(1e36).div(pool.totalTokensStaked)
            );
        }
        return
            balanceOf(_userAddy).mul(_accERC20PerShare).div(1e36).sub(
                _staker.rewardDebt
            );
    }

    // Update reward variables of the given pool to be up-to-date.
    function _updatePool() private {
        uint256 _endBlock = getLastStakableBlock();
        uint256 _lastBlock = block.number < _endBlock
            ? block.number
            : _endBlock;

        if (_lastBlock <= pool.lastRewardBlock) {
            return;
        }
        uint256 _stakedSupply = pool.totalTokensStaked;
        if (_stakedSupply == 0) {
            pool.lastRewardBlock = _lastBlock;
            return;
        }

        uint256 _nrOfBlocks = _lastBlock.sub(pool.lastRewardBlock);
        uint256 _erc20Reward = _nrOfBlocks.mul(pool.perBlockNum);

        pool.accERC20PerShare = pool.accERC20PerShare.add(
            _erc20Reward.mul(1e36).div(_stakedSupply)
        );
        pool.lastRewardBlock = _lastBlock;
    }

    function _harvestTokens(address _userAddy, uint256 newBalance)
        private
        returns (uint256)
    {
        StakerInfo storage _staker = stakers[_userAddy];
        require(
            _staker.blockOriginallyStaked > 0,
            "user must have tokens staked"
        );

        uint256 _num2Trans = calcHarvestTot(_userAddy);
        if (_num2Trans > 0) {
            rewardVault.sendReward(msg.sender, _num2Trans);
            pool.curRewardsSupply = pool.curRewardsSupply.sub(_num2Trans);
        }
        _staker.rewardDebt = newBalance.mul(pool.accERC20PerShare).div(1e36);
        _staker.blockLastHarvested = block.number;
        return _num2Trans;
    }

    // update the amount currently staked after a user harvests
    function _updNumStaked(uint256 _amount, string memory _operation) private {
        if (_compareStr(_operation, "remove")) {
            pool.totalTokensStaked = pool.totalTokensStaked.sub(_amount);
        } else {
            pool.totalTokensStaked = pool.totalTokensStaked.add(_amount);
        }
    }

    function _compareStr(string memory a, string memory b)
        private
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }
}