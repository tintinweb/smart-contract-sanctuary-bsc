// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

contract ChainVerseEvent {

    struct Payment {
        address currency;
        uint256 price;
    }

    event Breeding(address[] addresses, uint256 indexed newItemId, uint256 parent1Id, uint256 parent2Id, Payment[] payments, Payment payment, uint256 expire, bytes signature);

    constructor(){

    }
    function breeding(address[] calldata addresses, uint256 newItemId,
        uint256 parent1Id, uint256 parent2Id,
        Payment[] calldata payments, Payment calldata payment,
        uint256 expire, bytes memory signature) public {
        emit Breeding(addresses, newItemId, parent1Id, parent2Id, payments, payment, expire, signature);
    }
}