// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "./StakingLibV2.sol";
import "./AddressesLib.sol";
import "./Error.sol";

contract StakingProxyV2 is AccessControlEnumerable, ReentrancyGuardUpgradeable {
    using AddressesLib for address[];

    StakePool[] private _pools;

    uint256 public constant daysOfYear = 365;

    // poolId => user => stake info
    mapping(uint256 => mapping(address => StakeInfo)) private _stakeInfo;

    // amount token holders staked: token address => amount
    mapping(address => uint256) private _stakedAmounts;
    // amount rewards to paid holders: reward address => amount
    mapping(address => uint256) private _rewardAmounts;

    // history stake index by user: poolId => user => index
    mapping(uint256 => mapping(address => uint256)) private _stakeHistoryIndex;
    // history stake by user: user => histories
    mapping(address => StakeInfo[]) private _stakeHistories;

    // list token locked
    address[] private _lockedAddresses;
    // total token locked amount
    mapping(address => uint256) private _lockedAmounts;

    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), Error.ADMIN_ROLE_REQUIRED);
        _;
    }

    event NewPool(uint256 poolId);
    event ClosePool(uint256 poolId);
    event Staked(address user, uint256 poolId, uint256 amount);
    event UnStaked(address user, uint256 poolId);
    event Withdrawn(address user, uint256 poolId, uint256 amount, uint256 reward);

    function initialize(address _multiSigAccount) public initializer {
        renounceRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(DEFAULT_ADMIN_ROLE, _multiSigAccount);
    }

    function createPool(
        uint256 _startTime,
        uint256 _endTime,
        address _stakeAddress,
        address _rewardAddress,
        uint256 _minTokenStake,
        uint256 _maxTokenStake,
        uint256 _maxPoolStake,
        uint256 _duration,
        uint256 _redemptionPeriod,
        uint256 _apr,
        bool _allowUnStake
    ) external nonReentrant onlyAdmin {
        require(_startTime >= block.timestamp, Error.START_TIME_MUST_IN_FUTURE_DATE);
        require(_duration != 0, Error.DURATION_MUST_NOT_EQUAL_ZERO);
        require(_minTokenStake > 0, Error.MIN_TOKEN_STAKE_MUST_GREATER_ZERO);
        require(_maxTokenStake >= _minTokenStake, Error.MAX_TOKEN_STAKE_MUST_GREATER_MIN_TOKEN_STAKE);
        require(_maxPoolStake > 0, Error.MAX_POOL_STAKE_MUST_GREATER_ZERO);

        uint256 totalReward = (_maxPoolStake * _duration * _apr) / (daysOfYear * 1 ether);

        require(
            IERC20(_rewardAddress).transferFrom(_msgSender(), address(this), totalReward),
            Error.TRANSFER_REWARD_FAILED
        );

        StakePool memory pool = StakePool(
            _pools.length,
            _startTime,
            _endTime,
            true,
            _stakeAddress,
            _rewardAddress,
            _minTokenStake,
            _maxTokenStake,
            _maxPoolStake,
            0,
            _duration,
            _redemptionPeriod,
            _apr,
            _allowUnStake
        );

        _pools.push(pool);

        _lockedAddresses.add(_stakeAddress);

        emit NewPool(pool.id);
    }

    function closePool(uint256 _poolId) external nonReentrant onlyAdmin {
        require(_poolId < _pools.length, Error.POOL_NOT_FOUND);

        _pools[_poolId].isActive = false;

        emit ClosePool(_poolId);
    }

    function getDetailPool(uint256 _poolId) external view returns (StakePool memory) {
        require(_poolId < _pools.length, Error.POOL_NOT_FOUND);

        return _pools[_poolId];
    }

    function getAllPools() external view returns (StakePool[] memory) {
        return _pools;
    }

    /**
        @dev count pools is active and staked amount less than max pool token
     */
    function _getCountActivePools() internal view returns (uint256 count) {
        count = 0;
        for (uint256 i = 0; i < _pools.length; i++) {
            if (
                _pools[i].isActive &&
                _pools[i].totalStaked < _pools[i].maxPoolStake &&
                _pools[i].endTime > block.timestamp
            ) {
                count++;
            }
        }
    }

    function getCountActivePools() external view returns (uint256) {
        return _getCountActivePools();
    }

    function _getActivePools() internal view returns (StakePool[] memory activePools) {
        activePools = new StakePool[](_getCountActivePools());
        uint256 count = 0;

        for (uint256 i = 0; i < _pools.length; i++) {
            if (
                _pools[i].isActive &&
                _pools[i].totalStaked < _pools[i].maxPoolStake &&
                _pools[i].endTime > block.timestamp
            ) {
                activePools[count++] = _pools[i];
            }
        }
    }

    /**
        @dev list pools is active an staked amount less than max pool token
     */
    function getActivePools() external view returns (StakePool[] memory) {
        return _getActivePools();
    }

    /** 
        @dev value date start 07:00 UTC next day
     */
    function stake(uint256 _poolId, uint256 _amount) external nonReentrant {
        require(_poolId < _pools.length, Error.POOL_NOT_FOUND);

        StakePool memory pool = _pools[_poolId];
        StakeInfo memory stakeInfo = _stakeInfo[_poolId][_msgSender()];

        require(stakeInfo.amount == 0 || stakeInfo.withdrawTime > 0, Error.DUPLICATE_STAKE);

        require(pool.isActive && pool.endTime > block.timestamp, Error.POOL_CLOSED);
        require(_amount > 0, Error.AMOUNT_MUST_GREATER_ZERO);
        require(pool.startTime <= block.timestamp, Error.IT_NOT_TIME_STAKE_YET);
        require(pool.minTokenStake <= _amount, Error.AMOUNT_MUST_GREATER_OR_EQUAL_MIN_TOKEN_STAKE);
        require(pool.maxTokenStake >= _amount, Error.AMOUNT_MUST_LESS_OR_EQUAL_MAX_TOKEN_STAKE);
        require(pool.totalStaked + _amount <= pool.maxPoolStake, Error.OVER_MAX_POOL_STAKE);

        require(
            IERC20(pool.stakeAddress).transferFrom(_msgSender(), address(this), _amount),
            Error.TRANSFER_TOKEN_FAILED
        );

        uint256 reward = (_amount * pool.duration * pool.apr) / (daysOfYear * 1 ether);

        // 07:00 UTC next day
        uint256 valueDate = (block.timestamp / 1 days) * 1 days + 1 days + 7 hours;

        stakeInfo = StakeInfo(_poolId, block.timestamp, valueDate, _amount, 0);

        _pools[_poolId].totalStaked += _amount;
        _stakeInfo[_poolId][_msgSender()] = stakeInfo;

        _stakeHistoryIndex[_poolId][_msgSender()] = _stakeHistories[_msgSender()].length;
        _stakeHistories[_msgSender()].push(stakeInfo);

        _stakedAmounts[pool.stakeAddress] += _amount;
        _rewardAmounts[pool.rewardAddress] += reward;

        _lockedAmounts[pool.stakeAddress] += _amount;

        emit Staked(_msgSender(), _poolId, _amount);
    }

    /**
        @dev stake info in pool by user
     */
    function getStakeInfo(uint256 _poolId, address _user) external view returns (StakeInfo memory) {
        return _stakeInfo[_poolId][_user];
    }

    function getStakeHistories(address _user) external view returns (StakeInfo[] memory) {
        return _stakeHistories[_user];
    }

    function _getCountStakeAvailable(address _user) internal view returns (uint256 count) {
        count = 0;
        for (uint256 i = 0; i < _stakeHistories[_user].length; i++) {
            if (_stakeHistories[_user][i].withdrawTime == 0) count++;
        }
    }

    function getStakeClaims(address _user) external view returns (RewardInfo[] memory stakeClaims) {
        stakeClaims = new RewardInfo[](_getCountStakeAvailable(_user));
        uint256 count = 0;

        for (uint256 i = 0; i < _stakeHistories[_user].length; i++) {
            if (_stakeHistories[_user][i].withdrawTime == 0) {
                StakeInfo memory stakeInfo = _stakeHistories[_user][i];
                StakePool memory pool = _pools[stakeInfo.poolId];

                uint256 rewardAmount = _getRewardClaimable(pool.id, _user);

                uint256 interestEndDate = stakeInfo.valueDate + pool.duration * 1 days;
                bool canClaim = interestEndDate + pool.redemptionPeriod * 1 days <= block.timestamp;

                stakeClaims[count++] = RewardInfo(
                    pool.id,
                    pool.stakeAddress,
                    pool.rewardAddress,
                    stakeInfo.amount,
                    rewardAmount,
                    canClaim
                );
            }
        }
    }

    function _getRewardClaimable(uint256 _poolId, address _user) internal view returns (uint256 rewardClaimable) {
        StakeInfo memory stakeInfo = _stakeInfo[_poolId][_user];
        StakePool memory pool = _pools[_poolId];

        if (stakeInfo.amount == 0 || stakeInfo.withdrawTime != 0) return 0;
        if (stakeInfo.valueDate > block.timestamp) return 0;

        uint256 lockedDays = (block.timestamp - stakeInfo.valueDate) / 1 days;

        if (lockedDays > pool.duration) lockedDays = pool.duration;

        rewardClaimable = (stakeInfo.amount * lockedDays * pool.apr) / (daysOfYear * 1 ether);
    }

    function getRewardClaimable(uint256 _poolId, address _user) external view returns (uint256) {
        require(_poolId < _pools.length, Error.POOL_NOT_FOUND);

        return _getRewardClaimable(_poolId, _user);
    }

    /** 
        @dev user withdraw token staked without reward
     */
    function unStake(uint256 _poolId) external nonReentrant {
        require(_poolId < _pools.length, Error.POOL_NOT_FOUND);

        StakeInfo memory stakeInfo = _stakeInfo[_poolId][_msgSender()];
        StakePool memory pool = _pools[_poolId];

        require(pool.allowUnStake, Error.POOL_NOT_ALLOW_UN_STAKE);
        require(stakeInfo.amount > 0, Error.NOTHING_TO_WITHDRAW);

        uint256 interestEndDate = stakeInfo.valueDate + pool.duration * 1 days;

        require(block.timestamp < interestEndDate, Error.CANNOT_UN_STAKE_WHEN_OVER_DURATION);

        uint256 rewardFullDuration = (stakeInfo.amount * pool.duration * pool.apr) / (daysOfYear * 1 ether);

        require(IERC20(pool.stakeAddress).transfer(_msgSender(), stakeInfo.amount), Error.TRANSFER_TOKEN_FAILED);

        _pools[_poolId].totalStaked -= stakeInfo.amount;

        _stakedAmounts[pool.stakeAddress] -= stakeInfo.amount;
        _rewardAmounts[pool.rewardAddress] -= rewardFullDuration;

        _stakeHistories[_msgSender()][_stakeHistoryIndex[_poolId][_msgSender()]].withdrawTime = block.timestamp;
        delete _stakeInfo[_poolId][_msgSender()];
        delete _stakeHistoryIndex[_poolId][_msgSender()];

        emit UnStaked(_msgSender(), _poolId);
    }

    /** 
        @dev user withdraw token & reward
     */
    function withdraw(uint256 _poolId) external nonReentrant {
        require(_poolId < _pools.length, Error.POOL_NOT_FOUND);

        StakeInfo memory stakeInfo = _stakeInfo[_poolId][_msgSender()];
        StakePool memory pool = _pools[_poolId];

        require(stakeInfo.amount > 0 && stakeInfo.withdrawTime == 0, Error.NOTHING_TO_WITHDRAW);

        uint256 interestEndDate = stakeInfo.valueDate + pool.duration * 1 days;

        require(
            interestEndDate + pool.redemptionPeriod * 1 days <= block.timestamp,
            Error.CANNOT_WITHDRAW_BEFORE_REDEMPTION_PERIOD
        );

        uint256 reward = _getRewardClaimable(_poolId, _msgSender());

        if (pool.stakeAddress == pool.rewardAddress) {
            require(
                IERC20(pool.rewardAddress).transfer(_msgSender(), stakeInfo.amount + reward),
                Error.TRANSFER_REWARD_FAILED
            );
        } else {
            require(IERC20(pool.rewardAddress).transfer(_msgSender(), reward), Error.TRANSFER_REWARD_FAILED);
            require(IERC20(pool.stakeAddress).transfer(_msgSender(), stakeInfo.amount), Error.TRANSFER_TOKEN_FAILED);
        }

        _stakedAmounts[pool.stakeAddress] -= stakeInfo.amount;
        _rewardAmounts[pool.rewardAddress] -= reward;

        _stakeHistories[_msgSender()][_stakeHistoryIndex[_poolId][_msgSender()]].withdrawTime = block.timestamp;
        delete _stakeInfo[_poolId][_msgSender()];
        delete _stakeHistoryIndex[_poolId][_msgSender()];

        emit Withdrawn(_msgSender(), _poolId, stakeInfo.amount, reward);
    }

    /**
        @dev all token in all pools holders staked
     */
    function getStakedAmount(address _tokenAddress) external view returns (uint256) {
        return _stakedAmounts[_tokenAddress];
    }

    /**
        @dev all rewards in all pools to paid holders
     */
    function getRewardAmount(address _tokenAddress) external view returns (uint256) {
        return _rewardAmounts[_tokenAddress];
    }

    function getTotalLocked() external view returns (LockedInfo[] memory lockedInfoList) {
        lockedInfoList = new LockedInfo[](_lockedAddresses.length);
        for (uint256 i = 0; i < _lockedAddresses.length; i++) {
            lockedInfoList[i] = LockedInfo(_lockedAddresses[i], _lockedAmounts[_lockedAddresses[i]]);
        }
    }

    /** 
        @dev admin withdraws excess token
     */
    function withdrawERC20(address _tokenAddress, uint256 _amount) external nonReentrant onlyAdmin {
        require(_amount != 0, Error.AMOUNT_MUST_GREATER_ZERO);

        bool canWithdraw = true;
        StakePool[] memory activePools = _getActivePools();
        for (uint256 i = 0; i < activePools.length; i++) {
            if (activePools[i].rewardAddress == _tokenAddress) {
                canWithdraw = false;
                break;
            }
        }
        require(canWithdraw, Error.TOKEN_USED_IN_ACTIVE_POOL);

        require(
            IERC20(_tokenAddress).balanceOf(address(this)) >=
                _stakedAmounts[_tokenAddress] + _rewardAmounts[_tokenAddress] + _amount,
            Error.NOT_ENOUGH_TOKEN
        );

        require(IERC20(_tokenAddress).transfer(_msgSender(), _amount), Error.TRANSFER_TOKEN_FAILED);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IAccessControlEnumerable.sol";
import "./AccessControl.sol";
import "../utils/structs/EnumerableSet.sol";

/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Overload {grantRole} to track enumerable memberships
     */
    function grantRole(bytes32 role, address account) public virtual override(AccessControl, IAccessControl) {
        super.grantRole(role, account);
        _roleMembers[role].add(account);
    }

    /**
     * @dev Overload {revokeRole} to track enumerable memberships
     */
    function revokeRole(bytes32 role, address account) public virtual override(AccessControl, IAccessControl) {
        super.revokeRole(role, account);
        _roleMembers[role].remove(account);
    }

    /**
     * @dev Overload {renounceRole} to track enumerable memberships
     */
    function renounceRole(bytes32 role, address account) public virtual override(AccessControl, IAccessControl) {
        super.renounceRole(role, account);
        _roleMembers[role].remove(account);
    }

    /**
     * @dev Overload {_setupRole} to track enumerable memberships
     */
    function _setupRole(bytes32 role, address account) internal virtual override {
        super._setupRole(role, account);
        _roleMembers[role].add(account);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2;

/**
    @dev represents one pool
    */
struct StakePool {
    uint256 id;
    uint256 startTime;
    uint256 endTime;
    bool isActive;
    address stakeAddress;
    address rewardAddress;
    uint256 minTokenStake; // minimum token user can stake
    uint256 maxTokenStake; // maximum total user can stake
    uint256 maxPoolStake; // maximum total token all user can stake
    uint256 totalStaked;
    uint256 duration; // days
    uint256 redemptionPeriod; // days
    uint256 apr;
    bool allowUnStake;
}

/**
    @dev represents one user stake in one pool
    */
struct StakeInfo {
    uint256 poolId;
    uint256 stakeTime;
    uint256 valueDate;
    uint256 amount;
    uint256 withdrawTime;
}

struct RewardInfo {
    uint256 poolId;
    address stakeAddress;
    address rewardAddress;
    uint256 amount;
    uint256 claimableReward;
    bool canClaim;
}

struct LockedInfo {
    address tokenAddress;
    uint256 amount;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2;

library AddressesLib {
    function add(address[] storage self, address element) internal {
        if (!exists(self, element)) self.push(element);
    }

    function exists(address[] storage self, address element) internal view returns (bool) {
        for (uint256 i = 0; i < self.length; i++) {
            if (self[i] == element) {
                return true;
            }
        }
        return false;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2;

library Error {
    string public constant ADMIN_ROLE_REQUIRED = "Error: ADMIN role required";

    string public constant POOL_NOT_FOUND = "Error: Pool not found";

    string public constant START_TIME_MUST_IN_FUTURE_DATE = "Error: Start time must be in future date";
    string public constant DURATION_MUST_NOT_EQUAL_ZERO = "Error: Duration must be not equal 0";
    string public constant MIN_TOKEN_STAKE_MUST_GREATER_ZERO = "Error: Min token stake must be greater than 0";
    string public constant MAX_TOKEN_STAKE_MUST_GREATER_MIN_TOKEN_STAKE =
        "Error: Max token stake must be greater than min token stake";
    string public constant MAX_POOL_STAKE_MUST_GREATER_ZERO = "Error: Max pool stake must be greater than 0";
    string public constant DENOMINATOR_APR_MUST_GREATER_ZERO = "Error: Denominator apr must be greater than 0";
    string public constant REWARD_PERCENT_MUST_IN_RANGE_BETWEEN_ONE_TO_HUNDRED =
        "Error: Reward percent must be in range [1, 100]";

    string public constant TRANSFER_REWARD_FAILED = "Error: Transfer reward token failed";
    string public constant TRANSFER_TOKEN_FAILED = "Error: Transfer token failed";

    string public constant DUPLICATE_STAKE = "Error: Duplicate stake";
    string public constant AMOUNT_MUST_GREATER_ZERO = "Error: Amount must be greater than 0";
    string public constant IT_NOT_TIME_STAKE_YET = "Error: It's not time to stake yet";
    string public constant POOL_CLOSED = "Error: Pool closed";
    string public constant POOL_IS_ACTIVE = "Error: Pool is active";
    string public constant AMOUNT_MUST_GREATER_OR_EQUAL_MIN_TOKEN_STAKE =
        "Error: Amount must be greater or equal min token stake";
    string public constant AMOUNT_MUST_LESS_OR_EQUAL_MAX_TOKEN_STAKE =
        "Error: Amount must be less or equal max token stake";
    string public constant OVER_MAX_POOL_STAKE = "Error: Over max pool stake";

    string public constant NOTHING_TO_WITHDRAW = "Error: Nothing to withdraw";
    string public constant NOT_ENOUGH_TOKEN = "Error: Not enough token";
    string public constant POOL_NOT_ALLOW_UN_STAKE = "Error: Pool not allow un stake";
    string public constant CANNOT_UN_STAKE_WHEN_OVER_DURATION = "Error: Cannot un stake when over duration";
    string public constant CANNOT_WITHDRAW_BEFORE_REDEMPTION_PERIOD = "Error: Cannot withdraw before redemption period";

    string public constant UPDATE_WITHDRAW_TIME_LAST_STAKE_FAILED = "Error: Update withdraw time last stake failed";

    string public constant TOKEN_USED_IN_ACTIVE_POOL = "Error: Token being used in an active pool";
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IAccessControl.sol";

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable is IAccessControl {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT

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

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}