/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol

pragma solidity >=0.6.2;

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

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol

pragma solidity >=0.6.2;


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

// File: @openzeppelin/contracts/utils/Address.sol


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


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

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


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

// File: @openzeppelin/contracts/token/ERC1155/IERC1155.sol


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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
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

// File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;


/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// File: contracts/IWarrior721.sol



pragma solidity 0.8.7;


interface IWarrior721 is IERC721Enumerable {
    function ETERNAL_CALL() external;
    function G_WarriorId() external view returns (uint256 _warriorId);
    function G_TotalActiveSupply() external view returns (uint256 _totalActiveSupply);
    function WhitelistMint(address to_, uint256 timestamp_, uint256 hero_, uint256 rarity_, uint256 level_) external returns (bool _mintedSuccessfully, uint256 _mintedWarriorId);
    function MultiWhitelistMint(address[] calldata to_, uint256[] calldata hero_, uint256[] calldata rarity_) external returns (bool _mintedSuccessfully);
    function changeBaseURI(string calldata newbaseURI) external returns (string memory _newbaseURI);
}
// File: contracts/IEternalStorage.sol



pragma solidity 0.8.7;

interface IEternalStorage {
    
    // *** GLOBAL_DATA_BOOL ***
    function SET_GLOBAL_DATA_BOOL(bytes32 key_, bool value_) external;
    function GET_GLOBAL_DATA_BOOL(bytes32 key_) external view returns (bool);
    function SET_GLOBAL_DATA_BOOL(bytes32 key_0, bool value_0,
                                  bytes32 key_1, bool value_1,
                                  bytes32 key_2, bool value_2,
                                  bytes32 key_3, bool value_3) 
                                  external;
    function GET_GLOBAL_DATA_BOOL(bytes32 key_0, bytes32 key_1) 
                                  external view
                                  returns (bool, bool);
    function GET_GLOBAL_DATA_BOOL(bytes32 key_0, bytes32 key_1, 
                                  bytes32 key_2, bytes32 key_3) 
                                  external view
                                  returns (bool, bool, bool, bool);

    // *** GLOBAL_DATA_UINT256 ***
    function SET_GLOBAL_DATA_UINT256(bytes32 key_, uint256 value_) external;
    function GET_GLOBAL_DATA_UINT256(bytes32 key_) external view returns (uint256);
    function SET_GLOBAL_DATA_UINT256(bytes32 key_0, uint256 value_0,
                                     bytes32 key_1, uint256 value_1,
                                     bytes32 key_2, uint256 value_2,
                                     bytes32 key_3, uint256 value_3) 
                                     external;
    function GET_GLOBAL_DATA_UINT256(bytes32 key_0, bytes32 key_1) 
                                     external view
                                     returns (uint256, uint256);
    function GET_GLOBAL_DATA_UINT256(bytes32 key_0, bytes32 key_1, 
                                     bytes32 key_2, bytes32 key_3) 
                                     external view
                                     returns (uint256, uint256, uint256, uint256);

    // *** GLOBAL_DATA_ADDRESS ***
    function SET_GLOBAL_DATA_ADDRESS(bytes32 key_, address value_) external;
    function GET_GLOBAL_DATA_ADDRESS(bytes32 key_) external view returns (address);
    function SET_GLOBAL_DATA_ADDRESS(bytes32 key_0, address value_0,
                                     bytes32 key_1, address value_1,
                                     bytes32 key_2, address value_2,
                                     bytes32 key_3, address value_3) 
                                     external;
    function GET_GLOBAL_DATA_ADDRESS(bytes32 key_0, bytes32 key_1) 
                                     external view
                                     returns (address, address);
    function GET_GLOBAL_DATA_ADDRESS(bytes32 key_0, bytes32 key_1, 
                                     bytes32 key_2, bytes32 key_3) 
                                     external view
                                     returns (address, address, address, address);
    function INCREASE_GLOBAL_DATA_UINT256(bytes32 key_, uint256 value_) external;
    function DECREASE_GLOBAL_DATA_UINT256(bytes32 key_, uint256 value_) external;

    // *** NFT_DATA ***
    function SET_NFT_DATA_UINT256(uint256 index_, uint256 structDataIndex_, uint256 uint256DataIndex_, uint256 value_) external;
    function SET_NFT_DATA_BOOL(uint256 index_, uint256 structDataIndex_, uint256 boolDataIndex_, bool value_) external;
    function GET_NFT_DATA_UINT256(uint256 index_, uint256 structDataIndex_, uint256 uint256DataIndex_) external view returns (uint256);
    function GET_NFT_DATA_BOOL(uint256 index_, uint256 structDataIndex_, uint256 boolDataIndex_) external view returns (bool);
    function SET_NFT_DATA_UINT256(uint256 index_, uint256 structDataIndex_, 
                                  uint256 uint256DataIndex_0, uint256 value_0,
                                  uint256 uint256DataIndex_1, uint256 value_1) 
                                  external;
    function SET_NFT_DATA_UINT256(uint256 index_, uint256 structDataIndex_, 
                                  uint256 uint256DataIndex_0, uint256 value_0,
                                  uint256 uint256DataIndex_1, uint256 value_1,
                                  uint256 uint256DataIndex_2, uint256 value_2,
                                  uint256 uint256DataIndex_3, uint256 value_3) 
                                  external;
    function SET_NFT_DATA_BOOL(uint256 index_, uint256 structDataIndex_, 
                               uint256 boolDataIndex_0, bool value_0,
                               uint256 boolDataIndex_1, bool value_1,
                               uint256 boolDataIndex_2, bool value_2,
                               uint256 boolDataIndex_3, bool value_3) 
                               external;
    function GET_NFT_DATA_UINT256(uint256 index_, uint256 structDataIndex_, 
                                  uint256 uint256DataIndex_0, uint256 uint256DataIndex_1) 
                                  external view 
                                  returns (uint256, uint256);
    function GET_NFT_DATA_BOOL(uint256 index_, uint256 structDataIndex_, 
                               uint256 boolDataIndex_0, uint256 boolDataIndex_1) 
                               external view 
                               returns (bool, bool);
    function GET_NFT_DATA_UINT256(uint256 index_, uint256 structDataIndex_, 
                                  uint256 uint256DataIndex_0, uint256 uint256DataIndex_1,
                                  uint256 uint256DataIndex_2, uint256 uint256DataIndex_3) 
                                  external view 
                                  returns (uint256, uint256, uint256, uint256);
    function GET_NFT_DATA_BOOL(uint256 index_, uint256 structDataIndex_, 
                               uint256 boolDataIndex_0, uint256 boolDataIndex_1,
                               uint256 boolDataIndex_2, uint256 boolDataIndex_3) 
                               external view 
                               returns (bool, bool, bool, bool);
    function INCREASE_NFT_DATA_UINT256(uint256 index_, uint256 structDataIndex_, uint256 uint256DataIndex_, uint256 value_) external;
    function DECREASE_NFT_DATA_UINT256(uint256 index_, uint256 structDataIndex_, uint256 uint256DataIndex_, uint256 value_) external;

    // *** WALLET_DATA ***
    function SET_WALLET_DATA_UINT256(address addr_, uint256 structDataIndex_, uint256 uint256DataIndex_, uint256 value_) external;
    function SET_WALLET_DATA_BOOL(address addr_, uint256 structDataIndex_, uint256 boolDataIndex_, bool value_) external;
    function GET_WALLET_DATA_UINT256(address addr_, uint256 structDataIndex_, uint256 uint256DataIndex_) external view returns (uint256);
    function GET_WALLET_DATA_BOOL(address addr_, uint256 structDataIndex_, uint256 boolDataIndex_) external view returns (bool);
    function SET_WALLET_DATA_UINT256(address addr_, uint256 structDataIndex_, 
                                     uint256 uint256DataIndex_0, uint256 value_0,
                                     uint256 uint256DataIndex_1, uint256 value_1) 
                                     external;
    function SET_WALLET_DATA_UINT256(address addr_, uint256 structDataIndex_, 
                                     uint256 uint256DataIndex_0, uint256 value_0,
                                     uint256 uint256DataIndex_1, uint256 value_1,
                                     uint256 uint256DataIndex_2, uint256 value_2,
                                     uint256 uint256DataIndex_3, uint256 value_3) 
                                     external;
    function SET_WALLET_DATA_BOOL(address addr_, uint256 structDataIndex_, 
                                  uint256 boolDataIndex_0, bool value_0,
                                  uint256 boolDataIndex_1, bool value_1,
                                  uint256 boolDataIndex_2, bool value_2,
                                  uint256 boolDataIndex_3, bool value_3) 
                                  external;
    function GET_WALLET_DATA_UINT256(address addr_, uint256 structDataIndex_, 
                                     uint256 uint256DataIndex_0, uint256 uint256DataIndex_1) 
                                     external view 
                                     returns (uint256, uint256);
    function GET_WALLET_DATA_BOOL(address addr_, uint256 structDataIndex_, 
                                  uint256 boolDataIndex_0, uint256 boolDataIndex_1) 
                                  external view 
                                  returns (bool, bool);
    function GET_WALLET_DATA_UINT256(address addr_, uint256 structDataIndex_, 
                                     uint256 uint256DataIndex_0, uint256 uint256DataIndex_1,
                                     uint256 uint256DataIndex_2, uint256 uint256DataIndex_3) 
                                     external view 
                                     returns (uint256, uint256, uint256, uint256);
    function GET_WALLET_DATA_BOOL(address addr_, uint256 structDataIndex_, 
                                  uint256 boolDataIndex_0, uint256 boolDataIndex_1,
                                  uint256 boolDataIndex_2, uint256 boolDataIndex_3) 
                                  external view 
                                  returns (bool, bool, bool, bool);
    function INCREASE_WALLET_DATA_UINT256(address addr_, uint256 structDataIndex_, uint256 uint256DataIndex_, uint256 value_) external;
    function DECREASE_WALLET_DATA_UINT256(address addr_, uint256 structDataIndex_, uint256 uint256DataIndex_, uint256 value_) external;

    // *** OWNER ***
    function AddToWhiteList(address addr_) external;
    function AddToWhiteList(address[] calldata addr_) external;
    function RemoveFromWhiteList(address addr_) external;
    function RemoveFromWhiteList(address[] calldata addr_) external;
    function AddToAllWhiteLists(address addr_) external;
    function AddToAllWhiteLists(address[] calldata addr_) external;
    function RemoveFromAllWhiteLists(address addr_) external;
    function RemoveFromAllWhiteLists(address[] calldata addr_) external;
    function IsWhiteListed(address addr) external view returns (bool);
    function owner() external view returns (address);
    function transferOwnership(address newOwner_) external;
    function withdrawETHFixed(uint256 withdrawAmount_) external;
}



// File: contracts/Bank.sol



pragma solidity 0.8.7;






contract Bank {

    bool private CAN_WITHDRAW;
    bool private BETATEST_ENABLED;
    uint256 private WITHDRAW_FEE_DAILY_DROP;
    uint256 private WITHDRAW_COIN_FEE;
    uint256 private WITHDRAW_COOLDOWN;
    uint256 private ETH_WITHDRAW_FEE;
    uint256 private SWAP_FEE_ON_WITHDRAW;
    uint256 public balance;
    uint256 constant private DECIMALS_18 = 1000000000000000000; // 10 ** 18
    address private FEECOLLECTOR_ADDRESS;
    address private owner_;
    address private immutable AOW_ADDRESS;
    IEternalStorage private eternalStorage;
    IUniswapV2Router02 private immutable uniswapV2Router;
    IERC20 immutable aowCoin;
    
    constructor(address eternalStorageAddr_, address aowAddr_, address routerAddress_) {
        require(eternalStorageAddr_ != address(0));
        eternalStorage = IEternalStorage(eternalStorageAddr_);
        owner_ = eternalStorage.owner();
        AOW_ADDRESS = aowAddr_;
        aowCoin = IERC20(aowAddr_);
        uniswapV2Router = IUniswapV2Router02(routerAddress_);
    }
    
// *** ETERNAL CALL ***
    function ETERNAL_CALL() external onlyOwnerOrWhitelisted {
        owner_ = eternalStorage.owner();
        (bool forceStop_, bool gameEnabled_, bool canWithdrawCoin_, bool betatestEnabled)
         = eternalStorage.GET_GLOBAL_DATA_BOOL("FORCE_STOP", "GAME_ENABLED", "CAN_WITHDRAW_COIN", "BETATEST_ENABLED");
        BETATEST_ENABLED = betatestEnabled;
        CAN_WITHDRAW = !forceStop_ && gameEnabled_ && canWithdrawCoin_;
        (WITHDRAW_FEE_DAILY_DROP, WITHDRAW_COIN_FEE, WITHDRAW_COOLDOWN, ETH_WITHDRAW_FEE)
         = eternalStorage.GET_GLOBAL_DATA_UINT256("WITHDRAW_FEE_DAILY_DROP", "WITHDRAW_COIN_FEE", "WITHDRAW_COOLDOWN", "ETH_WITHDRAW_FEE");
        SWAP_FEE_ON_WITHDRAW = eternalStorage.GET_GLOBAL_DATA_UINT256("SWAP_FEE_ON_WITHDRAW");
        FEECOLLECTOR_ADDRESS = eternalStorage.GET_GLOBAL_DATA_ADDRESS("FEECOLLECTOR_ADDRESS");
    }

// *** DESTROY ***
    function A_DestroyContract(bool confirmed) external onlyOwner {
        require(confirmed);
        address collector_ = eternalStorage.owner();
        require(collector_ != address(0));
        selfdestruct(payable(collector_));
    }

// *** WITHDRAW ***
    function A_WITHDRAW_AOW() external payable canWithdraw(msg.sender)
        returns (bool _isSuccessful) {
        address msgSender_ = msg.sender;
        uint256 timeStamp = block.timestamp;
        if (BETATEST_ENABLED) {
            require(eternalStorage.GET_WALLET_DATA_BOOL(msgSender_, 0, 5), "User is not beta tester");
        }
        // Get Variables
        (uint256 withdrawalAmount_, uint256 lastWithdrawTime_) =
        eternalStorage.GET_WALLET_DATA_UINT256(msgSender_, 0, 0, 1);
        uint256 totalFeePercentage = WITHDRAW_COIN_FEE;
        
        uint256 ethFee = ETH_WITHDRAW_FEE;
        require(aowCoin.balanceOf(address(this)) >= withdrawalAmount_ && msg.value == ethFee && timeStamp > lastWithdrawTime_ + WITHDRAW_COOLDOWN);
        if (ethFee > 0) {
            balance += ethFee;
            emit E_A_TransferReceived(msgSender_, ethFee); 
        } 
        eternalStorage.SET_WALLET_DATA_UINT256(msgSender_, 0, 
                                               0, 0,
                                               1, timeStamp);
        uint256 withdrawTimeDifference = timeStamp - lastWithdrawTime_;
        uint256 totalFeeTokenAmount;
        unchecked {
            // Seconds per day
            if (withdrawTimeDifference >= 86400) {
                withdrawTimeDifference /= 86400;
                if (totalFeePercentage >= withdrawTimeDifference * WITHDRAW_FEE_DAILY_DROP)
                    totalFeePercentage -= withdrawTimeDifference * WITHDRAW_FEE_DAILY_DROP;
                else totalFeePercentage = 0;
            }
            totalFeeTokenAmount = (withdrawalAmount_ * totalFeePercentage) / 100;
            if (totalFeeTokenAmount > 0) withdrawalAmount_ -= totalFeeTokenAmount;
        }
        transferERC20_(aowCoin, msgSender_, withdrawalAmount_);
        if (totalFeeTokenAmount > 0 && SWAP_FEE_ON_WITHDRAW > 0) swapTokensForEth((totalFeeTokenAmount * SWAP_FEE_ON_WITHDRAW) /100);
        emit E_A_WITHDRAW_AOW(msgSender_, withdrawalAmount_);
        return true;
    }
    function SweepTokensForEth(uint256 tokenAmount) external onlyOwnerOrWhitelisted {
        if (tokenAmount > 0 && tokenAmount <= 10 ** 23)
            swapTokensForEth(tokenAmount);
    }
	function swapTokensForEth(uint256 tokenAmount) private {
		if (tokenAmount > 0) {
			// Generate the uniswap pair path of token -> weth
			address[] memory path = new address[](2);
			path[0] = AOW_ADDRESS;
			path[1] = uniswapV2Router.WETH();

			aowCoin.approve(address(uniswapV2Router), tokenAmount);
			// Make the swap
			uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
				tokenAmount,
				0, // Accept any amount of ETH
				path,
				FEECOLLECTOR_ADDRESS, // Collector
				block.timestamp
			);
		}
	}

// *** PRIVATE ***
    function _G_IsActionOrBlacklisted_(address addr_) private view returns (bool) {
        (bool isBlacklisted_, bool isActionlisted_) =
        eternalStorage.GET_WALLET_DATA_BOOL(addr_, 0, 0, 3);
        return (isBlacklisted_ && isActionlisted_);
    }

// *** RECEIVE & TRANSFER ***
    receive() payable external {
        balance += msg.value;
        emit E_A_TransferReceived(msg.sender, msg.value);
    }
	function withdrawERC721(address tokenAddress_, uint256 tokenId_) external onlyOwner {
        IERC721 token_ = IERC721(tokenAddress_);
        require(FEECOLLECTOR_ADDRESS != address(0) && token_.ownerOf(tokenId_) == address(this));
        token_.safeTransferFrom(address(this), FEECOLLECTOR_ADDRESS, tokenId_);
    }
    function withdrawERC1155(address tokenAddress_, uint256 tokenId_, uint256 amount_) external onlyOwner {
        IERC1155 token_ = IERC1155(tokenAddress_);
        require(FEECOLLECTOR_ADDRESS != address(0) && token_.balanceOf(address(this), tokenId_) >= amount_ && amount_ > 0);
        token_.safeTransferFrom(address(this), FEECOLLECTOR_ADDRESS, tokenId_, amount_, "");
    }
    function withdrawETHFixed(uint256 withdrawAmount_) external onlyOwner {
        address _feeCollector = FEECOLLECTOR_ADDRESS;
        require(_feeCollector != address(0));
        payable(_feeCollector).transfer(withdrawAmount_);
        if (balance >= withdrawAmount_) balance -= withdrawAmount_;
        else balance = 0;
        emit E_A_TransferSent(address(this), _feeCollector, withdrawAmount_);
    }
    function withdrawETH(uint256 withdrawAmount_) external onlyOwner {
        require(FEECOLLECTOR_ADDRESS != address(0) && withdrawAmount_ <= balance, "Insufficient funds");
        payable(FEECOLLECTOR_ADDRESS).transfer(withdrawAmount_);
        balance -= withdrawAmount_;
        emit E_A_TransferSent(address(this), FEECOLLECTOR_ADDRESS, withdrawAmount_);
    }
    function transferERC20(address tokenAddress_, uint256 amount) external onlyOwner {
        require(FEECOLLECTOR_ADDRESS != address(0));
        IERC20 token_ = IERC20(tokenAddress_);
        uint256 erc20balance = token_.balanceOf(address(this));
        require(amount <= erc20balance, "balance is low");
        token_.transfer(FEECOLLECTOR_ADDRESS, amount);
        emit E_A_TransferSent(address(this), FEECOLLECTOR_ADDRESS, amount);
    }
    function transferERC20_(IERC20 token_, address to_, uint256 amount_) private {
        uint256 erc20balance = token_.balanceOf(address(this));
        require(amount_ <= erc20balance, "balance is low");
        bool success_ = token_.transfer(to_, amount_);
        require(success_);
        emit E_A_TransferSent(address(this), to_, amount_);
    }

// *** MODIFIERS ***
    modifier onlyOwner() {
        require(owner_ == msg.sender);
        _;
    }
    modifier onlyOwnerOrWhitelisted() {
        require(eternalStorage.GET_WALLET_DATA_BOOL(msg.sender, 0, 1));
        _;
    }
    modifier canWithdraw(address addr_) {
        require(CAN_WITHDRAW && !_G_IsActionOrBlacklisted_(addr_) && eternalStorage.GET_WALLET_DATA_UINT256(addr_, 0, 0) >= DECIMALS_18);
        eternalStorage.SET_WALLET_DATA_BOOL(addr_, 0, 3, true);
        _;
        eternalStorage.SET_WALLET_DATA_BOOL(addr_, 0, 3, false);
    }

// *** EVENTS ***
    event E_A_WITHDRAW_AOW(address indexed addr_, uint256 value_);
    event E_A_TransferReceived(address indexed from_, uint256 amount_);
    event E_A_TransferSent(address indexed from_, address indexed to_, uint256 amount_);
}