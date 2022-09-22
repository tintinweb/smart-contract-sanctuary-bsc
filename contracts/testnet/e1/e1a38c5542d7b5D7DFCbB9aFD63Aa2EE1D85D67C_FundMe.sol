/**
 *Submitted for verification at BscScan.com on 2022-09-22
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


error NotOwner();

contract FundMe {
    
    address public /* immutable */ i_owner;
    uint256 public constant MINIMUM_USD = 10 * 1e18;
    struct Donate {
            uint256 to;
            address from;
            uint256 amount;
 }

  uint256 public funderCount;
  Donate[] public funders;
  
    
    constructor() {
        funderCount= 0;
       
        i_owner = msg.sender;
    }

    function fund(uint256 id) public payable  {
        require(msg.value >= 0.05 ether);

        funders.push(Donate(id,msg.sender,msg.value));
        funderCount++;
       
   
    }
    
 
    
    modifier onlyOwner {
        // require(msg.sender == owner);
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }
    
    function withdraw() public onlyOwner {
 
       
       
        delete funders;
        funderCount = 0;
        // // transfer
      
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }
   

   

}