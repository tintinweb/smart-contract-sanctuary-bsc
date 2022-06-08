//Contract based on https://docs.openzeppelin.com/contracts/3.x/erc721
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./auth.sol";

interface ITeazeNFT {
    function tokenURI(uint256 tokenId) external view returns (string memory); 
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function mint(address _recipient, string memory _uri, uint _packNFTid) external returns (uint256); 
}

interface Inserter {
    function makeActive() external; 
    function getNonce() external view returns (uint256);
    function getRandMod(uint256 _extNonce, uint256 _modifier, uint256 _modulous) external view returns (uint256);
}

contract TeazePacks is Ownable, Authorizable, Whitelisted, ReentrancyGuard {
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    Counters.Counter public _PackIds; //so we can track which Packs have been added to the system
    Counters.Counter public _NFTIds; //so we can track which NFT's have been added to the Packs
    Counters.Counter public _LootBoxIds; //so we can track amount of lootboxes in creation
    Counters.Counter public unclaimedBoxes; //so we can limit the amount of active unclaimed lootboxes
    Counters.Counter public claimedBoxes; //so we can track the total amount of claimed lootboxes

    struct PackInfo { //creator, name, id, price, priceStep, sbxprice, mintLimit, reedeemable, purchasable, exists
        address packCreatorAddress; //wallet address of the Pack creator
        string collectionName; // Name of nft creator/influencer/artist
        uint256 packID; //ID of the pack
        uint256 price; //BNB minting price of the NFT Pack
        uint256 priceStep; //how much the price of the NFT should increase in BNB
        uint256 sbxprice; //SimpBux price of minting from the NFT Pack
        uint256 mintLimit; //total amount of this NFT to mint
        bool redeemable; //can be purchased with SimpBux
        bool purchasable; //can be purchased with BNB tokens
        bool exists;
    }

    struct NFTInfo {
        address nftCreatorAddress; //wallet address of the Pack creator
        string nftName; // Name of the actual NFT artwork
        string uri; //address of NFT metadata
        uint256 packID; //ID of the 3 card pack
        uint256 mintClass; //0 = common, 1 = uncommon, 2 = rare
        uint256 mintPercent; //percent chance out of 100 for the NFT to mint
        bool lootboxable; //can be added to lootbox
        bool exists;
    }

    struct LootboxInfo {
        uint256 rollNumber; //number needed to claim reward
        uint256 rewardAmount; //amount of BNB in lootbox
        uint256 collectionArray; //array of NFT id's needed to claim
        uint256 percentTotal; //total percent of combined NFT mintPercent
        uint256 mintclassTotal; //total mintclass (higher mintclass = higher bnb reward)
        address claimedBy; //address that unlocked the lootbox
        bool claimed; //unclaimed = false, claimed = true
    }

    mapping (string => bool) private collections; //Whether the collection name exists or not.
    mapping (string => bool) private nftnames; //Whether the collection name exists or not.
    mapping (uint => bool) private packs; //Whether the packID exists or not.
    mapping(uint256 => PackInfo) public packInfo; // Info of each NFT artist/infuencer wallet.
    mapping(uint256 => NFTInfo) public nftInfo; // Info of each NFT artist/infuencer wallet.
    mapping(uint256 => LootboxInfo) public lootboxInfo; // Info of each lootbox.
    uint256[] public activelootboxarray; //Array to store each active lootbox id so we can view.
    uint256[] private inactivelootboxarray; //Array to store each active lootbox id so we can view.
    mapping(uint => uint256[]) public PackNFTids; // array of NFT ID's listed under each pack.
    mapping(uint256 => uint256[]) public LootboxNFTids; // array of NFT ID's listed under each lootbox.
    mapping (uint256 => bool) public claimed; //Whether the nft tokenID has been used to claim a lootbox or not.
    mapping(uint => uint256) public PackNFTmints; //number of NFT minted from a certain pack.
    mapping(address => mapping(uint => uint)) public userPackPurchased; //How many of each pack a certain address has minted.
    mapping(string => bool) private NFTuriExists;  // Get total # minted by URI.
    mapping(uint256 => uint) private NFTmintedCountID; // Get total # minted by NFTID.

    Inserter public inserter;
    address public nftContract; // Address of the associated farming contract.
    address public farmingContract; // Address of the associated farming contract.
    uint256 private heldAmount = 0; //Variable to determine how much BNB is in the contract not allocated to a lootbox
    uint256 public maxRewardAmount = 300000000000000006; //Maximum reward of a lootbox (simpcrate)
    uint256 public rewardPerClass = 33333333333333334; //Amount each class # adds to reward (maxRewardAmount / nftPerLootBox)
    uint256 public nftPerLootbox = 3;
    uint256 public lootboxdogMax = 90; //Maximum roll the lootbox will require to unlock it
    uint256 private randNonce;
    uint256 public rollFee = 0.001 ether; //Fee the contract takes for each attempt at opening the lootbox once the user has the NFTs
    uint256 public unclaimedLimiter = 30; //Sets total number of unclaimed lootboxes that can be active at any given time
    bool public boxesEnabled = true;

    constructor(address _nftContract, address _farmingContract, address _inserter) {
        nftContract = _nftContract;
        farmingContract = _farmingContract;
        inserter = Inserter(_inserter);
        randNonce = inserter.getNonce();
        inserter.makeActive();
        addWhitelisted(owner());
    }

    receive() external payable {}

    function premint(address _recipient, uint256 _packid) public nonReentrant returns (uint256) {

        randNonce++;

        uint256 nftbalance = IERC721(nftContract).balanceOf(_recipient);
        require(nftbalance <= 100, "E01");

        require(address(farmingContract) != address(0), "E02");
        require(msg.sender == address(farmingContract), "E03");

        PackInfo storage packinfo = packInfo[_packid];

        require(PackNFTmints[_packid] < packinfo.mintLimit, "E04");

        //Randomizing mint starts here
        uint packlength = PackNFTids[_packid].length;

        uint count = 0;

        require(packlength >= 3, "E05");

        uint256 roll = inserter.getRandMod(randNonce, _packid, 100); //get user roll 0-99
        
        uint256[] memory array = new uint256[](100); //create array from 0-99

        for (uint256 x = 0; x < packlength; ++x) { //for each NFTID in the pack

            NFTInfo memory tempnftinfo = nftInfo[PackNFTids[_packid][x]]; //should be NFT info of each nft in for-loop

            for(uint256 y = 0; y < tempnftinfo.mintPercent; y++) {
                array[count] = PackNFTids[_packid][x]; //populate array with # of percentage (ex. 59%, put 59 entries in the array)
                count++;
            }

        }

        for (uint256 i = 0; i < array.length; i++) { //now we take our array and scramble the contents
            uint256 n = i + uint256(keccak256(abi.encodePacked(randNonce+i, _recipient))) % (array.length - i);
            uint256 temp = array[n];
            array[n] = array[i];
            array[i] = temp;
        }

        uint256 nftid = array[roll];
        NFTInfo storage nftinfo = nftInfo[nftid];
        
        //update counters

        NFTmintedCountID[nftid] = NFTmintedCountID[nftid] + 1;

        PackNFTmints[_packid] = PackNFTmints[_packid] + 1;

        if (boxesEnabled && unclaimedBoxes.current() < unclaimedLimiter) {checkIfLootbox();}

        return ITeazeNFT(nftContract).mint(_recipient, nftinfo.uri, nftid);

    }

       //returns the balance of the erc20 token required for validation
    function checkBalance(address _token, address _holder) public view returns (uint256) {
        IERC20 token = IERC20(_token);
        return token.balanceOf(_holder);
    }
    
    function setNFTContract(address _address) public onlyAuthorized {
        nftContract = _address;
    }

    function setFarmingContract(address _address) public onlyAuthorized {
        farmingContract = _address;
    }

    function setPackInfo (string memory _collectionName, uint256 _price, uint256 _sbxprice, uint256 _priceStep, uint256 _mintLimit, bool _redeemable, bool _purchasable) public onlyWhitelisted returns (uint256) {
        require(whitelisted[_msgSender()], "E06"); 
        require(bytes(_collectionName).length > 0, "E07");
        require(!collections[_collectionName], "E08");
        if(_purchasable) {require(_price > 0, "E09");}
        if(_redeemable) {require(_sbxprice > 0, "E10");}       
        require(_priceStep >= 0, "E11");
        require(_mintLimit > 0, "E12");
                
        _PackIds.increment();

        uint256 _packid = _PackIds.current();

        PackInfo storage packinfo = packInfo[_packid];
        
        packinfo.packCreatorAddress = _msgSender();
        packinfo.collectionName = _collectionName;
        packinfo.packID = _packid;
        packinfo.price = _price;
        packinfo.sbxprice = _sbxprice;
        packinfo.priceStep = _priceStep;
        packinfo.mintLimit = _mintLimit;
        packinfo.redeemable = _redeemable; //whether pack can be opened with SBX
        packinfo.purchasable = _purchasable; //whether the pack can be opened with BNB
        packinfo.exists = true;

        packs[_packid] = true;
        collections[_collectionName] = true;
        
        return _packid;
    }

    
    //NFT's get added to a pack # along with mint class (for the lootbox ordering) and mint percentages (for the user mint chance)
    function setNFTInfo(string memory _nftName, string memory _URI, uint256 _packID, uint256 _mintPercent, bool _lootboxable) public onlyWhitelisted returns (uint256) {

        require(whitelisted[_msgSender()], "E06"); 
        require(bytes(_nftName).length > 0, "E07");
        require(!nftnames[_nftName], "E08");
        require(bytes(_URI).length > 0, "E13");
        require(_packID > 0, "E14");
        require(packs[_packID], "E14");
        require(_mintPercent > 0, "E15");
        require(!NFTuriExists[_URI], "E16");

        (,,uint256 percentTotal) = getAllNFTbyPack(_packID);

        require(percentTotal.add(_mintPercent) <= 100,"E17");

        _NFTIds.increment();

        uint256 _nftid = _NFTIds.current();

        NFTInfo storage nftinfo = nftInfo[_nftid];

           nftinfo.nftCreatorAddress = _msgSender();
           nftinfo.nftName = _nftName;  
           nftinfo.uri = _URI;
           nftinfo.packID = _packID;
           if (_mintPercent < 25) { nftinfo.mintClass = 3;}
           if (_mintPercent >= 25 && _mintPercent < 50) { nftinfo.mintClass = 2;}
           if (_mintPercent >= 50 && _mintPercent <= 100) { nftinfo.mintClass = 1;}
           nftinfo.mintPercent = _mintPercent;
           nftinfo.lootboxable = _lootboxable; //Whether this NFT can be added to a lootbox
           nftinfo.exists = true;

            NFTuriExists[_URI] = true;
            nftnames[_nftName] = true;

            //To Do: if this NFT is inserted into the wrong pack, provide function that deletes from current pack and adds to correct pack

            PackNFTids[_packID].push(_nftid);

        return  _nftid; 

    }

    // Get the current NFT counter
    function getCurrentNFTID() public view returns (uint256) {
        return _NFTIds.current();
    }

    // Get all NFT IDs added to a pack, and return the mint percentage total
    function getAllNFTbyPack(uint256 _packid) public view returns (uint256[] memory, string[] memory, uint256) {

        uint packlength = PackNFTids[_packid].length;

        uint256[] memory ids = new uint256[](packlength);
        string[] memory name = new string[](packlength);
        uint256 count = 0;
        uint256 percentTotal = 0;

        for (uint256 x = 0; x < packlength; ++x) {          

            NFTInfo storage nftinfo = nftInfo[PackNFTids[_packid][x]];
            ids[count] = PackNFTids[_packid][x];
            name[count] = nftinfo.nftName;
            percentTotal = percentTotal.add(nftinfo.mintPercent);
            count = count+1;
           
        }

        return (ids,name,percentTotal);
    }
    
    //Returns the name of all packs or collections
    function getAllCollectionNames() public view returns (uint256[] memory, string[] memory) {

        uint256 totalPacks = _PackIds.current();
        uint256[] memory ids = new uint256[](totalPacks);
        string[] memory name = new string[](totalPacks);
        uint256 count = 0;

        for (uint256 x = 1; x <= totalPacks; ++x) {

            PackInfo storage packinfo = packInfo[x];

            if (bytes(packinfo.collectionName).length > 0) {
                ids[count] = x;
                name[count] = packinfo.collectionName;
                count++;
            }

        }

        return (ids,name);
    }

    function deletePack(uint256 _packid) external onlyWhitelisted {// to do: add switch for packs to

        PackInfo storage packinfo = packInfo[_packid];
        PackInfo storage packinfocopy = packInfo[_PackIds.current()];

        require(packinfo.packCreatorAddress == address(_msgSender()) || authorized[_msgSender()], "Sender is not creator or authorized");  

        //creator, name, id, price, priceStep, sbxprice, mintLimit, reedeemable, purchaseable, exists  

        collections[packinfo.collectionName] = false;

        packinfo.packCreatorAddress = packinfocopy.packCreatorAddress;
        packinfo.collectionName = packinfocopy.collectionName;
        packinfo.packID = packinfocopy.packID;
        packinfo.price = packinfocopy.price;
        packinfo.priceStep = packinfocopy.priceStep;
        packinfo.sbxprice = packinfocopy.sbxprice;
        packinfo.mintLimit = packinfocopy.mintLimit;
        packinfo.redeemable = packinfocopy.redeemable;
        packinfo.purchasable = packinfocopy.purchasable;
        packinfo.exists = true;    

        packinfocopy.packCreatorAddress = address(0);
        packinfocopy.collectionName = "";
        packinfocopy.packID = 0;
        packinfocopy.price = 0;
        packinfocopy.priceStep = 0;
        packinfocopy.sbxprice = 0;
        packinfocopy.mintLimit = 0;
        packinfocopy.redeemable = false;
        packinfocopy.purchasable = false;
        packinfocopy.exists = false;    

        _PackIds.decrement();

        assignAllNFTtoPack(_packid,0,false);

    }

    function assignAllNFTtoPack(uint256 _packIDfrom, uint256 _packIDto, bool _lootboxable) internal returns (bool) {

        require(packs[_packIDfrom], "E18");
        require(packs[_packIDto], "E19");

        uint packfromlength = PackNFTids[_packIDfrom].length;

        for (uint256 x = 0; x < packfromlength; ++x) {          

            NFTInfo storage nftinfo = nftInfo[PackNFTids[_packIDfrom][x]];
            
            nftinfo.packID = _packIDto;
            nftinfo.lootboxable = _lootboxable;

            //remove all NFT in 'from' pack
            PackNFTids[_packIDfrom].pop();

            //add NFT to 'to' pack mapping, will be created if it doesn't exist
            PackNFTids[_packIDto].push(PackNFTids[_packIDfrom][x]);
           
        }

        return (true);
    }

    function reassignNFTtoPack(uint256 _nftid, uint256 _packIDfrom, uint256 _packIDto, bool _lootboxable) internal returns (bool) {

        require(packs[_packIDfrom], "E18");
        require(packs[_packIDto], "E19");

        uint packfromlength = PackNFTids[_packIDfrom].length;

        NFTInfo storage nftinfo = nftInfo[_nftid];

           for (uint256 x = 0; x < packfromlength; ++x) { //remove from old pack

               if (PackNFTids[nftinfo.packID][x] == _nftid) {

                   if(x == packfromlength-1) { //last in array, pop

                   PackNFTids[nftinfo.packID].pop();

                   } else { //copy last in array to this, then pop last

                   PackNFTids[nftinfo.packID][x] = PackNFTids[nftinfo.packID][packfromlength-1]; 
                   PackNFTids[nftinfo.packID].pop(); 

                   }

               }

           }

           nftinfo.packID = _packIDto; //add to new pack in NFT struct
           nftinfo.lootboxable = _lootboxable;
           PackNFTids[_packIDto].push(_nftid); //add NFT to pack struct

        return (true);
        
    }

    function assignAllNFTtoPackAuth(uint256 _packIDfrom, uint256 _packIDto, bool _lootboxable) external onlyAuthorized returns (bool) {
       return assignAllNFTtoPack(_packIDfrom,_packIDto,_lootboxable);
    }

    
    // Set creator address to new, or set to 0 address to clear out the NFT completely
    function deleteNFT(uint256 _nftid) public onlyWhitelisted {

        NFTInfo storage nftinfo = nftInfo[_nftid];
        NFTInfo storage nftinfocopy = nftInfo[_NFTIds.current()];

        require(nftinfo.nftCreatorAddress == address(_msgSender()) || authorized[_msgSender()], "Sender is not creator or authorized");  

           NFTuriExists[nftinfo.uri] = false;
           nftnames[nftinfo.nftName] = false;

           uint packfromlength = PackNFTids[nftinfo.packID].length;

           for (uint256 x = 0; x < packfromlength; ++x) {   

               if (PackNFTids[nftinfo.packID][x] == _nftid) {

                   if(x == packfromlength-1) { //last in array, pop

                   PackNFTids[nftinfo.packID].pop();

                   } else { //copy last in array to this, then pop last

                   PackNFTids[nftinfo.packID][x] = PackNFTids[nftinfo.packID][packfromlength-1]; 
                   PackNFTids[nftinfo.packID].pop(); 

                   }

               }

           }

           nftinfo.nftCreatorAddress = nftinfocopy.nftCreatorAddress;
           nftinfo.nftName = nftinfocopy.nftName;
           nftinfo.uri = nftinfocopy.uri;
           nftinfo.packID = nftinfocopy.packID;
           nftinfo.mintClass = nftinfocopy.mintClass;
           nftinfo.mintPercent = nftinfocopy.mintPercent;
           nftinfo.lootboxable = nftinfocopy.lootboxable;
           nftinfo.exists = true;

           nftinfocopy.nftCreatorAddress = address(0);
           nftinfocopy.nftName = "";
           nftinfocopy.uri = "";
           nftinfocopy.packID = 0;
           nftinfocopy.mintClass = 0;
           nftinfocopy.mintPercent = 0;
           nftinfocopy.lootboxable = false;
           nftinfocopy.exists = false;

           _NFTIds.decrement();          
       
    }

    // Set NFT name
    function setNFTName(uint256 _nftid, string memory _name) external onlyAuthorized {

        NFTInfo storage nftinfo = nftInfo[_nftid];

        require(bytes(_name).length > 0, "E07");    

       nftinfo.nftName = _name;
    }

    // Get NFT URI string
    function getNFTURI(uint256 _nftid) public view returns (string memory) {
        NFTInfo storage nftinfo = nftInfo[_nftid];
        return nftinfo.uri;
    }

    // Set NFT URI string
    function setNFTUri(uint256 _nftid, string memory _uri) external onlyAuthorized {

        NFTInfo storage nftinfo = nftInfo[_nftid];

        require(nftinfo.nftCreatorAddress == address(_msgSender()) || authorized[_msgSender()], "Sender is not creator or authorized");  
        require(bytes(_uri).length > 0, "E13");     
        require(!NFTuriExists[_uri], "E16"); 

        NFTuriExists[nftinfo.uri] = false;

       nftinfo.uri = _uri;

        NFTuriExists[_uri] = true;
    }
    

    // Get pack info
    function getPackInfo(uint256 _packid) public view returns (uint256,uint256,uint256,uint256,bool,bool) {
        PackInfo storage packinfo = packInfo[_packid];
        return (packinfo.price,packinfo.priceStep,packinfo.sbxprice,packinfo.mintLimit,packinfo.redeemable,packinfo.purchasable);

    }
    
    function packExists(uint256 _packid) external view returns (bool) {
        
        return packs[_packid];
    }

    function nftExists(uint256 _nftid) external view returns (bool) {
        NFTInfo storage nftinfo = nftInfo[_nftid];
        return nftinfo.exists;
    }

    // This will allow to rescue ETH sent by mistake directly to the contract
    function rescueETHFromContract() external onlyOwner {
        address payable _owner = payable(_msgSender());
        _owner.transfer(address(this).balance);
    }

    // Function to allow admin to claim *other* ERC20 tokens sent to this contract (by mistake)
    function transferERC20Tokens(address _tokenAddr, address _to, uint _amount) public onlyOwner {
       
        IERC20(_tokenAddr).transfer(_to, _amount);
    }

    function getIDbyURI(string memory _uri) public view returns (uint256) {
        uint256 totalNFT = _NFTIds.current();
        uint256 nftID = 0;

        for (uint256 x = 1; x <= totalNFT; ++x) {

            NFTInfo storage nftinfo = nftInfo[x];

            if (keccak256(bytes(nftinfo.uri)) == keccak256(bytes(_uri))) {   
                nftID = x;
            }

        }

        return nftID;
    }

    function getPackIDbyNFT(uint256 _nftid) external view returns (uint256) {

        NFTInfo storage nftinfo = nftInfo[_nftid];
        return nftinfo.packID;

    }

    function packPurchased(address _recipient, uint256 _packid) external {

        require(msg.sender == address(farmingContract), "E20");

        userPackPurchased[_recipient][_packid] = userPackPurchased[_recipient][_packid] + 1;
    }

    
    // Set cost of opening a pack
    function setPackPrice(uint256 _packid, uint256 _price, uint _priceStep, uint256 _sbxprice) public onlyAuthorized {

         require(packs[_packid], "E14");

        PackInfo storage packinfo = packInfo[_packid];

        require(_price > 0, "E09");
        require(_sbxprice > 0, "E10");

       packinfo.price = _price;
       packinfo.priceStep = _priceStep;
       packinfo.sbxprice = _sbxprice;
    }

    

    // Set NFT redeemable with SimpBux
    function setPackRedeemable(uint256 _packid, bool _redeemable) public onlyAuthorized {

         require(packs[_packid], "E14");

        PackInfo storage packinfo = packInfo[_packid];

       packinfo.redeemable = _redeemable;
    }

    

    // Set Pack purchasable with BNB tokens
    function setPackPurchasable(uint256 _packid, bool _purchasable) public onlyAuthorized {

        require(packs[_packid], "E14");

        PackInfo storage packinfo = packInfo[_packid];

       packinfo.purchasable = _purchasable;
    }

    

    // Set Pack mint limit
    function setPackMintLimit(uint256 _packid, uint256 _limit) public onlyAuthorized {

        require(packs[_packid], "E14");

        PackInfo storage packinfo = packInfo[_packid];

        require(_limit > 0, "E12");

       packinfo.mintLimit = _limit;
    }


    function getPackTotalMints(uint256 _packid) external view returns (uint256) {
        return PackNFTmints[_packid];
    }

    function getUserPackPurchased(address _recipient, uint256 _packid) public view returns (uint256) {
        return userPackPurchased[_recipient][_packid];
    }

    function getUserPackPrice(address _recipient, uint256 _packid) external view returns (uint256) {

        uint256 purchases = getUserPackPurchased(_recipient, _packid);

        (uint256 price,uint256 priceStep,,,,) = getPackInfo(_packid);
             
        uint256 userPrice = price.add(purchases.mul(priceStep));

        return userPrice;
    }

    function checkIfLootbox() public {

        uint256 nftids = _NFTIds.current();
        //if (heldAmount.add(maxRewardAmount) <= address(this).balance && nftids > 0) {
        if (true) {
            //create lootbox

            randNonce++;

            _LootBoxIds.increment();

            uint256 lootboxid = _LootBoxIds.current();

            uint256 mintclassTotals = 0;
            uint256 percentTotals = 0;
            
            uint256 nftroll = 0;
            
            
            for (uint256 x = 1; x <= nftPerLootbox; ++x) {

                nftroll = inserter.getRandMod(randNonce, x, nftids.mul(100)); //get a random nft
                nftroll = nftroll+100;
                nftroll = nftroll.div(100);

                LootboxNFTids[lootboxid].push(nftroll);

                NFTInfo storage nftinfo = nftInfo[nftroll];

                mintclassTotals = mintclassTotals.add(nftinfo.mintClass);
                percentTotals = percentTotals.add(nftinfo.mintPercent);
                
            }                  

            uint256 boxreward = rewardPerClass.mul(mintclassTotals);

            uint256 boxroll = inserter.getRandMod(randNonce, uint8(uint256(keccak256(abi.encodePacked(block.timestamp)))%100), lootboxdogMax); //get box roll 0-89
            boxroll = boxroll+1; //normalize

            LootboxInfo storage lootboxinfo = lootboxInfo[lootboxid];

            lootboxinfo.rollNumber = boxroll;
            lootboxinfo.collectionArray = lootboxid;
            lootboxinfo.mintclassTotal = mintclassTotals;
            lootboxinfo.percentTotal = percentTotals;
            lootboxinfo.rewardAmount = boxreward;
            lootboxinfo.claimedBy = address(0);
            lootboxinfo.claimed = false;
             

            //update heldAmount
            heldAmount = heldAmount.add(boxreward);

            unclaimedBoxes.increment();

            activelootboxarray.push(lootboxid); //add lootboxid to loopable array for view function
            
        }
    }

    function ClaimLootbox(uint256 _lootboxid) external payable nonReentrant returns (bool winner, bool used, uint256 roll, uint256 dogroll) {

        LootboxInfo storage lootboxinfo = lootboxInfo[_lootboxid];

        require(!lootboxinfo.claimed, "E21");
        require(msg.value == rollFee, "E22");

        //check wallet against Simpcrate NFT

        uint256 lootboxlength = LootboxNFTids[_lootboxid].length;

        bool result = false;
        bool hasNFTresult = true;
        bool NFTunusedresult = false;
        uint256[] memory tokens = new uint256[](lootboxlength); //create array 
        uint256 tokentemp;
        uint256 userroll = 0;
        uint256 lootbox = _lootboxid; 

        for (uint x = 0; x < lootboxlength; x++) {

            (result,tokentemp) = checkWalletforNFT(x,_msgSender(), lootbox);
            hasNFTresult = hasNFTresult && result;
            tokens[x] = tokentemp;
            NFTunusedresult = NFTunusedresult || claimed[tokentemp];
        }

        if (hasNFTresult && !NFTunusedresult) { //user has all NFT, none have been used to obtain SimpCrate, roll to beat the dog
            userroll = inserter.getRandMod(randNonce, uint8(uint256(keccak256(abi.encodePacked(_msgSender())))%100), 100); 
            userroll = userroll+1;

            if (userroll >= lootboxinfo.rollNumber) {
                //transfer winnings to user, update struct, mark tokenIDs as ineligible for future lootboxes
                payable(_msgSender()).transfer(lootboxinfo.rewardAmount);
                heldAmount = heldAmount.sub(lootboxinfo.rewardAmount);

                for (uint256 z=0; z<tokens.length; z++) {
                    claimed[tokens[z]] = true;
                }

                lootboxinfo.claimed = true;
                lootboxinfo.claimedBy = _msgSender();

                claimedBoxes.increment();
                unclaimedBoxes.decrement();

            }
        }

        payable(this).transfer(rollFee);

        uint arraylength = activelootboxarray.length;

        //Remove packid from active array
        for(uint x = 0; x < arraylength; x++) {
            if (activelootboxarray[x] == _lootboxid) {
                activelootboxarray[x] = activelootboxarray[arraylength-1];
                activelootboxarray.pop();
            }
        }       

        //Add packid to inactive array
        inactivelootboxarray.push(_lootboxid);

        return (hasNFTresult, NFTunusedresult, userroll, lootboxinfo.rollNumber);

    }   

    function checkWalletforNFT(uint256 _position, address _holder, uint256 _lootbox) public view returns (bool nftpresent, uint256 tokenid) {

        uint256 nftbalance = IERC721(nftContract).balanceOf(_holder);
        bool result;
        uint256 token;

         for (uint256 y = 0; y < nftbalance; y++) {

             string memory boxuri = getNFTURI(LootboxNFTids[_lootbox][_position]);
             string memory holderuri = ITeazeNFT(nftContract).tokenURI(ITeazeNFT(nftContract).tokenOfOwnerByIndex(_holder, y));

            if (keccak256(bytes(boxuri)) == keccak256(bytes(holderuri))) {
                result = true;
                token = ITeazeNFT(nftContract).tokenOfOwnerByIndex(_holder, y);
            } else {
                result = false;
                token = 0;
            }

        }

        return (result, tokenid);
    }

    function checkIfWinnwer(uint256 _lootboxid, address _holder) external view returns (bool) {

        LootboxInfo storage lootboxinfo = lootboxInfo[_lootboxid];

        //check wallet against Simpcrate NFT

        uint256 lootboxlength = LootboxNFTids[_lootboxid].length;

        bool result = false;
        bool hasNFTresult = true;
        bool NFTunusedresult = false;
        uint256 tokentemp;

        for (uint x = 0; x < lootboxlength; x++) {

            (result,tokentemp) = checkWalletforNFT(x, _holder, _lootboxid);
            hasNFTresult = hasNFTresult && result;
            NFTunusedresult = NFTunusedresult || claimed[tokentemp];
        }

        if ((lootboxinfo.claimed == false) && hasNFTresult && !NFTunusedresult) {return true;} else {return false;}       

    }

    function updateRewardAmounts(uint256 _maxRewardAmount, uint256 _nftPerLootbox, bool _auth) external onlyAuthorized {

        //the larger the _maxRewardAmount the longer it will take the contract to create a lootbox
        //the more _nftPerLootbox the harder they will be to open, taking longer for users to collect the appropriate NFTs

        //we can set some limitations here or override them with _auth = true

        if (!_auth) {
            require(_maxRewardAmount < 0.5 ether, "E23");
            require(_nftPerLootbox <= 5, "E24");
        }

        maxRewardAmount = _maxRewardAmount;
        nftPerLootbox = _nftPerLootbox;

        rewardPerClass = maxRewardAmount.div(nftPerLootbox);

    }

    function changeLootboxDogMax(uint256 _dogroll) external onlyAuthorized {
        require(_dogroll >= 50, "E25");
        require(_dogroll <= 90, "E26");

        lootboxdogMax = _dogroll;
    }

    function changeRollFee(uint256 _rollFee) external onlyAuthorized {
        require(_rollFee >= 0 && _rollFee <= 0.01 ether, "E27");

        rollFee = _rollFee;
    }

    function changeUnclaimedLimiter(uint256 _limit, bool _auth) external onlyAuthorized {

        if (!_auth) {
            require(_limit <= 50, "E28");
        }

        unclaimedLimiter = _limit;
        
    }

    function viewActiveSimpCrates() external view returns (uint256[] memory lootboxes){

        return activelootboxarray;

    }

    function viewInactiveSimpCrates(uint _startingpoint, uint _length) external view returns (uint256[] memory) {

        uint256[] memory array = new uint256[](_length); 

        //Loop through the segment at the starting point
        for(uint x = 0; x < _length; x++) {
          array[x] = inactivelootboxarray[_startingpoint.add(x)];
        }   

        return array;

    }
    
    function getInactiveSimpCratesLength() external view returns (uint256) {
        return inactivelootboxarray.length;
    }

    function mintedCountbyID(uint256 _id) public view returns (uint256) {
        return NFTmintedCountID[_id];
    }
 
    function setBoxesEnabled(bool _status) external onlyAuthorized {
        boxesEnabled = _status;
    }
}

//Contract based on https://docs.openzeppelin.com/contracts/3.x/erc721
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

// Allows another user(s) to change contract variables
contract Authorizable is Ownable {

    mapping(address => bool) public authorized;

    modifier onlyAuthorized() {
        require(authorized[_msgSender()] || owner() == address(_msgSender()));
        _;
    }

    function addAuthorized(address _toAdd) onlyOwner public {
        require(_toAdd != address(0));
        authorized[_toAdd] = true;
        
    }

    function removeAuthorized(address _toRemove) onlyOwner public {
        require(_toRemove != address(0));
        require(_toRemove != address(_msgSender()));
        authorized[_toRemove] = false;
    }

}

// Allows authorized users to add creators addresses to the whitelist
contract Whitelisted is Ownable, Authorizable {

    mapping(address => bool) public whitelisted;

    modifier onlyWhitelisted() {
        require(whitelisted[_msgSender()] || authorized[_msgSender()] || owner() == address(_msgSender()));
        _;
    }

    function addWhitelisted(address _toAdd) onlyAuthorized public {
        require(_toAdd != address(0));
        whitelisted[_toAdd] = true;
    }

    function removeWhitelisted(address _toRemove) onlyAuthorized public {
        require(_toRemove != address(0));
        require(_toRemove != address(_msgSender()));
        whitelisted[_toRemove] = false;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
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