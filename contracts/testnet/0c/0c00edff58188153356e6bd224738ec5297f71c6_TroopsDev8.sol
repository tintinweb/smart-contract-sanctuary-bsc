// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////   INTERFACES    ////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address owner);

 function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function power(uint256 p_idNFT) external view returns (uint256);
}

interface IERC721II {
    function ownerOf(uint256 tokenId) external view returns (address owner);

 function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function power(uint256 p_idNFT) external view returns (uint256);
}

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



interface ITROOPS {
    // Troop info
    struct Troop {
        uint256 id;
        uint256 power;
        uint8 ammunition;
        string name;
        uint256 readyTime;
    }

    // Events
    event e_newTroop(address indexed owner, uint256 idTroop);
    event e_incremetTroop(address indexed owner, uint256 idTroop);
    event e_deleteTroop(address indexed owner, uint256 indexed idTroop);
    event e_checkTroopBehavior(address _user);
}

contract TroopsDev8 is ITROOPS {
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////// STATE           /////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // Id count
    uint256 private s_idsCount;
    uint256 cooldownTime;
    address logicContract;
    uint256 private model;
    bool feeEvent;
    bool ammunitionEvent;

    // ERC20 Utility Token Address
    address private ERC20_ADDRESS;

    // ERC721 NFTs Token Address
    address private ERC721_ADDRESS_OLD;
    address private ERC721_ADDRESS_NEW;

    // Rewards Cotract Address
    address private REWARDS_ADDRESS;

    //owner
    address private proxyDelegate;

    //Oracler
    IPANCAKEFACTORY private FACTORY;
    IPANCAKEROUTER private ROUTER;
    AggregatorV3Interface private PRICE_FEED;

    //Array of troops
    Troop[] private troops;

    /////////////////////////////////////////////////////////////////////////////////////////////
    ///////// Mapping
    /////////////////////////////////////////////////////////////////////////////////////////////

    // Id troop => troops position (array)
    mapping(uint256 => uint256) private s_infoTroops;

    // Id troop => bool
    mapping(uint256 => bool) private s_activeTroops;

    // Id nft => Id troop
    mapping(uint256 => uint256) private s_nftsTroops;

    // Id troop =>  Id NFT (array)
    mapping(uint256 => uint256[]) private s_troopsNfts;

    // Addess user => Id troops (array)
    mapping(address => uint256[]) private s_ownerTroops;

    // Address user => Number troops active (array)
    mapping(address => uint256) private s_numbers_activeTroops;

    //Address to owner
    mapping(uint256 => address) private s_TroopOwner;

    //address to ban
    mapping(address => bool) private s_checkTroopBehavior;

    mapping (uint256 => bool) private s_freeAmmution;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    // Initializaer
    //////////////////////////////////////////////////////////////////////////////////////////////////
/*
    function initialize() external {
        s_idsCount = 90000;
        cooldownTime = 5 minutes;
        model = 1000000000000000;
        feeEvent = true;
        ERC20_ADDRESS = 0xaf63BA2eE1245aDc74Df34671cDAd97d98daA5A4;
        ERC721_ADDRESS_OLD = 0x9C8a0eeCB1c8AEefC8388bDef82717Db20F72d3b;
        ERC721_ADDRESS_NEW = 0xf3348B5E971875A4E60C745618C0fE4eF05176b5;
        REWARDS_ADDRESS = 0xBb61985Ac6eb49b70fc5ec0567650315275F635B;
        proxyDelegate = msg.sender;
        FACTORY = IPANCAKEFACTORY(0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc);
        ROUTER = IPANCAKEROUTER(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        PRICE_FEED = AggregatorV3Interface(
            0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
        );
    }
    */

    ////////////////////////////////////////////////////////////////////
    //////////////// M O D I F I E R S /////////////////////////////////
    ////////////////////////////////////////////////////////////////////

    modifier proxyCaller() {
        require(
            msg.sender == proxyDelegate,
            "proxyDelegate verification failed"
        );
        _;
    }

    function setRewardsLogicContract(address _address) external proxyCaller {
        logicContract = _address;
    }

    function setDataCooldown(uint256 _time) external proxyCaller {
        cooldownTime = _time;
    }

    function setModel(uint256 _newModel) external proxyCaller {
        model = _newModel;
    }

    function setFeeEvent(bool choice) public proxyCaller returns (bool) {
        if (choice == true) {
            feeEvent = true;
        } else {
            feeEvent = false;
        }
        return feeEvent;
    }

          function setCheckTroop(address _user) external proxyCaller {
        require(!s_checkTroopBehavior[_user], "user already blacklisted ");
        s_checkTroopBehavior[_user] = true;
        emit e_checkTroopBehavior(_user);
    }

        function setWhitelist(address _user) external proxyCaller {
        require(s_checkTroopBehavior[_user], "user dont blacklisted ");
        s_checkTroopBehavior[_user] = false;
        emit e_checkTroopBehavior(_user);
    }

    function setAmmunitionEvent (bool choice) external proxyCaller returns (bool){
        ammunitionEvent = choice;
        return ammunitionEvent;
    }

     function checkOut() external proxyCaller {
        uint256 amount = address(this).balance;
        payable(msg.sender).transfer(amount);
        
    }


    function updateLastTimeAttack(uint256 p_idTroop) public returns (bool) {
        require(
            msg.sender == logicContract,
            "only the logicContract can call this function"
        );
        troops[s_infoTroops[p_idTroop]].readyTime = uint256(
            block.timestamp + cooldownTime
        );

        troops[s_infoTroops[p_idTroop]].ammunition -= 1;

        /*
        uint256 position = getChestPosition(p_nftId);
        chestPresales[position].isOpen = true;
        */
        return true;
    }

    function setNewTroopAddress (address _address) external proxyCaller returns (bool){
        ERC721_ADDRESS_NEW = _address;
        return true;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////  PUBLIC FUNCTIONS      ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // Wallet => Returns number (active troops)
    function numberActiveTroop(address p_owner) public view returns (uint256) {
        return s_numbers_activeTroops[p_owner];
    }

    // Get info troop and state
    function troop(uint256 p_idTroop) public view returns (Troop memory, bool) {
        return (troops[s_infoTroops[p_idTroop]], s_activeTroops[p_idTroop]);
    }

    // ID Troop => Returns IDs nfts
    function idsNftsTroop(uint256 p_idTroop)
        public
        view
        returns (uint256[] memory)
    {
        return s_troopsNfts[p_idTroop];
    }

    // ID Nft => Returns ID Troop
    function idTroopNft(uint256 p_idNft) public view returns (uint256) {
        return s_nftsTroops[p_idNft];
    }

    // Wallet => Returns IDs troops
    function idTroops(address p_owner) public view returns (uint256[] memory) {
        return s_ownerTroops[p_owner];
    }

    // ID TROOP OWNER
    function idTroopsOwner(uint256 p_idTroop) public view returns (address) {
        return s_TroopOwner[p_idTroop];
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////MAIN FUNCTIONS  //////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////

    // Get price to create troop
    function priceCreateTroop(uint256[] memory p_nftsIds, uint8 p_ammunition)
        public
        view
        returns (uint256)
    {
        require(
            s_numbers_activeTroops[msg.sender] <= 30 && p_nftsIds.length <= 21,
            "the user has the maximum number of troops or characters for this troop"
        );

        require(
            p_ammunition == 0 ||
                p_ammunition == 7 ||
                p_ammunition == 15 ||
                p_ammunition == 30,
            "Not wrong ammunition data"
        );

         _repeated(p_nftsIds);

        uint256 cost;
        if (p_ammunition > 0) {
            cost = _ammunition(p_nftsIds, p_ammunition);
        }
        // How many Dollars for a 1 BNB without decimals
        uint256 BNB_USD_Price = _getBNBPrice() / 10**8;
        // How many BNB for a 1 ERC20 Token
        uint256 ERC20_BNB_Price = _getERC20Price();
        // how many bnb
        uint256 amountBNB = (cost * 1 ether) / BNB_USD_Price;
        if (feeEvent == true) {
            amountBNB =
                ((cost * 1 ether) + ((_feeBuilt(p_nftsIds) * 1 ether) / 2)) /
                BNB_USD_Price;
            //result
        }
        uint256 amountERC20 = (amountBNB * 1 ether) / ERC20_BNB_Price;
        return amountERC20;
    }

    // Create troop
    function createTroop(
        uint256[] memory p_nftsIds,
        uint8 p_ammunition,
        string memory p_name
    ) public payable returns (bool) {
        require(
            s_numbers_activeTroops[msg.sender] <= 30 && p_nftsIds.length <= 20,
            "the user has the maximum number of troops or characters for this troop"
        );

        require(
            p_ammunition == 0 ||
                p_ammunition == 7 ||
                p_ammunition == 15 ||
                p_ammunition == 30,
            "wrong ammunition data"
        );
        require(msg.value >= businessModel(), "out of gas");
           _repeated(p_nftsIds);
        s_idsCount++;
 
        uint256 power;
        for (uint256 i = 0; i < p_nftsIds.length; i++) {
            require(_ownerNftId(p_nftsIds[i]) == msg.sender, "nft owner error");
           
            power += _powerNft(p_nftsIds[i]);

            s_troopsNfts[s_idsCount].push(p_nftsIds[i]);
            s_nftsTroops[p_nftsIds[i]] = s_idsCount;
            s_TroopOwner[s_idsCount] = msg.sender;
        }
        require(power >= 300, "you don't have enough power to create troops");
        uint256 cost;
        if (p_ammunition > 0) {
            cost = _ammunition(p_nftsIds, p_ammunition);
        }
        // How many Dollars for a 1 BNB without decimals
        uint256 BNB_USD_Price = _getBNBPrice() / 10**8;
        // How many BNB for a 1 ERC20 Token
        uint256 ERC20_BNB_Price = _getERC20Price();
        // how many bnb
        uint256 amountBNB = (cost * 1 ether) / BNB_USD_Price;

        if (feeEvent == true) {
            amountBNB =
                ((cost * 1 ether) + ((_feeBuilt(p_nftsIds) * 1 ether) / 2)) /
                BNB_USD_Price;
        }

        //result
        uint256 amountERC20 = (amountBNB * 1 ether) / ERC20_BNB_Price;

        IERC20(ERC20_ADDRESS).transferFrom(
            msg.sender,
            REWARDS_ADDRESS,
            amountERC20
        );

        _transferNft(p_nftsIds);
        troops.push(
            Troop(s_idsCount, power, p_ammunition, p_name, block.timestamp)
        );
        s_infoTroops[s_idsCount] = troops.length - 1;

        bool checkFor;

        for (uint256 i = 0; i < s_ownerTroops[msg.sender].length; i++) {
            if (s_ownerTroops[msg.sender][i] == 0) {
                s_ownerTroops[msg.sender][i] = s_idsCount;
                checkFor = true;
                break;
            }
        }
        if (!checkFor) {
            s_ownerTroops[msg.sender].push(s_idsCount);
        }

        s_activeTroops[s_idsCount] = true;
        s_numbers_activeTroops[msg.sender]++;

        if(p_ammunition > 0){
        s_freeAmmution[s_idsCount] = true;
        }

        emit e_newTroop(msg.sender, s_idsCount);

        return true;
    }

    ///////////////////////////////function to increment ammunition to exist troop///////////////////
    function incrementAmmunition(uint256 p_idTroop, uint8 p_ammunition)
        public
        payable
        returns (bool)
    {
        require(
            p_ammunition == 7 || p_ammunition == 15 || p_ammunition == 30,
            "wrong ammunition data"
        );
        require(msg.value == businessModel(), "out of gas");

        uint256 cost = _ammunitionIncrementCost(p_ammunition,p_idTroop);

       

        IERC20(ERC20_ADDRESS).transferFrom(
            msg.sender,
            REWARDS_ADDRESS,
            cost
        );

        (troops[s_infoTroops[p_idTroop]].ammunition * 1 days); //10  10 0

        //este el caso en que aun tienes dias de municion y quieres agregar mas
        if (troops[s_infoTroops[p_idTroop]].ammunition > 0) {
            troops[s_infoTroops[p_idTroop]].ammunition += p_ammunition;

            // cuando no tiene municion disponible [45, 30/11, ]
        } else {
            troops[s_infoTroops[p_idTroop]].ammunition = p_ammunition;
           
        }

         if(p_ammunition > 0){
        s_freeAmmution[s_idsCount] = true;
        }

        //crear evento de incremento de munuicion
        emit e_incremetTroop(msg.sender, p_idTroop);
        return true;
    }

     function priceIncrementTroop(uint256 p_idTroop, uint256[] memory p_nftsIds)
        public
        view
        returns (uint256)
    {
        require(s_activeTroops[p_idTroop], "Not allowed firts");

        require(
            (s_troopsNfts[s_idsCount].length + p_nftsIds.length) < 21,
            "Not allowed"
        );

        _repeated(p_nftsIds);
         
         require(troops[s_infoTroops[p_idTroop]].ammunition > 0,"No ammunition time avaliable");
        // How many Dollars for a 1 BNB without decimals
        uint256 BNB_USD_Price = _getBNBPrice() / 10**8;
        // How many BNB for a 1 ERC20 Token
        uint256 ERC20_BNB_Price = _getERC20Price();

        uint256 amountBNB = ((p_nftsIds.length * troops[s_infoTroops[p_idTroop]].ammunition) * 1 ether) /
            BNB_USD_Price;
        return (((amountBNB * 1 ether) / ERC20_BNB_Price) / 100) * 70;
   
    }


     function incrementTroop(uint256 p_idTroop, uint256[] memory p_nftsIds)
        public payable
        
        returns (bool)
    {
        require(s_activeTroops[p_idTroop], "Not allowed");

        require(
            (s_troopsNfts[s_idsCount].length + p_nftsIds.length) < 21,
            "Not allowed"
        );
        require(msg.value >= businessModel(), "out of gas");

        uint256 position = _infoPositionTroopOwner(p_idTroop);
        require(position < 1000000000000, "position validation false");

  
        require(troops[s_infoTroops[p_idTroop]].ammunition > 0,"No ammunition time avaliable");

      uint256 amountERC20 = priceIncrementTroop(p_idTroop, p_nftsIds);

        IERC20(ERC20_ADDRESS).transferFrom(
            msg.sender,
            REWARDS_ADDRESS,
            amountERC20
        );

        uint256 power;
        for (uint256 i = 0; i < p_nftsIds.length; i++) {
            require(
                _ownerNftId(p_nftsIds[i]) == msg.sender,
                "Not you dont are owner"
            );

            _repeated(p_nftsIds);

    

            power += _powerNft(p_nftsIds[i]);
            s_troopsNfts[p_idTroop].push(p_nftsIds[i]);
            s_nftsTroops[p_nftsIds[i]] = p_idTroop;
        }
        _transferNft(p_nftsIds);
        troops[s_infoTroops[p_idTroop]].power += power;

        emit e_incremetTroop(msg.sender, p_idTroop);

        return true;
    }

     function deleteTroop(uint256 p_idTroop) public payable returns (bool) {
        require(!s_checkTroopBehavior[msg.sender],"your account is under investigation for improper behavior");
        require(s_activeTroops[p_idTroop], "troop was deleted");
        require(
            troops[s_infoTroops[p_idTroop]].ammunition == 0,
            "troop with active ammunition"
        );
        require(troops[s_infoTroops[p_idTroop]].readyTime <= block.timestamp, "you have attacked today, you have to wait 24 hours to dismantle this troop");
        require(msg.value >= businessModel(), "out of gas");
        uint256 position = _infoPositionTroopOwner(p_idTroop);
        require(position < 1000000000000, "position busy");

        delete s_ownerTroops[msg.sender][position];
        delete s_activeTroops[p_idTroop];

        s_numbers_activeTroops[msg.sender]--;
        _transferNftOwner(s_troopsNfts[p_idTroop]);
        emit e_deleteTroop(msg.sender, p_idTroop);

        return true;
    }






    //////////////////////////////////////////////////////////////////////////////////////////////////
    // Internal functions
    //////////////////////////////////////////////////////////////////////////////////////////////////

    // Returns fee to use
    function businessModel() internal view returns (uint256) {
        return model;
    }

    // Position to Troop
    function _infoPositionTroopOwner(uint256 p_idTroop)
        internal
        view
        returns (uint256)
    {
        for (uint256 i = 0; i < s_ownerTroops[msg.sender].length; i++) {
            if (s_ownerTroops[msg.sender][i] == p_idTroop) {
                return i;
            }
        }

        return 1000000000000;
    }

    function _ownerNftId(uint256 p_idNft) internal view returns (address) {
        if (p_idNft < 40000) {
            return IERC721II(ERC721_ADDRESS_OLD).ownerOf(p_idNft);
        } else  {
            return IERC721(ERC721_ADDRESS_NEW).ownerOf(p_idNft);
        }
    }

    function _powerNft(uint256 p_idNft) internal view returns (uint256) {
        if (p_idNft < 40000) {
            return IERC721II(ERC721_ADDRESS_OLD).power(p_idNft);
        } else {
            return IERC721(ERC721_ADDRESS_NEW).power(p_idNft);
        }
    }

    // Ammunition
    function _ammunition(uint256[] memory p_nftsIds, uint8 p_ammunition)
        public
        view
        returns (uint256)
    {
        uint256 amount;

        if (p_ammunition == 7) {
            if(ammunitionEvent == true){
                amount = 0;
            }else{
            amount = 5 * p_nftsIds.length;
            }
        }

        if (p_ammunition == 15) {
            amount = 7 * p_nftsIds.length;
        }

        if (p_ammunition == 30) {
            amount = 12 * p_nftsIds.length;
        }

        return amount;
    }
  function _ammunitionIncrementCost(uint8 p_ammunition,uint256 p_idTroop)
        public
        view
        returns (uint256)
    {
        uint256 cost;
       uint256 [] memory p_nftsIds = s_troopsNfts[p_idTroop];

        if (p_ammunition == 7) {
            if(ammunitionEvent == true && s_freeAmmution[p_idTroop] == true ){
                cost = 5 * p_nftsIds.length;
            }else{
           cost= 0;
            }
        }

        if (p_ammunition == 15) {
            cost = 7 * p_nftsIds.length;
        }

        if (p_ammunition == 30) {
            cost = 12 * p_nftsIds.length;
        }
          
           // How many Dollars for a 1 BNB without decimals
        uint256 BNB_USD_Price = _getBNBPrice() / 10**8;
        // How many BNB for a 1 ERC20 Token
        uint256 ERC20_BNB_Price = _getERC20Price();
        // how many bnb
        uint256 amountBNB = (cost * 1 ether) / BNB_USD_Price;
        //result
        uint256 amountERC20 = (amountBNB * 1 ether) / ERC20_BNB_Price;
        
        return amountERC20;

    }


    function _feeBuilt(uint256[] memory p_nftsIds)
        public
        pure
        returns (uint256)
    {
        uint256 amount;
        for (uint256 i = 0; i < p_nftsIds.length; i++) {
            amount += 1;
        }

        return amount;
    }

    function _transferNft(uint256[] memory p_nftsIds) internal {
        for (uint256 i = 0; i < p_nftsIds.length; i++) {
            require(_ownerNftId(p_nftsIds[i]) == msg.sender, "nft owner error");
            if (p_nftsIds[i] < 40000) {
                IERC721II(ERC721_ADDRESS_OLD).transferFrom(
                    msg.sender,
                    address(this),
                    p_nftsIds[i]
                );
            } else {
                IERC721(ERC721_ADDRESS_NEW).transferFrom(
                    msg.sender,
                    address(this),
                    p_nftsIds[i]
                );
            }
        }
    }

    function _transferNftOwner(uint256[] memory p_nftsIds) internal {
        for (uint256 i = 0; i < p_nftsIds.length; i++) {
            require(
                s_TroopOwner[s_nftsTroops[p_nftsIds[i]]] == msg.sender,
                "nft owner error"
            );
            if (p_nftsIds[i] < 40000) {
                IERC721II(ERC721_ADDRESS_OLD).transferFrom(
                    address(this),
                    msg.sender,
                    p_nftsIds[i]
                );
            } else {
                IERC721(ERC721_ADDRESS_NEW).transferFrom(
                    address(this),
                    msg.sender,
                    p_nftsIds[i]
                );
            }
        }
    }

    // Repeated ids
    function _repeated(uint256[] memory p_nftsIds) internal pure {
        for (uint256 i = 0; i < p_nftsIds.length; i++) {
            uint256 id = p_nftsIds[i];
            uint256 pos = i;
            for (uint256 x = 0; x < p_nftsIds.length; x++) {
                if (id == p_nftsIds[x] && x != pos) {
                    revert("Error, nft repeated");
                }
            }
        }
    }

    // Returns the latest price BNB / USD
    // Returns how many Dollars for a 1 BNB
    function _getBNBPrice() internal view returns (uint256) {
        (, int256 price, , , ) = PRICE_FEED.latestRoundData();

        return uint256(price);
    }

    // Returns the latest price Utility Token (ERC20) / BNB
    function _getERC20Price() internal view returns (uint256) {
        IPANCAKERPAIR pair = IPANCAKERPAIR(
            FACTORY.getPair(ERC20_ADDRESS, ROUTER.WETH())
        ); // [ERC20,BNB]

        (uint256 Res0, uint256 Res1, ) = pair.getReserves();

        if (ERC20_ADDRESS < ROUTER.WETH()) {
            uint256 res1 = Res1 * 1 ether;
            // return amount of BNB needed to buy 1 Token ERC20
            return (res1 / Res0);
        } else {
            uint256 res0 = Res0 * 1 ether;
            // return amount of BNB needed to buy 1 Token ERC20
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