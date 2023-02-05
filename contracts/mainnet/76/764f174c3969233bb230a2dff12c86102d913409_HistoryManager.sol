//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./Ownable.sol";

interface IHistory {
    function addData(address user, uint buyIn, address token, uint gameId, uint versionNo) external;
    function setLost(address user, uint gameId) external;
}

contract HistoryManager is Ownable, IHistory {

    struct Game {
        uint256 buyIn;
        address token;
        uint256 gameId;
        uint256 time;
        uint256 versionNo;
        bool lost;
    }
    mapping ( address => Game[] ) public games;
    mapping ( address => mapping ( uint256 => uint256 )) public gameIdToUserNonce;

    address public game;

    function setGame(address newGame) external onlyOwner {
        game = newGame;
    }

    function addData(address user, uint buyIn, address token, uint gameId, uint versionNo) external override {
        require(msg.sender == game, 'Only Game');

        gameIdToUserNonce[user][gameId] = games[user].length;

        games[user].push(Game({
            buyIn: buyIn,
            token: token,
            gameId: gameId,
            time: block.timestamp,
            versionNo: versionNo,
            lost: false
        }));
    }

    function setLost(address user, uint gameId) external override {
        require(msg.sender == game, 'Only Game');

        // fetch ID in user history array to update
        uint nonce = gameIdToUserNonce[user][gameId];
        if (nonce >= games[user].length) {
            return;
        }

        // update lost to true
        games[user][nonce].lost = true;

        // clear useless memory
        delete gameIdToUserNonce[user][gameId];
    }

    function getUserData(address user) external view returns (
        uint256[] memory buyIns,
        address[] memory tokens,
        uint256[] memory gameIds,
        uint256[] memory times,
        uint256[] memory versionNos,
        bool[] memory losts
    ) {

        uint len = games[user].length;
        buyIns = new uint256[](len);
        tokens = new address[](len);
        gameIds = new uint256[](len);
        times = new uint256[](len);
        versionNos = new uint256[](len);
        losts = new bool[](len);

        for (uint i = 0; i < len;) {
            buyIns[i] = games[user][i].buyIn;
            tokens[i] = games[user][i].token;
            gameIds[i] = games[user][i].gameId;
            times[i] = games[user][i].time;
            versionNos[i] = games[user][i].versionNo;
            losts[i] = games[user][i].lost;
            unchecked { ++i; }
        }
    }

    function getUserDataPaginated(address user, uint start, uint end) external view returns (
        uint256[] memory buyIns,
        address[] memory tokens,
        uint256[] memory gameIds,
        uint256[] memory times,
        uint256[] memory versionNos,
        bool[] memory losts
    ) {

        uint len = end - start;
        buyIns = new uint256[](len);
        tokens = new address[](len);
        gameIds = new uint256[](len);
        times = new uint256[](len);
        versionNos = new uint256[](len);
        losts = new bool[](len);

        uint count = 0;

        for (uint i = start; i < end;) {
            buyIns[count] = games[user][i].buyIn;
            tokens[count] = games[user][i].token;
            gameIds[count] = games[user][i].gameId;
            times[count] = games[user][i].time;
            versionNos[count] = games[user][i].versionNo;
            losts[count] = games[user][i].lost;
            unchecked { ++i; ++count; }
        }
    }

}