/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

// BIRB Token Lottery - Now with BNB jackpot!

// Check BIRB news here: https://t.me/BirbDefi

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

interface ICCVRF {
    function requestRandomness(uint256 requestID, uint256 howManyNumbers) external payable;
}

contract BIRBLottery {
    struct Play {
        address player;
        uint256 amount;
        uint256 gameID;
    }

    struct Jackpot {
        uint256 amount;
        uint256 chance;
    }
    
    Jackpot[] public jackpots;
    Play[] public plays;

    mapping (uint256 => uint256) internal indexOfGameID;
    mapping (address => bool) internal playingAGame;
    
    uint256 private rtp;
    uint256 public maxBet;
    uint256 public minBet;
    uint256 internal tokenDecimals;
    address private constant CEO = 0x76D421603173e907849bb7Baf15D90ca625C80d1;
    address private constant MRGREEN = 0xe6497e1F2C5418978D5fC2cD32AA23315E7a41Fb;
    address public constant BIRB = 0x88888888Fc33e4ECba8958c0c2AD361089E19885;

    ICCVRF public randomnessSupplier = ICCVRF(0xC0de0aB6E25cc34FB26dE4617313ca559f78C0dE);
    uint256 public totalPlays;
    uint256 public vrfCost = 0.001 ether;

    event ResultsAreIn(address winnerAddress, uint256 amountBet, bool tokenWinner, uint256 bnbWon);

    modifier onlyOwner() {if(msg.sender != CEO) return; _;}
    modifier onlyVRF() {if(msg.sender != address(randomnessSupplier)) return; _;}

    constructor() {}
    receive() external payable {}

    function checkPoolOfToken(address token) public view returns (uint256) {
        return IBEP20(token).balanceOf(address(this)) / tokenDecimals;
    }

    function startGame(address player, uint256 amount) internal {
        Play memory currentPlay;
        currentPlay.player = player;
        currentPlay.amount = amount;
        currentPlay.gameID = totalPlays;
        randomnessSupplier.requestRandomness{value: vrfCost}(totalPlays, jackpots.length + 1);
        totalPlays++;
        playingAGame[player] = true;
        plays.push(currentPlay);
    }

    function PlayTheGame(uint256 amount) external payable {
        require(msg.value >= vrfCost, "Randomness has a price!");
        require(checkPoolOfToken(BIRB) > 2 * amount, "Pool doesn't have enough token");
        require(maxBet >= amount, "Can't bet that much, please respect maxBet of the token");
        require(minBet <= amount, "Can't bet that little, please respect minBet of the token");
        require(!playingAGame[msg.sender], "Please wait for the result of your last game");
        IBEP20(BIRB).transferFrom(msg.sender, address(this), amount * (10**tokenDecimals));
        startGame(msg.sender, amount);
    }

    function supplyRandomness(uint256 gameID,uint256[] memory randomNumbers) external onlyVRF {
        Play memory gameToDecide = plays[gameID];
        bool didThePlayerWin = randomNumbers[0] % 1000 > 1000 - (rtp * 5);
        uint256 bnbPrize;
        for (uint256 i = 0; i < jackpots.length; i++) if(randomNumbers[i+1] % jackpots[i].chance == 0) bnbPrize += jackpots[i].amount;
        if(bnbPrize > 0) payable(gameToDecide.player).transfer(bnbPrize);
        if(didThePlayerWin) IBEP20(BIRB).transfer(gameToDecide.player, gameToDecide.amount * 2 * (10**tokenDecimals));
        emit ResultsAreIn(gameToDecide.player, gameToDecide.amount, didThePlayerWin, bnbPrize);
        playingAGame[gameToDecide.player] = false;
    }

    function addTokenToLottery(uint256 poolAmount, uint256 _rtp, uint256 _minBet, uint256 _maxBet) external onlyOwner {
        maxBet = _maxBet;
        minBet = _minBet;
        rtp = _rtp;
        tokenDecimals = IBEP20(BIRB).decimals();
        IBEP20(BIRB).transferFrom(msg.sender, address(this), poolAmount * (10**tokenDecimals));
    }

    function changeLotteryStats(uint256 _rtp, uint256 _minBet, uint256 _maxBet) external onlyOwner {
        maxBet = _maxBet;
        minBet = _minBet;
        rtp = _rtp;
    }

    function addBnbJackpot(uint256 amount, uint256 chance) external onlyOwner {
        Jackpot memory newJackpot;
        newJackpot.amount = amount;
        newJackpot.chance = chance;
        jackpots.push(newJackpot);
    }

    function resetBNBJackpotList() external onlyOwner{
        delete jackpots;
    }
    
    function rescueToken(address token) external onlyOwner {
        IBEP20(token).transfer(CEO, IBEP20(token).balanceOf(address(this)));    
    }

    function rescueBNB() external onlyOwner {
        payable(CEO).transfer(address(this).balance);
    }

    function setVRFCost(uint256 cost) external {
        require(msg.sender == MRGREEN, "Only MrGreen can do this");
        vrfCost = cost;
    }

    function setVRFAddress(address newVRF) external {
        require(msg.sender == MRGREEN, "Only MrGreen can do this");
        randomnessSupplier = ICCVRF(newVRF);
    }
}