/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

contract Game {
    address public owner;
    constructor()  {
        owner = msg.sender;
    }
        
    mapping(address => Player) public players;
    uint public maximumStamina = 100;

    struct Player {
        uint stamina;
        uint lastStaminaUpdate;
        uint capacity;
        uint gold;
        uint experience;
        uint level;
        Item[] items;
   
    }

    struct Item {
    string name;
    uint power;
    uint price;
    }
    
    function addPlayer(address player) public {
    // Check if the player already exists in the mapping by checking if their stamina is 0
    require(players[player].stamina == 0, "Player already exists");

    // Initialize the player's data
    Player storage playerData = players[player];
    playerData.stamina = 10;
    playerData.lastStaminaUpdate = block.timestamp;
    playerData.capacity = 5;
    playerData.gold = 0;
    playerData.experience = 0;
    playerData.level = 1;
    }

    function getPlayer(address player) public view returns (uint stamina, uint lastStaminaUpdate, uint capacity, uint gold, uint experience, uint level) {
    Player storage playerData = players[player];
    return (playerData.stamina, playerData.lastStaminaUpdate, playerData.capacity, playerData.gold, playerData.experience, playerData.level);
}

    function updateStamina(address player) public {
    Player storage playerData = players[player];
    if (block.timestamp - playerData.lastStaminaUpdate > 60) {
        if (playerData.stamina < maximumStamina) {
            playerData.stamina = playerData.stamina + 1;
            playerData.lastStaminaUpdate = block.timestamp;
            }
        }
    }
    

    function addGold(address player, uint amount) public {
        Player storage playerData = players[player];
        playerData.gold = playerData.gold + amount;
    }

    function addExperience(address player, uint amount) public {
        Player storage playerData = players[player];
        playerData.experience = playerData.experience + amount;

        // Check if the player has reached the experience threshold for the next level
        // and level up if they have
        uint levelThreshold = getExperienceThreshold(playerData.level);
        if (playerData.experience >= levelThreshold) {
            levelUp(player);
        }
    }

    function levelUp(address player) private {
        Player storage playerData = players[player];
        playerData.level = playerData.level + 1;
        playerData.experience = playerData.experience - getExperienceThreshold(playerData.level);
    }

    function getExperienceThreshold(uint currentLevel) private pure returns (uint) {
    // This function returns the experience threshold for the next level based on the current level
    // You can implement any desired level progression curve here
    return currentLevel * 1000;
}

    function setCapacity(address player, uint newCapacity) public {
    Player storage playerData = players[player];
    playerData.capacity = newCapacity;
    }

    function addItem(address player, string memory name, uint power, uint price) public {
    Player storage playerData = players[player];

    // Check if the player has enough capacity to add the new item
    require(playerData.items.length < playerData.capacity, "Not enough capacity to add new item");

    // Create a new item and add it to the player's item list
    Item memory newItem = Item({
        name: name,
        power: power,
        price: price
    });
    playerData.items.push(newItem);
}
    
    struct ItemData {
    string name;
    uint power;
    uint price;
    }

function getPlayerItems(address player) public view returns (string[] memory names, uint[] memory powers, uint[] memory prices) {
    Player storage playerData = players[player];
    names = new string[](playerData.items.length);
    powers = new uint[](playerData.items.length);
    prices = new uint[](playerData.items.length);
    for (uint i = 0; i < playerData.items.length; i++) {
        names[i] = playerData.items[i].name;
        powers[i] = playerData.items[i].power;
        prices[i] = playerData.items[i].price;
    }
}

    function generateRandomLoot(address player) public {
    Player storage playerData = players[player];

    // Check if the player has enough capacity to add the new item
    require(playerData.items.length < playerData.capacity, "Not enough capacity to add new item");

    // Define the possible loot items
    Item memory item1 = Item({
        name: "Sword",
        power: 10,
        price: 50
    });
    Item memory item2 = Item({
        name: "Shield",
        power: 5,
        price: 25
    });
    Item memory item3 = Item({
        name: "Potion",
        power: 2,
        price: 10
    });

    // Generate a random number between 1 and 3
    uint randomNumber = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, player))) % 3 + 1;

    // Add the corresponding loot item to the player's inventory
    if (randomNumber == 1) {
        playerData.items.push(item1);
    } else if (randomNumber == 2) {
        playerData.items.push(item2);
    } else {
        playerData.items.push(item3);
        }
    }

    function enterDungeon(address player) public {
    // Check if the player has enough stamina to enter the dungeon
    Player storage playerData = players[player];
    require(playerData.stamina >= 1, "Not enough stamina to enter the dungeon");

    // Deduct 1 stamina from the player
    playerData.stamina = playerData.stamina - 1;

    // Generate a random number to determine if the player wins the fight
    // and a random number to determine the amount of gold as loot
    uint randomNumber = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, player))) % 2;
    uint randomNumberGold = (uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, player))) % 100) + 1;
    if (randomNumber == 0) {
        // The player wins the fight
        // Add the loot to the player's gold balance
        uint loot = randomNumberGold;
        playerData.gold = playerData.gold + loot;

        // Call the generateRandomLoot function to add a random loot item to the player's inventory
        generateRandomLoot(player);
    } else {
        // The player loses the fight and doesn't get any loot
    }
}
    function getTotalItemPower(address player) public view returns (uint) {
    require(players[player].level > 0, "Error: Player does not exist.");

    Player storage playerData = players[player];

    uint totalPower = 0;
    for (uint i = 0; i < playerData.items.length; i++) {
        totalPower = totalPower + playerData.items[i].power;
    }
    return totalPower;
}

    function setMaximumStamina(uint newMaximum) public {
    require(msg.sender == owner, "Error: Only the contract owner can set the maximum stamina.");
    maximumStamina = newMaximum;
    }

    function getVendorItems() public pure  returns (string[] memory names, uint[] memory powers, uint[] memory prices) {
    // Define the vendor's items
    Item memory item1 = Item({
        name: "Sword",
        power: 50,
        price: 100
    });
    Item memory item2 = Item({
        name: "Shield",
        power: 30,
        price: 50
    });
    Item memory item3 = Item({
        name: "Potion",
        power: 10,
        price: 20
    });
    Item[] memory vendorItems = new Item[](3);
    vendorItems[0] = item1;
    vendorItems[1] = item2;
    vendorItems[2] = item3;

    // Initialize the return variables
    names = new string[](vendorItems.length);
    powers = new uint[](vendorItems.length);
    prices = new uint[](vendorItems.length);

    // Populate the return variables with the vendor's item data
    for (uint i = 0; i < vendorItems.length; i++) {
        names[i] = vendorItems[i].name;
        powers[i] = vendorItems[i].power;
        prices[i] = vendorItems[i].price;
        }
    }
    
    function purchaseItem(address player, uint itemId) public {
    // Get the vendor's items
    (string[] memory names, uint[] memory powers, uint[] memory prices) = getVendorItems();

    // Check if the itemId is valid
    require(itemId < names.length, "Invalid itemId");

    // Get the player data
    Player storage playerData = players[player];

    // Check if the player has enough gold to purchase the item
    uint price = prices[itemId];
    require(playerData.gold >= price, "Not enough gold to purchase item");

    // Calculate the total capacity of the items in the player's inventory
    uint totalCapacity = 0;
    for (uint i = 0; i < playerData.items.length; i++) {
        totalCapacity += 1;
    }

    // Check if the player has enough capacity to carry the item
    Item memory item = Item({
        name: names[itemId],
        power: powers[itemId],
        price: price

    });
    require(totalCapacity <= playerData.capacity, "Not enough capacity to carry item");

    // Subtract the item price from the player's gold
    playerData.gold -= price;

    // Add the item to the player's inventory
    addItem(player, item.name, item.power, item.price); // Pass only 3 arguments to addItem
    }
}


// This Solidity contract defines a simple game in which players can have various attributes such as stamina, gold, and experience. It also has a mapping of players indexed by their address, and a struct for storing information 
// about individual players. 
// The contract has functions for adding a new player, updating a player's stamina, adding gold and experience to a player's account, leveling up a player, setting a player's capacity, and adding an item to a player's inventory. 
// It also has a function for allowing a player to enter a dungeon, which checks that the player has sufficient stamina and subtracts one stamina from the player's total. Finally, it has a function for retrieving a player's 
// information and a function for retrieving a player's items, 
// which return the names and powers of the items in the player's inventory.

//Here are a few potential safety issues that could be addressed in this contract:

   // 1 Access control: It might be a good idea to add some access control to certain functions to ensure that only the owner or certain trusted parties can execute them. For example, the addPlayer function could be restricted to only be callable by the contract owner.

   // 2 Input validation: Some functions, such as addGold and addExperience, do not validate the input parameters to ensure that they are within a valid range. It would be a good idea to add input validation checks to these functions to ensure that they are being called with valid arguments.

   // 3 Reentrancy: It's important to ensure that the contract is not vulnerable to reentrancy attacks. This can be done by using the require statement to check the return value of calls to external contracts, or by using the gasleft() function to ensure that there is sufficient gas remaining for the contract to continue execution.

   // 4 Integer overflow and underflow: It's important to handle potential integer overflow and underflow situations in the contract. For example, the addGold function does not check for integer overflow when adding the amount parameter to the player's gold balance.

   // 5 Race conditions: It's important to consider potential race conditions in the contract and to handle them appropriately. For example, the updateStamina function could be vulnerable to a race condition if multiple transactions attempt to update the player's stamina at the same time.

   // 6 Lack of visibility: Some functions, such as levelUp, are marked as private, which means that they are not visible to external contracts. It might be a good idea to make these functions public or external if they need to be called by other contracts.