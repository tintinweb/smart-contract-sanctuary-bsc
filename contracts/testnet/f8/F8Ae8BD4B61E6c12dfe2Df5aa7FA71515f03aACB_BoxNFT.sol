// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "./CharacterNFT.sol";
import "./DiceNFT.sol";
import "./Utils.sol";
// import "./BuildingNFT.sol";
// import "./sol";

contract BoxNFT is ERC721Upgradeable, ERC721BurnableUpgradeable, OwnableUpgradeable, PausableUpgradeable{
    using MathUpgradeable for uint256;
    using MathUpgradeable for uint48;
    using MathUpgradeable for uint32;
    using MathUpgradeable for uint16;
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter public _tokenIds;
    
    struct Box {
        uint256 id;
        uint256 rank;
    }
    CharacterNFT public characterNFT;
    DiceNFT public diceNFT;
    
    function initialize() public initializer {
      __ERC721_init("Box NFT BPLUS", "BONB");
      openBoxActive=false;
      __Ownable_init();
    }
    
    mapping(address => mapping(uint256 => Box)) public boxes;// address - id - details // cach lay details = boxes[address][boxId]
    
    address public boxMarketPlace;
    modifier onlyBoxMarketPlaceOrOwner {
      require(msg.sender == boxMarketPlace || msg.sender == owner());
      _;
    }

    address public boxNFTRound;
    modifier onlyBoxNFTRoundOrOwner {
      require(msg.sender == boxNFTRound || msg.sender == owner());
      _;
    }
    bool public openBoxActive;
    event randomData(uint256 characterId, uint256 diceId, uint256 randomCharacter,uint256 randomDice);
    
    

    function initByOwner(CharacterNFT _characterNFT, DiceNFT _diceNFT, address _boxNFTRound, address _boxMarketPlace, address _operator) public  onlyOwner {
        characterNFT = _characterNFT;
        diceNFT = _diceNFT;
        boxNFTRound=_boxNFTRound;
        boxMarketPlace=_boxMarketPlace;
        operator=_operator;
    }

  function createBox(address owner,uint256 rank) public onlyOperatorOrOwner returns (uint256) {
        _tokenIds.increment();
        uint256 newBoxId = _tokenIds.current();
        _safeMint(owner, newBoxId);
        boxes[owner][newBoxId] = Box(newBoxId,rank);
        return newBoxId;
    }
  
  function getBoxPublic(address _owner, uint256 _id) public view returns (
        uint256 id,
        uint256 rank
        ) {
    Box memory _box= boxes[_owner][_id];
    id=_box.id;
    rank=_box.rank;
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
        if(msg.sender != boxMarketPlace){
          require(msg.sender != _target, "Can not transfer myself");
        }
        Box memory box=boxes[ownerOf(_nftId)][_nftId];
        // star will start = 1, exp will start = 0

        boxes[_target][_nftId] = box;
        boxes[ownerOf(_nftId)][_nftId]= Box(0,0);
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
        require(
            ownerOf(tokenId ) == msg.sender || getApproved(tokenId ) == msg.sender,
            "Not approved"
        );
        require(from != to, "Can not transfer myself");
        require(to != address(0), "Invalid address");

        Box memory box= boxes[from][tokenId];
        boxes[to][tokenId ] = box;
        boxes[from][tokenId ]= Box(0,0);
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
        Box memory box= boxes[from][tokenId];
        boxes[to][tokenId ] = box;
        boxes[from][tokenId ]= Box(0,0);
        _safeTransfer(from, to, tokenId, _data);
    }    

  function approveMarketPlace(address to, uint256 tokenId) external whenNotPaused onlyBoxMarketPlaceOrOwner {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
         _approve(to,tokenId);
  }


function buyBox(address buyer,uint256 rank) external whenNotPaused onlyBoxNFTRoundOrOwner returns (uint256) {
        _tokenIds.increment();
        uint256 newBoxId = _tokenIds.current();
        _safeMint(buyer, newBoxId);
        boxes[buyer][newBoxId] =Box(newBoxId,rank);
        return newBoxId;
    }

function openBox(uint256 tokenId) external whenNotPaused returns (uint256 characterId,uint256 diceId,uint256 randomCharacter,uint256 randomDice){
        require(openBoxActive==true, "openBox not active");
        Box memory box = boxes[msg.sender][tokenId];
        boxes[msg.sender][tokenId]= Box(0,0);
        uint256 rank=box.rank;
        uint256 rankSelect=1;
        uint256 typeCharacter = 1;
        diceId=0;
        randomDice=0;
        randomCharacter=0;
        if(rank==11){
          randomCharacter = utils.random(1,100);
          uint256 randomRank = utils.random(1,100);
          if(1<= randomCharacter && randomCharacter<=10){
                typeCharacter=1;
           } else if (11 <= randomCharacter && randomCharacter<=20) {
                typeCharacter=2;
           } else if (21 <= randomCharacter && randomCharacter<=30) {
                typeCharacter=3;
           } else if (31 <= randomCharacter && randomCharacter<=40) {
                typeCharacter=4;
            }else if (41 <= randomCharacter && randomCharacter<=50) {
                typeCharacter=1;
           } else if (51 <= randomCharacter && randomCharacter<=60) {
                typeCharacter=6;
            } else if (61 <= randomCharacter && randomCharacter<=70) {
                typeCharacter=7;
           } else if (71 <= randomCharacter && randomCharacter<=80) {
                typeCharacter=8;
            } else if (81 <= randomCharacter && randomCharacter<=90) {
                typeCharacter=9;
           } else if (91 <= randomCharacter && randomCharacter<=100) {
                typeCharacter=9;
           }  
          if(1<= randomRank && randomRank<=82){
            rankSelect=1;
          } else if(83<= randomRank && randomRank<=95){
            rankSelect=2;
          }else if(96<= randomRank && randomRank<=100){
            rankSelect=3;
          }
          characterId=characterNFT.createCharacter(msg.sender,typeCharacter,rankSelect,1,0);

        }else{
        uint256 value = uint256(tokenId*block.timestamp);
            // uint256 randomHaveDice =  (value << 10) % 100+1;
            uint256 randomRank = (value << 20) % 100+1;
            bool haveDice=false;
            uint256 typeDice=0;
          
            // Random rank to get rank design
            if(rank==1){
              if(1<= randomRank && randomRank<=83){
                rankSelect=1; // 80% rank D
              }else{
                rankSelect=2; // 20% rank C
              }
            }else if(rank==2){
              if(1<= randomRank && randomRank<=75){
                rankSelect=2; // 75% rank C
              }else {
                rankSelect=3; // 25% rank B
              }
            }else if(rank==3){
              rankSelect=3;
            }

            // Random rank to get dice design
            
            if(tokenId<2870){
              haveDice=true;
            }

            if(rankSelect==1){
              randomCharacter = (value << 20)%100+1;
              if(1<= randomCharacter && randomCharacter<=10){
                typeCharacter=1;
              } else if (11 <= randomCharacter && randomCharacter<=20) {
                typeCharacter=2;
              } else if (21 <= randomCharacter && randomCharacter<=30) {
                typeCharacter=3;
              } else if (31 <= randomCharacter && randomCharacter<=40) {
                typeCharacter=4;
              }else if (41 <= randomCharacter && randomCharacter<=50) {
                typeCharacter=1;
              } else if (51 <= randomCharacter && randomCharacter<=60) {
                typeCharacter=2;
              } else if (61 <= randomCharacter && randomCharacter<=70) {
                typeCharacter=7;
              } else if (71 <= randomCharacter && randomCharacter<=80) {
                typeCharacter=8;
              } else if (81 <= randomCharacter && randomCharacter<=90) {
                typeCharacter=9;
              } else if (91 <= randomCharacter && randomCharacter<=100) {
                typeCharacter=9;
              }  
              characterId=characterNFT.createCharacter(msg.sender,typeCharacter,rankSelect,1,0);
              randomDice = (value << 30)%100+1;
              if(haveDice==true){
                if(1<= randomDice && randomDice<=20){
                  typeDice=11;
                } else if (21 <= randomDice && randomDice <= 60) {
                  typeDice=12;
                } else if (61 <= randomDice && randomDice<=100) {
                  typeDice=13;
                }
                diceId=diceNFT.createDice(msg.sender,typeDice);
              }
            }
            else if(rankSelect==2){
                randomCharacter = (value << 20)%100+1;
              if(1<= randomCharacter && randomCharacter<=10){
                typeCharacter=1;
              } else if (11 <= randomCharacter && randomCharacter<=20) {
                typeCharacter=2;
              } else if (21 <= randomCharacter && randomCharacter<=30) {
                typeCharacter=3;
              } else if (31 <= randomCharacter && randomCharacter<=40) {
                typeCharacter=4;
              }else if (41 <= randomCharacter && randomCharacter<=50) {
                typeCharacter=1;
              } else if (51 <= randomCharacter && randomCharacter<=60) {
                typeCharacter=2;
              } else if (61 <= randomCharacter && randomCharacter<=70) {
                typeCharacter=7;
              } else if (71 <= randomCharacter && randomCharacter<=80) {
                typeCharacter=8;
              } else if (81 <= randomCharacter && randomCharacter<=90) {
                typeCharacter=9;
              } else if (91 <= randomCharacter && randomCharacter<=100) {
                typeCharacter=9;
              } 
              characterId=characterNFT.createCharacter(msg.sender,typeCharacter,rankSelect,1,0);
              randomDice = (value << 10)%100+1;
              if(haveDice==true){
                if(1<= randomDice && randomDice<=10){
                  typeDice=2;
                } else if (11 <= randomDice && randomDice <= 55) {
                  typeDice=14;
                } else if (56 <= randomDice && randomDice<=100) {
                  typeDice=15;
                }
                diceId=diceNFT.createDice(msg.sender,typeDice);
              }
            }

            else if(rankSelect==3){
                randomCharacter = (value << 20)%100+1;
              if(1<= randomCharacter && randomCharacter<=10){
                typeCharacter=1;
              } else if (11 <= randomCharacter && randomCharacter<=20) {
                typeCharacter=2;
              } else if (21 <= randomCharacter && randomCharacter<=30) {
                typeCharacter=3;
              } else if (31 <= randomCharacter && randomCharacter<=40) {
                typeCharacter=4;
              }else if (41 <= randomCharacter && randomCharacter<=50) {
                typeCharacter=1;
              } else if (51 <= randomCharacter && randomCharacter<=60) {
                typeCharacter=2;
              } else if (61 <= randomCharacter && randomCharacter<=70) {
                typeCharacter=7;
              } else if (71 <= randomCharacter && randomCharacter<=80) {
                typeCharacter=8;
              } else if (81 <= randomCharacter && randomCharacter<=90) {
                typeCharacter=9;
              } else if (91 <= randomCharacter && randomCharacter<=100) {
                typeCharacter=9;
              }
              characterId=characterNFT.createCharacter(msg.sender,typeCharacter,rankSelect,1,0);
              randomDice = (value << 10)%100+1;
              if(haveDice==true){
                if(1<= randomDice && randomDice<=10){
                  typeDice=2;
                } else if (11 <= randomDice && randomDice <= 55) {
                  typeDice=14;
                } else if (56 <= randomDice && randomDice<=100) {
                  typeDice=15;
                }
                diceId=diceNFT.createDice(msg.sender,typeDice);
              }
            }

            else if(rankSelect==4){
                randomCharacter = (value << 20)%100+1;
              if(1<= randomCharacter && randomCharacter<=10){
                typeCharacter=1;
              } else if (11 <= randomCharacter && randomCharacter<=20) {
                typeCharacter=2;
              } else if (21 <= randomCharacter && randomCharacter<=30) {
                typeCharacter=3;
              } else if (31 <= randomCharacter && randomCharacter<=40) {
                typeCharacter=4;
              }else if (41 <= randomCharacter && randomCharacter<=50) {
                typeCharacter=1;
              } else if (51 <= randomCharacter && randomCharacter<=60) {
                typeCharacter=2;
              } else if (61 <= randomCharacter && randomCharacter<=70) {
                typeCharacter=7;
              } else if (71 <= randomCharacter && randomCharacter<=80) {
                typeCharacter=8;
              } else if (81 <= randomCharacter && randomCharacter<=90) {
                typeCharacter=9;
              } else if (91 <= randomCharacter && randomCharacter<=100) {
                typeCharacter=9;
              } 
              characterId=characterNFT.createCharacter(msg.sender,typeCharacter,rankSelect,1,0);
              randomDice = (value << 10)%100+1;
              if(haveDice==true){
                if(1<= randomDice && randomDice<=10){
                  typeDice=2;
                } else if (11 <= randomDice && randomDice <= 55) {
                  typeDice=14;
                } else if (56 <= randomDice && randomDice<=100) {
                  typeDice=15;
                }
                diceId=diceNFT.createDice(msg.sender,typeDice);
              }
            }
          emit randomData(
              typeCharacter,
              typeDice,
              randomCharacter,
              randomDice
            );
        }
        if(minBoxAccessory <= tokenId && tokenId <= maxBoxAccessory){
            accessories[tokenId] = Accessory(msg.sender,characterId,1);
        }
        _burn(tokenId);
    }

  function getBoxesOfSender(address sender) external view returns (Box[] memory ) {
        uint range=_tokenIds.current();
        uint i=1;
        uint index=0;
        uint x=0;
        for(i; i <= range; i++){
          if(boxes[sender][i].id !=0){
            index++;
          }
        }
        Box[] memory result = new Box[](index);
        i=1;
        for(i; i <= range; i++){
          if(boxes[sender][i].id !=0){
            result[x] = boxes[sender][i];
            x++;
          }
        }
        return result;
  }  

  function setBoxNFTRound(address _boxNFTRound) public onlyOwner{
    boxNFTRound=_boxNFTRound;
  }

  function setOpenBoxActive(bool _openBoxActive) public onlyOwner{
    openBoxActive=_openBoxActive;
  }

  function setCharacterNFT(CharacterNFT _characterNFT) public onlyOwner{
    characterNFT=_characterNFT;
  }

  function setBoxMarketPlace(address _boxMarketPlace) public onlyOwner{
    boxMarketPlace=_boxMarketPlace;
  }

  function setOperator(address _operator) public onlyOwner{
    operator = _operator;
  }  

  function withdraw(address _target, uint256 _amount) external onlyOwner {
        require(_target != address(0), "Invalid address");
        payable(_target).transfer(_amount);
    }

  function updateBox(address owner,uint256 nftId, uint256 id, uint256 rank) public onlyOperatorOrOwner returns (uint256) {
        boxes[owner][nftId] =Box(id,rank);
        return nftId;
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


    string public baseURI;
    using StringsUpgradeable for uint256;
    function setBaseURI(string memory _baseURI) public onlyOwner{
      baseURI=_baseURI;
    }  
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        address sender=ownerOf(tokenId);
        Box memory box= boxes[sender][tokenId];
        string memory rank="";
        string memory json=".json";
        if(box.rank==1){
          rank="d";
        }
        else if(box.rank==2){
          rank="c";
        }
        else if(box.rank==3){
          rank="b";
        }
        else if(box.rank==4){
          rank="a";
        }
        else if(box.rank==5){
          rank="s";
        }
        else if(box.rank==6){
          rank="ss";
        }
        else if(box.rank==7){
          rank="sss";
        }
        else if(box.rank==11){
          rank="random";
        }
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI,rank,json))  : "";
    }

    address public operator;
    modifier onlyOperatorOrOwner {
      require(msg.sender == operator || msg.sender == owner());
      _;
    }

    Utils public utils;
    function setUtils(Utils _utils) public onlyOwner{
        utils = _utils;
    }

    struct Accessory {
        address owner;
        uint256 characterNft;
        uint256 typeAccessory;


    }
    mapping(uint256 => Accessory) public accessories; //character - type accessories
    uint256 public minBoxAccessory;
    uint256 public maxBoxAccessory;

  function setMinBoxAccessory(uint256 _minBoxAccessory) public onlyOwner{
    minBoxAccessory=_minBoxAccessory;
  }

  function setMaxBoxAccessory(uint256 _maxBoxAccessory) public onlyOwner{
    maxBoxAccessory=_maxBoxAccessory;
  }

  function getAccessory(uint256 _id) public view returns (
        address _owner,
        uint256 _characterNft,
        uint256 _typeAccessory
        ) {
        _owner = accessories[_id].owner;
        _characterNft = accessories[_id].characterNft;
        _typeAccessory = accessories[_id].typeAccessory;
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
// import "./sol";
import "./IBEP20.sol";
contract CharacterNFT is ERC721Upgradeable, ERC721BurnableUpgradeable, OwnableUpgradeable, PausableUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter public _tokenIds;
    
    // using CharactersUpgradeable for Character;
    using MathUpgradeable for uint256;
    using MathUpgradeable for uint48;
    using MathUpgradeable for uint32;
    using MathUpgradeable for uint16;
    uint256 public version;
    struct Character {
        uint256 id;
        uint256 characterType;
        uint256 rank;
        uint256 star;
        uint256 exp;
        uint256 isDeleted;
        // uint256[] abilities;
    }
    event logCreateRandomThreeCharacter(uint256 nftId, uint256 characterType, uint256 rank, uint256 star, uint256 exp);

    // namely the ERC721 instances for name symbol decimals etc
    function initialize() public initializer {
        __ERC721_init("Character NFT BPLUS", "CHNB");
        __Ownable_init();
    }
    address public academyUpStar;
    modifier onlyAcademyUpStarOrOwner {
      require(msg.sender == academyUpStar || msg.sender == owner());
      _;
    }

    address public evolutionUpRank;
    modifier onlyEvolutionUpRankOrOwner {
      require(msg.sender == evolutionUpRank || msg.sender == owner());
      _;
    }

    mapping(address => mapping(uint256 => uint256)) public characters;// address - id - details // cach lay details = characters[address][characterId]
    mapping (uint256 => address) public characterIndexToOwner;

    address public boxNFT;
    modifier onlyBoxNFTOrOperatorOrOwner {
      require(msg.sender == boxNFT || msg.sender == owner()||msg.sender == operator);
      _;
    }

    address public characterMarketPlace;
    modifier onlyCharacterMarketPlaceOrOwner {
      require(msg.sender == characterMarketPlace || msg.sender == owner());
      _;
    }

  function createCharacter(address owner,uint256 characterType, uint256 rank, uint256  star,uint256  exp) public onlyBoxNFTOrOperatorOrOwner  returns (uint256) {
        _tokenIds.increment();
        uint256 newCharacterId = _tokenIds.current();
        //we can call mint from the ERC721 contract to mint our nft token
        // _safeMint(msg.sender, newCharacterId);
        _safeMint(owner, newCharacterId);
        characters[owner][newCharacterId] = encode(Character(newCharacterId,characterType,rank,star,exp,0));
        characterIndexToOwner[newCharacterId]=owner;
        return newCharacterId;
    }

  function updateCharacter(address owner,uint256 nftId, uint256 id, uint256 characterType, uint256 rank, uint256  star,uint256 exp,uint256 isDeleted) public onlyOperatorOrOwner returns (uint256) {
        characters[owner][nftId] = encode(Character(id,characterType,rank,star,exp,isDeleted));
        return nftId;
    }

  // function upStar(address _owner,uint256 _nftId) public onlyAcademyUpStarOrOwner {
  //   Character memory character= getCharacter(_owner,_nftId);
  //   character.star=character.star+1;
  //   character.exp=0;
  //   characters[_owner][_nftId] = encode(character);
  // }

   function upStarV2(address _owner,uint256 _nftId, uint _star) public onlyAcademyUpStarOrOwner {
    Character memory character= getCharacter(_owner,_nftId);
    require(character.star + _star <= 5 , 'Invalid number of stars'); 
    character.star=character.star + _star;
    character.exp=0;
    characters[_owner][_nftId] = encode(character);
  }

  function upRank(address _owner,uint256 _mainNftId, uint256[] memory _materialNftIds) public onlyEvolutionUpRankOrOwner {
    Character memory character= getCharacter(_owner,_mainNftId);
    character.rank=character.rank+1;
    character.star=1;
    character.exp=0;
    characters[_owner][_mainNftId] = encode(character);
    for(uint i = 0; i < _materialNftIds.length; i++){
       characters[_owner][_materialNftIds[i]]=encode(Character(_materialNftIds[i],0,0,0,0,1));
    }
  }

  // function upExp(address _owner,uint256 _nftId,uint256 _exp) public onlyAcademyUpStarOrOwner  {
  //   Character memory character= getCharacter(_owner,_nftId);
  //   character.exp=character.exp + _exp;
  //   characters[_owner][_nftId] = encode(character);
  // }

  function getCharacter(address owner, uint256 id) public view returns (Character memory _character) {
    uint256 details= characters[owner][id];
    _character.id = uint256(uint48(details>>100));
    _character.characterType = uint256(uint16(details>>148));
    _character.rank = uint256(uint16(details>>164));
    _character.star =uint256(uint16(details>>180));
    _character.exp =uint256(uint32(details>>196));
    _character.isDeleted =uint256(uint8(details>>228));
  }
  
function getCharacterPublic(address _owner, uint256 _id) public view returns (
        uint256 id,
        uint256 characterType,
        uint256 rank,
        uint256 star,
        uint256 exp,
        uint256 isDeleted
        ) {
    Character memory _character= getCharacter(_owner,_id);
    id=_character.id;
    characterType=_character.characterType;
    rank=_character.rank;
    star=_character.star;
    exp=_character.exp;
    isDeleted=_character.isDeleted;
  }

  function encode(Character memory character) public pure returns (uint256) {
  // function encode(Character memory character)  external view returns  (uint256) {
    uint256 value;
    value = uint256(character.id);
    value |= character.id << 100;
    value |= character.characterType << 148;
    value |= character.rank << 164;
    value |= character.star << 180;
    value |= character.exp << 196;
    value |= character.isDeleted << 228;
    return value;
  }



  function initByOwner(address _academyUpStar, address _evolutionUpRank,  address _characterMarketPlace, address _boxNFT) public onlyOwner{
    academyUpStar=_academyUpStar;
    evolutionUpRank=_evolutionUpRank;
    characterMarketPlace=_characterMarketPlace;
    boxNFT=_boxNFT;
  }

  function getCharacterOfSender(address sender) external view returns (Character[] memory ) {
        uint range=_tokenIds.current();
        uint i=1;
        uint index=0;
        uint x=0;
        for(i; i <= range; i++){
          Character memory character = getCharacter(sender,i);
          if(character.id !=0){
            index++;
          }
        }
        Character[] memory result = new Character[](index);
        i=1;
        for(i; i <= range; i++){
          Character memory character = getCharacter(sender,i);
          if(character.id !=0){
            result[x] = character;
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
        if(msg.sender != characterMarketPlace){
          require(_target == characterMarketPlace, "function only support for Marketplace");
          require(msg.sender != _target, "Can not transfer myself");
        }
        Character memory character= getCharacter(ownerOf(_nftId),_nftId);
        // star will start = 1, exp will start = 0
        // character.star=1;
        // character.exp=0;

        characters[_target][_nftId] = encode(character);
        characters[ownerOf(_nftId)][_nftId]= encode(Character(0,0,0,0,0,0));
        characterIndexToOwner[_nftId]=_target;
        _transfer(ownerOf(_nftId), _target, _nftId);
    }

  function transferFrom(
        address from,
        address to,
        uint256 tokenId 
    )
        public  virtual override  whenNotPaused 
    {
      
        require(isTransfer == true, "Can not transfer");
        require(_exists(tokenId ), "Non existed NFT");
        require(ownerOf(tokenId ) == from, "Only owner NFT can transfer");
        require(from != to, "Can not transfer myself");
        require(
            ownerOf(tokenId ) == msg.sender || getApproved(tokenId ) == msg.sender,
            "Not approved"
        );
        require(to != address(0), "Invalid address");

        Character memory character= getCharacter(from,tokenId );
        characters[to][tokenId ] = encode(character);
        characters[from][tokenId ]= encode(Character(0,0,0,0,0,0));
        characterIndexToOwner[tokenId ]=to;
        _transfer(from, to, tokenId );
    }

  function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(isTransfer == true, "Can not transfer");
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        require(from != to, "Can not transfer myself");
        Character memory character= getCharacter(from,tokenId );
        characters[to][tokenId ] = encode(character);
        characters[from][tokenId ]= encode(Character(0,0,0,0,0,0));
        characterIndexToOwner[tokenId ]=to;
        _safeTransfer(from, to, tokenId, _data);
    }  

  function approveMarketPlace(address to, uint256 tokenId) external onlyCharacterMarketPlaceOrOwner {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
         _approve(to,tokenId);
  }

  function approveEvolutionUpRank(address to, uint256 tokenId) external onlyEvolutionUpRankOrOwner {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
         _approve(to,tokenId);
  }

  function createCharacterWhileList(address[] memory owners,uint256 characterType) public onlyOwner {
        for (uint i=0; i<owners.length; i++) {
        _tokenIds.increment();
        uint256 newCharacterId = _tokenIds.current();
        _safeMint(owners[i], newCharacterId);
        characters[owners[i]][newCharacterId] = encode(Character(newCharacterId,characterType,1,1,0,0)); // 1,2,3,7
        characterIndexToOwner[newCharacterId]=owners[i];
        }
    }

function updateCharacterIndexToOwner(uint256 nftId,address owner) public onlyOwner  {
        characterIndexToOwner[nftId]= owner;
    }

  function setVersion(uint256 _version) public onlyOwner {
    version=_version;
  }

  function setBoxNFT(address _boxNFT) public onlyOwner{
    boxNFT=_boxNFT;
  }  

  function setEvolutionUpRank(address _evolutionUpRank) public onlyOwner{
    evolutionUpRank=_evolutionUpRank;
  }  

  function setAcademyUpStar(address _academyUpStar) public onlyOwner{
    academyUpStar=_academyUpStar;
  }

  function setCharacterMarketPlace(address _characterMarketPlace) public onlyOwner{
    characterMarketPlace=_characterMarketPlace;
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

    string public baseURI;
    using StringsUpgradeable for uint256;
    function setBaseURI(string memory _baseURI) public onlyOwner{
      baseURI=_baseURI;
    }  
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        address sender=ownerOf(tokenId);
        Character memory character = getCharacter(sender,tokenId);
        string memory json=".json";
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI,character.characterType.toString(),"_",character.rank.toString(),json))  : "";
    }

  function setOperator(address _operator) public onlyOwner{
    operator = _operator;
    }  


   address public operator;
    modifier onlyOperatorOrOwner {
      require(msg.sender == operator || msg.sender == owner());
      _;
    }

    bool isTransfer;
    function setIsTransfer(bool _isTransfer) public onlyOwner{
    isTransfer=_isTransfer;
  }

  IBEP20 public token;
  function setIBEP20(address _tokenBEP20) public onlyOwner{
        token = IBEP20(_tokenBEP20);
  }
  function withdrawToken() external onlyOwner {
        uint256 _balance = token.balanceOf(address(this));
        token.transfer(msg.sender, _balance);
    }

  mapping (uint256 => uint256) public feeTransferByRank;
  function setFeeTransferByRank(uint256 rank,uint256 feeTransfer) public onlyOwner{
    feeTransferByRank[rank]= feeTransfer;
  }  
  function getFeeTransferByRank(uint256 rank) external view returns (uint256  _feeTransfer){
    _feeTransfer = feeTransferByRank[rank];
  } 

  function transferWithCost(uint256 _nftId, address _target, uint256 _fee)
        external whenNotPaused
    {
        require(_exists(_nftId), "Non existed NFT");
        require(
            ownerOf(_nftId) == msg.sender || getApproved(_nftId) == msg.sender,
            "Not approved"
        );
        require(_target != address(0), "Invalid address");
        if(msg.sender != characterMarketPlace){
          require(msg.sender != _target, "Can not transfer myself");
        }
        
        Character memory character= getCharacter(ownerOf(_nftId),_nftId);

        token.approve(address(this),_fee);
        token.transferFrom(msg.sender, address(this), _fee);

        require(feeTransferByRank[character.rank] == _fee, "Fee not correct");

        characters[_target][_nftId] = encode(character);
        characters[ownerOf(_nftId)][_nftId]= encode(Character(0,0,0,0,0,0));
        characterIndexToOwner[_nftId]=_target;
        _transfer(ownerOf(_nftId), _target, _nftId);
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
// import "./sol";

contract DiceNFT is ERC721Upgradeable, ERC721BurnableUpgradeable, OwnableUpgradeable, PausableUpgradeable {
    using MathUpgradeable for uint256;
    using MathUpgradeable for uint48;
    using MathUpgradeable for uint32;
    using MathUpgradeable for uint16;
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter public _tokenIds;
    struct Dice {
        uint256 id;
        uint256 diceType;
        // uint256[] abilities;
    }
    
    mapping(address => mapping(uint256 => uint256)) public dices;// address - id - details // cach lay details = dices[address][diceId]

    address public boxNFT;
    modifier onlyBoxNFTOrOperatorOrOwner {
      require(msg.sender == boxNFT || msg.sender == owner()|| msg.sender == operator);
      _;
    }
    
    address public diceMarketPlace;
    modifier onlyDiceMarketPlaceOrOwner {
      require(msg.sender == diceMarketPlace || msg.sender == owner());
      _;
    }
    
    // namely the ERC721 instances for name symbol decimals etc
    function initialize() public initializer {
        __ERC721_init("Dice NFT BPLUS", "DINB");
        __Ownable_init();
    }

    function initByOwner(address _diceMarketPlace, address _boxNFT) public onlyOwner{
      diceMarketPlace=_diceMarketPlace;
      boxNFT=_boxNFT;
    }
    event logCreateRandomThreeDice(uint256 nftId, uint256 diceType);
    
    function createDice(address owner,uint256 diceType) public onlyBoxNFTOrOperatorOrOwner whenNotPaused returns (uint256) {
        _tokenIds.increment();
        uint256 newDiceId = _tokenIds.current();
        _safeMint(owner, newDiceId);
        dices[owner][newDiceId] = encode(Dice(newDiceId,diceType));
        diceIndexToOwner[newDiceId ]=owner;
        return newDiceId;
    }

    function updateDice(address owner,uint256 nftId, uint256 id, uint256 diceType) public onlyOperatorOrOwner returns (uint256) {
        dices[owner][nftId] = encode(Dice(id,diceType));
        return nftId;
    }


    // function createRandomThreeDice(address owner) public {
    //     for (uint i=0; i<3; i++) {
    //     _tokenIds.increment();
    //     uint256 newDiceId = _tokenIds.current();
    //     //we can call mint from the ERC721 contract to mint our nft token
    //     // _safeMint(msg.sender, newDiceId);
    //     _safeMint(owner, newDiceId);
        
    //     uint256 value = uint256(newDiceId*block.timestamp);
    //     uint256 diceTypeRandom = (value << 30+i*2)%10+1;

    //     emit logCreateRandomThreeDice(newDiceId,diceTypeRandom);
    //     dices[owner][newDiceId] = encode(Dice(newDiceId,diceTypeRandom));
    //     }
    // }

    function getDice(address owner, uint256 id) public view returns (Dice memory _dice) {
      uint256 details= dices[owner][id];
      _dice.id = uint256(uint48(details>>100));
      _dice.diceType = uint256(uint16(details>>148));
    }
  
  function getDicePublic(address _owner, uint256 _id) public view returns (
          uint256 id,
          uint256 diceType) {
      Dice memory _dice= getDice(_owner,_id);
      id=_dice.id;
      diceType=_dice.diceType;
    }

  function encode(Dice memory dice) public pure returns (uint256) {
    // function encode(Dice memory dice)  external view returns  (uint256) {
      uint256 value;
      value = uint256(dice.id);
      value |= dice.id << 100;
      value |= dice.diceType << 148;
      return value;
  }

  function getDiceOfSender(address sender) external view returns (Dice[] memory ) {
        uint range=_tokenIds.current();
        uint i=1;
        uint index=0;
        uint x=0;
        for(i; i <= range; i++){
          Dice memory dice = getDice(sender,i);
          if(dice.id !=0){
            index++;
          }
        }
        Dice[] memory result = new Dice[](index);
        i=1;
        for(i; i <= range; i++){
          Dice memory dice = getDice(sender,i);
          if(dice.id !=0){
            result[x] = dice;
            x++;
          }
        }
        return result;
  }

  function transfer(uint256 _nftId, address _target)
        external
    {
        require(_exists(_nftId), "Non existed NFT");
        require(
            ownerOf(_nftId) == msg.sender || getApproved(_nftId) == msg.sender,
            "Not approved"
        );
        require(_target != address(0), "Invalid address");
        if(msg.sender != diceMarketPlace){
          require(msg.sender != _target, "Can not transfer myself");
        }
        Dice memory dice= getDice(ownerOf(_nftId),_nftId);
        // star will start = 1, exp will start = 0
        dices[_target][_nftId] = encode(dice);
        dices[ownerOf(_nftId)][_nftId]= encode(Dice(0,0));
        diceIndexToOwner[_nftId]=_target;
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
        require(from != to, "Can not transfer myself");
        require(ownerOf(tokenId ) == from, "Only owner NFT can transfer");
        require(
            ownerOf(tokenId ) == msg.sender || getApproved(tokenId ) == msg.sender,
            "Not approved"
        );
        require(to != address(0), "Invalid address");

        Dice memory dice= getDice(from,tokenId );
        dices[to][tokenId ] = encode(dice);
        dices[from][tokenId ]= encode(Dice(0,0));
        diceIndexToOwner[tokenId ]=to;
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
        Dice memory dice= getDice(from,tokenId );
        dices[to][tokenId ] = encode(dice);
        dices[from][tokenId ]= encode(Dice(0,0));
        diceIndexToOwner[tokenId ]=to;
        _safeTransfer(from, to, tokenId, _data);
    }  

  function approveMarketPlace(address to, uint256 tokenId) external onlyDiceMarketPlaceOrOwner {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
         _approve(to,tokenId);
  }

  function setBoxNFT(address _boxNFT) public onlyOwner{
    boxNFT=_boxNFT;
  }  

  function setDiceMarketPlace(address _diceMarketPlace) public onlyOwner{
    diceMarketPlace=_diceMarketPlace;
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

     string public baseURI;
    using StringsUpgradeable for uint256;
    function setBaseURI(string memory _baseURI) public onlyOwner{
      baseURI=_baseURI;
    }  
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        address sender=ownerOf(tokenId);
        Dice memory dice = getDice(sender,tokenId);
        string memory json=".json";
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI,dice.diceType.toString(),json))  : "";
    }

    mapping (uint256 => address) public diceIndexToOwner;  
    function updateDiceIndexToOwner(uint256 nftId,address owner) public onlyOwner  {
        diceIndexToOwner[nftId]= owner;
    }

    function setOperator(address _operator) public onlyOwner{
    operator = _operator;
    }  

   address public operator;
    modifier onlyOperatorOrOwner {
      require(msg.sender == operator || msg.sender == owner());
      _;
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

contract Utils is OwnableUpgradeable, PausableUpgradeable  {
    uint256 randomNumber;
    uint256 privateNumber;
    function initialize() public initializer {
       randomNumber=2204;
       privateNumber=97531;
      __Ownable_init();
    }

    function random(uint256 from, uint256 to) public whenNotPaused view returns (uint256 number) {
        require(to > from, "Not correct input");
        uint256 tmp1  = block.timestamp<<10 % 1245;
        uint256 tmp2  = block.timestamp<<20 % 6789;
        uint256 tmp3  = uint(keccak256(abi.encodePacked(block.timestamp,randomNumber,msg.sender)))%3333;
        uint256 tmp4= uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,randomNumber))) % randomNumber;
        number = from + ((tmp1 +tmp2 +tmp3 + tmp4 )  % (to-from+1));
        if(number < to-2 && number> 10){
           number = number - 3;
        }
    }


   // function randomV2(uint256 from, uint256 to, uint256 r) public whenNotPaused view returns (uint256 number) {
   //      require(to > from, "Not correct input");
   //      uint256 tmp1  = block.timestamp<<10 % 1245;
   //      uint256 tmp2  = block.timestamp<<20 % 6789;
   //      uint256 tmp3  = uint(keccak256(abi.encodePacked(block.timestamp,randomNumber,msg.sender)))%3333;
   //      uint256 tmp4= uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,randomNumber))) % randomNumber;
   //      number = from + ((tmp1 +tmp2 +tmp3 + tmp4 )  % (to-from+1));
   //      if(number<to && number> r){
   //         number = number - r;
   //      }
   //  }

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

   function setSub(uint256 _privateNumber) public onlyOwner  {
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