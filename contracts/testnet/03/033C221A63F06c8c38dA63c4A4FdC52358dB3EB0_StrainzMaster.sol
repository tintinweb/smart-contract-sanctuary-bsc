// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./StrainzNFT/StrainzNFT.sol";
import "./StrainzTokens/StrainzToken.sol";
import "./StrainzTokens/SeedzToken.sol";
import "./StrainzAccessory.sol";
import "./StrainzMarketplace.sol";
import "./SeedsStarterPack.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract StrainzMaster is Ownable {

    StrainzNFT public strainzNFT = new StrainzNFT();
    StrainzToken public strainzToken = new StrainzToken();
    SeedzToken public seedzToken = new SeedzToken(msg.sender);
    StrainzAccessory public strainzAccessory = new StrainzAccessory(msg.sender);
    StrainzMarketplace public strainzMarketplace = new StrainzMarketplace();
    SeedsStarterPack public seedsStarterPack = new SeedsStarterPack(0xF507fbB10940be6bBbE87fF7c8C9A4F61f4bb89C, 0x4f9e0ed73897f054405451D7206340e68225466E, 420420420, 420420420);
    //GOT TO CHANGE THE ABOVE TWO ADDRESSES TO REAL BUDS AND 420 CONTRACT ADDRESSES
    
    //data structure for manager system begins - connova

    mapping(address => bool) isManager;
    
    uint[] setWateringPenaltyInputs;
    mapping(uint => address) setWateringPenaltyCallers;
    uint[] setMarketplaceFeeInputs;
    mapping(uint => address) setMarketplaceFeeCallers;

    modifier onlyManagers {
        require(isManager[msg.sender], "Error: you are not a manager");
        _;
    }

    // data structure for managers ends - connova

    modifier onlyStarter { // added this new modifier for new contract
        require(msg.sender == address(seedsStarterPack), "Error: You are not authorized for this");
        _;
    }

    constructor() {
        isManager[owner()] = true;  //-connova
    }

    bool migrationActive = true;

     function withdraw(address addressToWithdrawTo) public onlyOwner returns(bool) {

        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.
        (bool sent, bytes memory data) = addressToWithdrawTo.call{value: address(this).balance}(""); // - connova
        require(sent, "Failed to send Ether");

    }

    function migrate() public { 
        require(migrationActive);
        uint amountToHarvest = strainzNFT.migrate(msg.sender);
        strainzToken.migrateMint(msg.sender, amountToHarvest);
    }

    function setMigration(bool active) public onlyOwner {
        migrationActive = active;
    }

    function setNewOwner(address newOwner) public {//don't need onlyOwner here since transferOwnership() already has it applied
        transferOwnership(newOwner);
    }

    function addManager(address newManager) public onlyOwner {
        require(!isManager[newManager], "Error: the address is already a manager");
        isManager[newManager] = true;
    }

    function removeManager(address manager) public onlyOwner {
        require(isManager[manager], "Error: that address is already not a manager");
        require(manager != owner(), "Error: the owner cannot be removed");
        isManager[manager] = false;
    }

    function isUserManager(address user) public view returns(bool userIsManager) {
        return isManager[user];
    }

    function setGrowFertilizerDetails(uint newCost, uint newBoost) public onlyOwner {
        seedzToken.setGrowFertilizerDetails(newCost, newBoost);
    }

    function setBreedFertilizerCost(uint newBreedFertilizerCost) public onlyOwner {
        strainzNFT.setBreedFertilizerCost(newBreedFertilizerCost);
    }

    function setBreedingCostFactor(uint newBreedingCostFactor) public onlyOwner {
        strainzNFT.setBreedingCostFactor(newBreedingCostFactor);
    }

    function createNewAccessory(uint bonus) public onlyOwner {
        strainzAccessory.createNewAccessory(bonus, msg.sender);
    }

    function setAccessoryBonus(uint accessoryType, uint bonus) public onlyOwner {
        strainzAccessory.setAccessoryBonus(accessoryType, bonus);
    }

    function setWateringPenalty(uint newPenalty) public onlyManagers {
        
        for(uint i=0; i<setWateringPenaltyInputs.length; i++) {
            
            if(setWateringPenaltyInputs[i] == newPenalty) {

                require(setWateringPenaltyCallers[newPenalty] != msg.sender, "Error: double submission by same manager");
                
                strainzNFT.setWateringPenalty(newPenalty);  //I added everything in this function except this line - connova

                if(i != setWateringPenaltyInputs.length - 1) {
                    setWateringPenaltyInputs[i] = setWateringPenaltyInputs[setWateringPenaltyInputs.length -1];
                }

                setWateringPenaltyInputs.pop();
                setWateringPenaltyCallers[newPenalty] = address(0);

            } else {
                
                setWateringPenaltyInputs.push(newPenalty);
                setWateringPenaltyCallers[newPenalty] = msg.sender;

            }
        }

    }

    function setGrowFactor(uint newGrowFactor) public onlyOwner {
        strainzNFT.setGrowFactor(newGrowFactor);
    }

    function setCompostFactor(uint newCompostFactor) public onlyOwner {
        strainzNFT.setCompostFactor(newCompostFactor);
    }

    function blacklistCheaters(uint[] calldata tokens, address[] calldata users) public onlyOwner {
        strainzNFT.blacklistCheaters(tokens, users);
    }

    function addSeedzPool(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate) public onlyOwner {
        seedzToken.add(_allocPoint, _lpToken, _withUpdate);
    }

    function setSeedzPool(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        seedzToken.set(_pid, _allocPoint, _withUpdate);
    }

    function setSeedzPerBlock(uint _seedzPerBlock) public onlyOwner {
        seedzToken.setSeedzPerBlock(_seedzPerBlock);
    }

    function mintPromotion(address receiver, string memory prefix, string memory postfix, uint dna) public onlyOwner {

        strainzNFT.mintPromotion(receiver, prefix, postfix, dna);

    }

    function mintFromStarter(address receiver, string memory prefix, string memory postfix, uint dna) public onlyStarter {
        
        strainzNFT.mintFromStarter(receiver, prefix, postfix, dna); //added this function for the new seeds starter pack contract to be able to mint new strainz NFTs
        
    } 

    function changePriceOfPot(uint newPrice) public onlyOwner {
        
        seedsStarterPack.setPriceForPot(newPrice);                 // - connova

    }

    function changePriceOfSeedsStarterPack(uint newPrice) public onlyOwner {

        seedsStarterPack.setPriceForSeedsStarterPack(newPrice);                 // - connova

    }

    function setMarketplaceFee(uint newFee) public onlyManagers { 

        for(uint i=0; i<setMarketplaceFeeInputs.length; i++) {
            
            if(setMarketplaceFeeInputs[i] == newFee) {

                require(setMarketplaceFeeCallers[newFee] != msg.sender, "Error: double submission by same manager");
                
                strainzMarketplace.setMarketplaceFee(newFee);   //I added everything in this function except this line - connova

                if(i != setMarketplaceFeeInputs.length - 1) {
                    setMarketplaceFeeInputs[i] = setMarketplaceFeeInputs[setMarketplaceFeeInputs.length -1];
                }  

                setMarketplaceFeeInputs.pop();
                setMarketplaceFeeCallers[newFee] = address(0);
            
            } else {

                setMarketplaceFeeInputs.push(newFee);
                setMarketplaceFeeCallers[newFee] = msg.sender;

            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./StrainzDNA.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../StrainzMaster.sol";
import "../v1/IStrainzV1.sol";
import "./StrainMetadata.sol";

contract StrainzNFT is ERC721Enumerable, StrainzDNA, IStrainMetadata {


    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    event Minted(uint tokenId);
    event Breed(uint parent1, uint parent2, uint child);
    event Composted(uint tokenId);


    uint public wateringPenaltyPerDay = 10; // %
    uint public growFactor = 255;
    uint public compostFactor = 100;
    uint public breedingCostFactor = 5;
    uint public breedFertilizerCost = 1000e18;


    mapping(uint => StrainMetadata) public strainData;

    StrainzMaster master;

    modifier onlyMaster {
        require(msg.sender == address(master));
        _;
    }

    constructor() ERC721("Strainz", "STRAINZ") {
        master = StrainzMaster(msg.sender);
    }
    function _baseURI() internal pure override returns (string memory) {
        return "https://api.v2.strainz.tech/strain/";
    }

    function mintTo(address receiver, string memory prefix, string memory postfix, uint dna, uint generation, uint growRate) private returns (uint) {
        _tokenIdCounter.increment();
        uint tokenId = _tokenIdCounter.current();
        _mint(receiver, tokenId);
        strainData[tokenId] = StrainMetadata(tokenId, prefix, postfix, dna, generation, growRate, block.timestamp, growRate * breedingCostFactor);
        emit Minted(tokenId);
        return tokenId;
    }

    // mint promotional unique strainz (will get custom images)
    function mintPromotion(address receiver, string memory prefix, string memory postfix, uint dna) public onlyMaster {
        mintTo(receiver, prefix, postfix, dna, 0, 255);
    }

    function mintFromStarter(address receiver, string memory prefix, string memory postfix, uint dna) public onlyMaster {
        mintTo(receiver, prefix, postfix, dna, 0, 255);
    }

    // breed two strainz
    function breed(uint _first, uint _second, bool breedFertilizer) public {
        require(ownerOf(_first) == msg.sender && ownerOf(_second) == msg.sender);
        StrainMetadata storage strain1 = strainData[_first];
        StrainMetadata storage strain2 = strainData[_second];

        uint strainzCost = (strain1.breedingCost + strain2.breedingCost) / 2;

        // Burn cost
        master.strainzToken().breedBurn(msg.sender, strainzCost);

        uint newStrainId = mixBreedMint(strain1, strain2, breedFertilizer);
        uint averageGrowRate = (strain1.growRate + strain2.growRate) / 2;
        // Burn fertilizer cost
        if (breedFertilizer && averageGrowRate >= 128) {
            master.seedzToken().breedBurn(msg.sender, breedFertilizerCost);
            master.strainzAccessory().breedAccessories(strain1.id, strain2.id, newStrainId);
        }


        emit Breed(strain1.id, strain2.id, newStrainId);

    }

    function mixBreedMint(StrainMetadata storage strain1, StrainMetadata storage strain2, bool breedFertilizer) private returns (uint) {
        uint newDNA = mixDNA(strain1.dna, strain2.dna);
        uint generation = max(strain1.generation, strain2.generation) + 1;

        bool mix = block.number % 2 == 0;

        strain1.breedingCost = strain1.breedingCost + strain1.growRate * breedingCostFactor;
        strain2.breedingCost = strain2.breedingCost + strain2.growRate * breedingCostFactor;

        return mintTo(
            msg.sender,
            mix ? strain1.prefix : strain2.prefix,
            mix ? strain2.postfix : strain1.postfix,
            newDNA, generation,
            mixStat(strain1.growRate, strain2.growRate, breedFertilizer)
        );
    }


    function compost(uint strainId) public {
        require(ownerOf(strainId) == msg.sender);
        StrainMetadata storage strain = strainData[strainId];
        master.strainzAccessory().detachAll(strainId);
        _burn(strainId);
        master.seedzToken().compostMint(msg.sender, strain.growRate * 1e18 * compostFactor / 100);
        emit Composted(strainId);
    }

    function getWateringCost(uint tokenId) public view returns (uint) {
        StrainMetadata storage strain = strainData[tokenId];
        uint currentGrowRate = getCurrentGrowRateForPlant(tokenId);

        uint diff = strain.growRate - currentGrowRate;

        uint amountOfPlants = balanceOf(ownerOf(tokenId));
        uint penalty = 1;
        if (amountOfPlants > 250) {
            penalty = 9;
        } else if (amountOfPlants > 200) {
            penalty = 8;
        } else if (amountOfPlants > 100) {
            penalty = 7;
        } else if (amountOfPlants > 50) {
            penalty = 5;
        } else if (amountOfPlants > 10) {
            penalty = 3;
        } else if (amountOfPlants > 5) {
            penalty = 2;
        }

        return penalty * diff;
    }

    function harvestAndWaterAll() public {
        uint numberOfTokens = balanceOf(msg.sender);
        require(numberOfTokens > 0);
        uint sum = 0;
        for (uint i = 0; i < numberOfTokens; i++) {
            StrainMetadata storage strain = strainData[tokenOfOwnerByIndex(msg.sender, i)];
            sum += harvestableAmount(strain.id) - getWateringCost(strain.id);
            strain.lastHarvest = block.timestamp;
        }
        master.strainzToken().harvestMint(msg.sender, sum);
    }


    function harvestableAmount(uint tokenId) public view returns (uint) {
        StrainMetadata storage strain = strainData[tokenId];
        uint timeSinceLastHarvest = block.timestamp - strain.lastHarvest;

        uint fertilizerBonus = master.seedzToken().getHarvestableFertilizerAmount(tokenId, strain.lastHarvest);

        uint accessoryBonus = master.strainzAccessory().getHarvestableAccessoryAmount(tokenId, timeSinceLastHarvest);

        uint accumulatedAmount = getAccumulatedHarvestAmount(strain);

        return accumulatedAmount + fertilizerBonus + accessoryBonus;
    }

    function getAccumulatedHarvestAmount(StrainMetadata storage strain) private view returns (uint) {
        uint wateringRange = min(block.timestamp - strain.lastHarvest, 9 days);

        uint growRate = strain.growRate * 1647058824;

        uint harvestableSum = (((20 * growRate * wateringRange * 1 days) - (growRate * wateringRange * wateringRange))) / (20 * 1 days * 1 days) / 1000000000;

        uint stagnationSum = 0;
        if (block.timestamp - strain.lastHarvest > 9 days) {
            stagnationSum = (block.timestamp - strain.lastHarvest + 9 days) * growRate * 10 / 100000000000 days;
        }
        return harvestableSum + stagnationSum;
    }

    function getCurrentGrowRateForPlant(uint plantId) public view returns (uint) {
        StrainMetadata storage strain = strainData[plantId];
        uint timeSinceLastWatering = min(block.timestamp - strain.lastHarvest, 9 days);
        return max(16, strain.growRate - (strain.growRate * wateringPenaltyPerDay * timeSinceLastWatering / 100 days));
    }


    function max(uint a, uint b) private pure returns (uint) {
        if (a > b) {
            return a;
        } else return b;
    }

    function min(uint a, uint b) private pure returns (uint) {
        if (a < b) {
            return a;
        } else return b;
    }

    function mixStat(uint rate1, uint rate2, bool breedFertilizer) private pure returns (uint) {
        uint average = (rate1 + rate2) / 2;
        return breedFertilizer ? min(average + 10, 255) : (average > (25 + 16) ? average - 25 : 16);
    }

    mapping(uint => bool) blacklist; // tokenId -> blacklisted
    mapping(address => bool) blacklistedUser; // address -> blacklisted

    function blacklistCheaters(uint[] calldata tokens, address[] calldata users) public onlyMaster {
        for (uint i = 0; i < tokens.length; i++) {
            blacklist[tokens[i]] = true;
        }
        for (uint i = 0; i < users.length; i++) {
            blacklistedUser[users[i]] = true;
        }
    }

    IStrainzV1 strainzV1NFT = IStrainzV1(0x59516426a8BB328d2F546B05421CBc047042e38f);
    IERC20 strainzV1Token = IERC20(0x7F1AddbB144363730a433A21ACDaB7b36F988252);

    function migrate(address user) public onlyMaster returns (uint) {


        uint numberOfStrainz = min(50, strainzV1NFT.balanceOf(user));

        uint sumToHarvest = 0;
        bool userBlacklisted = blacklistedUser[user];
        //migrate NFT
        if (numberOfStrainz > 0) {
            for (uint i = 0; i < numberOfStrainz; i++) {
                uint id = strainzV1NFT.tokenOfOwnerByIndex(user, 0); // always the first token, because it gets transferred
                StrainMetadata memory strain = getV1Strain(id);
                strainzV1NFT.transferFrom(user, address(this), id); // burn v1


                if (!blacklist[id] && !userBlacklisted) {
                    uint timeSinceLastHarvest = block.timestamp - strain.lastHarvest;
                    uint amountToHarvest = (strain.growRate * 255 * timeSinceLastHarvest) / 24 weeks;
                    // old formular
                    sumToHarvest += amountToHarvest;
                    uint migratedId = mintTo(user, strain.prefix, strain.postfix, strain.dna, strain.generation, max(16, strain.growRate));
                    strainData[migratedId].breedingCost = getNewBreedingCost(strain);

                    // accessories
                    bool hasJoint = getGene(strain.dna, 4) == 1;
                    bool hasSunglasses = getGene(strain.dna, 5) == 1;
                    bool hasEarring = getGene(strain.dna, 6) == 1;
                    bool hasMisc = getGene(strain.dna, 7) == 1;  //added this for miscAccessories - connova
                    if (hasJoint || hasSunglasses || hasEarring || hasMisc) {//modified this if statement to incorporate hasMisc bool - connova
                        master.strainzAccessory().migrateMint(migratedId, hasJoint, hasSunglasses, hasEarring, hasMisc);
                    }

                }
            }
        }


        uint amountOfStrainzV1Tokens = strainzV1Token.balanceOf(user);
        strainzV1Token.transferFrom(user, address(this), amountOfStrainzV1Tokens);
        sumToHarvest += amountOfStrainzV1Tokens;

        return userBlacklisted ? 0 : sumToHarvest;
    }

    function getV1Strain(uint strainId) private view returns (StrainMetadata memory) {
        (uint id,
        string memory prefix,
        string memory postfix,
        uint dna,
        uint generation,
        uint growRate, // 0-255
        uint lastHarvest,
        uint breedingCost) = strainzV1NFT.strainData(strainId);

        return StrainMetadata(id, prefix, postfix, dna, generation, max(16, growRate), lastHarvest, breedingCost);
    }

    function getNewBreedingCost(StrainMetadata memory strain) private pure returns (uint) {
        if (strain.breedingCost == 1000) {
            return strain.growRate * 5;
        } else if (strain.breedingCost == 2000) {
            return strain.growRate * 5 * 2;
        } else if (strain.breedingCost == 4000) {
            return strain.growRate * 5 * 3;
        } else if (strain.breedingCost == 8000) {
            return strain.growRate * 5 * 4;
        } else if (strain.breedingCost == 16000) {
            return strain.growRate * 5 * 5;
        } else if (strain.breedingCost == 32000) {
            return strain.growRate * 5 * 6;
        } else {
            return strain.growRate * 5 * 7;
        }
    }

    function setWateringPenalty(uint newPenalty) public onlyMaster {
        wateringPenaltyPerDay = newPenalty;
    }

    function setGrowFactor(uint newGrowFactor) public onlyMaster {
        growFactor = newGrowFactor;
    }

    function setCompostFactor(uint newCompostFactor) public onlyMaster {
        compostFactor = newCompostFactor;
    }

    function setBreedFertilizerCost(uint newBreedFertilizerCost) public onlyMaster {
        breedFertilizerCost = newBreedFertilizerCost;
    }

    function setBreedingCostFactor(uint newBreedingCostFactor) public onlyMaster {
        breedingCostFactor = newBreedingCostFactor;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../StrainzNFT/StrainzNFT.sol";

contract StrainzToken is ERC20 {
    StrainzMaster master;


    constructor()  ERC20("Strainz", "STRAINZ") {
        master = StrainzMaster(msg.sender);
    }
    modifier onlyMaster() {
        require(msg.sender == address(master));
        _;
    }
    modifier onlyStrainzNFT {
        require(msg.sender == address(master.strainzNFT()));
        _;
    }

    modifier onlyMarketplace {
        require(msg.sender == address(master.strainzMarketplace()));
        _;
    }

    function decimals() public pure override returns(uint8) {
        return 0;
    }

    function harvestMint(address receiver, uint amount) public onlyStrainzNFT {
        _mint(receiver, amount);
    }

    function migrateMint(address receiver, uint amount) public onlyMaster {
        _mint(receiver, amount);
    }

    function breedBurn(address account, uint amount) public onlyStrainzNFT {
        _burn(account, amount);
    }

    function waterBurn(address account, uint amount) public onlyStrainzNFT {
        _burn(account, amount);
    }

    function marketPlaceBurn(address account, uint amount) public onlyMarketplace {
        _burn(account, amount);
    }

    function burn(uint amount) public {
        _burn(msg.sender, amount);
    }


}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "../StrainzMaster.sol";

contract SeedzToken is ERC20 {

    StrainzMaster master;
    modifier onlyMaster() {
        require(msg.sender == address(master));
        _;
    }
    modifier onlyStrainzNFT() {
        require(msg.sender == address(master.strainzNFT()));
        _;
    }

    mapping(uint => uint) public lastTimeGrowFertilizerUsedOnPlant;

    event FertilizerBought(address buyer, uint plantId);

    uint public growFertilizerCost = 500e18;
    uint public growFertilizerBoost = 100;

    function buyGrowFertilizer(uint plantId) public {
        uint cost = growFertilizerCost;

        require(balanceOf(msg.sender) >= cost);
        require(lastTimeGrowFertilizerUsedOnPlant[plantId] + 1 weeks < block.timestamp);
        _burn(msg.sender, cost);
        lastTimeGrowFertilizerUsedOnPlant[plantId] = block.timestamp;
        emit FertilizerBought(msg.sender, plantId);
    }

    function setGrowFertilizerDetails(uint newCost, uint newBoost) public onlyMaster {
        growFertilizerCost = newCost;
        growFertilizerBoost = newBoost;
    }
    // LP Pools by Sushiswap: https://etherscan.io/address/0xc2edad668740f1aa35e4d8f227fb8e17dca888cd#code
    // Info of each user.
    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of SEEDZ
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accSeedzPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accSeedzPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. SEEDZ to distribute per block.
        uint256 lastRewardBlock;  // Last block number that SEEDZ distribution occurs.
        uint256 accSeedzPerShare; // Accumulated SEEDZ per share, times 1e12. See below.
    }

    // SEEDZ tokens created per block.
    uint256 public seedzPerBlock = 5e17;

    function setSeedzPerBlock(uint _seedzPerBlock) public onlyMaster {
        massUpdatePools();
        seedzPerBlock = _seedzPerBlock;

    }

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation poitns. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;


    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);


    constructor(address owner) ERC20("Seedz", "SEEDZ") {
        master = StrainzMaster(msg.sender);
        _mint(owner, 125000 * 1e18); // initial liquidity
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate) public onlyMaster {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint += _allocPoint;
        poolInfo.push(PoolInfo({
        lpToken : _lpToken,
        allocPoint : _allocPoint,
        lastRewardBlock : block.number,
        accSeedzPerShare : 0
        }));
    }

    // Update the given pool's SEEDZ allocation point. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyMaster {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint - poolInfo[_pid].allocPoint + _allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    // View function to see pending SEEDZ on frontend.
    function pendingSeedz(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accSeedzPerShare = pool.accSeedzPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = block.number - pool.lastRewardBlock;
            uint256 seedzReward = multiplier * seedzPerBlock * pool.allocPoint / totalAllocPoint;
            accSeedzPerShare += seedzReward * 1e12 / lpSupply;
        }
        return (user.amount * accSeedzPerShare / 1e12) - user.rewardDebt;
    }

    // Update reward vairables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = block.number - pool.lastRewardBlock;
        uint256 seedzReward = multiplier * seedzPerBlock * pool.allocPoint / totalAllocPoint;
        _mint(address(this), seedzReward);
        pool.accSeedzPerShare += seedzReward * 1e12 / lpSupply;
        pool.lastRewardBlock = block.number;
    }

    // Deposit LP tokens to MasterChef for SEEDZ allocation.
    function deposit(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = (user.amount * pool.accSeedzPerShare / 1e12) - user.rewardDebt;
            safeSeedzTransfer(msg.sender, pending);
        }
        pool.lpToken.transferFrom(address(msg.sender), address(this), _amount);
        user.amount += _amount;
        user.rewardDebt = user.amount * pool.accSeedzPerShare / 1e12;
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = (user.amount * pool.accSeedzPerShare / 1e12) - user.rewardDebt;
        safeSeedzTransfer(msg.sender, pending);
        user.amount -= _amount;
        user.rewardDebt = user.amount * pool.accSeedzPerShare / 1e12;

        pool.lpToken.transfer(address(msg.sender), _amount);

        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.lpToken.transfer(address(msg.sender), amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    // Safe SEEDZ transfer function, just in case if rounding error causes pool to not have enough SEEDZ.
    function safeSeedzTransfer(address _to, uint256 _amount) internal {
        uint256 seedzBal = balanceOf(address(this));
        if (_amount > seedzBal) {
            _transfer(address(this), _to, seedzBal);
        } else {
            _transfer(address(this), _to, _amount);
        }
    }


    function compostMint(address receiver, uint amount) public onlyStrainzNFT {
        _mint(receiver, amount);
    }

    function getHarvestableFertilizerAmount(uint strainId, uint lastHarvest) public view returns (uint) {
        uint fertilizerBonus = 0;
        uint fertilizerAttachTime = lastTimeGrowFertilizerUsedOnPlant[strainId];
        if (fertilizerAttachTime > 0) {
            uint start = max(fertilizerAttachTime, lastHarvest);

            uint end = min(start + 1 weeks, block.timestamp);

            fertilizerBonus = (end - start) * growFertilizerBoost / 1 days;
        }
        return fertilizerBonus;
    }

    function breedBurn(address account, uint amount) public onlyStrainzNFT {
        _burn(account, amount);
    }


    function max(uint a, uint b) private pure returns (uint) {
        if (a > b) {
            return a;
        } else return b;
    }

    function min(uint a, uint b) private pure returns (uint) {
        if (a < b) {
            return a;
        } else return b;
    }


    function decimals() public pure override returns (uint8) {
        return 18;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
//maybe we'll have to remove '../node_modules/' once deploying in the 3 lines below
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./StrainzMaster.sol";


contract StrainzAccessory is ERC721Enumerable, IERC721Receiver {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    // accessoryId -> accessoryType (Joint, Sunglasses, Earring, ...)
    mapping(uint => uint) public accessoryTypeByTokenId;
    // accessoryId -> time
    mapping(uint => uint) public timeOfLastAttachment;

    // strainzNFT -> tokenIds
    mapping(uint => uint[]) public accessoriesByStrainId;
    function getAccessoriesByStrainId(uint strainId) public view returns (uint[] memory) {
        return accessoriesByStrainId[strainId];
    }


    uint numberOfAccessoryTypes = 0;
    mapping(uint => uint) public growBonusForType;

    event AccessoryAttached(uint accessoryId, uint strainId);

    StrainzMaster master;
    modifier onlyMaster {
        require(msg.sender == address(master));
        _;
    }

    modifier onlyStrainzNFT {
        require(msg.sender == address(master.strainzNFT()));
        _;
    }

    constructor(address owner) ERC721("Strainz Accessory", "ACCESSORY") {
        master = StrainzMaster(msg.sender);
        createNewAccessory(10, owner);
        createNewAccessory(25, owner);
        createNewAccessory(50, owner);
        createNewAccessory(0, owner); //added a new creation for miscAccessory with a bonus of 0
    }

    // creates new accessory (breeding)
    function mintAccessory(uint typeId, uint strainId) private {
        uint accessoryId = mint(typeId, address(this));
        accessoriesByStrainId[strainId].push(accessoryId);
        timeOfLastAttachment[accessoryId] = block.timestamp;
    }

    // creates new accessory (migration)
    function migrateMint(uint strainId, bool hasJoint, bool hasSunglasses, bool hasEarring, bool hasMisc) public onlyStrainzNFT {
        if (hasMisc) { //added this additional if statement and bool for the miscAccessories - connova
            mintAccessory(4, strainId);
        }
        if (hasJoint) {
            mintAccessory(3, strainId);
        }
        if (hasSunglasses) {
            mintAccessory(2, strainId);
        }
        if (hasEarring) {
            mintAccessory(1, strainId);
        }

    }

    // initial accessories
    function mint(uint typeId, address receiver) private returns (uint){
        require(typeId <= numberOfAccessoryTypes && typeId > 0);
        _tokenIdCounter.increment();
        uint accessoryId = _tokenIdCounter.current();
        _mint(receiver, accessoryId);
        accessoryTypeByTokenId[accessoryId] = typeId;
        return accessoryId;
    }

    // attach accessory on plant
    function attachAccessory(uint accessoryId, uint strainId) public {
        require(ownerOf(accessoryId) == msg.sender);
        require(master.strainzNFT().ownerOf(strainId) == msg.sender);
        // no double accessories
        require(!sameTypeAlreadyAttached(accessoriesByStrainId[strainId], accessoryTypeByTokenId[accessoryId]));

        transferFrom(msg.sender, address(this), accessoryId);
        accessoriesByStrainId[strainId].push(accessoryId);
        timeOfLastAttachment[accessoryId] = block.timestamp;
        emit AccessoryAttached(accessoryId, strainId);
    }

    // detach accessory (compost)
    function detachAccessory(uint accessoryId, uint strainId) private {
        uint[] storage accessories = accessoriesByStrainId[strainId];
        int index = indexOf(accessories, accessoryId);
        require(index >= 0);
        remove(accessories, uint(index));
        _transfer(address(this), master.strainzNFT().ownerOf(strainId), accessoryId);
    }

    function getHarvestableAccessoryAmount(uint strainId, uint timeSinceLastHarvest) public view returns (uint) {
        uint[] memory accessoryIds = getAccessoriesByStrainId(strainId);

        uint accessoryBonus = 0;
        for (uint i = 0; i < accessoryIds.length; i++) {
            uint accessoryType = accessoryTypeByTokenId[accessoryIds[i]];
            uint boost = growBonusForType[accessoryType];
            uint timeOfAttachment = timeOfLastAttachment[accessoryIds[i]];
            if (timeOfAttachment == 0) {
                continue;
            }
            uint attachTime = min(block.timestamp - timeOfAttachment, timeSinceLastHarvest);

            accessoryBonus += attachTime * boost / 1 days;
        }
        return accessoryBonus;
    }


    // detach all (compost)
    function detachAll(uint strainId) public onlyStrainzNFT {
        uint[] memory accessoryIds = accessoriesByStrainId[strainId];
        for (uint i = 0; i < accessoryIds.length; i++) {
            detachAccessory(accessoryIds[i], strainId);
        }
    }


    function sameTypeAlreadyAttached(uint[] storage array, uint newType) private view returns (bool) {
        for (uint i = 0; i < array.length; i++) {
            uint existingType = accessoryTypeByTokenId[array[i]];
            if (existingType == newType) {
                return true;
            }
        }
        return false;
    }

    // generates accessories based on parents/fertilizer
    function breedAccessories(uint strain1Id, uint strain2Id, uint newStrainId) public onlyStrainzNFT {
        uint[] storage strain1Accessories = accessoriesByStrainId[strain1Id];
        uint[] storage strain2Accessories = accessoriesByStrainId[strain2Id];

        for (uint i = 1; i <= numberOfAccessoryTypes; i++) {
            bool hasParent1 = sameTypeAlreadyAttached(strain1Accessories, i);
            bool hasParent2 = sameTypeAlreadyAttached(strain2Accessories, i);
            if (hasParent1 && hasParent2){
                mintAccessory(i, newStrainId);
            }

        }

    }

    function createNewAccessory(uint bonus, address owner) public onlyMaster {
        require(numberOfAccessoryTypes < 10);
        numberOfAccessoryTypes++;
        growBonusForType[numberOfAccessoryTypes] = bonus;
        for (uint i = 0; i < 20; i++) {
            mint(numberOfAccessoryTypes, owner);
        }
    }

    function setAccessoryBonus(uint accessoryType, uint bonus) public onlyMaster {
        growBonusForType[accessoryType] = bonus;
    }


    function max(uint a, uint b) private pure returns (uint) {
        if (a > b) {
            return a;
        } else return b;
    }

    function min(uint a, uint b) private pure returns (uint) {
        if (a < b) {
            return a;
        } else return b;
    }

    function remove(uint[] storage array, uint index) private {
        if (index >= array.length) {
            return;
        }
        array[index] = array[array.length - 1];
        array.pop();
    }

    function indexOf(uint[] storage array, uint tokenId) private view returns (int) {
        for (uint i = 0; i < array.length; i++) {
            if (array[i] == tokenId) {
                return int(i);
            }
        }
        return - 1;
    }

    bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;

    function onERC721Received(address, address, uint256, bytes calldata) public pure override returns (bytes4) {
        return ERC721_RECEIVED;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./StrainzTokens/StrainzToken.sol";
import "./StrainzMaster.sol";

contract StrainzMarketplace is IERC721Receiver {
    using Counters for Counters.Counter;
    Counters.Counter private _tradeCounter;
    enum TradeStatus {
        Open, Closed, Cancelled
    }
    struct ERC721Trade {
        uint id;
        address poster;
        address nftContractAddress;
        uint tokenId;
        uint strainzTokenPrice;
        TradeStatus status;
        address buyer;
    }

    event ERC721TradeStatusChange(uint tradeId, TradeStatus status);

    mapping(uint => ERC721Trade) public erc721Trades;
    uint public marketplaceFee = 10;

    StrainzMaster master;
    modifier onlyMaster {
        require(msg.sender == address(master));
        _;
    }
    constructor() {
        master = StrainzMaster(msg.sender);
    }

    function setMarketplaceFee(uint newFee) public onlyMaster {
        marketplaceFee = newFee;
    }

    function getTradeCount() public view returns (uint) {
        return _tradeCounter.current();
    }

    function openERC721Trade(address nftContractAddress, uint tokenId, uint price) public {
        IERC721 nftContract = IERC721(nftContractAddress);
        require(nftContract.ownerOf(tokenId) == msg.sender);
        _tradeCounter.increment();
        nftContract.transferFrom(msg.sender, address(this), tokenId);
        uint id = _tradeCounter.current();
        erc721Trades[id] = ERC721Trade(id, msg.sender, nftContractAddress, tokenId, price, TradeStatus.Open, address(0));

        emit ERC721TradeStatusChange(id, TradeStatus.Open);
    }

    function executeERC721Trade(uint tradeId) public {
        ERC721Trade memory trade = erc721Trades[tradeId];
        require(trade.status == TradeStatus.Open);
        uint marketPlaceShare = trade.strainzTokenPrice * marketplaceFee / 100;

        master.strainzToken().marketPlaceBurn(msg.sender, marketPlaceShare); // fee is burnt increasing market price of strainzToken

        master.strainzToken().transferFrom(msg.sender, trade.poster, trade.strainzTokenPrice - marketPlaceShare);
        IERC721 nftContract = IERC721(trade.nftContractAddress);
        nftContract.safeTransferFrom(address(this), msg.sender, trade.tokenId);

        erc721Trades[tradeId].status = TradeStatus.Closed;
        erc721Trades[tradeId].buyer = msg.sender;
        emit ERC721TradeStatusChange(tradeId, TradeStatus.Closed);
    }

    function cancelERC721Trade(uint tradeId) public {
        ERC721Trade memory trade = erc721Trades[tradeId];
        require(msg.sender == trade.poster);
        require(trade.status == TradeStatus.Open);
        IERC721 nftContract = IERC721(trade.nftContractAddress);
        nftContract.transferFrom(address(this), trade.poster, trade.tokenId);

        erc721Trades[tradeId].status = TradeStatus.Cancelled;
        emit ERC721TradeStatusChange(tradeId, TradeStatus.Cancelled);
    }


    bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;

    function onERC721Received(address, address, uint256, bytes calldata) public pure override returns (bytes4) {
        return ERC721_RECEIVED;
    }


}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./StrainzMaster.sol";


contract SeedsStarterPack is ERC721Enumerable{

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    address budsContract;
    address fourTwentyContract;

    uint priceForPot;
    uint priceForSeedsStarterPack;

    StrainzMaster master;
    mapping (address => bool) isMaster;

    mapping(uint => bool) isNFTConsumedToMintStrainzNFT;
    mapping(uint => bool) isPot;
    mapping(address => uint[]) wallet;

    constructor(address buds, address fourTwenty, uint priceOfPot, uint priceOfSeedsStarterPack) ERC721("Strainz Starterpack", "Starter") {
        budsContract = buds;
        fourTwentyContract = fourTwenty;
        master = StrainzMaster(msg.sender);
        priceForPot = priceOfPot;
        priceForSeedsStarterPack = priceOfSeedsStarterPack;
        isMaster[msg.sender] = true;
    }

    function setPriceForPot(uint newPrice) public {
        require(isMaster[msg.sender], "Error: Authorization Denied"); // -connova
        priceForPot = newPrice;
    }

    function setPriceForSeedsStarterPack(uint newPrice) public {
        require(isMaster[msg.sender] == true, "Error: Authorization Denied"); // -connova
        priceForSeedsStarterPack = newPrice;
    }

    function buyPot() public {
        IERC20(budsContract).transferFrom(msg.sender, address(this), priceForPot);
        _tokenIdCounter.increment();
         uint potId = _tokenIdCounter.current();
        _mint(msg.sender, potId);
        isPot[potId] = true;
        wallet[msg.sender].push(potId);
    }

    function buySeedsStarterPack(string memory firstNameOfPlant, string memory lastNameOfPlant) public {
        bool hasConsumablePot;
        uint eligiblePotIndex;
        for (uint i = 0; i < wallet[msg.sender].length; i++) {
            if (isPot[wallet[msg.sender][i]] && !isNFTConsumedToMintStrainzNFT[wallet[msg.sender][i]]) {
                hasConsumablePot = true;
                eligiblePotIndex = i;
                break;
            }
        }
        require(hasConsumablePot, "Error: You do not have a pot available");
        IERC20(fourTwentyContract).transferFrom(msg.sender, address(this), priceForSeedsStarterPack);
        _tokenIdCounter.increment();
        uint starterPackID = _tokenIdCounter.current();
        _mint(msg.sender, starterPackID);
        uint dna = makeDNA();
        master.mintFromStarter(msg.sender, firstNameOfPlant, lastNameOfPlant, dna);
        isNFTConsumedToMintStrainzNFT[wallet[msg.sender][eligiblePotIndex]] = true;
        isNFTConsumedToMintStrainzNFT[starterPackID] = true;
    }

    function isTokenAPot(uint tokenId) public view returns(bool) {
        require(tokenId <= _tokenIdCounter.current(), "Error: Token doesn't exist");
        return isPot[tokenId];
    }

    function makeDNA() public view returns(uint) {
        uint randomValue = random();
        uint j = randomValue;
        uint length;
        while (j !=0) {
            length++;
            j /= 10;
        }

        while (randomValue > 99999999999999999) {
            randomValue /= 10;
        }

        return randomValue;
    }

    function random() internal view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StrainzDNA {

    struct DNAData {
        uint potGene;
        uint headGene;
        uint bodyGene;
        uint faceGene;
        uint jointGene;
        uint sunglassesGene;
        uint earringGene;
        uint miscAccessories; //added new accessory here - connova
        uint redGene;
        uint greenGene;
        uint blueGene;
    }

    function getGene(uint dna, uint n) public pure returns (uint) {
        return (dna / (10 ** (16 - n))) % 10; //changed 15 to 16 here due to addition of miscAccessories in DNAData struct - connova
    }

    function getBlueGene(uint dna) public pure returns (uint){
        return dna % 1000;
    }

    function getGreenGene(uint dna) public pure returns (uint) {
        return (dna % 1000000 - (dna % 1000)) / 1000;
    }

    function getRedGene(uint dna) public pure returns (uint) {
        return (dna % 1000000000 - (dna % 1000000)) / 1000000;
    }

    function mixDNA(uint dna1, uint dna2) public view returns (uint) {
        uint randomValue = random(256);
        DNAData memory data = DNAData(
            ((getGene(dna1, 0) * getGene(dna2, 0) * randomValue) % 7) + 1, // pot
            ((getGene(dna1, 1) * getGene(dna2, 1) * randomValue) % 7) + 1, // head
            ((getGene(dna1, 2) * getGene(dna2, 2) * randomValue) % 6) + 1, // body
            ((getGene(dna1, 3) * getGene(dna2, 3) * randomValue) % 5) + 1, // face
            0, // joint (not used)
            0, // sunglass (not used)
            0, // earring (not used)
            0, // miscAccessories (not used) -connova
            (getRedGene(dna1) * getRedGene(dna2) + randomValue) % 256, // red
            (getGreenGene(dna1) * getGreenGene(dna2) + randomValue) % 256, // green
            (getBlueGene(dna1) * getBlueGene(dna2) + randomValue) % 256 // blue
        );


        uint newDNA = ((10 ** 16) * data.potGene) + ((10 ** 15) * data.headGene) + ((10 ** 14) * data.bodyGene)//added 1 to each exponent -connova
        + ((10 ** 13) * data.faceGene) + ((10 ** 12) * data.jointGene) + ((10 ** 11) * data.sunglassesGene) + ((10 ** 10) * data.earringGene)//same change as above line - connova
        + ((10 ** 6) * data.redGene) + ((10 ** 3) * data.greenGene) + (data.blueGene % 256);//shouldn't have to change this line despite addition of miscAccessories - connova

        return newDNA;
    }


    function clamp(uint value, uint min, uint max) public pure returns (uint) {
        return (value < min) ? min : (value > max) ? max : value;
    }

    function random(uint range) internal view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp))) % range;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "./IERC721Enumerable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "../StrainzNFT/StrainMetadata.sol";

abstract contract IStrainzV1 is IERC721Enumerable, IStrainMetadata {
    function harvestAll() public virtual;
    mapping(uint => StrainMetadata) public strainData;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IStrainMetadata {
    struct StrainMetadata {
        uint id;
        string prefix;
        string postfix;
        uint dna;
        uint generation;
        uint growRate; // 0-255
        uint lastHarvest;
        uint breedingCost;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}