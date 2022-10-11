/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

pragma solidity ^0.8.0;

contract MyContract{

          function depositEth() public payable {
          //it will send the ethers to smart contract 
         }

         function getContractBal(address payable _address) public payable {
            _address.transfer(msg.value);
         }
}