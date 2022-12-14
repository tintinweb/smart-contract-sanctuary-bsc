/**
 *Submitted for verification at BscScan.com on 2022-12-14
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Counters.sol


// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
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
    function hasRole(bytes32 role, address user) external view returns (bool);
    function checkKey(bytes32 accessKey) external view returns(bool);
    function usedHash(bytes32 hash_) external view returns (bool);
    function useSignature(bytes32 hashSign) external;
    function roundRobinMember(bytes32 role, uint256 index) external view returns (address);
    function roundRobinMemberCount(bytes32 role) external view returns (uint256);
}
// File: Libraries/constant/EBSAddress.sol


pragma solidity 0.8.2;



abstract contract EBSAddress {
    IEBSControl constant public EBS_CONTROL = IEBSControl(0xEad382916F2960fD8a04E76D50144688C70b1207);
    address constant public EBS_MARKETPLACE = 0x484c51fFd89DB203Ea9f1F07F605863121879088;
    address constant public EBS_PREORDER = 0xEc6862A77b162FCb558EC968A91810717FF4d6d0;
    IERC20Wrapper constant public EBS_WRAPPER1 = IERC20Wrapper(payable(0x481496565dd08462D8FfEaA6Bea910A234cdA216));
    IERC20Wrapper constant public EBS_WRAPPER2 = IERC20Wrapper(payable(0x0e61a0287C07C11b991aF8294B3a3F0ad89428CD));
    address constant public EBS_ZK_CLONE_FACOTRY = 0xBE8ed2602fF818715938e2C45d3f312a45Dda8F5;
    address constant public EBS_ZK_MANAGER = 0xB73fC80Fc1BF81c6EBdb2fd63e2A10dD631cc5F9;
    address constant public EBS_ZK_MANAGER_CALLER = 0xF86F726B5A44778FB573A593ea48Fae9F28c620c;
    address constant public EBS_CHAIN_MANAGER = 0x5a1024eB65289f68acb704c5260A1312165a3d50;
}
// File: Libraries/control/EBSModifier.sol


pragma solidity 0.8.2;



abstract contract EBSModifier is EBSAddress, Pausable {
    modifier onlyAdmin() {
        require(EBS_CONTROL.hasRole(keccak256("ADMIN_ROLE"), msg.sender), "EBSModifier: Must have ADMIN_ROLE");
        _;
    }

    modifier onlyOperator() {
        require(
            EBS_CONTROL.hasRole(keccak256("ADMIN_ROLE"), msg.sender) ||
            EBS_CONTROL.hasRole(keccak256("OPERATOR_ROLE"), msg.sender), 
            "EBSModifier: Must have OPERATOR_ROLE"
        );
        _;
    }

    modifier onlyZKOperator() {
        require(
            EBS_CONTROL.hasRole(keccak256("ADMIN_ROLE"), msg.sender) ||
            EBS_CONTROL.hasRole(keccak256("ZK_OPERATOR_ROLE"), msg.sender), 
            "EBSModifier: Must have ZK_OPERATOR_ROLE"
        );
        _;
    }

    modifier onlyWhitelistUser() {
        require(EBS_CONTROL.hasRole(keccak256("WHITELIST_USER"), msg.sender), "EBSModifier: Whitelist user");
        _;
    }

    modifier notBlacklistUser() {
        require(!(EBS_CONTROL.hasRole(keccak256("BLACKLIST_USER"), msg.sender)), "EBSModifier: Blacklist user");
        _;
    }

    modifier onlyFromManagerCaller(){
        require(EBS_CONTROL.hasRole(keccak256("ADMIN_ROLE"), msg.sender) || msg.sender == EBS_ZK_MANAGER_CALLER, "EBSModifier: Invalid caller");
        _;
    }

    function pause() external whenNotPaused{
        require(EBS_CONTROL.hasRole(keccak256("ADMIN_ROLE"), msg.sender), "EBSModifier: Must have ADMIN_ROLE");
        _pause();
    }

    function unpause() external whenPaused{
        require(EBS_CONTROL.hasRole(keccak256("ADMIN_ROLE"), msg.sender), "EBSModifier: Must have ADMIN_ROLE");
        _unpause();
    }
}
// File: @openzeppelin/contracts/utils/Create2.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/Create2.sol)

pragma solidity ^0.8.0;

/**
 * @dev Helper to make usage of the `CREATE2` EVM opcode easier and safer.
 * `CREATE2` can be used to compute in advance the address where a smart
 * contract will be deployed, which allows for interesting new mechanisms known
 * as 'counterfactual interactions'.
 *
 * See the https://eips.ethereum.org/EIPS/eip-1014#motivation[EIP] for more
 * information.
 */
library Create2 {
    /**
     * @dev Deploys a contract using `CREATE2`. The address where the contract
     * will be deployed can be known in advance via {computeAddress}.
     *
     * The bytecode for a contract can be obtained from Solidity with
     * `type(contractName).creationCode`.
     *
     * Requirements:
     *
     * - `bytecode` must not be empty.
     * - `salt` must have not been used for `bytecode` already.
     * - the factory must have a balance of at least `amount`.
     * - if `amount` is non-zero, `bytecode` must have a `payable` constructor.
     */
    function deploy(
        uint256 amount,
        bytes32 salt,
        bytes memory bytecode
    ) internal returns (address) {
        address addr;
        require(address(this).balance >= amount, "Create2: insufficient balance");
        require(bytecode.length != 0, "Create2: bytecode length is zero");
        /// @solidity memory-safe-assembly
        assembly {
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Create2: Failed on deploy");
        return addr;
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy}. Any change in the
     * `bytecodeHash` or `salt` will result in a new destination address.
     */
    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address) {
        return computeAddress(salt, bytecodeHash, address(this));
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy} from a contract located at
     * `deployer`. If `deployer` is this contract's address, returns the same value as {computeAddress}.
     */
    function computeAddress(
        bytes32 salt,
        bytes32 bytecodeHash,
        address deployer
    ) internal pure returns (address) {
        bytes32 _data = keccak256(abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash));
        return address(uint160(uint256(_data)));
    }
}

// File: Libraries/utils/CloneFactory.sol


pragma solidity 0.8.2;


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

    function create2Clone(
        address target, 
        uint256 salt
    ) internal returns (address result) {
        result = Create2.deploy(0,keccak256(abi.encodePacked(salt)),getContractCreationCode(target));
    }

    function getContractCreationCode(
        address logic
    ) internal pure returns (bytes memory) {
        bytes10 creation = 0x3d602d80600a3d3981f3;
        bytes10 prefix = 0x363d3d373d3d3d363d73;
        bytes20 targetBytes = bytes20(logic);
        bytes15 suffix = 0x5af43d82803e903d91602b57fd5bf3;
        return abi.encodePacked(creation, prefix, targetBytes, suffix);
    }

    function computeAddress(
        address implementation,
        uint256 salt
    ) internal view returns (address){
        return Create2.computeAddress(keccak256(abi.encodePacked(salt)), keccak256(getContractCreationCode(implementation)), address(this));
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
// File: @openzeppelin/contracts/utils/StorageSlot.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

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
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }
}

// File: Libraries/proxy/EBSInitializedProxy.sol


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
// File: Ownership/EBSOwnershipCloneFactory.sol


pragma solidity 0.8.2;





contract EBSOwnershipCloneFactory is CloneFactory, EBSModifier {
    using Counters for Counters.Counter;
    InitializedProxy[] private  _assets;
    address private _ownershipLogicAddress;
    address private _initializedProxyLogicAddress;
    Counters.Counter private _salt;

    event NewAsset(
        address indexed asset, 
        address indexed creator
    );

    function setOwnershipLogic(address logic) external onlyAdmin {
        _ownershipLogicAddress = logic;
    }

    function setInitializedProxyLogic(address logic) external onlyAdmin {
        _initializedProxyLogicAddress = logic;
    }

    function currentSalt() external view returns (uint256){
        return _salt.current();
    }

    function predictAsset(uint256 salt) external view returns (address){
        return computeAddress(_initializedProxyLogicAddress, salt);
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

        _salt.increment();

        InitializedProxy asset = InitializedProxy(
            payable(
                create2Clone(_initializedProxyLogicAddress, _salt.current())
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