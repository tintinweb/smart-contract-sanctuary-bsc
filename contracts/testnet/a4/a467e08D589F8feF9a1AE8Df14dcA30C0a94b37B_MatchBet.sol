// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Disableable is Ownable {
    bool public disabled = false;

    modifier onlyEnabled() {
        require(!disabled, "Betting is disabled");
        _;
    }

    function disable() external onlyOwner {
        disabled = true;
    }

    function enable() external onlyOwner {
        disabled = false;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "./Disableable.sol";
import "./MatchesOracle.sol";

contract MatchBet is Disableable {
    struct Bet {
        uint id;
        address user;
        uint matchId;
        int8 winner;
        uint8 score1;
        uint8 score2;
    }
    struct RoundBet {
        uint id;
        uint[] bets;
    }
    event BetPlaced(
        uint id,
        uint roundId,
        address user,
        uint matchId,
        int8 winner,
        uint8 score1,
        uint8 score2
    );

    mapping(uint => RoundBet) public roundBets;
    mapping(uint => Bet) public bets;
    mapping(address => uint[]) public userBets;
    uint public nextBetId = 0;

    address internal matchesOracleAddress;
    MatchesOracle internal matchesOracle;

    constructor(address matchesOracleAddress_) {
        require(matchesOracleAddress_ != address(0), "Invalid address");
        matchesOracleAddress = matchesOracleAddress_;
        matchesOracle = MatchesOracle(matchesOracleAddress);
    }

    function setMatchesOracleAddress(address matchesOracleAddress_) public onlyOwner {
        require(matchesOracleAddress_ != address(0), "Invalid address");
        matchesOracleAddress = matchesOracleAddress_;
        matchesOracle = MatchesOracle(matchesOracleAddress);
    }

    function _validBet(address user, uint stage, uint matchId, int8 winner) internal view returns (bool) {
        require(user != address(0), "Invalid address");
        require(matchesOracle.roundExists(stage), "Round does not exist");
        require(matchesOracle.matchExists(stage, matchId), "Match does not exist");
        require(winner == 0 || winner == 1 || winner == 2, "Winner must be 0, 1 or 2");
        return true;
    }

    function _roundOpen(uint stage) internal view returns (bool) {
        MatchesOracle.Round memory round = matchesOracle.getRound(stage);
        return round.state == MatchesOracle.State.Open;
    }

    function getOracleAddress() public view returns (address) {
        return matchesOracleAddress;
    }

    function checkConnection() public view returns (bool) {
        return matchesOracle.checkConnection();
    }

    function getMatch(uint stage, uint matchId) public view returns (MatchesOracle.Match memory) {
        return matchesOracle.getMatch(stage, matchId);
    }

    function placeBet(uint stage, uint[] memory matchId, int8[] memory winner, uint8[] memory score1, uint8[] memory score2) public onlyEnabled {
        require(matchId.length == winner.length, "lengths of arrays must be equal");
        require(matchId.length == score1.length, "lengths of arrays must be equal");
        require(matchId.length == score2.length, "lengths of arrays must be equal");
        require(_roundOpen(stage), "Round is not open");
        uint temp = nextBetId;
        for (uint i = 0; i < matchId.length; i++) {
            require(_validBet(msg.sender, stage, matchId[i], winner[i]), "Bet is not valid");
            Bet memory bet = Bet(nextBetId, msg.sender, matchId[i], winner[i], score1[i], score2[i]);
            bets[nextBetId] = bet;
            userBets[msg.sender].push(nextBetId);
            temp++;
            emit BetPlaced(bet.id, stage, bet.user, bet.matchId, bet.winner, bet.score1, bet.score2);
        }
        nextBetId = temp;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";

contract MatchesOracle is Ownable {
    struct Match {
        uint id;
        string team1;
        string team2;
        int8 winner;
        uint8 score1;
        uint8 score2;
        bool ended;
    }
    enum State {
        Pending,
        Open,
        Closed
    }
    enum Stage {
        Group1,
        Group2,
        Group3,
        RoundOf16,
        QuarterFinals,
        SemiFinals,
        Final
    }
    struct Round {
        uint id;
        Stage stage;
        State state;
        uint[] matches;
    }
    mapping(uint => Round) public rounds;
    mapping(uint => Match) public matches;

    function roundExists(uint id) public view returns (bool) {
        require(id > 0, "Round id must be greater than 0");
        return rounds[id].id == id;
    }

    function matchExists(uint roundId, uint matchId) public view returns (bool) {
        if (!roundExists(roundId)) {
            return false;
        }
        Round memory round = rounds[roundId];
        for (uint i = 0; i < round.matches.length; i++) {
            if (round.matches[i] == matchId) {
                return true;
            }
        }
        return false;
    }

    function getRound(uint id) public view returns (Round memory) {
        require(roundExists(id), "Round does not exist");
        return rounds[id];
    }

    function getMatch(uint roundId, uint matchId) public view returns (Match memory) {
        require(matchExists(roundId, matchId), "Match does not exist");
        return matches[matchId];
    }

    function addRound(uint id, Stage stage) public onlyOwner {
        require(!roundExists(id), "Round already exists");
        rounds[id] = Round(id, stage, State.Pending, new uint[](0));
    }

    function addMatch(uint roundId, uint id, string memory team1, string memory team2) public onlyOwner {
        require(roundExists(roundId), "Round does not exist");
        require(!matchExists(roundId, id), "Match already exists");
        rounds[roundId].matches.push(id);
        matches[id] = Match(id, team1, team2, -1, 0, 0, false);
    }

    function setRoundState(uint id, State state) public onlyOwner {
        require(roundExists(id), "Round does not exist");
        rounds[id].state = state;
    }

    function setMatchWinner(uint roundId, uint matchId, int8 winner, uint8 score1, uint8 score2) public onlyOwner {
        require(matchExists(roundId, matchId), "Match does not exist");
        require(rounds[roundId].state == State.Closed, "Round is not closed");
        require(winner >= -1 && winner <= 2, "Invalid winner");
        matches[matchId].winner = winner;
        matches[matchId].score1 = score1;
        matches[matchId].score2 = score2;
        matches[matchId].ended = true;
    }

    function getAddress() public view returns (address) {
        return address(this);
    }

    function checkConnection() public pure returns (bool) {
        return true;
    }
}