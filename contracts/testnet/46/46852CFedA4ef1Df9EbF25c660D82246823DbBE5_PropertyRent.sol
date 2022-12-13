/*
  ____                            _           ____  _____       _    
 |  _ \ _ __ ___  _ __   ___ _ __| |_ _   _  |  _ \| ____|_ __ | |_  
 | |_) | '__/ _ \| '_ \ / _ \ '__| __| | | | | |_) |  _| | '_ \| __| 
 |  __/| | | (_) | |_) |  __/ |  | |_| |_| | |  _ <| |___| | | | |_  
 |_|   |_|  \___/| .__/ \___|_|   \__|\__, | |_| \_\_____|_| |_|\__| 
                 |_|                  |___/                          

*/

//SPDX-License-Identifier: MIT Licensed
pragma solidity ^0.8.6;

contract PropertyRent {
    struct property {
        address payable landlord;
        address payable rentiee;
        uint256 amountRent;
        bool status;
        uint256 timeframe;
        uint256 tokenId;
    }

    mapping(uint256 => property) public Rent;
    uint256 public PropertyRentTime = 1 minutes;
    function requestToRent(uint256 _amount, uint256 _tokenID) public {
        require(Rent[_tokenID].tokenId != _tokenID, "Rentout");
        Rent[_tokenID] = property(
            payable(msg.sender),
            payable(address(0)),
            _amount,
            false,
            0,
            _tokenID
        );
    }

    function getRent(uint256 _tokenID) public payable {
        require(
            Rent[_tokenID].amountRent == msg.value,
            "Rent amount must be same"
        );
        if (
            Rent[_tokenID].rentiee == msg.sender &&
            Rent[_tokenID].timeframe + PropertyRentTime <= block.timestamp
        ) {
            address payable landLord = Rent[_tokenID].landlord;
            landLord.transfer(msg.value);
            Rent[_tokenID].rentiee = payable(msg.sender);
            Rent[_tokenID].timeframe = block.timestamp;
        } else {
            require(!Rent[_tokenID].status, "Rentout");
            address payable landLord = Rent[_tokenID].landlord;
            landLord.transfer(msg.value);
            Rent[_tokenID].rentiee = payable(msg.sender);
            Rent[_tokenID].status = true;
            Rent[_tokenID].timeframe = block.timestamp;
        }
    }

    function UpdatePropertyStatus(uint256 _tokenID) public {
        require(Rent[_tokenID].landlord == msg.sender);
        Rent[_tokenID].status = false;
    }
}