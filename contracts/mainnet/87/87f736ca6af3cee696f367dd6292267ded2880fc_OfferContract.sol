/**
 *Submitted for verification at BscScan.com on 2023-02-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract OfferContract {
    struct Offer {
        address wallet;
        uint256 offerNumber;
        uint256 price;
    }
    
    mapping(uint256 => Offer) public offers;
    uint256 public offerCount;
    uint256 public acceptingOffersUntil;


    function submitOffer(uint256 _price) public {
        offerCount++;
        offers[offerCount] = Offer({
            wallet: msg.sender,
            offerNumber: offerCount,
            price: _price
        });
    }

    function getAllOffers() public view returns (address[] memory wallets, uint256[] memory offerNumbers, uint256[] memory prices) {
        wallets = new address[](offerCount);
        offerNumbers = new uint256[](offerCount);
        prices = new uint256[](offerCount);

        uint256 index = 0;
        for (uint256 i = 1; i <= offerCount; i++) {
            wallets[index] = offers[i].wallet;
            offerNumbers[index] = offers[i].offerNumber;
            prices[index] = offers[i].price;
            index++;
        }
    }

        
    function submitOfferTime(uint256 _price) public {
        require(block.timestamp <= acceptingOffersUntil, "Offers are not being accepted at this time.");
        offerCount++;
        offers[offerCount] = Offer({
            wallet: msg.sender,
            offerNumber: offerCount,
            price: _price
        });
    }



    function setAcceptingOffersPeriod(uint256 _acceptingOffersUntil) public {
        acceptingOffersUntil = _acceptingOffersUntil;
    }

    function getHighestOffer() public view returns (address wallet, uint256 offerNumber, uint256 price) {
        uint256 highestPrice = 0;
        for (uint256 i = 1; i <= offerCount; i++) {
            if (offers[i].price > highestPrice) {
                highestPrice = offers[i].price;
                wallet = offers[i].wallet;
                offerNumber = offers[i].offerNumber;
                price = highestPrice;
            }
        }
    }
}