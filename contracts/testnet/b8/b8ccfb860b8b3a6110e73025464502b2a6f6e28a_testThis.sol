/**
 *Submitted for verification at BscScan.com on 2022-02-05
*/

pragma solidity 0.4.25;


contract testThis{

    uint public a;

    function testArray(uint[] memory _add) public 
    {
        a = _add.length;
    }

}