// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
contract Variables{
    //State variables are stored on the blockchain
    string public text = "This id state variable of outside of the function";
    uint public num =1244;

    function doSomething() public {
        //local variable not stored in blockchain
        uint i =89867;
        uint timestamp = block.timestamp;//current block timestamp
        address sender = msg.sender; // address of the caller
        
    }

}