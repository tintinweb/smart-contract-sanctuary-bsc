/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "addition overflow");

        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "subtraction overflow");
    }


    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }


    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }


    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IGameData {

    //game
    struct GameDetail {
        uint256 id;
        uint256 category;
        string appId;
        int256[] groupIds;
        uint256 botType;
        string title;
        string introduction;
        string story;

        // v/100
        uint256 eliminateProportion;
        uint256 awardProportion;
        uint256 creatorProportion;
        uint256 sponsorProportion;
        uint256 winnerNum;
        uint256[] buffIds;
        string buffDesc;
        string[] events;
        //ticket
        bool ticketIsEth;
        IERC20 ticketsToken;
        uint256 ticketAmount;
        //option
        uint256 effectStartTime;
        uint256 effectEndTime;
        //option auto start
        bool daily;
        //24H
        uint256 startH;
        uint256 startM;
        bool exist;
        address creator;
        uint256 blockNum;
        uint256 blockTimestamp;
    }


    function setGame(string memory _appId, GameDetail memory _game) external;

    function getGame(uint256 _id) external view returns (GameDetail memory);

    function getGames(uint256[] memory _ids) external view returns (GameDetail[] memory);

    function getAppGames(string memory _appId) external view returns (uint256[] memory);

    function getGameIds() external view returns (uint256[] memory);

    function getPlayers(uint256 _gameId, uint256 _ground) external view returns (address[] memory);

    function setPlayers(uint256 _gameId, uint256 _round, address[] memory _players) external;

    function addPlayer(uint256 _gameId, uint256 _round, address _player) external;

    function getBuffPlayers(uint256 _gameId, uint256 _round) external view returns (uint256[] memory);

    function setBuffPlayers(uint256 _gameId, uint256 _round, uint256[] memory _indexes) external;

    function addBuffPlayers(uint256 _gameId, uint256 _round, uint _index) external;

    function getTicketsPool(uint256 _gameId, uint256 _round) external view returns (uint256);

    function getGameTicket(uint256 _id) external view returns (bool isEth, IERC20 token, uint256 amount);

    //game result
    struct GameRound {
        uint256 gameId;
        uint256 round;
        address[] winners;
        uint256 participate;
        address sponsor;
        uint256 launchTime;
        int256[] eliminatePlayerIndexes;
        int256[] buffUsersIndexes;
        int256[] eventsIndexes;
        bool over;
        bool exist;
    }

    function initGameRound(uint256 _gameId, address _sponsor, uint256 _launchTime) external;

    function editGameRound(uint256 _gameId, uint256 _round, GameRound memory _gameRound) external;

    function getGameRound(uint256 _gameId, uint256 _round) external view returns (GameRound memory);

    function getGameLatestRoundNum(uint256 _gameId) external view returns (int256);

    function getGameRoundList(uint256 _gameId) external view returns (GameRound[] memory);
}


contract Permission {
    address public owner;
    mapping(address => bool) public operators;
    modifier onlyOperator(){
        require(operators[msg.sender], "Only Operator");
        _;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Only Owner");
        _;
    }

    function transferOwner(address _newOwner) public onlyOwner {
        operators[owner] = false;
        owner = _newOwner;
        operators[_newOwner] = true;
    }

    function addOperator(address _newOperator) public onlyOwner {
        operators[_newOperator] = true;
    }

    function delOperator(address _removeOperator) public onlyOwner {
        operators[_removeOperator] = false;
    }

}


contract GameLogic is Permission {

    using SafeMath for uint256;

    IGameData public gameData;

    mapping(uint256 => mapping(uint256 => address[])) private winners;
    mapping(uint256 => mapping(uint256 => int256[])) private  eliminatePlayerIndexes;
    mapping(uint256 => mapping(uint256 => int256[])) private buffUsersIndexes;
    mapping(uint256 => mapping(uint256 => int256[])) private eventsIndexes;
    mapping(uint256 => mapping(uint256 => int256[]))private remainPlayers;

    constructor(IGameData _gameData) {
        gameData = _gameData;
        owner = msg.sender;
        operators[msg.sender] = true;
    }

    function addEliminatePlayer(uint256 _gameId, uint256 _round, int256 _index) public onlyOperator {
        eliminatePlayerIndexes[_gameId][_round].push(_index);
    }

    function getEliminatePlayers(uint256 _gameId, uint256 _round) public view returns (int256[] memory){
        return eliminatePlayerIndexes[_gameId][_round];
    }

    function addEvent(uint256 _gameId, uint256 _round, int256 _index) public onlyOperator {
        eventsIndexes[_gameId][_round].push(_index);
    }

    function getEventsIndexes(uint256 _gameId, uint256 _round) public view returns (int256[] memory){
        return eventsIndexes[_gameId][_round];
    }

    function getbuffUsersIndexes(uint256 _gameId, uint256 _round) public view returns (int256[] memory){
        return eventsIndexes[_gameId][_round];
    }

    function addBufferUserIndex(uint256 _gameId, uint256 _round, int256 _index) public onlyOperator {
        buffUsersIndexes[_gameId][_round].push(_index);
    }


    function triggerBuff(uint256 _gameId, uint256 _round, uint256 _index) public onlyOperator {
        (bool hasIndex,uint256 index) = _checkHasIndex(_index, eliminatePlayerIndexes[_gameId][_round]);
        if (hasIndex) {
            buffUsersIndexes[_gameId][_round].push(int256(_index));
            eliminatePlayerIndexes[_gameId][_round][index] = - 1;
            eventsIndexes[_gameId][_round][index] = - 1;
            remainPlayers[_gameId][_round].push(int256(_index));
        }
    }

    function getWinners(uint256 _gameId, uint256 _round) public view returns (address[] memory){
        return winners[_gameId][_round];
    }


    function eliminatePlayer(uint256 _gameId, uint256 _round, int256 _index) public onlyOperator {
        IGameData.GameDetail memory game = gameData.getGame(_gameId);
        if (_randomNumber(100, game.eliminateProportion) > game.eliminateProportion || remainPlayers[_gameId][_round].length < game.winnerNum) {
            remainPlayers[_gameId][_round].push(_index);
            return;
        }
        eliminatePlayerIndexes[_gameId][_round].push(_index);
        eventsIndexes[_gameId][_round].push(int256(_randomNumber(game.events.length, game.events.length)));
    }


    function calculateResult(uint256 _gameId, uint256 _round) public onlyOperator returns
    (int256[] memory _eliminatePlayerIndexes,
        int256[] memory _buffUserIndexes,
        int256[] memory _eventsIndexes,
        address[] memory _winners){

        IGameData.GameDetail memory game = gameData.getGame(_gameId);
        address[] memory players = gameData.getPlayers(_gameId, _round);

        if (players.length <= game.winnerNum) {
            winners[_gameId][_round] = players;
        } else {
            while (remainPlayers[_gameId][_round].length > game.winnerNum) {
                uint256 eliminateNum = remainPlayers[_gameId][_round].length.mul(game.eliminateProportion).div(100);
                if (eliminateNum == 0) {
                    eliminateNum = 1;
                }
                for (uint i = 0; i < eliminateNum; i++) {
                    uint256 eliminateIndex = _randomNumber(remainPlayers[_gameId][_round].length, eliminateNum);
                    _calculateEliminate(_gameId, _round, eliminateIndex, game.events.length);
                }
            }
            _calculateWinner(_gameId, _round, players);
        }

        return (eliminatePlayerIndexes[_gameId][_round], buffUsersIndexes[_gameId][_round], eventsIndexes[_gameId][_round], winners[_gameId][_round]);
    }

    function _calculateEliminate(uint256 _gameId, uint256 _round, uint256 _eliminateIndex, uint256 _eventLength) internal returns (bool)  {
        bool eliminate = false;
        uint256 playerIndex = uint256(remainPlayers[_gameId][_round][_eliminateIndex]);
        (bool hasIndex,) = _checkHasIndex(playerIndex, buffUsersIndexes[_gameId][_round]);
        if (_checkHasBuff(_gameId, _round, playerIndex) && !hasIndex) {
            buffUsersIndexes[_gameId][_round].push(int256(playerIndex));
            eliminatePlayerIndexes[_gameId][_round].push(- 1);
            eventsIndexes[_gameId][_round].push(- 1);
        } else {
            eliminatePlayerIndexes[_gameId][_round].push(int256(playerIndex));
            eventsIndexes[_gameId][_round].push(int256(_randomNumber(_eventLength, remainPlayers[_gameId][_round].length)));

            (remainPlayers[_gameId][_round][_eliminateIndex], remainPlayers[_gameId][_round][remainPlayers[_gameId][_round].length - 1]) =
            (remainPlayers[_gameId][_round][remainPlayers[_gameId][_round].length - 1], remainPlayers[_gameId][_round][_eliminateIndex]);
            remainPlayers[_gameId][_round].pop();
            eliminate = true;
        }
        return eliminate;
    }

    function _calculateWinner(uint256 _gameId, uint256 _round, address[] memory _players) internal {
        for (uint i = 0; i < remainPlayers[_gameId][_round].length; i++) {
            uint256 index = uint256(remainPlayers[_gameId][_round][i]);
            winners[_gameId][_round].push(_players[index]);
        }
    }


    function _checkHasBuff(uint256 _gameId, uint256 _round, uint256 _index) internal view returns (bool){
        uint256[] memory indexes = gameData.getBuffPlayers(_gameId, _round);
        bool hasBuff = false;
        for (uint i = 0; i < indexes.length; i++) {
            if (indexes[i] == _index) {
                hasBuff = true;
            }
        }
        return hasBuff;
    }

    function _checkHasIndex(uint256 _index, int256[] memory _list) internal pure returns (bool, uint256){
        bool hasIndex = false;
        uint256 index = 0;
        for (uint i = 0; i < _list.length; i++) {
            if (_list[i] == int256(_index)) {
                hasIndex = true;
                index = i;
            }
        }
        return (hasIndex, index);
    }

    function _randomNumber(uint256 _scope, uint256 _salt) internal view returns (uint256) {
        return uint256(keccak256(abi.encode(abi.encodePacked(block.timestamp, block.difficulty), _salt))) % _scope;
    }


}