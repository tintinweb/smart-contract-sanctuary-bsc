/**
 *Submitted for verification at BscScan.com on 2022-06-03
*/

/***
 *    ██████╗  ██████╗ ██╗    ██╗███████╗██████╗ ███╗   ███╗ █████╗ ██████╗ ███████╗
 *    ██╔══██╗██╔═══██╗██║    ██║██╔════╝██╔══██╗████╗ ████║██╔══██╗██╔══██╗██╔════╝
 *    ██████╔╝██║   ██║██║ █╗ ██║█████╗  ██████╔╝██╔████╔██║███████║██║  ██║█████╗  
 *    ██╔═══╝ ██║   ██║██║███╗██║██╔══╝  ██╔══██╗██║╚██╔╝██║██╔══██║██║  ██║██╔══╝  
 *    ██║     ╚██████╔╝╚███╔███╔╝███████╗██║  ██║██║ ╚═╝ ██║██║  ██║██████╔╝███████╗
 *    ╚═╝      ╚═════╝  ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝
 *    ███████╗ ██████╗ ██████╗ ███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗
 *    ██╔════╝██╔════╝██╔═══██╗██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║
 *    █████╗  ██║     ██║   ██║███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║
 *    ██╔══╝  ██║     ██║   ██║╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║
 *    ███████╗╚██████╗╚██████╔╝███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║
 *    ╚══════╝ ╚═════╝ ╚═════╝ ╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝
 *                                                                                  
 */                                                                                                   
// SPDX-License-Identifier: MIT

pragma solidity ^0.5.17;


// Interface to access Powermade contract data
interface Powermade {
    // userInfos getter function (automatically generated because userInfos mapping is public). The getter can only contain standard types, not arrays or other mappings.
    function userInfos(address userAddr) external view returns (uint id, uint referrerID, uint virtualID, uint32 round_robin_next_index, bool banned, uint totalEarned);
    // get the businessEnabled
    function businessEnabled() external view returns (bool enabled);
    // get the bannedLogic
    function bannedLogic() external view returns (bool flag);
    // Get package info
    function getPackageInfo(uint16 packageID, uint userID) external view returns (uint price, uint duration, bool enabled, bool rebuy_enabled, bool rebuy_before_exp, uint16[] memory prerequisites, uint16[] memory percentages, bool prereq_not_exp, uint totalEarnedPack, uint purchasesCount, uint last_pid);
    // Get purchase info
    function getPurchaseInfo(uint purchaseID) external view returns (uint userID, uint16 packageID, uint price, uint timestamp, uint duration, bool expired);
}


// Manages the registration to an Event (using a ticket generated client-side)
contract PowermadeEventACL {

    Powermade public powermadeContract;

    // Events ACL feature (manage subscription to classes/lessons/events with unique client side tickets).
    // packageID -> Event UID (wallet address) -> UserID -> Event registration Timestamp (or 0)
    mapping(uint16 => mapping(address => mapping(uint => uint))) private eventsACL;
    // Hashed Unique Ticket -> userID (>0 means used)
    mapping(bytes32 => uint) private ticketUserID;
    event RegisterToEventEv(uint16 indexed packageID, address indexed eventUID, uint userID);


    // Constructor called when deploying
    constructor(address _powermadeAddress) public {
        powermadeContract = Powermade(_powermadeAddress);
    }


    // Function to register to an Event, given the Event (packageID+eventUID - Event always associated to a packageID) and the hash of the generate 
    // personal unique Ticket (address like). Only a single registration is allowed (for a userID with a single Ticket)
    function registerToEvent(uint16 packageID, address eventUID, bytes32 ticket_hashed) public {
        require(powermadeContract.businessEnabled(), "Business non enabled");
        (uint userID, , , , bool banned, ) = powermadeContract.userInfos(msg.sender);
        require(userID > 1, "Not a user of the contract!");
        require(powermadeContract.bannedLogic() ? !banned : banned, "User is banned/disabled");
        // The package can be disabled (no new purchases) and the registration still allowed (for those who already bought)
        // But we need to check if they really bought to be able to register to the Event
        ( , , , , , , , , , uint purchasesCount, ) = powermadeContract.getPackageInfo(packageID, userID);
        require(purchasesCount > 0, "Package never bought!");
        require(ticketUserID[ticket_hashed] == 0, "Ticket already exists");
        require(eventsACL[packageID][eventUID][userID] == 0, "User already registered to the Event");
        // Register to the event
        eventsACL[packageID][eventUID][userID] = block.timestamp;
        ticketUserID[ticket_hashed] = userID;
        emit RegisterToEventEv(packageID, eventUID, userID);
    }


    // Check the registration list to an Event, given the PackageID+EventID and the ticked (address like). Returns the timestamp of the registration to the Event 
    // (if it's 0 it means the ticket not registered), the userID associated to the ticket and some useful data regarding the last Purchase of the given PackageID, 
    // for a quick check.
    function checkEventRegistration(uint16 packageID, address eventUID, address ticket) public view returns (uint reg_timestamp, uint userID, uint PID_last, uint timestamp_last, uint duration_last, bool expired_last) {
        // Get the userID
        userID = ticketUserID[keccak256(abi.encodePacked(ticket))];
        // get the registration timestamp 
        reg_timestamp = eventsACL[packageID][eventUID][userID];
        if (userID > 0) {
            uint purchasesCount;
            ( , , , , , , , , , purchasesCount, PID_last) = powermadeContract.getPackageInfo(packageID, userID);
            if(purchasesCount > 0) {
                ( , , , timestamp_last, duration_last, expired_last) = powermadeContract.getPurchaseInfo(PID_last);
            }
        }
    }


    // Convenience function to generate the keccak256 hash for an address. This is a pure function and does not store data in the blockchain.
    function addressToKeccakHash(address addr) public pure returns (uint256 address_hex, bytes32 address_hashed) {
        address_hex = uint256(uint160(addr));
        address_hashed = keccak256(abi.encodePacked(addr));
    }


}