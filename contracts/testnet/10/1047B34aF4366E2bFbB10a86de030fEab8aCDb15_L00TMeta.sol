// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import '@openzeppelin/contracts/utils/Base64.sol';

import './interfaces/IElements.sol';
import {Utils} from './Utils.sol';

// L00TMeta contains metadata and logic for L00T
contract L00TMeta {
    uint8 private chainIdx;
    address private _forge;
    address public _owner;
    IElements private elements;
    // namePrefixes Mappings
    mapping(uint8 => string[]) private namePrefixes;
    // current Upgrade State
    mapping(uint256 => uint8[8][2]) public upgradeState;
    mapping(uint256 => bool) public hasUpgrade;

    // Map out initial name prefixes
    constructor(uint8 _chainIdx, address _elements) {
        require(_chainIdx < 5, 'ST0NE: _chainIdx needs to be within 0-4');
        chainIdx = _chainIdx;
        _owner = msg.sender;
        // for dev admin, set _owner as the forge contract to start so we can continue deployment
        _forge = _owner;
        elements = IElements(_elements); 
    }

    // function access modifiers
    /**
     * @dev Throws if called by any account other than the forge.
     */
    modifier onlyForge() {
        require(_forge == msg.sender, "L00TMETA: caller is not the Forge");
        _;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_onlyOwner(), "L00TMETA: caller is not the Owner");
        _;
    }

    // also check tx.origin so dev deployment can have appropriate permissions
    function _onlyOwner() private view returns (bool valid){
        if (_owner == msg.sender) return true;
        if (_owner == tx.origin) return true;
        return false;
    }

    string[] private necklaces = ['Necklace', 'Amulet', 'Pendant'];

    string[] private rings = [
        'Gold Ring',
        'Silver Ring',
        'Bronze Ring',
        'Platinum Ring',
        'Titanium Ring'
    ];

    // L00T Data (cc0 LOOT-based)
    // First 4 elements are fixated to their elemental affinity
    // ie: suffixes[0] is Fire, [1] == Water, etc w/ [4] being Phys
    // Rest of the entries are common to all chains.
    string[] private suffixes = [
        'of Giants', //phys
        'of Rage', //fire
        'of Reflection', //water
        'of Brilliance', //light
        'of Power', //dark
        'of Titans', //common...
        'of Skill',
        'of Perfection',
        'of Enlightenment',
        'of Protection',
        'of Anger',
        'of Fury',
        'of Vitriol',
        'of the Fox',
        'of Detection',
        'of the Twins'
    ];

    string[] private nameSuffixes = [
        'Root',
        'Sun', //fire
        'Bender', //water...
        'Glow',
        'Shadow',
        'Bane',
        'Bite',
        'Song',
        'Roar',
        'Grasp',
        'Instrument',
        'Whisper',
        'Shout',
        'Growl',
        'Tear',
        'Peak',
        'Form',
        'Moon'
    ];

    string[] private weapons = [
        'Long Sword',
        'Warhammer', //fire...
        'Wand',
        'Ghost Wand',
        'Book',
        'Quarterstaff',
        'Maul',
        'Mace',
        'Club',
        'Katana',
        'Falchion',
        'Scimitar',
        'Short Sword',
        'Grave Wand',
        'Bone Wand',
        'Grimoire',
        'Chronicle',
        'Tome'
    ];

    string[] private chestArmor = [
        'Plate Mail',
        'Dragonskin Armor',
        'Divine Robe',
        'Holy Chestplate',
        'Demon Husk',
        'Silk Robe',
        'Linen Robe',
        'Robe',
        'Shirt',
        'Studded Leather Armor',
        'Hard Leather Armor',
        'Leather Armor',
        'Ornate Chestplate',
        'Chain Mail',
        'Ring Mail'
    ];

    string[] private headArmor = [
        'Great Helm',
        "Dragon's Crown",
        'Divine Hood',
        'Ancient Helm',
        'Demon Crown',
        'Ornate Helm',
        'Full Helm',
        'Helm',
        'War Cap',
        'Leather Cap',
        'Cap',
        'Crown',
        'Silk Hood',
        'Linen Hood',
        'Hood'
    ];

    string[] private waistArmor = [
        'Heavy Belt',
        'Dragonskin Belt',
        'Ornate Belt',
        'Brightsilk Sash',
        'Demonhide Belt',
        'War Belt',
        'Plated Belt',
        'Mesh Belt',
        'Studded Leather Belt',
        'Hard Leather Belt',
        'Leather Belt',
        'Silk Sash',
        'Wool Sash',
        'Linen Sash',
        'Sash'
    ];

    string[] private footArmor = [
        'Heavy Boots',
        'Dragonskin Boots',
        'Divine Slippers',
        'Holy Greaves',
        'Demonhide Boots',
        'Ornate Greaves',
        'Greaves',
        'Chain Boots',
        'Studded Leather Boots',
        'Hard Leather Boots',
        'Leather Boots',
        'Silk Slippers',
        'Wool Shoes',
        'Linen Shoes',
        'Shoes'
    ];

    string[] private handArmor = [
        'Heavy Gloves',
        'Dragonskin Gloves',
        'Divine Gloves',
        'Holy Gauntlets',
        "Demon's Hands",
        'Ornate Gauntlets',
        'Gauntlets',
        'Chain Gloves',
        'Studded Leather Gloves',
        'Hard Leather Gloves',
        'Leather Gloves',
        'Silk Gloves',
        'Wool Gloves',
        'Linen Gloves',
        'Gloves'
    ];

    // defined for easy loop in metadata logic
    string[] private slotNames = [
        'Weapon',
        'Chest',
        'Head',
        'Waist',
        'Foot',
        'Hand',
        'Neck',
        'Ring'
    ];

    // move init to function so can be deployed on smaller gas limit chains (avax)
    function initMetadata() external onlyOwner {
        // namePrefixes Mappings
        namePrefixes[0] = [
            'Apocalypse',
            'Beast',
            'Behemoth',
            'Bramble',
            'Cataclysm',
            'Gale',
            'Golem',
            'Pain',
            'Pandemonium',
            'Tempest',
            'Viper'
        ];
        namePrefixes[1] = [
            'Agony',
            'Armageddon',
            'Blood',
            'Brimstone',
            'Brood',
            'Demon',
            'Dragon',
            'Doom',
            'Loath',
            'Maelstrom',
            'Onslaught',
            'Phoenix',
            'Rage',
            'Wrath'
        ];
        namePrefixes[2] = [
            'Chimeric',
            'Dusk',
            'Eagle',
            'Foe',
            'Fate',
            'Havoc',
            'Hypnotic',
            'Kraken',
            'Mind',
            'Sol',
            'Storm',
            'Vortex'
        ];
        namePrefixes[3] = [
            'Damnation',
            'Dire',
            'Empyrean',
            'Glyph',
            'Honour',
            'Miracle',
            'Oblivion',
            'Rapture',
            'Rune',
            'Soul',
            'Sorrow',
            'Spirit',
            'Victory',
            "Light's",
            'Shimmering'
        ];
        namePrefixes[4] = [
            'Blight',
            'Carrion',
            'Corpse',
            'Corruption',
            'Death',
            'Dread',
            'Ghoul',
            'Gloom',
            'Grim',
            'Hate',
            'Morbid',
            'Plague',
            'Skull',
            'Torment',
            'Vengeance',
            'Woe'
        ];
    }

    // returns current upgrade state, where 1st elem is refinements and 2nd is elements
    // proto metadata is [item level][element] current status of the token.
    // ie: ([0,1,0,0,...],[1,0,....]) would have an elemental 1st slot and a +1 refined 2nd.
    function getUpgradeState(uint256 tokenId) public view returns (uint8[8][2] memory) {
        return upgradeState[tokenId];
    }

    // owner functions
    function setForge(address _forgeAddress) external onlyOwner {
        _forge = _forgeAddress;
    }

    // pass off Owner. Used for dev to pass off owner to L00T contract for permissions.
    // SHOULD BE SET BEFORE MINTING
    function setOwner(address owner) external onlyOwner {
        _owner = owner;
    }

    // Hopefully this isn't too expensive...
    function mintCheck(uint256 tokenId) external onlyOwner {
        for(uint8 i = 0; i < 8; i++){
            _mintRefine(tokenId, i);
        }
    }

    // check greatness to determine if we should upgrade values on mint.
    function _mintRefine(uint256 tokenId, uint8 slot) private {
        uint8 greatness = uint8(Utils.random(
            string(abi.encodePacked(slotNames[slot], Utils.toString(tokenId)))
        ) % 21);
        if (greatness == 20) {
            _refineSlot(tokenId, slot);
        }
    }
    // owner function to set incoming state from chain traversal
    function setUpgradeState(uint256 tokenId, uint8[8][2] calldata _upgradeState) external onlyOwner {
        upgradeState[tokenId] = _upgradeState;
        if(!hasUpgrade[tokenId]) hasUpgrade[tokenId] = true;
    }

    // Forge: refine a slot
    function refineSlot(uint256 tokenId, uint8 _slot) external onlyForge {
        _refineSlot(tokenId, _slot);
    }

    function _refineSlot(uint256 tokenId, uint8 _slot) private {
        require(_slot < 8, 'L00TMETA: item slot out of range');
        // make sure not over-refining
        require(upgradeState[tokenId][0][_slot] < 10, 'L00TMETA: Item Maxed Already');
        ++upgradeState[tokenId][0][_slot];
        if(!hasUpgrade[tokenId]) hasUpgrade[tokenId] = true;
    }

    // Forge: enchant an element to a slot
    function enchantSlot(uint256 tokenId, uint8 _slot, uint8 _elem) external onlyForge {
        require(_slot < 8, 'L00TMETA: item slot out of range');
        require(_elem != 0, 'L00TMETA: Cannot apply zero value');
        // apply element
        upgradeState[tokenId][1][_slot] = uint8(_elem);
        if(!hasUpgrade[tokenId]) hasUpgrade[tokenId] = true;
    }

    function getWeapon(uint256 tokenId) public view returns (string memory) {
        return _getItem(tokenId, 0, weapons);
    }

    function getChest(uint256 tokenId) public view returns (string memory) {
        return _getItem(tokenId, 1, chestArmor);
    }

    function getHead(uint256 tokenId) public view returns (string memory) {
        return _getItem(tokenId, 2, headArmor);
    }

    function getWaist(uint256 tokenId) public view returns (string memory) {
        return _getItem(tokenId, 3, waistArmor);
    }

    function getFoot(uint256 tokenId) public view returns (string memory) {
        return _getItem(tokenId, 4, footArmor);
    }

    function getHand(uint256 tokenId) public view returns (string memory) {
        return _getItem(tokenId, 5, handArmor);
    }

    function getNeck(uint256 tokenId) public view returns (string memory) {
        return _getItem(tokenId, 6, necklaces);
    }

    function getRing(uint256 tokenId) public view returns (string memory) {
        return _getItem(tokenId, 7, rings);
    }

    function _getItem(uint256 tokenId, uint8 slot, string[] memory sourceArray) internal view returns (string memory) {
        string memory str = pluck(tokenId, slotNames[slot], sourceArray);
        uint8 refined = upgradeState[tokenId][0][slot];
        if (refined == 0) return str;
        // add refined value if refined
        return string(abi.encodePacked(str, ' +', Utils.toString(refined)));
    }

    // Pluck items based on rarity rolls
    function pluck(
        uint256 tokenId,
        string memory keyPrefix,
        string[] memory sourceArray
    ) internal view returns (string memory) {
        uint256 rand = Utils.random(
            string(abi.encodePacked('L00T:', keyPrefix, Utils.toString(tokenId)))
        );
        // chain affinity based on tokenId
        uint8 affinity = uint8(tokenId % 5);
        uint8 greatness = uint8(rand % 21);
        // bitshift to roll for chain special
        uint8 chainSpecial = uint8(((rand >> 16) & 0xFFFF) % 255);
        uint8 pick;
        string memory output;

        // Initial item pick:
        if (sourceArray.length > 5) {
            // If most rare, take unique chain item
            if (chainSpecial == 254) { // roughly 0.4% (1/254)
                output = sourceArray[affinity];
            } else {
                // Otherwise pick from the rest (first 5 indexes reserved)
                pick = uint8(5 + (rand % (sourceArray.length - 5)));
            }
        } else {
            // Necklace and Ring fallthru
            pick = uint8(rand % sourceArray.length);
        }
        output = sourceArray[pick];

        if (greatness > 14) {
            output = string(
                abi.encodePacked(output, ' ', suffixes[rand % suffixes.length])
            );
        }
        if (greatness >= 19) {
            string[2] memory name;

            name[0] = namePrefixes[affinity][
                rand % namePrefixes[affinity].length
            ];
            name[1] = nameSuffixes[rand % nameSuffixes.length];
            if (greatness >= 19) {
                output = string(
                    abi.encodePacked("'", name[0], ' ', name[1], "' ", output)
                );
                // greatness == 20 is naturally refined but we'll handle it with data store
            }
        }
        return output;
    }
    
    // Compile SVG and JSON Metadata as a large base64 encoded string...
    function getMetaData(uint256 tokenId) public view returns (string memory) {
        // If traversed add traversed class
        bool traversed = uint8(tokenId % 5) != chainIdx;
        uint8[8][2] memory currState = getUpgradeState(tokenId); 
        // require minted
        string[19] memory parts;
        parts[
            0
        ] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { font-family: serif; font-size: 14px; } .plain {fill: rgb(187, 187, 187);} .traversed { stroke-width: 4; stroke: gold;}</style><rect width="100%" height="100%" fill="';
        parts[1] = elements.getBG(tokenId);

        // If traversed add traversed class
        if (uint8(tokenId % 5) != chainIdx) {
            parts[2] = string(abi.encodePacked(
                '" class="traversed" /><text x="10" y="20" class="base',
                currState[1][0] == 0 && currState[0][0] == 0 ? ' plain' : string(abi.encodePacked(
                    'fill="', elements.getFC(currState[1][0])
                )) ,'">'
            ));
        } else {
            parts[2] =  string(abi.encodePacked(
                '" /><text x="10" y="20" class="base',
                currState[1][0] == 0 && currState[0][0] == 0 ? ' plain' : string(abi.encodePacked(
                '" fill="', elements.getFC(currState[1][1]))),'">'
            ));
        }

        parts[3] = getWeapon(tokenId);
        parts[4] = string(abi.encodePacked(
            '</text><text x="10" y="40" class="base',
                currState[1][1] == 0 && currState[0][1] == 0 ? ' plain' : string(abi.encodePacked(
                '" fill="', elements.getFC(currState[1][1]))),'">'
        ));
        parts[5] = getChest(tokenId);
        parts[6] = string(abi.encodePacked(
            '</text><text x="10" y="60" class="base',
                currState[1][2] == 0 && currState[0][2] == 0 ? ' plain' : string(abi.encodePacked(
                '" fill="', elements.getFC(currState[1][2]))),'">'
        ));
        parts[7] = getHead(tokenId);
        parts[8] = string(abi.encodePacked(
            '</text><text x="10" y="80" class="base',
                currState[1][3] == 0 && currState[0][3] == 0 ? ' plain' : string(abi.encodePacked(
                '" fill="', elements.getFC(currState[1][3]))),'">'
        ));
        parts[9] = getWaist(tokenId);
        parts[10] = string(abi.encodePacked(
            '</text><text x="10" y="100" class="base',
                currState[1][4] == 0 && currState[0][4] == 0 ? ' plain' : string(abi.encodePacked(
                '" fill="', elements.getFC(currState[1][4]))),'">'
        ));
        parts[11] = getFoot(tokenId);
        parts[12] = string(abi.encodePacked(
            '</text><text x="10" y="120" class="base',
                currState[1][5] == 0 && currState[0][5] == 0 ? ' plain' : string(abi.encodePacked(
                '" fill="', elements.getFC(currState[1][5]))),'">'
        ));
        parts[13] = getHand(tokenId);
        parts[14] = string(abi.encodePacked(
            '</text><text x="10" y="140" class="base',
                currState[1][6] == 0 && currState[0][6] == 0 ? ' plain' : string(abi.encodePacked(
                '" fill="', elements.getFC(currState[1][6]))),'">'
        ));
        parts[15] = getNeck(tokenId);
        parts[16] = string(abi.encodePacked(
            '</text><text x="10" y="160" class="base',
                currState[1][7] == 0 && currState[0][7] == 0 ? ' plain' : string(abi.encodePacked(
                '" fill="', elements.getFC(currState[1][7]))),'">'
        ));
        parts[17] = getRing(tokenId);
        parts[18] = '</text></svg>';

        // combine in parts
        string memory output = string(
            abi.encodePacked(
                parts[0],
                parts[1],
                parts[2],
                parts[3],
                parts[4],
                parts[5],
                parts[6]
            )
        );
        output = string(
            abi.encodePacked(
                output,
                parts[7],
                parts[8],
                parts[9],
                parts[10],
                parts[11],
                parts[12]
            )
        );
        output = string(
            abi.encodePacked(
                output,
                parts[13],
                parts[14],
                parts[15],
                parts[16],
                parts[17],
                parts[18]
            )
        );

        // determine additional elemental metadata
        string memory elemStr;
        if(currState[1][0] > 0) {
            elemStr = string(abi.encodePacked(
                ', { "trait_type": "Weapon Element", "value": "', elements.ElemStr(currState[1][0]) ,'"}'
            ));
        }
        for (uint8 i = 1; i < 8; i++){
            uint8 elem = currState[1][i];
            if(elem > 0) {
                elemStr = string(abi.encodePacked(
                    elemStr,
                    ', { "trait_type": "', slotNames[i] ,' Element", "value": "',
                    elements.ElemStr(elem), '"}'
                ));
            }
        }

        // metadata json construction
        string memory metaString = string(
            abi.encodePacked(
                // stacked pack
                string(abi.encodePacked(
                    '"attributes": [{ "trait_type": "Weapon", "value": "', parts[3],
                    '" }, { "trait_type": "Chest", "value": "', parts[5], '" }',
                    ', { "trait_type": "Head", "value": "', parts[7], '" }',
                    ', { "trait_type": "Waist", "value": "', parts[9], '" }',
                    ', { "trait_type": "Foot", "value": "', parts[11], '" }'
                )), 
                ', { "trait_type": "Hand", "value": "', parts[13], '" }',
                ', { "trait_type": "Neck", "value": "', parts[15], '" }',
                ', { "trait_type": "Ring", "value": "', parts[17], '" }',
                elemStr,
                traversed
                    ? ', { "trait_type": "Traversed", "value": "Traversed"}'
                    : '',
                ']'
            )
        );

        // encode the whole package
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Bag #',
                        Utils.toString(tokenId),
                        '", "description": "L00T is additional randomized adventurer gear generated and stored on chain that is also upgradeable by an external contract. Maximum supply is dynamic, increasing dynamic to this chain\'s block rate. Stats, images, and other functionality are intentionally omitted for others to interpret. Feel free to use L00T in any way you want.", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(output)), '",', metaString,
                        '}'
                    )
                )
            )
        );
        // mime
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