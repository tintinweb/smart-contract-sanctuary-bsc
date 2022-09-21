/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

pragma solidity ^0.8.7;

contract Marblef1{

    address public adminAddress; // address of the admin
    address public operatorAddress; // address of the operator
    address public tokenAddress; // address of the betb token
    bool public pause;
    uint256 public intervalSeconds; // interval in seconds between two prediction rounds
    uint256 public bufferSeconds; // number of seconds for valid execution of a prediction round
    uint256 public currentRace; 
    uint256 public minTokenAmount;
    uint256 public minRacePrice;

    struct Marble{
        uint256 marbleId;
        string color; // color name or RGB notation for dynamic color in frontend
        uint256 totalBet; //Bet on individual Marble by all players 
        //bool isActive;
    }

    struct Race {
        uint256[] marbles; 
        bool paidOut; // after a race is paidOut it can be considered done
        uint256 startTimestamp; //unix timestamp
        uint256 lockTimestamp; //unix timestamp
        uint256 closeTimestamp; //unix timestamp
        uint256[] bets;
        int winnerIdInMarbleIdToRace; // -1 until a winner is determined
        uint256 totalBet; //Bet on all Marbles by all players
        uint256 price; //price of the race
        bool voidRace;
    }

    struct Bet {
        address payable bettorAddr;//bettor address
        bool rewarded; // if true, person already has been rewarded
        uint256 idInMarbleIdToRace; //marble on which better is betting
        uint256 betAmount; //amount they bet
    }

    mapping(address => bool) authorized;

    // lookup betIds from the uint256[] of bets in Race structs
    mapping(uint256 => Bet) private betIdToBet;
    mapping(uint256 => Marble) public marbleIdToRace;
    mapping(uint256 => Marble) public superSetmMarbles;
    mapping(uint256 => Race) public races;
    
    uint256 betsInSystem = 0;
    uint256 marblesRaceInSystem = 0;
    uint256 totalMarbles;

    address payable public ecoSystemWallet ;
    uint256 public ecoSystemFeePercentage;
    
    constructor(address payable _ecoSystemAddress, uint256 _ecoSystemFeePercentage, address _tokenAddress){
        superSetmMarbles[1] = Marble(1,"Red",0); // RGB notation to pick the color from frontend
        superSetmMarbles[2] = Marble(2,"Green",0);
        superSetmMarbles[3] = Marble(3,"Yellow",0);
        superSetmMarbles[4] = Marble(4,"Blue",0);
        superSetmMarbles[5] = Marble(5,"Violet",0);
        superSetmMarbles[6] = Marble(6,"Black",0);
        superSetmMarbles[7] = Marble(7,"Olive",0);
        superSetmMarbles[8] = Marble(8,"White",0);
        superSetmMarbles[9] = Marble(9,"Brown",0);
        superSetmMarbles[10] = Marble(10,"Pink",0);
        totalMarbles = 10;
        ecoSystemWallet = _ecoSystemAddress;
        ecoSystemFeePercentage= _ecoSystemFeePercentage;
        authorized[msg.sender] = true;
        authorized[_ecoSystemAddress] = true;

        adminAddress = msg.sender;
        operatorAddress = _ecoSystemAddress;
        tokenAddress = _tokenAddress;
        minTokenAmount = 0;
        pause = false;
        intervalSeconds = 15*60;
        bufferSeconds = 60;
        currentRace = 0;
        minRacePrice = 5000000000000000;
    }

    event StartRound(uint256 indexed race);
    event VoidRound(uint256 indexed race, bool status);

    modifier onlyAuthorized
    {
        require( authorized[msg.sender] == true, "Not Authorized to call...!" );
        _;
    }

    modifier whenNotPaused() {
        require(pause == false, "Contract is pause");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "Not admin");
        _;
    }

    modifier onlyAdminOrOperator() {
        require(msg.sender == adminAddress || msg.sender == operatorAddress, "Not operator/admin");
        _;
    }

    modifier onlyOperator() {
        require(msg.sender == operatorAddress, "Not operator");
        _;
    }

    function isAuthorized(address _address) public view returns(bool) {
        return authorized[_address];
    }
     function getNumberOfBetsOnRace(uint256 _raceIndex) public view returns(uint256) {
        return races[_raceIndex].bets.length;
    }

    function getNumberOfMarblesInRace(uint256 _raceIndex) public view returns(uint256) {
        return races[_raceIndex].marbles.length;
    }

    function getAvailableMarbleIdsInRace(uint256 _raceIndex) public view returns(uint256[] memory) {
        return races[_raceIndex].marbles;
    }
   
    function getTotalBetInRace(uint256 _raceIndex) public view returns(uint256) {
        return races[_raceIndex].totalBet;
    }

    function getRace(uint256 raceIndex) public view returns(uint256[] memory, bool, uint256, uint256, int, uint256) {
        return (races[raceIndex].marbles, races[raceIndex].paidOut, races[raceIndex].startTimestamp,
        getNumberOfBetsOnRace(raceIndex), races[raceIndex].winnerIdInMarbleIdToRace, races[raceIndex].totalBet );
    }
    
    function authorize(address _address) public onlyAuthorized {
        authorized[_address] = true;
    }

    function unAuthorize(address _address) public onlyAuthorized {
        authorized[_address] = false;
    }

    function UpdateEcoSystemWallet(address payable _ecoSystemAddress) public onlyAuthorized {
        ecoSystemWallet = _ecoSystemAddress;
    }

    function AddMarble(string memory color) public onlyAuthorized{
        totalMarbles++;
        superSetmMarbles[totalMarbles] = Marble(totalMarbles, color, 0);
    }

    function GetUnStuckBalance(address receiver, uint256 amountToWithdraw) public onlyAuthorized{
        uint256 amount = (amountToWithdraw <= address(this).balance) ? amountToWithdraw : address(this).balance;
        payable(receiver).transfer(amount);
    }

    function removeDuplicateRaces(uint256[] memory _marbleIds) private view returns(uint256[] memory _distinctMarbleIds)
    {
        uint256[] memory distinctMarbleIds = new uint256[](_marbleIds.length) ;
        uint256 k = 0;
             
        for(uint256 i=0; i< (_marbleIds.length);i++)
        {
            bool isExistsOrInvalid = false;
            uint256 id = _marbleIds[i];
            if( 0 < id && id <= totalMarbles)
            {
                for(int256 j= int256(i)-1; j >= 0 ;j--)
                {
                    if(( id ==_marbleIds[uint256(j)]) && (i!= uint256(j) ) )
                    {
                        isExistsOrInvalid = true;                        
                    }
                }
            }
            else{
                isExistsOrInvalid = true;
            }
            if(!isExistsOrInvalid){ 
                distinctMarbleIds[k] = id;
                k++;
            }
            
        }
        return removeZeroEntries(distinctMarbleIds, k);
    }
    
    function removeZeroEntries(uint256[] memory _marbleIds, uint256 nonZerolength) private pure returns(uint256[] memory _nonZeroMarblesInRace)
    {
        require(nonZerolength <= _marbleIds.length, "non ZeroValues length is greater than actual array size..!");
        uint256[] memory nonZeroMarblesInRace = new uint256[](nonZerolength);

        uint256 j = 0;
        for(uint256 i=0; i< _marbleIds.length && j< nonZerolength; i++)
        {
            uint256 id = _marbleIds[i];
            if( id != 0)
            {
                nonZeroMarblesInRace[j] = id;
                j++;
            }
        }

        return nonZeroMarblesInRace;
    }

    function newRace(uint256[] memory _marbleIds, uint256 _raceTime, uint256 _racePrice) public whenNotPaused onlyAdminOrOperator {
        require( _marbleIds.length >= 7 , "Atleast 7 marbles!");
        require(_raceTime > block.timestamp, "Race must take place for future");
        require(_racePrice > minRacePrice, "price must be greater than min limit");

        uint256[] memory bets;
        currentRace = currentRace + 1;

        Race storage races = races[currentRace];
        races.marbles = _marbleIds;
        races.paidOut = false;
        races.startTimestamp = _raceTime;
        races.lockTimestamp = _raceTime + intervalSeconds;
        races.closeTimestamp = _raceTime + (2 * intervalSeconds);
        races.bets = bets;
        races.winnerIdInMarbleIdToRace = -1;
        races.totalBet = 0;
        races.price = _racePrice;
        races.voidRace = false;

        emit StartRound(currentRace);
    }

    function setVoidRace(uint256 _raceIndex, bool _status) public whenNotPaused onlyAdminOrOperator {
        require(races[_raceIndex].closeTimestamp > block.timestamp, "Race already finished");
        Race storage races = races[currentRace];
        races.voidRace = _status;

        emit VoidRound(_raceIndex, _status);
    }

    function claimBetAmt(uint256 _raceIndex) public whenNotPaused onlyAdminOrOperator {
        require(races[_raceIndex].voidRace == true, "raceIndex is not yet void");
    }


    function createBet(uint256 _raceIndex, uint256 _marbleIndex, uint256 _amount) public payable{
        require(msg.value >= _amount,
            "Bet amount must be equal or less than sent amount");
        //require(_raceIndex < races.length, "Race does not exist");
        require(races[_raceIndex].lockTimestamp > block.timestamp, "Race has already run");
        require((_marbleIndex >= 0 && _marbleIndex < races[_raceIndex].marbles.length),
            "Marble number does not exist in this race");
        
        betsInSystem++;
        uint256 newBetId = (betsInSystem);
        
        races[_raceIndex].totalBet += _amount; //adding total amount for all marbles in race

        uint256 _marbleIdToRaceId = races[_raceIndex].marbles[_marbleIndex] ;
        marbleIdToRace[_marbleIdToRaceId].totalBet += _amount; //adding participants amount for indvidual marbles in race
        betIdToBet[newBetId] = Bet(payable(msg.sender), false, _marbleIdToRaceId, _amount);
        races[_raceIndex].bets.push(newBetId);
    }


    
    // do we need ths as a payable? as we are not specifying how much to send and sending from self wallet
    function evaluateRace(uint256 _raceIndex, int256 _winnerMarbleIndex ) public onlyAuthorized payable{
        require(races[_raceIndex].closeTimestamp > block.timestamp, "Race not yet finished");
        require(races[_raceIndex].paidOut == false, "Race already evaluated");
        //require(_raceIndex < races.length, "Race does not exist");

        uint256 _idInMarbleIdToRace = races[_raceIndex].marbles[uint256(_winnerMarbleIndex)];
        uint256 _totalRaceBet = races[_raceIndex].totalBet;
        uint256 _totalWinnerMarbleBet = marbleIdToRace[_idInMarbleIdToRace].totalBet;

        uint256 _ecoSystemBalance = (_totalRaceBet * ecoSystemFeePercentage) > 100 ? (_totalRaceBet * ecoSystemFeePercentage) / 100 : 0;
        uint256 _remainingBalance = _totalRaceBet - _ecoSystemBalance;

       
        ecoSystemWallet.transfer(_ecoSystemBalance);
        
        if( (races[_raceIndex].bets.length > 0) && (_totalWinnerMarbleBet > 0) ){
            uint256 _multiplierPercentage = (_remainingBalance * 100) /  _totalWinnerMarbleBet;
            for(uint256 i = 0; i < races[_raceIndex].bets.length; i++){
                Bet memory tempBet = betIdToBet[races[_raceIndex].bets[i]];
                if(tempBet.idInMarbleIdToRace == _idInMarbleIdToRace) {
                    uint256 _betAmount = tempBet.betAmount;
                    uint256 winAmount = (_betAmount * _multiplierPercentage) > 100 ? (_betAmount * _multiplierPercentage) / 100 : 0;
                    require(address(this).balance > winAmount, "Not enough funds to reward bettor");
                    tempBet.bettorAddr.transfer(winAmount);
                }
            }
        }

        races[_raceIndex].paidOut = true;
        races[_raceIndex].winnerIdInMarbleIdToRace =  int(_idInMarbleIdToRace);
    }
    receive() payable external {}
}