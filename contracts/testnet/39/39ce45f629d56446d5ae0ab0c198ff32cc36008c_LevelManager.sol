// SPDX-License-Identifier: MIT
pragma solidity =0.8.4;

import "./Ownable.sol";
import "./IStakingLockable.sol";
import "./ILevelManager.sol";
import "./WithLevels.sol";
import "./WithPools.sol";
import "./Adminable.sol";

contract LevelManager is Adminable, ILevelManager, WithLevels, WithPools {
    bytes32 public constant ADDER_ROLE = keccak256("ADDER_ROLE");

    bool public lockEnabled = true;

    mapping(address => bool) isIDO;
    mapping(address => uint256) public userUnlocksAt;
    // Address to level idx. 0 idx makes it fetch the real level
    mapping(address => uint256) public forceLevel;
    address[] public forceLevelAddresses;

    event Lock(address indexed account, uint256 unlockTime, address locker);
    event LockEnabled(bool status);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(ADDER_ROLE, _msgSender());
    }

    modifier onlyIDO() {
        require(isIDO[_msgSender()], "Only IDOs can lock");
        _;
    }

    function isLocked(address account) external view override returns (bool) {
        return lockEnabled && userUnlocksAt[account] > block.timestamp;
    }

    function getUserTier(address account)
        public
        view
        override
        returns (Tier memory)
    {
        if (forceLevel[account] > 0) {
            return tiers[forceLevel[account]];
        }

        return getTierForAmount(getUserAmount(account));
    }

    function getUserUnlockTime(address account)
        external
        view
        override
        returns (uint256)
    {
        return userUnlocksAt[account];
    }

    function getUserAmount(address account) public view returns (uint256) {
        uint256 totalAmount = 0;

        for (uint256 i = 0; i < pools.length; i++) {
            IStakingLockableExternal pool = pools[i];
            address poolAddr = address(pool);
            uint256 multiplier = poolMultiplier[poolAddr];
            if (poolEnabled[poolAddr]) {
                try pool.getLockedAmount(account) returns (uint256 amount) {
                    totalAmount += (amount * multiplier) / DEFAULT_MULTIPLIER;
                    continue;
                } catch {}

                // for old staking contracts
                try pool.userInfo(account) returns (
                    IStakingLockableExternal.UserInfo memory userInfo
                ) {
                    totalAmount +=
                        (userInfo.amount * multiplier) /
                        DEFAULT_MULTIPLIER;
                    continue;
                } catch {}
            }
        }

        return totalAmount;
    }

    function toggleLocking(bool status) external onlyOwnerOrAdmin {
        lockEnabled = status;
        emit LockEnabled(status);
    }

    function addIDO(address account) external onlyRole(ADDER_ROLE) {
        require(account != address(0), "IDO cannot be zero address");
        isIDO[account] = true;
    }

    // Override the level id, set 0 to reset
    function setAccountLevel(address account, uint256 levelIdx)
        external
        onlyOwner
    {
        forceLevel[account] = levelIdx;
        address[] storage addrs = forceLevelAddresses;
        if (levelIdx > 0) {
            for (uint256 i = 0; i < addrs.length; i++) {
                if (addrs[i] == account) {
                    return;
                }
            }
            addrs.push(account);
        } else {
            // Delete address
            for (uint256 i = 0; i < addrs.length; i++) {
                if (addrs[i] == account) {
                    for (uint256 j = i; j < addrs.length - 1; j++) {
                        addrs[j] = addrs[j + 1];
                    }
                    addrs.pop();
                    break;
                }
            }
        }
    }

    function getAlwaysRegister()
        external
        view
        override
        returns (
            address[] memory,
            string[] memory,
            uint256[] memory
        )
    {
        uint256 length = forceLevelAddresses.length;
        address[] memory addresses = new address[](length);
        string[] memory tiersIds = new string[](length);
        uint256[] memory weights = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            address addr = forceLevelAddresses[i];
            uint256 levelIdx = forceLevel[addr];
            addresses[i] = addr;
            tiersIds[i] = tiers[levelIdx].id;
            weights[i] = tiers[levelIdx].multiplier;
        }
        return (addresses, tiersIds, weights);
    }

    function lock(address account, uint256 idoStart) external override onlyIDO {
        internalLock(account, idoStart);
    }

    function internalLock(address account, uint256 idoStart) internal {
        require(
            idoStart >= block.timestamp,
            "LevelManager: IDO start must be in future"
        );

        Tier memory tier = getUserTier(account);
        if (tier.lockingPeriod == 0) {
            return;
        }

        uint256 unlockTime = idoStart + tier.lockingPeriod;
        if (userUnlocksAt[account] < unlockTime) {
            userUnlocksAt[account] = unlockTime;
            emit Lock(account, unlockTime, _msgSender());

            // Support for old stakers
            for (uint256 i = 0; i < pools.length; i++) {
                IStakingLockableExternal pool = pools[i];
                address poolAddr = address(pool);
                if (poolEnabled[poolAddr]) {
                    try pool.lock(account) {} catch {}
                }
            }
        }
    }

    function unlock(address account) external onlyOwnerOrAdmin {
        userUnlocksAt[account] = block.timestamp;
    }

    function batchLock(address[] calldata addresses) external onlyOwnerOrAdmin {
        for (uint256 i = 0; i < addresses.length; i++) {
            internalLock(addresses[i], block.timestamp);
        }
    }

    function batchUnlock(address[] calldata addresses)
        external
        onlyOwnerOrAdmin
    {
        for (uint256 i = 0; i < addresses.length; i++) {
            userUnlocksAt[addresses[i]] = block.timestamp;
        }
    }
}