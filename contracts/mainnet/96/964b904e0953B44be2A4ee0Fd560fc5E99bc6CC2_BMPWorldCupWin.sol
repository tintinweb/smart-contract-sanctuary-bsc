/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

pragma solidity ^0.4.26;

/**
 * @title Ballot
 * @dev Implements voting process along with vote delegation
 */
contract BMPWorldCupWin {
    struct Ticket {
        address holder;
        uint8[5] guesses;
    }

    struct Round {
        uint256 startTime;
        uint256 jackpot;
        address[] winners;
        Ticket[] tickets;
    }

    mapping(uint256 => Round) public rounds;
    uint256 public currentRound = 1;
    uint256 public constant cycle = 7 days;
    address public supportedContract;
    address owner;

    event buyEvent(address indexed user, uint8[5] guesses);

    constructor() public {
        rounds[currentRound].startTime = now;
        owner = msg.sender;
    }

    function buyTicket(uint8[5] guesses) public payable {
        require(
            supportedContract != address(0),
            "supported contract is not inserted"
        );
        require(msg.value >= (15 ether) / 1000, "Insufficient amount.");
        supportedContract.transfer((35 * msg.value) / 100);
        if (now - rounds[currentRound].startTime >= cycle) {
            drawRound();
        }
        rounds[currentRound].tickets.push(Ticket(msg.sender, guesses));

        emit buyEvent(msg.sender, guesses);
    }

    function drawRound() public {
        require(
            now - rounds[currentRound].startTime >= cycle,
            "Cycle not finished!"
        );
        uint8[] memory randomNumbers = generateRandom();
        address[] memory winners = new address[](
            rounds[currentRound].tickets.length
        );
        uint256 winnersCount;
        for (uint256 i; i < rounds[currentRound].tickets.length; i++) {
            Ticket storage ticket = rounds[currentRound].tickets[i];
            if (
                ticket.guesses[0] == randomNumbers[0] &&
                ticket.guesses[1] == randomNumbers[1] &&
                ticket.guesses[2] == randomNumbers[2] &&
                ticket.guesses[3] == randomNumbers[3] &&
                ticket.guesses[4] == randomNumbers[4]
            ) {
                winners[winnersCount] = ticket.holder;
                winnersCount += 1;
            }
        }

        //pay winners
        if (winnersCount > 0) {
            uint256 prize = address(this).balance / winnersCount;
            for (uint256 j; j < winnersCount; j++) {
                winners[j].transfer(prize);
                rounds[currentRound].winners.push(winners[j]);
            }
        }
        rounds[currentRound].jackpot = address(this).balance;

        //start next round
        currentRound += 1;
        rounds[currentRound].startTime = now;
    }

    function generateRandom() public view returns (uint8[] memory) {
        uint8[] memory numbers = new uint8[](5);
        for (uint256 j = 0; j < 5; j++) {
            numbers[j] =
                1 +
                (uint8(
                    keccak256(
                        abi.encodePacked(
                            block.difficulty,
                            block.timestamp,
                            rounds[currentRound].tickets.length,
                            j
                        )
                    )
                ) % 3);
        }
        return numbers;
    }

    function changeContract(address newAddress) public {
        require(msg.sender == owner, "only owner!");
        supportedContract = newAddress;
    }

    function changeOwner(address newOwner) public {
        require(msg.sender == owner, "only owner!");
        owner = newOwner;
    }

    function getUserTickets(address _adr) public view returns (uint256) {
        uint256 tickets = 0;
        for (uint256 i = 0; i < rounds[currentRound].tickets.length; i++) {
            if (rounds[currentRound].tickets[i].holder == _adr) {
                tickets++;
            }
        }
        return tickets;
    }

    function getLotteryStats()
        public
        view
        returns (
            uint256 roundId,
            uint256 jackpot,
            uint256 tickets,
            uint256 start,
            uint256 prevJackpot,
            address[] prevWinners
        )
    {
        Round storage round = rounds[currentRound];
        roundId = currentRound;
        jackpot = address(this).balance;
        tickets = round.tickets.length;
        start = round.startTime;
        prevJackpot = currentRound == 1 ? 0 : rounds[currentRound - 1].jackpot;
        prevWinners = currentRound == 1
            ? new address[](0)
            : rounds[currentRound - 1].winners;
    }
}