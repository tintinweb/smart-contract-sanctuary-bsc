/**
 *Submitted for verification at BscScan.com on 2022-07-28
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

interface ICCVRF {
    function requestRandomness(uint256 requestID, uint256 howManyNumbers) external payable;
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

    ICCVRF public randomnessSupplier = ICCVRF(0xC0de0aB6E25cc34FB26dE4617313ca559f78C0dE);
    uint256 totalPlays;
    uint256 vrfCost = 0.002 ether;
    
    modifier onlyOwner() {if(msg.sender != CEO) return; _;}
    modifier onlyVRF() {if(msg.sender != address(randomnessSupplier)) return; _;}

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

    function getTicketsBought(address player) public view returns (uint256) {
        uint256 ticketsOfPlayer;
        for(uint256 i= 0; i < jackpotPlayers.length; i++){
            if(jackpotPlayers[i] == player) ticketsOfPlayer++;
        }
        return ticketsOfPlayer;
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
        delete jackpotPlayers;
    }

    function setupJackpotWithTokenPrize(uint256 _priceOfTicket, uint256 _percentageToBurn, uint256 _howManyWinners, uint256 openForHowManyHours) external onlyOwner{
        require(!jackpotIsOpen,"Jackpot is already open");
        howManyWinners = _howManyWinners;
        priceOfTicket = _priceOfTicket;
        percentageToBurn = _percentageToBurn;
        jackpotIsOpen = true;
        cashPrice = false;
        canParticipateUntil = block.timestamp + openForHowManyHours * 1 hours;
    }

    function setupJackpotWithCashPrize(uint256 _priceOfTicket, uint256 _howManyWinners, address tokenForPrice, uint256 totalPrizeAmount, uint256 openForHowManyHours) external onlyOwner{
        require(!jackpotIsOpen,"Jackpot is already open");
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
    
    function rescueBNB() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

////////////////////////////////ChainLink Section ///////////////////////////
    function supplyRandomness(uint256,uint256[] memory randomNumbers) external onlyVRF {
        uint256[] memory check = new uint256[](randomNumbers.length);
        for(uint256 i= 0; i < randomNumbers.length; i++){
            check[i] = (randomNumbers[i] % jackpotPlayers.length) + 1;
            
            if(i>0) {
                for(uint256 j= 0; j < i; j++){
                    if(check[i] == check[j]) {
                        totalPlays++;
                        randomnessSupplier.requestRandomness{value: vrfCost}(totalPlays, howManyWinners);
                        return;
                    }
                }
            }
            winners.push(jackpotPlayers[(randomNumbers[i] % jackpotPlayers.length) + 1]);
        }
        jackpotWinnerChosen = true;
    }

    function drawWinners() external payable onlyOwner {
        // use msg.value of at least 0.01bnb to make sure it can redraw winners if there are two winners that are the same
        totalPlays++;
        // require(block.timestamp > canParticipateUntil, "Let them finish filling the pool");
        randomnessSupplier.requestRandomness{value: vrfCost}(totalPlays, howManyWinners);
        jackpotIsOpen = false;
    }
////////////////////////////////ChainLink Section ///////////////////////////
}