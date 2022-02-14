/**
 *Submitted for verification at BscScan.com on 2022-02-14
*/

pragma solidity ^0.6.0;
contract SimpleContract {
    string message;

    function SetMessage(string memory _message) public {
        message=_message;
    }
}