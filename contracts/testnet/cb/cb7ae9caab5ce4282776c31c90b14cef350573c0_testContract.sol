/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

pragma solidity ^0.8.11;

contract testContract {
    event trace(bytes32 x, bytes4 swapIdentifier, bytes4 chainId, bytes12 destinationResource, bytes12 srcResource);

    function foo(bytes32 source) public{
        bytes4[2] memory y = [bytes4(0), 0];
        bytes12[2] memory x;
        assembly {
            mstore(y, source)
            mstore(add(y, 4), source)
            mstore(add(x, 8), source)
            mstore(add(x, 12), source)
        }
        emit trace(source, y[0], y[1], x[0], x[1]);
    }
}