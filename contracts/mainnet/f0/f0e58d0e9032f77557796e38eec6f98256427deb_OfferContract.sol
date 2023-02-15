/**
 *Submitted for verification at BscScan.com on 2023-02-15
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
    mapping(uint256 => mapping(uint256 => Offer)) public submittedOffers; 




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

function getRandomOffers(uint256 _tokenId) public view returns (address[] memory wallets, uint256[] memory offerNumbers, uint256[] memory prices) {
    wallets = new address[](3);
    offerNumbers = new uint256[](3);
    prices = new uint256[](3);

    uint256[] memory offerIndices = new uint256[](offerCount);
    for (uint256 i = 0; i < offerCount; i++) {
        offerIndices[i] = i + 1;
    }

    // shuffle offer indices
    for (uint256 i = offerCount - 1; i > 0; i--) {
        uint256 j = uint256(keccak256(abi.encodePacked(block.timestamp, i))) % (i + 1);
        uint256 temp = offerIndices[i];
        offerIndices[i] = offerIndices[j];
        offerIndices[j] = temp;
    }

    // select first three offers
    for (uint256 i = 0; i < 3; i++) {
        wallets[i] = offers[_tokenId][offerIndices[i]].wallet;
        offerNumbers[i] = offers[_tokenId][offerIndices[i]].offerNumber;
        prices[i] = offers[_tokenId][offerIndices[i]].price;
    }
}

function gettenRandomOffers(uint256 _tokenId) public view returns (address[] memory wallets, uint256[] memory offerNumbers, uint256[] memory prices) {
    wallets = new address[](10);
    offerNumbers = new uint256[](10);
    prices = new uint256[](10);

    uint256[] memory offerIndices = new uint256[](offerCount);
    for (uint256 i = 0; i < offerCount; i++) {
        offerIndices[i] = i + 1;
    }

    // shuffle offer indices
    for (uint256 i = offerCount - 1; i > 0; i--) {
        uint256 j = uint256(keccak256(abi.encodePacked(block.timestamp, i))) % (i + 1);
        uint256 temp = offerIndices[i];
        offerIndices[i] = offerIndices[j];
        offerIndices[j] = temp;
    }

    // select first three offers
    for (uint256 i = 0; i < 10; i++) {
        wallets[i] = offers[_tokenId][offerIndices[i]].wallet;
        offerNumbers[i] = offers[_tokenId][offerIndices[i]].offerNumber;
        prices[i] = offers[_tokenId][offerIndices[i]].price;
    }
}


        function submitOffer(uint256 _tokenId, uint256 _price) public {
        offerCount++;
        offers[_tokenId][offerCount] = Offer({
            wallet: msg.sender,
            offerNumber: offerCount,
            price: _price
        });
    }

        
function submitOfferTime(uint256 _tokenId, uint256 _price) public {
require(block.timestamp <= acceptingOffersUntil[_tokenId], "Offers are not being accepted at this time.");
offerCount++;
offers[_tokenId][offerCount] = Offer({
wallet: msg.sender,
offerNumber: offerCount,
price: _price
});
submittedOffers[_tokenId][offerCount] = Offer({
wallet: msg.sender,
offerNumber: offerCount,
price: _price
});
}

function getRandomSubmittedOffers(uint256 _tokenId) public view returns (address[] memory wallets, uint256[] memory offerNumbers, uint256[] memory prices) {
    wallets = new address[](3);
    offerNumbers = new uint256[](3);
    prices = new uint256[](3);

    uint256[] memory offerIndices = new uint256[](offerCount);
    for (uint256 i = 0; i < offerCount; i++) {
        offerIndices[i] = i + 1;
    }

    // shuffle offer indices
    for (uint256 i = offerCount - 1; i > 0; i--) {
        uint256 j = uint256(keccak256(abi.encodePacked(block.timestamp, i))) % (i + 1);
        uint256 temp = offerIndices[i];
        offerIndices[i] = offerIndices[j];
        offerIndices[j] = temp;
    }

    // select first three offers
    uint256 count = 0;
    for (uint256 i = 0; i < offerCount && count < 3; i++) {
        Offer memory offer = submittedOffers[_tokenId][offerIndices[i]];
        if (offer.wallet != address(0)) {
            wallets[count] = offer.wallet;
            offerNumbers[count] = offer.offerNumber;
            prices[count] = offer.price;
            count++;
        }
    }
}

function gettenRandomSubmittedOffers(uint256 _tokenId) public view returns (address[] memory wallets, uint256[] memory offerNumbers, uint256[] memory prices) {
    wallets = new address[](10);
    offerNumbers = new uint256[](10);
    prices = new uint256[](10);

    uint256[] memory offerIndices = new uint256[](offerCount);
    for (uint256 i = 0; i < offerCount; i++) {
        offerIndices[i] = i + 1;
    }

    // shuffle offer indices
    for (uint256 i = offerCount - 1; i > 0; i--) {
        uint256 j = uint256(keccak256(abi.encodePacked(block.timestamp, i))) % (i + 1);
        uint256 temp = offerIndices[i];
        offerIndices[i] = offerIndices[j];
        offerIndices[j] = temp;
    }

    // select first three offers
    uint256 count = 0;
    for (uint256 i = 0; i < offerCount && count < 10; i++) {
        Offer memory offer = submittedOffers[_tokenId][offerIndices[i]];
        if (offer.wallet != address(0)) {
            wallets[count] = offer.wallet;
            offerNumbers[count] = offer.offerNumber;
            prices[count] = offer.price;
            count++;
        }
    }
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