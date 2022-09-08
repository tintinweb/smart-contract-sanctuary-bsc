/**
 *Submitted for verification at BscScan.com on 2022-09-08
*/

// SPDX-License-Identifier: MIT
// File: product/IEBSZKOwnership.sol


pragma solidity 0.8.2;

interface IEBSZKOwnership {
    function activate() external;
    function changeKey(bytes calldata newSignature, bytes32 key) external;
    function withdraw (address receiver,bytes32 key) external;     
    function ownerSignature(bytes32 key) external view returns(bytes memory);
    function token(bytes32 key) external view  returns(address);
    function tokenType(bytes32 key) external view  returns(uint8);
    function id(bytes32 key) external view  returns(uint256);
    function amounts(bytes32 key) external view  returns(uint256);
    function activated(bytes32 key) external view  returns(bool);
}

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
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
        _;
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

pragma solidity ^0.8.0;


// File: product/IERC20Wrapper.sol


pragma solidity 0.8.2;


interface IERC20Wrapper is IERC1155 {
  receive () external payable;

  function getTokenID(address _token) external view returns (uint256 tokenID);
  function getIdAddress(uint256 _id) external view returns (address token) ;
  function getNTokens() external view;
  function onERC1155Received(address _operator, address payable _from, uint256 _id, uint256 _value, bytes calldata _data ) external returns(bytes4);
  function onERC1155BatchReceived(address _operator, address payable _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external returns(bytes4);
}
// File: product/IEBSControl.sol


pragma solidity 0.8.2;

interface IEBSControl {
    function checkSignerValidSignature(bytes calldata sign, bytes32 messages) external returns (bool);
    function checkUserValidSignature(bytes calldata sign, bytes32 messages, address user) external view returns (bool);
    function isAdmin(address user) external view returns (bool);
    function isOperator(address user) external view returns (bool);
    function isZKOperator(address user) external view returns (bool);
    function isBlacklistUser(address user) external view returns (bool);
    function isWhitelistUser(address user) external view returns (bool);
    function checkKey(bytes32 accessKey) external view returns(bool);
    function usedHash(bytes32 hash_) external view returns (bool);
    function useSignature(bytes32 hashSign) external;
}
// File: product/EBSAddress.sol


pragma solidity 0.8.2;



abstract contract EBSAddress {
    address constant public EBS_MARKETPLACE = 0x484c51fFd89DB203Ea9f1F07F605863121879088;
    address constant public EBS_PREORDER = 0xEc6862A77b162FCb558EC968A91810717FF4d6d0;
    IEBSControl constant public EBS_CONTROL = IEBSControl(0xEad382916F2960fD8a04E76D50144688C70b1207);
    IERC20Wrapper constant public EBS_WRAPPER1 = IERC20Wrapper(payable(0x481496565dd08462D8FfEaA6Bea910A234cdA216));
    IERC20Wrapper constant public EBS_WRAPPER2 = IERC20Wrapper(payable(0x0e61a0287C07C11b991aF8294B3a3F0ad89428CD));
    address constant public EBS_ZK_CLONE_FACOTRY = 0xBE8ed2602fF818715938e2C45d3f312a45Dda8F5;
    address constant public EBS_ZK_MANAGER = 0xB73fC80Fc1BF81c6EBdb2fd63e2A10dD631cc5F9;
    address constant public EBS_ZK_MARKETPLACE = 0xF86F726B5A44778FB573A593ea48Fae9F28c620c;
}
// File: product/EBSPauser.sol


pragma solidity ^0.8.2;



abstract contract EBSPauser is EBSAddress, Pausable {
    function pause() external whenNotPaused{
        require(EBS_CONTROL.isAdmin(msg.sender), "MarketplaceOrder: Must have ADMIN_ROLE");
        _pause();
    }

    function unpause() external whenPaused{
        require(EBS_CONTROL.isAdmin(msg.sender), "MarketplaceOrder: Must have ADMIN_ROLE");
        _unpause();
    }
}
// File: product/EBSZKMarketplace.sol


pragma solidity 0.8.2;



contract EBSZKMarketplace is EBSPauser {
    mapping (bytes32 => address) private _paymentToken;
    mapping (bytes32 => address) private _product;
    mapping (bytes32 => uint8) private _paymentType;
    mapping (bytes32 => uint256) private _paymentAmounts;

    event MatchOrder(
        address indexed product,
        address indexed payment,
        address indexed caller
    );

    event Revoke(
        bytes32 indexed secretKey,
        address indexed revoker
    );

    event List(
        bytes32 indexed secretKey,
        address indexed product,
        address indexed caller
    );

    modifier onlyZKOperator() {
        require(EBS_CONTROL.isZKOperator(msg.sender), "EBS-ZKMarketplace: Must have ZK_OPERATOR_ROLE");
        _;
    }

    function viewOrder(
        bytes32 secretKey
    ) external view returns(
        address paymentToken,
        uint8 paymentType,
        uint256 paymentAmounts
    ){
      return(
        _paymentToken[secretKey],
        _paymentType[secretKey],
        _paymentAmounts[secretKey]
      );
    }

    function lists(
        address[] memory paymentTokens,
        address[] memory products,
        uint8[] memory paymentTypes,
        uint256[] memory paymentAmountss,
        bytes32[] memory secretKeys
    ) external whenNotPaused onlyZKOperator {
        require(
            products.length == paymentTokens.length &&
            products.length == paymentTypes.length &&
            products.length == paymentAmountss.length &&
            products.length == secretKeys.length,
            "EBS-ZKMarketplace: Length mismatch"
        );

        for (uint256 i; i < products.length ; i++){
            list(paymentTokens[i], products[i], paymentTypes[i], paymentAmountss[i], secretKeys[i]);
        }
    }

    function list(
        address paymentToken,
        address product,
        uint8 paymentType,
        uint256 paymentAmounts,
        bytes32 secretKey
    ) public whenNotPaused onlyZKOperator{
        _paymentToken[secretKey] = paymentToken;
        _product[secretKey] = product;
        _paymentType[secretKey] = paymentType;

        if (paymentType == 3 || paymentType == 4){
            require(paymentAmounts == 1, "EBS-ZKMarketplace: Invalid amounts");
        }
        
        _paymentAmounts[secretKey] = paymentAmounts;

        emit List(secretKey, product, msg.sender);
    }

    function matchOrders(
        address[] memory payments,
        bytes32[] memory secretKeys,
        bytes32 key
    ) external whenNotPaused onlyZKOperator{
        require(payments.length == secretKeys.length, "EBS-ZKMarketplace: Length mismatch");

        for (uint256 i; i < payments.length ; i++){
            matchOrder(payments[i], secretKeys[i], key);
        }
    }

    function matchOrder(
        address payment,
        bytes32 secretKey,
        bytes32 key
    ) public whenNotPaused onlyZKOperator{
        require(_product[secretKey] != address(0), "EBS-ZKMarketplace: Invalid product");
        require(IEBSZKOwnership(payment).activated(key), "EBS-ZKMarketplace: Item deactivated");

        require(
            IEBSZKOwnership(payment).tokenType(key) == _paymentType[secretKey] &&
            IEBSZKOwnership(payment).token(key) == _paymentToken[secretKey] &&
            IEBSZKOwnership(payment).amounts(key) == _paymentAmounts[secretKey],
            "EBS-ZKMarketplace: Invalid payment"
        );

        bytes memory paymentKey = IEBSZKOwnership(payment).ownerSignature(key);
        bytes memory productKey = IEBSZKOwnership(_product[secretKey]).ownerSignature(key);

        IEBSZKOwnership(_product[secretKey]).changeKey(paymentKey,key);
        IEBSZKOwnership(payment).changeKey(productKey,key);

        emit MatchOrder(_product[secretKey], payment, msg.sender);
    }

    function revokes(
        bytes32[] memory secretKeys
    ) external onlyZKOperator{
        for (uint256 i; i < secretKeys.length ; i++){
            revoke(secretKeys[i]);
        }
    }

    function revoke(
        bytes32 secretKey
    ) public onlyZKOperator{
        _paymentToken[secretKey] = address(0);
        _product[secretKey] = address(0);
        _paymentType[secretKey] = 0;
        _paymentAmounts[secretKey] = 0;

        emit Revoke(secretKey, msg.sender);
    }
}