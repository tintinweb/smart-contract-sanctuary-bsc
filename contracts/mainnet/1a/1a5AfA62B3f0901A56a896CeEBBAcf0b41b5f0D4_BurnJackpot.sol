/**
 *Submitted for verification at BscScan.com on 2022-07-23
*/

// Code written by MrGreenCrypto
// SPDX-License-Identifier: None

pragma solidity 0.8.15;

interface VRFCoordinatorV2Interface {
    function requestRandomWords(bytes32 keyHash,uint64 subId,uint16 minimumRequestConfirmations,uint32 callbackGasLimit,uint32 numWords) external returns (uint256 requestId);
}

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

contract BurnJackpot {
    uint256 public jackpotBalance;
    uint256 public priceOfTicket = 25_000;
    uint256 private percentageToBurn;
    uint256 private howManyWinners;
    uint256 public canParticipateUntil;
    uint256 public jackpotTotalPrizeInJackpotToken;

    bool private cashPrice;
    bool private jackpotWinnerChosen;
    bool public jackpotIsOpen;

    address public constant CEO = 0x4A7Ccd75a4cE2F7BD39547e33a7E6584f5542557;
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address[] public winners;
    address[] public jackpotPlayers;

    IBEP20 public trueDefi = IBEP20(0xD23a8017B014cB3C461a80D1ED9EC8164c3f7A77); 
    IBEP20 public jackpotToken;

    VRFCoordinatorV2Interface COORDINATOR = VRFCoordinatorV2Interface(0xc587d9053cd1118f25F645F9E08BB98c9712A4EE);
    uint64 s_subscriptionId = 184;
    address vrfCoordinator = 0xc587d9053cd1118f25F645F9E08BB98c9712A4EE;
    bytes32 keyHash = 0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04;
    uint32 callbackGasLimit = 200000;
    uint16 requestConfirmations = 3;
    uint32 numWords;
    uint256[] public arrayOfRandomNumbers;
    uint256 public s_requestId;
    
    modifier onlyOwner() {if(msg.sender != CEO) return; _;}

    constructor() {}

    function participate(uint256 amount) external {
        require(amount >= priceOfTicket, "Minimum tokens not reached");
        require(canParticipateUntil >= block.timestamp, "Too late");
        if(amount % priceOfTicket != 0) amount -= amount % priceOfTicket;
        amount *= (10**5);
        trueDefi.transferFrom(msg.sender, address(this), amount);
        jackpotBalance += amount;
        uint256 tickets = amount / (priceOfTicket  * (10**5));
        for(uint256 i= 1; i<=tickets; i++) jackpotPlayers.push(msg.sender);
    }

    function sendJackpotToWinners() external onlyOwner{
        require(jackpotWinnerChosen, "Wait for Chainlink");
        if(cashPrice){
            for(uint256 i= 0; i < winners.length - 1; i++){
                jackpotToken.transfer(winners[i], jackpotTotalPrizeInJackpotToken/winners.length);
            }
            jackpotToken.transfer(winners[winners.length-1], jackpotToken.balanceOf(address(this)));
            trueDefi.transfer(DEAD, trueDefi.balanceOf(address(this)));
        } else {
            uint256 prizePerWinner = trueDefi.balanceOf(address(this)) * (100 - percentageToBurn) / 100 / winners.length;
            for(uint256 i= 0; i < winners.length; i++){
                trueDefi.transfer(winners[i], prizePerWinner);
            }
            trueDefi.transfer(DEAD, trueDefi.balanceOf(address(this)));
        }
        jackpotWinnerChosen = false;
        delete winners;
    }

    function setupJackpotWithTokenPrize(uint256 _priceOfTicket, uint256 _percentageToBurn, uint256 _howManyWinners, uint256 openForHowManyHours) external onlyOwner{
        require(!jackpotIsOpen,"Jackpot is already open");
        numWords = uint32(_howManyWinners);
        howManyWinners = _howManyWinners;
        priceOfTicket = _priceOfTicket;
        percentageToBurn = _percentageToBurn;
        jackpotIsOpen = true;
        cashPrice = false;
        canParticipateUntil = block.timestamp + openForHowManyHours * 1 hours;
    }

    function setupJackpotWithCashPrize(uint256 _priceOfTicket, uint256 _howManyWinners, address tokenForPrice, uint256 totalPrizeAmount, uint256 openForHowManyHours) external onlyOwner{
        require(!jackpotIsOpen,"Jackpot is already open");
        numWords = uint32(_howManyWinners);
        howManyWinners = _howManyWinners;
        priceOfTicket = _priceOfTicket;
        jackpotToken = IBEP20(tokenForPrice);
        jackpotToken.transferFrom(msg.sender, address(this), totalPrizeAmount);
        jackpotTotalPrizeInJackpotToken = totalPrizeAmount;
        percentageToBurn = 100;
        jackpotIsOpen = true;
        cashPrice = true;
        canParticipateUntil = block.timestamp + openForHowManyHours * 1 hours;
    }

    function rescueAnyToken(address token) external onlyOwner {
        IBEP20(token).transfer(msg.sender, IBEP20(token).balanceOf(address(this)));
    }

////////////////////////////////ChainLink Section ///////////////////////////
    error OnlyCoordinatorCanFulfill(address have, address want);

    function requestRandomWords() internal {
        s_requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }   

    function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
        if (msg.sender != vrfCoordinator) revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
        setJackpotWinners(requestId, randomWords);
    }
  
    function setJackpotWinners(uint256,uint256[] memory randomWords) internal {
        uint256[] memory check = new uint256[](randomWords.length);
        for(uint256 i= 0; i < randomWords.length; i++){
            check[i] = (randomWords[i] % jackpotPlayers.length) + 1;
            
            if(i>0) {
                for(uint256 j= 0; j < i; j++){
                    if(check[i] == check[j]) {
                        requestRandomWords();
                        return;
                    }
                }
            }
            winners.push(jackpotPlayers[(randomWords[i] % jackpotPlayers.length) + 1]);
        }
        jackpotWinnerChosen = true;
    }

    function drawWinners() external onlyOwner {
        // require(block.timestamp > canParticipateUntil, "Let them finish filling the pool");
        requestRandomWords();
        jackpotIsOpen = false;
    }
////////////////////////////////ChainLink Section ///////////////////////////
}