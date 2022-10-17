// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// import "./BoldCryptoLockUtils/Address.sol";
// import "./BoldCryptoLockUtils/Ownable.sol";
// import "./BoldCryptoLockUtils/IERC20.sol";
// import "./BoldCryptoLockUtils/SafeERC20.sol";
// import "./BoldCryptoLockUtils/EnumerableSet.sol";
// import "./BoldCryptoLockUtils/Pausable.sol";

// import "./BoldCryptoLockUtils/IBoldCryptoLock.sol";
// import "./BoldCryptoLockUtils/IUniswapV2Router02.sol";
// import "./BoldCryptoLockUtils/IUniswapV2Pair.sol";
// import "./BoldCryptoLockUtils/IUniswapV2Factory.sol";
// import "./BoldCryptoLockUtils/FullMath.sol";

import "./Address.sol";
import "./Ownable.sol";
import "./IERC20.sol";
import "./SafeERC20.sol";
import "./EnumerableSet.sol";
import "./Pausable.sol";

import "./IBoldCryptoLock.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Factory.sol";
import "./FullMath.sol";

interface ICrowdsaleFactory {
    function lockFee() external view returns (uint256);

    function feeAddress() external view returns (address payable);

    function factoryGenerated() external view returns (address);
}

interface IFactoryGenerated {
    function isFactoryGenerated(address _address) external view returns (bool);
}

contract BoldCryptoLock is IBoldCryptoLock, Ownable, Pausable {
    using Address for address payable;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    using SafeERC20 for IERC20;

    struct Lock {
        uint256 id;
        address token;
        address lockOwner;
        uint256 amount;
        uint256 lockDate;
        uint256 tgeDate; // TGE date for vesting locks, unlock date for normal locks
        bool useBatchRelease; //Is false for normal locks
        uint256 vestingDuration; //Is 0 for normal locks
        uint256 tgeBps; // In bips. Is 0 for normal locks
        uint256 cycleBps; // In bips. Is 0 for normal locks
        uint256 unlockedAmount;
        string description;
    }

    struct CumulativeLockInfo {
        address token;
        address factory;
        uint256 amount;
    }

    /*
     * A hundred percent is stored as a multiple of 1000 to increase precision and
     * accomodate fractional percentages to the third decimal place.
     */
    uint256 public constant A_HUNDRED_PCT = 100_000;
    bool public feeActivated;
    ICrowdsaleFactory public iCrowdsaleFactory;

    Lock[] private _locks;
    mapping(address => EnumerableSet.UintSet) private _userLpLockIds;
    mapping(address => EnumerableSet.UintSet) private _userNormalLockIds;

    EnumerableSet.AddressSet private _lpLockedTokens;
    EnumerableSet.AddressSet private _normalLockedTokens;
    mapping(address => CumulativeLockInfo) public cumulativeLockInfo;
    mapping(address => EnumerableSet.UintSet) private _tokenToLockIds;

    event LockAdded(
        uint256 indexed id,
        address token,
        address lockOwner,
        uint256 amount,
        uint256 unlockDate
    );
    event LockUpdated(
        uint256 indexed id,
        address token,
        address lockOwner,
        uint256 newAmount,
        uint256 newUnlockDate
    );
    event LockRemoved(
        uint256 indexed id,
        address token,
        address lockOwner,
        uint256 amount,
        uint256 unlockedAt
    );
    event LockVested(
        uint256 indexed id,
        address token,
        address lockOwner,
        uint256 amount,
        uint256 total,
        uint256 timestamp
    );
    event LockDescriptionChanged(uint256 lockId);
    event LockOwnerChanged(
        uint256 lockId,
        address lockOwner,
        address newLockOwner
    );

    constructor(address _iCrowdsaleFactory, bool _feeActivated) {
        iCrowdsaleFactory = ICrowdsaleFactory(_iCrowdsaleFactory);
        feeActivated = _feeActivated;
    }

    modifier validLock(uint256 lockId) {
        require(lockId < _locks.length, "BCL: invalid lock id");
        _;
    }

    modifier checkFeeRequirement() {
        if (feeActivated) {
            if (address(iCrowdsaleFactory) != address(0)) {
                if (!factoryGenerated().isFactoryGenerated(msg.sender)) {
                    require(msg.value == lockFee(), "BCL: fee required");
                }
            }
        }
        _;
    }

    function activateLockFee(bool _newStatus) external onlyOwner {
        feeActivated = _newStatus;
    }

    function lockFee() public view returns (uint256) {
        return iCrowdsaleFactory.lockFee();
    }

    function sendFee(uint256 amount) external onlyOwner {
        _sendFee(amount);
    }

    function _sendFee(uint256 amount) private {
        (bool sent, ) = feeAddress().call{value: amount}("");
        require(sent, "BCL: fee send fail");
    }

    function feeAddress() public view returns (address) {
        return iCrowdsaleFactory.feeAddress();
    }

    function factoryGenerated() public view returns (IFactoryGenerated) {
        return IFactoryGenerated(iCrowdsaleFactory.factoryGenerated());
    }

    function updateCrowdsaleFactory(address newAddress) external onlyOwner {
        iCrowdsaleFactory = ICrowdsaleFactory(newAddress);
    }

    function lock(
        address lockOwner,
        address token,
        bool isLpToken,
        uint256 amount,
        uint256 unlockDate,
        string memory description
    ) external payable override returns (uint256 id) {
        require(
            unlockDate > block.timestamp,
            "BCL: unlock date should be in the future"
        );
        require(amount > 0, "BCL: amount should be greater than 0");
        id = _createLock(
            lockOwner,
            token,
            isLpToken,
            amount,
            unlockDate,
            false,
            0,
            0,
            0,
            description
        );
        _safeTransferFromEnsureExactAmount(
            token,
            msg.sender,
            address(this),
            amount
        );
        emit LockAdded(id, token, lockOwner, amount, unlockDate);
        return id;
    }

    function vestingLock(
        address lockOwner,
        address token,
        bool isLpToken,
        uint256 amount,
        uint256 tgeDate, // first release date
        bool useBatchRelease, // true for batch false for linear
        uint256 vestingDuration, // vesting duration
        uint256 tgeBps, //first release percentage
        uint256 cycleBps, // each cycle percentage
        string memory description
    ) external payable override returns (uint256 id) {
        require(
            tgeDate > block.timestamp,
            "BCL: TGE date should be in the future"
        );
        require(vestingDuration > 0, "BCL: invalid vesting duration");
        require(
            tgeBps > 0 && tgeBps < A_HUNDRED_PCT,
            "BCL: invalid bips for TGE"
        );

        require(cycleBps < A_HUNDRED_PCT, "BCL: invalid cycle bips");
        if (useBatchRelease) {
            require(cycleBps > 0, "BCL: invalid cycle bips");
        }
        require(
            tgeBps + cycleBps <= A_HUNDRED_PCT,
            "BCL: sum of TGE bps and cycle bps should be less than 100000"
        );
        require(amount > 0, "BCL: amount should be greater than 0");
        id = _createLock(
            lockOwner,
            token,
            isLpToken,
            amount,
            tgeDate,
            useBatchRelease,
            vestingDuration,
            tgeBps,
            cycleBps,
            description
        );
        _safeTransferFromEnsureExactAmount(
            token,
            msg.sender,
            address(this),
            amount
        );
        emit LockAdded(id, token, lockOwner, amount, tgeDate);
        return id;
    }

    function multipleVestingLock(
        address[] calldata lockOwners,
        uint256[] calldata amounts,
        address token,
        bool isLpToken,
        uint256 tgeDate,
        bool useBatchRelease,
        uint256 vestingDuration,
        uint256 tgeBps,
        uint256 cycleBps,
        string memory description
    ) external payable override returns (uint256[] memory) {
        require(lockOwners.length == amounts.length, "BCL: Length mismatched");
        require(
            tgeDate > block.timestamp,
            "BCL: TGE date should be in the future"
        );
        require(vestingDuration > 0, "BCL: Invalid vesting duration");
        require(tgeBps > 0 && tgeBps < A_HUNDRED_PCT, "Invalid bips for TGE");
        require(
            cycleBps > 0 && cycleBps < A_HUNDRED_PCT,
            "BCL: Invalid bips for cycle"
        );
        require(
            tgeBps + cycleBps <= A_HUNDRED_PCT,
            "BCL: Sum of TGE bps and cycle bps should be less than 100000"
        );
        return
            _multipleVestingLock(
                lockOwners,
                amounts,
                token,
                [isLpToken, useBatchRelease],
                [tgeDate, vestingDuration, tgeBps, cycleBps],
                description
            );
    }

    function _multipleVestingLock(
        address[] calldata lockOwners,
        uint256[] calldata amounts,
        address token,
        bool[2] memory boolSettings,
        // bool isLpToken,
        uint256[4] memory vestingSettings, // avoid stack too deep
        string memory description
    ) internal returns (uint256[] memory) {
        uint256 sumAmount = _sumAmount(amounts);
        uint256 count = lockOwners.length;
        uint256[] memory ids = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            ids[i] = _createLock(
                lockOwners[i],
                token,
                boolSettings[0], // is LpToken
                amounts[i],
                vestingSettings[0], // TGE date
                boolSettings[1], //use batch relese
                vestingSettings[1], //vestingDuration
                vestingSettings[2], // TGE bps
                vestingSettings[3], // cycle bps
                description
            );
            emit LockAdded(
                ids[i],
                token,
                lockOwners[i],
                amounts[i],
                vestingSettings[0] // TGE date
            );
        }
        _safeTransferFromEnsureExactAmount(
            token,
            msg.sender,
            address(this),
            sumAmount
        );
        return ids;
    }

    function _sumAmount(uint256[] calldata amounts)
        internal
        pure
        returns (uint256)
    {
        uint256 sum = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            if (amounts[i] == 0) {
                revert("BCL: Amount cant be zero");
            }
            sum += amounts[i];
        }
        return sum;
    }

    function _createLock(
        address lockOwner,
        address token,
        bool isLpToken,
        uint256 amount,
        uint256 tgeDate,
        bool useBatchRelease,
        uint256 vestingDuration,
        uint256 tgeBps,
        uint256 cycleBps,
        string memory description
    ) internal checkFeeRequirement returns (uint256 id) {
        if (isLpToken) {
            address possibleFactoryAddress = _parseFactoryAddress(token);
            id = _lockLpToken(
                lockOwner,
                token,
                possibleFactoryAddress,
                amount,
                tgeDate,
                useBatchRelease,
                vestingDuration,
                tgeBps,
                cycleBps,
                description
            );
        } else {
            id = _lockNormalToken(
                lockOwner,
                token,
                amount,
                tgeDate,
                useBatchRelease,
                vestingDuration,
                tgeBps,
                cycleBps,
                description
            );
        }
        _sendFee(msg.value);
        return id;
    }

    function _lockLpToken(
        address lockOwner,
        address token,
        address factory,
        uint256 amount,
        uint256 tgeDate,
        bool useBatchRelease,
        uint256 vestingDuration,
        uint256 tgeBps,
        uint256 cycleBps,
        string memory description
    ) private returns (uint256 id) {
        id = _registerLock(
            lockOwner,
            token,
            amount,
            tgeDate,
            useBatchRelease,
            vestingDuration,
            tgeBps,
            cycleBps,
            description
        );
        _userLpLockIds[lockOwner].add(id);
        _lpLockedTokens.add(token);

        CumulativeLockInfo storage tokenInfo = cumulativeLockInfo[token];
        if (tokenInfo.token == address(0)) {
            tokenInfo.token = token;
            tokenInfo.factory = factory;
        }
        tokenInfo.amount = tokenInfo.amount + amount;

        _tokenToLockIds[token].add(id);
    }

    function _lockNormalToken(
        address lockOwner,
        address token,
        uint256 amount,
        uint256 tgeDate,
        bool useBatchRelease,
        uint256 vestingDuration,
        uint256 tgeBps,
        uint256 cycleBps,
        string memory description
    ) private returns (uint256 id) {
        id = _registerLock(
            lockOwner,
            token,
            amount,
            tgeDate,
            useBatchRelease,
            vestingDuration,
            tgeBps,
            cycleBps,
            description
        );
        _userNormalLockIds[lockOwner].add(id);
        _normalLockedTokens.add(token);

        CumulativeLockInfo storage tokenInfo = cumulativeLockInfo[token];
        if (tokenInfo.token == address(0)) {
            tokenInfo.token = token;
            tokenInfo.factory = address(0);
        }
        tokenInfo.amount = tokenInfo.amount + amount;

        _tokenToLockIds[token].add(id);
    }

    function _registerLock(
        address lockOwner,
        address token,
        uint256 amount,
        uint256 tgeDate,
        bool useBatchRelease,
        uint256 vestingDuration,
        uint256 tgeBps,
        uint256 cycleBps,
        string memory description
    ) private whenNotPaused returns (uint256 id) {
        id = _locks.length;
        Lock memory newLock = Lock({
            id: id,
            token: token,
            lockOwner: lockOwner,
            amount: amount,
            lockDate: block.timestamp,
            tgeDate: tgeDate,
            useBatchRelease: useBatchRelease,
            vestingDuration: vestingDuration,
            tgeBps: tgeBps,
            cycleBps: cycleBps,
            unlockedAmount: 0,
            description: description
        });
        _locks.push(newLock);
    }

    function unlock(uint256 lockId) external override validLock(lockId) {
        Lock storage userLock = _locks[lockId];
        require(
            userLock.lockOwner == msg.sender,
            "BCL: You dont own this lock"
        );

        if (userLock.tgeBps > 0) {
            _vestingUnlock(userLock);
        } else {
            _normalUnlock(userLock);
        }
    }

    function _normalUnlock(Lock storage userLock) internal {
        require(
            block.timestamp >= userLock.tgeDate,
            "BCL: not yet unlock time"
        );
        require(userLock.unlockedAmount == 0, "BCL: zero unlocked amount");

        CumulativeLockInfo storage tokenInfo = cumulativeLockInfo[
            userLock.token
        ];

        bool isLpToken = tokenInfo.factory != address(0);

        if (isLpToken) {
            _userLpLockIds[msg.sender].remove(userLock.id);
        } else {
            _userNormalLockIds[msg.sender].remove(userLock.id);
        }

        uint256 unlockAmount = userLock.amount;

        if (tokenInfo.amount <= unlockAmount) {
            tokenInfo.amount = 0;
        } else {
            tokenInfo.amount = tokenInfo.amount - unlockAmount;
        }

        if (tokenInfo.amount == 0) {
            if (isLpToken) {
                _lpLockedTokens.remove(userLock.token);
            } else {
                _normalLockedTokens.remove(userLock.token);
            }
        }
        userLock.unlockedAmount = unlockAmount;

        _tokenToLockIds[userLock.token].remove(userLock.id);

        IERC20(userLock.token).safeTransfer(msg.sender, unlockAmount);

        emit LockRemoved(
            userLock.id,
            userLock.token,
            msg.sender,
            unlockAmount,
            block.timestamp
        );
    }

    function _vestingUnlock(Lock storage userLock) internal {
        uint256 withdrawable = _withdrawableTokens(userLock);
        uint256 newTotalUnlockAmount = userLock.unlockedAmount + withdrawable;
        require(
            withdrawable > 0 && newTotalUnlockAmount <= userLock.amount,
            "BCL: zero unlocked amount"
        );

        CumulativeLockInfo storage tokenInfo = cumulativeLockInfo[
            userLock.token
        ];
        bool isLpToken = tokenInfo.factory != address(0);

        if (newTotalUnlockAmount == userLock.amount) {
            if (isLpToken) {
                _userLpLockIds[msg.sender].remove(userLock.id);
            } else {
                _userNormalLockIds[msg.sender].remove(userLock.id);
            }
            _tokenToLockIds[userLock.token].remove(userLock.id);
            emit LockRemoved(
                userLock.id,
                userLock.token,
                msg.sender,
                newTotalUnlockAmount,
                block.timestamp
            );
        }

        if (tokenInfo.amount <= withdrawable) {
            tokenInfo.amount = 0;
        } else {
            tokenInfo.amount = tokenInfo.amount - withdrawable;
        }

        if (tokenInfo.amount == 0) {
            if (isLpToken) {
                _lpLockedTokens.remove(userLock.token);
            } else {
                _normalLockedTokens.remove(userLock.token);
            }
        }
        userLock.unlockedAmount = newTotalUnlockAmount;

        IERC20(userLock.token).safeTransfer(userLock.lockOwner, withdrawable);

        emit LockVested(
            userLock.id,
            userLock.token,
            msg.sender,
            withdrawable,
            userLock.amount,
            block.timestamp
        );
    }

    function withdrawableTokens(uint256 lockId)
        external
        view
        returns (uint256)
    {
        Lock memory userLock = getLockById(lockId);
        return _withdrawableTokens(userLock);
    }

    function _withdrawableTokens(Lock memory userLock)
        internal
        view
        returns (uint256)
    {
        if (userLock.amount == 0) return 0;
        if (userLock.unlockedAmount >= userLock.amount) return 0;
        if (block.timestamp < userLock.tgeDate) return 0;
        if (userLock.vestingDuration == 0) return 0;

        uint256 currentTotal = 0;
        uint256 withdrawable = 0;
        uint256 tgeReleaseAmount = (userLock.amount * userLock.tgeBps) /
            A_HUNDRED_PCT;
        uint256 elapsedTime = block.timestamp - userLock.tgeDate;
        if (!userLock.useBatchRelease) {
            //use linear release
            currentTotal =
                _getLinearReleaseAmount(
                    userLock,
                    tgeReleaseAmount,
                    elapsedTime
                ) +
                tgeReleaseAmount;
        } else {
            //use batch release
            currentTotal =
                _getBatchReleaseAmount(userLock, elapsedTime) +
                tgeReleaseAmount;
        }

        if (currentTotal > userLock.amount) {
            withdrawable = userLock.amount - userLock.unlockedAmount;
        } else {
            withdrawable = currentTotal - userLock.unlockedAmount;
        }
        return withdrawable;
    }

    function _getLinearReleaseAmount(
        Lock memory userLock,
        uint256 tgeReleaseAmount,
        uint256 elapsedTime
    ) private pure returns (uint256) {
        uint256 amountUnderVesting = userLock.amount - tgeReleaseAmount;
        return
            FullMath.mulDiv(
                amountUnderVesting,
                elapsedTime,
                userLock.vestingDuration
            );
    }

    function _getBatchReleaseAmount(Lock memory userLock, uint256 elapsedTime)
        private
        pure
        returns (uint256)
    {
        uint256 numOfBatchCycles = (A_HUNDRED_PCT - userLock.tgeBps) /
            userLock.cycleBps;
        uint256 cycleDuration = userLock.vestingDuration / numOfBatchCycles;
        uint256 elapseCycles = elapsedTime / cycleDuration;
        uint256 batchReleaseAmount = FullMath.mulDiv(
            userLock.amount,
            userLock.cycleBps,
            A_HUNDRED_PCT
        );
        return elapseCycles * batchReleaseAmount;
    }

    function editLock(
        uint256 lockId,
        uint256 newAmount,
        uint256 newUnlockDate
    ) external override validLock(lockId) {
        Lock storage userLock = _locks[lockId];
        require(
            userLock.lockOwner == msg.sender,
            "BCL: you dont own this lock"
        );
        require(userLock.unlockedAmount == 0, "BCL: Lock was unlocked");

        if (newUnlockDate > 0) {
            require(
                newUnlockDate >= userLock.tgeDate &&
                    newUnlockDate > block.timestamp,
                "BCL: New unlock time should not be before old unlock time or current time"
            );
            userLock.tgeDate = newUnlockDate;
        }

        if (newAmount > 0) {
            require(
                newAmount >= userLock.amount,
                "BCL: New amount should not be less than current amount"
            );

            uint256 diff = newAmount - userLock.amount;

            if (diff > 0) {
                userLock.amount = newAmount;
                CumulativeLockInfo storage tokenInfo = cumulativeLockInfo[
                    userLock.token
                ];
                tokenInfo.amount = tokenInfo.amount + diff;
                _safeTransferFromEnsureExactAmount(
                    userLock.token,
                    msg.sender,
                    address(this),
                    diff
                );
            }
        }

        emit LockUpdated(
            userLock.id,
            userLock.token,
            userLock.lockOwner,
            userLock.amount,
            userLock.tgeDate
        );
    }

    function editLockDescription(uint256 lockId, string memory description)
        external
        validLock(lockId)
    {
        Lock storage userLock = _locks[lockId];
        require(
            userLock.lockOwner == msg.sender,
            "BCL: you dont own this lock"
        );
        userLock.description = description;
        emit LockDescriptionChanged(lockId);
    }

    function transferLockOwnership(uint256 lockId, address newLockOwner)
        public
        validLock(lockId)
    {
        Lock storage userLock = _locks[lockId];
        address currentLockOwner = userLock.lockOwner;
        require(currentLockOwner == msg.sender, "BCL: you dont own this lock");

        userLock.lockOwner = newLockOwner;

        CumulativeLockInfo storage tokenInfo = cumulativeLockInfo[
            userLock.token
        ];

        bool isLpToken = tokenInfo.factory != address(0);

        if (isLpToken) {
            _userLpLockIds[currentLockOwner].remove(lockId);
            _userLpLockIds[newLockOwner].add(lockId);
        } else {
            _userNormalLockIds[currentLockOwner].remove(lockId);
            _userNormalLockIds[newLockOwner].add(lockId);
        }

        emit LockOwnerChanged(lockId, currentLockOwner, newLockOwner);
    }

    function renounceLockOwnership(uint256 lockId) external {
        transferLockOwnership(lockId, address(0));
    }

    function _safeTransferFromEnsureExactAmount(
        address token,
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        uint256 oldRecipientBalance = IERC20(token).balanceOf(recipient);
        IERC20(token).safeTransferFrom(sender, recipient, amount);
        uint256 newRecipientBalance = IERC20(token).balanceOf(recipient);
        require(
            newRecipientBalance - oldRecipientBalance == amount,
            "BCL: Sent token amount differed with transferred amount"
        );
    }

    function getTotalLockCount() external view returns (uint256) {
        // Returns total lock count, regardless of whether it has been unlocked or not
        return _locks.length;
    }

    function getLockAt(uint256 index) external view returns (Lock memory) {
        return _locks[index];
    }

    function getLockById(uint256 lockId) public view returns (Lock memory) {
        return _locks[lockId];
    }

    function allLpTokenLockedCount() public view returns (uint256) {
        return _lpLockedTokens.length();
    }

    function allNormalTokenLockedCount() public view returns (uint256) {
        return _normalLockedTokens.length();
    }

    function getCumulativeLpTokenLockInfoAt(uint256 index)
        external
        view
        returns (CumulativeLockInfo memory)
    {
        return cumulativeLockInfo[_lpLockedTokens.at(index)];
    }

    function getCumulativeNormalTokenLockInfoAt(uint256 index)
        external
        view
        returns (CumulativeLockInfo memory)
    {
        return cumulativeLockInfo[_normalLockedTokens.at(index)];
    }

    function getCumulativeLpTokenLockInfo(uint256 start, uint256 end)
        external
        view
        returns (CumulativeLockInfo[] memory)
    {
        if (end >= _lpLockedTokens.length()) {
            end = _lpLockedTokens.length() - 1;
        }
        uint256 length = end - start + 1;
        CumulativeLockInfo[] memory lockInfo = new CumulativeLockInfo[](length);
        uint256 currentIndex = 0;
        for (uint256 i = start; i <= end; i++) {
            lockInfo[currentIndex] = cumulativeLockInfo[_lpLockedTokens.at(i)];
            currentIndex++;
        }
        return lockInfo;
    }

    function getCumulativeNormalTokenLockInfo(uint256 start, uint256 end)
        external
        view
        returns (CumulativeLockInfo[] memory)
    {
        if (end >= _normalLockedTokens.length()) {
            end = _normalLockedTokens.length() - 1;
        }
        uint256 length = end - start + 1;
        CumulativeLockInfo[] memory lockInfo = new CumulativeLockInfo[](length);
        uint256 currentIndex = 0;
        for (uint256 i = start; i <= end; i++) {
            lockInfo[currentIndex] = cumulativeLockInfo[
                _normalLockedTokens.at(i)
            ];
            currentIndex++;
        }
        return lockInfo;
    }

    function totalTokenLockedCount() external view returns (uint256) {
        return allLpTokenLockedCount() + allNormalTokenLockedCount();
    }

    function lpLockCountForUser(address user) public view returns (uint256) {
        return _userLpLockIds[user].length();
    }

    function lpLocksForUser(address user)
        external
        view
        returns (Lock[] memory)
    {
        uint256 length = _userLpLockIds[user].length();
        Lock[] memory userLocks = new Lock[](length);
        for (uint256 i = 0; i < length; i++) {
            userLocks[i] = getLockById(_userLpLockIds[user].at(i));
        }
        return userLocks;
    }

    function lpLockForUserAtIndex(address user, uint256 index)
        external
        view
        returns (Lock memory)
    {
        require(lpLockCountForUser(user) > index, "Invalid index");
        return getLockById(_userLpLockIds[user].at(index));
    }

    function normalLockCountForUser(address user)
        public
        view
        returns (uint256)
    {
        return _userNormalLockIds[user].length();
    }

    function normalLocksForUser(address user)
        external
        view
        returns (Lock[] memory)
    {
        uint256 length = _userNormalLockIds[user].length();
        Lock[] memory userLocks = new Lock[](length);

        for (uint256 i = 0; i < length; i++) {
            userLocks[i] = getLockById(_userNormalLockIds[user].at(i));
        }
        return userLocks;
    }

    function normalLockForUserAtIndex(address user, uint256 index)
        external
        view
        returns (Lock memory)
    {
        require(normalLockCountForUser(user) > index, "BCL: Invalid index");
        return getLockById(_userNormalLockIds[user].at(index));
    }

    function totalLockCountForUser(address user)
        external
        view
        returns (uint256)
    {
        return normalLockCountForUser(user) + lpLockCountForUser(user);
    }

    function totalLockCountForToken(address token)
        external
        view
        returns (uint256)
    {
        return _tokenToLockIds[token].length();
    }

    function getLocksForToken(
        address token,
        uint256 start,
        uint256 end
    ) public view returns (Lock[] memory) {
        if (end >= _tokenToLockIds[token].length()) {
            end = _tokenToLockIds[token].length() - 1;
        }
        uint256 length = end - start + 1;
        Lock[] memory locks = new Lock[](length);
        uint256 currentIndex = 0;
        for (uint256 i = start; i <= end; i++) {
            locks[currentIndex] = getLockById(_tokenToLockIds[token].at(i));
            currentIndex++;
        }
        return locks;
    }

    function _parseFactoryAddress(address token)
        internal
        view
        returns (address)
    {
        address possibleFactoryAddress;
        try IUniswapV2Pair(token).factory() returns (address factory) {
            possibleFactoryAddress = factory;
        } catch {
            revert("BCL: This token is not an LP token");
        }
        require(
            possibleFactoryAddress != address(0) &&
                _isValidLpToken(token, possibleFactoryAddress),
            "BCL: This token is not an LP token."
        );
        return possibleFactoryAddress;
    }

    function _isValidLpToken(address token, address factory)
        private
        view
        returns (bool)
    {
        IUniswapV2Pair pair = IUniswapV2Pair(token);
        address factoryPair = IUniswapV2Factory(factory).getPair(
            pair.token0(),
            pair.token1()
        );
        return factoryPair == token;
    }
}