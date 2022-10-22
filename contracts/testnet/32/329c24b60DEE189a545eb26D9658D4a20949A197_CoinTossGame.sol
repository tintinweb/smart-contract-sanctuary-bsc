// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract CoinTossGame {
    event transfered(
        address indexed from,
        address indexed to,
        uint256 indexed amount
    );

    address private owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner can call this function");
        _;
    }

    function flipCoin() public payable {
        uint256 treasury = address(this).balance - msg.value;

        require(treasury != 0, "Can not participate because treasury is empty");
        require(msg.value != 0, "Attach money to try your luck");

        if (msg.value > treasury) {
            payable(msg.sender).transfer(msg.value);
            emit transfered(address(this), msg.sender, msg.value);
        } else if (randomNumber() <= 499) {
            payable(msg.sender).transfer(msg.value * 2);
            emit transfered(address(this), msg.sender, msg.value);
        }
    }

    function randomNumber() internal view returns (uint256) {
        return
            uint256(keccak256(abi.encode(block.timestamp, block.difficulty))) %
            1000;
    }

    function depositFundsInTreasury() public payable onlyOwner {
        require(msg.value != 0, "Attach money to deposit");
    }

    function checkTreasuryBalance() public view returns (uint256) {
        return address(this).balance;
    }
}