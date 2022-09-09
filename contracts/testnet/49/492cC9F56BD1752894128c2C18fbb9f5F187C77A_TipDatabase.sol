// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.14;

import "./NBLGovernance.sol";

contract TipDatabase is NBLGovernance {

    /**
        Tip Structure
     */
    struct Tip {
        address from;
        address to;
        uint256 amount;
        uint256 when;
        uint8 method; // 0 - NBL | 1 - BNB | 2 - Other Crypto | 3 - Credit Card
    }

    /**
        User Structure
     */
    struct UserInfo {
        bool isRegisteredStreamer;
        string userName;
        uint256[] allTipsReceived;
        uint256[] allTipsSent;
    }

    /**
        Current Tip ID
     */
    uint256 public currentTipID;

    /**
        Amount of NBL Processed As Tips
     */
    uint256 public totalNBL;

    /**
        TipID => Tip Info
     */
    mapping ( uint256 => Tip ) public tipInfo;

    /**
        User => User Info
     */
    mapping ( address => UserInfo ) private userInfo;

    /**
        UserName => Streamer
     */
    mapping ( string => address ) public getStreamerByName;

    /**
        Tipping Swapper
     */
    address public tippingSwapper;

    /**
        Streamer Setter
     */
    address public streamerSetter;

    function setTippingSwapper(address newSwapper) external onlyOwner {
        tippingSwapper = newSwapper;
    }

    function setStreamerSetter(address newSetter) external onlyOwner {
        streamerSetter = newSetter;
    }



    function registerStreamer(address newStreamer, string calldata userName_) external {
        require(
            msg.sender == streamerSetter || msg.sender == this.getOwner(),
            'Only Setter Or Owner'
        );
        require(
            getStreamerByName[userName_] == address(0),
            'User Name Already Exists'
        );
        require(
            newStreamer != address(0),
            'Zero Address'
        );
        getStreamerByName[userName_] = newStreamer;
        userInfo[newStreamer].userName = userName_;
        userInfo[newStreamer].isRegisteredStreamer = true;
    }


    function changeUsername(address user, string calldata userName_) external {
        require(
            msg.sender == streamerSetter || msg.sender == this.getOwner(),
            'Only Setter Or Owner'
        );
        require(
            userInfo[user].isRegisteredStreamer,
            'Not Streamer'
        );
        require(
            getStreamerByName[userName_] == address(0),
            'User Name Exists'
        );
        delete getStreamerByName[userInfo[user].userName];
        getStreamerByName[userName_] = user;
        userInfo[user].userName = userName_;
    }


    function revokeStreamer(address newStreamer) external {
        require(
            msg.sender == streamerSetter || msg.sender == this.getOwner(),
            'Only Setter Or Owner'
        );
        userInfo[newStreamer].isRegisteredStreamer = false;
    }


    function registerTip(
        address from,
        address to,
        uint256 amount,
        uint8 method
    ) external {
        require(
            msg.sender == tippingSwapper,
            'Only Swapper Can Register Tip'
        );
        require(
            userInfo[to].isRegisteredStreamer == true,
            'Not Registered Streamer'
        );

        // Set Tip Info
        tipInfo[currentTipID] = Tip({
            from: from,
            to: to,
            amount: amount,
            when: block.timestamp,
            method: method
        });

        // Add To Tips Sent And Received
        userInfo[from].allTipsSent.push(currentTipID);
        userInfo[to].allTipsReceived.push(currentTipID);

        // Increment Tip ID
        unchecked {
            totalNBL += amount;
            currentTipID++;
        }
    }

    function isStreamer(address streamer) external view returns (bool) {
        return userInfo[streamer].isRegisteredStreamer;
    }

    function numberOfTipsReceived(address user) external view returns (uint256) {
        return userInfo[user].allTipsReceived.length;
    }

    function numberOfTipsSent(address user) external view returns (uint256) {
        return userInfo[user].allTipsSent.length;
    }

    function fetchAllTipsReceived(address user) external view returns (uint256[] memory) {
        return userInfo[user].allTipsReceived;
    }

    function fetchAllTipsSent(address user) external view returns (uint256[] memory) {
        return userInfo[user].allTipsSent;
    }

    function fetchTipInfo(uint256 tipID) public view returns (address, address, uint256, uint256, uint8) {
        return (tipInfo[tipID].from, tipInfo[tipID].to, tipInfo[tipID].amount, tipInfo[tipID].when, tipInfo[tipID].method);
    }

    function batchFetchTipInfo(uint256[] calldata tipIDs) public view returns (address[] memory, address[] memory, uint256[] memory, uint256[] memory, uint8[] memory) {

        uint len = tipIDs.length;
        address[] memory froms = new address[](len);
        address[] memory tos = new address[](len);
        uint256[] memory amounts = new uint256[](len);
        uint256[] memory whens = new uint256[](len);
        uint8[] memory methods = new uint8[](len);

        for (uint i = 0; i < len;) {

            (
                froms[i], tos[i], amounts[i], whens[i], methods[i]
            ) = fetchTipInfo(tipIDs[i]);

            unchecked { ++i; }
        }
        return ( froms, tos, amounts, whens, methods );
    }

    function fetchAllTipsReceivedInfo(address user) external view returns (address[] memory, address[] memory, uint256[] memory, uint256[] memory, uint8[] memory) {
        uint len = userInfo[user].allTipsReceived.length;

        address[] memory froms = new address[](len);
        address[] memory tos = new address[](len);
        uint256[] memory amounts = new uint256[](len);
        uint256[] memory whens = new uint256[](len);
        uint8[] memory methods = new uint8[](len);

        for (uint i = 0; i < len;) {

            (
                froms[i], tos[i], amounts[i], whens[i], methods[i]
            ) = fetchTipInfo(userInfo[user].allTipsReceived[i]);

            unchecked { ++i; }
        }
        return ( froms, tos, amounts, whens, methods );
    }

    function fetchAllTipsSentInfo(address user) external view returns (address[] memory, address[] memory, uint256[] memory, uint256[] memory, uint8[] memory) {
        uint len = userInfo[user].allTipsSent.length;

        address[] memory froms = new address[](len);
        address[] memory tos = new address[](len);
        uint256[] memory amounts = new uint256[](len);
        uint256[] memory whens = new uint256[](len);
        uint8[] memory methods = new uint8[](len);

        for (uint i = 0; i < len;) {

            (
                froms[i], tos[i], amounts[i], whens[i], methods[i]
            ) = fetchTipInfo(userInfo[user].allTipsSent[i]);

            unchecked { ++i; }
        }
        return ( froms, tos, amounts, whens, methods );
    }

    function batchFetchAllTipsReceivedInfo(address user, uint256 startIndex, uint256 endIndex) external view returns (address[] memory, address[] memory, uint256[] memory, uint256[] memory, uint8[] memory) {
        uint len = endIndex - startIndex;
        address user_ = user;
        address[] memory froms = new address[](len);
        address[] memory tos = new address[](len);
        uint256[] memory amounts = new uint256[](len);
        uint256[] memory whens = new uint256[](len);
        uint8[] memory methods = new uint8[](len);
        uint count = 0;

        for (uint i = startIndex; i < endIndex;) {

            (
                froms[count], tos[count], amounts[count], whens[count], methods[count]
            ) = fetchTipInfo(userInfo[user_].allTipsReceived[i]);

            unchecked { ++i; ++count; }
        }
        return ( froms, tos, amounts, whens, methods );
    }

    function batchFetchAllTipsSentInfo(address user, uint256 startIndex, uint256 endIndex) external view returns (address[] memory, address[] memory, uint256[] memory, uint256[] memory, uint8[] memory) {
        uint len = endIndex - startIndex;
        address user_ = user;
        address[] memory froms = new address[](len);
        address[] memory tos = new address[](len);
        uint256[] memory amounts = new uint256[](len);
        uint256[] memory whens = new uint256[](len);
        uint8[] memory methods = new uint8[](len);
        uint count = 0;

        for (uint i = startIndex; i < endIndex;) {

            (
                froms[count], tos[count], amounts[count], whens[count], methods[count]
            ) = fetchTipInfo(userInfo[user_].allTipsSent[i]);

            unchecked { ++i; ++count; }
        }
        return ( froms, tos, amounts, whens, methods );
    }
}