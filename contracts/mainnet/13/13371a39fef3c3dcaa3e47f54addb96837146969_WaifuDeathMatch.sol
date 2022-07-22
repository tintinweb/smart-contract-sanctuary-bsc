/**
 *Submitted for verification at BscScan.com on 2022-07-22
*/

//Waifu DeathMatch

// Code written by MrGreenCrypto
// SPDX-License-Identifier: None

pragma solidity 0.8.15;

interface IShoujoStats {
    struct Shoujo {
        uint16 nameIndex;
        uint16 surnameIndex;
        uint8 rarity;
        uint8 personality;
        uint8 cuteness;
        uint8 lewd;
        uint8 intelligence;
        uint8 aggressiveness;
        uint8 talkative;
        uint8 depression;
        uint8 genki;
        uint8 raburabu; 
        uint8 boyish;
    }
    function tokenStatsByIndex(uint256 index) external view returns (Shoujo memory);
}

interface WaifuInterface{
    function transferFrom(address from, address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function ownerOf(uint256 tokenId) external view returns (address);
}

interface WaifusOwnerInterface{
    function getAllIdsOwnedBy(address owner) external view returns(uint256[] memory);
}

interface ICCVRF {
    function requestRandomness(uint256 requestID, uint256 howManyNumbers) external payable;
}

contract WaifuDeathMatch {
    WaifusOwnerInterface public waifusOwnedBy = WaifusOwnerInterface (0xA0BA1Ad248DE4118Cf39080e8a5aD0d548Be95b7);
    WaifuInterface public waifu = WaifuInterface(0x2129cFb8E63C62D0E119d2597536EE4e1a8e39Da);
    IShoujoStats waifuStats = IShoujoStats(0x12fDECb39E134BD96fa8E4d0F7Aa31580dC6b641);


    uint256 public totalDeathMatchID;
    mapping(uint256 => bool) public wantsToFight;
    mapping(uint256 => uint256) public whichMatchIsThatWaifuFightingIn;
    mapping(uint256 => uint256) public whichWaifuIsFighting;
    mapping(uint256 => uint256) public secondWaifuOfDeathMatch;
   
    uint256 fightCost = 0.00420 ether;

    ICCVRF public randomnessSupplier = ICCVRF(0xC0de0aB6E25cc34FB26dE4617313ca559f78C0dE);
    modifier onlyVRF() {if(msg.sender != address(randomnessSupplier)) return; _;}
    uint256 totalDeathMatchesFought;
    uint256 vrfCost = 0.001337 ether;

    address public constant CEO = 0xe6497e1F2C5418978D5fC2cD32AA23315E7a41Fb;
    modifier onlyOwner() {if(msg.sender != CEO) return; _;}
    
    event DeathMatchOver(address winner, uint256 waifuWon, address loser);

    constructor() {}

    function getAllIdsOfWallet( address wallet) public view returns(uint256[] memory) {
        return waifusOwnedBy.getAllIdsOwnedBy(wallet);
    }

    function listAllOpenDeathMatches() public view returns (uint256[] memory) {
        uint256[] memory listOfAllOpenDeathMatches;
        uint256 totalOpenDeathMatches;

        for(uint256 i = 0; i < totalDeathMatchID; i++){
            if(wantsToFight[whichWaifuIsFighting[i]]) {
                listOfAllOpenDeathMatches[totalOpenDeathMatches] = i;
                totalOpenDeathMatches++;
            }
        }
        return listOfAllOpenDeathMatches;
    }

    function listTheIdsOfAllWaifusOnDeathRow() public view returns (uint256[] memory) {
        uint256[] memory listOfWaifusOnDeathRow;
        uint256 totalWaifusOnDeathRow;

        for(uint256 i = 0; i < totalDeathMatchID; i++){
            if(wantsToFight[whichWaifuIsFighting[i]]) {
                listOfWaifusOnDeathRow[totalWaifusOnDeathRow] = whichWaifuIsFighting[i];
                totalWaifusOnDeathRow++;
            }
        }
        return listOfWaifusOnDeathRow;
    }

    function getDeathMatchIdOfWaifu(uint256 waifuId) public view returns(uint256){
        return whichMatchIsThatWaifuFightingIn[waifuId];
    }

    function listAllOpenDeathMatchesWithTheIdOfTheWaifuOnDeathRow() public view returns (uint256[] memory, uint256[] memory) {
        uint256[] memory listOfAllOpenDeathMatches = listAllOpenDeathMatches();
        uint256[] memory listOfWaifusOnDeathRow = listTheIdsOfAllWaifusOnDeathRow();
        return (listOfAllOpenDeathMatches,listOfWaifusOnDeathRow);
    }

    function openDeathMatch(uint256 waifuId) payable external {
        require(waifu.isApprovedForAll(msg.sender, address(this)),"Need approval for your waifus");
        require(msg.value >= fightCost, "Must offer enough to pay the asking price");
        wantsToFight[waifuId] = true;
        whichWaifuIsFighting[totalDeathMatchID] = waifuId;
        whichMatchIsThatWaifuFightingIn[waifuId] = totalDeathMatchID;
        totalDeathMatchID++;
    }

    function joinDeathMatch(uint256 deathMatchID, uint256 waifuID) external payable {
        require(waifu.isApprovedForAll(msg.sender, address(this)),"Need approval for your waifus");
        require(wantsToFight[whichWaifuIsFighting[deathMatchID]], "Can't fight a waifu that doesn't want to fight");
        require(waifu.ownerOf(waifuID) == msg.sender, "Can't fight with a waifu that is not owned by you");
        uint256 yourRarity = getRarity(waifuID);
        uint256 opponentRarity = getRarity(whichWaifuIsFighting[deathMatchID]);
        require(yourRarity >= opponentRarity, "Can't fight a stronger waifu");
        require(msg.value >= fightCost, "Must offer enough to pay the asking price");
        wantsToFight[whichWaifuIsFighting[deathMatchID]] = false;
        secondWaifuOfDeathMatch[deathMatchID] = waifuID;
        randomnessSupplier.requestRandomness{value: vrfCost}(deathMatchID, 3);
    }

    function supplyRandomness(uint256 deathMatchID, uint256[] memory randomNumbers) external onlyVRF {
        uint256 firstWaifu = whichWaifuIsFighting[deathMatchID];
        uint256 secondWaifu = secondWaifuOfDeathMatch[deathMatchID];
        address ownerOfFirstWaifu = waifu.ownerOf(firstWaifu);
        address ownerOfSecondWaifu = waifu.ownerOf(secondWaifu);
        uint256 whichAttributeIsCompared = randomNumbers[2] % 9;
        uint256 strength1 = getStats(firstWaifu)[whichAttributeIsCompared];
        uint256 strength2 = getStats(secondWaifu)[whichAttributeIsCompared];
        uint256 modifier1 = randomNumbers[0] % 100 + 50;
        uint256 modifier2 = randomNumbers[1] % 100 + 50;

        if(strength1 * modifier1 >= strength2 * modifier2) {
            waifu.transferFrom(ownerOfSecondWaifu, ownerOfFirstWaifu, secondWaifu);
            emit DeathMatchOver(ownerOfFirstWaifu, secondWaifu, ownerOfSecondWaifu);
        } else{
            waifu.transferFrom(ownerOfFirstWaifu, ownerOfSecondWaifu, firstWaifu);
            emit DeathMatchOver(ownerOfSecondWaifu, firstWaifu, ownerOfFirstWaifu);
        }
        payable(CEO).transfer(address(this).balance);
    }

    function getRarity(uint256 waifuID) public view returns (uint256) {
        IShoujoStats.Shoujo memory waifuToCheck = waifuStats.tokenStatsByIndex(waifuID);
        return waifuToCheck.rarity;
    }

    function getStats(uint256 waifuID) public view returns(uint8[] memory) {
        IShoujoStats.Shoujo memory waifuToCheck = waifuStats.tokenStatsByIndex(waifuID);
        uint8[] memory waifuAttributes = new uint8[](9);
        waifuAttributes[0] = waifuToCheck.cuteness;
        waifuAttributes[1] = waifuToCheck.lewd;
        waifuAttributes[2] = waifuToCheck.intelligence;
        waifuAttributes[3] = waifuToCheck.aggressiveness;
        waifuAttributes[4] = waifuToCheck.talkative;
        waifuAttributes[5] = waifuToCheck.depression;
        waifuAttributes[6] = waifuToCheck.genki;
        waifuAttributes[7] = waifuToCheck.raburabu;
        waifuAttributes[8] = waifuToCheck.boyish;
        return waifuAttributes;
    }
}