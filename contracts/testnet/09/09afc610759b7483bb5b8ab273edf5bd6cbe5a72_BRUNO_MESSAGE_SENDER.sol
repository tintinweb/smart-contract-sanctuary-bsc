/**
 *Submitted for verification at BscScan.com on 2022-09-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;


contract BRUNO_MESSAGE_SENDER{

    string _message;
    string _receiversName;
    string _reciversTelegram;
    address _receiver;    


    function Message(string memory message, string memory receiversName, string memory receiversTelegram, address receiver) public {

        _message = message;
        _receiversName = receiversName;
        _reciversTelegram = receiversTelegram;
        _receiver = receiver;
    }
}