/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

pragma solidity ^0.8.16;



contract Bakery {

  // index of created contracts

  Cookie[] public contracts;
  

  // useful to know the row count in contracts index

  function getContractCount() public view returns(uint contractCount) {
    return contracts.length;
  }

  // deploy a new contract

  function newCookie()
    public
  {
    Cookie c = new Cookie();
    contracts.push(c);
  }
}


contract Cookie {

  // suppose the deployed contract has a purpose

  function getFlavor() public pure returns (string memory flavor) {
    return "mmm ... chocolate chip";
  }    
}