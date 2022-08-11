/**
 *Submitted for verification at BscScan.com on 2022-08-10
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface Vault {
    function deposit() external;
}

contract Minter {

    uint public minted;
    uint public price = 1 ether/1000;
    uint public balance = address(this).balance;
    address public VaultAddress;

    constructor(address _addr) payable{
        VaultAddress = _addr;
    }

    function setVaultAddress(address _addr) public {
        VaultAddress = _addr;
    }

    function mint() public payable {
        require (msg.value == price);
        minted ++;
        Vault(VaultAddress).deposit();
    }

    function retrieveBalance() public {
        address payable receiver = payable(msg.sender);
        receiver.transfer(balance);
    }
}