/**
 *Submitted for verification at BscScan.com on 2022-08-12
*/

// File: contracts/abc.sol

pragma solidity ^0.8.13;


interface Al {

    function get() external view returns (uint256);
    
}
contract A {

    uint256 public a;
    address b;

    function setA(uint256 _a) public {
        a = _a;
    }

    function setB(address _b) public {
        b = _b;
    }

    function get() public {
        a =  Al(b).get();
    }
    
}


contract B {

    uint256 a;
    address c;

    function setA(uint256 _a) public payable {
        a = _a;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function setC(address _c) public {
        c = _c;
    }

    function get() public view returns (uint256) {
        return Al(c).get();
    }
    
}

contract C {

    uint256 a = 160298;

    function setA(uint256 _a) public {
        a = _a;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function get() public view returns (uint256) {
        return a;
    }
    
}


contract TestContract {
    event Start(uint start, uint middle, uint end) anonymous;
    event End(uint start, uint middle, uint end) anonymous;

    function abc() public {
        emit Start(1,2,3);
    }

}