/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

pragma solidity >=0.7.0 <0.9.0;


interface Callee {
   
    function receiveCall(uint256 n) external;

}

contract Caller{

    function callContract(uint256 n, address _callee) public {

        Callee(_callee).receiveCall(n);
    }

    function delegCall(uint256 n, address _callee) public {

        _callee.delegatecall(abi.encodeWithSignature("receiveCall(uint256)", n));
    }

}