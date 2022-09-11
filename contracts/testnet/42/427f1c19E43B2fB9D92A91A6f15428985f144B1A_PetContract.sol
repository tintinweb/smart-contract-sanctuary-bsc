/**
 *Submitted for verification at BscScan.com on 2022-09-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.13;

// 1. Creating a new pet contract
contract PetContract {

    // 2. Declaring our smart contract state variables
    string public petName;
    string public petOwner;
    string public petAge;

    // 3. Creating a set pet function
    function setPet(string memory newPetName, string memory newPetOwner, string memory newPetAge)
    public  {
        petName  = newPetName;
        petOwner = newPetOwner;
        petAge   = newPetAge;
    }

    // 4. Creating a fetch pet function
    function getPet() public view returns (string memory, string memory, string memory) 
    {
        return (petAge, petName, petOwner);
    }

}