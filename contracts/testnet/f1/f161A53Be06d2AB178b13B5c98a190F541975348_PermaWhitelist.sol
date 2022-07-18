/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IDatabase {
    function getOwner() external view returns (address);
}

contract PermaWhitelist {

    IDatabase public immutable database;

    mapping ( address => bool ) private _isWhitelisted;

    modifier onlyOwner() {
        require(
            msg.sender == database.getOwner(),
            'Not DB Owner'
        );
        _;
    }
    
    constructor(address db) {
        database = IDatabase(db);
    }

    function whitelist(address[] calldata users) external onlyOwner {
        uint len = users.length;
        for (uint i = 0; i < len;) {
            _isWhitelisted[users[i]] = true;
            unchecked {
                ++i;
            }
        }
    }

    function unWhitelist(address[] calldata users) external onlyOwner {
        uint len = users.length;
        for (uint i = 0; i < len;) {
            _isWhitelisted[users[i]] = false;
            unchecked {
                ++i;
            }
        }
    }

    function isWhitelisted(address user) external view returns (bool) {
        return _isWhitelisted[user];
    }

}