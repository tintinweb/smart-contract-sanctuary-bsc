//SPDX-License-Identifier: Business Source License 1.1

pragma solidity ^0.8.9;

import "../interfaces/IERC721MintableWithTokenURIFacet.sol";
import {LibDiamondv2} from "../../../../libraries/diamond/LibDiamondv2.sol";
import {AppStorage} from "../AppStorage.sol";
import "../libraries/LibERC721TokenURI.sol";

contract ERC721OwnerMintableWithTokenURIFacet is
    IERC721MintableWithTokenURIFacet
{
    AppStorage internal s;

    function mintToWithTokenURI(
        address to_,
        uint256 tokenId_,
        string calldata tokenURI_
    ) external {
        LibDiamondv2.enforceIsContractOwner();
        require(
            s.owners[tokenId_] == address(0),
            "ERC721: Token already minted"
        );
        s.owners[tokenId_] = to_;
        s.balances[to_]++;

        LibERC721TokenURI.setBaseTokenTokenURI(tokenId_, tokenURI_);

        emit Transfer(address(0), to_, tokenId_);
    }
}

//SPDX-License-Identifier: Business Source License 1.1

pragma solidity ^0.8.9;

interface IERC721MintableWithTokenURIFacet {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    function mintToWithTokenURI(
        address to,
        uint256 tokenId,
        string calldata tokenURI
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

//SPDX-License-Identifier: Business Source License 1.1
pragma solidity ^0.8.9;

struct AppStorage {
    bool initialized;
    // Token name
    string name;
    // Token symbol
    string symbol;
    // Mapping from token ID to owner address
    mapping(uint256 => address) owners;
    // Mapping owner address to token count
    mapping(address => uint256) balances;
    // Mapping from token ID to approved address
    mapping(uint256 => address) tokenApprovals;
    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) operatorApprovals;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library LibERC721TokenURI {
    bytes32 internal constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.erc721.token.uri");

    struct ERC721TokenURIStorage {
        mapping(uint256 => string) tokenURIs;
    }

    function erc721TokenURIStorage()
        internal
        pure
        returns (ERC721TokenURIStorage storage ds)
    {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            ds.slot := position
        }
    }

    function setBaseTokenTokenURI(uint256 _tokenId, string calldata _tokenURI)
        internal
    {
        erc721TokenURIStorage().tokenURIs[_tokenId] = _tokenURI;
    }

    function tokenURI(uint256 _tokenId) internal view returns (string memory) {
        return erc721TokenURIStorage().tokenURIs[_tokenId];
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