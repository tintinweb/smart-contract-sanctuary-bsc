/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

pragma solidity >0.8.0;

contract Receiver {
    string greeting = "Hello";
    
    event Greeting(string greeting);
    
    function greet() external  {
        emit Greeting(greeting);
    }
}