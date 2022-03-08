/**
 *Submitted for verification at BscScan.com on 2022-03-08
*/

pragma solidity ^0.4.26;

contract MyTools {
    function getSlice(uint256 begin, uint256 end, bytes text) public  pure returns (bytes) {
        bytes memory a = new bytes(end-begin+1);
        for(uint i=0;i<=end-begin;i++){
            a[i] = text[i+begin-1];
        }
        return a;
    }


    function bytesToUint(bytes memory b) public  view returns (uint256){

        uint256 number;
        for(uint i= 0; i<b.length; i++){
            number = number + uint8(b[i])*(2**(8*(b.length-(i+1))));
        }
        return  number;
    }


    function bytesToAddress(bytes memory bys) public view returns (address addr) {
        assembly {
            addr := mload(add(bys,20))
        }

    }
}