/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

// SPDX-License-Identifier: MIT
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

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
    constructor(address initialOwner) {
        require(initialOwner != address(0), "Zero owner address prohibited");
        _transferOwnership(initialOwner);
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


contract Matrix is Ownable {
    using SafeERC20 for IERC20;
    using Address for address;


    struct UserData {
        uint256 userId;
        uint256 refCount;
        uint256 regDate;
        uint256 partnerId;
        uint256 ratio;
        uint256 earned;
        address wallet;
    }


    struct PartnerData {
        uint256 regDate;
        uint256 partnerId;
        uint256 earned;
        uint256 refCount;
        address wallet;
    }

    struct LevelsData {
        uint256 price;
        uint256 reinvestCount;
        bool status;
        uint256 uplineId;
        uint256 earned;
        uint256 partnersCount;
        uint256[] firstThreeRefferrals;
    }

    struct User {
        address wallet;
        uint256 partnerId;
        uint256 refCount;
        uint256 invested;
        uint256 regDate;
    }


    mapping (address => uint256) private ids;

    mapping (uint256 => User) private users; // mapping of users

    mapping(uint256 => bool) public usedNonces;

    mapping(uint256 => uint256[]) private partners; // user partners

    mapping(uint256 => mapping(uint256 => uint256)) reinvestCount; // number of reinvests for each level

    mapping(uint256 => mapping(uint256 => uint256)) earned; // amount of earned BUSD for each level

    mapping(uint256 => mapping(uint256 => uint256)) lost; // amount of lost BUSD for each level

    mapping(uint256 => mapping(uint256 => uint256)) partnersCount; // number of active partners on each level

    mapping(uint256 => mapping(uint256 => uint256)) uplines; // upline Id on each level

    mapping(uint256 => mapping(uint256 => uint256[])) matrix; // users on level 2

    mapping(uint256 => mapping(uint256 => bool)) isActive; // is level active for user

    uint256 public presaleEndTime;

    uint256 private lastUserId = 1;

    uint256 private txCount;
    uint256 private totalInvested;


    uint256[13] public prices = [  0,
                                    16000000000000000000,
                                    32000000000000000000,
                                    64000000000000000000,
                                    128000000000000000000,
                                    256000000000000000000,
                                    512000000000000000000,
                                    1024000000000000000000,
                                    2048000000000000000000,
                                    4096000000000000000000,
                                    8192000000000000000000,
                                    16384000000000000000000,
                                    32768000000000000000000
                                ];


    IERC20 private BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    uint256[3] public percentages = [60,30,10];

    address public verifier = 0xa889cEb0FE4521ba4218d97188a2c30c6Fd48792;

    event Register(uint256 userId, address indexed account, uint256 partner);

    event Payment(uint256 uplineId, uint256 level, uint256 amount);

    event LostPayment(uint256 uplineId, uint256 level, uint256 amount);

    event LevelBought(uint256 userId, uint256 refId, uint256 uplineId, uint256 level);

    event Reinvest(uint256 uplineId, uint256 level);

    event LevelPriceChanged(uint256 level, uint256 newprice);

    event TopWalletChanged(address indexed oldwallet, address indexed newwallet);


    constructor(address initialOwner, address first) Ownable(initialOwner) {
        User storage u = users[1];
        u.wallet = first;
        u.refCount = 0;
        u.partnerId = 1;
        u.invested = 0;
        u.regDate = block.timestamp;
        ids[first] = 1;
        for (uint256 i = 1; i < 13; i++) {
            isActive[1][i] = true;
        }
        emit Register(1, first, 1);
    }


    function whitelist(address account, uint256[] memory key) public onlyOwner {
        require(account != address(0), "Zero address is not allowed");
        require((key.length > 0 && key.length < 13), "Invalid key value");
        require(!isRegistered(account), "User is already registered");
        lastUserId += 1;
        User storage u = users[lastUserId];
        u.wallet = account;
        u.regDate = block.timestamp;
        u.invested = 0;
        u.refCount = 0;
        u.partnerId = 1;
        ids[account] = lastUserId;
        users[1].refCount += 1;
        partners[1].push(lastUserId);
        for (uint256 i = 0; i < key.length; i++) {
            if (key[i] > 0 && key[i] < 13) {
                isActive[lastUserId][key[i]] = true;
            }
        }
        emit Register(lastUserId, account, 1);
    }


    function changeTopWallet(address account) public onlyOwner {
        require(account != address(0), "Zero address not allowed");
        require(account != users[1].wallet, "This account is already a top user");
        emit TopWalletChanged(users[1].wallet, account);
        ids[users[1].wallet] = 0;
        users[1].wallet = account;
        ids[account] = 1;
    }

    function setLevelPrice(uint256 level, uint256 price) external onlyOwner {
        require((level > 0 && level < 13), "Invalid level number");
        require(price > 0, "Zero price not allowed");
        prices[level] = price;
        emit LevelPriceChanged(level, price);
    }

    function setVerifier(address account) external onlyOwner {
        require(account != address(0), "Zero address not allowed");
        verifier = account;
    }

    function setBUSD(address cntr) external onlyOwner {
        require((cntr != address(0) && cntr.isContract()), "Invalid stablecoin contract address");
        BUSD = IERC20(cntr);
    }


    function setPercentages(uint256[3] memory values) external onlyOwner {
        require(values[0] + values[1] + values[2] == 100, "Invalid values. Sum must be 100");
        percentages = values;
    }


    function setPresaleEnd(uint256 date) external onlyOwner {
        presaleEndTime = date;
    }


    function register(address account, uint256 refId) internal returns (uint256) {
        if (refId > lastUserId) {
            refId = 1;
        }
        lastUserId += 1;
        User storage u = users[lastUserId];
        u.wallet = account;
        u.regDate = block.timestamp;
        u.invested = 0;
        u.refCount = 0;
        u.partnerId = refId;
        ids[account] = lastUserId;
        users[refId].refCount += 1;
        partners[refId].push(lastUserId);
        emit Register(lastUserId, account, refId);
        return refId;
    }

    function buyLevel(uint256 level) public {
        if (isRegistered(_msgSender())) {
            buyLevel(level, users[ids[_msgSender()]].partnerId);
        } else {
            buyLevel(level, 1);
        }
    }

    function buyLevel(uint256 level, uint256 refId) public {
        require((level > 0 && level < 13), "Invalid level number");
        require(!levelActiveByAddress(_msgSender(), level), "You have already bought this level");
        if (level > 1) require(levelActiveByAddress(_msgSender(), level-1), "You must buy previous level before buying next one");
        require(presaleEndTime < block.timestamp, "Public sale is not yet available");
        if (!isRegistered(_msgSender())) {
            refId = register(_msgSender(), refId);
        }
        BUSD.safeTransferFrom(_msgSender(), address(this), prices[level]);
        isActive[ids[_msgSender()]][level] = true;
        txCount += 1;
        totalInvested += prices[level];
        users[ids[_msgSender()]].invested += prices[level];
        partnersCount[refId][level] += 1;
        placeUser(level, prices[level], ids[_msgSender()], refId);
    }

    function placeUser(uint256 level, uint256 amount, uint256 userId, uint256 refId) internal {
        uint256 uplineId;
        if (!levelActiveByID(refId, level)) {
            uplineId = 1;
        } else {
            uplineId = refId;
        }
        matrix[uplineId][level].push(userId);
        uplines[userId][level] = uplineId;
        emit LevelBought(userId, refId, uplineId, level);
        if (matrix[uplineId][level].length == 3) {
            delete matrix[uplineId][level];
            reinvestCount[uplineId][level] += 1;
            BUSD.safeTransfer(users[1].wallet, amount * percentages[0] / 100);
            earned[1][level] += amount * percentages[0] / 100;
            emit Reinvest(uplineId, level);
            uint256[] memory payments = new uint256[](2);
            payments[0] = amount * percentages[1] / 100;
            payments[1] = amount * percentages[2] / 100;
            sendPayment(level, payments, users[refId].partnerId);
        } else {
            uint256[] memory payments = new uint256[](3);
            payments[0] = amount * percentages[0] / 100;
            payments[1] = amount * percentages[1] / 100;
            payments[2] = amount - payments[0] - payments[1];
            sendPayment(level, payments, refId);
        }
    }


    function sendPayment(uint256 level, uint256[] memory payments, uint256 uplineId) internal {
        uint256 nextId;
        for (uint i = 0; i < payments.length; i++) {
            nextId = uplineId;
            for (uint j = 0; j < 3; j++) {
                if (levelActiveByID(nextId, level)) {
                    BUSD.safeTransfer(users[nextId].wallet, payments[i]);
                    earned[nextId][level] += payments[i];
                    payments[i] = 0;
                    emit Payment(nextId, level, payments[i]);
                    break;
                } else {
                    lost[nextId][level] += payments[i];
                    emit LostPayment(nextId, level, payments[i]);
                    nextId = users[nextId].partnerId;
                }
            }
            if (payments[i] > 0) {
                BUSD.safeTransfer(users[1].wallet, payments[i]);
                earned[1][level] += payments[i];
                emit Payment(1, level, payments[i]);
            }
            uplineId = users[uplineId].partnerId;
        }
    }


    function presale(uint256 level, uint256 refId, uint256 nonce, bytes memory sig) external {
        require(presaleEndTime > block.timestamp, "Presale is over");
        require(!usedNonces[nonce]);
        bytes32 message = prefixed(keccak256(abi.encodePacked(nonce, level, _msgSender(), address(this))));
        address signer = recoverSigner(message, sig);
        require(signer == verifier, "Unauthorized transaction");
        usedNonces[nonce] = true;
        require((level > 0 && level < 13), "Invalid level number");
        require(!levelActiveByAddress(_msgSender(), level), "You have already bought this level");
        if (level > 1) require(levelActiveByAddress(_msgSender(), level-1), "You must buy previous level before buying next one");
        if (!isRegistered(_msgSender())) {
            refId = register(_msgSender(), refId);
        }
        BUSD.safeTransferFrom(_msgSender(), address(this), prices[level]);
        isActive[ids[_msgSender()]][level] = true;
        txCount += 1;
        totalInvested += prices[level];
        users[ids[_msgSender()]].invested += prices[level];
        partnersCount[refId][level] += 1;
        placeUser(level, prices[level], ids[_msgSender()], refId);
    }

    function getGlobals() public view returns(uint256, uint256, uint256) {
        return (lastUserId, totalInvested, txCount);
    }

    function isRegistered(address account) public view returns (bool) {
        return ids[account] > 0;
    }

    function getAddressByID(uint256 id) public view returns (address) {
        return users[id].wallet;
    }

    function getIdByAddress(address account) public view returns (uint256) {
        return ids[account];
    }

    function levelActiveByAddress(address account, uint256 level) public view returns (bool) {
        return isActive[ids[account]][level];
    }

    function levelActiveByID(uint256 id, uint256 level) public view returns (bool) {
        return isActive[id][level];
    }


    function getTotalEarned(uint id) public view returns (uint256) {
        uint256 _earned;
        for (uint i = 1; i < 13; i++) {
            _earned += earned[id][i];
        }
        return _earned;
    }

    function getUserDataById(uint256 id) public view returns(UserData memory) {
        uint256 ratio;
        if (users[id].invested == 0) {
            ratio = 0;
        } else {
            ratio = getTotalEarned(id) * 100 / users[id].invested;
        }
        UserData memory u = UserData({
                                        userId: id,
                                        refCount: users[id].refCount,
                                        regDate: users[id].regDate,
                                        partnerId: users[id].partnerId,
                                        ratio: ratio,
                                        earned: getTotalEarned(id),
                                        wallet: users[id].wallet
                                  });
        return u;
    }


    function getUserDataByAddress(address account) public view returns (UserData memory) {
        uint256 userId = ids[account];
        UserData memory u = getUserDataById(userId);
        return u;
    }


    function getLevelsById(uint256 id) public view returns(LevelsData[] memory) {
        LevelsData[] memory result = new LevelsData[](12);
        for (uint i = 1; i < 13; i++) {
            result[i-1] = LevelsData({
                                    price: prices[i],
                                    reinvestCount: reinvestCount[id][i],
                                    status: levelActiveByID(id, i),
                                    uplineId: uplines[id][i],
                                    earned: earned[id][i],
                                    partnersCount: partnersCount[id][i],
                                    firstThreeRefferrals: matrix[id][i]
                                  });

        }
        return result;
    }


    function getLevelsByAddress(address account) public view returns (LevelsData[] memory) {
        uint256 userId = ids[account];
        LevelsData[] memory result = getLevelsById(userId);
        return result;
    }


    function getPartnersById(uint256 id, uint256 skip, uint256 limit) public view returns(uint256, PartnerData[] memory) {
        if (id > lastUserId || skip + limit > partners[id].length) {
            skip = 0;
            limit = partners[id].length;
        }
        PartnerData[] memory p = new PartnerData[](limit);
        for (uint i=skip; i < skip + limit; i++) {
            p[i-skip] = PartnerData({
                                    regDate: users[partners[id][i]].regDate,
                                    partnerId: partners[id][i],
                                    earned: getTotalEarned(partners[id][i]),
                                    refCount: users[partners[id][i]].refCount,
                                    wallet: users[partners[id][i]].wallet
                                  });
        }
        return (partners[id].length, p);
    }

    function getPartnersByAddress(address account, uint256 skip, uint256 limit) public view returns (uint256, PartnerData[] memory) {
        uint256 userId = ids[account];
        (uint256 total, PartnerData[] memory result) = getPartnersById(userId, skip, limit);
        return (total, result);
    }



    function recoverSigner(bytes32 message, bytes memory sig) public pure
    returns (address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = splitSignature(sig);

        return ecrecover(message, v, r, s);
    }

    function splitSignature(bytes memory sig)
    public
    pure
    returns (uint8, bytes32, bytes32)
    {
        require(sig.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    // Builds a prefixed hash to mimic the behavior of eth_sign.
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

}