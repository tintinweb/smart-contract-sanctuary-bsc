/**
 *Submitted for verification at BscScan.com on 2022-03-11
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Fullname {

    address public owner = msg.sender;
    modifier restricted() {
        require(
        msg.sender == owner,
        "This function is restricted to the contract's owner"
        );
        _;
    }

    string public firstname;
    string public lastname;

    address[] public fullnameAccessWhitelist;
    mapping (address => bool) public whitelistArrayFound;
    mapping (address => uint) public whitelistArrayIndex;

    address[] public accessRequestPendingList;
    mapping (address => bool) public accessRequestArrayFound;
    mapping (address => uint) public accessRequestArrayIndex;

    function getOwner() external view returns (address) {

        return owner;
    }

    function getFirstname() external view returns (string memory) {

        require(
            isContainInWhitelist(msg.sender) || msg.sender == owner,
            "No permission to read"
        );

        return firstname;
    }
    

    function getLastname() external view returns (string memory) {

        require(
            isContainInWhitelist(msg.sender) || msg.sender == owner,
            "No permission to read"
        );

        return lastname;
    }

    function _setFirstname(string calldata _firstname) external restricted {

        firstname = _firstname;

    }

    function _setLastname(string calldata _lastname) external restricted {

        lastname = _lastname;

    }

    // --- Start Whitelist section ---

    function isContainInWhitelist(address _address) public view returns (bool){
        return whitelistArrayFound[_address];
    }

    function getWhitelist() external restricted view returns (address[] memory) {
        return fullnameAccessWhitelist;
    }

    function _newWhitelist(address _address) external restricted {

        require(
            !isContainInWhitelist(_address),
            "Duplicate address, already in whitelist."
        );

        fullnameAccessWhitelist.push(_address);
        whitelistArrayFound[_address] = true;
        whitelistArrayIndex[_address] = fullnameAccessWhitelist.length - 1;

    }

    function _removeWhitelist(address _address) external restricted {

        require(
            isContainInWhitelist(_address),
            "Address not found in whitelist."
        );

        fullnameAccessWhitelist[whitelistArrayIndex[_address]] = address(0);

        whitelistArrayFound[_address] = false;
        delete whitelistArrayIndex[_address];

    }

    // --- End Whitelist section ---


    // --- Start Pending list section ---

    function isContainInPendingList(address _address) public view returns (bool){
        return accessRequestArrayFound[_address];
    }

    function getPendingList() external restricted view returns (address[] memory) {
        return accessRequestPendingList;
    }

    function _newPendingList(address _address) external restricted {

        require(
            !isContainInPendingList(_address),
            "Duplicate address, already in pending list."
        );

        accessRequestPendingList.push(_address);
        accessRequestArrayFound[_address] = true;
        accessRequestArrayIndex[_address] = accessRequestPendingList.length - 1;

    }

    function _removePendingList(address _address) external restricted {

        require(
            isContainInPendingList(_address),
            "Address not found in pending list."
        );

        accessRequestPendingList[accessRequestArrayIndex[_address]] = address(0);

        accessRequestArrayFound[_address] = false;
        delete accessRequestArrayIndex[_address];

    }

    function _requestAccess() external {

        require(
            !isContainInPendingList(msg.sender) && !isContainInWhitelist(msg.sender),
            "Already in pending list or whitelist."
        );

        accessRequestPendingList.push(msg.sender);
        accessRequestArrayFound[msg.sender] = true;
        accessRequestArrayIndex[msg.sender] = accessRequestPendingList.length - 1;

    }

    // --- End Pending list section ---
  
}