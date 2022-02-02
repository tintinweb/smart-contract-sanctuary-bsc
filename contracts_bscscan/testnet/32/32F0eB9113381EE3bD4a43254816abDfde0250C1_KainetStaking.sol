/**
 *Submitted for verification at BscScan.com on 2022-02-01
*/

// SPDX-License-Identifier: MIT

// https://bscscan.com/address/0x38afe11cee9db78ed1934f33eb6c4975438f3719#code

pragma solidity ^0.8.11;

interface IERC20 {

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

}

abstract contract Declaration {

    uint40 constant ONE_DAY = 60 * 60 * 24;
    uint40 constant ONE_YEAR = ONE_DAY * 365;

    IERC20 public immutable KAINET;

    constructor(
        address _immutableKainet
    ) {
        KAINET = IERC20(_immutableKainet);
    }

}

/**
 * @dev Provides the msg.sender in the current execution context.
 */
abstract contract ContextSimple {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }   
}


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
abstract contract OwnableSafe is ContextSimple {
    address private _owner; 

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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


/**
 * @title ConfigurablePools
 * @author Aaron Hanson <[email protected]>
 */
abstract contract ConfigurablePools is OwnableSafe, Declaration {

    struct PoolInfo {
        uint40 lockDays;
        uint40 rewardRate;
        bool isFlexible;
        uint256 totalStaked;
        uint256 totalRewardsReserved;
    }

    uint256 public constant NUM_POOLS = 4;

    mapping(uint256 => PoolInfo) public pools;

    constructor() {
        pools[0] = PoolInfo(60, 15, true, 0, 0);
        pools[1] = PoolInfo(15, 35, false, 0, 0);
        pools[2] = PoolInfo(30, 50, false, 0, 0);
        pools[3] = PoolInfo(60, 75, false, 0, 0);
    }

    function editPoolTerms(
        uint256 _poolID,
        uint40 _newLockDays,
        uint40 _newRewardRate
    )
        external
        onlyOwner
    {
        require(
            _poolID < NUM_POOLS,
            "Invalid pool ID"
        );

        require(
            _newLockDays > 0,
            "Lock days cannot be zero"
        );

        require(
            _newRewardRate > 0,
            "Reward rate cannot be zero"
        );

        pools[_poolID].lockDays = _newLockDays;
        pools[_poolID].rewardRate = _newRewardRate;
    }

}

/**
 * @title RewardsVault
 * @author Aaron Hanson <[email protected]>
 */
abstract contract RewardsVault is ConfigurablePools {

    uint256 public vaultAvailableBalance;

    function donateToVault(
        uint256 _amount
    )
        external
    {
        vaultAvailableBalance += _amount;

        KAINET.transferFrom(
            _msgSender(),
            address(this),
            _amount
        );
    }

    function withdrawFromVault(
        uint256 _amount
    )
        external
        onlyOwner
    {
        vaultAvailableBalance -= _amount;

        KAINET.transfer(
            _msgSender(),
            _amount
        );
    }

}

/**
 * @title KainetStaking
 * @author Aaron Hanson <[email protected]>
 */
contract KainetStaking is RewardsVault {

    struct Stake {
        uint256 amount;
        bool isActive;
        uint40 poolID;
        uint40 rewardRate;
        uint40 startTimestamp;
        uint40 maturityTimestamp;
    }

    mapping(address => mapping(bytes16 => Stake)) public stakes;

    mapping(address => uint256) public stakeCount;

    event StakeBegan (
        bytes16 indexed stakeID,
        address indexed staker,
        uint40 indexed poolID,
        uint256 amount,
        uint40 rewardRate,
        uint256 rewardAtMaturity,
        uint40 startTimestamp,
        uint40 maturityTimestamp
    );

    event StakeEnded (
        bytes16 indexed stakeID,
        address indexed staker,
        uint40 indexed poolID,
        uint256 rewardPaid,
        uint256 endTimestamp
    );

    constructor(
        address _immutableKainet
    )
        Declaration(_immutableKainet)
    {}

    function beginStake(
        uint40 _poolID,
        uint256 _amount
    )
        external
        returns (bytes16 stakeID)
    {
        require(
            _poolID < NUM_POOLS,
            "Invalid pool ID"
        );

        require(
            _amount > 0,
            "Amount cannot be zero"
        );

        PoolInfo storage pool = pools[_poolID];

        uint256 maxReward = _calcStakeMaxReward(
            pool,
            _amount
        );

        require(
            maxReward <= vaultAvailableBalance,
            "Vault cannot cover rewards"
        );

        unchecked {
            vaultAvailableBalance -= maxReward;
        }

        pool.totalStaked += _amount;
        pool.totalRewardsReserved += maxReward;

        KAINET.transferFrom(
            _msgSender(),
            address(this),
            _amount
        );

        uint40 blockTimestamp = uint40(block.timestamp);
        uint40 maturityTimestamp = blockTimestamp + pool.lockDays * ONE_DAY;

        Stake memory stake = Stake(
            _amount,
            true,
            _poolID,
            pool.rewardRate,
            blockTimestamp,
            maturityTimestamp
        );

        stakeID = getStakeID(
            _msgSender(),
            stakeCount[_msgSender()]
        );

        stakes[_msgSender()][stakeID] = stake;
        stakeCount[_msgSender()] += 1;

        emit StakeBegan(
            stakeID,
            _msgSender(),
            _poolID,
            stake.amount,
            stake.rewardRate,
            maxReward,
            stake.startTimestamp,
            stake.maturityTimestamp
        );
    }

    function endStake(
        bytes16 _stakeID
    )
        external
    {
        Stake storage stake = stakes[_msgSender()][_stakeID];
        PoolInfo storage pool = pools[stake.poolID];

        require(
            stake.isActive == true,
            "Stake is inactive"
        );

        (
            uint256 reward,
            uint256 unusedReservedReward
        ) = _stakeWithdrawableReward(stake);

        stake.isActive = false;
        vaultAvailableBalance += unusedReservedReward;
        pool.totalRewardsReserved -= reward + unusedReservedReward;
        pool.totalStaked -= stake.amount;

        KAINET.transfer(
            _msgSender(),
            stake.amount + reward
        );

        emit StakeEnded(
            _stakeID,
            _msgSender(),
            stake.poolID,
            reward,
            block.timestamp
        );
    }

    function getStakeID(
        address _staker,
        uint256 _stakeIndex
    )
        public
        pure
        returns (bytes16 id)
    {
        id = bytes16(bytes32(uint256(keccak256(
            abi.encodePacked(_staker, _stakeIndex)
        ))));
    }

    function stakeInfo(
        address _staker,
        bytes16 _stakeID
    )
        external
        view
        returns (
            uint256 amount,
            uint40 lockDays,
            bool isActive,
            uint40 poolID,
            uint40 rewardRate,
            uint40 startTimestamp,
            uint40 maturityTimestamp,
            bool isMature,
            uint256 withdrawableReward,
            uint256 unusedReservedReward
        )
    {
        Stake memory stake = stakes[_staker][_stakeID];

        amount = stake.amount;
        lockDays = (stake.maturityTimestamp - stake.startTimestamp) / ONE_DAY;
        isActive = stake.isActive;
        poolID = stake.poolID;
        rewardRate = stake.rewardRate;
        startTimestamp = stake.startTimestamp;
        maturityTimestamp = stake.maturityTimestamp;
        isMature = block.timestamp >= stake.maturityTimestamp;
        (withdrawableReward, unusedReservedReward) = _stakeWithdrawableReward(
            stake
        );
    }

    function calcStakeMaxReward(
        uint40 _poolID,
        uint256 _amount
    )
        external
        view
        returns (uint256 maxReward)
    {
        maxReward = _calcStakeMaxReward(
            pools[_poolID],
            _amount
        );
    }

    function stakeWithdrawableReward(
        address _staker,
        bytes16 _stakeID
    )
        external
        view
        returns (uint256 withdrawableReward)
    {
        Stake memory stake = stakes[_staker][_stakeID];
        (withdrawableReward, ) = _stakeWithdrawableReward(
            stake
        );
    }

    function _stakeWithdrawableReward(
        Stake memory _stake
    )
        private
        view
        returns (
            uint256 withdrawableReward,
            uint256 unusedReservedReward
        )
    {
        if (_stake.isActive == true) {
            uint256 rewardAtMaturity = _calculateReward(
                _stake.amount,
                _stake.rewardRate,
                _stake.maturityTimestamp - _stake.startTimestamp
            );

            withdrawableReward = _calculateReward(
                _stake.amount,
                _stake.rewardRate,
                _stakeRewardableDuration(
                    _stake
                )
            );

            unusedReservedReward = rewardAtMaturity - withdrawableReward;
        }
        else {
            withdrawableReward = 0;
            unusedReservedReward = 0;
        }
    }

    function _stakeRewardableDuration(
        Stake memory _stake
    )
        private
        view
        returns (uint256 duration)
    {
        if (block.timestamp >= _stake.maturityTimestamp) {
            duration = _stake.maturityTimestamp - _stake.startTimestamp;
        }
        else {
            PoolInfo memory pool = pools[_stake.poolID];
            duration = pool.isFlexible == true
                ? block.timestamp - _stake.startTimestamp
                : 0;
        }
    }

    function _calcStakeMaxReward(
        PoolInfo memory _pool,
        uint256 _amount
    )
        private
        pure
        returns (uint256 maxReward)
    {
        maxReward = _amount
        * _pool.lockDays
        * _pool.rewardRate
        / 36500;
    }

    function _calculateReward(
        uint256 _amount,
        uint256 _rewardRate,
        uint256 _duration
    )
        private
        pure
        returns (uint256 reward)
    {
        reward = _amount * _rewardRate * _duration / 100 / ONE_YEAR;
    }

}