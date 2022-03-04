/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

pragma solidity ^0.8.0;

contract User {
    struct A {
        string name;
        string pass;
        uint mm;
    }

    struct B {
        uint bbb;
        uint ccc;
    }

    mapping(address => A[]) public a;

    mapping(address => B) public b;

    mapping(address => uint[]) public c;


    constructor () {
        a[msg.sender].push( A("lisi", "ff", 22));

        a[msg.sender].push( A("lisi", "ff", 22));
        
    }

    function getA(address addr) public view returns(A[] memory) {
        return a[addr];
    }

    function getB(uint index, address addr) public view returns(A memory) {
        return a[addr][index];
    }

}