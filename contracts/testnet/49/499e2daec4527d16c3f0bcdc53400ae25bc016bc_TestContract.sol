/**
 *Submitted for verification at BscScan.com on 2022-11-09
*/

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