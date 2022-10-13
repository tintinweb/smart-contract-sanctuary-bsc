/**
 *Submitted for verification at BscScan.com on 2022-10-13
*/

// SPDX-License-Identifier: MIT

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

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: Offchain/IEBSChainManager.sol


pragma solidity 0.8.2;

interface IEBSChainManager {
    function currentBlock() external view returns (uint256);
    function header(uint256 blockNumber) external view returns(bytes32 previousHash, bytes32 merkleRoot, bytes32 r, bytes32 s, uint8 v, uint256 timeSubmitted);
    function verifyTxData(uint256 blockNumber, bytes32 txRoot, bytes32 leaf, bytes32[] memory proof) external view returns (bool);
    function verifyTxRoot(uint256 blockNumber, bytes32 leaf, bytes32[] memory proof) external view returns (bool);
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


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

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
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
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

// File: @openzeppelin/contracts/interfaces/IERC1155.sol


// OpenZeppelin Contracts v4.4.1 (interfaces/IERC1155.sol)

pragma solidity ^0.8.0;


// File: Marketplace/IERC20Wrapper.sol


pragma solidity 0.8.2;


interface IERC20Wrapper is IERC1155 {
  receive () external payable;

  function getTokenID(address _token) external view returns (uint256 tokenID);
  function getIdAddress(uint256 _id) external view returns (address token) ;
  function getNTokens() external view;
  function onERC1155Received(address _operator, address payable _from, uint256 _id, uint256 _value, bytes calldata _data ) external returns(bytes4);
  function onERC1155BatchReceived(address _operator, address payable _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external returns(bytes4);
}
// File: Libraries/control/IEBSControl.sol


pragma solidity 0.8.2;

interface IEBSControl {
    function checkSignerValidSignature(bytes calldata sign, bytes32 messages) external returns (bool);
    function checkUserValidSignature(bytes calldata sign, bytes32 messages, address user) external view returns (bool);
    function isAdmin(address user) external view returns (bool);
    function isMinter(address user) external view returns (bool);
    function isOperator(address user) external view returns (bool);
    function isZKOperator(address user) external view returns (bool);
    function isBlacklistUser(address user) external view returns (bool);
    function isWhitelistUser(address user) external view returns (bool);
    function checkKey(bytes32 accessKey) external view returns(bool);
    function usedHash(bytes32 hash_) external view returns (bool);
    function useSignature(bytes32 hashSign) external;
}
// File: Libraries/constant/EBSAddress.sol


pragma solidity 0.8.2;




abstract contract EBSAddress {
    address constant public EBS_MARKETPLACE = 0x484c51fFd89DB203Ea9f1F07F605863121879088;
    address constant public EBS_PREORDER = 0xEc6862A77b162FCb558EC968A91810717FF4d6d0;
    IEBSControl constant public EBS_CONTROL = IEBSControl(0xEad382916F2960fD8a04E76D50144688C70b1207);
    IERC20Wrapper constant public EBS_WRAPPER1 = IERC20Wrapper(payable(0x481496565dd08462D8FfEaA6Bea910A234cdA216));
    IERC20Wrapper constant public EBS_WRAPPER2 = IERC20Wrapper(payable(0x0e61a0287C07C11b991aF8294B3a3F0ad89428CD));
    address constant public EBS_ZK_CLONE_FACOTRY = 0xBE8ed2602fF818715938e2C45d3f312a45Dda8F5;
    address constant public EBS_ZK_MANAGER = 0xB73fC80Fc1BF81c6EBdb2fd63e2A10dD631cc5F9;
    address constant public EBS_ZK_MANAGER_CALLER = 0xF86F726B5A44778FB573A593ea48Fae9F28c620c;
    IEBSChainManager constant public EBS_CHAIN_MANAGER = IEBSChainManager(0x5a1024eB65289f68acb704c5260A1312165a3d50);
}
// File: Libraries/control/EBSPauser.sol


pragma solidity 0.8.2;



abstract contract EBSPauser is EBSAddress, Pausable {
    modifier notBlacklistUser() {
        require(!(EBS_CONTROL.isBlacklistUser(msg.sender)), "EBSPauser: Blacklist user");
        _;
    }

    modifier onlyWhitelistUser() {
        require(EBS_CONTROL.isWhitelistUser(msg.sender), "EBSPauser: Not Whitelist user");
        _;
    }

    modifier onlyOperator() {
        require(EBS_CONTROL.isOperator(msg.sender), "EBSPauser: Must have OPERATOR_ROLE");
        _;
    }

    modifier onlyZKOperator() {
        require(EBS_CONTROL.isZKOperator(msg.sender), "EBSPauser: Must have ZK_OPERATOR_ROLE");
        _;
    }

    modifier onlyMinter() {
        require(EBS_CONTROL.isMinter(msg.sender), "EBSPauser: Must have MINTER_ROLE");
        _;
    }

    modifier onlyAdmin() {
        require(EBS_CONTROL.isAdmin(msg.sender), "EBSPauser: Must have ADMIN_ROLE");
        _;
    }

    modifier onlyFromManagerCaller(){
        require(EBS_CONTROL.isAdmin(msg.sender) || msg.sender == EBS_ZK_MANAGER_CALLER, "EBSPauser: Invalid caller");
        _;
    }

    function pause() external whenNotPaused{
        require(EBS_CONTROL.isAdmin(msg.sender), "EBSPauser: Must have ADMIN_ROLE");
        _pause();
    }

    function unpause() external whenPaused{
        require(EBS_CONTROL.isAdmin(msg.sender), "EBSPauser: Must have ADMIN_ROLE");
        _unpause();
    }
}
// File: ZeroKnowledgeProof/EBSManagerCaller.sol


pragma solidity 0.8.2;


contract EBSManagerCaller is EBSPauser {
    event Response(
        bool success, 
        bytes data
    );

    function sendMessages(bytes[] calldata messages) external whenNotPaused onlyZKOperator {
        for (uint256 i; i < messages.length; i++){
            sendMessage(messages[i]);
        }
    }

    function sendMessage(bytes memory message) public whenNotPaused onlyZKOperator {
        (bool success, bytes memory returnData) = EBS_ZK_MANAGER.call(message);

        require(success, "EBSManagerCaller: call data failed");

        emit Response(success, returnData);
    }
}