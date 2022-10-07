//SPDX-License-Identifier: Business Source License 1.1

pragma solidity ^0.8.9;

import "../interfaces/IERC721SpecificTokenURIGetterFacet.sol";
import "../libraries/LibERC721SpecificTokenURI.sol";

contract ERC721SpecificTokenURIGetterFacet is
    IERC721SpecificTokenURIGetterFacet
{
    function tokenURI(uint256 tokenId_)
        external
        view
        override
        returns (string memory)
    {
        return LibERC721SpecificTokenURI.tokenURI(tokenId_);
    }
}

//SPDX-License-Identifier: Business Source License 1.1
pragma solidity ^0.8.9;

interface IERC721SpecificTokenURIGetterFacet {
    function tokenURI(uint256 tokenId_) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library LibERC721SpecificTokenURI {
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

    function setSpecificTokenURI(uint256 _tokenId, string calldata _tokenURI)
        internal
    {
        erc721TokenURIStorage().tokenURIs[_tokenId] = _tokenURI;
    }

    function tokenURI(uint256 _tokenId) internal view returns (string memory) {
        return erc721TokenURIStorage().tokenURIs[_tokenId];
    }
}