/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract LuckyGame{
    /* ANy user can participate in the game
        1- users who wants to participate must pay an entrance fee = 5 BUSD in BNB
        2- after reaching 20 players we should pick a random winner from the 20 players
        3- All process of re-launching the game is automated
        4- The winner must pay a fee of 25% in order to be able to withdraw his funds gained in the game
        5- 3 main functions used:
            - function enterRaffle() {} : anyone who pays the entry 5 BUSD
            - function pickWinner() {} : automatically pick the winner after reaching 20 players 
            - function withdrawFunds() {} : the winner can withdraw funds if he pays 25% in fees to the smart contract
    */

    // State varibale that we can change and they are stored with the smart contract on the blockchain
    uint256 public entryPrice = 18500000000000000;
    address payable[] private players;
    uint256 private roundNumber = 1;
    uint256 public MAX_NUMBER_PLAYERS = 5;
    uint256 public toWinner = ((MAX_NUMBER_PLAYERS * entryPrice) * 3) / 4;
    uint256 public toCreator = ((MAX_NUMBER_PLAYERS * entryPrice) * 1) / 4;
    // a mapping to track each user entry
    mapping(address => uint256) public playerToNumberOfEntry;

    // mapping to map each winner with amount that he will be able to withdraw
    mapping(address => uint256) public winnerAmountToWithdraw;

    // game varibales
    address private winnerAddress;

    //setting the random number variable
    uint256 private randomNumber;

    // ids of winners
    uint256 public winnerId = 0;

    // address to send the game 25% fees
    // 0x7d2ac5c396b0900722d7231C041C8A7d4B71934E

    uint256 public fundsToCreator;

    // struct to store the winners
    struct winnersHistory {
        uint256 roundNumber;
        address _winnerOfTheRaffle;
        uint256 _amountGained;
    }

    // enum to create a state for the game
    enum gameState {
        OPEN,
        SELECTING
    }

    gameState public stateOfTheRaffle = gameState(0);

    // events section
    event playerEntered(address indexed _player);
    event winnerOfRound(
        uint256 indexed _Round,
        address indexed _winnerOfRaffle,
        uint256 indexed _amountToTransfer
    );

    winnersHistory[] public dataHistory;

    address[] public WINNERS;

    // function that generate a random number using the blocktimestamp
    function setRandomNumber() private returns (uint256) {
        require(
            stateOfTheRaffle == gameState.SELECTING,
            "Raffle is still opened!"
        );
        uint256 _randomNumber = uint256(
            keccak256(
                abi.encodePacked(block.difficulty, block.timestamp, players)
            )
        );
        randomNumber = _randomNumber;
        return _randomNumber;
    }

    // main functions of the raffle game
    function enterGame() public payable {
        require(msg.value == entryPrice, "Entry price is not correct!");
        require(
            players.length < 6,
            "Players have reached 6. Please, try next round!"
        );
        require(stateOfTheRaffle == gameState.OPEN, "Raffle is closed!");
        players.push(payable(msg.sender));
        emit playerEntered(msg.sender);
    }

    function pickWinner() public {
        require(players.length > 4, "Number of players is not correct!");
        require(address(this).balance > 0, "Not enough balance!");
        stateOfTheRaffle = gameState.SELECTING;
        uint256 RANDOM_NUMBER = setRandomNumber();
        uint256 winnerIndex = RANDOM_NUMBER % players.length;
        winnerAddress = players[winnerIndex];
        WINNERS.push(players[winnerIndex]);
        winnerAmountToWithdraw[players[winnerIndex]] = toWinner;
        fundsToCreator = toCreator;
        dataHistory.push(
            winnersHistory(roundNumber, players[winnerIndex], toWinner)
        );
        emit winnerOfRound(roundNumber, players[winnerIndex], toWinner);
        roundNumber = roundNumber + 1;
        stateOfTheRaffle = gameState.OPEN;
        players = new address payable[](0);
    }

    function checkWinner(address _WINNER_ADDRESS) public view returns (bool) {
        for (uint256 c = 0; c < WINNERS.length; c++) {
            if (_WINNER_ADDRESS == WINNERS[c]) {
                return true;
            }
        }
        return false;
    }

    function withdrawFunds() public {
        require(checkWinner(msg.sender), "You are not the winner!");
        require(
            winnerAmountToWithdraw[msg.sender] != 0,
            "You have already withdraw your funds!"
        );
        payable(msg.sender).transfer(winnerAmountToWithdraw[msg.sender]);
        payable(0x7d2ac5c396b0900722d7231C041C8A7d4B71934E).transfer(toCreator);

        winnerAmountToWithdraw[msg.sender] = 0;
    }

    // functions to view or get data
    function getNumberOfPlayers() public view returns (uint256) {
        return players.length;
    }

    function getNumberOfRounds() public view returns (uint256) {
        return roundNumber;
    }

    // function that calculate the number of how much an address occurs in the players array
    function getNumberOfEntries(
        address _playerAddress
    ) public view returns (uint256) {
        uint256 counter = 0;
        for (uint256 i = 0; i < players.length; i++) {
            if (_playerAddress == players[i]) {
                counter = counter + 1;
            }
        }
        return counter;
    }

    function getState() public view returns (gameState) {
        return stateOfTheRaffle;
    }

    function getWinner() public view returns (address) {
        return winnerAddress;
    }

    function getWinnersData() public view returns (winnersHistory[] memory) {
        return dataHistory;
    }

    function getWINNERS() public view returns (address[] memory) {
        return WINNERS;
    }
}