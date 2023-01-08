/**
 *Submitted for verification at BscScan.com on 2023-01-08
*/

// SPDX-License-Identifier: UNLICENSED

// interested with this contract? => https://t.me/OxADE07

pragma solidity ^0.8.17;

interface iBotFrag {
    function BotFragBuyX(bytes32 data) external payable;
}

contract BotFragPublic {
    iBotFrag botfrag;

    constructor(address _bot) {
        botfrag = iBotFrag(_bot);
    }

    function OxADE07(bytes32 data) external payable {
        (bool status, ) = address(botfrag).call{value: msg.value}(
            abi.encodeCall(iBotFrag.BotFragBuyX, (data))
        );
        require(status, "x01");
    }
}