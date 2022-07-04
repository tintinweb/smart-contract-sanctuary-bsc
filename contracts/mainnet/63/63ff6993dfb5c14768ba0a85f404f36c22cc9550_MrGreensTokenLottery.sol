/**
 *Submitted for verification at BscScan.com on 2022-07-04
*/

// Code written by MrGreenCrypto
// SPDX-License-Identifier: None

pragma solidity 0.8.15;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface VRFCoordinatorV2Interface {
    function getRequestConfig()
        external
        view
        returns (
            uint16,
            uint32,
            bytes32[] memory
        );
    function requestRandomWords(
        bytes32 keyHash,
        uint64 subId,
        uint16 minimumRequestConfirmations,
        uint32 callbackGasLimit,
        uint32 numWords
    ) external returns (uint256 requestId);
    function createSubscription() external returns (uint64 subId);
    function getSubscription(uint64 subId)
        external
        view
        returns (
            uint96 balance,
            uint64 reqCount,
            address owner,
            address[] memory consumers
    );
    function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;
    function acceptSubscriptionOwnerTransfer(uint64 subId) external;
    function addConsumer(uint64 subId, address consumer) external;
    function removeConsumer(uint64 subId, address consumer) external;
    function cancelSubscription(uint64 subId, address to) external;
}

contract MrGreensTokenLottery {
    
    struct Play {
        address player;
        address token;
        uint256 amount;
        uint256 gameID;
    }

    Play[] public plays;

    mapping (address => bool) internal playingAGame;
    mapping (address => uint256) public rtpPerToken;
    mapping (address => uint256) public maxBetPerToken;
    mapping (address => uint256) public minBetPerToken;
    mapping (uint256 => uint256) internal indexOfGameID;
    mapping (address => uint256) internal tokenDecimals;

    address private constant CEO = 0xe6497e1F2C5418978D5fC2cD32AA23315E7a41Fb;

    VRFCoordinatorV2Interface COORDINATOR = VRFCoordinatorV2Interface(0xc587d9053cd1118f25F645F9E08BB98c9712A4EE);
    uint64 s_subscriptionId = 184;
    address vrfCoordinator = 0xc587d9053cd1118f25F645F9E08BB98c9712A4EE;
    bytes32 keyHash = 0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04;
    uint32 callbackGasLimit = 200000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;
    uint256 s_requestId;

    event ResultsAreIn(address token, address winnerAddress, uint256 amountBet, uint256 amountWon);
    event PlayerPlayed(address token, address playerAddress, uint256 amount);

    modifier onlyOwner() {if(msg.sender != CEO) return; _;}
    constructor() {}

    receive() external payable {}
    
/////////////////// THE GAMBLE ///////////////////////////////////////////////////////////////////////

    function checkPoolOfToken(address token) public view returns (uint256) {
        return IBEP20(token).balanceOf(address(this));
    }

    function startGame(address player, address token, uint256 amount) internal {
        Play memory currentPlay;
        currentPlay.player = player;
        currentPlay.token = token;
        currentPlay.amount = amount;
        currentPlay.gameID = requestRandomWords();
        
        indexOfGameID[currentPlay.gameID] = plays.length;

        playingAGame[player] = true;
        plays.push(currentPlay);
    }


    function PlayTheGame(address token, uint256 amount) external {
        
        require(checkPoolOfToken(token) > 2 * amount * (10 ** tokenDecimals[token]), "Pool doesn't have enough token");
        require(maxBetPerToken[token] >= amount, "Can't bet that much, please respect maxBet of the token");
        require(minBetPerToken[token] <= amount, "Can't bet that little, please respect minBet of the token");
        require(!playingAGame[msg.sender], "Please wait for the result of your last game");

        IBEP20(token).transferFrom(msg.sender, address(this), amount * (10**tokenDecimals[token]));

        startGame(msg.sender, token, amount);

        emit PlayerPlayed(token, msg.sender, amount);
    }

    function payTheWinner(uint256 requestId,uint256[] memory randomWords) internal {
        Play memory gameToDecide = plays[indexOfGameID[requestId]];

        bool didThePlayerWin = randomWords[0] % 1000 > 1000 - (rtpPerToken[gameToDecide.token] * 5);

        if(didThePlayerWin) {
            IBEP20(gameToDecide.token).transfer(gameToDecide.player, gameToDecide.amount * 2 * (10**tokenDecimals[gameToDecide.token]));
            emit ResultsAreIn(gameToDecide.token, gameToDecide.player, gameToDecide.amount, gameToDecide.amount * 2);
        } else{
            emit ResultsAreIn(gameToDecide.token, gameToDecide.player, gameToDecide.amount, 0);
        }
        playingAGame[gameToDecide.player] = false;
    }


/////////////////// ADMIN FUNCTIONS ///////////////////////////////////////////////////////////////////////
    function addTokenToLottery(address token, uint256 poolAmount, uint256 rtp, uint256 minBet, uint256 maxBet) external {
        require(rtp >= 90, "RTP has to be higher than 90");
        require(poolAmount > 10 * maxBet, "Minimum deposit is 10x maxBet");
        maxBetPerToken[token] = maxBet;
        minBetPerToken[token] = minBet;
        rtpPerToken[token] = rtp;
        tokenDecimals[token] = IBEP20(token).decimals();
        IBEP20(token).transferFrom(msg.sender, address(this), poolAmount * (10**tokenDecimals[token]));
    }
    
    function rescueToken(address token) external onlyOwner {
        IBEP20(token).transfer(CEO, IBEP20(token).balanceOf(address(this)));    
    }

    function rescueBNB() external onlyOwner {
        payable(CEO).transfer(address(this).balance);
    }

////////////////////////////////ChainLink Section ///////////////////////////
    function requestRandomWords() internal returns (uint256) {
        s_requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        return s_requestId;
    }   

    error OnlyCoordinatorCanFulfill(address have, address want);

    function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
        if (msg.sender != vrfCoordinator) revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
        payTheWinner(requestId, randomWords);
    }
    
}