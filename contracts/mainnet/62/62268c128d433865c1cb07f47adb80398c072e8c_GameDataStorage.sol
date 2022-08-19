/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


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


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
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


contract GameDataStorage is Permission {
    using SafeMath for uint256;

    constructor() {
        owner = msg.sender;
        addOperator(msg.sender);
    }

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

    mapping(uint256 => GameDetail) private games;
    mapping(string => uint256[]) private appGames;
    mapping(uint256 => mapping(uint256 => uint256[])) private buffPlayerIndexes;
    mapping(uint256 => mapping(uint256 => address[])) private players;
    mapping(uint256 => mapping(uint256 => uint256)) private ticketsPoll;

    uint256[] private gameIds;

    function setGame(string memory _appId, GameDetail memory _game) public onlyOperator {
        if (!games[_game.id].exist) {
            appGames[_appId].push(_game.id);
            gameIds.push(_game.id);
        }
        _game.blockNum = block.number;
        _game.blockTimestamp = block.timestamp;
        games[_game.id] = _game;

    }

    function getGame(uint256 _id) public view returns (GameDetail memory) {
        return games[_id];
    }

    function getGames(uint256[] memory _ids) public view returns (GameDetail[] memory) {
        GameDetail[] memory details = new GameDetail[](_ids.length);
        for (uint i = 0; i < _ids.length; i++) {
            details[i] = games[_ids[i]];
        }
        return details;
    }


    function getAppGames(string memory _appId) public view returns (uint256[] memory){
        return appGames[_appId];
    }

    function getGameIds() public view returns (uint256[] memory){
        return gameIds;
    }

    function getPlayers(uint256 _gameId, uint256 _ground) public view returns (address[] memory){
        return players[_gameId][_ground];
    }

    function setPlayers(uint256 _gameId, uint256 _round, address[] memory _players) public onlyOperator {

        for (uint i = 0; i < _players.length; i++) {
            players[_gameId][_round].push(_players[i]);
            ticketsPoll[_gameId][_round] = ticketsPoll[_gameId][_round].add(games[_gameId].ticketAmount);
        }
        if (players[_gameId][_round].length == 0) {
            players[_gameId][_round] = _players;
        } else {
            for (uint i = 0; i < _players.length; i++) {
                players[_gameId][_round].push(_players[i]);
            }
        }
    }

    function addPlayer(uint256 _gameId, uint256 _round, address _player) public onlyOperator {
        players[_gameId][_round].push(_player);
        ticketsPoll[_gameId][_round] = ticketsPoll[_gameId][_round].add(games[_gameId].ticketAmount);
    }

    function getBuffPlayers(uint256 _gameId, uint256 _round) public view returns (uint256[] memory){
        return buffPlayerIndexes[_gameId][_round];
    }

    function setBuffPlayers(uint256 _gameId, uint256 _round, uint256[] memory _indexes) public onlyOperator {
        if (buffPlayerIndexes[_gameId][_round].length == 0) {
            buffPlayerIndexes[_gameId][_round] = _indexes;
        } else {
            for (uint i = 0; i < _indexes.length; i++) {
                buffPlayerIndexes[_gameId][_round].push(_indexes[i]);
            }
        }
    }

    function addBuffPlayers(uint256 _gameId, uint256 _round, uint _index) public onlyOperator {
        buffPlayerIndexes[_gameId][_round].push(_index);
    }

    function getTicketsPool(uint256 _gameId, uint256 _round) public view returns (uint256){
        return ticketsPoll[_gameId][_round];
    }




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

    mapping(uint256 => GameRound[]) private gameRoundList;


    function initGameRound(uint256 _gameId, address _sponsor, uint256 _launchTime) public onlyOperator {
        if (games[_gameId].exist) {
            GameRound memory gameRound = GameRound(
                _gameId,
                gameRoundList[_gameId].length,
                new address[](0),
                0,
                _sponsor,
                _launchTime,
                new int256[](0),
                new int256[](0),
                new int256[](0),
                false,
                true
            );
            gameRoundList[_gameId].push(gameRound);
        }
    }

    function editGameRound(uint256 _gameId, uint256 _round, GameRound memory _gameRound) public onlyOperator {
        gameRoundList[_gameId][_round] = _gameRound;
    }

    function getGameRound(uint256 _gameId, uint256 _round) public view returns (GameRound memory){
        GameRound memory gameRound = GameRound(
            0,
            0,
            new address[](0),
            0,
            address(0),
            0,
            new int256[](0),
            new int256[](0),
            new int256[](0),
            false,
            false
        );

        if (gameRoundList[_gameId].length == 0) {
            return gameRound;
        }

        if (gameRoundList[_gameId].length.sub(1) < _round) {
            return gameRound;
        }

        return gameRoundList[_gameId][_round];
    }

    function getGameLatestRoundNum(uint256 _gameId) public view returns (int256){
        if (gameRoundList[_gameId].length > 0) {
            return int256(gameRoundList[_gameId].length.sub(1));
        } else {
            return - 1;
        }
    }

    function getGameRoundList(uint256 _gameId) public view returns (GameRound[] memory){
        return gameRoundList[_gameId];
    }


    function getGameAndRound(uint256 _gameId) public view returns (GameDetail memory detail, GameRound[] memory gameRounds){
        return (games[_gameId], gameRoundList[_gameId]);
    }
}