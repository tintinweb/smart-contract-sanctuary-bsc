// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

interface IPANCAKEFACTORY {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

interface IPANCAKEROUTER {
    function WETH() external pure returns (address);
}

interface IPANCAKERPAIR {
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

interface IREWARDS {
    function incrementRewards(address p_user, uint256 p_amount)
        external
        returns (bool);
}

interface ITROOPS {
    struct Troop {
       uint256 id;
        uint256 power;
        uint256 ammunition;
        //uint256 timeStamp;
        string name;
        uint256 readyTime;
    }

    function troop(uint256 p_idTroop)
        external
        view
        returns (Troop memory, bool);

    function updateLastTimeAttack(uint256 p_idTroop) external returns (bool);

    function ammunitionAttackValidate(uint256 p_idTroop)
        external
        view
        returns (bool);

    function idsNftsTroop(uint256 p_idTroop)
        external
        view
        returns (uint256[] memory);

    function idTroopsOwner(uint256 p_idTroop) external view returns (address);
}

interface ILEGIONS {
    struct Legion {
        uint256 id;
        uint256 power;
        uint256 ammunition;
        //uint256 timeStamp;
        string name;
        uint256 readyTime;
    }

    function legion(uint256 p_idLegion)
        external
        view
        returns (Legion memory, bool);

    function updateLastTimeAttack(uint256 p_idLegion) external returns (bool);

    /* function ammunitionAttackValidate(uint256 p_idLegion)
        external
        view
        returns (uint256);
*/
    function idLegionNft(uint256 p_idNft)
        external
        view
        returns (uint256[] memory);

    function idLegionsOwner(uint256 p_idLegion) external view returns (address);

    function idsNftsLegion(uint256 p_idLegion)
        external
        view
        returns (uint256[] memory);
}

interface ILOGICREWARDSDEVV14 {
    function incrementRewardsPreviewTroop(uint256 p_idTroop, uint256 p_level)
        external
        payable
        returns (bool);

    function incrementRewardsPreviewLegion(uint256 p_idLegion, uint256 p_level)
        external
        payable
        returns (bool);

    function incrementRewardsTroop(uint256 p_idTroop, uint256 p_level)
        external
        payable
        returns (bool,uint256 randomNumber);

    function incrementRewardsLegion(uint256 p_idLegion, uint256 p_level)
        external
        payable
        returns (bool, uint256 randomNumber);

    function getCanIncrementRewards(uint256 p_idNFT, uint256 p_level)
        external
        view
        returns (bool);

    function blocksToCanIncremetRewards(uint256 p_idNFT, uint256 p_level)
        external
        view
        returns (uint256);

    function blocksExpireToCanIncremetRewards(bytes32 p_hashRewards)
        external
        view
        returns (uint256);

    function getDegradationLegion(uint256 p_idLegion)
        external
        view
        returns (uint256);

    function getDegradationNFT(uint256 p_idNFT)
        external
        view
        returns (uint256, uint256);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}
interface IVIRUS {
    function rarity(uint256 p_nftId) external view returns (uint256);
    function burnVirus(uint256 _idNft) external returns (bool);
    function ownerOf(uint256 tokenId) external view returns(address owner);

}
interface ITITANIUM {
    function rarity(uint256 p_nftId) external view returns (uint256);
    function burnTitanium(uint256 _idNft) external returns (bool);
    function ownerOf(uint256 tokenId) external view returns(address owner);

}



contract LogicRewardsDevV35 is ILOGICREWARDSDEVV14 {
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // STATE
    //////////////////////////////////////////////////////////////////////////////////////////////////

    // Block number preview increment reguards
    mapping(bytes32 => uint256) private s_blockSuccess;

    // Seasons
    // Timelock, 1 de enero de 2021 0:00:00
    uint256 s_timeSeasons;
    address s_coinbaseSeasons;
    uint256 public s_randomSeason;
    uint256 public s_incrementNumRandom;

    // Rewards Address
    address private REWARDS_ADDRESS;

    // Troops Address
    address private TROOPS_ADDRESS;

    // Legions Address
    address private LEGIONS_ADDRESS; ////// <=============== (CAMBIAR)

    // ERC20 Utility Token Address
    address private ERC20_ADDRESS;
    address private proxyDelegate;
    ITROOPS troops;
    ILEGIONS legions;

    uint256 private model;
    mapping(address => bool) private blacklist;
    bool private engage;
    bool private engageZ;

    event e_winHumanoid(
        address indexed owner,
        uint256 mision,
        uint256 time,
        uint256 idTroop,
        uint256 randomNumber
    );
    event e_loseHumanoid(address indexed owner, uint256 mision, uint256 time,uint256 idTroop,uint256 randomNumber);

    event e_newEngage(address owner, bool engage);
    event e_newEngageZ(address owner, bool engage);

    event e_winZombie(
        address indexed owner,
        uint256 mision,
        uint256 time,
        uint256 idLegion,
        uint256 randomNumber
    );
    event e_loseZombie(
        address indexed owner,
        uint256 mision,
        uint256 time,
        uint256 idLegion,
        uint256 randomNumber
    );

    // Factory Pancakeswap
    // dev contract 0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc
    //prod contract 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73
    IPANCAKEFACTORY private constant FACTORY =
        IPANCAKEFACTORY(0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc);

    // Router Pancakeswap
    //dev 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
    //prod 0x10ED43C718714eb63d5aA57B78B54704E256024E
    IPANCAKEROUTER private constant ROUTER =
        IPANCAKEROUTER(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);

    /*  
        Chainlink Oracle
        ----------------------------------------------------
        Network: Binance Smart Chain
        Aggregator: BNB/USD (8 Decimals)
        Address Mainet: 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
        addres tesnet: 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
    */
    AggregatorV3Interface private constant PRICE_FEED =
        AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);

    //////////////////////////////////////////////////////////////////////////////////////////////////
    // Constructor
    //////////////////////////////////////////////////////////////////////////////////////////////////
    /*
    function initialize() external{
        REWARDS_ADDRESS = 0xBb61985Ac6eb49b70fc5ec0567650315275F635B;
        TROOPS_ADDRESS = 0xb2abF4d3ADe01348e702731120a3B5c3F9587335;
        LEGIONS_ADDRESS = 0xb2abF4d3ADe01348e702731120a3B5c3F9587335; ////// <=============== (CAMBIAR)
        ERC20_ADDRESS = 0xaf63BA2eE1245aDc74Df34671cDAd97d98daA5A4;
        proxyDelegate = msg.sender;
        s_timeSeasons= 1609455600;
        model = 1000000000000000;
        engage = false;
        engageZ = false;
        troops = ITROOPS(0xB749819A84d06fed0276fBc8e26534900F71363B);
        legions = ILEGIONS(0xb2abF4d3ADe01348e702731120a3B5c3F9587335);
    }
*/
    mapping(uint256 => uint256) private s_degradation;
    mapping(uint256 => uint256) private s_timeRestartDegration;
    mapping(uint256 => uint256) private s_timesToAttack;

    //humanoid mappings
    mapping(uint256 => uint256) private s_humanoidDegradation;
    mapping(uint256 => uint256) private s_humanoidTimeRestartDegration;
    mapping(uint256 => uint256) private s_humanoidTimesToAttack;

    mapping(uint256 => bool) private s_penaltyHumanoid;
    IVIRUS virus;
    ITITANIUM titanium;






function incrementRewardsPreviewTroop(uint256 p_idTroop, uint256 p_level)
        public
        payable
        override
        returns (bool)
    {
        (ITROOPS.Troop memory troop, bool exists) = troops.troop(p_idTroop);
        uint256 [] memory arrayNFTs = troops.idsNftsTroop(p_idTroop);
        require(exists, "Troop dont exist");
        require(p_level > 0 && p_level < 11, "Mision not available");
        require(
            troops.idTroopsOwner(p_idTroop) == msg.sender,
            "You dont are owner of this troop"
        );
        require(
            troop.readyTime <= block.timestamp,
            "Not have passed 24 hours to attack again"
        );
        require(troop.ammunition > 0, "Troop without active ammunitions");
        require(!engage, "maintenance");
        require(
            !blacklist[msg.sender],
            "your account is banned for attempted cheating"
        );
        troops.updateLastTimeAttack(p_idTroop);
        for (uint256 i = 0; i < arrayNFTs.length; i++) {
        require(s_humanoidDegradation[arrayNFTs[i]] < 30,"You have one NFT with 0 durability, please Heal him and try again");
         if(arrayNFTs[i] < 44276 && s_penaltyHumanoid[arrayNFTs[i]] == false ){
            s_penaltyHumanoid[arrayNFTs[i]] = true;
            s_humanoidTimeRestartDegration[arrayNFTs[i]] = 2;
        }
        }

        uint256 power = troop.power;
        _checkPower(p_level, power);

        bytes32 hashRewards = keccak256(
            abi.encodePacked(msg.sender, p_idTroop, p_level)
        );

        if (
            s_blockSuccess[hashRewards] > 0 &&
            s_blockSuccess[hashRewards] + 7 < block.number &&
            s_blockSuccess[hashRewards] + 1 < block.number - 256
        ) {
            delete s_blockSuccess[hashRewards];
        }
        require(s_blockSuccess[hashRewards] == 0, "Not allowed");
        s_blockSuccess[hashRewards] = block.number;

        return true;
    }

    function getDegradationNFT(uint256 p_idNFT)
        public
        view
        override
        returns (uint256, uint256)
    {
        if (s_degradation[p_idNFT] >= 5) {
            if (s_degradation[p_idNFT] < 10) {
                return (2, s_degradation[p_idNFT]);
            } else if (s_degradation[p_idNFT] < 15) {
                return (4, s_degradation[p_idNFT]);
            } else if (s_degradation[p_idNFT] < 20) {
                return (8, s_degradation[p_idNFT]);
            } else if (s_degradation[p_idNFT] < 22) {
                return (11, s_degradation[p_idNFT]);
            } else if (s_degradation[p_idNFT] < 25) {
                return (15, s_degradation[p_idNFT]);
            } else if (s_degradation[p_idNFT] < 27) {
                return (18, s_degradation[p_idNFT]);
            } else if (s_degradation[p_idNFT] < 30) {
                return (21, s_degradation[p_idNFT]);
            } else {
                return (25, s_degradation[p_idNFT]);
            }
        }

        return (0, s_degradation[p_idNFT]);
    }

      function getHumanoidDegradationNFT(uint256 p_idNFT)
        public
        view
        returns (uint256, uint256)
    {
        if (s_humanoidDegradation[p_idNFT] >= 5) {
            if (s_humanoidDegradation[p_idNFT] < 10) {
                return (2, s_humanoidDegradation[p_idNFT]);
            } else if (s_humanoidDegradation[p_idNFT] < 15) {
                return (4, s_humanoidDegradation[p_idNFT]);
            } else if (s_humanoidDegradation[p_idNFT] < 20) {
                return (8, s_humanoidDegradation[p_idNFT]);
            } else if (s_humanoidDegradation[p_idNFT] < 22) {
                return (12, s_humanoidDegradation[p_idNFT]);
            } else if (s_humanoidDegradation[p_idNFT] < 25) {
                return (15, s_humanoidDegradation[p_idNFT]);
            } else if (s_humanoidDegradation[p_idNFT] < 27) {
                return (18, s_humanoidDegradation[p_idNFT]);
            } else if (s_humanoidDegradation[p_idNFT] < 30) {
                return (21, s_humanoidDegradation[p_idNFT]);
            } else {
                return (25, s_humanoidDegradation[p_idNFT]);
            }
        }

        return (0, s_humanoidDegradation[p_idNFT]);
    }

    modifier proxyCaller() {
        require(
            msg.sender == proxyDelegate,
            "proxyDelegate verification failed"
        );
        _;
    }

    function value(uint256 p_idNft,uint256 p_kindElement) public view returns (uint256) {
        uint256 costPerDegradation;
        uint256 BNB_USD_Price = _getBNBPrice() / 10**8;
        uint256 ERC20_BNB_Price = _getERC20Price();

        if (s_timeRestartDegration[p_idNft] == 1 && p_kindElement == 0)  {
            costPerDegradation = 55;
        } else if (s_timeRestartDegration[p_idNft] >= 2 && p_kindElement == 0) {
            costPerDegradation = 100;
        } else if(s_timeRestartDegration[p_idNft] == 1 && p_kindElement == 1){
            costPerDegradation = 40;
        }else if (s_timeRestartDegration[p_idNft] == 2 && p_kindElement == 1){
          costPerDegradation = 75;
        }else if (s_timeRestartDegration[p_idNft] == 0 && p_kindElement == 1){
          costPerDegradation = 26;
        }else if (p_kindElement == 2 || p_kindElement == 3){
          costPerDegradation = 0;
        }
         else {
            costPerDegradation = 35;
        }
        uint256 amountBNBReward = (costPerDegradation * 1 ether) /
            BNB_USD_Price;
        return (amountBNBReward * 1 ether) / ERC20_BNB_Price;
    }

    //humanoid
       function valueHumanoid(uint256 p_idNft,uint256 p_kindElement) public view returns (uint256) {
        uint256 costPerDegradation;
        uint256 BNB_USD_Price = _getBNBPrice() / 10**8;
        uint256 ERC20_BNB_Price = _getERC20Price();

        //old humanoids without real degratation
        if(p_idNft < 44276 && s_penaltyHumanoid[p_idNft] == false && p_kindElement == 0){
                 costPerDegradation = 100;        
                }   
         //old with descount       
        if(p_idNft < 44276 && s_penaltyHumanoid[p_idNft] == false && p_kindElement == 1){
                 costPerDegradation = 100;        
                }       
        
        //new without descount 1 count
        if (s_humanoidTimeRestartDegration[p_idNft] == 1 && p_kindElement == 0) {
            costPerDegradation = 55;
        //new with descount 1 count  
        }  else if (s_humanoidTimeRestartDegration[p_idNft] == 1 && p_kindElement == 1) {
            costPerDegradation = 40;
        } 
       // new with 2 and witout discount
        else if (s_humanoidTimeRestartDegration[p_idNft] >= 2 && p_kindElement == 0) {
            costPerDegradation = 100;
        } 
        else if (s_humanoidTimeRestartDegration[p_idNft] >= 2 && p_kindElement == 1) {
            costPerDegradation = 75;
        } 
         else if (s_humanoidTimeRestartDegration[p_idNft] == 0 && p_kindElement == 1){
          costPerDegradation = 26;
        }else if (p_kindElement == 2 || p_kindElement == 3){
          costPerDegradation = 0;
        }
        else {
            costPerDegradation = 35;
        }
        uint256 amountBNBReward = (costPerDegradation * 1 ether) /
            BNB_USD_Price;
        return (amountBNBReward * 1 ether) / ERC20_BNB_Price;
    }

    function getTimesToRestart(uint256 p_nftId, uint256 p_kindElement)
        public
        view
        returns (uint256, uint256)
    {
        return (s_timeRestartDegration[p_nftId], value(p_nftId, p_kindElement));
    }

     function getHumanoidTimesToRestart(uint256 p_nftId,uint256 p_kindElement)
        public
        view
        returns (uint256, uint256)
    {
        return (s_humanoidTimeRestartDegration[p_nftId], valueHumanoid(p_nftId,p_kindElement));
    }

    function _canPayDurability(uint256 p_idNft, uint256 p_kindElement ) public view returns (bool) {
        if (IERC20(ERC20_ADDRESS).balanceOf(msg.sender) < value(p_idNft,p_kindElement)) {
            return false;
        } else {
            return true;
        }
    }

     function _canPayHumanoidDurability(uint256 p_idNft, uint256 p_kindElement) public view returns (bool) {
        if (IERC20(ERC20_ADDRESS).balanceOf(msg.sender) < valueHumanoid(p_idNft,p_kindElement)) {
            return false;
        } else {
            return true;
        }
    }

    function restartDurability(uint256 p_idNft,uint256 element)
        external
        payable
        returns (bool)
    {
        uint256 rarity;
        require(
            s_degradation[p_idNft] > 0 && s_timeRestartDegration[p_idNft] < 3,
            "the nft has no durability to restore or this nft have the maximum restores per nft"
        );
        require(msg.value == businessModel(), "out of gas");
        
         if (element == 0){
             rarity = 0;
         }else{
             require(msg.sender == IVIRUS(virus).ownerOf(element),"you not are the owner of this element");
         rarity = IVIRUS(virus).rarity(element);  
         } 
        require(
            _canPayDurability(p_idNft,rarity),
            "you dont have suficients tokens to restart durability"
        );
        IERC20(ERC20_ADDRESS).transferFrom(
            msg.sender,
            REWARDS_ADDRESS,
            value(p_idNft,rarity)
        );
        s_degradation[p_idNft] = 0;
        if(rarity == 3){
         s_timeRestartDegration[p_idNft] = 0;
        }else{
         s_timeRestartDegration[p_idNft] += 1;
        }
        if(element > 0){
        IVIRUS(virus).burnVirus(element);
        }
        return true;
    }

    function restartHumanoidDurability(uint256 p_idNft, uint256 element)
        external
        payable
        returns (bool)
    {
        uint256 rarity;
        require(
            s_humanoidDegradation[p_idNft] > 0 && s_humanoidTimeRestartDegration[p_idNft] < 3,
            "the nft has no durability to restore or this nft have the maximum restores per nft"
        );
        require(msg.value == businessModel(), "out of gas");
         
         if (element == 0){
             rarity = 0;
         }else{
             rarity = ITITANIUM(titanium).rarity(element);
             require(msg.sender == ITITANIUM(titanium).ownerOf(element),"you not are owner this element");
         }
        
        require(
            _canPayHumanoidDurability(p_idNft,rarity),
            "you dont have suficients tokens to restart durability"
        );
         if(p_idNft < 44276 && s_penaltyHumanoid[p_idNft] == false && rarity < 3 ){
             
             s_penaltyHumanoid[p_idNft] = true;
                 s_humanoidDegradation[p_idNft] = 0;
              s_humanoidTimeRestartDegration[p_idNft] = 3;
               IERC20(ERC20_ADDRESS).transferFrom(
            msg.sender,
            REWARDS_ADDRESS,
            valueHumanoid(p_idNft,rarity)
        );
                return true;   
                }  

        IERC20(ERC20_ADDRESS).transferFrom(
            msg.sender,
            REWARDS_ADDRESS,
            valueHumanoid(p_idNft,rarity)
        );
        s_humanoidDegradation[p_idNft] = 0;
        if(rarity == 3){
            s_humanoidTimeRestartDegration[p_idNft] = 0;
        }else{
        s_humanoidTimeRestartDegration[p_idNft] += 1;
        }
        if(element > 0){
            ITITANIUM(titanium).burnTitanium(element);
        }
        return true;
    }

    function setDurability(
        uint256 p_i,
        uint256 p_nftId,
        uint256 p_durability
    ) external proxyCaller returns (bool) {
        for (uint256 i = p_i; i < p_nftId; i++) {
            s_degradation[i] = p_durability;
        }
        return true;
    }

     function setHumanoidDurability(
        uint256 p_i,
        uint256 p_nftId,
        uint256 p_durability
    ) external proxyCaller returns (bool) {
        for (uint256 i = p_i; i < p_nftId; i++) {
            s_humanoidDegradation[i] = p_durability;
        }
        return true;
    }
 function setHumanoidTimesToDurability (uint256[] memory p_idnfts, uint256 p_value) external proxyCaller returns (bool){
         for(uint256 i = 0; i < p_idnfts.length; i++){
             s_humanoidTimeRestartDegration[p_idnfts[i]] = p_value;
             s_penaltyHumanoid[p_idnfts[i]] = true;
         }
         return true;
    }
    

    function setTroopContract (address p_troopAddress) external proxyCaller returns (bool){
        TROOPS_ADDRESS = p_troopAddress;
        return true;
    }

    function setTroopInterfaceContract (address p_interface)external proxyCaller returns (bool){
        troops = ITROOPS(p_interface);
        return true;
    }

    function setIntefacesElementum (uint256 p_kind,address p_address) external proxyCaller returns (bool){
        if(p_kind == 1){
            virus = IVIRUS(p_address);
            return true;
        }else{
            titanium = ITITANIUM(p_address);    
            return true;
        }
        
    }

    function getDegradationTroop(uint256 p_idTroop)
        public
        view
        returns (uint256)
    {
         uint256[] memory arrayNFTs = ITROOPS(TROOPS_ADDRESS).idsNftsTroop(
            p_idTroop
        );

        uint256 degradation;
        for (uint256 i = 0; i < arrayNFTs.length; i++) {
            if (s_humanoidDegradation[arrayNFTs[i]] >= 5) {
                if (s_humanoidDegradation[arrayNFTs[i]] < 10) {
                    degradation += 2;
                } else if (s_humanoidDegradation[arrayNFTs[i]] < 15) {
                    degradation += 4;
                } else if (s_humanoidDegradation[arrayNFTs[i]] < 20) {
                    degradation += 8;
                } else if (s_humanoidDegradation[arrayNFTs[i]] < 22) {
                    degradation += 12;
                } else if (s_humanoidDegradation[arrayNFTs[i]] < 25) {
                    degradation += 15;
                } else if (s_humanoidDegradation[arrayNFTs[i]] < 27) {
                    degradation += 18;
                } else if (s_humanoidDegradation[arrayNFTs[i]] < 30) {
                    degradation += 21;
                } else {
                    degradation += 25;
                }
            }
            degradation += 0;
        }

        return degradation;
    }

    function setBlacklist(address _user) external proxyCaller {
        require(!blacklist[_user], "user already blacklisted ");
        blacklist[_user] = true;
    }

    function setWhitelist(address _user) external proxyCaller {
        require(blacklist[_user], "user dont blacklisted ");
        blacklist[_user] = false;
    }

    function setEngage(bool choice) public proxyCaller returns (bool) {
        if (choice == true) {
            engage = true;
        } else {
            engage = false;
        }
        emit e_newEngage(msg.sender, choice);
        return engage;
    }

    function setEngageZ(bool choice) public proxyCaller returns (bool) {
        if (choice == true) {
            engageZ = true;
        } else {
            engageZ = false;
        }
        emit e_newEngageZ(msg.sender, choice);
        return engageZ;
    }

    function businessModel() internal view returns (uint256) {
        return model;
    }

    function setModel(uint256 _newModel) external proxyCaller {
        model = _newModel;
    }

    function checkOut() external proxyCaller {
        uint256 amount = address(this).balance;
        payable(msg.sender).transfer(amount);
    }

    function incrementRewardsPreviewLegion(uint256 p_idLegion, uint256 p_level)
        public
        payable
        override
        returns (bool)
    {
        (ILEGIONS.Legion memory legion, bool exists) = ILEGIONS(LEGIONS_ADDRESS)
            .legion(p_idLegion);
             uint256[] memory arrayNFTs = ILEGIONS(LEGIONS_ADDRESS).idsNftsLegion(
            p_idLegion
        );
        require(exists, "Legion dont exist");
        require(p_level > 0 && p_level < 11, "Mision not available");
        require(
            legions.idLegionsOwner(p_idLegion) == msg.sender,
            "You dont are owner of this legion"
        );
        require(
            legion.readyTime <= block.timestamp,
            "Not have passed 24 hours to attack again"
        );
        require(legion.ammunition > 0, "Legion without active ammunition");
        require(!engageZ, "maintenance");
        require(
            !blacklist[msg.sender],
            "your account is banned for attempted cheating"
        );
        require(msg.value == businessModel(), "out of gas");
         for (uint256 i = 0; i < arrayNFTs.length; i++) {
        require(s_degradation[arrayNFTs[i]] < 30,"You have one NFT with 0 durability, please Heal him and try again");
         }
        legions.updateLastTimeAttack(p_idLegion);

        uint256 power = legion.power;
        _checkPower(p_level, power);

        bytes32 hashRewards = keccak256(
            abi.encodePacked(msg.sender, p_idLegion, p_level)
        );

        if (
            s_blockSuccess[hashRewards] > 0 &&
            s_blockSuccess[hashRewards] + 7 < block.number &&
            s_blockSuccess[hashRewards] + 1 < block.number - 256
        ) {
            delete s_blockSuccess[hashRewards];
        }
        require(s_blockSuccess[hashRewards] == 0, "Not allowed");
        s_blockSuccess[hashRewards] = block.number;

        return true;
    }

    function getDegradationLegion(uint256 p_idLegion)
        public
        view
        override
        returns (uint256)
    {
        uint256[] memory arrayNFTs = ILEGIONS(LEGIONS_ADDRESS).idsNftsLegion(
            p_idLegion
        );

        uint256 degradation;
        for (uint256 i = 0; i < arrayNFTs.length; i++) {
            if (s_degradation[arrayNFTs[i]] >= 5) {
                if (s_degradation[arrayNFTs[i]] < 10) {
                    degradation += 2;
                } else if (s_degradation[arrayNFTs[i]] < 15) {
                    degradation += 4;
                } else if (s_degradation[arrayNFTs[i]] < 20) {
                    degradation += 8;
                } else if (s_degradation[arrayNFTs[i]] < 22) {
                    degradation += 12;
                } else if (s_degradation[arrayNFTs[i]] < 25) {
                    degradation += 15;
                } else if (s_degradation[arrayNFTs[i]] < 27) {
                    degradation += 18;
                } else if (s_degradation[arrayNFTs[i]] < 30) {
                    degradation += 21;
                } else {
                    degradation += 25;
                }
            }
            degradation += 0;
        }

        return degradation;
    }

     function incrementRewardsTroop(uint256 p_idTroop, uint256 p_level)
        external
        payable
        override
        returns (bool, uint256)
    {
        (ITROOPS.Troop memory troop, bool exists) = ITROOPS(TROOPS_ADDRESS)
            .troop(p_idTroop);
        require(exists, "Troop dont exist");
        require(p_level > 0 && p_level < 11, "Mision not available");
        require(
            troops.idTroopsOwner(p_idTroop) == msg.sender,
            "You dont are owner of this troop"
        );
        require(msg.value == businessModel(), "out of gas");

        uint256 power = troop.power;
        _checkPower(p_level, power);

        bytes32 hashRewards = keccak256(
            abi.encodePacked(msg.sender, p_idTroop, p_level)
        );

        uint256[] memory arrayNFTs = ITROOPS(TROOPS_ADDRESS).idsNftsTroop(
            p_idTroop
        );

        (bool success, uint256 getNumber) = _success(p_level, hashRewards,p_idTroop);

        if (!success) {
            emit e_loseHumanoid(msg.sender, p_level, block.timestamp, p_idTroop,getNumber);
            
             for (uint256 i = 0; i < arrayNFTs.length; i++) {
                s_humanoidTimesToAttack[arrayNFTs[i]] += 1;
             }
             IREWARDS(REWARDS_ADDRESS).incrementRewards(
                msg.sender,
                 0
            );

            delete s_blockSuccess[hashRewards];
            return (false, getNumber);
        }

        if (success) {
                for (uint256 i = 0; i < arrayNFTs.length; i++) {
                s_humanoidDegradation[arrayNFTs[i]] += 1;
            }
       
            IREWARDS(REWARDS_ADDRESS).incrementRewards(
                msg.sender,
                _getRewardsToken(p_level)
                );
            emit e_winHumanoid(
                msg.sender,
                p_level,
                block.timestamp,
                p_idTroop,
                getNumber
            );
        }
        delete s_blockSuccess[hashRewards];

        return (true, getNumber);
    }

   function incrementRewardsLegion(uint256 p_idLegion, uint256 p_level)
        public
        payable
        override
        returns (bool, uint256)
    {
        (ILEGIONS.Legion memory legion, bool exists) = ILEGIONS(LEGIONS_ADDRESS)
            .legion(p_idLegion);
        require(exists, "Legion dont exist");
        require(p_level > 0 && p_level < 11, "Mision not available");
        require(
            legions.idLegionsOwner(p_idLegion) == msg.sender,
            "You dont are owner of this legion"
        );
        require(msg.value == businessModel(), "out of gas");

        uint256 power = legion.power;
        _checkPower(p_level, power);

        bytes32 hashRewards = keccak256(
            abi.encodePacked(msg.sender, p_idLegion, p_level)
        );

        uint256[] memory arrayNFTs = ILEGIONS(LEGIONS_ADDRESS).idsNftsLegion(
            p_idLegion
        );
        
        (bool success, uint256 getNumber) = _successZ(
            p_level,
            hashRewards,
            p_idLegion
        );
        
        if (!success) {
            emit e_loseZombie(
                msg.sender,
                p_level,
                block.timestamp,
                p_idLegion,
                getNumber
            );
             for (uint256 i = 0; i < arrayNFTs.length; i++) {
                s_timesToAttack[arrayNFTs[i]] += 1;
             }
                IREWARDS(REWARDS_ADDRESS).incrementRewards(
                msg.sender,
                 0
            );

            delete s_blockSuccess[hashRewards];
            return (false, getNumber);
        }

        if (success) {
            for (uint256 i = 0; i < arrayNFTs.length; i++) {
                s_degradation[arrayNFTs[i]] += 1;
            }
        
            IREWARDS(REWARDS_ADDRESS).incrementRewards(
                msg.sender,
                 _getRewardsToken(p_level)
            );
        }

        delete s_blockSuccess[hashRewards];
        emit e_winZombie(
            msg.sender,
            p_level,
            block.timestamp,
            p_idLegion,
            getNumber
        );
        return (true, getNumber);
    }

    function getCanIncrementRewards(uint256 p_idNFT, uint256 p_level)
        public
        view
        override
        returns (bool)
    {
        return
            _getCanIncrementRewards(
                keccak256(abi.encodePacked(msg.sender, p_idNFT, p_level))
            );
    }

    function blocksToCanIncremetRewards(uint256 p_idNFT, uint256 p_level)
        public
        view
        override
        returns (uint256)
    {
        return
            _blocksToCanIncremetRewards(
                keccak256(abi.encodePacked(msg.sender, p_idNFT, p_level))
            );
    }

    function blocksExpireToCanIncremetRewards(bytes32 p_hashRewards)
        public
        view
        override
        returns (uint256)
    {
        return _blocksExpireToCanIncremetRewards(p_hashRewards);
    }

    function viewRewards(uint256 p_level) external view returns (uint256) {
        uint256 BNB_USD_Price = _getBNBPrice() / 10**8; // 565
        uint256 ERC20_BNB_Price = _getERC20Price();

        uint256 amountBNBReward = (_rewardAmount(p_level) * 1 ether) /
            BNB_USD_Price;
        return (amountBNBReward * 1 ether) / ERC20_BNB_Price;
    }

    function validatePower(uint256 p_power) external pure returns (uint256) {
        if (p_power >= 300 && p_power < 500) {
            return 1;
        }
        if (p_power >= 500 && p_power < 700) {
            return 2;
        }
        if (p_power >= 700 && p_power < 900) {
            return 3;
        }
        if (p_power >= 900 && p_power < 1100) {
            return 4;
        }
        if (p_power >= 1100 && p_power < 1300) {
            return 5;
        }
        if (p_power >= 1300 && p_power < 1500) {
            return 6;
        }
        if (p_power >= 1500 && p_power < 1700) {
            return 7;
        }
        if (p_power >= 1700 && p_power < 1900) {
            return 8;
        }
        if (p_power >= 1900 && p_power < 2100) {
            return 9;
        }
        if (p_power >= 2100) {
            return 10;
        }
        return 0;
    }

    function getMisionData(uint256 p_idLegion)
        public
        view
        returns (uint256[10] memory)
    {
        uint256 degradation;
        degradation = getDegradationLegion(p_idLegion);
        uint256[10] memory mision;
        mision[0] = 80;
        mision[1] = 75;
        mision[2] = 70;
        mision[3] = 65;
        mision[4] = 62;
        mision[5] = 60;
        mision[6] = 57;
        mision[7] = 55;
        mision[8] = 52;
        mision[9] = 50;
        uint256[10] memory calculated;

        for (uint256 i = 0; i < calculated.length; i++) {
            if (degradation > mision[i]) {
                calculated[i] = 0;
            } else {
                calculated[i] = mision[i] - degradation;
            }
        }
        return calculated;
    }

    function getMisionDataTroop(uint256 p_idTroop)
        public
        view
        returns (uint256[10] memory)
    {
        uint256 degradation;
        degradation = getDegradationTroop(p_idTroop);
        uint256[10] memory mision;
        mision[0] = 80;
        mision[1] = 75;
        mision[2] = 70;
        mision[3] = 65;
        mision[4] = 62;
        mision[5] = 60;
        mision[6] = 57;
        mision[7] = 55;
        mision[8] = 52;
        mision[9] = 50;
        uint256[10] memory calculated;

        for (uint256 i = 0; i < calculated.length; i++) {
            if (degradation > mision[i]) {
                calculated[i] = 0;
            } else {
                calculated[i] = mision[i] - degradation;
            }
        }
        return calculated;
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////
    // Internal functions
    //////////////////////////////////////////////////////////////////////////////////////////////////

    /* function _canIncrementReward() internal view returns (bool) {
        for (uint256 i = 0; i < ORIGIN_ADDRESS.length; i++) {
            if (ORIGIN_ADDRESS[i] == msg.sender) {
                return true;
            }
        }

        return false;
    }
    */
      function _getRewardsToken (uint256 p_level) internal view returns (uint256){
       uint256 BNB_USD_Price = _getBNBPrice() / 10**8;
        uint256 ERC20_BNB_Price = _getERC20Price();

        uint256 amountBNBReward = (_rewardAmount(p_level) * 1 ether) /
            BNB_USD_Price;
        return (amountBNBReward * 1 ether) /
            ERC20_BNB_Price;
    }


    function _checkPower(uint256 p_level, uint256 p_power) internal pure {
        if (p_level == 1 && p_power < 300) {
            revert("Insufficient power");
        }
        if (p_level == 2 && p_power < 500) {
            revert("Insufficient power");
        }
        if (p_level == 3 && p_power < 700) {
            revert("Insufficient power");
        }
        if (p_level == 4 && p_power < 900) {
            revert("Insufficient power");
        }
        if (p_level == 5 && p_power < 1100) {
            revert("Insufficient power");
        }
        if (p_level == 6 && p_power < 1300) {
            revert("Insufficient power");
        }
        if (p_level == 7 && p_power < 1500) {
            revert("Insufficient power");
        }
        if (p_level == 8 && p_power < 1700) {
            revert("Insufficient power");
        }
        if (p_level == 9 && p_power < 1900) {
            revert("Insufficient power");
        }
        if (p_level == 10 && p_power < 2100) {
            revert("Insufficient power");
        }
    }

    function _rewardAmount(uint256 p_level) internal pure returns (uint256) {
        if (p_level == 1) {
            return 15;
        }
        if (p_level == 2) {
            return 22;
        }
        if (p_level == 3) {
            return 31;
        }
        if (p_level == 4) {
            return 42;
        }
        if (p_level == 5) {
            return 55;
        }
        if (p_level == 6) {
            return 72;
        }
        if (p_level == 7) {
            return 87;
        }
        if (p_level == 8) {
            return 115;
        }
        if (p_level == 9) {
            return 135;
        }

        return 150;
    }
     function _getNumberPerMisionTroop(uint256 p_level, uint256 p_idTroop)
        public
        view
        returns (uint256)
    {
        uint256[10] memory numberPerMision = getMisionDataTroop(p_idTroop);
        return numberPerMision[p_level - 1];
    }


  function _success(uint256 p_level, bytes32 p_hashRewards,uint256 p_idTroop)
        internal
        returns (bool, uint256)
    {
        if (
            s_blockSuccess[p_hashRewards] > 0 &&
            s_blockSuccess[p_hashRewards] + 7 < block.number &&
            s_blockSuccess[p_hashRewards] + 1 < block.number - 256
        ) {
            delete s_blockSuccess[p_hashRewards];
            return (false,99);
        }

        require(_getCanIncrementRewards(p_hashRewards), "fix hash");

        uint256 numBlock = s_blockSuccess[p_hashRewards];
        uint256 randomnumber = uint256(
            keccak256(
                abi.encodePacked(
                    uint256(blockhash(uint256(numBlock + 6))),
                    uint256(blockhash(uint256(numBlock + 5))),
                    uint256(blockhash(uint256(numBlock + 4))),
                    uint256(blockhash(uint256(numBlock + 3))),
                    uint256(blockhash(uint256(numBlock + 2))),
                    uint256(blockhash(uint256(numBlock + 1)))
                )
            )
        ) % 99;
         randomnumber += 1;

            if (randomnumber <= _getNumberPerMisionTroop(p_level, p_idTroop)) {
                return (true, randomnumber); 
            }
        return (false, randomnumber);
    }

     function _getNumberPerMision(uint256 p_level, uint256 p_idLegion)
        public
        view
        returns (uint256)
    {
        uint256[10] memory numberPerMision = getMisionData(p_idLegion);
        return numberPerMision[p_level - 1];
    }


    function _successZ(
        uint256 p_level,
        bytes32 p_hashRewards,
        uint256 p_idLegion
    ) internal returns (bool, uint256) {
        if (
            s_blockSuccess[p_hashRewards] > 0 &&
            s_blockSuccess[p_hashRewards] + 7 < block.number &&
            s_blockSuccess[p_hashRewards] + 1 < block.number - 256
        ) {
            delete s_blockSuccess[p_hashRewards];
            return (false, 99);
        }

        require(_getCanIncrementRewards(p_hashRewards), "fix hash");

        uint256 numBlock = s_blockSuccess[p_hashRewards];
        uint256 randomnumber = uint256(
            keccak256(
                abi.encodePacked(
                    uint256(blockhash(uint256(numBlock + 6))),
                    uint256(blockhash(uint256(numBlock + 5))),
                    uint256(blockhash(uint256(numBlock + 4))),
                    uint256(blockhash(uint256(numBlock + 3))),
                    uint256(blockhash(uint256(numBlock + 2))),
                    uint256(blockhash(uint256(numBlock + 1)))
                )
            )
        ) % 99;
        randomnumber += 1;

             if (randomnumber <= _getNumberPerMision(p_level, p_idLegion)) {
                return (true, randomnumber);
            }

        return (false, randomnumber);
    }

    function _getCanIncrementRewards(bytes32 p_hashRewards)
        internal
        view
        returns (bool)
    {
        if (
            s_blockSuccess[p_hashRewards] == 0 ||
            s_blockSuccess[p_hashRewards] + 7 >= block.number ||
            s_blockSuccess[p_hashRewards] + 1 < block.number - 256
        ) {
            return false;
        }

        return true;
    }

    function _blocksToCanIncremetRewards(bytes32 p_hashRewards)
        internal
        view
        returns (uint256)
    {
        if (block.number >= s_blockSuccess[p_hashRewards] + 7) {
            return 0;
        }

        return (s_blockSuccess[p_hashRewards] + 7) - block.number;
    }

    function _blocksExpireToCanIncremetRewards(bytes32 p_hashRewards)
        internal
        view
        returns (uint256)
    {
        if ((block.number - 256) >= (s_blockSuccess[p_hashRewards] + 1)) {
            return 0;
        }

        return (s_blockSuccess[p_hashRewards] + 1) - (block.number - 256);
    }

    function _getBNBPrice() internal view returns (uint256) {
        (, int256 price, , , ) = PRICE_FEED.latestRoundData();

        return uint256(price);
    }

    function _getERC20Price() internal view returns (uint256) {
        IPANCAKERPAIR pair = IPANCAKERPAIR(
            FACTORY.getPair(ERC20_ADDRESS, ROUTER.WETH())
        );

        (uint256 Res0, uint256 Res1, ) = pair.getReserves();

        if (ERC20_ADDRESS < ROUTER.WETH()) {
            uint256 res1 = Res1 * 1 ether;
            return (res1 / Res0);
        } else {
            uint256 res0 = Res0 * 1 ether;
            return (res0 / Res1);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}