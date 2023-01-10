/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

pragma solidity ^0.6.12;

contract SimpleContract {
    string public message;  // Declare a public string variable "message"

    // The following variables are directlty readable by public, so no need for getter functions
    uint256 public interactions;  // Count the number of interactions
    address public lastUser;  // The last address interacted with this contract

    // Declare an event called "MessageSet" that will be triggered
    // when the value of "message" is changed
    event MessageSet(string message);


    // Function to set the value of "message"
    function setMessage(string memory _message) public {
        message = _message;
        emit MessageSet(_message);  // Trigger the "MessageSet" event
    }

    // Function to get the value of "message"
    function getMessage() public view returns (string memory) {
        return message;
    }
}