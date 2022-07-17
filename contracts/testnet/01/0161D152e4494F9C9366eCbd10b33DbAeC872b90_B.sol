/**
 *Submitted for verification at BscScan.com on 2022-07-16
*/

pragma solidity >=0.7.0 <0.9.0;

contract B{

    uint public age;

    uint private age2;

    uint public age3;

    function setAge(uint _age) public {
        age = _age;
    }

    function setAge3(uint _age) internal {
        age2 = 10;
        age3 += _age;
    }
}