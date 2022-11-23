// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

/**
 * @title Control the current timestamp for easy debugging
 * @author Stone (@Vmeta3 Labs)
 * @dev If it is not in development mode, please do not modify the current time
 */
library Time {
    struct Timestamp {
        uint256 _current_time;
    }

    function _getCurrentTime(Timestamp storage timestamp) internal view returns (uint256) {
        if (timestamp._current_time > 0) {
            return timestamp._current_time;
        } else {
            return block.timestamp;
        }
    }

    function _setCurrentTime(Timestamp storage timestamp, uint256 time_map) internal {
        timestamp._current_time = time_map;
    }
}