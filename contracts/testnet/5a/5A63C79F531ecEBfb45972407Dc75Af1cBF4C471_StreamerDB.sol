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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IGovernance {
    function getOwner() external view returns (address);
    function hasPermissions(address user, uint8 rank) external view returns (bool);
}

contract NBLGovernance {

    /**
        Governance
     */
    IGovernance public constant governance = IGovernance(0x923c24d71013005fc773DB673776032dd5f0a62a);

    /**
        Ensures Authority
     */
    modifier onlyOwner(){
        require(
            msg.sender == governance.getOwner(),
            'Only Owner'
        );
        _;
    }

    function getOwner() external view returns (address) {
        return governance.getOwner();
    }

    function hasPermissions(address user, uint8 rank) public view returns (bool) {
        return governance.hasPermissions(user, rank);
    }

}