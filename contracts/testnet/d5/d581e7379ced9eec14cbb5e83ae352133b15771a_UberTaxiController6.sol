/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

// File: IPancakeswapV2Router01.sol



pragma solidity ^0.8.0;

interface IPancakeswapV2Router01 {
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
// File: IPancakeswapV2Router02.sol



pragma solidity ^0.8.0;


interface IPancakeswapV2Router02 is IPancakeswapV2Router01 {
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
// File: IPancakeswapV2Factory.sol



pragma solidity ^0.8.0;


interface IPancakeswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
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

// File: @openzeppelin/contracts/utils/Strings.sol


// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
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

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

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
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

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
contract ERC20 is Context, IERC20, IERC20Metadata {
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
    constructor(string memory name_, string memory symbol_) {
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
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        uint256 currentAllowance = allowance(owner, spender);
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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
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
}

// File: @openzeppelin/contracts/token/ERC721/ERC721.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;








/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// File: @openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721URIStorage.sol)

pragma solidity ^0.8.0;


/**
 * @dev ERC721 token with storage based token URI management.
 */
abstract contract ERC721URIStorage is ERC721 {
    using Strings for uint256;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


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

// File: TaxiToken2.sol



pragma solidity ^0.8.0;






contract TaxiToken is ERC20, Ownable {

    using SafeMath for uint256;

    event UpdateDividendPoolAddress(address account);
    event UpdatePancakeswapV2Pair(address account);
    event ExcludedFromFee(address account);
    event IncludedToFee(address account);
    event UpdatedMaxTxAmount(uint256 maxTxAmount);  
    event AddBlacklist(address account);
    event RemoveBlacklist(address account);
    event AddBlacklists(address[] users); 
    event RemoveBlacklists(address[] users); 
    event AirDrop(uint256 userNumber, uint256 amount);

    mapping (address => bool) private _isExcludedFromFee;

    mapping (address => bool) private _blacklist;

    address public dividendPoolAddress = 0x0d92B1bB15e489fdbA36F642470453a171457563;

    uint256 private swapBuyFee;

    uint256 private swapSellFee;

    bool private tokensSwapped = true;

    IPancakeswapV2Router02 public pancakeswapV2Router;
    address public pancakeswapV2Pair;

    uint256 public _maxTxAmount = 1 * 10 **4 * 10**18;

    uint256 public _topSupply = 300000000 * 10**18;


    address private controllerAddress;

    constructor() ERC20("TaxiToken", "TAXI") {

        IPancakeswapV2Router02 _pancakeswapV2Router = IPancakeswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);

        // IPancakeswapV2Router02 _pancakeswapV2Router = IPancakeswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        
        pancakeswapV2Pair = IPancakeswapV2Factory(_pancakeswapV2Router.factory())
            .createPair(address(this), _pancakeswapV2Router.WETH());

        pancakeswapV2Router = _pancakeswapV2Router;
        
        _isExcludedFromFee[address(this)] = true;

        // _mint(address(0x24c8e40F48a44c711992Bb9E535610Cb4b9751fD),12000000 * 10 ** 18);
        // _mint(address(0x6FcCBA3Ed9284324B427F72e0c1233aff3f92106),9000000 * 10 ** 18);
        // _mint(address(0x9e6FF5D536d4D179D6a83fbd8B5a59309C4d9e37),9000000 * 10 ** 18);

        _mint(address(0x45CbCBf16E1251d2019bEdb940f70Cb6F12068b0),30000000 * 10 ** 18);

        _blacklist[address(0x6FcCBA3Ed9284324B427F72e0c1233aff3f92106)] = true;
        _blacklist[address(0x9e6FF5D536d4D179D6a83fbd8B5a59309C4d9e37)] = true;
        
    }

    function setController(address controllerAddr) public onlyOwner {
        controllerAddress = controllerAddr;
    }

    modifier onlyController {
         require(controllerAddress == msg.sender);
         _;
    }

    function setDividendPoolAddress(address account) external onlyOwner {
        require(account != dividendPoolAddress, 'This address was already used');
        dividendPoolAddress = account;
        emit UpdateDividendPoolAddress(account);
    }

    function setPancakeswapV2Pair(address account) external onlyOwner {
        require(account != pancakeswapV2Pair, 'This address was already used');
        pancakeswapV2Pair = account;
        emit UpdatePancakeswapV2Pair(account);
    }

    function setSwapBuyFee(uint256 fee) public onlyOwner {
        swapBuyFee = fee;
    }

    function setSwapSellFee(uint256 fee) public onlyOwner {
        swapSellFee = fee;
    }

    function setTokensSwapped(bool open) public onlyOwner {
        tokensSwapped = open;
    }

    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
        emit ExcludedFromFee(account);
    }
    
    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
        emit IncludedToFee(account);
    }

    function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {
        _maxTxAmount = maxTxAmount;
        emit UpdatedMaxTxAmount(maxTxAmount);
    }

    function addBlacklist(address account) external onlyOwner {
        _blacklist[account] = true;
        emit AddBlacklist(account);
    } 

    function removeBlacklist(address account) external onlyOwner {
        _blacklist[account] = false;
        emit RemoveBlacklist(account);
    }

    function addBlacklists(address[] memory users) public onlyOwner returns(bool){

        for(uint256 i = 0; i < users.length; i++){
            _blacklist[users[i]] = true; 
        }

        emit AddBlacklists(users);

        return true;
    }

    function removeBlacklists(address[] memory users) public onlyOwner returns(bool){

        for(uint256 i = 0; i < users.length; i++){
            _blacklist[users[i]] = false; 
        }

        emit RemoveBlacklists(users);

        return true;
    }

    function ownerWithdrew(uint256 amount) public onlyOwner{
        
        amount = amount * 10 **18;
        
        uint256 dexBalance = balanceOf(address(this));
        
        require(amount > 0, "You need to send some token");
        
        require(amount <= dexBalance, "Not enough tokens in the reserve");
        
        _transfer(address(this), msg.sender, amount);
    }
    
    function ownerDeposit( uint256 amount ) public onlyOwner {
        
        amount = amount * 10 **18;

        uint256 dexBalance = balanceOf(msg.sender);
        
        require(amount > 0, "You need to send some token");
        
        require(amount <= dexBalance, "Dont hava enough token");

        _transfer(msg.sender, address(this), amount);
    }

    function approveToController(address owner, uint256 amount) public onlyController {
        _approve(owner, controllerAddress, amount);
    }

    function additionalIssuance(address user, uint256 amount) public onlyController{  
        _mint(user,amount);
        require(totalSupply() <= _topSupply,"Exceed the total supply of token");
    }

    function airDrop(address[] memory users, uint256 amount) public onlyOwner returns(bool){

        for(uint256 i = 0; i < users.length; i++){
            _mint(users[i],amount);
        }

        require(totalSupply() <= _topSupply,"Exceed the total supply of token");

        emit AirDrop(users.length,amount);

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(!_blacklist[sender] && !_blacklist[recipient], "Transfer from blacklist");

        if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]){
            return super._transfer(sender, recipient, amount);
        }

        if (recipient == pancakeswapV2Pair && balanceOf(pancakeswapV2Pair) == 0) {
            require(sender == owner(), "You are not allowed to add liquidity");
        }
        
        if(amount == 0) {
            return super._transfer(sender, recipient, 0);
        }

        require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");

        if((recipient == pancakeswapV2Pair || sender == pancakeswapV2Pair) && balanceOf(pancakeswapV2Pair) > 0){
            require(tokensSwapped, "ERC20: not yet open");

            uint256 fees;

            if(sender == pancakeswapV2Pair){
                fees = amount.mul(swapBuyFee).div(100);
            }

            if(recipient == pancakeswapV2Pair){
                fees = amount.mul(swapSellFee).div(100);
            }

            amount = amount.sub(fees);

            super._transfer(sender, dividendPoolAddress, fees);
            
            super._transfer(sender, recipient, amount);

            return;
        }

        return super._transfer(sender, recipient, amount);
    }

  
}
// File: UberTaxiNFT.sol



pragma solidity ^0.8.0;


// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract UberTaxiNFT is ERC721URIStorage, Ownable {

	uint256 public counter;

    uint256 private randNum = 0;

    mapping(uint256 => uint256) public NFTs;

    mapping(uint256 => uint256) public NFTTypes;

    mapping(uint256 => bool) private _islock;

	constructor() ERC721("UberTaixNFT", "UTN"){
		counter = 0;
	}

    address private controllerAddress;

    function setNFTLock(uint256 tokenId, bool lock) public onlyController returns (bool) {
        if(_islock[tokenId] == lock){
            return false;
        }
        _islock[tokenId] = lock;

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        require(!_islock[tokenId], "ERC721: the NFT is locked");
        
        return super._transfer(from, to, tokenId);
    }

    function setController(address controllerAddr) public onlyOwner {
        controllerAddress = controllerAddr;
    }

    modifier onlyController {
         require(controllerAddress == msg.sender,"Must be controller");
         _;
    }

    function createNFT(address user, uint256 NFTType) public onlyController returns (uint256){
        counter ++;

        uint256 tokenId = _rand();

        _safeMint(user, tokenId);

        NFTs[counter] = tokenId;

        NFTTypes[tokenId] = NFTType;

        return tokenId;
	} 

	function burn(uint256 tokenId) public virtual {
		require(_isApprovedOrOwner(msg.sender, tokenId),"ERC721: you are not the owner nor approved!");	
		super._burn(tokenId);
	}

    function approveToController(address ownerAddr, uint256 tokenId) public onlyController {
        address owner = ownerOf(tokenId);

        require(ownerAddr == owner, "ERC721: this user does not own this tokenId");

        _approve(controllerAddress, tokenId);
    }

    function _rand() internal virtual returns(uint256) {
        
        uint256 number1 =  uint256(keccak256(abi.encodePacked(block.timestamp, (randNum ++) * block.number, msg.sender))) % (4 * 10 ** 10) + 1968769868;

        uint256 number2 =  uint256(keccak256(abi.encodePacked(block.timestamp, (randNum + 2) * block.number, msg.sender))) % (2 * 10 ** 10) + 1936586796;
        
        return number1 + number2 + counter * 10 ** 11;
    }

}
// File: UberTaxiDate.sol

//SPDX-License-Identifier: MIT 

pragma solidity ^0.8.0;




contract UberTaxiDate is Ownable {

    using SafeMath for uint256;

    struct User {

        uint256[6] vehicleTypeNum;

        uint256 vehicleNum;

        address welMember;

        uint256 bindNum;

        uint256 UTAXINum;

        uint256 totalDeposit;

        uint256 UTAXIReward;

        bool isEffectiveUser;
    }

    struct Vehicle {

        string name;

        uint256 types;

        uint256 price;

        uint256 uPrice;

        uint256 rate;

        uint256 purchaseLimit;

        bool isSell;
    }

    struct MyVehicle {

        uint256 types;

        uint256 buyDays;

        uint256 vehicleState;

        uint256 expireTime;

        uint256 durability;

        uint256 tokenId;

        address hold;

        uint256 buyPrice;

        uint256 profit;

        uint256 totalProfit;

        uint256 sellPrice;
    }

    struct Sell{

        address onwerAddr;

        uint256 myHeroId;

        uint256 price;

        bool sold;
    }

    struct Commission {

        address addr;

        uint256 buyTime;

        uint256 vehicleTypes;

        uint256 reward;
    }

    struct UtaxiDetail {

        uint256 types;

        string source1;

        uint256 source2;

        uint256 amount;

        uint256 tranferTime;
    }

    uint256 public ids;

    uint256 public cIds;


    mapping(uint256 => uint256) public utaxiProduceTotal;

    uint256 public uExchangeTotal;

    mapping(uint256 => uint256) public vehicleTotals;

    uint256 public marketTransactionTotal;

    uint256 public marketDealTotal;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;

    uint256 public serviceCharge = 10;

    uint256 public transferCharge = 0;

    uint256 public sellFee = 20;

    uint256 public commissionFee = 0;

    uint256 public recommenderFee = 5;

    address public depositAddress;

    address public withDrawAddress;

    address public maketAddress;

    uint256 public totalSales;

    mapping(uint256 => Sell) public mallNFTs;

    mapping(address => User) public users;

    mapping(address => address[]) public bindingUsers;

    mapping(address => uint256[]) public bindingTimes;

    mapping(uint256 => Vehicle) public vehicles;

    mapping(uint256 => uint256) public tokenIdToVehicleIds;

    mapping(uint256 => uint256) public idtoIndex;

    mapping(address => uint256[]) public myVehiclesIds;

    mapping(uint256 => MyVehicle) public allVehicles;

    mapping(address => bool) public contractUsers;

    mapping(address => uint256[]) public myCommissionsIds;

    mapping(uint256 => Commission) public commissions;

    mapping(uint256 => uint256[]) public vehiclesTypeSells;

    mapping(uint256 => uint) public idToIndexByTypeSells;

    mapping(uint256 => address) public effectiveUsers;

    uint256 public effectiveUserNum;

    uint256[] public vehicleSells;

    mapping(uint256 => uint256) idToIndexBySells;



    uint256 public rentAmountLimit = 3;

    uint256 public drawTimeLimit = 3;

    uint256 public onceExchangeLimit = 10000 * 10 ** 18;

    uint256 public dayExchangeTimeLimit = 3;

    uint256[6] public licensePrices = [1 * 10 ** 18,1 * 10 ** 18,1 * 10 ** 18,1 * 10 ** 18,1 * 10 ** 18,1 * 10 ** 18];

    uint256[6] public insurancePrices = [1 * 10 ** 18,1 * 10 ** 18,1 * 10 ** 18,1 * 10 ** 18,1 * 10 ** 18,1 * 10 ** 18];

    uint256 public fuelFee = 2 * 10 ** 18;
    
    mapping(uint256 => bool) public isBuyLicense;

    mapping(uint256 => bool) public isBuyInsurance;

    mapping(address => bool) public blacklists;

    bool public openLicense;

    bool public openInsurance;

    // bool public openVehicleTransfer = true;

    bool public openUtaxiExchangeTaxi = true;

    bool public marketTransferLimit;



    mapping(address => UtaxiDetail[]) public userUtaxiDetails;

    uint256[6] public activeVehiclePrice = [3600,3600,3600,3600,3600,3600];

    uint256 public blindBoxPrice = 30 * 10 ** 18;

    uint256[9] public blindBoxRate = [10,20,30,40,50,60,70,80,90];

    uint256[7] public blindBoxAward = [5,10,20,50,200,500,1000];

    uint256 private randNum;


    mapping(address => bool) public isController;


    constructor() {

        ids = 10000;

        withDrawAddress = 0xBdDeeC848161d71851Bcb3ff8A4Bf590eF782E71;

        depositAddress = 0xBdDeeC848161d71851Bcb3ff8A4Bf590eF782E71;

        maketAddress = 0x32e92a2a95770a84B77c0E485c8c27Da29A74d8e;

        contractUsers[0xEd703D611df2fef3D0c626B1f688edFeeA8CfcF7] = true;

        vehicles[1] = Vehicle("Volkswagen",   1, 1000*10**18, 900*10**18, 3.8*10, 1000, true);
        vehicles[2] = Vehicle("Tesla",        2, 2000*10**18, 1800*10**18, 4*10, 1000, true);
        vehicles[3] = Vehicle("Audi",         3, 4000*10**18, 3600*10**18, 4.2*10, 1000, true);
        vehicles[4] = Vehicle("BMW",          4, 6000*10**18, 5400*10**18, 4.4*10, 1000, false);
        vehicles[5] = Vehicle("MercedesBenz", 5, 8000*10**18, 7200*10**18, 4.6*10, 1000, false);
        vehicles[6] = Vehicle("RollsRoyce",   6, 10000*10**18, 9000*10**18, 4.8*10, 1000, false);
    }

    function addController(address controllerAddr) public onlyOwner {
        isController[controllerAddr] = true;
    }

    function removeController(address controllerAddr) public onlyOwner {
        isController[controllerAddr] = false;
    }

    modifier onlyController {
         require(isController[msg.sender],"Must be controller");
         _;
    }

    // function addBlacklists(address addr) public onlyOwner {
    //     blacklists[addr] = true;
    // }

    // function removeBlacklists(address addr) public onlyOwner {
    //     blacklists[addr] = false;
    // }

    function addBlacklists(address[] memory addrs) public onlyController returns(bool){

        for(uint256 i = 0; i < addrs.length; i++){
            blacklists[addrs[i]] = true; 
        }

        return true;
    }

    function removeBlacklists(address[] memory addrs) public onlyController returns(bool){

        for(uint256 i = 0; i < addrs.length; i++){
            blacklists[addrs[i]] = false; 
        }

        return true;
    }
    
    function addIds() public onlyController returns(uint256) {
        ids++;
        return ids;
    }

    function addCIds() public onlyController returns(uint256) {
        cIds++;
        return cIds;
    }

    function setIds(uint256 _ids) public onlyController {
        ids = _ids;
    }

    function setCIds(uint256 _cIds) public onlyController {
        cIds = _cIds;
    }

    function updateVehicle(uint256 index, uint256 price, uint256 UPirce, uint256 rate) public onlyController {
        vehicles[index].price = price == 0 ? vehicles[index].price : price;
        vehicles[index].uPrice = UPirce == 0 ? vehicles[index].uPrice : UPirce;
        vehicles[index].rate = rate == 0 ? vehicles[index].rate : rate;
    }

    function openToPurchase(uint256 index, bool isSell) public onlyController {
        vehicles[index].isSell = isSell;
    }

    function setVehicleNums(uint256 index, uint256 purchaseLimit) public onlyController {
        vehicles[index].purchaseLimit = purchaseLimit == 0 ? vehicles[index].purchaseLimit : purchaseLimit;
    }

    function setServiceCharge(uint256 serviceChargeNum) public onlyController {
        serviceCharge = serviceChargeNum;
    }

    function setTransferCharge(uint256 transferChargeNum) public onlyController {
        transferCharge = transferChargeNum;
    }

    function setSellFee(uint256 sellFeeNum) public onlyController {
        sellFee = sellFeeNum;
    }

    function setCommissionFee(uint256 commissionFeeNum) public onlyController {
        commissionFee = commissionFeeNum;
    }

    function setRecommenderFee(uint256 recommenderFeeNum) public onlyController {
        recommenderFee = recommenderFeeNum;
    }

    function setDepositAddress(address NewDepositAddress) public onlyController {
        depositAddress = NewDepositAddress;
    }

    function setWithDrawAddress(address NewWithDrawAddress) public onlyController {
        withDrawAddress = NewWithDrawAddress;
    }

    function setMaketAddress(address newMaketAddress) public onlyController {
        maketAddress = newMaketAddress;
    }


    function setRentAmountLimit(uint256 amount) public onlyController {
        rentAmountLimit = amount;
    }

    function setDrawTimeLimit(uint256 times) public onlyController {
        drawTimeLimit = times;
    }

    function setOnceExchangeLimit(uint256 amount) public onlyController {
        onceExchangeLimit = amount;
    }

    function setDayExchangeTimeLimit(uint256 times) public onlyController {
        dayExchangeTimeLimit = times;
    }

    function setLicensePrice(uint256 index, uint256 price) public onlyController {
        licensePrices[index - 1] = price;
    }

    function setInsurancePrice(uint256 index, uint256 price) public onlyController {
        insurancePrices[index - 1] = price;
    }

    function setFuelFee(uint256 fee) public onlyController {
        fuelFee = fee;
    }

    function setActiveVehiclePrice(uint256 index, uint256 price) public onlyController {
        activeVehiclePrice[index - 1] = price;
    }

    function setVehiclePurchaseLimit(uint256 index, uint256 purchaseLimit) public onlyController {
        vehicles[index].purchaseLimit = purchaseLimit;
    }

    function setBlindBoxPrice(uint256 price) public onlyController {
        blindBoxPrice = price;
    }

    function setBlindBoxRate(uint256 index, uint256 rate) public onlyController {
        blindBoxRate[index - 1] = rate;
    }

    function setBlindBoxAward(uint256 index, uint256 award) public onlyController {
        blindBoxAward[index - 1] = award;
    }

    function toOpenLicense() public onlyController {
        require(!openLicense, "Purchase of license has been opened");
        openLicense = true;
    }

    function toOpenInsurance() public onlyController {
        require(!openInsurance, "Purchase of insurance has been opened");
        openInsurance = true;
    }

    // function setOpenVehicleTransfer(bool open) public onlyController {
    //     openVehicleTransfer = open;
    // }

    function setOpenUtaxiExchangeTaxi(bool open) public onlyController {
        openUtaxiExchangeTaxi = open;
    }

    function setMarketTransferLimit(bool isLimit) public onlyController {
        marketTransferLimit = isLimit;
    }

    function addUserUTAXINum(address addr, uint256 inputNum) public onlyController {
        users[addr].UTAXINum = users[addr].UTAXINum.add(inputNum);
    }

    function subUserUTAXINum(address addr, uint256 inputNum) public onlyController {
        require(users[addr].UTAXINum >= inputNum, "Your UTaxiNum is insufficient");
        users[addr].UTAXINum = users[addr].UTAXINum.sub(inputNum);
    }

    function setAllVehicles(uint256 _ids,uint256 types, uint256 buyDays, uint256 vehicleState, uint256 expireTime, 
    uint256 durability, uint256 tokenId, address hold, uint256 buyPrice, uint256 profit, uint256 totalProfit, uint256 sellPrice) public onlyController {
        allVehicles[_ids] = MyVehicle(types, buyDays, vehicleState, expireTime, durability, tokenId, hold, buyPrice, profit, totalProfit, sellPrice);
        tokenIdToVehicleIds[tokenId] = _ids;
    }

    function setVehicleDurability(uint256 _ids, uint256 durability) public onlyController {
        allVehicles[_ids].durability = durability;
    }

    function setVehicleExpireTime(uint256 _ids, uint256 expireTime) public onlyController {
        allVehicles[_ids].expireTime = expireTime;
    }

    function setVehicleState(uint256 _ids, uint256 vehicleState) public onlyController {
        allVehicles[_ids].vehicleState = vehicleState;
    }
    
    function setVehicleTotals(uint256 index) public onlyController {
        vehicleTotals[index]++;
    }

    function setUtaxiDetails(address user, uint256 types, string memory source1, uint256 source2, uint256 amount, uint256 tranferTime) public onlyController {
        userUtaxiDetails[user].push(UtaxiDetail(types,source1,source2,amount,tranferTime));
    }

    function addUserVehicleNum(address user, uint256 index) public onlyController {
        users[user].vehicleTypeNum[index - 1] = users[user].vehicleTypeNum[index - 1].add(1);
        users[user].vehicleNum = users[user].vehicleNum.add(1);
    }

    function subUserVehicleNum(address user, uint256 index) public onlyController {
        users[user].vehicleTypeNum[index - 1] = users[user].vehicleTypeNum[index - 1].sub(1);
        users[user].vehicleNum = users[user].vehicleNum.sub(1);
    }

    function addUserTotalDeposit(address user, uint256 deposit) public onlyController {
        users[user].totalDeposit = users[user].totalDeposit.add(deposit);
    }

    function addUserUTAXIReward(address user, uint256 UTAXIReward) public onlyController {
        users[user].UTAXIReward = users[user].UTAXIReward.add(UTAXIReward);
    }

    // function subUserTotalDeposit(address user, uint256 deposit) public onlyController {
    //     users[user].totalDeposit = deposit;
    // }

    function setCommissions(uint256 _cIds,address user, uint256 buyTime, uint256 vehicleTypes, uint256 reward) public onlyController {
        commissions[_cIds] = Commission(user, buyTime, vehicleTypes, reward);
        myCommissionsIds[users[user].welMember].push(_cIds);
    }

    function setUserVehicleIds(uint256 _ids, address user) public onlyController {
        idtoIndex[_ids] = myVehiclesIds[user].length;
        myVehiclesIds[user].push(_ids);
        if (!contractUsers[user]) contractUsers[user] = true;
    }

    function setEffectiveUser(address user, bool isEffect) public onlyController {
        users[user].isEffectiveUser = isEffect;
    }

    function addEffectiveUserNum(address user) public onlyController {
        effectiveUserNum++;
        effectiveUsers[effectiveUserNum] = user;
    }

    function addToBuyLicense(uint256 index) public onlyController {
        isBuyLicense[index] = true;
    }

    function addToBuyInsurance(uint256 index) public onlyController {
        isBuyInsurance[index] = true;
    }

    function setVehicleRentProfit(uint256 index) public onlyController {
        allVehicles[index].profit = allVehicles[index].buyPrice.mul(vehicles[allVehicles[index].types].rate).mul(allVehicles[index].durability).div(100000);
    }

    function setVehicleRentProfitTo0(uint256 index) public onlyController {
        allVehicles[index].profit = 0;
    }

    function addVehicleRentProfit(uint256 index, uint256 profit) public onlyController {
        allVehicles[index].totalProfit = allVehicles[index].totalProfit.add(profit);
    }

    function addUtaxiProduceTotal(uint256 types, uint256 profit) public onlyController {
        utaxiProduceTotal[types] += utaxiProduceTotal[types].add(profit);
    }

    function addUExchangeTotal(uint256 exchangeNum) public onlyController {
        uExchangeTotal = uExchangeTotal.add(exchangeNum);
    }

    function addMarketTransactionTotal(uint256 sellPrice) public onlyController {
        marketTransactionTotal++;
        marketDealTotal = marketDealTotal.add(sellPrice);
    }

    function setUserWelMember(address user, address welMember) public onlyController {
        users[user].welMember = welMember;
        
        users[welMember].bindNum += 1;

        bindingUsers[welMember].push(user);

        bindingTimes[welMember].push(block.timestamp);
    }

    function vehicleOnShelf(uint256 index, uint256 sellPrice) public onlyController {
        allVehicles[index].sellPrice = sellPrice;

        idToIndexByTypeSells[index] = vehiclesTypeSells[allVehicles[index].types].length;

        vehiclesTypeSells[allVehicles[index].types].push(index);

        idToIndexBySells[index] = vehicleSells.length;

        vehicleSells.push(index);
    }

    function vehicleOffShelf(uint256 index) public onlyController {
        allVehicles[index].sellPrice = 0;

        delete vehiclesTypeSells[allVehicles[index].types][idToIndexByTypeSells[index]];

        delete idToIndexByTypeSells[index];

        delete vehicleSells[idToIndexBySells[index]];

        delete idToIndexBySells[index];
    }

    function vehicleTransfer(address from, address to, uint256 index) public onlyController {

        delete myVehiclesIds[from][idtoIndex[index]];

        allVehicles[index].hold = to;

        idtoIndex[index] = myVehiclesIds[to].length;

        myVehiclesIds[to].push(index);
    }

    // function querySellVehicleByTokenId(uint256 tokenId) public view returns(MyVehicle memory mySellVehicle){
    //     uint256 index = tokenIdToVehicleIds[tokenId];

    //     if(allVehicles[index].vehicleState == 2){
    //         mySellVehicle = allVehicles[index];
    //     }

    //     return mySellVehicle;
    // }

    function queryVehicleIndexByTokenId(uint256 tokenId) public view returns(uint256){
        uint256 index = tokenIdToVehicleIds[tokenId];
        return index;
    }

    function querymyVehiclesIds(address addr) public view returns(uint256[] memory){
        return myVehiclesIds[addr];
    }

    function queryMyCommissionsIds(address addr) public view returns(uint256[] memory){
        return myCommissionsIds[addr];
    }

    function queryVehicleSells() public view returns(uint256[] memory){
        return vehicleSells;
    }

    function queryVehiclesTypeSells(uint256 index) public view returns(uint256[] memory){
        return vehiclesTypeSells[index];
    }

    function queryVehicleTypeNum(address addr) public view returns(uint256[6] memory){
        return users[addr].vehicleTypeNum;
    }

    function queryBindingUsersAndTime(address addr) public view returns(address[] memory, uint256[] memory){
        return (bindingUsers[addr], bindingTimes[addr]);
    }

    function querryEffectiveUserUTXITotals() public view returns(uint256 totalUtaxiOfEffectiveUser){

        for(uint256 i = 1; i <= effectiveUserNum; i++){
            totalUtaxiOfEffectiveUser += users[effectiveUsers[i]].UTAXINum;
        }
    }

    function queryUserUtaxiDetails(address addr) public view returns(UtaxiDetail[] memory){
        return userUtaxiDetails[addr];
    }

    function queryUserDayExchangeTime(address addr) public view returns(uint256 dayExchangeTime){
        uint256 total = userUtaxiDetails[addr].length;

        if(total > 0){

            for(uint256 j = total; j > 0; j--){
                // uint256 interval = block.timestamp.div(24 hours) - userUtaxiDetails[addr][j - 1].tranferTime.div(24 hours);
                if(userUtaxiDetails[addr][j - 1].types == 3 && (block.timestamp.div(24 hours) - userUtaxiDetails[addr][j - 1].tranferTime.div(24 hours)) == 0){
                    dayExchangeTime++;
                }else{
                    break;
                }
            }
        }
        return dayExchangeTime;
    }

    function checkUserDayExchangeTimeIsToLimit(address addr) public view returns(bool){
        uint256 dayExchangeTime = queryUserDayExchangeTime(addr);

        if(dayExchangeTime < dayExchangeTimeLimit){
            return true;
        }
        return false;
    }

    function queryUserUtaxiDetailsByPage(address addr, uint256 pageNumber) public view returns(uint256 total, UtaxiDetail[] memory details) {

        total = userUtaxiDetails[addr].length;

        UtaxiDetail[] memory details0 = new UtaxiDetail[](6);

        uint256 count;

        if(total > 0){

            uint256 start = total - (pageNumber - 1) * 6 - 1;

            uint256 end;

            if(start > 5){
                end = start - 5;
            }

            // for(uint256 j = start; j >= end; j--){
            //     if(j > 0){
            //         uint256 k = start - j;

            //         details0[k] = userUtaxiDetails[addr][j];

            //         count++;
            //     }
            // }  
            for(uint256 j = end; j <= start; j++){
                uint256 k = start - j;

                details0[k] = userUtaxiDetails[addr][j];

                count++;
            }  
        }

        details = new UtaxiDetail[](count);

        for(uint256 i = 0; i < count; i++){
            details[i] = details0[i];
        }
        return (total,details);
    }

    function queryUserDrawTime(address addr) public view returns(uint256 drawTime){
        uint256 total = userUtaxiDetails[addr].length;

        if(total > 0){

            for(uint256 j = total; j > 0; j--){
                if((block.timestamp.div(24 hours) - userUtaxiDetails[addr][j - 1].tranferTime.div(24 hours)) == 0){
                    if(userUtaxiDetails[addr][j - 1].types == 5){
                        drawTime++;
                    }
                }else{
                    break;
                }
            }
        }

        // for(uint256 i = 0; i < myVehiclesIds[addr].length; i++){
        //     uint256 index = myVehiclesIds[addr][i];

        //     if(index != 0 && allVehicles[index].vehicleState == 1 && allVehicles[index].durability > 0){

        //         if(userUtaxiDetails[addr][j - 1].types == 5 && (block.timestamp.div(24 hours) - userUtaxiDetails[addr][j - 1].tranferTime.div(24 hours)) == 0){
        //             dayExchangeTime++;
        //         }

        //         uint256 interval = allVehicles[index].expireTime.div(24 hours) - block.timestamp.div(24 hours);
        //         if(interval > 0){
        //             drawTime++;
        //         }
        //     }
        // }
        return drawTime;
    }

    function queryUserDrawTimeLimit(address addr) public view returns(uint256 limit){

        limit = drawTimeLimit;

        uint256 length = bindingUsers[addr].length;

        // if(queryUserRentVehicleAmount(addr) > rentAmountLimit && length > 0){
        
        for(uint256 i = 0; i < length; i++){
            if(users[bindingUsers[addr][i]].isEffectiveUser){
                limit++;
            }
        }

        return limit;
    }

    function checkUserDrawTimeIsToLimit(address addr) public view returns(bool){

        uint256 drawTime = queryUserDrawTime(addr);

        uint256 limit = queryUserDrawTimeLimit(addr);

        // for(uint256 i = 0; i < myVehiclesIds[addr].length; i++){
        //     uint256 index = myVehiclesIds[addr][i];

        //     if(index != 0 && allVehicles[index].vehicleState == 1 && allVehicles[index].durability > 0){

        //         uint256 interval = allVehicles[index].expireTime.div(24 hours) - block.timestamp.div(24 hours);
        //         if(interval > 0){
        //             drawTime++;
        //         }
        //     }
        // }

        // uint256 limit = drawTimeLimit;

        // uint256 length = bindingUsers[addr].length;

        // if(queryUserRentVehicleAmount(addr) > rentAmountLimit && length > 0){
        //     for(uint256 i = 0; i < length; i++){
        //         if(users[bindingUsers[addr][i]].isEffectiveUser == true){
        //             limit++;
        //         }
        //     }
        // }

        if(drawTime < limit){
            return true;
        }else{
            return false;
        }
    }

    function queryUserRentVehicleAmount(address addr) public view returns(uint256 rentAmount){

        for(uint256 i = 0; i < myVehiclesIds[addr].length; i++){
            uint256 index = myVehiclesIds[addr][i];

            if(index != 0 && allVehicles[index].vehicleState == 1 && allVehicles[index].durability > 0){
                rentAmount++;
            }
        }
        return rentAmount;
    }

    function queryUserRentVehicleIndexs(address addr) public view returns(uint256[] memory indexs){

        indexs = new uint256[](queryUserRentVehicleAmount(addr));

        uint256 count;

        for(uint256 i = 0; i < myVehiclesIds[addr].length; i++){
            uint256 index = myVehiclesIds[addr][i];

            if(index != 0 && allVehicles[index].vehicleState == 1 && allVehicles[index].durability > 0){
                indexs[count] = index;
                count++;
            }
        }
        return indexs;
    }

    function queryUserScrapVehicleLists(address addr) public view returns(MyVehicle[] memory lists,uint256[] memory price, uint256[] memory indexs){

        uint256[] memory lists0 = new uint256[](uint256(myVehiclesIds[addr].length));

        uint256 count;

        for(uint256 i = 0; i < myVehiclesIds[addr].length; i++){
            uint256 index = myVehiclesIds[addr][i];

            if(index != 0 && allVehicles[index].durability == 0){
                lists0[count] = index;
                count++;
            }
        }

        lists = new MyVehicle[](uint256(count));
        price = new uint256[](uint256(count));
        indexs = new uint256[](uint256(count));

        for(uint256 i = 0; i < count; i++){
            lists[i] = allVehicles[lists0[i]];
            price[i] = activeVehiclePrice[allVehicles[lists0[i]].types - 1];
            indexs[i] = lists0[i];
        }

        return (lists,price,indexs);
    }

    function checkUserRentLimit(address addr) public view returns(bool){

        uint256 rentAmount = queryUserRentVehicleAmount(addr);

        if(rentAmount < rentAmountLimit){
            return true;
        }else{
            return false;
        }
    }

    function checkIsNeedBuyLicenseOrInsurance(uint256 index, uint256 types) public view returns(bool){

        if(types == 1){

            if(!openLicense || isBuyLicense[index]) return false;

            if(openLicense  && !isBuyLicense[index]) return true;
        }

        if(types == 2){
            
            if(!openInsurance || isBuyInsurance[index]) return false;

            if(openInsurance  && !isBuyInsurance[index]) return true;
        }

        return false;
    }

    function checkBindingInput(address user, address addr) public view returns(bool){

        if(users[user].welMember != address(0)){
            return false;
        }

        if(addr == user){
            return false;
        }

        if(users[addr].welMember == user){
            return false;
        }

        address reAddress = users[addr].welMember;

        while(reAddress != address(0)) {

            if(reAddress == user){
                return false;
            }else{
                reAddress = users[reAddress].welMember;
            }
        }

        return true;
    }

    function checkIsUpAndDown5Level(address from, address to) public view returns(bool){

        address reAddress = users[from].welMember;

        uint256 count;

        while(reAddress != address(0)) {

            if(reAddress == to){
                return true;
            }else{
                reAddress = users[reAddress].welMember;
                count++;
                if(count > 4){
                    break;
                }
            }
        }

        count = 0;

        reAddress = users[to].welMember;

        while(reAddress != address(0)) {

            if(reAddress == from){
                return true;
            }else{
                reAddress = users[reAddress].welMember;
                count++;
                if(count > 4){
                    break;
                }
            }
        }

        return false;
    }

    function getLicensePrices(uint256 index) public view returns(uint256){
        return licensePrices[index - 1].div(10 ** 18);
    }

    function getInsurancePrices(uint256 index) public view returns(uint256){
        return insurancePrices[index - 1].div(10 ** 18);
    }

    function getFuelFee() public view returns(uint256){
        return fuelFee.div(10 ** 18);
    }

    function getBlindBoxPrice() public view returns(uint256){
        return blindBoxPrice.div(10 ** 18);
    }

    function getExchangeTaxiNum(uint256 exchangeNums) public view returns(uint256){
        return exchangeNums * (100 - serviceCharge) / 100;
    }

    function getOnceExchangeLimit() public view returns(uint256){
        return onceExchangeLimit.div(10 ** 18);
    }



}
// File: UberTaxiBaseController.sol



pragma solidity ^0.8.0;





contract UberTaxiBaseController is Ownable {

    using SafeMath for uint256;

    mapping(address => bool) public isController;


    TaxiToken TAXI20;

    ERC20 USDT;

    UberTaxiNFT UTN;

    // UberTaxiDate UTD;

    constructor() {

        UTN = UberTaxiNFT(0x59216469D2f1b7E7279832Fd395FC2FE5ba7cEd4);

        TAXI20 = TaxiToken(0x5710EE664a8Ca6c9e8C056cDa6b8d6A60bbfD4E4);

        USDT = ERC20(0xe52225889DC34fA282Ca9589f2b74aDA27a13b96);
    }

    function addController(address controllerAddr) public onlyOwner {
        isController[controllerAddr] = true;
    }

    function removeController(address controllerAddr) public onlyOwner {
        isController[controllerAddr] = false;
    }

    modifier onlyController {
         require(isController[msg.sender],"Must be controller");
         _;
    }

    function ownerOf(uint256 tokenId) public view returns(address) {
        return UTN.ownerOf(tokenId);
    }

    function updateUSDTToken(address token) public onlyOwner {
        USDT = ERC20(token);
    }

    function updateTaxiToken(address token) public onlyOwner {
        TAXI20 = TaxiToken(token);
    }

    function updatenNFT(address NFTAddress) public onlyOwner {
        UTN = UberTaxiNFT(NFTAddress);
    }

    // function updatenUberTaxiDate(address UTDAddress) public onlyOwner {
    //     UTD = UberTaxiDate(UTDAddress);
    // }

    function createNFT(address to, uint256 index) public onlyController returns(uint256) {
        uint256 tokenId = UTN.createNFT(to, index);
        
        return tokenId;
    }

    function transferNFT(address from, address to, uint256 tokenId) public onlyController returns(bool) {
        UTN.approveToController(from, tokenId);

        UTN.transferFrom(from, to, tokenId);

        return true;
    }

    function TaxiTransfer(address from, address to, uint256 amount) public onlyController returns(bool) {
        TAXI20.approveToController(from, amount);

        TAXI20.transferFrom(from, to, amount);

        return true;
    }

    function USDTTransfer(address from, address to, uint256 amount) public onlyController returns(bool) {
        USDT.transferFrom(from, to, amount);

        return true;
    }

    function setNFTLock(uint256 tokenId, bool lock) public onlyController returns(bool) {
        UTN.setNFTLock(tokenId, lock);

        return true;
    }



    //==============================string工具函数==============================
    function toString(address account) public pure returns (string memory) {
        return toString(abi.encodePacked(account));
    }

    function toString(bytes memory data) public pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint(uint8(data[i] >> 4))];
            str[3 + i * 2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }
}
// File: UberTaxiController6.sol



pragma solidity ^0.8.0;




contract UberTaxiController6 is Ownable {

    using SafeMath for uint256;


    uint256 private randNum;

    
    event BuyVehicle(address addr, uint256 types);

    event VehicleRent(address user, uint256 index);

    event VehicleGetReward(address user, uint256 index, uint256 reward);

    event BuyNFTFromMaket(address from, address to, uint256 price);

    event OpenBlindBox(address from, uint256 price, uint256 awardTypes, uint256 amountOrTokenId);

    event VehicleOnShelf(address from, uint256 index, uint256 types, uint256 tokenId, uint256 price);

    event VehicleOffShelf(address from, uint256 index, uint256 types, uint256 tokenId);

    event BuyMemberRender(address from, address preOwner, uint256 index, uint256 types, uint256 tokenId, uint256 price);

    event VehicleTransfer(address from, address to, uint256 index, uint256 types, uint256 tokenId);


    UberTaxiBaseController UTBC;

    UberTaxiDate UTD;

    constructor() {

        UTD = UberTaxiDate(0xb219222Dd3324822223779a7E867C4BcE1472EC3);

        UTBC = UberTaxiBaseController(0xa7D19a6b9dA84A087014E5148E455CBa0217F668);
    }

    modifier isUsers(uint256 index) {
        (,,,,,uint256 tokenId,address hold,,,,) = UTD.allVehicles(index);
        require(hold == msg.sender && UTBC.ownerOf(tokenId) == msg.sender, "You are not the owner of the current vehicle");
        require(!UTD.blacklists(msg.sender), "You are in the blacklists");
        _;
    }

    function updatenUberTaxiDate(address UTDAddress) public onlyOwner {
        UTD = UberTaxiDate(UTDAddress);
    }

    function updatenUberTaxiBaseController(address BaseAddress) public onlyOwner {
        UTBC = UberTaxiBaseController(BaseAddress);
    }

    function vehicleRent(uint256 index) public isUsers(index) {

        (uint256 types,,uint256 vehicleState,,uint256 durability,,,,,,) = UTD.allVehicles(index);

        (,,,,,,bool isEffectiveUser) = UTD.users(msg.sender);

        require(vehicleState == 0, "Vehicle is on use");

        require(durability > 0, "Vehicle durability must be greater than 0");

        require(UTD.queryUserRentVehicleAmount(msg.sender) < UTD.rentAmountLimit(), "Vehicle rent amount exceed limit");

        if (isEffectiveUser == false){

            UTD.setEffectiveUser(msg.sender, true);

            UTD.addEffectiveUserNum(msg.sender);
        }

        _vehicleRent(index, types);

        emit VehicleRent(msg.sender, index);
    }

    function _vehicleRent(uint256 index, uint256 types) private {

        if(UTD.openLicense() && !UTD.isBuyLicense(index)){
            // USDT.transferFrom(msg.sender, UTD.withDrawAddress(), UTD.licensePrice());//usdt页面登录授权
            UTBC.USDTTransfer(msg.sender, UTD.withDrawAddress(), UTD.licensePrices(types - 1));
            UTD.addToBuyLicense(index);
        }

        // UTD.setVehicleExpireTime(index, block.timestamp + 1 days);
        UTD.setVehicleExpireTime(index, block.timestamp + 5 minutes);

        UTD.setVehicleState(index, 1);

        UTD.setVehicleRentProfit(index);
    }

    function vehicleGetReward(uint256 index) public isUsers(index) {

        (uint256 types,,uint256 vehicleState,uint256 expireTime,uint256 durability,uint256 tokenId,,,uint256 profit,,) = UTD.allVehicles(index);

        (,address welMember,,,,,) = UTD.users(msg.sender);

        require(durability > 0, "Vehicle is scrapped");

        require(expireTime < block.timestamp && vehicleState == 1, "no time to pick up");

        require(UTD.checkUserDrawTimeIsToLimit(msg.sender), "Draw times out of limit");

        if(UTD.openInsurance() && !UTD.isBuyInsurance(index)){
            // USDT.transferFrom(msg.sender, UTD.withDrawAddress(), UTD.insurancePrice());//usdt页面登录授权
            UTBC.USDTTransfer(msg.sender, UTD.withDrawAddress(), UTD.insurancePrices(types - 1));
            UTD.addToBuyInsurance(index);
        }

        UTBC.TaxiTransfer(msg.sender, UTD.withDrawAddress(), UTD.fuelFee());

        UTD.addVehicleRentProfit(index, profit);

        UTD.addUserUTAXINum(msg.sender, profit);

        UTD.setUtaxiDetails(msg.sender, 5, '', tokenId, profit.div(10 ** 18), block.timestamp);

        // UTD.setVehicleDurability(index, durability - 1);
        // durability = durability.sub(20);
        durability = durability.sub(20);

        UTD.setVehicleDurability(index, durability);

        if (welMember != address(0) && UTD.queryUserRentVehicleAmount(welMember) > 0) {

            UTD.addUserUTAXINum(welMember, profit.mul(UTD.recommenderFee()).div(100));

            UTD.addUserUTAXIReward(welMember, profit.mul(UTD.recommenderFee()).div(100));

            UTD.setUtaxiDetails(welMember, 4, UTBC.toString(msg.sender), 0, profit.mul(UTD.recommenderFee()).div(10 ** 20), block.timestamp);
        }
    
        UTD.addUtaxiProduceTotal(types, profit);

        if(durability > 0) {

            _vehicleRent(index, types);

            emit VehicleGetReward(msg.sender, index, profit);
        }else{

            UTD.setVehicleState(index, 3);

            UTD.setVehicleRentProfitTo0(index);

            UTD.setVehicleExpireTime(index, block.timestamp);
        }

        emit VehicleGetReward(msg.sender, index, profit);
    }

    function sellMyVehicle(uint256 index) public isUsers(index) {

        (uint256 types,,uint256 vehicleState,,uint256 durability,uint256 tokenId,,uint256 buyPrice,,,) = UTD.allVehicles(index);

        require(durability == 100, "Vehicle durability must be full");

        require(vehicleState == 0, "Vehicle must be unused");

        uint256 prices = buyPrice;

        UTD.setVehicleState(index, 2);

        UTD.vehicleOnShelf(index, prices);

        UTBC.setNFTLock(tokenId, true);

        emit VehicleOnShelf(msg.sender, index, types, tokenId, prices);
    }

    function vehicleOnShelf(uint256 index, uint256 price) public isUsers(index) {

        (uint256 types,,uint256 vehicleState,,uint256 durability,uint256 tokenId,,,,,) = UTD.allVehicles(index);

        require(durability == 100, "Vehicle durability must be full");

        require(vehicleState == 0, "Vehicle must be unused");

        uint256 prices = price.mul(10 ** 18);

        UTD.setVehicleState(index, 2);

        UTD.vehicleOnShelf(index, prices);

        UTBC.setNFTLock(tokenId, true);

        emit VehicleOnShelf(msg.sender, index, types, tokenId, prices);
    }

    function vehicleOffShelf(uint256 index) public isUsers(index) {

        (uint256 types,,uint256 vehicleState,,,uint256 tokenId,,,,,) = UTD.allVehicles(index);

        require(vehicleState == 2, "Vehicle must be listed");

        UTD.setVehicleState(index, 0);

        UTD.vehicleOffShelf(index);

        UTBC.setNFTLock(tokenId, false);

        emit VehicleOffShelf(msg.sender, index, types, tokenId);
    }

    function buyMemberRender(uint256 index) public {

        (uint256 types,,uint256 vehicleState,,,uint256 tokenId,address hold,,,,uint256 sellPrice) = UTD.allVehicles(index);

        (,address welMember,,,,,) = UTD.users(msg.sender);

        require(vehicleState == 2, "Vehicle must be listed");

        require(hold != msg.sender, "You can not buy your Vehicle");

        uint256 fee = sellPrice * UTD.sellFee() / 100;

        if (welMember != address(0)) {
            UTBC.TaxiTransfer(msg.sender, welMember, fee);
        }else{
            UTBC.TaxiTransfer(msg.sender, UTD.maketAddress(), fee);
        }

        UTBC.TaxiTransfer(msg.sender, hold, sellPrice - fee);

        UTD.addMarketTransactionTotal(sellPrice);

        UTBC.setNFTLock(tokenId, false); 

        UTBC.transferNFT(hold, msg.sender, tokenId);

        // if (welMember != address(0)) {

        //     uint256 cIds = UTD.addCIds();
            
        //     UTD.setCommissions(cIds, msg.sender, block.timestamp, index, sellPrice);

        //     UTD.addUserTotalDeposit(welMember, sellPrice);

        //     uint256 commissionFee = sellPrice.mul(UTD.commissionFee()).div(100);

        //     UTD.addUserUTAXIReward(welMember, commissionFee);

        //     UTD.addUserUTAXINum(welMember, commissionFee);

        //     UTD.setUtaxiDetails(welMember, 4, UTBC.toString(msg.sender), 0, commissionFee.div(10 ** 18), block.timestamp);
        // }

        UTD.vehicleTransfer(hold, msg.sender, index);

        UTD.setVehicleState(index, 0);

        UTD.vehicleOffShelf(index);

        emit BuyMemberRender(msg.sender, hold, index, types, tokenId, sellPrice);
    }

}