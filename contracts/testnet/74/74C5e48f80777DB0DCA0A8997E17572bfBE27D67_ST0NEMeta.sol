// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import '@openzeppelin/contracts/utils/Base64.sol';
import './interfaces/IElements.sol';
import {Utils} from './Utils.sol';

// ST0NEMeta contains metadata and logic for ST0NEs
contract ST0NEMeta {
    uint8 private chainIdx;

    // ST0NE Rarities (sum/255). 5/255 left for elemental (2%)
    uint8[] private Rarities = [95, 165, 212, 234, 245, 250];
    // chance for ST0NE to be Refined (/255)
    uint8[] private RefinedChance = [48, 37, 28, 23, 14, 8];

    enum Stone {
        Frail,
        Simple,
        Strong,
        Shiny,
        Glowing,
        Divine,
        Elemental
    }

    string[] private StoneStr = [
        'Frail',
        'Simple',
        'Strong',
        'Shiny',
        'Glowing',
        'Divine',
        'Elemental'
    ];

    string[] private Rarity = [
        'Boring',
        'Common',
        'Uncommon',
        'Rare',
        'Epic',
        'Legendary',
        'Magical'
    ];

    IElements private elements;

    constructor(uint8 _chainIdx, address _elements) {
        require(_chainIdx < 5, 'ST0NE: _chainIdx needs to be within 0-4');
        chainIdx = _chainIdx;
        elements = IElements(_elements);
    }

    function getStone(Stone stone) public view returns (string memory) {
        return StoneStr[uint8(stone)];
    }

    function getElement(Stone stone, uint8 elem)
        public
        view
        returns (string memory)
    {
        // handle element
        if (stone == Stone.Elemental) {
            return elements.ElemStr(elem);
        }
        // other stones just check refined
        if (elem == 1) return 'Refined';
        return '';
    }

    function getRarity(Stone stone) public view returns (string memory) {
        // empty for most, "Refined" for rare non-element, {Element} if elemental
        return Rarity[uint8(stone)];
    }

    // get proto of metadata
    // returns [t, e] where t:stone type and e:element or refined(1)
    function getProtoMeta(uint256 tokenId)
        public
        view
        returns (uint8[2] memory)
    {
        return pluck(tokenId);
    }

    // returns string values and fill values
    function getMetaParts(uint256 tokenId)
        private
        view
        returns (string[6] memory metaParts)
    {
        uint8[2] memory proto = getProtoMeta(tokenId);
        Stone stone = Stone(proto[0]);
        uint8 elem = proto[1];

        // important values first, then styling values
        metaParts[0] = getStone(stone);
        metaParts[1] = getElement(stone, elem);
        metaParts[2] = getRarity(stone);
        metaParts[3] = elements.getBG(tokenId);
        metaParts[4] = getStoneFill(stone);
        metaParts[5] = stone == Stone.Elemental ? getElemFill(elem, false) : getElemFill(elem, true);
    }

    function getStoneFill(Stone stone) internal view returns (string memory) {
        // boring return
        if (stone == Stone.Frail) {
            return '#BBB';
        }
        return elements.getFC(uint8(stone));
    }

    function getElemFill(uint8 elem, bool reduce) internal view returns (string memory) {
        if (elem == 0) {
            return '#BBB';
        } else if (reduce) {
            --elem;
        }
        return elements.getFC(elem);
    }

    // pluck metadata as based on tokenId.
    // return [t, e] where t: stone type and e: element or refined if non-elem
    function pluck(uint256 tokenId)
        private
        view
        returns (uint8[2] memory stoneProto)
    {
        // chain affinity based on tokenId
        uint8 affinity = uint8(tokenId % 5);
        uint256 rand = Utils.random(
            string(abi.encodePacked('ST0NE', Utils.toString(tokenId)))
        );
        uint8 rarity = uint8(rand % 255);
        // bitshift to determine refined
        uint8 refined = uint8(((rand >>= 16) & 0xFFFF) % 255);
        // boring stones:
        if (rarity <= Rarities[0]) {
            if (refined <= RefinedChance[0]) {
                stoneProto[1] = 1;
            }
            return stoneProto; // [0,0] or [0,1];
        }
        // Determine rarity
        // loop up to but excluding elemental stone
        // TODO: Perhaps can do 'weighted coin' instead to remove loop. Might be fine because view only
        for (uint8 i = 1; i < Rarities.length - 1; i++) {
            // Physical affinity adjustment (effectively pads the count)
            if (affinity == 0) {
                // prevent overflow
                if (rarity >= 252) {
                    rarity = 255;
                } else {
                    rarity += 3;
                }
            }
            // Compare rarity against next threshold
            if (rarity <= Rarities[i]) {
                // set type
                stoneProto[0] = i;
                if (refined <= RefinedChance[i]) {
                    // refined
                    stoneProto[1] = 1;
                }
                return stoneProto; // [type, refined]
            }
        }
        // Elemental Stone Logic Only Below (other cases handled above)
        // Set Elemental Stone Type
        stoneProto[0] = uint8(Stone.Elemental);

        // 33% chance to be in affinity
        if (uint8((refined % 3)) == 0) {
            stoneProto[1] = affinity;
        }
        // roll element if not in affinity
        uint8 element = uint8(((rand >>= 16) & 0xFFFF) % 4);
        // Randomly pick element (includes affinity elem ~56%)
        stoneProto[1] = element;
        return stoneProto; // [elemental stone, elem]
    }

    // Compile SVG and JSON Metadata as a large base64 string...
    function getMetaData(uint256 tokenId) public view returns (string memory) {
        // If traversed add traversed class
        bool traversed = uint8(tokenId % 5) != chainIdx;
        // Get metadata from data contract
        string[6] memory metaParts = getMetaParts(tokenId);
        string[11] memory parts;

        // construct SVG
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { font-family: serif; font-size: 20px; } .traversed { stroke-width: 4; stroke: gold;}</style><rect width="100%" height="100%" fill="';
        // background based on source chain. TODO: Border when traversed?
        parts[1] = metaParts[3];
    
        traversed  
            ? parts[2] = '" class="traversed" /><text x="10" y="20" class="base" fill="'
            : parts[2] = '" /><text x="10" y="30" class="base" fill="';

        // stone class
        parts[3] = metaParts[4];
        parts[4] = '">';
        // stone text
        parts[5] = metaParts[0];
        parts[6] = ' Stone</text><text x="10" y="60" class="base" fill="';
        // elem class
        parts[7] = metaParts[5];
        parts[8] = '">';
        // elem text
        parts[9] = metaParts[1];

        parts[10] = '</text></svg>';

        // svg output
        string memory output = string(
            abi.encodePacked(
                parts[0],
                parts[1],
                parts[2],
                parts[3],
                parts[4],
                parts[5]
            )
        );
        output = string(
            abi.encodePacked(
                output,
                parts[6],
                parts[7],
                parts[8],
                parts[9],
                parts[10]
            )
        );

        // metadata json construction
        string memory metaString = string(
            abi.encodePacked(
                '"attributes": [{ "trait_type": "Rarity", "value": "', metaParts[2],
                '" }, { "trait_type": "Element", "value": "', metaParts[1], '" }',
                traversed
                    ? ', { "trait_type": "Traversed", "value": "Traversed"}'
                    : '',
                ']'
            )
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "', metaParts[0], ' Stone #', Utils.toString(tokenId),
                        '", "description": "ST0NEs are randomized stones generated and stored on chain. Maximum supply is dynamic, increasing dynamically to the block rate. Stats, images, and other functionality are intentionally omitted for others to interpret. Feel free to use ST0NE in any way you want.", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(output)), '",', metaString, '}'
                    )
                )
            )
        );
        output = string(
            abi.encodePacked('data:application/json;base64,', json)
        );

        return output;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Base64.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides a set of functions to operate with Base64 strings.
 *
 * _Available since v4.5._
 */
library Base64 {
    /**
     * @dev Base64 Encoding/Decoding Table
     */
    string internal constant _TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /**
     * @dev Converts a `bytes` to its Bytes64 `string` representation.
     */
    function encode(bytes memory data) internal pure returns (string memory) {
        /**
         * Inspired by Brecht Devos (Brechtpd) implementation - MIT licence
         * https://github.com/Brechtpd/base64/blob/e78d9fd951e7b0977ddca77d92dc85183770daf4/base64.sol
         */
        if (data.length == 0) return "";

        // Loads the table into memory
        string memory table = _TABLE;

        // Encoding takes 3 bytes chunks of binary data from `bytes` data parameter
        // and split into 4 numbers of 6 bits.
        // The final Base64 length should be `bytes` data length multiplied by 4/3 rounded up
        // - `data.length + 2`  -> Round up
        // - `/ 3`              -> Number of 3-bytes chunks
        // - `4 *`              -> 4 characters for each chunk
        string memory result = new string(4 * ((data.length + 2) / 3));

        assembly {
            // Prepare the lookup table (skip the first "length" byte)
            let tablePtr := add(table, 1)

            // Prepare result pointer, jump over length
            let resultPtr := add(result, 32)

            // Run over the input, 3 bytes at a time
            for {
                let dataPtr := data
                let endPtr := add(data, mload(data))
            } lt(dataPtr, endPtr) {

            } {
                // Advance 3 bytes
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                // To write each character, shift the 3 bytes (18 bits) chunk
                // 4 times in blocks of 6 bits for each character (18, 12, 6, 0)
                // and apply logical AND with 0x3F which is the number of
                // the previous character in the ASCII table prior to the Base64 Table
                // The result is then added to the table to get the character to write,
                // and finally write it in the result pointer but with a left shift
                // of 256 (1 byte) - 8 (1 ASCII char) = 248 bits

                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance
            }

            // When data `bytes` is not exactly 3 bytes long
            // it is padded with `=` characters at the end
            switch mod(mload(data), 3)
            case 1 {
                mstore8(sub(resultPtr, 1), 0x3d)
                mstore8(sub(resultPtr, 2), 0x3d)
            }
            case 2 {
                mstore8(sub(resultPtr, 1), 0x3d)
            }
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IElements {
    function getBG(uint256 tokenId) external view returns (string memory);

    function ElemStr(uint8 elem) external view returns (string memory);

    function getFC(uint8 idx) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

library Utils {
    bytes16 private constant _HEX_SYMBOLS = '0123456789abcdef';

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT license
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return '0';
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
            return '#00'; //black hex
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
     * modified to return #hexcode for styling
     */
    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory)
    {
        bytes memory buffer = new bytes(2 * length + 1);
        buffer[0] = '#';
        for (uint256 i = 2 * length; i > 0; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, 'Strings: hex length insufficient');
        return string(buffer);
    }
}