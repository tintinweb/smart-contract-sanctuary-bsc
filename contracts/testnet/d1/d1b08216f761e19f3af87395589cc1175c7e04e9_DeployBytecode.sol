/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

pragma solidity ^0.5.5;

contract DeployBytecode {
    constructor() public{

    }
    // Create contract from bytecode
    function deployBytecode(bytes memory bytecode) public returns (address) {
        address retval;
        assembly{
            mstore(0x0, bytecode)
            retval := create(0,0xa0, calldatasize)
        }
        return retval;
   }
}