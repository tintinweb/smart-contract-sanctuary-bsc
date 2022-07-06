/**
 *Submitted for verification at BscScan.com on 2022-07-06
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.9;


// 
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
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

// 
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */

// 
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)
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

// 
contract HmineMain is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct User {
        string nickname;
        address user;
        uint256 amount;
        uint256 reward;
    }

    // dead address to receive "burnt" tokens
    address public constant FURNACE =
        0x000000000000000000000000000000000000dEaD;

    address[4] public management = [
        0x5C9dE63470D0D6d8103f7c83F1Be4F55998706FC, // 0 Loft
        0x2165fa4a32B9c228cD55713f77d2e977297D03e8, // 1 Ghost
        0x70F5FB6BE943162545a496eD120495B05dC5ce07, // 2 Mike
        0x36b13280500AEBC5A75EbC1e9cB9Bf1b6A78a95e // 3 Miko
    ];

    address public constant safeHolders =
        0xcD8dDeE99C0c4Be4cD699661AE9c00C69D1Eb4A8;

    address public bankroll = 0x25be1fcF5F51c418a0C30357a4e8371dB9cf9369; // 4 Way Multisig wallet
    address public rewardGiver = 0x2165fa4a32B9c228cD55713f77d2e977297D03e8; // Ghost
    address public immutable currencyToken; // Will likely be DAI
    address public immutable hmineToken;

    uint256 public startTime;
    uint256 public index;
    uint256 public totalSold; // The contract will start with 100,000 Sold HMINE.
    uint256 public totalStaked; // The contract will start with 100,000 Staked HMINE.
    uint256 public currentPrice = 7e18; // The price is divisible by 1e18.  So in this case 7.00 is the current price.
    uint256 public constant roundIncrement = 1_000e18;
    uint256 public rewardTotal;
    uint256 public constant maxSupply = 200_000e18;
    uint256 public constant firstRound = 100_000e18;
    uint256 public constant secondRound = 101_000e18;

    mapping(address => uint256) public userIndex;
    mapping(uint256 => User) public users;

    // The user's pending reward is user's balance multiplied by the accumulated reward per share minus the user's reward debt.
    // The user's reward debt is always set to balance multiplied by the accumulated reward per share when reward's are distributed
    // (or balance changes, which also forces distribution), such that the diference immediately after distribution is always zero (nothing left)
    uint256 public accRewardPerShare;
    mapping(address => uint256) public userRewardDebt;

    modifier onlyRewardGiver() {
        require(msg.sender == rewardGiver, "Unauthorized");
        _;
    }

    modifier isRunning(bool _flag) {
        require(
            (startTime != 0 && startTime <= block.timestamp) == _flag,
            "Unavailable"
        );
        _;
    }

    constructor(address _currenctyToken, address _hmineToken) {
        currencyToken = _currenctyToken;
        hmineToken = _hmineToken;
    }

    // Start the contract.
    // Will not initialize if already started.
    function initialize(uint256 _startTime)
        external
        onlyOwner
        isRunning(false)
    {
        startTime = _startTime;

        // Admin is supposed to send an additional 100k HMINE to the contract
        uint256 _balance = IERC20(hmineToken).balanceOf(address(this));
        require(_balance == maxSupply, "Missing hmine balance");
    }

    // Used to initally migrate the user data from the sacrifice round. Can be run multiple times. Do 10 at a time.
    function migrateSacrifice(User[] memory _users)
        external
        onlyOwner
        nonReentrant
        isRunning(false)
    {
        uint256 _amountSum = 0;
        uint256 _rewardSum = 0;
        for (uint256 _i = 0; _i < _users.length; _i++) {
            address _userAddress = _users[_i].user;
            require(_userAddress != address(0), "Invalid address");
            require(userIndex[_userAddress] == 0, "Duplicate user");
            uint256 _index = _assignUserIndex(_userAddress);
            users[_index] = _users[_i];
            _amountSum += _users[_i].amount;
            _rewardSum += _users[_i].reward;
        }

        // Admin sends send initial token deposits to the contract
        IERC20(hmineToken).safeTransferFrom(
            msg.sender,
            address(this),
            _amountSum
        );
        totalSold += _amountSum;
        totalStaked += _amountSum;

        // Admin must send initial rewards to the contract
        IERC20(currencyToken).safeTransferFrom(
            msg.sender,
            address(this),
            _rewardSum
        );
        rewardTotal += _rewardSum;

        // Sanity check, pre-sale must not exceed 100k
        require(totalSold <= 100_000e18, "Migration excess");
    }

    // Total liquidity of HMINE available for trades.
    function hmineReserve() external view returns (uint256 _hmineReserve) {
        uint256 _balance = IERC20(hmineToken).balanceOf(address(this));
        return _balance - totalStaked;
    }

    // Total liquidity of DAI available for trades.
    function currencyReserve()
        external
        view
        returns (uint256 _currencyReserve)
    {
        uint256 _balance = IERC20(currencyToken).balanceOf(address(this));
        return _balance - rewardTotal;
    }

    // Allows for withdrawing DAI liquidity.
    // Admin is supposed to send the DAI liquidity directly to the contract.
    function recoverReserve(uint256 _amount) external onlyRewardGiver nonReentrant {
        // Checks to make sure there is enough dai on contract to fullfill the withdrawal.
        uint256 _balance = IERC20(currencyToken).balanceOf(address(this));
        uint256 _available = _balance - rewardTotal;
        require(_amount <= _available, "Insufficient DAI on Contract");

        // Send DAI to user.  User only get's 60% of the selling price.
        IERC20(currencyToken).safeTransfer(msg.sender, _amount);
    }

    // An external function to calculate the swap value.
    // If it's a buy then calculate the amount of HMINE you get for the DAI input.
    // If it's a sell then calculate the amount of DAI you get for the HMINE input.
    function calculateSwap(uint256 _amount, bool _isBuy)
        external
        view
        returns (uint256 _value)
    {
        (_value, ) = _isBuy ? _getBuyValue(_amount) : _getSellValue(_amount);
        return _value;
    }

    // Input the amount a DAI and return the HMINE value.
    // It takes into account the price upscale in case a round has been met during the buy.
    function _getBuyValue(uint256 _amount)
        internal
        view
        returns (uint256 _hmineValue, uint256 _price)
    {
        _price = currentPrice;
        _hmineValue = (_amount * 1e18) / _price;
        // Fixed price if below second round
        if (totalSold + _hmineValue <= secondRound) {
            // Increment price if second round is reached
            if (totalSold + _hmineValue == secondRound) {
                _price += 3e18;
            }
        }
        // Price calculation when beyond the second round
        else {
            _hmineValue = 0;
            uint256 _amountLeftOver = _amount;
            uint256 _roundAvailable = roundIncrement -
                (totalSold % roundIncrement);

            // If short of first round, adjust up to first round
            if (totalSold < firstRound) {
                _hmineValue += firstRound - totalSold;
                _amountLeftOver -= (_hmineValue * _price) / 1e18;
                _roundAvailable = roundIncrement;
            }

            uint256 _valueOfLeftOver = (_amountLeftOver * 1e18) / _price;
            if (_valueOfLeftOver < _roundAvailable) {
                _hmineValue += _valueOfLeftOver;
            } else {
                _hmineValue += _roundAvailable;
                _amountLeftOver =
                    ((_valueOfLeftOver - _roundAvailable) * _price) /
                    1e18;
                _price += 3e18;
                while (_amountLeftOver > 0) {
                    _valueOfLeftOver = (_amountLeftOver * 1e18) / _price;
                    if (_valueOfLeftOver >= roundIncrement) {
                        _hmineValue += roundIncrement;
                        _amountLeftOver =
                            ((_valueOfLeftOver - roundIncrement) * _price) /
                            1e18;
                        _price += 3e18;
                    } else {
                        _hmineValue += _valueOfLeftOver;
                        _amountLeftOver = 0;
                    }
                }
            }
        }
        return (_hmineValue, _price);
    }

    // This internal function is used to calculate the amount of DAI user will receive.
    // It takes into account the price reversal in case rounds have reversed during a sell order.
    function _getSellValue(uint256 _amount)
        internal
        view
        returns (uint256 _sellValue, uint256 _price)
    {
        _price = currentPrice;
        uint256 _roundAvailable = totalSold % roundIncrement;
        // Still in current round.
        if (_amount <= _roundAvailable) {
            _sellValue = (_amount * _price) / 1e18;
        }
        // Amount plus the mod total tells us tha the round or rounds will most likely be reached.
        else {
            _sellValue = (_roundAvailable * _price) / 1e18;
            uint256 _amountLeftOver = _amount - _roundAvailable;
            while (_amountLeftOver > 0) {
                if (_price > 7e18) {
                    _price -= 3e18;
                }
                if (_amountLeftOver > roundIncrement) {
                    _sellValue += (roundIncrement * _price) / 1e18;
                    _amountLeftOver -= roundIncrement;
                } else {
                    _sellValue += (_amountLeftOver * _price) / 1e18;
                    _amountLeftOver = 0;
                }
            }
        }
        return (_sellValue, _price);
    }

    // Buy HMINE with DAI
    function buy(uint256 _amount) external nonReentrant isRunning(true) {
        require(_amount > 0, "Invalid amount");

        (uint256 _hmineValue, uint256 _price) = _getBuyValue(_amount);

        // Used to send funds to the appropriate wallets and update global data
        _buyInternal(msg.sender, _amount, _hmineValue, _price);

        emit Buy(msg.sender, _hmineValue, _price);
    }

    // Used to send funds to the appropriate wallets and update global data
    // The buy and compound function calls this internal function.
    function _buyInternal(
        address _sender,
        uint256 _amount,
        uint256 _hmineValue,
        uint256 _price
    ) internal {
        // Checks to make sure supply is not exeeded.
        require(totalSold + _hmineValue <= maxSupply, "Exceeded supply");

        // Sends 7.5% / 4 to Loft, Ghost, Mike, Miko
        uint256 _managementAmount = ((_amount * 75) / 1000) / 4;

        // Sends 2.5% to SafeHolders
        uint256 _safeHoldersAmount = (_amount * 25) / 1000;

        // Sends 80% to bankroll
        uint256 _bankrollAmount = (_amount * 80) / 100;

        // Sends or keeps 10% to/in the contract for divs
        uint256 _amountToStakers = _amount -
            (4 * _managementAmount + _safeHoldersAmount + _bankrollAmount);

        if (_sender == address(this)) {
            for (uint256 _i = 0; _i < 4; _i++) {
                IERC20(currencyToken).safeTransfer(
                    management[_i],
                    _managementAmount
                );
            }
            IERC20(currencyToken).safeTransfer(safeHolders, _safeHoldersAmount);
            IERC20(currencyToken).safeTransfer(bankroll, _bankrollAmount);
        } else {
            for (uint256 _i = 0; _i < 4; _i++) {
                IERC20(currencyToken).safeTransferFrom(
                    _sender,
                    management[_i],
                    _managementAmount
                );
            }
            IERC20(currencyToken).safeTransferFrom(
                _sender,
                safeHolders,
                _safeHoldersAmount
            );
            IERC20(currencyToken).safeTransferFrom(
                _sender,
                bankroll,
                _bankrollAmount
            );
            IERC20(currencyToken).safeTransferFrom(
                _sender,
                address(this),
                _amountToStakers
            );
        }

        _distributeRewards(_amountToStakers);

        // Update user's stake entry.
        uint256 _index = _assignUserIndex(msg.sender);
        users[_index].user = msg.sender; // just in case it was not yet initialized
        _collectsUserRewardAndUpdatesBalance(
            users[_index],
            int256(_hmineValue)
        );

        // Update global values.
        totalSold += _hmineValue;
        totalStaked += _hmineValue;
        currentPrice = _price;
        rewardTotal += _amountToStakers;
    }

    // Sell HMINE for DAI
    function sell(uint256 _amount) external nonReentrant isRunning(true) {
        require(_amount > 0, "Invalid amount");

        (uint256 _sellValue, uint256 _price) = _getSellValue(_amount);

        // Sends HMINE to contract
        IERC20(hmineToken).safeTransferFrom(msg.sender, address(this), _amount);

        uint256 _60percent = (_sellValue * 60) / 100;

        // Checks to make sure there is enough dai on contract to fullfill the swap.
        uint256 _balance = IERC20(currencyToken).balanceOf(address(this));
        uint256 _available = _balance - rewardTotal;
        require(_60percent <= _available, "Insufficient DAI on Contract");

        // Send DAI to user.  User only get's 60% of the selling price.
        IERC20(currencyToken).safeTransfer(msg.sender, _60percent);

        // Update global values.
        totalSold -= _amount;
        currentPrice = _price;

        emit Sell(msg.sender, _amount, _price);
    }

    // Stake HMINE
    function stake(uint256 _amount) external nonReentrant isRunning(true) {
        require(_amount > 0, "Invalid amount");
        uint256 _index = _assignUserIndex(msg.sender);
        users[_index].user = msg.sender; // just in case it was not yet initialized

        // User sends HMINE to the contract to stake
        IERC20(hmineToken).safeTransferFrom(msg.sender, address(this), _amount);

        // Update user's staking amount
        _collectsUserRewardAndUpdatesBalance(users[_index], int256(_amount));
        // Update total staking amount
        totalStaked += _amount;
    }

    // Unstake HMINE
    function unstake(uint256 _amount) external nonReentrant isRunning(true) {
        require(_amount > 0, "Invalid amount");
        uint256 _index = userIndex[msg.sender];
        require(_index != 0, "Not staked yet");
        require(users[_index].amount >= _amount, "Inefficient stake balance");

        uint256 _10percent = (_amount * 10) / 100;
        uint256 _80percent = _amount - 2 * _10percent;

        // Goes to burn address
        IERC20(hmineToken).safeTransfer(FURNACE, _10percent);
        // Goes to bankroll
        IERC20(hmineToken).safeTransfer(bankroll, _10percent);
        // User only gets 80% HMINE
        IERC20(hmineToken).safeTransfer(msg.sender, _80percent);

        // Update user's staking amount
        _collectsUserRewardAndUpdatesBalance(users[_index], -int256(_amount));
        // Update total staking amount
        totalStaked -= _amount;
    }

    // Adds a nickname to the user.
    function updateNickname(string memory _nickname) external {
        uint256 _index = userIndex[msg.sender];
        require(index != 0, "User does not exist");
        users[_index].nickname = _nickname;
    }

    // Claim DIV as DAI
    function claim() external nonReentrant {
        uint256 _index = userIndex[msg.sender];
        require(index != 0, "User does not exist");
        _collectsUserRewardAndUpdatesBalance(users[_index], 0);
        uint256 _claimAmount = users[_index].reward;
        require(_claimAmount > 0, "No rewards to claim");
        rewardTotal -= _claimAmount;
        users[_index].reward = 0;
        IERC20(currencyToken).safeTransfer(msg.sender, _claimAmount);
    }

    // Compound the divs.
    // Uses the div to buy more HMINE internally by calling the _buyInternal.
    function compound() external nonReentrant isRunning(true) {
        uint256 _index = userIndex[msg.sender];
        require(index != 0, "User does not exist");
        _collectsUserRewardAndUpdatesBalance(users[_index], 0);
        uint256 _claimAmount = users[_index].reward;
        require(_claimAmount > 0, "No rewards to claim");
        // Removes the the claim amount from total divs for tracing purposes.
        rewardTotal -= _claimAmount;
        // remove the div from the users reward pool.
        users[_index].reward = 0;

        (uint256 _hmineValue, uint256 _price) = _getBuyValue(_claimAmount);

        _buyInternal(address(this), _claimAmount, _hmineValue, _price);

        emit Compound(msg.sender, _hmineValue, _price);
    }

    // Reward giver sends bonus DIV to top 20 holders
    function sendBonusDiv(
        uint256 _amount,
        address[] memory _topTen,
        address[] memory _topTwenty
    ) external onlyRewardGiver nonReentrant isRunning(true) {
        require(_amount > 0, "Invalid amount");

        // Admin sends div to the contract
        IERC20(currencyToken).safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );

        require(
            _topTen.length == 10 && _topTwenty.length == 10,
            "Invalid arrays"
        );

        // 75% split between topTen
        uint256 _topTenAmount = ((_amount * 75) / 100) / 10;
        // 25% split between topTwenty
        uint256 _topTwentyAmount = ((_amount * 25) / 100) / 10;

        for (uint256 _i = 0; _i < 10; _i++) {
            uint256 _index = userIndex[_topTen[_i]];
            require(_index != 0, "A user doesn't exist");
            users[_index].reward += _topTenAmount;
        }

        for (uint256 _i = 0; _i < 10; _i++) {
            uint256 _index = userIndex[_topTwenty[_i]];
            require(_index != 0, "A user doesn't exist");
            users[_index].reward += _topTwentyAmount;
        }

        uint256 _leftOver = _amount - 10 * (_topTenAmount + _topTwentyAmount);
        users[userIndex[_topTen[0]]].reward += _leftOver;

        rewardTotal += _amount;

        emit BonusReward(_amount);
    }

    // Reward giver sends daily divs to all holders
    function sendDailyDiv(uint256 _amount)
        external
        onlyRewardGiver
        nonReentrant
        isRunning(true)
    {
        require(_amount > 0, "Invalid amount");

        // Admin sends div to the contract
        IERC20(currencyToken).safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );

        _distributeRewards(_amount);

        rewardTotal += _amount;
    }

    // Calculates actual user reward balance
    function userRewardBalance(address _userAddress)
        external
        view
        returns (uint256 _reward)
    {
        User storage _user = users[userIndex[_userAddress]];
        // The difference is the user's share of rewards distributed since the last collection
        uint256 _newReward = (_user.amount * accRewardPerShare) /
            1e12 -
            userRewardDebt[_user.user];
        return _user.reward + _newReward;
    }

    // Distributes reward amount to all users propotionally to their stake.
    function _distributeRewards(uint256 _amount) internal {
        accRewardPerShare += (_amount * 1e12) / totalStaked;
    }

    // Collects pending rewards and updates user balance.
    function _collectsUserRewardAndUpdatesBalance(
        User storage _user,
        int256 _amountDelta
    ) internal {
        // The difference is the user's share of rewards distributed since the last collection/reset
        uint256 _newReward = (_user.amount * accRewardPerShare) /
            1e12 -
            userRewardDebt[_user.user];
        _user.reward += _newReward;
        if (_amountDelta >= 0) {
            _user.amount += uint256(_amountDelta);
        } else {
            _user.amount -= uint256(-_amountDelta);
        }
        // Resets user's reward debt so that the difference is zero
        userRewardDebt[_user.user] = (_user.amount * accRewardPerShare) / 1e12;
    }

    // Show user by address
    function getUserByAddress(address _userAddress)
        external
        view
        returns (User memory _user)
    {
        return users[userIndex[_userAddress]];
    }

    // Show user by index
    function getUserByIndex(uint256 _index)
        external
        view
        returns (User memory _user)
    {
        return users[_index];
    }

    // Takes in a user address and finds an existing index that is corelated to the user.
    // If index not found (ZERO) then it assigns an index to the user.
    function _assignUserIndex(address _user) internal returns (uint256 _index) {
        if (userIndex[_user] == 0) userIndex[_user] = ++index;
        return userIndex[_user];
    }

    // Updates the management and reward giver address.
    function updateStateAddresses(address _rewardGiver, address _bankRoll)
        external
        onlyOwner
    {
        require(
            _bankRoll != address(0) && _bankRoll != address(this),
            "Invalid address"
        );
        require(
            _rewardGiver != address(0) && _rewardGiver != address(this),
            "Invalid address"
        );
        bankroll = _bankRoll;
        rewardGiver = _rewardGiver;
    }

    // Updates the management.
    function updateManagement(address _management, uint256 _i)
        external
        onlyOwner
    {
        require(
            _management != address(0) && _management != address(this),
            "Invalid address"
        );
        require(_i < 4, "Invalid entry");
        management[_i] = _management;
    }

    event Buy(address indexed _user, uint256 _amount, uint256 _price);
    event Sell(address indexed _user, uint256 _amount, uint256 _price);
    event Compound(address indexed _user, uint256 _amount, uint256 _price);
    event BonusReward(uint256 _amount);
}