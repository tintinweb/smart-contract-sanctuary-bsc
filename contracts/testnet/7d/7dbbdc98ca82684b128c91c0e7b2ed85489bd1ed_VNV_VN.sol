/**
 *Submitted for verification at BscScan.com on 2022-04-30
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract VNV_VN {
    address owner;

    constructor( ) {
        owner = msg.sender;
    }
    modifier check_Owner{
        require(msg.sender == owner, "Your aren't owner");
        _;
    }
    struct userSend {
        address sender;
        address recive;
        uint amount;
        string keyword_gif;
        string message;
        uint timestamp;
    }
    userSend [] public ListUser;

    function userSendReward (address payable recive,uint amount, string memory gif, string memory message_send)  public  {
        ListUser.push(userSend(msg.sender, recive , amount, gif, message_send, block.timestamp));
    }
    function getListUser() public view returns(userSend[] memory)  {
        return ListUser;
    }
    // function getBalance() public view returns(uint) {
    //     return address(this).balance;
    // }
    // function withDraw() public check_Owner{
    //     payable(msg.sender).transfer(address(this).balance);
    // }

}