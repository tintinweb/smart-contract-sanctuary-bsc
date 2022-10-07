//SPDX-License-Identifier: Business Source License 1.1

pragma solidity ^0.8.9;

import "../interfaces/IERC721BaseTokenURIGetterFacet.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../libraries/LibERC721BaseTokenURI.sol";

contract ERC721BaseTokenURIGetterFacet is IERC721BaseTokenURIGetterFacet {
    function tokenURI(uint256 tokenId_)
        external
        view
        override
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    LibERC721BaseTokenURI.baseTokenURI(),
                    Strings.toString(tokenId_)
                )
            );
    }
}

//SPDX-License-Identifier: Business Source License 1.1
pragma solidity ^0.8.9;

interface IERC721BaseTokenURIGetterFacet {
    function tokenURI(uint256 tokenId_) external view returns (string memory);
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library LibERC721BaseTokenURI {
    bytes32 internal constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.erc721.base.token.uri");

    struct ERC721BaseTokenURIStorage {
        string baseTokenUri;
    }

    function erc721BaseTokenURIStorage()
        internal
        pure
        returns (ERC721BaseTokenURIStorage storage ds)
    {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            ds.slot := position
        }
    }

    function setBaseTokenTokenURI(string memory _baseTokenURI) internal {
        erc721BaseTokenURIStorage().baseTokenUri = _baseTokenURI;
    }

    function baseTokenURI() internal view returns (string memory) {
        return erc721BaseTokenURIStorage().baseTokenUri;
    }
}