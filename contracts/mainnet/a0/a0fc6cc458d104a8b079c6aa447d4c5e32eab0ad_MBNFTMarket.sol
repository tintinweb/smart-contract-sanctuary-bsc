/**
 *Submitted for verification at BscScan.com on 2022-03-01
*/

pragma solidity ^0.8.11;
// SPDX-License-Identifier: Unlicensed


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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
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
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
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
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     * opcode (which leaves remaining gas untouched) while Solidity uses an
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
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant alphabet = "0123456789abcdef";

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
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}

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

abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

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
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

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
    function transferFrom(address from, address to, uint256 tokenId) external;

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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

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

interface IERC20 {

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

interface IUniswapV2Factory {
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


// pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

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



// pragma solidity >=0.6.2;

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

abstract contract Ownable is Context {
    address _owner;

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

struct Sale {
    bool exists;
    address seller; //address of the person who created the sale
    address tokenContract; //address of the contract the NFT is from
    uint256 tokenId; //token ID of the NFT
    uint256 listPrice; //the LIST price 
    bool running;
    bool sold;
}

struct Token {
    bool exists;
    IERC20 token;
    address wbnbLPaddress;
    uint256 fees; //fees on token
    uint256 decimals;
}

struct Collection {
    bool exists;
    address collection_contract;
    uint256 royalties; //royatly fee, in permille
    uint256 totalRoyalites;
}

struct Offer {
    bool exists;
    address token_address;
    uint256 token_id;
    uint256 offer_token_id;
    uint256 offer_amount;
    address offerer;
}

contract MBNFTMarket is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;

    //Tokens
    IERC20 MB = IERC20(0x0962840397B0ebbFbb152930AcB0583e94F49B5c);
    address payable _USDTAddress = payable(0x55d398326f99059fF775485246999027B3197955);
    IERC20 wbnb = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);

    //Admin Addresses
    address payable public expense = payable(0xB30186581D1922a1A86E710161B3234c92945156);
    address payable public charity = payable(0xbd05D7670611fd82ac0dB90BF48A5f01cF3B496F);

    //mappings
    mapping(uint256 => Sale) public sales;
    mapping(uint256 => Token) public tokens;
    mapping(uint256 => Collection) public collections;
    mapping(uint256 => Offer) public offers;

    mapping(address => mapping(uint256 => uint256)) public nftToSaleTracker; //takes address, token id, and returns sale ID (0 represents no sale)
    mapping(address => uint256) public contractToCollectionTracker; //keeps track of collections based on address

    //variables
    IUniswapV2Router02 public uniswapV2Router;
    uint256 fees = 50; //platform fees, in permille
    bool salesEnabled = true;
    uint256 maxRoyalties = 100; //maximum allowed royalties (in %)

    //info vars
    uint256 public saleFinalId = 0;
    uint256 public tokensFinalId = 0;
    uint256 public collectionsFinalId = 0;
    uint256 public offersFinalId = 0;
    uint256 public activeSales = 0;

    //events
    event NewSale(address token_contract, uint256 token_id, uint256 list_price, uint256 sale_id, address seller);
    event SalePriceChanged(uint256 sale_id, uint256 old_price, uint256 new_price);
    event SaleCompleted(uint256 sale_id);
    event SaleCancelled(uint256 sale_id);
    event AdminSaleCancelled(uint256 sale_id);

    event NewOffer(address token_contract, uint256 token_id, uint256 offer_token_id, uint256 offer_amount, uint256 offer_id, address offerer);
    event OfferAccepted(uint256 offer_id);
    event OfferCancelled(uint256 offer_id);
    event AdminOfferCancelled(uint256 offer_id);

    event NewCollection(address token_contract, uint256 royalties, uint256 collection_id, address collection_owner);
    event CollectionRoyalitesChanged(uint256 collection_id, uint256 old_royalites, uint256 new_royalites);
    event RemovedCollection(uint256 collection_id);
    event AdminRemovedCollection(uint256 collection_id);
    event AdminAddedCollection(address token_contract, uint256 royalties, uint256 collection_id, address collection_owner);


    //getters
    function GetSale(uint256 id) public view returns(Sale memory)
    {
        return sales[id];
    }

    function GetToken(uint256 id) public view returns(Token memory)
    {
        return tokens[id];
    }

    function GetCollection(uint256 id) public view returns(Collection memory)
    {
        return collections[id];
    }

    function GetOffer(uint256 id) public view returns(Offer memory)
    {
        return offers[id];
    }

    function VerifySale(uint256 sale_id) public view returns(bool)
    {
        //check that sale is valid
        if(sales[sale_id].exists != true) return false;
        if(sales[sale_id].running != true) return false;

        IERC721 nft = IERC721(sales[sale_id].tokenContract);

        if(nft.ownerOf(sales[sale_id].tokenId) != sales[sale_id].seller) return false;
        if(!(nft.getApproved(sales[sale_id].tokenId) == address(this) || nft.isApprovedForAll(sales[sale_id].seller, address(this)))) return false;


        return true;
    }

    function VerifyOffer(uint256 offer_id) public view returns(bool)
    {
         //check that offer exists
        if(!offers[offer_id].exists) return false;
  
        //require offerer to have approved token transfer
        if(!(tokens[offers[offer_id].offer_token_id].token.allowance(offers[offer_id].offerer, address(this)) >= offers[offer_id].offer_amount)) return false;

        //require offerer to have necessary token balance
        if(!(tokens[offers[offer_id].offer_token_id].token.balanceOf(offers[offer_id].offerer) >= offers[offer_id].offer_amount)) return false;

        return true;
    }

    //admin functions
    function AdminEndSale(uint256 id) public onlyOwner
    {
        require(sales[id].running, "This sale is not running");
        nftToSaleTracker[sales[id].tokenContract][sales[id].tokenId] = 0;
        sales[id].running = false;
        activeSales = activeSales.sub(1);
        emit AdminSaleCancelled(id);
    }

    function AdminAddToken(address token_contract, address token_wbnb_lp, uint256 token_fees) public onlyOwner
    {
        tokensFinalId = tokensFinalId.add(1);
        tokens[tokensFinalId].exists = true;
        tokens[tokensFinalId].token = IERC20(token_contract);
        tokens[tokensFinalId].fees = token_fees;
        tokens[tokensFinalId].wbnbLPaddress = token_wbnb_lp;
    }

    function AdminUpdateToken(uint256 token_id, bool exists, address token_contract, address token_wbnb_lp, uint256 token_fees) public onlyOwner
    {
        tokens[token_id].exists = exists;
        tokens[tokensFinalId].token = IERC20(token_contract);
        tokens[tokensFinalId].fees = token_fees;
        tokens[tokensFinalId].wbnbLPaddress = token_wbnb_lp;
    }

    function AdminRemoveCollection(uint256 id) public onlyOwner
    {
        require(collections[id].exists, "This collection does not exists");
        collections[id].exists = false;
        collections[id].royalties = 0;

        contractToCollectionTracker[collections[id].collection_contract] = 0;
        emit AdminRemovedCollection(id);
    }

    function AdminRemoveOffer(uint256 id) public onlyOwner
    {
        require(offers[id].exists, "This offer does not exists");
        offers[id].exists = false;
        emit AdminOfferCancelled(id);
    }

    function AdminRemoveToken(uint256 id) public onlyOwner
    {
        require(tokens[id].exists, "This collection does not exists");
        tokens[id].exists = false;
    }

    function AdminSetExpense(address payable addy) public onlyOwner
    {
        expense = addy;
    }

    function AdminSetCharity(address payable addy) public onlyOwner
    {
        charity = addy;
    }

    function AdminSetUSDTAddress(address payable addy) public onlyOwner
    {
        _USDTAddress = addy;
    }

    function AdminSetFees(uint256 newFee) public onlyOwner
    {
        require(newFee >= 100, "Platform fees cannot exceed 10%");
        fees = newFee;
    }

    function AdminSetMaxRoyalties(uint256 newMax) public onlyOwner
    {
        require(newMax >= 100, "Max royalty fees cannot exceed 10%");
        maxRoyalties = newMax;
    }

    function AdminSetSaleEnabled(bool toggle) public onlyOwner
    {
        salesEnabled = toggle;
    }

    function AdminChangeRounter(address addy) public onlyOwner
    {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(addy);
        uniswapV2Router = _uniswapV2Router;
    }

    function AdminAddCollection(address token_contract) public onlyOwner
    {
        require(contractToCollectionTracker[token_contract] == 0, "Collection already exists for this contract address");

        Ownable ownable = Ownable(token_contract);

        collectionsFinalId = collectionsFinalId.add(1);

        Collection memory tempCollection;

        tempCollection.exists = true;
        tempCollection.collection_contract = token_contract;
        tempCollection.royalties = 0;
        tempCollection.totalRoyalites = 0;

        collections[collectionsFinalId] = tempCollection;
        contractToCollectionTracker[token_contract] = collectionsFinalId;

        emit AdminAddedCollection(token_contract, 0, collectionsFinalId, ownable.owner());
    }

    function AdminRepurchaseAndBurn() public onlyOwner
    {
        //Repurchases MB with any accrued BNB from swaps and sends to burn address
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(MB);

        // make the swap
       uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value:address(this).balance}(
            0, // accept any amount of MB
            path,
            0x0000000000000000000000000000000000000001,
            block.timestamp
        );
    }

    //user functions
    function CreateSale(address token_contract, uint256 token_id, uint256 list_price_bnb) public returns(uint256) 
    {
        require(nftToSaleTracker[token_contract][token_id] == 0, "A sale already exists for this NFT");

        IERC721 nft_contract = IERC721(token_contract);

        require(nft_contract.ownerOf(token_id) == _msgSender(), "You must own an NFT to list it for sale");
        require(nft_contract.isApprovedForAll(_msgSender(), address(this)) || nft_contract.getApproved(token_id) == address(this), "Approval required to create a sale");

        //Passes all requirements, create the sale
        saleFinalId = saleFinalId.add(1);
        
        Sale memory tempSale;
        tempSale.seller = _msgSender();
        tempSale.exists = true;
        tempSale.tokenContract = token_contract;
        tempSale.tokenId = token_id;
        tempSale.listPrice = list_price_bnb;
        tempSale.running = true;
        tempSale.sold = false;

        nftToSaleTracker[token_contract][token_id] = saleFinalId;

        activeSales = activeSales.add(1);

        sales[saleFinalId] = tempSale;
        emit NewSale(token_contract, token_id, list_price_bnb, saleFinalId, _msgSender());
        return saleFinalId;
    }

    function UpdateSalePrice(uint256 sale_id, uint256 new_price_bnb) public
    {
        require(VerifySale(sale_id), "Sale is not valid");
        require(_msgSender() == sales[sale_id].seller, "You cannot change the price of a sale that is not yours");

        emit SalePriceChanged(sale_id, sales[sale_id].listPrice, new_price_bnb);
        sales[sale_id].listPrice = new_price_bnb;
    }

    function EndSale(uint256 id) public
    {
        require(sales[id].exists, "This sale does not exist");
        require(sales[id].running, "This sale is not running");
        require(sales[id].seller == _msgSender(), "You cannot end another users sale");

        nftToSaleTracker[sales[id].tokenContract][sales[id].tokenId] = 0;

        activeSales = activeSales.sub(1);

        sales[id].running = false;
        emit SaleCancelled(id);
    }

    function CreateCollection(address token_contract, uint256 royalties) public nonReentrant returns(uint256)
    {
        require(contractToCollectionTracker[token_contract] == 0, "Collection already exists for this contract address");
        require(royalties <= maxRoyalties, "Royalies are too high");

        Ownable ownable = Ownable(token_contract);

        require(ownable.owner() == _msgSender(), "You must own a contract to create a collection for it");

        collectionsFinalId = collectionsFinalId.add(1);

        Collection memory tempCollection;

        tempCollection.exists = true;
        tempCollection.collection_contract = token_contract;
        tempCollection.royalties = royalties;
        tempCollection.totalRoyalites = 0;

        collections[collectionsFinalId] = tempCollection;
        contractToCollectionTracker[token_contract] = collectionsFinalId;

        emit NewCollection(token_contract, royalties, collectionsFinalId, _msgSender());
        return(collectionsFinalId);
    }

    function RemoveCollection(uint256 id) public
    {
        require(collections[id].exists, "This collection does not exist");
        
        Ownable ownable = Ownable(collections[id].collection_contract);

        require(ownable.owner() == _msgSender(), "You must own a collection to remove it");

        collections[id].exists = false;
        collections[id].royalties = 0;
        contractToCollectionTracker[collections[id].collection_contract] = 0;
        emit RemovedCollection(id);
    }

    function UpdateCollectionRoyalties(uint256 id, uint256 new_royalites) public
    {
        require(collections[id].exists, "This collection does not exist");
        
        Ownable ownable = Ownable(collections[id].collection_contract);

        require(ownable.owner() == _msgSender(), "You must own a collection to update it");

        require(new_royalites <= maxRoyalties, "Royalies are too high");

        emit CollectionRoyalitesChanged(id, collections[id].royalties, new_royalites);
        collections[id].royalties = new_royalites;
    }

    function CreateOffer(address token_address, uint256 token_id, uint256 offer_token_id, uint256 offer_amount) public returns (uint256)
    {
        require(tokens[offer_token_id].token.balanceOf(_msgSender()) >= offer_amount, "Offer exceeds token balance");
        require(tokens[offer_token_id].token.allowance(_msgSender(), address(this)) >= offer_amount, "Offer higher than token allowance");

        offersFinalId = offersFinalId.add(1);

        Offer memory tempOffer;
        tempOffer.exists = true;
        tempOffer.token_address = token_address;
        tempOffer.token_id = token_id;
        tempOffer.offer_token_id = offer_token_id;
        tempOffer.offer_amount = offer_amount;
        tempOffer.offerer = _msgSender();

        offers[offersFinalId] = tempOffer;
        emit NewOffer(token_address, token_id, offer_token_id, offer_amount, offersFinalId, _msgSender());
        return offersFinalId;
    }

    function CancelOffer(uint256 id) public
    {
        require(offers[id].offerer == _msgSender(), "You cannot cancel another users offer");

        offers[id].exists = false;
        emit OfferCancelled(id);
    }

    //buying functions
    function BuyWithBNB(uint256 saleId) public payable nonReentrant
    {
        //check that sale is valid
        require(sales[saleId].exists == true, "This sale does not exist");
        require(sales[saleId].running == true, "This sale is not running");

        IERC721 nft = IERC721(sales[saleId].tokenContract);

        require(nft.ownerOf(sales[saleId].tokenId) == sales[saleId].seller, "Seller no longer owns this NFT");
        require(nft.getApproved(sales[saleId].tokenId) == address(this) || nft.isApprovedForAll(sales[saleId].seller, address(this)), "Seller has not approved marketplace for NFT transfer");

        //check that value of msg is sufficient
        require(msg.value >= sales[saleId].listPrice, "Message value not sufficient");

        //swap BNB for MB
        uint256 mbReceived = BNBtoMB(msg.value);

        //process MB
        ProcessMB(mbReceived, sales[saleId].tokenContract, sales[saleId].seller);

        //transfer the NFT to the buyer
        nft.transferFrom(sales[saleId].seller, _msgSender(), sales[saleId].tokenId);

        //mark sale as complete
        sales[saleId].running = false;
        sales[saleId].sold = true;
        nftToSaleTracker[sales[saleId].tokenContract][sales[saleId].tokenId] = 0;
        activeSales = activeSales.sub(1);
        emit SaleCompleted(saleId);
    }

    function BuyWithToken(uint256 saleId, uint256 token_id) public nonReentrant
    {
        //check that sale is valid
        require(sales[saleId].exists == true, "This sale does not exist");
        require(sales[saleId].running == true, "This sale is not running");

        IERC721 nft = IERC721(sales[saleId].tokenContract);

        require(nft.ownerOf(sales[saleId].tokenId) == sales[saleId].seller, "Seller no longer owns this NFT");
        require(nft.getApproved(sales[saleId].tokenId) == address(this) || nft.isApprovedForAll(sales[saleId].seller, address(this)), "Seller has not approved marketplace for NFT transfer");

        //determine how many tokens to take from the buyer
        uint256 tokens_to_pay = salePriceToken(sales[saleId].listPrice, token_id);

        require(tokens[token_id].token.allowance(_msgSender(), address(this)) >= tokens_to_pay, "Not enough approval on token used to buy");

        //take tokens from buyer
        uint256 tokensReceived = tokens[token_id].token.balanceOf(address(this));
        tokens[token_id].token.transferFrom(_msgSender(), address(this), tokens_to_pay);
        tokensReceived = tokens[token_id].token.balanceOf(address(this)).sub(tokensReceived);

        //swap tokens for MB (if token is not MB)
        uint256 MB_Gained;
        if(token_id != 0)
        {
            MB_Gained = TokentoMB(tokensReceived, token_id);
        }
        else
        {
            MB_Gained = tokensReceived;
        }

        //Process MB
        ProcessMB(MB_Gained, sales[saleId].tokenContract, sales[saleId].seller);

        //transfer the NFT to the buyer
         nft.transferFrom(sales[saleId].seller, _msgSender(), sales[saleId].tokenId);

        //mark sale as complete
        sales[saleId].running = false;
        sales[saleId].sold = true;
        nftToSaleTracker[sales[saleId].tokenContract][sales[saleId].tokenId] = 0;
        activeSales = activeSales.sub(1);
        emit SaleCompleted(saleId);
    }

    function AcceptOffer(uint256 offer_id) public nonReentrant
    {
        //check that offer exists
        require(offers[offer_id].exists, "This offer does not exists or has been cancelled");

        IERC721 nft_contract = IERC721(offers[offer_id].token_address);

        //require acceptor owns this NFT and has approved transfer of this NFT
        require(nft_contract.ownerOf(offers[offer_id].token_id) == _msgSender(), "You must own this NFT to accept an offer");
        require(nft_contract.getApproved(offers[offer_id].token_id) == address(this) || nft_contract.isApprovedForAll(_msgSender(), address(this)), "You have not approved the marketplace to transfer your NFT");
        
        //require offerer to have approved token transfer
        require(tokens[offers[offer_id].offer_token_id].token.allowance(offers[offer_id].offerer, address(this)) >= offers[offer_id].offer_amount, "Offerer has not approved their tokens to be spent");

        //require offerer to have necessary token balance
        require(tokens[offers[offer_id].offer_token_id].token.balanceOf(offers[offer_id].offerer) >= offers[offer_id].offer_amount, "The offerer does not have enough tokens to fulfill the sale");

        //take tokens from the offerer
        uint256 tokensReceived = tokens[offers[offer_id].offer_token_id].token.balanceOf(address(this));
        tokens[offers[offer_id].offer_token_id].token.transferFrom(offers[offer_id].offerer, address(this), offers[offer_id].offer_amount);
        tokensReceived = tokens[offers[offer_id].offer_token_id].token.balanceOf(address(this)).sub(tokensReceived);

        //swap tokens for MB (if token is not MB)
        uint256 MB_Gained;
        if(offers[offer_id].offer_token_id != 0)
        {
            MB_Gained = TokentoMB(tokensReceived, offers[offer_id].offer_token_id);
        }
        else
        {
            MB_Gained = tokensReceived;
        }

        ProcessMB(MB_Gained, offers[offer_id].token_address, _msgSender());

        //transfer the NFT to the buyer
        nft_contract.transferFrom(_msgSender(), offers[offer_id].offerer, offers[offer_id].token_id);

        //mark the offer as completed
        offers[offer_id].exists = false;
        emit OfferAccepted(offer_id);
    }

    //token processing
    function BNBtoMB(uint256 bnb_amount) private returns (uint256)
    {
        require(bnb_amount > 0, "Cannot swap for 0 BNB");

        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(MB);

        uint256 MBgained = MB.balanceOf(address(this));

        // make the swap
       uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value:bnb_amount}(
            0, // accept any amount of MB
            path,
            address(this),
            block.timestamp
        );

        MBgained = MB.balanceOf(address(this)).sub(MBgained);

        return MBgained;
    }

    function TokentoMB(uint256 token_amount, uint256 token_id) private returns (uint256)
    {
        require(token_amount > 0, "Cannot swap for 0 tokens");
        require(token_id != 0, "Cannot swap MB for MB");

        address[] memory path = new address[](3);
        path[0] = address(tokens[token_id].token);
        path[1] = uniswapV2Router.WETH();
        path[2] = address(MB);

        tokens[token_id].token.approve(address(uniswapV2Router), token_amount);

        uint256 MBgained = MB.balanceOf(address(this));

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            token_amount,
            0, // accept any amount of MB
            path,
            address(this),
            block.timestamp
        );

        MBgained = MB.balanceOf(address(this)).sub(MBgained);

        return MBgained;
    }

    function ProcessMB(uint256 MB_Amount, address nft_contract, address seller) private
    {
        //caluclate platform fees
        uint256 MB_fees = (MB_Amount * fees).div(1000);
        uint256 MB_Charity = MB_fees.div(2);
        uint256 MB_Expense = MB_fees.sub(MB_Charity);

        uint256 MB_Royalties = 0;

        if(collections[contractToCollectionTracker[nft_contract]].royalties > 0)
        {
            MB_Royalties = (MB_Amount * collections[contractToCollectionTracker[nft_contract]].royalties).div(1000);
        }

        uint256 MB_Seller = MB_Amount.sub(MB_fees).sub(MB_Royalties);
        //send platform fees to appropriate wallets
        swapTokensForUSDT(MB_Charity, charity);
        swapTokensForUSDT(MB_Expense, expense);

        //send royalties to collection owner
        if(MB_Royalties > 0)
        {
            MB.transfer(Ownable(nft_contract).owner(), MB_Royalties);
        }

        //send remainder to seller
        MB.transfer(seller, MB_Seller);
    }

    function swapTokensForUSDT(uint256 tokenAmount, address payable destination) private {
        // generate the uniswap pair path of token -> weth

        if(tokenAmount == 0) return;

        address[] memory path = new address[](3);
        path[0] = address(MB);
        path[1] = uniswapV2Router.WETH();
        path[2] = _USDTAddress;

        MB.approve(address(uniswapV2Router), tokenAmount);
        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of Butter
            path,
            destination,
            block.timestamp
        );
    }

    function getTokenPerBNB(uint256 token_id) public view returns (uint256)
    {
        uint256 tokenBNBAmount = wbnb.balanceOf(tokens[token_id].wbnbLPaddress);
        uint256 tokenAmount = tokens[token_id].token.balanceOf(tokens[token_id].wbnbLPaddress);
        
        //Normalize decimals to BNB decimals, find amount of Butter 1 BNB is worth
        uint256 tokenDecimals = tokens[token_id].decimals;

        if(tokenDecimals > 18)
        {
            tokenAmount = tokenAmount.div(10**(tokenDecimals-18));
        }
        if(tokenDecimals < 18)
        {
            tokenAmount = tokenAmount.mul(10**(18-tokenDecimals));
        }
        
        uint256 tokenPerBNB = tokenAmount.div(tokenBNBAmount);
        
        return tokenPerBNB.mul(10**(tokenDecimals));
    }

    function salePriceToken(uint256 salePrice, uint256 token_id) public view returns (uint256)
    {
        //Returns the amount of Milk to meet a sale price in BUSD
        uint256 tokenPerBNB = getTokenPerBNB(token_id);
        
        uint256 tokenForSale = tokenPerBNB.mul(salePrice).div(10**18);
        
        //account for fees to ensure that seller always gets their desired amount from sale
        //2 transfers (buyer => this => PCS)
        tokenForSale = tokenForSale.mul(1000 + (tokens[token_id].fees.mul(2))).div(1000);

        return tokenForSale;
    }

    receive() external payable {}
    
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
        emit OwnershipTransferred(address(0), msgSender);

        tokens[0].exists = true;
        tokens[0].token = IERC20(0x0962840397B0ebbFbb152930AcB0583e94F49B5c);
        tokens[0].fees = 0;
        tokens[0].wbnbLPaddress = 0x38626e1e17Fc81d3e9a96D16517F8c56bC1B2968;
        tokens[0].decimals = 9;
    }
    
}