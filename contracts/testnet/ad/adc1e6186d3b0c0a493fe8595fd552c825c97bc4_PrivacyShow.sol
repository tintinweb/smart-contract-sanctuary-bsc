/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract PrivacyShow {
    uint256 private password = 123;

    string public publicData = "Public data for the world";

    string private privateData = "Private data is protected";

    event EventViewPrivateData(string _privateData);

    function viewPrivateData(uint256 _password) external returns (string memory) {
        require(_password == password, "Incorrect password");

        emit EventViewPrivateData(privateData);
        return privateData;
    }
}