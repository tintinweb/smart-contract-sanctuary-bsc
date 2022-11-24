//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./SmartChef.sol";

/**
 * @notice MasterChef educates various SmartChef and lunch them :)
 * @dev MasterChef contract deploy sub smartchef contracts
 * Each smartchef contract is unique for each rewards token
 */
contract MasterChef is Ownable {
    /// Second Skin NFT Staking Contract
    address public nftstaking;
    /// Total count of deployed chef contracts
    uint256 public totalCount;
    /// counter index => deployed chef address
    mapping(uint256 => address) public chefAddress;
    /// deployed chef address => counter index
    mapping(address => uint256) private _subchefIndexs;

    /// @dev Even whenever MasterChef deploy new smartchef
    /// @param id: Data ID from off-chain database to just identify
    event NewSmartChefContract(
        string id,
        address indexed smartChef,
        address indexed stakedToken,
        string rewardToken,
        bool rewardByAirdrop
    );

    /// @notice Check if target address is zero address
    modifier _realAddress(address addr) {
        require(addr != address(0x0), "Cannot be zero address");
        _;
    }

    /// @dev Constructore
    /// @param _nftstaking: NFTStaking contract address
    constructor(address _nftstaking) _realAddress(_nftstaking) {
        nftstaking = _nftstaking;
    }

    /**
     * @notice set/update NFTStaking contract
     * @param _nftstaking: NFTStaking contract address
     */
    function setNFTStaking(address _nftstaking)
        external
        _realAddress(_nftstaking)
        onlyOwner
    {
        nftstaking = _nftstaking;
    }

    /**
     * @dev deploy the new SmartChef contract
     * @param _id: Data ID from off-chain database to just identify
     * @param _reward: Reward token address. This can be used in case
     * Reward token is coming from other chains. Just notify address to users.
     * @param _stakedToken: staked token address
     * @param _rewardToken: reward token address
     * @param _rewardPerBlock: reward per block (in rewardToken)
     * @param _startBlock: start block
     * @param _bonusEndBlock: end block
     * @param _rewardByAirdrop: If reward token is coming from other chains
     * @param _boosterController: BoosterController contract address
     * In this case, reward token would be airdropped
     */
    function deploy(
        string memory _id,
        string memory _reward,
        IERC20Metadata _stakedToken,
        IERC20Metadata _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock,
        bool _rewardByAirdrop,
        address _boosterController
    ) external onlyOwner {
        require(_stakedToken.totalSupply() >= 0, "Invalid token");

        if (!_rewardByAirdrop) {
            require(_rewardToken.totalSupply() >= 0, "Invalid token");
        } else {
            bytes memory rewardStringBytes = bytes(_reward); // Uses memory

            require(rewardStringBytes.length > 0, "Cannot be zero address");
        }

        bytes memory bytecode = type(SmartChef).creationCode;
        // pass constructor argument
        bytecode = abi.encodePacked(
            bytecode,
            abi.encode(_stakedToken, _rewardToken, _reward, _rewardByAirdrop)
        );
        bytes32 salt = keccak256(abi.encodePacked());

        address smartChefAddress;

        assembly {
            smartChefAddress := create2(
                0,
                add(bytecode, 32),
                mload(bytecode),
                salt
            )
        }

        SmartChef(smartChefAddress).initialize(
            _stakedToken,
            _rewardToken,
            _reward,
            _rewardPerBlock,
            _startBlock,
            _bonusEndBlock,
            msg.sender,
            nftstaking,
            _rewardByAirdrop,
            _boosterController
        );

        // register address
        totalCount = totalCount + 1;
        chefAddress[totalCount] = smartChefAddress;
        _subchefIndexs[smartChefAddress] = totalCount;

        // emit event
        emit NewSmartChefContract(
            _id,
            smartChefAddress,
            address(_stakedToken),
            _reward,
            _rewardByAirdrop
        );
    }

    /**
     * @notice get all smartchef contract's address
     */
    function getAllChefAddress() external view returns (address[] memory) {
        address[] memory subchefAddress = new address[](totalCount);

        // Index starts from 1 but not 0
        for (uint256 i = 1; i <= totalCount; i++) {
            subchefAddress[i - 1] = chefAddress[i];
        }
        return subchefAddress;
    }
}

//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

// Openzeppelin libraries
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "./interfaces/INFTStaking.sol";
import "./interfaces/IBoosterController.sol";

/**
 * @dev Stake TAVA token with locked staking option
 * and distribute third-party token
 */
contract SmartChef is Ownable, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20Metadata;

    /**
     *  @dev Structs to store user staking data.
     */
    struct UserInfo {
        uint256 lockedAmount; // locked amount
        uint256 lockStartTime; // locked at.
        uint256 lockEndTime; // unlock at
        bool locked; //lock status.
        uint256 rewards; // rewards
        uint256 rewardDebt; // rewards debt
    }

    // The address of the smart chef factory
    address public immutable masterSmartChefFactory;
    // Booster controller
    IBoosterController public boosterController;

    // stakedToken
    IERC20Metadata public stakedToken;
    // rewardToken
    IERC20Metadata public rewardToken;
    // reward token from another network
    string public reward;
    // Second Skin NFT Staking Contract
    INFTStaking public nftstaking;

    // Info of each user that stakes tokens (stakedToken)
    mapping(address => UserInfo) public userInfo;

    /// @notice Reward token should be airdrop or not
    /// Since reward token is coming from several networks
    /// reward token might be airdropped
    /// If reward token is coming from ethereum network,
    /// Users can claim from our contract directly
    bool public rewardByAirdrop = true;

    // The precision factor
    uint256 public precisionFactor;
    // Whether it is initialized
    bool public isInitialized;
    // Accrued token per share
    uint256 public accTokenPerShare;
    // The block number when third-party rewardToken mining ends.
    uint256 public bonusEndBlock;
    // The block number when third-party rewardToken mining starts.
    uint256 public startBlock;
    // The block number of the last pool update
    uint256 public lastRewardBlock;
    // third-party rewardToken created per block.
    uint256 public rewardPerBlock;

    // Booster denominator
    uint256 public constant DENOMINATOR = 10000 * 365 days; // 100% * 365 days
    // Limit lock period on min-max level
    uint256 public constant MIN_LOCK_DURATION = 1 weeks;
    uint256 public constant MAX_LOCK_DURATION = 1000 days;
    // Min deposit able amount
    uint256 public constant MIN_DEPOSIT_AMOUNT = 0.00001 ether;

    event NewRewardPerBlock(uint256 rewardPerBlock);
    event NewStartAndEndBlocks(uint256 startBlock, uint256 endBlock);

    /// @notice whenever user lock or extend period, emit
    /// @param smartchef: smartchef contract address
    /// @param sender: staker/user wallet address
    /// @param lockedAmount: locked amount
    /// @param lockStartTime: locked at
    /// @param lockEndTime: unlock at
    /// @param rewards: reward amount
    /// @param rewardDebt: reward debt
    event Stake(
        address smartchef,
        address indexed sender,
        uint256 lockedAmount,
        uint256 lockStartTime,
        uint256 lockEndTime,
        uint256 rewards,
        uint256 rewardDebt
    );

    /// @notice whenever user lock or extend period, emit
    /// @param smartchef: smartchef contract address
    /// @param sender: staker/user wallet address
    /// @param rewards: locked amount
    /// @param boosterValue: boosted apr
    /// @param airdropWalletAddress: airdrop wallet address
    event Unstaked(
        address smartchef,
        address indexed sender,
        uint256 rewards,
        uint256 boosterValue,
        string airdropWalletAddress
    );

    /// @notice contructor
    /// Here, msg.sender is MasterChef contract address
    /// since MasterChef deploy this contract
    constructor() {
        masterSmartChefFactory = msg.sender;
    }

    /**
     * @notice Initialize the contract
     * @param _stakedToken: staked token address
     * @param _rewardToken: reward token address
     * @param _reward: Reward token address. This can be used in case
     * @param _rewardPerBlock: reward per block (in rewardToken)
     * @param _startBlock: start block
     * @param _bonusEndBlock: end block
     * @param _rewardByAirdrop: If reward token is coming from other chains
     * In this case, reward token would be airdropped
     */
    function initialize(
        IERC20Metadata _stakedToken,
        IERC20Metadata _rewardToken,
        string memory _reward,
        uint256 _rewardPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock,
        address _newOwner,
        address _nftstaking,
        bool _rewardByAirdrop,
        address _boosterController
    ) external {
        require(!isInitialized, "Already initialized");
        require(msg.sender == masterSmartChefFactory, "Not factory");
        require(_boosterController != address(0x0), "Cannot be zero address");

        boosterController = IBoosterController(_boosterController);
        // Make this contract initialized
        isInitialized = true;

        stakedToken = _stakedToken;
        rewardPerBlock = _rewardPerBlock;
        startBlock = _startBlock;
        bonusEndBlock = _bonusEndBlock;
        rewardByAirdrop = _rewardByAirdrop;

        // If reward token is claimable
        if (!_rewardByAirdrop) {
            rewardToken = _rewardToken;
            uint256 decimalsRewardToken = uint256(rewardToken.decimals());
            require(decimalsRewardToken < 30, "Must be less than 30");
            precisionFactor = uint256(10**(uint256(30) - decimalsRewardToken));
        } else {
            precisionFactor = uint256(10**(uint256(30) - 18));
        }
        reward = _reward;

        // Set the lastRewardBlock as the startBlock
        lastRewardBlock = startBlock;
        // nft staking
        nftstaking = INFTStaking(_nftstaking);

        // Transfer ownership to the admin address who becomes owner of the contract
        transferOwnership(_newOwner);
    }

    /**
     * @notice set/update BoosterController address
     */
    function setBoosterController(address _boosterController)
        external
        onlyOwner
    {
        require(_boosterController != address(0x0), "Cannot be zero address");
        boosterController = IBoosterController(_boosterController);
    }

    /**
     * @notice Pause staking
     */
    function setPause(bool _isPaused) external onlyOwner {
        if (_isPaused) _pause();
        else _unpause();
    }

    /*
     * @notice Update reward per block
     * @dev Only callable by owner.
     * @param _rewardPerBlock: the reward per block
     */
    function updateRewardPerBlock(uint256 _rewardPerBlock) external onlyOwner {
        require(block.number < startBlock, "Pool has started");
        rewardPerBlock = _rewardPerBlock;
        emit NewRewardPerBlock(_rewardPerBlock);
    }

    /**
     * @notice It allows the admin to update start and end blocks
     * @dev This function is only callable by owner.
     * @param _startBlock: the new start block
     * @param _bonusEndBlock: the new end block
     */
    function updateStartAndEndBlocks(
        uint256 _startBlock,
        uint256 _bonusEndBlock
    ) external onlyOwner {
        require(block.number < startBlock, "Pool has started");
        require(_startBlock < _bonusEndBlock, "startBlock too higher");
        require(block.number < _startBlock, "startBlock too lower");

        startBlock = _startBlock;
        bonusEndBlock = _bonusEndBlock;

        // Set the lastRewardBlock as the startBlock
        lastRewardBlock = startBlock;

        emit NewStartAndEndBlocks(_startBlock, _bonusEndBlock);
    }

    /**
     * @notice Stake TAVA token to get rewarded with third-party nft.
     * @param _amount: amount to lock
     * @param _lockDuration: duration to lock
     */
    function stake(uint256 _amount, uint256 _lockDuration)
        external
        nonReentrant
        whenNotPaused
        returns (bool)
    {
        require(_amount > 0 || _lockDuration > 0, "Nothing to deposit");
        return (_stake(_amount, _lockDuration, msg.sender));
    }

    /**
     * @notice Unlock staked tokens (Unlock)
     * @dev user side withdraw manually
     * @param airdropWalletAddress: some reward tokens are from other chains
     * so users cannot claim reward directly
     * To get reward tokens, they need to provide airdrop address
     */
    function unlock(string memory airdropWalletAddress)
        external
        nonReentrant
        returns (bool)
    {
        if (rewardByAirdrop) {
            bytes memory stringBytes = bytes(airdropWalletAddress); // Uses memory

            require(stringBytes.length > 0, "Cannot be zero address");
        }

        address _user = msg.sender;
        UserInfo storage user = userInfo[_user];
        uint256 _amount = user.lockedAmount;
        // set zero
        user.lockedAmount = 0;

        require(_amount > 0, "Empty to unlock");
        require(user.locked, "Already unlocked");
        require(user.lockEndTime < block.timestamp, "Still in locked");

        _updatePool();

        uint256 pending = (_amount * accTokenPerShare) /
            precisionFactor -
            user.rewardDebt;
        if (pending > 0) {
            user.rewards = user.rewards + pending;
        }

        // set zero
        user.locked = false;
        user.rewardDebt = 0;

        // unlock staked token
        stakedToken.safeTransfer(address(_user), _amount);
        uint256 lockDuration = user.lockEndTime - user.lockStartTime;

        uint256 boostedAPR = getStakerBoosterValue(_user);
        require(nftstaking.unstakeFromSmartChef(_user), "Unstake failed");
        uint256 rewardAmount = user.rewards +
            (user.rewards * boostedAPR) /
            (DENOMINATOR * lockDuration);

        user.rewards = 0;

        // Here, should be check pool balance as well as
        // For aidrop token, it would be done by admin automatically
        if (!rewardByAirdrop && rewardAmount > 0) {
            require(
                rewardToken.balanceOf(address(this)) >= rewardAmount,
                "Insufficient pool"
            );

            rewardToken.safeTransfer(address(_user), rewardAmount);
        }

        emit Unstaked(
            address(this),
            _user,
            rewardAmount,
            boostedAPR,
            airdropWalletAddress
        );

        return true;
    }

    /*
     * @notice Stop rewards
     * @dev Only callable by owner. Needs to be for emergency.
     */
    function emergencyRewardWithdraw(uint256 _amount) external onlyOwner {
        require(rewardToken != stakedToken, "Not able to withdraw");
        rewardToken.safeTransfer(address(msg.sender), _amount);
    }

    /**
     * @notice get booster APR of sender wallet.
     * @dev this value need to be divided by (365 days in second) booster denominator
     * and user's locked duration
     */
    function getStakerBoosterValue(address sender)
        public
        view
        returns (uint256)
    {
        (uint256[] memory lockTs, uint256[] memory amounts) = nftstaking
            .getSmartChefBoostData(sender, address(this));
        UserInfo memory user = userInfo[sender];

        uint256 len = lockTs.length;

        uint256 totalAPR = 0;
        for (uint256 i = 0; i < len; i++) {
            uint256 lockTs1 = lockTs[i];
            uint256 lockTs2 = 0;
            if (i < len - 1) {
                lockTs2 = lockTs[i + 1];
            } else lockTs2 = user.lockEndTime;

            totalAPR += _getBoostAPR(
                user.lockEndTime,
                lockTs1,
                lockTs2,
                amounts[i]
            );
        }

        return totalAPR;
    }

    /**
     * @notice Update reward variables of the given pool to be up-to-date.
     * @dev update accTokenPerShare
     */
    function _updatePool() internal {
        if (block.number <= lastRewardBlock) {
            return;
        }
        uint256 stakedTokenSupply = stakedToken.balanceOf(address(this));

        if (stakedTokenSupply == 0) {
            lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);
        uint256 tavaReward = multiplier * rewardPerBlock;
        accTokenPerShare =
            accTokenPerShare +
            (tavaReward * precisionFactor) /
            stakedTokenSupply;
        lastRewardBlock = block.number;
    }

    /**
     * @notice process staking
     */
    function _stake(
        uint256 _amount,
        uint256 _lockDuration,
        address _user
    ) internal returns (bool) {
        UserInfo storage user = userInfo[_user];
        uint256 currentLockedAmount = _amount;
        // which means extend days
        if (user.lockEndTime >= block.timestamp) {
            require(_amount == 0, "Extend lock duration");
            require(
                _lockDuration > user.lockEndTime - user.lockStartTime,
                "Not enough duration to extends"
            );
            currentLockedAmount = user.lockedAmount;
        } else {
            // when user deposit newly
            require(!user.locked, "Unlock previous one");
            user.lockStartTime = block.timestamp;
        }

        require(
            _lockDuration >= MIN_LOCK_DURATION,
            "Minimum lock period is one week"
        );
        require(
            _lockDuration <= MAX_LOCK_DURATION,
            "Maximum lock period exceeded"
        );

        // Only notify at first time but not for extends
        if (_amount > 0) {
            // Notify TAVA staking to nftstaking contract
            require(nftstaking.stakeFromSmartChef(_user), "NFTStaking failed");
        }

        _updatePool();

        if (user.lockedAmount > 0) {
            uint256 pending = (user.lockedAmount * accTokenPerShare) /
                precisionFactor -
                user.rewardDebt;
            if (pending > 0) {
                user.rewards = user.rewards + pending;
            }
        }

        if (_amount > 0) {
            user.lockedAmount = user.lockedAmount + _amount;
            stakedToken.safeTransferFrom(
                address(_user),
                address(this),
                _amount
            );
        }

        user.rewardDebt =
            (user.lockedAmount * accTokenPerShare) /
            precisionFactor;
        user.lockEndTime = user.lockStartTime + _lockDuration;
        user.locked = true;

        emit Stake(
            address(this),
            _user,
            _amount,
            user.lockStartTime,
            user.lockEndTime,
            user.rewards,
            user.rewardDebt
        );
        return true;
    }

    /**
     * @notice Return reward multiplier over the given _from to _to block.
     * @param _from: block to start
     * @param _to: block to finish
     */
    function _getMultiplier(uint256 _from, uint256 _to)
        internal
        view
        returns (uint256)
    {
        if (_to <= bonusEndBlock) {
            return _to - _from;
        } else if (_from >= bonusEndBlock) {
            return 0;
        } else {
            return bonusEndBlock - _from;
        }
    }

    /**
     * @notice calculate APR based on how many secondskin NFT staked
     * when they are staked, how long they has been staked for smartchef pool
     */
    function _getBoostAPR(
        uint256 unlockTs,
        uint256 lockTs1,
        uint256 lockTs2,
        uint256 amount
    ) private view returns (uint256) {
        uint256 boostAPR = boosterController.getBoosterAPR(
            amount,
            address(this)
        );

        uint256 lockDuration = 0;
        if (unlockTs > lockTs2) {
            lockDuration = lockTs2 - lockTs1;
        } else if (unlockTs < lockTs1) {
            lockDuration = 0;
        } else {
            lockDuration = unlockTs - lockTs1;
        }

        return (lockDuration * boostAPR);
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

interface IBoosterController {
    /**
     * @dev get Booster APR
     */
    function getBoosterAPR(uint256 _key, address _smartchef)
        external
        view
        returns (uint256);
}

//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

interface INFTStaking {
    /**
     * @notice when Stake TAVA or Extend locked period in SmartChef contract
     * need to start tracking staked secondskin NFT token IDs for booster
     */
    function stakeFromSmartChef(address sender) external returns (bool);

    /**
     * @notice when unstake TAVA in SmartChef contract
     * need to free space in nft staking contract
     */
    function unstakeFromSmartChef(address sender) external returns (bool);

    /**
     * @notice when Stake TAVA or Extend locked period in NFTChef contract
     * need to start tracking staked secondskin NFT token IDs for booster
     * @param sender: user address
     */
    function stakeFromNFTChef(address sender) external returns (bool);

    /**
     * @notice when unstake TAVA in NFTChef contract
     * need to free space in nft staking contract
     */
    function unstakeFromNFTChef(address sender) external returns (bool);

    /**
     * @notice get registered token IDs
     * @param sender: target address
     */
    function getStakedTokenIds(address sender)
        external
        view
        returns (uint256[] memory result);

    /**
     * @notice get registered token IDs for smartchef
     * @param sender: target address
     * @param smartchef: smartchef address
     * return timestamp array, registered count array at that ts
     */
    function getSmartChefBoostData(address sender, address smartchef)
        external
        view
        returns (uint256[] memory, uint256[] memory);

    /**
     * @notice get registered token IDs for nftchef
     * @param sender: target address
     * @param nftchef: nftchef address
     */
    function getNFTChefBoostCount(address sender, address nftchef)
        external
        view
        returns (uint256);

    /**
     * @notice Get registered amount by sender
     * @param sender: target address
     */
    function getStakedNFTCount(address sender)
        external
        view
        returns (uint256 amount);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/extensions/IERC20Metadata.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}