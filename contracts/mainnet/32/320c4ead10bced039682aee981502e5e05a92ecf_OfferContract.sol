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
    
    mapping(uint256 => mapping(uint256 => Offer)) public offers;
    uint256 public offerCount;
    mapping(uint256 => uint256) public acceptingOffersUntil;


    function submitOffer(uint256 _tokenId, uint256 _price) public {
        offerCount++;
        offers[_tokenId][offerCount] = Offer({
            wallet: msg.sender,
            offerNumber: offerCount,
            price: _price
        });
    }

    function getAllOffers(uint256 _tokenId) public view returns (address[] memory wallets, uint256[] memory offerNumbers, uint256[] memory prices) {
        wallets = new address[](offerCount);
        offerNumbers = new uint256[](offerCount);
        prices = new uint256[](offerCount);

        uint256 index = 0;
        for (uint256 i = 1; i <= offerCount; i++) {
            wallets[index] = offers[_tokenId][i].wallet;
            offerNumbers[index] = offers[_tokenId][i].offerNumber;
            prices[index] = offers[_tokenId][i].price;
            index++;
        }
    }

        
    function submitOfferTime(uint256 _tokenId, uint256 _price) public {
        require(block.timestamp <= acceptingOffersUntil[_tokenId], "Offers are not being accepted at this time.");
        offerCount++;
        offers[_tokenId][offerCount] = Offer({
            wallet: msg.sender,
            offerNumber: offerCount,
            price: _price
        });
    }



    function setAcceptingOffersPeriod(uint256 _tokenId, uint256 _acceptingOffersUntil) public {
        acceptingOffersUntil[_tokenId] = _acceptingOffersUntil;
    }

    function getHighestOffer(uint256 _tokenId) public view returns (address wallet, uint256 offerNumber, uint256 price) {
        uint256 highestPrice = 0;
        for (uint256 i = 1; i <= offerCount; i++) {
            if (offers[_tokenId][i].price > highestPrice) {
                highestPrice = offers[_tokenId][i].price;
                wallet = offers[_tokenId][i].wallet;
                offerNumber = offers[_tokenId][i].offerNumber;
                price = highestPrice;
            }
        }
    }

    function getTimeRemaining(uint256 _tokenId) public view returns (uint256) {
        return acceptingOffersUntil[_tokenId] - block.timestamp;
    }
}