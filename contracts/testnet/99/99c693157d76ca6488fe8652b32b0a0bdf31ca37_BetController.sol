// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Bet.sol";
  
contract BetController {

    address payable owner;
    address payable donationWallet;

    mapping(address => address[]) OpenBets;
    mapping(address => address[]) ClosedBets;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    //contract settings
    constructor() {
        owner = payable(msg.sender); // setting the contract creator
    }

    //TestInput "test2", "test desc",[], ["opt1","opt2"], 0, false, 10, 3, 100, false
    //public function to make donate
    function CreateBetContract(string memory title, 
                        string memory description,
                        address[] memory whitelistedAddresses,
                        string[] memory options, 
                        uint pickedOption, 
                        bool multipleEntries, 
                        uint256 value, 
                        uint maxP, 
                        uint verificationPercent, 
                        bool donation
                        )
                        public 
                        payable
                        returns(address)
    {
        require(value == msg.value, "Bet value was not transferred");
        
        try new BetContract(msg.sender) returns (BetContract newContract){
            newContract.SetBetState(BetStateIdentifier.OPEN);
            newContract.SetWhitelistedAddresses(whitelistedAddresses);
            newContract.SetTitle(title);
            newContract.SetDescription(description);
            newContract.SetMultipleEntries(multipleEntries);
            newContract.SetValue(value);
            newContract.SetMaxParticpants(maxP <= 0 ? 10000 : maxP);
            newContract.SetVerificationPercent(verificationPercent);
            newContract.SetDonationFlag(donation);

            for(uint i=0; i < options.length; i++){
                newContract.PushOption(options[i]);
            }

            newContract.AddParticipant(pickedOption);          

            if(donation){
                uint256 zeroPoint0 = msg.value / 1000;
                payable(newContract).transfer(zeroPoint0 * 999);
                payable(donationWallet).transfer(zeroPoint0);
            }else{
                payable(newContract).transfer(msg.value);
            }

            OpenBets[msg.sender].push(address(newContract));

            return address(newContract);

        } catch {
            return address(0);
        }
    }

    function RevertBet(address betAddress) public payable{
        IBetContract(betAddress).RevertBet();
    }

    /*
    Function to participate in a specific Bet
    Params
    1. betAddress - Type of 'address' - the Bet address in which the user wants to participate
    */
    function ParticipateInBet(address betAddress, uint optionIndex) public payable{
        //Get Bet with betAddress
        IBetContract currentBet = IBetContract(betAddress);

        //Check if Bet still takes participants and if the transferred value is equal to the Bet value
        require(currentBet.GetParticipants().length < currentBet.GetMaxParticipants(), "The Bet is full already");
        require(currentBet.GetValue() == msg.value, "The transferred value is not equal to the Bet value");
        require(currentBet.IsWhitelisted(msg.sender), "The user is not in the Bet Whitelist");
    
        //Add Participat to Bet
        currentBet.AddParticipant(optionIndex);

        if(currentBet.GetDonationFlag()){
            uint256 zeroPoint0 = msg.value / 1000;
            payable(betAddress).transfer(zeroPoint0 * 999);
            payable(donationWallet).transfer(zeroPoint0);
        }else{
            payable(betAddress).transfer(msg.value);
        }

        //Add Participant to OpenBets
        OpenBets[msg.sender].push(address(currentBet));
    }

    function Withdraw(address betAddress) public{
        
    }

    function ChooseWinner(address betAddress, uint betOption) public {
         //Get Bet with betAddress
        IBetContract currentBet = IBetContract(betAddress);
        currentBet.AddWinnerOption(betOption);
    }

    function GetBetBalance(address betAddress) public view returns(uint256){
        return IBetContract(betAddress).GetBalance();
    }

    /*
    Function to get the particiapte count of a specific Bet
    Params
    1. betAddress - Type of 'address' - the Bet address that holds the Bet count
    Returns
    1. Type of uint - Count of Bet participants
    */
    function GetParticipateCount(address betAddress) public view returns(uint){
        IBetContract currentBet = IBetContract((betAddress));
        return currentBet.GetParticipants().length;
    }

    /*
    Function to get all the open Bets for the requesting wallet
    Returns
    1. Type of BetInformation[] Array - all the open Bet structs within an array
    */
    function GetAllOpenBets() public view returns (BetInformation[] memory){
        return FetchBetArray(BetStateIdentifier.OPEN, msg.sender);
    }

    /*
    Function to get all the open Bets for a given wallet
    Returns
    1. Type of BetInformation[] Array - all the open Bet structs within an array
    */
    function GetAllOpenBets(address sourceAddress) public view onlyOwner returns(BetInformation[] memory){
        return FetchBetArray(BetStateIdentifier.OPEN, sourceAddress);
    }

    /*
    Function to get all the closed Bets for the requesting wallet
    Returns
    1. Type of BetInformation[] Array - all the closed Bet structs within an array
    */
    function GetAllClosedBets() public view returns (BetInformation[] memory){
        return FetchBetArray(BetStateIdentifier.CLOSED, msg.sender);
    }

    /*
    Function to get all the closed Bets for a given wallet
    Returns
    1. Type of BetInformation[] Array - all the closed Bet structs within an array
    */
    function GetAllClosedBets(address sourceAddress) public view onlyOwner returns(BetInformation[] memory){
        return FetchBetArray(BetStateIdentifier.CLOSED, sourceAddress);
    }

    /*
    Internal function to filter open and closed bets based on a source address
    */
    function FetchBetArray(BetStateIdentifier state, address sourceAddress) internal view returns(BetInformation[] memory){
        mapping(address => address[]) storage currentArray = state == BetStateIdentifier.OPEN ? OpenBets : ClosedBets;
        uint betCount = currentArray[sourceAddress].length;
        BetInformation[] memory betInfoArray = new BetInformation[](betCount);
        for(uint i = 0; i < betCount; i++){
            betInfoArray[i] = IBetContract(currentArray[sourceAddress][i]).GetOwnerBet();
        }
        return(betInfoArray);
    }

    /*
    Function to get the information of a specific Bet
    Params
    1. betAddress - Type of 'address' - the Bet of which we want the details
    Returns
    1. Type of BetInformation -  BetInformation struct
    */
    function GetBetInformation(address betAddress) public view returns(BetInformation memory){
        IBetContract currentBet = IBetContract((betAddress));
        return currentBet.GetOwnerBet();
    }

}