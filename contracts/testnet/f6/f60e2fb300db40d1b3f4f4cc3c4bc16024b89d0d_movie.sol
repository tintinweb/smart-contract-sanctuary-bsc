/**
 *Submitted for verification at BscScan.com on 2022-06-18
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract movie{
    address owner;
    int256 tno;

    struct booking{
        int256 sno;
        address booker;
        int256 persons;
        int256 date;
        string time;
        int256 screen;
    }

    booking[] tickets;

    constructor(){
        owner = msg.sender;
        tno = 0;
    }

    function book_ticket(int256 _persons, int256 _date, string memory _time, int256 _screen) public payable{
        payable(owner).transfer(msg.value);
        tickets.push(booking(++tno, msg.sender, _persons, _date, _time, _screen));
    }

    function get_tickets() public view returns(booking[] memory){
        booking[] memory found_tickets;
        for(uint256 i=0; i<uint256(tno); i++){
            if(tickets[i].booker == msg.sender){
                uint256 arrlen = found_tickets.length;
                arrlen++;
                found_tickets[arrlen] = tickets[i];
            }
        }
        return found_tickets;
    }

    function allocate_rewards(address _contract) public payable{
        payable(_contract).transfer(msg.value);
    }


}