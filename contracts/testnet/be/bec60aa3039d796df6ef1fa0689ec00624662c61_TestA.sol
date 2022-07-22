/**
 *Submitted for verification at BscScan.com on 2022-07-22
*/

pragma solidity >0.8.0;

contract TestA {
    function isContract(address _addr) public returns (bool isContract){
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }
}