/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

// SPDX-License-Identifier: GPL-3.0
// File: @openzeppelin/contracts/utils/math/SafeMath.sol

// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

// File: @openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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

// File: @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol

// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
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
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(
                _initialized < version,
                "Initializable: contract is already initialized"
            );
            _initialized = version;
            return true;
        }
    }
}

// File: contracts/market.sol

pragma solidity ^0.8.4;

//import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/utils/introspection/IERC165.sol";
//import "https://raw.githubusercontent.com/OpenZeppelin/contracts-upgradeable/master/contracts/token/ERC20/IERC20.sol";

interface IERC721 is IERC165Upgradeable {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function balanceOf(address owner) external view returns (uint256 balance);

    function Fee() external view returns (uint256 royalty);

    function royaltyInfo(uint256 tokenId, uint256 value)
        external
        view
        returns (address _receiver, uint256 _royaltyAmount);

    function collectionOwner() external view returns (address owner);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

contract EmpireMarketplaceV7 is Initializable {
    using SafeMath for uint256;
    struct AuctionItem {
        uint256 id;
        address tokenAddress;
        uint256 tokenId;
        uint256 askingPrice;
        bool isSold;
        bool bidItem;
        uint256 bidPrice;
        address bidderAddress;
        address ERC20;
    }

    uint256 public serviceFee; //2.5% serviceFee
    address public feeAddress; // admin address where serviceFee will be sent
    address public marketplaceOwner;
    address public empireToken;
    AuctionItem[] public itemsForSale;

    //to check if item is open to market
    mapping(address => mapping(uint256 => bool)) activeItems;
    mapping(address => bool) validERC;
    mapping(address => mapping(uint256 => uint256)) auctionItemId;
    mapping(address => mapping(address => mapping(uint256 => uint256))) pendingReturns;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event ItemAdded(
        uint256 id,
        uint256 tokenId,
        address tokenAddress,
        uint256 askingPrice,
        bool bidItem
    );
    event ItemSold(uint256 id, address buyer, uint256 askingPrice);
    event BidPlaced(
        uint256 tokenID,
        address bidder,
        uint256 bidPrice,
        address CollectionAdd
    );
    address public feeAggregatorAddress;
    uint256 public AggregatorFee;

    function initialize() external initializer {
        marketplaceOwner = msg.sender;
        //empireToken = _empireToken;
        //validERC[_empireToken] = true;
        serviceFee = 400;
        AggregatorFee = 100;
        feeAggregatorAddress = address(
            0x2C9C756A7CFd79FEBD2fa9b4C82c10a5dB9D8996
        );
        feeAddress = address(0x943cD6e3EBCfAF1B76c6336bd775245d4E0D7239);
    }

    modifier onlyOwner() {
        require(marketplaceOwner == msg.sender);
        _;
    }
    modifier OnlyItemOwner(address tokenAddress, uint256 tokenId) {
        IERC721 tokenContract = IERC721(tokenAddress);
        require(tokenContract.ownerOf(tokenId) == msg.sender);
        _;
    }
    modifier OnlyItemOwnerAuc(uint256 aucItemId) {
        IERC721 tokenContract = IERC721(
            itemsForSale[aucItemId - 1].tokenAddress
        );
        require(
            tokenContract.ownerOf(itemsForSale[aucItemId - 1].tokenId) ==
                msg.sender
        );
        _;
    }
    modifier HasTransferApproval(address tokenAddress, uint256 tokenId) {
        IERC721 tokenContract = IERC721(tokenAddress);
        require(tokenContract.getApproved(tokenId) == address(this));
        _;
    }
    modifier ItemExists(uint256 id) {
        require(itemsForSale[id - 1].id == id, "Could not find Item");
        _;
    }

    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(marketplaceOwner, newOwner);
        marketplaceOwner = newOwner;
    }

    function changeFeeAddress(address newFeeAddress) external onlyOwner {
        require(
            newFeeAddress != address(0),
            "newFeeAddress address cannot be 0"
        );
        feeAddress = newFeeAddress;
    }

    function changeFeeAggregatorAddress(address newFeeAggregatorAddress)
        external
        onlyOwner
    {
        require(
            newFeeAggregatorAddress != address(0),
            "feeAggregatorAddress address cannot be 0"
        );
        feeAggregatorAddress = newFeeAggregatorAddress;
    }

    function changeServiceFee(uint256 newFee) external onlyOwner {
        require(newFee < 3000, "Service Should be less than 30%");
        serviceFee = newFee;
    }

    function changeAggregatorFee(uint256 newFee) external onlyOwner {
        require(newFee < 3000, "Aggregator Should be less than 30%");
        require(
            serviceFee > newFee,
            "Aggregator Fee must be less than serviceFee"
        );
        AggregatorFee = newFee;
    }

    function addItemToMarket(
        uint256 tokenId,
        address tokenAddress,
        uint256 askingPrice,
        bool bidItem,
        address tokenERC20
    )
        external
        OnlyItemOwner(tokenAddress, tokenId)
        HasTransferApproval(tokenAddress, tokenId)
        returns (uint256)
    {
        require(
            activeItems[tokenAddress][tokenId] == false,
            "Item is already up for sale"
        );

        if (tokenERC20 == address(0)) {
            return _addItemSimple(tokenId, tokenAddress, askingPrice, bidItem);
        } else {
            require(validERC[tokenERC20], "ERC20 Token is not in valid list");
            return
                _addItemERC(
                    tokenId,
                    tokenAddress,
                    askingPrice,
                    bidItem,
                    tokenERC20
                );
        }
    }

    function _addItemSimple(
        uint256 tokenId,
        address tokenAddress,
        uint256 askingPrice,
        bool bidItem
    ) internal returns (uint256) {
        if (auctionItemId[tokenAddress][tokenId] == 0) {
            //item is being added for the first time in marketplace
            uint256 newItemId = itemsForSale.length + 1;
            itemsForSale.push(
                AuctionItem(
                    newItemId,
                    tokenAddress,
                    tokenId,
                    askingPrice,
                    false,
                    bidItem,
                    0,
                    address(0),
                    address(0)
                )
            );
            activeItems[tokenAddress][tokenId] = true;
            auctionItemId[tokenAddress][tokenId] = newItemId;

            assert(itemsForSale[newItemId - 1].id == newItemId);
            emit ItemAdded(
                newItemId,
                tokenId,
                tokenAddress,
                askingPrice,
                bidItem
            );
            return newItemId;
        } else {
            itemsForSale[auctionItemId[tokenAddress][tokenId] - 1]
                .isSold = false;
            itemsForSale[auctionItemId[tokenAddress][tokenId] - 1]
                .bidItem = bidItem;
            itemsForSale[auctionItemId[tokenAddress][tokenId] - 1]
                .askingPrice = askingPrice;
            activeItems[tokenAddress][tokenId] = true;

            assert(
                itemsForSale[auctionItemId[tokenAddress][tokenId] - 1].id ==
                    auctionItemId[tokenAddress][tokenId]
            );
            emit ItemAdded(
                auctionItemId[tokenAddress][tokenId],
                tokenId,
                tokenAddress,
                askingPrice,
                bidItem
            );
            return auctionItemId[tokenAddress][tokenId];
        }
    }

    function _addItemERC(
        uint256 tokenId,
        address tokenAddress,
        uint256 askingPrice,
        bool bidItem,
        address tokenERC20
    ) internal returns (uint256) {
        if (auctionItemId[tokenAddress][tokenId] == 0) {
            //item is being added for the first time in marketplace
            uint256 newItemId = itemsForSale.length + 1;
            itemsForSale.push(
                AuctionItem(
                    newItemId,
                    tokenAddress,
                    tokenId,
                    askingPrice,
                    false,
                    bidItem,
                    0,
                    address(0),
                    tokenERC20
                )
            );
            activeItems[tokenAddress][tokenId] = true;
            auctionItemId[tokenAddress][tokenId] = newItemId;

            assert(itemsForSale[newItemId - 1].id == newItemId);
            emit ItemAdded(
                newItemId,
                tokenId,
                tokenAddress,
                askingPrice,
                bidItem
            );
            return newItemId;
        } else {
            itemsForSale[auctionItemId[tokenAddress][tokenId] - 1]
                .isSold = false;
            itemsForSale[auctionItemId[tokenAddress][tokenId] - 1]
                .bidItem = bidItem;
            itemsForSale[auctionItemId[tokenAddress][tokenId] - 1]
                .askingPrice = askingPrice;
            itemsForSale[auctionItemId[tokenAddress][tokenId] - 1]
                .ERC20 = tokenERC20;
            activeItems[tokenAddress][tokenId] = true;

            assert(
                itemsForSale[auctionItemId[tokenAddress][tokenId] - 1].id ==
                    auctionItemId[tokenAddress][tokenId]
            );
            emit ItemAdded(
                auctionItemId[tokenAddress][tokenId],
                tokenId,
                tokenAddress,
                askingPrice,
                bidItem
            );
            return auctionItemId[tokenAddress][tokenId];
        }
    }

    function removeItem(uint256 id) public {
        address collectionAddress = itemsForSale[id - 1].tokenAddress;
        require(
            activeItems[collectionAddress][itemsForSale[id - 1].tokenId],
            "Already not listed in market"
        );
        require(
            IERC721(collectionAddress).ownerOf(itemsForSale[id - 1].tokenId) ==
                msg.sender,
            "Only Item Can Remove From Market"
        );
        activeItems[collectionAddress][itemsForSale[id - 1].tokenId] = false;
        if (
            itemsForSale[id - 1].isSold == false &&
            itemsForSale[id - 1].bidItem == true
        ) {
            pendingReturns[itemsForSale[id - 1].bidderAddress][
                itemsForSale[id - 1].ERC20
            ][itemsForSale[id - 1].id] = itemsForSale[id - 1].bidPrice;
            itemsForSale[id - 1].bidItem = false;
            itemsForSale[id - 1].bidderAddress = address(0);
            itemsForSale[id - 1].bidPrice = 0;
        }
        itemsForSale[id - 1].askingPrice = 0;
        itemsForSale[id - 1].ERC20 = address(0);
    }

    function BuyItem(uint256 id)
        external
        payable
        ItemExists(id)
        HasTransferApproval(
            itemsForSale[id - 1].tokenAddress,
            itemsForSale[id - 1].tokenId
        )
    {
        require(
            activeItems[itemsForSale[id - 1].tokenAddress][
                itemsForSale[id - 1].tokenId
            ],
            "Item not listed in market"
        );
        require(itemsForSale[id - 1].isSold == false, "Item already sold");
        require(
            itemsForSale[id - 1].bidItem == false,
            "Item not for instant buy"
        );
        IERC721 Collection = IERC721(itemsForSale[id - 1].tokenAddress);
        address itemOwner = Collection.ownerOf(itemsForSale[id - 1].tokenId);
        require(msg.sender != itemOwner, "Seller cannot buy item");

        if (itemsForSale[id - 1].ERC20 == address(0)) {
            require(
                msg.value >= itemsForSale[id - 1].askingPrice,
                "Not enough funds set"
            );
            _buyitemSimple(id);
        } else {
            _buyitemERC(id);
        }
    }

    function printOwner(address _collectionAddress)
        public
        view
        returns (address)
    {
        return IERC721(_collectionAddress).collectionOwner();
    }

    function _royaltyData(
        IERC721 _collection,
        uint256 _tokenid,
        uint256 amount
    ) public view returns (address recepient, uint256 value) {
        try _collection.royaltyInfo(_tokenid, amount) returns (
            address _rec,
            uint256 _val
        ) {
            if (_rec == address(0)) {
                return (_rec, 0);
            }
            return (_rec, _val);
        } catch {
            return (address(0), 0);
        }
    }

    function _buyitemSimple(uint256 id) internal {
        IERC721 Collection = IERC721(itemsForSale[id - 1].tokenAddress);
        address itemOwner = Collection.ownerOf(itemsForSale[id - 1].tokenId);

        uint256 sFee = _calculateServiceFee(msg.value);
        uint256 aFee = _calculateAggregatorFee(msg.value);

        (address royaltyAddress, uint256 rFee) = _royaltyData(
            Collection,
            itemsForSale[id - 1].tokenId,
            msg.value
        );

        (bool success, ) = itemOwner.call{
            value: msg.value.sub(sFee).sub(aFee).sub(rFee)
        }("");
        //(bool success, ) = itemOwner.call{value: msg.value}("");
        require(success, "Failed to send Ether");

        (bool success1, ) = feeAddress.call{value: sFee}("");
        require(success1, "Failed to send Ether (Service FEE)");

        if (aFee > 0) {
            (bool success3, ) = feeAggregatorAddress.call{value: aFee}("");
            require(success3, "Failed to send Ether (Aggregator FEE)");
        }

        if (rFee > 0) {
            (bool success2, ) = royaltyAddress.call{value: rFee}("");
            require(success2, "Failed to send Ether");
        }
        itemsForSale[id - 1].isSold = true;
        activeItems[itemsForSale[id - 1].tokenAddress][
            itemsForSale[id - 1].tokenId
        ] = false;
        IERC721(itemsForSale[id - 1].tokenAddress).safeTransferFrom(
            Collection.ownerOf(itemsForSale[id - 1].tokenId),
            msg.sender,
            itemsForSale[id - 1].tokenId
        );
        //itemsForSale[id - 1].seller.transfer(msg.value);

        //itemsForSale[id - 1].seller = payable(msg.sender);
        emit ItemSold(id, msg.sender, itemsForSale[id - 1].askingPrice);
    }

    function _buyitemERC(uint256 id) internal {
        AuctionItem memory _bi = itemsForSale[id - 1];
        IERC20Upgradeable tokenERC = IERC20Upgradeable(_bi.ERC20);
        IERC721 Collection = IERC721(_bi.tokenAddress);

        address itemOwner = Collection.ownerOf(_bi.tokenId);
        uint256 val = _bi.askingPrice;
        require(
            tokenERC.allowance(msg.sender, address(this)) >= val,
            "Not enough token funds"
        );
        uint256 sFee = _calculateServiceFee(val);
        uint256 aFee = _calculateAggregatorFee(val);
        //uint256 rFee = _calculateRoyaltyFee(val, Collection.Fee());
        (address royaltyAddress, uint256 rFee) = _royaltyData(
            Collection,
            _bi.tokenId,
            val
        );
        if (_bi.ERC20 == empireToken) {
            tokenERC.transferFrom(
                msg.sender,
                itemOwner,
                _bi.askingPrice.sub(rFee)
            );
            if (rFee > 0) {
                tokenERC.transferFrom(msg.sender, royaltyAddress, rFee);
            }
        } else {
            tokenERC.transferFrom(
                msg.sender,
                itemOwner,
                val.sub(sFee).sub(aFee).sub(rFee)
            );
            tokenERC.transferFrom(msg.sender, feeAddress, sFee);
            if (aFee > 0) {
                tokenERC.transferFrom(msg.sender, feeAggregatorAddress, aFee);
            }
            if (rFee > 0) {
                tokenERC.transferFrom(msg.sender, royaltyAddress, rFee);
            }
        }

        itemsForSale[id - 1].isSold = true;
        itemsForSale[id - 1].ERC20 = address(0);
        activeItems[itemsForSale[id - 1].tokenAddress][
            itemsForSale[id - 1].tokenId
        ] = false;
        IERC721(itemsForSale[id - 1].tokenAddress).safeTransferFrom(
            Collection.ownerOf(itemsForSale[id - 1].tokenId),
            msg.sender,
            itemsForSale[id - 1].tokenId
        );
        //itemsForSale[id - 1].seller.transfer(msg.value);

        //itemsForSale[id - 1].seller = payable(msg.sender);
        emit ItemSold(id, msg.sender, itemsForSale[id - 1].askingPrice);
    }

    function _calculateServiceFee(uint256 _amount)
        public
        view
        returns (uint256)
    {
        return _amount.mul(serviceFee - AggregatorFee).div(10**4);
    }

    function _calculateAggregatorFee(uint256 _amount)
        public
        view
        returns (uint256)
    {
        return _amount.mul(AggregatorFee).div(10**4);
    }

    function _calculateRoyaltyFee(uint256 _amount, uint256 _royalty)
        public
        pure
        returns (uint256)
    {
        return _amount.mul(_royalty).div(10**4);
    }

    function addERC20tokens(address erc20) external onlyOwner {
        validERC[erc20] = true;
    }

    function removeERC20tokens(address erc20) external onlyOwner {
        validERC[erc20] = false;
    }

    // put a bid on an item
    // modifiers: ItemExists, IsForSale, IsForBid, HasTransferApproval
    // args: auctionItemId
    // check if a bid already exists, if yes: check if this bid value is higher then prev

    function PlaceABid(uint256 aucItemId, uint256 amount)
        external
        payable
        ItemExists(aucItemId)
        HasTransferApproval(
            itemsForSale[aucItemId - 1].tokenAddress,
            itemsForSale[aucItemId - 1].tokenId
        )
    {
        require(
            activeItems[itemsForSale[aucItemId - 1].tokenAddress][
                itemsForSale[aucItemId - 1].tokenId
            ],
            "Item not listed in market"
        );
        require(
            itemsForSale[aucItemId - 1].isSold == false,
            "Item already sold"
        );
        require(
            itemsForSale[aucItemId - 1].bidItem == true,
            "Item not for bidding"
        );

        if (itemsForSale[aucItemId - 1].ERC20 == address(0)) {
            require(
                msg.value >= itemsForSale[aucItemId - 1].askingPrice,
                "Not enough funds set"
            );
            _placeBidSimple(aucItemId);
        } else {
            _placeBidERC(aucItemId, amount);
        }
    }

    function _placeBidSimple(uint256 id) internal {
        uint256 totalPrice = 0;
        if (
            pendingReturns[msg.sender][address(0)][itemsForSale[id - 1].id] == 0
        ) {
            totalPrice = msg.value;
        } else {
            totalPrice =
                msg.value +
                pendingReturns[msg.sender][address(0)][itemsForSale[id - 1].id];
        }
        require(
            totalPrice > itemsForSale[id - 1].askingPrice,
            "There is already a higher asking price"
        );
        require(
            totalPrice > itemsForSale[id - 1].bidPrice,
            "There is already a higher price"
        );

        pendingReturns[msg.sender][address(0)][itemsForSale[id - 1].id] = 0;
        if (itemsForSale[id - 1].bidPrice != 0) {
            pendingReturns[itemsForSale[id - 1].bidderAddress][address(0)][
                itemsForSale[id - 1].id
            ] = itemsForSale[id - 1].bidPrice;
        }
        itemsForSale[id - 1].bidPrice = totalPrice;
        itemsForSale[id - 1].bidderAddress = msg.sender;

        emit BidPlaced(
            itemsForSale[id - 1].tokenId,
            msg.sender,
            totalPrice,
            itemsForSale[id - 1].tokenAddress
        );
    }

    function _placeBidERC(uint256 id, uint256 amount) internal {
        uint256 totalPrice = 0;
        IERC20Upgradeable tokenERC = IERC20Upgradeable(
            itemsForSale[id - 1].ERC20
        );
        require(
            tokenERC.allowance(msg.sender, address(this)) >= amount,
            "Not enough token funds"
        );

        if (
            pendingReturns[msg.sender][itemsForSale[id - 1].ERC20][
                itemsForSale[id - 1].id
            ] == 0
        ) {
            totalPrice = amount;
        } else {
            totalPrice =
                amount +
                pendingReturns[msg.sender][itemsForSale[id - 1].ERC20][
                    itemsForSale[id - 1].id
                ];
        }
        require(
            totalPrice > itemsForSale[id - 1].askingPrice,
            "There is already a higher asking price"
        );
        require(
            totalPrice > itemsForSale[id - 1].bidPrice,
            "There is already a higher price"
        );
        tokenERC.transferFrom(msg.sender, address(this), amount);
        pendingReturns[msg.sender][itemsForSale[id - 1].ERC20][
            itemsForSale[id - 1].id
        ] = 0;
        if (itemsForSale[id - 1].bidPrice != 0) {
            pendingReturns[itemsForSale[id - 1].bidderAddress][
                itemsForSale[id - 1].ERC20
            ][itemsForSale[id - 1].id] = itemsForSale[id - 1].bidPrice;
        }
        itemsForSale[id - 1].bidPrice = totalPrice;
        itemsForSale[id - 1].bidderAddress = msg.sender;
    }

    function withdrawPrevBid(uint256 aucItemId, address _erc20)
        external
        returns (bool)
    {
        uint256 amount = pendingReturns[msg.sender][_erc20][aucItemId];
        require(amount > 0, "No Amount To Withdraw");
        if (amount > 0) {
            pendingReturns[msg.sender][_erc20][aucItemId] = 0;
            if (_erc20 == address(0)) {
                if (!payable(msg.sender).send(amount)) {
                    // No need to call throw here, just reset the amount owing
                    pendingReturns[msg.sender][_erc20][aucItemId] = amount;
                    return false;
                }
            } else {
                IERC20Upgradeable(_erc20).transfer(msg.sender, amount);
            }
        }
        return true;
    }

    function EndAuction(uint256 aucItemId)
        external
        payable
        ItemExists(aucItemId)
        OnlyItemOwnerAuc(aucItemId)
        HasTransferApproval(
            itemsForSale[aucItemId - 1].tokenAddress,
            itemsForSale[aucItemId - 1].tokenId
        )
    {
        require(
            activeItems[itemsForSale[aucItemId - 1].tokenAddress][
                itemsForSale[aucItemId - 1].tokenId
            ],
            "Item not listed in market"
        );
        //require(itemsForSale[aucItemId - 1].bidPrice > itemsForSale[aucItemId - 1].askingPrice, "No Bids Exist!");
        require(
            itemsForSale[aucItemId - 1].isSold == false,
            "Item already sold"
        );
        require(
            itemsForSale[aucItemId - 1].bidItem == true,
            "Item not for bidding"
        );
        //just EndAuction
        if (itemsForSale[aucItemId - 1].bidPrice == 0) {
            _endAuctionOnly(aucItemId);
        }
        //End And Distribute bidPrice
        else if (itemsForSale[aucItemId - 1].ERC20 == address(0)) {
            //require(msg.value >= itemsForSale[aucItemId - 1].askingPrice, "Not enough funds set");
            _endAuctionSimple(aucItemId);
        } else {
            _endAuctionERC(aucItemId);
        }
    }

    function _endAuctionSimple(uint256 id) internal {
        AuctionItem memory _bi = itemsForSale[id - 1];
        IERC721 Collection = IERC721(_bi.tokenAddress);
        address itemOwner = Collection.ownerOf(_bi.tokenId);
        uint256 sFee = _calculateServiceFee(_bi.bidPrice);
        uint256 aFee = _calculateAggregatorFee(_bi.bidPrice);
        //uint256 rFee = _calculateRoyaltyFee(itemsForSale[id - 1].bidPrice, Collection.Fee());
        (address royaltyAddress, uint256 rFee) = _royaltyData(
            Collection,
            _bi.tokenId,
            _bi.bidPrice
        );
        (bool success, ) = itemOwner.call{
            value: _bi.bidPrice.sub(sFee).sub(aFee).sub(rFee)
        }("");
        require(success, "Failed to send Ether");
        (bool success1, ) = feeAddress.call{value: sFee}("");
        require(success1, "Failed to send Ether");
        if (aFee > 0) {
            (bool success3, ) = feeAggregatorAddress.call{value: aFee}("");
            require(success3, "Failed to send Ether");
        }
        if (rFee > 0) {
            (bool success2, ) = royaltyAddress.call{value: rFee}("");
            require(success2, "Failed to send Ether");
        }
        Collection.safeTransferFrom(
            itemOwner,
            itemsForSale[id - 1].bidderAddress,
            _bi.tokenId
        );
        activeItems[itemsForSale[id - 1].tokenAddress][
            itemsForSale[id - 1].tokenId
        ] = false;
        itemsForSale[id - 1].isSold = true;
        pendingReturns[itemsForSale[id - 1].bidderAddress][address(0)][
            itemsForSale[id - 1].tokenId
        ] = 0;
        //itemsForSale[aucItemId - 1].seller = payable(itemsForSale[aucItemId - 1].bidderAddress);
        itemsForSale[id - 1].bidderAddress = address(0);
        itemsForSale[id - 1].bidPrice = 0;
        itemsForSale[id - 1].bidItem = false;
    }

    function _endAuctionERC(uint256 id) internal {
        AuctionItem memory _bi = itemsForSale[id - 1];
        IERC20Upgradeable tokenERC = IERC20Upgradeable(_bi.ERC20);
        IERC721 Collection = IERC721(_bi.tokenAddress);
        address itemOwner = Collection.ownerOf(_bi.tokenId);
        uint256 val = _bi.bidPrice;
        uint256 sFee = _calculateServiceFee(val);
        uint256 aFee = _calculateAggregatorFee(val);
        //uint256 rFee = _calculateRoyaltyFee(val, Collection.Fee());
        (address royaltyAddress, uint256 rFee) = _royaltyData(
            Collection,
            _bi.tokenId,
            _bi.bidPrice
        );

        if (itemsForSale[id - 1].ERC20 == empireToken) {
            tokenERC.transfer(itemOwner, val.sub(rFee));
            if (rFee > 0) {
                tokenERC.transfer(royaltyAddress, rFee);
            }
        } else {
            tokenERC.transfer(itemOwner, val.sub(sFee).sub(aFee).sub(rFee));
            tokenERC.transfer(feeAddress, sFee);
            if (aFee > 0) {
                tokenERC.transfer(feeAggregatorAddress, aFee);
            }
            if (rFee > 0) {
                tokenERC.transfer(royaltyAddress, rFee);
            }
        }
        Collection.safeTransferFrom(
            itemOwner,
            itemsForSale[id - 1].bidderAddress,
            itemsForSale[id - 1].tokenId
        );
        activeItems[itemsForSale[id - 1].tokenAddress][
            itemsForSale[id - 1].tokenId
        ] = false;
        itemsForSale[id - 1].isSold = true;
        pendingReturns[itemsForSale[id - 1].bidderAddress][
            itemsForSale[id - 1].ERC20
        ][itemsForSale[id - 1].tokenId] = 0;
        //itemsForSale[aucItemId - 1].seller = payable(itemsForSale[aucItemId - 1].bidderAddress);
        itemsForSale[id - 1].bidderAddress = address(0);
        itemsForSale[id - 1].bidPrice = 0;
        itemsForSale[id - 1].bidItem = false;
        itemsForSale[id - 1].ERC20 = address(0);
    }

    function _endAuctionOnly(uint256 id) internal {
        activeItems[itemsForSale[id - 1].tokenAddress][
            itemsForSale[id - 1].tokenId
        ] = false;
        itemsForSale[id - 1].isSold = true;
        pendingReturns[itemsForSale[id - 1].bidderAddress][address(0)][
            itemsForSale[id - 1].tokenId
        ] = 0;
        //itemsForSale[aucItemId - 1].seller = payable(itemsForSale[aucItemId - 1].bidderAddress);
        itemsForSale[id - 1].bidderAddress = address(0);
        itemsForSale[id - 1].bidPrice = 0;
        itemsForSale[id - 1].bidItem = false;
    }
}