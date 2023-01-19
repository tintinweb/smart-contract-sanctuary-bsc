/**
 *Submitted for verification at BscScan.com on 2023-01-18
*/

//   /$$$$$$            /$$                               /$$                
//  /$$__  $$          |__/                              | $$                
// | $$  \__/  /$$$$$$  /$$ /$$$$$$$   /$$$$$$   /$$$$$$$| $$$$$$$   /$$$$$$ 
// |  $$$$$$  /$$__  $$| $$| $$__  $$ |____  $$ /$$_____/| $$__  $$ /$$__  $$
//  \____  $$| $$  \ $$| $$| $$  \ $$  /$$$$$$$| $$      | $$  \ $$| $$  \ $$
//  /$$  \ $$| $$  | $$| $$| $$  | $$ /$$__  $$| $$      | $$  | $$| $$  | $$
// |  $$$$$$/| $$$$$$$/| $$| $$  | $$|  $$$$$$$|  $$$$$$$| $$  | $$|  $$$$$$/
//  \______/ | $$____/ |__/|__/  |__/ \_______/ \_______/|__/  |__/ \______/ 
//           | $$                                                            
//           | $$                                                            
//           |__/       
//
// Spinacho is a Telegram NFT bot.
//
// Current support is limited to BNBChain. If you require it on other chains, get in contact with @Lizardev (contact listed below).
//
// By subscribing your project on Spinacho, you gain access to all offered perks, including but not limited to:
//      - Querying minted NFTs from all subscribed collections
//      - Realtime mint notifications
//      - Realtime marketplace notifications
//      - Access to all subscribed collections through a single bot
//
// You can use this contract to subscribe your project. By subscribing, your project will be available for selection in the Spinacho Telegram interface.
// Getting started is simple:
//      1. Register your project
//          - Registration gives you one-month subscription for free
//      2. Extend or renew subscription
//          - You can buy as many months as you want
//          - If the subscription expires, you project will still be available for non-realtime queries (viewing etc.)
//          - For receiving live notifications about on-chain events, an active subscription is required
//
// Spinacho is made by @lizardev
// 
// https://spinacho.org     -> Official website
// https://t.me/SpinachoBot -> Link to the bot
// https://t.me/Lizardev    -> Contact for questions and support
// https://chainlegion.com  -> NFT project by @Lizardev, on BNBChain
// https://github.com/eldar-tree/spinacho-docs -> In-depth documentation
//_________________________________________________________________________________________________________________________
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

struct Subscription {
    address collection;
    string name;
    string description;
    uint256 expiration;
}

contract SpinachoSubscription {

    string constant private __OWNERSHIP_ERR = "Owner function.";
    string constant private __FEE_ERR = "Insufficient fee.";
    string constant private __TICKER_TAKEN_ERR = "This ticker is already registered.";
    string constant private __TICKER_MISSING_ERR = "This ticker is not registered.";
    string constant private __WITHDRAW_ERR = "Failed to withdraw funds.";
    string constant private __TICKER_LENGTH_ERR = "Ticker is too long.";
    string constant private __COLLECTION_TAKEN_ERR = "Collection already registered";

    mapping (string => Subscription) public subscriptions;
    mapping (address => bool) public collections;
    uint256 public subFee;
    address immutable public owner;

    constructor (uint256 subFee_) {
        owner = msg.sender;
        subFee = subFee_;
    }

    /** @dev Remove the given subscription */
    function deleteSubscription(string calldata ticker_) external {
        require (msg.sender == owner, __OWNERSHIP_ERR);
        delete subscriptions[ticker_];
    }

    /** @dev Update subscription fee */
    function setSubFee(uint256 fee_) external {
        require (msg.sender == owner, __OWNERSHIP_ERR);
        subFee = fee_; 
    }

    /** @dev Send current balance to deployer */
    function withdrawAll() external {
        uint256 balance = address(this).balance;
        (bool success, ) = payable(owner).call{value: balance}("");
        require (success, __WITHDRAW_ERR);
    }

    /** @dev Register a new collection with a 31-day automatic subscription */
    function createSubscription(string calldata ticker_, 
                                address collection_,
                                string calldata name_,
                                string calldata description_) external {
        uint256 tickerLength = bytes(ticker_).length;
        
        require (tickerLength >= 2 && tickerLength <= 4, __TICKER_LENGTH_ERR);
        require (subscriptions[ticker_].expiration == 0, __TICKER_TAKEN_ERR);
        require (!collections[collection_], __COLLECTION_TAKEN_ERR);

        Subscription memory sub = Subscription({
            collection: collection_,
            name: name_,
            description: description_,
            expiration: block.timestamp + 31 days
        });

        subscriptions[ticker_] = sub;
        collections[collection_] = true;
    }

    /** @dev Create new, or extend existing subscription for the given number of months */
    function extendSubscription(string calldata ticker_, uint256 months_) external payable {
        require (msg.value >= (months_ * subFee), __FEE_ERR);

        Subscription storage sub = subscriptions[ticker_];
        require (sub.expiration != 0, __TICKER_MISSING_ERR);
        
        // If subscription isn't active, restart it from this point 
        if (sub.expiration < block.timestamp) {
            sub.expiration = block.timestamp + (months_ * (31 days));
        }
        // If subscription is active, add additional months to total length
        else {
            sub.expiration += (months_ * (31 days));
        }
    }

}