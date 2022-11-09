/**
 *Submitted for verification at BscScan.com on 2022-11-09
*/

// solidity // SPDX-License-Identifier: UNLICENSED

pragma solidity = 0.8.17;

contract Factory{

    constructor()payable{}

    event Deployed(address addr);
    address testAddr;
    function deployed() public returns(bool){

        bytes memory bytecode= type(TestContract).creationCode;
        bytes32 salt = keccak256(abi.encodePacked());
        // bytes32 salt = keccak256(abi.encodePacked('1234'));传构造参数
        address addr;
        assembly {
             addr := create2(
             0,   //callvalue()
             add(bytecode,0x20),
             mload(bytecode),
             salt
          )
        }
        testAddr = addr;
        emit Deployed(addr);
        // TestContract(addr).initialize(msg.sender);
        return true;
     }
    function getTestAddr() public view returns(address){
        return testAddr;
    }

}

contract TestContract{
    address public owner;

    constructor() payable{
        owner = msg.sender;
    }
    function getBalance() public view returns(uint){
        return address(this).balance;
    } 
    function getOwner() public view returns(address){
        return owner;
    }
    function initialize(address _owner) public{
        owner = _owner;
    }
}