/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

// Sources flattened with hardhat v2.9.3 https://hardhat.org

// File contracts/Uniswap/IUniswapV2Router01.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}


// File contracts/Uniswap/IUniswapV2Router02.sol



pragma solidity ^0.8.9;
interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


// File contracts/common/Address.sol



pragma solidity ^0.8.9;

library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success,) = recipient.call{value : amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
    internal
    returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

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
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value : weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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


// File @openzeppelin/contracts/token/ERC20/[email protected]


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


// File contracts/utils/AddressUpgradeable.sol


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


// File contracts/proxy/Initializable.sol


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


// File contracts/interface/IERC20Upgradeable.sol


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


// File @openzeppelin/contracts/utils/introspection/[email protected]


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
interface IERC165 {
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


// File @openzeppelin/contracts/token/ERC1155/[email protected]


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}


// File contracts/interface/IBoostNFT.sol


pragma solidity ^0.8.0;
interface IBoostNFT is IERC1155 {
    function getMultiplier(address account, uint256 timeFrom, uint256 timeTo ) external view returns (uint256);
    function getLastMultiplier(address account, uint256 timeTo) external view returns (uint256);
}


// File contracts/common/SafeMath.sol


pragma solidity ^0.8.9;
library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
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
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is TKNaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouTKNd) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouTKNd) while Solidity
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouTKNd) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouTKNd) while Solidity uses an
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
        require(b != 0, errorMessage);
        return a % b;
    }
}


// File contracts/interface/IFeeManager.sol


pragma solidity ^0.8.0;
interface IFeeManager {
 function transferTokenToOperator(address _sender, uint256 _fee, address _token) external;
  function transferFeeToOperator(uint256 _fee) external;
  function transferETHToOperator() payable external;
  function transferFee(address _sender, uint256 _fee) external;
  function transferETH(address _recipient, uint256 _amount) external;
  function claim(address to, uint256 amount) external;
  function transfer(address to, uint256 amount) external;
  function transferFrom(address from, address to, uint256 amount) external;
  function getAmountETH(uint256 _amount) external view returns (uint256);
  function getTransferFee(uint256 _amount) external view returns (uint256);
  function getClaimFee(uint256 _amount) external view returns (uint256);
  function getRateUpgradeFee(string memory tierNameFrom, string memory tierNameTo) external view returns (uint32);
}


// File contracts/NodeManager.sol


pragma solidity ^0.8.0;
library MerkleProof {
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }
    
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash;
    }
}

struct Tier {
  uint8 id;
  string name;
  uint256 price;
  uint256 rewardsPerTime;
  uint32 claimInterval;
  uint256 maintenanceFee;
  uint32 maxPurchase;
}

struct Node {
  uint32 id;
  uint8 tierIndex;
  string title;
  address owner;
  uint32 createdTime;
  uint32 claimedTime;
  uint32 limitedTime;
  uint256 multiplier;
}

contract NodeManager is Initializable {
  // using SafeMath for uint256;
  IFeeManager public feeManager;
  // IBoostNFT public boostNFT;

  Tier[] private tierArr;
  mapping(string => uint8) public tierMap;
  uint8 public tierTotal;
  Node[] private nodesTotal;
  mapping(address => uint256[]) public nodesOfUser;
  uint32 public countTotal;
  mapping(address => uint32) public countOfUser;
  mapping(string => uint32) public countOfTier;
  uint256 public rewardsTotal;
  mapping(address => uint256) public rewardsOfUser;

  uint32 public maxCountOfUser; // 0-Infinite

  address public feeTokenAddress;
  bool public canNodeTransfer;

  address public owner;  

  mapping(address => bool) public blacklist;
  string[] private airdrops;
  mapping(string => bytes32) public merkleRoot;
  mapping(bytes32 => bool) public airdropSupplied;

  mapping(address => uint256) public unclaimed;
  address public minter;
  
  modifier onlyOwner() {
    require(owner == msg.sender, "Ownable: caller is not the owner");
    _;
  }

  event NodeCreated(address, string, uint32, uint32, uint32, uint32);
  event NodeUpdated(address, string, string, uint32);
  event NodeTransfered(address, address, uint32);
  event SwapIn(address indexed, uint32 indexed, string, uint32, int32);
  event SwapOut(address, uint32, uint32, string, uint32);

  // function initialize(address _feeManager, address _nftAddress) public initializer {
  function initialize(address _feeManager) public initializer {
    owner = msg.sender;

    bindFeeManager(_feeManager);
    // bindBoostNFT(_nftAddress);

    addTier('bronze', 10 ether, 0.16 ether, 1 days, 5 ether, 100);
    addTier('silver', 50 ether, 1 ether, 1 days, 15 ether, 10);
    addTier('gold', 100 ether, 2.5 ether, 1 days, 25 ether, 5);

    maxCountOfUser = 130; // 0-Infinite
    canNodeTransfer = true;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(
        newOwner != address(0),
        "Ownable: new owner is the zero address"
    );
    owner = newOwner;
  }

  function bindFeeManager(address _feeManager) public onlyOwner {
    feeManager = IFeeManager(_feeManager);
  }

  // function bindBoostNFT(address _nftAddress) public onlyOwner {
  //   boostNFT = IBoostNFT(_nftAddress);
  // }

  function setMinter(address _minter) public onlyOwner {
    minter = _minter;
  }

  function setPayTokenAddress(address _tokenAddress) public onlyOwner {
    feeTokenAddress = _tokenAddress;
  }

  function setCanNodeTransfer(bool value) public onlyOwner {
    canNodeTransfer = value;
  }

  function setMaxCountOfUser(uint32 _count) public onlyOwner {
    maxCountOfUser = _count;
  }
  
  function tiers() public view returns (Tier[] memory) {
    Tier[] memory tiersActive = new Tier[](tierTotal);
    uint8 j = 0;
    for (uint8 i = 0; i < tierArr.length; i++) {
      Tier storage tier = tierArr[i];
      if (tierMap[tier.name] > 0) tiersActive[j++] = tier;
    }
    return tiersActive;
  }

  function addTier(
    string memory name,
    uint256 price,
    uint256 rewardsPerTime,
    uint32 claimInterval,
    uint256 maintenanceFee,
    uint32 maxPurchase
  ) public onlyOwner {
    require(price > 0, "Tier's price has to be positive.");
    require(rewardsPerTime > 0, "Tier's rewards has to be positive.");
    require(claimInterval > 0, "Tier's claim interval has to be positive.");
    tierArr.push(
      Tier({
	      id: uint8(tierArr.length),
        name: name,
        price: price,
        rewardsPerTime: rewardsPerTime,
        claimInterval: claimInterval,
        maintenanceFee: maintenanceFee,
        maxPurchase: maxPurchase
      })
    );
    tierMap[name] = uint8(tierArr.length);
    tierTotal++;
  }
  
  function tierInfo(
    string memory tierName) public view returns(string memory,uint256,uint256,uint32,uint256,uint32) {
    uint8 tierId = tierMap[tierName];
    require(tierId > 0, "Tier's name is incorrect.");
    Tier storage tier = tierArr[tierId - 1];
    return (tier.name,tier.price,
    tier.rewardsPerTime,
    tier.claimInterval,
    tier.maintenanceFee,
    tier.maxPurchase
    );
  }
  function updateTier(
    string memory tierName,
    string memory name,
    uint256 price,
    uint256 rewardsPerTime,
    uint32 claimInterval,
    uint256 maintenanceFee,
    uint32 maxPurchase
  ) public onlyOwner {
    uint8 tierId = tierMap[tierName];
    require(tierId > 0, "Tier's name is incorrect.");
    require(price > 0, "Tier's price has to be positive.");
    require(rewardsPerTime > 0, "Tier's rewards has to be positive.");
    Tier storage tier = tierArr[tierId - 1];
    tier.name = name;
    tier.price = price;
    tier.rewardsPerTime = rewardsPerTime;
    tier.claimInterval = claimInterval;
    tier.maintenanceFee = maintenanceFee;
    tier.maxPurchase = maxPurchase;
    tierMap[tierName] = 0;
    tierMap[name] = tierId;
  }

  function setTierId(string memory name, uint8 id) public onlyOwner {
    tierMap[name] = id;
  }

  function removeTier(string memory tierName) public onlyOwner {
    require(tierMap[tierName] > 0, 'Tier was already removed.');
    tierMap[tierName] = 0;
    tierTotal--;
  }

  function maxNodeIndex() public view returns (uint32) {
    return uint32(nodesTotal.length);
  }

  function burnedNodes() public view returns (Node[] memory) {
    uint256 nodesLen = nodesTotal.length - countTotal;
    Node[] memory nodesBurn = new Node[](nodesLen);
    uint32 j = 0;
    for (uint256 i = 0;i<nodesTotal.length;i++) {
      Node storage node = nodesTotal[i];
      if(node.owner==address(0))
        nodesBurn[j++] = node;
    }
    return nodesBurn;
  }

  function nodes(address account) public view returns (Node[] memory) {
    if (account==address(0))
      return burnedNodes();
    uint256 nodesLen = countOfUser[account];
    Node[] memory nodesActive = new Node[](nodesLen);
    if(nodesLen>0) {
      uint256[] storage nodeIndice = nodesOfUser[account];
      uint32 j = 0;
      for (uint32 i = 0; i < nodeIndice.length; i++) {
        uint256 nodeIndex = nodeIndice[i];
        if (nodeIndex > 0) {
          Node storage node = nodesTotal[nodeIndex - 1];
          if (node.owner == account) {
            nodesActive[j] = node;
            // nodesActive[j].multiplier = getBoostRate(account, node.claimedTime, block.timestamp);
            j++;
            if(j>=nodesLen)
              break;
          }
        }
      }
    }
    return nodesActive;
  }

  function checkHasNodes(address account) public view returns (bool) {
    uint256[] storage nodeIndice = nodesOfUser[account];
    for (uint32 i = 0; i < nodeIndice.length; i++) {
      uint256 nodeIndex = nodeIndice[i];
      if (nodeIndex > 0) {
        Node storage node = nodesTotal[nodeIndex - 1];
        if (node.owner == account) {
          return true;          
        }
      }
    }
    return false;
  }

  function countOfNodes(address account, string memory tierName) public view returns (uint32) {
    uint8 tierId = tierMap[tierName];
    uint256[] storage nodeIndice = nodesOfUser[account];  
    uint32 count = 0;
    for (uint32 i = 0; i < nodeIndice.length; i++) {
      uint256 nodeIndex = nodeIndice[i];
      if (nodeIndex > 0) {
        Node storage node = nodesTotal[nodeIndex - 1];
        if (node.owner == account && node.tierIndex==tierId-1) {
          count++;
        }
      }
    }
    return count;
  }

  function _create(
    address account,
    string memory tierName,
    string memory title,
    uint32 count,
    int32 limitedTimeOffset
  ) private returns (uint256) {
    require(!blacklist[account],"Invalid wallet");
    uint8 tierId = tierMap[tierName];
    Tier storage tier = tierArr[tierId - 1];
    require(countOfUser[account]+count <= maxCountOfUser, 'Cannot create node more than MAX.');
    require(countOfNodes(account, tierName)+count <= tier.maxPurchase, 'Cannot create node more than MAX');
    for (uint32 i = 0; i < count; i++) {
      nodesTotal.push(
        Node({
          id: uint32(nodesTotal.length),
          tierIndex: tierId - 1,
          title: title,
          owner: account,
          multiplier: 0,
          createdTime: uint32(block.timestamp),
          claimedTime: uint32(block.timestamp),
          limitedTime: uint32(uint256(int(block.timestamp)+limitedTimeOffset))
        })
      );
      uint256[] storage nodeIndice = nodesOfUser[account];
      nodeIndice.push(nodesTotal.length);
    }
    countOfUser[account] += count;
    countOfTier[tierName] += count;
    countTotal += count;
    uint256 amount = tier.price * count;
    // if (count >= 10) amount = amount.mul(10000 - discountPer10).div(10000);
    return amount;
  }

  function mint(
    address[] memory accounts,
    string memory tierName,
    string memory title,
    uint32 count
  ) public onlyOwner {
    require(accounts.length>0, "Empty account list.");
    for(uint256 i = 0;i<accounts.length;i++) {
      _create(accounts[i], tierName, title, count, 0);
    }
  }

  function create(
    string memory tierName,
    string memory title,
    uint32 count
  ) public {
    uint256 amount = _create(msg.sender, tierName, title, count, 0);
    feeManager.transferFee(msg.sender, amount);
    emit NodeCreated(
      msg.sender,
      tierName,
      count,
      countTotal,
      countOfUser[msg.sender],
      countOfTier[tierName]
    );
  }

  /*function getBoostRate(address account, uint256 timeFrom, uint256 timeTo) public view returns (uint256) {
    uint256 multiplier = 1 ether;
    if(address(boostNFT) == address(0)){
      return multiplier;
    }
    multiplier = boostNFT.getMultiplier(account, timeFrom, timeTo);
    return multiplier;
  }*/
  
  function claimable(address _account) public view returns (uint256) {
    (uint256 claimableAmount,,) = _iterate(_account, 0, 0);
    return claimableAmount;
  }

  function _iterate(address _account, uint8 _tierId, uint32 _count) private view returns (uint256, uint32, uint256[] memory) {
    uint256 claimableAmount = 0;
    uint256[] storage nodeIndice = nodesOfUser[_account];
    uint256[] memory nodeIndiceResult = new uint256[](nodeIndice.length);
    uint32 count = 0;
    for (uint32 i = 0; i < nodeIndice.length; i++) {
      uint256 nodeIndex = nodeIndice[i];
      if (nodeIndex > 0) {
        Node storage node = nodesTotal[nodeIndex - 1];
        if (_tierId!=0 && node.tierIndex!=_tierId-1) continue;
        if (node.owner == _account) {
        //   uint256 multiplier = getBoostRate(_account, node.claimedTime, block.timestamp);          
          Tier storage tier = tierArr[node.tierIndex];
          claimableAmount = uint256(block.timestamp - node.claimedTime)
            * tier.rewardsPerTime
            // * multiplier
            / 1 ether
            / tier.claimInterval
            + claimableAmount;
          nodeIndiceResult[count] = nodeIndex;
          count ++;
          if(_count!=0 && count==_count) break;
        }
      }
    }
    return (claimableAmount, count, nodeIndiceResult);
  }

  function _claim() private {
    (uint256 claimableAmount,uint32 count,uint256[] memory nodeIndice) = _iterate(msg.sender, 0, 0);
    // require(claimableAmount > 0, 'No claimable tokens.');
    if(claimableAmount > 0) {
      rewardsOfUser[msg.sender] = rewardsOfUser[msg.sender] + claimableAmount;
      rewardsTotal = rewardsTotal + claimableAmount;
      unclaimed[msg.sender] += claimableAmount;
    }
    for(uint32 i = 0;i<count;i++) {
      uint256 index = nodeIndice[i];
      Node storage node = nodesTotal[index - 1];
      node.claimedTime = uint32(block.timestamp);
    }
  }

  function compound(
    string memory tierName,
    string memory title,
    uint32 count
  ) public {
    uint256 amount = _create(msg.sender, tierName, title, count, 0);
    if(unclaimed[msg.sender] < amount) _claim();
    require(unclaimed[msg.sender] >= amount, 'Insufficient claimable tokens to compound.');
    unclaimed[msg.sender] -= amount;
    // feeManager.claim(address(msg.sender), claimableAmount - exceptAmount);
    emit NodeCreated(
      msg.sender,
      tierName,
      count,
      countTotal,
      countOfUser[msg.sender],
      countOfTier[tierName]
    );
  }

  function claim() public {
    require(!blacklist[msg.sender],"Invalid wallet");
    _claim();
    require(unclaimed[msg.sender] > 0, 'No claimable tokens.');
    feeManager.claim(address(msg.sender), unclaimed[msg.sender]);
    unclaimed[msg.sender] = 0;
  }

  function upgrade(
    string memory tierNameFrom,
    string memory tierNameTo,
    uint32 count
  ) public payable {
    uint8 tierIndexFrom = tierMap[tierNameFrom];
    uint8 tierIndexTo = tierMap[tierNameTo];
    require(tierIndexFrom > 0, 'Invalid tier to upgrade from.');
    require(tierIndexTo > 0, 'Invalid tier to upgrade to.');
    Tier storage tierFrom = tierArr[tierIndexFrom - 1];
    Tier storage tierTo = tierArr[tierIndexTo - 1];
    require(tierTo.price > tierFrom.price, 'Unable to downgrade.');
    uint32 countNeeded = uint32(count * tierTo.price / tierFrom.price);
    (uint256 claimableAmount,uint32 countUpgrade, uint256[] memory nodeIndice) = _iterate(msg.sender, tierIndexFrom, countNeeded);
    // require(countUpgrade==countNeeded, 'Insufficient nodes.');
    if (claimableAmount > 0) {
      rewardsOfUser[msg.sender] = rewardsOfUser[msg.sender] + claimableAmount;
      rewardsTotal = rewardsTotal + claimableAmount;
      unclaimed[msg.sender] += claimableAmount;
    }
    int32 limitedTime = 0;
    for(uint32 i = 0;i<countUpgrade;i++) {
      uint256 index = nodeIndice[i];
      Node storage node = nodesTotal[index - 1];
      node.claimedTime = uint32(block.timestamp);
      node.owner = address(0);
      limitedTime += int32(int32(node.limitedTime) - int(block.timestamp));
    }
    countOfUser[msg.sender] -= countUpgrade;
    countOfTier[tierNameFrom] -= countUpgrade;
    countTotal -= countUpgrade;
    // countOfTier[tierNameTo] += count;
    if(countUpgrade<countNeeded) {
      uint256 price = tierFrom.price * (countNeeded - countUpgrade);
      // if (count >= 10) price = price.mul(10000 - discountPer10).div(10000);
      feeManager.transferFee(msg.sender, price);
    }
    _create(msg.sender, tierNameTo, '', count, int32(int(limitedTime) / int32(countNeeded)));
    uint256 feeETH = 0;
    uint256 feeToken = 0;
    (feeETH, feeToken) = getUpgradeFee(tierNameFrom, tierNameTo, count);
    // require(amountUpgradeFee<=msg.value, "Insufficient ETH for upgrade fee");
    if(msg.value >= feeETH) {
      feeManager.transferETHToOperator{value:feeETH}();
      if(msg.value > feeETH)
        payable(msg.sender).transfer(msg.value - feeETH);
    } else {
      feeManager.transferETHToOperator{value:msg.value}();
      uint256 fee = feeToken - (feeETH - msg.value) * feeToken / feeETH;
      feeManager.transferFeeToOperator(fee);
    }
    emit NodeUpdated(msg.sender, tierNameFrom, tierNameTo, count);
  }

  function getUpgradeFee(string memory tierNameFrom, string memory tierNameTo, uint32 count) public view returns (uint256, uint256) {
    uint8 tierIndexTo = tierMap[tierNameTo];
    require(tierIndexTo > 0, 'Invalid tier to upgrade to.');
    Tier storage tierTo = tierArr[tierIndexTo - 1];
    uint32 rateFee = feeManager.getRateUpgradeFee(tierNameFrom, tierNameTo);
    if(rateFee==0) return (0, 0);
    uint256 amountToken = tierTo.price * count * rateFee / 10000;
    return (feeManager.getAmountETH(amountToken), amountToken);
  }

  function transfer(
    string memory tierName,
    uint32 count,
    address recipient
  ) public {
    require(!blacklist[msg.sender],"Invalid wallet");
    require(canNodeTransfer==true,'Node transfer unavailable!');
    uint8 tierIndex = tierMap[tierName];
    require(tierIndex > 0, 'Invalid tier to transfer.');
    Tier storage tier = tierArr[tierIndex - 1];
    require(countOfUser[recipient]+count <= maxCountOfUser, 'Cannot transfer node, because recipient will get more than MAX');
    require(countOfNodes(recipient, tierName)+count <= tier.maxPurchase, 'Cannot transfer node, because recipient will get more than MAX');
    uint256[] storage nodeIndiceFrom = nodesOfUser[msg.sender];
    uint256[] storage nodeIndiceTo = nodesOfUser[recipient];
    uint32 countTransfer = 0;
    uint256 claimableAmount = 0;
    for (uint32 i = 0; i < nodeIndiceFrom.length; i++) {
      uint256 nodeIndex = nodeIndiceFrom[i];
      if (nodeIndex > 0) {
        Node storage node = nodesTotal[nodeIndex - 1];
        if (node.owner == msg.sender && tierIndex - 1 == node.tierIndex) {
          node.owner = recipient;
        //   uint256 multiplier = getBoostRate(msg.sender, node.claimedTime, block.timestamp);
          uint256 claimed = uint256(block.timestamp - node.claimedTime)
            * tier.rewardsPerTime
            / tier.claimInterval;
        //   claimableAmount = claimed * multiplier / 1 ether + claimableAmount;
          claimableAmount = claimed  / 1 ether + claimableAmount;
          node.claimedTime = uint32(block.timestamp);
          countTransfer++;
          nodeIndiceTo.push(nodeIndex);
          nodeIndiceFrom[i] = 0;
          if (countTransfer == count) break;
        }
      }
    }
    require(countTransfer == count, 'Not enough nodes to transfer.');
    countOfUser[msg.sender] -= count;
    countOfUser[recipient] += count;
    if (claimableAmount > 0) {
      rewardsOfUser[msg.sender] = rewardsOfUser[msg.sender] + claimableAmount;
      rewardsTotal = rewardsTotal + claimableAmount;
      unclaimed[msg.sender] += claimableAmount;
    }
    uint256 fee = feeManager.getTransferFee(tier.price * count);
    // if (count >= 10) fee = fee.mul(10000 - discountPer10).div(10000);
    if (fee > claimableAmount)
      feeManager.transferFrom(
        address(msg.sender),
        address(this),
        fee - claimableAmount
      );
    else if (fee < claimableAmount) {
      unclaimed[msg.sender] += claimableAmount - fee;
    }
    emit NodeTransfered(msg.sender, recipient, count);
  }

  function burnUser(address account) public onlyOwner {
    uint256[] storage nodeIndice = nodesOfUser[account];
    for (uint32 i = 0; i < nodeIndice.length; i++) {
      uint256 nodeIndex = nodeIndice[i];
      if (nodeIndex > 0) {
        Node storage node = nodesTotal[nodeIndex - 1];
        if (node.owner == account) {
          node.owner = address(0);
          node.claimedTime = uint32(block.timestamp);
          Tier storage tier = tierArr[node.tierIndex];
          countOfTier[tier.name]--;
        }
      }
    }
    nodesOfUser[account] = new uint256[](0);
    countTotal -= countOfUser[account];
    countOfUser[account] = 0;
  }

  function burnNodes(uint32[] memory indice) public onlyOwner {
    uint32 count = 0;
    for (uint32 i = 0; i < indice.length; i++) {
      uint256 nodeIndex = indice[i];
      if (nodeIndex > 0) {
        Node storage node = nodesTotal[nodeIndex - 1];
        if (node.owner != address(0)) {
          uint256[] storage nodeIndice = nodesOfUser[node.owner];
          for (uint32 j = 0; j < nodeIndice.length; j++) {
            if (nodeIndex == nodeIndice[j]) {
              nodeIndice[j] = 0;
              break;
            }
          }
          countOfUser[node.owner]--;
          node.owner = address(0);
          node.claimedTime = uint32(block.timestamp);
          Tier storage tier = tierArr[node.tierIndex];
          countOfTier[tier.name]--;
          count++;
        }
      }
    }
    countTotal -= count;
  }

  function pay(uint8 count, uint256[] memory selected) public payable {
    require(count > 0 && count <= 12, 'Invalid number of months.');
    uint256 fee = 0;
    if(selected.length==0) {
      uint256[] storage nodeIndice = nodesOfUser[msg.sender];
      for (uint32 i = 0; i < nodeIndice.length; i++) {
        uint256 nodeIndex = nodeIndice[i];
        if (nodeIndex > 0) {
          Node storage node = nodesTotal[nodeIndex - 1];
          if (node.owner == msg.sender) {
            Tier storage tier = tierArr[node.tierIndex];
            node.limitedTime += count * uint32(30 days);
            fee = tier.maintenanceFee * count + fee;
          }
        }
      }
    } else {
      for (uint32 i = 0; i < selected.length; i++) {
        uint256 nodeIndex = selected[i];
        Node storage node = nodesTotal[nodeIndex];
        if (node.owner == msg.sender) {
          Tier storage tier = tierArr[node.tierIndex];
          node.limitedTime += count * uint32(30 days);
          fee = tier.maintenanceFee * count + fee;
        }
      }
    }
    if(feeTokenAddress==address(0)) { 
      // pay with ETH
      require(fee == msg.value,"Invalid Fee amount");
      feeManager.transferETHToOperator{value:fee}();
    } else {
      // pay with stable coin BUSD
      require(fee < IERC20(feeTokenAddress).balanceOf(msg.sender),"Insufficient BUSD amount");
      feeManager.transferTokenToOperator(msg.sender, fee, feeTokenAddress);
    }
  }

  function unpaidNodes() public onlyOwner view returns (Node[] memory) {
    uint32 count = 0;
    for (uint32 i = 0; i < nodesTotal.length; i++) {
      Node storage node = nodesTotal[i];
      if (node.owner != address(0) && node.limitedTime < uint32(block.timestamp)) {
        count++;
      }
    }
    Node[] memory nodesInactive = new Node[](count);
    uint32 j = 0;
    for (uint32 i = 0; i < nodesTotal.length; i++) {
      Node storage node = nodesTotal[i];
      if (node.owner != address(0) && node.limitedTime < uint32(block.timestamp)) {
        nodesInactive[j++] = node;
      }
    }
    return nodesInactive;
  }

  function addBlacklist(address _account) public onlyOwner {
    blacklist[_account] = true;
  }

  function removeBlacklist(address _account) public onlyOwner {
    blacklist[_account] = false;
  }

  /*function getAirdrops() public view returns (string[] memory) {
    uint256 _len = airdrops.length;
    for (uint32 i = 0; i < airdrops.length; i++) {
      if(uint256(merkleRoot[airdrops[i]])==0) _len--;
    }
    string[] memory _airdrops = new string[](_len);
    for (uint32 i = 0; i < airdrops.length; i++) {
      _airdrops[i] = airdrops[i];
    }
    return _airdrops;
  }

  function setAirdrop(string memory _name, bytes32 _root) public onlyOwner {
    merkleRoot[_name] = _root;

  }

  function canAirdrop(address _account, string memory _tier, uint32 _amount) public view returns (bool) {
    bytes32 leaf = keccak256(abi.encodePacked(_account, _tier, _amount));
    return !airdropSupplied[leaf];
  }

  function claimAirdrop(string memory _name, string memory _tier, uint32 _amount, bytes32[] calldata _merkleProof) public {
    bytes32 leaf = keccak256(abi.encodePacked(msg.sender, _tier, _amount));
    bool valid = MerkleProof.verify(_merkleProof, merkleRoot[_name], leaf);
    require(valid, "Invalid airdrop address.");
    require(!airdropSupplied[leaf], "Already claimed.");
    _create(msg.sender, _tier, '', _amount, 0);   
    airdropSupplied[leaf] = true;
  }*/

  function swapIn(uint32 _chainId, string memory _tierName, uint32 _amount) public payable {
    uint8 tierIndex = tierMap[_tierName];
    require(tierIndex > 0, 'Invalid tier to swap.');
    (,uint32 count,uint256[] memory nodeIndice) = _iterate(msg.sender, tierIndex, _amount);
    require(count==_amount, 'Insufficient node amount.');
    int32 limitedTime = 0;
    for(uint32 i = 0;i<count;i++) {
      uint256 index = nodeIndice[i];
      Node storage node = nodesTotal[index - 1];
      node.claimedTime = uint32(block.timestamp);
      node.owner = address(0);
      limitedTime += int32(int32(node.limitedTime) - int(block.timestamp));
    }
    if(msg.value > 0)
      payable(minter).transfer(msg.value);
    emit SwapIn(msg.sender, _chainId, _tierName, _amount, int32(int(limitedTime) / int32(count)));
  }

  function swapOut(address _account, string memory _tierName, uint32 _amount, int32 _limitedTime) public {
    require(msg.sender==minter, "Only minter can call swap.");
    uint8 tierIndex = tierMap[_tierName];
    require(tierIndex > 0, 'Invalid tier to swap.');
    Tier storage tier = tierArr[tierIndex - 1];
    require(countOfNodes(_account, _tierName)+_amount <= tier.maxPurchase, 'Cannot swap node, because recipient will get more than MAX');
    _create(_account, _tierName, '', _amount, _limitedTime);
    // emit SwapOut(_account, chainId, _tierName, _amount);
  }
}