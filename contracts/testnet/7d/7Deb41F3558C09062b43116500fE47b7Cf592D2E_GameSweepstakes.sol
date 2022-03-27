/**
 *Submitted for verification at BscScan.com on 2022-03-26
*/

// SPDX-License-Identifier: MIT
// Rakeem

pragma solidity ^0.8.7;
 
contract GameSweepstakes {
  
    using SafeMath for uint256;
    uint256 public _feeDecimal = 2;
    
    bool internal locked;
    
    uint public gameID;
    address public admin;
 
    uint public PATICIPANT_MAX = 1000;
    uint256 public ticketAmount = 10 ether; // wei used
    uint public posibleWinners = 3; //integer
    uint public totalPercentagePayout = 90 * (10**2); // percentage  9000 = 90%
    uint public investorFee = 15 * (10**2);
    uint public investorPerStakeAmount = 1 ether;
    uint256 public winnerPayoutAmount;

   // Events 
    event NewParticipant(address payable addr, uint256 gameid, uint256 amount);
    event NewWinner(address payable addr, uint256 gameid, uint256 amount);
    event WinnerWithdrawal(uint gameid,address payable addr,uint256 amount, uint256 balance);
    event StakeholderWithdrawal(address payable addr,uint256 amount, uint256 balance);
    event Output(uint256 amount);
    event Output(Sweepstakes s);

    // game status
    enum Statuses { GameOpen, GameClosed }
    Statuses currentStatus;
 
    // game info
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
        uint[]  declaredWinnerTickets;
        uint status;
        uint draw;
    }

    
    mapping(uint => Sweepstakes) public Games;
    mapping(uint => address payable[])  public winnerHistory;
    mapping(uint => address payable[])  public participantHistory;
    mapping(address => uint256) public winnerFinalPay;
    mapping(uint => mapping(address => uint256)) public winnerAccounts;

     //stakeholders
     mapping(uint => address[]) public stakeholders;
     mapping(uint => mapping(address => uint256)) public _stakes;
     mapping(uint => mapping(address => uint256)) public stakeholderBalanceOwed;
     mapping(uint =>uint256) public _totalStakes;
 
        
    constructor() { 
            admin = msg.sender; 
            gameID = 1;     
    }

        // modifiers
        modifier onlyOwner(){
        require(msg.sender == admin,"Owner only!");
        _;
        }
        // cost 
        modifier costs (uint _amount) {
            require(msg.value >= _amount, "Incorrect amount!");
            _;
        }
        // reentrancy
        modifier noReentrancy() {
            require(!locked, "No reentrancy");
            locked = true;
            _;
            locked = false;
        }
        // game open
        modifier onlyWhileGameOpen{
            require(currentStatus == Statuses.GameOpen, "Game closed!");
            _;
        }
        // update create game
        function createNewGame(uint gameNumber_,string memory name_, string memory description_, uint startDate,uint endDate) public  onlyOwner returns(bool){
            
            require(Games[gameID].draw == 1,"Previous game not drawn!");

                gameID++;
                Games[gameID] = Sweepstakes({
                        gameNumber:gameNumber_,
                        name:name_,
                        description:description_,
                        startDate:(startDate > 0) ? startDate:block.timestamp,
                        endDate:(endDate > 0) ? endDate:block.timestamp,
                        posibleWinners:posibleWinners,
                        players: new address payable[](0),
                        playerTickets:  new uint[](0),
                        playerPayments: new uint[](0),
                        playerPaymentDate: new uint[](0),
                        declaredWinners: new address payable[](0),
                        declaredWinnerTickets: new uint[](0),
                        status:0,
                        draw:0
                }); 

                return true;
        }

        // update create game 
        function updateGame(uint gameId_, uint gameNumber_, string memory name_, string memory description_, uint startDate_, uint endDate_) public  onlyOwner returns(bool){
                        
             Games[gameId_].gameNumber = gameNumber_;
             Games[gameId_].name = name_;
             Games[gameId_].description = description_;
             Games[gameId_].startDate = startDate_;
             Games[gameId_].endDate = endDate_;
                        
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
        // contract balance
        function getBalance() public view returns (uint256){
            return address(this).balance;
        }
        // get ticket price
        function getTicketPrice() public view returns (uint256){
            // returns the ticket price 
            return ticketAmount;
        }
    
        // random uint
        function random(uint num_) internal view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, num_ , Games[gameID].players.length)));
        }
        //  participants addresses
        function getCurrentPlayers() public view returns (address payable[] memory){
            return Games[gameID].players;
        }
    function getCurrentPlayerTickets() public view returns (uint[] memory){
            return Games[gameID].playerTickets;
        }
    function getCurrentPlayerPayments() public view returns (uint[] memory){
            return Games[gameID].playerPayments;
        }
    function getCurrentPlayerPaymentDates() public view returns (uint[] memory){
            return Games[gameID].playerPaymentDate;
        }
    function getCurrentDeclaredWinners() public view returns (address payable[] memory){
            return Games[gameID].declaredWinners;
        }
    function getCurrentDeclaredWinnerTickets() public view returns (uint[] memory){
            return Games[gameID].declaredWinnerTickets;
        }
        function getWinnerBalanceOwed(uint gameId_) public view returns (uint256) {
        return winnerAccounts[gameId_][msg.sender];
        }
        function getCurrentPlayerCount() public view returns (uint){
            return Games[gameID].players.length;
        }
        // set ticket amount
        function setTicketAmount(uint256 fee) external onlyOwner {
            ticketAmount = fee; // set in wei
        }
        function setPosibleWinners(uint num) external onlyOwner {
            posibleWinners = num;
            Games[gameID].posibleWinners = num;
        }
        function setTotalPercentagePayout(uint percent) external onlyOwner {
                totalPercentagePayout = percent;
            }
        function setInvestorPerStakeAmount(uint amount) external onlyOwner {
                investorPerStakeAmount = amount;
            }
        function setInvestorFee(uint percent) external onlyOwner {
                investorFee = percent;
        }
        // set capacity
        function setMaximunCapacity(uint capacity) external onlyOwner {
                PATICIPANT_MAX = capacity;
            }
        // withdraw
        function withdraw() onlyOwner public payable{
            require(address(this).balance > 0,"No funds!");
        
            (bool success, ) = payable(admin).call{value: address(this).balance }("");
            require(success, "Failed to send Ether");
        }

        // stake holder withdraw
        function stakeholderWithdrawFunds(uint amount_) public returns(bool) {   
            require(stakeholderBalanceOwed[gameID][msg.sender] >= amount_, "Unavailable funds!");// guards up front
            require(amount_ > 0, "Zero funds!");
            stakeholderBalanceOwed[gameID][msg.sender] -= amount_;         // optimistic accounting

            // send notification
            emit StakeholderWithdrawal(payable(msg.sender), amount_, stakeholderBalanceOwed[gameID][msg.sender]);

            (bool success, ) = payable(msg.sender).call{value: amount_ }("");
        require(success, "Failed to send Ether");
        return success;
    }
        
        // winner withdraw
        function winnerWithdrawFunds(uint gameId_, uint amount_) public returns(bool) {   
            require(gameId_ > 0, "Invalid game!");
            require(winnerAccounts[gameId_][msg.sender] >= amount_, "Unavailable funds!");// guards up front
            require(amount_ > 0, "Zero funds!");

            winnerAccounts[gameId_][msg.sender] -= amount_;      
            // send notification
            emit WinnerWithdrawal(gameId_, payable(msg.sender), amount_, winnerAccounts[gameId_][msg.sender]);

            (bool success, ) = payable(msg.sender).call{value: amount_ }("");
                require(success, "Failed to send Ether");
            return success;
    }

        // calc winner discount
        function calcWinnerDiscountRate(uint posibles) public pure returns (uint){  
            return ((100/(posibles + 1)) * 10**2);
        }
    
        function investorPayment(uint quantity) external payable {
            //require that the transaction value to the contract is 0.1 ether
            require(Games[gameID].draw == 0, "Game closed!");   
            require(Games[gameID].status == 1 , "Game paused!");  
            require(msg.value > 0 , "Must send an amount");
            require(msg.value >= (quantity * investorPerStakeAmount) , "Insuficient amount!");
            //makes sure that the admin can not participate in game
            require(msg.sender != admin,"Admin can not participate!");

            payable(msg.sender).transfer(msg.value - (quantity * investorPerStakeAmount));
 
        }
    
        // buy ticket
        function buyTicket() external payable costs(ticketAmount) onlyWhileGameOpen{
        require(Games[gameID].draw == 0 , "Game closed!");   
        require(Games[gameID].status == 1 , "Game paused!");  
        require(msg.value > 0 , "Must send an amount");
        require(Games[gameID].players.length <= PATICIPANT_MAX , "We are at max capacity!");   
        require(msg.sender != admin,"Admin can not participate!");
                
        Games[gameID].players.push( payable(msg.sender)  );
        Games[gameID].playerTickets.push( random(block.timestamp) % 1000000 ); 
        Games[gameID].playerPayments.push( msg.value ); 
        Games[gameID].playerPaymentDate.push( block.timestamp ); 

        // emit new participant
        emit NewParticipant(payable(msg.sender),gameID,msg.value);
            
        }
 
        // picks a winner 
        function pickWinners() public onlyOwner onlyWhileGameOpen {
            require(Games[gameID].draw == 0 , "Game closed!");   
            require(address(this).balance > 0, "Insufficient ticket funds!");
            //makes sure that we have enough players in the sweepstakes game  
            require(Games[gameID].players.length >  posibleWinners , "Not enough players in the sweepstakes game.");
        
        // loop thru the number of posibles winners
            uint index;
            for(uint i = 1; i <= posibleWinners; i++){
                index = random(i) % Games[gameID].players.length;
                //selects the winner with random number
                Games[gameID].declaredWinners.push( Games[gameID].players[index] );
                Games[gameID].declaredWinnerTickets.push( Games[gameID].playerTickets[index] );
            }
    
           // total payout pool - the pot for winners
            winnerPayoutAmount = getBalance().mul(totalPercentagePayout).div(10**(_feeDecimal + 2));

            // process winnings
            processWinner(); 
    
        }


        // process winner
        function processWinner()  internal{
            // loop thru winner and assign winning amounts
            for(uint j = 0; j< Games[gameID].declaredWinners.length; j++){ 

                //  split the winning based on winning prices
                winnerFinalPay[Games[gameID].declaredWinners[j]] =        
                (winnerPayoutAmount/Games[gameID].declaredWinners.length) - (( (winnerPayoutAmount/Games[gameID].declaredWinners.length) * calcWinnerDiscountRate(Games[gameID].declaredWinners.length) * j )/ 10**(_feeDecimal + 2) );
                
                //pay to winner account 
                winnerAccounts[gameID][Games[gameID].declaredWinners[j]] += winnerFinalPay[Games[gameID].declaredWinners[j]];
                
                // emit winner
                emit NewWinner(Games[gameID].declaredWinners[j], gameID,  winnerFinalPay[Games[gameID].declaredWinners[j]] );
                emit Output(  winnerFinalPay[Games[gameID].declaredWinners[j]] );
            }
    
            //gets remaining amount -> must make admin a payable account
            payStakeholders(getBalance());

            //resets the plays  
        resetSweepstakes(); 
        
        }

   
        // resets the game
        function resetSweepstakes() internal {  
            // record winner data
            winnerHistory[gameID] = Games[gameID].declaredWinners;
            //record participants
            participantHistory[gameID] = Games[gameID].players;
            // update game struct
            Games[gameID].status = 0;
            Games[gameID].draw = 1;
            // reset game
            winnerPayoutAmount = 0;
        }

        // add stakeholder
        function addStakeholder(address account_, uint256 stakes_) public onlyOwner {
            require(account_ != address(0),"Can not add account zero address!");
            require(stakes_ > 0, "Stake must be more than 0!");
            require(_stakes[gameID][account_] == 0,"This ccount already has stakes!");
            uint256 _holderStakes = stakes_ * (10**2);
            require((_totalStakes[gameID] + _holderStakes) <= (100 * (10**2)),"Total stakes can only be 100%!");
            stakeholders[gameID].push(account_);
            _stakes[gameID][account_] = _holderStakes;
            _totalStakes[gameID] = _totalStakes[gameID] + _holderStakes;
        }
        
        // delete stakeholder
        function deleteStakeholder(address account_) public onlyOwner {
            require(account_ != address(0),"Can not delete account zero address!");
            require(_stakes[gameID][account_] > 0,"This ccount does not exist!");

            uint index;
            for (uint i = 0; i < stakeholders[gameID].length; i++) {
                if(stakeholders[gameID][i] == account_) {
                    index = i;
                }
            }
        
            if(index >= 0){
            for (uint j =  index; j < stakeholders[gameID].length - 1; j++) {
                stakeholders[gameID][j] = stakeholders[gameID][j + 1];
            }
            stakeholders[gameID].pop();
            _totalStakes[gameID] = _totalStakes[gameID] - _stakes[gameID][account_];
            delete _stakes[gameID][account_];
            }
    
        }
      
         // pay stakeholder
        function payStakeholders(uint256 amount_) public onlyOwner {
            if(stakeholders[gameID].length > 0){
                for (uint i = 0; i < stakeholders[gameID].length; i++) {
                    address s_accout = stakeholders[gameID][i];
                    uint256 _tamount = amount_.mul(getStakes(s_accout)).div(10**(_feeDecimal + 2));
                // payable( _accout ).transfer( _tamount ); 
                stakeholderBalanceOwed[gameID][s_accout] += _tamount;
                }
            } 
        }

        //get total stakes
        function totalStakes() public view returns (uint256) {
            return _totalStakes[gameID];
        }
        // get the stakes of the stakeholder
        function getStakes(address account_) public view returns (uint256) {
            return _stakes[gameID][account_];
        }
        // get the stakeholder balance owed 
        function getStakeholderBalanceOwed(address account_) public view returns (uint256) {
            return stakeholderBalanceOwed[gameID][account_];
        }

        //get a stakeholder
        function stakeholder(uint256 index_) public view returns (address) {
            return stakeholders[gameID][index_];
        }
        //get stake holder count
        function getStakeholderCount() public view returns (uint256) {
            return stakeholders[gameID].length;
        }
        //get stakeholders
        function getStakeholders() public view returns (address[] memory) {
            return stakeholders[gameID];
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