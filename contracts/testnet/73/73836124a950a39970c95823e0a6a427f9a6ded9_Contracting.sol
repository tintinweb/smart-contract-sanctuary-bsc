/**
 *Submitted for verification at BscScan.com on 2022-02-11
*/

pragma solidity >0.4.22<0.7.1;

contract Contracting{

   address public owner;
    constructor() public{

       owner = msg.sender;
    }

    function pay() public payable returns(string memory){

        return "success";
    }


    function WithdrawContractor(address payable _to) public payable returns(string memory){
        require(msg.sender==owner);
       _to.transfer(msg.value);
        return "success";
    }
}