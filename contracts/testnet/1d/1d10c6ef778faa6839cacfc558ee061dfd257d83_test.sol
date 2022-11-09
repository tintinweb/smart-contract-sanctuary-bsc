/**
 *Submitted for verification at BscScan.com on 2022-11-09
*/

pragma solidity ^0.4.22;
contract pair{
    constructor()public{}
}

contract test{
    constructor()public{}
    mapping (string=>pair) getpair;
    function initPair()public{
        pair a = new pair();
        getpair['0'] = a;
    }
    // function list(string memory count)public{
    //     return getpair;
    // }
}