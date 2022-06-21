/**
 *Submitted for verification at BscScan.com on 2022-06-20
*/

// File: contracts\objects\AssetType.sol

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

enum AssetType {
    ERC20,
    ERC721,
    ERC1155
}

// File: contracts\objects\TradeSingleStruct.sol

abstract contract TradeSingleStruct {
    struct TradeSingle {
        address initiator;
        address counterparty;
        address proposedAsset;
        uint proposedAmount;
        uint proposedTokenId;
        address askedAsset;
        uint askedAmount;
        uint askedTokenId;
        uint deadline;
        uint status;
        AssetType proposedAssetType;
        AssetType askedAssetType;
    }
}

// File: contracts\objects\TradeMultiStruct.sol


abstract contract TradeMultiStruct {
    struct TradeMulti {
        address initiator;
        address counterparty;
        address[] proposedAssets;
        uint proposedAmount;
        uint[] proposedTokenIds;
        address[] askedAssets;
        uint[] askedTokenIds;
        uint askedAmount;
        uint deadline;
        uint status;
        AssetType proposedAssetType;
        AssetType askedAssetType;
    }
}

// File: contracts\objects\TradeObjects.sol

abstract contract TradeObjects is
    TradeSingleStruct,
    TradeMultiStruct
{}

// File: contracts\utils\Ownable.sol


abstract contract Ownable {
    address private _owner;
    address private _newOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function newOwner() public view virtual returns (address) {
        return _newOwner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address transferOwner) public onlyOwner {
        require(transferOwner != newOwner());
        _newOwner = transferOwner;
    }

    function acceptOwnership() virtual public {
        require(msg.sender == newOwner(), "Ownable: caller is not the new owner");
        emit OwnershipTransferred(_owner, _newOwner);
        _owner = _newOwner;
        _newOwner = address(0);
    }
}

// File: contracts\utils\Address.sol

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

        uint size;
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
    function sendValue(address payable recipient, uint amount) internal {
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
        uint value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint value,
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

// File: contracts\utils\TransferHelper.sol

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }
    function safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }
    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }
    function safeTransferBNB(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: BNB_TRANSFER_FAILED');
    }
}

// File: contracts\interfaces\IWBNB.sol


interface IWBNB {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// File: contracts\storage\P2PStorage.sol

enum TradeState {
    Active,
    Succeeded,
    Canceled,
    Withdrawn,
    Overdue,
    CanceledOrWithdrawn
}

contract P2PStorage is Ownable, TradeObjects {    
    
    address public _implementationAddress;
    uint public version;
        
    uint public tradeCount;
    bool public isAnyNFTAllowed;
    uint public unlocked = 1;
    IWBNB public WBNB;
    
    mapping(uint => TradeSingle) public tradesSingle;
    mapping(uint => TradeMulti) public tradesMulti;
    mapping(address => uint[]) internal _userTrades;
    mapping(address => bool) public allowedNFT;
}

// File: contracts\interfaces\IERC721Receiver.sol

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
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// File: contracts\interfaces\IERC1155Receiver.sol

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver {
    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint,uint,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint,uint,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint id,
        uint value,
        bytes calldata data
    ) external returns (bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint[],uint[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint[],uint[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint[] calldata ids,
        uint[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// File: contracts\utils\ERC1155Receiver.sol

abstract contract ERC1155Receiver is IERC1155Receiver {}

// File: contracts\utils\ERC1155Holder.sol

/**
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint,
        uint,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint[] memory,
        uint[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}

// File: contracts\interfaces\IERC1155.sol


/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint id, uint value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint[] ids,
        uint[] values
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
    event URI(string value, uint indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint id) external view returns (uint);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint[] calldata ids)
        external
        view
        returns (uint[] memory);

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
        uint id,
        uint amount,
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
        uint[] calldata ids,
        uint[] calldata amounts,
        bytes calldata data
    ) external;

    function mint(
        address to,
        uint id,
        uint amount,
        bytes memory data
    ) external;

    function mintBatch(
        address to,
        uint[] memory ids,
        uint[] memory amounts,
        bytes memory data
    ) external;

    function burn(
        address from,
        uint id,
        uint amount
    ) external;

    function burnBatch(
        address from,
        uint[] memory ids,
        uint[] memory amounts
    ) external;
}

// File: contracts\interfaces\IERC165.sol

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

// File: contracts\interfaces\IERC721.sol

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
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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

// File: contracts\p2p\P2P.sol

contract P2P is P2PStorage, IERC721Receiver, ERC1155Holder {    

    event NewTradeSingle(address indexed user, address indexed proposedAsset, uint proposedAmount, uint proposedTokenId, address indexed askedAsset, uint askedAmount, uint askedTokenId, uint deadline, uint tradeId);
    event NewTradeMulti(address indexed user, address[] proposedAssets, uint proposedAmount, uint[] proposedIds, address[] askedAssets, uint askedAmount, uint[] askedIds, uint deadline, uint indexed tradeId);
    event SupportTrade(uint indexed tradeId, address indexed counterparty);
    event CancelTrade(uint indexed tradeId);
    event WithdrawOverdueAsset(uint indexed tradeId);
    event CancelOrWithdrawOverdueAssetTrade(uint indexed tradeId);
    event UpdateIsAnyNFTAllowed(bool indexed isAllowed);
    event UpdateAllowedNFT(address indexed nftContract, bool indexed isAllowed);

    receive() external payable {
        assert(msg.sender == address(WBNB)); // only accept ETH via fallback from the WBNB contract
    }
    
    modifier lock() {
        require(unlocked == 1, 'P2P: locked');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function createTrade20To20(address proposedAsset, uint proposedAmount, address askedAsset, uint askedAmount, uint deadline) external returns (uint tradeId) {
        require(Address.isContract(proposedAsset) && Address.isContract(askedAsset), "P2P: Not contracts");
        require(proposedAmount > 0, "P2P: Zero amount not allowed");
        TransferHelper.safeTransferFrom(proposedAsset, msg.sender, address(this), proposedAmount);
        tradeId = _createTradeSingle(proposedAsset, proposedAmount, 0, askedAsset, askedAmount, 0, deadline, AssetType.ERC20, AssetType.ERC20);   
    }

    // for trade ERC20 -> Native Coin use createTradeERC20ToERC20 and pass WBNB address as asked asset
    function createTradeBNBto20(address askedAsset, uint askedAmount, uint deadline) payable external returns (uint tradeId) {
        require(Address.isContract(askedAsset), "P2P: Not contract");
        require(msg.value > 0, "P2P: Zero amount not allowed");
        WBNB.deposit{value: msg.value}();
        tradeId = _createTradeSingle(address(WBNB), msg.value, 0, askedAsset, askedAmount, 0, deadline, AssetType.ERC20, AssetType.ERC20);   
    }



    function createTrade20To721(address proposedAsset, uint proposedAmount, address askedAsset, uint tokenId, uint deadline) external returns (uint tradeId) {
        require(Address.isContract(proposedAsset), "P2P: Not contracts");
        require(proposedAmount > 0, "P2P: Zero amount not allowed");
        _requireAllowed721Or1155(askedAsset);
        TransferHelper.safeTransferFrom(proposedAsset, msg.sender, address(this), proposedAmount);
        tradeId = _createTradeSingle(proposedAsset, proposedAmount, 0, askedAsset, 0, tokenId, deadline, AssetType.ERC20, AssetType.ERC721);   
    }

    // for trade NFT -> Native Coin use createTradeNFTtoERC20 and pass WBNB address as asked asset
    function createTrade721to20(address proposedAsset, uint tokenId, address askedAsset, uint askedAmount, uint deadline) external returns (uint tradeId) {
        require(Address.isContract(proposedAsset), "P2P: Not contracts");
        _requireAllowed721Or1155(proposedAsset);
        IERC721(proposedAsset).safeTransferFrom(msg.sender, address(this), tokenId);
        tradeId = _createTradeSingle(proposedAsset, 0, tokenId, askedAsset, askedAmount, 0, deadline, AssetType.ERC721, AssetType.ERC20);   
    }

    function createTradeBNBto721(address askedAsset, uint tokenId, uint deadline) payable external returns (uint tradeId) {
        require(Address.isContract(askedAsset), "P2P: Not contract");
        require(msg.value > 0, "P2P: Zero amount not allowed");
        _requireAllowed721Or1155(askedAsset);
        WBNB.deposit{value: msg.value}();
        tradeId = _createTradeSingle(address(WBNB), msg.value, 0, askedAsset, 0, tokenId, deadline, AssetType.ERC20, AssetType.ERC721);   
    }



    function createTrade1155to20(address proposedAsset, uint proposedAmount, uint proposedTokenId, address askedAsset, uint askedAmount, uint deadline) external returns (uint tradeId) {
        require(Address.isContract(proposedAsset), "P2P: Not contracts");
        require(proposedAmount > 0, "P2P: Zero amount not allowed");
        _requireAllowed721Or1155(proposedAsset);
        IERC1155(proposedAsset).safeTransferFrom(msg.sender, address(this), proposedTokenId, proposedAmount, "");
        tradeId = _createTradeSingle(proposedAsset, proposedAmount, proposedTokenId, askedAsset, askedAmount, 0, deadline, AssetType.ERC1155, AssetType.ERC20);   
    }

    function createTrade20To1155(address proposedAsset, uint proposedAmount, address askedAsset, uint tokenId, uint askedAmount, uint deadline) external returns (uint tradeId) {
        require(Address.isContract(proposedAsset), "P2P: Not contracts");
        require(proposedAmount > 0, "P2P: Zero amount not allowed");
        _requireAllowed721Or1155(askedAsset);
        TransferHelper.safeTransferFrom(proposedAsset, msg.sender, address(this), proposedAmount);
        tradeId = _createTradeSingle(proposedAsset, proposedAmount, 0, askedAsset, askedAmount, tokenId, deadline, AssetType.ERC20, AssetType.ERC1155);   
    }

    function createTradeBNBto1155(address askedAsset, uint tokenId, uint askedAmount, uint deadline) payable external returns (uint tradeId) {
        require(Address.isContract(askedAsset), "P2P: Not contract");
        require(msg.value > 0, "P2P: Zero amount not allowed");
        _requireAllowed721Or1155(askedAsset);
        WBNB.deposit{value: msg.value}();
        tradeId = _createTradeSingle(address(WBNB), msg.value, 0, askedAsset, askedAmount, tokenId, deadline, AssetType.ERC20, AssetType.ERC1155);   
    }



    function createTrade1155To721(address proposedAsset, uint proposedAmount, uint proposedTokenId, address askedAsset, uint tokenId, uint deadline) external returns (uint tradeId) {
        require(Address.isContract(proposedAsset), "P2P: Not contracts");
        require(proposedAmount > 0, "P2P: Zero amount not allowed");
        _requireAllowed721Or1155(askedAsset);
        _requireAllowed721Or1155(proposedAsset);
        IERC1155(proposedAsset).safeTransferFrom(msg.sender, address(this), proposedTokenId, proposedAmount, "");
        tradeId = _createTradeSingle(proposedAsset, proposedAmount, proposedTokenId, askedAsset, 0, tokenId, deadline, AssetType.ERC1155, AssetType.ERC721);   
    }

    function createTrade721to1155(address proposedAsset, uint proposedTokenId, address askedAsset, uint askedAmount, uint askedTokenId, uint deadline) external returns (uint tradeId) {
        require(Address.isContract(proposedAsset), "P2P: Not contracts");
        _requireAllowed721Or1155(askedAsset);
        _requireAllowed721Or1155(proposedAsset);
        IERC721(proposedAsset).safeTransferFrom(msg.sender, address(this), proposedTokenId);
        tradeId = _createTradeSingle(proposedAsset, 0, proposedTokenId, askedAsset, askedAmount, askedTokenId, deadline, AssetType.ERC721, AssetType.ERC1155);   
    }



    function supportTradeSingle(uint tradeId) external lock {
        require(tradeCount >= tradeId && tradeId > 0, "P2P: Invalid trade id");
        TradeSingle storage trade = tradesSingle[tradeId];
        require(trade.status == 0 && trade.deadline > block.timestamp, "P2P: Not active trade");

        if (trade.askedAssetType == AssetType.ERC721) {
            IERC721(trade.askedAsset).safeTransferFrom(msg.sender, trade.initiator, trade.askedTokenId);
        } else if (trade.askedAssetType == AssetType.ERC1155) {
            IERC1155(trade.askedAsset).safeTransferFrom(msg.sender, trade.initiator, trade.askedTokenId, trade.askedAmount, "");
        } else {
            TransferHelper.safeTransferFrom(trade.askedAsset, msg.sender, trade.initiator, trade.askedAmount);
        }
        _supportTradeSingle(tradeId);
    }

    function supportTradeSingleBNB(uint tradeId) payable external lock {
        require(tradeCount >= tradeId && tradeId > 0, "P2P: Invalid trade id");
        TradeSingle storage trade = tradesSingle[tradeId];
        require(trade.status == 0 && trade.deadline > block.timestamp, "P2P: Not active trade");
        require(msg.value >= trade.askedAmount, "P2P: Not enough BNB sent");
        require(trade.askedAsset == address(WBNB), "P2P: ERC20 trade");

        TransferHelper.safeTransferBNB(trade.initiator, trade.askedAmount);
        if (msg.value > trade.askedAmount) TransferHelper.safeTransferBNB(msg.sender, msg.value - trade.askedAmount);
        _supportTradeSingle(tradeId);
    }



    function cancelTrade(uint tradeId) external lock { 
        require(tradeCount >= tradeId && tradeId > 0, "P2P: Invalid trade id");
        require(tradesSingle[tradeId].initiator == msg.sender, "P2P: Not allowed");
        require(tradesSingle[tradeId].status == 0 && tradesSingle[tradeId].deadline > block.timestamp, "P2P: Not active trade");
        
        _cancelTradeOrWithdrawOverdueAssets(tradeId);
        
        tradesSingle[tradeId].status = 2;
        emit CancelTrade(tradeId);
    }

    function cancelTradeOrWithdrawOverdueAssets(uint tradeId) external lock { 
        require(tradeCount >= tradeId && tradeId > 0, "P2P: Invalid trade id");
        require(tradesSingle[tradeId].initiator == msg.sender, "P2P: Not allowed");
        require(tradesSingle[tradeId].status == 0, "P2P: Not active trade");
        
        _cancelTradeOrWithdrawOverdueAssets(tradeId);

        tradesSingle[tradeId].status = 5;
        emit CancelOrWithdrawOverdueAssetTrade(tradeId);
    }



    function withdrawOverdueAssetSingle(uint tradeId) external lock { 
        require(tradeCount >= tradeId && tradeId > 0, "P2P: Invalid trade id");
        TradeSingle storage trade = tradesSingle[tradeId];
        require(trade.initiator == msg.sender, "P2P: Not allowed");
        require(trade.status == 0 && trade.deadline < block.timestamp, "P2P: Not available for withdrawal");

        _cancelTradeOrWithdrawOverdueAssets(tradeId);

        trade.status = 3;
        emit WithdrawOverdueAsset(tradeId);
    }
    


    function onERC721Received(address operator, address from, uint tokenId, bytes memory data) external pure returns (bytes4) {
        return 0x150b7a02;
    }

    function state(uint tradeId) public view returns (TradeState) { //TODO
        require(tradeCount >= tradeId && tradeId > 0, "P2P: Invalid trade id");
        TradeSingle storage trade = tradesSingle[tradeId];
        if (trade.status == 1) {
            return TradeState.Succeeded;
        } else if (trade.status == 2 || trade.status == 3 || trade.status == 5) {
            return TradeState(trade.status);
        } else if (trade.deadline < block.timestamp) {
            return TradeState.Overdue;
        } else {
            return TradeState.Active;
        }
    }

    function userTrades(address user) public view returns (uint[] memory) {
        return _userTrades[user];
    }

    function _requireAllowed721Or1155(address nftContract) private view {
        require(isAnyNFTAllowed || allowedNFT[nftContract], "P2P: Not allowed NFT");
    }

    function _createTradeSingle(
        address proposedAsset, 
        uint proposedAmount, 
        uint proposedTokenId, 
        address askedAsset, 
        uint askedAmount, 
        uint askedTokenId, 
        uint deadline, 
        AssetType proposedAssetType,
        AssetType askedAssetType
    ) private returns (uint tradeId) { 
        require(askedAsset != proposedAsset, "P2P: Asked asset can not be equal to proposed asset");
        require(deadline > block.timestamp, "P2P: Incorrect deadline");
        tradeId = ++tradeCount;
        
        TradeSingle storage trade = tradesSingle[tradeId];
        trade.initiator = msg.sender;
        trade.proposedAsset = proposedAsset;
        if (proposedAmount > 0) trade.proposedAmount = proposedAmount;
        if (proposedTokenId > 0) trade.proposedTokenId = proposedTokenId;
        trade.askedAsset = askedAsset;
        if (askedAmount > 0) trade.askedAmount = askedAmount;
        if (askedTokenId > 0) trade.askedTokenId = askedTokenId;
        trade.deadline = deadline;
        trade.proposedAssetType = proposedAssetType; 
        trade.askedAssetType = askedAssetType; 
        
        _userTrades[msg.sender].push(tradeId);        
        emit NewTradeSingle(msg.sender, proposedAsset, proposedAmount, proposedTokenId, askedAsset, askedAmount, askedTokenId, deadline, tradeId);
    }

    function _supportTradeSingle(uint tradeId) private { 
        TradeSingle memory trade = tradesSingle[tradeId];
        
        if (trade.proposedAssetType == AssetType.ERC721) {
            IERC721(trade.proposedAsset).transferFrom(address(this), msg.sender, trade.proposedTokenId);
        } else if (trade.proposedAssetType == AssetType.ERC1155) {
            IERC1155(trade.proposedAsset).safeTransferFrom(address(this), msg.sender, trade.proposedTokenId, trade.proposedAmount, "");
        } else if (trade.proposedAsset != address(WBNB)) {
            TransferHelper.safeTransfer(trade.proposedAsset, msg.sender, trade.proposedAmount);
        } else {
            WBNB.withdraw(trade.proposedAmount);
            TransferHelper.safeTransferBNB(msg.sender, trade.proposedAmount);
        }
        
        tradesSingle[tradeId].counterparty = msg.sender;
        tradesSingle[tradeId].status = 1;
        emit SupportTrade(tradeId, msg.sender);
    }
    
    function _cancelTradeOrWithdrawOverdueAssets(uint tradeId) internal { 
        TradeSingle memory trade = tradesSingle[tradeId];

        if (trade.proposedAssetType == AssetType.ERC721) {
            IERC721(trade.proposedAsset).transferFrom(address(this), trade.initiator, trade.proposedTokenId);
        } else if (trade.proposedAssetType == AssetType.ERC1155) {
            IERC1155(trade.proposedAsset).safeTransferFrom(address(this), trade.initiator, trade.proposedTokenId, trade.proposedAmount, "");
        } else if (trade.proposedAsset != address(WBNB)) {
            TransferHelper.safeTransfer(trade.proposedAsset, trade.initiator, trade.proposedAmount);
        } else {
            WBNB.withdraw(trade.proposedAmount);
            TransferHelper.safeTransferBNB(trade.initiator, trade.proposedAmount);
        }
    }



    function cancelTradeOrWithdrawOverdueAssetsFor(uint tradeId) external lock onlyOwner { 
        require(tradeCount >= tradeId && tradeId > 0, "P2P: Invalid trade id");
        require(tradesSingle[tradeId].status == 0, "P2P: Not active trade");
        
        _cancelTradeOrWithdrawOverdueAssets(tradeId);
        
        tradesSingle[tradeId].status = 5;
        emit CancelOrWithdrawOverdueAssetTrade(tradeId);
    }

    function toggleAnyNFTAllowed() external onlyOwner {
        isAnyNFTAllowed = !isAnyNFTAllowed;
        emit UpdateIsAnyNFTAllowed(isAnyNFTAllowed);
    }

    function updateAllowedNFT(address nft, bool isAllowed) external onlyOwner {
        require(Address.isContract(nft), "P2P: Not a contract");
        allowedNFT[nft] = isAllowed;
        emit UpdateAllowedNFT(nft, isAllowed);
    }
}