/**
 *Submitted for verification at BscScan.com on 2022-09-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
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
// File: product/EBSInitializedProxy.sol


pragma solidity 0.8.2;



contract InitializedProxy {
    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    function initialize(
        address logic,
        bytes memory initializationCalldata
    ) external {
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = logic;
        // Delegatecall into the logic contract, supplying initialization calldata
        (bool success, bytes memory returnData) =  StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value.delegatecall(initializationCalldata);
        // // Revert if delegatecall to implementation reverts
        require(success, string(returnData));
    }

    fallback() external payable {
        address _impl = StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
                case 0 {
                    revert(ptr, size)
                }
                default {
                    return(ptr, size)
                }
        }
    }

    receive() external payable {} // solhint-disable-line no-empty-blocks
}
// File: product/EBSCloneFactory.sol


pragma solidity ^0.8.2;

abstract contract CloneFactory {
    function createClone(address target) internal returns (address result) {
        bytes20 targetBytes = bytes20(target);
        assembly {
        let clone := mload(0x40)
        mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
        mstore(add(clone, 0x14), targetBytes)
        mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
        result := create(0, clone, 0x37)
        }
    }

    function isClone(address target, address query) internal view returns (bool result) {
        bytes20 targetBytes = bytes20(target);
        assembly {
        let clone := mload(0x40)
        mstore(clone, 0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000)
        mstore(add(clone, 0xa), targetBytes)
        mstore(add(clone, 0x1e), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

        let other := add(clone, 0x40)
        extcodecopy(query, other, 0, 0x2d)
        result := and(
            eq(mload(clone), mload(other)),
            eq(mload(add(clone, 0xd)), mload(add(other, 0xd)))
        )
        }
    }
}


// File: product/EBSZKCloneFactory.sol


pragma solidity 0.8.2;




contract EBSZKCloneFactory is CloneFactory, EBSPauser {
    InitializedProxy[] private  _assets;
    address private _ownershipLogicAddress;
    address private _initializedProxyLogicAddress;
    
    event NewAsset(
        address asset, 
        address creator
    );

    modifier onlyZKOperator() {
        require(EBS_CONTROL.isZKOperator(msg.sender), "ZK-Factory: Must have ZK_OPERATOR_ROLE");
        _;
    }

    modifier onlyAdmin() {
        require(EBS_CONTROL.isAdmin(msg.sender), "ZK-Factory: Must have ZK_OPERATOR_ROLE");
        _;
    }

    function setOwnershipLogic(address logic) external onlyAdmin {
        _ownershipLogicAddress = logic;
    }

    function setInitializedProxyLogic(address logic) external onlyAdmin {
        _initializedProxyLogicAddress = logic;
    }

    function newAssets(
        bytes[] calldata ownerSignatures,
        address[] memory tokens,
        uint8[] memory tokenTypes,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external onlyZKOperator whenNotPaused returns (address[] memory) {
        require(
            ownerSignatures.length == tokens.length &&
            ownerSignatures.length == tokenTypes.length &&
            ownerSignatures.length == ids.length &&
            ownerSignatures.length == amounts.length,
            "Marketplace: Length mismatch"
        );

        address[] memory assets = new address[](ownerSignatures.length);

        for (uint8 i; i < ownerSignatures.length ; i++){
            assets[i] = newAsset(ownerSignatures[i], tokens[i], tokenTypes[i], ids[i], amounts[i]);
        }

        return assets;
    }

    function newAsset(
        bytes calldata ownerSignature,
        address token,
        uint8 tokenType,
        uint256 id,
        uint256 amounts
    ) public onlyZKOperator whenNotPaused returns (address) {
        if (tokenType == 0 || tokenType == 2) require (id == 0, "EBSCloneFacotry: Invalid id");
        if (tokenType == 3 || tokenType == 4) require (amounts == 1, "EBSCloneFacotry: Invalid amounts");

        bytes memory _initializationCalldata =
        abi.encodeWithSignature(
            "initialize(bytes,address,uint8,uint256,uint256)",
            ownerSignature,
            token,
            tokenType,
            id,
            amounts
        );

        InitializedProxy asset = InitializedProxy(
            payable(
                createClone(_initializedProxyLogicAddress)
            )
        );

        asset.initialize(
            _ownershipLogicAddress, 
            _initializationCalldata
        );

        _assets.push(asset);

        emit NewAsset(
            address(asset), 
            msg.sender
        );

        return address(asset);
    }

    function deployedAssets() public view returns (InitializedProxy[] memory asset) {
        return _assets;
    }  
}