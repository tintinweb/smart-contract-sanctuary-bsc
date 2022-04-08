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

    // uint256 constant _secondsInDay = 86400; // For Mainnet: 1 day = 86400s
    uint256 constant _secondsInDay = 120; // For Testnet: 2 mins = 120s

    struct Entity {
        string pool_name;
        string lock_code;
        address user;
        uint64 balance;
        uint64 released;
        uint64 release_now_amount;
        uint64 lock_period_amount;
        uint32 start_release_period_date;
        uint16 keep_period;
        uint16 lock_period;
    }

    Entity[] public entities;

    mapping(string => address) public poolAddress;
    mapping(string => uint256) public poolUsedBalances;
    mapping(string => uint256) public poolReleasedBalances;
    mapping(address => uint256) ownerEntitiesCount;
    mapping(string => bool) public lockCode;

    event LockToken(
        uint256 id,
        string pool_name,
        string lock_code,
        address indexed user,
        uint256 balance,
        uint256 release_now_amount,
        uint256 lock_period_amount,
        uint256 start_release_period_date,
        uint256 keep_period,
        uint256 lock_period,
        uint256 timestamp
    );
    event UpdateLockedToken(
        uint256 id,
        string pool_name,
        string lock_code,
        address indexed user,
        uint256 balance,
        uint256 release_now_amount,
        uint256 lock_period_amount,
        uint256 start_release_period_date,
        uint256 keep_period,
        uint256 lock_period,
        uint256 timestamp
    );
    event Release(
        uint256 id,
        string pool_name,
        string lock_code,
        address indexed user,
        uint256 amount,
        uint256 timestamp
    );

    /**
     * Constructor
     * @dev Set token address, pool address
     */
    constructor(
        address token,
        address seed_sale,
        address private_sale,
        address public_sale,
        address play_to_earn,
        address staking_reward,
        address ecosystem_fund,
        address team,
        address partner_advisor,
        address marketing,
        address liquidity
    ) {
        _tokenContract = IBEP20(token);

        poolAddress["seed-sale"] = seed_sale;
        poolAddress["private-sale"] = private_sale;
        poolAddress["public-sale"] = public_sale;
        poolAddress["play-to-earn"] = play_to_earn;
        poolAddress["staking-reward"] = staking_reward;
        poolAddress["ecosystem-fund"] = ecosystem_fund;
        poolAddress["team"] = team;
        poolAddress["partner-advisor"] = partner_advisor;
        poolAddress["marketing"] = marketing;
        poolAddress["liquidity"] = liquidity;
    }

    /**
     * Pause
     * @dev Allow owner pause releasing token
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * Pause
     * @dev Allow owner unpause releasing token
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * Lock token
     * @dev Allow owner send locked token to user
     */
    function lockToken(
        string memory pool_name,
        string memory lock_code,
        address user,
        uint256 balance,
        uint256 release_now_amount,
        uint256 lock_period_amount,
        uint256 keep_period,
        uint256 lock_period
    ) external onlyOwner {
        require(
            _tokenContract.balanceOf(poolAddress[pool_name]) >=
                poolUsedBalances[pool_name] + balance,
            "Pool not have enough token"
        );

        // Update pool balances
        poolUsedBalances[pool_name] += balance;

        // Calculate release time
        uint256 timestamp = block.timestamp;
        uint256 start_release_period_date = timestamp +
            keep_period *
            _secondsInDay;

        // Lock token for user
        entities.push(
            Entity(
                pool_name,
                lock_code,
                user,
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

        ownerEntitiesCount[user]++;
        lockCode[lock_code] = true;

        emit LockToken(
            id,
            pool_name,
            lock_code,
            user,
            balance,
            release_now_amount,
            lock_period_amount,
            start_release_period_date,
            keep_period,
            lock_period,
            timestamp
        );
    }

    /**
     * Update locked token
     * @dev Allow owner update balance, period for locked token
     */
    function updateLockedToken(
        uint256 id,
        uint256 balance,
        uint256 release_now_amount,
        uint256 lock_period_amount,
        uint256 keep_period,
        uint256 lock_period
    ) external onlyOwner {
        require(id < entities.length, "Invalid id");

        Entity storage entity = entities[id];

        require(
            _tokenContract.balanceOf(poolAddress[entity.pool_name]) >=
                poolUsedBalances[entity.pool_name] + balance - entity.balance,
            "Pool not have enough token"
        );

        // Update pool balances
        poolUsedBalances[entity.pool_name] += balance - entity.balance;

        // Calculate release time
        uint256 timestamp = block.timestamp;
        uint256 start_release_period_date = timestamp +
            keep_period *
            _secondsInDay;

        entity.balance = uint64(balance);
        entity.release_now_amount = uint64(release_now_amount);
        entity.lock_period_amount = uint64(lock_period_amount);
        entity.start_release_period_date = uint32(start_release_period_date);
        entity.keep_period = uint16(keep_period);
        entity.lock_period = uint16(lock_period);

        emit UpdateLockedToken(
            id,
            entity.pool_name,
            entity.lock_code,
            entity.user,
            balance,
            release_now_amount,
            lock_period_amount,
            start_release_period_date,
            keep_period,
            lock_period,
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
            if (entities[i].user == user) {
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

        Entity memory entity = entities[id];

        if (entity.lock_period > 0) {
            uint256 releasingAmount = entity.release_now_amount;

            if (block.timestamp > entity.start_release_period_date) {
                uint256 unlockedPeriod = Math.ceilDiv(
                    block.timestamp - entity.start_release_period_date,
                    entity.lock_period * _secondsInDay
                );
                releasingAmount += unlockedPeriod * entity.lock_period_amount;
            }

            return Math.min(releasingAmount, entity.balance) - entity.released;
        }

        return entity.balance - entity.released;
    }

    /**
     * Release
     * @dev Allow anyone check and release token for specified entity
     */
    function release(uint256 id) external whenNotPaused {
        uint256 amount = getAvailableReleaseAmount(id);
        require(amount > 0, "Invalid amount to release");

        Entity storage entity = entities[id];

        poolReleasedBalances[entity.pool_name] += amount;
        entity.released += uint64(amount);

        _tokenContract.transferFrom(
            poolAddress[entity.pool_name],
            entity.user,
            amount
        );

        emit Release(
            id,
            entity.pool_name,
            entity.lock_code,
            entity.user,
            amount,
            block.timestamp
        );
    }
}