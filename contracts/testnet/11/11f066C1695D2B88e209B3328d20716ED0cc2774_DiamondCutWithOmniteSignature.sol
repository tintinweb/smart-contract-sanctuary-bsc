// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IDiamondCutv2} from "../../../../interfaces/diamond/IDiamondCutv2.sol";
import {LibDiamondv2} from "../../../../libraries/diamond/LibDiamondv2.sol";
import {LibAccessControlListv2} from "../libraries/LibAccessControlListv2.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../interfaces/IDiamondCutWithOmniteSignature.sol";
import {LibMeta} from "../../../../libraries/diamond/LibMeta.sol";

// solhint-disable no-empty-blocks
contract DiamondCutWithOmniteSignature is
    IDiamondCutWithOmnitSignature,
    IDiamondCutv2
{
    using ECDSA for bytes32;
    bytes32 public constant CUT_EXECUTOR_ROLE = keccak256("CUT_EXECUTOR_ROLE");

    bytes32 internal constant EIP712_DOMAIN_HASH =
        keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name, string version, address verifyingContract, uint256 signedAt)"
                )
            )
        );

    modifier onlyExecutorRole() {
        _ensureHasCutExecutorRole(LibMeta.msgSender());
        _;
    }

    function encode(address[] calldata addresses)
        external
        pure
        override
        returns (bytes memory)
    {
        return abi.encode(addresses);
    }

    function initialize(bytes calldata initBytes) external payable override {
        address[] memory addresses = abi.decode(initBytes, (address[]));
        uint256 length = addresses.length;
        for (uint256 i = 0; i < length; ++i) {
            LibAccessControlListv2.grantRole(CUT_EXECUTOR_ROLE, addresses[i]);
        }
    }

    function cleanUp() external payable override {}

    function getDiamondCutWithSignatureHash(DiamondCutData calldata _data)
        public
        view
        override
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    uint16(0x1901),
                    EIP712_DOMAIN_HASH,
                    address(this),
                    keccak256(
                        abi.encode(
                            "diamondCutWitSignature(DiamondCutData calldata _data, bytes calldata _signature)",
                            _data
                        )
                    )
                )
            );
    }

    function _ensureHasCutExecutorRole(address addr) internal view {
        // solhint-disable-next-line reason-string
        require(
            LibAccessControlListv2.hasRole(CUT_EXECUTOR_ROLE, addr),
            "Account without CUT_EXECUTOR_ROLE"
        );
    }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override onlyExecutorRole {
        LibDiamondv2.enforceIsContractOwner();
        LibDiamondv2.diamondCut(_diamondCut, _init, _calldata);
    }

    function diamondCutWithoutInit(FacetCut[] calldata _diamondCut)
        external
        override
        onlyExecutorRole
    {
        LibDiamondv2.diamondCutWithoutInit(_diamondCut);
    }

    function diamondCutInitializable(
        FacetCutInitializable[] calldata _diamondCutInitializable,
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override onlyExecutorRole {
        LibDiamondv2.diamondCutInitializable(
            _diamondCutInitializable,
            _diamondCut,
            _init,
            _calldata
        );
    }

    function diamondCutInitilizableWithoutInit(
        FacetCutInitializable[] calldata _diamondCutInitializable,
        FacetCut[] calldata _diamondCut
    ) external override onlyExecutorRole {
        LibDiamondv2.diamondCutInitializableWithoutInit(
            _diamondCutInitializable,
            _diamondCut
        );
    }

    function diamondCutWitSignature(
        DiamondCutData calldata _data,
        bytes calldata _signature
    ) external payable override {
        bytes32 messageHash = getDiamondCutWithSignatureHash(_data);

        address signer = messageHash.toEthSignedMessageHash().recover(
            _signature
        );

        _ensureHasCutExecutorRole(signer);

        if (_data.value != msg.value) {
            revert("Wrong value");
        }

        if (block.timestamp > _data.until) {
            revert("Signature expired");
        }

        _data.wallet.transfer(msg.value);

        if (_data.init == address(0)) {
            if (_data.diamondCutInitializable.length == 0) {
                LibDiamondv2.diamondCutWithoutInit(_data.diamondCut);
            } else {
                LibDiamondv2.diamondCutInitializableWithoutInit(
                    _data.diamondCutInitializable,
                    _data.diamondCut
                );
            }
        } else {
            if (_data.diamondCutInitializable.length == 0) {
                LibDiamondv2.diamondCut(
                    _data.diamondCut,
                    _data.init,
                    _data._calldata
                );
            } else {
                LibDiamondv2.diamondCutInitializable(
                    _data.diamondCutInitializable,
                    _data.diamondCut,
                    _data.init,
                    _data._calldata
                );
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IDiamondCutv2 {
    enum FacetCutAction {
        Add,
        Replace,
        Remove
    }

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    struct FacetCutInitializable {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
        bytes initializeBytes;
    }

    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
    event DiamondCutInitializable(
        FacetCutInitializable[] _diamondCutInitializable,
        FacetCut[] _diamondCut,
        address _init,
        bytes _calldata
    );

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external;

    function diamondCutInitializable(
        FacetCutInitializable[] calldata _diamondCutInitializable,
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external;

    function diamondCutWithoutInit(FacetCut[] calldata _diamondCut) external;

    function diamondCutInitilizableWithoutInit(
        FacetCutInitializable[] calldata _diamondCutInitializable,
        FacetCut[] calldata _diamondCut
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IDiamondCutv2} from "../../interfaces/diamond/IDiamondCutv2.sol";
import {LibMeta} from "./LibMeta.sol";
import "../../interfaces/IInitializableFacet.sol";

library LibDiamondv2 {
    bytes32 internal constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.diamond.storage");

    struct FacetAddressAndPosition {
        address facetAddress;
        uint96 functionSelectorPosition; // position in facetFunctionSelectors.functionSelectors array
    }

    struct FacetFunctionSelectors {
        bytes4[] functionSelectors;
        uint256 facetAddressPosition; // position of facetAddress in facetAddresses array
    }

    struct DiamondStorage {
        mapping(bytes4 => FacetAddressAndPosition) selectorToFacetAndPosition;
        mapping(address => FacetFunctionSelectors) facetFunctionSelectors;
        address[] facetAddresses;
        mapping(bytes4 => bool) supportedInterfaces;
        address contractOwner;
        address diamondAddress;
    }

    function diamondStorage()
        internal
        pure
        returns (DiamondStorage storage ds)
    {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function setContractOwner(address _newOwner) internal {
        DiamondStorage storage ds = diamondStorage();
        address previousOwner = ds.contractOwner;
        ds.contractOwner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function contractOwner() internal view returns (address contractOwner_) {
        contractOwner_ = diamondStorage().contractOwner;
    }

    function enforceIsContractOwner() internal view {
        require(
            msg.sender == diamondStorage().contractOwner,
            "LibDiamond: Must be contract owner"
        );
    }

    function setDiamondAddress(address diamondAddress) internal {
        diamondStorage().diamondAddress = diamondAddress;
    }

    function owner() internal view returns (address) {
        return diamondStorage().contractOwner;
    }

    // Internal function version of diamondCut
    function diamondCut(
        IDiamondCutv2.FacetCut[] memory _diamondCut,
        address _init,
        bytes memory _calldata
    ) internal {
        handleDiamondCut(_diamondCut);
        initializeDiamondCut(_init, _calldata);
    }

    function diamondCutWithoutInit(IDiamondCutv2.FacetCut[] memory _diamondCut)
        internal
    {
        handleDiamondCut(_diamondCut);
    }

    function diamondCutInitializable(
        IDiamondCutv2.FacetCutInitializable[] memory _diamondCutInitializable,
        IDiamondCutv2.FacetCut[] memory _diamondCut,
        address _init,
        bytes memory _calldata
    ) internal {
        handleDiamondCutInitilizable(_diamondCut, _diamondCutInitializable);
        initializeDiamondCut(_init, _calldata);
    }

    function diamondCutInitializableWithoutInit(
        IDiamondCutv2.FacetCutInitializable[] memory _diamondCutInitializable,
        IDiamondCutv2.FacetCut[] memory _diamondCut
    ) internal {
        handleDiamondCutInitilizable(_diamondCut, _diamondCutInitializable);
    }

    function handleDiamondCutInitilizable(
        IDiamondCutv2.FacetCut[] memory _diamondCut,
        IDiamondCutv2.FacetCutInitializable[] memory _diamondCutInitializable
    ) internal {
        handleDiamondCut(_diamondCut);
        for (
            uint256 facetIndex;
            facetIndex < _diamondCutInitializable.length;
            facetIndex++
        ) {
            IDiamondCutv2.FacetCutAction action = _diamondCutInitializable[
                facetIndex
            ].action;

            if (action == IDiamondCutv2.FacetCutAction.Add) {
                addFunctions(
                    _diamondCutInitializable[facetIndex].facetAddress,
                    _diamondCutInitializable[facetIndex].functionSelectors
                );
            } else if (action == IDiamondCutv2.FacetCutAction.Replace) {
                replaceFunctions(
                    _diamondCutInitializable[facetIndex].facetAddress,
                    _diamondCutInitializable[facetIndex].functionSelectors
                );
            } else if (action == IDiamondCutv2.FacetCutAction.Remove) {
                removeFunctions(
                    _diamondCut[facetIndex].facetAddress,
                    _diamondCut[facetIndex].functionSelectors
                );
            } else {
                revert("LibDiamondCut: Incorrect FacetCutAction");
            }

            bool cleanUp = action == IDiamondCutv2.FacetCutAction.Remove;

            if (cleanUp) {
                (bool success, ) = _diamondCutInitializable[facetIndex]
                    .facetAddress
                    .delegatecall(
                        abi.encodeWithSelector(
                            IInitializableFacet.cleanUp.selector
                        )
                    );

                require(success, "Cleanup Failed");
            } else {
                bytes memory initData = _diamondCutInitializable[facetIndex]
                    .initializeBytes;

                (bool success, ) = _diamondCutInitializable[facetIndex]
                    .facetAddress
                    .delegatecall(
                        abi.encodeWithSelector(
                            IInitializableFacet.initialize.selector,
                            initData
                        )
                    );

                require(success, "Init Failed");
            }
        }
    }

    function handleDiamondCut(IDiamondCutv2.FacetCut[] memory _diamondCut)
        internal
    {
        for (
            uint256 facetIndex;
            facetIndex < _diamondCut.length;
            facetIndex++
        ) {
            IDiamondCutv2.FacetCutAction action = _diamondCut[facetIndex]
                .action;
            if (action == IDiamondCutv2.FacetCutAction.Add) {
                addFunctions(
                    _diamondCut[facetIndex].facetAddress,
                    _diamondCut[facetIndex].functionSelectors
                );
            } else if (action == IDiamondCutv2.FacetCutAction.Replace) {
                replaceFunctions(
                    _diamondCut[facetIndex].facetAddress,
                    _diamondCut[facetIndex].functionSelectors
                );
            } else if (action == IDiamondCutv2.FacetCutAction.Remove) {
                removeFunctions(
                    _diamondCut[facetIndex].facetAddress,
                    _diamondCut[facetIndex].functionSelectors
                );
            } else {
                revert("LibDiamondCut: Incorrect FacetCutAction");
            }
        }
    }

    function addFunctions(
        address _facetAddress,
        bytes4[] memory _functionSelectors
    ) internal {
        require(
            _functionSelectors.length > 0,
            "LibDiamondCut: No selectors in facet to cut"
        );
        DiamondStorage storage ds = diamondStorage();
        require(
            _facetAddress != address(0),
            "LibDiamondCut: Add facet can't be address(0)"
        );
        uint96 selectorPosition = uint96(
            ds.facetFunctionSelectors[_facetAddress].functionSelectors.length
        );
        // add new facet address if it does not exist
        if (selectorPosition == 0) {
            addFacet(ds, _facetAddress);
        }
        for (
            uint256 selectorIndex;
            selectorIndex < _functionSelectors.length;
            selectorIndex++
        ) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds
                .selectorToFacetAndPosition[selector]
                .facetAddress;
            require(
                oldFacetAddress == address(0),
                "LibDiamondCut: Can't add function that already exists"
            );
            addFunction(ds, selector, selectorPosition, _facetAddress);
            selectorPosition++;
        }
    }

    function addFunction(address _facetAddress, bytes4 _selector) internal {
        DiamondStorage storage ds = diamondStorage();
        require(
            _facetAddress != address(0),
            "LibDiamondCut: Add facet can't be address(0)"
        );
        uint96 selectorPosition = uint96(
            ds.facetFunctionSelectors[_facetAddress].functionSelectors.length
        );
        // add new facet address if it does not exist
        if (selectorPosition == 0) {
            addFacet(ds, _facetAddress);
        }

        address oldFacetAddress = ds
            .selectorToFacetAndPosition[_selector]
            .facetAddress;

        require(
            oldFacetAddress == address(0),
            "LibDiamondCut: Can't add function that already exists"
        );
        addFunction(ds, _selector, selectorPosition, _facetAddress);
        selectorPosition++;
    }

    function replaceFunctions(
        address _facetAddress,
        bytes4[] memory _functionSelectors
    ) internal {
        require(
            _functionSelectors.length > 0,
            "LibDiamondCut: No selectors in facet to cut"
        );
        DiamondStorage storage ds = diamondStorage();
        require(
            _facetAddress != address(0),
            "LibDiamondCut: Add facet can't be address(0)"
        );
        uint96 selectorPosition = uint96(
            ds.facetFunctionSelectors[_facetAddress].functionSelectors.length
        );
        // add new facet address if it does not exist
        if (selectorPosition == 0) {
            addFacet(ds, _facetAddress);
        }
        for (
            uint256 selectorIndex;
            selectorIndex < _functionSelectors.length;
            selectorIndex++
        ) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds
                .selectorToFacetAndPosition[selector]
                .facetAddress;
            require(
                oldFacetAddress != _facetAddress,
                "LibDiamondCut: Can't replace function with same function"
            );
            removeFunction(ds, oldFacetAddress, selector);
            addFunction(ds, selector, selectorPosition, _facetAddress);
            selectorPosition++;
        }
    }

    function removeFunctions(
        address _facetAddress,
        bytes4[] memory _functionSelectors
    ) internal {
        require(
            _functionSelectors.length > 0,
            "LibDiamondCut: No selectors in facet to cut"
        );
        DiamondStorage storage ds = diamondStorage();
        // if function does not exist then do nothing and return
        require(
            _facetAddress == address(0),
            "LibDiamondCut: Remove facet address must be address(0)"
        );
        for (
            uint256 selectorIndex;
            selectorIndex < _functionSelectors.length;
            selectorIndex++
        ) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds
                .selectorToFacetAndPosition[selector]
                .facetAddress;
            removeFunction(ds, oldFacetAddress, selector);
        }
    }

    function removeFunction(address _facetAddress, bytes4 _selector) internal {
        DiamondStorage storage ds = diamondStorage();
        // if function does not exist then do nothing and return
        require(
            _facetAddress == address(0),
            "LibDiamondCut: Remove facet address must be address(0)"
        );

        address oldFacetAddress = ds
            .selectorToFacetAndPosition[_selector]
            .facetAddress;
        removeFunction(ds, oldFacetAddress, _selector);
    }

    function addFacet(DiamondStorage storage ds, address _facetAddress)
        internal
    {
        enforceHasContractCode(
            _facetAddress,
            "LibDiamondCut: New facet has no code"
        );
        ds.facetFunctionSelectors[_facetAddress].facetAddressPosition = ds
            .facetAddresses
            .length;
        ds.facetAddresses.push(_facetAddress);
    }

    function addFunction(
        DiamondStorage storage ds,
        bytes4 _selector,
        uint96 _selectorPosition,
        address _facetAddress
    ) internal {
        ds
            .selectorToFacetAndPosition[_selector]
            .functionSelectorPosition = _selectorPosition;
        ds.facetFunctionSelectors[_facetAddress].functionSelectors.push(
            _selector
        );
        ds.selectorToFacetAndPosition[_selector].facetAddress = _facetAddress;
    }

    function removeFunction(
        DiamondStorage storage ds,
        address _facetAddress,
        bytes4 _selector
    ) internal {
        require(
            _facetAddress != address(0),
            "LibDiamondCut: Can't remove function that doesn't exist"
        );
        // an immutable function is a function defined directly in a diamond
        require(
            _facetAddress != address(this),
            "LibDiamondCut: Can't remove immutable function"
        );
        // replace selector with last selector, then delete last selector
        uint256 selectorPosition = ds
            .selectorToFacetAndPosition[_selector]
            .functionSelectorPosition;
        uint256 lastSelectorPosition = ds
            .facetFunctionSelectors[_facetAddress]
            .functionSelectors
            .length - 1;
        // if not the same then replace _selector with lastSelector
        if (selectorPosition != lastSelectorPosition) {
            bytes4 lastSelector = ds
                .facetFunctionSelectors[_facetAddress]
                .functionSelectors[lastSelectorPosition];
            ds.facetFunctionSelectors[_facetAddress].functionSelectors[
                    selectorPosition
                ] = lastSelector;
            ds
                .selectorToFacetAndPosition[lastSelector]
                .functionSelectorPosition = uint96(selectorPosition);
        }
        // delete the last selector
        ds.facetFunctionSelectors[_facetAddress].functionSelectors.pop();
        delete ds.selectorToFacetAndPosition[_selector];

        // if no more selectors for facet address then delete the facet address
        if (lastSelectorPosition == 0) {
            // replace facet address with last facet address and delete last facet address
            uint256 lastFacetAddressPosition = ds.facetAddresses.length - 1;
            uint256 facetAddressPosition = ds
                .facetFunctionSelectors[_facetAddress]
                .facetAddressPosition;
            if (facetAddressPosition != lastFacetAddressPosition) {
                address lastFacetAddress = ds.facetAddresses[
                    lastFacetAddressPosition
                ];
                ds.facetAddresses[facetAddressPosition] = lastFacetAddress;
                ds
                    .facetFunctionSelectors[lastFacetAddress]
                    .facetAddressPosition = facetAddressPosition;
            }
            ds.facetAddresses.pop();
            delete ds
                .facetFunctionSelectors[_facetAddress]
                .facetAddressPosition;
        }
    }

    function initializeDiamondCut(address _init, bytes memory _calldata)
        internal
    {
        if (_init == address(0)) {
            require(
                _calldata.length == 0,
                "LibDiamondCut: _init is address(0) but_calldata is not empty"
            );
        } else {
            require(
                _calldata.length > 0,
                "LibDiamondCut: _calldata is empty but _init is not address(0)"
            );
            if (_init != address(this)) {
                enforceHasContractCode(
                    _init,
                    "LibDiamondCut: _init address has no code"
                );
            }
            (bool success, bytes memory error) = _init.delegatecall(_calldata);
            if (!success) {
                if (error.length > 0) {
                    // bubble up the error
                    revert(string(error));
                } else {
                    revert("LibDiamondCut: _init function reverted");
                }
            }
        }
    }

    function enforceHasContractCode(
        address _contract,
        string memory _errorMessage
    ) internal view {
        uint256 contractSize;
        assembly {
            contractSize := extcodesize(_contract)
        }
        require(contractSize > 0, _errorMessage);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Strings.sol";

library LibAccessControlListv2 {
    bytes32 internal constant DIAMOND_ACL_STORAGE_POSITION =
        keccak256("diamond.standard.diamond.acl.storage");

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    struct ACLStorage {
        mapping(bytes32 => RoleData) roles;
    }

    function getStorage() internal pure returns (ACLStorage storage aclS) {
        bytes32 position = DIAMOND_ACL_STORAGE_POSITION;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            aclS.slot := position
        }
    }

    function hasRole(bytes32 role, address account)
        internal
        view
        returns (bool)
    {
        return getStorage().roles[role].members[account];
    }

    function grantRole(bytes32 role, address account) internal {
        if (!hasRole(role, account)) {
            getStorage().roles[role].members[account] = true;
        }
    }

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return getStorage().roles[role].adminRole;
    }

    function setRoleAdmin(bytes32 role, bytes32 adminRole) internal {
        getStorage().roles[role].adminRole = adminRole;
    }

    function revokeRole(bytes32 role, address account) internal {
        if (hasRole(role, account)) {
            getStorage().roles[role].members[account] = false;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import {IDiamondCutv2} from "../../../../interfaces/diamond/IDiamondCutv2.sol";
import "../../../../interfaces/IInitializableFacet.sol";

interface IDiamondCutWithOmnitSignature is IInitializableFacet {
    struct DiamondCutData {
        IDiamondCutv2.FacetCutInitializable[] diamondCutInitializable;
        IDiamondCutv2.FacetCut[] diamondCut;
        address init;
        bytes _calldata;
        address payable wallet;
        uint256 value;
        uint256 until;
    }

    function encode(address[] calldata addresses)
        external
        pure
        returns (bytes memory);

    function getDiamondCutWithSignatureHash(DiamondCutData calldata _data)
        external
        returns (bytes32);

    function diamondCutWitSignature(
        DiamondCutData calldata _data,
        bytes calldata _signaturee
    ) external payable;
}

//SPDX-License-Identifier: Business Source License 1.1

pragma solidity ^0.8.9;

library LibMeta {
    function msgSender() internal view returns (address sender_) {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            // solhint-disable-next-line no-inline-assembly
            assembly {
                // Load the 32 bytes word from memory with the address on the lower 20 bytes, and mask those.
                sender_ := and(
                    mload(add(array, index)),
                    0xffffffffffffffffffffffffffffffffffffffff
                )
            }
        } else {
            sender_ = msg.sender;
        }
    }
}

//SPDX-License-Identifier: Business Source License 1.1

pragma solidity ^0.8.9;

interface IInitializableFacet {
    function initialize(bytes calldata) external payable;

    function cleanUp() external payable;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}