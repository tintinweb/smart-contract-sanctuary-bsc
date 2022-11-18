// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import './IEmitEvent.sol';

contract EmitEvent is IEmitEvent {
    event Say(string message, uint256 traceid);

    function mintNFT(string memory message, uint256 traceid) public override {
        emit Say(message, traceid);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IEmitEvent {
    function mintNFT(string memory message, uint256 traceid) external;
}