/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

contract UserManager {
    enum Status {
        NORMAL,
        WHITELIST,
        BLACKLIST
    }

    uint256 public totalWhitelistUsers;
    uint256 public totalBlacklistUsers;
    address public owner;

    mapping(address => mapping(string => Status)) public mapUserStatuses; // map(address => map(type => Status))

    string private constant OVERALL = "all";

    // Constructor
    constructor() {
        owner = _msgSender();
    }

    // Modifiers
    modifier onlyOwner() {
        require(_msgSender() == owner, "Caller is not the owner.");
        _;
    }

    function whitelist(string memory _type, address[] memory _arrAddress) external onlyOwner {
        uint256 addressCount = _arrAddress.length;

        for (uint256 index = 0; index < addressCount; index++) {
            Status userStatus = mapUserStatuses[_arrAddress[index]][_type];

            if (userStatus == Status.NORMAL) {
                mapUserStatuses[_arrAddress[index]][_type] = Status.WHITELIST;
                totalWhitelistUsers++;
            } else if (userStatus == Status.BLACKLIST) {
                mapUserStatuses[_arrAddress[index]][_type] = Status.WHITELIST;
                totalBlacklistUsers--;
                totalWhitelistUsers++;
            }
        }
    }

    function blacklist(string memory _type, address[] memory _arrAddress) external onlyOwner {
        uint256 addressCount = _arrAddress.length;

        for (uint256 index = 0; index < addressCount; index++) {
            Status userStatus = mapUserStatuses[_arrAddress[index]][_type];

            if (userStatus == Status.NORMAL) {
                mapUserStatuses[_arrAddress[index]][_type] = Status.BLACKLIST;
                totalBlacklistUsers++;
            } else if (userStatus == Status.WHITELIST) {
                mapUserStatuses[_arrAddress[index]][_type] = Status.BLACKLIST;
                totalWhitelistUsers--;
                totalBlacklistUsers++;
            }
        }
    }

    function removeUser(string memory _type, address[] memory _arrAddress) external onlyOwner {
        uint256 addressCount = _arrAddress.length;

        for (uint256 index = 0; index < addressCount; index++) {
            Status userStatus = mapUserStatuses[_arrAddress[index]][_type];

            if (userStatus == Status.WHITELIST) {
                mapUserStatuses[_arrAddress[index]][_type] = Status.NORMAL;
                totalWhitelistUsers--;
            } else if (userStatus == Status.BLACKLIST) {
                mapUserStatuses[_arrAddress[index]][_type] = Status.NORMAL;
                totalBlacklistUsers--;
            }
        }
    }

    function isUserWhitelisted(string memory _type, address userAddress) external view returns (bool) {
        if (
            mapUserStatuses[userAddress][_type] == Status.WHITELIST ||
            mapUserStatuses[userAddress][OVERALL] == Status.WHITELIST
        ) {
            return true;
        }
        return false;
    }

    function isUserBlacklisted(string memory _type, address userAddress) external view returns (bool) {
        if (
            mapUserStatuses[userAddress][_type] == Status.BLACKLIST ||
            mapUserStatuses[userAddress][OVERALL] == Status.BLACKLIST
        ) {
            return true;
        }
        return false;
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Invalid address.");
        owner = _newOwner;
    }

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
}