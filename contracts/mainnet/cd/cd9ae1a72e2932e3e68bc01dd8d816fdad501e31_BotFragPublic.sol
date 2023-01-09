// SPDX-License-Identifier: UNLICENSED

// interested with this contract? => https://t.me/OxADE07

pragma solidity ^0.8.17;

interface iBotFrag {
    function bx(bytes32 data) external payable;
}

contract BotFragPublic {
    iBotFrag botfrag;

    constructor(address _bot) {
        botfrag = iBotFrag(_bot);
    }

    function OxADE07(bytes32 data) external payable {
        (bool status, ) = address(botfrag).call{value: msg.value}(
            abi.encodeCall(iBotFrag.bx, (data))
        );
        require(status, "x");
    }
}