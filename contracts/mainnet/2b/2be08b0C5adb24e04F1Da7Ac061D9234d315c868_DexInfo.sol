/**
 *Submitted for verification at BscScan.com on 2022-10-27
*/

// File: contracts/interfaces/swap/IDexInfo.sol


pragma solidity >=0.5.0;

interface IDexInfo {
    function recordPool(address token0, address token1, uint projectID, uint poolId) external;
    function updatePrice(address token0, address token1, uint reserve0, uint reserve1) external;
    function getPool(address ctr, address token0, address token1, uint projectId) external view returns(uint);
    function getPrice(address ctr, address token0, address token1) external view returns (uint,uint);

}
// File: contracts/libraries/LowGasSafeMath.sol


pragma solidity >=0.7.6;

/// @title Optimized overflow and underflow safe math operations
/// @notice Contains methods for doing math operations that revert on overflow or underflow for minimal gas cost
library LowGasSafeMath {
    /// @notice Returns x + y, reverts if sum overflows uint256
    /// @param x The augend
    /// @param y The addend
    /// @return z The sum of x and y
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x);
    }

    /// @notice Returns x - y, reverts if underflows
    /// @param x The minuend
    /// @param y The subtrahend
    /// @return z The difference of x and y
    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x);
    }

    function sub(uint120 x, uint120 y) internal pure returns (uint120 z) {
        require((z = x - y) <= x);
    }

    /// @notice Returns x * y, reverts if overflows
    /// @param x The multiplicand
    /// @param y The multiplier
    /// @return z The product of x and y
    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(x == 0 || (z = x * y) / x == y);
    }

    /// @notice Returns x + y, reverts if overflows or underflows
    /// @param x The augend
    /// @param y The addend
    /// @return z The sum of x and y
    function add(int256 x, int256 y) internal pure returns (int256 z) {
        require((z = x + y) >= x == (y >= 0));
    }

    /// @notice Returns x - y, reverts if overflows or underflows
    /// @param x The minuend
    /// @param y The subtrahend
    /// @return z The difference of x and y
    function sub(int256 x, int256 y) internal pure returns (int256 z) {
        require((z = x - y) <= x == (y >= 0));
    }
}

// File: contracts/libraries/FullMath.sol


pragma solidity >=0.7.6;

/// @title Contains 512-bit math functions
/// @notice Facilitates multiplication and division that can have overflow of an intermediate value without any loss of precision
/// @dev Handles "phantom overflow" i.e., allows multiplication and division where an intermediate value overflows 256 bits
library FullMath {
    /// @notice Calculates floor(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        // 512-bit multiply [prod1 prod0] = a * b
        // Compute the product mod 2**256 and mod 2**256 - 1
        // then use the Chinese Remainder Theorem to reconstruct
        // the 512 bit result. The result is stored in two 256
        // variables such that product = prod1 * 2**256 + prod0
        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        // Handle non-overflow cases, 256 by 256 division
        if (prod1 == 0) {
            require(denominator > 0);
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }

        // Make sure the result is less than 2**256.
        // Also prevents denominator == 0
        require(denominator > prod1);

        ///////////////////////////////////////////////
        // 512 by 256 division.
        ///////////////////////////////////////////////

        // Make division exact by subtracting the remainder from [prod1 prod0]
        // Compute remainder using mulmod
        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)
        }
        // Subtract 256 bit number from 512 bit number
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        // Factor powers of two out of denominator
        // Compute largest power of two divisor of denominator.
        // Always >= 1.
        uint256 twos = denominator & (~denominator + 1);
        // Divide denominator by power of two
        assembly {
            denominator := div(denominator, twos)
        }

        // Divide [prod1 prod0] by the factors of two
        assembly {
            prod0 := div(prod0, twos)
        }
        // Shift in bits from prod1 into prod0. For this we need
        // to flip `twos` such that it is 2**256 / twos.
        // If twos is zero, then it becomes one
        assembly {
            twos := add(div(sub(0, twos), twos), 1)
        }
        prod0 |= prod1 * twos;

        // Invert denominator mod 2**256
        // Now that denominator is an odd number, it has an inverse
        // modulo 2**256 such that denominator * inv = 1 mod 2**256.
        // Compute the inverse by starting with a seed that is correct
        // correct for four bits. That is, denominator * inv = 1 mod 2**4
        uint256 inv = (3 * denominator) ^ 2;
        // Now use Newton-Raphson iteration to improve the precision.
        // Thanks to Hensel's lifting lemma, this also works in modular
        // arithmetic, doubling the correct bits in each step.
        inv *= 2 - denominator * inv; // inverse mod 2**8
        inv *= 2 - denominator * inv; // inverse mod 2**16
        inv *= 2 - denominator * inv; // inverse mod 2**32
        inv *= 2 - denominator * inv; // inverse mod 2**64
        inv *= 2 - denominator * inv; // inverse mod 2**128
        inv *= 2 - denominator * inv; // inverse mod 2**256

        // Because the division is now exact we can divide by multiplying
        // with the modular inverse of denominator. This will give us the
        // correct result modulo 2**256. Since the precoditions guarantee
        // that the outcome is less than 2**256, this is the final result.
        // We don't need to compute the high bits of the result and prod1
        // is no longer required.
        result = prod0 * inv;
        return result;
    }

    /// @notice Calculates ceil(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        result = mulDiv(a, b, denominator);
        if (mulmod(a, b, denominator) > 0) {
            require(result < type(uint256).max);
            result++;
        }
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }
}

// File: contracts/libraries/SafeCast.sol


pragma solidity >=0.7.6;

/// @title Safe casting methods
/// @notice Contains methods for safely casting between types
library SafeCast {
    /// @notice Cast a uint256 to a uint160, revert on overflow
    /// @param y The uint256 to be downcasted
    /// @return z The downcasted integer, now type uint160
    function toUint160(uint256 y) internal pure returns (uint160 z) {
        require((z = uint160(y)) == y);
    }

    function toUint96(uint256 y) internal pure returns (uint96 z) {
        require((z = uint96(y)) == y);
    }

    function toUint16(uint256 y) internal pure returns (uint16 z) {
        require((z = uint16(y)) == y);
    }

    function toUint64(uint256 y) internal pure returns (uint64 z) {
        require((z = uint64(y)) == y);
    }

    function toUint120(uint256 y) internal pure returns (uint120 z) {
        require((z = uint120(y)) == y);
    }

    function toUint240(uint256 y) internal pure returns (uint240 z) {
        require((z = uint240(y)) == y);
    }
    
    function toUint128(uint256 y) internal pure returns (uint128 z) {
        require((z = uint128(y)) == y);
    }

    /// @notice Cast a int256 to a int128, revert on overflow or underflow
    /// @param y The int256 to be downcasted
    /// @return z The downcasted integer, now type int128
    function toInt128(int256 y) internal pure returns (int128 z) {
        require((z = int128(y)) == y);
    }

    /// @notice Cast a uint256 to a int256, revert on overflow
    /// @param y The uint256 to be casted
    /// @return z The casted integer, now type int256
    function toInt256(uint256 y) internal pure returns (int256 z) {
        require(y < 2**255);
        z = int256(y);
    }
}

// File: contracts/swap/libraries/Oracle.sol


pragma solidity >=0.5.0;




/// @title Oracle
library Oracle {
    using SafeCast for uint256;
    using LowGasSafeMath for uint256;

    struct Info {
        uint32 blockTimestampLast;
        uint240 price0CumulativeLast; 
        uint240 price1CumulativeLast;
    }

    function update(
        Info storage self,
        uint256 _reserve0,
        uint256 _reserve1
    ) internal {
        Info memory _self = self;
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        uint32 timeElapsed = blockTimestamp - _self.blockTimestampLast;
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            (self.price0CumulativeLast, self.price1CumulativeLast, self.blockTimestampLast) = (
                FullMath.mulDiv(_reserve1, timeElapsed, _reserve0).add(_self.price0CumulativeLast).toUint240(),
                FullMath.mulDiv(_reserve0, timeElapsed, _reserve1).add(_self.price1CumulativeLast).toUint240(),
                blockTimestamp
            );
        }else{
            self.blockTimestampLast = blockTimestamp;
        }
    }

}
// File: contracts/swap/DexInfo.sol





pragma solidity 0.8.7;

contract DexInfo is IDexInfo{
    using Oracle for Oracle.Info;
    
    mapping(bytes32 => Oracle.Info) public priceOracle;
    
    /// @notice Used to record pool id
    // swap pool => keccak256(abi.encodePacked(tk0, tk1, projectID) => pool id
    mapping(address => mapping(bytes32 => uint)) public projectPool;

    function recordPool(address token0, address token1, uint projectID, uint poolId) external override{
        bytes32 poolHash = keccak256(abi.encodePacked(token0, token1, projectID));
        require(projectPool[msg.sender][poolHash] == 0,"AE");
        projectPool[msg.sender][poolHash] = poolId;
    }

    function updatePrice(address token0, address token1, uint reserve0, uint reserve1) external override{
        bytes32 pairHash = keccak256(abi.encodePacked(token0, token1, msg.sender));
        priceOracle[pairHash].update(reserve0, reserve1);
    } 

    function getPool(address ctr, address token0, address token1, uint projectId) external override view returns(uint){
        bytes32 poolHash = keccak256(abi.encodePacked(token0, token1, projectId));
        return projectPool[ctr][poolHash];
    }

    function getPrice(address ctr, address token0, address token1) external override view returns (uint,uint){
        bytes32 pairHash = keccak256(abi.encodePacked(token0, token1, ctr));
        Oracle.Info memory _info = priceOracle[pairHash];
        return (_info.price0CumulativeLast, _info.price1CumulativeLast);
    }
}