/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

/*  
 * StakingLottery
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

contract StakingLottery {
    address public constant CEO = 0xc6CBDd49a933faC2188e9d5d1bEAE4f78C78c4f5;
    IBEP20 public constant TOKEN = IBEP20(0x598A8e825E06496d55288eAb47a3FeF785e71F68);

    ICCVRF public randomnessSupplier = ICCVRF(0xC0de0aB6E25cc34FB26dE4617313ca559f78C0dE);
    mapping (uint256 => bool) public nonceProcessed;
    uint256 private vrfCost = 0.002 ether;
    uint256 public nonce;
    uint256 public decimals;
    uint256 public stakingPoolBalance;
    uint256 public stakingJackpot;
    uint256 public tokensPerTicket;
    uint256 public howManyWinners;
    uint256 public daysUntilEnd;
    uint256 public stakingOpenForDays;
    uint256 public lastChanceToStake;
    uint256 public stakingEnds;

    bool public stakingIsOpen;
    bool public winnersChosen;
    bool public winnersPaid;

    struct Winners{
        uint256 round;
        address winner;
        uint256 prize;
    }

    Winners[] public winners;
    address[] public ticketsInDraw;
    address[] public winnersOfCurrent;

    event Winner(address winner, uint256 tokensWon);

    modifier onlyOwner() {if(msg.sender != CEO) return; _;}
    modifier onlyVRF() {if(msg.sender != address(randomnessSupplier)) return; _;}

    constructor() {
        decimals = TOKEN.decimals();
        tokensPerTicket = 50_000 * (10**decimals);
    }

    receive() external payable {}

    function stake(uint256 tickets) external {
        require(stakingIsOpen, "Staking isn't open right now");        
        require(lastChanceToStake > block.timestamp, "can only stake on day 1");
        uint256 tokensToStake = tickets * tokensPerTicket;
        TOKEN.transferFrom(msg.sender,address(this), tokensToStake);
        stakingPoolBalance += tokensToStake;
        for(uint256 i= 1; i<=tickets; i++) ticketsInDraw.push(msg.sender);
    }
    
    function setTokensPerTicket(uint256 _tokensPerTicket) external onlyOwner{
        tokensPerTicket = _tokensPerTicket * (10**decimals);
    }

    function setDays(uint256 _daysUntilEnd, uint256 _stakingOpenForDays) external onlyOwner{
        require(_stakingOpenForDays < _daysUntilEnd, "check your numbers");
        daysUntilEnd = _daysUntilEnd;
        stakingOpenForDays = _stakingOpenForDays;
    }

    function openStaking(uint256 stakingJackpotPrize, uint256 _howManyWinners) external onlyOwner {
        require(!stakingIsOpen, "Staking is already open");
        require(ticketsInDraw.length == 0, "Send tokens back first");
        
        lastChanceToStake = block.timestamp + (stakingOpenForDays * 1 minutes); // changed to hours for testing
        stakingEnds = block.timestamp + (daysUntilEnd * 1 minutes); // changed to hours for testing
        TOKEN.transferFrom(msg.sender,address(this),stakingJackpotPrize * (10**decimals));
        stakingJackpot = stakingJackpotPrize * (10**decimals);
        howManyWinners = _howManyWinners;
        stakingIsOpen = true;
        winnersChosen = false;
        winnersPaid = false;
    }

    function drawWinners() external onlyOwner {
        require(block.timestamp > stakingEnds && stakingIsOpen, "Wait until staking ends");
        randomnessSupplier.requestRandomness{value: vrfCost}(nonce, howManyWinners);
        stakingIsOpen = false;
    }

    function supplyRandomness(uint256 _nonce,uint256[] memory randomNumbers) external onlyVRF {
        if(nonceProcessed[_nonce]) return;
        nonceProcessed[_nonce] = true;

        for(uint256 i = 0; i < randomNumbers.length; i++) {
            uint256 winnerID = randomNumbers[i] % ticketsInDraw.length;
            winnersOfCurrent.push(ticketsInDraw[winnerID]);
            ticketsInDraw[winnerID] = ticketsInDraw[ticketsInDraw.length -1];
            ticketsInDraw.pop();    
        }
        winnersChosen = true;
    }

    function payTheWinners() external onlyOwner {
        require(winnersChosen, "Choose winners first");
        require(!winnersPaid, "Winners have already been paid");
        uint256 prize = stakingJackpot / howManyWinners;
        for(uint256 i = 0; i < winnersOfCurrent.length; i++) {
            TOKEN.transfer(winnersOfCurrent[i], prize + tokensPerTicket);
            Winners memory currentWinner;
            currentWinner.round = nonce;
            currentWinner.winner = winnersOfCurrent[i];
            currentWinner.prize = prize;
            emit Winner(currentWinner.winner, prize);
            winners.push(currentWinner);
        }
        delete winnersOfCurrent;
        stakingJackpot = 0;
        nonce++;
        winnersPaid = true;
    }

    function automaticallyReturnStakes() external onlyOwner {
        require(winnersPaid, "Can't send tokens back before paying the winners");
        uint256 howMany = ticketsInDraw.length;
        for(uint256 i= 0; i<howMany; i++) {
            address staker = ticketsInDraw[ticketsInDraw.length - 1];
            ticketsInDraw.pop;
            TOKEN.transfer(staker, tokensPerTicket);
            stakingPoolBalance -= tokensPerTicket;
        }
    }

    function manuallyReturnStakes(uint256 howMany) external onlyOwner {
        require(winnersPaid, "Can't send tokens back before paying the winners");
        if(howMany > ticketsInDraw.length) howMany = ticketsInDraw.length;
        for(uint256 i= 0; i<howMany; i++) {
            address staker = ticketsInDraw[ticketsInDraw.length - 1];
            ticketsInDraw.pop;
            TOKEN.transfer(staker, tokensPerTicket);
            stakingPoolBalance -= tokensPerTicket;
        }
    }
}