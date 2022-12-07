/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: CC-BY-4.0
pragma solidity ^0.8.7;

/**

     /$$      /$$                           /$$                     /$$$$$$$$ /$$                                                  
    | $$$    /$$$                          | $$                    | $$_____/|__/                                                  
    | $$$$  /$$$$  /$$$$$$   /$$$$$$   /$$$$$$$  /$$$$$$   /$$$$$$ | $$       /$$ /$$$$$$$   /$$$$$$  /$$$$$$$   /$$$$$$$  /$$$$$$ 
    | $$ $$/$$ $$ /$$__  $$ /$$__  $$ /$$__  $$ /$$__  $$ /$$__  $$| $$$$$   | $$| $$__  $$ |____  $$| $$__  $$ /$$_____/ /$$__  $$
    | $$  $$$| $$| $$  \ $$| $$  \__/| $$  | $$| $$  \ $$| $$  \__/| $$__/   | $$| $$  \ $$  /$$$$$$$| $$  \ $$| $$      | $$$$$$$$
    | $$\  $ | $$| $$  | $$| $$      | $$  | $$| $$  | $$| $$      | $$      | $$| $$  | $$ /$$__  $$| $$  | $$| $$      | $$_____/
    | $$ \/  | $$|  $$$$$$/| $$      |  $$$$$$$|  $$$$$$/| $$ /$$  | $$      | $$| $$  | $$|  $$$$$$$| $$  | $$|  $$$$$$$|  $$$$$$$
    |__/     |__/ \______/ |__/       \_______/ \______/ |__/|__/  |__/      |__/|__/  |__/ \_______/|__/  |__/ \_______/ \_______/

    TG: https://t.me/modorfinance
    DAPP: https://Mordor.Finance 
    Twitter: https://twitter.com/NoBullshitCorp 

    # Have fun with this contract, send-us your comments :) 
    # To support us, send to the supportWallet. It will be reversed in our projects. NoBullshit.

**/

contract MordorFinance {

    // Variables are public
    bool public initialized   = false; // The game will begin when this one will be true.
    uint256 public launchDate = 0;     // Keep the start date knowledge.
    address public owner;              // Renounced contract owner value is "0x0000000000000000000000000000000000000000".

    // Constants are private
    uint256 private immutable secondsByDay             = 43200;        // A day is 86400 seconds. 
    uint256 private immutable dailyROIPercent          = 3;            // Rewards % of sender balance on period. 
    uint256 private immutable tokenPerUnit             = 10000;        // How many token you get per one coin.
    uint256 private immutable feePercent               = 10;           // Amount of fees.
    uint256 private immutable unstackFeesPercent       = 20;           // Amount of fee that stays in TVL when the user unstack.
    uint256 private immutable marketingFeePercent      = 40;           // Dedicated to the TVL growth.
    uint256 private immutable minClaimToAvoidSanityTax = 6;            // Min claim to disable sustainability tax.
    uint256 private immutable sanityTaxAmountPercent   = 90;           // Sustainability tax amount.
    uint256 private immutable bonusDuration            = 7;            // Bonus period in days.
    uint256 private immutable maxHoursWithNoFight      = 1;            // Max period without action to close the fight.
    uint256 private immutable minBonusPercent          = 1;            // The min % effort you can send to get bonus.
    uint256 private immutable maxBonusPercent          = 5;            // The max % effort allowed to get bonus.
    uint256 private immutable autoclaimMinInvest       = 3 * 1e16 wei; // = 0.03 BNB / The amount that must be stacked to unlock the autoclaim feature.6
    uint256 private immutable fightPrice               = 2 * 1e16 wei; // = 0.02 BNB / The fixed price to fight in a battle.
    uint256 private immutable minStackAmount           = 5 * 1e16 wei; // = 0.05 BNB / The minimum amount to stack. 
   
    // Addresses are constants 
    address private immutable devAddress       = 0x87F44E7516426e2626Ae1781Fafa00870f17B66F; // The team wallet to eat.
    address private immutable marketingAddress = 0x31C52757250D3498185168Cba7D5791635F487A7; // The marketing wallet to pay bills.
    address private immutable supportWallet    = 0xffb5FA2c14FB9aB5A2e1D0125517C2023879C110; // The wallet to dispatch community effort.

    /**
     * Build the contract
     */
    constructor() {
        owner = msg.sender;
    }

    /**
     * Initialize the miner, the only owned method. Let's begins.
     *
     */
    function initialize() public {
        require(msg.sender == owner);
        require(!initialized);

        // Renounce owner by design.
        owner = 0x0000000000000000000000000000000000000000;

        // From here, the contract is free as birds and belongs to investors.
        launchDate = block.timestamp; 
        initialized = true;
    }

    /**
     *    ,---.   ,--.                ,--.    ,--.                                         ,--.  ,--.
     *   '   .-',-'  '-. ,--,--. ,---.|  |,-. `--',--,--,  ,---.      ,---.  ,---.  ,---.,-'  '-.`--' ,---. ,--,--,
     *   `.  `-.'-.  .-'' ,-.  || .--'|     / ,--.|      \| .-. |    (  .-' | .-. :| .--''-.  .-',--.| .-. ||      \
     *   .-'    | |  |  \ '-'  |\ `--.|  \  \ |  ||  ||  |' '-' '    .-'  `)\   --.\ `--.  |  |  |  |' '-' '|  ||  |
     *   `-----'  `--'   `--`--' `---'`--'`--'`--'`--''--'.`-  /     `----'  `----' `---'  `--'  `--' `---' `--''--'
     *                                                 `---'
     */

    // Amount structure
    struct Amounts {
        uint256 stack;        // Total amount of the stacked value
        uint256 widthdrawal;  // Total amount of withdrawed value
        uint256 balance;      // Current balance (Stacked value + Added Rewards)
        uint256 claim;        // Claim count
        uint256 bonusPercent; // The bonus value percent, from [min] to [max]
    }

    // Amount structure
    struct Dates {
        uint256 lastStack;        // The last user investment date
        uint256 lastClaim;        // When the last claim occurs
        uint256 bonusEnd;         // The buff end date
        uint256 autoclaimEnabled; // When the user has enabled the autoclaim
    }

    // The investor structure
    struct Investor {
        string name;
        Amounts amounts;
        Dates dates;
    }

    // Store investors by wallets adresses.
    mapping(address => Investor) private investors;

    /**
     * Add new liquidity to the sender stack.
     *
     * @param referrer The referrer address, msg.sender here will have no rewards (L.295).
     *
     */
    function stack(address referrer) external payable {
        require(initialized, "Not started yet !");
        require(msg.value >= minStackAmount, "You must add more funds to stack. The minimum is 0.5 BNB.");

        uint256 fees    = getDevFee(msg.value);
        uint256 balance = getSenderBalance();  

        // Reset the last action date.
        resetLastClaimDate(); 

        // Reset the last stack date.
        resetLastStackDate();

        // Reset the sender claim counter.
        resetClaimCounter();

        // Dispatch fees.
        collectFees(fees);

        // Give its reward to the referrer.
        handleReferrer(msg.value, referrer);

        // Add values to balance & investments.
        uint256 amountToAdd                   = msg.value - fees;
        investors[msg.sender].amounts.stack   += amountToAdd; 
        investors[msg.sender].amounts.balance = balance + ((amountToAdd * tokenPerUnit) / 1e18);
    }

    /**
     * Unstack the sender investment, retains unstack fees in TVL, then transfer the rest.
     *
     */
    function unstack() external {
        require(initialized, "Not started yet !");
        require(investors[msg.sender].amounts.stack > 0, "You need to stack before unstack!");

        uint256 unstackFees = getUnstackFees(
            investors[msg.sender].amounts.stack
        );

        // Transfer liquidity to user.
        payable(msg.sender).transfer(
            sub(investors[msg.sender].amounts.stack, unstackFees)
        );
 
        // Reset the last action date.
        resetLastClaimDate();

        // Reset the last stack date.
        resetLastStackDate();

        // Reset the claim counter.
        resetClaimCounter();

        // Reset send investments.
        investors[msg.sender].amounts.stack = 0;

        // Reset the token balance
        investors[msg.sender].amounts.balance = 0;
    }

    /**
     * Add the liquid value to the sender balance
     *
     */
    function claim() public {
        require(initialized, "Not started yet !");
        require(investors[msg.sender].amounts.stack > 0, "You need to stack before claim!");
        require(getSenderNextClaimDate() < block.timestamp, "You need to wait before claiming.");

        // Lock liquidity to sender balance.
        investors[msg.sender].amounts.balance = getSenderBalance() + getSenderLiquidAmount();

        // The last claim date is block.timestamp.
        resetLastClaimDate(); 

        // Add 1 claim to the user count.
        bumpSenderClaimCount();
    }

    /**
     * Send back liquidity to the sender, collect tax for dev & marketing
     *
     */
    function withdraw() public {
        require(initialized, "Not started yet !");
        require(getSenderNextClaimDate() < block.timestamp, "You need to wait before withdraw.");
        require(getSenderWithdrawableBalance() > 0);

        // Get the amount to withdraw.
        uint256 currentAmount = taxeWithdrawForSustainability(
            getSenderWithdrawableAmount()
        );

        // Reset the last action date.
        resetLastClaimDate();

        // Reset the claim counter.
        resetClaimCounter();

        // Transfer liquidity to user.
        payable(msg.sender).transfer(currentAmount);
    }

    /**
     * Taxe withdraw to keep the contract healthy for investisors
     *
     * @param amount The wanted amount to withdraw
     *
     */
    function taxeWithdrawForSustainability(uint256 amount) private view returns (uint256) {
        // Hungry players taxe.
        if (getSenderClaimCount() < minClaimToAvoidSanityTax) {
            return (amount * (100 - sanityTaxAmountPercent)) / 100;
        }

        return amount;
    }

    /**
     * Obtain a multiple bonus by burning your tokens to the cause.
     *   Given funds will be reversed to support our projects.
     *
     */
    function obtainNewBonus(uint256 amountPercent) public {
        require(initialized, "Not started yet !");
        require(amountPercent >= minBonusPercent, "The min bonus required is higher to obtain a bonus.");
        require(amountPercent <= maxBonusPercent, "The max bonus is reached.");
 
        // How much to burn ?
        uint256 currentSenderBalance = getSenderBalance();
        uint256 amountToBurn         = (currentSenderBalance * amountPercent) / 100;
        uint256 amountToTransfert    = (amountToBurn * 1e18) / tokenPerUnit;

        // Effective burn of the amount.
        investors[msg.sender].amounts.balance = currentSenderBalance - amountToBurn;

        // Add the bonus to the user.
        investors[msg.sender].amounts.bonusPercent = amountPercent;

        // Reset the last action date.
        setNewBonusExpirationDate();

        // Reset the last action date.
        resetLastClaimDate();

        // Reset the claim counter.
        resetClaimCounter();
 
        // Transfer liquidity to the support wallet.
        payable(supportWallet).transfer(amountToTransfert);
    }

    /**
     * Reset the bonus end date.
     *
     */
    function setNewBonusExpirationDate() private {
        if (getSenderBalance() == 0) {
            return;
        }

        investors[msg.sender].dates.bonusEnd = block.timestamp + (secondsByDay * bonusDuration);
    }

    /**
     * Returns the sender next claim timestamp.
     *
     * @return uint256
     */
    function getSenderBonusEndDate() private view returns (uint256) {
        return investors[msg.sender].dates.bonusEnd;
    }

    /**
     * Give some reward to the referrer of the new user
     *
     * @param amount   The amount of deposit
     * @param referrer The address of the referrer
     */
    function handleReferrer(uint256 amount, address referrer) private {
        // The sender can't be hiself referrer.
        if (referrer == msg.sender) {
            return;
        }

        // Dispatch
        uint256 amountForReferrer = (amount * tokenPerUnit) / 1e18; // Convert coins to token.
        investors[referrer].amounts.balance += (amountForReferrer * 10) / 100; // 10% for the referrer.
    }

    /**
     * Calculate dev fee amount
     *
     * @param amount The amount of deposit
     *
     * return int
     */
    function getDevFee(uint256 amount) private pure returns (uint256) {
        return div(mul(amount, feePercent), 100);
    }

    /**
     * Calculate dev fee amount
     *
     * return int
     */
    function getUnstackFees(uint256 amount) private pure returns (uint256) {
        return div(mul(amount, unstackFeesPercent), 100);
    }

    /**
     * Dispatch Marketing & Dev fees
     */
    function collectFees(uint256 fee) private {
        uint256 fee2 = (fee * marketingFeePercent) / 100;

        payable(marketingAddress).transfer(fee2);
        payable(devAddress).transfer(fee - fee2);
    }

    /**
     * Returns the smart contract balance
     *
     * @return uint256
     */
    function getBalance() private view returns (uint256) {
        return payable(address(this)).balance;
    }

    /**
     * Returns the sender balance
     *
     * @return uint256 
     */
    function getSenderBalance() private view returns (uint256) {
        uint256 secondsPassed  = getSecondPassedFromLastClaim();
        uint256 currentBalance = investors[msg.sender].amounts.balance;
        uint256 daysCount      = (block.timestamp - investors[msg.sender].dates.lastClaim) / secondsByDay;

        // Implement the autoclaim algorithm. Unlock days limit & autompound value.
        if (
            investors[msg.sender].dates.autoclaimEnabled != 0 &&
            secondsPassed > secondsByDay
        ) {
            // Iterate over day to add the autoclaimed amounts
            for (uint256 i = 0; i < daysCount; i++) {
                currentBalance += getRewardsFromBalance(currentBalance);
            }
        }

        return currentBalance;
    }

    /**
     * Returns the sender balance
     *
     * @return uint256
     */
    function getMinClaimToAvoidSanityTax() public pure returns (uint256) {
        return minClaimToAvoidSanityTax;
    }

    /**
     * Returns the sender next claim timestamp.
     *
     * @return uint256
     */
    function getSenderNextClaimDate() private view returns (uint256) {
        if (getSenderBalance() == 0) {
            return 0;
        }
        return getSenderLastClaimDate() + secondsByDay;
    }

    /**
     * Set the sender last action date to block.timestamp.
     *
     */
    function resetLastClaimDate() private {
        investors[msg.sender].dates.lastClaim = block.timestamp;
    }

    /**
     * Set the sender last stack date to block.timestamp.
     *
     */
    function resetLastStackDate() private {
        investors[msg.sender].dates.lastStack = block.timestamp;
    }

    /**
     * Enable the autoclaim feature
     *
     */
    function enableAutoclaim() public {
        require(getSenderStack() >= autoclaimMinInvest, "You need to stack more to enable autoclaim.");

        investors[msg.sender].dates.autoclaimEnabled = block.timestamp;
    }

    /**
     * Disable the autoclaim
     *
     */
    function disableAutoclaim() public {
        investors[msg.sender].dates.autoclaimEnabled = 0;
    }

    /**
     * Return whether the autoclaim is enabled or not.
     *
     * @return bool
     */
    function isAutoclaimEnabled() private view returns (bool) {
        return investors[msg.sender].dates.autoclaimEnabled != 0;
    }

    /**
     * Enable the autoclaim feature
     *
     * @return uint256
     */
    function getSenderLastClaimDate() private view returns (uint256) {
        return investors[msg.sender].dates.lastClaim;
    }

    /**
     * Add 1 to the send claim count to allow him to avoid tax a day.
     *
     */
    function bumpSenderClaimCount() private {
        investors[msg.sender].amounts.claim = getSenderClaimCount() + 1;
    }

    /**
     * Set the sender last action date to block.timestamp.
     *
     */
    function resetClaimCounter() private {
        investors[msg.sender].amounts.claim = 0;
    }

    /**
     * Return the autoclaim count.
     *
     * @return uint256
     */
    function getSenderClaimCount() private view returns (uint256) {
        // Implement the autoclaim feature.
        uint256 autoclaimCount = investors[msg.sender].dates.autoclaimEnabled > 0 ?
             (block.timestamp - investors[msg.sender].dates.lastClaim) / secondsByDay : 0;

        return investors[msg.sender].amounts.claim + autoclaimCount;
    }

    /**
     * Return the total value invested by the sender
     *
     * @return uint256
     */
    function getSenderStack() private view returns (uint256) {
        return investors[msg.sender].amounts.stack;
    }

    /**
     * Return the current user liquid reward
     *
     * @return uint256
     */
    function getSenderLiquidAmount() private view returns (uint256) {
        uint256 secondsPassed = getSecondPassedFromLastClaim();
        uint256 daysCount     = (block.timestamp - investors[msg.sender].dates.lastClaim) / secondsByDay;
        uint256 secondsLeft   = secondsPassed - (daysCount * secondsByDay);
        uint256 dailyReward   = (getSenderBalance() * getCurrentMultiple()) / 100;

        if (
            investors[msg.sender].dates.autoclaimEnabled == 0 &&
            secondsPassed > secondsByDay
        ) {
            return dailyReward;
        }

        // Add the current day rewards
        return ((dailyReward * secondsLeft * 1e18) / secondsByDay) / 1e18; //Avoid overflow
    }

    /**
     * Return the current withdrawable liquidity converted as coin.
     *
     * @return uint256
     */
    function getSenderWithdrawableAmount() private view returns (uint256) {
        return (getSenderWithdrawableBalance() * 1e18) / tokenPerUnit;
    }

    /**
     * Return the current withdrawable amount of token
     *
     * @return uint256
     */
    function getSenderWithdrawableBalance() private view returns (uint256) {
        uint256 currentBalance = getSenderBalance();
        uint256 daysCount      = (block.timestamp - investors[msg.sender].dates.lastClaim) / secondsByDay;
        uint256 lastDayRewards = 0;

        // For non-autoclaim enabled or period is less than a day.
        if (
            investors[msg.sender].dates.autoclaimEnabled == 0 ||
            getSecondPassedFromLastClaim() <= secondsByDay
        ) {
            return getSenderLiquidAmount();
        }

        // Autoclaim withdrawable funds are the last day balance. Iterate to find the amount.
        for (uint256 i = 0; i < daysCount; i++) {
            lastDayRewards = getRewardsFromBalance(currentBalance);
            currentBalance += lastDayRewards;
        }

        return lastDayRewards;
    }

    /**
     * Return the current multiplier for the sender
     *
     * @return uint256
     */
    function getCurrentMultiple() private view returns (uint256) {
        return dailyROIPercent + getSenderBonusPercent();
    }

    /**
     * Return the daily reward for the sender
     *
     * @return uint256
     */
    function getRewardsFromBalance(uint256 balance) private view returns (uint256) {
        return (balance * getCurrentMultiple()) / 100;
    }

    /**
     * Return the estimated daily reward for the sender
     *
     *
     * @return uint256
     */
    function getSecondPassedFromLastClaim() private view returns (uint256) {
        return block.timestamp - getSenderLastClaimDate();
    }

    /**
     * Return the estimated time left with the current bonus
     *
     * @return uint256
     */
    function getRemainingBonusSeconds() private view returns (uint256) {
        return investors[msg.sender].dates.bonusEnd > 0 && block.timestamp < investors[msg.sender].dates.bonusEnd
            ? investors[msg.sender].dates.bonusEnd - block.timestamp : 0;
    } 

    /**
     * Return the bonus amound, the max is maxBonusPercent. Heavy investors have some base bonus.
     *
     * @return uint256
     */
    function getSenderBonusPercent() private view returns (uint256) {
        // Implement a special bonus for our best investors.
        uint256 baseStackedBonus = getSenderStack() / (10 * 1e18);

        // Implement the regular bonus that investors can buy by burning token with obtainNewBonus().
        uint256 buyedBonus   = getRemainingBonusSeconds() > 0 ? investors[msg.sender].amounts.bonusPercent : 0;
        uint256 overallBonus = baseStackedBonus + buyedBonus;

        // The max available bonus is effort
        return overallBonus > maxBonusPercent ? maxBonusPercent : overallBonus;
    }

    /**
     *   ,-----.            ,--.    ,--.  ,--.                   ,---.                 ,--.  ,--.
     *   |  |) /_  ,--,--.,-'  '-.,-'  '-.|  | ,---.  ,---.     '   .-'  ,---.  ,---.,-'  '-.`--' ,---. ,--,--,
     *   |  .-.  \' ,-.  |'-.  .-''-.  .-'|  || .-. :(  .-'     `.  `-. | .-. :| .--''-.  .-',--.| .-. ||      \
     *   |  '--' /\ '-'  |  |  |    |  |  |  |\   --..-'  `)    .-'    |\   --.\ `--.  |  |  |  |' '-' '|  ||  |
     *   `------'  `--`--'  `--'    `--'  `--' `----'`----'     `-----'  `----' `---'  `--'  `--' `---' `--''--'
     */

    // Battle Structure
    struct Battle {
        uint256 startDate;                           // When the battle begins.
        uint256 endDate;                             // When the battle took end.
        uint256 lastFightDate;                       // When the last fight occured.
        uint256 jackpot;                             // The battle total rewards pool.
        mapping(address => uint256) totalPerSender;  // Store invested amount by investors.
        mapping(address => uint256) rewardPerSender; // Store the earned amount when the fight is over.
        address[] results;                           // Store the results of the battle.
        address[] fights;                            // Store each fight address
    } 

    Battle[] private battles; // Stores battles in a pool.

    /**
     * How many battles ever created
     *
     * @return uint256
     */
    function getBattlesCount() private view returns (uint256) {
        return battles.length;
    }

    /** 
     * Main action to fight againts all other investors.
     * Will:
     *  - Start battles
     *  - Add investors to the battle
     *  - Shuffle results
     *  - Close battles
     */
    function fight() external payable {
        require(initialized, "Not started yet !");
        require(getSenderBalance() > 0, "You need to have stacked funds to fight.");
        require(msg.value == fightPrice, "Fighting has a price.");

        // Check if we need to close a previous battle.
        if (hasBattleTookEnd()) {
            closeBattle();
        }

        // Do we need to create a new battle instance
        if (battles.length == 0 || battles[battles.length - 1].endDate > 0) {
            battles.push();
            battles[battles.length - 1].startDate = block.timestamp;
        }

        // Store the player for further usage.
        if (battles[battles.length - 1].totalPerSender[msg.sender] == 0) {
            battles[battles.length - 1].results.push(msg.sender);
        }

        // Add the fight price to the total per sender & jackpots
        battles[battles.length - 1].totalPerSender[msg.sender] += msg.value;
        battles[battles.length - 1].jackpot += msg.value;

        // Then, let's all the token fight each others!
        address[] memory results = battles[battles.length - 1].results;
        uint256 entropy = block.timestamp;

        // Implement Fisher-Yates shuffle to randomize results
        for (uint256 i = results.length - 1; i > 0; i--) {
            uint256 swapIndex = entropy % (results.length - i);
            address currentIndex = results[i];
            address indexToSwap = results[swapIndex];
            results[i] = indexToSwap;
            results[swapIndex] = currentIndex;
        }

        // Set new results and store the last fight date.
        battles[battles.length - 1].results = results;
        battles[battles.length - 1].lastFightDate = block.timestamp;
        battles[battles.length - 1].fights.push(msg.sender);
    }

    /**
     * Check if the last battle is over
     *
     * @return bool
     */
    function hasBattleTookEnd() private view returns (bool) {
        return  battles.length > 0 &&
            ((block.timestamp - battles[battles.length - 1].startDate) > secondsByDay ||                      // A day
            (block.timestamp - battles[battles.length - 1].lastFightDate) > (60 * 60 * maxHoursWithNoFight)); // End the fight if > maxHourswithNoFight
    }

    /**
     * Return the battle end date in case of regular end.
     */
    function getBattleEndDate() private view returns (uint256) {
        return battles.length > 0 ? battles[battles.length - 1].startDate + secondsByDay : 0;
    }

    /**
     * Return the battle end date if no player fight again.
     */
    function getLimitedFightEnd() private view returns (uint256) {
        return battles.length > 0 ? battles[battles.length - 1].lastFightDate + 60 * 60 * maxHoursWithNoFight : 0;
    } 

    /**
     * End the battle and send the rewards to winners wallets
     *
     */
    function closeBattle() private {
        require(battles.length > 0, "There no battle yet, please fight!");
        require(hasBattleTookEnd(), "The battle is not ended right now");

        address[] memory battleResults = getCurrentBattleResults();
        uint256 winnersCount           = getWinnersCount();

        // Implement the 2/3 battle rewards to winners, the last 1/3 stays in TVL.
        uint256 battleRewardsPart = (2 * battles[battles.length - 1].jackpot) /3;

        // Get the amount deposited by winners players only
        uint256 winnerJackpotPart = getWinnersJackpotAmount(winnersCount);

        // Iterate over winners to transfer gains.
        for (uint256 i = 0; i < winnersCount; i++) {
            address player        = battleResults[i];
            uint256 battleDeposit = battles[battles.length - 1].totalPerSender[player];

            // The reward depends on the battle participation, the more you fight, the more you win.
            uint256 playerReward = battleRewardsPart * (battleDeposit / winnerJackpotPart);

            // Store for history & transfer rewards to winners!
            battles[battles.length - 1].rewardPerSender[player] = playerReward;
            payable(player).transfer(playerReward);
        }

        battles[battles.length - 1].endDate = block.timestamp;
    }

    /**
     * Returns the user part of the reward in case of win.
     *
     * @return uint256
     */
    function getSenderCurrentReward() private view returns (uint256) {

        if(battles.length == 0) {
            return 0; 
        }

        uint256 winnersCount      = getWinnersCount();
        uint256 battleRewardsPart = (2 * battles[battles.length - 1].jackpot) / 3;
        uint256 winnerJackpotPart = getWinnersJackpotAmount(winnersCount);
        uint256 battleDeposit     = battles[battles.length - 1].totalPerSender[msg.sender];

        return battleRewardsPart * (battleDeposit / winnerJackpotPart);
    }

    /**
     * Return senders Battle history
     *
     * @return
     */
    function getSenderBattleHistory() public view returns (uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory)
    {
        uint256[] memory deposits = new uint256[](battles.length);
        uint256[] memory rewards = new uint256[](battles.length);
        uint256[] memory startDate = new uint256[](battles.length);
        uint256[] memory endDate = new uint256[](battles.length);

        for (uint256 i = 0; i < battles.length; i++) {
            deposits[i] = battles[i].totalPerSender[msg.sender];
            rewards[i] = battles[i].rewardPerSender[msg.sender];
            startDate[i] = battles[i].startDate;
            endDate[i] = battles[i].endDate;
        }

        return (deposits, rewards, startDate, endDate);
    }

    /**
     * Returns the jackpot part deposited by winners
     *
     * @param winnersCount How many winner for the current battle.
     *
     * @return uint256
     */
    function getWinnersJackpotAmount(uint256 winnersCount) private view returns (uint256) {
        uint256 amount = 0;

        // Iterate over winners to sum deposits .
        for (uint256 i = 0; i < winnersCount; i++) {
            address player = battles[battles.length - 1].results[i];
            amount += battles[battles.length - 1].totalPerSender[player];
        }

        return amount;
    }
  
    /**
     * Return the list of fights adresses
     *
     * @return uint256
     */
    function getBattleFights() private view returns (address[] memory) {   
        address[] memory empty; 
        return battles.length > 0 ? battles[battles.length - 1].fights : empty;
    }

    /**
     * Getter that returns the current battle start date
     *
     * @return uint256
     */
    function getCurrentBattleStartDate() private view returns (uint256) {
        return battles.length > 0 ? battles[battles.length - 1].startDate : 0;
    }

    /**
     * How many battles ever created
     *
     * @return uint256
     */
    function getCurrentBattleJackpot() private view returns (uint256) {
        return battles.length > 0 ? battles[battles.length - 1].jackpot : 0;
    }

    /**
     * Getter that returns the current battle results
     *
     * @return memory
     */
    function getCurrentBattleResults() private view returns (address[] memory) {
        return battles[battles.length - 1].results;
    }

    /**
     * Getter that returns the amount of winners of the current battle
     *
     * @return uint256
     */
    function getWinnersCount() private view returns (uint256) {
        if (battles.length == 0) {
            return 0;
        }

        return (getCurrentBattleResults().length + 2) / 3; // Ceil winners count.
    }

    /**
     * Group stacking informations to improve UX perfs
     *
     * @return
     */
    function pullStackingData()
        public
        view
        returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256,
            uint256, uint256, bool)
    {
        return (
            getBalance(),
            getSenderBalance(),
            getSenderStack(),
            getCurrentMultiple(),
            getSenderBonusPercent(),
            getRemainingBonusSeconds(), 
            getSenderLiquidAmount(),
            getSenderClaimCount(),
            getSenderNextClaimDate(),
            getSenderWithdrawableBalance(),
            getSenderWithdrawableAmount(),
            isAutoclaimEnabled()
        );
    }

    /**
     * Get rewards grouped informations
     *
     * @return
     */
    function pullBattleData()
        public
        view
        returns (bool, uint256, uint256, uint256, uint256, bool, uint256, uint256, address[] memory)
    {
        return (
            doIWinTheBattle(),
            getCurrentBattleJackpot(),
            getCurrentBattleStartDate(), 
            getBattleEndDate(), 
            getLimitedFightEnd(),
            hasBattleTookEnd(),
            getSenderCurrentReward(),
            getBattlesCount(), 
            getBattleFights() 
        );
    }

    /**
     * Check if the sender is a winner \o/, or a ugly looser :(
     *
     * @return bool
     */
    function doIWinTheBattle() private view returns (bool) {
        if (battles.length == 0) {
            return false;
        }

        address[] memory results = getCurrentBattleResults();

        for (uint256 i = 0; i < getWinnersCount(); i++) {
            if (address(results[i]) == address(msg.sender)) {
                return true;
            }
        }

        return false;
    }

    /**
     * How many player are fighting?
     *
     * @return uint
     */
    function getCurrentBattleTotalPlayer() public view returns (uint256) {
        if (battles.length == 0) {
            return 0;
        }

        return getCurrentBattleResults().length;
    }

    /**
     * Allow any external source to fill the contract,
     *   send us some fees from your fork, we will develop fresh new contracts ;)
     */
    receive() external payable {}

    /**
     * Math Utils
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

/**
 * No bullshit.
 */