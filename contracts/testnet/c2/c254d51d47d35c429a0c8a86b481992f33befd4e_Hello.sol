/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

pragma solidity 0.8.7;

contract Hello{
    string public helloStr;
    constructor(){
        helloStr = "Hello World!";
    }

    function setHello(string memory newValue) public {
        helloStr = newValue;
    }

    function getHello() public view returns(string memory) {
        return helloStr;
    }


}