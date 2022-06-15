/*

        ░█████╗░██████╗░██╗░░░██╗██████╗░████████╗███████╗██╗░░██╗
        ██╔══██╗██╔══██╗╚██╗░██╔╝██╔══██╗╚══██╔══╝██╔════╝╚██╗██╔╝
        ██║░░╚═╝██████╔╝░╚████╔╝░██████╔╝░░░██║░░░█████╗░░░╚███╔╝░
        ██║░░██╗██╔══██╗░░╚██╔╝░░██╔═══╝░░░░██║░░░██╔══╝░░░██╔██╗░
        ╚█████╔╝██║░░██║░░░██║░░░██║░░░░░░░░██║░░░███████╗██╔╝╚██╗
        ░╚════╝░╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░░░░░░░╚═╝░░░╚══════╝╚═╝░░╚═╝

This contract for locking and vesting liquidity tokens. Locked liquidity cannot be removed from DEX
until the specified unlock date has been reached. Supports several dexes.

Version 4

 • website:                           https://cryptexlock.me
 • medium:                            https://medium.com/cryptex-locker
 • Telegram Announcements Channel:    https://t.me/CryptExAnnouncements
 • Telegram Main Channel:             https://t.me/cryptexlocker
 • Twitter Page:                      https://twitter.com/ExLocker
 • Reddit:                            https://www.reddit.com/r/CryptExLocker/

*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.7.6;

import "SafeMath.sol";
import "EnumerableSet.sol";
import "IERC20.sol";
import "SafeERC20.sol";
import "Ownable.sol";
import "ReentrancyGuard.sol";
import "Address.sol";
import "IPancakeFactory.sol";
import "IPancakePair.sol";
import "IFeesCalculator.sol";
import "IMigrator.sol";
import "LockAndVestBase.sol";

contract CryptExLpTokenLockerV4 is LockAndVestBase {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.UintSet;
    using Address for address;

    mapping(address => bool) public isFactorySupported;
    IMigrator public migrator;

    struct TokenLock {
        address lpToken;
        address owner;
        uint256 tokenAmount;
        uint256 unlockTime;
        uint256 lockedCrx;
    }

    mapping(uint256 => TokenLock) public tokenLocks;

    mapping(address => EnumerableSet.UintSet) private userLocks;

    event OnTokenLock(
        uint256 indexed lockId,
        address indexed tokenAddress,
        address indexed owner,
        uint256 amount,
        uint256 unlockTime
    );
    event OnLockMigration(uint256 indexed lockId, address indexed migrator);

    modifier onlyLockOwner(uint256 lockId) {
        TokenLock storage lock = tokenLocks[lockId];
        require(
            lock.owner == address(msg.sender),
            "NO ACTIVE LOCK OR NOT OWNER"
        );
        _;
    }

    constructor(
        address[] memory supportedFactories,
        address _feesCalculator,
        address payable _feesReceiver,
        address _feeToken
    ) {
        feesCalculator = IFeesCalculator(_feesCalculator);
        feeReceiver = _feesReceiver;
        feeToken = IERC20(_feeToken);

        for (uint256 i = 0; i < supportedFactories.length; ++i) {
            for (uint256 j = i + 1; j < supportedFactories.length; ++j) {
                require(
                    supportedFactories[i] != supportedFactories[j],
                    "WRONG FACTORIES"
                );
            }

            require(
                _checkIfAddressIsFactory(supportedFactories[i]),
                "WRONG FACTORIES"
            );
            isFactorySupported[supportedFactories[i]] = true;
        }
    }

    /**
     * @notice allow/disallow factory for locking and vesting
     * @param factory factory address
     * @param value false - disallow,
     *              true  - allow
     */
    function setIsFactorySupported(address factory, bool value)
        external
        onlyOwner
    {
        require(_checkIfAddressIsFactory(factory), "WRONG FACTORY");
        isFactorySupported[factory] = value;
    }

    function _proceedLock(
        address token,
        address withdrawer,
        uint256 amountToLock,
        uint256 unlockTime,
        uint256 crxToLock,
        bool needToCheck
    ) internal virtual override returns (uint256 lockId) {
        if (needToCheck) {
            require(isLpToken(token), "NOT DEX PAIR");
        }

        TokenLock memory lock = TokenLock({
            lpToken: token,
            owner: withdrawer,
            tokenAmount: amountToLock,
            unlockTime: unlockTime,
            lockedCrx: crxToLock
        });

        lockId = lockNonce++;
        tokenLocks[lockId] = lock;

        userLocks[withdrawer].add(lockId);

        IERC20(token).safeTransferFrom(msg.sender, address(this), amountToLock);
        emit OnTokenLock(lockId, token, withdrawer, amountToLock, unlockTime);
        return lockId;
    }

    function isLpToken(address lpToken) private view returns (bool) {
        if (!lpToken.isContract()) {
            return false;
        }

        IPancakePair pair = IPancakePair(lpToken);
        address factory;
        try pair.factory() returns (address _factory) {
            factory = _factory;
        } catch (bytes memory) {
            return false;
        }

        if (!isFactorySupported[factory]) {
            return false;
        }

        address factoryPair = IPancakeFactory(factory).getPair(
            pair.token0(),
            pair.token1()
        );
        return factoryPair == lpToken;
    }

    /**
     * @notice increase unlock time of already locked tokens
     * @param newUnlockTime new unlock time (unix time in seconds)
     */
    function extendLockTime(uint256 lockId, uint256 newUnlockTime)
        external
        nonReentrant
        onlyLockOwner(lockId)
    {
        require(newUnlockTime > block.timestamp, "UNLOCK TIME IN THE PAST");
        require(
            newUnlockTime < 10000000000,
            "INVALID UNLOCK TIME, MUST BE UNIX TIME IN SECONDS"
        );
        TokenLock storage lock = tokenLocks[lockId];
        require(lock.unlockTime < newUnlockTime, "NOT INCREASING UNLOCK TIME");
        lock.unlockTime = newUnlockTime;
        emit OnLockDurationIncreased(lockId, newUnlockTime);
    }

    /**
     * @notice add tokens to an existing lock
     * @param amountToIncrement tokens amount to add
     * @param feePaymentMode fee payment mode
     */
    function increaseLockAmount(
        uint256 lockId,
        uint256 amountToIncrement,
        uint8 feePaymentMode
    ) external payable nonReentrant onlyLockOwner(lockId) {
        require(amountToIncrement > 0, "ZERO AMOUNT");
        TokenLock storage lock = tokenLocks[lockId];

        address _lpToken = lock.lpToken;
        (
            uint256 actualIncrementAmount,
            uint256 crxToLock
        ) = _getIncreaseLockAmounts(
                _lpToken,
                amountToIncrement,
                lock.unlockTime,
                feePaymentMode
            );

        lock.tokenAmount = lock.tokenAmount.add(actualIncrementAmount);
        lock.lockedCrx = lock.lockedCrx.add(crxToLock);
        IERC20(_lpToken).safeTransferFrom(
            msg.sender,
            address(this),
            actualIncrementAmount
        );
        emit OnLockAmountIncreased(lockId, amountToIncrement);
    }

    /**
     * @notice withdraw all tokens from lock. Current time must be greater than unlock time
     * @param lockId lock id to withdraw
     */
    function withdraw(uint256 lockId) external {
        TokenLock storage lock = tokenLocks[lockId];
        withdrawPartially(lockId, lock.tokenAmount);
    }

    /**
     * @notice withdraw specified amount of tokens from lock. Current time must be greater than unlock time
     * @param lockId lock id to withdraw tokens from
     * @param amount amount of tokens to withdraw
     */
    function withdrawPartially(uint256 lockId, uint256 amount)
        public
        nonReentrant
        onlyLockOwner(lockId)
    {
        TokenLock storage lock = tokenLocks[lockId];
        require(lock.tokenAmount >= amount, "AMOUNT EXCEEDS LOCKED");
        require(block.timestamp >= lock.unlockTime, "NOT YET UNLOCKED");

        address _owner = lock.owner;

        IERC20(lock.lpToken).safeTransfer(_owner, amount);

        uint256 tokenAmount = lock.tokenAmount.sub(amount);
        lock.tokenAmount = tokenAmount;
        if (tokenAmount == 0) {
            uint256 lockedCrx = lock.lockedCrx;
            if (lockedCrx > 0) {
                feeToken.safeTransfer(_owner, lockedCrx);
            }
            //clean up storage to save gas
            userLocks[_owner].remove(lockId);
            delete tokenLocks[lockId];
            emit OnTokenUnlock(lockId);
        }
        emit OnLockWithdrawal(lockId, amount);
    }

    /**
     * @notice transfer lock ownership to another account. If crxTokens were locked as a paymentFee, the new owner
     * will receive them after the unlock
     * @param lockId lock id to transfer
     * @param newOwner account to transfer lock
     */
    function transferLock(uint256 lockId, address newOwner)
        external
        onlyLockOwner(lockId)
    {
        require(newOwner != address(0), "ZERO NEW OWNER");
        TokenLock storage lock = tokenLocks[lockId];
        userLocks[lock.owner].remove(lockId);
        userLocks[newOwner].add(lockId);
        lock.owner = newOwner;
        emit OnLockOwnershipTransferred(lockId, newOwner);
    }

    /**
     * @notice get user's locks number
     * @param user user's address
     */
    function userLocksLength(address user) external view returns (uint256) {
        return userLocks[user].length();
    }

    /**
     * @notice get user lock id at specified index
     * @param user user's address
     * @param index index of lock id
     */
    function userLockAt(address user, uint256 index)
        external
        view
        returns (uint256)
    {
        return userLocks[user].at(index);
    }

    /**
     * @notice Sets the migrator contract that will perform the migration in case a new update of Pancake was
     * rolled out. Callable only by the owner of this contract.
     * @param newMigrator address of the migrator contract
     */
    function setMigrator(address newMigrator) external onlyOwner {
        migrator = IMigrator(newMigrator);
    }

    /**
     * @notice migrates liquidity in case new update of Pancake was rolled out.
     * @param lockId id of the lock
     * @param migratorContract address of migrator contract that will perform the migration (prevents frontrun attack
     * if a locker owner changes the migrator contract before the migration function was mined)
     */
    function migrate(uint256 lockId, address migratorContract)
        external
        nonReentrant
    {
        require(address(migrator) != address(0), "NO MIGRATOR");
        require(migratorContract == address(migrator), "WRONG MIGRATOR"); //frontrun prevention

        TokenLock storage lock = tokenLocks[lockId];
        require(lock.owner == msg.sender, "ONLY LOCK OWNER");
        IERC20(lock.lpToken).safeApprove(address(migrator), lock.tokenAmount);
        migrator.migrate(
            lock.lpToken,
            lock.tokenAmount,
            lock.unlockTime,
            lock.owner
        );
        emit OnLockMigration(lockId, address(migrator));

        userLocks[lock.owner].remove(lockId);
        delete tokenLocks[lockId];
    }

    /**
     * @notice recover accidentally sent tokens to the contract. Callable only by contract owner
     * @param tokenAddress token address to recover
     */
    function recoverLockedTokens(address tokenAddress) external onlyOwner {
        require(!isLpToken(tokenAddress), "unable to recover LP token");
        IERC20 token = IERC20(tokenAddress);
        token.safeTransfer(owner(), token.balanceOf(address(this)));
    }

    function _checkIfAddressIsFactory(address addressCheck)
        private
        view
        returns (bool)
    {
        if (!addressCheck.isContract()) {
            return false;
        }
        try IPancakeFactory(addressCheck).allPairsLength() returns (uint256) {
            return true;
        } catch (bytes memory) {
            return false;
        }
    }
}