/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Register{
    mapping(address=>string) public tokenString;
    address public adminAddress;
    constructor(address _adminAddress) {
        adminAddress = _adminAddress;
    }
    
    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "Not admin");
        _;
    }

    event Update(address indexed from, string indexed str);
    event NewAdminAddress(address admin);

    function update(string calldata rString) public {
        tokenString[msg.sender] = rString;
        emit Update(msg.sender,rString);
    }

    function clean(address user) public onlyAdmin {
        delete tokenString[user];
    }

    function setAdmin(address _adminAddress) external onlyAdmin {
        require(_adminAddress != address(0), "Cannot be zero address");
        adminAddress = _adminAddress;

        emit NewAdminAddress(_adminAddress);
    }

    
}