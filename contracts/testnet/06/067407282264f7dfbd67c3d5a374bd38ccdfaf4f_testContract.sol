/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

pragma solidity ^0.8.11;

contract testContract {
    event trace(bytes32 x, bytes4 swapIdentifier, bytes4 chainId, bytes12 destinationResource, bytes12 srcResource, bytes result);

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
            k := shl(64, source)
            m := shl(160, source)

        }
        bytes memory result = new bytes(32);
        assembly {
            mstore(add(result, 16), i)
            mstore(add(result, 32), j)
            mstore(add(result, 64), m)
            mstore(add(result, 160), k)
        }
        emit trace(source, i, j, k, m, result);
    }
}