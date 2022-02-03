// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

contract Lottery {
    address public immutable OWNER;
    address[] public players;

    uint256 private counter;

    constructor() {
        OWNER = msg.sender;
    }

    function enter() public payable {
        require(msg.value == 0.1 ether, "Invalid amount");

        players.push(msg.sender);
    }

    function random() private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.difficulty,
                        players,
                        counter
                    )
                )
            );
    }

    function pickWinner() public onlyOwner returns (address payable) {
        address payable winner = payable(players[random() % players.length]);

        winner.transfer(address(this).balance);

        players = new address[](0);

        counter = counter + 1;

        return winner;
    }

    function getPlayers() public view returns (address[] memory) {
        return players;
    }

    modifier onlyOwner() {
        require(OWNER == msg.sender, "Only Owner");
        _;
    }
}