// SPDX-License-Identifier: MIT LICENSE

    pragma solidity ^0.8.0;

    import "@openzeppelin/contracts/access/Ownable.sol";
    import "@openzeppelin/contracts/utils/Strings.sol";
    import "./interfaces/IMetadata.sol";
    import "./interfaces/INFT.sol";

    contract Metadata is Ownable, IMetadata {

        using Strings for uint256;

        uint256 private levelTypeIndex = 17;

        struct Meta {
            string name;
            string png;
        }

        string masterBackground;
        string slaveBackground;

        string[12] _metaTypes = [
        "Background",
        "Player",     
        "Laser",         
        "Glass",        
        "Nipple",        
        "Necklace",   
        "Top Hat",     
        "Update",       
        "Update",       
        "Update",             
        "MasterAttribut",
        "LevelAttribut"
        ];
        mapping(uint8 => mapping(uint8 => Meta)) public metaData;
        mapping(uint8 => uint8) public metaCountForType;
        string[4] _levels = [
        "8",
        "7",
        "6",
        "5"
        ];

        INFT public masterAndSlave;
    

        function selectMeta(uint16 seed, uint8 metaType) external view override returns(uint8) {
            if (metaType == levelTypeIndex) {
                uint256 chance = seed % 100;
                if (chance > 95) {
                    return 0;
                } else if (chance > 80) {
                    return 1;
                } else if (chance > 50) {
                    return 2;
                } else {
                    return 3;
                }
            }
            uint8 modOf = metaCountForType[metaType] > 0 ? metaCountForType[metaType] : 10;
            return uint8(seed % modOf);
        }


        function setGame(address _masterAndSlave) external onlyOwner {
            masterAndSlave = INFT(_masterAndSlave);
        }

        function uploadBackground(string calldata _master, string calldata _slave) external onlyOwner {
            masterBackground = _master;
            slaveBackground = _slave;
        }

        function uploadBackgroundMaster(string calldata _master) external onlyOwner {
            masterBackground = _master;
        }

        function uploadBackgroundSlave(string calldata _slave) external onlyOwner {
            slaveBackground = _slave;
        }


        function uploadMetadata(uint8 metaType, uint8[] calldata metaIds, Meta[] calldata metadata) external onlyOwner {
            require(metaIds.length == metadata.length, "Mismatched inputs");
            for (uint i = 0; i < metadata.length; i++) {
                metaData[metaType][metaIds[i]] = Meta(
                    metadata[i].name,
                    metadata[i].png
                );
            }
        }

        function setMetaCountForType(uint8[] memory _tType, uint8[] memory _len) public onlyOwner {
            for (uint i = 0; i < _tType.length; i++) {
                metaCountForType[_tType[i]] = _len[i];
            }
        }

    function withdraw() external onlyOwner {  
        address receiver = owner();
        payable(receiver).transfer(address(this).balance);
    }
    

        function drawMeta(Meta memory meta) internal pure returns (string memory) {
            return string(abi.encodePacked(
                    '<image x="4" y="4" width="32" height="32" image-rendering="pixelated" preserveAspectRatio="xMidYMid" xlink:href="data:image/png;base64,',
                    meta.png,
                    '"/>'
                ));
        }

        function draw(string memory png) internal pure returns (string memory) {
            return string(abi.encodePacked(
                    '<image x="4" y="4" width="32" height="32" image-rendering="pixelated" preserveAspectRatio="xMidYMid" xlink:href="data:image/png;base64,',
                    png,
                    '"/>'
                ));
        }

        function drawSVG(uint256 tokenId) public view returns (string memory) {
            INFT.NFTMetadata memory s = masterAndSlave.getTokenMetadata(tokenId);
            uint8 shift = s.isSlave ? 0 : 10;

            string memory Layer0to6 = string(abi.encodePacked(
                    drawMeta(metaData[0 + shift][s.Layer0 % metaCountForType[0 + shift]]),     
                    s.isSlave ? draw(slaveBackground) : draw(masterBackground),  
                    drawMeta(metaData[1 + shift][s.Layer1 % metaCountForType[1 + shift]]), 
                    drawMeta(metaData[2 + shift][s.Layer2 % metaCountForType[2 + shift]]),
                    drawMeta(metaData[3 + shift][s.Layer3 % metaCountForType[3 + shift]]),
                    drawMeta(metaData[4 + shift][s.Layer4 % metaCountForType[4 + shift]]),
                    drawMeta(metaData[5 + shift][s.Layer5 % metaCountForType[5 + shift]]),
                    drawMeta(metaData[6 + shift][s.Layer6 % metaCountForType[6 + shift]])           
                ));

            string memory Layer7to11 = string(abi.encodePacked(
                    drawMeta(metaData[7 + shift][s.Layer7 % metaCountForType[7 + shift]]),
                    drawMeta(metaData[8 + shift][s.Layer8 % metaCountForType[8 + shift]]),
                    drawMeta(metaData[9 + shift][s.Layer9 % metaCountForType[9 + shift]]),
                    !s.isSlave ? drawMeta(metaData[10 + shift][s.masterAttribut % metaCountForType[10 + shift]]) : '',
                    !s.isSlave ? drawMeta(metaData[11 + shift][s.levelIndex]) : ''                  
                ));

            string memory svgString = string(abi.encodePacked(Layer0to6,Layer7to11));

            return string(abi.encodePacked(
                    '<svg id="masterAndSlave" width="100%" height="100%" version="1.1" viewBox="0 0 40 40" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">',
                    svgString,
                    "</svg>"
                ));
        }

        function attributeForTypeAndValue(string memory metaType, string memory value) internal pure returns (string memory) {
            return string(abi.encodePacked(
                    "{",'"meta_type":"',
                    metaType,
                    '","value":"',
                    value,
                    '"},'
                ));
        }

        function compileAttributes(uint256 tokenId) public view returns (string memory) {
            INFT.NFTMetadata memory s = masterAndSlave.getTokenMetadata(tokenId);
            uint8 shift = s.isSlave ? 0 : 10;

            string memory Layer0to6 = string(abi.encodePacked(                
                        attributeForTypeAndValue(_metaTypes[0], metaData[0 + shift][s.Layer0 % metaCountForType[0 + shift]].name),
                        attributeForTypeAndValue(_metaTypes[1], metaData[1 + shift][s.Layer1 % metaCountForType[1 + shift]].name),
                        attributeForTypeAndValue(_metaTypes[2], metaData[2 + shift][s.Layer2 % metaCountForType[2 + shift]].name),
                        attributeForTypeAndValue(_metaTypes[3], metaData[3 + shift][s.Layer3 % metaCountForType[3 + shift]].name),
                        attributeForTypeAndValue(_metaTypes[4], metaData[4 + shift][s.Layer4 % metaCountForType[4 + shift]].name),
                        attributeForTypeAndValue(_metaTypes[5], metaData[5 + shift][s.Layer5 % metaCountForType[5 + shift]].name),
                        attributeForTypeAndValue(_metaTypes[6], metaData[6 + shift][s.Layer6 % metaCountForType[6 + shift]].name)
            ));

            string memory Layer7to11 = string(abi.encodePacked(
                        attributeForTypeAndValue(_metaTypes[7], metaData[7 + shift][s.Layer7 % metaCountForType[7 + shift]].name),
                        attributeForTypeAndValue(_metaTypes[8], metaData[8 + shift][s.Layer8 % metaCountForType[8 + shift]].name),
                        attributeForTypeAndValue(_metaTypes[9], metaData[9 + shift][s.Layer9 % metaCountForType[9 + shift]].name),
                        !s.isSlave ? attributeForTypeAndValue(_metaTypes[10], metaData[10 + shift][s.masterAttribut % metaCountForType[10 + shift]].name) : '',
                        !s.isSlave ? attributeForTypeAndValue(_metaTypes[11], metaData[11 + shift][s.levelIndex % metaCountForType[11 + shift]].name) : '',
                        !s.isSlave ? attributeForTypeAndValue("Level Score", _levels[s.levelIndex]) : ''
            ));

            string memory metadata = string(abi.encodePacked(Layer0to6,Layer7to11));


            return string(abi.encodePacked(
                    '[',
                    metadata,
                    "{",'"meta_type":"Generation","value":',
                    tokenId <= masterAndSlave.getPaidTokens() ? '"Gen 0"' : '"Gen 1"',
                    "},{",'"meta_type":"Type","value":',
                    s.isSlave ? '"Slave"' : '"Master"',
                    "}]"
                ));
        }

        function tokenURI(uint256 tokenId) public view override returns (string memory) {
            INFT.NFTMetadata memory s = masterAndSlave.getTokenMetadata(tokenId);

            string memory metadataGame = string(abi.encodePacked(
                    "{",'"name": "',
                    s.isSlave ? 'Slave #' : 'Master #',
                    tokenId.toString(),
                    '", "description":  "Slave & Master Game" is the next-generation NFT game on FTM that incorporates likelihood-based game derivatives in addition to NFT. With a wide range of choices and decision options, Slave & Master Game promises to generate an exciting and inquisitive community as each individual adopts different strategies to outperform the others and come out on top. The real question is: Are you #TeamSlave or #TeamMaster? Choose wisely or wait and watch the other get rich!", "image": "data:image/svg+xml;base64,',
                    base64(bytes(drawSVG(tokenId))),
                    '", "attributes":',
                    compileAttributes(tokenId),
                    "}"
                ));

            return string(abi.encodePacked(
                    "data:application/json;base64,",
                    base64(bytes(metadataGame))
                ));
        }


        string internal constant TABLE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

        function base64(bytes memory data) internal pure returns (string memory) {
            if (data.length == 0) return '';

            string memory table = TABLE;

            uint256 encodedLen = 4 * ((data.length + 2) / 3);

            string memory result = new string(encodedLen + 32);

            assembly {
                mstore(result, encodedLen)

                let tablePtr := add(table, 1)

                let dataPtr := data
                let endPtr := add(dataPtr, mload(data))

                let resultPtr := add(result, 32)

                for {} lt(dataPtr, endPtr) {}
                {
                    dataPtr := add(dataPtr, 3)

                    let input := mload(dataPtr)

                    mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F)))))
                    resultPtr := add(resultPtr, 1)
                    mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F)))))
                    resultPtr := add(resultPtr, 1)
                    mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(6, input), 0x3F)))))
                    resultPtr := add(resultPtr, 1)
                    mstore(resultPtr, shl(248, mload(add(tablePtr, and(input, 0x3F)))))
                    resultPtr := add(resultPtr, 1)
                }

                switch mod(mload(data), 3)
                case 1 {mstore(sub(resultPtr, 2), shl(240, 0x3d3d))}
                case 2 {mstore(sub(resultPtr, 1), shl(248, 0x3d))}
            }

            return result;
        }
    }

// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.0;

interface INFT {
  struct NFTMetadata {
    bool isSlave;
    uint8 Layer0; 
    uint8 Layer1;
    uint8 Layer2;
    uint8 Layer3;
    uint8 Layer4;
    uint8 Layer5;
    uint8 Layer6;
    uint8 Layer7;
    uint8 Layer8;
    uint8 Layer9;
    uint8 masterAttribut;
    uint8 levelIndex;
  }

  function getPaidTokens() external view returns (uint256);

  function getTokenMetadata(uint256 tokenId)
    external
    view
    returns (NFTMetadata memory);
}

// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.0;

interface IMetadata {
  function tokenURI(uint256 tokenId) external view returns (string memory);

  function selectMeta(uint16 seed, uint8 metaType)
    external
    view
    returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}