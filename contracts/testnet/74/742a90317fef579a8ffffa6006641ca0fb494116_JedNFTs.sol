// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "ERC721.sol";
import "ERC721URIStorage.sol";
import "Ownable.sol";
import "Counters.sol";
interface IBEP20 {
    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract JedNFTs is IERC721, ERC721URIStorage, Ownable {
  //Index of next token to be minted
  uint256 private _currentIndex;

  // Token name
  string private _name;

  // Token symbol
  string private _symbol;

  //Sale status
  bool public preSaleOn = false;
  bool public publicSaleOn = false;

  //Transfer permissions
  bool public transfersAllowed = true;

  //Set JED token address
  IBEP20 public jedToken = IBEP20(0x058a7Af19BdB63411d0a84e79E3312610D7fa90c);
  //Set KRED token address
  IBEP20 public kredToken = IBEP20(0xeA79d3a3a123C311939141106b0A9B1a5623696f);
  //Transaction coins
  address[5] public coins = [
      0x55d398326f99059fF775485246999027B3197955, // USDT
      0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3, // DAI
      0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56, // BUSD
      0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d, // USDC
      0x071549f11ade1044d338A66ABA6fA1903684Bec9 //0xeA79d3a3a123C311939141106b0A9B1a5623696f // KRED
  ];

  //NFT properties
  struct Character {
    uint8 characterIndex;
    uint8 characterTier;
    uint8[5] properties;
    uint256 lastGenTime;
  }
  //The mapping of token ID to defined characters
  mapping(uint256 => Character) public tokenIdToCharacter;

  //mapping of token ID to wallet owner
  mapping(uint256 => address) public ownershipMap;

  //Limited edition NFT tier limits
  uint16[5] public nftLimits = [
    20,
    50,
    500,
    5000,
    10000
  ];

  //Character names
  string[3] public characters = [
    "Jed",
    "Alliyah",
    "Raptor"
  ];

  //total mints per character and tier
  uint16[5][3] public nftMints;

  //Cost per tier
  uint256[5] public kredCostPerTier;
  uint256[5] public stableCostPerTier;

  //Per address mint volume map
  mapping (address => uint256) public totalPerAccount;

  //Max per account during presale
  uint16 public presaleBuyLimit = 5;

  constructor() ERC721("Jedstar First Mint Limited Edition", "JEDNFT1") {
      _name = "Jedstar First Mint Limited Edition";
      _symbol = "JEDNFT1";
      _currentIndex = 1;
      nftMints = [
        [0,0,0,0,0],
        [0,0,0,0,0],
        [0,0,0,0,0]
      ];
  }

  function setCostPerTier (
    bool stableCoin,
    uint256[5] memory _tierCosts
  ) public onlyOwner{
    require ( _tierCosts.length == 5, "There must be exactly 5 elements in the array");
    for (uint8 i = 0; i < 5; i++){
      require(_tierCosts[i] > 0, "Tier costs must be greater than zero");
    }
    if (stableCoin){
      stableCostPerTier = _tierCosts;
    }else{
      kredCostPerTier = _tierCosts;
    }
  }

  /**
   * @dev Hook that is called before a set of serially-ordered token ids are about to be transferred.
   * This includes minting.
   * And also called before burning one token.
   *
   * startTokenId - the first token id to be transferred
   *
   * Calling conditions:
   *
   * - When `from` and `to` are both non-zero, `from`'s `tokenId` will be
   * transferred to `to`.
   * - When `from` is zero, `tokenId` will be minted for `to`.
   * - When `to` is zero, `tokenId` will be burned by `from`.
   * - `from` and `to` are never both zero.
   */
  function _beforeTokenTransfers(
      address from,
      address to,
      uint256 tokenId
  ) internal virtual {
    require(transfersAllowed, "Transfers are currently disallowed");
  }

    /**
     * @dev Hook that is called after a set of serially-ordered token ids have been transferred.
     * This includes minting.
     * And also called after one token has been burned.
     *
     * tokenId - the token id to be transferred
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, `from`'s `tokenId` has been
     * transferred to `to`.
     * - When `from` is zero, `tokenId` has been minted for `to`.
     * - When `to` is zero, `tokenId` has been burned by `from`.
     * - `from` and `to` are never both zero.
     */
    function _afterTokenTransfers(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
      //update the ownership map
      ownershipMap[tokenId] = to;
    }

  /*

  On mint:
    - set character number
    - set tier number
    - make random properties
    - increase count of totalMinted for this category
    -

  */

  /**
   * @dev Returns the starting token ID.
   * To change the starting token ID, please override this function.
   */
  function _startTokenId() internal view virtual returns (uint256) {
      return 1;
  }

  function _nextTokenId() internal view returns (uint256) {
    return _currentIndex;
  }

  /**
   * @dev Regenerates the character properties
   *
   **/
  function regenProperties(uint256 _tokenId) public {
    require(_tokenId < _currentIndex, "Token ID does not exist");
    require(msg.sender == ownershipMap[_tokenId], "You must be the owner of the character to use this function");
    require(block.timestamp - tokenIdToCharacter[_tokenId].lastGenTime > 3 days, "You must wait at least 3 days before you can regen your character");

    if (block.timestamp - tokenIdToCharacter[_tokenId].lastGenTime > 30 days){
      require(jedToken.balanceOf(msg.sender) >= 10000e18, "You need at least 10k JED tokens to regen your character");
    }
    if (block.timestamp - tokenIdToCharacter[_tokenId].lastGenTime <= 30 days){
      require(jedToken.balanceOf(msg.sender) >= 15000e18, "You need at least 15k JED tokens to regen your character under 30 days");
    }
    if (block.timestamp - tokenIdToCharacter[_tokenId].lastGenTime <= 14 days){
      require(jedToken.balanceOf(msg.sender) >= 20000e18, "You need at least 20k JED tokens to regen your character under 14 days");
    }
    if (block.timestamp - tokenIdToCharacter[_tokenId].lastGenTime <= 7 days){
      require(jedToken.balanceOf(msg.sender) >= 25000e18, "You need at least 25k JED tokens to regen your character under 7 days");
    }

    //TODO do some actual regen here, but for now, just increase the first prop by 1
    tokenIdToCharacter[_tokenId].properties[0]++;

    tokenIdToCharacter[_tokenId].lastGenTime = block.timestamp;
  }

  function mint(uint8 _characterId, uint8 _tierId, uint8 _coinChoice, address _to) public payable {
    require(preSaleOn, "Sale has not started");
    if (!publicSaleOn){
      require(jedToken.balanceOf(msg.sender) >= 10000e18, "You need at least 10k JED tokens to mint");
      require(totalPerAccount[_to] < presaleBuyLimit, "Max on this account exceeded for presale");
    }

    require(_characterId < characters.length, "Invalid character ID reference");
    require(_tierId < nftLimits.length, "Invalid tier ID reference");
    require(_coinChoice < coins.length, "Invalid coin ID reference");

    uint256 total = nftMints[_characterId][_tierId];
    require(total < nftLimits[_tierId] , "The maximum number has been minted for this category");

    uint256 coinCost;
    if (_coinChoice == coins.length - 1){
      //the last coin in the array is assumed to be KRED
      coinCost = kredCostPerTier[_tierId];
    }else{
      coinCost = stableCostPerTier[_tierId];
    }
    uint256 coinDecimals = 10**IBEP20(coins[_coinChoice]).decimals();
    IBEP20(coins[_coinChoice]).transferFrom(
      msg.sender,
      owner(),
      coinCost * coinDecimals
    );

    //Define the unique properties of this NFT and write it
    Character memory myCharacter;
    myCharacter.characterIndex = _characterId;
    myCharacter.characterTier = _tierId;
    myCharacter.properties = [1,1,1,1,1];
    myCharacter.lastGenTime = block.timestamp;
    tokenIdToCharacter[_currentIndex] = myCharacter;

     _mint(_to);

   }

   /**
    * @dev Mints one token and transfers it to `to`.
    *
    * Requirements:
    *
    * - `to` cannot be the zero address.
    *
    * Emits a {Transfer} event for each mint.
    */
   function _mint(address to) internal {
       require (to != address(0), "Cannot mint to the zero address");

       _beforeTokenTransfers(address(0), to, _currentIndex);

       // Overflows are incredibly unrealistic.
       // `balance` and `numberMinted` have a maximum limit of 2**64.
       // `tokenId` has a maximum limit of 2**256.
       unchecked {
         totalPerAccount[to]++;
         emit Transfer(address(0), to, _currentIndex++);
       }
       _afterTokenTransfers(address(0), to, _currentIndex-1);
   }

   /**
    * @dev Transfers `tokenId` from `from` to `to`.
    *
    * Requirements:
    *
    * - `to` cannot be the zero address.
    * - `tokenId` token must be owned by `from`.
    *
    * Emits a {Transfer} event.
    */
   function transferFrom (
       address from,
       address to,
       uint256 tokenId
   ) public virtual override(ERC721, IERC721) {
     require(tokenId < _currentIndex, "Token ID does not exist");
     _beforeTokenTransfers(from, to, tokenId);

     require(ownershipMap[tokenId] == from, "From Address is not currently the known owner");

     emit Transfer(from, to, tokenId);
     _afterTokenTransfers(from, to, tokenId);

   }

   // Provide methods to extract tokens accidentally transferred to the contract
   function withdrawToken(uint8 _coinId, uint256 _value) external onlyOwner {
     require(_coinId < coins.length, "Invalid token reference");
     IBEP20(coins[_coinId]).transfer(owner(), _value);
   }
   function withdrawBNB(uint256 _value) external onlyOwner {
       payable(owner()).transfer(_value);
   }
   function withdrawAltToken(address _coin, uint256 _value) external onlyOwner {
       IBEP20(_coin).transfer(owner(), _value);
   }

   // Provide owner ways to start and stop sales from the contract
   function setSale(bool preIsOn, bool publicIsOn) public onlyOwner{
     preSaleOn = preIsOn;
     publicSaleOn = publicIsOn;
   }

   // Allow owner to cap pre-sale purchase volumes
   function setPresaleBuyLimit(uint16 _bl) public onlyOwner{
       presaleBuyLimit = _bl;
   }

   // Return the number of NFTs minted per character x tier
   function getMintCount(uint8 _characterId, uint8 _tierId) public view returns (uint16){
     require(_characterId < nftMints.length, "Character ID not recognised");
     require(_tierId < nftMints[_characterId].length, "Tier ID not recognised");
     return (nftMints[_characterId][_tierId]);
   }

   // Provide functions to easily retrieve NFT characteristics
   function getCharacterNameFromIndex(uint8 _idx) public view returns (string memory){
     require(_idx < characters.length, "Token ID not recognised");
     return characters[_idx];
   }
   function getCharacterIndex(uint256 _tokenID) public view returns (uint8) {
     require(_tokenID < _currentIndex, "Token ID not recognised");
     return tokenIdToCharacter[_tokenID].characterIndex;
   }
   function getCharacterTier(uint256 _tokenID) public view returns (uint8) {
     require(_tokenID < _currentIndex, "Token ID not recognised");
     return tokenIdToCharacter[_tokenID].characterTier;
   }
   function getCharacterProperties(uint256 _tokenID) public view returns (uint8[5] memory) {
     require(_tokenID < _currentIndex, "Token ID not recognised");
     return tokenIdToCharacter[_tokenID].properties;
   }
   function getCharacterLastGenTime(uint256 _tokenID) public view returns (uint256) {
     require(_tokenID < _currentIndex, "Token ID not recognised");
     return tokenIdToCharacter[_tokenID].lastGenTime;
   }
   
}