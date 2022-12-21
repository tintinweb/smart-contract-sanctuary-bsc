// SPDX-License-Identifier: MIT
// pragma solidity 0.6.12;
pragma solidity >=0.4.22 <0.7.0;
pragma experimental ABIEncoderV2;     

contract Ownable {
    address payable owner;
    constructor() public {
        owner = msg.sender;
    }

    modifier OnlyOwner {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }
    
}

contract SlotMachine is Ownable
{
    uint private Jackpot;

    enum Symbols {Seven, Bar, Melon, Bell, Peach, Orange, Cherry, Lemon}

    struct BetInput {
        uint inputAmount;
        bool isValue;
    }
    mapping(address => BetInput) public CurrentPlayers;
    
    event GameResult(
        address indexed player,
        bool won,
        uint amount,
        string reel1,
        string reel2,
        string reel3,
        bool canPlayAdditionalGame,
        bool wonAdditionalGame,
        uint number
    );

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

    // add balance to the slot machine for liquidity
    fallback() external payable {}
    receive() external payable {}

    function GetJackpot() public view returns (uint) {
        return Jackpot;
    }
    
    function GetBalance() public view returns (uint b){
        address payable self = address(this);
        return self.balance;
    }

    // function GetPlayResult(address player) public view returns (BetInput memory){
    //     return CurrentPlayers[player];
    // }

    function PlaySlotMachine() public payable {
        require(msg.value >= 100000000000000, "Bet size to small"); // 0.0001 ether
        // address payable self = address(this);
        // require(msg.value * 200 + Jackpot < self.balance, "The bet input is to large to be fully payed out"); //??
        require(CurrentPlayers[msg.sender].isValue == false, "Only one concurrent game per Player");

        // save that current sender is playing a game
        CurrentPlayers[msg.sender] = BetInput(msg.value, true);
        BetInput storage play = CurrentPlayers[msg.sender];

        (uint reel1Index, uint reel2Index, uint reel3Index) = GetRandomIndices();
        Symbols symbol1 = reel1[reel1Index];
        Symbols symbol2 = reel2[reel2Index];
        Symbols symbol3 = reel3[reel3Index];

        uint multiplicator = CheckIfDrawIsWinner(symbol1, symbol2, symbol3);
        bool won = multiplicator != 0;
        uint winningAmount = 0; // Todo should it be currentPlayer's []?
        bool hasAdditionalGame = multiplicator == 10; // case: 777
        bool wonAdditionalGame = false;
        uint additionalGameNumber = 0;

        if (won) {
            winningAmount = play.inputAmount * multiplicator;

            // check if additonal game can be played
            if (hasAdditionalGame) {
                // if random number is equal to 0 --> win
                additionalGameNumber = GetRandomNumber(9, "0");
                if (additionalGameNumber == 1) {
                    uint currentJackpot = Jackpot;
                    Jackpot = 0;
                    wonAdditionalGame = true;
                    winningAmount += currentJackpot;
                }
            }
        } else {
            // add 10% of the input to the jackpot
            Jackpot += play.inputAmount / 10;
        }
        // transfer funds or increase Jackpot
        if (winningAmount > 0) {
          msg.sender.transfer(winningAmount);
        }

        // delete player from mapping
        // delete(CurrentPlayers[msg.sender]);
        play.isValue = false;
        
        emit GameResult(
            msg.sender,
            won,
            winningAmount,
            MapEnumString(symbol1),
            MapEnumString(symbol2),
            MapEnumString(symbol3),
            hasAdditionalGame,
            wonAdditionalGame,
            additionalGameNumber
        );

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


    function CheckIfDrawIsWinner(Symbols symbol1, Symbols symbol2, Symbols symbol3) private pure returns (uint multiplicator) {
        // Cherries
        if (symbol1 == Symbols.Cherry) {
            // Cherry Cherry Anything
            if (symbol2 == Symbols.Cherry) {
                return 3; //5
            }
            // Cherry Anything Anything
            return 2;
        }
        
        if (symbol3 == Symbols.Bar) {
                // Orange Orange Bar
            if (symbol1 == Symbols.Orange && symbol2 == Symbols.Orange) {
                return 4; //10
            }
            
            // Peach Peach Bar
            if (symbol1 == Symbols.Peach && symbol2 == Symbols.Peach) {
                return 5; // 14
            }
            
            // Bell Bell Bar
            if (symbol1 == Symbols.Bell && symbol2 == Symbols.Bell) {
                return 6;  // 18
            }
            
            // Melon Melon Bar
            if (symbol1 == Symbols.Melon && symbol2 == Symbols.Melon) {
                return 9;  // 100
            }
        }
        
        bool areAllReelsEqual = symbol2 == symbol1 && symbol3 == symbol1;
        if (areAllReelsEqual) {
                // Orange Orange Orange
            if (symbol1 == Symbols.Orange) {
                return 10; // 10
            }
    
            // Peach Peach Peach
             else if (symbol1 == Symbols.Peach) {
                return 5;  // 14
            }
            
            // Bell Bell Bell
            if (symbol1 == Symbols.Bell) {
                return 6;  // 18
            }
            
            // Melon Melon Melon
            if (symbol1 == Symbols.Melon) {
                return 9; // 100
            }
            
            // Bar Bar Bar
            if (symbol1 == Symbols.Bar) {
                return 9; // 100
            }
            
            // 777
            if (symbol1 == Symbols.Seven) {
                return 10;     // 200
            }
        }
        
        // nothing
        return 0;
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

    // withdraw
    function withdraw(address payable _to, uint256 amount) public OnlyOwner {
        // uint256 tokenBalance = IERC20(earnToken).balanceOf(address(this));
        // require(tokenBalance > 0, "Owner has no balance to withdraw");
        // require(
        //     tokenBalance >= amount,
        //     "Insufficient amount of tokens to withdraw"
        // );
        // transfer some tokens to owner(or beneficient)
        // IERC20(earnToken).transfer(beneficiary, amount);
        _to.transfer(amount);
    }
    // burn
}