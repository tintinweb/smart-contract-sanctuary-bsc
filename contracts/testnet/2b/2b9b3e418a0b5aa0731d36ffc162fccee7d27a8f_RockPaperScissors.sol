/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

// File @openzeppelin/contracts/utils/[email protected]

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// File @openzeppelin/contracts/access/[email protected]

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File contracts/GameContext.sol

pragma solidity ^0.8.0;

abstract contract GameContext is Ownable {
    struct ContextData {
        uint32 waitingForOpponentTimeout;
        uint32 moveTimeout;
        uint32 scoreThreshold;
        uint32 roundThreshold;
        uint32 ownerTipRate;
        uint32 referralTipRate;
        uint32 claimTimeout;
    }

    mapping(uint256 => ContextData) internal _contexts;
    uint256 internal _currentContextIndex;

    constructor(ContextData memory context) {
        _contexts[_currentContextIndex] = context;
    }

    function getCurrentContext() external view returns(ContextData memory) {
        return _contexts[_currentContextIndex];
    }

    function updateContext(ContextData calldata context) external payable onlyOwner {
        _currentContextIndex++;
        _contexts[_currentContextIndex] = context;
        emit ContextUpdate(_currentContextIndex);
    }

    event ContextUpdate(uint256 newIndex);
}


// File contracts/Balance.sol

pragma solidity ^0.8.0;

abstract contract Balance {
    mapping(address => uint256) public balances;

    function withraw() external payable withrawMod() {
        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        emit Withraw(msg.sender, amount);
    }

    modifier withrawMod() {
        require(balances[msg.sender] > 0, "ZERO");
        _;
    }

    event Withraw(address indexed adr, uint256 amount);
}


// File contracts/Referral.sol

pragma solidity ^0.8.0;

abstract contract Referral {
    mapping(address => bool) public referrals;

    function registerReferral() external payable referralMod {
        referrals[msg.sender] = true;
        emit NewReferral(msg.sender);
    }

    modifier referralMod() {
        require(!referrals[msg.sender], "REGISTERED");
        _;
    }

    event NewReferral(address indexed ref);
}


// File contracts/RockPaperScissors.sol

pragma solidity ^0.8.0;

// solhint-disable not-rely-on-time
contract RockPaperScissors is Balance, GameContext, Referral {
    enum GameState {
        WaitingForOpponent,
        PendingMoves,
        ValidatingMoves,
        Finished
    }

    enum Move {
        Illegal,
        Rock,
        Paper,
        Scissors
    }

    struct Player {
        address adr;
        uint8 score;
        bytes32 hashedMove;
        bytes32 move;
    }

    struct Game {
        Player challenger;
        Player opponent;
        uint256 pot;
        uint256 updateTimestamp;
        uint256 acceptBlockNumber;
        uint256 validateBlockNumber;
        bytes32 passwordHash;
        GameState state;
        uint8 round;
        address referral;
        address winner;
        uint256 contextIndex;
    }

    struct GameWrapper {
        Game game;
        ContextData context;
        uint256 timestamp;
    }

    uint256 internal _nextGameId;
    mapping(uint256 => Game) internal _games;

    // solhint-disable no-empty-blocks
    constructor(ContextData memory context) GameContext(context) {}

    // public functions
    function getGame(uint256 gameId) public view returns (GameWrapper memory) {
        Game memory game = _games[gameId];
        ContextData memory context = _contexts[game.contextIndex];
        return GameWrapper(game, context, block.timestamp);
    }

    // external functions
    function startNewGame(address referral, bytes32 passwordHash)
        external
        payable
        startNewGameMod(referral)
        returns (uint256)
    {
        // get game
        uint256 gameId = _getNextGameId();
        Game storage game = _games[gameId];

        // set game info
        game.contextIndex = _currentContextIndex;
        game.pot = msg.value;
        game.updateTimestamp = block.timestamp;
        game.passwordHash = passwordHash;
        game.referral = referral;

        // set challenger info
        game.challenger.adr = msg.sender;

        // publish event
        emit GameUpdated(gameId, GameState.WaitingForOpponent);
        return gameId;
    }

    function acceptGame(uint256 gameId, string calldata password)
        external
        payable
        acceptGameMod(gameId, password)
    {
        // get game
        Game storage game = _games[gameId];

        // update state
        game.pot += msg.value;
        game.updateTimestamp = block.timestamp;
        game.state = GameState.PendingMoves;
        game.acceptBlockNumber = block.number;

        // set opponent info
        game.opponent.adr = msg.sender;

        // publish event
        emit GameUpdated(gameId, game.state);
    }

    function abortGame(uint256 gameId) external payable abortGameMod(gameId) {
        // get game
        Game storage game = _games[gameId];

        // update game
        game.state = GameState.Finished;
        game.updateTimestamp = block.timestamp;

        // refund
        if (game.pot > 0) {
            payable(game.challenger.adr).transfer(game.pot);
        }

        // publish events
        emit GameUpdated(gameId, game.state);
    }

    function submitHashedMove(uint256 gameId, bytes32 hashedMove)
        external
        payable
        submitHashedMoveMod(gameId)
    {
        // update player info
        Game storage game = _games[gameId];
        Player storage you = _getPlayer(game);
        you.hashedMove = hashedMove;

        // if other player's info is updated...
        Player storage other = _getOtherPlayer(game);
        if (other.hashedMove == 0) return;

        // ... update game state
        game.state = GameState.ValidatingMoves;
        game.updateTimestamp = block.timestamp;
        emit GameUpdated(gameId, game.state);
    }

    function submitMove(uint256 gameId, bytes32 move)
        external
        payable
        submitMoveMod(gameId)
    {
        // update player info
        Game storage game = _games[gameId];
        Player storage you = _getPlayer(game);
        you.move = move;

        // if other player's info is updated...
        Player storage other = _getOtherPlayer(game);
        if (other.move == 0) return;

        // ... update game state
        _resolveMoveSubmissions(gameId);
    }

    function surrenderGame(uint256 gameId)
        external
        payable
        surrenderGameMod(gameId)
    {
        Game storage game = _games[gameId];
        Player storage otherPlayer = _getOtherPlayer(game);
        _finishGame(game, otherPlayer.adr);
        emit GameUpdated(gameId, game.state);
    }

    function claimPot(uint256 gameId) external payable claimPotMod(gameId) {
        Game storage game = _games[gameId];
        game.updateTimestamp = block.timestamp;
        game.state = GameState.Finished;
        game.winner = msg.sender;
        _resolvePot(game, msg.sender);
        emit GameUpdated(gameId, game.state);
    }

    // internal functions
    function _getNextGameId() internal returns (uint256) {
        return _nextGameId++;
    }

    // if length of a string is zero avoid hashing by returning constant
    function _getStringHash(string calldata input)
        internal
        pure
        returns (bytes32)
    {
        return
            bytes(input).length == 0
                ? bytes32(0)
                : keccak256(abi.encodePacked(input));
    }

    function _parseMove(Player storage player) internal view returns (Move) {
        bytes32 hashedMove = keccak256(abi.encodePacked(player.move));

        if (hashedMove != player.hashedMove) return Move.Illegal;

        uint256 moveValue = uint256(player.move) & 3;

        if (moveValue < 4) return Move(moveValue);
        else return Move.Illegal;
    }

    function _getPlayer(Game storage game)
        internal
        view
        returns (Player storage)
    {
        if (game.opponent.adr == msg.sender) return game.opponent;
        else return game.challenger;
    }

    function _getOtherPlayer(Game storage game)
        internal
        view
        returns (Player storage)
    {
        if (game.opponent.adr == msg.sender) return game.challenger;
        else return game.opponent;
    }

    function _resolveMoveSubmissions(uint256 gameId) internal {
        Game storage game = _games[gameId];
        ContextData storage context = _contexts[game.contextIndex];
        Move opponentMove = _parseMove(game.opponent);
        Move challengerMove = _parseMove(game.challenger);
        Player storage winner = _getRoundWinner(
            game,
            opponentMove,
            challengerMove
        );

        emit ValidatedMoves(gameId, game.round, challengerMove, opponentMove);
        game.validateBlockNumber = block.number;
        game.round++;

        if (winner.adr != address(0)) winner.score++;
        else winner = _getLeadingPlayer(game);

        // if winner's score or game's round reached threshold - finish the game
        if (
            context.scoreThreshold == winner.score ||
            game.round == context.roundThreshold
        )
            _finishGame(game, winner.adr);
            // otherwise, proceed to the next round
        else _updateGameForNextRound(game);

        emit GameUpdated(gameId, game.state);
    }

    function _getRoundWinner(
        Game storage game,
        Move opponentMove,
        Move challengerMove
    ) internal view returns (Player storage) {
        if (opponentMove == challengerMove) return _games[~uint256(0)].opponent;

        uint256 moveMask = (1 << (uint256(challengerMove) + 4)) |
            (1 << uint256(opponentMove));

        // Challenger - Opponent : bits
        if (
            // Scissors - Rock : 1000 0010
            moveMask == 130 ||
            // Rock - Paper : 0010 0100
            moveMask == 36 ||
            // Paper - Scissors : 0100 1000
            moveMask == 72 ||
            // Illegal - Rock : 0001 0010
            moveMask == 18 ||
            // Illegal - Paper : 0001 0100
            moveMask == 20 ||
            // Illegal - Scissors : 0001 1000
            moveMask == 24
        )
            return game.opponent;
        else
            return game.challenger;
    }

    function _finishGame(Game storage game, address winner) internal {
        _resolvePot(game, winner);
        game.state = GameState.Finished;
        game.updateTimestamp = block.timestamp;
        game.winner = winner;
    }

    function _calculateBasisPoint(uint256 number, uint256 basisPoint)
        internal
        pure
        returns (uint256)
    {
        return (number * basisPoint) / 10000;
    }

    function _getRoundLeader(Game storage game)
        internal
        view
        returns (Player storage player)
    {
        if (game.state == GameState.PendingMoves) {
            return game.challenger.hashedMove != 0 ? game.challenger : game.opponent;
        } else if (game.state == GameState.ValidatingMoves) {
            return game.challenger.move != 0 ? game.challenger : game.opponent;
        } else return _games[~uint256(0)].challenger;
    }

    function _getLeadingPlayer(Game storage game)
        internal
        view
        returns (Player storage)
    {
        if (game.opponent.score > game.challenger.score) return game.opponent;
        else return game.challenger;
    }

    //
    function _getWinningPlayer(Game storage game)
        internal
        view
        returns (Player storage)
    {
        if (game.state == GameState.PendingMoves) {
            return
                game.challenger.hashedMove != 0 ? game.challenger : game.opponent;
        } else if (game.state == GameState.ValidatingMoves) {
            return game.challenger.move != 0 ? game.challenger : game.opponent;
        } else {
            return _getLeadingPlayer(game);
        }
    }

    function _updateGameForNextRound(Game storage game) internal {
        game.opponent.hashedMove = 0;
        game.opponent.move = 0;
        game.challenger.hashedMove = 0;
        game.challenger.move = 0;
        game.state = GameState.PendingMoves;
        game.updateTimestamp = block.timestamp;
    }

    function _resolvePot(Game storage game, address winner) internal {
        if (game.pot == 0)
            return;
        
        ContextData storage context = _contexts[game.contextIndex];

        uint256 pot = game.pot;

        uint256 ownerTip = _calculateBasisPoint(pot, context.ownerTipRate);

        if (game.referral != address(0)) {
            uint256 referralTip = _calculateBasisPoint(
                pot,
                context.referralTipRate
            );
            pot -= referralTip;
            balances[game.referral] += referralTip;
        }

        pot -= ownerTip;
        balances[owner()] += ownerTip;

        balances[winner] += pot;
    }

    // events
    event GameUpdated(uint256 indexed gameId, GameState indexed state);

    event ValidatedMoves(
        uint256 indexed gameId,
        uint8 round,
        Move challengerMove,
        Move opponentMove
    );

    // modifiers
    modifier onlyUnregisteredReferral() {
        require(!referrals[msg.sender], "ADDRESS");
        _;
    }

    modifier startNewGameMod(address referral) {
        require(referrals[referral] || referral == address(0), "REFERRAL");
        _;
    }

    modifier abortGameMod(uint256 gameId) {
        Game storage game = _games[gameId];
        require(
            game.challenger.adr == msg.sender &&
                game.opponent.adr == address(0) &&
                game.state == GameState.WaitingForOpponent,
            "UNELIGIBLE"
        );
        _;
    }

    modifier surrenderGameMod(uint256 gameId) {
        Game storage game = _games[gameId];
        require(
            game.state == GameState.PendingMoves ||
                game.state == GameState.ValidatingMoves,
            "UNELIGIBLE"
        );
        require(
            game.challenger.adr == msg.sender ||
                game.opponent.adr == msg.sender,
            "ADDRESS"
        );
        _;
    }

    modifier acceptGameMod(uint256 gameId, string calldata password) {
        Game storage game = _games[gameId];
        ContextData storage context = _contexts[game.contextIndex];
        require(
            game.challenger.adr != address(0) &&
                game.opponent.adr == address(0) &&
                game.state == GameState.WaitingForOpponent &&
                game.updateTimestamp + context.waitingForOpponentTimeout >=
                block.timestamp,
            "UNELIGIBLE"
        );
        require(game.challenger.adr != msg.sender, "ADDRESS");
        require(game.passwordHash == _getStringHash(password), "PASSWORD");
        require(game.pot == msg.value, "VALUE");
        _;
    }

    modifier onlyInvolvedPlayer(Game storage game) {
        require(
            game.opponent.adr == msg.sender ||
                game.challenger.adr == msg.sender,
            "ADDRESS"
        );
        _;
    }

    modifier submitHashedMoveMod(uint256 gameId) {
        Game storage game = _games[gameId];
        ContextData storage context = _contexts[game.contextIndex];
        require(
            game.state == GameState.PendingMoves &&
                game.updateTimestamp + context.moveTimeout >= block.timestamp,
            "UNELIGIBLE"
        );
        require(
            game.challenger.adr == msg.sender ||
                game.opponent.adr == msg.sender,
            "ADDRESS"
        );
        Player storage player = _getPlayer(game);
        require(player.hashedMove == 0, "SUBMITTED");
        _;
    }

    modifier submitMoveMod(uint256 gameId) {
        Game storage game = _games[gameId];
        ContextData storage context = _contexts[game.contextIndex];
        require(
            game.state == GameState.ValidatingMoves &&
                game.updateTimestamp + context.moveTimeout >= block.timestamp,
            "UNELIGIBLE"
        );
        require(
            game.challenger.adr == msg.sender ||
                game.opponent.adr == msg.sender,
            "ADDRESS"
        );
        Player storage player = _getPlayer(game);
        require(player.move == 0, "SUBMITTED");
        _;
    }

    modifier claimPotMod(uint256 gameId) {
        Game storage game = _games[gameId];
        ContextData storage context = _contexts[game.contextIndex];
        if ((game.updateTimestamp + context.claimTimeout) < block.timestamp) {
            require(
                game.challenger.adr != address(0),
                "UNELIGIBLE"
            );
        } else {
            require(
                (game.state == GameState.PendingMoves || game.state == GameState.ValidatingMoves) &&
                (game.updateTimestamp + context.moveTimeout) < block.timestamp,
                "UNELIGIBLE"
            );
            Player storage player = _getRoundLeader(game);
            require(
                player.adr == msg.sender,
                "ADDRESS"
            );
        }
        _;
    }
}