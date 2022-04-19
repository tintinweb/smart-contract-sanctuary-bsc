/**
 *Submitted for verification at BscScan.com on 2022-04-19
*/

pragma solidity ^0.8.10;

    contract Send {
        constructor() payable {}

        receive() external payable {}

        function sendViaCall(address payable _to) external payable {
            (bool success, ) = _to.call{value: msg.value}("");

            require(success, "Send failed");
        }
    }

    contract Receive {
        event Log(uint256 amount, uint256 gas);

        receive() external payable {
            emit Log(msg.value, gasleft());
        }
    }