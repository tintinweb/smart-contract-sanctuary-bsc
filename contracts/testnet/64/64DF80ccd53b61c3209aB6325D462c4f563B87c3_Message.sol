/**
 *Submitted for verification at BscScan.com on 2022-03-08
*/

pragma solidity ^0.5.0;

contract Message {
    string private newMessage = "";
    string public contractName = "hello world";
    event AddMess(string newMess);
    function setMessage(string memory _mess) public {
        newMessage = _mess;
        emit AddMess(_mess);
    }
    function getMessage() public view returns (string memory){
        return newMessage;
    }
}