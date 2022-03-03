/**
 *Submitted for verification at BscScan.com on 2022-03-03
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Notary {
    struct myCopyrightEntry {
        string fileName;
        string ownerName;
        uint256 timeStamp;
        bytes32 checksum;
        string comment;
        bool isSet;
        address setBy;
    }

    mapping(bytes32 => myCopyrightEntry) copyrightEntries;

    event NewEntry(
        bytes32 _checksum,
        string _fileName,
        string _ownerName,
        string _comment,
        address indexed _setBy
    );

    function addEntry(
        bytes32 _checksum,
        string memory _fileName,
        string memory _ownerName,
        string memory _comment
    ) public {
        require(!copyrightEntries[_checksum].isSet);

        copyrightEntries[_checksum].isSet = true;
        copyrightEntries[_checksum].fileName = _fileName;
        copyrightEntries[_checksum].ownerName = _ownerName;
        copyrightEntries[_checksum].timeStamp = block.timestamp;
        copyrightEntries[_checksum].comment = _comment;
        copyrightEntries[_checksum].setBy = msg.sender;

        emit NewEntry(_checksum, _fileName, _ownerName, _comment, msg.sender);
    }

    function getEntry(bytes32 _checksum)
        public
        view
        returns (
            string memory,
            string memory,
            uint256,
            string memory,
            address
        )
    {
        require(copyrightEntries[_checksum].isSet);

        return (
            copyrightEntries[_checksum].fileName,
            copyrightEntries[_checksum].ownerName,
            copyrightEntries[_checksum].timeStamp,
            copyrightEntries[_checksum].comment,
            copyrightEntries[_checksum].setBy
        );
    }
}