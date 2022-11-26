/**
 *Submitted for verification at BscScan.com on 2022-11-26
*/

pragma solidity ^0.8.0;

contract guess {
    uint256 private s4;
    uint256 private s6;
    address public owner;
    constructor() {
        owner = msg.sender;
    }
    function setsecretno(uint256 se4,uint256 se6) public {
        require(msg.sender == owner);
        s4 = se4;
        s6 = se6;
    }

    function guess4(uint256 n) public view returns(uint256){
        if(n == s4){
            return 1;
        }
        else if((n%1000) == (s4%1000)) {
            return 2;
        }
        else if((n%100) == (s4%100)) {
            return 3;
        }
        else {
            return 4;
        }
    }

    function guess6(uint256 n) public view returns(uint256){
        uint t = n/10000;
        uint s = s6/10000;
        uint p = n/1000;
        uint q = s6/1000;
        if(n == s6){
            return 1;
        }
        else if(((n%100) == (s6%100)) && (t == s)) {
            return 2;
        }
        else if( ((n%100) == (s6%100)) && ((p%100) == (q%100)) ) {
            return 3;
        }
        else {
            return 4;
        }
    }

    function countno(uint256 n) internal pure returns(uint256) {
        uint256 count=0;
    do {
    n = n / 10;
    ++count;
    } while (n != 0);
   return count;

    }

    function guessnumpos(uint256 no,uint p) public view returns(bool) {
       uint256 c1=countno(s6);
       uint256 t1 = s6 / (10**(c1-p));

       if(no == (t1%10)) {
           return true;
       }
       else {
           return false;
       }

    }


}