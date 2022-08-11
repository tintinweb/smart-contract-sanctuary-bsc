/**
 *Submitted for verification at BscScan.com on 2022-08-10
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

contract Vault {

    address public LastContact;
    bool public openVault;
    uint public counter;
    address public CallerContract;

    function deposit() public {
        LastContact = msg.sender;
        openVault = (msg.sender == CallerContract);
        counter++;
    }

    function setCallerContract(address _addr) public {
        CallerContract = _addr;
    }

}