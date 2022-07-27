// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "IERC20.sol";

contract JowirxBUSD {

    IERC20 tokenContract;
    address private owner;
    uint bal;

    constructor() payable {
        tokenContract = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        owner = msg.sender;
    }

    receive() external payable {}

    modifier OnlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function Approvetokens(uint256 _tokenamount) public returns(bool){
       tokenContract.approve(address(this), _tokenamount);
       return true;
   }

    function GetUserTokenBalance() public view returns(uint256){ 
       return tokenContract.balanceOf(msg.sender);
   }

    function deposit(uint256 _tokenamount) payable public {
        tokenContract.transferFrom(msg.sender, address(this), _tokenamount);
        bal += msg.value;
    }

    function getOwner() public view returns (address) {    
        return owner;
    }
    
    function withdrawToken(address _tokenContract, uint256 _amount) payable external {
        require(msg.sender == owner, "Only owner can withdraw!");
        IERC20(_tokenContract);
        tokenContract.transfer(msg.sender, _amount);
    }

}