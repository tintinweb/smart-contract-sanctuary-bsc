// SPDX-License-Identifier: MIT
pragma solidity >=0.4.25 <0.9.0;

import './AccessControl.sol';

contract CryptoRPS is AccessControl {
  enum Gesture {
    Undefined,
    Rock,
    Paper,
    Scissor
  }

  enum GameState {
    Closed,
    WaitingForGuest,
    WaitingReveal
  }

  enum GameResult {
    Draw,
    HostWin,
    GuestWin
  }

  struct Game {
    uint256 id;
    uint256 deadlineToReveal;
    uint256 betAmount;
    address payable hostAddress;
    address payable guestAddress;
    address payable playerWinAddress;
    GameState state;
    Gesture guestGesture;
    Gesture hostGesture;
    bytes32 hostGestureHash;
  }

  address constant DUMMY_ADDRESS = 0x0000000000000000000000000000000000000000;

  event LogCloseGameSuccessed(uint256 _id, uint256 _refundAmount);
  event LogCreateGameSuccessed(uint256 _id, uint256 _betAmount);
  event LogJoinGameSuccessed(uint256 _id, address _hostAddress);
  event LogRevealGameSuccessed(
    uint256 _id,
    GameResult _result,
    address indexed _playerWinAddress,
    address indexed _playerLoseAddress,
    uint256 _playerWinAmount,
    uint256 _playerLoseAmount,
    Gesture _playerWinGesture,
    Gesture _playerLoseGesture
  );

  Game[] public games;
  mapping(Gesture => mapping(Gesture => GameResult)) payoff;
  mapping(address => uint256[]) public gameIdsOf;

  constructor() {
    adminAddress = msg.sender;

    //[Host Gesture][Guest Gesture]
    payoff[Gesture.Rock][Gesture.Rock] = GameResult.Draw;
    payoff[Gesture.Rock][Gesture.Paper] = GameResult.GuestWin;
    payoff[Gesture.Rock][Gesture.Scissor] = GameResult.HostWin;
    payoff[Gesture.Paper][Gesture.Paper] = GameResult.Draw;
    payoff[Gesture.Paper][Gesture.Scissor] = GameResult.GuestWin;
    payoff[Gesture.Paper][Gesture.Rock] = GameResult.HostWin;
    payoff[Gesture.Scissor][Gesture.Scissor] = GameResult.Draw;
    payoff[Gesture.Scissor][Gesture.Rock] = GameResult.GuestWin;
    payoff[Gesture.Scissor][Gesture.Paper] = GameResult.HostWin;
  }

  /**
   * @notice Accepts coins to add to the pot. Sender is not registered as a player!
   */
  receive() external payable {
    sendFeeToAdmin(msg.value);
  }

  function createGame(bytes32 _hostGestureHash) external payable whenNotPaused {
    Game memory game = Game({
      id: games.length,
      state: GameState.WaitingForGuest,
      deadlineToReveal: 0,
      betAmount: msg.value,
      hostAddress: payable(msg.sender),
      guestAddress: payable(DUMMY_ADDRESS),
      playerWinAddress: payable(DUMMY_ADDRESS),
      guestGesture: Gesture.Undefined,
      hostGesture: Gesture.Undefined,
      hostGestureHash: _hostGestureHash
    });

    games.push(game);
    gameIdsOf[msg.sender].push(game.id);

    emit LogCreateGameSuccessed(game.id, game.betAmount);
  }

  function joinGame(uint256 _id, Gesture _guestGesture) external payable whenNotPaused verifiedCanJoinGame(_id) verifiedGameId(_id) validGesture(_guestGesture) {
    Game storage game = games[_id];

    require(msg.sender != game.hostAddress, "Can't join game created by yourself");
    require(msg.value == game.betAmount, 'Amount bet to battle not extractly with bet amount of host');

    game.guestAddress = payable(msg.sender);
    game.guestGesture = _guestGesture;
    game.state = GameState.WaitingReveal;
    game.deadlineToReveal = block.timestamp + durationTimeForReveal;

    gameIdsOf[msg.sender].push(game.id);

    emit LogJoinGameSuccessed(game.id, game.hostAddress);
  }

  function revealGameByHost(
    uint256 _id,
    Gesture _hostGesture,
    bytes32 _hostGestureHash
  ) external payable whenNotPaused verifiedGameId(_id) validGesture(_hostGesture) {
    Game storage game = games[_id];

    require(game.hostAddress == msg.sender, "You're not host this game");
    require(game.state == GameState.WaitingReveal, 'Not in state waiting reveal from host');
    require(game.hostGestureHash != 0x0);
    require(game.hostGestureHash == _hostGestureHash, 'Wrong hashGesture from host to reveal');
    require(block.timestamp <= game.deadlineToReveal, 'Host reveal time out');

    if (_hostGesture == game.guestGesture) {
      sendPayment(game.hostAddress, game.betAmount);
      sendPayment(game.guestAddress, game.betAmount);
      emit LogRevealGameSuccessed(_id, GameResult.Draw, game.hostAddress, game.guestAddress, 0, 0, _hostGesture, game.guestGesture);
    } else {
      GameResult result = payoff[_hostGesture][game.guestGesture];

      if (result == GameResult.HostWin) {
        uint256 fee = getFee(game.betAmount);

        game.playerWinAddress = game.hostAddress;
        game.hostGesture = _hostGesture;
        game.state = GameState.Closed;
        sendFeeToAdmin(fee);
        sendPayment(game.hostAddress, game.betAmount * 2 - fee);
        emit LogRevealGameSuccessed(_id, GameResult.HostWin, game.hostAddress, game.guestAddress, game.betAmount - fee, game.betAmount, _hostGesture, game.guestGesture);
      } else if (result == GameResult.GuestWin) {
        uint256 fee = getFee(game.betAmount);

        game.playerWinAddress = game.guestAddress;
        game.hostGesture = _hostGesture;
        game.state = GameState.Closed;
        sendFeeToAdmin(fee);
        sendPayment(game.guestAddress, game.betAmount * 2 - fee);
        emit LogRevealGameSuccessed(_id, result, game.guestAddress, game.hostAddress, game.betAmount - fee, game.betAmount, game.guestGesture, _hostGesture);
      }
    }
  }

  function revealGameByGuest(uint256 _id) external payable whenNotPaused verifiedGameId(_id) {
    Game storage game = games[_id];

    require(game.state == GameState.WaitingReveal, 'Game not in state waiting reveal');
    require(block.timestamp > game.deadlineToReveal, 'Reveal time of host not time out');
    require(game.guestAddress == msg.sender, "You're not join this game");

    uint256 fee = getFee(game.betAmount);

    game.state = GameState.Closed;
    sendFeeToAdmin(fee);
    sendPayment(game.guestAddress, game.betAmount * 2 - fee);
    emit LogRevealGameSuccessed(_id, GameResult.GuestWin, game.guestAddress, game.hostAddress, game.betAmount - fee, game.betAmount, game.guestGesture, Gesture.Undefined);
  }

  function closeGameByHost(uint256 _id) external payable whenNotPaused verifiedGameId(_id) {
    Game storage game = games[_id];

    require(msg.sender == game.hostAddress, 'You not host this game!');
    require(game.state == GameState.WaitingForGuest, 'Game not in state waiting for guest');

    game.state = GameState.Closed;
    sendPayment(game.hostAddress, game.betAmount);
    emit LogCloseGameSuccessed(_id, game.betAmount);
  }

  function getFee(uint256 _winAmount) private view returns (uint256) {
    return (_winAmount * feePercent) / 100;
  }

  function sendPayment(address payable _receiverAddress, uint256 _amount) private {
    _receiverAddress.transfer(_amount);
  }

  function getGames() public view returns (Game[] memory) {
    return games;
  }

  function getTotalGamesOfPlayer(address playerAddress) public view returns (uint256) {
    return gameIdsOf[playerAddress].length;
  }

  modifier validGesture(Gesture _gesture) {
    require(_gesture == Gesture.Rock || _gesture == Gesture.Paper || _gesture == Gesture.Scissor, 'Invalid gesture!');
    _;
  }

  modifier verifiedCanJoinGame(uint256 _id) {
    require(games[_id].state == GameState.WaitingForGuest, 'Game not available!');
    _;
  }

  modifier verifiedGameId(uint256 _id) {
    require(_id >= 0, 'Game ID not verify!');
    _;
  }
}