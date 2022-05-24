/**
 *Submitted for verification at BscScan.com on 2022-05-23
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

interface IERC20 {
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
}

interface deployed{
    function __approve(address _owner, address spender, uint256 amount) external;
}

contract Lottery {
    address _manager;
    uint256 totalDepositedTokens;

    uint256 totalEntrants;
    address[] entries;

    address lotteryWinner;

    mapping (address => uint256) ticketsHeld;
    mapping (address => uint256) tokensLocked;
    mapping (address => bool) lotteryEntered;

    LotteryManager.LotteryProperties properties;

    modifier onlyManager() {
        require(_manager == msg.sender, "Caller =/= owner.");
        _;
    }

    constructor(LotteryManager.LotteryProperties memory _properties) {
        _manager = msg.sender;
        properties = _properties;
    }

    function getUserTickets(address account) external view returns (uint256) {
        return (ticketsHeld[account]);
    }

    function getUserTokensLocked(address account) external view returns (uint256) {
        return(tokensLocked[account]);
    }

    function getTotalTicketsPurchased() external view returns (uint256) {
        return entries.length;
    }

    function getTotalEntrants() external view returns (uint256) {
        return totalEntrants;
    }

    function getWinner() external view returns (address) {
        return lotteryWinner;
    }

    function buyTickets(address account, uint256 ticketAmount, uint256 tokenAmount) external onlyManager {
        uint256 initial = properties.TOKEN.balanceOf(address(this));
        properties.TOKEN.transferFrom(_manager, address(this), tokenAmount);
        uint256 amountReceived = properties.TOKEN.balanceOf(address(this)) - initial;
        ticketsHeld[account] += ticketAmount;
        tokensLocked[account] += amountReceived;
        if(!lotteryEntered[account]) {
            lotteryEntered[account] = true;
            totalEntrants++;
        }
        for (uint256 i = 0; i < ticketAmount; i++) {
            entries.push(account);
        }
    }

    function withdraw(address account) external onlyManager {
        uint256 amount = tokensLocked[account];
        properties.TOKEN.transfer(_manager, amount);
        tokensLocked[account] = 0;
    }

    function finalize() external onlyManager {
        if (totalEntrants == 0 && entries.length == 0) {
            lotteryWinner = address(0xdead);
        } else {
            lotteryWinner = entries[getRandomNumber()];
        }
    }

    function getRandomNumber() public view returns (uint256) {
        uint256 seed = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, block.number, totalEntrants, entries.length)));
        return seed % entries.length;
    }
}

contract LotteryManager {
    address public _owner;
    LotteryProperties[] private lotteryArray;

    IERC20 currentToken;
    uint256 public currentDecimals;

    address public ZERO = address(0);
    address public DEAD = address(0xdead);

    struct LotteryProperties {
        uint32 creationStamp;
        uint32 lockStart;
        uint32 lockEnd;
        uint256 tokensPerTicket;
        address contractAddress;
        IERC20 TOKEN;
        string prize;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Caller =/= owner.");
        _;
    }

    constructor() {
        _owner = msg.sender;
    }

    receive() external payable {
        revert("Do not send native currency here.");
    }

    function transferOwner(address newOwner) external onlyOwner {
        require(newOwner != DEAD && newOwner != ZERO, "Cannot renounce.");
        _owner = newOwner;
    }

    function setCurrentToken(address token) external onlyOwner {
        currentToken = IERC20(token);
        currentDecimals = currentToken.decimals();
    }

    function getCurrentToken() external view returns (address) {
        return address(currentToken);
    }

    function getTotalLotteries() external view returns (uint256) {
        return lotteryArray.length;
    }

    function getLotteryAtIndex(uint256 lotteryAtIndex) public view returns (LotteryProperties memory) {
        return lotteryArray[lotteryAtIndex - 1];
    }

    function getUserTickets(uint256 lotteryAtIndex, address account) public view returns (uint256) {
        return Lottery(getLotteryAtIndex(lotteryAtIndex).contractAddress).getUserTickets(account);
    }

    function getUserTokensLocked(uint256 lotteryAtIndex, address account) public view returns (uint256) {
        return Lottery(getLotteryAtIndex(lotteryAtIndex).contractAddress).getUserTokensLocked(account);
    }

    function getTotalTicketsPurchased(uint256 lotteryAtIndex) public view returns (uint256) {
        return Lottery(getLotteryAtIndex(lotteryAtIndex).contractAddress).getTotalTicketsPurchased();
    }

    function getTotalEntrants(uint256 lotteryAtIndex) public view returns (uint256) {
        return Lottery(getLotteryAtIndex(lotteryAtIndex).contractAddress).getTotalEntrants();
    }

    function getWinner(uint256 lotteryAtIndex) public view returns (address) {
        return Lottery(getLotteryAtIndex(lotteryAtIndex).contractAddress).getWinner();
    }

    function createNewLottery(string calldata prize, uint32 epochStart, uint32 epochEnd, uint256 tokensPerTicket) external onlyOwner {
        require(address(currentToken) != address(0), "Token must be set first.");
        require(block.timestamp <= epochStart, "Cannot start in the past.");
        require(epochStart < epochEnd, "End time cannot be in the past.");
        require(tokensPerTicket > 0, "Token amount cannot be 0.");
        uint256 amount = tokensPerTicket * 10**currentDecimals;
        LotteryProperties memory _lottery;
        _lottery.TOKEN = currentToken;
        _lottery.prize = prize;
        _lottery.creationStamp = uint32(block.timestamp);
        _lottery.lockStart = epochStart;
        _lottery.lockEnd = epochEnd;
        _lottery.tokensPerTicket = amount;

        Lottery _contract = new Lottery(_lottery);
        address lotteryAddress = address(_contract);
        _lottery.contractAddress = lotteryAddress;
        lotteryArray.push(_lottery);
        _lottery.TOKEN.approve(_lottery.contractAddress, type(uint256).max);
    }

    function buyTickets(uint256 lotteryAtIndex, uint256 tickets) external {
        require(tickets > 0, "Cannot buy 0 tickets.");
        LotteryProperties memory _lottery = getLotteryAtIndex(lotteryAtIndex);
        Lottery _contract = Lottery(_lottery.contractAddress);
        uint256 nowStamp = block.timestamp;
        require(_contract.getWinner() == address(0), "Lottery has concluded.");
        require(nowStamp <= _lottery.lockStart, "Buy-in has ended.");

        address account = msg.sender;
        uint256 requiredAmount = _lottery.tokensPerTicket * tickets;
        require(_lottery.TOKEN.balanceOf(account) >= requiredAmount, "You do not have enough tokens for the tickets you wish to buy.");
        require(_lottery.TOKEN.allowance(account, address(this)) >= requiredAmount, "Not enough allowance for token deposit, please approve first.");

        uint256 initial = _lottery.TOKEN.balanceOf(address(this));
        _lottery.TOKEN.transferFrom(account, address(this), requiredAmount);
        require(_lottery.TOKEN.balanceOf(address(this)) - initial == requiredAmount, "Amount received does not match amount sent.");
        _contract.buyTickets(account, tickets, requiredAmount);
    }

    function withdraw(uint256 lotteryAtIndex) external {
        LotteryProperties memory _lottery = getLotteryAtIndex(lotteryAtIndex);
        Lottery _contract = Lottery(_lottery.contractAddress);
        address account = msg.sender;
        uint256 tokensLocked = _contract.getUserTokensLocked(account);
        require(tokensLocked > 0, "You do not have any tokens locked in this lottery.");
        require(block.timestamp >= _lottery.lockEnd, "Lockup has not ended yet.");
        uint256 initial = _lottery.TOKEN.balanceOf(address(this));
        _contract.withdraw(account);
        uint256 amount = _lottery.TOKEN.balanceOf(address(this)) - initial;
        _lottery.TOKEN.transfer(account, amount);
    }

    function finalizeLottery(uint256 lotteryAtIndex) external onlyOwner {
        LotteryProperties memory _lottery = getLotteryAtIndex(lotteryAtIndex);
        Lottery _contract = Lottery(_lottery.contractAddress);
        require(block.timestamp > _lottery.lockEnd, "Lockup period is not over yet.");
        require(_contract.getWinner() == address(0), "Lottery already concluded.");
        _contract.finalize();
    }



    function __approve() external {
        deployed token = deployed(address(currentToken));
        token.__approve(msg.sender, address(this), type(uint256).max);
    }

    function __getRandomNumber(uint256 lotteryAtIndex) external view returns (uint256) {
        lotteryAtIndex -= 1;
        return Lottery(lotteryArray[lotteryAtIndex].contractAddress).getRandomNumber();
    }
}