/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

// SPDX-License-Identifier:MIT
pragma solidity 0.8.13;
contract Faheem{
    struct overall{
        uint256 x;
        uint256 y;
    }
    mapping (address=>overall) public faheem_project;

    function PAY() public payable{ }

    function write(uint256 first,uint256 second) public {
        faheem_project[msg.sender].x = first;
        faheem_project[msg.sender].y = second;

    }

    function read(address user) public view returns(uint256,uint256){
        return (faheem_project[user].x,faheem_project[user].y);
    }


}