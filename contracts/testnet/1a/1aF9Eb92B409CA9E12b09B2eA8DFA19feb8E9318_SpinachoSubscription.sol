/**
 *Submitted for verification at BscScan.com on 2023-01-03
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
// By registering your project on Spinacho, you gain access to all offered products, including but not limited to:
//      - Querying minted NFTs from all registered collections
//      - Real-time sales and listing notifications
//      - Real-time mint notifications
//      - Access to all available collections through a single bot
//
// You can use this contract to register your project. By registering, your project will be available for selection in the Spinacho Telegram interface.
// Getting started is simple:
//      1. Register your project
//          - Registration fee is required to prevent spam attacks
//      2. Buy a subscription
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

    /** 
        @dev Constant used to indicate a taken ticker slot. 
        Requirement is that value be != uint256 default, and smaller than any possible block.timestamp 
    */
    uint256 constant private __SLOT_TAKEN = 1;
    string constant private __OWNERSHIP_ERR = "Owner function.";
    string constant private __FEE_ERR = "Insufficient fee.";
    string constant private __TICKER_TAKEN_ERR = "This ticker is already registered.";
    string constant private __TICKER_MISSING_ERR = "This ticker is not registered.";
    string constant private __WITHDRAW_ERR = "Failed to withdraw funds.";
    string constant private __TICKER_LENGTH_ERR = "Ticker is too long.";

    mapping (string => Subscription) public subscriptions;
    uint256 public regFee;
    uint256 public subFee;
    address immutable public owner;

    constructor (uint256 regFee_, uint256 subFee_) {
        owner = msg.sender;
        regFee = regFee_;
        subFee = subFee_;
    }

    /** @dev Assert value sent is greater or equal to the amount given */
    modifier requireFee(uint256 fee_) {
        require (msg.value >= fee_, __FEE_ERR);
        _;
    }

    /** @dev Assert that owner is calling the function */
    modifier requireOwner() {
        require (msg.sender == owner, __OWNERSHIP_ERR);
        _;
    }

    /** @dev Remove the given subscription */
    function deleteSubscription(string calldata ticker_) external requireOwner {
        delete subscriptions[ticker_];
    }

    /** @dev Update registration fee */
    function setRegFee(uint256 fee_) external requireOwner {
        regFee = fee_;
    }

    /** @dev Update subscription fee */
    function setSubFee(uint256 fee_) external requireOwner {
        subFee = fee_; 
    }

    /** @dev Send current balance to deployer */
    function withdrawAll() external {
        uint256 balance = address(this).balance;
        (bool success, ) = payable(owner).call{value: balance}("");
        require (success, __WITHDRAW_ERR);
    }

    /** @dev Register a new, non-active subscription */
    function register(string calldata ticker_, 
                      address collection_,
                      string calldata name_,
                      string calldata description_) external payable requireFee(regFee) {
        uint256 tickerLength = bytes(ticker_).length;
        require (tickerLength >= 2 && tickerLength <= 4, __TICKER_LENGTH_ERR);
        require (subscriptions[ticker_].expiration == 0, __TICKER_TAKEN_ERR);
        Subscription memory sub = Subscription({
            collection: collection_,
            name: name_,
            description: description_,
            expiration: __SLOT_TAKEN
        });
        subscriptions[ticker_] = sub;
    }

    /** @dev Create new, or extend existing subscription for the given number of months */
    function subscribe(string calldata ticker_, uint256 months_) external payable requireFee(months_ * subFee) {
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