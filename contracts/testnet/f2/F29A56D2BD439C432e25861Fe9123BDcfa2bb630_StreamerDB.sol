// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.14;

import "./NBLGovernance.sol";

interface ITipDatabase {
    function registerStreamer(address newStreamer, string calldata userName_) external;
    function changeUsername(address user, string calldata userName_) external;
    function revokeStreamer(address streamer) external;
}

contract StreamerDB is NBLGovernance {

    ITipDatabase public immutable database;

    constructor(address tipDB) {
        database = ITipDatabase(tipDB);
    }

    function registerStreamer(address newStreamer, string calldata userName_) external onlyOwner {
        database.registerStreamer(newStreamer, userName_);
    }

    function changeUsername(address user, string calldata userName_) external onlyOwner {
        database.changeUsername(user, userName_);
    }

    function revokeStreamer(address streamer) external onlyOwner {
        database.revokeStreamer(streamer);
    }

}