// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import './IEmitEvent.sol';

contract ExecFunction {
    address public emitEventAddress;
    mapping(address => uint256) public randomList;

    constructor(address emitEventAddress) {
        emitEventAddress = emitEventAddress;
    }

    function random(
        address addr,
        uint256 maxNumber,
        uint256 seedRandom
    ) internal view returns (uint256) {
        uint256 seed;
        unchecked {
            seed = uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp +
                            block.difficulty +
                            ((
                                uint256(
                                    keccak256(abi.encodePacked(block.coinbase))
                                )
                            ) / (block.timestamp)) +
                            block.gaslimit +
                            ((uint256(keccak256(abi.encodePacked(addr)))) /
                                (block.timestamp)) +
                            block.number +
                            uint256(
                                keccak256(
                                    abi.encodePacked(
                                        blockhash(block.number - 1)
                                    )
                                )
                            ) +
                            gasleft() +
                            seedRandom
                    )
                )
            );
        }

        uint256 randomNumber = seed % maxNumber;
        randomNumber = randomNumber < maxNumber
            ? randomNumber + 1
            : randomNumber;

        return randomNumber;
    }

    function execFunc(string memory message) public {
        uint256 traceid = random(msg.sender, 0, block.number);

        IEmitEvent(emitEventAddress).mintNFT(message, traceid);
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IEmitEvent {
    function mintNFT(string memory message, uint256 traceid) external;
}