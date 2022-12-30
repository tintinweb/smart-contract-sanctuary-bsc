/**
 *Submitted for verification at BscScan.com on 2022-12-30
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
    DAPP: https://Mordor.Finance/battles 
    Twitter: https://twitter.com/NoBullshitCorp 
  
    # Have fun with this contract, send-us your comments :) 
    # To support us, send to the supportWallet. The amount will be reversed in our projects. NoBullshit.

**/
  
contract MordorFinanceBattles {  

    // Variables are public 
    bool    public initialized = false;  // The game will begin when this one will be true. 
    uint256 public launchDate  = 0;      // Keep the start date knowledge. 
    address public owner;                // Store the owner adress 
    uint256 public maintenance = 0;      // Enable the maintenance will disable new fights creation.
 
    // Constants are private
    uint256 private immutable secondsByDay                = 86400;        // A day is 86400 seconds. 
    uint256 private immutable maxHoursWithNoFight         = 1;            // Max period without action to close the fight.
    uint256 private immutable fightPrice                  = 5 * 1e16 wei; // = 0.02 BNB / The fixed price to fight in a battle. 

    // Addresses are constants   
    address private immutable mordorContract              = 0x85DF0777E84e4C4Fe79Ea538a67B666eEAdFdF15; // Where to send the 1/3 . 
 
    /** 
     * Build the contract 
     */
    constructor() { 
        owner = msg.sender;
        initialize(); 
    }

    /**
     * Initialize the miner, the only owned method. Let's begins. 
     *
     */
    function initialize() public {
        require(msg.sender == owner);
        require(!initialized, "Already initialized."); 
        
        // From here, the contract is free as birds and belongs to investors.
        launchDate  = block.timestamp;
        initialized = true;
    }


    /**
     * Enable the maintenance to disable new fights creation
     * 
     */
    function enableMaintenance() public { 
        require(msg.sender == owner);
        maintenance = block.timestamp;
    }
    

    /**
     * Disable the maintenace mode
     * 
     */ 
    function disableMaintenance() public {
        require(msg.sender == owner);
        maintenance = 0;
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

    mapping(address => uint256) public liquidFightRewards;  // Store liquid rewards 
    address[] winners;   

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
     * How many battles ever created
     *
     * @return uint256 
     */ 
    function getLastWinners() public view returns (address[] memory) {
        return winners;
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
        require(msg.value == fightPrice, "Fighting has a price.");
   
        // What to do with a previous ended battle 
        if (hasBattleTookEnd()) { 

            // Implement the maintenance mode to disable new fights. 
            if(maintenance != 0) {
                revert("Maintenance is enabled, you can't close nor create new battle.");
            }
 
            // Check if we need to close a previous battle. 
            if(battles[battles.length - 1].endDate == 0) {
                closeBattle();
            }
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
        battles[battles.length - 1].totalPerSender[msg.sender] += (2 * msg.value) / 3;
        battles[battles.length - 1].jackpot += (2 * msg.value) / 3;

        // Send 1/3 to support wallet 
        sendEffortPart(msg.value / 3); 

        // Then, let's all the token fight each others! 
        address[] memory results = battles[battles.length - 1].results; 
        uint256 entropy          = block.timestamp; 

        // Implement Fisher-Yates shuffle to randomize results
        for(uint256 i = results.length - 1 ; i > 0; i--) {
            uint256 swapIndex    = entropy % (results.length - i);
            address currentIndex = results[i];
            address indexToSwap  = results[swapIndex];
            results[i]           = indexToSwap;
            results[swapIndex]   = currentIndex;
        }

        // Set new results and store the last fight date. 
        battles[battles.length - 1].results       = results; 
        battles[battles.length - 1].lastFightDate = block.timestamp;

        // Add the fighter list for each battle
        battles[battles.length - 1].fights.push(msg.sender); 
    }

    /**
     * Check if the last battle is over
     *
     * @return bool
     */
    function hasBattleTookEnd() private view returns (bool) {
        return  battles.length > 0 &&
            ((block.timestamp - battles[battles.length - 1].startDate) > secondsByDay ||                         // A day
            (block.timestamp - battles[battles.length - 1].lastFightDate) > (60 * 60 * maxHoursWithNoFight));    // End the fight if > maxHourswithNoFight
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
    * Transfert some player's liquid rewards 
    **/
    function transfertRewardsFor(address player) public { 
        payable(player).transfer(liquidFightRewards[player]);  
        liquidFightRewards[player] = 0;
    }

    /**
    * Transfert own player's liquid rewards when he want
    **/
    function transferMyRewards() external { 
        transfertRewardsFor(msg.sender);  
    } 

    /**
    * Return the player liquid amount 
    **/
    function getMyLiquidRewardsAmount() public view returns (uint256) {
        return liquidFightRewards[msg.sender];
    }

    /**
     * Transfert all liquidities to players, mainly used for maintenances. 
     * 
     */
    function transfertAllRewards() public {
        require(msg.sender == owner);

        // Iterate over winners to transfer gains.
        for (uint256 i = 0; i < winners.length; i++) {
            transfertRewardsFor(winners[i]);
        }
    }

    /**
     * Used to close the battle in maintenace mode with no cost for players.
     * 
     */
    function endBattle() external {
        require(msg.sender == owner);
        require(maintenance != 0, "End battle require maintenance enabled");
        require(battles.length > 0, "There's no battle yet, please fight!"); 
        require(battles[battles.length - 1].endDate == 0, "Battle should be closed once."); 
        require(hasBattleTookEnd(), "Non ended battles can't be closed"); 
 
        closeBattle(); 
    }


    /**
     * End the battle and send the rewards to winners wallets
     * 
     */
    function closeBattle() private {
        require(battles.length > 0, "There's no battle yet, please fight!"); 
        address[] memory battleResults = getCurrentBattleResults();
        uint256 winnersCount           = getWinnersCount(); 

        // Implement the 2/3 battle rewards to winners
        uint256 battleRewardsPart = battles[battles.length - 1].jackpot;

        // Get the amount deposited by winners players only 
        uint256 winnerJackpotPart = getWinnersJackpotAmount(winnersCount);

        // Iterate over winners to transfer gains.
        for (uint256 i = 0; i < winnersCount; i++) {
            address player        = battleResults[i]; 
            uint256 battleDeposit = battles[battles.length - 1].totalPerSender[player];
 
            // The reward depends on the battle participation, the more you fight, the more you win. 
            uint256 playerReward  = (battleRewardsPart * battleDeposit) / winnerJackpotPart;

            // Records winners for further usage.
            winners.push(player);

            //Store for history.
            battles[battles.length - 1].rewardPerSender[player] = playerReward;
 
            // Add player reward to its liquidity pool
            liquidFightRewards[player] = liquidFightRewards[player] + playerReward;
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
        uint256 battleRewardsPart = battles[battles.length - 1].jackpot;
        uint256 winnerJackpotPart = getWinnersJackpotAmount(winnersCount);
        uint256 battleDeposit     = battles[battles.length - 1].totalPerSender[msg.sender];
 
        return (battleRewardsPart * battleDeposit) / winnerJackpotPart; 
    }

    /**
     * Return senders Battle history
     *
     * @return
     */
    function getBattleHistory(address player) public view returns (uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory)
    {
        uint256[] memory deposits = new uint256[](battles.length);
        uint256[] memory rewards = new uint256[](battles.length);
        uint256[] memory startDate = new uint256[](battles.length);
        uint256[] memory endDate = new uint256[](battles.length);

        for (uint256 i = 0; i < battles.length; i++) {
            deposits[i] = battles[i].totalPerSender[player];
            rewards[i] = battles[i].rewardPerSender[player]; 
            startDate[i] = battles[i].startDate;
            endDate[i] = battles[i].endDate;
        }

        return (deposits, rewards, startDate, endDate);
    }

    /**
     * Return senders Battle history
     *
     * @return
     */
    function getSenderBattleHistory() public view returns (uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory)
    {
        return getBattleHistory(msg.sender); 
    }

    /**
     * Returns the jackpot part deposited by winners 
     *
     * @param winnersCount How many winner for the current battle. 
     * 
     * @return uint256
     */ 
    function getWinnersJackpotAmount(uint256 winnersCount) private view returns(uint256) {
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
        return battles.length > 0 ? battles[battles.length -1].fights : empty;
    }

    /**
     * Getter that returns the current battle start date 
     *
    * @return uint256
     */ 
    function getCurrentBattleStartDate() private view returns (uint256) {
        return battles.length > 0 ? battles[battles.length -1].startDate : 0;
    }

    /**
     * How many battles ever created
     *
     * @return uint256
     */ 
    function getCurrentBattleJackpot() private view returns (uint256) {
        return battles.length > 0 ? battles[battles.length -1].jackpot : 0;
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
     * Getter that returns the current battle results 
     *
     * @return memory
     */
    function getBattleResults(uint256 position) public view returns (address[] memory) {
        return battles[position].results;
    }
 
 
    /**
     * Getter that returns the amount of winners of the current battle 
     *
     * @return uint256
     */
    function getWinnersCount() private view returns (uint256) {
        if(battles.length == 0) {
            return 0; 
        }
        
        uint256 playerCount = getCurrentBattleResults().length; 

        if(playerCount < 3) {
            return 1; 
        }

        return playerCount/3;  
    }


    /**
     * Check if the sender is a winner \o/, or a ugly looser :(  
     *
     * @return bool
     */
    function doIWinTheBattle() private view returns (bool) {
        if(battles.length == 0) {
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
     * Get rewards grouped informations
     *
     * @return
     */
    function pullBattleData()
        public
        view
        returns (bool, uint256, uint256, uint256, uint256, bool, uint256, uint256, address[] memory, uint256, uint256)
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
            getBattleFights(),
            getMyLiquidRewardsAmount(),
            getWinnersCount() 
        );  
    }

   /**
     * Send support to mordor contract
     */
    function sendEffortPart(uint256 amount) private {
        payable(mordorContract).transfer(amount);
    }

    /**
     * Allow any external source to fill the contract, 
     *   send us some fees from your fork, we will develop fresh new contracts ;)
     */
    receive() external payable {
        battles[battles.length - 1].jackpot += msg.value;
    }



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