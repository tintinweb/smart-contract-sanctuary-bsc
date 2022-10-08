// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

// import "hardhat/console.sol";

contract Lottery {
    address public manager;
    address[] public players;

    uint256 public constant ENTER_FEE = 1 ether;

    modifier onlyManager() {
        require(msg.sender == manager, "only manager");
        _;
    }

    constructor() {
        manager = msg.sender;
    }

    function enter() public payable {
        require(msg.value == ENTER_FEE, "insufficient enter fee");

        players.push(msg.sender);
    }

    function pickWinner() public onlyManager {
        uint256 index = _random() % players.length;

        payable(players[index]).transfer(address(this).balance);
        delete players;
    }

    function updateManager(address _manager) public onlyManager {
        manager = _manager;
    }

    function _random() private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(block.difficulty, block.timestamp, players)
                )
            );
    }

    function getPlayers() public view returns (address[] memory _players) {
        _players = players;
    }
}