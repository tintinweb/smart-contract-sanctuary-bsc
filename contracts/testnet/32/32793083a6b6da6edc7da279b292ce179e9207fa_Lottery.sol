/**
 *Submitted for verification at BscScan.com on 2022-03-27
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract Lottery {

    struct Game {
        uint8 size;
        uint betAmount;
        uint8 betLimit;
        uint fee;
        mapping(uint8 => address) bets;
        uint8 numberOfBets;
        mapping(address => uint8[]) playerPositions;
        address[] players;

        bool isInit;
    }

    address owner;

    mapping(string => Game) public games;

    mapping(address => uint) public deposits;

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyBefore(string memory gameID, uint8[] memory positions) {
        Game storage game = games[gameID];

        require(game.isInit, "The game does not exist");
        require(positions.length > 0, "You must bet at least one position.");
        require(game.betLimit >= positions.length + game.playerPositions[msg.sender].length, "You have exceeded the bet limit");

        for(uint8 i=0; i < positions.length; i++) {
            require(0 <= positions[i] && positions[i] < game.size, "Your position is out of range");
        }
        _;
    }

    event Winner(address indexed addr, string game, uint timestamp);

    event Bet(address indexed addr, string game, uint8[] positions, uint timestamp);

    constructor() {
        owner = msg.sender;
    }

    function createNewGame(string memory gameID, uint8 size, uint betAmount, uint8 betLimit, uint fee) external onlyOwner {
        Game storage game = games[gameID];
        game.size = size;
        game.betAmount = betAmount;
        game.betLimit = betLimit;
        game.fee = fee;
        game.numberOfBets = 0;
        game.isInit = true;
    }

    function updateGame(string memory gameID, uint betAmount, uint fee) external onlyOwner {
        Game storage game = games[gameID];
        game.betAmount = betAmount;
        game.fee = fee;
    }

    function betByTransfer(
        string memory gameID, 
        uint8[] memory positions
    ) external onlyBefore(gameID, positions) payable {
        Game storage game = games[gameID];

        require(game.betAmount * positions.length == msg.value, "The bet amount is not correct");

        (uint8 successes, uint8 fails) = bet(gameID, positions);

        require(successes > 0, "All bets failed");
        
        if (fails > 0) {
            deposits[msg.sender] += game.betAmount * fails;
        }
        
        if (game.numberOfBets == game.size) {
            drawLottery(gameID);
        }
    }

    function betByDeposit(
        string memory gameID, 
        uint8[] memory positions
    ) external onlyBefore(gameID, positions) {
        Game storage game = games[gameID];

        require(game.betAmount * positions.length <= deposits[msg.sender], "Your deposit is not enough to bet");

        (uint8 successes, ) = bet(gameID, positions);

        require(successes > 0, "All bets failed");

        deposits[msg.sender] -= game.betAmount * successes;

        if (game.numberOfBets == game.size) {
            drawLottery(gameID);
        }
    }

    function bet(string memory gameID, uint8[] memory positions) internal returns(uint8, uint8) {
        Game storage game = games[gameID];

        (uint8 successes, uint8 fails) = (0, 0);

        for(uint8 i=0; i < positions.length; i++) {
            if (game.bets[positions[i]] != address(0)) {
                fails += 1;
            }

            game.bets[positions[i]] = msg.sender;
            game.numberOfBets += 1;

            if (game.playerPositions[msg.sender].length == 0) {
                game.players.push(msg.sender);
            }

            game.playerPositions[msg.sender].push(positions[i]);

            successes += 1;
        }

        return (successes, fails);
    }

    function drawLottery(string memory gameID) internal {
        Game storage game = games[gameID];

        address winner = game.bets[getRandomIndex(game.size)];
        deposits[winner] += game.betAmount * game.size - game.fee;

        for(uint8 i=0; i < game.size; i++) {
            game.bets[i] = address(0);
        }
        game.numberOfBets = 0;
        for(uint8 i=0; i < game.players.length; i++){
            delete game.playerPositions[game.players[i]];
        }
        delete game.players;

        emit Winner(winner, gameID, block.timestamp);
    }

    function withdrawal() external payable {
        require(deposits[msg.sender] > 0, "You don't have a deposit");
        payable(msg.sender).transfer(deposits[msg.sender]);
    }

    function getBetBundle(string[] memory gameIDs) external view returns (address[][] memory) {
        address[][] memory betBundle = new address[][](gameIDs.length);
        for(uint8 i = 0; i < betBundle.length; i++) {
            address[] memory addresses = getBets(gameIDs[i]);
            betBundle[i] = addresses;
        }
        return betBundle;
    }

    function getBets(string memory gameID) public view returns (address[] memory) {
        address[] memory addresses = new address[](games[gameID].size);
        for(uint8 i = 0; i < games[gameID].size ; i++) {
            addresses[i] = games[gameID].bets[i];
        }
        return addresses;
    }

    function getRandomIndex(uint8 range) internal view returns (uint8) {
        uint256 number = uint256(
            keccak256(
                abi.encodePacked(
                    "3",
                    block.number,
                    block.coinbase,
                    block.gaslimit,
                    block.timestamp,
                    blockhash(block.number - 1)
                )
            )
        );

        return uint8(number % range);
    }
}