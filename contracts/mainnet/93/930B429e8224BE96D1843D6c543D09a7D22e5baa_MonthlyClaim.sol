//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "crypto-subscriptions/contracts/BillingDate.sol";

contract MonthlyClaim is Ownable, Pausable, BillingDate {
    struct UserInfo {
        uint256 amount;
        uint256 tokenIndex;
        uint256 lastClaimRound;
    }
    struct ClaimRound {
        uint256 startsAt;
        uint8 claimDateIndex;
    }

    mapping(address => UserInfo) public usersInfo;
    address[] public tokens;

    mapping(uint256 => ClaimRound) public claimRounds;
    uint256 public currentClaimRound;

    uint8[] public claimDates;

    event SetUserInfo(
        address user,
        uint256 amount,
        uint256 lastClaimRound,
        uint256 tokenIndex
    );
    event UserRemoved(address user);
    event Claimed(address user, uint256 amount, address token);
    event NewRoundCreated(uint256 startsAt, uint8 claimDate);
    event SetToken(uint256 index, address token);

    constructor(
        uint256 currentClaimRound_,
        uint256 nextClaimTimestamp,
        uint8 nextClaimDateIndex,
        uint8[] memory claimDates_
    ) {
        currentClaimRound = currentClaimRound_;

        claimRounds[currentClaimRound + 1] = ClaimRound({
            startsAt: nextClaimTimestamp,
            claimDateIndex: nextClaimDateIndex
        });

        claimDates = claimDates_;
    }

    function setTokenByIndex(uint256 index, address token) external onlyOwner {
        require(index <= tokens.length, "Invalid index");

        if (index == tokens.length) tokens.push(token);
        else tokens[index] = token;

        emit SetToken(index, token);
    }

    function setUsersInfo(
        address[] calldata users,
        uint256[] calldata amounts,
        uint256[] calldata lastClaimRounds,
        uint256[] calldata tokenIndexes
    ) external onlyOwner {
        require(users.length == amounts.length, "Values do not match");
        require(
            amounts.length == lastClaimRounds.length,
            "Values do not match"
        );
        require(
            lastClaimRounds.length == tokenIndexes.length,
            "Values do not match"
        );

        for (uint256 index = 0; index < users.length; index++) {
            _setUserInfo(
                users[index],
                amounts[index],
                lastClaimRounds[index],
                tokenIndexes[index]
            );
        }
    }

    function setUserInfo(
        address user,
        uint256 amount,
        uint256 lastClaimRound,
        uint256 tokenIndex
    ) external onlyOwner {
        _setUserInfo(user, amount, lastClaimRound, tokenIndex);
    }

    function removeUser(address user) external onlyOwner {
        delete usersInfo[user];
        emit UserRemoved(user);
    }

    function claim() external whenNotPaused {
        _executeClaim(msg.sender);
    }

    function executeClaim(address user) external onlyOwner {
        _executeClaim(user);
    }

    function executeClaims(address[] calldata users) external onlyOwner {
        for (uint256 index = 0; index < users.length; index++) {
            _executeClaim(users[index]);
        }
    }

    function withdraw(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
    }

    function withdrawEth() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function _setUserInfo(
        address user,
        uint256 amount,
        uint256 lastClaimRound,
        uint256 tokenIndex
    ) internal {
        require(tokens[tokenIndex] != address(0), "Token does not exist");

        UserInfo storage userInfoStorage = usersInfo[user];
        userInfoStorage.amount = amount;
        userInfoStorage.tokenIndex = tokenIndex;
        userInfoStorage.lastClaimRound = lastClaimRound;

        emit SetUserInfo(user, amount, lastClaimRound, tokenIndex);
    }

    function _executeClaim(address user) internal {
        uint256 currentClaimRound_ = currentClaimRound;
        require(
            claimRounds[currentClaimRound_].startsAt < block.timestamp,
            "claimRound is not started yet"
        );

        ClaimRound memory newClaimRound = claimRounds[currentClaimRound_ + 1];

        bool newClaimRoundStarted = newClaimRound.startsAt > 0 &&
            newClaimRound.startsAt < block.timestamp;
        if (newClaimRoundStarted) {
            delete claimRounds[currentClaimRound_];
            // increment currentClaimRound and create round, if new one already started
            currentClaimRound++;
            currentClaimRound_++;

            _createNewRound(newClaimRound);
        }

        UserInfo memory userInfo = usersInfo[user];
        require(userInfo.amount > 0, "No tokens for claim");
        require(
            userInfo.lastClaimRound < currentClaimRound_,
            "Already claimed"
        );

        address token = tokens[userInfo.tokenIndex];
        uint256 amount = userInfo.amount *
            (currentClaimRound_ - userInfo.lastClaimRound);

        IERC20(token).transfer(user, amount);
        usersInfo[user].lastClaimRound = currentClaimRound_;

        emit Claimed(user, amount, token);
    }

    function _createNewRound(ClaimRound memory claimRound) internal {
        uint8[] memory claimDates_ = claimDates;
        uint8 nextClaimDateIndex = claimRound.claimDateIndex;

        bool isLastIndex = claimRound.claimDateIndex == claimDates_.length - 1;
        if (isLastIndex) nextClaimDateIndex = 0;
        else nextClaimDateIndex++;

        uint256 nextClaimTimestamp;

        uint8 nextClaimDate = claimDates_[nextClaimDateIndex];
        if (isLastIndex) {
            nextClaimTimestamp = getTimestampOfNextDate(
                block.timestamp,
                nextClaimDate
            );
        } else {
            uint8 currentClaimDate = claimDates_[claimRound.claimDateIndex];
            nextClaimTimestamp =
                claimRound.startsAt +
                (nextClaimDate - currentClaimDate) *
                1 days;
        }

        claimRounds[currentClaimRound + 1] = ClaimRound({
            startsAt: nextClaimTimestamp,
            claimDateIndex: nextClaimDateIndex
        });

        emit NewRoundCreated(nextClaimTimestamp, nextClaimDate);
    }
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

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

contract BillingDate {
    uint256 constant DENOMINATOR = 10_000;

    /**
     * parse timestamp & get service params for calculations
     */
    function getDaysFromTimestamp(uint256 timestamp)
        public
        pure
        returns (
            uint256 daysFrom0,
            uint256 yearStartDay,
            uint256 dayOfYear,
            uint256 yearsFrom1972
        )
    {
        // get number of days from seconds
        daysFrom0 = (timestamp * DENOMINATOR) / 86_400 / DENOMINATOR;

        // get number of full years from `01.01.1970 + 730 days = 01.01.1972` (first leap year from 1970)
        yearsFrom1972 =
            ((((daysFrom0 - 730) * DENOMINATOR) / 1461) * 4) /
            DENOMINATOR;

        // subtract 1 year from numOfYears (so 0 year = 01.01.1973) and add 1096 days (= 366 + 365 + 365 days) so 0 years is 01.01.1970 so we can get 0 day of the year
        yearStartDay = ((((yearsFrom1972 - 1) * 1461) / 4) + 1096);

        dayOfYear = daysFrom0 - yearStartDay + 1;
    }

    /**
     * parse date info from timestamp
     */
    function parseTimestamp(uint256 timestamp)
        public
        pure
        returns (
            uint256 date,
            uint256 month,
            uint256 year,
            uint256 daysInMonth
        )
    {
        (, , uint256 dayOfYear, uint256 yearsFrom1972) = getDaysFromTimestamp(
            timestamp
        );

        year = 1972 + yearsFrom1972;

        uint8[12] memory monthsLengths = [
            31,
            yearsFrom1972 % 4 == 0 ? 29 : 28,
            31,
            30,
            31,
            30,
            31,
            31,
            30,
            31,
            30,
            31
        ];

        for (uint256 index = 0; index < 12; index++) {
            uint256 _daysInMonth = monthsLengths[index];

            if (dayOfYear > _daysInMonth) {
                dayOfYear -= _daysInMonth;
                continue;
            }
            date = dayOfYear;
            month = index + 1;
            daysInMonth = _daysInMonth;
            break;
        }
    }

    /**
     * get timestamp of next billing from current date
     */
    function billingTimestampFromDate(
        uint256 date,
        uint256 month,
        uint256 year
    ) public pure returns (uint256 timestamp) {
        timestamp = (((((year - 1973) * 1461) / 4)) + 1096);
        uint8[12] memory monthsLengths = [
            31,
            (year - 1972) % 4 == 0 ? 29 : 28,
            31,
            30,
            31,
            30,
            31,
            31,
            30,
            31,
            30,
            31
        ];

        for (uint256 index = 0; index < 12; index++) {
            uint256 _daysInMonth = monthsLengths[index];

            if (index + 1 == month) {
                // if days in next month lt current date, next billing date eq end of the next month
                if (date > _daysInMonth) date = _daysInMonth;
                break;
            }
            timestamp += _daysInMonth;
        }
        timestamp += date - 1;
        timestamp *= 86_400;
    }

    /**
     * get current date and next billing timestamp from current timestamp
     */
    function parseBillingTimestamp(uint256 timestamp)
        public
        pure
        returns (uint8 billingDay, uint256 nextBillingTimestamp)
    {
        (
            uint256 daysFrom0,
            ,
            uint256 dayOfYear,
            uint256 yearsFrom1972
        ) = getDaysFromTimestamp(timestamp);

        nextBillingTimestamp = daysFrom0;

        uint8[12] memory monthsLengths = [
            31,
            yearsFrom1972 % 4 == 0 ? 29 : 28,
            31,
            30,
            31,
            30,
            31,
            31,
            30,
            31,
            30,
            31
        ];

        for (uint256 index = 0; index < 12; index++) {
            uint256 daysInMonth = monthsLengths[index];

            if (dayOfYear > daysInMonth) {
                dayOfYear -= daysInMonth;
                continue;
            }
            billingDay = uint8(dayOfYear);

            if (index == 11) {
                nextBillingTimestamp += daysInMonth;
                break;
            }
            uint256 daysInNextMonth = monthsLengths[index + 1];
            /**
             * if billingDay gt daysInNextMonth (billingDay == 31 && daysInNextMonth == 28)
             * expiration date will be next month's last day (= 28)
             */
            nextBillingTimestamp += billingDay > daysInNextMonth
                ? (daysInMonth - billingDay + daysInNextMonth)
                : daysInMonth;

            break;
        }

        nextBillingTimestamp *= 86_400;
    }

    /**
     * get timestamp of certain date in next month
     */
    function getTimestampOfNextDate(uint256 timestamp, uint8 date)
        public
        pure
        returns (uint256 nextDateTimestamp)
    {
        (
            ,
            uint256 yearStartDay,
            uint256 dayOfYear,
            uint256 yearsFrom1972
        ) = getDaysFromTimestamp(timestamp);

        nextDateTimestamp = yearStartDay;

        uint8[12] memory monthsLengths = [
            31,
            yearsFrom1972 % 4 == 0 ? 29 : 28,
            31,
            30,
            31,
            30,
            31,
            31,
            30,
            31,
            30,
            31
        ];

        for (uint256 index = 0; index < 12; index++) {
            uint256 daysInMonth = monthsLengths[index];

            if (dayOfYear > daysInMonth) {
                nextDateTimestamp += daysInMonth;
                dayOfYear -= daysInMonth;
                continue;
            }

            if (index == 11) {
                nextDateTimestamp += daysInMonth + date - 1;
                break;
            }
            uint256 daysInNextMonth = monthsLengths[index + 1];

            nextDateTimestamp +=
                daysInMonth +
                (date > daysInNextMonth ? daysInNextMonth : date) -
                1;

            break;
        }

        nextDateTimestamp *= 86_400;
    }
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