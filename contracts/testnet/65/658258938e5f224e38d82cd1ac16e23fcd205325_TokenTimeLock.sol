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

    uint256 public balances;
    uint256 constant _tokenModulus = 10**8;
    // uint256 constant _secondsInDay = 86400;
    uint256 constant _secondsInDay = 5; // For Testnet

    struct Entity {
        address user;
        string lock_type;
        uint256 balance;
        uint256 unlocked;
        uint256 release_now_amount;
        uint256 keep_period;
        uint256 lock_period;
        uint256 lock_period_amount;
        uint256 start_release_period_date;
    }

    Entity[] public entities;

    mapping(uint256 => address) public entityToOwner;
    mapping(address => uint256) ownerEntitiesCount;

    event LockToken(
        address indexed user,
        string lock_type,
        uint256 id,
        uint256 balance,
        uint256 release_now_amount,
        uint256 keep_period,
        uint256 lock_period,
        uint256 lock_period_amount,
        uint256 start_release_period_date,
        uint256 timestamp
    );
    event Release(
        address indexed user,
        string lock_type,
        uint256 id,
        uint256 amount,
        uint256 timestamp
    );
    event Withdraw(address indexed owner, uint256 amount, uint256 timestamp);

    /**
     * Constructor
     * @dev Set token address, swap and release period
     */
    constructor(address token) {
        _tokenContract = IBEP20(token);
    }

    /**
     * Lock token
     * @dev Allow owner send locked token to user
     */
    function lockToken(
        address user,
        string memory lock_type,
        uint256 balance,
        uint256 release_now_amount,
        uint256 keep_period,
        uint256 lock_period,
        uint256 lock_period_amount
    ) external onlyOwner {
        require(
            _tokenContract.balanceOf(address(this)) >= balances + balance,
            "Pool not have enough token"
        );

        // Lock token for contract
        balances += balance;

        uint256 timestamp = block.timestamp;
        uint256 start_release_period_date = timestamp +
            keep_period *
            _secondsInDay;

        // Lock token for user
        entities.push(
            Entity(
                user,
                lock_type,
                balance,
                0,
                release_now_amount,
                keep_period,
                lock_period,
                lock_period_amount,
                start_release_period_date
            )
        );
        uint256 id = entities.length - 1;

        entityToOwner[id] = user;
        ownerEntitiesCount[user]++;

        emit LockToken(
            user,
            lock_type,
            id,
            balance,
            release_now_amount,
            keep_period,
            lock_period,
            lock_period_amount,
            start_release_period_date,
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
        Entity memory entity = entities[id];

        uint256 availableAmount;

        if (entity.lock_period > 0) {
            uint256 unlockedPeriod = (block.timestamp -
                entity.start_release_period_date) / entity.lock_period;

            uint256 unlockAmount = entity.release_now_amount +
                unlockedPeriod *
                entity.lock_period_amount -
                entity.unlocked;

            availableAmount = Math.min(unlockAmount, entity.balance);
        }

        return availableAmount;
    }

    /**
     * Release
     * @dev Allow anyone check and release token for specified entity
     */
    function release(uint256 id, uint256 amount) external whenNotPaused {
        Entity storage entity = entities[id];
        require(
            entity.balance >= amount && amount > 0,
            "Invalid amount to release"
        );

        balances -= amount;
        entity.unlocked += amount;

        _tokenContract.transfer(entity.user, amount);

        emit Release(
            entity.user,
            entity.lock_type,
            id,
            amount,
            block.timestamp
        );
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
     * Withdraw token
     * @dev Allow owner withdraw free token
     */
    function withdrawToken(uint256 amount) external onlyOwner {
        require(
            _tokenContract.balanceOf(address(this)) >= balances + amount,
            "Token locked"
        );
        _tokenContract.transfer(msg.sender, amount);
        emit Withdraw(msg.sender, amount, block.timestamp);
    }
}