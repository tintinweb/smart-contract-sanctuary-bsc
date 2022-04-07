// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Context.sol";
import "./Ownable.sol";
import "./Pausable.sol";
import "./IBEP20.sol";
import "./Math.sol";

/**
 * Token Time Lock
 * @dev Allow owner send locked token to user
 * @author Brian Dhang
 */
contract TokenTimeLock is Pausable, Ownable {
    using Math for uint256;
    IBEP20 immutable _tokenContract;

    uint256 public lockedBalances;
    uint256 constant _tokenModulus = 10**8;
    // uint256 constant _secondsInDay = 86400;
    uint256 constant _secondsInDay = 5; // For Testnet

    struct Entity {
        address user;
        string lock_code;
        uint64 balance;
        uint64 unlocked;
        uint64 release_now_amount;
        uint64 lock_period_amount;
        uint32 start_release_period_date;
        uint16 keep_period;
        uint16 lock_period;
    }

    Entity[] public entities;

    mapping(uint256 => address) public entityToOwner;
    mapping(address => uint256) ownerEntitiesCount;
    mapping(string => bool) public lockCode;

    event LockToken(
        address indexed user,
        string lock_code,
        uint256 balance,
        uint256 release_now_amount,
        uint256 lock_period_amount,
        uint256 start_release_period_date,
        uint256 keep_period,
        uint256 lock_period,
        uint256 id,
        uint256 timestamp
    );
    event Release(
        address indexed user,
        string lock_code,
        uint256 amount,
        uint256 id,
        uint256 timestamp
    );

    /**
     * Constructor
     * @dev Set token address
     */
    constructor(address token) {
        _tokenContract = IBEP20(token);
    }

    /**
     * Pause
     * @dev Allow owner pause releasing token
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * Pause
     * @dev Allow owner unpause releasing token
     */
    function unpause() public onlyOwner {
        _unpause();
    }

    /**
     * Lock token
     * @dev Allow owner send locked token to user
     */
    function lockToken(
        address user,
        string memory lock_code,
        uint256 balance,
        uint256 release_now_amount,
        uint256 lock_period_amount,
        uint256 keep_period,
        uint256 lock_period
    ) external onlyOwner {
        require(
            _tokenContract.balanceOf(owner()) >= lockedBalances + balance,
            "Pool not have enough token"
        );

        // Lock token for contract
        lockedBalances += balance;

        uint256 timestamp = block.timestamp;
        uint256 start_release_period_date = timestamp +
            keep_period *
            _secondsInDay;

        // Lock token for user
        entities.push(
            Entity(
                user,
                lock_code,
                uint64(balance),
                0,
                uint64(release_now_amount),
                uint64(lock_period_amount),
                uint32(start_release_period_date),
                uint16(keep_period),
                uint16(lock_period)
            )
        );
        uint256 id = entities.length - 1;

        entityToOwner[id] = user;
        ownerEntitiesCount[user]++;
        lockCode[lock_code] = true;

        emit LockToken(
            user,
            lock_code,
            balance,
            release_now_amount,
            lock_period_amount,
            start_release_period_date,
            keep_period,
            lock_period,
            id,
            timestamp
        );
    }

    /**
     * Get entities by user
     * @dev Allow anyone get entities of specified user
     */
    function getEntitiesByUser(address user)
        external
        view
        returns (uint256[] memory)
    {
        uint256[] memory result = new uint256[](ownerEntitiesCount[user]);
        uint256 counter = 0;
        for (uint256 i = 0; i < entities.length; i++) {
            if (entityToOwner[i] == user) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

    /**
     * Get available release token
     * @dev Allow anyone get available release token of specified user
     */
    function getAvailableReleaseAmount(uint256 id)
        public
        view
        returns (uint256)
    {
        require(id < entities.length, "Invalid id");

        uint256 availableAmount;

        Entity memory entity = entities[id];

        if (entity.lock_period > 0) {
            uint256 unlockedPeriod = (block.timestamp -
                entity.start_release_period_date) / entity.lock_period;

            uint256 unlockAmount = entity.release_now_amount +
                unlockedPeriod *
                entity.lock_period_amount -
                entity.unlocked;

            availableAmount = Math.min(
                unlockAmount,
                entity.balance - entity.unlocked
            );
            return availableAmount;
        }

        return entity.balance - entity.unlocked;
    }

    /**
     * Release
     * @dev Allow anyone check and release token for specified entity
     */
    function release(uint256 id) external whenNotPaused {
        Entity storage entity = entities[id];
        uint256 amount = getAvailableReleaseAmount(id);
        require(amount > 0, "Invalid amount to release");

        lockedBalances -= amount;
        entity.unlocked += uint32(amount);

        _tokenContract.transferFrom(owner(), entity.user, amount);

        emit Release(
            entity.user,
            entity.lock_code,
            id,
            amount,
            block.timestamp
        );
    }
}