// SPDX-License-Identifier: MIT
// Developed by: dxsoftware.net

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

library Errors {
  string public constant ZERO_GROW_K_PERIOD = "ZERO_GROW_K_PERIOD";
  string public constant NOT_DEPOSIT_OWNER = "NOT_DEPOSIT_OWNER";
  string public constant DEPOSIT_IS_LOCKED = "DEPOSIT_IS_LOCKED";
  string public constant INSUFFICIENT_DEPOSIT = "INSUFFICIENT_DEPOSIT";
  string public constant ZERO_TOTAL_RATING = "ZERO_TOTAL_RATING";
  string public constant ZERO_ADDRESS = "ZERO_ADDRESS";
  string public constant SMALL_END_K = "SMALL_END_K";
  string public constant ZERO_DEPOSIT_AMOUNT = "ZERO_DEPOSIT_AMOUNT";
  string public constant NOT_FOUND = "NOT_FOUND";
  string public constant WRONG_INDEX = "WRONG_INDEX";
  string public constant DATA_INCONSISTENCY = "DATA_INCONSISTENCY";
  string public constant INSUFFICIENT_SWAP = "INSUFFICIENT_SWAP";
}

library Periods {
  uint256 public constant ZERO_MONTHS = 0;
  uint256 public constant THREE_MONTHS = 7948800;
  uint256 public constant SIX_MONTHS = 15811200;
  uint256 public constant ONE_YEAR = 31536000;
}

library Statuses {
  uint256 public constant ROYAL = 1;
  uint256 public constant VIP = 2;
  uint256 public constant _1144 = 3;
}

contract SummitKodaStaking is Ownable, ReentrancyGuard {
  using SafeERC20 for IERC20;
  using EnumerableSet for EnumerableSet.UintSet;

  event DepositPut(address indexed user, uint40 lockFor, uint256 indexed id, uint256 amount);
  event DepositWithdrawn(address indexed user, uint256 indexed id, uint256 amount, uint256 rest);
  event SharePremium(address indexed user, uint256 amount, uint256 premiumPerRatingPoint, uint256 totalRating);
  event PremiumPaid(address indexed user, uint256 amount);

  struct Deposit {
    address user;
    uint40 depositAt;
    uint40 lockFor;
    uint256 amount;
    bool isWithdrawable;
  }

  mapping(uint256 => uint256) public statusBoosts;
  mapping(address => uint256) public statuses;
  mapping(uint256 => uint256) public correspondingFakeDepositId;
  mapping(address => EnumerableSet.UintSet[]) internal fakeDeposits;
  mapping(address => uint256) internal fakeDepositsIndex;

  mapping(address => uint256) public userTotalDeposits; // user => amount
  mapping(address => mapping(uint256 => uint256)) public userDeposits; // user => lockFor => amount
  mapping(address => mapping(address => uint256)) public claimedTokenAmounts; // token => user => amount
  mapping(address => mapping(address => uint256)) public ratings; // token => user => rating

  mapping(address => mapping(uint256 => uint256)) public apys; // token => lockFor => apy/rating
  mapping(uint256 => uint256) public lockAmounts; // lockFor => amount

  address public immutable stakingToken;
  address public immutable kodaToken;
  address public immutable kapexToken;

  address public penaltyReceiver;

  uint256 internal nextDepositId;

  mapping(address => uint256) public totalRatings;
  mapping(address => uint256) public tokenPerRatingPoints;

  uint256 public constant PREMIUM_PER_RATING_POINT_BASE = 10**18;

  mapping(uint256 => Deposit) public deposits;
  mapping(address => EnumerableSet.UintSet) internal userDepositIds;

  mapping(uint256 => uint256) public penalties;

  mapping(address => mapping(address => uint256)) public tokensEarned; // token => user => amount

  constructor(
    address _kodaToken,
    address _kapexToken,
    address _stakingToken,
    address _penaltyReceiver
  ) {
    kodaToken = _kodaToken;
    kapexToken = _kapexToken;
    stakingToken = _stakingToken;
    penaltyReceiver = _penaltyReceiver;

    apys[_kodaToken][Periods.ZERO_MONTHS] = 55;
    apys[_kodaToken][Periods.THREE_MONTHS] = 80;
    apys[_kodaToken][Periods.SIX_MONTHS] = 105;
    apys[_kodaToken][Periods.ONE_YEAR] = 150;

    apys[_kapexToken][Periods.ZERO_MONTHS] = 0;
    apys[_kapexToken][Periods.THREE_MONTHS] = 80;
    apys[_kapexToken][Periods.SIX_MONTHS] = 105;
    apys[_kapexToken][Periods.ONE_YEAR] = 150;

    penalties[Periods.ZERO_MONTHS] = 0;
    penalties[Periods.THREE_MONTHS] = 2000;
    penalties[Periods.SIX_MONTHS] = 3000;
    penalties[Periods.ONE_YEAR] = 5000;

    statusBoosts[Statuses._1144] = 200;
    statusBoosts[Statuses.VIP] = 400;
    statusBoosts[Statuses.ROYAL] = 600;
  }

  function setStatus(address _user, uint256 _status) internal {
    statuses[_user] = _status;

    if (_status == 0) {
      for (uint256 i = 0; i < fakeDeposits[_user][fakeDepositsIndex[_user]].length(); ++i) {
        uint256 fakeDepositId = fakeDeposits[_user][fakeDepositsIndex[_user]].at(i);
        withdrawDeposit(fakeDepositId, deposits[fakeDepositId].amount);
      }

      fakeDeposits[_user].push();
      fakeDepositsIndex[_user]++;
    }
  }

  function setStatuses(address[] calldata _users, uint256[] calldata _statuses) external onlyOwner {
    for (uint256 userIndex = 0; userIndex < _users.length; ++userIndex) {
      address _user = _users[userIndex];
      uint256 _status = _statuses[userIndex];

      setStatus(_user, _status);
    }
  }

  function setStatusBoost(uint256 _status, uint256 _boost) external onlyOwner {
    statusBoosts[_status] = _boost;
  }

  function setPenaltyReceiver(address _penaltyReceiver) external onlyOwner {
    penaltyReceiver = _penaltyReceiver;
  }

  function setApy(
    address _token,
    uint256 _lockFor,
    uint256 _apy
  ) external onlyOwner {
    apys[_token][_lockFor] = _apy;
  }

  function setPenalty(uint256 _lockFor, uint256 _penalty) external onlyOwner {
    penalties[_lockFor] = _penalty;
  }

  function getUserDepositIds(address user) external view returns (uint256[] memory) {
    uint256[] memory depositIds = new uint256[](userDepositIds[user].length());
    for (uint256 i = 0; i < userDepositIds[user].length(); ++i) {
      depositIds[i] = userDepositIds[user].at(i);
    }
    return depositIds;
  }

  function getUserDepositIdAtIndex(address user, uint256 index) external view returns (uint256) {
    return userDepositIds[user].at(index);
  }

  function getUserDepositsLength(address user) external view returns (uint256) {
    return userDepositIds[user].length();
  }

  function sharePremium(address premiumToken, uint256 amount) external {
    require(totalRatings[premiumToken] > 0, Errors.ZERO_TOTAL_RATING);

    tokenPerRatingPoints[premiumToken] += (amount * PREMIUM_PER_RATING_POINT_BASE) / totalRatings[premiumToken];
    emit SharePremium(msg.sender, amount, tokenPerRatingPoints[premiumToken], totalRatings[premiumToken]);
    IERC20(premiumToken).safeTransferFrom(msg.sender, address(this), amount);
  }

  function claimPremium(address premiumToken) external {
    claimedTokenAmounts[premiumToken][msg.sender] = _claimPremium(premiumToken, msg.sender);
  }

  function _claimPremium(address premiumToken, address beneficiary) private returns (uint256) {
    uint256 total = (ratings[premiumToken][beneficiary] * tokenPerRatingPoints[premiumToken]) /
      PREMIUM_PER_RATING_POINT_BASE;
    uint256 _claimedAmount = claimedTokenAmounts[premiumToken][beneficiary];

    if (total <= _claimedAmount) {
      return _claimedAmount;
    }

    uint256 rest = total - _claimedAmount;

    emit PremiumPaid(msg.sender, rest);

    tokensEarned[premiumToken][beneficiary] += rest;
    IERC20(premiumToken).safeTransfer(beneficiary, rest);

    return total;
  }

  function premiumOf(address premiumToken, address user) external view returns (uint256) {
    uint256 total = (ratings[premiumToken][user] * tokenPerRatingPoints[premiumToken]) / PREMIUM_PER_RATING_POINT_BASE;
    uint256 _claimedAmount = claimedTokenAmounts[premiumToken][user];
    if (total <= _claimedAmount) {
      return 0;
    }
    uint256 rest = total - _claimedAmount;
    return rest;
  }

  function putDeposit(uint256 amount, uint40 lockFor) external returns (uint256) {
    IERC20(stakingToken).safeTransferFrom(msg.sender, address(this), amount);

    uint256 depositId = deposit(msg.sender, amount, lockFor, true);
    uint256 fakeAmount = (amount * statusBoosts[statuses[msg.sender]]) / 10000;

    if (fakeAmount > 0) {
      uint256 fakeDepositId = putFakeDeposit(msg.sender, fakeAmount, lockFor);
      correspondingFakeDepositId[depositId] = fakeDepositId;
    }

    return depositId;
  }

  function putFakeDeposit(
    address user,
    uint256 amount,
    uint40 lockFor
  ) internal returns (uint256) {
    uint256 fakeDepositId = deposit(user, amount, lockFor, false);

    if (fakeDepositsIndex[user] == fakeDeposits[user].length) {
      fakeDeposits[user].push();
    }

    fakeDeposits[user][fakeDepositsIndex[user]].add(fakeDepositId);
    return fakeDepositId;
  }

  function deposit(
    address beneficiary,
    uint256 amount,
    uint40 lockFor,
    bool isWithdrawable
  ) private returns (uint256) {
    _claimPremium(kodaToken, beneficiary);
    _claimPremium(kapexToken, beneficiary);

    uint256 depositId = nextDepositId++;
    deposits[depositId] = Deposit({
      user: beneficiary,
      depositAt: uint40(block.timestamp),
      amount: amount,
      lockFor: lockFor,
      isWithdrawable: isWithdrawable
    });

    uint256 kodaDeltaRating = amount * apys[kodaToken][lockFor];
    uint256 kapexDeltaRating = amount * apys[kapexToken][lockFor];

    claimedTokenAmounts[kodaToken][beneficiary] =
      ((ratings[kodaToken][beneficiary] + kodaDeltaRating) * tokenPerRatingPoints[kodaToken]) /
      PREMIUM_PER_RATING_POINT_BASE;
    claimedTokenAmounts[kapexToken][beneficiary] =
      ((ratings[kapexToken][beneficiary] + kapexDeltaRating) * tokenPerRatingPoints[kapexToken]) /
      PREMIUM_PER_RATING_POINT_BASE;

    ratings[kodaToken][beneficiary] += kodaDeltaRating;
    ratings[kapexToken][beneficiary] += kapexDeltaRating;

    totalRatings[kodaToken] += kodaDeltaRating;
    totalRatings[kapexToken] += kapexDeltaRating;

    if (isWithdrawable) {
      userTotalDeposits[beneficiary] += amount;
    }
    userDeposits[beneficiary][lockFor] += amount;
    lockAmounts[lockFor] += amount;

    require(userDepositIds[beneficiary].add(depositId), Errors.DATA_INCONSISTENCY);

    emit DepositPut(beneficiary, lockFor, depositId, amount);

    return depositId;
  }

  function withdrawDeposit(uint256 depositId, uint256 amount) public {
    Deposit memory deposit = deposits[depositId];

    _claimPremium(kodaToken, deposit.user);
    _claimPremium(kapexToken, deposit.user);

    if (deposit.amount < amount) {
      revert(Errors.INSUFFICIENT_DEPOSIT);
    }
    // deposit.amount >= amount
    require(deposit.user == msg.sender || owner() == msg.sender, Errors.NOT_DEPOSIT_OWNER);
    require(userDepositIds[deposit.user].contains(depositId), Errors.DATA_INCONSISTENCY);

    uint256 kodaDeltaRating = amount * apys[kodaToken][deposit.lockFor];
    uint256 kapexDeltaRating = amount * apys[kapexToken][deposit.lockFor];

    if (deposit.isWithdrawable) {
      userTotalDeposits[deposit.user] -= amount;
    }
    userDeposits[deposit.user][deposit.lockFor] -= amount;
    lockAmounts[deposit.lockFor] -= amount;

    claimedTokenAmounts[kodaToken][deposit.user] =
      ((ratings[kodaToken][deposit.user] - kodaDeltaRating) * tokenPerRatingPoints[kodaToken]) /
      PREMIUM_PER_RATING_POINT_BASE;
    claimedTokenAmounts[kapexToken][deposit.user] =
      ((ratings[kapexToken][deposit.user] - kapexDeltaRating) * tokenPerRatingPoints[kapexToken]) /
      PREMIUM_PER_RATING_POINT_BASE;

    ratings[kodaToken][deposit.user] -= kodaDeltaRating;
    ratings[kapexToken][deposit.user] -= kapexDeltaRating;

    totalRatings[kodaToken] -= kodaDeltaRating;
    totalRatings[kapexToken] -= kapexDeltaRating;

    uint256 fakeDepositId = correspondingFakeDepositId[depositId];

    if (deposit.amount > amount) {
      deposit.amount -= amount;
      emit DepositWithdrawn(deposit.user, depositId, amount, deposit.amount);
    } else {
      // deposit.amount == amount, because of require condition (take care!)
      delete deposits[depositId]; // free up storage slot
      require(userDepositIds[deposit.user].remove(depositId), Errors.DATA_INCONSISTENCY);
      if (fakeDeposits[deposit.user].length > fakeDepositsIndex[deposit.user]) {
        fakeDeposits[deposit.user][fakeDepositsIndex[deposit.user]].remove(fakeDepositId);
      }
      emit DepositWithdrawn(deposit.user, depositId, amount, 0);
    }

    if (fakeDepositId != 0) {
      if (deposits[fakeDepositId].user != address(0)) {
        withdrawDeposit(fakeDepositId, deposits[fakeDepositId].amount);
      }
      correspondingFakeDepositId[depositId] = 0;
    }

    if (!deposit.isWithdrawable) {
      return;
    }

    if (block.timestamp < deposit.depositAt + deposit.lockFor) {
      uint256 penalty = (amount * penalties[deposit.lockFor]) / 10000;
      amount -= penalty;

      IERC20(stakingToken).safeTransfer(penaltyReceiver, penalty);
    }

    IERC20(stakingToken).safeTransfer(deposit.user, amount);
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
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
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
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