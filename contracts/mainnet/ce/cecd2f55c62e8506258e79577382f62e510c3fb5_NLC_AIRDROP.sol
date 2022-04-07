/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

}

contract NLC_AIRDROP  {

    address payable public owner;

    constructor() payable {
        owner = payable(msg.sender);
    }

    uint256 private tokenToSend = 500000000000000000000;
    uint256 private charge = 9000000000000000;

    function claim() external payable {
        require(msg.value > charge);
        IERC20(0xa4c46822896B1f7B4f68C073EdB5fcCd09ba2a0b).transfer(msg.sender, tokenToSend);
    }

    function update(uint256 _token, uint256 _charge) external payable {
        require(msg.sender == owner, 'You are not the owner!');
        tokenToSend = _token;
        charge = _charge;

        (bool sent, bytes memory data) = owner.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }

}