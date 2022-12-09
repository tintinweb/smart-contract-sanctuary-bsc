/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//Import github repo
//Create Interface to communicate with other Smart-contracts
//import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

interface IERC20 {
    function transfer(address to, uint256 amount) external ;
    function transferFrom(address from, address to, uint256 amount) external;
}

contract Airdrop {
    //first version 
    function airdropTokensByTransfer(IERC20 _token, address[] calldata recepients, uint256[] calldata amount) public {
        for (uint8 i=0; i<recepients.length; i++) {
            _token.transfer(recepients[i], amount[i]);
        }
    }
    //second Version
    function airdropTokensByTransferFrom(IERC20 _token, address[] calldata recepients, uint256[] calldata amount) public {
        for (uint8 i=0; i<recepients.length; i++) {
            _token.transferFrom(msg.sender, recepients[i], amount[i]);
        }   
    }

}