/**
 *Submitted for verification at BscScan.com on 2022-07-08
*/

// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.0;

interface IOwnable {
    function owner() external view returns (address);

    function renounceOwnership() external;

    function transferOwnership(address newOwner_) external;
}

contract Ownable is IOwnable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view override returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual override onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner_)
    public
    virtual
    override
    onlyOwner
    {
        require(
            newOwner_ != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner_);
        _owner = newOwner_;
    }
}

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
    function toHexString(uint256 value, uint256 length)
    internal
    pure
    returns (string memory)
    {
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
}

    struct TokenTrait {
        uint8 body;
        uint8 clothes;
        uint8 hair;
        uint8 jewelry;
        uint8 tatto;
        uint8 belt;
        uint8 sunglass;
        uint8 hat;
        uint8 mask;
        uint8 weapon;
    }

    struct TokenType {
        uint8 gen;
        uint8 level;
        uint8 kind; //  1 2 3  => Ganster swat eva  Lead(level 4 5)
        uint8 mintCount; // have a baby Count
    }

interface IRichcityNFT {
    // struct to store each token's traits

    function getTokenTraits(uint256 tokenId)
    external
    view
    returns (TokenTrait memory, TokenType memory);
}

contract Traits is Ownable {
    using Strings for uint256;
    // struct to store each trait's data for metadata and rendering
    struct Trait {
        string name;
        string png;
    }

    // mapping from trait type (index) to its name
    string[10] _traitTypes = [
    "Clothes",
    "Hair",
    "Jewelry",
    "Tatto",
    "Belt",
    "Sunglasses",
    "Hat",
    "Mask",
    "Weapon",
    "Body"
    ];
    // storage of each traits name and base64 PNG data
    mapping(uint8 => mapping(uint8 => Trait)) public traitData;
    mapping(uint8 => uint8) public traitCountForType;
    // mapping from authority to its score
    string[5] _level = ["1", "2", "3", "4", "5"];
    IRichcityNFT public game;

    function selectTrait(uint16 seed, uint8 traitType)
    external
    view
    returns (uint8)
    {
        uint8 modOf = traitCountForType[traitType] > 0
        ? traitCountForType[traitType]
        : 10;
        return uint8(seed % modOf);
    }

    /***ADMIN */

    function setGame(address _game) external onlyOwner {
        game = IRichcityNFT(_game);
    }

    /**
     * administrative to upload the names and images associated with each trait
     * @param traitType the trait type to upload the traits for (see traitTypes for a mapping)
     * @param traits the names and base64 encoded PNGs for each trait
     */
    function uploadTraits(
        uint8 traitType,
        uint8[] calldata traitIds,
        Trait[] calldata traits
    ) external onlyOwner {
        require(traitIds.length == traits.length, "Mismatched inputs");

        for (uint256 i = 0; i < traits.length; i++) {
            traitData[traitType][traitIds[i]] = Trait(
                traits[i].name,
                traits[i].png
            );
        }
    }

    function setTraitCountForType(
        uint8[] calldata _tType,
        uint8[] calldata _len
    ) external onlyOwner {
        for (uint256 i = 0; i < _tType.length; i++) {
            traitCountForType[_tType[i]] = _len[i];
        }
    }

    /***RENDER */

    /**
     * generates an <image> element using base64 encoded PNGs
     * @param trait the trait storing the PNG data
     * @return the <image> element
     */
    function drawTrait(Trait memory trait)
    internal
    pure
    returns (string memory)
    {
        return
        string(
            abi.encodePacked(
                '<image x="4" y="4" width="32" height="32" image-rendering="pixelated" preserveAspectRatio="xMidYMid" xlink:href="data:image/png;base64,',
                trait.png,
                '"/>'
            )
        );
    }

    /**
     * generates an entire SVG by composing multiple <image> elements of PNGs
     * @param tokenId the ID of the token to generate an SVG for
     * @return a valid SVG of the Adventurer / King
     */
    function drawSVG(uint256 tokenId) public view returns (string memory) {
        (TokenTrait memory s, TokenType memory s1) = game.getTokenTraits(
            tokenId
        );
        uint8 shift = s1.kind * 10;
        //  10 20 30 40
        if (s1.kind == 1 && s1.level > 4) shift = 40;
        string memory svgString;
        if (s1.kind == 1 && s1.level <= 4) {
            svgString = string(
                abi.encodePacked(
                    drawTrait(
                        traitData[5 + shift][
                        s.body % traitCountForType[5 + shift]
                        ]
                    ),
                    drawTrait(
                        traitData[8 + shift][
                        s.hair % traitCountForType[8 + shift]
                        ]
                    ),
                    drawTrait(
                        traitData[10 + shift][
                        s.tatto % traitCountForType[10 + shift]
                        ]
                    ),
                    drawTrait(
                        traitData[6 + shift][
                        s.clothes % traitCountForType[6 + shift]
                        ]
                    ),
                    drawTrait(
                        traitData[9 + shift][
                        s.jewelry % traitCountForType[9 + shift]
                        ]
                    )
                )
            );
        } else if (s1.kind == 1 && s1.level > 4) {
            svgString = string(
                abi.encodePacked(
                    drawTrait(
                        traitData[5 + shift][
                        s.body % traitCountForType[5 + shift]
                        ]
                    ),
                    drawTrait(
                        traitData[6 + shift][
                        s.clothes % traitCountForType[6 + shift]
                        ]
                    ),
                    drawTrait(
                        traitData[9 + shift][
                        s.belt % traitCountForType[9 + shift]
                        ]
                    ),
                    drawTrait(
                        traitData[8 + shift][
                        s.hair % traitCountForType[8 + shift]
                        ]
                    ),
                    drawTrait(
                        traitData[10 + shift][
                        s.sunglass % traitCountForType[10 + shift]
                        ]
                    )
                )
            );
        } else if (s1.kind == 2) {
            svgString = string(
                abi.encodePacked(
                    drawTrait(
                        traitData[5 + shift][
                        s.body % traitCountForType[5 + shift]
                        ]
                    ),
                    drawTrait(
                        traitData[8 + shift][
                        s.mask % traitCountForType[8 + shift]
                        ]
                    ),
                    drawTrait(
                        traitData[6 + shift][
                        s.clothes % traitCountForType[6 + shift]
                        ]
                    ),
                    drawTrait(
                        traitData[10 + shift][
                        s.hat % traitCountForType[10 + shift]
                        ]
                    ),
                    drawTrait(
                        traitData[9 + shift][
                        s.weapon % traitCountForType[9 + shift]
                        ]
                    )
                )
            );
        } else {
            svgString = string(
                abi.encodePacked(
                    drawTrait(
                        traitData[5 + shift][
                        s.body % traitCountForType[5 + shift]
                        ]
                    ),
                    drawTrait(
                        traitData[8 + shift][
                        s.jewelry % traitCountForType[8 + shift]
                        ]
                    ),
                    drawTrait(
                        traitData[9 + shift][
                        s.hair % traitCountForType[9 + shift]
                        ]
                    ),
                    drawTrait(
                        traitData[10 + shift][
                        s.tatto % traitCountForType[10 + shift]
                        ]
                    )
                )
            );
        }
        return
        string(
            abi.encodePacked(
                '<svg id="game" width="100%" height="100%" version="1.1" viewBox="0 0 40 40" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">',
                svgString,
                "</svg>"
            )
        );
    }

    /**
     * generates an attribute for the attributes array in the ERC721 metadata standard
     * @param traitType the trait type to reference as the metadata key
     * @param value the token's trait associated with the key
     * @return a JSON dictionary for the single attribute
     */
    function attributeForTypeAndValue(
        string memory traitType,
        string memory value
    ) internal pure returns (string memory) {
        return
        string(
            abi.encodePacked(
                '{"trait_type":"',
                traitType,
                '","value":"',
                value,
                '"}'
            )
        );
    }

    /**
     * generates an array composed of all the individual traits and values
     * @param tokenId the ID of the token to compose the metadata for
     * @return a JSON array of all of the attributes for given token ID
     */
    function compileAttributes(uint256 tokenId)
    public
    view
    returns (string memory)
    {
        (TokenTrait memory s, TokenType memory s1) = game.getTokenTraits(
            tokenId
        );
        uint8 shift = s1.kind * 10;
        if (s1.kind == 1 && s1.level > 4) shift = 40;
        string memory traits;
        if (s1.kind == 1 && s1.level <= 4) {
            traits = string(
                abi.encodePacked(
                    attributeForTypeAndValue(
                        _traitTypes[0],
                        traitData[6 + shift][
                        s.clothes % traitCountForType[6 + shift]
                        ].name
                    ),
                    ",",
                    attributeForTypeAndValue(
                        _traitTypes[1],
                        traitData[8 + shift][
                        s.hair % traitCountForType[8 + shift]
                        ].name
                    ),
                    ",",
                    attributeForTypeAndValue(
                        _traitTypes[2],
                        traitData[9 + shift][
                        s.jewelry % traitCountForType[9 + shift]
                        ].name
                    ),
                    ",",
                    attributeForTypeAndValue(
                        _traitTypes[3],
                        traitData[9 + shift][
                        s.tatto % traitCountForType[9 + shift]
                        ].name
                    ),
                    ",",
                    attributeForTypeAndValue(
                        _traitTypes[9],
                        traitData[5 + shift][
                        s.body % traitCountForType[5 + shift]
                        ].name
                    ),
                    ",",
                    attributeForTypeAndValue("Level", _level[s1.level - 1]),
                    ",",
                    attributeForTypeAndValue(
                        "MintCount",
                        uint256(s1.mintCount).toString()
                    ),
                    ","
                )
            );
        } else if (s1.kind == 1 && s1.level > 4) {
            traits = string(
                abi.encodePacked(
                    attributeForTypeAndValue(
                        _traitTypes[4],
                        traitData[9 + shift][
                        s.belt % traitCountForType[9 + shift]
                        ].name
                    ),
                    ",",
                    attributeForTypeAndValue(
                        _traitTypes[1],
                        traitData[8 + shift][
                        s.hair % traitCountForType[8 + shift]
                        ].name
                    ),
                    ",",
                    attributeForTypeAndValue(
                        _traitTypes[5],
                        traitData[10 + shift][
                        s.sunglass % traitCountForType[10 + shift]
                        ].name
                    ),
                    ",",
                    attributeForTypeAndValue(
                        _traitTypes[9],
                        traitData[5 + shift][
                        s.body % traitCountForType[5 + shift]
                        ].name
                    ),
                    ",",
                    attributeForTypeAndValue("Level", _level[s1.level - 1]),
                    ",",
                    attributeForTypeAndValue(
                        "MintCount",
                        uint256(s1.mintCount).toString()
                    ),
                    ","
                )
            );
        } else if (s1.kind == 2) {
            traits = string(
                abi.encodePacked(
                    attributeForTypeAndValue(
                        _traitTypes[0],
                        traitData[6 + shift][
                        s.clothes % traitCountForType[6 + shift]
                        ].name
                    ),
                    ",",
                    attributeForTypeAndValue(
                        _traitTypes[7],
                        traitData[8 + shift][
                        s.mask % traitCountForType[8 + shift]
                        ].name
                    ),
                    ",",
                    attributeForTypeAndValue(
                        _traitTypes[8],
                        traitData[9 + shift][
                        s.weapon % traitCountForType[9 + shift]
                        ].name
                    ),
                    ",",
                    attributeForTypeAndValue(
                        _traitTypes[6],
                        traitData[10 + shift][
                        s.hat % traitCountForType[10 + shift]
                        ].name
                    ),
                    ",",
                    attributeForTypeAndValue(
                        _traitTypes[9],
                        traitData[5 + shift][
                        s.body % traitCountForType[5 + shift]
                        ].name
                    ),
                    ",",
                    attributeForTypeAndValue("Level", _level[s1.level - 1]),
                    ",",
                    attributeForTypeAndValue(
                        "MintCount",
                        uint256(s1.mintCount).toString()
                    ),
                    ","
                )
            );
        } else {
            traits = string(
                abi.encodePacked(
                    attributeForTypeAndValue(
                        _traitTypes[2],
                        traitData[8 + shift][
                        s.jewelry % traitCountForType[8 + shift]
                        ].name
                    ),
                    ",",
                    attributeForTypeAndValue(
                        _traitTypes[1],
                        traitData[9 + shift][
                        s.hair % traitCountForType[9 + shift]
                        ].name
                    ),
                    ",",
                    attributeForTypeAndValue(
                        _traitTypes[3],
                        traitData[10 + shift][
                        s.tatto % traitCountForType[10 + shift]
                        ].name
                    ),
                    ",",
                    attributeForTypeAndValue(
                        _traitTypes[9],
                        traitData[5 + shift][
                        s.body % traitCountForType[5 + shift]
                        ].name
                    ),
                    ",",
                    attributeForTypeAndValue("Level", _level[s1.level - 1]),
                    ",",
                    attributeForTypeAndValue(
                        "MintCount",
                        uint256(s1.mintCount).toString()
                    ),
                    ","
                )
            );
        }
        return
        string(
            abi.encodePacked(
                "[",
                traits,
                '{"trait_type":"Generation","value":"',
                "Gen",
                uint256(s1.gen).toString(),
                '"},{"trait_type":"Type","value":',
                s1.kind == 1
                ? s1.level <= 4 ? '"Gangster"' : '"LEAD"'
                : s1.kind == 2
            ? '"SWAT"'
            : '"EVA"',
                "}]"
            )
        );
    }

    /**
     * generates a base64 encoded metadata response without referencing off-chain content
     * @param tokenId the ID of the token to generate the metadata for
     * @return a base64 encoded JSON dictionary of the token's metadata and SVG
     */
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        (, TokenType memory s1) = game.getTokenTraits(tokenId);

        string memory metadata = string(
            abi.encodePacked(
                '{"name": "',
                s1.kind == 1
                ? s1.level <= 4 ? "Gangster #" : "Gangster LEAD #"
                : s1.kind == 2
            ? "SWAT #"
            : "EVA #",
                tokenId.toString(),
                '", "description": "Welcome to the 1980s. From the decade of big hair, excess, and pastel suits comes a story of Gangsters rising to the top of the criminal pile as The RichDao Family returns. Rich City is a huge urban sprawl ranging from the beach to the swamps and the glitz to the ghetto. You arrive in a city brimming with delights and degradation and are given the opportunity to take it over as you choose.", "image": "data:image/svg+xml;base64,',
                base64(bytes(drawSVG(tokenId))),
                '", "attributes":',
                compileAttributes(tokenId),
                "}"
            )
        );

        return
        string(
            abi.encodePacked(
                "data:application/json;base64,",
                base64(bytes(metadata))
            )
        );
    }

    /***BASE 64 - Written by Brech Devos */

    string internal constant TABLE =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    function base64(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return "";

        // load the table into memory
        string memory table = TABLE;

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        // add some extra buffer at the end required for the writing
        string memory result = new string(encodedLen + 32);

        assembly {
        // set the actual output length
            mstore(result, encodedLen)

        // prepare the lookup table
            let tablePtr := add(table, 1)

        // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

        // result ptr, jump over length
            let resultPtr := add(result, 32)

        // run over the input, 3 bytes at a time
            for {

            } lt(dataPtr, endPtr) {

            } {
                dataPtr := add(dataPtr, 3)

            // read 3 bytes
                let input := mload(dataPtr)

            // write 4 characters
                mstore(
                resultPtr,
                shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                resultPtr,
                shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                resultPtr,
                shl(248, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                resultPtr,
                shl(248, mload(add(tablePtr, and(input, 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
            }

        // padding with '='
            switch mod(mload(data), 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }
        }

        return result;
    }
}