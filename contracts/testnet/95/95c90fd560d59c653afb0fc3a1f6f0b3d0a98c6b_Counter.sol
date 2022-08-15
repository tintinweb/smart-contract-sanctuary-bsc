/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

pragma solidity ^0.8.0;
contract Counter{
    uint public count;
    string public name;
    constructor(){
        count=1;
        name="My counter";
    }
    function increment()public returns(uint){
        count++;
        return count;
    }

    function decrement()public returns(uint){
        require(count>0,"Can't decrement anything from zero");
        count--;
        return count;
    }
    function getCount()public view returns(uint){
        return count;
    }

    function getName()public view returns(string memory){
        return name;
    }

    function setName(string memory _newName)public returns(string memory newName){
        name=_newName;
        return name;
    }
    function resetCounter()public returns(uint){        
        return count=1;
    }

}