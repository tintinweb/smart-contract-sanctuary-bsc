// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import {Utils} from './Utils.sol';

contract Elements {
    // Element ENUMS
    enum Element {
        Phys,
        Fire,
        Water,
        Light,
        Dark,
        Mana,
        Spirit,
        Gravity,
        Null,
        Aether,
        Matter,
        Void
    }

    string[] public ElemStr = [
        'Physical',
        'Fire',
        'Water',
        'Light',
        'Dark',
        'Mana*',
        'Spirit*',
        'Gravity*',
        'Null*',
        'Aether**',
        'Matter**',
        'Void**'
    ];

    // background is set by source chain so only first 5.
    uint24[] internal ElemBG = [0x272727, 0x2c1108, 0x08122c, 0x35351a, 0x241431];
    // Foreground colour is for elemental text.
    uint24[] internal ElemFC = [
        0xffffff,
        0xcc1a0d,
        0x187fc1,
        0xcece36,
        0x812cc9,
        // t2
        0x2ed054,
        0x16d5c5,
        0x945e1f,
        0x234234,
        // t3
        0xabf915,
        0xf66d09,
        0xc53ec7
    ];

    // Recipe Mappings (Recipes[Fire][Water] => Mana)
    mapping(Element => mapping(Element => Element)) public Recipes;

    constructor() {
        // T2 Recipes
        Recipes[Element.Fire][Element.Water] = Element.Mana;
        Recipes[Element.Fire][Element.Dark] = Element.Gravity;
        Recipes[Element.Water][Element.Light] = Element.Spirit;
        Recipes[Element.Light][Element.Dark] = Element.Null;
        // T3 Recipes
        Recipes[Element.Mana][Element.Spirit] = Element.Aether;
        Recipes[Element.Mana][Element.Gravity] = Element.Matter;
        Recipes[Element.Mana][Element.Null] = Element.Void;
    }

    function getBG(uint256 tokenId) public view returns (string memory) {
        return Utils.toHexString(ElemBG[tokenId % 5]);
    }

    function getFC(uint8 idx) public view returns (string memory) {
        return Utils.toHexString(ElemFC[idx]);
    }
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