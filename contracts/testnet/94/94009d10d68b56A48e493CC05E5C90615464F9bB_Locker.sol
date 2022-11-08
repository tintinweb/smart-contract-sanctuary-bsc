// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Locker is ReentrancyGuard {
    struct SLockDescriptor {
        address tokenAddress;
        address owner;
        string name;
        uint256 amount;
        bool vest;
        uint256 unlockAt;
        string vestUnit;
        uint256 vestPeriod;
        uint16 vestPercentage;
    }

    struct SLocker {
        address lockerAddress;
        address tokenAddress;
        address owner;
        string name;
        uint256 createdAt;
        uint256 amount;
        uint256 currentAmountLocked;
        uint256 releasedAmount;
        bool vest;
        uint256 unlockAt; // if vest, first time
        bool claimed; // for vest, fully claimed
        string vestUnit; // Days | Weeks | Months | Years
        uint256 vestPeriod;
        uint16 vestPercentage; // 100.00
        uint16 vestUnlockedPercentage; // 100.00
        uint256 vestFullyUnlocksAt;
        uint256 vestClaimedPeriods;
        uint16 vestClaimedPercentage; // 100.00
    }

    event ChangedName(string previousName, string name);
    event ChangedDuration(uint256 previousDuration, uint256 duration);
    event ChangedAmount(uint256 previousAmount, uint256 amount);
    event ChangedOwner(address previousOwner, address owner);
    event Claimed(uint256 amount);

    SLocker private locker;
    address private factory;

    bytes32 public constant Days = keccak256(abi.encodePacked("Days"));
    bytes32 public constant Weeks = keccak256(abi.encodePacked("Weeks"));
    bytes32 public constant Months = keccak256(abi.encodePacked("Months"));
    bytes32 public constant Years = keccak256(abi.encodePacked("Years"));

    uint16 public constant PERCENTAGE_PRECISION = 10000;

    modifier onlyOwner() {
        require(locker.owner == msg.sender, "permissions denied");
        _;
    }

    constructor() {
        factory = msg.sender;
    }

    function lock(SLockDescriptor memory lockDescriptor) external nonReentrant {
        require(factory == msg.sender);
        factory = address(0);

        address tokenAddress = lockDescriptor.tokenAddress;
        address owner = lockDescriptor.owner;
        string memory name = lockDescriptor.name;
        uint256 amount = lockDescriptor.amount;
        bool vest = lockDescriptor.vest;
        uint256 unlockAt = lockDescriptor.unlockAt;
        string memory vestUnit = lockDescriptor.vestUnit;
        uint256 vestPeriod = lockDescriptor.vestPeriod;
        uint16 vestPercentage = lockDescriptor.vestPercentage;

        require(
            IERC20Metadata(tokenAddress).balanceOf(address(this)) == amount,
            "invalid amount was transferred to locker"
        );

        require(tokenAddress != address(0), "invalid token address");
        require(owner != address(0), "invalid owner address");
        require(amount > 0, "invalid amount");

        if (vest) {
            require(unlockAt > block.timestamp, "should unlock in future");
            require(getVestUnitPeriod(vestUnit) > 0, "invalid vest unit");
            require(vestPeriod > 0, "invalid vest period");
            require(
                vestPercentage > 0 && vestPercentage < PERCENTAGE_PRECISION / 2,
                "invalid vest percentage"
            );
        }

        uint256 vestFullyUnlocksAt = vest
            ? unlockAt +
                ((vestPeriod *
                    getVestUnitPeriod(vestUnit) *
                    PERCENTAGE_PRECISION) / vestPercentage)
            : 0;

        address lockerAddress = address(this);

        locker = SLocker({
            lockerAddress: lockerAddress,
            tokenAddress: tokenAddress,
            owner: owner,
            name: name,
            createdAt: block.timestamp,
            amount: amount,
            currentAmountLocked: amount,
            releasedAmount: 0,
            vest: vest,
            unlockAt: unlockAt,
            claimed: false,
            vestUnit: vestUnit,
            vestPeriod: vestPeriod,
            vestPercentage: vestPercentage,
            vestUnlockedPercentage: 0,
            vestFullyUnlocksAt: vestFullyUnlocksAt,
            vestClaimedPeriods: 0,
            vestClaimedPercentage: 0
        });
    }

    function getInfo() public view returns (SLocker memory) {
        SLocker memory info = locker;

        if (locker.vest) {
            uint256 time = locker.unlockAt > block.timestamp
                ? locker.unlockAt
                : locker.vestFullyUnlocksAt > block.timestamp
                ? block.timestamp
                : locker.vestFullyUnlocksAt;

            uint256 duration = getDuration();
            uint256 period = locker.vestPeriod *
                getVestUnitPeriod(locker.vestUnit);
            uint256 totalPeriods = duration / period;

            info.vestUnlockedPercentage = uint16(
                ((totalPeriods -
                    ((duration - (time - locker.unlockAt)) / period)) *
                    PERCENTAGE_PRECISION) / totalPeriods
            );

            info.currentAmountLocked =
                locker.amount -
                ((locker.amount * locker.vestUnlockedPercentage) /
                    PERCENTAGE_PRECISION);
        } else {
            info.currentAmountLocked = locker.unlockAt > block.timestamp
                ? locker.amount
                : 0;
        }

        return info;
    }

    function getDuration() public view returns (uint256) {
        return locker.vestFullyUnlocksAt - locker.unlockAt;
    }

    function getLocker() public view returns (SLocker memory) {
        return locker;
    }

    function getVestUnitPeriod(string memory unit)
        public
        pure
        returns (uint256)
    {
        bytes32 byteUnit = keccak256(abi.encodePacked(unit));

        if (byteUnit == Days) return 1 days;
        if (byteUnit == Weeks) return 1 weeks;
        if (byteUnit == Months) return 4 weeks;
        if (byteUnit == Years) return 365 days;

        return 0;
    }

    function rename(string calldata name) external onlyOwner nonReentrant {
        string memory previousName = locker.name;
        locker.name = name;
        emit ChangedName(previousName, name);
    }

    function extendDuration(uint256 duration) external onlyOwner nonReentrant {
        require(
            locker.unlockAt > block.timestamp,
            "cannot extend duration once unlocked"
        );
        uint256 previousDuration = locker.unlockAt;
        require(
            duration > previousDuration,
            "can extend only after the current unlock date"
        );

        locker.unlockAt = duration;
        emit ChangedDuration(previousDuration, duration);
    }

    function extendAmount(uint256 amount) external onlyOwner nonReentrant {
        require(
            locker.unlockAt > block.timestamp,
            "cannot extend amount once unlocked"
        );
        uint256 previousAmount = locker.amount;

        uint256 recipientBalanceBefore = IERC20Metadata(locker.tokenAddress)
            .balanceOf(address(this));

        require(
            IERC20Metadata(locker.tokenAddress).transferFrom(
                msg.sender,
                address(this),
                amount - previousAmount
            ),
            "transfer failed"
        );

        uint256 actualAmount = IERC20Metadata(locker.tokenAddress).balanceOf(
            address(this)
        ) - recipientBalanceBefore;

        require(actualAmount > 0, "no amount was transferred");

        locker.amount += actualAmount;

        emit ChangedAmount(previousAmount, actualAmount);
    }

    function transferOwnership(address owner) external onlyOwner nonReentrant {
        locker.owner = owner;
        emit ChangedOwner(msg.sender, owner);
    }

    function claim() external onlyOwner nonReentrant {
        require(!locker.claimed, "already claimed");

        uint256 currentAmountUnlocked = locker.amount -
            getInfo().currentAmountLocked;

        require(
            currentAmountUnlocked > locker.releasedAmount,
            "there are no claimable tokens"
        );

        uint256 claimableAmount = currentAmountUnlocked - locker.releasedAmount;

        locker.releasedAmount += claimableAmount;

        if (locker.vest) {
            locker.vestClaimedPercentage = uint16(
                (currentAmountUnlocked * PERCENTAGE_PRECISION) / locker.amount
            );

            locker.claimed =
                locker.vestClaimedPercentage >= PERCENTAGE_PRECISION;
        } else {
            locker.claimed = true;
        }

        require(
            IERC20Metadata(locker.tokenAddress).transfer(
                locker.owner,
                claimableAmount
            ),
            "transfer failed"
        );

        emit Claimed(claimableAmount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
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