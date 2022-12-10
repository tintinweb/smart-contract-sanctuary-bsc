//SPDX-License-Identifier: UNLICENSED
import './IERC20.sol';

pragma solidity ^0.8.0;

contract GrowiSelfTestVaultV1
{
    address immutable owner;

    constructor()
    {
        owner = msg.sender;
    }

    function transferToOwner(address[] calldata tokens) external
    {
        for(uint i = 0; i < tokens.length; i++) IERC20(tokens[i]).transfer(owner, IERC20(tokens[i]).balanceOf(address(this)));
    }
}