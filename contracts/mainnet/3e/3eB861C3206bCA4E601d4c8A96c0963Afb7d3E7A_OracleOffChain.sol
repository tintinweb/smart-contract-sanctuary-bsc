// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import './IOracleOffChain.sol';
import '../utils/NameVersion.sol';
import '../library/SafeMath.sol';

contract OracleOffChain is IOracleOffChain, NameVersion {

    using SafeMath for uint256;
    using SafeMath for int256;

    string  public symbol;
    bytes32 public immutable symbolId;
    address public immutable signer;
    uint256 public immutable delayAllowance;

    int256  public immutable jumpTimeWindow; // not necessarily equals to delayAllowance

    // stores timestamp/value/jump/lastSignagureTimestamp in 1 slot, instead of 4, to save gas
    // timestamp takes 32 bits, which can hold timestamp range from 1 to 4294967295 (year 2106)
    // value takes 96 bits with accuracy of 1e-18, which can hold value range from 1e-18 to 79,228,162,514.26
    struct Data {
        uint32 timestamp;
        uint96 value;
        int96  jump;
        uint32 lastSignatureTimestamp;
    }
    Data public data;

    constructor (string memory symbol_, address signer_, uint256 delayAllowance_, int256 jumpTimeWindow_, uint256 value_)
    NameVersion('OracleOffChain', '3.0.4')
    {
        symbol = symbol_;
        symbolId = keccak256(abi.encodePacked(symbol_));
        signer = signer_;
        delayAllowance = delayAllowance_;
        jumpTimeWindow = jumpTimeWindow_;
        data.value = uint96(value_);
    }

    function timestamp() external view returns (uint256) {
        return data.timestamp;
    }

    function value() external view returns (uint256) {
        return data.value;
    }

    function getValue() external view returns (uint256) {
        Data memory d = data;
        if (d.timestamp != block.timestamp) {
            revert(string(abi.encodePacked(
                bytes('OracleOffChain.getValue: '), bytes(symbol), bytes(' expired')
            )));
        }
        return d.value;
    }

    function updateValue(
        uint256 timestamp_,
        uint256 value_,
        uint8 v_,
        bytes32 r_,
        bytes32 s_
    ) external returns (bool)
    {
        require(value_ != 0 && value_ <= type(uint96).max);
        Data memory d = data;
        // this is the first update in this block and value_ is newer and valid (not too old)
        if (block.timestamp > d.timestamp && timestamp_ > d.lastSignatureTimestamp && block.timestamp < timestamp_ + delayAllowance) {
            bytes32 message = keccak256(abi.encodePacked(symbolId, timestamp_, value_));
            bytes32 hash = keccak256(abi.encodePacked('\x19Ethereum Signed Message:\n32', message));
            address signatory = ecrecover(hash, v_, r_, s_);
            require(signatory == signer, 'OracleOffChain.updateValue: invalid signature');

            int256 interval = (block.timestamp - d.timestamp).utoi();
            int256 jump;
            if (interval < jumpTimeWindow) {
                jump = d.jump * (jumpTimeWindow - interval) / jumpTimeWindow // previous jump impact
                     + (value_.utoi() - uint256(d.value).utoi());            // current jump impact
            } else {
                jump = (value_.utoi() - uint256(d.value).utoi()) * jumpTimeWindow / interval; // only current jump impact
            }

            require(jump >= type(int96).min && jump <= type(int96).max); // check jump overflows
            data = Data({
                timestamp:              uint32(block.timestamp),
                value:                  uint96(value_),
                jump:                   int96(jump),
                lastSignatureTimestamp: uint32(timestamp_)
            });

            emit NewValue(timestamp_, value_);
            return true;
        }
        return false;
    }

    function getValueWithJump() external view returns (uint256 val, int256 jump) {
        Data memory d = data;
        if (d.timestamp != block.timestamp) {
            revert(string(abi.encodePacked(
                bytes('OracleOffChain.getValueWithHistory: '), bytes(symbol), bytes(' expired')
            )));
        }
        return (d.value, d.jump);
    }

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import './INameVersion.sol';

/**
 * @dev Convenience contract for name and version information
 */
abstract contract NameVersion is INameVersion {

    bytes32 public immutable nameId;
    bytes32 public immutable versionId;

    constructor (string memory name, string memory version) {
        nameId = keccak256(abi.encodePacked(name));
        versionId = keccak256(abi.encodePacked(version));
    }

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import './IOracle.sol';

interface IOracleOffChain is IOracle {

    event NewValue(uint256 indexed timestamp, uint256 indexed value);

    function signer() external view returns (address);

    function delayAllowance() external view returns (uint256);

    function updateValue(
        uint256 timestamp,
        uint256 value,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (bool);

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

library SafeMath {

    uint256 constant UMAX = 2 ** 255 - 1;
    int256  constant IMIN = -2 ** 255;

    function utoi(uint256 a) internal pure returns (int256) {
        require(a <= UMAX, 'SafeMath.utoi: overflow');
        return int256(a);
    }

    function itou(int256 a) internal pure returns (uint256) {
        require(a >= 0, 'SafeMath.itou: underflow');
        return uint256(a);
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != IMIN, 'SafeMath.abs: overflow');
        return a >= 0 ? a : -a;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function max(int256 a, int256 b) internal pure returns (int256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a <= b ? a : b;
    }

    function min(int256 a, int256 b) internal pure returns (int256) {
        return a <= b ? a : b;
    }

    // rescale a uint256 from base 10**decimals1 to 10**decimals2
    function rescale(uint256 a, uint256 decimals1, uint256 decimals2) internal pure returns (uint256) {
        return decimals1 == decimals2 ? a : a * 10**decimals2 / 10**decimals1;
    }

    // rescale towards zero
    // b: rescaled value in decimals2
    // c: the remainder
    function rescaleDown(uint256 a, uint256 decimals1, uint256 decimals2) internal pure returns (uint256 b, uint256 c) {
        b = rescale(a, decimals1, decimals2);
        c = a - rescale(b, decimals2, decimals1);
    }

    // rescale towards infinity
    // b: rescaled value in decimals2
    // c: the excessive
    function rescaleUp(uint256 a, uint256 decimals1, uint256 decimals2) internal pure returns (uint256 b, uint256 c) {
        b = rescale(a, decimals1, decimals2);
        uint256 d = rescale(b, decimals2, decimals1);
        if (d != a) {
            b += 1;
            c = rescale(b, decimals2, decimals1) - a;
        }
    }

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

interface INameVersion {

    function nameId() external view returns (bytes32);

    function versionId() external view returns (bytes32);

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import '../utils/INameVersion.sol';

interface IOracle is INameVersion {

    function symbol() external view returns (string memory);

    function symbolId() external view returns (bytes32);

    function timestamp() external view returns (uint256);

    function value() external view returns (uint256);

    function getValue() external view returns (uint256);

    function getValueWithJump() external returns (uint256 val, int256 jump);

}