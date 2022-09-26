/**
 *Submitted for verification at BscScan.com on 2022-09-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract TestContract{
   
    uint256 public testAge = 100;


    struct Data {
        string  name;
        uint256 birthday;
    }

    Data[] public testArray;

    event Age (uint256 oldage, uint256 newage);


    function setAge(uint256 _age) public  {
        emit Age(testAge, _age);
        testAge = _age;
    }

    function getAge() public view returns(uint256){
        return testAge;
    }

    function setData(string memory _name, uint256 _birthday) public {
        testArray.push(Data(_name, _birthday));
    }

    function getIndexData(uint256 _id) public view returns(string memory _testname, uint256  _testbirthday) {
        
        return (testArray[_id].name, testArray[_id].birthday);

    }



}