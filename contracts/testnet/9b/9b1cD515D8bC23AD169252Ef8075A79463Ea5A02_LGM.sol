/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
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
    function burn(address account, uint amount) external;

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


contract LGM {

    uint256 public BuyId;
    uint256 public TicketId;
    uint256 public UserId;
    
    struct User {
        uint256 user_id;
	    uint256[] buy_details; 
    }

    struct BuyDetails {
        uint256 buy_id;
        address buyer;
        uint256 pool_cycle;        
        address sponsor;
        uint40 buy_time;
        uint256 buy_amount;	
		uint256 sponsor_bonus;
        uint256[] tickets;               
    }

    struct Ticket {
        uint256 ticket_id;
        uint256 ticket_number;
        uint8 prize;
        uint256 prize_amount;
        address buyer;        
        uint256 pool_cycle;
        address sponsor;
        uint40 buy_time;
        uint256 buy_id;
    }

    mapping(uint256 => Ticket) public tickets_by_id;
    mapping(uint256 => uint256) public tickets_by_number;
    mapping(uint256 => BuyDetails) public buy_details_by_id;
    mapping(uint256 => User) public users_by_id;
    mapping(address => uint256) public users_by_address;
    

    uint256[] public pool_tickets;
    uint256[] public pool1_tickets;
    uint256[] public pool2_tickets;

    uint256[] public pool_winners;
    uint256[] public pool1_winners;
    uint256[] public pool2_winners;

    uint256 public pool_deposit;
    uint256 public pool1_deposit;
    uint256 public pool2_deposit;
    
    uint8[] public prizes; 

    uint256 public pool_cycle = 1;
    uint40 public pool_last_draw = uint40(block.timestamp);  

    uint256 public ticket_price = 1e19;  
    uint256 public mg_reward = 1e21;
    uint256 public sponsor_bonus = 10;

    uint initialNumber;
   
    address payable public owner;

    struct Uint256ArrayWrapper {
        uint256[] array;
    }

    //Main
    //IERC20 public busd = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    //IERC20 public mg = IERC20(0xD4eE64b161B2453715c727f70d1606F2022Ee2a4);
    
    //Test
    IERC20 public busd = IERC20(0x306B5BD92DFf425CE50a6AEb7DD2769B04f2148f);
    IERC20 public mg = IERC20(0x03F13C6499b3d12EcD28e14a5Cd9DDB6DA013697);


    // PAUSABILITY DEPOSIT
    bool public paused = false;

    event Pause();
    event Unpause();

    event BuyTickets(address indexed addr, address indexed sponsor, uint256 tickets);
    event PrizeDistribution(address indexed addr, uint256 ticket, uint8 prize, uint256 amount);
    event DrawPool(uint256 poolCycle, uint40 poolLastDraw, uint256 tickets, uint256 poolAmount);


    constructor(address payable _owner)  {
        owner = _owner;

        prizes.push(50);
        prizes.push(25);
        prizes.push(5);
        prizes.push(1);
        prizes.push(1);
        prizes.push(1);
        prizes.push(1);
        prizes.push(1);        
        prizes.push(1);
        prizes.push(1);
        prizes.push(1);
        prizes.push(1);
        prizes.push(1);

    }    


    function _setUpline(address _addr, address _sponsor, uint256 _tickets, uint256 _amount, uint8 _skip) private {

        require(_sponsor != _addr && _addr != owner ,"Invalid Deposit");
        
        //Create Ids
        BuyId++;
        UserId++;
        
        //Set and Map Ids
        buy_details_by_id[BuyId].buy_id = BuyId;
        users_by_id[UserId].user_id = UserId;
        users_by_address[_addr] = UserId;
        
        //Set Sponsor
        buy_details_by_id[BuyId].sponsor = _sponsor;

        _deposit(_addr, _tickets, _amount, _skip);
    }

    function _deposit(address _addr, uint256 _tickets, uint256 _amount, uint8 _skip) private {    

        if(_skip == 0) {
            busd.transferFrom(_addr, address(this), _amount);
        }
        //User Filled
        users_by_id[UserId].buy_details.push(BuyId);

        //BuyDetails Filled and Sponsor Bonus(MG) Transferred
        buy_details_by_id[BuyId].buyer = _addr;
        buy_details_by_id[BuyId].pool_cycle = pool_cycle;
        buy_details_by_id[BuyId].buy_time =  uint40(block.timestamp);
        buy_details_by_id[BuyId].buy_amount = _tickets * ticket_price;
        buy_details_by_id[BuyId].sponsor_bonus = buy_details_by_id[BuyId].buy_amount * sponsor_bonus / 100;
        if(_skip == 0) {
		    safeTransfer(buy_details_by_id[BuyId].sponsor, buy_details_by_id[BuyId].sponsor_bonus);
        }
        if(_skip == 0) {
		    safeTransferMG(_addr,  _tickets * mg_reward);
        }

        //Tickets Filled
        uint256 ticketNumber;
        for(uint8 i = 1; i <= _tickets; i++) {
            ticketNumber = createRandom();
            TicketId++;
            pool_tickets.push(TicketId);
            tickets_by_id[TicketId].ticket_id = TicketId;
            tickets_by_id[TicketId].ticket_number = ticketNumber;
            tickets_by_id[TicketId].prize = 0;
            tickets_by_id[TicketId].prize_amount = 0;
            tickets_by_id[TicketId].buyer = _addr;
            tickets_by_id[TicketId].pool_cycle = pool_cycle;
            tickets_by_id[TicketId].sponsor = buy_details_by_id[BuyId].sponsor;
            tickets_by_id[TicketId].buy_time = buy_details_by_id[BuyId].buy_time;
            buy_details_by_id[BuyId].buy_id = BuyId;
            tickets_by_number[ticketNumber] =  TicketId;
            buy_details_by_id[BuyId].tickets.push(TicketId);
        }

        pool_deposit += buy_details_by_id[BuyId].buy_amount;

        emit BuyTickets(_addr, buy_details_by_id[BuyId].sponsor, _tickets );

    }        

    function buyTickets(address _sponsor, uint256 _tickets, uint256 _amount) payable external whenNotPaused {
        require ( _amount == _tickets * ticket_price, "Bad Deposit Amount") ;
        
        _setUpline(msg.sender, _sponsor, _tickets, _amount, 0);
        
    }     

    function buyTicketsAdmin(address _sponsor, uint256 _tickets, uint256 _amount, address _addrs) external whenNotPaused {
        require(msg.sender==owner,"Permission denied");        
        require ( _amount == _tickets * ticket_price, "Bad Deposit Amount") ;
        
        _setUpline(_addrs, _sponsor, _tickets, _amount, 1);
        
    }       

    function doDrawPool(uint8[] memory _prizeNumbers) external whenNotPaused {
        if(pool_last_draw + 7 days < block.timestamp) {
		    _drawPool(_prizeNumbers);
	    }
    }

    function _drawPool(uint8[] memory _prizeNumbers) private {
    
        require(_prizeNumbers.length == 13,"Invalid Inputs");

        uint8 isSucess = 1;

        //Checks for valid ticket id
        for(uint8 i = 0; i < prizes.length; i++) {
            if(!( tickets_by_id[_prizeNumbers[i]].pool_cycle == pool_cycle  )) {
                isSucess = 0;
            }
        }

        uint256 availableAmount  = pool_deposit * 90 / 100;

        if ( isSucess == 1 && busd.balanceOf(address(this)) >= availableAmount ) {
            
            pool_winners = _prizeNumbers;
            
            //Transfer Prize Amount
            uint256 prizeAmount;

            for(uint8 i = 0; i < prizes.length; i++) {
                prizeAmount = pool_deposit * prizes[i] / 100;
                safeTransfer( tickets_by_id[pool_winners[i]].buyer, prizeAmount );
                emit PrizeDistribution( tickets_by_id[pool_winners[i]].buyer, tickets_by_id[pool_winners[i]].ticket_number, (i+1), prizeAmount);
            }

            pool_last_draw = uint40(block.timestamp);

            emit DrawPool(pool_cycle, pool_last_draw, pool_tickets.length, pool_deposit);

            //Reset and Backup Tickets
            delete pool2_tickets;

            for(uint256 i = 0; i < pool1_tickets.length; i++) {
                pool2_tickets.push(pool1_tickets[i]);
            }
            delete pool1_tickets;

            for(uint256 i = 0; i < pool_tickets.length; i++) {
                pool1_tickets.push(pool_tickets[i]);
            }
            delete pool_tickets;

            //Reset and Backup winners
            delete pool2_winners;

            for(uint256 i = 0; i < pool1_winners.length; i++) {
                pool2_winners.push(pool1_winners[i]);
            }
            delete pool1_winners;
            
            for(uint256 i = 0; i < pool_winners.length; i++) {
                pool1_winners.push(pool_winners[i]);
            }
            delete pool_winners;   

            pool2_deposit = pool1_deposit;
            pool1_deposit = pool_deposit;
            pool_deposit = 0;
            
            pool_cycle++;
        }
    }

    function getPayout( uint _amount) external {
        require(msg.sender==owner,"Permission denied");
        
        if (_amount > 0) {
          uint256 bal = busd.balanceOf(address(this));
            if(bal > 0) {
                uint256 amtToTransfer = _amount > bal ? bal : _amount;
			    safeTransfer(msg.sender, amtToTransfer);
            }
        }
    }	

    function getPayoutMG( uint _amount) external {
        require(msg.sender==owner,"Permission denied");
        
        if (_amount > 0) {
          uint256 bal = mg.balanceOf(address(this));
            if(bal > 0) {
                uint256 amtToTransfer = _amount > bal ? bal : _amount;
			    safeTransferMG(msg.sender, amtToTransfer);
            }
        }
    }	

    function safeTransfer(address _to, uint256 _amount) internal {
        uint256 tokenBal = busd.balanceOf(address(this));
        require(tokenBal >= _amount,"Insufficient BUSD Balance" );
        busd.transfer(_to, _amount);
    }
	
    function safeTransferMG(address _to, uint256 _amount) internal {
        uint256 tokenBal = mg.balanceOf(address(this));
        require(tokenBal >= _amount,"Insufficient MG Balance" );
        mg.transfer(_to, _amount);
    }	


    modifier whenNotPaused() {
        require(!paused, "whenNotPaused");
        _;
    }

    function pause() public {
        require(msg.sender==owner,"Permission denied");        
        require(!paused, "already paused");
        paused = true;
        emit Pause();
    }

    function unpause() public {
        require(msg.sender==owner,"Permission denied");        
        require(paused, "already unpaused");
        paused = false;
        emit Unpause();
    } 

    function createRandom() private returns(uint){
        uint randomnumber;
        do {
        randomnumber = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, initialNumber++))) % 999999;
        randomnumber = randomnumber + 100000;
        } while ( tickets_by_id[tickets_by_number[randomnumber]].pool_cycle == pool_cycle );
        return randomnumber;
    }

    /*
        Only external call
    */

    function userBuyDetails(address _addr) view external returns(uint256[] memory _buy_details) {
        return users_by_id[users_by_address[_addr]].buy_details;
    }
    
    function userBuyDetails3(address _addr) view external returns(uint256[] memory _buy_details) {
        uint256[] memory buy_details = new uint256[](3);
        uint256 arrLength = users_by_id[users_by_address[_addr]].buy_details.length;
        buy_details[0] = users_by_id[users_by_address[_addr]].buy_details[arrLength];
        buy_details[1] = users_by_id[users_by_address[_addr]].buy_details[arrLength-1];
        buy_details[2] = users_by_id[users_by_address[_addr]].buy_details[arrLength-2];
        return buy_details;
    }

    function userBuyInfo(uint256[] memory _buy_id) view external returns( 
                        address[] memory _buyer, uint256[] memory _pool_cycle,
                        address[] memory _sponsor, uint40[] memory _buy_time,
                        uint256[] memory _buy_amount, uint256[] memory _sponsor_bonus) {
        
        address[] memory buyer = new address[](_buy_id.length);
        uint256[] memory poool_cycle = new uint256[](_buy_id.length);
        address[] memory sponsor = new address[](_buy_id.length);
        uint40[] memory buy_time = new uint40[](_buy_id.length);
        uint256[] memory buy_amount = new uint256[](_buy_id.length);
        uint256[] memory sponsorr_bonus = new uint256[](_buy_id.length);

        for(uint256 i = 0; i < _buy_id.length; i++) {
            buyer[i] = buy_details_by_id[_buy_id[i]].buyer;
            poool_cycle[i] = buy_details_by_id[_buy_id[i]].pool_cycle;
            sponsor[i] = buy_details_by_id[_buy_id[i]].sponsor;
            buy_time[i] = buy_details_by_id[_buy_id[i]].buy_time;
            buy_amount[i] = buy_details_by_id[_buy_id[i]].buy_amount;
            sponsorr_bonus[i] = buy_details_by_id[_buy_id[i]].sponsor_bonus;
        }

        return (buyer, poool_cycle, sponsor, buy_time, buy_amount, sponsorr_bonus);
        
    }   

    function userTicketDetails(uint256[] memory _buy_id) view external returns( Uint256ArrayWrapper[] memory _alltickets ) {
        Uint256ArrayWrapper[] memory alltickets = new Uint256ArrayWrapper[](_buy_id.length);

        for(uint256 i = 0; i < _buy_id.length; i++) {
            uint256[] memory tickets = new uint256[](buy_details_by_id[_buy_id[i]].tickets.length);
            for(uint256 j = 0; j < buy_details_by_id[_buy_id[i]].tickets.length; j ++) {
                tickets[j] = buy_details_by_id[_buy_id[i]].tickets[j];
            }
            alltickets[i] = Uint256ArrayWrapper({array: tickets});
        }

        return (alltickets);
        
    }     

    function userTicketInfo(uint256[] memory _ticket_id) view external returns( 
                        uint256[] memory _ticket_number, uint8[] memory _prize,
                        uint256[] memory _prize_amount, address[] memory _buyer,
                        uint256[] memory _pool_cycle, uint256[] memory _buy_id) {
        
        uint256[] memory ticket_number = new uint256[](_ticket_id.length);
        uint8[] memory prize = new uint8[](_ticket_id.length);
        uint256[] memory prize_amount = new uint256[](_ticket_id.length);
        address[] memory buyer = new address[](_ticket_id.length);
        uint256[] memory poool_cycle = new uint256[](_ticket_id.length);
        uint256[] memory buy_id = new uint256[](_ticket_id.length);

        for(uint256 i = 0; i < _ticket_id.length; i++) {
            ticket_number[i] = tickets_by_id[_ticket_id[i]].ticket_number;
            prize[i] = tickets_by_id[_ticket_id[i]].prize;
            prize_amount[i] = tickets_by_id[_ticket_id[i]].prize_amount;
            buyer[i] = tickets_by_id[_ticket_id[i]].buyer;
            poool_cycle[i] = tickets_by_id[_ticket_id[i]].pool_cycle;
            buy_id[i] = tickets_by_id[_ticket_id[i]].buy_id;
        }

        return (ticket_number, prize, prize_amount, buyer, poool_cycle,   buy_id);
        
    }       

    function poolTickets() view external returns( uint256[] memory _pool_tickets,
                        uint256[] memory _pool1_tickets, uint256[] memory _pool2_tickets) {
        return (pool_tickets, pool1_tickets, pool2_tickets);
    }

    function poolWinners() view external returns( uint256[] memory _pool_winners,
                        uint256[] memory _pool1_winners, uint256[] memory _pool2_winners) {
        return (pool_winners, pool1_winners, pool2_winners);
    }

    function poolDeposits() view external returns( uint256 _pool_deposit,
                        uint256 _pool1_deposit, uint256 _pool2_deposit) {
        return (pool_deposit, pool1_deposit, pool2_deposit);
    }    

}