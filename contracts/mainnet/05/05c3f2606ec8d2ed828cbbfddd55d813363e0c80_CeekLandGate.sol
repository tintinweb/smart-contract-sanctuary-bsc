/**
 *Submitted for verification at BscScan.com on 2022-12-15
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

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

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721TokenReceiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

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
        require(_status != _ENTERED, "CEEKLANDGATE_001");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
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
        require(address(this).balance >= amount, "CEEKLANDGATE_002");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "CEEKLANDGATE_003");
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
        string memory errorStr = string(abi.encodePacked("CEEKLANDGATE_004", " ", toString(abi.encodePacked(target)), " ", toString(data)));
        return functionCall(target, data, errorStr);
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
        return functionCallWithValue(target, data, value, "CEEKLANDGATE_005");
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
        require(address(this).balance >= value, "CEEKLANDGATE_006");
        require(isContract(target), "CEEKLANDGATE_007");

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
        string memory errorStr = string(abi.encodePacked("CEEKLANDGATE_008", " ", toString(abi.encodePacked(target)), " ", toString(data)));
        return functionStaticCall(target, data, errorStr);
    }

    function toString(bytes memory data) public pure returns(string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint i = 0; i < data.length; i++) {
            str[2+i*2] = alphabet[uint(uint8(data[i] >> 4))];
            str[3+i*2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
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
        require(isContract(target), "CEEKLANDGATE_009");

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
        string memory errorStr = string(abi.encodePacked("CEEKLANDGATE_010", " ", toString(abi.encodePacked(target)), " ", toString(data)));
        return functionDelegateCall(target, data, errorStr);
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
        require(isContract(target), "CEEKLANDGATE_011");

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

contract EIP20 {

    uint256 public totalSupply;

    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show.
    string public symbol;                 //An identifier: eg SBX

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    constructor(
        uint256 _initialAmount,
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory _tokenSymbol
    ) {
        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens
        totalSupply = _initialAmount;                        // Update total supply
        name = _tokenName;                                   // Set the name for display purposes
        decimals = _decimalUnits;                            // Amount of decimals for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 _allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && _allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (_allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        emit Transfer(_from, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);
}

contract CeekLandGate is ERC165, ReentrancyGuard, Context, IERC721TokenReceiver {
    using SafeMath for uint256;

    using Address for address payable;
    using Address for address;

	struct Currency {
		address payment_token;
		uint256 value; //price in WEI
	}

    struct ExchangeRate {
        address[] payment_token;
        uint256[] contract_payment_token_reserve;
        uint256[] payment_token_reserve;
    }

	address public contract_owner;
	
	// admin address, the owner of the marketplace
    address payable public admin;

    // admin to transfer sell transactions from old marketplace SC
    address payable public sellAdmin;

	// ceek deposit address after selling NFT
    address payable public ceekDepositAdmin;

    //wbnb token address
    address public wbnbToken;

    //SC swap factory address
    address public swapFactory;

	EIP20[] public payment_tokens;
    mapping(uint256 => address[]) public payment_tokens_nft;
    mapping(uint256 => string[]) public allowedToBuyCeekUserId;
    mapping(uint256 => address[]) public allowedToBuyWallet;
    string[] public blackListedCeekUser;
    address[] public blackListedAddress;

	// commission rate is a value from 0 to 10000 (1%=100)
    uint256 commissionRate;

	// Mapping payment address for tokenId 
    mapping(uint256 => address payable) private _wallets;
	

    mapping(uint256 => string) private _sellControlSum;

    // Mapping from token ID to sell price EIP20 token
    mapping(uint256 => Currency) internal sellBidPrice;
	
    // last price sold or auctioned
    mapping(uint256 => Currency) internal soldFor;
	
    IERC721 private contract_ceekland;
	address private contract_decoder;

    event OnSale(uint256 indexed tokenId, Currency indexed price, address indexed wallet);
    event Sale(uint256 indexed tokenId, address indexed to, address indexed paymentToken, Currency defaultValue, Currency value, uint256 total);
    event Commission(uint256 indexed tokenId, address indexed to, address indexed paymentToken, Currency defaultValue, Currency value, uint256 rate, uint256 total);
	
	constructor(
        address _owner, EIP20[] memory _payment_tokens, 
        IERC721 _contract_ceekland, address _contract_decoder, address _swapFactory,
		address payable _admin, address payable _sellAdmin, address payable _ceekDepositAdmin, uint256 _commissionRate, 
         address _wbnbToken)
    {
		contract_owner = _owner;
		admin = _admin;
        sellAdmin = _sellAdmin;
		ceekDepositAdmin = _ceekDepositAdmin;
		payment_tokens = _payment_tokens;
        swapFactory = _swapFactory;
        contract_ceekland = _contract_ceekland;
        contract_decoder = _contract_decoder;
        commissionRate = _commissionRate;
        wbnbToken = _wbnbToken;
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
	
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165) returns (bool) {
        return interfaceId == type(IERC721TokenReceiver).interfaceId || super.supportsInterface(interfaceId);
    }

    function getExchangeRate0(address currencyFrom, address currencyTo) public view returns (uint256, uint256) {
        address pairAddress = IUniswapV2Factory(swapFactory).getPair(currencyFrom, currencyTo);

        if (pairAddress == address(0x0000000000000000000000000000000000000000)) {
            return (1, 1);
        }

        bytes memory resultReserves = Address.functionStaticCall(pairAddress, abi.encodeWithSignature("getReserves()"), "CEEKLANDGATE_030");

        (uint256 reserve0, uint256 reserve1,) = abi.decode(resultReserves, (uint112,uint112,uint32));

        bytes memory resultToken0 = Address.functionStaticCall(pairAddress, abi.encodeWithSignature("token0()"), "CEEKLANDGATE_031");

        (address token0) = abi.decode(resultToken0, (address));

        if (token0 == currencyFrom) {
            return (reserve1, reserve0);
        }

        return (reserve0, reserve1);
    }

    function getExchangeRate(address currencyFrom, address currencyTo) public view returns (uint256, uint256) {
        if (currencyFrom == currencyTo) {
            return (1, 1);
        }

        if (currencyFrom == wbnbToken || currencyTo == wbnbToken) {
            return getExchangeRate0(currencyFrom, currencyTo);
        }

        address pairAddress1 = IUniswapV2Factory(swapFactory).getPair(currencyFrom, wbnbToken);
        address pairAddress2 = IUniswapV2Factory(swapFactory).getPair(currencyTo, wbnbToken);

        uint256 reserve0 = 1;
        uint256 reserve1 = 1;
        uint256 reserve2 = 1;
        uint256 reserve3 = 1;
        address token0 = currencyFrom;
        address token1 = currencyTo;

        if (pairAddress1 != address(0x0000000000000000000000000000000000000000)) {
            bytes memory resultReserves1 = Address.functionStaticCall(pairAddress1, abi.encodeWithSignature("getReserves()"), "CEEKLANDGATE_030");

            (reserve0, reserve1,) = abi.decode(resultReserves1, (uint112,uint112,uint32));

            bytes memory resultToken0 = Address.functionStaticCall(pairAddress1, abi.encodeWithSignature("token0()"), "CEEKLANDGATE_031");

            token0 = abi.decode(resultToken0, (address));
        } 

        if (pairAddress2 != address(0x0000000000000000000000000000000000000000)) {
            bytes memory resultReserves2 = Address.functionStaticCall(pairAddress2, abi.encodeWithSignature("getReserves()"), "CEEKLANDGATE_030");

            (reserve2, reserve3,) = abi.decode(resultReserves2, (uint112,uint112,uint32));

            bytes memory resultToken1 = Address.functionStaticCall(pairAddress2, abi.encodeWithSignature("token0()"), "CEEKLANDGATE_031");

            token1 = abi.decode(resultToken1, (address));
        } 

        if (token0 == currencyFrom) {
            if (token1 == currencyTo) {
                return (reserve2, (reserve0.mul(reserve3)).div(reserve1));
            } else {
                return (reserve3, (reserve0.mul(reserve2)).div(reserve1));
            }
        } else {
            if (token1 == currencyTo) {
                return (reserve2, (reserve1.mul(reserve3)).div(reserve0));
            } else {
                return (reserve3, (reserve1.mul(reserve2)).div(reserve0));
            }
        }
    }

    function getExchangeRates(address payment_token) public view returns (ExchangeRate memory) {
        ExchangeRate memory exRates = ExchangeRate(new address[](payment_tokens.length), new uint256[](payment_tokens.length), new uint256[](payment_tokens.length));
        uint256 i;
        uint256 j;
        uint256 reserve0;
        uint256 reserve1;

        j=0;
        for (i=0; i<payment_tokens.length; i++) {
            if (address(payment_tokens[i]) == address(payment_token)) {
                continue;
            }

            (reserve0, reserve1) = getExchangeRate(payment_token, address(payment_tokens[i]));

            exRates.payment_token[j] = address(payment_tokens[i]);
            exRates.contract_payment_token_reserve[j] = reserve1;
            exRates.payment_token_reserve[j] = reserve0;

            j++;
        }

        return exRates;
    }

    function checkIsOwner(uint256 tokenId, bytes memory ceekUserIdParam, bool isAdmin) private {
		bytes memory resultOwnerOf = Address.functionStaticCall(address(contract_ceekland), abi.encodeWithSignature("ownerOf(uint256)", tokenId), "CEEKLANDGATE_012");

        (address tokenOwner) = abi.decode(resultOwnerOf, (address));

        bytes memory resultCEEKOwnerOf = Address.functionStaticCall(address(contract_ceekland), abi.encodeWithSignature("ceekOwnerOf(uint256)", tokenId), "CEEKLANDGATE_013");

        (string memory tokenCEEKOwner) = abi.decode(resultCEEKOwnerOf, (string));

		string memory ceekUserId;

		ceekUserId = getCeekUserId(ceekUserIdParam);
        markAsUsedCeekUserId(ceekUserIdParam);

        // onlyOwner	
        if (isAdmin) {
            require((_msgSender()==tokenOwner || (keccak256(abi.encodePacked((tokenCEEKOwner))) != keccak256(abi.encodePacked((""))) && keccak256(abi.encodePacked((tokenCEEKOwner))) == keccak256(abi.encodePacked((ceekUserId))))), "CEEKLANDGATE_014");
        } else {
            require((_msgSender()==tokenOwner && (keccak256(abi.encodePacked((tokenCEEKOwner))) == keccak256(abi.encodePacked((""))) || (keccak256(abi.encodePacked((tokenCEEKOwner))) != keccak256(abi.encodePacked((""))) && keccak256(abi.encodePacked((tokenCEEKOwner))) == keccak256(abi.encodePacked((ceekUserId)))))), "CEEKLANDGATE_014");
        }

        checkIsBlackListed(ceekUserId, _msgSender());
    }

    function checkIsNotOwner(uint256 tokenId, bytes memory ceekUserIdParam) private returns(address, string memory) {
        bytes memory resultOwnerOf = Address.functionStaticCall(address(contract_ceekland), abi.encodeWithSignature("ownerOf(uint256)", tokenId), "CEEKLANDGATE_015");

        (address tokenOwner) = abi.decode(resultOwnerOf, (address));

        bytes memory resultCEEKOwnerOf = Address.functionStaticCall(address(contract_ceekland), abi.encodeWithSignature("ceekOwnerOf(uint256)", tokenId), "CEEKLANDGATE_016");

        (string memory tokenCEEKOwner) = abi.decode(resultCEEKOwnerOf, (string));

		string memory ceekUserId;

		ceekUserId = getCeekUserId(ceekUserIdParam);
        markAsUsedCeekUserId(ceekUserIdParam);

        //onlyNotOwner
        require((_msgSender()!=tokenOwner && (keccak256(abi.encodePacked((tokenCEEKOwner))) == keccak256(abi.encodePacked((""))) || keccak256(abi.encodePacked((tokenCEEKOwner))) != keccak256(abi.encodePacked((ceekUserId))))), "CEEKLANDGATE_017");

        checkIsBlackListed(ceekUserId, _msgSender());

        return (tokenOwner, ceekUserId);
    }

    function checkIsBlackListed(string memory ceekUserId, address walletAddress) public view {
        bool blocked = false;
        uint256 i;
        if (blackListedCeekUser.length > 0) {
            for(i=0;i<blackListedCeekUser.length;i++) {
                if (keccak256(abi.encodePacked((blackListedCeekUser[i]))) == keccak256(abi.encodePacked((ceekUserId)))) {
                    blocked = true;
                    break;
                }
            }
            require((!blocked),"CEEKLANDGATE_035");
        }
        if (blackListedAddress.length > 0) {
           for(i=0;i<blackListedAddress.length;i++) {
               if (address(blackListedAddress[i]) == walletAddress) {
                   blocked = true;
                   break;
               }
            } 
            require((!blocked),"CEEKLANDGATE_036");
        }        
    }

    function checkIsMinter(address wallet) public view returns(bool) {
		bytes memory resultOwnerOf = Address.functionStaticCall(address(contract_ceekland), abi.encodeWithSignature("isMinter(address)", wallet), "CEEKLANDGATE_040");

        (bool isMinter) = abi.decode(resultOwnerOf, (bool));

        return isMinter;
    }

    function getSellControlSum(uint256 tokenId) public view returns(string memory) {
        require(_msgSender()==sellAdmin, "CEEKLANDGATE_038");
        
        return _sellControlSum[tokenId];
    }

    function sell(uint256 tokenId, uint256 priceValue, address pricePaymentToken, bytes memory ceekUserIdParam, address[] memory paymentTokenNft, string[] memory _allowedToBuyCeekUserId, address[] memory _allowedToBuyWallet, bytes memory _sellControlSumParam) public {	
        if (!(checkIsMinter(_msgSender()))) {
            checkIsOwner(tokenId, ceekUserIdParam, false);
        }

        _sellControlSum[tokenId] = getCeekUserId(_sellControlSumParam);

        markAsUsedCeekUserId(_sellControlSumParam);

        sellBidPrice[tokenId] = Currency(pricePaymentToken, priceValue);

        payment_tokens_nft[tokenId] = paymentTokenNft;
        allowedToBuyCeekUserId[tokenId] = _allowedToBuyCeekUserId;
        allowedToBuyWallet[tokenId] = _allowedToBuyWallet;
            
        if (pricePaymentToken != address(0) && priceValue > 0) {
            // set wallet payment
            if (checkIsMinter(_msgSender())) {
                _wallets[tokenId] = ceekDepositAdmin;
            } else {
                _wallets[tokenId] = payable(_msgSender());
            }

            emit OnSale(tokenId, sellBidPrice[tokenId], _wallets[tokenId]);
        } else {
            emit OnSale(tokenId, sellBidPrice[tokenId], address(0));
        }
    }

    function sellByAdmin(uint256 tokenId, uint256 priceValue, address pricePaymentToken, address payable wallet, bytes memory ceekUserIdParam, address[] memory paymentTokenNft, string[] memory _allowedToBuyCeekUserId, address[] memory _allowedToBuyWallet, bytes memory _sellControlSumParam) public {
        require(_msgSender()==sellAdmin, "CEEKLANDGATE_038");

        checkIsOwner(tokenId, ceekUserIdParam, true);

        _sellControlSum[tokenId] = getCeekUserId(_sellControlSumParam);

        markAsUsedCeekUserId(_sellControlSumParam);

        sellBidPrice[tokenId] = Currency(pricePaymentToken, priceValue);

        payment_tokens_nft[tokenId] = paymentTokenNft;
        allowedToBuyCeekUserId[tokenId] = _allowedToBuyCeekUserId;
        allowedToBuyWallet[tokenId] = _allowedToBuyWallet;
            
        if (pricePaymentToken != address(0) && priceValue > 0) {
            // set wallet payment
            if (wallet != address(0)) {
                _wallets[tokenId] = wallet;
            } else {
                _wallets[tokenId] = ceekDepositAdmin;
            }

            emit OnSale(tokenId, sellBidPrice[tokenId], _wallets[tokenId]);
        } else {
            emit OnSale(tokenId, sellBidPrice[tokenId], address(0));
        }
    }

    function beforeBuyCheck1(uint256 tokenId, uint256 priceValue, address pricePaymentToken, address paymentTokenAddress) private view returns(uint256) {
        uint256 i;
        bool ptOk1 = false;
        bool onSale = false;
        uint256 token_price;

        for (i=0;i<payment_tokens.length;i++) {
            if (address(payment_tokens[i])==paymentTokenAddress) {
                ptOk1 = true;
                break;
            }
        }

        require(ptOk1, "CEEKLANDGATE_028");

        Currency memory currency = sellBidPrice[tokenId];

        if (currency.payment_token != address(0) && currency.value > 0) {
            onSale = true;

            require((currency.value==priceValue && currency.payment_token==pricePaymentToken), "CEEKLANDGATE_032");
        }

        require(onSale, "CEEKLANDGATE_020");

        ptOk1 = false;
        for (i=0;i<payment_tokens_nft[tokenId].length;i++) {
            if (address(payment_tokens_nft[tokenId][i])==paymentTokenAddress) {
                ptOk1 = true;
                break;
            }
        }

        require(ptOk1, "CEEKLANDGATE_029");

        if (paymentTokenAddress == pricePaymentToken) {
            token_price = currency.value;
        } else {
            (uint256 exRates1, uint256 exRates2) = getExchangeRate(currency.payment_token, paymentTokenAddress);

            token_price = currency.value.mul(exRates1).div(exRates2);
        }

        return (token_price);
    }

    function beforeBuyCheck2(uint256 tokenId, uint256 tokenPrice, bytes memory ceekUserIdParam, address paymentTokenAddress) private returns(address, string memory, Currency memory) {
        // is on sale
        bool onSale = false;

        Currency memory saleBidPriceCurrency;
        if (sellBidPrice[tokenId].payment_token != address(0) && sellBidPrice[tokenId].value > 0) {

            if (paymentTokenAddress != wbnbToken) {
                bytes memory resultAllowance = Address.functionStaticCall(paymentTokenAddress, abi.encodeWithSignature("allowance(address,address)", msg.sender, address(this)));
                (uint256 tokenAllowance) = abi.decode(resultAllowance, (uint256));

                bytes memory resultBalanceOf = Address.functionStaticCall(paymentTokenAddress, abi.encodeWithSignature("balanceOf(address)", msg.sender));
                (uint256 balanceOf) = abi.decode(resultBalanceOf, (uint256));
                require(tokenPrice <= balanceOf, "CEEKLANDGATE_018");
                require(tokenPrice <= tokenAllowance, "CEEKLANDGATE_019");
            }

            onSale = true;

            saleBidPriceCurrency.payment_token = paymentTokenAddress;
            saleBidPriceCurrency.value = tokenPrice;
        }

        require(onSale, "CEEKLANDGATE_020");

        (address tokenOwner, string memory ceekUserId) = checkIsNotOwner(tokenId, ceekUserIdParam);

        return (tokenOwner, ceekUserId, saleBidPriceCurrency);
    }

    function beforeBuyCheck3(uint256 tokenId, string memory ceekUserId) private view {
        if (allowedToBuyCeekUserId[tokenId].length > 0) {
            bool allowed = false;
            uint256 i;
            for (i=0; i<allowedToBuyCeekUserId[tokenId].length; i++) {
                if (keccak256(abi.encodePacked((allowedToBuyCeekUserId[tokenId][i]))) == keccak256(abi.encodePacked((ceekUserId)))) {
                    allowed = true;
                    break;
                }
            }
            require(allowed, "CEEKLANDGATE_033");
        }
        if (allowedToBuyWallet[tokenId].length > 0) {
            bool allowed = false;
            uint256 i;
            for(i=0; i<allowedToBuyWallet[tokenId].length; i++) {
                if (allowedToBuyWallet[tokenId][i] == _msgSender()) {
                    allowed = true;
                    break;
                }
            }
            require(allowed, "CEEKLANDGATE_034");
        }
    }

    function beforeBuyCheck4(uint256 tokenId, bytes memory _sellControlSumParam) public {
        string memory sellControlSum = getCeekUserId(_sellControlSumParam);

        markAsUsedCeekUserId(_sellControlSumParam);

        require((keccak256(abi.encodePacked((_sellControlSum[tokenId]))) != keccak256(abi.encodePacked((""))) && keccak256(abi.encodePacked((_sellControlSum[tokenId]))) == keccak256(abi.encodePacked((sellControlSum)))), "CEEKLANDGATE_039");
    }

    function getPriceInCurrency(uint256 tokenId, EIP20 payment_token) public view returns (uint256) {
        uint256 token_price;

        Currency memory defaultSellBidPrice = sellBidPrice[tokenId];
        require(defaultSellBidPrice.payment_token != address(0) && defaultSellBidPrice.value > 0, "CEEKLANDGATE_037");

        (uint256 exRates1, uint256 exRates2) = getExchangeRate(defaultSellBidPrice.payment_token, address(payment_token));

        token_price = defaultSellBidPrice.value.mul(exRates1).div(exRates2);

        return token_price;
    }

    function emitBuyEvents(uint256 tokenId, address paymentTokenAddress, Currency memory saleBidPriceCurrency, uint256 token_price, uint256 amount4admin) private {
        emit Sale(tokenId, _wallets[tokenId], paymentTokenAddress, sellBidPrice[tokenId], saleBidPriceCurrency, token_price.sub(amount4admin));
        emit Commission(tokenId, admin, paymentTokenAddress, sellBidPrice[tokenId], saleBidPriceCurrency, commissionRate, amount4admin);
    }

    // Buy option
    function buy(uint256 tokenId, uint256 priceValue, address pricePaymentToken, bytes memory ceekUserIdParam, EIP20 payment_token, bytes memory _sellControlSumParam) public payable nonReentrant {        
        (uint256 token_price) = beforeBuyCheck1(tokenId, priceValue, pricePaymentToken, address(payment_token));

        (address tokenOwner, string memory ceekUserId, Currency memory saleBidPriceCurrency) = beforeBuyCheck2(tokenId,token_price,ceekUserIdParam,address(payment_token));

        beforeBuyCheck3(tokenId, ceekUserId);

        beforeBuyCheck4(tokenId, _sellControlSumParam);

        if (address(payment_token) == wbnbToken) {
            require(msg.value >= token_price, "CEEKLANDGATE_021");
        }

        // we need to call a transferFrom from this contract, which is the one with permission to sell the NFT
        callOptionalReturn(contract_ceekland, abi.encodeWithSelector(contract_ceekland.transferFrom.selector, tokenOwner, msg.sender, tokenId));
		
		Address.functionCall(address(contract_ceekland), abi.encodeWithSignature("setCeekOwnerOf(uint256,string)", tokenId, ceekUserId));
		
        // calculate amounts
        uint256 amount4admin = token_price.mul(commissionRate).div(10000);
       // uint256 amount4owner = token_price.sub(amount4admin);

        if (address(payment_token) == wbnbToken) {
            // to owner
            payable(_wallets[tokenId]).transfer(token_price.sub(amount4admin));

            // to admin
            if (amount4admin>0) {
                payable(admin).transfer(amount4admin);
            }
        } else {
            // to owner
            require(payment_token.transferFrom(msg.sender, _wallets[tokenId], token_price.sub(amount4admin)), "CEEKLANDGATE_022");

            // to admin
            if (amount4admin>0) {
                require(payment_token.transferFrom(msg.sender, admin, amount4admin), "CEEKLANDGATE_023");
            }
        }

        emitBuyEvents(tokenId, address(payment_token), saleBidPriceCurrency, token_price, amount4admin);

        soldFor[tokenId] = saleBidPriceCurrency;

        // close the sell
        delete sellBidPrice[tokenId];
        delete payment_tokens_nft[tokenId];

        delete _wallets[tokenId];
        delete allowedToBuyCeekUserId[tokenId];
        delete allowedToBuyWallet[tokenId];
        delete _sellControlSum[tokenId];
    }
	
	// update contract fields
    function updateAdmin(EIP20[] memory _payment_tokens, IERC721 _contract_ceekland,
                         address _contract_decoder, address payable _admin, address payable _sellAdmin, address payable _ceekDepositAdmin,
                         uint256 _commissionRate, 
                         address _wbnbToken, address _swapFactory) public {
        require(_msgSender()==contract_owner, "CEEKLANDGATE_024");
		payment_tokens = _payment_tokens;
        swapFactory = _swapFactory;
		admin = _admin;
        sellAdmin = _sellAdmin;
		ceekDepositAdmin = _ceekDepositAdmin;
        contract_ceekland = _contract_ceekland;
        contract_decoder = _contract_decoder;
        commissionRate = _commissionRate;
        wbnbToken = _wbnbToken;
    }
	
	/**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC721 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "CEEKLANDGATE_025");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "CEEKLANDGATE_026");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "CEEKLANDGATE_027");
        }
    }

	function getCeekUserId(bytes memory ceekUserIdParam) internal view returns (string memory) {
   		bytes memory resultDecode = Address.functionStaticCall(contract_decoder, abi.encodeWithSignature("decode(bytes,bool)", ceekUserIdParam,true));
				
		return abi.decode(resultDecode, (string));
	}

    function markAsUsedCeekUserId(bytes memory ceekUserIdParam) internal {
		Address.functionCall(contract_decoder,abi.encodeWithSignature("markAsUsed(bytes)", ceekUserIdParam));
	}
		
    // simple function to return the price of a tokenId for auctions
    // returns: bid price, sold price, only one can be non zero
    function getPrice(uint256 tokenId, string memory groupId, uint256 coord_land, uint256 coord_row, uint256 coord_col) public view returns (Currency memory, Currency memory) {
		if (tokenId == 0) {
            (bytes memory resultTokenId) = Address.functionStaticCall(address(contract_ceekland),abi.encodeWithSignature("getTokenIdByCoordsOrGroup(string, uint256, uint256, uint256)", groupId, coord_land, coord_row, coord_col));

            tokenId = abi.decode(resultTokenId, (uint256));
		}

		if (sellBidPrice[tokenId].payment_token != address(0) && sellBidPrice[tokenId].value > 0) {
            return (sellBidPrice[tokenId], Currency(address(0), 0));
        }
        
		return (Currency(address(0), 0), soldFor[tokenId]);
    }

    function setBlackListUsers(string[] memory _blackListedCeekUser, address[] memory _blackListedAddress) public {
        require(_msgSender()==contract_owner, "CEEKLANDGATE_024");
        blackListedCeekUser = _blackListedCeekUser;
        blackListedAddress = _blackListedAddress;
    }
}