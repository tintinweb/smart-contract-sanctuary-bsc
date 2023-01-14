/**
 *Submitted for verification at BscScan.com on 2023-01-13
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// smart contract: to whom we want to create copies
contract DeployWithCreate2 {
    address public owner;
    
    constructor(address _owner) {
        owner = _owner;
    }
}


// Smart Contract: This is factory contract. which will create copies of the smart contract
contract Create2Factory {
    event Deploy(address addr);

    // this function will create a smart contract address in advance which will be deployed later on the blockchain.
    // This function used create2 opcode.
    function deploy(uint _salt) external {
        DeployWithCreate2 _contract = new DeployWithCreate2{salt: bytes32(_salt)}(msg.sender);
        emit Deploy(address(_contract));
    }


    // These following 2 functions are to verify the smart contract address which was created by deploy function.
    function getAddress(bytes memory bytecode, uint _salt) public view returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(
            bytes1(0xff), address(this), _salt, keccak256(bytecode)
        ));
        return address(uint160(uint(hash)));
    }

    // this function will return the bytecode for getAddress() function.
    function getBytecode(address _owner) public pure returns (bytes memory) {
        bytes memory bytecode = type(DeployWithCreate2).creationCode;
        return abi.encodePacked(bytecode, abi.encode(_owner));
    }
}