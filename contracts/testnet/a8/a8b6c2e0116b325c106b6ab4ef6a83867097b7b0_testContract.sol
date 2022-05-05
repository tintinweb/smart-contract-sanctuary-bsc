/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

pragma solidity ^0.8.11;

contract testContract {
    event trace(bytes32 x, bytes4 swapIdentifier, bytes4 chainId, bytes12 destinationResource, bytes12 srcResource);

    function foo(bytes32 source) public{
        // bytes4[2] memory y = [bytes4(0), 0];
        // bytes12[2] memory x;
        bytes4 i;
        bytes4 j; 
        bytes12 k;
        bytes12 m;
        assembly {
            i := source
            j := shl(32, source)
            k := shl(96, source)
            m := shl(192, source)
        
        }
        emit trace(source, i, j, k, m);
    }
}