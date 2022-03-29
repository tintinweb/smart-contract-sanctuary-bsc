/**
 *Submitted for verification at BscScan.com on 2022-03-29
*/

/*
Funds Locker

This script will allow you to store tokens securely and it can only be withdrawn to the owner's address.

The contract should:

- Allow only the registered owner to withdraw funds

- A password is required to withdraw funds

- Store different funds (eg. BNB, BUSD etc)

- Registered owner can be change both the address and the password.

- To change registered owner, the new address, the original owner's consent and password is required.

- Suppose a hacker hacks into the wallet. He must both have access to the wallet and know the password to access funds.

*/


pragma solidity ^0.8.7;

contract FundsLocker {

    address ownerWalletAddress;
    string private ownerWalletPassword;

    modifier onlyOwner() {
        require(msg.sender == ownerWalletAddress, "You do not have permission to use this!");
        _;
    }

    constructor(address _ownerWalletAddress) {
        ownerWalletAddress = payable(_ownerWalletAddress);
    }


    function getWalletOwner() public view returns (address) {
        return ownerWalletAddress;
    }

    function depositFunds() public payable {
        (bool success,) = ownerWalletAddress.call{value: msg.value}("");
        require(success, "Failed to deposit funds!");
    }

    function withdrawFunds(uint transferAmount) public onlyOwner {
        require(address(this).balance >= transferAmount, "Insufficient funds!");

        transferAmount = 1 ether * transferAmount;

        payable(ownerWalletAddress).transfer(transferAmount);
    }

    /*function changePassword(string memory oldPassword, string memory newPassword) public onlyOwner {
        require(oldPassword == ownerWalletPassword, "Incorrect password!");

        ownerWalletPassword = oldPassword;

    }*/

    function selfDestruct() public onlyOwner {
        selfdestruct(payable(msg.sender));
    }
}