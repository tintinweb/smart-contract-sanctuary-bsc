//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./JKPLibrary.sol";
import "./IJoKenPo.sol";

contract JKPAdapter {
    IJoKenPo private joKenPo;
    address public immutable owner;
    uint256 public plays = 0;

    event EndGame(address lastPlayer, JKPLibrary.Options newChoice);

    constructor() {
        owner = msg.sender;
    }

    function getAddress() external view returns (address) {
        return address(joKenPo);
    }

    function upgrade(address newImplementation) external restricted {
        require(
            newImplementation != address(0),
            "Empty address is not permitted"
        );
        joKenPo = IJoKenPo(newImplementation);
    }

    function getResult() external view upgraded returns (string memory) {
        return joKenPo.getResult();
    }

    function play(JKPLibrary.Options newChoice) external payable upgraded {
        joKenPo.play{value: msg.value}(newChoice);

        plays++;

        if (plays % 2 == 0) emit EndGame(msg.sender, newChoice);
    }

    function getLeaderboard()
        external
        view
        upgraded
        returns (JKPLibrary.Player[] memory)
    {
        return joKenPo.getLeaderboard();
    }

    function setBid(uint256 newBid) external restricted upgraded {
        return joKenPo.setBid(newBid);
    }

    function setCommission(uint8 newCommission) external restricted upgraded {
        return joKenPo.setCommission(newCommission);
    }

    function getBid() external view upgraded returns (uint256) {
        return joKenPo.getBid();
    }

    function getCommission() external view upgraded returns (uint8) {
        return joKenPo.getCommission();
    }

    modifier upgraded() {
        require(address(joKenPo) != address(0), "You must upgrade first");
        _;
    }

    modifier restricted() {
        require(owner == msg.sender, "You do not have permission");
        _;
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

    function play(JKPLibrary.Options newChoice) external payable;

    function getLeaderboard()
        external
        view
        returns (JKPLibrary.Player[] memory);

    function getBid() external view returns (uint256);

    function getCommission() external view returns (uint8);

    function setBid(uint256 newBid) external;

    function setCommission(uint8 newCommission) external;
}