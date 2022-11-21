// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "./IOracle.sol";
import "../library/SafeMath.sol";
import "../utils/NameVersion.sol";

contract OracleChainlink is IOracle, NameVersion {
    using SafeMath for int256;

    string public symbol;
    bytes32 public immutable symbolId;

    IChainlinkFeed public immutable feed;
    uint256 public immutable feedDecimals;

    constructor(string memory symbol_, address feed_)
        NameVersion("OracleChainlink", "3.0.2")
    {
        symbol = symbol_;
        symbolId = keccak256(abi.encodePacked(symbol_));
        feed = IChainlinkFeed(feed_);
        feedDecimals = IChainlinkFeed(feed_).decimals();
    }

    function timestamp() external view returns (uint256) {
        (uint256 updatedAt, ) = _getLatestRoundData();
        return updatedAt;
    }

    function value() public view returns (uint256 val) {
        (, int256 answer) = _getLatestRoundData();
        val = answer.itou();
        if (feedDecimals != 18) {
            val *= 10**(18 - feedDecimals);
        }
    }

    function getValue() external view returns (uint256 val) {
        val = value();
    }

    function _getLatestRoundData() internal view returns (uint256, int256) {
        (
            uint80 roundId,
            int256 answer,
            ,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = feed.latestRoundData();
        require(
            answeredInRound >= roundId,
            "OracleChainlink._getLatestRoundData: stale"
        );
        require(
            updatedAt != 0,
            "OracleChainlink._getLatestRoundData: incomplete round"
        );
        require(answer > 0, "OracleChainlink._getLatestRoundData: answer <= 0");
        return (updatedAt, answer);
    }
}

interface IChainlinkFeed {
    function decimals() external view returns (uint8);

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "../utils/INameVersion.sol";

interface IOracle is INameVersion {
    function symbol() external view returns (string memory);

    function symbolId() external view returns (bytes32);

    function timestamp() external view returns (uint256);

    function value() external view returns (uint256);

    function getValue() external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

library SafeMath {
    uint256 constant UMAX = 2**255 - 1;
    int256 constant IMIN = -2**255;

    function utoi(uint256 a) internal pure returns (int256) {
        require(a <= UMAX, "SafeMath.utoi: overflow");
        return int256(a);
    }

    function itou(int256 a) internal pure returns (uint256) {
        require(a >= 0, "SafeMath.itou: underflow");
        return uint256(a);
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != IMIN, "SafeMath.abs: overflow");
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
    function rescale(
        uint256 a,
        uint256 decimals1,
        uint256 decimals2
    ) internal pure returns (uint256) {
        return decimals1 == decimals2 ? a : (a * 10**decimals2) / 10**decimals1;
    }

    // rescale towards zero
    // b: rescaled value in decimals2
    // c: the remainder
    function rescaleDown(
        uint256 a,
        uint256 decimals1,
        uint256 decimals2
    ) internal pure returns (uint256 b, uint256 c) {
        b = rescale(a, decimals1, decimals2);
        c = a - rescale(b, decimals2, decimals1);
    }

    // rescale towards infinity
    // b: rescaled value in decimals2
    // c: the excessive
    function rescaleUp(
        uint256 a,
        uint256 decimals1,
        uint256 decimals2
    ) internal pure returns (uint256 b, uint256 c) {
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

import "./INameVersion.sol";

/**
 * @dev Convenience contract for name and version information
 */
abstract contract NameVersion is INameVersion {
    bytes32 public immutable nameId;
    bytes32 public immutable versionId;

    constructor(string memory name, string memory version) {
        nameId = keccak256(abi.encodePacked(name));
        versionId = keccak256(abi.encodePacked(version));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

interface INameVersion {
    function nameId() external view returns (bytes32);

    function versionId() external view returns (bytes32);
}