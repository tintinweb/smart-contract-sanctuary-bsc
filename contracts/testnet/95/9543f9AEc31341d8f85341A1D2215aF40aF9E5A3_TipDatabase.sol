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
        string note;
    }

    /**
        User Structure
     */
    struct UserInfo {
        bool isRegisteredStreamer;
        string userName;
        uint256[] allTipsReceived;
        uint256[] allTipsSent;
        uint256 amountNBLSent;
        uint256 amountNBLReceived;
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
        uint8 method,
        string calldata note
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
            method: method,
            note: note
        });

        // Add To Tips Sent And Received
        userInfo[from].allTipsSent.push(currentTipID);
        userInfo[to].allTipsReceived.push(currentTipID);

        // Increment Tip ID
        unchecked {
            totalNBL += amount;
            currentTipID++;
            userInfo[from].amountNBLSent += amount;
            userInfo[to].amountNBLReceived += amount;
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

    function fetchTipInfo(uint256 tipID) public view returns (address, address, uint256, uint256, uint8, string memory) {
        return (tipInfo[tipID].from, tipInfo[tipID].to, tipInfo[tipID].amount, tipInfo[tipID].when, tipInfo[tipID].method, tipInfo[tipID].note);
    }

    function batchFetchTipInfo(uint256[] calldata tipIDs) public view returns (address[] memory, address[] memory, uint256[] memory, uint256[] memory, uint8[] memory, string[] memory) {

        uint len = tipIDs.length;
        uint256[] calldata tipz = tipIDs;
        address[] memory froms = new address[](len);
        address[] memory tos = new address[](len);
        uint256[] memory amounts = new uint256[](len);
        uint256[] memory whens = new uint256[](len);
        uint8[] memory methods = new uint8[](len);
        string[] memory notes = new string[](len);

        for (uint i = 0; i < len;) {

            (
                froms[i], tos[i], amounts[i], whens[i], methods[i], notes[i]
            ) = fetchTipInfo(tipz[i]);

            unchecked { ++i; }
        }
        return ( froms, tos, amounts, whens, methods, notes );
    }

    function fetchAllTipsReceivedInfo(address user) external view returns (address[] memory, uint256[] memory, uint256[] memory, uint8[] memory, string[] memory) {
        uint len = userInfo[user].allTipsReceived.length;
        address[] memory froms = new address[](len);
        uint256[] memory amounts = new uint256[](len);
        uint256[] memory whens = new uint256[](len);
        uint8[] memory methods = new uint8[](len);
        string[] memory notes = new string[](len);

        for (uint i = 0; i < len;) {

            (
                froms[i], , amounts[i], whens[i], methods[i], notes[i]
            ) = fetchTipInfo(userInfo[user].allTipsReceived[i]);

            unchecked { ++i; }
        }
        return ( froms, amounts, whens, methods, notes );
    }

    function fetchAllTipsSentInfo(address user) external view returns (address[] memory, uint256[] memory, uint256[] memory, uint8[] memory, string[] memory) {
        uint len = userInfo[user].allTipsSent.length;

        address[] memory tos = new address[](len);
        uint256[] memory amounts = new uint256[](len);
        uint256[] memory whens = new uint256[](len);
        uint8[] memory methods = new uint8[](len);
        string[] memory notes = new string[](len);

        for (uint i = 0; i < len;) {

            (
                , tos[i], amounts[i], whens[i], methods[i], notes[i]
            ) = fetchTipInfo(userInfo[user].allTipsSent[i]);

            unchecked { ++i; }
        }
        return ( tos, amounts, whens, methods, notes );
    }

    function batchFetchAllTipsReceivedInfo(address user, uint256 startIndex, uint256 endIndex) external view returns (address[] memory, uint256[] memory, uint256[] memory, uint8[] memory, string[] memory) {
        uint len = endIndex - startIndex;
        address user_ = user;
        uint start_ = startIndex;
        uint end_ = endIndex;
        address[] memory froms = new address[](len);
        uint256[] memory amounts = new uint256[](len);
        uint256[] memory whens = new uint256[](len);
        uint8[] memory methods = new uint8[](len);
        string[] memory notes = new string[](len);
        uint count = 0;

        for (uint i = start_; i < end_;) {

            (
                froms[count], , amounts[count], whens[count], methods[count], notes[count]
            ) = fetchTipInfo(userInfo[user_].allTipsReceived[i]);

            unchecked { ++i; ++count; }
        }
        return ( froms, amounts, whens, methods, notes );
    }

    function batchFetchAllTipsSentInfo(address user, uint256 startIndex, uint256 endIndex) external view returns (address[] memory, uint256[] memory, uint256[] memory, uint8[] memory, string[] memory) {
        uint len = endIndex - startIndex;
        address user_ = user;
        uint start_ = startIndex;
        uint end_ = endIndex;
        address[] memory tos = new address[](len);
        uint256[] memory amounts = new uint256[](len);
        uint256[] memory whens = new uint256[](len);
        uint8[] memory methods = new uint8[](len);
        string[] memory notes = new string[](len);
        uint count = 0;

        for (uint i = start_; i < end_;) {

            (
                , tos[count], amounts[count], whens[count], methods[count], notes[count]
            ) = fetchTipInfo(userInfo[user_].allTipsSent[i]);

            unchecked { ++i; ++count; }
        }
        return ( tos, amounts, whens, methods, notes );
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