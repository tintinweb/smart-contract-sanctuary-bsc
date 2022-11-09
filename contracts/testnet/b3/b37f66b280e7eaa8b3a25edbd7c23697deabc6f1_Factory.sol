/**
 *Submitted for verification at BscScan.com on 2022-11-09
*/

// solidity // SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.6;

contract Factory{
    constructor() public payable{}
     event Deployed(address addr,uint256 salt);

     // 得到将要部署的合约的bytecode
     function deployed(address _owner) public returns(bool){
        bytes memory bytecode= type(TestContract).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(_owner));

        // assembly {
        //     pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        // }
        address addr = address(uint160(uint256(keccak256(
             abi.encodePacked(
                 bytes1(0xff),
                 address(this),
                 salt,
                 keccak256(bytecode)
             )
         ))));
      
        TestContract(addr).initialize(msg.sender);
        return true;
     }

}

contract TestContract{
    address public owner;

    constructor(address _owner) public payable{
        owner =_owner;
    }
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
    function initialize(address _owner) public{
        owner = _owner;
    }
}