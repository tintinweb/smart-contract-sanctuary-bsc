/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/

pragma solidity ^0.8.16;

contract Adoption {
    // Declare an array of 16 Ethereum addresses as the adopter of each pet
    address[16] public adopters;

    // Adopting a pet
    function adopt(uint petId) public returns (uint) {
        require(petId >= 0 && petId <= 15, "Pet-ID out of range");
        adopters[petId] = msg.sender;  // address of account/smart contract that calls this function
        return petId;
    }

    // Retrieving the adopters
    function getAdopters() public view returns (address[16] memory) {
        return adopters;
    }
}