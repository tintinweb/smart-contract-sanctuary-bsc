/**
 *Submitted for verification at BscScan.com on 2022-12-01
*/

pragma solidity >=0.4.16 <0.9.0;

contract SetNumberContract{
    uint interger_number;

    function SetNumber(uint i) public {
        interger_number=i;
        
    }
    function GetNumber() public view returns(uint){
        return interger_number;
    }
}