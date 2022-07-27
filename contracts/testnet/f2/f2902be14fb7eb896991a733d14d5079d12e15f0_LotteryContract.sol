/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract LotteryContract is Ownable {

    uint256 public currentLotteryId;
    uint256 public currentTicketId;

    enum Status {
        Pending,
        Open,
        Close,
        Claim
    }

    struct Lottery {
        Status status;
        uint256 startTime;
        uint256 endTime;
        uint256 price;
        bool    pause;       
        address token;
        uint256 addFunds;
        uint256 amount;
        uint256 firstTicketId;
        uint256 nextTicketId;
        uint256 winningTicketBlock;
        uint256 finalNumber;
        uint256[6] rewardAmountPerBracket;
        uint256[6] countWinnersPerBracket;
    }

    struct Ticket {
        uint256 number;
        address owner;
        uint256 lotteryId;
    }

    mapping(uint256 => Lottery) public lotteries;
    mapping(uint256 => Ticket)  public lotteryTicket;
    mapping(uint256 => uint256) public bracketCalculator;

    mapping(address => mapping(uint256 => uint256[])) private userTicketIdsPerLotteryId;
    // Keeps track of number of ticket per unique combination for each lotteryId
    mapping(uint256 => mapping(uint256 => uint256)) public numberTicketsPerLotteryId;

    mapping(uint256 => bool) public ticketNumber;

    event StartLottery(uint256 indexed lotteryId, uint256 startTime, uint256 endTime, uint256 price, address token);
    event CloseLottery(uint256 indexed lotteryId, uint256 time);
    event PurchaseTicket(uint256 indexed lotteryId, address indexed buyer, uint256 price, uint256 totalTickets, uint256 time);
    event GiftTicket(address owner, address receipent, uint256 ticketId, uint256 lotteryId); 
    event AdminGiveTicket(address receipent, uint256 totalTickets, uint256 lotteryId, uint256 time);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
    event AddFunds(uint256 indexed lotteryId, uint256 amount);
    event TicketsClaim(address account, uint256 rewards, uint256 lotteryId,uint256 totalTickets, uint256 time);
    event LotteryDrawn(uint256 lotteryId, uint256 finalNumber, uint256 time);

    
    constructor(){
        bracketCalculator[0] = 1;
        bracketCalculator[1] = 11;
        bracketCalculator[2] = 111;
        bracketCalculator[3] = 1111;
        bracketCalculator[4] = 11111;
        bracketCalculator[5] = 111111;   
    }


    function startLottery(uint256 _endTime, uint256 _startTime, uint256 _price, address _token, uint256[6] memory _reward) public onlyOwner {
        require(_startTime >= block.timestamp, "Invalid Time");
        require(_price > 0, "Price must be greater than 0");
       
        Lottery memory lotteryInfo;
        lotteryInfo = Lottery ({    
            status: Status.Open,                                                                                                               
            startTime : _startTime,
            endTime   : _endTime,
            price     : _price,
            pause     : false,         
            amount    : 0,
            token     : _token,
            addFunds  : 0,           
            firstTicketId : currentTicketId,
            nextTicketId : currentTicketId + 1,
            winningTicketBlock : 0,
            finalNumber :0,
            rewardAmountPerBracket : _reward,
            countWinnersPerBracket : [uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0)]
        });
        lotteries[currentLotteryId] = lotteryInfo;
        currentLotteryId++;
        emit StartLottery(currentLotteryId, _startTime, _endTime, _price, _token);
    }

    function closeLottery(uint256 _lotteryId) public onlyOwner {
      require(block.timestamp > lotteries[_lotteryId].startTime, "Lottery already started");
      require(lotteries[_lotteryId].status == Status.Open, "Lottery not open");
      lotteries[_lotteryId].status = Status.Close;
      emit CloseLottery( _lotteryId, block.timestamp);
    }

    function adminGiveTickets(uint256 _lotteryId, uint256[] memory _ticketNumber, address _receipent) public onlyOwner{
        require(_ticketNumber.length != 0, "No ticket specified");
        require(block.timestamp < lotteries[_lotteryId].startTime, "Lottery already started");
        for (uint256 i = 0; i < _ticketNumber.length; i++) {
            require(!ticketNumber[_ticketNumber[i]],"This number already exist");
            uint256 thisTicketNumber = _ticketNumber[i];
            numberTicketsPerLotteryId[_lotteryId][1 + (thisTicketNumber % 10)]++;
            numberTicketsPerLotteryId[_lotteryId][11 + (thisTicketNumber % 100)]++;
            numberTicketsPerLotteryId[_lotteryId][111 + (thisTicketNumber % 1000)]++;
            numberTicketsPerLotteryId[_lotteryId][1111 + (thisTicketNumber % 10000)]++;
            numberTicketsPerLotteryId[_lotteryId][11111 + (thisTicketNumber % 100000)]++;
            numberTicketsPerLotteryId[_lotteryId][111111 + (thisTicketNumber % 1000000)]++;
            userTicketIdsPerLotteryId[_receipent][_lotteryId].push(currentTicketId);
            lotteryTicket[currentTicketId] = Ticket({number: thisTicketNumber, owner: _receipent, lotteryId : _lotteryId});
            currentTicketId++; 
            ticketNumber[_ticketNumber[i]] = true;
        }
        emit AdminGiveTicket(_receipent,_ticketNumber.length, _lotteryId, block.timestamp); 
    }

    function buyTickets(uint256 _lotteryId, uint256[] memory _ticketNumber, uint256 _amount) public {
        require(_ticketNumber.length != 0, "No ticket specified");
        // require(block.timestamp > lotteries[_lotteryId].startTime && block.timestamp < lotteries[_lotteryId].endTime, "Lottery not open yet or completed");
        require(!lotteries[_lotteryId].pause,"Lottery is paused");
        require(lotteries[_lotteryId].status == Status.Open, "Lottery is not open");
        uint256 amount = lotteries[_lotteryId].price * _ticketNumber.length;
        require(_amount >= amount, "Less Amount");
        IERC20(lotteries[_lotteryId].token).transferFrom(msg.sender, address(this), amount);
        lotteries[_lotteryId].amount += _amount;
        for (uint256 i = 0; i < _ticketNumber.length; i++) {
            require(!ticketNumber[_ticketNumber[i]],"This number already exist");
            uint256 thisTicketNumber = _ticketNumber[i];
            numberTicketsPerLotteryId[_lotteryId][1 + (thisTicketNumber % 10)]++;
            numberTicketsPerLotteryId[_lotteryId][11 + (thisTicketNumber % 100)]++;
            numberTicketsPerLotteryId[_lotteryId][111 + (thisTicketNumber % 1000)]++;
            numberTicketsPerLotteryId[_lotteryId][1111 + (thisTicketNumber % 10000)]++;
            numberTicketsPerLotteryId[_lotteryId][11111 + (thisTicketNumber % 100000)]++;
            numberTicketsPerLotteryId[_lotteryId][111111 + (thisTicketNumber % 1000000)]++;
            userTicketIdsPerLotteryId[msg.sender][_lotteryId].push(currentTicketId);
            lotteryTicket[currentTicketId] = Ticket({number: thisTicketNumber, owner: msg.sender, lotteryId : _lotteryId});
            currentTicketId++; 
            lotteries[_lotteryId].winningTicketBlock = block.number + 1;
            ticketNumber[_ticketNumber[i]] = true;
        }
        emit PurchaseTicket(_lotteryId, msg.sender, amount, _ticketNumber.length, block.timestamp);            
    }

    function transferTicket(address _receipent, uint256 _ticketId) public {
        require(lotteryTicket[_ticketId].owner == msg.sender, "You are not owner");
        // require(block.timestamp < lotteries[lotteryTicket[_ticketId].lotteryId].startTime, "Lottery already started");
        lotteryTicket[_ticketId].owner = _receipent;
        emit GiftTicket(msg.sender, _receipent, _ticketId, lotteryTicket[_ticketId].lotteryId);  
    }
 


    function checkTicketId(uint256 _ticketId, uint256 _lotteryId) public view returns(uint256 , uint256, uint256){
        uint256 number  = lotteryTicket[_ticketId].number;
        uint256 winningNumber = lotteries[_lotteryId].finalNumber;
        uint256 j=0;
        for (uint256 i = 0; i < 6; i++) {
            if(number % (10**i) == winningNumber % (10**i)){
                j=i;
            }
        }
        uint256 totalUser = numberTicketsPerLotteryId[_lotteryId][bracketCalculator[j] + (winningNumber % 10 ** (j + 1))];      
        uint256 userrewrads = (lotteries[_lotteryId].amount + lotteries[_lotteryId].addFunds) * (lotteries[_lotteryId].rewardAmountPerBracket[j]/100) /  lotteries[_lotteryId].countWinnersPerBracket[j] + 1;
        return (userrewrads, totalUser, j);
    }   

    function claim(uint256 _ticketId, uint256 _lotteryId) public{
        require(lotteries[_lotteryId].endTime < block.timestamp, "Lottery not end yet");
        require(lotteries[_lotteryId].status == Status.Claim, "Lottery not claimable");
        require(msg.sender == lotteryTicket[_ticketId].owner, "Not the owner");
        uint256 number  = lotteryTicket[_ticketId].number;
        uint256 winningNumber = lotteries[_lotteryId].finalNumber;
        uint256 j=0;
        for (uint256 i = 0; i < 6; i++) {
            if(number % (10**i) == winningNumber % (10**i)){
                j=i;
            }
        }
        require(lotteries[_lotteryId].rewardAmountPerBracket[j] != 0, "No prize for this bracket");
        uint256 totalUser = numberTicketsPerLotteryId[_lotteryId][bracketCalculator[j] + (winningNumber % 10 ** (j + 1))];
        lotteries[_lotteryId].countWinnersPerBracket[j] += totalUser;
        lotteryTicket[_ticketId].owner = address(0);
        uint256 userrewrads = (lotteries[_lotteryId].amount + lotteries[_lotteryId].addFunds) * (lotteries[_lotteryId].rewardAmountPerBracket[j]/100) /  lotteries[_lotteryId].countWinnersPerBracket[j];
        IERC20(lotteries[_lotteryId].token).transfer(msg.sender, userrewrads);
        emit TicketsClaim(msg.sender, userrewrads, _lotteryId, _ticketId ,block.timestamp);        
    }   


    function drawnTicket(uint256 _lotteryId) public onlyOwner{
        // require(lotteries[_lotteryId].status == Status.Close, "Lottery not close");
        require(lotteries[_lotteryId].finalNumber == 0, "Already Drawn");
        lotteries[_lotteryId].finalNumber = uint(keccak256(abi.encodePacked(_lotteryId , blockhash(lotteries[_lotteryId].winningTicketBlock)))) % 1000000;      
        lotteries[_lotteryId].status = Status.Claim;
        emit LotteryDrawn(_lotteryId,  lotteries[_lotteryId].finalNumber, block.timestamp);
    } 


    function pauseLottery(uint256 _lotteryId) public onlyOwner {
        lotteries[_lotteryId].pause = !lotteries[_lotteryId].pause;
    }

    function changeRewardPer(uint256 _lotteryId, uint256[6] memory _amt) public onlyOwner {
        lotteries[_lotteryId].rewardAmountPerBracket = _amt;
    }

    function addFunds(uint256 _lotteryId, uint256 _amount) public onlyOwner {
        require(lotteries[_lotteryId].status == Status.Open, "Lottery not open");
        require(block.timestamp < lotteries[_lotteryId].endTime, "Lottery Ended");
        IERC20(lotteries[_lotteryId].token).transferFrom(msg.sender, address(this), _amount);
        lotteries[_lotteryId].addFunds += _amount;
        emit AddFunds(_lotteryId, _amount);
    }

    function withdrawFunds(uint256 _amount, address _token) public onlyOwner {
        IERC20(_token).transfer(msg.sender, _amount);
    }

    function viewUserTicketIds(address _user, uint256 _lotteryId) public view returns(uint256[] memory){
        return userTicketIdsPerLotteryId[_user][_lotteryId];
    }
 
}