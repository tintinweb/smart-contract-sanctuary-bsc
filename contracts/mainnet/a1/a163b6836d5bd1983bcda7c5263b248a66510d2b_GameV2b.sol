// SPDX-License-Identifier: UNLICENSED
// PLay Poseidon Game Contracts v2.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./NFT.sol";
import "./GameItem.sol";
import "./GameCoin.sol";
import "./GameLibs.sol";

contract GameV2b is OwnableUpgradeable {
    function initialize(
        address owner_address
    ) public virtual initializer {
        __Game_init(owner_address);
    }

    function __Game_init(
        address owner_address
    ) internal initializer {
        OwnableUpgradeable.__Ownable_init();
        __Game_init_unchained(owner_address);
    }

    function __Game_init_unchained(
        address owner_address
    ) internal initializer {
        OwnableUpgradeable.__Ownable_init_unchained();
        transferOwnership(owner_address);
    }

    /**
     * All state variable must be defined here and never change the order nor remove old one
     *
     * See https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable#potentially-unsafe-operations.
     */
    // Version 1
    NFT public heroNFT;
    NFT public petNFT;
    GameItems public gameItems;
    GameCoin public gameCoin;

    mapping(address => uint8) private gameMasterMap_address_tier;
    // NFT Hero
    mapping(uint256 => uint8) private heroNFTMap_tokenId_gradeIndex;
    mapping(uint8 => uint256) private heroNFTMap_gradeIndex_mintCount;
    mapping(uint8 => uint8) private heroNFTMap_gradeIndex_noClass;
    mapping(uint256 => uint8) private heroNFTMap_tokenId_classIndex;
    mapping(uint256 => uint256) private heroNFTMap_tokenId_combinationIndex;
    // NFT Pet
    bytes32 private _randomSeed;
    mapping(uint256 => uint8) private petNFTMap_tokenId_rarityLevel;
    mapping(uint8 => uint256) private petNFTMap_rarityLevel_mintCount;
    mapping(uint8 => uint8) private petNFTMap_rarityLevel_noClass;
    mapping(uint256 => uint8) private petNFTMap_tokenId_classIndex;
    mapping(uint256 => uint256) private petNFTMap_tokenId_attribute1;
    // GameCoin
    mapping(address => uint256) private claimRewardHistoryMap_address_timestamp;
    uint256 private claimRewardCooldown;
    uint256 private _totalRewardClaimed;
    uint256 private _currentRewardBudget;
    // Upgrade NFT Hero Level
    mapping(uint256 => uint256[]) private heroNFTMap_tokenId_fusedHeroTokenId;
    uint8 private _heroNFTMaxLevel;
    // Shopping
    mapping(uint256 => uint256) private shoppingPriceMap_itemTypeId_weiPrice;
    // Market place
    uint256 private _marketPlaceTransactionFeePercent;
    // GameV2 starting from here
    event EventHeroUpgrade(address operator, address indexed heroOwner, uint256 indexed heroTokenId, uint256 indexed fusingHeroTokenId, uint toLevel, uint category);
    event EventClaimRewardCoin(address operator, address indexed claimTo, uint256 amount, uint category);
    // GameV2b
    NFT public orbNFT;
    // Mapping from orbNFT token ID to the token ID of the bound heroNFT
    mapping(uint256 => uint256) private _orbNFTBoundToTokenId;

    mapping(uint256 => uint8) private orbNFTMap_tokenId_rarityLevel;
    mapping(uint256 => uint8) private orbNFTMap_tokenId_classIndex;
    mapping(uint256 => uint256) private orbNFTMap_tokenId_attribute1;
    mapping(uint256 => uint256) private orbNFTMap_tokenId_attribute2;
    // Upgrade NFT Orb Level
    mapping(uint256 => uint256[]) private orbNFTMap_tokenId_fusedGemTokenTypeId;
    uint8 private _orbNFTMaxLevel;

    event EventOrbUpgrade(address operator, address indexed orbOwner, uint256 indexed orbTokenId, uint256 fusedGemTokenTypeId, uint curLevel, uint afterLevel, uint category);
    // mint cost when craft equipment
    mapping(uint8 => uint256) private mintCostMap_rarityLevel_weiPrice;
    // End
    function generateRandomNumber(uint256 maxNumber, uint256 seedOffset0, uint256 seedOffset1, uint256 seedOffset2) private returns (uint256) {
        return uint256(keccak256(abi.encodePacked(
                seedOffset2,
                _randomSeed,
                block.timestamp,
                block.difficulty,
                seedOffset1,
                msg.sender,
                maxNumber,
                blockhash(block.number - 1),
                seedOffset0,
                _totalRewardClaimed
            ))) % maxNumber;
    }

    function setRandomSeed(bytes32 randomSeed) external {
        require(
            (owner() == _msgSender() || isGameMaster(_msgSender(), 2)),
            "Game: revert"
        );
        _randomSeed = randomSeed;
    }

    function setHeroNFTContract(address contractAddress) external onlyOwner {
        heroNFT = NFT(contractAddress);
    }

    function setPetNFTContract(address contractAddress) external onlyOwner {
        petNFT = NFT(contractAddress);
    }

    function setGameItemsContract(address contractAddress) external onlyOwner {
        gameItems = GameItems(contractAddress);
    }

    function setGameCoinContract(address contractAddress) external onlyOwner {
        gameCoin = GameCoin(contractAddress);
    }

    function setOrbNFTContract(address contractAddress) external onlyOwner {
        orbNFT = NFT(contractAddress);
    }

    function setGameMasterAddress(address gameMasterAddress, uint8 tier) external onlyOwner {
        gameMasterMap_address_tier[gameMasterAddress] = tier;
    }

    function isGameMaster(address gameMasterAddress) private returns (bool){
        return gameMasterMap_address_tier[gameMasterAddress] > 0;
    }

    function isGameMaster(address gameMasterAddress, uint8 tier) private returns (bool){
        require(tier > 0, "Game: revert");
        return gameMasterMap_address_tier[gameMasterAddress] >= tier;
    }

    function setNumberOfClassPerHeroGrade(uint8 gradeIndex, uint8 number) external onlyOwner {
        heroNFTMap_gradeIndex_noClass[gradeIndex] = number;
    }

    function mintHeroNFT(uint8 gradeIndex, address to) external onlyOwner returns (uint256){
        return _mintHeroNFT(gradeIndex, to, 0);
    }

    function _mintHeroNFT(uint8 gradeIndex, address to, uint256 seedOffset) private returns (uint256){
        require(gradeIndex > 0, "Game: revert");
        uint8 class_count = heroNFTMap_gradeIndex_noClass[gradeIndex];
        require(class_count > 0, "Game: revert");
        uint256 nft_tokenId = heroNFT.mint(to);
        // set Grade of HeroNFT with nft_tokenId , gradeIndex start from 1
        heroNFTMap_tokenId_gradeIndex[nft_tokenId] = gradeIndex;

        uint256 currentCount = heroNFTMap_gradeIndex_mintCount[gradeIndex];
        // used current count of grade NFT to chose class (this will ensure equal distribution of Hero class)
        // classIndex must greater than 0
        heroNFTMap_tokenId_classIndex[nft_tokenId] = uint8(1 + (currentCount % uint256(class_count)));

        // generate zodiac sets of 1
        uint256 maxCombinationIndex = 12;
        // generate zodiac sets of 4
        if (gradeIndex == 1) maxCombinationIndex = 1365;
        // generate zodiac sets of 3
        else if (gradeIndex == 2 || gradeIndex == 3) maxCombinationIndex = 364;
        // generate zodiac sets of 2
        else if (gradeIndex == 4 || gradeIndex == 5) maxCombinationIndex = 78;

        uint256 combinationIndex = 1 + generateRandomNumber(maxCombinationIndex, seedOffset + 160, seedOffset + nft_tokenId, seedOffset + 1);

        heroNFTMap_tokenId_combinationIndex[nft_tokenId] = combinationIndex;

        // increase count of grade NFT
        heroNFTMap_gradeIndex_mintCount[gradeIndex] = currentCount + 1;

        return nft_tokenId;
    }

    function getHeroNFTGrade(uint256 nft_tokenId) public view returns (uint8 gradeIndex, string memory grade) {
        gradeIndex = heroNFTMap_tokenId_gradeIndex[nft_tokenId];
        require(gradeIndex > 0, "Game: revert");
        grade = NFTHero.getGrade(gradeIndex);
    }

    function getHeroNFTClass(uint256 nft_tokenId) public view returns (uint8 gradeIndex, uint8 classIndex, string memory class_id) {
        gradeIndex = heroNFTMap_tokenId_gradeIndex[nft_tokenId];
        classIndex = heroNFTMap_tokenId_classIndex[nft_tokenId];
        require(gradeIndex > 0 && classIndex > 0, "Game: revert");
        class_id = NFTHero.genHeroClassIds()[gradeIndex - 1][classIndex - 1];
    }

    function getHeroNFTZodiacSet(uint256 nft_tokenId) public view returns (uint256 combinationIndex, string memory z1, string memory z2, string memory z3, string memory z4) {
        uint8 gradeIndex = heroNFTMap_tokenId_gradeIndex[nft_tokenId];
        combinationIndex = heroNFTMap_tokenId_combinationIndex[nft_tokenId];
        require(gradeIndex > 0 && combinationIndex > 0, "Game: revert");
        if (gradeIndex == 1) {
            (z1, z2, z3, z4) = NFTHero.getZodiacSignSet4Combination(combinationIndex);
        } else if (gradeIndex == 2 || gradeIndex == 3) {
            (z1, z2, z3) = NFTHero.getZodiacSignSet3Combination(combinationIndex);
            z4 = "";
        } else if (gradeIndex == 4 || gradeIndex == 5) {
            (z1, z2) = NFTHero.getZodiacSignSet2Combination(combinationIndex);
            z3 = "";
            z4 = "";
        } else if (gradeIndex == 6 || gradeIndex == 7) {
            z1 = NFTHero.getZodiacSign(uint8(combinationIndex));
            z2 = "";
            z3 = "";
            z4 = "";
        }
    }

    // PET

    function setNumberOfClassPerPetRarity(uint8 rarityLevel, uint8 number) external onlyOwner {
        petNFTMap_rarityLevel_noClass[rarityLevel] = number;
    }

    function mintPetNFT(uint8 rarityLevel, address to) external onlyOwner returns (uint256){
        return _mintPetNFT(rarityLevel, to, 0);
    }

    function _mintPetNFT(uint8 rarityLevel, address to, uint256 seedOffset) private returns (uint256){
        require(rarityLevel <= 7, "Game: revert");
        require(petNFTMap_rarityLevel_noClass[rarityLevel] > 0, "Game: revert");
        uint256 nft_tokenId = petNFT.mint(to);
        // set RarityLevel of PetNFT with nft_tokenId , gradeIndex start from 1
        petNFTMap_tokenId_rarityLevel[nft_tokenId] = rarityLevel;

        // currentCount = petNFTMap_rarityLevel_mintCount[rarityLevel];
        // used current count of Rarity NFT to chose class (this will ensure equal distribution of Pet class)
        // classIndex must greater than 0
        petNFTMap_tokenId_classIndex[nft_tokenId] = uint8(1 + (petNFTMap_rarityLevel_mintCount[rarityLevel] % uint256(petNFTMap_rarityLevel_noClass[rarityLevel])));

        // increase count of Rarity NFT
        petNFTMap_rarityLevel_mintCount[rarityLevel] = petNFTMap_rarityLevel_mintCount[rarityLevel] + 1;

        // gen random attributes based on rarity
        uint256 attr1_plus_random_range = 0;
        uint256 attr1 = 0;
        (attr1_plus_random_range, attr1) = NFTPet.getAttrRandomRange(rarityLevel);
        if (attr1_plus_random_range > 0) {
            // 1st offset is line number in source code, 3st offset is 1 due to only generate one
            attr1 += generateRandomNumber(attr1_plus_random_range, seedOffset + 250, seedOffset + nft_tokenId, seedOffset + 1);
        }
        petNFTMap_tokenId_attribute1[nft_tokenId] = attr1;
        // default value of mapping is 0, so keep in mind
        return nft_tokenId;
    }

    function getPetNFTRarity(uint256 nft_tokenId) public view returns (uint8 rarityLevel, string memory rarity) {
        rarityLevel = petNFTMap_tokenId_rarityLevel[nft_tokenId];
        require(rarityLevel > 0, "Game: revert");
        rarity = NFTPet.getRarity(rarityLevel);
    }


    function getPetNFTClass(uint256 nft_tokenId) public view returns (uint8 rarityLevel, uint8 classIndex, string memory class_id) {
        rarityLevel = petNFTMap_tokenId_rarityLevel[nft_tokenId];
        classIndex = petNFTMap_tokenId_classIndex[nft_tokenId];
        require(rarityLevel > 0 && classIndex > 0, "Game: revert");
        class_id = NFTPet.genPetClassIds()[rarityLevel - 1][classIndex - 1];
    }

    function getPetNFTAttrBonusBuff(uint256 nft_tokenId) public view returns (uint256) {
        // attributes bonus buff is attribute1
        return petNFTMap_tokenId_attribute1[nft_tokenId];
    }


    function summonHeroUsingTotem(address account, uint256 itemId, uint8 quantity) external {
        require(
            (account == _msgSender() || isGameMaster(_msgSender())),
            "Game: revert"
        );
        string memory itemType;
        string memory itemName;
        (itemType, itemName) = gameItems.getItemInfo(itemId);
        string memory TOTEM = "TOTEM";
        require(CommonUtils.hashCompareWithLengthCheck(itemType, TOTEM), "Game: revert");
        gameItems.burn(account, itemId, quantity);
        // if gradeIndex=0 it will throw error when _mintHeroNFT
        uint8 gradeIndex = 0;
        // itemName="Totem Grade S"
        if (itemId == 3) gradeIndex = 1;
        // itemName="Totem Grade A"
        else if (itemId == 4) gradeIndex = 2;
        // itemName="Totem Grade B"
        else if (itemId == 5) gradeIndex = 3;
        // itemName="Totem Grade C"
        else if (itemId == 6) gradeIndex = 4;
        // itemName="Totem Grade D"
        else if (itemId == 7) gradeIndex = 5;
        // itemName="Totem Grade E"
        else if (itemId == 8) gradeIndex = 6;
        // itemName="Totem Grade F"
        else if (itemId == 9) gradeIndex = 7;
        for (uint8 i = 0; i < quantity; i++) {
            _mintHeroNFT(gradeIndex, account, 0 + i);
        }
    }

    function spawnPetUsingEgg(address account, uint256 itemId, uint8 quantity) external {
        require(
            (account == _msgSender() || isGameMaster(_msgSender())),
            "Game: revert"
        );
        return _spawnPetUsingEgg(account, itemId, quantity, 0);
    }

    function _spawnPetUsingEgg(address account, uint256 itemId, uint8 quantity, uint256 seedOffset) private {
        (string memory itemType, string memory itemName) = gameItems.getItemInfo(itemId);
        string memory EGG = "EGG";
        require(CommonUtils.hashCompareWithLengthCheck(itemType, EGG), "Game: revert");
        gameItems.burn(account, itemId, quantity);
        // Common = 7;
        // Rare = 5;
        // Epic = 3;
        // Legendary = 2;
        // Mythical = 1;
        uint8 mint_count = 0;
        uint8 epic_count = 0;
        for (uint8 i = 0; i < quantity; i++) {
            // if rarityLevel=0 it will throw error when _mintPetNFT
            // 1st offset is line number in source code, 3st offset is loop index
            uint256 rng_result = generateRandomNumber(100000, seedOffset + 358, seedOffset + itemId, seedOffset + mint_count);
            uint8 rarityLevel = NFTPet.getSpawnPetChanceWhenOpenEgg(itemId, rng_result);
            if (rarityLevel == 3) epic_count += 1;
            if (itemId == 1 && rarityLevel > 3 && i + 1 >= 5 && epic_count == 0) {
                // guaranteed to get 1 Epic pet if open at least 5 rare egg
                epic_count += 1;
                rarityLevel = 3;
            }
            mint_count += 1;
            _mintPetNFT(rarityLevel, account, seedOffset + mint_count);
        }
    }

    function setClaimRewardCooldown(uint256 cooldownInSeconds) external onlyOwner {
        claimRewardCooldown = cooldownInSeconds;
    }

    function totalRewardClaimed() public view returns (uint256){
        return _totalRewardClaimed;
    }

    function currentRewardBudget(address gm) external view returns (uint256)  {
        require(
            (owner() == _msgSender() || gameMasterMap_address_tier[gm] >= 2),
            "Game: revert"
        );
        return _currentRewardBudget;
    }

    function increaseRewardBudget(uint256 amount) external onlyOwner {
        _currentRewardBudget += amount;
        require(_currentRewardBudget <= gameCoin.balanceOf(address(this)), "Game: revert");
    }

    function claimRewardCoin(address account, uint256 amount) external {
        require(isGameMaster(_msgSender()), "Game: revert");
        require(claimRewardHistoryMap_address_timestamp[account] + claimRewardCooldown <= block.timestamp, "Game: revert");
        // check for fraud
        require(heroNFT.balanceOf(account) > 0, "Game: revert");
        //require(petNFT.balanceOf(account) > 0, "Game: revert");
        // check budget
        require(amount < _currentRewardBudget, "Game: revert");
        // transfer reward coin to account
        gameCoin.transfer(account, amount);
        // deduct budget
        _currentRewardBudget -= amount;
        // track total claimed
        _totalRewardClaimed += amount;
        // set new claim reward timestamp for this account
        claimRewardHistoryMap_address_timestamp[account] = block.timestamp;
        // Emit events
        emit EventClaimRewardCoin(_msgSender(), account, amount, 0);
    }

    function getNextClaimRewardTimestamp(address account) public view returns (uint256){
        return claimRewardHistoryMap_address_timestamp[account] + claimRewardCooldown;
    }

    function getHeroNFTLevel(uint256 nft_tokenId) public view returns (uint){
        return heroNFTMap_tokenId_fusedHeroTokenId[nft_tokenId].length + 1;
    }

    function getHeroNFTMaxLevel() public view returns (uint8){
        return _heroNFTMaxLevel;
    }

    function setHeroNFTMaxLevel(uint8 maxLevel) external onlyOwner {
        _heroNFTMaxLevel = maxLevel;
    }

    function upgradeHeroLevel(address account, uint256 heroTokenId, uint256 fusingHeroTokenId, uint toLevel, uint256 gameCoinCostAmount, uint256[] calldata batchBurnItemTypeIds, uint256[] calldata batchBurnItemQty) external {
        require(isGameMaster(_msgSender()), "Game: revert");
        require(toLevel <= _heroNFTMaxLevel, "Game: revert");
        require(heroNFT.ownerOf(heroTokenId) == account && heroNFT.ownerOf(fusingHeroTokenId) == account, "Game: revert");
        // quick upgrade by fusing 2 NFT Hero with same level same class
        if (heroTokenId == fusingHeroTokenId) {
            // emit Event Normal Upgrade
            emit EventHeroUpgrade(_msgSender(), account, heroTokenId, fusingHeroTokenId, toLevel, 0);
        }
        else {
            // check hero class
            uint8 gradeIndex = heroNFTMap_tokenId_gradeIndex[heroTokenId];
            uint8 classIndex = heroNFTMap_tokenId_classIndex[heroTokenId];
            require(gradeIndex == heroNFTMap_tokenId_gradeIndex[fusingHeroTokenId], "Game: revert");
            require(classIndex == heroNFTMap_tokenId_classIndex[fusingHeroTokenId], "Game: revert");
            // check hero level
            require(getHeroNFTLevel(heroTokenId) == getHeroNFTLevel(fusingHeroTokenId), "Game: revert");
            // burn the 2nd hero
            heroNFT.burn(fusingHeroTokenId);
            // emit Event Quick Upgrade
            emit EventHeroUpgrade(_msgSender(), account, heroTokenId, fusingHeroTokenId, toLevel, 1);
        }
        if (gameCoinCostAmount > 0) {
            // transfer cost amount from account
            gameCoin.transferFrom(account, address(this), gameCoinCostAmount);
        }
        if (batchBurnItemTypeIds.length > 0) {
            // starting from Hero LV6 will require some extra game items to leveling up
            gameItems.burnBatch(account, batchBurnItemTypeIds, batchBurnItemQty);
        }
        // upgrade hero
        heroNFTMap_tokenId_fusedHeroTokenId[heroTokenId].push(fusingHeroTokenId);
        // make sure hero has reach the new level
        require(getHeroNFTLevel(heroTokenId) == toLevel, "Game: revert");
    }

    // In-Game shop

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    function setItemPriceInWei(uint256 itemTypeId, uint256 weiPrice) external onlyOwner {
        shoppingPriceMap_itemTypeId_weiPrice[itemTypeId] = weiPrice;
    }

    function getItemPriceInWei(uint256 itemTypeId) public view returns (uint256) {
        return shoppingPriceMap_itemTypeId_weiPrice[itemTypeId];
    }

    // on-chain purchase with ETH/BNB/MATIC
    function purchaseGameItem(uint256 itemTypeId, uint256 itemQty) external payable {
        uint256 priceInWei = shoppingPriceMap_itemTypeId_weiPrice[itemTypeId];
        // check price again a minimum price 10^15 in wei to prevent human error when set price
        // 0.001 BNB min price
        require(priceInWei >= 1000000000000000, "Item price is not set or its has been forbidden to purchase");
        require(msg.value == itemQty * priceInWei, "Send amount is not match the total cost in wei");
        gameItems.mint(_msgSender(), itemTypeId, itemQty, new bytes(0));
    }

    function withdrawGas() external onlyOwner {
        // price in wei need to be extract from item price table
        (bool success, bytes memory data) = address(owner()).call{value : address(this).balance}("");
        require(success, "Game: revert");
    }

    function mintGameItemsWithCost(address receiver, uint256[] calldata batchMintItemTypeIds, uint256[] calldata batchMintItemQty, uint256 gameCoinCost) external {
        require(isGameMaster(_msgSender()), "Game: revert");
        if (gameCoinCost > 0) {
            gameCoin.transferFrom(receiver, address(this), gameCoinCost);
        }
        gameItems.mintBatch(receiver, batchMintItemTypeIds, batchMintItemQty, new bytes(0));
    }

    function burnToMintGameItemsWithCost(address receiver, uint256[] calldata batchBurnItemTypeIds, uint256[] calldata batchBurnItemQty, uint256[] calldata batchMintItemTypeIds, uint256[] calldata batchMintItemQty, uint256 gameCoinCost) external {
        require(isGameMaster(_msgSender()), "Game: revert");
        if (gameCoinCost > 0) {
            gameCoin.transferFrom(receiver, address(this), gameCoinCost);
        }
        gameItems.burnBatch(receiver, batchBurnItemTypeIds, batchBurnItemQty);
        gameItems.mintBatch(receiver, batchMintItemTypeIds, batchMintItemQty, new bytes(0));
    }

    // Market Place
//    function setMarketPlaceTransactionFeePercent(uint256 feePercent) external onlyOwner {
//        require(feePercent < 100, "Game: revert");
//        _marketPlaceTransactionFeePercent = feePercent;
//    }
//
//    function getMarketPlaceTransactionFeePercent() public view returns (uint256) {
//        return _marketPlaceTransactionFeePercent;
//    }

    function _swapNFTforGameCoin(address sellerAccount, address buyerAccount, address nftERC721Contract, uint256 nftId, uint256 gameCoinAmount) private {
        require(gameCoinAmount > 0, "Game: revert");
        IERC721 nftContract = IERC721(nftERC721Contract);
        // confirm ownership of NFT
        require(nftContract.ownerOf(nftId) == sellerAccount, "Game: revert");
        // transfer entire gameCoin amount from buyer to game contract first (this is to avoid deflationary tax)
        gameCoin.transferFrom(buyerAccount, address(this), gameCoinAmount);
        // transfer NFT from seller to buyer
        nftContract.transferFrom(sellerAccount, buyerAccount, nftId);
    }

    function swapNFTforGameCoinBetweenAccountsInGame(address sellerAccount, address buyerAccount, address nftERC721Contract, uint256 nftId, uint256 gameCoinAmount) external {
        require(isGameMaster(_msgSender()), "Game: revert");
        _swapNFTforGameCoin(sellerAccount, buyerAccount, nftERC721Contract, nftId, gameCoinAmount);
        // seller will receive In-Game amount instead of On-Chain gameCoin, backend will decide fee
    }

//    function swapNFTforGameCoinBetweenAccounts(address sellerAccount, address buyerAccount, address nftERC721Contract, uint256 nftId, uint256 gameCoinAmount) external {
//        require(isGameMaster(_msgSender()), "Game: revert");
//        _swapNFTforGameCoin(sellerAccount, buyerAccount, nftERC721Contract, nftId, gameCoinAmount);
//        // cut transaction fee and send amount back to seller
//        uint256 final_amount = gameCoinAmount * (100 - _marketPlaceTransactionFeePercent) / 100;
//        require(final_amount <= gameCoinAmount, "Game: revert");
//        // transfer gameCoin amount after deduct fee to seller
//        gameCoin.transfer(sellerAccount, final_amount);
//    }

    function sellGameItemsForGameCoinBetweenAccountsInGame(address sellerAccount, address buyerAccount, uint256[] calldata batchSendItemTypeIds, uint256[] calldata batchSendItemQty, uint256 gameCoinAmount) external {
        require(isGameMaster(_msgSender()), "Game: revert");
        // send items to buyer
        gameItems.safeBatchTransferFrom(sellerAccount, buyerAccount, batchSendItemTypeIds, batchSendItemQty, new bytes(0));
        // seller will receive In-Game amount instead of On-Chain gameCoin, backend will decide fee
        // transfer entire gameCoin amount from buyer to game contract
        gameCoin.transferFrom(buyerAccount, address(this), gameCoinAmount);
    }

    // Chest opening
    function _openChestNoBurn(address account, uint256 chestItemId, uint256 quantity, bool drop_unlock, uint256 seedOffset) private {
        // https://en.wikipedia.org/wiki/Linear_congruential_generator#m_a_power_of_2,_c_=_0
        // choose m = 340282366920938463463374607431768211456 (2^128)
        // choose a = 47026247687942121848144207491837523525
        // chose c = a random odd number smaller than m
        uint256 c = generateRandomNumber(340282366920938463463374607431768211456, seedOffset + 651, seedOffset, seedOffset);
        if (c % 2 == 0) c++;
        // generate x0 < m, seed number will be used to generate a series of random number % 100000
        uint256 x0 = generateRandomNumber(340282366920938463463374607431768211456, seedOffset + 654, seedOffset + chestItemId, seedOffset + quantity);
        // set locks and roll rewards
        uint256[66] memory rewardItemQtyList;
        uint256 gameCoinReward;
        if (drop_unlock == true) {
            (rewardItemQtyList, gameCoinReward) = TreasureDropRate.getReward(chestItemId, quantity, x0, 340282366920938463463374607431768211456, 47026247687942121848144207491837523525, c, true, true, true);
        } else {
            if (quantity >= 100) (rewardItemQtyList, gameCoinReward) = TreasureDropRate.getReward(chestItemId, quantity, x0, 340282366920938463463374607431768211456, 47026247687942121848144207491837523525, c, true, true, true);
            else if (quantity >= 50) (rewardItemQtyList, gameCoinReward) = TreasureDropRate.getReward(chestItemId, quantity, x0, 340282366920938463463374607431768211456, 47026247687942121848144207491837523525, c, true, true, false);
            else if (quantity >= 20) (rewardItemQtyList, gameCoinReward) = TreasureDropRate.getReward(chestItemId, quantity, x0, 340282366920938463463374607431768211456, 47026247687942121848144207491837523525, c, true, false, false);
            else (rewardItemQtyList, gameCoinReward) = TreasureDropRate.getReward(chestItemId, quantity, x0, 340282366920938463463374607431768211456, 47026247687942121848144207491837523525, c, false, false, false);
        }
        // granting reward in GameItem
        uint256[] memory batchMintItemTypeIds = new uint256[](66);
        uint256[] memory batchMintItemQty = new uint256[](66);
        uint8 count_item = 0;
        for (uint8 item_id = 0; item_id < 66; item_id++) {
            if (rewardItemQtyList[item_id] == 0) continue;
            batchMintItemTypeIds[count_item] = item_id;
            batchMintItemQty[count_item++] = rewardItemQtyList[item_id];
        }
        gameItems.mintBatch(account, batchMintItemTypeIds, batchMintItemQty, new bytes(0));

        // granting reward in GameCoin token
        if (gameCoinReward > 0) {
            // check budget
            require(gameCoinReward < _currentRewardBudget, "Game: revert");
            // transfer reward coin to account
            gameCoin.transfer(account, gameCoinReward);
            // deduct budget
            _currentRewardBudget -= gameCoinReward;
            // track total claimed, cause this is consider the same as player claim from reward pool
            _totalRewardClaimed += gameCoinReward;
            // Emit events
            emit EventClaimRewardCoin(_msgSender(), account, gameCoinReward, 2);
        }
    }

    function openChestByGameMaster(address account, uint256 chestItemId, uint256 quantity, bool drop_unlock, uint256[] calldata batchBurnItemTypeIds, uint256[] calldata batchBurnItemQty) external {
        require(isGameMaster(_msgSender()), "Game: revert");
        if (batchBurnItemTypeIds.length > 0) {
            gameItems.burnBatch(account, batchBurnItemTypeIds, batchBurnItemQty);
        }
        _openChestNoBurn(account, chestItemId, quantity, drop_unlock, 681);
    }

    // NFT Equipments (Orb, Relic)
    function bindOrbToHero(uint256 orb_tokenId, uint256 hero_tokenId) external {
        require(isGameMaster(_msgSender()), "Game: revert");
        address orb_owner = orbNFT.ownerOf(orb_tokenId);
        if (orb_owner != address(this)) {
            require(orb_owner == heroNFT.ownerOf(hero_tokenId), "Game: revert");
            // set bound Hero
            _orbNFTBoundToTokenId[orb_tokenId] = hero_tokenId;
            // transfer orb NFT ownership to Game contract
            orbNFT.transferFrom(orb_owner, address(this), orb_tokenId);
        } else {
            // set bound Hero
            _orbNFTBoundToTokenId[orb_tokenId] = hero_tokenId;
            // technically this function should allow GM to reassign ownership of already bound Orb to any one
        }
    }

    function unbindOrbFromHero(uint256 orb_tokenId, uint256 ccItemQty) external {
        require(isGameMaster(_msgSender()), "Game: revert");
        address orb_owner = heroNFT.ownerOf(_orbNFTBoundToTokenId[orb_tokenId]);
        if (ccItemQty > 0) {
            // burn Chaos Charm is required
            gameItems.burn(orb_owner, 75, ccItemQty);
        }
        // unset bound Hero (this is not really necessary, can be skip to save gas fee)
        // _orbNFTBoundToTokenId[orb_tokenId] = 0;
        // transfer orb NFT ownership from Game contract to True owner
        orbNFT.transferFrom(address(this), orb_owner, orb_tokenId);
    }

    function getOrbBoundToTokenId(uint256 tokenId) public view returns (uint256) {
        require(orbNFT.ownerOf(tokenId) == address(this), "Game: revert");
        return _orbNFTBoundToTokenId[tokenId];
    }

    function _mintOrbNFT(uint8 rarityLevel, uint8 classIndex, uint256 attr_bonus_buff, address to, uint256 seedOffset) private returns (uint256){
        require(rarityLevel >= 1 && rarityLevel <= 7, "Game: revert");
        require(classIndex > 0, "Game: revert");
        require(attr_bonus_buff <= 6000, "Game: revert");
        uint256 nft_tokenId = orbNFT.mint(to);
        // set RarityLevel of OrbNFT with nft_tokenId
        orbNFTMap_tokenId_rarityLevel[nft_tokenId] = rarityLevel;
        // set ClassIndex of OrbNFT with nft_tokenId
        orbNFTMap_tokenId_classIndex[nft_tokenId] = classIndex;
        uint256 attr1;
        uint256 attr1_plus_random_range;
        (attr1, attr1_plus_random_range) = NFTWeaponOrb.getMagitekGasRandomRange(rarityLevel);
        if (attr1_plus_random_range > 0) {
            // 1st offset is line number in source code, 3rd offset is 1 due to only generate one
            attr1 += generateRandomNumber(attr1_plus_random_range, seedOffset + 681, seedOffset + nft_tokenId, seedOffset + 1);
        }
        // default value of mapping is 0, so keep in mind
        orbNFTMap_tokenId_attribute1[nft_tokenId] = attr1;
        // set attribute bonus buff
        orbNFTMap_tokenId_attribute2[nft_tokenId] = attr_bonus_buff;
        return nft_tokenId;
    }

    function mintOrbNFT(uint8 rarityLevel, uint8 classIndex, uint256 attr_bonus_buff, address to) external onlyOwner returns (uint256){
        return _mintOrbNFT(rarityLevel, classIndex, attr_bonus_buff, to, 0);
    }

    function getOrbNFTRarity(uint256 nft_tokenId) public view returns (uint8 rarityLevel, string memory rarity) {
        rarityLevel = orbNFTMap_tokenId_rarityLevel[nft_tokenId];
        require(rarityLevel > 0, "Game: revert");
        rarity = NFTPet.getRarity(rarityLevel);
    }

    function getOrbNFTClass(uint256 nft_tokenId) public view returns (uint8 classIndex, string memory class_id) {
        classIndex = orbNFTMap_tokenId_classIndex[nft_tokenId];
        require(classIndex > 0, "Game: revert");
        class_id = NFTWeaponOrb.genOrbClassIds()[classIndex - 1];
    }

    function getOrbTrueOwner(uint256 nft_tokenId) public view returns (bool isBound, uint256 boundTo, address owner) {
        // check if orb is bound
        owner = orbNFT.ownerOf(nft_tokenId);
        isBound = owner == address(this);
        // nft_id id of the Hero which the orb is bound to, can be ignore if isBound=False
        boundTo = _orbNFTBoundToTokenId[nft_tokenId];
        // calculate true owner when orb is bound
        if (isBound == true) {
            owner = heroNFT.ownerOf(boundTo);
        }
    }

    function getOrbNFTAttributes(uint256 nft_tokenId) public view returns (uint8 rarityLevel, uint8 classIndex, uint256 magitekGas, uint256 damageBonusBuff, bool isBound, uint256 boundTo, uint level, uint256[] memory upgradeHistory, address owner) {
        // rarity level of the orb 1 is highest
        rarityLevel = orbNFTMap_tokenId_rarityLevel[nft_tokenId];
        // class index of the orb
        classIndex = orbNFTMap_tokenId_classIndex[nft_tokenId];
        // magitek gas is attribute1
        magitekGas = orbNFTMap_tokenId_attribute1[nft_tokenId];
        // damage bonus buff is attribute2
        damageBonusBuff = orbNFTMap_tokenId_attribute2[nft_tokenId];
        // check orb is bound and true ownership
        (isBound, boundTo, owner) = getOrbTrueOwner(nft_tokenId);
        (level, upgradeHistory) = getOrbNFTLevel(nft_tokenId);
    }

    function getOrbNFTLevel(uint256 nft_tokenId) public view returns (uint level, uint256[] memory upgradeHistory){
        // the history of fusing gem into orb to upgrade it
        upgradeHistory = orbNFTMap_tokenId_fusedGemTokenTypeId[nft_tokenId];
        // Orb Level start at +0 (LV0)
        level = upgradeHistory.length;
    }

    function getOrbNFTMaxLevel() public view returns (uint8){
        return _orbNFTMaxLevel;
    }

    function setOrbNFTMaxLevel(uint8 maxLevel) external onlyOwner {
        _orbNFTMaxLevel = maxLevel;
    }

    function setMintCostInWei(uint8 rarityLevel, uint256 weiPrice) external onlyOwner {
        mintCostMap_rarityLevel_weiPrice[rarityLevel] = weiPrice;
    }

    function getMintCostInWei(uint8 rarityLevel) public view returns (uint256) {
        return mintCostMap_rarityLevel_weiPrice[rarityLevel];
    }

    // on-chain mint with ETH/BNB/MATIC
    function craftEquipmentWeaponOrb(uint8 rarityLevel, uint256 nft_petId1, uint256 nft_petId2) external payable {
        require(msg.value == mintCostMap_rarityLevel_weiPrice[rarityLevel], "Game: revert");
        require(rarityLevel == petNFTMap_tokenId_rarityLevel[nft_petId1], "Game: revert");
        uint256 sumAttrBuff = petNFTMap_tokenId_attribute1[nft_petId1] + petNFTMap_tokenId_attribute1[nft_petId2];
        uint256 successRate = NFTWeaponOrb.getCraftSuccessRate(rarityLevel, sumAttrBuff);
        require(successRate > 0, "Game: revert");
        require(_msgSender() == petNFT.ownerOf(nft_petId1) && _msgSender() == petNFT.ownerOf(nft_petId2), "Game: revert");
        NFTWeaponOrb.burnPetAndMaterialsForCraft(rarityLevel, nft_petId1, nft_petId2, _msgSender(), petNFT, gameItems);

        uint256 randomResult = generateRandomNumber(10000, nft_petId1, nft_petId2, rarityLevel + 779);
        // check for failed, if failed lower rarityLevel by one grade
        if (randomResult >= successRate) {
            if (rarityLevel == 3 || rarityLevel == 5) rarityLevel = rarityLevel + 2;
            else if (rarityLevel > 0 && rarityLevel < 3) rarityLevel = rarityLevel + 1;
        }
        // chose class
        uint8 orbClassIndex = 0;
        // Common orb have 4 neutral class index from 1 to 4
        if (rarityLevel == 7) orbClassIndex = 1 + uint8(randomResult % 4);
        // Rare/Epic/Legendary have 4 neutral class and 4 elemental class index from 1 to 8
        if (rarityLevel == 5 || rarityLevel == 3 || rarityLevel == 2) orbClassIndex = 1 + uint8(randomResult % 8);
        require(orbClassIndex > 0, "Game: revert");

        // use previous randomResult as seedOffset
        _mintOrbNFT(rarityLevel, orbClassIndex, sumAttrBuff, _msgSender(), randomResult);
    }

    function upgradeOrbLevel(address account, uint256 orb_tokenId, uint curLevel, uint256 fusedGemTokenTypeId, uint256 gameCoinCostAmount, uint256[] calldata batchBurnItemTypeIds, uint256[] calldata batchBurnItemQty) external {
        require(isGameMaster(_msgSender()), "Game: revert");
        uint256[] storage upgradeHistory = orbNFTMap_tokenId_fusedGemTokenTypeId[orb_tokenId];
        require(upgradeHistory.length == curLevel, "Game: revert");
        require(curLevel < _orbNFTMaxLevel, "Game: revert");
        require(batchBurnItemTypeIds[0] == fusedGemTokenTypeId, "Game: revert");

        if (gameCoinCostAmount > 0) {
            // transfer cost amount from account
            gameCoin.transferFrom(account, address(this), gameCoinCostAmount);
        }
        if (batchBurnItemTypeIds.length > 0) {
            // starting from Hero LV6 will require some extra game items to leveling up
            gameItems.burnBatch(account, batchBurnItemTypeIds, batchBurnItemQty);
        }
        uint category;
        // if randomResult < successRate
        if (generateRandomNumber(100000, orb_tokenId, fusedGemTokenTypeId, curLevel + 752) < NFTWeaponOrb.getUpgradeSuccessRate(curLevel, fusedGemTokenTypeId, batchBurnItemQty[0])) {
            // success upgrade orb
            upgradeHistory.push(fusedGemTokenTypeId);
            category = 1;
        } else {
            category = 0;
            if (curLevel >= 9) {
                uint256 ccBalance = gameItems.balanceOf(account, 75);
                if (ccBalance == 0) {
                    category = 2;
                    orbNFT.burn(orb_tokenId);
                } else {
                    category = 3;
                    // burnItem when upgrade to +10 if don't have Chaos Charm (75), and minus 1LV if have enough, minus more if dont have enough
                    uint256 expectedBurnQty = curLevel - 8;
                    if (expectedBurnQty > ccBalance) {
                        // burn Chaos Charm
                        gameItems.burn(account, 75, ccBalance);
                        // minus more level based on the delta of Chaos Charm balance and expectedBurnQty
                        for (uint i = 0; i <= expectedBurnQty - ccBalance; i++) upgradeHistory.pop();
                    } else {
                        // burn Chaos Charm
                        gameItems.burn(account, 75, expectedBurnQty);
                        upgradeHistory.pop();
                    }
                }
            } else if (curLevel > 0) {
                delete orbNFTMap_tokenId_fusedGemTokenTypeId[orb_tokenId];
            }
        }
        //category 1 is success
        emit EventOrbUpgrade(_msgSender(), account, orb_tokenId, fusedGemTokenTypeId, curLevel, upgradeHistory.length, category);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.3.2 (token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol)

pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @dev {ERC721} token, including:
 *
 *  - ability for holders to burn (destroy) their tokens
 *  - a minter role that allows for token minting (creation)
 *  - a pauser role that allows to stop all token transfers
 *  - token ID and URI autogeneration
 *
 * This contract uses {AccessControl} to lock permissioned functions using the
 * different roles - head to its documentation for details.
 *
 * The account that deploys the contract will be granted the minter and pauser
 * roles, as well as the default admin role, which will let it grant both minter
 * and pauser roles to other accounts.
 */
contract NFT is
    Context,
    AccessControlEnumerable,
    ERC721Enumerable,
    ERC721Burnable,
    ERC721Pausable
{
    using Counters for Counters.Counter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    Counters.Counter private _tokenIdTracker;

    string private _baseTokenURI;

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE` and `PAUSER_ROLE` to the
     * account that deploys the contract.
     *
     * Token URIs will be autogenerated based on `baseURI` and their token IDs.
     * See {ERC721-tokenURI}.
     */
    constructor(
        string memory name,
        string memory symbol,
        string memory baseTokenURI
    ) ERC721(name, symbol) {
        _baseTokenURI = baseTokenURI;

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    /**
     * @dev Creates a new token for `to`. Its token ID will be automatically
     * assigned (and available on the emitted {IERC721-Transfer} event), and the token
     * URI autogenerated based on the base URI passed at construction.
     *
     * See {ERC721-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(address to) public virtual returns(uint256){
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have minter role to mint");

        // We cannot just use balanceOf to create the new tokenId because tokens
        // can be burned (destroyed), so we need a separate counter.
        uint256 token_id = _tokenIdTracker.current();
        _mint(to, token_id);
        _tokenIdTracker.increment();
        return token_id;
    }

    /**
     * @dev Pauses all token transfers.
     *
     * See {ERC721Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have pauser role to pause");
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC721Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have pauser role to unpause");
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlEnumerable, ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

// SPDX-License-Identifier: UNLICENSED
// PLay Poseidon Game Contracts Libraries

pragma solidity ^0.8.0;

import "./NFT.sol";
import "./GameItem.sol";

library CommonUtils {
    function hashCompareWithLengthCheck(string memory a, string memory b) public pure returns (bool) {
        if (bytes(a).length != bytes(b).length) {
            return false;
        } else {
            return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
        }
    }
}

//library CraftGameItems {
//    function burnNFTtoMintGameItemsWithCost( GameV2b game, address _msgSender, address receiver, NFT nft_contract, uint256 nft_tokenId, GameItems gameItems, uint256[] calldata batchMintItemTypeIds, uint256[] calldata batchMintItemQty, GameCoin gameCoin, uint256 gameCoinCost) public {
////        require(game.isGameMaster(_msgSender), "Game: revert");
//        if (gameCoinCost > 0) {
//            gameCoin.transferFrom(receiver, address(game), gameCoinCost);
//        }
//        nft_contract.burn(nft_tokenId);
//        gameItems.mintBatch(receiver, batchMintItemTypeIds, batchMintItemQty, new bytes(0));
//    }
//}


library NFTHero {
    function getGrade(uint8 gradeIndex) public pure returns (string memory grade){
        if (gradeIndex == 1) {
            grade = "S";
        } else if (gradeIndex == 2) {
            grade = "A";
        } else if (gradeIndex == 3) {
            grade = "B";
        } else if (gradeIndex == 4) {
            grade = "C";
        } else if (gradeIndex == 5) {
            grade = "D";
        } else if (gradeIndex == 6) {
            grade = "E";
        } else if (gradeIndex == 7) {
            grade = "F";
        } else {
            grade = "?";
        }
    }

    function genHeroClassIds() public pure returns (string[3][7] memory){
        return [['S1', 'S2', 'S3'], ['A1', 'A2', 'A3'], ['B1', 'B2', 'B3'], ['C1', 'C2', 'C3'], ['D1', 'D2', 'D3'], ['E1', 'E2', 'E3'], ['F1', 'F2', 'F3']];
    }

    function getZodiacSign(uint8 zodiacIndex) public pure returns (string memory) {
        require(zodiacIndex <= 12, "Game: zodiacIndex must be <= 12");
        //  "♈︎","♉︎","♊","♋︎","♌︎","♍︎","♎︎","♏︎","♐︎","♑︎","♒︎","♓︎"
        string[13] memory zodiac_signs = ["", unicode"Aries ♈︎", unicode"Taurus ♉︎", unicode"Gemini ♊", unicode"Cancer ♋︎", unicode"Leo ♌︎", unicode"Virgo ♍︎", unicode"Libra ♎︎", unicode"Scorpio ♏︎", unicode"Sagittarius ♐︎", unicode"Capricorn ♑︎", unicode"Aquarius ♒︎", unicode"Pisces ♓︎"];
        return zodiac_signs[zodiacIndex];
    }

    function _getCombination(uint8 r, uint256 combinationIndex) private pure returns (uint8 i1, uint8 i2, uint8 i3, uint8 i4){
        require(r <= 4);
        uint256 count = 1;
        uint8 n = 12;
        for (i1 = 1; i1 <= n; i1++) {
            if (r >= 2)
                for (i2 = i1; i2 <= n; i2++) {
                    if (r >= 3)
                        for (i3 = i2; i3 <= n; i3++) {
                            if (r >= 4)
                                for (i4 = i3; i4 <= n; i4++) {
                                    if (count++ == combinationIndex) return (i1, i2, i3, i4);
                                }
                            else if (count++ == combinationIndex) return (i1, i2, i3, i4);
                        }
                    else if (count++ == combinationIndex) return (i1, i2, i3, i4);
                }
            else if (count++ == combinationIndex) return (i1, i2, i3, i4);
        }
    }

    function getZodiacSignSet2Combination(uint256 combinationIndex) public pure returns (string memory z1, string memory z2) {
        require(combinationIndex <= 78, "Game: combinationIndex for zodiac set of 2 must be <= 78");
        (uint8 i1,uint8 i2,uint8 i3,uint8 i4) = _getCombination(2, combinationIndex);
        z1 = getZodiacSign(i1);
        z2 = getZodiacSign(i2);
    }

    function getZodiacSignSet3Combination(uint256 combinationIndex) public pure returns (string memory z1, string memory z2, string memory z3) {
        require(combinationIndex <= 364, "Game: combinationIndex for zodiac set of 3 must be <= 364");
        (uint8 i1,uint8 i2,uint8 i3,uint8 i4) = _getCombination(3, combinationIndex);
        z1 = getZodiacSign(i1);
        z2 = getZodiacSign(i2);
        z3 = getZodiacSign(i3);
    }

    function getZodiacSignSet4Combination(uint256 combinationIndex) public pure returns (string memory z1, string memory z2, string memory z3, string memory z4) {
        require(combinationIndex <= 1365, "Game: combinationIndex for zodiac set of 4 must be <= 1365");
        //        uint8[4][1366] memory all_combinations = _genCombination(4);
        (uint8 i1,uint8 i2,uint8 i3,uint8 i4) = _getCombination(4, combinationIndex);
        z1 = getZodiacSign(i1);
        z2 = getZodiacSign(i2);
        z3 = getZodiacSign(i3);
        z4 = getZodiacSign(i4);
    }
}

library NFTPet {
    function getRarity(uint8 rarityLevel) public pure returns (string memory rarity){
        if (rarityLevel == 1) rarity = "Mythical";
        else if (rarityLevel == 2) rarity = "Legendary";
        else if (rarityLevel == 3) rarity = "Epic";
        else if (rarityLevel == 4) rarity = "VeryRare";
        else if (rarityLevel == 5) rarity = "Rare";
        else if (rarityLevel == 6) rarity = "Uncommon";
        else if (rarityLevel == 7) rarity = "Common";
        else rarity = "?";
    }

    function genPetClassIds() public pure returns (string[9][7] memory){
        return [['My_1', 'My_2', 'My_3', 'My_4', 'My_5', 'My_6', 'My_7', 'My_8', 'My_9'], ['Le_1', 'Le_2', 'Le_3', 'Le_4', 'Le_5', 'Le_6', 'Le_7', 'Le_8', 'Le_9'], ['Ep_1', 'Ep_2', 'Ep_3', 'Ep_4', 'Ep_5', 'Ep_6', 'Ep_7', 'Ep_8', 'Ep_9'], ['VR_1', 'VR_2', 'VR_3', 'VR_4', 'VR_5', 'VR_6', 'VR_7', 'VR_8', 'VR_9'], ['Ra_1', 'Ra_2', 'Ra_3', 'Ra_4', 'Ra_5', 'Ra_6', 'Ra_7', 'Ra_8', 'Ra_9'], ['Un_1', 'Un_2', 'Un_3', 'Un_4', 'Un_5', 'Un_6', 'Un_7', 'Un_8', 'Un_9'], ['Co_1', 'Co_2', 'Co_3', 'Co_4', 'Co_5', 'Co_6', 'Co_7', 'Co_8', 'Co_9']];
    }

    function getSpawnPetChanceWhenOpenEgg(uint256 itemId, uint256 rng_result) public pure returns (uint8){
        if (itemId == 0) {// itemName="Common Egg"
            // Legendary 0.2% 200
            if (rng_result < 200) return 2;
            // Epic 3.8% 200+3800
            else if (rng_result < 4000) return 3;
            // Rare 44% 200+3800+44000
            else if (rng_result < 48000) return 5;
            // Common 52%
            else return 7;
        } else if (itemId == 1) {// itemName="Rare Egg"  // price must be greater than 10x of Common Egg
            // Mythical 0.12% 120
            if (rng_result < 120) return 1;
            // Legendary 1.8% 120+1800
            if (rng_result < 1920) return 2;
            // Epic 20% 120+1800+20000
            else if (rng_result < 21920) return 3;
            // Rare 78.08%
            else return 5;
        } else if (itemId == 2) {// itemName="Legendary Egg"  // not for sell, only dropped, auctioned
            // Mythical 4.4% 4400
            if (rng_result < 4400) return 1;
            // Legendary 66% 4400+66000
            else if (rng_result < 70400) return 2;
            // Epic 29.6%
            else return 3;
        } else {
            // unknown
            return 0;
        }
    }

    function getAttrRandomRange(uint8 rarityLevel) public pure returns (uint256 attr1_plus_random_range, uint256 attr1){
        if (rarityLevel == 1) {// "Mythical"
            attr1 = 2500;
            attr1_plus_random_range = 500 + 1;
            //allow attr1 can be from 2500-3000
        }
        else if (rarityLevel == 2) {// "Legendary";
            attr1 = 2000;
            attr1_plus_random_range = 500;
            //allow attr1 can be from 2000-2499
        }
        else if (rarityLevel == 3) {// "Epic";
            attr1 = 1000;
            attr1_plus_random_range = 1000;
            //allow attr1 can be from 1000-1999
        }
        else if (rarityLevel == 4) {// "VeryRare";
            attr1 = 500;
            attr1_plus_random_range = 500;
            //allow attr1 can be from 500-999
        }
        else if (rarityLevel == 5) {// "Rare";
            attr1 = 0;
            attr1_plus_random_range = 1000;
            //allow attr1 can be from 0-999
        }
        else if (rarityLevel == 6) {// "Uncommon";
            attr1 = 0;
            attr1_plus_random_range = 500;
            //allow attr1 can be from 0-499
        } else {
            attr1 = 0;
            attr1_plus_random_range = 0;
        }
        //"Common" or unknown rarity dont get bonus buff
    }

}

library TreasureDropRate {
    function getReward(uint256 chestItemId, uint256 quantity, uint256 x0, uint256 m, uint256 a, uint256 c, bool q20_unlock, bool q50_unlock, bool q100_unlock) public pure returns (uint256[66] memory rewardItemQtyList, uint256 gameCoinReward) {
        // Common Treasure = 10;
        // Rare Treasure = 11;
        // Epic Treasure = 12;
        // Legendary Treasure = 13;
        gameCoinReward = 0;
        uint256 x;
        uint256 miss_count;
        if (chestItemId == 13) {
            // open legendary chest
            for (uint256 i = 0; i < quantity; i++) {
                // get next random number for EGG
                x0 = (a * x0 + c) % m;
                x = x0 % 100000;
                // Legendary Egg 0.2%
                if (x < 200) rewardItemQtyList[2] += 2;
                // Rare Egg 26%
                else if (x < 26200) rewardItemQtyList[1] += 2;

                // get next random number for UPGRADE_SCROLL
                x0 = (a * x0 + c) % m;
                x = x0 % 100000;
                // Upgrade Scroll LV12 1.28%
                if (x < 1280) rewardItemQtyList[22] += 4;
                // Upgrade Scroll LV11 2.56%
                else if (x < 3840) rewardItemQtyList[21] += 4;
                // Upgrade Scroll LV10 5.12%
                else if (x < 8960) rewardItemQtyList[20] += 4;
                // Upgrade Scroll LV9 10.24%
                else if (x < 19200) rewardItemQtyList[19] += 4;
                // Upgrade Scroll LV8 20.48%
                else if (x < 39680) rewardItemQtyList[18] += 4;
                // Upgrade Scroll LV7 40.96%
                else if (x < 80640) rewardItemQtyList[17] += 4;

                // get next random number for GEM
                x0 = (a * x0 + c) % m;
                x = x0 % 100000;
                // Greater Diamond 19%
                if (x < 19000) rewardItemQtyList[33] += 4;
                // Greater Ruby 19%
                else if (x < 38000) rewardItemQtyList[32] += 4;
                // Greater Sapphire 21%
                else if (x < 59000) rewardItemQtyList[31] += 4;
                // Greater Emerald 21%
                else if (x < 80000) rewardItemQtyList[30] += 4;
                // Guarantee 16 Lesser GEM of 1 type Random
                x0 = (a * x0 + c) % m;
                x = x0 % 100000;
                if (x < 25000) rewardItemQtyList[29] += 16;
                else if (x < 50000) rewardItemQtyList[28] += 16;
                else if (x < 75000) rewardItemQtyList[27] += 16;
                else rewardItemQtyList[26] += 16;

                // get next random number for ORB_MATERIAL
                x0 = (a * x0 + c) % m;
                x = x0 % 100000;
                // Legendary Orb Material 0.5%
                if (x < 500) rewardItemQtyList[37] += 2;
                // Epic Orb Material 5%
                else if (x < 5500) rewardItemQtyList[36] += 4;
                // Guarantee 8 Rare Orb Material and 16 Common Orb Material
                rewardItemQtyList[35] += 8;
                rewardItemQtyList[34] += 16;

                // get next random number for BOOK
                x0 = (a * x0 + c) % m;
                x = x0 % 100000;
                // Book of Wind 9%
                if (x < 9000) rewardItemQtyList[44] += 2;
                // Book of Fire 9%
                else if (x < 18000) rewardItemQtyList[43] += 2;
                // Book of Ice 10%
                else if (x < 28000) rewardItemQtyList[42] += 2;
                // Book of Earth 10%
                else if (x < 38000) rewardItemQtyList[41] += 2;
                // Book of Protection 4%
                else if (x < 42000) rewardItemQtyList[40] += 2;
                // Book of Ultimatum 20%
                else if (x < 62000) rewardItemQtyList[39] += 2;

                // get next random number for ELIXIR
                x0 = (a * x0 + c) % m;
                x = x0 % 100000;
                // Super Elixir of Deep Sea 0.08% 80
                if (x < 80) rewardItemQtyList[65] += 1;
                // Greater Elixir of Deep Sea 0.2% 80+200
                else if (x < 280) rewardItemQtyList[64] += 3;
                // Light Elixir of Deep Sea 2% 80+200+2000
                else if (x < 2280) rewardItemQtyList[63] += 3;
                // Minor Elixir of Deep Sea 8% 80+200+2000+8000
                else if (x < 10280) rewardItemQtyList[62] += 3;
            }
        } else {
            // loop open Common/Rare/Epic chest
            for (uint256 i = 0; i < quantity; i++) {
                uint256 miss_count = 0;

                // get next random number for EGG
                x0 = (a * x0 + c) % m;
                x = x0 % 100000;
                // Legendary Egg 0.02% 20
                if (x < 20 && q100_unlock) rewardItemQtyList[2]++;
                // Common Egg 2.6% 20+2600
                else if (x < 2620) rewardItemQtyList[0]++;
                else miss_count++;

                // get next random number for UPGRADE_SCROLL
                x0 = (a * x0 + c) % m;
                x = x0 % 100000;
                // Upgrade Scroll LV12 0.128% 128
                if (x < 128 && q50_unlock) rewardItemQtyList[22]++;
                // Upgrade Scroll LV11 0.256% 128+256
                else if (x < 384 && q50_unlock) rewardItemQtyList[21]++;
                // Upgrade Scroll LV10 0.512% 128+256+512
                else if (x < 896 && q20_unlock) rewardItemQtyList[20]++;
                // Upgrade Scroll LV9 1.024% 128+256+512+1024
                else if (x < 1920 && q20_unlock) rewardItemQtyList[19]++;
                // Upgrade Scroll LV8 2.048% 128+256+512+1024+2048
                else if (x < 3968) rewardItemQtyList[18]++;
                // Upgrade Scroll LV7 4.096% 128+256+512+1024+2048+4096
                else if (x < 8064) rewardItemQtyList[17]++;
                else miss_count++;

                // get next random number for GEM
                x0 = (a * x0 + c) % m;
                x = x0 % 100000;
                // Greater Diamond 1.9% 1900
                if (x < 1900) rewardItemQtyList[33]++;
                // Greater Ruby 1.9% 1900+1900
                else if (x < 3800) rewardItemQtyList[32]++;
                // Greater Sapphire 2.1% 1900+1900+2100
                else if (x < 5900) rewardItemQtyList[31]++;
                // Greater Emerald 2.1% 1900+1900+2100+2100
                else if (x < 8000) rewardItemQtyList[30]++;
                // Lesser Diamond 15.5% 1900+1900+2100+2100+15500
                else if (x < 23500) rewardItemQtyList[29]++;
                // Lesser Ruby 15.5% 1900+1900+2100+2100+15500+15500
                else if (x < 39000) rewardItemQtyList[28]++;
                // Lesser Sapphire 16.5% 1900+1900+2100+2100+15500+15500+16500
                else if (x < 55500) rewardItemQtyList[27]++;
                // Lesser Emerald 16.5% 1900+1900+2100+2100+15500+15500+16500+16500
                else if (x < 72000) rewardItemQtyList[26]++;
                else miss_count++;

                // get next random number for ORB_MATERIAL
                x0 = (a * x0 + c) % m;
                x = x0 % 100000;
                // Legendary Orb Material 0.05% 50
                if (x < 50 && q100_unlock) rewardItemQtyList[37]++;
                // Epic Orb Material 0.5% 50+500
                else if (x < 550 && q20_unlock) rewardItemQtyList[36]++;
                // Rare Orb Material 4% 50+500+4000
                else if (x < 4550) rewardItemQtyList[35]++;
                // Common Orb Material 36% 50+500+4000+36000
                else if (x < 40550) rewardItemQtyList[34]++;
                else miss_count++;

                // get next random number for BOOK
                x0 = (a * x0 + c) % m;
                x = x0 % 100000;
                // Book of Wind 0.9% 900
                if (x < 900 && q20_unlock) rewardItemQtyList[44]++;
                // Book of Fire 0.9% 900+900
                else if (x < 1800 && q20_unlock) rewardItemQtyList[43]++;
                // Book of Ice 1% 900+900+1000
                else if (x < 2800 && q20_unlock) rewardItemQtyList[42]++;
                // Book of Earth 1% 900+900+1000+1000
                else if (x < 3800 && q20_unlock) rewardItemQtyList[41]++;
                // Book of Protection 0.4% 900+900+1000+1000+400
                else if (x < 4200 && q50_unlock) rewardItemQtyList[40]++;
                // Book of Ultimatum 2% 900+900+1000+1000+400+2000
                else if (x < 6200) rewardItemQtyList[39]++;
                else miss_count++;

                // get next random number for hidden TREASURE
                if (chestItemId == 10 || chestItemId == 11) {
                    x0 = (a * x0 + c) % m;
                    x = x0 % 100000;
                    // Legendary TREASURE 1% 1000
                    if (x < 1000) rewardItemQtyList[13]++;
                    // Epic TREASURE 4% 1000+4000
                    else if (x < 5000) rewardItemQtyList[12]++;
                    else miss_count++;
                } else {
                    // if Epic Treasure and all missed then player will get a big reward of 1200 PPP instead
                    if (chestItemId == 12 && miss_count == 5) gameCoinReward += 1200000000000000000000;
                }
            }
        }
    }
}

library NFTWeaponOrb {

    function genOrbClassIds() public pure returns (string[8] memory){
        return ['Ne_Repeat', 'Ne_Split', 'Ne_Rapid', 'Ne_Charge', 'Em_Earth', 'Em_Ice', 'Em_Fire', 'Em_Wind'];
    }

    function getMagitekGasRandomRange(uint8 rarityLevel) public pure returns (uint256 start, uint256 random_range){
        // gen random attributes based on rarity
        if (rarityLevel == 1) {// "Mythical"
            start = 8000;
            random_range = 2000;
            //allow start can be from 8000-9999
        }
        else if (rarityLevel == 2) {// "Legendary";
            start = 6000;
            random_range = 2000;
            //allow start can be from 6000-7999
        }
        else if (rarityLevel == 3) {// "Epic";
            start = 4000;
            random_range = 2000;
            //allow start can be from 4000-5999
        }
        else if (rarityLevel == 4) {// "VeryRare";
            start = 2500;
            random_range = 1500;
            //allow start can be from 2500-3999
        }
        else if (rarityLevel == 5) {// "Rare";
            start = 1500;
            random_range = 2500;
            //allow start can be from 1500-3999
        }
        else if (rarityLevel == 6) {// "Uncommon";
            start = 1500;
            random_range = 1500;
            //allow start can be from 1500-2999
        } else {
            //"Common" or unknown rarity get a fixed attr1 at 1500
            random_range = 0;
            start = 1500;
        }
    }

    function getCraftSuccessRate(uint8 rarityLevel, uint256 sumAttrBuff) public pure returns (uint256 successRate){
        if (rarityLevel == 1) {
            // Mythical, min 35%, at 45% = always success
            if (sumAttrBuff >= 4500) successRate = 10000;
            else if (sumAttrBuff >= 4000) successRate = 5000;
            else if (sumAttrBuff >= 3500) successRate = 2500;
        } else if (rarityLevel == 2) {
            // Legendary, min 25%, at 35% = always success
            if (sumAttrBuff >= 3500) successRate = 10000;
            else if (sumAttrBuff >= 3000) successRate = 5000;
            else if (sumAttrBuff >= 2500) successRate = 2500;
        } else if (rarityLevel == 3) {
            // Epic, min 15%, at 25% = always success
            if (sumAttrBuff >= 2500) successRate = 10000;
            else if (sumAttrBuff >= 2000) successRate = 5000;
            else if (sumAttrBuff >= 1500) successRate = 2500;
        } else if (rarityLevel == 5) {
            // Rare, min 5%, at 15% = always success
            if (sumAttrBuff >= 1500) successRate = 10000;
            else if (sumAttrBuff >= 1000) successRate = 5000;
            else if (sumAttrBuff >= 500) successRate = 2500;
        } else if (rarityLevel == 7) {
            // Common, will not failed but only allow to craft <10% Dmg buff
            if (sumAttrBuff >= 1000) successRate = 0;
            else successRate = 10000;
        } else {
            successRate = 0;
        }
    }

    function burnPetAndMaterialsForCraft(uint8 rarityLevel, uint256 nft_petId1, uint256 nft_petId2, address account, NFT petNFT, GameItems gameItems) public {
        // burn 2 Pets
        petNFT.burn(nft_petId1);
        petNFT.burn(nft_petId2);
        // burn ORB_MATERIAL according to expected rarityLevel not by outcome rarityLevel
        if (rarityLevel == 1) gameItems.burn(account, 38, 2);
        else if (rarityLevel == 2) gameItems.burn(account, 37, 4);
        else if (rarityLevel == 3) gameItems.burn(account, 36, 8);
        else if (rarityLevel == 4) gameItems.burn(account, 35, 32);
        else if (rarityLevel == 5) gameItems.burn(account, 35, 16);
        else if (rarityLevel == 6) gameItems.burn(account, 34, 48);
        else if (rarityLevel == 7) gameItems.burn(account, 34, 24);
    }

    function getUpgradeSuccessRate(uint curLevel, uint256 fusedGemTokenTypeId, uint256 quantity) public pure returns (uint256){
        // base = 0.375%, LV8 1L=base=375, LV12 1G=base=375, LV17 1C=base=375
        uint256 capRate;
        if (curLevel <= 6) capRate = 96000;
        else if (curLevel <= 9) capRate = 96000 - 12000 * (curLevel - 6);
        else if (curLevel <= 14) capRate = 60000 - 6000 * (curLevel - 9);
        else if (curLevel <= 18) capRate = 30000 - 3000 * (curLevel - 14);
        else capRate = 18000;

        uint256 rate;
        if (fusedGemTokenTypeId >= 26 && fusedGemTokenTypeId <= 29) {
            // lesser gem L
            if (curLevel > 5) return 0;
            rate = 375 * 2 ** (5 - curLevel) * quantity;
        } else if (fusedGemTokenTypeId >= 30 && fusedGemTokenTypeId <= 33) {
            // greater gem G
            if (curLevel < 5) return 0;
            if (curLevel > 10) return 0;
            rate = 375 * 2 ** (10 - curLevel) * quantity;
        } else if (fusedGemTokenTypeId == 74) {
            if (curLevel < 10) return 0;
            if (curLevel <= 15) rate = 375 * 2 ** (15 - curLevel) * quantity;
            else rate = 375 - (curLevel - 15) * 25;
            // this allow up to LV+30
        } else {
            // unknown gem
            return 0;
        }
        if (rate < capRate) return rate;
        else return capRate;
    }

}

// SPDX-License-Identifier: UNLICENSED
// PLay Poseidon GameItem Contracts v1.0

pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC1155/presets/ERC1155PresetMinterPauser.sol";

contract GameItems is ERC1155PresetMinterPauser {

    constructor(string memory baseTokenURI) ERC1155PresetMinterPauser(baseTokenURI){}

    mapping(uint256 => string) private map_itemId_itemType;
    mapping(uint256 => string) private map_itemId_itemName;


    function setItemInfo(uint256 itemId, string calldata itemType, string calldata itemName) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "GameItems: must have admin role to setItemInfo");
        map_itemId_itemType[itemId] = itemType;
        map_itemId_itemName[itemId] = itemName;
    }

    function getItemInfo(uint256 itemId) public view returns (string memory itemType, string memory itemName) {
        itemType = map_itemId_itemType[itemId];
        itemName = map_itemId_itemName[itemId];
        // emtpy string "" will be returned for undefined Item
        // if dont want this behavior uncomment below
        require(bytes(itemType).length > 0 && bytes(itemName).length > 0, "GameItem: itemId doesnt exist");
    }
}

// SPDX-License-Identifier: UNLICENSED
// PLay Poseidon GameCoin Contracts v1.0

pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

interface IERC20Deflationary is IERC20 {

    /**
     * @dev return how many percent of transaction amount is going to be taxed when token holder
      is executing a transfer. Address that in the whitelist is excluded from this fee
     */
    function transferFeePercent() external view returns (uint256);

    /**
     * @dev add an address to tax whitelist
     */
    function addAddressToWhitelist(address whitelistAddress) external;

    /**
     * @dev remove an address from tax whitelist
     */
    function removeAddressFromWhitelist(address whitelistAddress) external;

}

abstract contract BotPrevent {

    function protect(address sender, address receiver, uint256 amount) public virtual;

}

contract GameCoin is AccessControlEnumerable, ERC20Burnable, ERC20Pausable {
    bytes32 public constant WHITELISTER_ROLE = keccak256("WHITELISTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    event EventWhiteList(address indexed target, bool state);

    constructor(string memory name,
        string memory symbol,
        uint256 initialSupply,
        address owner,
        address treasury,
        uint256 treasuryPercent,
        uint256 burnPercent,
        uint256 stopBurnSupply) ERC20(name, symbol){
        require(owner != address(0), "GameCoin: owner address must not be zero");
        require(treasury != address(0), "GameCoin: treasury address must not be zero");
        _mint(owner, initialSupply);
        treasuryAddress = treasury;

        require(treasuryPercent < 10, "GameCoin: transferFeeTreasuryPercent must be lower than 10%");
        transferFeeTreasuryPercent = treasuryPercent;
        require(burnPercent < 10, "GameCoin: transferFeeBurnPercent must be lower than 10%");
        transferFeeBurnPercent = burnPercent;
        require(stopBurnSupply < initialSupply, "GameCoin: stopBurnSupply must be lower than total supply");
        transferStopBurnWhenLowSupply = stopBurnSupply;

        _setupRole(DEFAULT_ADMIN_ROLE, owner);
        _setupRole(WHITELISTER_ROLE, owner);
        _setupRole(PAUSER_ROLE, owner);
    }

    mapping(address => bool) private _senderWhitelist;
    mapping(address => bool) private _recipientWhitelist;
    address public immutable treasuryAddress;
    uint256 public immutable transferFeeTreasuryPercent;
    uint256 public immutable transferFeeBurnPercent;
    uint256 public immutable transferStopBurnWhenLowSupply;

    BotPrevent public BP;
    bool public bpEnabled = false;
    bool public BPDisabledForever = false;

    function transferFeePercent() external view returns (uint256){
        return transferFeeTreasuryPercent + transferFeeBurnPercent;
    }

    function addAddressToWhitelist(address whitelistAddress) external {
        require(whitelistAddress != address(0), "GameCoin: address must not be zero");
        require(hasRole(WHITELISTER_ROLE, _msgSender()), "GameCoin: must have whitelister role");
        _senderWhitelist[whitelistAddress] = true;
        _recipientWhitelist[whitelistAddress] = true;
        emit EventWhiteList(whitelistAddress, true);
    }

    function removeAddressFromWhitelist(address whitelistAddress) external {
        require(whitelistAddress != address(0), "GameCoin: address must not be zero");
        require(hasRole(WHITELISTER_ROLE, _msgSender()), "GameCoin: must have whitelister role");
        _senderWhitelist[whitelistAddress] = false;
        _recipientWhitelist[whitelistAddress] = false;
        emit EventWhiteList(whitelistAddress, false);
    }

    function addAddressToSenderWhitelist(address whitelistAddress) external {
        require(whitelistAddress != address(0), "GameCoin: address must not be zero");
        require(hasRole(WHITELISTER_ROLE, _msgSender()), "GameCoin: must have whitelister role");
        _senderWhitelist[whitelistAddress] = true;
        emit EventWhiteList(whitelistAddress, true);
    }

    function addAddressToRecipientWhitelist(address whitelistAddress) external {
        require(whitelistAddress != address(0), "GameCoin: address must not be zero");
        require(hasRole(WHITELISTER_ROLE, _msgSender()), "GameCoin: must have whitelister role");
        _recipientWhitelist[whitelistAddress] = true;
        emit EventWhiteList(whitelistAddress, true);
    }

    function setBPAddress(address _bp) external {
        require(hasRole(PAUSER_ROLE, _msgSender()), "GameCoin: must have pauser role");
        require(address(BP) == address(0), "Can only be initialized once");
        BP = BotPrevent(_bp);
    }

    function setBPEnabled(bool _enabled) external {
        require(hasRole(PAUSER_ROLE, _msgSender()), "GameCoin: must have pauser role");
        bpEnabled = _enabled;
    }

    function setBotProtectionDisableForever() external {
        require(hasRole(PAUSER_ROLE, _msgSender()), "GameCoin: must have pauser role");
        require(BPDisabledForever == false);
        BPDisabledForever = true;
    }

    /**
     * @dev Pause token transfer, can be used to prevent attack
     *
     */
    function pause() external {
        require(hasRole(PAUSER_ROLE, _msgSender()), "GameCoin: must have pauser role");
        _pause();
    }
    /**
     * @dev Unpause token transfer
     *
     */
    function unpause() external {
        require(hasRole(PAUSER_ROLE, _msgSender()), "GameCoin: must have pauser role");
        _unpause();
    }

    /**
     * @dev Set _beforeTokenTransfer hook to used ERC20Pausable
     *
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20, ERC20Pausable) {
        super._beforeTokenTransfer(from, to, amount);
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *  Added transfer fee mechanism
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        if (bpEnabled && !BPDisabledForever) {
            BP.protect(sender, recipient, amount);
        }

        if (_senderWhitelist[sender] == true || _recipientWhitelist[recipient] == true) {
            super._transfer(sender, recipient, amount);
        } else {
            // calculate treasury token amount
            uint256 treasury_token_amount = (amount * transferFeeTreasuryPercent) / 100;
            // burn token only if totalSupply > minimumSupply else put all Fee to treasury
            uint256 burn_token_amount = 0;
            if (totalSupply() > transferStopBurnWhenLowSupply) {
                burn_token_amount = (amount * transferFeeBurnPercent) / 100;
            } else {
                treasury_token_amount += (amount * transferFeeBurnPercent) / 100;
            }
            require(treasury_token_amount + burn_token_amount < amount, "ERC20 Deflationary: transfer fee is greater or equal than amount");
            // treasury token
            super._transfer(sender, treasuryAddress, treasury_token_amount);
            // burn token
            if (burn_token_amount > 0) {
                _burn(sender, burn_token_amount);
            }
            // adjust amount of recipient
            amount -= treasury_token_amount + burn_token_amount;
            super._transfer(sender, recipient, amount);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
                /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Pausable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "../../../security/Pausable.sol";

/**
 * @dev ERC721 token with pausable token transfers, minting and burning.
 *
 * Useful for scenarios such as preventing trades until the end of an evaluation
 * period, or having an emergency switch for freezing all token transfers in the
 * event of a large bug.
 */
abstract contract ERC721Pausable is ERC721, Pausable {
    /**
     * @dev See {ERC721-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        require(!paused(), "ERC721Pausable: token transfer while paused");
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/extensions/ERC721Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "../../../utils/Context.sol";

/**
 * @title ERC721 Burnable Token
 * @dev ERC721 Token that can be burned (destroyed).
 */
abstract contract ERC721Burnable is Context, ERC721 {
    /**
     * @dev Burns `tokenId`. See {ERC721-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
        _burn(tokenId);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

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
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

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
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
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
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
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
            "ERC721: approve caller is not token owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

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
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");

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
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
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
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
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
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
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
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
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
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
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
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/ERC20Pausable.sol)

pragma solidity ^0.8.0;

import "../ERC20.sol";
import "../../../security/Pausable.sol";

/**
 * @dev ERC20 token with pausable token transfers, minting and burning.
 *
 * Useful for scenarios such as preventing trades until the end of an evaluation
 * period, or having an emergency switch for freezing all token transfers in the
 * event of a large bug.
 */
abstract contract ERC20Pausable is ERC20, Pausable {
    /**
     * @dev See {ERC20-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC20.sol";
import "../../../utils/Context.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

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
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/presets/ERC1155PresetMinterPauser.sol)

pragma solidity ^0.8.0;

import "../ERC1155.sol";
import "../extensions/ERC1155Burnable.sol";
import "../extensions/ERC1155Pausable.sol";
import "../../../access/AccessControlEnumerable.sol";
import "../../../utils/Context.sol";

/**
 * @dev {ERC1155} token, including:
 *
 *  - ability for holders to burn (destroy) their tokens
 *  - a minter role that allows for token minting (creation)
 *  - a pauser role that allows to stop all token transfers
 *
 * This contract uses {AccessControl} to lock permissioned functions using the
 * different roles - head to its documentation for details.
 *
 * The account that deploys the contract will be granted the minter and pauser
 * roles, as well as the default admin role, which will let it grant both minter
 * and pauser roles to other accounts.
 *
 * _Deprecated in favor of https://wizard.openzeppelin.com/[Contracts Wizard]._
 */
contract ERC1155PresetMinterPauser is Context, AccessControlEnumerable, ERC1155Burnable, ERC1155Pausable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE`, and `PAUSER_ROLE` to the account that
     * deploys the contract.
     */
    constructor(string memory uri) ERC1155(uri) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    /**
     * @dev Creates `amount` new tokens for `to`, of token type `id`.
     *
     * See {ERC1155-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC1155PresetMinterPauser: must have minter role to mint");

        _mint(to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] variant of {mint}.
     */
    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC1155PresetMinterPauser: must have minter role to mint");

        _mintBatch(to, ids, amounts, data);
    }

    /**
     * @dev Pauses all token transfers.
     *
     * See {ERC1155Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC1155PresetMinterPauser: must have pauser role to pause");
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC1155Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC1155PresetMinterPauser: must have pauser role to unpause");
        _unpause();
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlEnumerable, ERC1155)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override(ERC1155, ERC1155Pausable) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.0;

import "../IERC1155.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/ERC1155Pausable.sol)

pragma solidity ^0.8.0;

import "../ERC1155.sol";
import "../../../security/Pausable.sol";

/**
 * @dev ERC1155 token with pausable token transfers, minting and burning.
 *
 * Useful for scenarios such as preventing trades until the end of an evaluation
 * period, or having an emergency switch for freezing all token transfers in the
 * event of a large bug.
 *
 * _Available since v3.1._
 */
abstract contract ERC1155Pausable is ERC1155, Pausable {
    /**
     * @dev See {ERC1155-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        require(!paused(), "ERC1155Pausable: token transfer while paused");
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/extensions/ERC1155Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC1155.sol";

/**
 * @dev Extension of {ERC1155} that allows token holders to destroy both their
 * own tokens and those that they have been approved to use.
 *
 * _Available since v3.1._
 */
abstract contract ERC1155Burnable is ERC1155 {
    function burn(
        address account,
        uint256 id,
        uint256 value
    ) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );

        _burn(account, id, value);
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );

        _burnBatch(account, ids, values);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.0;

import "./IERC1155.sol";
import "./IERC1155Receiver.sol";
import "./extensions/IERC1155MetadataURI.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    constructor(string memory uri_) {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: address zero is not a valid owner");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `ids` and `amounts` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    /**
     * @dev Hook that is called after any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable is IAccessControl {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControlEnumerable.sol";
import "./AccessControl.sol";
import "../utils/structs/EnumerableSet.sol";

/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view virtual override returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view virtual override returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Overload {_grantRole} to track enumerable memberships
     */
    function _grantRole(bytes32 role, address account) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

    /**
     * @dev Overload {_revokeRole} to track enumerable memberships
     */
    function _revokeRole(bytes32 role, address account) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
                /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}