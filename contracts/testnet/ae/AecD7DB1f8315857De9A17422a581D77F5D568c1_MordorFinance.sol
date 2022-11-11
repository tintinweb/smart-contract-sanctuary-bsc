/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

// SPDX-License-Identifier: CC-BY-4.0

/**

 /$$      /$$                           /$$                     /$$$$$$$$ /$$                                                  
| $$$    /$$$                          | $$                    | $$_____/|__/                                                  
| $$$$  /$$$$  /$$$$$$   /$$$$$$   /$$$$$$$  /$$$$$$   /$$$$$$ | $$       /$$ /$$$$$$$   /$$$$$$  /$$$$$$$   /$$$$$$$  /$$$$$$ 
| $$ $$/$$ $$ /$$__  $$ /$$__  $$ /$$__  $$ /$$__  $$ /$$__  $$| $$$$$   | $$| $$__  $$ |____  $$| $$__  $$ /$$_____/ /$$__  $$
| $$  $$$| $$| $$  \ $$| $$  \__/| $$  | $$| $$  \ $$| $$  \__/| $$__/   | $$| $$  \ $$  /$$$$$$$| $$  \ $$| $$      | $$$$$$$$
| $$\  $ | $$| $$  | $$| $$      | $$  | $$| $$  | $$| $$      | $$      | $$| $$  | $$ /$$__  $$| $$  | $$| $$      | $$_____/
| $$ \/  | $$|  $$$$$$/| $$      |  $$$$$$$|  $$$$$$/| $$ /$$  | $$      | $$| $$  | $$|  $$$$$$$| $$  | $$|  $$$$$$$|  $$$$$$$
|__/     |__/ \______/ |__/       \_______/ \______/ |__/|__/  |__/      |__/|__/  |__/ \_______/|__/  |__/ \_______/ \_______/
                                                                                                                               
**/ 

pragma solidity ^0.8.7; // solhint-disable-line

contract MordorFinance {  

    // Is the miner enabled ! 
    bool public initialized=false;

    // Constants.  
    address private owner;                           // Will be renounced at initialization 
    uint256 private secondsByDay=600;                // PRD: 86400;       
    uint256 private dailyROIPercent=3;               // Rewards % of sender balance on period
    uint256 private tokenPerUnit=10000;              // How many token you get per one unit. 
    uint256 private feePercent=10;                   // Amount of fees
    uint256 private unstackFeesPercent=20;           // Amount of fee when the user unstack
    uint256 private unstackDurationPenalityDays=30;  // When user user has stacked 30 days the penality is removed
    uint256 private marketingFeePercent=40;          // Dedicated to the TVL growth
    uint256 private minClaimToAvoidSanityTax=6;      // Min claim to disable sustainability tax
    uint256 private sanityTaxAmountPercent=90;       // Sustainability tax amount 
    uint256 private effortMinPercent=1;              // The min % effort you can send to get bonus
    uint256 private effortMaxPercent=5;              // The max % effort allowed to get bonus 
    uint256 private autocompoundMinInvest=3;         // The amount that must be invested to unlock the autocompound feature
    uint256 private fightPrice=1;                    // The fixed price to fight in a battle 
    uint256 private maxHoursWithNoFight=2;           // Max period without action to close the fight 

    // Team addresses 
    address private devAddress=0x0d8dD7B14937f9c8087B644C9ab20F3B487760A5;         // The team wallet to improve contracts 
    address private marketingAddress=0x9069Ac19B7657C276008139734d5Db7a0596a3C5;   // The marketing wallet to pay bills 
    address private effortWallet=0xffb5FA2c14FB9aB5A2e1D0125517C2023879C110;       // The wallet to dispatch community effort 
 
    // Amount structure 
    struct Amounts {
        uint256 stack;                  // Total amount of the stacked value
        uint256 widthdrawal;            // Total amount of withdrawed value
        uint256 balance;                // Current balance (Stacked value + Added Rewards)
        uint256 compound;               // Compound count 
        uint256 bonusPercent;           // The bonus value percent, from [min] to [max]
    }

    // Amount structure 
    struct Dates {
        uint256 lastStack;              // The last user investment date 
        uint256 lastClaim;              // When the last claim occurs
        uint256 bonusEnd;               // The buff end date 
        uint256 lastCompound;           // Used to calculate the daily reward
        uint256 autocompoundEnabled;    // When the user has enabled the autocompound 
    }

    // The investor structure 
    struct Investor {
        string name; 
        Amounts amounts;
        Dates dates;
    }

    // Store investors 
    mapping (address => Investor) private investors;

    /**
     * Build the contract
     */
    constructor()  { 
        owner = msg.sender;
        initialize(); 
    } 
 

    /**
     * Initialize the miner, let's play. 
     * 
     */
    function initialize() public { 
        require(msg.sender == owner); 

        // Renounce owner by design
        // owner=0x0000000000000000000000000000000000000000;

        // Let's start 
        initialized=true;
    }

    /**
     * Add new liquidity to the contract balance 
     */
    function stack(address referrer) external payable {    
        require(initialized, "Not started yet !");
        uint256 amountValue=msg.value;
        uint256 fees=getDevFee(amountValue);  
                 
        // Reset the last action date 
        resetLastClaimDate(); 

        // Reset the last stack date 
        resetLastStackDate(); 
 
        // Reset the compound counter 
        resetCompoundCounter();
 
        // Dispatch fees 
        collectFees(fees);

        // Give its reward to the referrer
        handleReferrer(amountValue, referrer);    

        // Add values to balance & investments 
        investors[msg.sender].amounts.stack=add(getSenderStack(), msg.value);
    }


    /**
     * Unstack the sender investment, apply fees to retain in TVL, then transfert. 
     */
    function unstack() external payable {
        require(initialized, "Not started yet !"); 
        require(investors[msg.sender].amounts.stack > 0, "You need to stack before unstack!");         
    
        uint256 unstackFees=getUnstackFees(investors[msg.sender].amounts.stack);  
         
        // Reset the last action date 
        resetLastClaimDate(); 

        // Reset the last stack date 
        resetLastStackDate(); 
 
        // Reset the compound counter 
        resetCompoundCounter();
  
        // Transfer liquidity to user.  
        payable(msg.sender).transfer(sub(investors[msg.sender].amounts.stack, unstackFees));

        // Reset send investments.  
        investors[msg.sender].amounts.stack=0;
    }


    /**
     * Store the liquid value in the balance  
     * 
     */
    function compound() public {
        require(initialized, "Not started yet !"); 
        require(getSenderNextClaimDate() < block.timestamp, "You need to wait before compounding."); 
    
        // Lock liquidity to sender balance. 
        investors[msg.sender].amounts.balance=add(getSenderBalance(), getSenderLiquidAmount());

        // The last claim date is block.timestamp. 
        resetLastClaimDate(); 
        
        // Add 1 compound to the user count 
        bumpSenderCompoundCount(); 
    }


    /**
     * Send back liquidity to the sender, collect tax for dev & marketing 
     * 
     */
    function withdraw() public {
        require(initialized, "Not started yet !"); 
        require(getSenderNextClaimDate() < block.timestamp, "You need to wait before withdraw.");
        
        // Get the amount to withdraw
        uint256 currentAmount=taxeWithdrawForSustainability(
            getSenderLiquidAmount() / tokenPerUnit
        );
         
        // Calculate fees based on the current amount 
        uint256 fees=getDevFee(currentAmount);

        // Reset the last action date 
        resetLastClaimDate(); 

        // Reset the compound counter 
        resetCompoundCounter();
 
        // Transfer liquidity to user.  
        payable(msg.sender).transfer(sub(currentAmount, fees));
    }


    /**
     * Send support to support wallet 
     */ 
    function sendToSupportWallet(uint256 amount) private {
        payable(effortWallet).transfer(amount);
    }


    /**
     * Taxe withdraw to keep the contract healthy for investissors  
     */
    function taxeWithdrawForSustainability(uint256 amount) view private returns(uint256){

        // Hungry players taxe 
        if(getSenderCompoundCount() < minClaimToAvoidSanityTax) {
            return  (amount * (100 - sanityTaxAmountPercent)) / 100; 
        }
 
        // Anti whales taxe: 50% taxe for amounts >= 10% of contract balance
        if(amount >= (getBalance() * 10) / 100) {
            return amount / 2; 
        }
 
        // Anti whales taxe: 25% taxe for amounts >= 5% of contract balance
        if(amount >= (getBalance() * 5) / 100) { 
            return amount - (amount / 4);
        }

        return amount;
    }



    /**
     * Get bonus by burning your tokens to the cause
     * 
     */
    function obtainNewBonus(uint256 amountPercent) public {
        require(initialized, "Not started yet !"); 
        require(amountPercent >= effortMinPercent, "The min effort required is higher to obtain bonus.");
        require(amountPercent <= effortMaxPercent, "The max effort is reached.");
        require(getBonusEndDate() < block.timestamp, "You need to wait before adding a new bonus."); 

        // Reset the last action date 
        setNewBonusExpirationDate(); 

        // How much to burn ? 
        uint256 amountToBurn=(investors[msg.sender].amounts.balance * amountPercent) / 100;

        // Effective burn of the amount
        investors[msg.sender].amounts.balance = investors[msg.sender].amounts.balance - amountToBurn; 

        // Add the bonus to the user. 
        investors[msg.sender].amounts.bonusPercent = amountPercent;

        // Transfer liquidity to the effort wallet 
        payable(effortWallet).transfer(amountToBurn);
    }


    /**
     * Reset the bonus percent and date
     */
    function setNewBonusExpirationDate() private {
        if(getSenderBalance() == 0) {
            return;
        }
        investors[msg.sender].dates.bonusEnd = block.timestamp + secondsByDay;
    }


    /**
     * Returns the sender next claim timestamp.
     * 
     * @return Integer
     */
    function getBonusEndDate() public view returns(uint256){
        return investors[msg.sender].dates.bonusEnd;
    }


    /**
     * Give some reward to the referrer of the new user 
     * 
     * return int 
     */
    function handleReferrer(uint256 amount, address referrer) private {
         if(referrer == msg.sender) {
            return;  
        }
 
        investors[msg.sender].amounts.balance=investors[msg.sender].amounts.balance + (amount * 10) / 100;
    }


    /**
     * Calculate dev fee amount  
     * 
     * return int 
     */
    function getDevFee(uint256 amount) view private returns(uint256){
        return div(mul(amount, feePercent), 100); 
    }


    /**
     * Calculate dev fee amount  
     * 
     * return int 
     */
    function getUnstackFees(uint256 amount) view private returns(uint256){
        // unstackFeesPercent=20;           // Amount of fee when the user unstack
        // unstackDurationPenalityDays
 
        return div(mul(amount, unstackFeesPercent), 100); 
    }


    /**
     * Dispatch fees to the team 
     */
    function collectFees(uint256 fee) private {
        uint256 fee2=(fee * marketingFeePercent) / 100; 

        payable(marketingAddress).transfer(fee2);
        payable(devAddress).transfer(fee-fee2); 
    }


    /**
     * Returns the smart contract balance 
     * 
     * @return Integer
     */
    function getBalance() public view returns(uint256){
        return payable(address(this)).balance; 
    }


    /**
     * Returns the sender balance 
     * 
     * @return Integer
     */
    function getSenderBalance() public view returns(uint256){
        return investors[msg.sender].amounts.balance;
    }


    /**
     * Returns the sender balance 
     * 
     * @return Integer
     */
    function getMinClaimToAvoidSanityTax() public view returns(uint256){
        return minClaimToAvoidSanityTax; 
    }


    /**
     * Returns the sender next claim timestamp.
     * 
     * @return Integer
     */
    function getSenderNextClaimDate() public view returns(uint256){
        if(getSenderBalance() == 0) {
            return 0;
        }
        return getSenderLastClaimDate() + secondsByDay; 
    }


    /**
     * Set the sender last action date to block.timestamp. 
     * 
     */
    function resetLastClaimDate() private {
        investors[msg.sender].dates.lastClaim=block.timestamp;
    }

    /**
     * Set the sender last stack date to block.timestamp. 
     * 
     */
    function resetLastStackDate() private {
        investors[msg.sender].dates.lastStack=block.timestamp;
    }


    /**
     * Enable the autocompound feature
     * 
     */
    function enableAutocompound() public {
        require(getSenderStack() > autocompoundMinInvest, "The amount of investment is not reached to enable autocompound.");

        investors[msg.sender].dates.autocompoundEnabled = block.timestamp; 
    }


    /**
     * Disable the autocompound 
     * 
     */
    function disableAutocompound() public {
        investors[msg.sender].dates.autocompoundEnabled = 0;  
    }


    /**
    * Enable the autocompound feature 
    *
    */ 
    function getSenderLastClaimDate() public view returns(uint256) {
        return investors[msg.sender].dates.lastClaim; 
    }

    /**
     * Add 1 to the send compound count to allow him to avoid tax a day.
     */
    function bumpSenderCompoundCount() private {
         investors[msg.sender].amounts.compound=investors[msg.sender].amounts.compound+1;
    }


    /**
     * Set the sender last action date to block.timestamp. 
     * 
     */
    function resetCompoundCounter() private {
        investors[msg.sender].amounts.compound=0;
    }


   /**
    * Set the sender last action date to block.timestamp. 
    * 
    */
    function getSenderCompoundCount() public view returns(uint256) {
        return investors[msg.sender].amounts.compound;
    }


    /**
     * Return the total value invested by the sender
     * 
     */
    function getSenderStack() public view returns(uint256) {
        return investors[msg.sender].amounts.stack;
    }

 
    /**
     * Return the current user liquid reward 
     * 
     * @return Integer  
     */
    function getSenderLiquidAmount() public view returns(uint256){
        uint256 secondsPassed=getSecondPassedFromLastClaim();

        if(investors[msg.sender].dates.autocompoundEnabled == 0 && secondsPassed > secondsByDay) {
            return getEstimatedDailyRewards(); 
        } 
      
        //10/100 = secondsByDay (100/100)
        //ratio  = ((getSenderBalance() * 10) / 100 * (secondsPassed * 1e18/secondsByDay)) / 1e18

        // Multiply & Divide by 1e18 to avoid underflow 
        return ((getSenderBalance() * (dailyROIPercent + getSenderBonusPercent())) / 100 * (secondsPassed * 1e18/secondsByDay)) / 1e18; 
    }


    /**
     * Return the estimated daily reward for the sender
     *  
     * 
     * @return Integer  
     */
    function getSecondPassedFromLastClaim() public view returns(uint256){
        return block.timestamp - getSenderLastClaimDate();
    } 


    /**
     * Return the estimated time left with the current bonus
     * 
     * @return Integer  
     */
    function getRemainingBonusSeconds() public view returns(uint256){
        return investors[msg.sender].dates.bonusEnd - block.timestamp; 
    } 

    /**
     * Return the estimated time left with the current bonus
     * 
     * @return Integer  
     */
    function getSenderBonusPercent() public view returns(uint256){
        if(getRemainingBonusSeconds() > 0) {
            return investors[msg.sender].amounts.bonusPercent; 
        }
        return 0; 
    } 

    /**
     * Return the estimated daily reward for the sender
     * 
     * 
     * @return Integer 
     */
    function getEstimatedDailyRewards() public view returns(uint256){
        return getSenderBalance() * dailyROIPercent / 100; 
    }


  // Declaring state variable 
    // of type array. One is fixed-size
    // and the other is dynamic array
    uint[] data = [10, 20, 30, 40, 50]; 
    
    address[] fightResults = [address(0x0000000000000000000000000000000000000000), 0x1000000000000000000000000000000000000000, 0x3000000000000000000000000000000000000000];  
    
    // Battle Structure
    struct Battle {
        uint256 startDate;                              // The last user investment date 
        uint256 endDate;                                // When the last claim occurs
        uint256 lastFightDate;                          // When the last fight occurs
        uint256 total;                                  // The buff end date 
        mapping (address => uint256) totalPerSender;
        address[] players;
        address[] results;    // When the user has enabled the autocompound 
    }

    Battle[] battles;  

    /**
     * Store the liquid value in the balance  
     * 
     */
    function fight() external payable {
        require(initialized, "Not started yet !");
        require(msg.value != fightPrice, "Enter the battle have a fixed price.");
        
        // The first battle 
        if(battles.length == 0) {
            // createNewBattle(); 
        }

        // 1 day max or N hours without actions 
        if(
            battles[battles.length - 1].startDate - block.timestamp > secondsByDay || 
            battles[battles.length - 1].startDate - battles[battles.length - 1].lastFightDate > (60 * 60 * maxHoursWithNoFight)
        ) {
            // closeBattle(); 
        }
 
        // If the player wants to start battle. 
        if(battles[battles.length - 1].totalPerSender[msg.sender] == 0) {
            battles[battles.length - 1].players.push(msg.sender); 
        }

        // Add the fight price to the total per sender
        battles[battles.length - 1].totalPerSender[msg.sender] += msg.value;

        // Reset the player name 
        //if(name != "unknown") {
            //investors[this.sender].name(name); 
        //}

        // Let's fight! 
        for (uint256 i = 0; i < battles[battles.length - 1].players.length; i++) {
            uint256 n = i + uint256(keccak256(abi.encodePacked(block.timestamp))) % (battles[battles.length - 1].players.length - i);
            address temp = fightResults[n];
            fightResults[n] = fightResults[i];
            fightResults[i] = temp;
        }
    }


    /**
     * Return the estimated daily reward for the sender
     * 
     * 
     * @return Integer 
     */
    function getCurrentBattleResults() public view returns(address[] memory){
        return fightResults; 
    }
    

    /**
     * Return the estimated daily reward for the sender
     * 
     * 
     * @return Integer 
     */
    function amIaWinner() public view returns(bool){
        address me = 0x0000000000000000000000000000000000000000; 

        for (uint256 i = 0; i < (fightResults.length / 3); i++) {
            if(fightResults[i] == me) {
                return true; 
            }
        } 
        
        return false; 
    }


    /**
     * Allow any external source to fill the contract 
     */ 
    receive() external payable {}


    /**
     * Some math Utils
     */

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
        return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }


    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }


    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }


    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}