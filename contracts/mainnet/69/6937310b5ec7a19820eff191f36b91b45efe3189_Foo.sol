/**
 *Submitted for verification at BscScan.com on 2022-12-30
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.12;

/*
library IntExtended {

    function increment(int _self) public pure returns (int) {
        return _self+1;
    }

    function decrease(int _value) public pure returns (int){
        return _value-1;
    }
}

contract TestLibrary {
    using IntExtended for uint;

    int public ab;

    function testIncrement(int _base) public returns (int) {
        ab += IntExtended.increment(_base);
        //uint a = IntExtended.increment(_base);
        //ab = IntExtended.increment(_base);
        return ab;
    }

    function checkDecrease(int main) public returns (int){
        ab -= IntExtended.decrease(main);
        return ab;
    }

    function dd(int xx) public pure returns (int){
        return xx/2;
    }
}

interface ECVerify {
    function ecverify(bytes32 hash, bytes memory sig, address signer) external returns (bool);
}*/

interface Assertion{
    function sortTwo(string memory str) external pure returns (address);
}


contract Foo {
    Assertion lib = Assertion(0xCDF61180A03D8300e41b44eD57EF130A3bB74783);

    function jj() public view returns(address){
        return lib.sortTwo(alphabet);
    }

    string alphabet = "1234567890abcdefghijklmnopqrstuvwxyz";

}