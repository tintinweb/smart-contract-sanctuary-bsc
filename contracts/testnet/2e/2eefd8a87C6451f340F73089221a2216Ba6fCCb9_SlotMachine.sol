/**
 *Submitted for verification at BscScan.com on 2022-12-17
*/

// File: SlotMachine.sol

pragma solidity >=0.4.22 <0.7.0;

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

contract Mortal is Ownable {
    function kill() public OnlyOwner {
        selfdestruct(owner);
    }
}

// interface RandomNumberOracleAPI {

//     function RequestRandomNumbers(address player, address callingSlotMachine) external;
// }

contract SlotMachine is Mortal
{
    uint private Jackpot;
    // address private RandomOracleAddress;

    enum Symbols {Seven, Bar, Melon, Bell, Peach, Orange, Cherry, Lemon}
    mapping(address => BetInput) CurrentPlayers;

    // event GameStarted(address indexed player);

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

    struct BetInput {
        uint inputAmount;
        bool isValue;
    }

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

    // function SetRandomOracleAddress(address target) public OnlyOwner {
    //     RandomOracleAddress = target;
    // }

    // For testing purposes
    function DeleteGame(address payable player) public OnlyOwner {
        delete(CurrentPlayers[player]);
    }
    
    function GetBalance() public view returns (uint b){
        address payable self = address(this);
        return self.balance;
    }

    function PlaySlotMachine() public payable {
        require(msg.value >= 100000000000000, "Bet size to small"); // 0.0001 ether
        // address payable self = address(this);
        // require(msg.value * 200 + Jackpot < self.balance, "The bet input is to large to be fully payed out"); //??
        require(CurrentPlayers[msg.sender].isValue == false, "Only one concurrent game per Player");

        // save that current sender is playing a game
        CurrentPlayers[msg.sender] = BetInput(msg.value, true);

        (uint reel1Index, uint reel2Index, uint reel3Index, uint reel4Index) = GetRandomIndices();
        // uint[] memory randomNums = GetRandomIndices();

        StopReels(reel1Index, reel2Index, reel3Index, reel4Index, msg.sender);

    }

    function StopReels(uint reel1Index, uint reel2Index, uint reel3Index, uint reel4Index, address payable player) public {
        // require(msg.sender == RandomOracleAddress, "Sender is not registered random Oracle");
        BetInput memory input = CurrentPlayers[player];
        require(input.isValue == true, "Player must have an open game"); 

        // get symbol for each real
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
            winningAmount = input.inputAmount * multiplicator;

            // check if additonal game can be played
            if (hasAdditionalGame) {

                // if random number is equal to 10 --> win
                additionalGameNumber = reel4Index;
                if (additionalGameNumber == 10) {
                    uint currentJackpot = Jackpot;
                    Jackpot = 0;
                    wonAdditionalGame = true;
                    winningAmount += currentJackpot;
                }
            }
        }

        // delete player from mapping
        // delete(CurrentPlayers[player]);
        
        // transfer funds or increase Jackpot
        if (winner) {
            player.transfer(winningAmount);
        } else {
            // add 10% of the input to the jackpot
            Jackpot += input.inputAmount / 10;
        }
        CurrentPlayers[msg.sender].isValue == false;

        emit GameResult(
            player,
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

    function GetRandomIndices() private view returns (uint, uint, uint, uint) {
        // indexReel = new uint[](4);
        uint indexReel1 = GetRandomNumber(reel1.length - 1, "1");
        uint indexReel2 = GetRandomNumber(reel2.length - 1, "2");
        uint indexReel3= GetRandomNumber(reel3.length - 1, "3");
        uint indexReel4 = GetRandomNumber(9, "0");

        require(indexReel1 >= 0 && indexReel1 < reel1.length, "Reel1 random index out of range");
        require(indexReel2 >= 0 && indexReel2 < reel2.length, "Reel2 random index out of range");
        require(indexReel3 >= 0 && indexReel3 < reel3.length, "Reel3 random index out of range");
        require(indexReel4 >= 0 && indexReel4 < 10, "Reel4 random index out of range");

        return (indexReel1, indexReel2, indexReel3, indexReel4);
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
                return 5;
            }
            // Cherry Anything Anything
            return 2;
        }
        
        if (symbol3 == Symbols.Bar) {
                // Orange Orange Bar
            if (symbol1 == Symbols.Orange && symbol2 == Symbols.Orange) {
                return 10;
            }
            
            // Peach Peach Bar
            if (symbol1 == Symbols.Peach && symbol2 == Symbols.Peach) {
                return 14;
            }
            
            // Bell Bell Bar
            if (symbol1 == Symbols.Bell && symbol2 == Symbols.Bell) {
                return 18;
            }
            
            // Melon Melon Bar
            if (symbol1 == Symbols.Melon && symbol2 == Symbols.Melon) {
                return 100;
            }
        }
        
        bool areAllReelsEqual = symbol2 == symbol1 && symbol3 == symbol1;
        if (areAllReelsEqual) {
                // Orange Orange Orange
            if (symbol1 == Symbols.Orange) {
                return 10;
            }
    
            // Peach Peach Peach
             else if (symbol1 == Symbols.Peach) {
                return 14;
            }
            
            // Bell Bell Bell
            if (symbol1 == Symbols.Bell) {
                return 18;
            }
            
            // Melon Melon Melon
            if (symbol1 == Symbols.Melon) {
                return 100;
            }
            
            // Bar Bar Bar
            if (symbol1 == Symbols.Bar) {
                return 100;
            }
            
            // 777
            if (symbol1 == Symbols.Seven) {
                return 200;
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