// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
                /// @solidity memory-safe-assembly
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "../../libraries/LibDiamond.sol";
import "../../libraries/LibSwapper.sol";

contract RangoAccessManagerFacet {

    struct whitelistRequest {
        address contractAddress;
        bytes4[] methodIds;
    }

    /// @notice Notifies that a new contract is whitelisted
    /// @param _address The address of the contract
    event ContractWhitelisted(address _address);

    /// @notice Notifies that a new contract is whitelisted
    /// @param contractAddress The address of the contract
    /// @param methods The method signatures that are whitelisted for a contractAddress
    event ContractAndMethodsWhitelisted(address contractAddress, bytes4[] methods);

    /// @notice Notifies that a new contract is blacklisted
    /// @param _address The address of the contract
    event ContractBlacklisted(address _address);

    /// @notice Adds a contract & its' methods to the whitelisted addresses that can be called. The contract is usually a dex.
    /// @param req The array containing address of the contract & its' methods
    function addWhitelistContract(whitelistRequest[] calldata req) public {
        LibDiamond.enforceIsContractOwner();

        for (uint i = 0; i < req.length; i++) {
            LibSwapper.addMethodWhitelists(req[i].contractAddress, req[i].methodIds);
            emit ContractAndMethodsWhitelisted(req[i].contractAddress, req[i].methodIds);
            emit ContractWhitelisted(req[i].contractAddress);
        }
    }

    /// @notice Adds a contract to the whitelisted addresses that can be called
    /// @param _address The address of the contract to be whitelisted
    function addWhitelistContract(address _address) public {
        LibDiamond.enforceIsContractOwner();
        LibSwapper.addWhitelist(_address);
        emit ContractWhitelisted(_address);
    }

    /// @notice Adds a list of contracts to the whitelisted conracts that can be called
    /// @param _addresses The addresses of the contracts to be whitelisted
    function addWhitelists(address[] calldata _addresses) external {
        LibDiamond.enforceIsContractOwner();
        for (uint i = 0; i < _addresses.length; i++)
            addWhitelistContract(_addresses[i]);
    }

    /// @notice Removes a contract from the whitelisted addresses
    /// @param _address The address of the contract to be removed from whitelist
    function removeWhitelistContract(address _address) external {
        LibDiamond.enforceIsContractOwner();
        LibSwapper.removeWhitelist(_address);
        emit ContractBlacklisted(_address);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "../../libraries/LibDiamond.sol";
import "../../libraries/LibInterchain.sol";

// @title The base contract to be used as a parent of middleware classes
// @author George
// @dev Note that this is not a facet and should be extended and deployed separately.
contract RangoBaseInterchainMiddleware {
    /// @dev keccak256("exchange.rango.middleware.base")
    bytes32 internal constant BASE_MIDDLEWARE_CONTRACT_NAMESPACE = hex"ad914d4300c64e1902ca499875cd8a76ae717047bcfaa9e806ff7ea4f6911268";

    struct BaseInterchainMiddlewareStorage {
        address rangoDiamond;
        address owner;
    }

    struct whitelistRequest {
        address contractAddress;
        bytes4[] methodIds;
    }

    constructor(
        address _owner,
        address _rangoDiamond,
        address _weth
    ){
        require(_owner != address(0));
        updateOwnerInternal(_owner);
        updateRangoDiamondInternal(_rangoDiamond);
        LibSwapper.setWeth(_weth);
    }


    /// Events
    /// @notice Emits when the rango diamond address is updated
    /// @param oldAddress The previous address
    /// @param newAddress The new address
    event RangoDiamondAddressUpdated(address oldAddress, address newAddress);
    /// @notice Emits when the weth address is updated
    /// @param oldAddress The previous address
    /// @param newAddress The new address
    event WethAddressUpdated(address oldAddress, address newAddress);
    /// @notice Emits when the owner is updated
    /// @param previousOwner The previous owner
    /// @param newOwner The new owner
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    /// @notice Notifies that admin manually refunded some money
    /// @param _token The address of refunded token, 0x000..00 address for native token
    /// @param _amount The amount that is refunded
    event Refunded(address _token, uint _amount);
    /// @notice Notifies that a new contract is whitelisted
    /// @param _address The address of the contract
    event ContractWhitelisted(address _address);
    /// @notice Notifies that a new contract is blacklisted
    /// @param _address The address of the contract
    event ContractBlacklisted(address _address);
    /// @notice Notifies that a new contract is whitelisted
    /// @param _dapp The address of the contract
    event MessagingDAppWhitelisted(address _dapp);
    /// @notice Notifies that a new contract is blacklisted
    /// @param _dapp The address of the contract
    event MessagingDAppBlacklisted(address _dapp);

    /// @notice used to limit access only to owner
    modifier onlyOwner() {
        require(msg.sender == getBaseInterchainMiddlewareStorage().owner, "should be called only by owner");
        _;
    }

    /// @notice used to limit access only to rango diamond
    modifier onlyDiamond() {
        require(msg.sender == getBaseInterchainMiddlewareStorage().rangoDiamond, "should be called only from diamond");
        _;
    }

    /// @notice Enables the contract to receive native ETH token from other contracts including WETH contract
    receive() external payable {}

    /// Administration & Control

    /// @notice Updates the address of rango diamond contract
    /// @param newAddress The new address of diamond contract
    function updateRangoDiamondAddress(address newAddress) external onlyOwner {
        updateRangoDiamondInternal(newAddress);
    }
    /// @notice Updates the address of weth contract
    /// @param newAddress The new address of weth contract
    function updateWethAddress(address newAddress) external onlyOwner {
        LibSwapper.setWeth(newAddress);
    }
    /// @notice Updates the address of owner
    /// @param newAddress The new address of owner
    function updateOwner(address newAddress) external onlyOwner {
        updateOwnerInternal(newAddress);
    }

    /// @notice Transfers an ERC20 token from this contract to msg.sender
    /// @dev This endpoint is to return money to a user if we didn't handle failure correctly and the money is still in the contract
    /// @dev Currently the money goes to admin and they should manually transfer it to a wallet later
    /// @param _tokenAddress The address of ERC20 token to be transferred
    /// @param _amount The amount of money that should be transfered
    function refund(address _tokenAddress, uint256 _amount) external onlyOwner {
        IERC20 ercToken = IERC20(_tokenAddress);
        uint balance = ercToken.balanceOf(address(this));
        require(balance >= _amount, 'Insufficient balance');

        SafeERC20.safeTransfer(IERC20(_tokenAddress), msg.sender, _amount);
        emit Refunded(_tokenAddress, _amount);
    }

    /// @notice Transfers the native token from this contract to msg.sender
    /// @dev This endpoint is to return money to a user if we didn't handle failure correctly and the money is still in the contract
    /// @dev Currently the money goes to admin and they should manually transfer it to a wallet later
    /// @param _amount The amount of native token that should be transferred
    function refundNative(uint256 _amount) external onlyOwner {
        uint balance = address(this).balance;
        require(balance >= _amount, 'Insufficient balance');

        (bool sent,) = msg.sender.call{value : _amount}("");
        require(sent, "failed to send native");

        emit Refunded(LibSwapper.ETH, _amount);
    }

    /// @notice Adds a list of contracts to the whitelisted DEXes that can be called
    /// @param req The requests for whitelisting contracts and methods
    function addWhitelistContractMiddleWare(whitelistRequest[] calldata req) external onlyOwner {
        for (uint i = 0; i < req.length; i++) {
            LibSwapper.addMethodWhitelists(req[i].contractAddress, req[i].methodIds);
            emit ContractWhitelisted(req[i].contractAddress);
        }
    }

    /// @notice Removes a contract from the whitelisted DEXes
    /// @param contractAddress The address of the DEX or dApp
    function removeWhitelistMiddleWare(address contractAddress) external onlyOwner {
        LibSwapper.removeWhitelist(contractAddress);
        emit ContractBlacklisted(contractAddress);
    }

    /// @notice Removes a method of contract from the whitelisted DEXes
    /// @param contractAddress The address of the DEX or dApp
    /// @param methodId The method of the DEX
    function removeMethodWhitelistMiddleWare(address contractAddress, bytes4 methodId) external onlyOwner {
        LibSwapper.removeMethodWhitelist(contractAddress, methodId);
    }

    /// @notice Adds a list of contracts to the whitelisted messaging dApps that can be called
    /// @param _dapps The addresses of dApps
    function addMessagingDAppsMiddleWare(address[] calldata _dapps) external onlyOwner {
        address dapp;
        for (uint i = 0; i < _dapps.length; i++) {
            dapp = _dapps[i];
            LibInterchain.addMessagingDApp(dapp);
            emit MessagingDAppWhitelisted(dapp);
        }
    }

    /// @notice Removes a contract from dApps that can be called
    /// @param _dapp The address of dApp
    function removeMessagingDAppContractMiddleWare(address _dapp) external onlyOwner {
        LibInterchain.removeMessagingDApp(_dapp);
        emit MessagingDAppBlacklisted(_dapp);
    }


    /// Internal and Private functions
    function updateRangoDiamondInternal(address newAddress) private {
        BaseInterchainMiddlewareStorage storage s = getBaseInterchainMiddlewareStorage();
        address oldAddress = s.rangoDiamond;
        s.rangoDiamond = newAddress;
        emit RangoDiamondAddressUpdated(oldAddress, newAddress);
    }

    function updateOwnerInternal(address newAddress) private {
        BaseInterchainMiddlewareStorage storage s = getBaseInterchainMiddlewareStorage();
        address oldAddress = s.owner;
        s.owner = newAddress;
        emit OwnershipTransferred(oldAddress, newAddress);
    }

    /// @dev fetch local storage
    function getBaseInterchainMiddlewareStorage() private pure returns (BaseInterchainMiddlewareStorage storage s) {
        bytes32 namespace = BASE_MIDDLEWARE_CONTRACT_NAMESPACE;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            s.slot := namespace
        }
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "../../libraries/LibDiamond.sol";
import "../../libraries/LibInterchain.sol";

contract RangoInterchainFacet {
    /// Events ///

    /// @notice Notifies that a new contract is whitelisted
    /// @param _dapp The address of the contract
    event MessagingDAppWhitelisted(address _dapp);

    /// @notice Notifies that a new contract is blacklisted
    /// @param _dapp The address of the contract
    event MessagingDAppBlacklisted(address _dapp);

    /// @notice Adds a contract to the whitelisted messaging dApps that can be called
    /// @param _dapp The address of dApp
    function addMessagingDAppContract(address _dapp) public {
        LibDiamond.enforceIsContractOwner();
        LibInterchain.addMessagingDApp(_dapp);
        emit MessagingDAppWhitelisted(_dapp);
    }

    /// @notice Adds a list of contracts to the whitelisted messaging dApps that can be called
    /// @param _dapps The addresses of dApps
    function addMessagingDApps(address[] calldata _dapps) external {
        LibDiamond.enforceIsContractOwner();
        for (uint i = 0; i < _dapps.length; i++)
            addMessagingDAppContract(_dapps[i]);
    }

    /// @notice Removes a contract from dApps that can be called
    /// @param _dapp The address of dApp
    function removeMessagingDAppContract(address _dapp) external {
        LibDiamond.enforceIsContractOwner();
        LibInterchain.removeMessagingDApp(_dapp);
        emit MessagingDAppBlacklisted(_dapp);
    }
}

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity 0.8.16;

interface IBridge {
    function send(
        address _receiver,
        address _token,
        uint256 _amount,
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage
    ) external;

    function sendNative(
        address _receiver,
        uint256 _amount,
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage
    ) external payable;

    function relay(
        bytes calldata _relayRequest,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external;

    function transfers(bytes32 transferId) external view returns (bool);

    function withdraws(bytes32 withdrawId) external view returns (bool);

    function withdraw(
        bytes calldata _wdmsg,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external;

    /**
     * @notice Verifies that a message is signed by a quorum among the signers.
     * @param _msg signed message
     * @param _sigs list of signatures sorted by signer addresses in ascending order
     * @param _signers sorted list of current signers
     * @param _powers powers of current signers
     */
    function verifySigs(
        bytes memory _msg,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external view;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

interface IMessageBusSender {
    function calcFee(bytes calldata _message) external view returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.16;

abstract contract MessageBusAddress {
    /// @dev keccak256("exchange.rango.facets.cbridge.msg.messagebusaddress")
    bytes32 internal constant MSG_BUS_ADDRESS_NAMESPACE = hex"d82f4f572578dde7d9e798c168d6d6abab176a082ca20bc9a27a6c48782c92ef";

    struct MsgBusAddrStorage {
        address messageBus;
    }

    event MessageBusUpdated(address messageBus);

    function setMessageBusInternal(address _messageBus) internal {
        MsgBusAddrStorage storage s = getMsgBusAddrStorage();
        s.messageBus = _messageBus;
        emit MessageBusUpdated(s.messageBus);
    }

    function getMsgBusAddress() internal view returns (address) {
        MsgBusAddrStorage storage s = getMsgBusAddrStorage();
        return s.messageBus;
    }

    /// @dev fetch local storage
    function getMsgBusAddrStorage() private pure returns (MsgBusAddrStorage storage s) {
        bytes32 namespace = MSG_BUS_ADDRESS_NAMESPACE;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            s.slot := namespace
        }
    }

}

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity 0.8.16;

import "../interfaces/IMessageReceiverApp.sol";
import "./MessageBusAddress.sol";

abstract contract MessageReceiverApp is IMessageReceiverApp, MessageBusAddress {
    modifier onlyMessageBus() {
        require(msg.sender == getMsgBusAddress(), "caller is not message bus");
        _;
    }

    /**
     * @notice Called by MessageBus (MessageBusReceiver) if the process is originated from MessageBus (MessageBusSender)'s
     *         sendMessageWithTransfer it is only called when the tokens are checked to be arrived at this contract's address.
     * @param _sender The address of the source app contract
     * @param _token The address of the token that comes out of the bridge
     * @param _amount The amount of tokens received at this contract through the cross-chain bridge.
     *        the contract that implements this contract can safely assume that the tokens will arrive before this
     *        function is called.
     * @param _srcChainId The source chain ID where the transfer is originated from
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _executor Address who called the MessageBus execution function
     */
    function executeMessageWithTransfer(
        address _sender,
        address _token,
        uint256 _amount,
        uint64 _srcChainId,
        bytes calldata _message,
        address _executor
    ) external payable virtual override onlyMessageBus returns (ExecutionStatus) {}

    /**
     * @notice Only called by MessageBus (MessageBusReceiver) if
     *         1. executeMessageWithTransfer reverts, or
     *         2. executeMessageWithTransfer returns ExecutionStatus.Fail
     * @param _sender The address of the source app contract
     * @param _token The address of the token that comes out of the bridge
     * @param _amount The amount of tokens received at this contract through the cross-chain bridge.
     *        the contract that implements this contract can safely assume that the tokens will arrive before this
     *        function is called.
     * @param _srcChainId The source chain ID where the transfer is originated from
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _executor Address who called the MessageBus execution function
     */
    function executeMessageWithTransferFallback(
        address _sender,
        address _token,
        uint256 _amount,
        uint64 _srcChainId,
        bytes calldata _message,
        address _executor
    ) external payable virtual override onlyMessageBus returns (ExecutionStatus) {}

    /**
     * @notice Called by MessageBus (MessageBusReceiver) to process refund of the original transfer from this contract
     * @param _token The token address of the original transfer
     * @param _amount The amount of the original transfer
     * @param _message The same message associated with the original transfer
     * @param _executor Address who called the MessageBus execution function
     */
    function executeMessageWithTransferRefund(
        address _token,
        uint256 _amount,
        bytes calldata _message,
        address _executor
    ) external payable virtual override onlyMessageBus returns (ExecutionStatus) {}

    /**
     * @notice Called by MessageBus (MessageBusReceiver)
     * @param _sender The address of the source app contract
     * @param _srcChainId The source chain ID where the transfer is originated from
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _executor Address who called the MessageBus execution function
     */
    function executeMessage(
        address _sender,
        uint64 _srcChainId,
        bytes calldata _message,
        address _executor
    ) external payable virtual override onlyMessageBus returns (ExecutionStatus) {}
}

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../libraries/MsgDataTypes.sol";
import "../libraries/MessageSenderLib.sol";
import "./MessageBusAddress.sol";

abstract contract MessageSenderApp is MessageBusAddress {
    using SafeERC20 for IERC20;

    // ============== Utility functions called by apps ==============

    /**
     * @notice Sends a message to a contract on another chain.
     * Sender needs to make sure the uniqueness of the message Id, which is computed as
     * hash(type.MessageOnly, sender, receiver, srcChainId, srcTxHash, dstChainId, message).
     * If messages with the same Id are sent, only one of them will succeed at dst chain.
     * @param _receiver The address of the destination app contract.
     * @param _dstChainId The destination chain ID.
     * @param _message Arbitrary message bytes to be decoded by the destination app contract.
     * @param _fee The fee amount to pay to MessageBus.
     */
    function sendMessage(
        address _receiver,
        uint64 _dstChainId,
        bytes memory _message,
        uint256 _fee
    ) internal {
        MessageSenderLib.sendMessage(_receiver, _dstChainId, _message, getMsgBusAddress(), _fee);
    }

    /**
     * @notice Sends a message associated with a transfer to a contract on another chain.
     * @param _receiver The address of the destination app contract.
     * @param _token The address of the token to be sent.
     * @param _amount The amount of tokens to be sent.
     * @param _dstChainId The destination chain ID.
     * @param _nonce A number input to guarantee uniqueness of transferId. Can be timestamp in practice.
     * @param _maxSlippage The max slippage accepted, given as percentage in point (pip). Eg. 5000 means 0.5%.
     *        Must be greater than minimalMaxSlippage. Receiver is guaranteed to receive at least
     *        (100% - max slippage percentage) * amount or the transfer can be refunded.
     *        Only applicable to the {MsgDataTypes.BridgeSendType.Liquidity}.
     * @param _message Arbitrary message bytes to be decoded by the destination app contract.
     *        If message is empty, only the token transfer will be sent
     * @param _bridgeSendType One of the {BridgeSendType} enum.
     * @param _fee The fee amount to pay to MessageBus.
     * @return The transfer ID.
     */
    function sendMessageWithTransfer(
        address _receiver,
        address _token,
        uint256 _amount,
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage,
        bytes memory _message,
        MsgDataTypes.BridgeSendType _bridgeSendType,
        uint256 _fee
    ) internal returns (bytes32) {
        return
        MessageSenderLib.sendMessageWithTransfer(
            _receiver,
            _token,
            _amount,
            _dstChainId,
            _nonce,
            _maxSlippage,
            _message,
            _bridgeSendType,
            getMsgBusAddress(),
            _fee
        );
    }

    /**
     * @notice Sends a token transfer via a bridge.
     * @dev sendMessageWithTransfer with empty message
     * @param _receiver The address of the destination app contract.
     * @param _token The address of the token to be sent.
     * @param _amount The amount of tokens to be sent.
     * @param _dstChainId The destination chain ID.
     * @param _nonce A number input to guarantee uniqueness of transferId. Can be timestamp in practice.
     * @param _maxSlippage The max slippage accepted, given as percentage in point (pip). Eg. 5000 means 0.5%.
     *        Must be greater than minimalMaxSlippage. Receiver is guaranteed to receive at least
     *        (100% - max slippage percentage) * amount or the transfer can be refunded.
     *        Only applicable to the {MsgDataTypes.BridgeSendType.Liquidity}.
     * @param _bridgeSendType One of the {BridgeSendType} enum.
     */
    function sendTokenTransfer(
        address _receiver,
        address _token,
        uint256 _amount,
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage,
        MsgDataTypes.BridgeSendType _bridgeSendType
    ) internal returns (bytes32) {
        return
        MessageSenderLib.sendMessageWithTransfer(
            _receiver,
            _token,
            _amount,
            _dstChainId,
            _nonce,
            _maxSlippage,
            "", // empty message, which will not trigger sendMessage
            _bridgeSendType,
            getMsgBusAddress(),
            0
        );
    }
}

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity 0.8.16;

import "../libraries/MsgDataTypes.sol";

interface IMessageBus {
    function liquidityBridge() external view returns (address);

    function pegBridge() external view returns (address);

    function pegBridgeV2() external view returns (address);

    function pegVault() external view returns (address);

    function pegVaultV2() external view returns (address);

    /**
     * @notice Calculates the required fee for the message.
     * @param _message Arbitrary message bytes to be decoded by the destination app contract.
     @ @return The required fee.
     */
    function calcFee(bytes calldata _message) external view returns (uint256);

    /**
     * @notice Sends a message to a contract on another chain.
     * Sender needs to make sure the uniqueness of the message Id, which is computed as
     * hash(type.MessageOnly, sender, receiver, srcChainId, srcTxHash, dstChainId, message).
     * If messages with the same Id are sent, only one of them will succeed at dst chain..
     * A fee is charged in the native gas token.
     * @param _receiver The address of the destination app contract.
     * @param _dstChainId The destination chain ID.
     * @param _message Arbitrary message bytes to be decoded by the destination app contract.
     */
    function sendMessage(
        address _receiver,
        uint256 _dstChainId,
        bytes calldata _message
    ) external payable;

    /**
     * @notice Sends a message associated with a transfer to a contract on another chain.
     * If messages with the same srcTransferId are sent, only one of them will succeed at dst chain..
     * A fee is charged in the native token.
     * @param _receiver The address of the destination app contract.
     * @param _dstChainId The destination chain ID.
     * @param _srcBridge The bridge contract to send the transfer with.
     * @param _srcTransferId The transfer ID.
     * @param _dstChainId The destination chain ID.
     * @param _message Arbitrary message bytes to be decoded by the destination app contract.
     */
    function sendMessageWithTransfer(
        address _receiver,
        uint256 _dstChainId,
        address _srcBridge,
        bytes32 _srcTransferId,
        bytes calldata _message
    ) external payable;

    /**
     * @notice Withdraws message fee in the form of native gas token.
     * @param _account The address receiving the fee.
     * @param _cumulativeFee The cumulative fee credited to the account. Tracked by SGN.
     * @param _sigs The list of signatures sorted by signing addresses in ascending order. A withdrawal must be
     * signed-off by +2/3 of the sigsVerifier's current signing power to be delivered.
     * @param _signers The sorted list of signers.
     * @param _powers The signing powers of the signers.
     */
    function withdrawFee(
        address _account,
        uint256 _cumulativeFee,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external;

    /**
     * @notice Execute a message with a successful transfer.
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _transfer The transfer info.
     * @param _sigs The list of signatures sorted by signing addresses in ascending order. A relay must be signed-off by
     * +2/3 of the sigsVerifier's current signing power to be delivered.
     * @param _signers The sorted list of signers.
     * @param _powers The signing powers of the signers.
     */
    function executeMessageWithTransfer(
        bytes calldata _message,
        MsgDataTypes.TransferInfo calldata _transfer,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external payable;

    /**
     * @notice Execute a message with a refunded transfer.
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _transfer The transfer info.
     * @param _sigs The list of signatures sorted by signing addresses in ascending order. A relay must be signed-off by
     * +2/3 of the sigsVerifier's current signing power to be delivered.
     * @param _signers The sorted list of signers.
     * @param _powers The signing powers of the signers.
     */
    function executeMessageWithTransferRefund(
        bytes calldata _message, // the same message associated with the original transfer
        MsgDataTypes.TransferInfo calldata _transfer,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external payable;

    /**
     * @notice Execute a message not associated with a transfer.
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _sigs The list of signatures sorted by signing addresses in ascending order. A relay must be signed-off by
     * +2/3 of the sigsVerifier's current signing power to be delivered.
     * @param _signers The sorted list of signers.
     * @param _powers The signing powers of the signers.
     */
    function executeMessage(
        bytes calldata _message,
        MsgDataTypes.RouteInfo calldata _route,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external payable;
}

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity 0.8.16;

interface IMessageReceiverApp {
    enum ExecutionStatus {
        Fail, // execution failed, finalized
        Success, // execution succeeded, finalized
        Retry // execution rejected, can retry later
    }

    /**
     * @notice Called by MessageBus (MessageBusReceiver) if the process is originated from MessageBus (MessageBusSender)'s
     *         sendMessageWithTransfer it is only called when the tokens are checked to be arrived at this contract's address.
     * @param _sender The address of the source app contract
     * @param _token The address of the token that comes out of the bridge
     * @param _amount The amount of tokens received at this contract through the cross-chain bridge.
     *        the contract that implements this contract can safely assume that the tokens will arrive before this
     *        function is called.
     * @param _srcChainId The source chain ID where the transfer is originated from
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _executor Address who called the MessageBus execution function
     */
    function executeMessageWithTransfer(
        address _sender,
        address _token,
        uint256 _amount,
        uint64 _srcChainId,
        bytes calldata _message,
        address _executor
    ) external payable returns (ExecutionStatus);

    /**
     * @notice Only called by MessageBus (MessageBusReceiver) if
     *         1. executeMessageWithTransfer reverts, or
     *         2. executeMessageWithTransfer returns ExecutionStatus.Fail
     * @param _sender The address of the source app contract
     * @param _token The address of the token that comes out of the bridge
     * @param _amount The amount of tokens received at this contract through the cross-chain bridge.
     *        the contract that implements this contract can safely assume that the tokens will arrive before this
     *        function is called.
     * @param _srcChainId The source chain ID where the transfer is originated from
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _executor Address who called the MessageBus execution function
     */
    function executeMessageWithTransferFallback(
        address _sender,
        address _token,
        uint256 _amount,
        uint64 _srcChainId,
        bytes calldata _message,
        address _executor
    ) external payable returns (ExecutionStatus);

    /**
     * @notice Called by MessageBus (MessageBusReceiver) to process refund of the original transfer from this contract
     * @param _token The token address of the original transfer
     * @param _amount The amount of the original transfer
     * @param _message The same message associated with the original transfer
     * @param _executor Address who called the MessageBus execution function
     */
    function executeMessageWithTransferRefund(
        address _token,
        uint256 _amount,
        bytes calldata _message,
        address _executor
    ) external payable returns (ExecutionStatus);

    /**
     * @notice Called by MessageBus (MessageBusReceiver)
     * @param _sender The address of the source app contract
     * @param _srcChainId The source chain ID where the transfer is originated from
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _executor Address who called the MessageBus execution function
     */
    function executeMessage(
        address _sender,
        uint64 _srcChainId,
        bytes calldata _message,
        address _executor
    ) external payable returns (ExecutionStatus);
}

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../../interfaces/IBridge.sol";
import "../interfaces/IMessageBus.sol";
import "./MsgDataTypes.sol";

library MessageSenderLib {
    using SafeERC20 for IERC20;

    // ============== Internal library functions called by apps ==============

    /**
     * @notice Sends a message to a contract on another chain.
     * Sender needs to make sure the uniqueness of the message Id, which is computed as
     * hash(type.MessageOnly, sender, receiver, srcChainId, srcTxHash, dstChainId, message).
     * If messages with the same Id are sent, only one of them will succeed at dst chain.
     * @param _receiver The address of the destination app contract.
     * @param _dstChainId The destination chain ID.
     * @param _message Arbitrary message bytes to be decoded by the destination app contract.
     * @param _messageBus The address of the MessageBus on this chain.
     * @param _fee The fee amount to pay to MessageBus.
     */
    function sendMessage(
        address _receiver,
        uint64 _dstChainId,
        bytes memory _message,
        address _messageBus,
        uint256 _fee
    ) internal {
        IMessageBus(_messageBus).sendMessage{value : _fee}(_receiver, _dstChainId, _message);
    }

    /**
     * @notice Sends a message associated with a transfer to a contract on another chain.
     * @param _receiver The address of the destination app contract.
     * @param _token The address of the token to be sent.
     * @param _amount The amount of tokens to be sent.
     * @param _dstChainId The destination chain ID.
     * @param _nonce A number input to guarantee uniqueness of transferId. Can be timestamp in practice.
     * @param _maxSlippage The max slippage accepted, given as percentage in point (pip). Eg. 5000 means 0.5%.
     *        Must be greater than minimalMaxSlippage. Receiver is guaranteed to receive at least
     *        (100% - max slippage percentage) * amount or the transfer can be refunded.
     *        Only applicable to the {MsgDataTypes.BridgeSendType.Liquidity}.
     * @param _message Arbitrary message bytes to be decoded by the destination app contract.
     *        If message is empty, only the token transfer will be sent
     * @param _bridgeSendType One of the {MsgDataTypes.BridgeSendType} enum.
     * @param _messageBus The address of the MessageBus on this chain.
     * @param _fee The fee amount to pay to MessageBus.
     * @return The transfer ID.
     */
    function sendMessageWithTransfer(
        address _receiver,
        address _token,
        uint256 _amount,
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage,
        bytes memory _message,
        MsgDataTypes.BridgeSendType _bridgeSendType,
        address _messageBus,
        uint256 _fee
    ) internal returns (bytes32) {
        if (_bridgeSendType == MsgDataTypes.BridgeSendType.Liquidity) {
            return
            sendMessageWithLiquidityBridgeTransfer(
                _receiver,
                _token,
                _amount,
                _dstChainId,
                _nonce,
                _maxSlippage,
                _message,
                _messageBus,
                _fee
            );
        } else {
            revert("bridge type not supported");
        }
    }

    /**
     * @notice Sends a message to an app on another chain via MessageBus with an associated liquidity bridge transfer.
     * @param _receiver The address of the destination app contract.
     * @param _token The address of the token to be sent.
     * @param _amount The amount of tokens to be sent.
     * @param _dstChainId The destination chain ID.
     * @param _nonce A number input to guarantee uniqueness of transferId. Can be timestamp in practice.
     * @param _maxSlippage The max slippage accepted, given as percentage in point (pip). Eg. 5000 means 0.5%.
     *        Must be greater than minimalMaxSlippage. Receiver is guaranteed to receive at least
     *        (100% - max slippage percentage) * amount or the transfer can be refunded.
     * @param _message Arbitrary message bytes to be decoded by the destination app contract.
     *        If message is empty, only the token transfer will be sent
     * @param _messageBus The address of the MessageBus on this chain.
     * @param _fee The fee amount to pay to MessageBus.
     * @return The transfer ID.
     */
    function sendMessageWithLiquidityBridgeTransfer(
        address _receiver,
        address _token,
        uint256 _amount,
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage,
        bytes memory _message,
        address _messageBus,
        uint256 _fee
    ) internal returns (bytes32) {
        address bridge = IMessageBus(_messageBus).liquidityBridge();
        // IERC20(_token).safeIncreaseAllowance(bridge, _amount); // using safeIncreaseAllowance fails for eth.usdt
        SafeERC20.safeApprove(IERC20(_token), bridge, 0);
        SafeERC20.safeIncreaseAllowance(IERC20(_token), bridge, _amount);
        IBridge(bridge).send(_receiver, _token, _amount, _dstChainId, _nonce, _maxSlippage);
        bytes32 transferId = keccak256(
            abi.encodePacked(address(this), _receiver, _token, _amount, _dstChainId, _nonce, uint64(block.chainid))
        );
        if (_message.length > 0) {
            IMessageBus(_messageBus).sendMessageWithTransfer{value : _fee}(
                _receiver,
                _dstChainId,
                bridge,
                transferId,
                _message
            );
        }
        return transferId;
    }
}

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity 0.8.16;

library MsgDataTypes {
    // bridge operation type at the sender side (src chain)
    enum BridgeSendType {
        Null,
        Liquidity,
        PegDeposit,
        PegBurn,
        PegV2Deposit,
        PegV2Burn,
        PegV2BurnFrom
    }

    // bridge operation type at the receiver side (dst chain)
    enum TransferType {
        Null,
        LqRelay, // relay through liquidity bridge
        LqWithdraw, // withdraw from liquidity bridge
        PegMint, // mint through pegged token bridge
        PegWithdraw, // withdraw from original token vault
        PegV2Mint, // mint through pegged token bridge v2
        PegV2Withdraw // withdraw from original token vault v2
    }

    enum MsgType {
        MessageWithTransfer,
        MessageOnly
    }

    enum TxStatus {
        Null,
        Success,
        Fail,
        Fallback,
        Pending // transient state within a transaction
    }

    struct TransferInfo {
        TransferType t;
        address sender;
        address receiver;
        address token;
        uint256 amount;
        uint64 wdseq; // only needed for LqWithdraw (refund)
        uint64 srcChainId;
        bytes32 refId;
        bytes32 srcTxHash; // src chain msg tx hash
    }

    struct RouteInfo {
        address sender;
        address receiver;
        uint64 srcChainId;
        bytes32 srcTxHash; // src chain msg tx hash
    }

    struct MsgWithTransferExecutionParams {
        bytes message;
        TransferInfo transfer;
        bytes[] sigs;
        address[] signers;
        uint256[] powers;
    }

    struct BridgeTransferParams {
        bytes request;
        bytes[] sigs;
        address[] signers;
        uint256[] powers;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "./im/message/framework/MessageSenderApp.sol";
import "./im/message/framework/MessageReceiverApp.sol";
import "../../../interfaces/IUniswapV2.sol";
import "../../../interfaces/IWETH.sol";
import "./im/interfaces/IMessageBusSender.sol";
import "../../../interfaces/IRangoCBridge.sol";
import "../../../libraries/LibInterchain.sol";
import "../../../interfaces/IRangoMessageReceiver.sol";
import "../../../interfaces/Interchain.sol";
import "../../../utils/ReentrancyGuard.sol";
import "../../../libraries/LibDiamond.sol";
import {RangoCBridgeMiddleware} from "./RangoCBridgeMiddleware.sol";

/// @title The root contract that handles Rango's interaction with cBridge through a middleware
/// @author George
/// @dev Logic for direct interaction with CBridge is mostly implemented in RangoCBridgeMiddleware contract.
contract RangoCBridgeFacet is IRango, IRangoCBridge, ReentrancyGuard {
    /// @dev keccak256("exchange.rango.facets.cbridge")
    bytes32 internal constant CBRIDGE_NAMESPACE = hex"c41612f6cce3d3f6bab8332956a2c64db0d9b22d96d4f739ed2233d021aebb9b";

    struct cBridgeStorage {
        address payable rangoCBridgeMiddlewareAddress;
    }

    /// Constructor

    /// @notice Initialize the contract.
    /// @param rangoCBridgeMiddlewareAddress The address of rango cBridge middleware
    function initCBridge(address payable rangoCBridgeMiddlewareAddress) external {
        LibDiamond.enforceIsContractOwner();
        updateRangoCBridgeMiddlewareAddressInternal(rangoCBridgeMiddlewareAddress);
    }

    /// @notice Enables the contract to receive native ETH token from other contracts including WETH contract
    receive() external payable {}


    /// @notice Emits when the cBridge address is updated
    /// @param oldAddress The previous address
    /// @param newAddress The new address
    event RangoCBridgeMiddlewareAddressUpdated(address oldAddress, address newAddress);

    /// @notice Executes a DEX (arbitrary) call + a cBridge send function
    /// @param request The general swap request containing from/to token and fee/affiliate rewards
    /// @param calls The list of DEX calls, if this list is empty, it means that there is no DEX call and we are only bridging
    /// @dev The cbridge part is handled in the RangoCBridgeMiddleware contract
    /// @dev If this function is success, user will automatically receive the fund in the destination in his/her wallet (receiver)
    /// @dev If bridge is out of liquidity somehow after submiting this transaction and success, user must sign a refund transaction which is not currently present here, will be supported soon
    function cBridgeSwapAndBridge(
        LibSwapper.SwapRequest memory request,
        LibSwapper.Call[] calldata calls,
        CBridgeBridgeRequest calldata bridgeRequest
    ) external payable nonReentrant {
        address payable middleware = getCBridgeStorage().rangoCBridgeMiddlewareAddress;
        require(middleware != LibSwapper.ETH, "Middleware not set");
        // transfer tokens to middleware if necessary
        uint sgnFee = bridgeRequest.sgnFee;
        uint value = sgnFee;
        uint bridgeAmount;
        if (request.toToken == LibSwapper.ETH && msg.value == 0) {
            uint out = LibSwapper.onChainSwapsPreBridge(request, calls, 0);
            bridgeAmount = out - sgnFee;
            // value should not decrease sgnFee, we should send full value to the middleware
            value = out;
        }
        else {
            bridgeAmount = LibSwapper.onChainSwapsPreBridge(request, calls, sgnFee);
        }
        // transfer tokens to middleware if necessary
        if (request.toToken != LibSwapper.ETH) {
            SafeERC20.safeTransfer(IERC20(request.toToken), middleware, bridgeAmount);
        }

        if (bridgeRequest.bridgeType == CBridgeBridgeType.TRANSFER) {
            RangoCBridgeMiddleware(middleware).doSend{value : value}(
                bridgeRequest.receiver,
                request.toToken,
                bridgeAmount,
                bridgeRequest.dstChainId,
                bridgeRequest.nonce,
                bridgeRequest.maxSlippage);

            // event emission
            emit RangoBridgeInitiated(
                request.requestId,
                request.toToken,
                bridgeAmount,
                bridgeRequest.receiver,
                bridgeRequest.dstChainId,
                false,
                false,
                uint8(BridgeType.CBridge),
                request.dAppTag
            );
        } else {
            Interchain.RangoInterChainMessage memory imMessage = abi.decode((bridgeRequest.imMessage), (Interchain.RangoInterChainMessage));
            RangoCBridgeMiddleware(middleware).doCBridgeIM{value : value}(
                request.toToken,
                bridgeAmount,
                bridgeRequest.receiver,
                bridgeRequest.dstChainId,
                bridgeRequest.nonce,
                bridgeRequest.maxSlippage,
                sgnFee,
                imMessage
            );

            // event emission
            emit RangoBridgeInitiated(
                request.requestId,
                request.toToken,
                bridgeAmount,
                bridgeRequest.receiver,
                bridgeRequest.dstChainId,
                true,
                imMessage.actionType != Interchain.ActionType.NO_ACTION,
                uint8(BridgeType.CBridge),
                request.dAppTag
            );
        }
    }

    /// @notice Executes a DEX (arbitrary) call + a cBridge send function

    /// @dev The cbridge part is handled in the RangoCBridgeMiddleware contract
    /// @dev If this function is success, user will automatically receive the fund in the destination in his/her wallet (receiver)
    /// @dev If bridge is out of liquidity somehow after submiting this transaction and success, user must sign a refund transaction which is not currently present here, will be supported later
    function cBridgeBridge(
        RangoBridgeRequest memory request,
        CBridgeBridgeRequest calldata bridgeRequest
    ) external payable nonReentrant {
        address payable middleware = getCBridgeStorage().rangoCBridgeMiddlewareAddress;
        require(middleware != LibSwapper.ETH, "Middleware not set");
        // transfer tokens to middleware if necessary
        uint amount = request.amount;
        uint sumFees = LibSwapper.sumFees(request);
        uint value = bridgeRequest.sgnFee;
        if (request.token == LibSwapper.ETH) {
            require(msg.value >= amount + bridgeRequest.sgnFee + sumFees, "Insufficient ETH");
            value = amount + bridgeRequest.sgnFee;
        } else {
            // To save gas we dont transfer to this contract, instead we directly transfer from user to middleware.
            // Note we only send the amount to middleware (doesn't include fees)
            SafeERC20.safeTransferFrom(IERC20(request.token), msg.sender, middleware, amount);
            require(msg.value >= value, "Insufficient ETH");
        }

        // collect fees directly from sender
        LibSwapper.collectFeesFromSender(request);

        if (bridgeRequest.bridgeType == CBridgeBridgeType.TRANSFER) {
            RangoCBridgeMiddleware(middleware).doSend{value : value}(
                bridgeRequest.receiver,
                request.token,
                amount,
                bridgeRequest.dstChainId,
                bridgeRequest.nonce,
                bridgeRequest.maxSlippage);

            // event emission
            emit RangoBridgeInitiated(
                request.requestId,
                request.token,
                amount,
                bridgeRequest.receiver,
                bridgeRequest.dstChainId,
                false,
                false,
                uint8(BridgeType.CBridge),
                request.dAppTag
            );
        } else {
            Interchain.RangoInterChainMessage memory imMessage = abi.decode((bridgeRequest.imMessage), (Interchain.RangoInterChainMessage));
            RangoCBridgeMiddleware(middleware).doCBridgeIM{value : value}(
                request.token,
                amount,
                bridgeRequest.receiver,
                bridgeRequest.dstChainId,
                bridgeRequest.nonce,
                bridgeRequest.maxSlippage,
                bridgeRequest.sgnFee,
                imMessage
            );

            // event emission
            emit RangoBridgeInitiated(
                request.requestId,
                request.token,
                amount,
                bridgeRequest.receiver,
                bridgeRequest.dstChainId,
                true,
                imMessage.actionType != Interchain.ActionType.NO_ACTION,
                uint8(BridgeType.CBridge),
                request.dAppTag
            );
        }
    }

    function updateRangoCBridgeMiddlewareAddressInternal(address payable newAddress) private {
        cBridgeStorage storage s = getCBridgeStorage();

        address oldAddress = getRangoCBridgeMiddlewareAddress();
        s.rangoCBridgeMiddlewareAddress = newAddress;

        emit RangoCBridgeMiddlewareAddressUpdated(oldAddress, newAddress);
    }

    function getRangoCBridgeMiddlewareAddress() internal view returns (address) {
        cBridgeStorage storage s = getCBridgeStorage();
        return s.rangoCBridgeMiddlewareAddress;
    }

    /// @dev fetch local storage
    function getCBridgeStorage() private pure returns (cBridgeStorage storage s) {
        bytes32 namespace = CBRIDGE_NAMESPACE;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            s.slot := namespace
        }
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "./im/message/framework/MessageReceiverApp.sol";
import "./im/message/framework/MessageSenderApp.sol";
import "../../../libraries/LibInterchain.sol";
import "../../../utils/ReentrancyGuard.sol";
import "../../base/RangoAccessManagerFacet.sol";
import "../../base/RangoInterchainFacet.sol";
import "../../base/RangoBaseInterchainMiddleware.sol";

/// @title The middleware contract that handles Rango's interaction with cBridge.
/// @author George
/// @dev this contract works directly with cBridge and messagebus.
///      Note that this is not a facet and should be deployed separately.
contract RangoCBridgeMiddleware is RangoBaseInterchainMiddleware, IRango, MessageSenderApp, MessageReceiverApp, ReentrancyGuard {

    /// @dev keccak256("exchange.rango.middleware.cbridge")
    bytes32 internal constant CBIRDGE_MIDDLEWARE_NAMESPACE = hex"2ba094f4e7908864b6d0bf1b955a13285820ecdae1501be90101739a37f73d34";

    struct RangoCBridgeMiddlewareStorage {
        address cBridgeAddress;
        address rangoDiamond;
    }

    constructor(
        address _owner,
        address _cBridgeAddress,
        address _cBridgeMessageBusAddress,
        address _rangoDiamond,
        address _weth
    ) RangoBaseInterchainMiddleware(_owner, _rangoDiamond, _weth){
        updateCBridgeAddressInternal(_cBridgeAddress);
        setMessageBusInternal(_cBridgeMessageBusAddress);
    }

    /// Events

    /// @notice Emits when the cBridge address is updated
    /// @param oldAddress The previous address
    /// @param newAddress The new address
    event CBridgeAddressUpdated(address oldAddress, address newAddress);
    /// @notice A series of events with different status value to help us track the progress of cross-chain swap
    /// @param id The transferId generated by cBridge
    /// @param token The token address in the current network that is being bridged
    /// @param outputAmount The latest observed amount in the path, aka: input amount for source and output amount on dest
    /// @param destination The destination address that received the money, ZERO address if not sent to the end-user yet
    event CBridgeIMStatusUpdated(bytes32 id, address token, uint256 outputAmount, IRango.CrossChainOperationStatus status, address destination);
    /// @notice A simple cBridge.send scenario
    /// @param receiver The wallet address of receiver on the destination
    /// @param token The address of token on the source chain
    /// @param amount The input amount sent to the bridge
    /// @param dstChainId The network id of destination chain
    /// @param nonce A nonce mechanism used by cBridge that is generated off-chain, it normally is the time.now()
    /// @param maxSlippage The maximum tolerable slippage by user on cBridge side (The bridge is not 1-1 and may have slippage in big swaps)
    event CBridgeSend(address receiver, address token, uint256 amount, uint64 dstChainId, uint64 nonce, uint32 maxSlippage);

    /// Administration & Control

    /// @notice Updates the address of cBridge contract
    /// @param newAddress The new address of cBridge contract
    function updateCBridgeAddress(address newAddress) external onlyOwner {
        updateCBridgeAddressInternal(newAddress);
    }
    /// @notice Updates the address of messageBus
    /// @param _messageBus The new address of messageBus
    function setMessageBus(address _messageBus) external onlyOwner {
        setMessageBusInternal(_messageBus);
    }

    /// @inheritdoc IMessageReceiverApp
    /// @dev We also send a message to dApp if dAppMessage is valid
    /// @dev We refund the money back to the message.originalSender which is the source wallet address or any wallet that dapp likes to be receiver of the refund
    function executeMessageWithTransferRefund(
        address token,
        uint256 amount,
        bytes calldata message,
        address // executor
    ) external payable override onlyMessageBus nonReentrant returns (ExecutionStatus) {
        Interchain.RangoInterChainMessage memory m = abi.decode((message), (Interchain.RangoInterChainMessage));

        LibSwapper.BaseSwapperStorage storage baseStorage = LibSwapper.getBaseSwapperStorage();
        address fromToken = token;
        if (token == baseStorage.WETH) {
            if (IERC20(token).balanceOf(address(this)) < amount) {
                if (address(this).balance >= amount) {
                    fromToken = LibSwapper.ETH;
                } else {
                    revert("Neither WETH nor ETH were found on contract");
                }
            }
        }

        LibInterchain._sendTokenWithDApp(
            fromToken,
            amount,
            m.originalSender,
            m.dAppMessage,
            m.dAppSourceContract,
            IRangoMessageReceiver.ProcessStatus.REFUND_IN_SOURCE
        );

        emit RangoBridgeCompleted(
            m.requestId,
            fromToken,
            m.originalSender,
            m.recipient,
            amount,
            IRango.CrossChainOperationStatus.RefundInSource,
            m.dAppTag
        );
        return ExecutionStatus.Success;
    }

    /// @inheritdoc IMessageReceiverApp
    /**
     * @dev If our message contains a uniswap-like DEX call on the destination we also perform it here
     * There are also some flags such as:
     * 1. message.bridgeNativeOut which indicates that bridge sent native token to us, so we unwrap it if required
     * 2. message.nativeOut which indicates that we should send native token to end-user/dapp so we unwrap it if needed
     */
    function executeMessageWithTransfer(
        address, // sender
        address token,
        uint256 amount,
        uint64 srcChainId,
        bytes memory message,
        address // executor
    ) external payable override onlyMessageBus nonReentrant returns (ExecutionStatus) {
        Interchain.RangoInterChainMessage memory m = abi.decode((message), (Interchain.RangoInterChainMessage));
        (address receivedToken, uint dstAmount, IRango.CrossChainOperationStatus status) = LibInterchain.handleDestinationMessage(token, amount, m);

        emit RangoBridgeCompleted(
            m.requestId,
            receivedToken,
            m.originalSender,
            m.recipient,
            dstAmount,
            status,
            m.dAppTag
        );
        // always return success since swap failure is already handled in-place
        return ExecutionStatus.Success;
    }

    /// @inheritdoc IMessageReceiverApp
    /// @dev In case of failure in the destination, we only send money to the end-user in the destination
    function executeMessageWithTransferFallback(
        address, // sender
        address token, // token
        uint256 amount, // amount
        uint64 srcChainId,
        bytes memory message,
        address // executor
    ) external payable override onlyMessageBus nonReentrant returns (ExecutionStatus) {
        Interchain.RangoInterChainMessage memory m = abi.decode((message), (Interchain.RangoInterChainMessage));
        LibSwapper.BaseSwapperStorage storage baseStorage = LibSwapper.getBaseSwapperStorage();

        address sourceToken = m.bridgeRealOutput == LibSwapper.ETH && token == baseStorage.WETH ? LibSwapper.ETH : token;

        LibInterchain._sendTokenWithDApp(
            sourceToken,
            amount,
            m.recipient,
            m.dAppMessage,
            m.dAppSourceContract,
            IRangoMessageReceiver.ProcessStatus.REFUND_IN_DESTINATION
        );

        emit RangoBridgeCompleted(
            m.requestId,
            token,
            m.originalSender,
            m.recipient,
            amount,
            IRango.CrossChainOperationStatus.RefundInDestination,
            m.dAppTag
        );
        return ExecutionStatus.Fail;
    }

    /// @notice Computes the sgnFee for a given message based on messageBus formula
    /// @param imMessage The message that fee is computed for
    function computeCBridgeSgnFee(Interchain.RangoInterChainMessage memory imMessage) external view returns (uint) {
        bytes memory msgBytes = abi.encode(imMessage);
        return IMessageBus(getMsgBusAddress()).calcFee(msgBytes);
    }

    /// @notice Executes a bridging via cBridge
    /// @param receiver The receiver address in the destination chain
    /// @param token The token address to be bridged
    /// @param amount The amount of the token to be bridged
    /// @param dstChainId The network id of destination chain, ex: 10 for optimism
    /// @param nonce A nonce mechanism used by cBridge that is generated off-chain, it normally is the time.now()
    /// @param maxSlippage The maximum tolerable slippage by user on cBridge side (The bridge is not 1-1 and may have slippage in big swaps)
    function doSend(
        address receiver,
        address token,
        uint256 amount,
        uint64 dstChainId,
        uint64 nonce,
        uint32 maxSlippage
    ) external payable nonReentrant onlyDiamond {
        address cBridgeAddress = getRangoCBridgeMiddlewareStorage().cBridgeAddress;
        require(cBridgeAddress != LibSwapper.ETH, 'cBridge address not set');
        if (token != LibSwapper.ETH) {
            LibSwapper.approve(token, cBridgeAddress, amount);
            IBridge(cBridgeAddress).send(receiver, token, amount, dstChainId, nonce, maxSlippage);
        } else {
            IBridge(cBridgeAddress).sendNative{value : amount}(receiver, amount, dstChainId, nonce, maxSlippage);
        }
        emit CBridgeSend(receiver, token, amount, dstChainId, nonce, maxSlippage);
    }

    /// @notice Executes a cBridgeIM call
    /// @param fromToken The address of source token to bridge
    /// @param inputAmount The amount of input to be bridged
    /// @param receiverContract Our RangoCBridge.sol contract in the destination chain that will handle the destination logic
    /// @param dstChainId The network id of destination chain, ex: 10 for optimism
    /// @param nonce A nonce mechanism used by cBridge that is generated off-chain, it normally is the time.now()
    /// @param maxSlippage The maximum tolerable slippage by user on cBridge side (The bridge is not 1-1 and may have slippage in big swaps)
    /// @param sgnFee The fee amount (in native token) that cBridge IM charges for delivering the message
    /// @param imMessage Our custom interchain message that contains all the required info for the RangoCBridge.sol on the destination
    function doCBridgeIM(
        address fromToken,
        uint inputAmount,
        address receiverContract, // The receiver app contract address, not recipient
        uint64 dstChainId,
        uint64 nonce,
        uint32 maxSlippage,
        uint sgnFee,

        Interchain.RangoInterChainMessage memory imMessage
    ) external payable nonReentrant onlyDiamond {
        require(msg.value >= sgnFee, 'sgnFee is bigger than the input');
        address cBridgeAddress = getRangoCBridgeMiddlewareStorage().cBridgeAddress;
        address messageBus = getMsgBusAddress();

        require(messageBus != LibSwapper.ETH, 'cBridge message-bus address not set');
        require(cBridgeAddress != LibSwapper.ETH, 'cBridge address not set');
        require(imMessage.dstChainId == dstChainId, 'dstChainId and imMessage.dstChainId do not match');

        if (fromToken != LibSwapper.ETH)
            LibSwapper.approve(fromToken, cBridgeAddress, inputAmount);

        bytes memory message = abi.encode(imMessage);

        sendMessageWithTransfer(
            receiverContract,
            fromToken,
            inputAmount,
            dstChainId,
            nonce,
            maxSlippage,
            message,
            MsgDataTypes.BridgeSendType.Liquidity,
            sgnFee
        );
    }

    function updateCBridgeAddressInternal(address newAddress) private {
        RangoCBridgeMiddlewareStorage storage s = getRangoCBridgeMiddlewareStorage();
        address oldAddress = s.cBridgeAddress;
        s.cBridgeAddress = newAddress;
        emit CBridgeAddressUpdated(oldAddress, newAddress);
    }

    /// @dev fetch local storage
    function getRangoCBridgeMiddlewareStorage() private pure returns (RangoCBridgeMiddlewareStorage storage s) {
        bytes32 namespace = CBIRDGE_MIDDLEWARE_NAMESPACE;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            s.slot := namespace
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IDiamondCut {
    enum FacetCutAction {
        Add,
        Replace,
        Remove
    }
    // Add=0, Replace=1, Remove=2

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    /// @notice Add/replace/remove any number of functions and optionally execute
    ///         a function with delegatecall
    /// @param _diamondCut Contains the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments
    ///                  _calldata is executed with delegatecall on _init
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external;

    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

/// @title An interface to interchain message types
/// @author Uchiha Sasuke
interface Interchain {
    enum ActionType { NO_ACTION, UNI_V2, UNI_V3, CALL }
    enum CallSubActionType { WRAP, UNWRAP, NO_ACTION }

    struct RangoInterChainMessage {
        address requestId;
        uint64 dstChainId;
        address bridgeRealOutput;
        address toToken;
        address originalSender;
        address recipient;
        ActionType actionType;
        bytes action;
        CallSubActionType postAction;
        uint16 dAppTag;

        // Extra message
        bytes dAppMessage;
        address dAppSourceContract;
        address dAppDestContract;
    }

    struct UniswapV2Action {
        address dexAddress;
        uint amountOutMin;
        address[] path;
        uint deadline;
    }

    struct UniswapV3ActionExactInputSingleParams {
        address dexAddress;
        address tokenIn;
        address tokenOut;
        uint24 fee;
        uint256 deadline;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice The requested call data which is computed off-chain and passed to the contract
    /// @param target The dex contract address that should be called
    /// @param callData The required data field that should be give to the dex contract to perform swap
    struct CallAction {
        address tokenIn;
        address spender;
        CallSubActionType preAction;
        address payable target;
        bytes callData;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IRango {
    struct RangoBridgeRequest {
        address requestId;
        address token;
        uint amount;
        uint platformFee;
        uint affiliateFee;
        address payable affiliatorAddress;
        uint destinationExecutorFee;
        uint16 dAppTag;
    }

    enum BridgeType {Across, CBridge, Hop, Hyphen, Multichain, Stargate, Synapse, Thorchain, Symbiosis, Axelar, Voyager, Poly, OptimismBridge, ArbitrumBridge, Wormhole, AllBridge}

    /// @notice Status of cross-chain swap
    /// @param Succeeded The whole process is success and end-user received the desired token in the destination
    /// @param RefundInSource Bridge was out of liquidity and middle asset (ex: USDC) is returned to user on source chain
    /// @param RefundInDestination Our handler on dest chain this.executeMessageWithTransfer failed and we send middle asset (ex: USDC) to user on destination chain
    /// @param SwapFailedInDestination Everything was ok, but the final DEX on destination failed (ex: Market price change and slippage)
    enum CrossChainOperationStatus {
        Succeeded,
        RefundInSource,
        RefundInDestination,
        SwapFailedInDestination
    }

    event RangoBridgeInitiated(
        address indexed requestId,
        address bridgeToken,
        uint256 bridgeAmount,
        address receiver,
        uint destinationChainId,
        bool hasInterchainMessage,
        bool hasDestinationSwap,
        uint8 indexed bridgeId,
        uint16 indexed dAppTag
    );

    event RangoBridgeCompleted(
        address indexed requestId,
        address indexed token,
        address indexed originalSender,
        address receiver,
        uint amount,
        CrossChainOperationStatus status,
        uint16 dAppTag
    );

}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "./Interchain.sol";
import "../libraries/LibSwapper.sol";

/// @title An interface to RangoCBridge.sol contract to improve type hinting
/// @author Uchiha Sasuke
interface IRangoCBridge {
    enum CBridgeBridgeType {TRANSFER, TRANSFER_WITH_MESSAGE}
    /// @param receiver The receiver address in the destination chain. For interchain message, receiver is the dApp contract address on destination, not recipient
    /// @param dstChainId The network id of destination chain, ex: 10 for optimism
    /// @param nonce A nonce mechanism used by cBridge that is generated off-chain, it normally is the time.now()
    /// @param maxSlippage The maximum tolerable slippage by user on cBridge side (The bridge is not 1-1 and may have slippage in big swaps)
    struct CBridgeBridgeRequest {
        CBridgeBridgeType bridgeType;
        address receiver;
        uint64 dstChainId;
        uint64 nonce;
        uint32 maxSlippage;
        uint sgnFee;
        bytes imMessage;
    }

    function cBridgeBridge(
        IRango.RangoBridgeRequest memory request,
        CBridgeBridgeRequest calldata bridgeRequest
    ) external payable;

    function cBridgeSwapAndBridge(
        LibSwapper.SwapRequest memory request,
        LibSwapper.Call[] calldata calls,
        CBridgeBridgeRequest calldata bridgeRequest
    ) external payable;

}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

interface IRangoMessageReceiver {
    enum ProcessStatus { SUCCESS, REFUND_IN_SOURCE, REFUND_IN_DESTINATION }

    function handleRangoMessage(
        address token,
        uint amount,
        ProcessStatus status,
        bytes memory message
    ) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "./IStargateRouter.sol";
import "./Interchain.sol";
import "./IRango.sol";
import "../libraries/LibSwapper.sol";

/// @title An interface to interact with RangoStargateFacet
/// @author Uchiha Sasuke
interface IRangoStargate {
    enum StargateBridgeType {TRANSFER, TRANSFER_WITH_MESSAGE}

    struct StargateRequest {
        StargateBridgeType bridgeType;
        uint16 dstChainId;
        uint256 srcPoolId;
        uint256 dstPoolId;
        address payable srcGasRefundAddress;
        uint256 minAmountLD;

        uint256 dstGasForCall;
        uint256 dstNativeAmount;
        bytes dstNativeAddr;

        bytes to;
        uint stgFee;

        bytes imMessage;
    }

    function stargateSwapAndBridge(
        LibSwapper.SwapRequest memory request,
        LibSwapper.Call[] calldata calls,
        IRangoStargate.StargateRequest memory stargateRequest
    ) external payable;

    function stargateBridge(
        IRangoStargate.StargateRequest memory stargateRequest,
        IRango.RangoBridgeRequest memory bridgeRequest
    ) external payable;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

interface IStargateReceiver {
    function sgReceive(
        uint16 chainId,
        bytes memory srcAddress,
        uint256 nonce,
        address token,
        uint256 amountLD,
        bytes memory payload
    ) external;
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.16;

interface IStargateRouter {
    struct lzTxObj {
        uint256 dstGasForCall;
        uint256 dstNativeAmount;
        bytes dstNativeAddr;
    }

    function swap(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        uint256 _amountLD,
        uint256 _minAmountLD,
        lzTxObj memory _lzTxParams,
        bytes calldata _to,
        bytes calldata _payload
    ) external payable;

    function swapETH(
        uint16 _dstChainId,
        address payable _refundAddress,
        bytes calldata _toAddress,
        uint256 _amountLD,
        uint256 _minAmountLD
    ) external payable;

    function quoteLayerZeroFee(
        uint16 _dstChainId,
        uint8 _functionType,
        bytes calldata _toAddress,
        bytes calldata _transferAndCallPayload,
        lzTxObj memory _lzTxParams
    ) external view returns (uint256, uint256);
}

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity 0.8.16;

/// @dev based on swap router of uniswap v2 https://docs.uniswap.org/protocol/V2/reference/smart-contracts/router-02#swapexactethfortokens
interface IUniswapV2 {
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity 0.8.16;
/// @dev based on IswapRouter of UniswapV3 https://docs.uniswap.org/protocol/reference/periphery/interfaces/ISwapRouter
interface IUniswapV3 {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);
}

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity 0.8.16;

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { IDiamondCut } from "../interfaces/IDiamondCut.sol";

/// Implementation of EIP-2535 Diamond Standard
/// https://eips.ethereum.org/EIPS/eip-2535
library LibDiamond {
    /// @dev keccak256("diamond.standard.diamond.storage");
    bytes32 internal constant DIAMOND_STORAGE_POSITION = hex"c8fcad8db84d3cc18b4c41d551ea0ee66dd599cde068d998e57d5e09332c131c";

    // Diamond specific errors
    error IncorrectFacetCutAction();
    error NoSelectorsInFacet();
    error FunctionAlreadyExists();
    error FacetAddressIsZero();
    error FacetAddressIsNotZero();
    error FacetContainsNoCode();
    error FunctionDoesNotExist();
    error FunctionIsImmutable();
    error InitZeroButCalldataNotEmpty();
    error CalldataEmptyButInitNotZero();
    error InitReverted();
    // ----------------

    struct FacetAddressAndPosition {
        address facetAddress;
        uint96 functionSelectorPosition; // position in facetFunctionSelectors.functionSelectors array
    }

    struct FacetFunctionSelectors {
        bytes4[] functionSelectors;
        uint256 facetAddressPosition; // position of facetAddress in facetAddresses array
    }

    struct DiamondStorage {
        // maps function selector to the facet address and
        // the position of the selector in the facetFunctionSelectors.selectors array
        mapping(bytes4 => FacetAddressAndPosition) selectorToFacetAndPosition;
        // maps facet addresses to function selectors
        mapping(address => FacetFunctionSelectors) facetFunctionSelectors;
        // facet addresses
        address[] facetAddresses;
        // Used to query if a contract implements an interface.
        // Used to implement ERC-165.
        mapping(bytes4 => bool) supportedInterfaces;
        // owner of the contract
        address contractOwner;
    }

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            ds.slot := position
        }
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function setContractOwner(address _newOwner) internal {
        DiamondStorage storage ds = diamondStorage();
        address previousOwner = ds.contractOwner;
        ds.contractOwner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function contractOwner() internal view returns (address contractOwner_) {
        contractOwner_ = diamondStorage().contractOwner;
    }

    function enforceIsContractOwner() internal view {
        require(msg.sender == diamondStorage().contractOwner, "LibDiamond: Must be contract owner");
    }

    event DiamondCut(IDiamondCut.FacetCut[] _diamondCut, address _init, bytes _calldata);

    // Internal function version of diamondCut
    function diamondCut(
        IDiamondCut.FacetCut[] memory _diamondCut,
        address _init,
        bytes memory _calldata
    ) internal {
        for (uint256 facetIndex; facetIndex < _diamondCut.length; ) {
            IDiamondCut.FacetCutAction action = _diamondCut[facetIndex].action;
            if (action == IDiamondCut.FacetCutAction.Add) {
                addFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);
            } else if (action == IDiamondCut.FacetCutAction.Replace) {
                replaceFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);
            } else if (action == IDiamondCut.FacetCutAction.Remove) {
                removeFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);
            } else {
                revert IncorrectFacetCutAction();
            }
            unchecked {
                ++facetIndex;
            }
        }
        emit DiamondCut(_diamondCut, _init, _calldata);
        initializeDiamondCut(_init, _calldata);
    }

    function addFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        if (_facetAddress == address(0)) {
            revert FacetAddressIsZero();
        }
        if (_functionSelectors.length == 0) {
            revert NoSelectorsInFacet();
        }
        DiamondStorage storage ds = diamondStorage();
        uint96 selectorPosition = uint96(ds.facetFunctionSelectors[_facetAddress].functionSelectors.length);
        // add new facet address if it does not exist
        if (selectorPosition == 0) {
            addFacet(ds, _facetAddress);
        }
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; ) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds.selectorToFacetAndPosition[selector].facetAddress;
            if (oldFacetAddress != address(0)) {
                revert FunctionAlreadyExists();
            }
            addFunction(ds, selector, selectorPosition, _facetAddress);
            unchecked {
                ++selectorPosition;
                ++selectorIndex;
            }
        }
    }

    function replaceFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        if (_functionSelectors.length == 0) {
            revert NoSelectorsInFacet();
        }
        if (_facetAddress == address(0)) {
            revert FacetAddressIsZero();
        }
        DiamondStorage storage ds = diamondStorage();
        uint96 selectorPosition = uint96(ds.facetFunctionSelectors[_facetAddress].functionSelectors.length);
        // add new facet address if it does not exist
        if (selectorPosition == 0) {
            addFacet(ds, _facetAddress);
        }
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; ) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds.selectorToFacetAndPosition[selector].facetAddress;
            if (oldFacetAddress == _facetAddress) {
                revert FunctionAlreadyExists();
            }
            removeFunction(ds, oldFacetAddress, selector);
            addFunction(ds, selector, selectorPosition, _facetAddress);
            unchecked {
                ++selectorPosition;
                ++selectorIndex;
            }
        }
    }

    function removeFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        if (_functionSelectors.length == 0) {
            revert NoSelectorsInFacet();
        }
        DiamondStorage storage ds = diamondStorage();
        // if function does not exist then do nothing and return
        if (_facetAddress != address(0)) {
            revert FacetAddressIsNotZero();
        }
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; ) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds.selectorToFacetAndPosition[selector].facetAddress;
            removeFunction(ds, oldFacetAddress, selector);
            unchecked {
                ++selectorIndex;
            }
        }
    }

    function addFacet(DiamondStorage storage ds, address _facetAddress) internal {
        enforceHasContractCode(_facetAddress);
        ds.facetFunctionSelectors[_facetAddress].facetAddressPosition = ds.facetAddresses.length;
        ds.facetAddresses.push(_facetAddress);
    }

    function addFunction(
        DiamondStorage storage ds,
        bytes4 _selector,
        uint96 _selectorPosition,
        address _facetAddress
    ) internal {
        ds.selectorToFacetAndPosition[_selector].functionSelectorPosition = _selectorPosition;
        ds.facetFunctionSelectors[_facetAddress].functionSelectors.push(_selector);
        ds.selectorToFacetAndPosition[_selector].facetAddress = _facetAddress;
    }

    function removeFunction(
        DiamondStorage storage ds,
        address _facetAddress,
        bytes4 _selector
    ) internal {
        if (_facetAddress == address(0)) {
            revert FunctionDoesNotExist();
        }
        // an immutable function is a function defined directly in a diamond
        if (_facetAddress == address(this)) {
            revert FunctionIsImmutable();
        }
        // replace selector with last selector, then delete last selector
        uint256 selectorPosition = ds.selectorToFacetAndPosition[_selector].functionSelectorPosition;
        uint256 lastSelectorPosition = ds.facetFunctionSelectors[_facetAddress].functionSelectors.length - 1;
        // if not the same then replace _selector with lastSelector
        if (selectorPosition != lastSelectorPosition) {
            bytes4 lastSelector = ds.facetFunctionSelectors[_facetAddress].functionSelectors[lastSelectorPosition];
            ds.facetFunctionSelectors[_facetAddress].functionSelectors[selectorPosition] = lastSelector;
            ds.selectorToFacetAndPosition[lastSelector].functionSelectorPosition = uint96(selectorPosition);
        }
        // delete the last selector
        ds.facetFunctionSelectors[_facetAddress].functionSelectors.pop();
        delete ds.selectorToFacetAndPosition[_selector];

        // if no more selectors for facet address then delete the facet address
        if (lastSelectorPosition == 0) {
            // replace facet address with last facet address and delete last facet address
            uint256 lastFacetAddressPosition = ds.facetAddresses.length - 1;
            uint256 facetAddressPosition = ds.facetFunctionSelectors[_facetAddress].facetAddressPosition;
            if (facetAddressPosition != lastFacetAddressPosition) {
                address lastFacetAddress = ds.facetAddresses[lastFacetAddressPosition];
                ds.facetAddresses[facetAddressPosition] = lastFacetAddress;
                ds.facetFunctionSelectors[lastFacetAddress].facetAddressPosition = facetAddressPosition;
            }
            ds.facetAddresses.pop();
            delete ds.facetFunctionSelectors[_facetAddress].facetAddressPosition;
        }
    }

    function initializeDiamondCut(address _init, bytes memory _calldata) internal {
        if (_init == address(0)) {
            if (_calldata.length != 0) {
                revert InitZeroButCalldataNotEmpty();
            }
        } else {
            if (_calldata.length == 0) {
                revert CalldataEmptyButInitNotZero();
            }
            if (_init != address(this)) {
                enforceHasContractCode(_init);
            }
            // solhint-disable-next-line avoid-low-level-calls
            (bool success, bytes memory error) = _init.delegatecall(_calldata);
            if (!success) {
                if (error.length > 0) {
                    // bubble up the error
                    revert(string(error));
                } else {
                    revert InitReverted();
                }
            }
        }
    }

    function enforceHasContractCode(address _contract) internal view {
        uint256 contractSize;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            contractSize := extcodesize(_contract)
        }
        if (contractSize == 0) {
            revert FacetContainsNoCode();
        }
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IUniswapV2.sol";
import "../interfaces/IUniswapV3.sol";
import "../interfaces/IWETH.sol";
import "../interfaces/IRangoStargate.sol";
import "../interfaces/IStargateReceiver.sol";
import "../interfaces/IRangoMessageReceiver.sol";
import "./LibSwapper.sol";

library LibInterchain {

    /// @dev keccak256("exchange.rango.library.interchain")
    bytes32 internal constant BASE_MESSAGING_CONTRACT_NAMESPACE = hex"ff95014231b901d2b22bd69b4e83dacd84ac05e8c2d1e9fba0c7e2f3ed0db0eb";

    struct BaseInterchainStorage {
        mapping (address => bool) whitelistMessagingContracts;
    }

    // @notice Adds a contract to the whitelisted messaging dApps that can be called
    /// @param _dapp The address of dApp
    function addMessagingDApp(address _dapp) internal {
        BaseInterchainStorage storage baseStorage = getBaseMessagingContractStorage();
        baseStorage.whitelistMessagingContracts[_dapp] = true;
    }

    /// @notice Removes a contract from dApps that can be called
    /// @param _dapp The address of dApp
    function removeMessagingDApp(address _dapp) internal {
        BaseInterchainStorage storage baseStorage = getBaseMessagingContractStorage();

        require(baseStorage.whitelistMessagingContracts[_dapp], "contract not whitelisted");
        delete baseStorage.whitelistMessagingContracts[_dapp];
    }

    /// @notice This event indicates that a dApp used Rango messaging (dAppMessage field) and we delivered the message to it
    /// @param _receiverContract The address of dApp's contract that was called
    /// @param _token The address of the token that is sent to the dApp, ETH for native token
    /// @param _amount The amount of the token sent to them
    /// @param _status The status of operation, informing the dApp that the whole process was a success or refund
    /// @param _appMessage The custom message that the dApp asked Rango to deliver
    /// @param success Indicates that the function call to the dApp encountered error or not
    /// @param failReason If success = false, failReason will be the string reason of the failure (aka message of require)
    event CrossChainMessageCalled(
        address _receiverContract,
        address _token,
        uint _amount,
        IRangoMessageReceiver.ProcessStatus _status,
        bytes _appMessage,
        bool success,
        string failReason
    );

    event ActionDone(Interchain.ActionType actionType, address contractAddress, bool success, string reason);
    event SubActionDone(Interchain.CallSubActionType subActionType, address contractAddress, bool success, string reason);

    function encodeIm(Interchain.RangoInterChainMessage memory im) external pure returns (bytes memory) {
        return abi.encode(im);
    }

    function handleDestinationMessage(
        address _token,
        uint _amount,
        Interchain.RangoInterChainMessage memory m
    ) internal returns (address, uint256 dstAmount, IRango.CrossChainOperationStatus status) {

        LibSwapper.BaseSwapperStorage storage baseStorage = LibSwapper.getBaseSwapperStorage();
        address sourceToken = m.bridgeRealOutput == LibSwapper.ETH && _token == baseStorage.WETH ? LibSwapper.ETH : _token;

        bool ok = true;
        address receivedToken = sourceToken;
        dstAmount = _amount;

        if (m.actionType == Interchain.ActionType.UNI_V2)
            (ok, dstAmount, receivedToken) = _handleUniswapV2(sourceToken, _amount, m, baseStorage);
        else if (m.actionType == Interchain.ActionType.UNI_V3)
            (ok, dstAmount, receivedToken) = _handleUniswapV3(sourceToken, _amount, m, baseStorage);
        else if (m.actionType == Interchain.ActionType.CALL)
            (ok, dstAmount, receivedToken) = _handleCall(sourceToken, _amount, m, baseStorage);
        else if (m.actionType != Interchain.ActionType.NO_ACTION)
            revert("Unsupported actionType");

        if (ok && m.postAction != Interchain.CallSubActionType.NO_ACTION) {
            (ok, dstAmount, receivedToken) = _handlePostAction(receivedToken, dstAmount, m.postAction, baseStorage);
        }

        status = ok ? IRango.CrossChainOperationStatus.Succeeded : IRango.CrossChainOperationStatus.RefundInDestination;
        IRangoMessageReceiver.ProcessStatus dAppStatus = ok 
            ? IRangoMessageReceiver.ProcessStatus.SUCCESS 
            : IRangoMessageReceiver.ProcessStatus.REFUND_IN_DESTINATION;

        _sendTokenWithDApp(receivedToken, dstAmount, m.recipient, m.dAppMessage, m.dAppDestContract, dAppStatus);

        return (receivedToken, dstAmount, status);
    }

    /// @notice Performs a uniswap-v2 operation
    /// @param _message The interchain message that contains the swap info
    /// @param _amount The amount of input token
    /// @return ok Indicates that the swap operation was success or fail
    /// @return amountOut If ok = true, amountOut is the output amount of the swap
    function _handleUniswapV2(
        address _token,
        uint _amount,
        Interchain.RangoInterChainMessage memory _message,
        LibSwapper.BaseSwapperStorage storage baseStorage
    ) private returns (bool ok, uint256 amountOut, address outToken) {
        Interchain.UniswapV2Action memory action = abi.decode((_message.action), (Interchain.UniswapV2Action));
        require(baseStorage.whitelistContracts[action.dexAddress] == true, "Dex address is not whitelisted");
        require(action.path.length >= 2, "Invalid uniswap-V2 path");

        bool shouldDeposit = _token == LibSwapper.ETH && action.path[0] == baseStorage.WETH;
        if (!shouldDeposit)
            require(_token == action.path[0], "bridged token must be the same as the first token in destination swap path");
        else {
            require(action.path[0] == baseStorage.WETH, "Invalid uniswap-V2 path");
            IWETH(baseStorage.WETH).deposit{value: _amount}();
        }

        LibSwapper.approve(action.path[0], action.dexAddress, _amount);

        try
            IUniswapV2(action.dexAddress).swapExactTokensForTokens(
                _amount,
                action.amountOutMin,
                action.path,
                address(this),
                action.deadline
            )
        returns (uint256[] memory amounts) {
            emit ActionDone(Interchain.ActionType.UNI_V2, action.dexAddress, true, "");
            return (true, amounts[amounts.length - 1], action.path[action.path.length - 1]);
        } catch {
            emit ActionDone(Interchain.ActionType.UNI_V2, action.dexAddress, true, "Uniswap-V2 call failed");
            return (false, _amount, shouldDeposit ? baseStorage.WETH : _token);
        }
    }

    /// @notice Performs a uniswap-v3 operation
    /// @param _message The interchain message that contains the swap info
    /// @param _amount The amount of input token
    /// @return ok Indicates that the swap operation was success or fail
    /// @return amountOut If ok = true, amountOut is the output amount of the swap
    function _handleUniswapV3(
        address _token,
        uint _amount,
        Interchain.RangoInterChainMessage memory _message,
        LibSwapper.BaseSwapperStorage storage baseStorage
    ) private returns (bool, uint256, address) {
        Interchain.UniswapV3ActionExactInputSingleParams memory action = abi
            .decode((_message.action), (Interchain.UniswapV3ActionExactInputSingleParams));

        require(baseStorage.whitelistContracts[action.dexAddress] == true, "Dex address is not whitelisted");

        bool shouldDeposit = _token == LibSwapper.ETH && action.tokenIn == baseStorage.WETH;
        if (!shouldDeposit)
            require(_token == action.tokenIn, "bridged token must be the same as the tokenIn in uniswapV3");
        else {
            require(action.tokenIn == baseStorage.WETH, "Invalid uniswap-V2 path");
            IWETH(baseStorage.WETH).deposit{value: _amount}();
        }

        LibSwapper.approve(action.tokenIn, action.dexAddress, _amount);

        try
            IUniswapV3(action.dexAddress).exactInputSingle(IUniswapV3.ExactInputSingleParams({
                tokenIn : action.tokenIn,
                tokenOut : action.tokenOut,
                fee : action.fee,
                recipient : address(this),
                deadline : action.deadline,
                amountIn : _amount,
                amountOutMinimum : action.amountOutMinimum,
                sqrtPriceLimitX96 : action.sqrtPriceLimitX96
            }))
        returns (uint amountOut) {
            emit ActionDone(Interchain.ActionType.UNI_V3, action.dexAddress, true, "");
            return (true, amountOut, action.tokenOut);
        } catch {
            emit ActionDone(Interchain.ActionType.UNI_V3, action.dexAddress, false, "Uniswap-V3 call failed");
            return (false, _amount, shouldDeposit ? baseStorage.WETH : _token);
        }
    }

    /// @notice Performs a uniswap-v2 operation
    /// @param _message The interchain message that contains the swap info
    /// @param _amount The amount of input token
    /// @return ok Indicates that the swap operation was success or fail
    /// @return amountOut If ok = true, amountOut is the output amount of the swap
    function _handleCall(
        address _token,
        uint _amount,
        Interchain.RangoInterChainMessage memory _message,
        LibSwapper.BaseSwapperStorage storage baseStorage
    ) private returns (bool ok, uint256 amountOut, address outToken) {
        Interchain.CallAction memory action = abi.decode((_message.action), (Interchain.CallAction));

        require(baseStorage.whitelistContracts[action.target] == true, "Action.target is not whitelisted");
        require(baseStorage.whitelistContracts[action.spender] == true, "Action.spender is not whitelisted");

        address sourceToken = _token;

        if (action.preAction == Interchain.CallSubActionType.WRAP) {
            require(_token == LibSwapper.ETH, "Cannot wrap non-native");
            require(action.tokenIn == baseStorage.WETH, "action.tokenIn must be WETH");
            (ok, amountOut, sourceToken) = _handleWrap(_token, _amount, baseStorage);
        } else if (action.preAction == Interchain.CallSubActionType.UNWRAP) {
            require(_token == baseStorage.WETH, "Cannot unwrap non-WETH");
            require(action.tokenIn == LibSwapper.ETH, "action.tokenIn must be ETH");
            (ok, amountOut, sourceToken) = _handleUnwrap(_token, _amount, baseStorage);
        } else {
            require(action.tokenIn == _token, "_message.tokenIn mismatch in call");
        }
        if (!ok)
            return (false, _amount, _token);

        if (sourceToken != LibSwapper.ETH)
            LibSwapper.approve(sourceToken, action.spender, _amount);

        uint value = sourceToken == LibSwapper.ETH ? _amount : 0;
        uint toBalanceBefore = LibSwapper.getBalanceOf(_message.toToken);

        (bool success, bytes memory ret) = action.target.call{value: value}(action.callData);
        if (success) {
            emit ActionDone(Interchain.ActionType.CALL, action.target, true, "");

            uint toBalanceAfter = LibSwapper.getBalanceOf(_message.toToken);
            return (true, toBalanceAfter - toBalanceBefore, _message.toToken);
        } else {
            emit ActionDone(Interchain.ActionType.CALL, action.target, false, LibSwapper._getRevertMsg(ret));
            return (false, _amount, _token);
        }
    }

    /// @notice Performs a uniswap-v2 operation
    /// @param _postAction The type of action to perform such as WRAP, UNWRAP
    /// @param _amount The amount of input token
    /// @return ok Indicates that the swap operation was success or fail
    /// @return amountOut If ok = true, amountOut is the output amount of the swap
    function _handlePostAction(
        address _token,
        uint _amount,
        Interchain.CallSubActionType _postAction,
        LibSwapper.BaseSwapperStorage storage baseStorage
    ) private returns (bool ok, uint256 amountOut, address outToken) {

        if (_postAction == Interchain.CallSubActionType.WRAP) {
            require(_token == LibSwapper.ETH, "Cannot wrap non-native");
            (ok, amountOut, outToken) = _handleWrap(_token, _amount, baseStorage);
        } else if (_postAction == Interchain.CallSubActionType.UNWRAP) {
            require(_token == baseStorage.WETH, "Cannot unwrap non-WETH");
            (ok, amountOut, outToken) = _handleUnwrap(_token, _amount, baseStorage);
        } else {
            revert("Unsupported post-action");
        }
        if (!ok)
            return (false, _amount, _token);
        return (ok, amountOut, outToken);
    }

    /// @notice Performs a WETH.deposit operation
    /// @param _amount The amount of input token
    /// @return ok Indicates that the swap operation was success or fail
    /// @return amountOut If ok = true, amountOut is the output amount of the swap
    function _handleWrap(
        address _token,
        uint _amount,
        LibSwapper.BaseSwapperStorage storage baseStorage
    ) private returns (bool ok, uint256 amountOut, address outToken) {
        require(_token == LibSwapper.ETH, "Cannot wrap non-ETH tokens");

        IWETH(baseStorage.WETH).deposit{value: _amount}();
        emit SubActionDone(Interchain.CallSubActionType.WRAP, baseStorage.WETH, true, "");

        return (true, _amount, baseStorage.WETH);
    }

    /// @notice Performs a WETH.deposit operation
    /// @param _amount The amount of input token
    /// @return ok Indicates that the swap operation was success or fail
    /// @return amountOut If ok = true, amountOut is the output amount of the swap
    function _handleUnwrap(
        address _token,
        uint _amount,
        LibSwapper.BaseSwapperStorage storage baseStorage
    ) private returns (bool ok, uint256 amountOut, address outToken) {
        if (_token != baseStorage.WETH)
            revert("Non-WETH tokens unwrapped");

        IWETH(baseStorage.WETH).withdraw(_amount);
        emit SubActionDone(Interchain.CallSubActionType.UNWRAP, baseStorage.WETH, true, "");

        return (true, _amount, LibSwapper.ETH);
    }
    
    /// @notice An internal function to send a token from the current contract to another contract or wallet
    /// @dev This function also can convert WETH to ETH before sending if _withdraw flat is set to true
    /// @dev To send native token _nativeOut param should be set to true, otherwise we assume it's an ERC20 transfer
    /// @dev If there is a message from a dApp it sends the money to the contract instead of the end-user and calls its handleRangoMessage
    /// @param _token The token that is going to be sent to a wallet, ZERO address for native
    /// @param _amount The sent amount
    /// @param _receiver The receiver wallet address or contract
    function _sendTokenWithDApp(
        address _token,
        uint256 _amount,
        address _receiver,
        bytes memory _dAppMessage,
        address _dAppReceiverContract,
        IRangoMessageReceiver.ProcessStatus processStatus
    ) internal {
        bool thereIsAMessage = _dAppReceiverContract != LibSwapper.ETH;
        address immediateReceiver = thereIsAMessage ? _dAppReceiverContract : _receiver;
        BaseInterchainStorage storage messagingStorage = getBaseMessagingContractStorage();
        emit LibSwapper.SendToken(_token, _amount, immediateReceiver);

        if (_token == LibSwapper.ETH) {
            LibSwapper._sendNative(immediateReceiver, _amount);
        } else {
            SafeERC20.safeTransfer(IERC20(_token), immediateReceiver, _amount);
        }

        if (thereIsAMessage) {
            require(
                messagingStorage.whitelistMessagingContracts[_dAppReceiverContract],
                "3rd-party contract not whitelisted"
            );

            try IRangoMessageReceiver(_dAppReceiverContract)
                .handleRangoMessage(_token, _amount, processStatus, _dAppMessage)
            {
                emit CrossChainMessageCalled(_dAppReceiverContract, _token, _amount, processStatus, _dAppMessage, true, "");
            } catch Error(string memory reason) {
                emit CrossChainMessageCalled(_dAppReceiverContract, _token, _amount, processStatus, _dAppMessage, false, reason);
            } catch (bytes memory lowLevelData) {
                emit CrossChainMessageCalled(_dAppReceiverContract, _token, _amount, processStatus, _dAppMessage, false, LibSwapper._getRevertMsg(lowLevelData));
            }
        }
    }

    /// @notice A utility function to fetch storage from a predefined random slot using assembly
    /// @return s The storage object
    function getBaseMessagingContractStorage() internal pure returns (BaseInterchainStorage storage s) {
        bytes32 namespace = BASE_MESSAGING_CONTRACT_NAMESPACE;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            s.slot := namespace
        }
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IWETH.sol";
import "../interfaces/IRango.sol";

/// @title BaseSwapper
/// @author 0xiden
/// @notice library to provide swap functionality
library LibSwapper {

    /// @dev keccak256("exchange.rango.library.swapper")
    bytes32 internal constant BASE_SWAPPER_NAMESPACE = hex"43da06808a8e54e76a41d6f7b48ddfb23969b1387a8710ef6241423a5aefe64a";

    address payable constant ETH = payable(0x0000000000000000000000000000000000000000);

    struct BaseSwapperStorage {
        address payable feeContractAddress;
        address WETH;
        mapping(address => bool) whitelistContracts;
        mapping(address => mapping(bytes4 => bool)) whitelistMethods;
    }

    /// @notice Emitted if any fee transfer was required
    /// @param token The address of received token, address(0) for native
    /// @param affiliatorAddress The address of affiliate wallet
    /// @param platformFee The amount received as platform fee
    /// @param destinationExecutorFee The amount received to execute transaction on destination (only for cross chain txs)
    /// @param affiliateFee The amount received by affiliate
    /// @param dAppTag Optional identifier to make tracking easier.
    event FeeInfo(
        address token,
        address indexed affiliatorAddress,
        uint platformFee,
        uint destinationExecutorFee,
        uint affiliateFee,
        uint16 indexed dAppTag
    );

    /// @notice A call to another dex or contract done and here is the result
    /// @param target The address of dex or contract that is called
    /// @param success A boolean indicating that the call was success or not
    /// @param returnData The response of function call
    event CallResult(address target, bool success, bytes returnData);

    /// @notice A swap request is done and we also emit the output
    /// @param requestId Optional parameter to make tracking of transaction easier
    /// @param fromToken Input token address to be swapped from
    /// @param toToken Output token address to be swapped to
    /// @param amountIn Input amount of fromToken that is being swapped
    /// @param dAppTag Optional identifier to make tracking easier
    /// @param outputAmount The output amount of the swap, measured by the balance change before and after the swap
    /// @param receiver The address to receive the output of swap. Can be address(0) when swap is before a bridge action
    event RangoSwap(
        address indexed requestId,
        address fromToken,
        address toToken,
        uint amountIn,
        uint minimumAmountExpected,
        uint16 indexed dAppTag,
        uint outputAmount,
        address receiver
    );

    /// @notice Output amount of a dex calls is logged
    /// @param _token The address of output token, ZERO address for native
    /// @param amount The amount of output
    event DexOutput(address _token, uint amount);

    /// @notice The output money (ERC20/Native) is sent to a wallet
    /// @param _token The token that is sent to a wallet, ZERO address for native
    /// @param _amount The sent amount
    /// @param _receiver The receiver wallet address
    event SendToken(address _token, uint256 _amount, address _receiver);


    /// @notice Notifies that Rango's fee receiver address updated
    /// @param _oldAddress The previous fee wallet address
    /// @param _newAddress The new fee wallet address
    event FeeContractAddressUpdated(address _oldAddress, address _newAddress);

    /// @notice Notifies that WETH address is updated
    /// @param _oldAddress The previous weth address
    /// @param _newAddress The new weth address
    event WethContractAddressUpdated(address _oldAddress, address _newAddress);

    /// @notice Notifies that admin manually refunded some money
    /// @param _token The address of refunded token, 0x000..00 address for native token
    /// @param _amount The amount that is refunded
    event Refunded(address _token, uint _amount);

    /// @notice The requested call data which is computed off-chain and passed to the contract
    /// @dev swapFromToken and amount parameters are only helper params and the actual amount and
    /// token are set in callData
    /// @param spender The contract which the approval is given to if swapFromToken is not native.
    /// @param target The dex contract address that should be called
    /// @param swapFromToken Token address of to be used in the swap.
    /// @param amount The amount to be approved or native amount sent.
    /// @param callData The required data field that should be give to the dex contract to perform swap
    struct Call {
        address spender;
        address payable target;
        address swapFromToken;
        address swapToToken;
        bool needsTransferFromUser;
        uint amount;
        bytes callData;
    }

    /// @notice General swap request which is given to us in all relevant functions
    /// @param requestId The request id passed to make tracking transactions easier
    /// @param fromToken The source token that is going to be swapped (in case of simple swap or swap + bridge) or the briding token (in case of solo bridge)
    /// @param toToken The output token of swapping. This is the output of DEX step and is also input of bridging step
    /// @param amountIn The amount of input token to be swapped
    /// @param platformFee The amount of fee charged by platform
    /// @param destinationExecutorFee The amount of fee required for relayer execution on the destination
    /// @param affiliateFee The amount of fee charged by affiliator dApp
    /// @param affiliatorAddress The wallet address that the affiliator fee should be sent to
    /// @param minimumAmountExpected The minimum amount of toToken expected after executing Calls
    /// @param dAppTag An optional parameter
    struct SwapRequest {
        address requestId;
        address fromToken;
        address toToken;
        uint amountIn;
        uint platformFee;
        uint destinationExecutorFee;
        uint affiliateFee;
        address payable affiliatorAddress;
        uint minimumAmountExpected;
        uint16 dAppTag;
    }

    /// @notice initializes the base swapper and sets the init params (such as Wrapped token address)
    /// @param _weth Address of wrapped token (WETH, WBNB, etc.) on the current chain
    function setWeth(address _weth) internal {
        BaseSwapperStorage storage baseStorage = getBaseSwapperStorage();
        address oldAddress = baseStorage.WETH;
        baseStorage.WETH = _weth;
        require(_weth != address(0), "Invalid WETH!");
        emit WethContractAddressUpdated(oldAddress, _weth);
    }

    /// @notice Sets the wallet that receives Rango's fees from now on
    /// @param _address The receiver wallet address
    function updateFeeContractAddress(address payable _address) internal {
        BaseSwapperStorage storage baseSwapperStorage = getBaseSwapperStorage();

        address oldAddress = baseSwapperStorage.feeContractAddress;
        baseSwapperStorage.feeContractAddress = _address;

        emit FeeContractAddressUpdated(oldAddress, _address);
    }

    /// Whitelist ///

    /// @notice Adds a contract to the whitelisted DEXes that can be called
    /// @param contractAddress The address of the DEX
    function addWhitelist(address contractAddress) internal {
        BaseSwapperStorage storage baseStorage = getBaseSwapperStorage();
        baseStorage.whitelistContracts[contractAddress] = true;
    }

    /// @notice Adds a method of contract to the whitelisted DEXes that can be called
    /// @param contractAddress The address of the DEX
    /// @param methodIds The method of the DEX
    function addMethodWhitelists(address contractAddress, bytes4[] calldata methodIds) internal {
        BaseSwapperStorage storage baseStorage = getBaseSwapperStorage();

        baseStorage.whitelistContracts[contractAddress] = true;
        for (uint i = 0; i < methodIds.length; i++)
            baseStorage.whitelistMethods[contractAddress][methodIds[i]] = true;
    }

    /// @notice Adds a method of contract to the whitelisted DEXes that can be called
    /// @param contractAddress The address of the DEX
    /// @param methodId The method of the DEX
    function addMethodWhitelist(address contractAddress, bytes4 methodId) internal {
        BaseSwapperStorage storage baseStorage = getBaseSwapperStorage();

        baseStorage.whitelistContracts[contractAddress] = true;
        baseStorage.whitelistMethods[contractAddress][methodId] = true;
    }

    /// @notice Removes a contract from the whitelisted DEXes
    /// @param contractAddress The address of the DEX or dApp
    function removeWhitelist(address contractAddress) internal {
        BaseSwapperStorage storage baseStorage = getBaseSwapperStorage();

        require(baseStorage.whitelistContracts[contractAddress], 'Contract not found');
        delete baseStorage.whitelistContracts[contractAddress];
    }

    /// @notice Removes a method of contract from the whitelisted DEXes
    /// @param contractAddress The address of the DEX or dApp
    /// @param methodId The method of the DEX
    function removeMethodWhitelist(address contractAddress, bytes4 methodId) internal {
        BaseSwapperStorage storage baseStorage = getBaseSwapperStorage();

        require(baseStorage.whitelistMethods[contractAddress][methodId], 'Contract not found');
        delete baseStorage.whitelistMethods[contractAddress][methodId];
    }

    function onChainSwapsPreBridge(
        SwapRequest memory request,
        Call[] calldata calls,
        uint extraFee
    ) internal returns (uint out) {

        bool isNative = request.fromToken == ETH;
        uint minimumRequiredValue = (isNative ? request.platformFee + request.affiliateFee + request.amountIn + request.destinationExecutorFee : 0) + extraFee;
        require(msg.value >= minimumRequiredValue, 'Send more ETH to cover input amount + fee');

        (, out) = onChainSwapsInternal(request, calls, extraFee);
        // when there is a bridge after swap, set the receiver in swap event to address(0)
        emitSwapEvent(request, out, ETH);

        return out;
    }

    /// @notice Internal function to compute output amount of DEXes
    /// @param request The general swap request containing from/to token and fee/affiliate rewards
    /// @param calls The list of DEX calls
    /// @param extraNativeFee The amount of native tokens to keep and not return to user as excess amount.
    /// @return The response of all DEX calls and the output amount of the whole process
    function onChainSwapsInternal(
        SwapRequest memory request,
        Call[] calldata calls,
        uint256 extraNativeFee
    ) internal returns (bytes[] memory, uint) {

        uint toBalanceBefore = getBalanceOf(request.toToken);
        uint fromBalanceBefore = getBalanceOf(request.fromToken);
        uint256[] memory initialBalancesList = getInitialBalancesList(calls);

        // transfer tokens from user for SwapRequest and Calls that require transfer from user.
        transferTokensFromUserForSwapRequest(request);
        transferTokensFromUserForCalls(calls);

        bytes[] memory result = callSwapsAndFees(request, calls);

        // check if any extra tokens were taken from contract and return excess tokens if any.
        returnExcessAmounts(request, calls, initialBalancesList);

        // get balance after returning excesses.
        uint fromBalanceAfter = getBalanceOf(request.fromToken);

        // check over-expense of fromToken and return excess if any.
        if (request.fromToken != ETH) {
            require(fromBalanceAfter >= fromBalanceBefore, "Source token balance on contract must not decrease after swap");
            if (fromBalanceAfter > fromBalanceBefore)
                _sendToken(request.fromToken, fromBalanceAfter - fromBalanceBefore, msg.sender);
        }
        else {
            require(fromBalanceAfter >= fromBalanceBefore - msg.value, "Source token balance on contract must not decrease after swap");
            // When we are keeping extraNativeFee for bridgingFee, we should consider it in calculations.
            if (fromBalanceAfter > fromBalanceBefore - msg.value + extraNativeFee)
                _sendToken(request.fromToken, fromBalanceAfter + msg.value - fromBalanceBefore - extraNativeFee, msg.sender);
        }

        uint toBalanceAfter = getBalanceOf(request.toToken);

        uint secondaryBalance = toBalanceAfter - toBalanceBefore;
        require(secondaryBalance >= request.minimumAmountExpected, "Output is less than minimum expected");

        return (result, secondaryBalance);
    }

    /// @notice Private function to handle fetching money from wallet to contract, reduce fee/affiliate, perform DEX calls
    /// @param request The general swap request containing from/to token and fee/affiliate rewards
    /// @param calls The list of DEX calls
    /// @dev It checks the whitelisting of all DEX addresses + having enough msg.value as input
    /// @return The bytes of all DEX calls response
    function callSwapsAndFees(SwapRequest memory request, Call[] calldata calls) private returns (bytes[] memory) {
        bool isSourceNative = request.fromToken == ETH;
        BaseSwapperStorage storage baseSwapperStorage = getBaseSwapperStorage();

        for (uint256 i = 0; i < calls.length; i++) {
            require(baseSwapperStorage.whitelistContracts[calls[i].spender], "Contract spender not whitelisted");
            require(baseSwapperStorage.whitelistContracts[calls[i].target], "Contract target not whitelisted");
            bytes4 sig = bytes4(calls[i].callData[: 4]);
            require(baseSwapperStorage.whitelistMethods[calls[i].target][sig], "Unauthorized call data!");
        }

        // Get Platform fee
        bool hasPlatformFee = request.platformFee > 0;
        bool hasDestExecutorFee = request.destinationExecutorFee > 0;
        bool hasAffiliateFee = request.affiliateFee > 0;
        if (hasPlatformFee || hasDestExecutorFee) {
            require(baseSwapperStorage.feeContractAddress != ETH, "Fee contract address not set");
            _sendToken(request.fromToken, request.platformFee + request.destinationExecutorFee, baseSwapperStorage.feeContractAddress, isSourceNative, false);
        }

        // Get affiliate fee
        if (hasAffiliateFee) {
            require(request.affiliatorAddress != ETH, "Invalid affiliatorAddress");
            _sendToken(request.fromToken, request.affiliateFee, request.affiliatorAddress, isSourceNative, false);
        }

        // emit Fee event
        if (hasPlatformFee || hasDestExecutorFee || hasAffiliateFee) {
            emit FeeInfo(
                request.fromToken,
                request.affiliatorAddress,
                request.platformFee,
                request.destinationExecutorFee,
                request.affiliateFee,
                request.dAppTag
            );
        }

        // Execute swap Calls
        bytes[] memory returnData = new bytes[](calls.length);
        address tmpSwapFromToken;
        for (uint256 i = 0; i < calls.length; i++) {
            tmpSwapFromToken = calls[i].swapFromToken;
            bool isTokenNative = tmpSwapFromToken == ETH;
            if (isTokenNative == false)
                approve(tmpSwapFromToken, calls[i].spender, calls[i].amount);

            (bool success, bytes memory ret) = isTokenNative
            ? calls[i].target.call{value : calls[i].amount}(calls[i].callData)
            : calls[i].target.call(calls[i].callData);

            emit CallResult(calls[i].target, success, ret);
            if (!success)
                revert(_getRevertMsg(ret));
            returnData[i] = ret;
        }

        return returnData;
    }

    /// @notice Approves an ERC20 token to a contract to transfer from the current contract
    /// @param token The address of an ERC20 token
    /// @param to The contract address that should be approved
    /// @param value The amount that should be approved
    function approve(address token, address to, uint value) internal {
        SafeERC20.safeApprove(IERC20(token), to, 0);
        SafeERC20.safeIncreaseAllowance(IERC20(token), to, value);
    }

    function _sendToken(address _token, uint256 _amount, address _receiver) internal {
        (_token == ETH) ? _sendNative(_receiver, _amount) : SafeERC20.safeTransfer(IERC20(_token), _receiver, _amount);
    }

    function sumFees(IRango.RangoBridgeRequest memory request) internal pure returns (uint256) {
        return request.platformFee + request.affiliateFee + request.destinationExecutorFee;
    }

    function sumFees(SwapRequest memory request) internal pure returns (uint256) {
        return request.platformFee + request.affiliateFee + request.destinationExecutorFee;
    }

    function collectFees(IRango.RangoBridgeRequest memory request) internal {
        // Get Platform fee
        bool hasPlatformFee = request.platformFee > 0;
        bool hasDestExecutorFee = request.destinationExecutorFee > 0;
        bool hasAffiliateFee = request.affiliateFee > 0;
        bool hasAnyFee = hasPlatformFee || hasDestExecutorFee || hasAffiliateFee;
        if (!hasAnyFee) {
            return;
        }
        bool isSourceNative = request.token == ETH;
        BaseSwapperStorage storage baseSwapperStorage = getBaseSwapperStorage();

        if (hasPlatformFee || hasDestExecutorFee) {
            require(baseSwapperStorage.feeContractAddress != ETH, "Fee contract address not set");
            _sendToken(request.token, request.platformFee + request.destinationExecutorFee, baseSwapperStorage.feeContractAddress, isSourceNative, false);
        }

        // Get affiliate fee
        if (hasAffiliateFee) {
            require(request.affiliatorAddress != ETH, "Invalid affiliatorAddress");
            _sendToken(request.token, request.affiliateFee, request.affiliatorAddress, isSourceNative, false);
        }

        // emit Fee event
        emit FeeInfo(
            request.token,
            request.affiliatorAddress,
            request.platformFee,
            request.destinationExecutorFee,
            request.affiliateFee,
            request.dAppTag
        );
    }

    function collectFeesFromSender(IRango.RangoBridgeRequest memory request) internal {
        // Get Platform fee
        bool hasPlatformFee = request.platformFee > 0;
        bool hasDestExecutorFee = request.destinationExecutorFee > 0;
        bool hasAffiliateFee = request.affiliateFee > 0;
        bool hasAnyFee = hasPlatformFee || hasDestExecutorFee || hasAffiliateFee;
        if (!hasAnyFee) {
            return;
        }
        bool isSourceNative = request.token == ETH;
        BaseSwapperStorage storage baseSwapperStorage = getBaseSwapperStorage();

        if (hasPlatformFee || hasDestExecutorFee) {
            require(baseSwapperStorage.feeContractAddress != ETH, "Fee contract address not set");
            if (isSourceNative)
                _sendToken(request.token, request.platformFee + request.destinationExecutorFee, baseSwapperStorage.feeContractAddress, isSourceNative, false);
            else
                SafeERC20.safeTransferFrom(
                    IERC20(request.token),
                    msg.sender,
                    baseSwapperStorage.feeContractAddress,
                    request.platformFee + request.destinationExecutorFee
                );
        }

        // Get affiliate fee
        if (hasAffiliateFee) {
            require(request.affiliatorAddress != ETH, "Invalid affiliatorAddress");
            if (isSourceNative)
                _sendToken(request.token, request.affiliateFee, request.affiliatorAddress, isSourceNative, false);
            else
                SafeERC20.safeTransferFrom(
                    IERC20(request.token),
                    msg.sender,
                    request.affiliatorAddress,
                    request.affiliateFee
                );
        }

        // emit Fee event
        emit FeeInfo(
            request.token,
            request.affiliatorAddress,
            request.platformFee,
            request.destinationExecutorFee,
            request.affiliateFee,
            request.dAppTag
        );
    }

    /// @notice An internal function to send a token from the current contract to another contract or wallet
    /// @dev This function also can convert WETH to ETH before sending if _withdraw flat is set to true
    /// @dev To send native token _nativeOut param should be set to true, otherwise we assume it's an ERC20 transfer
    /// @param _token The token that is going to be sent to a wallet, ZERO address for native
    /// @param _amount The sent amount
    /// @param _receiver The receiver wallet address or contract
    /// @param _nativeOut means the output is native token
    /// @param _withdraw If true, indicates that we should swap WETH to ETH before sending the money and _nativeOut must also be true
    function _sendToken(
        address _token,
        uint256 _amount,
        address _receiver,
        bool _nativeOut,
        bool _withdraw
    ) internal {
        BaseSwapperStorage storage baseStorage = getBaseSwapperStorage();
        emit SendToken(_token, _amount, _receiver);

        if (_nativeOut) {
            if (_withdraw) {
                require(_token == baseStorage.WETH, "token mismatch");
                IWETH(baseStorage.WETH).withdraw(_amount);
            }
            _sendNative(_receiver, _amount);
        } else {
            SafeERC20.safeTransfer(IERC20(_token), _receiver, _amount);
        }
    }

    /// @notice An internal function to send native token to a contract or wallet
    /// @param _receiver The address that will receive the native token
    /// @param _amount The amount of the native token that should be sent
    function _sendNative(address _receiver, uint _amount) internal {
        (bool sent,) = _receiver.call{value : _amount}("");
        require(sent, "failed to send native");
    }


    /// @notice A utility function to fetch storage from a predefined random slot using assembly
    /// @return s The storage object
    function getBaseSwapperStorage() internal pure returns (BaseSwapperStorage storage s) {
        bytes32 namespace = BASE_SWAPPER_NAMESPACE;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            s.slot := namespace
        }
    }

    /// @notice To extract revert message from a DEX/contract call to represent to the end-user in the blockchain
    /// @param _returnData The resulting bytes of a failed call to a DEX or contract
    /// @return A string that describes what was the error
    function _getRevertMsg(bytes memory _returnData) internal pure returns (string memory) {
        // If the _res length is less than 68, then the transaction failed silently (without a revert message)
        if (_returnData.length < 68) return 'Transaction reverted silently';

        assembly {
        // Slice the sighash.
            _returnData := add(_returnData, 0x04)
        }
        return abi.decode(_returnData, (string));
        // All that remains is the revert string
    }

    function getBalanceOf(address token) internal view returns (uint) {
        return token == ETH ? address(this).balance : IERC20(token).balanceOf(address(this));
    }

    /// @notice Fetches the balances of swapToTokens.
    /// @dev this fetches the balances for swapToToken of swap Calls. If native eth is received, the balance has already increased so we subtract msg.value.
    function getInitialBalancesList(Call[] calldata calls) internal view returns (uint256[] memory) {
        uint callsLength = calls.length;
        uint256[] memory balancesList = new uint256[](callsLength);
        address token;
        for (uint256 i = 0; i < callsLength; i++) {
            token = calls[i].swapToToken;
            balancesList[i] = getBalanceOf(token);
            if (token == ETH)
                balancesList[i] -= msg.value;
        }
        return balancesList;
    }

    /// This function transfers tokens from users based on the SwapRequest, it transfers amountIn + fees.
    function transferTokensFromUserForSwapRequest(SwapRequest memory request) private {
        uint transferAmount = request.amountIn + sumFees(request);
        if (request.fromToken != ETH)
            SafeERC20.safeTransferFrom(IERC20(request.fromToken), msg.sender, address(this), transferAmount);
        else
            require(msg.value >= transferAmount);
    }

    /// This function iterates on calls and if needsTransferFromUser, transfers tokens from user
    function transferTokensFromUserForCalls(Call[] calldata calls) private {
        uint callsLength = calls.length;
        Call calldata call;
        address token;
        for (uint256 i = 0; i < callsLength; i++) {
            call = calls[i];
            token = call.swapFromToken;
            if (call.needsTransferFromUser && token != ETH)
                SafeERC20.safeTransferFrom(IERC20(call.swapFromToken), msg.sender, address(this), call.amount);
        }
    }

    /// @dev returns any excess token left by the contract.
    /// We iterate over `swapToToken`s because each swapToToken is either the request.toToken or is the output of
    /// another `Call` in the list of swaps which itself either has transferred tokens from user,
    /// or is a middle token that is the output of another `Call`.
    function returnExcessAmounts(
        SwapRequest memory request,
        Call[] calldata calls,
        uint256[] memory initialBalancesList) internal {
        uint excessAmountToToken;
        address tmpSwapToToken;
        uint currentBalanceTo;
        for (uint256 i = 0; i < calls.length; i++) {
            tmpSwapToToken = calls[i].swapToToken;
            currentBalanceTo = getBalanceOf(tmpSwapToToken);
            excessAmountToToken = currentBalanceTo - initialBalancesList[i];
            if (excessAmountToToken > 0 && tmpSwapToToken != request.toToken) {
                _sendToken(tmpSwapToToken, excessAmountToToken, msg.sender);
            }
        }
    }

    function emitSwapEvent(SwapRequest memory request, uint output, address receiver) internal {
        emit RangoSwap(
            request.requestId,
            request.fromToken,
            request.toToken,
            request.amountIn,
            request.minimumAmountExpected,
            request.dAppTag,
            output,
            receiver
        );
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

/// @title Reentrancy Guard
/// @author 
/// @notice Abstract contract to provide protection against reentrancy
abstract contract ReentrancyGuard {
    /// Storage ///

    /// @dev keccak256("exchange.rango.reentrancyguard");
    bytes32 private constant NAMESPACE = hex"4fe94118b1030ac5f570795d403ee5116fd91b8f0b5d11f2487377c2b0ab2559";

    /// Types ///

    struct ReentrancyStorage {
        uint256 status;
    }

    /// Errors ///

    error ReentrancyError();

    /// Constants ///

    uint256 private constant _NOT_ENTERED = 0;
    uint256 private constant _ENTERED = 1;

    /// Modifiers ///

    modifier nonReentrant() {
        ReentrancyStorage storage s = reentrancyStorage();
        if (s.status == _ENTERED) revert ReentrancyError();
        s.status = _ENTERED;
        _;
        s.status = _NOT_ENTERED;
    }

    /// Private Methods ///

    /// @dev fetch local storage
    function reentrancyStorage() private pure returns (ReentrancyStorage storage data) {
        bytes32 position = NAMESPACE;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            data.slot := position
        }
    }
}