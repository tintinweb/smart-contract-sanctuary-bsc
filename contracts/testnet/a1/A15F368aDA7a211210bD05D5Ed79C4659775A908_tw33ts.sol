/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

contract tw33ts {

    address public owner;
    uint256 private counter;

    constructor() {
        counter = 0;
        owner = msg.sender;
    }

    struct tw33t {
        address tw33ter;
        uint256 id;
        string tw33tTxt;
        string tw33tImg;
    }

    event tw33tCreated (
        address tw33ter,
        uint256 id,
        string tw33tTxt,
        string tw33tImg
    );

    mapping(uint256 => tw33t) Tw33ts;

    function addTw33t(
        string memory tw33tTxt,
        string memory tw33tImg
    ) public payable {
        require(msg.value == (1 ether), "Please submit 1 Matic");
        tw33t storage newTw33t = Tw33ts[counter];
        newTw33t.tw33tTxt = tw33tTxt;
        newTw33t.tw33tImg = tw33tImg;
        newTw33t.tw33ter = msg.sender;
        newTw33t.id = counter;

        emit tw33tCreated(
            msg.sender,
            counter,
            tw33tTxt,
            tw33tImg
        );
        
        counter++;

        payable(owner).transfer(msg.value);
    }

    function getTw33t(uint256 id) public view returns(
        string memory,
        string memory,
        address
    ){
        require(id < counter, "No such tw33t");
        tw33t storage t = Tw33ts[id];
        return(t.tw33tTxt,t.tw33tImg,t.tw33ter);
    }

}