/**
 *Submitted for verification at BscScan.com on 2022-12-01
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-30
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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
contract ReentrancyGuard {
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

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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

// OpenZeppelin Contracts v4.3.2 (token/BEP20/IBEP20.sol)
/**
 * @dev Interface of the BEP20 standard as defined in the EIP.
 */
interface IBEP20 {
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

// OpenZeppelin Contracts v4.3.2 (utils/Address.sol)
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

// OpenZeppelin Contracts v4.3.2 (token/BEP20/utils/SafeBEP20.sol)
/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeBEP20: decreased allowance below zero");
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
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

interface IERC1155Mintable {
    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;

    function burn(
        address account,
        uint256 id,
        uint256 value
    ) external;

    function balanceOf(
        address account, 
        uint256 id
    ) external view returns (uint256);
}

contract WSGKeySwapHubV2 is Ownable, ReentrancyGuard {
    event KeySwapExecuted(uint keyAmount, uint id, address account);

    struct KeySwapPair {
        uint cards;
        uint keys;
    }

    address private _treasury;
    IERC1155Mintable public immutable nftContract;
    uint public pricePerKey = 18195000 ether;
    uint public batchSwapCost = 54141850 ether;

    uint[] private commonIds = [
        10001, 10002, 10003, 10004, 10005, 10006, 10007, 10008, 10009, 10010,
        10021, 10022, 10023, 10024, 10025, 10026, 10027, 10028, 10029, 10030,
        10041, 10042, 10043, 10044, 10045, 10046, 10047, 10048, 10049, 10050,
        10061, 10062, 10063, 10064, 10065, 10066, 10067, 10068, 10069, 10070,
        10081, 10082, 10083, 10084, 10085, 10086, 10087, 10088, 10089, 10090,
        10101, 10102, 10103, 10104, 10105, 10106, 10107, 10108, 10109, 10110,
        10121, 10122, 10123, 10124, 10125, 10126, 10127, 10128, 10129, 10130,
        10141, 10142, 10143, 10144, 10145, 10146, 10147, 10148, 10149, 10150,
        10161, 10162, 10163, 10164, 10165, 10166, 10167, 10168, 10169, 10170,
        10181, 10182, 10183, 10184, 10185, 10186, 10187, 10188, 10189, 10190,
        10201, 10202, 10203, 10204, 10205, 10206, 10207, 10208, 10209, 10210,
        10221, 10222, 10223, 10224, 10225, 10226, 10227, 10228, 10229, 10230];

    uint[] private rareIds = [
        10011, 10012, 10013, 10014, 10015, 10016,
        10031, 10032, 10033, 10034, 10035, 10036,
        10051, 10052, 10053, 10054, 10055, 10056,
        10071, 10072, 10073, 10074, 10075, 10076,
        10091, 10092, 10093, 10094, 10095, 10096,
        10111, 10112, 10113, 10114, 10115, 10116,
        10131, 10132, 10133, 10134, 10135, 10136,
        10151, 10152, 10153, 10154, 10155, 10156,
        10171, 10172, 10173, 10174, 10175, 10176,
        10191, 10192, 10193, 10194, 10195, 10196,
        10211, 10212, 10213, 10214, 10215, 10216,
        10231, 10232, 10233, 10234, 10235, 10236];

    uint[] private mythicIds = [
        10017, 10018, 10019,
        10037, 10038, 10039,
        10057, 10058, 10059,
        10077, 10078, 10079,
        10097, 10098, 10099,
        10117, 10118, 10119,
        10137, 10138, 10139,
        10157, 10158, 10159,
        10177, 10178, 10179,
        10197, 10198, 10199,
        10217, 10218, 10219,
        10237, 10238, 10239];

    uint[] private legendaryIds = [
        10020,
        10040,
        10060,
        10080,
        10100,
        10120,
        10140,
        10160,
        10180,
        10200,
        10220,
        10240];

    mapping(uint => KeySwapPair) private swapRates;
    mapping(address => bool) private _blacklisted;
    address private constant wsg = address(0xA58950F05FeA2277d2608748412bf9F802eA4901);

    constructor () 
    {
        _treasury = address(0x8fdeB61D7c0D0945eC1d02a15DE91A4960b0a874);
        nftContract = IERC1155Mintable(0xe86E4b3bB1846a017153CedCD0458dc9Ad835D9b);

        for (uint c = 0; c < commonIds.length; c++) {
            setSwapRate(commonIds[c], 1, 1);
        }

        for (uint r = 0; r < rareIds.length; r++) {
            setSwapRate(rareIds[r], 1, 5);
        }

        for (uint m = 0; m < mythicIds.length; m++) {
            setSwapRate(mythicIds[m], 1, 20);
        }

        for (uint l = 0; l < legendaryIds.length; l++) {
            setSwapRate(legendaryIds[l], 1, 50);
        }
    }

    /** VIEW FUNCTIONS */

    function isBlacklisted(address account) public view virtual returns (bool) {
        return _blacklisted[account];
    }

    function treasury() public view virtual returns (address) {
        return _treasury;
    }

    /** EXTERNAL FUNCTIONS */

    function _swapForKeys(uint tokenId, uint keyAmount, uint id) internal {
        require(IBEP20(wsg).balanceOf(msg.sender) >= keyAmount * pricePerKey, '!balance');
        require(!_blacklisted[msg.sender], '!blacklisted');
        KeySwapPair storage pair = swapRates[tokenId];
        require(keyAmount >= pair.keys, '!min');
        require(keyAmount % pair.keys == 0, '!multiplier');

        uint total = keyAmount * pricePerKey; 
        uint cards;
        if (pair.keys >= pair.cards) {
            cards = keyAmount / pair.keys;
        } else {
            cards = keyAmount * pair.cards;
        }

        require(nftContract.balanceOf(msg.sender, tokenId) >= cards, '!nfts');
        nftContract.burn(msg.sender, tokenId, cards);

        SafeBEP20.safeTransferFrom(IBEP20(wsg), msg.sender, address(this), total);
        emit KeySwapExecuted(keyAmount, id, msg.sender);
    }

    function batchSwapForKeys(uint[] memory tokenIds, uint[] memory keyAmounts, uint id) external virtual nonReentrant {
        require(tokenIds.length == keyAmounts.length, "Array sizes do not match");
        require(tokenIds.length > 0, "Empty array");

        if (tokenIds.length > 1) {
            bool takeFee = false;

            for (uint index = 1; index < tokenIds.length; index++) {
                if (tokenIds[index] != tokenIds[0]) takeFee = true;
            }

            if (takeFee) {
                uint sum;

                for (uint index = 0; index < keyAmounts.length; index++) {
                    sum += keyAmounts[index];
                }

                uint cost = (sum - 1) * batchSwapCost;
                require(IBEP20(wsg).balanceOf(msg.sender) >= cost, '!sum');
                SafeBEP20.safeTransferFrom(IBEP20(wsg), msg.sender, address(this), cost);
            }
        }

        for (uint index = 0; index < tokenIds.length; index++) {
            uint tokenId = tokenIds[index];
            uint keyAmount = keyAmounts[index];

            _swapForKeys(tokenId, keyAmount, id);

            id = id + 1;
        }
    }

    /** RESTRICTED FUNCTIONS */

    function release() external virtual onlyOwner {
        Address.sendValue(payable(treasury()), address(this).balance);
    }

    function release(address token) external virtual onlyOwner {
        SafeBEP20.safeTransfer(IBEP20(token), treasury(), IBEP20(token).balanceOf(address(this)));
    }

    function setSwapRate(uint tokenId, uint cards, uint keys) public virtual onlyOwner {
        swapRates[tokenId] = KeySwapPair(cards, keys);
    }

    function batchSetSwapRate(uint[] memory tokenIds, uint[] memory cards, uint[] memory keys) external virtual onlyOwner {
        require(tokenIds.length == cards.length && cards.length == keys.length, '!length');
        for (uint index = 0; index < tokenIds.length; index++) {
            setSwapRate(tokenIds[index], cards[index], keys[index]);
        }
    }

    function setSwapPrice(uint price) external virtual onlyOwner {
        pricePerKey = price * 10**18;
    }
    
    function setBatchSwapCost(uint price) external virtual onlyOwner {
        batchSwapCost = price * 10**18;
    }

    function toggleBlacklisted(address account) external virtual onlyOwner {
        _blacklisted[account] = !_blacklisted[account];
    }

    function setTreasury(address treasury_) external virtual onlyOwner {
        require(treasury_ != address(0), '!treasury');
        _treasury = treasury_;
    }
}