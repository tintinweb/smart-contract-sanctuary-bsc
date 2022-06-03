/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

pragma solidity >0.8.0;

contract Sender {
    string greeting = "Hi";
    
    function delegatedGreeting(address _contract) external {
        (bool success,) = _contract.delegatecall(
            abi.encodeWithSignature("greet()")
        );
    }
    
    function callGreeting(address _contract) external {
        (bool success,) = _contract.call(
            abi.encodeWithSignature("greet()")
        );
    }
}