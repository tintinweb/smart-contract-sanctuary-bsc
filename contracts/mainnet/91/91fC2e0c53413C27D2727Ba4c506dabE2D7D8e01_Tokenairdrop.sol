/**
 *Submitted for verification at BscScan.com on 2022-03-01
*/

pragma solidity ^0.5.17;


contract IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}
contract Tokenairdrop {

   function airdropToken(IERC20 token, address payable[] memory to, uint256[] memory amt) public {
      
        // the addresses and amounts should be same in length
        require(to.length == amt.length, "The length of two array should be the same");
        
        for (uint i=0; i < to.length; i++) 
        {
            token.transfer(to[i], amt[i]);
        }
   }  
}