/**
 *Submitted for verification at BscScan.com on 2022-08-16
*/

// File: contracts/Victim.sol

pragma solidity ^0.8.0;

contract ContractAbc {
    string public Name;

    constructor (string memory name) public {
        Name = name;
    }
}
// File: contracts/Attaker.sol

pragma solidity ^0.8.0;



contract Factory {
    address[] public newContracts;

    function createContract (string memory name) public {
        address newContract = address(new  ContractAbc(name));
        newContracts.push(newContract);
    } 
}