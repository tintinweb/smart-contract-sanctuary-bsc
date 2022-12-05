//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./JKPLibrary.sol";
import "./IJoKenPo.sol";

contract JKPAdapter {
    IJoKenPo private joKenPo;
    address public immutable owner;

    event Played(address indexed player, string result);

    constructor() {
        owner = msg.sender;
    }

    function getAddress() external view returns (address) {
        return address(joKenPo);
    }

    function upgrade(address newImplementation) external restricted {
        joKenPo = IJoKenPo(newImplementation);
    }

    modifier restricted() {
        require(owner == msg.sender, "You do not have permission.");
        _;
    }

    function getResult() external view returns (string memory) {
        require(address(joKenPo) != address(0), "You must upgrade first");
        return joKenPo.getResult();
    }

    function play(JKPLibrary.Options newChoice) external payable {
        require(address(joKenPo) != address(0), "You must upgrade first");
        string memory result = joKenPo.play{value: msg.value}(newChoice);
        emit Played(msg.sender, result);
    }

    function getLeaderboard()
        external
        view
        returns (JKPLibrary.Player[] memory)
    {
        require(address(joKenPo) != address(0), "You must upgrade first");
        return joKenPo.getLeaderboard();
    }

    function setBid(uint256 newBid) external {
        require(address(joKenPo) != address(0), "You must upgrade first");
        return joKenPo.setBid(newBid);
    }

    function setCommission(uint8 newCommission) external {
        require(address(joKenPo) != address(0), "You must upgrade first");
        return joKenPo.setCommission(newCommission);
    }

    function getBid() external view returns (uint256) {
        require(address(joKenPo) != address(0), "You must upgrade first");
        return joKenPo.getBid();
    }

    function getCommission() external view returns (uint8) {
        require(address(joKenPo) != address(0), "You must upgrade first");
        return joKenPo.getCommission();
    }
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

library JKPLibrary {

    enum Options {
        NONE,
        ROCK,
        PAPER,
        SCISSORS
    } //0, 1, 2, 3

    struct Player {
        address wallet;
        uint16 wins;
    }
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./JKPLibrary.sol";

interface IJoKenPo {
    function getResult() external view returns (string memory);

    function play(JKPLibrary.Options newChoice) external payable returns(string memory);

    function getLeaderboard()
        external
        view
        returns (JKPLibrary.Player[] memory);

    function getBid() external view returns (uint256);

    function getCommission() external view returns (uint8);

    function setBid(uint256 newBid) external;

    function setCommission(uint8 newCommission) external;
}