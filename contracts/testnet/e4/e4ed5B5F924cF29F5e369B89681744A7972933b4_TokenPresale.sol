/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;



// Part: OpenZeppelin/[email protected]/Address

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

// Part: OpenZeppelin/[email protected]/Context

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

// Part: OpenZeppelin/[email protected]/IERC20

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

// Part: OpenZeppelin/[email protected]/ReentrancyGuard

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

// Part: OpenZeppelin/[email protected]/Ownable

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

// Part: OpenZeppelin/[email protected]/SafeERC20

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

// File: TokenPrivateSale.sol

contract TokenPresale is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 bought;
        uint256 whitelistBought;
        bool claimed;
    }

    uint256 public immutable HARD_CAP;
    uint256 public immutable SOFT_CAP;
    uint256 public immutable MIN_BUY; // per wallet
    uint256 public immutable MAX_BUY; // per wallet

    uint256 public tokenPerRaise; // tokens per 1 ETH RAISE_TOKEN
    uint256 public immutable BUY_INTERVAL;
    uint256 public constant BASE_INTERVAL = 0.01 ether;
    uint256 public constant BARE_MIN = 0.0001 ether;

    uint256 public immutable wl_duration;
    uint256 public immutable public_duration;
    uint256 public saleStart;

    bool public wl_end;
    bool public public_end;
    bool public claimable;

    IERC20 public BUY_TOKEN;
    IERC20 public RAISE_TOKEN;
    IERC20 public WHITELIST_TOKEN;

    uint256 public whitelistedUsers;

    uint256 public totalRaised;
    uint256 public whitelistMin;
    uint256 public tokensToSell;

    mapping(address => UserInfo) public userInfo;
    mapping(address => bool) public whitelist;

    event BoughtToken(address indexed _user, uint256 amount, uint256 _raised);
    event TokenClaimed(address indexed _user, uint256 amount);
    event TokenSet(address _token);
    event FundsClaimed(address _to, uint256 _amount);

    receive() external payable {
        // We do nothing... if people send funds directly that's on them... use the function people
    }

    fallback() external payable {
        // We do nothing... if people send funds directly that's on them... use the function people
    }

    /**
    @param _token token address to be distributed. If NO TOKEN YET, send Address(0)
    @param _owner project owner address (Required)
    @param _whitelistToken token address needed for whitelist
    @param _collectToken token address to be collected (ETH or OTHER) if address == address(0) use native ETH
    @param configs The configs array are the following parameters:
    0 - MIN BUY (has to be at least 0.0001 ether, if MIN is larger than 0.01 the min buy threshold is 0.01)
    1 - MAX BUY (if zero there will be no MAX)
    2 - softcap (can be zero for no soft cap)
    3 - hardcap (can be zero for no cap)
    4 - whitelist token amount to hold for whitelist (if zero the whitelist is not created) IF WHITELIST ADDRESS == ADDRESS(0) 
          then whitelist will need to be added to the mapping
    5 - whitelist timelimit IN HOURS (can be zero to make it manual)
    6 - total tokens to be sold (can be zero if number is pending or airdropped)
    7 - public duration IN HOURS (can be zero, owner will have to manually close the public sale duration)
    8 - start time
    **/

    constructor(
        address _token,
        address _owner,
        address _whitelistToken,
        address _collectToken,
        uint256[9] memory configs
    ) {
        require(_owner != address(0)); // dev:  Need a new owner
        transferOwnership(_owner);
        if (_token != address(0)) BUY_TOKEN = IERC20(_token);
        if (_collectToken != address(0)) RAISE_TOKEN = IERC20(_collectToken);
        if (_whitelistToken != address(0)) {
            WHITELIST_TOKEN = IERC20(_whitelistToken);
            require(configs[4] > 0, "CF4"); // dev: Wrong config on 4, can't add whitelist token and zero requirement.
            whitelistMin = configs[4];
        }
        wl_duration = configs[5] * 1 hours;
        public_duration = configs[7] * 1 hours;
        SOFT_CAP = configs[2];
        HARD_CAP = configs[3];
        require((SOFT_CAP + HARD_CAP) % BASE_INTERVAL == 0, "CF2|3"); //dev: Get good caps, these suck

        require(configs[0] > BARE_MIN, "CF0-P"); // dev: Wrong config on 0 pre actually writting the info
        uint256 interval;
        if (configs[0] >= 0.01 ether) interval = 0.01 ether;
        else interval = BARE_MIN;
        BUY_INTERVAL = interval;
        MIN_BUY = configs[0];
        MAX_BUY = configs[1];
        require(MAX_BUY > MIN_BUY, "CF1"); // dev: Max buy is less than min buy
        tokensToSell = configs[6];
        saleStart = configs[8];
    }

    function buyToken(uint256 _otherAmount) external payable nonReentrant {
        uint256 amount;
        if (address(RAISE_TOKEN) == address(0)) amount = msg.value;
        else {
            require(msg.value == 0);
            amount = _otherAmount;
        }

        UserInfo storage user = userInfo[msg.sender];
        uint256 totalBought = user.bought + user.whitelistBought;
        require(
            amount > 0 &&
                amount % BUY_INTERVAL == 0 &&
                totalBought + amount >= MIN_BUY,
            "Amount or Interval invalid"
        );

        bool isWhitelist = checkTimeLimits();

        require(
            totalBought < MAX_BUY && totalBought + amount <= MAX_BUY,
            "User Cap reached"
        );
        uint256 raised = totalRaised;
        require(
            raised < HARD_CAP && raised + amount <= HARD_CAP,
            "Main cap reached"
        );
        if (isWhitelist) user.whitelistBought += amount;
        else user.bought += amount;
        totalRaised += amount;

        emit BoughtToken(msg.sender, amount, totalRaised);
    }

    function claimToken() external nonReentrant {
        require(claimable, "Sale running");
        require(address(BUY_TOKEN) != address(0), "Token not yet available");
        UserInfo storage user = userInfo[msg.sender];
        require(
            !user.claimed && (user.bought + user.whitelistBought) > 0,
            "Already claimed"
        );
        user.claimed = true;
        uint256 u_claim = user.bought + user.whitelistBought;
        u_claim *= tokenPerRaise;
        BUY_TOKEN.safeTransfer(msg.sender, u_claim);
        emit TokenClaimed(msg.sender, u_claim);
    }

    function startSale(uint256 _startTimestamp) external onlyOwner {
        if (_startTimestamp == 0) {
            saleStart = block.timestamp;
        } else {
            require(saleStart == 0 && _startTimestamp > block.timestamp); // dev: Already set
            saleStart = _startTimestamp;
        }
    }

    function checkTimeLimits() internal returns (bool) {
        require(saleStart > 0 && block.timestamp > saleStart); // dev: Not started yet
        // if no duration of whitelist added
        if (wl_duration == 0) {
            if (wl_end) {
                if (public_duration == 0) {
                    if (public_end) {
                        require(false); // dev: Sale ended
                    }
                } else {
                    require(
                        block.timestamp <
                            saleStart + wl_duration + public_duration
                    ); // dev: Sale over
                }
                return false;
            } else {
                require(getWhitelistStatus(msg.sender)); // dev: Not in whitelist
                return true;
            }
        } else {
            if (block.timestamp < saleStart + wl_duration) {
                require(getWhitelistStatus(msg.sender)); // dev: Not whitelisted
                return true;
            } else {
                if (public_duration == 0) {
                    if (public_end) {
                        require(false); // dev: Sale ended
                    }
                } else {
                    require(
                        block.timestamp <
                            saleStart + wl_duration + public_duration
                    ); // dev: Sale over
                }
                return false;
            }
        }
    }

    function getWhitelistStatus(address _user) internal returns (bool) {
        if (address(WHITELIST_TOKEN) == address(0)) return whitelist[_user];
        uint256 bal = WHITELIST_TOKEN.balanceOf(_user);
        return bal >= whitelistMin;
    }

    function manualEndWhitelist() external onlyOwner {
        require(wl_duration == 0, "Duration set");
        wl_end = true;
    }

    function manualEndPublic() external onlyOwner {
        require(public_duration == 0, "Duration set");
        public_end = true;
    }

    /// @notice Set the token if the token was not set originally
    /// @param _token the address of the new token;
    function setToken(address _token) external onlyOwner {
        require(address(BUY_TOKEN) == address(0), "Token Set");
        BUY_TOKEN = IERC20(_token);
        emit TokenSet(_token);
    }

    function addWhitelist(address _user) external onlyOwner {
        require(!whitelist[_user], "Already whitelisted");
        whitelist[_user] = true;
        whitelistedUsers++;
    }

    function whitelistMultiple(address[] calldata _users) external onlyOwner {
        uint256 len = _users.length;
        require(len > 0, "Non zero");
        for (uint256 i = 0; i < len; i++) {
            whitelist[_users[i]] = true;
        }
        whitelistedUsers += len;
    }

    function tokensClaimable() external onlyOwner {
        require(
            public_end ||
                block.timestamp > saleStart + wl_duration + public_duration
        ); //dev: Sale running
        require(
            address(BUY_TOKEN) != address(0) &&
                BUY_TOKEN.balanceOf(address(this)) > 0
        ); // dev: no tokens here
        uint256 current;
        if (address(RAISE_TOKEN) == address(0)) current = address(this).balance;
        else current = RAISE_TOKEN.balanceOf(address(this));
        tokenPerRaise = BUY_TOKEN.balanceOf(address(this)) / current;
        claimable = true;
    }

    /// @notice Withdraw the raised funds
    /// @dev withdraw the raised funds to the owner wallet
    function withdraw() external payable onlyOwner {
        uint256 raised;
        bool succ;
        if (address(RAISE_TOKEN) == address(0)) {
            raised = address(this).balance;
            (succ, ) = payable(msg.sender).call{value: raised}("");
            require(succ, "Unsuccessful, withdraw");
        } else {
            raised = RAISE_TOKEN.balanceOf(address(this));
            succ = RAISE_TOKEN.transfer(msg.sender, raised);
        }
        emit FundsClaimed(msg.sender, raised);
    }

    function saleStatus()
        external
        view
        returns (
            bool _saleStat,
            bool _wl,
            bool _pl
        )
    {
        _saleStat = saleStart > 0 && block.timestamp > saleStart;
        _wl = wl_duration > 0
            ? block.timestamp > saleStart + wl_duration
            : !wl_end;
        _pl = public_duration > 0 && !wl_end
            ? block.timestamp > saleStart + wl_duration + public_duration
            : !public_end;
    }
}