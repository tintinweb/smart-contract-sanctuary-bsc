//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./IVRF.sol";
import "./Ownable.sol";
import "./Address.sol";

interface IFeeRecipient {
    function trigger(address token, uint256 ref) external;
}

interface IVRFCoordinatorV2 is VRFCoordinatorV2Interface {
    function getFeeConfig()
        external
        view
        returns (
            uint32 fulfillmentFlatFeeLinkPPMTier1,
            uint32 fulfillmentFlatFeeLinkPPMTier2,
            uint32 fulfillmentFlatFeeLinkPPMTier3,
            uint32 fulfillmentFlatFeeLinkPPMTier4,
            uint32 fulfillmentFlatFeeLinkPPMTier5,
            uint24 reqsForTier2,
            uint24 reqsForTier3,
            uint24 reqsForTier4,
            uint24 reqsForTier5
        );
}

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}

// History Manager Interface
interface IHistory {
    function addData(address user, uint buyIn, address token, uint gameId, uint versionNo) external;
    function setLost(address user, uint gameId) external;
}

/**
    Russian Roullete Game
 */
contract RussianRoulette is Ownable, VRFConsumerBaseV2 {

    // History Manager
    IHistory public constant history = IHistory(0x764F174c3969233Bb230a2dFF12c86102D913409);

    // Version Number
    uint256 public immutable versionNo;

    // VRF Coordinator
    IVRFCoordinatorV2 private COORDINATOR;

    // Your subscription ID.
    uint64 private s_subscriptionId;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    bytes32 private keyHash;

    // Table Structure
    struct Table {
        address token;
        uint256 buyIn;
        uint32 max_players;
        uint32 duration;
        uint32 gasToCallRandom;
        uint256 gameID;
    }

    // Game Structure
    struct Game {
        bool hasEnded;
        uint256 tableId;
        address[] players;
        address loser;
        uint256 pot;
        uint256 startTime;
        uint256 requestTime;
        uint256 request;
    }

    // Token Structure
    struct Token {
        bool isApproved;
        uint256 fee;
        address feeRecipient;
    }

    // mapping from tableID => Table
    mapping ( uint256 => Table ) public tables;

    // mapping from GameID => Game
    mapping ( uint256 => Game ) public games;

    // request ID => GameID
    mapping ( uint256 => uint256 ) private requestToGame;

    // Token => Token Structure
    mapping ( address => Token ) public tokens;

    // Table Nonce
    uint256 public tableNonce = 1;

    // Game Nonce
    uint256 public gameNonce = 1;

    // Fee Recipient
    address public feeRecipient;

    // Fees
    uint256 public platformFee = 25;

    /// @notice number of blocks until a re-request of the random number is allowed
    uint256 public RE_REQUEST_TIME = 6_000;

    /** Minimum Amount of BNB That Must Be Attached To A Join For Gas */
    uint256 public minBuyInGas = 0.001 ether;

    /** Recipient of Chainlink fees charged */
    address public chainlinkFeesRecipient;

    /** Fee Denominator */
    uint256 private constant FEE_DENOM = 1000;

    // Valid Table
    modifier isValidTable(uint256 tableId) {
        require(
            tableId > 0 && tableId < tableNonce,
            'Table Not Valid'
        );
        _;
    }

    // Events
    event TableCreated(
        uint256 newTableId,
        address token,
        uint256 buyIn,
        uint32 max_palyers,
        uint32 duration,
        uint32 gasToCallRandom
    );

    /// @notice emitted after a game has been started at a specific table
    event GameStarted(uint256 tableId, uint256 gameId);

    /// @notice Emitted after the VRF comes back with the index of the losing player
    event GameEnded(uint256 tableId, uint256 gameId, address loser);

    constructor(
        uint256 versionNo_
    ) VRFConsumerBaseV2(0xc587d9053cd1118f25F645F9E08BB98c9712A4EE) {
        // setup chainlink
        keyHash = 0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04;
        COORDINATOR = IVRFCoordinatorV2(0xc587d9053cd1118f25F645F9E08BB98c9712A4EE);
        s_subscriptionId = 702;
        chainlinkFeesRecipient = msg.sender;
        feeRecipient = 0x3aaEDc223c2Ac151a322f4eC79f4A02CD55189E4;
        versionNo = versionNo_;
    }

    //////////////////////////////////////
    ///////    OWNER FUNCTIONS    ////////
    //////////////////////////////////////

    function createTable(
        address token,
        uint256 buyIn,
        uint32 max_players,
        uint32 duration,
        uint32 gasToCallRandom
    ) external onlyOwner {
        
        // initialize table
        tables[tableNonce] = Table({
            token: token,
            buyIn: buyIn,
            max_players: max_players,
            duration: duration,
            gasToCallRandom: gasToCallRandom,
            gameID: 0
        });

        // emit event
        emit TableCreated(tableNonce, token, buyIn, max_players, duration, gasToCallRandom);

        // increment table nonce
        tableNonce++;
    }

    function setToken(uint256 tableId, address token) external onlyOwner isValidTable(tableId) {
        tables[tableId].token = token;
    }

    function setBuyIn(uint256 tableId, uint256 newBuyIn) external onlyOwner isValidTable(tableId) {
        tables[tableId].buyIn = newBuyIn;
    }

    function setMaxPlayers(uint256 tableId, uint32 maxPlayers) external onlyOwner isValidTable(tableId) {
        tables[tableId].max_players = maxPlayers;
    }

    function setDuration(uint256 tableId, uint32 duration) external onlyOwner isValidTable(tableId) {
        tables[tableId].duration = duration;
    }

    function setGasToCallRandom(uint256 tableId, uint32 newGas) external onlyOwner isValidTable(tableId) {
        tables[tableId].gasToCallRandom = newGas;
    }

    function setReRequestTime(uint256 newTime) external onlyOwner {
        RE_REQUEST_TIME = newTime;
    }

    function setMinBuyInGas(uint256 weiValue) external onlyOwner {
        minBuyInGas = weiValue;
    }

    function setChainlinkFeesRecipient(address newChainlinkFeesRecipient) external onlyOwner {
        chainlinkFeesRecipient = newChainlinkFeesRecipient;
    }

    function removeTable(uint256 tableId) external onlyOwner {
        require(
            tables[tableId].gameID == 0,
            'Game In Progress'
        );
        delete tables[tableId];
    }

    function setFeeRecipient(address newRecipient) external onlyOwner {
        feeRecipient = newRecipient;
    }

    function setSubscriptionID(uint64 subscriptionID) external onlyOwner {
        s_subscriptionId = subscriptionID;
    }

    function setKeyHash(bytes32 newHash) external onlyOwner {
        keyHash = newHash;
    }

    function withdrawETH(uint256 amount) external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: amount}("");
        require(s);
    }

    function withdrawToken(address token, uint amount) external onlyOwner {
        TransferHelper.safeTransfer(token, msg.sender, amount);
    }

    function setTokenFee(address token, uint256 newFee) external onlyOwner {
        require(
            newFee < 250,
            'Fee Too High'
        );
        tokens[token].fee = newFee;
    }

    function setTokenFeeRecipient(address token, address newRecipient) external onlyOwner {
        require(
            newRecipient != address(0), 'Zero Address'
        );
        tokens[token].feeRecipient = newRecipient;
    }

    function setPlatformFee(uint newFee) external onlyOwner {
        require(newFee < FEE_DENOM, 'Fee Out Of Bounds');
        platformFee = newFee;
    }

    //////////////////////////////////////
    ///////   Public FUNCTIONS    ////////
    //////////////////////////////////////

    function joinGame(uint256 tableId, uint256 ref) external payable isValidTable(tableId) {

        // if first join, start the game
        if (tables[tableId].gameID == 0) {
            _startGame(tableId);
        }

        // join game
        uint256 gameId = _joinGame(tableId, ref);

        // if two players are in the game, start the timer
        if (games[gameId].players.length == 2) {
            games[gameId].startTime = block.number;
        }

        // if max players is reached, end game early
        if (games[gameId].players.length >= tables[tableId].max_players) {
            _endGame(tableId);
        }
    }

    function endGame(uint256 tableId) external isValidTable(tableId) {
        require(
            tables[tableId].gameID > 0,
            'No Game'
        );
        require(
            timeLeftInGame(tableId) == 0,
            'Game In Progress'
        );

        // end game
        _endGame(tableId);
    }

    function refundGame(uint256 tableId) external isValidTable(tableId) {

        uint256 gameID = tables[tableId].gameID;
        require(
            gameID > 0,
            'No Game'
        );
        require(
            games[gameID].players.length == 1,
            'Must Have Only 1 Player'
        );
        require(
            msg.sender == games[gameID].players[0],
            'Only Sole Player Can Destroy'
        );

        // toggle has ended to true
        games[gameID].hasEnded = true;

        // clear storage
        delete tables[games[gameID].tableId].gameID; // allow new game to start

        // send value back to user
        _send(
            tables[games[gameID].tableId].token,
            games[gameID].players[0],
            games[gameID].pot
        );
    }

    function donateToGamePot(uint256 tableId, uint256 amount) external payable isValidTable(tableId) {
        
        uint256 gameID = tables[tableId].gameID;
        require(
            gameID > 0,
            'No Game'
        );

        // put forth payment
        uint256 received = tables[tableId].token == address(0) ? msg.value : _transferIn(tables[tableId].token, amount);
        require(
            received > 0,
            'ERR Received'
        );
        
        // increment pot by amount received
        unchecked {
            games[gameID].pot += received;
        }
    }

    function reRequestWords(uint256 tableId) external {
        uint256 gameId = tables[tableId].gameID;
        require(
            gameId > 0,
            'No Game'
        );
        require(
            games[gameId].hasEnded == true,
            'Game Not Ended'
        );
        require(
            timeToRerequest(gameId) == 0,
            'Not Time To Re Request'
        );

        // delete any previous request for gameId to prevent double spending
        delete requestToGame[games[gameId].request];

        // request new random word
        _requestRandom(gameId);
    }


    //////////////////////////////////////
    ///////   INTERNAL FUNCTIONS  ////////
    //////////////////////////////////////

    function _startGame(uint256 tableId) internal {

        // set table stats
        tables[tableId].gameID = gameNonce;

        // set game stats
        games[gameNonce].tableId = tableId;
        
        // emit event
        emit GameStarted(tableId, gameNonce);

        // increment game nonce
        unchecked {
            gameNonce++;
        }
    }

    function _endGame(uint256 tableId) internal {
        require(
            games[tables[tableId].gameID].hasEnded == false,
            'Game Already Ended'
        );
        require(
            games[tables[tableId].gameID].players.length >= 2,
            'Must Have At Least 2 Players'
        );

        // toggle has ended to true
        games[tables[tableId].gameID].hasEnded = true;

        // request random words for game
        _requestRandom(tables[tableId].gameID);
    }

    function _joinGame(uint256 tableId, uint256 ref) internal returns (uint256) {

        // ensure no contract joins so they cannot mess with the receive() function
        require(
            Address.isContract(msg.sender) == false,
            'Contracts Can Not Partake'
        );

        // current game ID
        uint256 gameId = tables[tableId].gameID;

        // ensure state allows for new game
        require(
            gameId > 0,
            'No Game'
        );
        require(
            games[tables[tableId].gameID].hasEnded == false,
            'Game Already Ended'
        );
        require(
            games[gameId].players.length < tables[tableId].max_players,
            'Max Players Entered'
        );

        // put forth payment
        uint256 received;

        if (tables[tableId].token == address(0)) {

            // ensure buy in requirement is met
            require(
                msg.value >= tables[tableId].buyIn,
                'Invalid Buy In'
            );

            // set received to be msg.value -- allows for extra value to be added if desired
            received = tables[tableId].buyIn;
        } else {

            // note amount received from transfer
            received = _transferIn(tables[tableId].token, tables[tableId].buyIn);            
        }
        require(
            received > 0,
            'ERR Received'
        );

        // Calculate VRF Cost Fee
        uint256 fee = tables[tableId].token == address(0) ? msg.value - tables[tableId].buyIn : msg.value;
        require(
            fee >= minBuyInGas,
            'MIN BUY IN GAS AID REQUIRED'
        );

        // send fee to fee recipient
        _send(address(0), chainlinkFeesRecipient, fee);
        
        // take fee out of amount received
        uint256 potValue = _takeFee(tables[tableId].token, received, ref);

        // increment pot by amount received
        unchecked {
            games[gameId].pot += potValue;
        }

        // add player
        games[gameId].players.push(msg.sender);

        // add to players history
        history.addData(msg.sender, tables[tableId].buyIn, tables[tableId].token, gameId, versionNo);

        return gameId;
    }

    function _takeFee(address token, uint256 amount, uint256 ref) internal returns (uint256) {

        // divvy up fees
        uint256 fee = ( amount * tokens[token].fee ) / FEE_DENOM;
        uint256 platform = ( amount * platformFee ) / FEE_DENOM;

        // send fees to sources
        _send(token, tokens[token].feeRecipient, fee);
        _send(token, feeRecipient, platform);

        // Fee Recipient
        IFeeRecipient(feeRecipient).trigger(token, ref);

        // return amount less fees
        return amount - ( fee + platform );
    }

    function _transferIn(address token, uint256 amount) internal returns (uint256) {
        require(
            IERC20(token).allowance(msg.sender, address(this)) >= amount,
            'Insufficient Allowance'
        );
        require(
            IERC20(token).balanceOf(msg.sender) >= amount,
            'Insufficient Balance'
        );
        uint256 before = IERC20(token).balanceOf(address(this));
        TransferHelper.safeTransferFrom(token, msg.sender, address(this), amount);
        uint256 After = IERC20(token).balanceOf(address(this));
        require(
            After > before,
            'Zero Received'
        );
        return After - before;
    }

    function _requestRandom(uint256 gameId) internal {

        // fetch required gas limit from game
        uint32 gasToCallRandom = tables[games[gameId].tableId].gasToCallRandom;
        if (gasToCallRandom == 0) {
            return;
        }

        // get random number and send rewards when callback is executed
        // the callback is called "fulfillRandomWords"
        // this will revert if VRF subscription is not set and funded.
        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            3, // number of block confirmations before returning random value
            gasToCallRandom, // callback gas limit is dependent num of random values & gas used in callback
            1 // the number of random results to return
        );

        // map this request ID to the game it belongs to
        requestToGame[requestId] = gameId;

        // set the request time in case of fulfill error
        games[gameId].requestTime = block.number;

        // save requestId incase we need to re-request, avoids double spending
        games[gameId].request = requestId;
    }

    /**
        Chainlink's callback to provide us with randomness
     */
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {

        // get table ID
        uint256 gameId = requestToGame[requestId];
        
        // if faulty ID, remove
        if (gameId == 0) {
            return;
        }

        // clear storage
        delete requestToGame[requestId];
        delete tables[games[gameId].tableId].gameID; // allow new game to start

        // process random word for table
        uint nPlayers = games[gameId].players.length;
        if (nPlayers > 0) {

            // select loser out of array
            address loser = games[gameId].players[randomWords[0] % nPlayers];
            games[gameId].loser = loser;

            // set loser in history manager
            history.setLost(loser, gameId);

            // divvy up pot to remaining players
            uint nPlayersToSplit = nPlayers - 1;
            if (nPlayersToSplit == 0) {
                // only one player, send tokens to loser -- should never happen, but just in case
                _send(tables[games[gameId].tableId].token, loser, games[gameId].pot);
            } else {

                // amount for each winner
                uint potValueForEachWinner = ( games[gameId].pot / nPlayersToSplit );

                // skip loser only once in case they bet multiple times
                bool skippedLoser = false;

                // loop through players, paying each out their share
                for (uint i = 0; i < nPlayers;) {
                    if (games[gameId].players[i] == loser && skippedLoser == false) {
                        skippedLoser = true;
                    } else {
                        _send(
                            tables[games[gameId].tableId].token,
                            games[gameId].players[i],
                            potValueForEachWinner
                        );
                    }
                    unchecked { ++i; }
                }

            }
            
            // Emit Game Ended Event
            emit GameEnded(games[gameId].tableId, gameId, loser);
        } 
    }

    function _send(address token, address to, uint amount) internal {
        if (to == address(0) || amount == 0) {
            return;
        }

        if (token == address(0)) {
            (bool s,) = payable(to).call{value: amount}("");
            require(s);
        } else {
            TransferHelper.safeTransfer(token, to, amount);
        }
    }

    //////////////////////////////////////
    ///////     READ FUNCTIONS    ////////
    //////////////////////////////////////

    function getPlayersForTable(uint256 tableId) public view returns (address[] memory) {
        return getPlayersForGame(tables[tableId].gameID);
    }

    function getPlayersForGame(uint256 gameId) public view returns (address[] memory) {
        return games[gameId].players;
    }

    function isPlayerInTable(uint256 tableId, address player) public view returns (bool) {
        return isPlayerInGame(tables[tableId].gameID, player);
    }

    function isPlayerInGame(uint256 gameId, address player) public view returns (bool) {
        for (uint i = 0; i < games[gameId].players.length; i++) {
            if (games[gameId].players[i] == player) {
                return true;
            }
        }
        return false;
    }

    function getLoserForGame(uint256 gameId) public view returns (address) {
        return games[gameId].loser;
    }

    function timeToRerequest(uint256 gameId) public view returns (uint256) {
        uint endTime = games[gameId].requestTime + RE_REQUEST_TIME;
        return endTime <= block.number ? 0 : endTime - block.number;
    }

    function tokenBalance(address token) public view returns (uint256) {
        return token == address(0) ? address(this).balance : IERC20(token).balanceOf(address(this));
    }

    function getTableInfo(uint256 tableId) public view returns (
        address token,
        uint256 buyIn,
        uint32 max_players,
        uint32 duration,
        uint32 gasToCallRandom,
        uint256 gameID
    ) {
        token = tables[tableId].token;
        buyIn = tables[tableId].buyIn;
        max_players = tables[tableId].max_players;
        duration = tables[tableId].duration;
        gasToCallRandom = tables[tableId].gasToCallRandom;
        gameID = tables[tableId].gameID;
        
    }

    function listTableInfo() external view returns (
        address[] memory gameTokens,
        uint256[] memory buyIns,
        uint32[] memory max_playerss,
        uint32[] memory durations,
        uint32[] memory gasToCallRandoms,
        uint256[] memory gameIDs
    ) {
        
        gameTokens = new address[](tableNonce - 1);
        buyIns = new uint256[](tableNonce - 1);
        max_playerss = new uint32[](tableNonce - 1);
        durations = new uint32[](tableNonce - 1);
        gasToCallRandoms = new uint32[](tableNonce - 1);
        gameIDs = new uint256[](tableNonce - 1);

        for (uint i = 1; i < tableNonce;) {
            (
                gameTokens[i-1],
                buyIns[i-1],
                max_playerss[i-1],
                durations[i-1],
                gasToCallRandoms[i-1],
                gameIDs[i-1]
            ) = getTableInfo(i);
            unchecked { ++i; }
        }
    }

    function listGameIDs() external view returns (
        uint256[] memory gameIDs
    ) {
        gameIDs = new uint256[](tableNonce - 1);
        for (uint i = 1; i < tableNonce;) {
            gameIDs[i-1] = tables[i].gameID;
            unchecked { ++i; }
        }
    }

    function listTableAndGamesInfo() external view returns (
        address[] memory gameTokens,
        uint256[] memory buyIns,
        uint32[] memory max_playerss,
        uint32[] memory durations,
        uint256[] memory numberOfPlayers,
        uint256[] memory pots,
        uint256[] memory gameIDs,
        uint256[] memory startTimes
    ) {
        
        gameTokens = new address[](tableNonce - 1);
        buyIns = new uint256[](tableNonce - 1);
        max_playerss = new uint32[](tableNonce - 1);
        durations = new uint32[](tableNonce - 1);
        numberOfPlayers = new uint256[](tableNonce - 1);
        pots = new uint256[](tableNonce - 1);
        gameIDs = new uint256[](tableNonce - 1);
        startTimes = new uint256[](tableNonce - 1);
        uint gameId;

        for (uint i = 1; i < tableNonce;) {
            (
                gameTokens[i - 1],
                buyIns[i - 1],
                max_playerss[i - 1],
                durations[i - 1],
                ,
                gameId
            ) = getTableInfo(i);
            numberOfPlayers[i - 1] = games[gameId].players.length;
            pots[i - 1] = games[gameId].pot;
            gameIDs[i - 1] = gameId;
            startTimes[i - 1] = games[gameId].startTime;
            unchecked { ++i; }
        }
    }

    function getGameInfo(uint256 gameId) external view returns(
        bool gameEnded,
        uint256 tableId,
        address[] memory players,
        address loser,
        uint256 pot,
        uint256 startTime
    ) {
        gameEnded = games[gameId].hasEnded;
        tableId = games[gameId].tableId;
        players = games[gameId].players;
        loser = games[gameId].loser;
        pot = games[gameId].pot;
        startTime = games[gameId].startTime;
    }

    function timeLeftInGame(uint256 tableId) public view returns (uint256) {
        if (tables[tableId].gameID == 0) {
            return 0;
        }
        if (games[tables[tableId].gameID].startTime == 0) {
            return type(uint256).max;
        }
        uint endTime = tables[tableId].duration + games[tables[tableId].gameID].startTime;
        return endTime > block.number ? endTime - block.number : 0;
    }
}