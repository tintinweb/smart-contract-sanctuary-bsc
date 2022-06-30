/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

//import "hardhat/console.sol";

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract RandomNumberBetting {
    
    struct PlayerData {
        address user;
        uint256 total;
        uint256[8] bettedAmount;
    }

    PlayerData[] internal players;

    mapping(address => uint256) internal userId;
    mapping(address => uint256) internal _balance;

    address private owner;
    address[] private args;

    uint bettingState = 0;

    uint256 durationOfBetting = 5 minutes;
    uint256 durationOfDelay = 2 minutes;

    uint256 totalBettedAmount;
    uint256 historicalNumberOfUser;

    uint256 winningNumberLastPhase;

    uint256 endTimeOfBetting;
    uint256[8] bettedAmountForEachNumber;

    IBEP20 tokenContract;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
        historicalNumberOfUser = 0;
    }

    function setBettingTime(uint256 _timeOfBetting) public onlyOwner {
        require(bettingState !=1, "Can't set now");
        durationOfBetting = _timeOfBetting;
    }

    function setDelayTime(uint256 _timeOfDelay) public onlyOwner {
        require(bettingState !=1, "Can't set now");
        durationOfDelay = _timeOfDelay;
    }

    function setTokenAddress(address _newAddress) public onlyOwner {
        tokenContract = IBEP20(_newAddress);
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
    
    function getOwner() public  view returns(address) {
        return owner;
    }

    function getEndTime() public view returns(uint256) {
        return endTimeOfBetting;
    }

    function getTotalAmount() public onlyOwner view returns (uint256) {
        return totalBettedAmount;
    }

    function balanceOfContract() public onlyOwner view returns (uint256) {
        return tokenContract.balanceOf(address(this));
    }

    function getDurationOfBetting() public view returns (uint256) {
        return durationOfBetting;
    }

    function getBettingState() public view returns (uint) {
        return bettingState;
    }

    function getBettingData(address account) public view returns (uint256, uint256, uint256) {
        require(bettingState > 0, "Can't get betting data now");

        uint256 countOfPlayer;
        countOfPlayer = players.length - 1;

        uint256 _userId;
        _userId = userId[account];
        uint256 mani;
        mani = players[_userId].total;

        return ( countOfPlayer, historicalNumberOfUser, mani );

    }

    function getAmountWithdrawable() public view returns(uint256) {
        return _balance[msg.sender];
    }
	
	// This function init all state
    function initState() internal {
        totalBettedAmount = 0;

        for(uint256 i = 1; i < players.length; i ++) {
            delete userId[players[i].user];
        }
        for(uint256 i = 0; i < 8; i ++) {
            bettedAmountForEachNumber[i] = 0;
        }

        delete players;
        delete args;
        players.push();
    }

    function startBetting() public {
        require(bettingState != 1, "Betting is already started");
        require(block.timestamp > endTimeOfBetting, "Can't start now");
        
        initState();
        bettingState = 1;
        endTimeOfBetting = block.timestamp + durationOfBetting;
    }

    function stopBetting() public {
        require(bettingState == 1, "Betting has not started yet");
        require(block.timestamp > endTimeOfBetting,"Can't stop now.");
        
        bettingState = 2;
        endTimeOfBetting = block.timestamp + durationOfDelay;
        payout();
    }

    // User can bet for 6 days. After 6 days, bet is stopped.
    function bet(uint256 number, uint256 amount) public {

        require(block.timestamp < endTimeOfBetting, "Betting isn't started yet.");

        tokenContract.transferFrom(msg.sender, address(this), amount);

        uint256 _userId;
        _userId = userId[msg.sender];

        if(_userId == 0) {
            _userId = players.length;
            players.push();

            PlayerData memory newplayer;
            newplayer.user = msg.sender;

            players[_userId] = newplayer;
            args.push(msg.sender);
            historicalNumberOfUser += 1;
        }

        players[_userId].bettedAmount[number] += amount;
        players[_userId].total += amount;
        bettedAmountForEachNumber[number] += amount;
        userId[msg.sender] = _userId;
        totalBettedAmount += amount;
    }

    function claimReward() public {
        require(_balance[msg.sender] != 0, "Your balance is zero");

        uint256 senderBalance = _balance[msg.sender];
        _balance[msg.sender] = 0;
        tokenContract.transfer(msg.sender, senderBalance);
    }

    function random() internal view returns (uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, args)));
    }
    
    function pickWinner() internal view returns (uint){
        uint index = random() % 8;
        return index;
    }

    function getWinNumber() public view returns (uint){ 
        return winningNumberLastPhase; 
    }

    function payout() internal {
        uint winNumber;
        winNumber = pickWinner();

        winningNumberLastPhase = winNumber;

        // pay to owner
        uint256 twentyPercent;
        twentyPercent = totalBettedAmount * 2 / 10;
        tokenContract.transfer(owner, twentyPercent);
        totalBettedAmount -= twentyPercent;

        // pay to winner
        uint256 sum = 0;
        uint256 countOfPlayer;
        countOfPlayer = players.length;
        for(uint256 i = 1; i < countOfPlayer; i ++) {
            if(players[i].bettedAmount[winNumber] > 0) {
                uint256 rewardAmount;
                rewardAmount = players[i].bettedAmount[winNumber] * totalBettedAmount;
                uint256 tempAmount = rewardAmount / bettedAmountForEachNumber[winNumber];
                _balance[players[i].user] += tempAmount;
                sum += tempAmount;
            }
        }
        totalBettedAmount -= sum;

        tokenContract.transfer(owner, totalBettedAmount);
    }
}