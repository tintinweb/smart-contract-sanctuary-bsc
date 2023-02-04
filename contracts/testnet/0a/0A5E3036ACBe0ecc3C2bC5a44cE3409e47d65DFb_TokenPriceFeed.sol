// SPDX-License-Identifier: MIT

pragma solidity =0.8.17;
pragma experimental ABIEncoderV2;

interface IChainlinkPriceFeed {
    function latestAnswer() external view returns(int256);
    function latestRound() external view returns(uint80);
    function getRoundData(uint80) external view returns(uint80, int256, uint256, uint256, uint80);
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.17;
pragma experimental ABIEncoderV2;

interface ITokenPriceFeed {
    function setPrice(uint256, uint256) external;
    function getPrice(uint256) external view returns (uint256);
    function info() external view returns (address, uint256, uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.17;
pragma experimental ABIEncoderV2;

import "../interfaces/ITokenPriceFeed.sol";
import "../interfaces/IChainlinkPriceFeed.sol";

contract TokenPriceFeed is ITokenPriceFeed {
    /* ========== STATE VARIABLES ========== */

    address public fastPriceFeed;
    address public immutable token;
    uint256 public lastUpdated;
    uint256 public lastPrice;

    // price data;
    mapping (uint256 => uint256) public prices;
    mapping (uint256 => bool) public isUpdated;

    /* ========== MODIFIERS ======== */

    modifier onlyFastPriceFeed {
        require(fastPriceFeed == msg.sender, "TokenPriceFeed: !fastPriceFeed");
        _;
    }

    /* ========== CONSTRUCTOR ========== */

    constructor (address _token, address _fastPriceFeed) {
        token = _token;
        fastPriceFeed = _fastPriceFeed;
    }

    /* ========== VIEWS ========== */

    function getPrice(uint256 _timestamp) external view returns (uint256) {
        return prices[_timestamp];
    }

    function info() external view returns(address, uint256, uint256) {
        return (token, lastUpdated, lastPrice);
    }

    function getPrices(uint256[] memory _timestamps) external view returns (uint256[] memory _data) {
        for (uint256 i = 0; i < _timestamps.length; i++) {
            _data[i] = prices[_timestamps[i]];
        }
    }

    /* ========== PUBLIC FUNCTIONS ========== */

    /* ========== RESTRICTED FUNCTIONS ========== */

    function setPrice(uint256 _price, uint256 _timestamp) external onlyFastPriceFeed {
        require(!isUpdated[_timestamp], "TokenPriceFeed: updated");
        prices[_timestamp] = _price;
        lastUpdated = _timestamp;
        lastPrice = _price;
        isUpdated[_timestamp] = true;
        emit PriceAdded(_price, _timestamp);
    }

    function changeFastPriceFeed(address _new) external onlyFastPriceFeed {
        fastPriceFeed = _new;
    }

    // EVENTS
    event PriceAdded(uint256 _price, uint256 _timestamp);
}