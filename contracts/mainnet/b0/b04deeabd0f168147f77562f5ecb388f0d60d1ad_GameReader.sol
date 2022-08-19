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


    modifier onlyOwner(){
        require(msg.sender == owner, "Only Owner");
        _;
    }

    function transferOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

}

contract GameReader is Permission {

    IGameData public gameData;

    uint256 public availableSize = 20;

    constructor(IGameData _gameData) {
        owner = msg.sender;
        gameData = _gameData;
    }



    function setAvailableSize(uint256 _newSize) public onlyOwner {
        availableSize = _newSize;
    }


    function changeGameData(IGameData _newData) public onlyOwner {
        gameData = _newData;
    }


    function getAvailableGameIds() public view returns (uint256[] memory){
        return _getFilteredGameIds(true, 0);
    }

    function getGroupGameIds(int256 _groupId) public view returns (uint256[] memory){
        return _getFilteredGameIds(true, _groupId);
    }

    function _getFilteredGameIds(bool _efficient, int256 _groupId) internal view returns (uint256[] memory){
        uint256[] memory availableIds = new uint256[](availableSize);
        uint256 size = 0;
        for (uint i = 0; i < gameData.getGameIds().length; i++) {
            if (size >= availableSize) {
                break;
            }
            IGameData.GameDetail memory game = gameData.getGame(gameData.getGameIds()[i]);
            if (_efficient) {
                if (game.effectEndTime >= block.timestamp) {
                    if (_groupId != 0) {
                        if (_checkInList(_groupId, game.groupIds)) {
                            availableIds[size] = game.id;
                            size++;
                        }
                    } else {
                        availableIds[size] = game.id;
                        size++;
                    }
                }
            } else {
                if (_groupId != 0 && _checkInList(_groupId, game.groupIds)) {
                    availableIds[size] = game.id;
                    size++;
                }
            }
        }
        return availableIds;
    }

    function getNotOverRound(int256 _groupId, uint256 _size) public view returns (IGameData.GameRound[] memory){
        IGameData.GameRound[] memory rounds = new IGameData.GameRound[](_size);
        uint256[] memory availableIds = _getFilteredGameIds(true, _groupId);
        uint256 size = 0;
        for (uint i = 0; i < availableIds.length; i++) {
            if (size >= _size) {
                break;
            }
            IGameData.GameRound[] memory _rounds = gameData.getGameRoundList(availableIds[i]);
            for (uint j = 0; j < _rounds.length; j++) {
                if (size >= _size) {
                    break;
                }
                if (!_rounds[j].over) {
                    rounds[size] = _rounds[j];
                    size++;
                }
            }
        }
        return rounds;
    }

    function _checkInList(int256 _id, int256[] memory _list) internal pure returns (bool){
        bool has = false;
        for (uint i = 0; i < _list.length; i++) {
            if (_list[i] == _id) {
                has = true;
                break;
            }
        }
        return has;
    }


}