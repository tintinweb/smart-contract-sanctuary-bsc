//SPDX-License-Identifier: Business Source License 1.1

pragma solidity ^0.8.9;

import "../interfaces/IERC721ContractURIFacet.sol";
import "../libraries/LibContractURI.sol";

contract ERC721ContractURIFacet is IERC721ContractURIFacet {
    function initialize(bytes calldata initBytes) external payable {
        string memory _contractURI = abi.decode(initBytes, (string));
        LibContractURI.setContractURI(_contractURI);
    }

    function cleanUp() external payable override {
        LibContractURI.setContractURI("");
    }

    function contractURI() external view override returns (string memory) {
        return LibContractURI.contractURI();
    }

    function encode(string calldata baseTokenURI_)
        external
        pure
        returns (bytes memory)
    {
        return abi.encode(baseTokenURI_);
    }
}

//SPDX-License-Identifier: Business Source License 1.1
pragma solidity ^0.8.9;

import "../../../../interfaces/IInitializableFacet.sol";

interface IERC721ContractURIFacet is IInitializableFacet {
    function contractURI() external returns (string memory);

    function encode(string calldata baseTokenURI_)
        external
        pure
        returns (bytes memory);
}

//SPDX-License-Identifier: Business Source License 1.1

pragma solidity ^0.8.9;

library LibContractURI {
    bytes32 internal constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.erc721.contrct.uri");

    struct ERC721ContractURIStorage {
        string contractURI;
    }

    function erc721ContractURIStorage()
        internal
        pure
        returns (ERC721ContractURIStorage storage ds)
    {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            ds.slot := position
        }
    }

    function setContractURI(string memory _contractURI) internal {
        erc721ContractURIStorage().contractURI = _contractURI;
    }

    function contractURI() internal view returns (string memory) {
        return erc721ContractURIStorage().contractURI;
    }
}

//SPDX-License-Identifier: Business Source License 1.1

pragma solidity ^0.8.9;

interface IInitializableFacet {
    function initialize(bytes calldata) external payable;

    function cleanUp() external payable;
}