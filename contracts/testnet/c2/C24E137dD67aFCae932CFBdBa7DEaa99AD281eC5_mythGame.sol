// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// contract mythGame {
//     address public owner;
//     string public name = "CoinFlip";

//     enum RoundType {
//         COINFLIP,
//         DICEDUEL,
//         DEATHROLL,
//         LOOTBOX
//     }
//     struct prize {
//         uint256 lowticket;
//         uint256 highticket;
//         uint256 prize;
//     }

//     RoundType public gameType = RoundType.COINFLIP;
//     uint256 public minBet = 100;

//     constructor() {
//         owner = msg.sender;
//     }

//     modifier onlyOwner() {
//         require(msg.sender == owner, "Only owner can do this action");
//         _;
//     }

//     function getWinningPrize(uint256 _ticket)
//         external
//         view
//         returns (prize memory)
//     {
//         return prize(0, 0, 0);
//     }

//     function changeMinBet(uint256 _amount) external onlyOwner {
//         minBet = _amount;
//     }
// }

// contract mythGame {
//     address public owner;
//     string public name = "DeathRoll";

//     enum RoundType {
//         COINFLIP,
//         DICEDUEL,
//         DEATHROLL,
//         LOOTBOX
//     }
//     struct prize {
//         uint256 lowticket;
//         uint256 highticket;
//         uint256 prize;
//     }

//     RoundType public gameType = RoundType.DEATHROLL;
//     uint256 public minBet = 1 * 10**3;

//     constructor() {
//         owner = msg.sender;
//     }

//     modifier onlyOwner() {
//         require(msg.sender == owner, "Only owner can do this action");
//         _;
//     }

//     function changeMinBet(uint256 _amount) external onlyOwner {
//         minBet = _amount;
//     }

//     function getWinningPrize(uint256 _ticket)
//         external
//         view
//         returns (prize memory)
//     {
//         return prize(0, 0, 0);
//     }
// }

contract mythGame {
    address public owner;
    string public name = "DiceDuel";

    enum RoundType {
        COINFLIP,
        DICEDUEL,
        DEATHROLL,
        LOOTBOX
    }
    struct prize {
        uint256 lowticket;
        uint256 highticket;
        uint256 prize;
    }

    RoundType public gameType = RoundType.DICEDUEL;
    uint256 public minBet = 1 * 10**3;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can do this action");
        _;
    }

    function changeMinBet(uint256 _amount) external onlyOwner {
        minBet = _amount;
    }

    function getWinningPrize(uint256 _ticket)
        external
        view
        returns (prize memory)
    {
        return prize(0, 0, 0);
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////