/**
 *Submitted for verification at BscScan.com on 2022-10-03
*/

/*  
 * BurnLottery
 * 
 * Written by: MrGreenCrypto
 * Co-Founder of CodeCraftrs.com
 * 
 * SPDX-License-Identifier: None
 */
pragma solidity 0.8.17;

interface IBEP20 {
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface ICCVRF {
    function requestRandomness(uint256 requestID, uint256 howManyNumbers) external payable;
}

contract BurnLottery {
    address public constant CEO = 0x7e94a785A590EEbBAd494c6EF08f80e494ac3616;
    IBEP20 public constant TOKEN = IBEP20(0x0627E7ee0D14FCdd2ff30d1563AeBDBccec678be);

    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;
    ICCVRF public randomnessSupplier = ICCVRF(0xC0de0aB6E25cc34FB26dE4617313ca559f78C0dE);
    mapping (uint256 => bool) public nonceProcessed;
    uint256 private vrfCost = 0.002 ether;
    uint256 public nonce;
    uint256 public decimals;
    uint256 public priceOfTicketBurnLottery = 10_000;
    uint256 public maxTicketsPerWallet = 10;
    uint256 public maxTicketsPerDraw = 20;
    uint256 public tokensBurntSoFar;
    uint256 public burnJackpot;
    uint256 public tokenToBurn;
    uint256 public totalTicketsSoldInThisLottery;
    
    bool public burnJackpotIsOpen = true;
    bool public paused;
    bool public pauseToAdjust;

    struct Winners{
        uint256 round;
        address winner;
        uint256 prize;
    }

    Winners[] public winners;
    address[] public players;

    event Winner(address winner, uint256 tokensWon);

    modifier onlyOwner() {if(msg.sender != CEO) return; _;}
    modifier onlyVRF() {if(msg.sender != address(randomnessSupplier)) return; _;}

    constructor() {
        decimals = TOKEN.decimals();
    }

    receive() external payable {}

    function BuyBurn(uint256 tickets) external {
        require(burnJackpotIsOpen, "Jackpot is full, please wait");
        require(tickets + getTicketsBought(msg.sender) <= maxTicketsPerWallet, "Trying to buy too many tickets");
        if(totalTicketsSoldInThisLottery + tickets > maxTicketsPerDraw) tickets = maxTicketsPerDraw - totalTicketsSoldInThisLottery;
        totalTicketsSoldInThisLottery += tickets;
        uint256 tokensToSend = tickets * priceOfTicketBurnLottery * (10**decimals);
        TOKEN.transferFrom(msg.sender, address(this), tokensToSend);
        burnJackpot += tokensToSend / 2;
        tokenToBurn += tokensToSend / 2;
        for(uint256 i= 1; i<=tickets; i++) players.push(msg.sender);
        if(players.length >= maxTicketsPerDraw) drawBurnWinner();
    }

    function supplyRandomness(uint256 _nonce,uint256[] memory randomNumbers) external onlyVRF {
            if(nonceProcessed[_nonce]) return;
            address winnerAdd = players[(randomNumbers[0] % players.length)];
            TOKEN.transfer(DEAD, tokenToBurn);
            TOKEN.transfer(winnerAdd, TOKEN.balanceOf(address(this)));
            tokensBurntSoFar += tokenToBurn;
            nonceProcessed[_nonce] = true;
            emit Winner(winnerAdd, burnJackpot);
            Winners memory currentWinner;
            currentWinner.round = _nonce;
            currentWinner.winner = winnerAdd;
            currentWinner.prize = burnJackpot;
            winners.push(currentWinner);
            tokenToBurn = 0;
            burnJackpot = 0;
            delete players;
            totalTicketsSoldInThisLottery = 0; 
            if(!pauseToAdjust) burnJackpotIsOpen = true;
            else paused = true;
        }

    function getTicketsBought(address player) public view returns (uint256) {
        uint256 ticketsOfPlayer;
        for(uint256 i= 0; i < players.length; i++) if(players[i] == player) ticketsOfPlayer++;
        return ticketsOfPlayer;
    }

    function drawBurnWinner() internal {
        randomnessSupplier.requestRandomness{value: vrfCost}(nonce, 1);
        nonce++;
        burnJackpotIsOpen = false;
    }

    function rescueAnyToken(address token) external onlyOwner {
        IBEP20(token).transfer(msg.sender, IBEP20(token).balanceOf(address(this)));
    }
    
    function rescueBNB() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function pauseNextRoundToAdjust() external onlyOwner {
        pauseToAdjust = true;
    }

    function setVariablesAndOpen(uint256 price, uint256 maxWallet, uint256 max) external onlyOwner {
        require(paused, "Pause the contract before changing variables");
        priceOfTicketBurnLottery = price;
        maxTicketsPerWallet = maxWallet;
        maxTicketsPerDraw = max;
        paused = false;
        pauseToAdjust = false;
        burnJackpotIsOpen = true;
    }
}