/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

pragma solidity ^0.8.0;

contract test {
    mapping (uint32 => string) public results;
    constructor() public  {
    }

    function set(uint32 key,string calldata val) public {
        results[key]=val;
    }

    function get(uint32 key) external view returns(string memory){
        bytes memory tempEmptyStringTest = bytes(results[key]);
        require(tempEmptyStringTest.length > 0,"val is empty");
        return results[key];
    }
}