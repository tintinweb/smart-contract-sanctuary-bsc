/**
 *Submitted for verification at BscScan.com on 2022-05-10
*/

pragma solidity >=0.4.22 <0.7.0;

contract Ownable {
    address payable owner;
    constructor() public {
        owner = msg.sender;
    }

    modifier IsOwner {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }
    
}


contract SlotMachine is Ownable
{
    uint private Checkpot;
    event GameResult(
        address indexed player,
        bool won,
        uint amount,
        string reel1,
        string reel2,
        string reel3,
        bool canPlayAdditionalGame,
        bool wonAdditionalGame,
        uint number);

    enum Symbols {Seven, Bar, Melon, Bell, Peach, Orange, Cherry, Lemon}

    Symbols[21] private reel1 = [
        Symbols.Seven,
        Symbols.Bar, Symbols.Bar, Symbols.Bar,
        Symbols.Melon, Symbols.Melon,
        Symbols.Bell,
        Symbols.Peach, Symbols.Peach, Symbols.Peach, Symbols.Peach, Symbols.Peach, Symbols.Peach, Symbols.Peach,
        Symbols.Orange, Symbols.Orange, Symbols.Orange, Symbols.Orange, Symbols.Orange,
        Symbols.Cherry, Symbols.Cherry
        ];

    Symbols[24] private reel2 = [
        Symbols.Seven,
        Symbols.Bar, Symbols.Bar,
        Symbols.Melon, Symbols.Melon,
        Symbols.Bell, Symbols.Bell, Symbols.Bell, Symbols.Bell, Symbols.Bell,
        Symbols.Peach, Symbols.Peach, Symbols.Peach,
        Symbols.Orange, Symbols.Orange, Symbols.Orange, Symbols.Orange, Symbols.Orange,
        Symbols.Cherry, Symbols.Cherry, Symbols.Cherry, Symbols.Cherry, Symbols.Cherry, Symbols.Cherry
        ];
    
    Symbols[23] private reel3 = [
        Symbols.Seven,
        Symbols.Bar,
        Symbols.Melon, Symbols.Melon,
        Symbols.Bell, Symbols.Bell, Symbols.Bell, Symbols.Bell, Symbols.Bell, Symbols.Bell, Symbols.Bell, Symbols.Bell,
        Symbols.Peach, Symbols.Peach, Symbols.Peach,
        Symbols.Orange, Symbols.Orange, Symbols.Orange, Symbols.Orange,
        Symbols.Lemon, Symbols.Lemon, Symbols.Lemon, Symbols.Lemon
        ];

    uint[10] private AdditionalGame = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

    function GetCheckpot() public view returns (uint) {
        return Checkpot;
    }

    function PlaySlotMachine() public payable {
        require(msg.value > 0, "Bet size to small");
        

        (uint reel1Index, uint reel2Index, uint reel3Index) = GetRandomIndices();
        Symbols symbol1 = reel1[reel1Index];
        Symbols symbol2 = reel2[reel2Index];
        Symbols symbol3 = reel3[reel3Index];

        uint multiplicator = CheckIfDrawIsWinner(symbol1, symbol2, symbol3);
        bool winner = multiplicator != 0;
        uint winningAmount = 0;
        bool hasAdditionalGame = multiplicator == 200; // case: 777
        bool wonAdditionalGame = false;
        uint additionalGameNumber = 0;

        if (winner) {
            winningAmount = msg.value * multiplicator;

            // check if additonal game can be played
            if (hasAdditionalGame) {
                // if random number is equal to 0 --> win
                additionalGameNumber = GetRandomNumber(10,"0");
                if (additionalGameNumber == 0) {
                    uint currentCheckpot = Checkpot;
                    Checkpot = 0;
                    wonAdditionalGame = true;
                    winningAmount += currentCheckpot;
                }
            }
        } else {
            // add 10% of the input to the checkpot
            Checkpot += msg.value / 10; // TODO is this a correct division
        }
        
        if (winningAmount > 0) {
          msg.sender.transfer(winningAmount);
        }

        emit GameResult(
            msg.sender,
            winner,
            winningAmount,
            MapEnumString(symbol1),
            MapEnumString(symbol2),
            MapEnumString(symbol3),
            hasAdditionalGame,
            wonAdditionalGame,
            additionalGameNumber
            );
    }
    
    fallback() external payable {}
    receive() external payable {}

    function CheckIfDrawIsWinner(Symbols symbol1, Symbols symbol2, Symbols symbol3) private pure returns (uint multiplicator) {
        // 777
        if (symbol1 == Symbols.Seven && symbol2 == symbol1 && symbol3 == symbol1) {
            return 200;
        }
        // Bar Bar Bar
        if (symbol1 == Symbols.Bar && symbol2 == symbol1 && symbol3 == symbol1) {
            return 100;
        }
        // Melon Melon Melon
        if (symbol1 == Symbols.Melon && symbol2 == symbol1 && symbol3 == symbol1) {
            return 100;
        }
        // Bell Bell Bell
        if (symbol1 == Symbols.Bell && symbol2 == symbol1 && symbol3 == symbol1) {
            return 18;
        }
        // Peach Peach Peach
        if (symbol1 == Symbols.Peach && symbol2 == symbol1 && symbol3 == symbol1) {
            return 14;
        }
        // Orange Orange Orange
        if (symbol1 == Symbols.Orange && symbol2 == symbol1 && symbol3 == symbol1) {
            return 10;
        }

        // Melon Melon Bar
        if (symbol1 == Symbols.Melon && symbol2 == Symbols.Melon && symbol3 == Symbols.Bar) {
            return 100;
        }
        // Bell Bell Bar
        if (symbol1 == Symbols.Bell && symbol2 == Symbols.Bell && symbol3 == Symbols.Bar) {
            return 18;
        }
        // Peach Peach Bar
        if (symbol1 == Symbols.Peach && symbol2 == Symbols.Peach && symbol3 == Symbols.Bar) {
            return 14;
        }
        // Orange Orange Bar
        if (symbol1 == Symbols.Orange && symbol2 == Symbols.Orange && symbol3 == Symbols.Bar) {
            return 10;
        }

        // Cherries
        if (symbol1 == Symbols.Cherry) {
            // Cherry Cherry Anything
            if (symbol2 == Symbols.Cherry) {
                return 5;
            }
            // Cherry Anything Anything
            return 2;
        }

        // nothing
        return 0;
    }

    function GetRandomIndices() private view returns (uint, uint, uint) {
        uint indexReel1 = GetRandomNumber(reel1.length - 1, "1");
        uint indexReel2 = GetRandomNumber(reel2.length - 1, "2");
        uint indexReel3 = GetRandomNumber(reel3.length - 1, "3");

        require(indexReel1 >= 0 && indexReel1 < reel1.length, "Reel1 random index out of range");
        require(indexReel2 >= 0 && indexReel2 < reel2.length, "Reel2 random index out of range");
        require(indexReel3 >= 0 && indexReel3 < reel3.length, "Reel3 random index out of range");
        return (indexReel1, indexReel2, indexReel3);
    }

    function GetRandomNumber(uint max, bytes32 salt) private view returns (uint) {
        uint randomNumber = uint256(keccak256(abi.encode(block.difficulty, now, salt))) % (max + 1);
        require(randomNumber <= max, "random number out of range");
        return randomNumber;
    }

    function MapEnumString(Symbols input) private pure returns (string memory) {
        if (input == Symbols.Seven) {
            return "7";
        } else if (input == Symbols.Bar) {
            return "bar";
        } else if (input == Symbols.Melon) {
            return "melon";
        } else if (input == Symbols.Bell) {
            return "bell";
        } else if (input == Symbols.Peach) {
            return "peach";
        } else if (input == Symbols.Orange) {
            return "orange";
        } else if (input == Symbols.Cherry) {
            return "cherry";
        } else {
            return "lemon";
        }
    }

}