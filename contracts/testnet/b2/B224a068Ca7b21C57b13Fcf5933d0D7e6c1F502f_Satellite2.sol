/**
 *Submitted for verification at BscScan.com on 2022-03-10
*/

contract Satellite2 {
    //these state variables need to be in the exact same order of contract A when performing a delegate call
    uint public num;
    address public sender;
    uint public value;
    
    constructor() public { owner = msg.sender; }
    address payable owner;
    
    //capture the following data and save it in the state variables
    function setVars(uint _num) public payable {
        //lets multiply the num by 2 so we can see a change
        num = num + 2 * _num;
        sender = msg.sender;
        value = msg.value;
    }
    
     //send funds back to the owner and destroy the contract
    function Destruct() public {
        selfdestruct(owner);
    }
}