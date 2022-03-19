/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

// SPDX-License-Identifier: MIT
// Rakeem

pragma solidity ^0.8.3;

//import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract GameSweepstakes1 {
   IERC20 public myToken;

    using SafeMath for uint256;
    uint256 public _feeDecimal = 2;
    
    bool internal locked;
    
    uint public gameID;
    address public admin;

    address payable[] public declaredWinners;
    address payable[] public players;
    uint[] public playerTickets;
    uint[] public playerPayments;
    uint[] public playerPaymentDate;
    
    bool public tokenPay = false;
    uint256 ticketAmount = 10 ether; // wei used
    uint public posibleWinners = 3; //integer
    uint public totalPercentagePayout = 90 * (10**2); // percentage  9000 = 90%
    uint256 public winnerPayoutAmount;

   // Events 
    event NewParticipant(address payable addr, uint256 gameid, uint256 amount);
    event NewWinner(address payable addr, uint256 gameid, uint256 amount);
    event WinnerWithdrawal(uint gameid,address payable addr,uint256 amount, uint256 balance);
    event ShareHolderWithdrawal(address payable addr,uint256 amount, uint256 balance);
    event Output(uint256 amount);
    event Output(Sweepstakes s);

    // controls when the game is in session
    enum Statuses { GameOpen, GameClosed }
    Statuses currentStatus;
 
    // stores all the game information
    struct Sweepstakes {
        uint  gameNumber;
        string name;
        string description;
        uint startDate;
        uint endDate;
        uint posibleWinners;
        address payable[] players;
        uint[]  playerTickets;
        uint[]  playerPayments;
        uint[]  playerPaymentDate;
        address payable[] declaredWinners;
        uint status;
        
    }

    
    mapping(uint => Sweepstakes) public Games;
    mapping(uint => address payable[])  public winnerHistory;
    mapping(uint => address payable[])  public participantHistory;
    mapping(address => uint256) public winnerFinalPay;
    mapping(uint => mapping(address => uint256)) public winnerAccounts;

     //shareholders
    address[] internal shareHolders;
    mapping(address => uint256) internal _shares;
    mapping(address => uint256) internal shareHolderBalanceOwed;
    uint256 internal _totalShares;
 
        
    constructor(address tokenContractAddress) { 
           // admin is the address deploying the contract
            admin = msg.sender; 
            gameID = 1;   
            myToken = IERC20(tokenContractAddress);    
    }



    // modifiers
    modifier onlyOwner(){
    require(msg.sender == admin,"You are not the owner");
    _;
    }
    // this modifier allows you to pass in an amount
    modifier costs (uint _amount) {
        //check price.  If the message value is >= to 2 ether then true and continue
        require(msg.value >= _amount, "Not enough amount provided");
        _;
    }
    // validate
    modifier noReentrancy() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }
     // game open
     modifier onlyWhileGameOpen{
         //check status.  Require checks to see if it is true then continue if not it is false it will halt and displays error message
        require(currentStatus == Statuses.GameOpen, "Game currently closed!");
        _;
    }

     // update create game
    function createNewGame(uint gameNumber_,string memory name_, string memory description_) public  onlyOwner returns(bool){
 
            Games[gameID] = Sweepstakes({
                    gameNumber:gameNumber_,
                    name:name_,
                    description:description_,
                    startDate:block.timestamp,
                    endDate:block.timestamp,
                    posibleWinners:posibleWinners,
                    players: players,
                    playerTickets:  playerTickets,
                    playerPayments:playerPayments,
                    playerPaymentDate:playerPaymentDate,
                    declaredWinners: declaredWinners,
                    status:1
            }); 

            return true;
    }
     // delete game
    function deleteGame(uint gameId_) public  onlyOwner returns(bool){
      delete Games[gameId_];
      return true;       
    }

    // start game
    function startGame(uint gameId_) public  onlyOwner returns(bool){
       currentStatus = Statuses.GameOpen;
       Games[gameId_].status = (currentStatus ==Statuses.GameOpen) ? 1:0;
       return (currentStatus == Statuses.GameOpen);       
    }

    // stop game
    function stopGame(uint gameId_) public  onlyOwner returns(bool){
      currentStatus = Statuses.GameClosed;
      Games[gameId_].status = (currentStatus == Statuses.GameClosed) ? 0:1;
      return (currentStatus == Statuses.GameClosed);          
    }

    
    // get contract balance
    function getBalance() public view returns (uint256){
        // returns the contract balance 
        return address(this).balance;
    }

    function setTokenContract(address newAddr_) public onlyOwner returns(bool success) {
        myToken = IERC20(newAddr_);
    return true;
    }

    // set token pay
    function setTokenPay(bool tokenpay_) public onlyOwner returns (bool){
        tokenPay = tokenpay_;
        return tokenPay;
    }

   function getTokenHolderBalance(address addr) public view returns (uint256){
        // returns the contract balance 
        return myToken.balanceOf(addr);
    }


     function transferToken(address addr) public onlyOwner payable returns (bool){
        return  myToken.transfer(addr,1);
    }
      function transferTokenFrom(address addr) public onlyOwner payable returns (bool){
        return  myToken.transferFrom(msg.sender,addr,1);
    }
    
 
     function getTokenBalance() public view returns (uint256){
        // returns the contract balance 
        return myToken.balanceOf(msg.sender);
    }
   function getTokenName() public view returns (string memory){
        // returns the contract balance 
        return myToken.name();
    }

    function getTokenSymbol() public view returns (string memory){
        // returns the contract balance 
        return myToken.symbol();
    }

 
     function getTokenTotalSupply() public view returns (uint256){
        // returns the contract balance 
        return myToken.totalSupply();
    }
   
    // get ticket price
    function getTicketPrice() public view returns (uint256){
        // returns the ticket price 
        return ticketAmount;
    }
 
    /**
     * @dev generates random int *WARNING* -> Not safe for public use, vulnerbility detected
     * @return random uint
     */ 
    function random(uint num_) internal view returns(uint){
       return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, num_ , players.length)));
    }

   
     //  participants addresses
    function getCurrentPlayers() public view returns (address payable[] memory){
        // returns the address of the players
        return players;
    }
     // gets the nuber of participants
    function getCurrentPlayerCount() public view returns (uint){
        // returns the contract balance 
        return players.length;
    }
     // set ticket amount
    function setTicketAmount(uint256 fee) external onlyOwner {
        ticketAmount = fee; // set in wei
    }
 
    //  @dev withset posible winners 
    function setPosibleWinners(uint num) external onlyOwner {
        posibleWinners = num;
    }

   // set payout percentage
   function setTotalPercentagePayout(uint percent) external onlyOwner {
        totalPercentagePayout = percent;
    }

    // withdraw
    function withdraw() onlyOwner public payable{
        require(address(this).balance > 0,"You have no funds to withdraw!");
    
        (bool success, ) = payable(admin).call{value: address(this).balance }("");
        require(success, "Failed to send Ether");
    }


     // share holder withdraw
    function shareHolderWithdrawFunds(uint amount_) public returns(bool) {   
        require(shareHolderBalanceOwed[msg.sender] >= amount_, "Unavailable funds!");// guards up front
        require(amount_ > 0, "Zero funds!");
        shareHolderBalanceOwed[msg.sender] -= amount_;         // optimistic accounting
        (bool success, ) = payable(msg.sender).call{value: amount_ }("");
            require(success, "Failed to send Ether");
      
        // send notification
        emit ShareHolderWithdrawal(payable(msg.sender), amount_, shareHolderBalanceOwed[msg.sender]);
    return success;
   }
    
    // winner withdraw
    function winnerWithdrawFunds(uint gameId_, uint amount_) public returns(bool) {   
        require(gameId_ > 0, "Invalid game!");
        require(winnerAccounts[gameId_][msg.sender] >= amount_, "Unavailable funds!");// guards up front
        require(amount_ > 0, "Zero funds!");

        winnerAccounts[gameId_][msg.sender] -= amount_;         // optimistic accounting
        (bool success, ) = payable(msg.sender).call{value: amount_ }("");
            require(success, "Failed to send Ether");
       
        // send notification
        emit WinnerWithdrawal(gameId_, payable(msg.sender), amount_, winnerAccounts[gameId_][msg.sender]);
    return success;
   }

    // calc winner discount
    function calcWinnerDiscountRate(uint posibles) public pure returns (uint){  
        return ((100/(posibles + 1)) * 10**2);
    }

    function TestCal(uint posibles) public pure returns(uint){  
    uint winnerPayoutAmounta = 54000;
    return  winnerPayoutAmounta + posibles;   
    }

 
    // buy ticket
    function buyTicket() external payable costs(ticketAmount) onlyWhileGameOpen{
    //require that the transaction value to the contract is 0.1 ether
    require(msg.value > 0 , "Must send an amount");
   
            
    //makes sure that the admin can not participate in game
    require(msg.sender != admin,"Admin can not participate!");
            
    // pushing the account conducting the transaction onto the players array as a payable address
    players.push( payable(msg.sender)  );
    playerTickets.push( random(block.timestamp) % 1000000 ); 
    playerPayments.push( msg.value ); 
    playerPaymentDate.push( block.timestamp ); 

    // emit new participant
    emit NewParticipant(payable(msg.sender),gameID,msg.value);
        
    }

    // picks a winner from the sweepstakes game, and grants winner the balance of contract
    function pickWinners() public onlyOwner onlyWhileGameOpen{
        require(address(this).balance > 0, "Insufficient ticket funds!");
        //makes sure that we have enough players in the sweepstakes game  
        require(players.length >  posibleWinners , "Not enough players in the sweepstakes game.");
       
       // loop thru the number of posibles winners
        uint index;
        for(uint i = 1; i <= posibleWinners; i++){
            index = random(i) % players.length;
            //selects the winner with random number
            declaredWinners.push( players[index] );
        }
   
       // total payout pool - the pot for winners
        winnerPayoutAmount = getBalance().mul(totalPercentagePayout).div(10**(_feeDecimal + 2));

        // process winnings
        processWinner(); 
 
    }


     // process winner
     function processWinner()  internal{
        // loop thru winner and assign winning amounts
        for(uint j = 0; j< declaredWinners.length; j++){ 

            //  split the winning based on winning prices
            winnerFinalPay[declaredWinners[j]] =        
            (winnerPayoutAmount/declaredWinners.length) - (( (winnerPayoutAmount/declaredWinners.length) * calcWinnerDiscountRate(declaredWinners.length) * j )/ 10**(_feeDecimal + 2) );
            
            //pay to winner account
           // payable(declaredWinners[j]).transfer(  winnerFinalPay[declaredWinners[j]] );  
           winnerAccounts[gameID][declaredWinners[j]] += winnerFinalPay[declaredWinners[j]];
            
            // emit winner
            emit NewWinner(declaredWinners[j], gameID,  winnerFinalPay[declaredWinners[j]] );
            emit Output(  winnerFinalPay[declaredWinners[j]] );
         }
   
        //gets remaining amount -> must make admin a payable account
        payShareholders(getBalance());

        //resets the plays array once someone is picked
       // resetSweepstakes(); 
     
    }

   
    // resets the game
    function resetSweepstakes() internal {  

        // record winner data
        winnerHistory[gameID] = declaredWinners;
        //record participants
        participantHistory[gameID] = players;

        // update game struct
        Games[gameID].status = 0;
        Games[gameID].players = players;
        Games[gameID].playerTickets = playerTickets;
        Games[gameID].playerPayments = playerPayments;
        Games[gameID].playerPaymentDate = playerPaymentDate;
        Games[gameID].declaredWinners = declaredWinners;
        
        // reset game
        gameID++;
        players = new address payable[](0);
        playerTickets = new uint[](0);
        playerPayments = new uint[](0);
        playerPaymentDate = new uint[](0);

        winnerPayoutAmount = 0;
 
    }

        // add shareholder
        function addShareHolder(address account_, uint256 shares_) public onlyOwner {
            require(account_ != address(0),"Can not add account zero address!");
            require(shares_ > 0, "Share must be more than 0!");
            require(_shares[account_] == 0,"This ccount already has shares!");
            uint256 _holderShares = shares_ * (10**2);
            require((_totalShares + _holderShares) <= (100 * (10**2)),"Total shares can only be 100%!");
            shareHolders.push(account_);
            _shares[account_] = _holderShares;
            _totalShares = _totalShares + _holderShares;
        }
        
        // delete shareholder
        function deleteShareHolder(address account_) public onlyOwner {
            require(account_ != address(0),"Can not delete account zero address!");
            require(_shares[account_] > 0,"This ccount does not exist!");

            uint index;
            for (uint i = 0; i < shareHolders.length; i++) {
                if(shareHolders[i] == account_) {
                    index = i;
                }
            }
        
            if(index >= 0){
            for (uint j =  index; j < shareHolders.length - 1; j++) {
                shareHolders[j] = shareHolders[j + 1];
            }
            shareHolders.pop();
            _totalShares = _totalShares - _shares[account_];
            delete _shares[account_];
            }
    
        }
      
         // pay shareholder
        function payShareholders(uint256 amount_) public onlyOwner {
            if(shareHolders.length > 0){
                for (uint i = 0; i < shareHolders.length; i++) {
                    address s_accout = shareHolders[i];
                    uint256 _tamount = amount_.mul(getShares(s_accout)).div(10**(_feeDecimal + 2));
                // payable( _accout ).transfer( _tamount ); 
                shareHolderBalanceOwed[s_accout] += _tamount;
                }
            } 
        }

        //get total shares
        function totalShares() public view returns (uint256) {
            return _totalShares;
        }
        // get the shares of the shareholder
        function getShares(address account_) public view returns (uint256) {
            return _shares[account_];
        }
        // get the shareholder balance owed 
        function getShareholderBalceOwed(address account_) public view returns (uint256) {
            return shareHolderBalanceOwed[account_];
        }

        //get a shareholder
        function shareholder(uint256 index_) public view returns (address) {
            return shareHolders[index_];
        }
        //get share holder count
        function getShareholderCount() public view returns (uint256) {
            return shareHolders.length;
        }
        //get shareholders
        function getShareholders() public view returns (address[] memory) {
            return shareHolders;
        }


    receive()  external payable{}
   
 
}

 

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}