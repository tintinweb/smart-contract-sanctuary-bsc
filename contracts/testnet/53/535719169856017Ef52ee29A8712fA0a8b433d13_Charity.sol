pragma solidity ^0.8.9;
pragma abicoder v2;

contract Charity {
    address public owner;
    mapping(uint => string) public checkContract;

    constructor (address _owner) public {
        require(_owner != address(0), "no-owner-provided");
        owner = _owner;
    }

    function add(uint _id, string memory _name) public {
        checkContract[_id] = _name;
    }

   function check(uint num) public returns(string memory){
       require(msg.sender == owner , "only owner");
       return checkContract[num];
   }
    
}