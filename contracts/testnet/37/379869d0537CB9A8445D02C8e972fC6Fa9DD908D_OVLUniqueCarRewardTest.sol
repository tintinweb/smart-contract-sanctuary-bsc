// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

contract OVLUniqueCarRewardTest {
    uint256 private constant NUM_OF_PART = 4;

    mapping(string => bool) private combinations;
    mapping(string => bool) private claimed;

    mapping(uint256 => bool) private usedParts;

    uint256 public reward;

    constructor(uint256 _reward) {
        reward = _reward;
    }

    function initCombination(string[] memory _carIds) public returns (bool) {
        for (uint256 i = 0; i < _carIds.length; i++) {
            combinations[_carIds[i]] = true;
        }
        return true;
    }

    function checkCombination(string memory _carId) public view returns (bool) {
        return combinations[_carId] && !claimed[_carId];
    }

    function claimReward(uint256[] calldata _assetIds) public returns (bool) {
        require(_assetIds.length == NUM_OF_PART, "not enought part");

        // get asset id

        // validate car part
        if (_checkCarPart(_assetIds)) {
            // check combination
            string memory carId = _computeCarId(_assetIds);
            if (checkCombination(carId)) {
                claimed[carId] = true;

                return (true);
            } else {
                revert("combination invalid");
            }
        } else {
            revert("car part invalid");
        }
    }

    function _checkCarPart(uint256[] memory _assetIds)
        private
        pure
        returns (bool)
    {
        for (uint256 i = 0; i < _assetIds.length; i++) {
            if (_formatId(_assetIds[i]) != i) {
                return false;
            }
        }
        return true;
    }

    function _formatId(uint256 _assetId) private pure returns (uint256) {
        uint256 tmp = (_assetId / 100000) % 10;
        return tmp;
    }

    // compute car id
    function _computeCarId(uint256[] memory _tokenIds)
        private
        pure
        returns (string memory)
    {
        uint256 value;
        value |= _tokenIds[0];
        value |= (_tokenIds[1] << 31);
        value |= (_tokenIds[2] << 63);
        value |= (_tokenIds[3] << 94);

        return Strings.toString(value);
    }
}

// 0xc0C165F4A5360e30BF6ADa4aa4bC251630fcFd48

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