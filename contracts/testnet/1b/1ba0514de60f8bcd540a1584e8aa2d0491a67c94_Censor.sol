/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
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

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

contract Censor {

    using Strings for uint256;
    
    string constant private _MESSAGE_TAG = '<MESSAGE>';
    string[] private _imageParts;

    constructor() {
        _imageParts.push("<svg xmlns='http://www.w3.org/2000/svg' width='1000' height='1000' viewBox='0 0 1000 1000'>");
            _imageParts.push("<style>@font-face {font-family: 'C';src: ");
            _imageParts.push("url('data:font/woff2;charset=utf-8;base64,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') format('woff2');");
            _imageParts.push("font-weight: 500; font-style: normal; font-display: swap;}");
            _imageParts.push(".f { width: 100%; height: 100%; }");
            _imageParts.push(".b { fill: whitesmoke; }");
            _imageParts.push(".a { animation: o 2s ease-out forwards; }");
            _imageParts.push("@keyframes o { 10% { opacity: 1; } 100% { opacity: 0; } }");
            _imageParts.push("tspan { fill: black; font-family: 'C'; font-size: 70px; text-transform: uppercase; text-anchor: middle; }");
            _imageParts.push("</style>");
            _imageParts.push("<rect class='b f' />");
            _imageParts.push(_MESSAGE_TAG);
            _imageParts.push("<rect class='b f a' />");
        _imageParts.push("</svg>");
    }

    function metadata(uint256 tokenId, string memory message, uint256 value) external view returns(string memory) {
        return string(abi.encodePacked('data:application/json;utf8,{"name":"Censored #',tokenId.toString(),'", "description":"',_toUpperCase(message),'", "created_by":"Pak", "image":"data:image/svg+xml;utf8,',
            svg(tokenId, message, value),
            '","attributes":[{"trait_type":"Censored","value":"True"},{"trait_type":"Initial Price","value":',_valueString(value),'}]}'));
    }

    function _toUpperCase(string memory message) private pure returns (string memory) {
        bytes memory messageBytes = bytes(message);
        bytes memory upperMessageBytes = new bytes(messageBytes.length);
        for (uint i = 0; i < messageBytes.length; i++) {
            bytes1 char = messageBytes[i];
            if (char >= 0x61 && char <= 0x7A) {
                // So we add 32 to make it lowercase
                upperMessageBytes[i] = bytes1(uint8(char) - 32);
            } else {
                upperMessageBytes[i] = char;
            }
        }
        return string(upperMessageBytes);
    }

    function _renderLines(string memory message) private pure returns (string memory) {
        // Allocate memory for max number of lines (7) at 18 characters each (126)
        bytes memory lineBytes = new bytes(126);
        uint8[] memory lineLengths = new uint8[](7);
        
        // Compute line count
        bytes memory messageBytes = bytes(message);
        uint8 wordLength;
        uint8 lineLength;
        uint8 lineIndex;
        uint256 messageLastIndex = messageBytes.length-1;
        for (uint i = 0; i <= messageLastIndex; i++) {
            bytes1 char = messageBytes[i];
            if (i == 0 || char != 0x20 || i == messageLastIndex) {
                wordLength += 1;
            }
            if (char == 0x20 || i == messageLastIndex) {
                // Check line length is < 18 after adding new word
                if ((lineLength == 0 && lineLength + wordLength <= 18) || (lineLength + wordLength <= 17)) {
                    // Add into the current lineBytes
                    uint256 lineBytesOffset = lineIndex*18;
                    if (lineLength > 0) {
                       // Additional word, add a space
                       lineBytes[lineBytesOffset+lineLength] = 0x20;
                       lineLength += 1;
                    }
                    for (uint j = 0; j < wordLength; j++) {
                        lineBytes[lineBytesOffset+lineLength+j] = messageBytes[(i == messageLastIndex ? 1 : 0)+i-wordLength+j];
                    }
                    lineLength += wordLength;
                    lineLengths[lineIndex] = lineLength;
                } else {
                    // Word plus existing line length over max
                    if (wordLength > 18) {
                        if (lineLength > 0) {
                            // Move to new line if there have already been words added to this line
                            lineIndex += 1;
                            lineLength = 0;
                        }
                        uint256 lineBytesOffset = lineIndex*18;
                        for (uint j = 0; j < wordLength; j++) {
                            lineLength += 1;
                            lineBytes[lineBytesOffset+(j % 18)] = messageBytes[(i == messageLastIndex ? 1 : 0)+i-wordLength+j];
                            if (j > 0 && j % 18 == 17) {
                                // New line every 18 characters
                                lineLengths[lineIndex] = lineLength;
                                lineIndex += 1;
                                lineLength = 0;
                                lineBytesOffset = lineIndex*18;
                            }
                        }
                        lineLengths[lineIndex] = lineLength;
                    } else {
                        // New line
                        lineIndex += 1;
                        uint256 lineBytesOffset = lineIndex*18;
                        for (uint j = 0; j < wordLength; j++) {
                            lineBytes[lineBytesOffset+j] = messageBytes[(i == messageLastIndex ? 1 : 0)+i-wordLength+j];
                        }
                        lineLength = wordLength;
                        lineLengths[lineIndex] = lineLength;
                    }
                }
                wordLength = 0;
            }
        }

        string memory lines;
        string memory strikeouts;
        uint8 lineCount;
        for (uint i = 0; i <= lineIndex; i++) {
            uint256 lineBytesOffset = i*18;
            if (lineLengths[i] > 0) {
               lineCount += 1;
               bytes memory line = new bytes(lineLengths[i]);
               bytes memory strikeout = new bytes(lineLengths[i]);
               for (uint j = 0; j < lineLengths[i]; j++) {
                   line[j] = lineBytes[lineBytesOffset+j];
                   strikeout[j] = 0x2D;
               }
               if (i == 0) {
                   lines = string(abi.encodePacked(lines,"<tspan x='500'>",line,"</tspan>"));
                   strikeouts = string(abi.encodePacked(strikeouts,"<tspan x='500'>",strikeout,"</tspan>"));
               } else {
                   lines = string(abi.encodePacked(lines,"<tspan x='500' dy='1em'>",line,"</tspan>"));
                   strikeouts = string(abi.encodePacked(strikeouts,"<tspan x='500' dy='1em'>",strikeout,"</tspan>"));
               }
            }
        }
        return string(abi.encodePacked("<svg y='",(560-uint256(lineCount)*35).toString(),"' overflow='visible'><text>",lines,"</text><text>",strikeouts,"</text></svg>"));
    }

    function _valueString(uint256 value) private pure returns (string memory) {
        uint256 eth = value/10**18;
        uint256 decimal4 = value/10**14 - eth*10**4;
        return string(abi.encodePacked(eth.toString(), '.', _decimal4ToString(decimal4)));
    }

    function _decimal4ToString(uint256 decimal4) private pure returns (string memory) {
        bytes memory decimal4Characters = new bytes(4);
        for (uint i = 0; i < 4; i++) {
            decimal4Characters[3 - i] = bytes1(uint8(0x30 + decimal4 % 10));
            decimal4 /= 10;
        }
        return string(abi.encodePacked(decimal4Characters));
    }

    function svg(uint256, string memory message, uint256) public view returns(string memory) {
        bytes memory byteString;
        for (uint i = 0; i < _imageParts.length; i++) {
            if (_checkTag(_imageParts[i], _MESSAGE_TAG)) {
                byteString = abi.encodePacked(byteString, _renderLines(message));
            } else {
                byteString = abi.encodePacked(byteString, _imageParts[i]);
            }
        }
        return string(byteString);
    }

    function _checkTag(string storage a, string memory b) private pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}