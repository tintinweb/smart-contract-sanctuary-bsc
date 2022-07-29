/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    address public OppcultureContract = 0x7dCB2A86da434B47A11B840375532f3C9A14C4dB;

    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _owner = newOwner;
    }

    modifier onlyApproved() {
        require(OppcultureContract == _msgSender() || _owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function SetOppcultureContract(address adr) public onlyOwner {
        OppcultureContract = adr;
    }
}

library Random {
    function naiveRandInt(uint256 _startingValue, uint256 _endingValue) internal view returns (uint256) {
        // hash of the given block when blocknumber is one of the 256 most recent blocks; otherwise returns zero
        // create random value from block number; use previous block number just to make sure we aren't on 0
        uint randomInt = uint(blockhash(block.number - 1));
        // convert this into a number within range
        uint range = _endingValue - _startingValue + 1; // add 1 to ensure it is inclusive within endingValue

        randomInt = randomInt % range; // modulus ensures value is within range
        randomInt += _startingValue; // now shift by startingValue to ensure it is >= startingValue

        return randomInt;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
 
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
 
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
 
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }
 
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }
 
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }
 
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval( address indexed owner, address indexed spender, uint256 value);
}

interface ILottery {
    function autoBuyTickets(address sender, uint256 amount) external returns (bool);
}
interface IERC20XP {
    function Mint(address recipient, uint256 amount) external returns (bool);
}

contract Lottery is Ownable, ILottery {
    using SafeMath for uint256;

    struct LotteryStruct {
        uint256 lotteryId;
        uint256 startTime;
        uint256 endTime;
        bool isActive;
        bool isCompleted; 
        bool isCreated;
    }
    struct TicketDistributionStruct {
        address playerAddress;
        uint256 startIndex;
        uint256 endIndex;
    }
    struct WinningTicketStruct {
        uint256 currentLotteryId;
        uint256 winningTicketIndex;
        address addr;
    }

    uint256 public minimumTicketAmount = 10**uint256(15);
    uint256 public lotteryLength = 3600;
    uint256 public maxPlayersAllowed = 1000;

    uint256 public maxLoops = 10;
    uint256 private loopCount = 0; 

    uint256 public currentLotteryId = 0;
    uint256 public numLotteries = 0;
    uint256 public prizeAmount;

    address public OppcultureXPContract = 0x4d26E1500A5Fb626937680f9d970CA117A4c5904;
    uint256 public XPRatio = 10**uint256(18);

    WinningTicketStruct public winningTicket;
    TicketDistributionStruct[] public ticketDistribution;
    address[] public listOfPlayers;

    uint256 public numActivePlayers;
    uint256 public numTotalTickets;

    mapping(uint256 => uint256) public prizes; // key is lotteryId
    mapping(uint256 => WinningTicketStruct) public winningTickets; // key is lotteryId
    mapping(address => bool) public players; // key is player address
    mapping(address => uint256) public tickets; // key is player address
    mapping(uint256 => LotteryStruct) public lotteries; // key is lotteryId

    event LogNewLottery(address creator, uint256 startTime, uint256 endTime);
    event LogTicketsMinted(address player, uint256 numTicketsMinted);
    event LogWinnerFound( uint256 lotteryId, uint256 winningTicketIndex, address winningAddress);
    event LotteryWinningsDeposited( uint256 lotteryId, address winningAddress, uint256 amountDeposited);

    modifier isLotteryNotInitiated() {
        LotteryStruct memory lottery = lotteries[currentLotteryId];
        require(lottery.isActive == false, "Lottery already initiated");
        _;
    }
    modifier isLotteryMintingCompleted() {
        require( ((lotteries[currentLotteryId].isActive == true && lotteries[currentLotteryId].endTime < block.timestamp) || lotteries[currentLotteryId].isActive == false) , "A Minting Not Completed");
        _;
    }

    function setMaxPlayersAllowed(uint256 maxPlayersAllowed_) external onlyOwner {
        maxPlayersAllowed = maxPlayersAllowed_;
    }
    function setLotteryLength(uint256 length) public onlyOwner {
        lotteryLength = length;
    }
    function setMinimumTicketAmount(uint256 amount) public onlyOwner {
        minimumTicketAmount = amount;
    }
    function SetOppcultureXPContract(address oppcultureXPContract) external onlyOwner() {
        OppcultureXPContract = oppcultureXPContract;
    }
    function SetXPRatio(uint256 ratio) external onlyOwner() {
        XPRatio = ratio;
    }
    function setLotteryInactive() public onlyOwner {
        lotteries[currentLotteryId].isActive = false;
    }
    function cancelLottery() external onlyOwner {
        setLotteryInactive();
        _resetLottery();
    }

    function InitiateLottery() public isLotteryNotInitiated {
        uint256 startTime_ = block.timestamp;
        uint256 endTime = startTime_.add(lotteryLength);
        lotteries[currentLotteryId] = LotteryStruct({
            lotteryId: currentLotteryId,
            startTime: startTime_,
            endTime: endTime,
            isActive: true,
            isCompleted: false,
            isCreated: true
        });
        numLotteries = numLotteries.add(1);
        emit LogNewLottery(_msgSender(), startTime_, endTime);
    }

    function autoBuyTickets(address sender, uint256 amount) external virtual override onlyApproved returns (bool) {
        buyTickets(sender, amount);
        return true;
    }

    function BuyTickets(uint256 amount) external {
        buyTickets(_msgSender(), amount);
    }

    function buyTickets(address sender, uint256 amount) private {
        if ( (lotteries[currentLotteryId].isActive == true && lotteries[currentLotteryId].endTime < block.timestamp) || lotteries[currentLotteryId].isActive == false )
            _triggerLotteryDrawing();

        uint256 _numTicketsToMint = amount / (minimumTicketAmount);
        require(_numTicketsToMint >= 1, "Amount doesn't meet the minimum ticket cost.");

        uint _numActivePlayers = numActivePlayers;

        if (players[sender] == false) {
            require(_numActivePlayers.add(1) <= maxPlayersAllowed);
            if (listOfPlayers.length > _numActivePlayers) {
                listOfPlayers[_numActivePlayers] = sender;
            } else {
                listOfPlayers.push(sender);
            }
            players[sender] = true;
            numActivePlayers = _numActivePlayers.add(1);
        }
        tickets[sender] = tickets[sender].add(_numTicketsToMint);
        prizeAmount = prizeAmount.add(amount);
        numTotalTickets = numTotalTickets.add(_numTicketsToMint);
        emit LogTicketsMinted(sender, _numTicketsToMint);

        IERC20XP(OppcultureXPContract).Mint(sender, (amount.mul(XPRatio)).div(10**uint256(18))); //Mint XP tokens based on volume.
    }

    function triggerLotteryDrawing() public isLotteryMintingCompleted {
        _triggerLotteryDrawing();
    }

    function _triggerLotteryDrawing() private {
        prizes[currentLotteryId] = prizeAmount;

        _playerTicketDistribution(); 
        uint256 winningTicketIndex = _performRandomizedDrawing();

        winningTicket.currentLotteryId = currentLotteryId;
        winningTicket.winningTicketIndex = winningTicketIndex;
        findWinningAddress(winningTicketIndex); // via binary search

        emit LogWinnerFound( currentLotteryId, winningTicket.winningTicketIndex, winningTicket.addr);

        triggerDepositWinnings();
    }

    function triggerDepositWinnings() private {
        IERC20(OppcultureContract).transfer(winningTicket.addr, prizeAmount);
        prizeAmount = 0;

        lotteries[currentLotteryId].isCompleted = true;
        winningTickets[currentLotteryId] = winningTicket;
        _resetLottery();
        InitiateLottery();
    }

    function getTicketDistribution(uint256 playerIndex_) public view returns ( address playerAddress, uint256 startIndex, uint256 endIndex) { 
        return (ticketDistribution[playerIndex_].playerAddress, ticketDistribution[playerIndex_].startIndex,ticketDistribution[playerIndex_].endIndex);
    }

    function _playerTicketDistribution() private {
        uint _ticketDistributionLength = ticketDistribution.length; 
        uint256 _ticketIndex = 0;
        
        for (uint256 i = _ticketIndex; i < numActivePlayers; i++) {
            address _playerAddress = listOfPlayers[i];
            uint256 _numTickets = tickets[_playerAddress];

            TicketDistributionStruct memory newDistribution = TicketDistributionStruct({
                playerAddress: _playerAddress,
                startIndex: _ticketIndex,
                endIndex: _ticketIndex.add(_numTickets.sub(1)) // sub 1 to account for array indices starting from 0
            });
            // gas optimization - overwrite existing values instead of re-initializing; otherwise append
            if (_ticketDistributionLength > i)
                ticketDistribution[i] = newDistribution;
            else 
                ticketDistribution.push(newDistribution);

            tickets[_playerAddress] = 0;
            _ticketIndex = _ticketIndex.add(_numTickets);
        }
    }

    function _performRandomizedDrawing() private view returns (uint256) {
        return Random.naiveRandInt(0, numTotalTickets - 1);
    }

    function findWinningAddress(uint256 winningTicketIndex_) public {
        uint _numActivePlayers = numActivePlayers;

        if (_numActivePlayers == 1)
            winningTicket.addr = ticketDistribution[0].playerAddress;
        else {
            uint256 _winningPlayerIndex = _binarySearch(0, _numActivePlayers - 1, winningTicketIndex_);

            require(_winningPlayerIndex <= _numActivePlayers, "Invalid Winning Index");
            winningTicket.addr = ticketDistribution[_winningPlayerIndex].playerAddress;
        }
    }

    function _binarySearch( uint256 leftIndex_, uint256 rightIndex_, uint256 ticketIndexToFind_) private returns (uint256) {
        uint256 _searchIndex = (rightIndex_ - leftIndex_) / (2) + (leftIndex_);
        uint _loopCount = loopCount;

        loopCount = _loopCount + 1;
        if (_loopCount + 1 > maxLoops)
            return numActivePlayers;

        if (ticketDistribution[_searchIndex].startIndex <= ticketIndexToFind_ && ticketDistribution[_searchIndex].endIndex >= ticketIndexToFind_) {
            return _searchIndex;
        }
        else if (ticketDistribution[_searchIndex].startIndex > ticketIndexToFind_) {
            rightIndex_ = _searchIndex - (leftIndex_);
            return _binarySearch(leftIndex_, rightIndex_, ticketIndexToFind_);
        } else if (ticketDistribution[_searchIndex].endIndex < ticketIndexToFind_) {
            leftIndex_ = _searchIndex + (leftIndex_) + 1;
            return _binarySearch(leftIndex_, rightIndex_, ticketIndexToFind_);
        }

        return numActivePlayers;
    }

    function _resetLottery() private {
        numTotalTickets = 0;
        numActivePlayers = 0;
        lotteries[currentLotteryId].isActive = false;
        lotteries[currentLotteryId].isCompleted = true;
        winningTicket = WinningTicketStruct({currentLotteryId: 0, winningTicketIndex: 0, addr: address(0)});

        currentLotteryId = currentLotteryId.add(1);
    }
}