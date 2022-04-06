/**
 *Submitted for verification at BscScan.com on 2022-04-05
*/

// File: mowsseAuction/ISendValueProxy.sol


pragma solidity ^0.8.2;

interface ISendValueProxy {
    function sendValue(address payable _to) external payable;
}

// File: mowsseAuction/SendValueProxy.sol


pragma solidity ^0.8.2;

/**
 * @dev Contract that attempts to send value to an address.
 */
contract SendValueProxy is ISendValueProxy {

    /**
     * @dev Send some wei to the address.
     * @param _to address to send some value to.
     */
    function sendValue(address payable _to) external override payable {
        // Note that `<address>.transfer` limits gas sent to receiver. It may
        // not support complex contract operations in the future.
        _to.transfer(msg.value);
    }
}

// File: @openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

// File: @openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
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

// File: mowsseAuction/IMarketplaceSettings.sol


pragma solidity ^0.8.2;

/**
 * @title IMarketplaceSettings Settings governing a marketplace.
 */
interface IMarketplaceSettings {
    /////////////////////////////////////////////////////////////////////////
    // Marketplace Min and Max Values
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Get the max value to be used with the marketplace.
     * @return uint256 wei value.
     */
    function getMarketplaceMaxValue() external view returns (uint256);

    /**
     * @dev Get the max value to be used with the marketplace.
     * @return uint256 wei value.
     */
    function getMarketplaceMinValue() external view returns (uint256);

    /////////////////////////////////////////////////////////////////////////
    // Marketplace Fee
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Get the marketplace fee percentage.
     * @return uint8 wei fee.
     */
    function getMarketplaceFeePercentage() external view returns (uint8);

    /////////////////////////////////////////////////////////////////////////
    // BuyerReward Fee
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Get the buyerReward fee percentage.
     * @return uint8 blok fee.
     */
    function getBuyerRewardFeePercentage() external view returns (uint8);

    /**
     * @dev Utility function for calculating the marketplace fee for given amount of wei.
     * @param _amount uint256 wei amount.
     * @return uint256 wei fee.
     */
    function calculateMarketplaceFee(uint256 _amount)
        external
        view
        returns (uint256);

    /////////////////////////////////////////////////////////////////////////
    // Primary Sale Fee
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Get the primary sale fee percentage for a specific ERC721 contract.
     * @param _contractAddress address ERC721Contract address.
     * @return uint8 wei primary sale fee.
     */
    function getERC721ContractPrimarySaleFeePercentage(address _contractAddress)
        external
        view
        returns (uint8);

    /**
     * @dev Utility function for calculating the primary sale fee for given amount of wei
     * @param _contractAddress address ERC721Contract address.
     * @param _amount uint256 wei amount.
     * @return uint256 wei fee.
     */
    function calculatePrimarySaleFee(address _contractAddress, uint256 _amount)
        external
        view
        returns (uint256);
        

    /**
     * @dev Check whether the ERC721 token has sold at least once.
     * @param _contractAddress address ERC721Contract address.
     * @param _tokenId uint256 token ID.
     * @return bool of whether the token has sold.
     */
    function hasERC721TokenSold(address _contractAddress, uint256 _tokenId)
        external
        view
        returns (bool);

    /**
     * @dev Mark a token as sold.
     * Requirements:
     *
     * - `_contractAddress` cannot be the zero address.
     * @param _contractAddress address ERC721Contract address.
     * @param _tokenId uint256 token ID.
     * @param _hasSold bool of whether the token should be marked sold or not.
     */
    function markERC721Token(
        address _contractAddress,
        uint256 _tokenId,
        bool _hasSold
    ) external;

    /////////////////////////////////////////////////////////////////////////
    // checkModeratorRole
    /////////////////////////////////////////////////////////////////////////
    /**
    *
     * @param _account address of the account to check moderator role.
     */
    function checkModeratorRole(address _account) external view returns(bool);
    

    
}
// File: mowsseAuction/IERC721TokenCreator.sol


pragma solidity ^0.8.2;

/**
 * @title IERC721 Non-Fungible Token Creator basic interface
 */
interface IERC721TokenCreator {
    /**
     * @dev Gets the creator of the token
     * @param _contractAddress address of the ERC721 contract
     * @param _tokenId uint256 ID of the token
     * @return address of the creator
     */
    function tokenCreator(address _contractAddress, uint256 _tokenId)
        external
        view
        returns (address payable);
}
// File: mowsseAuction/IERC721CreatorRoyalty.sol


pragma solidity ^0.8.2;


/**
 * @title IERC721CreatorRoyalty Token level royalty interface.
 */
interface IERC721CreatorRoyalty is IERC721TokenCreator {
    /**
     * @dev Get the royalty fee percentage for a specific ERC721 contract.
     * @param _contractAddress address ERC721Contract address.
     * @param _tokenId uint256 token ID.
     * @return uint8 wei royalty fee.
     */
    function getERC721TokenRoyaltyPercentage(
        address _contractAddress,
        uint256 _tokenId
    ) external view returns (uint8);

    /**
     * @dev Utililty function to calculate the royalty fee for a token.
     * @param _contractAddress address ERC721Contract address.
     * @param _tokenId uint256 token ID.
     * @param _amount uint256 wei amount.
     * @return uint256 wei fee.
     */
    function calculateRoyaltyFee(
        address _contractAddress,
        uint256 _tokenId,
        uint256 _amount
    ) external view returns (uint256);
}
// File: @openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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

// File: @openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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

// File: @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;


/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// File: @openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol


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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// File: @openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;





/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}

// File: @openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;



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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// File: mowsseAuction/MaybeSendValue.sol


pragma solidity ^0.8.2;


//import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";




/**
 * @dev Contract with a ISendValueProxy that will catch reverts when attempting to transfer funds.
 */
abstract contract MaybeSendValue is Initializable, OwnableUpgradeable {
     using SafeERC20Upgradeable for IERC20Upgradeable;

    SendValueProxy proxy;
    address public vault;
    address public blokToken;

    event ERC20Payment(address indexed to, uint256 indexed itemId, address tokenAddress, uint256 tokenAmount);

    function initializeMaybeSendValue(address _vault, address _blok)  public {
        proxy = new SendValueProxy();
        vault = _vault;
        blokToken = _blok;
    }

    /////////////////////////////////////////////////////////////////////////
    // setVaultAddress
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Admin function to set the Vault.
     * Rules:
     * - only owner
     * - _address != address(0)
     * @param _address address of the IMarketplaceSettings.
     */
    function setVaultAddress(address _address) public onlyOwner{
        require(
            _address != address(0),
            'setVaultAddress::Cannot have null address for vault'
        );

        vault = _address;
    }

     /////////////////////////////////////////////////////////////////////////
    // setBlokAddress
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Admin function to set the Vault.
     * Rules:
     * - only owner
     * - _address != address(0)
     * @param _address address of the IMarketplaceSettings.
     */
    function setBlokAddress(address _address) public onlyOwner{
        require(
            _address != address(0),
            'setBlokAddress::Cannot have null address for blokToken'
        );

        blokToken = _address;
    }


    /**
     * @dev Maybe send some wei to the address via a proxy. Returns true on success and false if transfer fails.
     * @param _to address to send some value to.
     * @param _value uint256 amount to send.
     */
    function maybeSendValue(address payable _to, uint256 _value)
        internal
        returns (bool)
    {
        // Call sendValue on the proxy contract and forward the mesg.value.
        /* solium-disable-next-line */
        (bool success, ) = address(proxy).call{value: _value}(
            abi.encodeWithSignature("sendValue(address)", _to)
        );
        // (bool success, bytes memory _) = address(proxy).call.value(_value)(
        //     abi.encodeWithSignature("sendValue(address)", _to)
        // );
        return success;
    }

    /**
     * @dev Maybe send some blok to the address. Returns true on success and false if transfer fails.
     * @param _to address to send some blok to.
     * @param _value uint256 amount to send.
     */
    function sendToken( address _to, uint256 _value , uint256 _itemId)            
        internal
        returns (bool)
    {                        

        //@TODO must have a check so that only a specific role is allowed to call this function                                           

    //    (bool success, ) = address(blok).call(
    //         abi.encodeWithSignature("transferFrom(address,address,uint256)",vault,_to,_value)
    //     );
        IERC20Upgradeable(blokToken).safeTransferFrom(vault, _to, _value);
            emit ERC20Payment(_to, _itemId, blokToken, _value);

    //     return success;
    }
}

// File: mowsseAuction/SendValueOrEscrow.sol


pragma solidity ^0.8.2;

// import "@openzeppelin/contracts/security/PullPayment.sol";





/**
 * @dev Contract to make payments. If a direct transfer fails, it will store the payment in escrow until the address decides to pull the payment.
 */
contract SendValueOrEscrow is Initializable, MaybeSendValue {
    // using ERC20Upgradeable for IERC20Upgradeable;

    /////////////////////////////////////////////////////////////////////////
    // Events
    /////////////////////////////////////////////////////////////////////////
    event SendValue(address indexed _payee, uint256 amount);

    
    
    function initializeSendValueOrEscrow(address _vault, address _blokTokenAddress) public {
        MaybeSendValue.initializeMaybeSendValue(_vault, _blokTokenAddress);
          
    }


     
    /////////////////////////////////////////////////////////////////////////
    // sendTokenOrEscrow
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Send some blok to an address.
     * @param _to address to send some blok to.
     * @param _value uint256 amount to send.
     */
    function sendTokenOrEscrow(address _to, uint256 _value, uint256 _itemId) internal {   
        // attempt to make the transfer
         MaybeSendValue.sendToken( _to, _value, _itemId);
        // if it fails, transfer it into escrow for them to redeem at their will.
        // if (!successfulTransfer) {
        //}

        //emit SendValue(_to, _value);
    }
}

// File: @openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol


// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: mowsseAuction/Payments.sol


pragma solidity ^0.8.2;





/**
 * @title Payments contract for SuperRare Marketplaces.
 */
contract Payments is Initializable, SendValueOrEscrow {
    using SafeMathUpgradeable for uint256;
    using SafeMathUpgradeable for uint8;
    
   function initializePayments(address _vault, address _blokTokenAddress) public {
        SendValueOrEscrow.initializeSendValueOrEscrow(_vault, _blokTokenAddress);
    }

    /////////////////////////////////////////////////////////////////////////
    // refund
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Internal function to refund an address. Typically for canceled bids or offers.
     * Requirements:
     *
     *  - _payee cannot be the zero address
     *
     * @param _marketplacePercentage uint8 percentage of the fee for the marketplace.
     * @param _amount uint256 value to be split.
     * @param _payee address seller of the token.
     */
    function refund(
        uint8 _marketplacePercentage,
        address payable _payee,
        uint256 _amount,
        uint256 _itemId
    ) internal {
        require(
            _payee != address(0),
            "refund::no payees can be the zero address"
        );                                                         // *** verify this function   ***

        if (_amount > 0) {
            SendValueOrEscrow.sendTokenOrEscrow(
                _payee,
                _amount.add(
                    calcPercentagePayment(_amount, _marketplacePercentage)
                ),
                _itemId
            );
        }
    }

    /////////////////////////////////////////////////////////////////////////
    // payout
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Internal function to pay the seller, creator, and maintainer.
     * Requirements:
     *
     *  - _marketplacePercentage + _royaltyPercentage + _buyerRewardPercentage <= 100
     *  - no payees can be the zero address
     *
     * @param _amount uint256 value to be split.
     * @param _isPrimarySale bool of whether this is a primary sale.
     * @param _marketplacePercentage uint8 percentage of the fee for the marketplace.
     * @param _royaltyPercentage uint8 percentage of the fee for the royalty.
     * @param _buyerRewardPercentage uint8 percentage of rewards for buyer in blok.
     * @param _payee address seller of the token.
     * @param _marketplacePayee address seller of the token.
     * @param _royaltyPayee address seller of the token.
     * @param _buyerAddress address of the buyer.
     */
    function payout(
        uint256 _amount,
        bool _isPrimarySale,
        uint8 _marketplacePercentage,
        uint8 _royaltyPercentage,
        uint8 _buyerRewardPercentage,
        address  _payee,
        address  _marketplacePayee,
        address  _royaltyPayee,
        address  _buyerAddress ,
        uint256 itemId
    ) internal {
        // require(
        //     _marketplacePercentage <= 100,
        //     "payout::marketplace percentage cannot be above 100"
        // );

        //@TODO test it for edge cases
        require(
            _marketplacePercentage.add(_royaltyPercentage.add(_buyerRewardPercentage)) <= 100,
            "payout::percentages cannot go beyond 100"
        );                                                   
        require(
            _payee != address(0) &&
                _buyerAddress != address(0) &&
                _marketplacePayee != address(0) &&
                _royaltyPayee != address(0),
            "payout::no payees can be the zero address"
        );

        // Note:: Solidity is kind of terrible in that there is a limit to local
        //        variables that can be put into the stack. The real pain is that
        //        one can put structs, arrays, or mappings into memory but not basic
        //        data types. Hence our payments array that stores these values.
        uint256[4] memory payments;

        // uint256 marketplacePayment
        payments[0] = calcPercentagePayment(_amount, _marketplacePercentage);

        // uint256 royaltyPayment
        payments[1] = calcRoyaltyPayment(
            _isPrimarySale,
            _amount,
            _royaltyPercentage
        );                              // **** Need to verify primary sale ****

        // uint256 buyerRewardPayment
        payments[2] = calcBuyerReward(
            _amount,
            _buyerRewardPercentage
        );

        // uint256 payeePayment
        payments[3] = _amount.sub(payments[0]).sub(payments[1]);

         //@TODO To check sufficient balance available at vault address and allowance available at contract address 
        // marketplacePayment


        if (payments[0] > 0) {
            SendValueOrEscrow.sendTokenOrEscrow(_marketplacePayee, payments[0] ,itemId);    // admin
            // blokTransfer(_marketplacePayee, payments[0]);
        }

        // royaltyPayment
        if (payments[1] > 0) {
            SendValueOrEscrow.sendTokenOrEscrow(_royaltyPayee, payments[1],itemId);        // artist/creator
        }
        // buyerRewardPayment
        if (payments[2] > 0) {
            SendValueOrEscrow.sendTokenOrEscrow(_buyerAddress, payments[2],itemId);        // buyer
        }
        // payeePayment
        if (payments[3] > 0) {
            SendValueOrEscrow.sendTokenOrEscrow(_payee, payments[3],itemId);       // artist
        }
    }

    /////////////////////////////////////////////////////////////////////////
    // calcRoyaltyPayment
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Private function to calculate Royalty amount.
     *      If primary sale: 0
     *      If no royalty percentage: 0
     *      otherwise: royalty in wei
     * @param _isPrimarySale bool of whether this is a primary sale
     * @param _amount uint256 value to be split
     * @param _percentage uint8 royalty percentage
     * @return uint256 wei value owed for royalty
     */
    function calcRoyaltyPayment(
        bool _isPrimarySale,
        uint256 _amount,
        uint8 _percentage
    ) private pure returns (uint256) {
        if (_isPrimarySale) {
            return 0;
        }
        return calcPercentagePayment(_amount, _percentage);
    }

    /////////////////////////////////////////////////////////////////////////
    // calcBuyerReward
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Private function to calculate BuyerReward amount.
     * @param _amount uint256 value to be split
     * @param _percentage uint8 royalty percentage
     * @return uint256 blok value owed for Buyer reward
     */
    function calcBuyerReward(
        uint256 _amount,
        uint8 _percentage
    ) private pure returns (uint256) {

        return calcPercentagePayment(_amount, _percentage);

    }

    /////////////////////////////////////////////////////////////////////////
    // calcPrimarySalePayment
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Private function to calculate PrimarySale amount.
     *      If not primary sale: 0
     *      otherwise: primary sale in wei
     * @param _isPrimarySale bool of whether this is a primary sale
     * @param _amount uint256 value to be split
     * @param _percentage uint8 royalty percentage
     * @return uint256 wei value owed for primary sale
     */
    function calcPrimarySalePayment(
        bool _isPrimarySale,
        uint256 _amount,
        uint8 _percentage
    ) private pure returns (uint256) {
        if (_isPrimarySale) {
            return calcPercentagePayment(_amount, _percentage);
        }
        return 0;
    }

    /////////////////////////////////////////////////////////////////////////
    // calcPercentagePayment
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Internal function to calculate percentage value.
     * @param _amount uint256 wei value
     * @param _percentage uint8  percentage
     * @return uint256 wei value based on percentage.
     */
    function calcPercentagePayment(uint256 _amount, uint8 _percentage)
        internal
        pure
        returns (uint256)
    {
        return _amount.mul(_percentage).div(100);
    }
}

// File: @openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// File: mowsseAuction/MowseAuctionHouse.sol


pragma solidity ^0.8.2;








contract MowseAuctionHouse is Initializable, Payments {
    using SafeMathUpgradeable for uint256;
    /////////////////////////////////////////////////////////////////////////
    // Constants
    /////////////////////////////////////////////////////////////////////////

    // Types of Auctions
    bytes32 public constant COLDIE_AUCTION = 'COLDIE_AUCTION';
    bytes32 public constant SCHEDULED_AUCTION = 'SCHEDULED_AUCTION';
    bytes32 public constant NO_AUCTION = bytes32(0);

    uint public endTime ;

    /////////////////////////////////////////////////////////////////////////
    // Structs
    /////////////////////////////////////////////////////////////////////////
    // A reserve auction.
    struct Auction {
        address payable auctionCreator;
        uint256 creationTimeInSeconds;
        uint256 lengthOfAuctionInSeconds;
        uint256 startingTimeInSeconds;
        uint256 endTimeInEpochSeconds;
        uint256 reservePrice;
        uint256 minimumBid;
        bytes32 auctionType;
    }

    // The active bid for a given token, contains the bidder, the marketplace fee at the time of the bid, and the amount of wei placed on the token
    struct ActiveBid {
        address payable bidder;
        uint8 marketplaceFee;
        uint256 amount;
    }

    /////////////////////////////////////////////////////////////////////////
    // State Variables
    /////////////////////////////////////////////////////////////////////////

    // Marketplace Settings Interface
    IMarketplaceSettings public iMarketSettings;

    // Creator Royalty Interface
    IERC721CreatorRoyalty public iERC721CreatorRoyalty;

    // Mapping from ERC721 contract to mapping of tokenId to Auctions.
    mapping(address => mapping(uint256 => Auction)) private auctions;

    // Mapping of ERC721 contract to mapping of token ID to the bid amount.
    mapping(address => mapping(uint256 => ActiveBid [])) private currentBids;

     // Mapping of ERC721 contract to mapping of token ID to the current bid amount.
    mapping(address => mapping(uint256 => ActiveBid)) private currentMaxBids;

    // Max Bid on an nft
      ActiveBid public maxBid ;

    // Number of blocks to begin refreshing auction lengths
    uint256 public auctionLengthExtension;

    // Max Length that an auction can be
    uint256 public maxLength;

    // A minimum increase in bid amount when out bidding someone.
    uint8 public minimumBidIncreasePercentage; // 10 = 10% @TODO remove bid increase percentage
    /////////////////////////////////////////////////////////////////////////
    // Events
    /////////////////////////////////////////////////////////////////////////
    event NewColdieAuction(
        address indexed _contractAddress,
        uint256 indexed _tokenId,
        address indexed _auctionCreator,
        uint256 _reservePrice,
        uint256 _lengthOfAuctionInSeconds
    );

    event CancelAuction(
        address indexed _contractAddress,
        uint256 indexed _tokenId,
        address indexed _auctionCreator
    );

    event NewScheduledAuction(
        address indexed _contractAddress,
        uint256 indexed _tokenId,
        address indexed _auctionCreator,
        uint256 _startingTimeInSeconds,
        uint256 _minimumBid,
        uint256 _lengthOfAuctionInSeconds
    );

    event AuctionBid(
        address indexed _contractAddress,
        address indexed _bidder,
        uint256 indexed _tokenId,
        uint256 _amount,
        bool _startedAuction,
        uint256 _newAuctionLength,
        address _previousBidder
    );

    event AuctionSettled(
        address indexed _contractAddress,
        address indexed _bidder,
        address _seller,
        uint256 indexed _tokenId,
        uint256 _amount
    );

    /////////////////////////////////////////////////////////////////////////
    // initialize
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Initializes the contract setting the market settings and creator royalty interfaces.
     * @param _iMarketSettings address to set as iMarketSettings.
     * @param _iERC721CreatorRoyalty address to set as iERC721CreatorRoyalty.
     */
    function initialize(
        address _iMarketSettings,
        address _iERC721CreatorRoyalty
    ) public initializer {
        //needs modification in time according to polygon
        maxLength = 7 days; // ~ 7 days == 7 days * 24 hours * 3600s / 2.3s per block.
        auctionLengthExtension = 15 minutes; // ~ 15 min == 15 min * 60s / 2.3s per block

        require(
            _iMarketSettings != address(0),
            'constructor::Cannot have null address for _iMarketSettings'
        );

        require(
            _iERC721CreatorRoyalty != address(0),
            'constructor::Cannot have null address for _iERC721CreatorRoyalty'
        );
        __Ownable_init();
        // Set iMarketSettings
        iMarketSettings = IMarketplaceSettings(_iMarketSettings);

        // Set iERC721CreatorRoyalty
        iERC721CreatorRoyalty = IERC721CreatorRoyalty(_iERC721CreatorRoyalty);

        //minimumBidIncreasePercentage = 10; @TODO maybe need to set min Bid percentage
    }

    /////////////////////////////////////////////////////////////////////////
    // setIMarketplaceSettings
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Admin function to set the marketplace settings.
     * Rules:
     * - only owner
     * - _address != address(0)
     * @param _address address of the IMarketplaceSettings.
     */
    function setMarketplaceSettings(address _address) public onlyOwner {
        require(
            _address != address(0),
            'setMarketplaceSettings::Cannot have null address for _iMarketSettings'
        );

        iMarketSettings = IMarketplaceSettings(_address);
    }

    /////////////////////////////////////////////////////////////////////////
    // setIERC721CreatorRoyalty
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Admin function to set the IERC721CreatorRoyalty.
     * Rules:
     * - only owner
     * - _address != address(0)
     * @param _address address of the IERC721CreatorRoyalty.
     */
    function setIERC721CreatorRoyalty(address _address) public onlyOwner {
        require(
            _address != address(0),
            'setIERC721CreatorRoyalty::Cannot have null address for _iERC721CreatorRoyalty'
        );

        iERC721CreatorRoyalty = IERC721CreatorRoyalty(_address);
    }

    /////////////////////////////////////////////////////////////////////////
    // setMaxLength
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Admin function to set the maxLength of an auction.
     * Rules:
     * - only owner
     * - _maxLangth > 0
     * @param _maxLength uint256 max length of an auction.
     */
    function setMaxLength(uint256 _maxLength) public onlyOwner {
        require(
            _maxLength > 0,
            'setMaxLength::_maxLength must be greater than 0'
        );

        maxLength = _maxLength;
    }

    /////////////////////////////////////////////////////////////////////////
    // setMinimumBidIncreasePercentage
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Admin function to set the minimum bid increase percentage.
     * Rules:
     * - only owner
     * @param _percentage uint8 to set as the new percentage.
     */
    function setMinimumBidIncreasePercentage(uint8 _percentage)
        public
        onlyOwner
    {
        minimumBidIncreasePercentage = _percentage;
    }

    /////////////////////////////////////////////////////////////////////////
    // setAuctionLengthExtension
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Admin function to set the auctionLengthExtension of an auction.
     * Rules:
     * - only owner
     * - _auctionLengthExtension > 0
     * @param _auctionLengthExtension uint256 max length of an auction.
     */
    function setAuctionLengthExtension(uint256 _auctionLengthExtension)
        public
        onlyOwner
    {
        require(
            _auctionLengthExtension > 0,
            'setAuctionLengthExtension::_auctionLengthExtension must be greater than 0'
        );

        auctionLengthExtension = _auctionLengthExtension;
    }

    /////////////////////////////////////////////////////////////////////////
    // createColdieAuction
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev create a reserve auction token contract address, token id, price
     * Rules:
     * - Cannot create an auction if contract isn't approved by owner
     * - lengthOfAuctionInSeconds (in blocks) > 0
     * - lengthOfAuctionInSeconds (in blocks) <= maxLength
     * - Reserve price must be >= 0
     * - Must be owner of the token
     * - Cannot have a current auction going
     * @param _contractAddress address of ERC721 contract.
     * @param _tokenId uint256 id of the token.
     * @param _reservePrice uint256 Wei value of the reserve price.
     * @param _lengthOfAuctionInSeconds uint256 length of auction in blocks.
     */
    function createColdieAuction(
        address _contractAddress,
        uint256 _tokenId,
        uint256 _reservePrice,
        uint256 _lengthOfAuctionInSeconds
    ) public {
        // Rules
        _requireOwnerApproval(_contractAddress, _tokenId);
        _requireOwnerAsSender(_contractAddress, _tokenId);
        require(
            _lengthOfAuctionInSeconds <= maxLength,
            'createColdieAuction::Cannot have auction longer than maxLength'
        );
        require(
            auctions[_contractAddress][_tokenId].auctionType == NO_AUCTION ||
                (msg.sender !=
                    auctions[_contractAddress][_tokenId].auctionCreator),
            'createColdieAuction::Cannot have a current auction'
        );
        require(
            _lengthOfAuctionInSeconds > 0,
            'createColdieAuction::_lengthOfAuctionInSeconds must be > 0'
        );
        require(
            _reservePrice >= 0,
            'createColdieAuction::_reservePrice must be >= 0'
        );
        require(
            _reservePrice <= iMarketSettings.getMarketplaceMaxValue(),
            'createColdieAuction::Cannot set reserve price higher than max value'
        );

        // Create the auction
        auctions[_contractAddress][_tokenId] = Auction(
            payable(msg.sender),
            block.timestamp,
            _lengthOfAuctionInSeconds,
            0,
            0,
            _reservePrice,
            0,
            COLDIE_AUCTION
        );

        emit NewColdieAuction(
            _contractAddress,
            _tokenId,
            msg.sender,
            _reservePrice,
            _lengthOfAuctionInSeconds
        );
    }

    /////////////////////////////////////////////////////////////////////////
    // cancelAuction
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev cancel an auction
     * Rules:
     * - Must have an auction for the token
     * - Auction cannot have started
     * - Must be the creator of the auction
     * - Must return token to owner if escrowed
     * @param _contractAddress address of ERC721 contract.
     * @param _tokenId uint256 id of the token.
     */
    function cancelAuction(address _contractAddress, uint256 _tokenId)
        external
    {
        require(
            auctions[_contractAddress][_tokenId].auctionType != NO_AUCTION,
            'cancelAuction::Must have a current auction'
        );
        require(
            auctions[_contractAddress][_tokenId].startingTimeInSeconds == 0 ||
                auctions[_contractAddress][_tokenId].startingTimeInSeconds >
                block.timestamp,
            'cancelAuction::auction cannot be started'
        );
        require(
            auctions[_contractAddress][_tokenId].auctionCreator == msg.sender,
            'cancelAuction::must be the creator of the auction'
        );

        Auction memory auction = auctions[_contractAddress][_tokenId];

        auctions[_contractAddress][_tokenId] = Auction(
            payable(address(0)),
            0,
            0,
            0,
            0,
            0,
            0,
            NO_AUCTION
        );

        // Return the token if this contract escrowed it
        IERC721Upgradeable erc721 = IERC721Upgradeable(_contractAddress);
        if (erc721.ownerOf(_tokenId) == address(this)) {
            erc721.transferFrom(address(this), msg.sender, _tokenId);
        }

        emit CancelAuction(_contractAddress, _tokenId, auction.auctionCreator);
    }

    /////////////////////////////////////////////////////////////////////////
    // createScheduledAuction
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev create a scheduled auction token contract address, token id
     * Rules:
     * - lengthOfAuctionInSeconds (in blocks) > 0
     * - startingTimeInSeconds > currentBlock
     * - Cannot create an auction if contract isn't approved by owner
     * - Minimum bid must be >= 0
     * - Must be owner of the token
     * - Cannot have a current auction going for this token
     * @param _contractAddress address of ERC721 contract.
     * @param _tokenId uint256 id of the token.
     * @param _minimumBid uint256 Wei value of the reserve price.
     * @param _lengthOfAuctionInSeconds uint256 length of auction in blocks.
     * @param _startingTimeInSeconds uint256 block number to start the auction on.
     */
    function createScheduledAuction(
        address _contractAddress,
        uint256 _tokenId,
        uint256 _minimumBid,
        uint256 _lengthOfAuctionInSeconds,
        uint256 _startingTimeInSeconds
    ) external {
        require(
            _lengthOfAuctionInSeconds > 0,
            'createScheduledAuction::_lengthOfAuctionInSeconds must be greater than 0'
        );
        require(
            _lengthOfAuctionInSeconds <= maxLength,
            'createScheduledAuction::Cannot have auction longer than maxLength'
        );
        require(
            _startingTimeInSeconds >= block.timestamp,
            'createScheduledAuction:: startingTimeInSeconds must be greater than block.timestamp'
        );
        require(
            _minimumBid <= iMarketSettings.getMarketplaceMaxValue(),
            'createScheduledAuction::Cannot set minimum bid higher than max value'
        );
        _requireOwnerApproval(_contractAddress, _tokenId);
        _requireOwnerAsSender(_contractAddress, _tokenId);
        require(
            auctions[_contractAddress][_tokenId].auctionType == NO_AUCTION ||
                (msg.sender !=
                    auctions[_contractAddress][_tokenId].auctionCreator),
            'createScheduledAuction::Cannot have a current auction'
        );

        endTime = _startingTimeInSeconds.add(
            _lengthOfAuctionInSeconds
        );

        // Create the scheduled auction.
        auctions[_contractAddress][_tokenId] = Auction(
            payable(msg.sender),
            block.timestamp,
            _lengthOfAuctionInSeconds,
            _startingTimeInSeconds,
            endTime,
            0,
            _minimumBid,
            SCHEDULED_AUCTION
        );

        // Transfer the token to this contract to act as escrow.
        IERC721Upgradeable erc721 = IERC721Upgradeable(_contractAddress);
        erc721.transferFrom(msg.sender, address(this), _tokenId);

        emit NewScheduledAuction(
            _contractAddress,
            _tokenId,
            msg.sender,
            _startingTimeInSeconds,
            _minimumBid,
            _lengthOfAuctionInSeconds
        );
    }

    /////////////////////////////////////////////////////////////////////////
    // bid
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Bid on artwork with an auction.
     * Rules:
     * - if auction creator is still owner, owner must have contract approved
     * - There must be a running auction or a reserve price auction for the token
     * - bid > 0
     * - if startingTimeInSeconds - block.timestamp < auctionLengthExtension
     * -    then auctionLength = Starting block - (currentBlock + extension)
     * - Auction creator != bidder
     * - bid >= minimum bid
     * - bid >= reserve price
     * - block.timestamp < startingTimeInSeconds + lengthOfAuctionInSeconds
     * - bid > current bid
     * - if previous bid then returned
     * @param _contractAddress address of ERC721 contract.
     * @param _tokenId uint256 id of the token.
     * @param _amount uint256 Wei value of the bid.
     */
    function bid(
        address _contractAddress,
        uint256 _tokenId,
        uint256 _amount
    ) external  { // @TODO remove payable  
        Auction memory auction = auctions[_contractAddress][_tokenId];

        // Must have existing auction.
        require(
            auction.auctionType != NO_AUCTION,
            'bid::Must have existing auction'
        );

        // Must have existing auction.
        require(
            auction.auctionCreator != msg.sender,
            'bid::Cannot bid on your own auction'
        );

        // Must have pending coldie auction or running auction.
        require(
            auction.startingTimeInSeconds <= block.timestamp,
            'bid::Must have a running auction or pending coldie auction'
        );

        // Check that bid is greater than 0.
        require(_amount > 0, 'bid::Cannot bid 0 Wei.');

        // Check that bid is less than max value.
        require(
            _amount <= iMarketSettings.getMarketplaceMaxValue(),
            'bid::Cannot bid higher than max value'
        );

        // Check that bid is larger than min value.
        require(
            _amount >= iMarketSettings.getMarketplaceMinValue(),
            'bid::Cannot bid lower than min value'
        );

        // Check that bid is larger than minimum bid value or the reserve price.
        require(
            (_amount >= auction.reservePrice && auction.minimumBid == 0) ||
                (_amount >= auction.minimumBid && auction.reservePrice == 0),
            'bid::Cannot bid lower than reserve or minimum bid'
        );

        // Auction cannot have ended.
        require(
            auction.startingTimeInSeconds == 0 ||
                block.timestamp <
                auction.startingTimeInSeconds.add(
                    auction.lengthOfAuctionInSeconds
                ),
            'bid::Cannot have ended'
        );

        // Check that enough ether was sent.
        uint256 requiredCost = _amount.add(
            iMarketSettings.calculateMarketplaceFee(_amount)
        );
       // require(requiredCost == msg.value, 'bid::Must bid the correct amount.'); //@TODo remmove

        // If owner of token is auction creator make sure they have contract approved
        IERC721Upgradeable erc721 = IERC721Upgradeable(_contractAddress);
        address owner = erc721.ownerOf(_tokenId);

        // Check that token is owned by creator or by this contract
        require(
            auction.auctionCreator == owner || owner == address(this),
            'bid::Cannot bid on auction if auction creator is no longer owner.'
        );

        if (auction.auctionCreator == owner) {
            _requireOwnerApproval(_contractAddress, _tokenId);
        }

        ActiveBid memory currentBid = currentMaxBids[_contractAddress][_tokenId];

        // Must bid higher than current bid.
        require(
             _amount > currentBid.amount 
            //  && _amount >=
            //     currentBid.amount.add(
            //         currentBid.amount.mul(minimumBidIncreasePercentage).div(100)
            //     )
            ,
            'bid::must bid higher than previous bid '
        );

        // Return previous bid
        // We do this here because it clears the bid for the refund. This makes it safe from reentrence.
        //@TODO refund bid what can we do regarding this

        // if (currentBid.amount != 0) {
        //     _refundBid(_contractAddress, _tokenId);
        // }
        //Set the currentMax bid  
          maxBid = ActiveBid(
            payable(msg.sender),
            iMarketSettings.getMarketplaceFeePercentage(),
            _amount
        );

        // Set the new bid
        currentBids[_contractAddress][_tokenId].push(maxBid);
        currentMaxBids[_contractAddress][_tokenId] = maxBid;
        // If is a pending coldie auction, start the auction
        // if (auction.startingTimeInSeconds == 0) {
        //     auctions[_contractAddress][_tokenId].startingTimeInSeconds = block
        //         .timestamp;
        //     erc721.transferFrom(
        //         auction.auctionCreator,
        //         address(this),
        //         _tokenId
        //     );
        //     emit AuctionBid(
        //         _contractAddress,
        //         msg.sender,
        //         _tokenId,
        //         _amount,
        //         true,
        //         0,
        //         currentBid.bidder
        //     );
        // }
        // If the time left for the auction is less than the extension limit bump the length of the auction.
         if (
            (
                auction.startingTimeInSeconds.add(
                    auction.lengthOfAuctionInSeconds
                )
            ).sub(block.timestamp) < auctionLengthExtension
        ) {
            auctions[_contractAddress][_tokenId].lengthOfAuctionInSeconds = (
                block.timestamp.add(auctionLengthExtension)
            ).sub(auction.startingTimeInSeconds);
            emit AuctionBid(
                _contractAddress,
                msg.sender,
                _tokenId,
                _amount,
                false,
                auctions[_contractAddress][_tokenId].lengthOfAuctionInSeconds,
                currentBid.bidder
            );
        }
        // Otherwise, it's a normal bid
        else {
            emit AuctionBid(
                _contractAddress,
                msg.sender,
                _tokenId,
                _amount,
                false,
                0,
                currentBid.bidder
            );
        }
    }

    /////////////////////////////////////////////////////////////////////////
    // settleAuction
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Settles the auction, transferring the auctioned token to the bidder and the bid to auction creator.
     * Rules:
     * - There must be an unsettled auction for the token
     * - current bidder becomes new owner
     * - auction creator gets paid
     * - there is no longer an auction for the token
     * @param _contractAddress address of ERC721 contract.
     * @param _tokenId uint256 id of the token.
     */
    function settleAuction(address _contractAddress, uint256 _tokenId)
        external
    {
        require(
            iMarketSettings.checkModeratorRole(msg.sender),
            'Caller is not Moderator'
        );

        Auction memory auction = auctions[_contractAddress][_tokenId];

        require(
            auction.auctionType != NO_AUCTION &&
                auction.startingTimeInSeconds != 0,
            'settleAuction::Must have a current auction that has started'
        );
        require(
            block.timestamp >=
                auction.startingTimeInSeconds.add(
                    auction.lengthOfAuctionInSeconds
                ),
            'settleAuction::Can only settle ended auctions.'
        );

        ActiveBid memory currentBid = currentMaxBids[_contractAddress][_tokenId];

       delete currentBids[_contractAddress][_tokenId];

        auctions[_contractAddress][_tokenId] = Auction(
            payable(address(0)),
            0,
            0,
            0,
            0,
            0,
            0,
            NO_AUCTION
        );
        IERC721Upgradeable erc721 = IERC721Upgradeable(_contractAddress);

        // If there were no bids then end the auction and return the token to its original owner.
        if (currentBid.bidder == address(0)) {
            // Transfer the token to back to original owner.
            erc721.transferFrom(
                address(this),
                auction.auctionCreator,
                _tokenId
            );
            emit AuctionSettled(
                _contractAddress,
                address(0),
                auction.auctionCreator,
                _tokenId,
                0 
            );
            return;
        }

        // Transfer the token to the winner of the auction.
        erc721.transferFrom(address(this), currentBid.bidder, _tokenId);

        address payable owner = _makePayable(owner());
        Payments.payout(
            currentBid.amount,
            !iMarketSettings.hasERC721TokenSold(_contractAddress, _tokenId),
            currentBid.marketplaceFee,
            iERC721CreatorRoyalty.getERC721TokenRoyaltyPercentage(
                _contractAddress,
                _tokenId
            ),
            iMarketSettings.getERC721ContractPrimarySaleFeePercentage(
                _contractAddress
            ),
            auction.auctionCreator,
            owner,
            iERC721CreatorRoyalty.tokenCreator(_contractAddress, _tokenId),
            owner,
            0 //@TODO to be replace with itemId
        );
        iMarketSettings.markERC721Token(_contractAddress, _tokenId, true);
        emit AuctionSettled(
            _contractAddress,
            currentBid.bidder,
            auction.auctionCreator,
            _tokenId,
            currentBid.amount
        );
    }

    /////////////////////////////////////////////////////////////////////////
    // getAuctionDetails
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Get current auction details for a token
     * Rules:
     * - Return empty when there's no auction
     * @param _contractAddress address of ERC721 contract.
     * @param _tokenId uint256 id of the token.
     */
    function getAuctionDetails(address _contractAddress, uint256 _tokenId)
        external
        view
        returns (
            bytes32,
            uint256,
            address,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        Auction memory auction = auctions[_contractAddress][_tokenId];

        return (
            auction.auctionType,
            auction.creationTimeInSeconds,
            auction.auctionCreator,
            auction.lengthOfAuctionInSeconds,
            auction.startingTimeInSeconds,
            auction.minimumBid,
            auction.reservePrice
        );
    }

    /////////////////////////////////////////////////////////////////////////
    // getCurrentBid
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Get the current bid
     * Rules:
     * - Return empty when there's no bid
     * @param _contractAddress address of ERC721 contract.
     * @param _tokenId uint256 id of the token.
     */
    function getCurrentBid(address _contractAddress, uint256 _tokenId)
        external
        view
        returns (address, uint256)
    {
        return (
            currentMaxBids[_contractAddress][_tokenId].bidder,
            currentMaxBids[_contractAddress][_tokenId].amount
        );
    }

    /////////////////////////////////////////////////////////////////////////
    // _requireOwnerApproval
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Require that the owner have the MowseAuctionHouse approved.
     * @param _contractAddress address of ERC721 contract.
     * @param _tokenId uint256 id of the token.
     */
    function _requireOwnerApproval(address _contractAddress, uint256 _tokenId)
        internal
        view
    {
        IERC721Upgradeable erc721 = IERC721Upgradeable(_contractAddress);
        address owner = erc721.ownerOf(_tokenId);
        require(
            erc721.isApprovedForAll(owner, address(this)),
            'owner must have approved contract'
        );
    }

    /////////////////////////////////////////////////////////////////////////
    // _requireOwnerAsSender
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Require that the owner be the sender.
     * @param _contractAddress address of ERC721 contract.
     * @param _tokenId uint256 id of the token.
     */
    function _requireOwnerAsSender(address _contractAddress, uint256 _tokenId)
        internal
        view
    {
        IERC721Upgradeable erc721 = IERC721Upgradeable(_contractAddress);
        address owner = erc721.ownerOf(_tokenId);
        require(owner == msg.sender, 'owner must be message sender');
    }

    /////////////////////////////////////////////////////////////////////////
    // _refundBid
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Internal function to return an existing bid on a token to the
     *      bidder and reset bid.
     * @param _contractAddress address of ERC721 contract.
     * @param _tokenId uin256 id of the token.
     */
    function _refundBid(address _contractAddress, uint256 _tokenId) internal {
        ActiveBid memory currentBid = currentMaxBids[_contractAddress][_tokenId];
        if (currentBid.bidder == address(0)) {
            return;
        }

        currentMaxBids[_contractAddress][_tokenId] = ActiveBid(
            payable(address(0)),
            0,
            0
        );

        // refund the bidder
        Payments.refund(
            currentBid.marketplaceFee,
            currentBid.bidder,
            currentBid.amount,
            0 //@TODO to be replace with itemId
        );
    }

    /////////////////////////////////////////////////////////////////////////
    // _makePayable
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Internal function to set a bid.
     * @param _address non-payable address
     * @return payable address
     */
    function _makePayable(address _address)
        internal
        pure
        returns (address payable)
    {
        return payable(address(uint160(_address)));
    }

    function getBlockNumber() public view returns (uint256) {
        return block.number;
    }
}