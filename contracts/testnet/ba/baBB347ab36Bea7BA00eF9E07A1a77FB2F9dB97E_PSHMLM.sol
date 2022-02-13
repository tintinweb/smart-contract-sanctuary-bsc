// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./PSHRewarder.sol";
import "./DailyAccessController.sol";

/// @title DAO.PSH IPF MLM
/// @author PSH Team
/// @notice This contract is the core of PSH MLM.
/// @dev The contract stores the dependency between the participants and implements the distribution of funds
contract PSHMLM is Ownable, PSHRewarder, DailyAccessController {
  using SafeERC20 for IERC20;

  /// @dev Last user's ID (aka total users count)
  uint256 public currentUserID;
  /// @dev token that accepted as payment method
  IERC20 public paymentToken;
  /// @dev base subscription duration
  uint256 private subscriptionDuration;
  /// @dev time until the end of the subscription from which it can be renewed
  uint256 private subscriptionRenewalOffset;
  /// @dev subscription renewal price
  uint256 public subscriptionPrice;
  uint256 public fee;
  address public feeReceiver;

  /// @dev Stores user info by id
  /// @return exists does user exists
  /// @return wallet user's ethereum wallet address
  /// @return referrer user's referrer id
  /// @return subscriptionExpiry subscription expiration timestamp (in seconds, unixtipestamp)
  mapping(uint256 => User) public users;

  /// @notice Resolves ethereum address to user id.
  /// @dev Returns 0 when not found.
  /// @return user id
  mapping(address => uint256) public userWallets;

  mapping(uint256 => uint256[]) private referrals;

  struct User {
    bool exists;
    address wallet;
    uint256 referrer;
    uint256 subscriptionExpiry;
  }

  struct Ref {
    uint256 id;
    address wallet;
    uint256 refsCount;
    bool subscriptionActive;
  }

  /// @dev Emits on user registration
  event RegisterUserEvent(
    address indexed user,
    address indexed referrer,
    uint256 userID,
    uint256 referrerID
  );
  /// @dev Emits on subscription renewal
  event SubscriptionRenewalEvent(
    address indexed user,
    uint256 expirationTime,
    uint256 userID
  );
  /// @dev Emits on wallet address change
  event WalletChangeEvent(
    address indexed oldWallet,
    address indexed newWallet,
    uint256 userID
  );

  // @dev Emits on payment
  event PaymentEvent(uint256 sender, uint256 amount);

  /// @dev Emits on token transfer
  event TransferEvent(uint256 sender, uint256[] recipients, uint256 amount);

  /// @param rootUser root wallet or contract address
  /// @param token payment token address
  /// @param price initial subscription price
  constructor(
    address rootUser,
    address token,
    address _feeReceiver,
    uint256 price,
    uint256 _fee,
    address rewardToken,
    uint256 rewardAmount
  )
    PSHRewarder(rewardToken, rewardAmount)
    DailyAccessController(DailyAccessController.Parity.EVEN, 0)
  {
    require(rootUser != address(0), "firstUser is zero");
    require(token != address(0), "payment token is zero");
    require(_feeReceiver != address(0), "feeReceiver is zero");
    require(price > 0, "price is zero");
    require(fee < price, "fee > price");

    subscriptionPrice = price;
    fee = _fee;
    feeReceiver = _feeReceiver;
    subscriptionDuration = 30 days;
    subscriptionRenewalOffset = 4 days;

    paymentToken = IERC20(token);

    currentUserID++;

    users[currentUserID] = User({
      exists: true,
      wallet: rootUser,
      referrer: 1,
      subscriptionExpiry: 1 << 37
    });

    userWallets[rootUser] = currentUserID;

    emit RegisterUserEvent(rootUser, rootUser, currentUserID, currentUserID);

    emit SubscriptionRenewalEvent(
      rootUser,
      users[currentUserID].subscriptionExpiry,
      currentUserID
    );
  }

  // PUBLIC / EXTERNAL ==================================================================

  /// @notice User registration point
  /// @param referrer referrer id
  function registerUser(uint256 referrer) public onlyAllowedDays solvent {
    require(referrer > 0 && referrer <= currentUserID, "Invalid referrer ID");
    require(userWallets[msg.sender] == 0, "User already registered");
    createUser(msg.sender, referrer);
  }

  function createUser(address wallet, uint256 referrer) private {
    currentUserID++;

    users[currentUserID] = User({
      exists: true,
      wallet: wallet,
      referrer: referrer,
      subscriptionExpiry: 0
    });

    userWallets[msg.sender] = currentUserID;

    // Push into referrals list
    referrals[referrer].push(currentUserID);

    emit RegisterUserEvent(
      msg.sender,
      users[referrer].wallet,
      currentUserID,
      referrer
    );

    renewSubscription(currentUserID);
  }

  /// @dev Allows to renew subscription for `subscriptionDuration`
  function renewSubscription() public solvent {
    require(userWallets[msg.sender] != 0, "User not found");
    require(isCanRenew(), "Renewal not yet available");

    renewSubscription(userWallets[msg.sender]);
  }

  /// @notice Allows user to change wallet. NOTE: This action is irreversible
  /// @param newWalletAddress new wallet address
  function changeWallet(address newWalletAddress) external {
    require(userWallets[msg.sender] != 0, "User not found");
    require(userWallets[newWalletAddress] == 0, "User already registered");

    uint256 userid = userWallets[msg.sender];
    userWallets[msg.sender] = 0;
    userWallets[newWalletAddress] = userid;
    users[userid].wallet = newWalletAddress;
    emit WalletChangeEvent(msg.sender, newWalletAddress, userid);
  }

  /// @dev Changes payment token address. Should be ERC20 token.
  function changePaymentToken(address newToken) external onlyOwner {
    require(newToken != address(0), "Address cannot be zero");
    paymentToken = IERC20(newToken);
  }

  function setSubscriptionPrice(uint256 newPrice) external onlyOwner {
    require(newPrice > 0, "cannot be zero");
    require(newPrice > fee, "price < fee");

    subscriptionPrice = newPrice;
  }

  function setFee(uint256 newFee) external onlyOwner {
    require(subscriptionPrice > newFee, "price < fee");

    fee = newFee;
  }

  function setFeeReceiver(address newFeeReceiver) external onlyOwner {
    require(newFeeReceiver != address(0), "address is zero");
    feeReceiver = newFeeReceiver;
  }

  // private ===========================================================================
  function findAcceptableRecipients(uint256 _userid, uint256 depth)
    private
    view
    returns (uint256[] memory)
  {
    uint256[] memory recipients = new uint256[](depth);
    for (uint256 i = 0; i < depth; i++) {
      recipients[i] = findAcceptableRecipient(_userid, i);
    }
    return recipients;
  }

  function findAcceptableRecipient(uint256 _userid, uint256 depth)
    private
    view
    returns (uint256)
  {
    uint256 recipientID = _userid;

    for (uint256 i = 0; i < depth + 1; i++) {
      recipientID = users[recipientID].referrer;

      if (recipientID == 1) break;
    }

    if (
      isSubscriptionActive(recipientID) &&
      isQualifiedFor(recipientID, depth + 1)
    ) {
      return recipientID;
    }

    return 1;
  }

  function renewSubscription(uint256 _userid) private {
    users[_userid].subscriptionExpiry = (users[_userid].subscriptionExpiry >
      block.timestamp)
      ? users[_userid].subscriptionExpiry + subscriptionDuration // subscription not yet expired
      : block.timestamp + subscriptionDuration; // subscription already expired

    payForSubscription(_userid);

    emit SubscriptionRenewalEvent(
      msg.sender,
      users[_userid].subscriptionExpiry,
      _userid
    );

    sendReward(msg.sender);
  }

  /// @dev Implements payments
  function payForSubscription(uint256 _userid) private {
    emit PaymentEvent(_userid, subscriptionPrice);
    uint256 amount = (subscriptionPrice - fee) / 5;

    paymentToken.safeTransferFrom(msg.sender, feeReceiver, fee);

    uint256[] memory recipients = findAcceptableRecipients(_userid, 5);
    for (uint256 i = 0; i < recipients.length; i++) {
      paymentToken.safeTransferFrom(
        msg.sender,
        users[recipients[i]].wallet,
        amount
      );
    }
    emit TransferEvent(_userid, recipients, amount);
  }

  // VIEWS ==============================================================================
  function qualificationLevel(uint256 userid) public view returns (uint256) {
    return maxQualifiedFor(userid, 5);
  }

  function maxQualifiedFor(uint256 userid, uint256 level)
    private
    view
    returns (uint256)
  {
    uint256[] memory refs = referrals[userid];
    uint256 maxQualified = 0;
    for (uint256 i = 0; i < refs.length; i++) {
      if (isSubscriptionActive(refs[i])) maxQualified++;
      if (maxQualified == level) break;
    }
    return maxQualified;
  }

  function isQualifiedFor(uint256 userid, uint256 level)
    private
    view
    returns (bool)
  {
    return maxQualifiedFor(userid, level) == level;
  }

  function isCanRenew() private view returns (bool) {
    uint256 userid = userWallets[msg.sender];
    return isCanRenew(userid);
  }

  /// @dev Сan the user renew the subscription or not
  function isCanRenew(uint256 userid) public view returns (bool) {
    return (users[userid].exists &&
      users[userid].subscriptionExpiry - subscriptionRenewalOffset <
      block.timestamp);
  }

  /// @return current subscription state
  function isSubscriptionActive(uint256 _userid) public view returns (bool) {
    return (users[_userid].subscriptionExpiry > block.timestamp);
  }

  /// @notice Returns total referrals count and referrals list
  /// @dev Referral list returns as Ref structs array
  /// @param  userid user id
  /// @param offset specify number of referrals to skip
  /// @param limit specify number of referrals to return
  /// @return tRefsCount total referrals count for specified userid
  /// @return refList array of Ref structs
  function getReferrals(
    uint256 userid,
    uint256 offset,
    uint256 limit
  ) external view returns (uint256 tRefsCount, Ref[] memory refList) {
    tRefsCount = referrals[userid].length;
    refList = new Ref[](limit);

    uint256 maxLimit = ((tRefsCount - offset) < limit)
      ? tRefsCount - offset
      : limit;
    for (uint256 i = 0; i < maxLimit; i++) {
      uint256 refid = referrals[userid][i + offset];
      refList[i] = Ref(
        refid,
        users[refid].wallet,
        referrals[refid].length,
        isSubscriptionActive(refid)
      );
    }
  }

  /// @notice Returns caller's solvency report
  /// @return _pass Does caller pass solvency check or not
  /// @return _tokenAddress payment token address
  /// @return _userBalance caller's payment token balanceOf
  /// @return _currentAllowance caller's current allowance
  /// @return _subscriptionPrice subscription price
  function solvencyCheck(address wallet)
    public
    view
    returns (
      bool _pass,
      address _tokenAddress,
      uint256 _userBalance,
      uint256 _currentAllowance,
      uint256 _subscriptionPrice
    )
  {
    uint256 userBalance = paymentToken.balanceOf(wallet);

    uint256 currentAllowance = paymentToken.allowance(wallet, address(this));

    bool pass = (currentAllowance >= subscriptionPrice &&
      userBalance >= subscriptionPrice);

    return (
      pass,
      address(paymentToken),
      userBalance,
      currentAllowance,
      subscriptionPrice
    );
  }

  /// @notice Returns summary info about user by ID
  /// @param userid user id
  /// @return id user id
  /// @return wallet user wallet address
  /// @return subscriptionExpiry subscription expiration timestamp (in seconds, unixtipestamp)
  /// @return refsCount direct referrals count
  /// @return referrer referrer's id
  function getUserInfo(uint256 userid)
    public
    view
    returns (
      uint256 id,
      address wallet,
      uint256 subscriptionExpiry,
      uint256 refsCount,
      uint256 referrer
    )
  {
    return (
      userid,
      users[userid].wallet,
      users[userid].subscriptionExpiry,
      referrals[userid].length,
      users[userid].referrer
    );
  }

  /// @notice Same as getUserInfo, but accepts wallet address instead of user id
  /// @param _wallet ethereum wallet address
  /// @return id user id
  /// @return wallet user wallet address
  /// @return subscriptionExpiry subscription expiration timestamp (in seconds, unixtipestamp)
  /// @return refsCount direct referrals count
  /// @return referrer referrer's id
  function getUserInfoByWallet(address _wallet)
    external
    view
    returns (
      uint256 id,
      address wallet,
      uint256 subscriptionExpiry,
      uint256 refsCount,
      uint256 referrer
    )
  {
    return getUserInfo(userWallets[_wallet]);
  }

  // MODIFIERS ==========================================================================

  modifier solvent() {
    (bool pass, , , , ) = solvencyCheck(msg.sender);
    require(pass, "Insufficient funds or allowance");
    _;
  }
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IPSHx.sol";

abstract contract PSHRewarder is Ownable {
  IPSHx public rewardToken;
  uint256 public rewardAmount;

  constructor(address _rewardToken, uint256 _rewardAmount) {
    require(_rewardToken != address(0), "reward token is zero");
    rewardToken = IPSHx(_rewardToken);
    rewardAmount = _rewardAmount;
  }

  function sendReward(address recipient) internal {
    uint256 rewardLeftover = rewardToken.cap() - rewardToken.totalSupply();
    if (rewardLeftover < rewardAmount) return;
    rewardToken.mintWithLock(recipient, rewardAmount);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract DailyAccessController is Ownable {
  enum Parity {
    EVEN,
    ODD
  }

  Parity private _allowedParity;
  int256 private _timeShift;
  bool private _isEnabled;

  constructor(Parity allowedParity, int256 timeShift) {
    setParity(allowedParity);
    setTimeShift(timeShift);
    setAccessControllerEnabled(true);
  }

  //============================== STATE CHANGE

  function setParity(Parity allowedParity) public onlyOwner {
    _allowedParity = allowedParity;
  }

  function setTimeShift(int256 timeShift) public onlyOwner {
    _timeShift = timeShift;
  }

  function setAccessControllerEnabled(bool state) public onlyOwner {
    _isEnabled = state;
  }

  //============================== VIEWS
  function isAccessControllerEnabled() public view returns (bool) {
    return _isEnabled;
  }

  function getAllowedParity() public view returns (Parity) {
    return _allowedParity;
  }

  function getTimeShift() public view returns (int256) {
    return _timeShift;
  }

  function isRegistrationAllowed() public view returns (bool) {
    return
      uint256((int256(fullDaysGone()) % 2)) == uint256(_allowedParity) ||
      !_isEnabled;
  }

  function timeLeft() external view returns (uint256) {
    return ((fullDaysGone() + 1) * (3600 * 24)) - timestampWithTimeShift();
  }

  function nextStateChange() external view returns (uint256) {
    return uint256(int256((fullDaysGone() + 1) * (3600 * 24)) - _timeShift);
  }

  //============================== PRIVATE
  function fullDaysGone() private view returns (uint256) {
    return timestampWithTimeShift() / (3600 * 24);
  }

  function timestampWithTimeShift() private view returns (uint256) {
    return uint256((int256(block.timestamp) + _timeShift));
  }

  //============================== MODIFIERS
  modifier onlyAllowedDays() {
    require(isRegistrationAllowed(), "Registration not allowed today");
    _;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPSHx is IERC20 {
  function mintWithLock(address account, uint256 amount) external;

  function cap() external view returns (uint256);
}