/**
 *Submitted for verification at BscScan.com on 2022-04-20
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract abc{


        function SetPercentage() public payable
    {
     require(msg.value>0,"Select amount first");
    }

    function show() public view returns(uint256)

    {
        return address(this).balance;
    }
    function transfer (address payable rec, uint256 amount) public
    {
        rec.transfer(amount);
    } 
    
       function transfer1 (address payable rec) public payable
    {
        rec.transfer(msg.value);
    }


}

contract xyz is abc{

}