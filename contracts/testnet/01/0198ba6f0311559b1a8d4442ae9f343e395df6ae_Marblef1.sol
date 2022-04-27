/**
 *Submitted for verification at BscScan.com on 2022-04-27
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-23
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract Marblef1{

    struct Marble{
        uint marbleId;
        string color;
        uint totalBet; //Bet on individual Marble by all players 
        //bool isActive;
    }

    struct Race {
        uint[] marbles; 
        bool paidOut; // after a race is paidOut it can be considered done
        uint expireTime; //unix timestamp
        uint[] bets;
        int winnerIdInMarbleIdToRace; // -1 until a winner is determined
        uint totalBet; //Bet on all Marbles by all players
    }

    struct Bet {
        address payable bettorAddr;//bettor address
        bool rewarded; // if true, person already has been rewarded
        uint idInMarbleIdToRace; //marble on which better is betting
        uint betAmount; //amount they bet
    }

    mapping(address => bool) authorized;

    // lookup betIds from the uint[] of bets in Race structs
    mapping(uint => Bet) private betIdToBet;
    mapping(uint => Marble) public marbleIdToRace;
    mapping(uint => Marble) public superSetmMarbles;

    Race[] private races;

    uint betsInSystem = 0;
    uint marblesRaceInSystem = 0;
    uint totalMarbles;

    //bytes32 public adminPassHash = keccak256(abi.encode("")); //useful for manually generating passwords
    bytes32 private adminPassHash = 0xc8d1bf7f2c23c61179850dae51b6ec884c2215578d89634882b1d4cb66984c47; //password

    address payable ecoSystemWallet ;
    uint public ecoSystemFeePercentage;

    constructor(address payable _ecoSystemAddress, uint _ecoSystemFeePercentage){
        superSetmMarbles[1] = Marble(1,"Red",0); // RGB notation to pick the color from frontend
        superSetmMarbles[2] = Marble(2,"Green",0);
        superSetmMarbles[3] = Marble(3,"Yellow",0);
        superSetmMarbles[4] = Marble(4,"Blue",0);
        superSetmMarbles[5] = Marble(5,"Violet",0);
        superSetmMarbles[6] = Marble(6,"Black",0);
        superSetmMarbles[7] = Marble(7,"Violet",0);
        superSetmMarbles[8] = Marble(8,"White",0);
        superSetmMarbles[9] = Marble(9,"Brown",0);
        superSetmMarbles[10] = Marble(10,"Pink",0);
        totalMarbles = 10;
        ecoSystemWallet = _ecoSystemAddress;
        ecoSystemFeePercentage= _ecoSystemFeePercentage;
        authorized[msg.sender] = true;
        authorized[_ecoSystemAddress] = true;
    }

    modifier onlyAuthorized
    {
        require( authorized[msg.sender] == true, "Not Authorized to call...!" );
        _;
    }

    function authorize(address _address) public onlyAuthorized {
        authorized[_address] = true;
    }

    function unAuthorize(address _address) public onlyAuthorized {
        authorized[_address] = false;
    }

    function AddMarble(string memory color) public onlyAuthorized{
        totalMarbles++;
        superSetmMarbles[totalMarbles] = Marble(totalMarbles, color, 0);
    }

    function getNumberOfBetsOnRace(uint _raceIndex) public view returns(uint) {
        return races[_raceIndex].bets.length;
    }

    function getNumberOfMarblesInRace(uint _raceIndex) public view returns(uint) {
        return races[_raceIndex].marbles.length;
    }

    function getAvailableMarblesInRace(uint _raceIndex) public view returns(uint[] memory) {
        return races[_raceIndex].marbles;
    }
   
    function getTotalBetInRace(uint _raceIndex) public view returns(uint) {
        return races[_raceIndex].totalBet;
    }

    function getNumberOfRaces() public view returns(uint) {
        return races.length;
    }

    function getRace(uint raceIndex) public view returns(uint[] memory, bool, uint, uint, int, uint) {
        return (races[raceIndex].marbles, races[raceIndex].paidOut, races[raceIndex].expireTime,
        getNumberOfBetsOnRace(raceIndex), races[raceIndex].winnerIdInMarbleIdToRace, races[raceIndex].totalBet );
    }

    function GetUnStuckBalance(address receiver, uint256 amountToWithdraw) public onlyAuthorized{
        uint256 amount = (amountToWithdraw <= address(this).balance) ? amountToWithdraw : address(this).balance;
        payable(receiver).transfer(amount);
    }

    function createRace(uint[] memory _marbleIds, uint _raceTime) public onlyAuthorized {
        require( _marbleIds.length >= 2 , "Atleast 2 marbles should be there for Race..!");
        require(_raceTime > block.timestamp, "Race must take place in the future");
        
        uint[] memory bets;
        uint[] memory marblesInRace;
        
        for(uint i=0 ; i< _marbleIds.length; i++)
        {
            uint _marblesRaceInSystem = marblesRaceInSystem + 1;
            marblesInRace[i] = _marblesRaceInSystem;
            marbleIdToRace[_marblesRaceInSystem] = superSetmMarbles[_marbleIds[i]];
        }

        races.push(Race(marblesInRace, false, _raceTime, bets, -1, 0));
    }

    function createBet(uint _raceIndex, uint _marbleIndex, uint _amount) public payable{
        require(msg.value >= _amount,
            "Bet amount must be equal or less than sent amount");
        require(_raceIndex < races.length, "Race does not exist");
        require(races[_raceIndex].expireTime > block.timestamp, "Race has already run");
        require((_marbleIndex >= 0 && _marbleIndex < races[_raceIndex].marbles.length),
            "Marble number does not exist in this race");

        betsInSystem++;
        uint newBetId = (betsInSystem);
        
        races[_raceIndex].totalBet += _amount; //adding total amount for all marbles in race

        uint _marbleIdToRaceId = races[_raceIndex].marbles[_marbleIndex] ;
        marbleIdToRace[_marbleIdToRaceId].totalBet += _amount;
        betIdToBet[newBetId] = Bet(payable(msg.sender), false, _marbleIdToRaceId, _amount);
        races[_raceIndex].bets.push(newBetId);

        //payable(address(this)).transfer(_amount);  //??

    }



    function evaluateRace(uint _raceIndex, int256 _winnerMarbleIndex ) public payable onlyAuthorized{
        require(races[_raceIndex].expireTime < block.timestamp, "Race not yet run");
        require(races[_raceIndex].paidOut == false, "Race already evaluated");
        require(_raceIndex < races.length, "Race does not exist");

        uint _idInMarbleIdToRace = races[_raceIndex].marbles[uint(_winnerMarbleIndex)];
        uint _totalRaceBet = races[_raceIndex].totalBet;
        uint _totalWinnerMarbleBet = marbleIdToRace[_idInMarbleIdToRace].totalBet;

        uint _ecoSystemBalance = (_totalRaceBet * ecoSystemFeePercentage) > 100 ? (_totalRaceBet * ecoSystemFeePercentage) / 100 : 0;
        uint _remainingBalance = _totalRaceBet - _ecoSystemBalance;

        uint multiplier = _remainingBalance /  _totalWinnerMarbleBet;

        ecoSystemWallet.transfer(_ecoSystemBalance);

        if(races[_raceIndex].bets.length > 0) {
            for(uint i = 0; i < races[_raceIndex].bets.length; i++){
                Bet memory tempBet = betIdToBet[races[_raceIndex].bets[i]];
                if(tempBet.idInMarbleIdToRace == _idInMarbleIdToRace) {
                    uint winAmount = tempBet.betAmount * multiplier;
                    require(address(this).balance > winAmount, "Not enough funds to reward bettor");
                    tempBet.bettorAddr.transfer(winAmount);
                }
            }
        }

        races[_raceIndex].paidOut = true;
        races[_raceIndex].winnerIdInMarbleIdToRace =  int(_idInMarbleIdToRace);
    }

}