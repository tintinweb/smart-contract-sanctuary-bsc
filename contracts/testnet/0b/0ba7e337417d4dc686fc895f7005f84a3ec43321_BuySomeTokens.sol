/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IERC20 {
    function transfer(address to, uint amount) external;
    function decimals() external view returns(uint);
}

contract BuySomeTokens {
    uint tokenPriceInWei = 0.00000001190476 ether;

    IERC20 token;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function purchase() public payable {
        require(msg.value >= 0.021 ether, "Not enough money sent - ensure balance is at least 0.021");
        uint tokensToTransfer = msg.value / tokenPriceInWei;
        // uint remainder = msg.value - tokensToTransfer * tokenPriceInWei;
        token.transfer(msg.sender, tokensToTransfer * 10 ** token.decimals());
        // payable(msg.sender).transfer(remainder); //send the rest back

    }
}