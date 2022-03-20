// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./Address.sol";
import "./IERC20.sol";
import "./SafeERC20.sol";
import "./ILotteryPrice.sol";
import "./ILotteryRandom.sol";
import "./ILotteryNFT.sol";

contract DynamixLottery is Ownable {
	using SafeERC20 for IERC20;

    address public operatorAddress;

	uint256 public currentLotteryId = 0;
    uint256 public currentTicketId = 0;
	
	uint256 public ticketPriceInUSD = 5 * 10**18;
    uint256 public maxTicket = 100;
	
	IDynamixLotteryPrice public lotteryPrice;
	IDynamixLotteryRandom public lotteryRandom;
	IDynamixLotteryNFT public lotteryNFT;
	
	enum LotteryStatus {
        Open,
        InDraw,
        Close
    }

    struct Lottery {
        LotteryStatus status;
        uint256 startTime;
        uint256 endTime;
        uint256 firstTicketId;
        uint256 lastTicketId;
        uint256 amount;
        uint32 winningNumber;
        uint32[6] winnersPerBracket;
        uint256[6] amountsPerBracket;
    }

    struct Ticket {
        uint32 number;
        address player;
    }
	
	struct TicketView {
		uint256 id;
        uint32 number;
        uint8 matchNumber;
		address player;
		bool claimed;
    }
		
	mapping(uint256 => Lottery) private _lotteries;
    mapping(uint256 => Ticket) private _tickets;
    mapping(address => mapping(uint256 => uint256[])) private _players;

	event NewBet(
		address indexed player, 
		address betInToken,
		uint256 indexed lotteryId, 
		uint256 numberTickets
	);
	
	event NewLottery(
		uint256 indexed lotteryId
	);
	
	event DrawnLottery(
		uint256 indexed lotteryId, 
		uint32 winningNumber
	);
	
	event CloseLottery(
		uint256 indexed lotteryId
	);
	
	event FundsInjected(
		uint256 indexed lotteryId, 
		uint256 amount
	);
	
	event FundsWithDrawn(
		uint256 amount
	);

	event TicketsClaimed(
		address indexed player, 
		uint256 indexed lotteryId, 
		uint256 amount
	);
	
	event AddressConfigurationChanged(
		string typeValue,
		address addrValue
	);
	
	event TicketPriceChanged(
		uint256 ticketPriceInUSD,
		uint256 maxTicket
	);

	modifier onlyOperator() {
        require(msg.sender == operatorAddress || msg.sender == owner(), "Not operator");
        _;
    }
	
	constructor() {
        
    }
	
	// *****************************************
	// Main Lottery Functions
	// *****************************************

	// Bet in lottery
	function bet(uint256 lotteryId, uint32[] memory tickets, address betInToken) public {
		require(tickets.length != 0, "No ticket specified");
        require(tickets.length <= maxTicket, "Too many tickets");
        require(_lotteries[lotteryId].status == LotteryStatus.Open, "Lottery is not open");
        require(block.timestamp < _lotteries[lotteryId].endTime, "Lottery is over");

		// Swap and Transfer
		uint256 price = lotteryNFT.hasDiscount(msg.sender) ? ticketPriceInUSD / 2 : ticketPriceInUSD;
		uint256 totalDyna = lotteryPrice.swapAndTransfer(address(msg.sender), tickets.length, betInToken, address(this), price);
		_lotteries[lotteryId].amount += totalDyna;
		
		// Create Tickets
		for (uint256 i = 0; i < tickets.length; i++) {
            uint32 number = tickets[i];

            require((number >= 0) && (number <= 999999), "Ticket Number Outside range");

            _tickets[currentTicketId] = Ticket({number: number, player: msg.sender});
			 _players[msg.sender][lotteryId].push(currentTicketId);
			 
            currentTicketId++;	
        }

		_lotteries[lotteryId].lastTicketId = currentTicketId;
        emit NewBet(msg.sender, betInToken, lotteryId, tickets.length);		
	}
		
	// Start New Lottery
	function createLottery(uint256 endTime) public onlyOperator returns(Lottery memory)  {
		uint256 nextAmount = 0;
		
		if(currentLotteryId != 0) {
			for (uint256 i = 0; i < _lotteries[currentLotteryId].amountsPerBracket.length; i++) 
				nextAmount += _lotteries[currentLotteryId].amountsPerBracket[i] * _lotteries[currentLotteryId].winnersPerBracket[i];
			nextAmount = _lotteries[currentLotteryId].amount - nextAmount;
		}
		
		Lottery memory newLottery = Lottery({
			status: LotteryStatus.Open, 
			startTime: block.timestamp,
			endTime: endTime,
			firstTicketId: currentTicketId,
			lastTicketId: currentTicketId,
			amount: nextAmount,
			winningNumber: 0,
			winnersPerBracket: [uint32(0), uint32(0), uint32(0), uint32(0), uint32(0), uint32(0)],
			amountsPerBracket: [uint256(0), uint256(0), uint256(0), uint256(0), uint256(0), uint256(0)]
		});
		       
		currentLotteryId++;
		_lotteries[currentLotteryId] = newLottery;
		
		emit NewLottery(currentLotteryId);	
		
		return viewLottery(currentLotteryId);
	}
	
	// Draw Lottery
	function draw(uint256 lotteryId, uint256 random) public onlyOperator returns(Lottery memory)  {
        require(_lotteries[lotteryId].status == LotteryStatus.Open, "Lottery is not open");

		_lotteries[lotteryId].status = LotteryStatus.InDraw;
		_lotteries[lotteryId].winningNumber = lotteryRandom.getRandomNumber(random);
		
		emit DrawnLottery(currentLotteryId, _lotteries[lotteryId].winningNumber);	
		
		return viewLottery(currentLotteryId);
	}
	
	// Set Winners Per Bracket
	function calculWinnersPerBracket(uint256 lotteryId, uint32[6] memory winnersPerBracket,  uint32[6] memory percentsPerBracket) public onlyOperator  {
        require(_lotteries[lotteryId].status == LotteryStatus.InDraw, "Lottery is not Drawn");

		_lotteries[lotteryId].status = LotteryStatus.Close;
		_lotteries[lotteryId].winnersPerBracket = winnersPerBracket;
		
		for (uint256 i = 0; i < winnersPerBracket.length; i++) {
			if(winnersPerBracket[i] != 0)
				_lotteries[lotteryId].amountsPerBracket[i] = _lotteries[lotteryId].amount * percentsPerBracket[i] / 100 / winnersPerBracket[i];
		}
		
		emit CloseLottery(currentLotteryId);	
	}
	
	// Inject amount in lottery
	function injectFunds(uint256 lotteryId, uint256 amount) public onlyOwner  {
		_lotteries[lotteryId].amount = amount;
		
		emit FundsInjected(lotteryId, amount);	
	}
	
	// Withdrawal (for security or smart contract migration reasons)
	function withDrawalFunds(uint256 totalDYNA) public onlyOwner  {
		if(totalDYNA != 0 && lotteryPrice.DYNA() != address(0)) {
			IERC20 token = IERC20(lotteryPrice.DYNA());
			token.safeTransfer(owner(), totalDYNA);
			
			emit FundsWithDrawn(totalDYNA);	
		}
	}
	
	// Claim tickets
	function claim(uint256 lotteryId, uint256[] memory ticketIds) public {
        require(_lotteries[lotteryId].status == LotteryStatus.Close, "Lottery is not Closed");
		uint256 totalDYNA = 0;
		
		for (uint256 i = 0; i < ticketIds.length; i++) {
            uint256 id = ticketIds[i];

            require(id >= _lotteries[lotteryId].firstTicketId && id < _lotteries[lotteryId].lastTicketId, "this ticket is not in this lottery");
            require(msg.sender == _tickets[id].player, "You are not owner of this ticket, or this ticket is already claimed");
			
			uint8 matchNumber = lotteryNFT.countMatch(_tickets[id].number, _lotteries[lotteryId].winningNumber, _tickets[id].player);
			if(matchNumber != 0) {
				totalDYNA += _lotteries[lotteryId].amountsPerBracket[matchNumber - 1];
				_tickets[id].player = address(0);
			}
        }
		
		if(totalDYNA != 0 && lotteryPrice.DYNA() != address(0)) {
			IERC20 token = IERC20(lotteryPrice.DYNA());
			token.safeTransfer(msg.sender, totalDYNA);
		}
		
		emit TicketsClaimed(msg.sender, lotteryId, totalDYNA);		
	}
	
	// *****************************************
	// View Lottery Functions
	// *****************************************
	
	// View Lottery information
	function viewLottery(uint256 lotteryId) public view returns(Lottery memory) {
		return _lotteries[lotteryId];
	}
	
	// View Tickets 
	function viewTickets(uint256 lotteryId, uint256 fromTicketId, uint256 toTicketId) public view returns(TicketView[] memory) {
		fromTicketId = fromTicketId < _lotteries[lotteryId].firstTicketId ? _lotteries[lotteryId].firstTicketId : fromTicketId;
		toTicketId = toTicketId > _lotteries[lotteryId].lastTicketId ? _lotteries[lotteryId].lastTicketId : toTicketId;
		
		uint256 length = toTicketId - fromTicketId;
		TicketView[] memory Tickets = new TicketView[](length);
		
		for (uint256 i = 0; i < length; i++) {
			uint256 ticketId = i + fromTicketId;
			
			Tickets[i].id = ticketId;
			Tickets[i].number = _tickets[ticketId].number;
			Tickets[i].player = _tickets[ticketId].player;
			Tickets[i].claimed = _tickets[ticketId].player == address(0);

			if(_lotteries[lotteryId].winningNumber != 0)
				Tickets[i].matchNumber = lotteryNFT.countMatch(Tickets[i].number, _lotteries[lotteryId].winningNumber, _tickets[ticketId].player);
        }
		
		return Tickets;
	}

	// View Player information
	function viewPlayer(address player, uint256 lotteryId, uint256 from, uint256 to) public view returns(TicketView[] memory) {
		require(from < to, "from must be less than to");
		
		uint256 length = _players[player][lotteryId].length;
		length = to > length ? length - from : to - from;

		TicketView[] memory Tickets = new TicketView[](length);
		
		for (uint256 i = 0; i < length; i++) {
            uint256 ticketId = _players[player][lotteryId][i + from];
            
			Tickets[i].id = ticketId;
			Tickets[i].number = _tickets[ticketId].number;
			Tickets[i].player = _tickets[ticketId].player;
			Tickets[i].claimed = _tickets[ticketId].player == address(0);
			
			if(_lotteries[lotteryId].winningNumber != 0)
				Tickets[i].matchNumber = lotteryNFT.countMatch(Tickets[i].number, _lotteries[lotteryId].winningNumber, _tickets[ticketId].player);
        }
		
		return Tickets;
	}
	
	// *****************************************
	// Admin Lottery Functions
	// *****************************************

	// Change Lottery Price Manager
	function changeLotteryPrice(address lotteryPriceAddress) public onlyOwner {
		 lotteryPrice = IDynamixLotteryPrice(lotteryPriceAddress);
		 emit AddressConfigurationChanged("lotteryPriceAddress", lotteryPriceAddress);
	}
	
	// Change Lottery Random Manager
	function changeLotteryRandom(address lotteryRandomAddress) public onlyOwner {
		 lotteryRandom = IDynamixLotteryRandom(lotteryRandomAddress);
		 emit AddressConfigurationChanged("lotteryRandom", lotteryRandomAddress);
	}
	
	// Change Lottery NFT Manager
	function changeLotteryNFT(address lotteryNFTAddress) public onlyOwner {
		 lotteryNFT = IDynamixLotteryNFT(lotteryNFTAddress);
		 emit AddressConfigurationChanged("lotteryNFT", lotteryNFTAddress);
	}
	
	// Change bot Operator address
	function changeOperator(address operator) public onlyOwner {
		 operatorAddress = operator;
		 emit AddressConfigurationChanged("operatorAddress", operatorAddress);
	}

	// Change Ticket Price and Max ticket
	function changeTicketPrice(uint256 price, uint256 max) public onlyOwner {
		 ticketPriceInUSD = price;
		 maxTicket = max;
		 
		 emit TicketPriceChanged(ticketPriceInUSD, maxTicket);
	}
}