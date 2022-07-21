// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Struct.sol";
import "./Base64.sol";

contract GameLootReveal {
    struct Solid {
        string question;
        string value;
        string discovered;
        string p1;
        string p2;
        string p3;
        string p4;
        string p5;
    }

    constructor() {}

    function genSVG(AttributeData[] memory attrData)
        public
        pure
        returns (string memory)
    {
        uint256 len = attrData.length;

        string memory output = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"> <style>.lineCount { fill: #BABABA; font-family: consolas; font-size: 6px; }</style> <style>.key { fill: #e0932d; font-family: consolas; font-size: 6px; }</style> <style>.value { fill: #ffffff; font-family: consolas; font-size: 6px; }</style> <style>.archloot { fill: #ffffff; font-size: 4px; }</style><rect width="100%" height="100%" fill="';
        string memory p0 = '"/><rect x="4" y="4" width="97.7%" height="98%" fill="#242925"/> <rect x="4" y="4" width="5%" height="98%" fill="#2c302d"/> <rect x="104" y="4" width="5%" height="98%" fill="#2c302d"/> <rect x="204" y="4" width="5%" height="88%" fill="#2c302d"/><image id="image0" width="128.5" height="27.2" x="210" y="315" href="data:image/png;base64,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 KzAwOjAwiHjs8AAAAABJRU5ErkJggg==" />';

        bytes memory data;
        // Attribute ID 0, which represents the rarity
        if (attrData[0].attrValue == 1) {
            // blue
            data = abi.encodePacked(output, '#0026ed', p0,'<text x="6" y="12" class="lineCount">');
        } else if (attrData[0].attrValue == 2) {
            // purple
            data = abi.encodePacked(output, '#7F007F', p0,'<text x="6" y="12" class="lineCount">');
        } else if (attrData[0].attrValue == 3) {
            // orange
            data = abi.encodePacked(output, '#FF8000', p0,'<text x="6" y="12" class="lineCount">');
        } else if (attrData[0].attrValue == 4) {
            // red
            data = abi.encodePacked(output, '#FF0000', p0,'<text x="6" y="12" class="lineCount">');
        } else {
            // white
            data = abi.encodePacked(output, '#FFFFFF', p0,'<text x="6" y="12" class="lineCount">');
        }

        Solid memory solid = Solid(
                "????",
                "value",
                "To be discovered",
                '</text><text x="',
                '" y="',
                '" class="key">',
                '" class="value">',
                '" class="lineCount">'
            );

        // x base: 6 24 40 interval: 100
        // y base: 12      interval: 11

        for (uint256 i = 1; i <= 90; i++) {
            uint256 xs;
            string memory y;
            if (i % 31 == 0) {
                y = toString(12 + (31 - 1) * 11);
                xs = i / 31 - 1;
            }else{
                y = toString(12 + (i % 31 - 1) * 11);
                xs = i / 31;
            }
            if (i < len) {
                AttributeData memory attrData_ = attrData[i];
                uint256 integer;
                uint256 decimal;
                bytes memory value;
                if (attrData_.attrValue > 1e5){
                    integer = attrData_.attrValue / 1e8;
                    decimal = attrData_.attrValue - integer * 1e8;
                    bytes memory zero;
                    value = toBytes(decimal);
                    if (value.length != 8) {
                        for (uint256 j = 0; j < 8 - value.length; j++) {
                            zero = abi.encodePacked(zero, "0");
                        }
                    }
                    value = abi.encodePacked(toString(integer), ".",zero, value);
                }else{
                    value = bytes(toString(attrData_.attrValue));
                }
                if (i == 1) {
                    data = abi.encodePacked(
                        data,
                        abi.encodePacked(
                            toString(attrData_.attrID),
                            solid.p1,
                            toString(24 + xs * 100)),
                        abi.encodePacked(
                            solid.p2,
                            y,
                            solid.p3),
                        abi.encodePacked(
                            solid.value,
                            solid.p1,
                            toString(40 + xs * 100)),
                        abi.encodePacked(
                            solid.p2,
                            y,
                            solid.p4),
                        abi.encodePacked(
                            value,
                            solid.p1
                        )
                    );
                }else{
                    data = abi.encodePacked(
                        data,
                        abi.encodePacked(
                            toString(6 + xs * 100),
                            solid.p2,
                            y),
                        abi.encodePacked(
                            solid.p5,
                            toString(attrData_.attrID),
                            solid.p1),
                        abi.encodePacked(
                            toString(24 + xs * 100),
                            solid.p2,
                            y),
                        abi.encodePacked(
                            solid.p3,
                            solid.value,
                            solid.p1),
                        abi.encodePacked(
                            toString(40 + xs * 100),
                            solid.p2,
                            y),
                        abi.encodePacked(
                            solid.p4,
                            value,
                            solid.p1)
                    );
                }
            }else{
                if (i == 90) {
                    data = abi.encodePacked(
                        data,
                        abi.encodePacked(
                            toString(6 + xs * 100),
                            solid.p2,
                            y),
                        abi.encodePacked(
                            solid.p5,
                            solid.question,
                            solid.p1),
                        abi.encodePacked(
                            toString(24 + xs * 100),
                            solid.p2,
                            y),
                        abi.encodePacked(
                            solid.p3,
                            solid.value,
                            solid.p1),
                        abi.encodePacked(
                            toString(40 + xs * 100),
                            solid.p2,
                            y),
                        abi.encodePacked(
                            solid.p4,
                            solid.discovered)
                    );
                }else {
                    data = abi.encodePacked(
                        data,
                        abi.encodePacked(
                            toString(6 + xs * 100),
                            solid.p2,
                            y),
                        abi.encodePacked(
                            solid.p5,
                            solid.question,
                            solid.p1),
                        abi.encodePacked(
                            toString(24 + xs * 100),
                            solid.p2,
                            y),
                        abi.encodePacked(
                            solid.p3,
                            solid.value,
                            solid.p1),
                        abi.encodePacked(
                            toString(40 + xs * 100),
                            solid.p2,
                            y),
                        abi.encodePacked(
                            solid.p4,
                            solid.discovered,
                            solid.p1)
                    );
                }
                
            }
        }

        data = abi.encodePacked(data, "</text></svg>");

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"description": "GameLoot is a general NFT for games. Images, attribute name and other functionality are intentionally omitted for each game to interprets. You can use gameLoot as you like in a variety of games.", "image": "data:image/svg+xml;base64,',
                        Base64.encode(data),
                        '"}'
                    )
                )
            )
        );
        output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        return output;
    }

    function toString(uint256 value) internal pure returns (string memory) {
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

    function toBytes(uint256 value) internal pure returns (bytes memory) {
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
        return buffer;
    }
}

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

struct AttributeData {
    uint128 attrID;
    uint128 attrValue;
}

struct AttrMetadataStruct {
    uint256 attrID;
    string name;
}

interface IGameERC20Token {
    function mint(address account, uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <[email protected]>
library Base64 {
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}