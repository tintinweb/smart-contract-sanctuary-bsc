// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "./IBEP20.sol";
import "./HeroCoreNFT.sol";
import "./HeroNFT.sol";
import "./HeroBlueprintNFT.sol";
import "./Utils.sol";
import "./HeroStruct.sol";

contract CyborgLab is HeroStruct,OwnableUpgradeable, PausableUpgradeable  {
    HeroNFT public heroNFT;
    HeroCoreNFT public heroCoreNFT;
    HeroBlueprintNFT public heroBlueprintNFT;
    IBEP20 public chip;
    IBEP20 public nova;
    Utils public utils;
    mapping(uint256 => uint256) feeNova; // [Battery Core in Hero] = [fee]
    mapping(uint256 => uint256) feeChip; // [Battery Core in Hero] = [fee]
    mapping (address => bool) public operators;

    modifier onlyOperatorOrOwner {
      require(operators[msg.sender] == true || msg.sender == owner());
      _;
    }

    function initialize() public initializer {
        feeChip[5]=1*10**18;  
        feeChip[4]=1*10**18;
        feeChip[3]=1*10**18;
        feeChip[2]=1*10**18;
        feeChip[1]=1*10**18;
        __Ownable_init();
    }

    function initByOwner(IBEP20 _chip, IBEP20 _nova, HeroNFT _heroNFT, HeroCoreNFT _heroCoreNFT, HeroBlueprintNFT _heroBlueprintNFT, Utils _utils) public  onlyOwner {
        chip = _chip;
        nova = _nova;
        heroNFT = _heroNFT;
        heroCoreNFT = _heroCoreNFT;
        heroBlueprintNFT = _heroBlueprintNFT;
         utils = _utils;
        operators[address(_heroNFT)] = true;
        operators[address(_heroCoreNFT)] = true;
        operators[address(_heroBlueprintNFT)] = true;

    }
   
    function wakeHero(uint256 _heroCoreId,uint256 _heroBlueprintId,uint256 _chipAmount) public whenNotPaused {
        (uint256 coreId,
        uint256 classHero,
        uint256 pSkill,
        uint256 coreIsDeleted) = heroCoreNFT.getHeroCorePublic(msg.sender,_heroCoreId);
        require(coreId!=0, "Not found NFT");
        require(coreIsDeleted==0, "NFT is deleted");

        (uint256 blueprintId,
        uint256 rank,
        uint256 tech,
        uint256 blueprintIsDeleted) = heroBlueprintNFT.getHeroBlueprintPublic(msg.sender,_heroBlueprintId);
        require(blueprintId!=0, "Not found NFT");
        require(blueprintIsDeleted==0, "NFT is deleted");
        Hero memory _hero = Hero(
            0,
            rank,
            classHero,
            pSkill,
            tech,
            0,
            0,
            0,
            0,
        utils.random1(1, 2),
        utils.random2(1, 2),
        utils.random3(1, 2),
        utils.random4(1, 2),
        utils.random1(1, 2),
        utils.random2(1, 2),
        utils.random3(1, 2),
        utils.random4(1, 2),
        0,
        0
        );
        heroNFT.createHero(_hero,msg.sender);
        heroCoreNFT.approveCyborgLab(address(this),coreId);
        heroCoreNFT.burn(coreId);
        heroBlueprintNFT.approveCyborgLab(address(this),blueprintId);
        heroBlueprintNFT.burn(blueprintId);
 
        require(feeChip[rank]==_chipAmount,"Not correct amount Chip");
        chip.approve(address(this), _chipAmount);
        chip.transferFrom(msg.sender, address(this),_chipAmount);
    }

    // function swapPartHero(uint256 _heroMainId,uint256 _heroMaterialId,uint256 _chipAmount) public whenNotPaused {
       
    //     Hero memory heroMain = heroNFT.getHero(msg.sender, _heroMainId);
    //     Hero memory heroMaterial = heroNFT.getHero(msg.sender,_heroMaterialId);
    //     require(heroMain.rank>=4, "Hero rank must be GE 4");
    //     require(coreIsDeleted==0, "NFT is deleted");

    //     (uint256 blueprintId,
    //     uint256 rank,
    //     uint256 tech,
    //     uint256 blueprintIsDeleted) = heroBlueprintNFT.getHeroBlueprintPublic(msg.sender,_heroBlueprintId);
    //     require(blueprintId!=0, "Not found NFT");
    //     require(blueprintIsDeleted==0, "NFT is deleted");
    //     Hero memory _hero = Hero(
    //         0,
    //         rank,
    //         classHero,
    //         pSkill,
    //         tech,
    //     utils.random1(1, 2),
    //     utils.random2(1, 2),
    //     utils.random3(1, 2),
    //     utils.random4(1, 2),
    //     utils.random1(1, 2),
    //     utils.random2(1, 2),
    //     utils.random3(1, 2),
    //     utils.random4(1, 2),
    //     0,
    //     0
    //     );
    //     heroNFT.createHero(_hero,msg.sender);
    //     heroCoreNFT.approveCyborgLab(address(this),coreId);
    //     heroCoreNFT.burn(coreId);
    //     heroBlueprintNFT.approveCyborgLab(address(this),blueprintId);
    //     heroBlueprintNFT.burn(blueprintId);
 
    //     require(feeChip[rank]==_chipAmount,"Not correct amount Chip");
    //     chip.approve(address(this), _chipAmount);
    //     chip.transferFrom(msg.sender, address(this),_chipAmount);
    // }




    function setNova(address _nova) public onlyOwner{
        nova = IBEP20(_nova);
    } 

    function setChip(address _chip) public onlyOwner{
        chip = IBEP20(_chip);
    }  

    function setHeroCore(HeroCoreNFT _heroCoreNFT) public onlyOwner{
        heroCoreNFT=_heroCoreNFT;
        operators[address(_heroCoreNFT)] = true;
    } 

    function setHero(HeroNFT _heroNFT) public onlyOwner{
        heroNFT=_heroNFT;
        operators[address(_heroNFT)] = true;
    } 

    function setHeroBlueprint(HeroBlueprintNFT _heroBlueprintNFT) public onlyOwner{
        heroBlueprintNFT=_heroBlueprintNFT;
        operators[address(_heroBlueprintNFT)] = true;
    } 
  
    function setUtils(Utils _utils) public onlyOwner{
        utils = _utils;
    } 

    function setFeeChip(uint256 _rank, uint256 _fee) public onlyOwner{
        feeChip[_rank] = _fee;
    } 

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner whenNotPaused {
       _pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused {
       _unpause();
    }

    function withdrawWith(address _tokenBEP20, uint256 _amount) external onlyOwner {
        IBEP20(_tokenBEP20).transfer(msg.sender, _amount);
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "./IBEP20.sol";
import "./HeroStruct.sol";

contract HeroBlueprintNFT is HeroStruct, ERC721Upgradeable, ERC721BurnableUpgradeable, OwnableUpgradeable, PausableUpgradeable {
    using MathUpgradeable for uint256;
    using MathUpgradeable for uint48;
    using MathUpgradeable for uint32;
    using MathUpgradeable for uint16;
    using StringsUpgradeable for uint256;
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter public _tokenIds;
    address public boxNFT;
    bool public isTransfer;
    bool public isTransferMarketPlace;
    string public baseURI;
    address public cyborgLab;
    mapping(address => mapping(uint256 => uint256)) public blueprints;// address - id - details // cach lay details = blueprints[address][heroBlueprintId]
    mapping (uint256 => address) public blueprintIndexToOwner;
    address public heroBlueprintMarketPlace;
    mapping (address => bool) public operators;

    // namely the ERC721 instances for name symbol decimals etc
    function initialize() public initializer {
        __ERC721_init("HERO BLUEPRINT NFT", "HEBN");
        isTransfer = true;
        isTransferMarketPlace = true;
       
        __Ownable_init();
    }

    modifier onlyOperatorOrOwner {
      require(operators[msg.sender] == true || msg.sender == owner());
      _;
    }


  function initByOwner(address _heroBlueprintMarketPlace, address _boxNFT,address _cyborgLab) public onlyOwner{
    heroBlueprintMarketPlace = _heroBlueprintMarketPlace;
    boxNFT = _boxNFT;
    cyborgLab = _cyborgLab;
    operators[_heroBlueprintMarketPlace] = true ;
    operators[_boxNFT] = true ;
    operators[_cyborgLab] = true ;
  }

  function createHeroBlueprint(address owner,uint256 rank,uint256 tech) public onlyOperatorOrOwner  returns (uint256) {
        _tokenIds.increment();
        uint256 newHeroBlueprintId = _tokenIds.current();
        //we can call mint from the ERC721 contract to mint our nft token
        // _safeMint(msg.sender, newHeroBlueprintId);
        _safeMint(owner, newHeroBlueprintId);
        blueprints[owner][newHeroBlueprintId] = encode(HeroBlueprint(newHeroBlueprintId,rank,tech,0));
        blueprintIndexToOwner[newHeroBlueprintId]=owner;
        return newHeroBlueprintId;
    }

  function updateHeroBlueprint(address owner,uint256 nftId, uint256 id, uint256 rank, uint256 tech,  uint256 isDeleted) public onlyOperatorOrOwner returns (uint256) {
        blueprints[owner][nftId] = encode(HeroBlueprint(id,rank,tech,isDeleted));
        return nftId;
    }


  function getHeroBlueprint(address owner, uint256 id) public view returns (HeroBlueprint memory _heroBlueprint) {
    uint256 details= blueprints[owner][id];
    _heroBlueprint.id = uint256(uint48(details>>100));
    _heroBlueprint.rank = uint256(uint8(details>>148));
    _heroBlueprint.tech = uint256(uint8(details>>156));
    _heroBlueprint.isDeleted =uint256(uint8(details>>164));
  }
  
function getHeroBlueprintPublic(address _owner, uint256 _id) public view returns (
        uint256 id,
        uint256 rank,
        uint256 tech,
        uint256 isDeleted
        ) {
    HeroBlueprint memory _heroBlueprint= getHeroBlueprint(_owner,_id);
    id=_heroBlueprint.id;
    rank = _heroBlueprint.rank;
    tech = _heroBlueprint.tech;
    isDeleted=_heroBlueprint.isDeleted;
  }

  function encode(HeroBlueprint memory heroBlueprint) public pure returns (uint256) {
  // function encode(HeroBlueprint memory heroBlueprint)  external view returns  (uint256) {
    uint256 value;
    value = uint256(heroBlueprint.id);
    value |= heroBlueprint.id << 100;
    value |= heroBlueprint.rank << 148;
    value |= heroBlueprint.tech << 156;
    value |= heroBlueprint.isDeleted << 164;
    return value;
  }


  function getHeroBlueprintOfSender(address sender) external view returns (HeroBlueprint[] memory ) {
        uint range=_tokenIds.current();
        uint i=1;
        uint index=0;
        uint x=0;
        for(i; i <= range; i++){
          HeroBlueprint memory heroBlueprint = getHeroBlueprint(sender,i);
          if(heroBlueprint.id !=0){
            index++;
          }
        }
        HeroBlueprint[] memory result = new HeroBlueprint[](index);
        i=1;
        for(i; i <= range; i++){
          HeroBlueprint memory heroBlueprint = getHeroBlueprint(sender,i);
          if(heroBlueprint.id !=0){
            result[x] = heroBlueprint;
            x++;
          }
        }
        return result;
  }

function transfer(uint256 _nftId, address _target)
        external whenNotPaused
    {
        require(isTransferMarketPlace==true, "MarketPlace Off");
        require(_exists(_nftId), "Non existed NFT");
        require(
            ownerOf(_nftId) == msg.sender || getApproved(_nftId) == msg.sender,
            "Not approved"
        );
        require(_target != address(0), "Invalid address");
        if(msg.sender != heroBlueprintMarketPlace){
          require(msg.sender != _target, "Can not transfer myself");
        }

        if(msg.sender != heroBlueprintMarketPlace &&  _target!=heroBlueprintMarketPlace){
          revert("Can not transfer outsite MarketPlace");
        }
        HeroBlueprint memory heroBlueprint= getHeroBlueprint(ownerOf(_nftId),_nftId);
       
        blueprints[_target][_nftId] = encode(heroBlueprint);
        blueprints[ownerOf(_nftId)][_nftId]= encode(HeroBlueprint(0,0,0,0));
        blueprintIndexToOwner[_nftId]=_target;
        _transfer(ownerOf(_nftId), _target, _nftId);
    }

  function transferFrom(
        address from,
        address to,
        uint256 tokenId 
    )
        public  virtual override  whenNotPaused 
    {
        
        require(_exists(tokenId ), "Non existed NFT");
        require(ownerOf(tokenId ) == from, "Only owner NFT can transfer");
        require(from != to, "Can not transfer myself");
        require(
            ownerOf(tokenId ) == msg.sender || getApproved(tokenId ) == msg.sender,
            "Not approved"
        );
        require(isTransfer == true, "Can not transfer");
        require(to != address(0), "Invalid address");

        HeroBlueprint memory heroBlueprint= getHeroBlueprint(from,tokenId );
        blueprints[to][tokenId ] = encode(heroBlueprint);
        blueprints[from][tokenId ]= encode(HeroBlueprint(0,0,0,0));
        blueprintIndexToOwner[tokenId ]=to;
        _transfer(from, to, tokenId );
    }

  function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
      
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        require(from != to, "Can not transfer myself");
        require(isTransfer == true, "Can not transfer");
        HeroBlueprint memory heroBlueprint= getHeroBlueprint(from,tokenId );
        blueprints[to][tokenId ] = encode(heroBlueprint);
        blueprints[from][tokenId ]= encode(HeroBlueprint(0,0,0,0));
        blueprintIndexToOwner[tokenId ]=to;
        _safeTransfer(from, to, tokenId, _data);
    }  

  function approveMarketPlace(address to, uint256 tokenId) external onlyOperatorOrOwner {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
         _approve(to,tokenId);
  }

function updateHeroBlueprintIndexToOwner(uint256 nftId,address owner) public onlyOwner  {
        blueprintIndexToOwner[nftId]= owner;
    }

  function setBoxNFT(address _boxNFT) public onlyOwner{
    boxNFT=_boxNFT;
    operators[boxNFT] =true;
  }  


  function setHeroBlueprintMarketPlace(address _heroBlueprintMarketPlace) public onlyOwner{
    heroBlueprintMarketPlace=_heroBlueprintMarketPlace;
    operators[_heroBlueprintMarketPlace] =true;
  }

  function setCyborgLab(address _cyborgLab) public onlyOwner{
    cyborgLab=_cyborgLab;
    operators[_cyborgLab] =true;
  }

  function setBaseURI(string memory _baseURI) public onlyOwner{
      baseURI=_baseURI;
    }  
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        address sender=ownerOf(tokenId);
        HeroBlueprint memory heroBlueprint = getHeroBlueprint(sender,tokenId);
        string memory json=".json";
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI,heroBlueprint.rank.toString(),json))  : "";
    }

    function setIsTransfer(bool _isTransfer) public onlyOwner{
    isTransfer=_isTransfer;
  }    

    function setIsTransferMarketPlace(bool _isTransferMarketPlace) public onlyOwner{
    isTransferMarketPlace=_isTransferMarketPlace;
  }   

  function approveCyborgLab(address to, uint256 tokenId) external onlyOperatorOrOwner {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        _approve(to,tokenId);
  }

    function setOperator(address operator, bool isActive) external onlyOwner {
          operators[operator] =isActive;
    }


    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner whenNotPaused {
       _pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused {
       _unpause();
    }

  function withdrawWith(address _tokenBEP20, uint256 _amount) external onlyOwner {
        IBEP20(_tokenBEP20).transfer(msg.sender, _amount);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "./IBEP20.sol";
import "./HeroStruct.sol";
contract HeroCoreNFT is HeroStruct,ERC721Upgradeable, ERC721BurnableUpgradeable, OwnableUpgradeable, PausableUpgradeable {
    using MathUpgradeable for uint256;
    using MathUpgradeable for uint48;
    using MathUpgradeable for uint32;
    using MathUpgradeable for uint16;
    using StringsUpgradeable for uint256;
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter public _tokenIds;

    address public boxNFT;
    bool public isTransfer;
    bool public isTransferMarketPlace;
    string public baseURI;
    address public cyborgLab;
    // using HeroCoresUpgradeable for HeroCore;


    // namely the ERC721 instances for name symbol decimals etc
    function initialize() public initializer {
        __ERC721_init("HERO CORE NFT", "HECN");
        isTransfer = true;
        isTransferMarketPlace = true;
       
        __Ownable_init();
    }

    mapping(address => mapping(uint256 => uint256)) public cores;// address - id - details // cach lay details = cores[address][heroCoreId]
    mapping (uint256 => address) public coreIndexToOwner;
    address public heroCoreMarketPlace;
    mapping (address => bool) public operators;
    modifier onlyOperatorOrOwner {
      require(operators[msg.sender] == true || msg.sender == owner());
      _;
    }

    function initByOwner(address _heroCoreMarketPlace, address _boxNFT,address _cyborgLab) public onlyOwner{
    heroCoreMarketPlace = _heroCoreMarketPlace;
    boxNFT = _boxNFT;
    cyborgLab = _cyborgLab;
    operators[_heroCoreMarketPlace] = true ;
    operators[_boxNFT] = true ;
    operators[_cyborgLab] = true ;
  
  }

  function createHeroCore(address owner,uint256 classHero,uint256 pSkill) public onlyOperatorOrOwner  returns (uint256) {
        _tokenIds.increment();
        uint256 newId = _tokenIds.current();
        _safeMint(owner, newId);
        cores[owner][newId] = encode(HeroCore(newId,classHero,pSkill,0));
        coreIndexToOwner[newId]=owner;
        return newId;
    }

  function updateHeroCore(address owner,uint256 nftId, uint256 id, uint256 classHero,uint256 pSkill,uint256 isDeleted) public onlyOperatorOrOwner returns (uint256) {
        cores[owner][nftId] = encode(HeroCore(id,classHero,pSkill,isDeleted));
        return nftId;
    }

  function getHeroCore(address owner, uint256 id) public view returns (HeroCore memory _heroCore) {
    uint256 details= cores[owner][id];
    _heroCore.id = uint256(uint48(details>>100));
    _heroCore.classHero = uint256(uint8(details>>148));
    _heroCore.pSkill = uint256(uint8(details>>156));
    _heroCore.isDeleted =uint256(uint8(details>>164));
  }
  
function getHeroCorePublic(address _owner, uint256 _id) public view returns (
        uint256 id,
        uint256 classHero,
        uint256 pSkill,
        uint256 isDeleted
        ) {
    HeroCore memory _heroCore= getHeroCore(_owner,_id);
    id=_heroCore.id;
    classHero=_heroCore.classHero;
    pSkill=_heroCore.pSkill;
    isDeleted=_heroCore.isDeleted;
  }

  function encode(HeroCore memory heroCore) public pure returns (uint256) {
  // function encode(HeroCore memory heroCore)  external view returns  (uint256) {
    uint256 value;
    value = uint256(heroCore.id);
    value |= heroCore.id << 100;
    value |= heroCore.classHero << 148;
    value |= heroCore.pSkill << 156;
    value |= heroCore.isDeleted << 164;
    return value;
  }

 

  function getHeroCoreOfSender(address sender) external view returns (HeroCore[] memory ) {
        uint range=_tokenIds.current();
        uint i=1;
        uint index=0;
        uint x=0;
        for(i; i <= range; i++){
          HeroCore memory heroCore = getHeroCore(sender,i);
          if(heroCore.id !=0){
            index++;
          }
        }
        HeroCore[] memory result = new HeroCore[](index);
        i=1;
        for(i; i <= range; i++){
          HeroCore memory heroCore = getHeroCore(sender,i);
          if(heroCore.id !=0){
            result[x] = heroCore;
            x++;
          }
        }
        return result;
  }

function transfer(uint256 _nftId, address _target)
        external whenNotPaused
    {
        require(isTransferMarketPlace==true, "MarketPlace Off");
        require(_exists(_nftId), "Non existed NFT");
        require(
            ownerOf(_nftId) == msg.sender || getApproved(_nftId) == msg.sender,
            "Not approved"
        );
        require(_target != address(0), "Invalid address");
        if(msg.sender != heroCoreMarketPlace){
          require(msg.sender != _target, "Can not transfer myself");
        }

        if(msg.sender != heroCoreMarketPlace &&  _target!=heroCoreMarketPlace){
          revert("Can not transfer outsite MarketPlace");
        }
        HeroCore memory heroCore= getHeroCore(ownerOf(_nftId),_nftId);
       
        // star will start = 1, exp will start = 0
        // heroCore.star=1;
        // heroCore.exp=0;

        cores[_target][_nftId] = encode(heroCore);
        cores[ownerOf(_nftId)][_nftId]= encode(HeroCore(0,0,0,0));
        coreIndexToOwner[_nftId]=_target;
        _transfer(ownerOf(_nftId), _target, _nftId);
    }

  function transferFrom(
        address from,
        address to,
        uint256 tokenId 
    )
        public  virtual override  whenNotPaused 
    {
        
        require(_exists(tokenId ), "Non existed NFT");
        require(ownerOf(tokenId ) == from, "Only owner NFT can transfer");
        require(from != to, "Can not transfer myself");
        require(
            ownerOf(tokenId ) == msg.sender || getApproved(tokenId ) == msg.sender,
            "Not approved"
        );
        require(isTransfer == true, "Can not transfer");
        require(to != address(0), "Invalid address");

        HeroCore memory heroCore= getHeroCore(from,tokenId );
        cores[to][tokenId ] = encode(heroCore);
        cores[from][tokenId ]= encode(HeroCore(0,0,0,0));
        coreIndexToOwner[tokenId ]=to;
        _transfer(from, to, tokenId );
    }

  function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
      
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        require(from != to, "Can not transfer myself");
        require(isTransfer == true, "Can not transfer");
        HeroCore memory heroCore= getHeroCore(from,tokenId );
        cores[to][tokenId ] = encode(heroCore);
        cores[from][tokenId ]= encode(HeroCore(0,0,0,0));
        coreIndexToOwner[tokenId ]=to;
        _safeTransfer(from, to, tokenId, _data);
    }  

  function approveMarketPlace(address to, uint256 tokenId) external onlyOperatorOrOwner {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
         _approve(to,tokenId);
  }

function updateHeroCoreIndexToOwner(uint256 nftId,address owner) public onlyOwner  {
        coreIndexToOwner[nftId]= owner;
    }

  function setBoxNFT(address _boxNFT) public onlyOwner{
    boxNFT=_boxNFT;
    operators[_boxNFT] =true;
  }  

  function setHeroCoreMarketPlace(address _heroCoreMarketPlace) public onlyOwner{
    heroCoreMarketPlace=_heroCoreMarketPlace;
        operators[_heroCoreMarketPlace] =true;
  }

  function setOperator(address operator, bool isActive) external onlyOwner {
          operators[operator] =isActive;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner whenNotPaused {
       _pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused {
       _unpause();
    }

    
    function setBaseURI(string memory _baseURI) public onlyOwner{
      baseURI=_baseURI;
    }  
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        address sender=ownerOf(tokenId);
        HeroCore memory heroCore = getHeroCore(sender,tokenId);
        string memory json=".json";
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI,heroCore.classHero.toString(),json))  : "";
    }

    function setIsTransfer(bool _isTransfer) public onlyOwner{
    isTransfer=_isTransfer;
  }    

    function setIsTransferMarketPlace(bool _isTransferMarketPlace) public onlyOwner{
    isTransferMarketPlace=_isTransferMarketPlace;
  }   

  function setCyborgLab(address _cyborgLab) public onlyOwner{
    cyborgLab=_cyborgLab;
    operators[_cyborgLab] =true;
  }  

  function approveCyborgLab(address to, uint256 tokenId) external onlyOperatorOrOwner {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        _approve(to,tokenId);
  }
  
  function withdrawWith(address _tokenBEP20, uint256 _amount) external onlyOwner {
        IBEP20(_tokenBEP20).transfer(msg.sender, _amount);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "./IBEP20.sol";
import "./HeroStruct.sol";
contract HeroNFT is HeroStruct, ERC721Upgradeable, ERC721BurnableUpgradeable, OwnableUpgradeable, PausableUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter public _tokenIds;
    
    address public boxNFT;
    bool public isTransfer;
    bool public isTransferMarketPlace;
    string public baseURI;
    address public heroMarketPlace;
    address public cyborgLab;

    mapping(address => mapping(uint256 => uint256)) public heroDetails1;// address - id - details // cach lay details = heros[address][heroId]
    mapping (uint256 => address) public heroIndexToOwner;
    mapping(address => mapping(uint256 => uint256)) public heroDetails2;// address - id - details // cach lay details = heros[address][heroId]
    
    // using HerosUpgradeable for Hero;
    using MathUpgradeable for uint256;
    using MathUpgradeable for uint48;
    using MathUpgradeable for uint32;
    using MathUpgradeable for uint16;
    using StringsUpgradeable for uint256;
    
    // namely the ERC721 instances for name symbol decimals etc
    function initialize() public initializer {
        __ERC721_init("HERO NFT", "HEN");
        isTransfer=true;
        __Ownable_init();
    }

    mapping (address => bool) public operators;
    mapping(address => mapping(uint256 => uint256)) public heroDetails3;// address - id - details // cach lay details = heros[address][heroId]
    modifier onlyOperatorOrOwner {
      require(operators[msg.sender] == true || msg.sender == owner());
      _;
    }
  
  function initByOwner(address _heroMarketPlace, address _boxNFT,address _cyborgLab) public onlyOwner{
    heroMarketPlace=_heroMarketPlace;
    boxNFT=_boxNFT;
    cyborgLab = _cyborgLab;
    operators[_heroMarketPlace] =true;
    operators[_boxNFT] =true;
    operators[_cyborgLab] =true;    
  }

 function createHero(Hero memory _hero, address owner) public onlyOperatorOrOwner  returns (uint256) {
        _tokenIds.increment();
        uint256 newId = _tokenIds.current();
        _safeMint(owner, newId);
        heroDetails1[owner][newId] = encodeDetails1(Hero(newId,_hero.rank,_hero.classHero,_hero.pSkill,_hero.tech,_hero.bodyId,_hero.leftArmId,_hero.rightArmId,_hero.legsId,_hero.rarityBody,_hero.rarityLeftArm,_hero.rarityRightArm,_hero.rarityLegs,_hero.suitBody,_hero.suitLeftArm,_hero.suitRightArm,_hero.suitLeg,_hero.doneAt,0));
        heroDetails2[owner][newId] = encodeDetails2(Hero(newId,_hero.rank,_hero.classHero,_hero.pSkill,_hero.tech,_hero.bodyId,_hero.leftArmId,_hero.rightArmId,_hero.legsId,_hero.rarityBody,_hero.rarityLeftArm,_hero.rarityRightArm,_hero.rarityLegs,_hero.suitBody,_hero.suitLeftArm,_hero.suitRightArm,_hero.suitLeg,_hero.doneAt,0));
        heroDetails3[owner][newId] = encodeDetails3(Hero(newId,_hero.rank,_hero.classHero,_hero.pSkill,_hero.tech,_hero.bodyId,_hero.leftArmId,_hero.rightArmId,_hero.legsId,_hero.rarityBody,_hero.rarityLeftArm,_hero.rarityRightArm,_hero.rarityLegs,_hero.suitBody,_hero.suitLeftArm,_hero.suitRightArm,_hero.suitLeg,_hero.doneAt,0));
        
        heroIndexToOwner[newId]=owner;
        return newId;
    }

   function updateHero(Hero memory _hero, address owner) public onlyOperatorOrOwner returns (uint256) {
        heroDetails1[owner][_hero.id] = encodeDetails1(Hero(_hero.id,_hero.rank,_hero.classHero,_hero.pSkill,_hero.tech,_hero.bodyId,_hero.leftArmId,_hero.rightArmId,_hero.legsId,_hero.rarityBody,_hero.rarityLeftArm,_hero.rarityRightArm,_hero.rarityLegs,_hero.suitBody,_hero.suitLeftArm,_hero.suitRightArm,_hero.suitLeg,_hero.doneAt,0));
        heroDetails2[owner][_hero.id] = encodeDetails2(Hero(_hero.id,_hero.rank,_hero.classHero,_hero.pSkill,_hero.tech,_hero.bodyId,_hero.leftArmId,_hero.rightArmId,_hero.legsId,_hero.rarityBody,_hero.rarityLeftArm,_hero.rarityRightArm,_hero.rarityLegs,_hero.suitBody,_hero.suitLeftArm,_hero.suitRightArm,_hero.suitLeg,_hero.doneAt,0));
        heroIndexToOwner[_hero.id]=owner;
        return _hero.id;
    }  

  function getHero(address owner, uint256 id) public view returns (Hero memory _hero) {
    uint256 details1= heroDetails1[owner][id];
    uint256 details2= heroDetails2[owner][id];
    uint256 details3= heroDetails3[owner][id];
    _hero.id  = uint256(uint24(details1>>84));
    _hero.rank = uint256(uint8(details1>>108));
    _hero.classHero = uint256(uint8(details1>>116));
    _hero.pSkill = uint256(uint8(details1>>124));
    _hero.tech = uint256(uint8(details1>>132));
    _hero.doneAt = uint256(uint32(details1>>164));
    _hero.isDeleted = uint256(uint8(details1>>172));

    _hero.rarityBody = uint256(uint8(details2>>108));
    _hero.rarityLeftArm = uint256(uint8(details2>>116));
    _hero.rarityRightArm = uint256(uint8(details2>>124));
    _hero.rarityLegs = uint256(uint8(details2>>132));
    _hero.suitBody = uint256(uint8(details2>>140));
    _hero.suitLeftArm  = uint256(uint8(details2>>148));
    _hero.suitRightArm = uint256(uint8(details2>>156));
    _hero.suitLeg = uint256(uint8(details2>>164));

    _hero.suitBody = uint256(uint32(details3>>108));
    _hero.suitLeftArm  = uint256(uint8(details3>>140));
    _hero.suitRightArm = uint256(uint8(details3>>172));
    _hero.suitLeg = uint256(uint8(details3>>204));

  }

  function encodeDetails1(Hero memory hero) private pure returns (uint256) {
    uint256 value;
    value = uint256(hero.id);
    value |= hero.id << 84;
    value |= hero.rank << 108;
    value |= hero.classHero << 116;
    value |= hero.pSkill << 124;
    value |= hero.tech << 132;
    value |= hero.doneAt << 164;
    value |= hero.isDeleted << 172;
    return value;
  }

 function encodeDetails2(Hero memory hero)  private pure returns (uint256) {
    uint256 value;
    value = uint256(hero.id);
    value |= hero.id << 84;
    value |= hero.rarityBody << 108;
    value |= hero.rarityLeftArm << 116;
    value |= hero.rarityRightArm << 124;
    value |= hero.rarityLegs << 132;
    value |= hero.suitBody << 140;
    value |= hero.suitLeftArm << 148;
    value |= hero.suitRightArm << 156;
    value |= hero.suitLeg << 164;
    return value;
  }
  
  function encodeDetails3(Hero memory hero) private pure returns (uint256) {
    uint256 value;
    value = uint256(hero.id);
    value |= hero.id << 84;
    value |= ((hero.id -1) * 4 + 1) << 108;
    value |= ((hero.id -1) * 4 + 2) << 140;
    value |= ((hero.id -1) * 4 + 3) << 172;
    value |= ((hero.id -1) * 4 + 4) << 204;
    return value;
  }
  
function getHeroDetails1Public(address _owner, uint256 _id) public view returns (
      uint256 id,
        uint256 rank,
        uint256 classHero,
        uint256 pSkill,
        uint256 tech,
        uint256 doneAt, 
        uint256 isDeleted
        ) {
    Hero memory _hero= getHero(_owner,_id);
    id=_hero.id;
    rank=_hero.rank;
    classHero=_hero.classHero;
    pSkill=_hero.pSkill;
    tech=_hero.tech;
    doneAt = _hero.doneAt;
    isDeleted = _hero.isDeleted;
  }
  
function getHeroDetails2Public(address _owner, uint256 _id) public view returns (
        uint256 id,
        uint256 rarityBody,
        uint256 rarityLeftArm,
        uint256 rarityRightArm,
        uint256 rarityLegs,
        uint256 suitBody,
        uint256 suitLeftArm,
        uint256 suitRightArm,
        uint256 suitLeg
        ) {
    Hero memory _hero= getHero(_owner,_id);
    id=_hero.id;
    rarityBody = _hero.rarityBody;
    rarityLeftArm = _hero.rarityLeftArm;
    rarityRightArm = _hero.rarityRightArm;
    rarityLegs = _hero.rarityLegs;
    suitBody = _hero.suitBody;
    suitLeftArm = _hero.suitLeftArm;
    suitRightArm = _hero.suitRightArm;
    suitLeg = _hero.suitLeg;
  }

  function getHeroOfSender(address sender) external view returns (Hero[] memory ) {
        uint range=_tokenIds.current();
        uint i=1;
        uint index=0;
        uint x=0;
        for(i; i <= range; i++){
          Hero memory hero = getHero(sender,i);
          if(hero.id !=0){
            index++;
          }
        }
        Hero[] memory result = new Hero[](index);
        i=1;
        for(i; i <= range; i++){
          Hero memory hero = getHero(sender,i);
          if(hero.id !=0){
            result[x] = hero;
            x++;
          }
        }
        return result;
  }

function transfer(uint256 _nftId, address _target)
        external whenNotPaused
    {
        require(_exists(_nftId), "Non existed NFT");
        require(
            ownerOf(_nftId) == msg.sender || getApproved(_nftId) == msg.sender,
            "Not approved"
        );
        require(_target != address(0), "Invalid address");
        if(msg.sender != heroMarketPlace){
          require(msg.sender != _target, "Can not transfer myself");
        }
        Hero memory hero= getHero(ownerOf(_nftId),_nftId);
        heroDetails1[_target][_nftId] = encodeDetails1(hero);
        heroDetails1[ownerOf(_nftId)][_nftId]= encodeDetails1(Hero(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));
        heroDetails2[_target][_nftId] = encodeDetails2(hero);
        heroDetails2[ownerOf(_nftId)][_nftId]= encodeDetails2(Hero(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));
        heroIndexToOwner[_nftId]=_target;
        _transfer(ownerOf(_nftId), _target, _nftId);
    }

  function transferFrom(
        address from,
        address to,
        uint256 tokenId 
    )
        public  virtual override  whenNotPaused 
    {
        require(_exists(tokenId ), "Non existed NFT");
        require(ownerOf(tokenId ) == from, "Only owner NFT can transfer");
        require(from != to, "Can not transfer myself");
        require(
            ownerOf(tokenId ) == msg.sender || getApproved(tokenId ) == msg.sender,
            "Not approved"
        );
        require(to != address(0), "Invalid address");

        Hero memory hero= getHero(from,tokenId );
        heroDetails1[to][tokenId ] = encodeDetails1(hero);
        heroDetails1[from][tokenId ]= encodeDetails1(Hero(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));
        heroDetails2[to][tokenId ] = encodeDetails2(hero);
        heroDetails2[from][tokenId ]= encodeDetails2(Hero(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));
        heroIndexToOwner[tokenId ]=to;
        _transfer(from, to, tokenId );
    }

  function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        require(from != to, "Can not transfer myself");
        Hero memory hero= getHero(from,tokenId );
          heroDetails1[to][tokenId ] = encodeDetails1(hero);
        heroDetails1[from][tokenId ]= encodeDetails1(Hero(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));
        heroDetails2[to][tokenId ] = encodeDetails2(hero);
        heroDetails2[from][tokenId ]= encodeDetails2(Hero(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));
        heroIndexToOwner[tokenId ]=to;
        _safeTransfer(from, to, tokenId, _data);
    }  

  function approveMarketPlace(address to, uint256 tokenId) external onlyOperatorOrOwner {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
         _approve(to,tokenId);
  }


  function updateHeroIndexToOwner(uint256 nftId,address owner) public onlyOwner  {
        heroIndexToOwner[nftId]= owner;
    }

  function setBoxNFT(address _boxNFT) public onlyOwner{
    boxNFT=_boxNFT;
    operators[_boxNFT] =true;
  }  

  function setHeroMarketPlace(address _heroMarketPlace) public onlyOwner{
    heroMarketPlace=_heroMarketPlace;
    operators[_heroMarketPlace] =true;
  }

  /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner whenNotPaused {
       _pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused {
       _unpause();
    }

    
    function setBaseURI(string memory _baseURI) public onlyOwner{
      baseURI=_baseURI;
    }
  
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        address sender=ownerOf(tokenId);
        Hero memory hero = getHero(sender,tokenId);
        string memory json=".json";
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI,hero.classHero.toString(),hero.tech.toString(),hero.rank.toString(),json))  : "";
    }
    
  function setIsTransfer(bool _isTransfer) public onlyOwner{
    isTransfer=_isTransfer;
  }  

  function setCyborgLab(address _cyborgLab) public onlyOwner{
    cyborgLab=_cyborgLab;
    operators[_cyborgLab] =true;
  }   

  function withdrawWith(address _tokenBEP20, uint256 _amount) external onlyOwner {
    IBEP20(_tokenBEP20).transfer(msg.sender, _amount);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

contract HeroStruct {
   struct Hero {
        uint256 id;
        uint256 rank;           // 1
        uint256 classHero;      // 2
        uint256 pSkill;         // 3
        uint256 tech;           // 4

        uint256 bodyId;         // 5
        uint256 leftArmId;      // 6
        uint256 rightArmId;     // 7
        uint256 legsId;         // 8

        uint256 rarityBody;         // 9
        uint256 rarityLeftArm;      // 10
        uint256 rarityRightArm;     // 11
        uint256 rarityLegs;         // 12

        uint256 suitBody;           // 13
        uint256 suitLeftArm;        // 14
        uint256 suitRightArm;       // 15
        uint256 suitLeg;            // 16

        uint256 doneAt;    // 17
        uint256 isDeleted; // 18
  
    }
    struct HeroDetails1 {
        uint256 id;
        uint256 rank;
        uint256 classHero;
        uint256 pSkill;
        uint256 tech;
        uint256 doneAt; 
        uint256 isDeleted;
    }

    struct HeroDetails2 {
       uint256 id;
        uint256 rarityBody;
        uint256 rarityLeftArm;
        uint256 rarityRightArm;
        uint256 rarityLegs;
        uint256 suitBody;
        uint256 suitLeftArm;
        uint256 suitRightArm;
        uint256 suitLeg;
    }

    struct HeroDetails3 {
        uint256 id;
        uint256 bodyId;
        uint256 leftArmId;
        uint256 rightArmId;
        uint256 legsId;
    }

    struct HeroCore {
        uint256 id;
        uint256 classHero;        // 1, 2, 3:  Damage, Tank, Healer  
        uint256 pSkill;       // 1, 2, 3, ...: 	Attack Boost, Health Boost
        uint256 isDeleted;
    }

    struct HeroBlueprint {
        uint256 id;
        uint256 rank;
        uint256 tech;
        uint256 isDeleted;
    }

    

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "./VRFv2Consumer.sol";

contract Utils is OwnableUpgradeable, PausableUpgradeable  {
    using SafeMathUpgradeable for uint256;
    uint256 randomNumber;
    uint256 privateNumber;
    VRFv2Consumer public v2Consumer;
    function initialize() public initializer {
      __Ownable_init();
    }

    function initByOwner(VRFv2Consumer _v2Consumer,uint256 _randomNumber,uint256 _privateNumber) public onlyOwner{
        v2Consumer = _v2Consumer;
        randomNumber=_randomNumber;
        privateNumber=_privateNumber;
    }

    function random(uint256 from, uint256 to) public whenNotPaused view returns (uint256 number) {
        require(to > from, "Not correct input");
        uint256 tmp  = uint(keccak256(abi.encodePacked(block.timestamp,randomNumber,msg.sender)))%34560;
        number = from + (tmp  % (to-from+1));
    }

    function random1(uint256 from, uint256 to) public whenNotPaused view returns (uint256 number) {
      require(to > from, "Not correct input");
        uint256 tmp  = uint(keccak256(abi.encodePacked(block.timestamp,randomNumber,msg.sender)))%1234565;
        number = from + (tmp  % (to-from+1));
    }

    function random2(uint256 from, uint256 to) public whenNotPaused view returns (uint256 number) {
       require(to > from, "Not correct input");
        uint256 tmp  = uint(keccak256(abi.encodePacked(block.timestamp,randomNumber,msg.sender)))%945588;
        number = from + (tmp  % (to-from+1));
    }

     function random3(uint256 from, uint256 to) public whenNotPaused view returns (uint256 number) {
        require(to > from, "Not correct input");
        uint256 tmp  = uint(keccak256(abi.encodePacked(block.timestamp,randomNumber,msg.sender)))<<10 %4558;
        number = from + (tmp  % (to-from+1));
    }

      function random4(uint256 from, uint256 to) public whenNotPaused view returns (uint256 number) {
        require(to > from, "Not correct input");
        uint256 tmp  = uint(keccak256(abi.encodePacked(block.timestamp,randomNumber,msg.sender)))%594551;
        number = from + (tmp  % (to-from+1));
    }
    
    function randomV2VRF(uint256 from, uint256 to) public whenNotPaused  returns (uint256 _randomV2) {
        require(to > from, "Not correct input");
        uint256 _random = v2Consumer.getRandomWords();
        _randomV2 = from + _random.mod(to-from).add(1);
    }

    function getRandomNumber(uint256 _privateNumber) public  view returns (uint256) {
      require(privateNumber==_privateNumber,"Not correct number private");
      return randomNumber;
    }

    function setRandomNumber(uint256 _randomNumber) public onlyOwner  {
       randomNumber = _randomNumber;
    }

    function setNumberPrivate(uint256 _privateNumber) public onlyOwner  {
       privateNumber = _privateNumber;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner whenNotPaused {
       _pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused {
       _unpause();
    }
}

// SPDX-License-Identifier: MIT
// An example of a consumer contract that relies on a subscription for funding.
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract VRFv2Consumer is VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface COORDINATOR;
    LinkTokenInterface LINKTOKEN;

    // Your subscription ID.
    uint64 s_subscriptionId;

    // Rinkeby coordinator. For other networks,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    address vrfCoordinator = 0x6A2AAd07396B36Fe02a22b33cf443582f682c82f;

    // Rinkeby LINK token contract. For other networks,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    address link = 0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    bytes32 keyHash = 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit = 100000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 numWords =  2;

    uint256[] public s_randomWords;
    uint256 public s_requestId;
    address s_owner;
    mapping (address => bool) public operators;

    constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        LINKTOKEN = LinkTokenInterface(link);
        s_owner = msg.sender;
        s_subscriptionId = subscriptionId;
    }

    // Assumes the subscription is funded sufficiently.
    function requestRandomWords() public onlyOperator {
        // Will revert if subscription is not set and funded.
        s_requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        s_randomWords = randomWords;
    }

    function addOperator(
        address operator
    ) public onlyOwner {
        operators[operator] = true;
    }

    function removeOperator(
        address operator
    ) public onlyOwner {
        operators[operator] = false;
    }

    function getOperator(
        address operator
    ) public view returns(bool)  {
        return operators[operator];
    }

    modifier onlyOwner() {
        require(msg.sender == s_owner);
        _;
    }

    modifier onlyOperator() {
        require(operators[msg.sender] == true);
        _;
    }

    function getRandomWords() public returns(uint256) {
        requestRandomWords();
        return s_randomWords[0];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness. It ensures 2 things:
 * @dev 1. The fulfillment came from the VRFCoordinator
 * @dev 2. The consumer contract implements fulfillRandomWords.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash). Create subscription, fund it
 * @dev and your consumer contract as a consumer of it (see VRFCoordinatorInterface
 * @dev subscription management functions).
 * @dev Call requestRandomWords(keyHash, subId, minimumRequestConfirmations,
 * @dev callbackGasLimit, numWords),
 * @dev see (VRFCoordinatorInterface for a description of the arguments).
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomWords method.
 *
 * @dev The randomness argument to fulfillRandomWords is a set of random words
 * @dev generated from your requestId and the blockHash of the request.
 *
 * @dev If your contract could have concurrent requests open, you can use the
 * @dev requestId returned from requestRandomWords to track which response is associated
 * @dev with which randomness request.
 * @dev See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ.
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request. It is for this reason that
 * @dev that you can signal to an oracle you'd like them to wait longer before
 * @dev responding to the request (however this is not enforced in the contract
 * @dev and so remains effective only in the case of unmodified oracle software).
 */
abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   */
  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBaseV2 expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomWords the VRF output expanded to the requested number of words
   */
  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {
  /**
   * @notice Get configuration relevant for making requests
   * @return minimumRequestConfirmations global min for request confirmations
   * @return maxGasLimit global max for request gas limit
   * @return s_provingKeyHashes list of registered key hashes
   */
  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );

  /**
   * @notice Request a set of random words.
   * @param keyHash - Corresponds to a particular oracle job which uses
   * that key for generating the VRF proof. Different keyHash's have different gas price
   * ceilings, so you can select a specific one to bound your maximum per request cost.
   * @param subId  - The ID of the VRF subscription. Must be funded
   * with the minimum subscription balance required for the selected keyHash.
   * @param minimumRequestConfirmations - How many blocks you'd like the
   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
   * for why you may want to request more. The acceptable range is
   * [minimumRequestBlockConfirmations, 200].
   * @param callbackGasLimit - How much gas you'd like to receive in your
   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
   * may be slightly less than this amount because of gas used calling the function
   * (argument decoding etc.), so you may need to request slightly more than you expect
   * to have inside fulfillRandomWords. The acceptable range is
   * [0, maxGasLimit]
   * @param numWords - The number of uint256 random values you'd like to receive
   * in your fulfillRandomWords callback. Note these numbers are expanded in a
   * secure way by the VRFCoordinator from a single random value supplied by the oracle.
   * @return requestId - A unique identifier of the request. Can be used to match
   * a request to a response in fulfillRandomWords.
   */
  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  /**
   * @notice Create a VRF subscription.
   * @return subId - A unique subscription id.
   * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
   * @dev Note to fund the subscription, use transferAndCall. For example
   * @dev  LINKTOKEN.transferAndCall(
   * @dev    address(COORDINATOR),
   * @dev    amount,
   * @dev    abi.encode(subId));
   */
  function createSubscription() external returns (uint64 subId);

  /**
   * @notice Get a VRF subscription.
   * @param subId - ID of the subscription
   * @return balance - LINK balance of the subscription in juels.
   * @return reqCount - number of requests for this subscription, determines fee tier.
   * @return owner - owner of the subscription.
   * @return consumers - list of consumer address which are able to use this subscription.
   */
  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @param newOwner - proposed new owner of the subscription
   */
  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @dev will revert if original owner of subId has
   * not requested that msg.sender become the new owner.
   */
  function acceptSubscriptionOwnerTransfer(uint64 subId) external;

  /**
   * @notice Add a consumer to a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - New consumer which can use the subscription
   */
  function addConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Remove a consumer from a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - Consumer to remove from the subscription
   */
  function removeConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Cancel a subscription
   * @param subId - ID of the subscription
   * @param to - Where to send the remaining LINK to
   */
  function cancelSubscription(uint64 subId, address to) external;
}

// SPDX-License-Identifier: MIT

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
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
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
    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
        _;
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC721Upgradeable.sol";
import "./IERC721ReceiverUpgradeable.sol";
import "./extensions/IERC721MetadataUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../utils/StringsUpgradeable.sol";
import "../../utils/introspection/ERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable {
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

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
    function __ERC721_init(string memory name_, string memory symbol_) internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal initializer {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
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
        address owner = ERC721Upgradeable.ownerOf(tokenId);
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
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
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
        address owner = ERC721Upgradeable.ownerOf(tokenId);
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
        address owner = ERC721Upgradeable.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
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
        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
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
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
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
    uint256[44] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
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

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
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

pragma solidity ^0.8.0;

import "../ERC721Upgradeable.sol";
import "../../../utils/ContextUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @title ERC721 Burnable Token
 * @dev ERC721 Token that can be irreversibly burned (destroyed).
 */
abstract contract ERC721BurnableUpgradeable is Initializable, ContextUpgradeable, ERC721Upgradeable {
    function __ERC721Burnable_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721Burnable_init_unchained();
    }

    function __ERC721Burnable_init_unchained() internal initializer {
    }
    /**
     * @dev Burns `tokenId`. See {ERC721-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC721Upgradeable.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721MetadataUpgradeable is IERC721Upgradeable {
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

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library CountersUpgradeable {
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

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
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

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

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
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

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
interface IERC165Upgradeable {
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

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMathUpgradeable {
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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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