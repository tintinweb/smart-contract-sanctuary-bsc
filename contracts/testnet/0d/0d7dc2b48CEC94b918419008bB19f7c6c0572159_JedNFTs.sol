// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
import "ERC721.sol";
import "ERC721URIStorage.sol";
import "Ownable.sol";

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
  uint256 private _counter;

  //Sale status
  bool public preSaleOn = false;
  bool public publicSaleOn = false;

  //Transfer permissions
  bool public transfersAllowed = true;

  //Set JED token address
  address public jedCoin = 0x058a7Af19BdB63411d0a84e79E3312610D7fa90c;
  //Set KRED token address
  address public kredCoin = 0xeA79d3a3a123C311939141106b0A9B1a5623696f;

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
  mapping(uint256 => address) private _owners;

  // Mapping owner address to token count
  mapping(address => uint256) private _balances;

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
  mapping(address => uint256[5]) coinCostPerTier;

  //Per address mint volume map
  mapping (address => uint256) public totalPerAccount;

  //Max per account during presale
  uint16 public presaleBuyLimit = 5;

  constructor() ERC721("Jedstar First Mint Limited Edition", "JEDNFT1") {
    nftMints = [
      [0,0,0,0,0],
      [0,0,0,0,0],
      [0,0,0,0,0]
    ];
    coinCostPerTier[0x55d398326f99059fF775485246999027B3197955] = [1,2,3,4,5]; //USDT
    coinCostPerTier[0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3] = [1,2,3,4,5]; //DAI
    coinCostPerTier[0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56] = [1,2,3,4,5]; //BUSD
    coinCostPerTier[0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d] = [1,2,3,4,5]; //USDC
    coinCostPerTier[0x071549f11ade1044d338A66ABA6fA1903684Bec9] = [10,9,8,7,6]; //KREDT 0xeA79d3a3a123C311939141106b0A9B1a5623696f, [10,9,8,7,6] //KRED
    _counter = 1;
  }

  function mint(uint8 _characterId, uint8 _tierId, address _coin, address _to) public returns (uint256) {
    require(preSaleOn, "Sale has not started");
    if (!publicSaleOn){
      require(IBEP20(jedCoin).balanceOf(msg.sender) >= 10000e18, "You need at least 10k JED tokens to mint");
      require(totalPerAccount[_to] < presaleBuyLimit, "Max on this account exceeded for presale");
    }

    require(_characterId < characters.length, "Invalid character ID reference");
    require(_tierId < nftLimits.length, "Invalid tier ID reference");
    require(coinCostPerTier[_coin][0] > 0, "Coin is not supported");

    require(nftMints[_characterId][_tierId] < nftLimits[_tierId] , "The maximum number has been minted for this category");

    uint256 coinCost = coinCostPerTier[_coin][_tierId];
    uint256 coinDecimals = 10**IBEP20(_coin).decimals();
    IBEP20(_coin).transferFrom(
      msg.sender,
      owner(),
      coinCost * coinDecimals
    );
    uint256 newItemId = _counter;

    //Define the unique properties of this NFT and write it
    Character memory myCharacter;
    myCharacter.characterIndex = _characterId;
    myCharacter.characterTier = _tierId;
    myCharacter.properties = [1,1,1,1,1];
    myCharacter.lastGenTime = block.timestamp;
    tokenIdToCharacter[newItemId] = myCharacter;


    nftMints[_characterId][_tierId]++;
    _mint(_to, newItemId);
    _setTokenURI(newItemId, string(abi.encodePacked("https://assets.jedstar.space/nft/jednft1-", Strings.toString(_characterId), "-", Strings.toString(_tierId), ".json")));
    _counter++;
    return newItemId;
   }

  /**************************************
   *** Custom functions for JED NFTs ****
   **************************************/

  /**
    * @dev Allows contract owner to specify the cost of each NFT tier for a specific coin type.
    *
    * Requirements:
    *
    * - '_coin' must already exist as a supported coin
    * - `_tierCosts` must be an array of ints 5 in length.
    *
    */
  function setCostPerTier (
    address _coin,
    uint256[5] memory _tierCosts
  ) public onlyOwner{
    require ( _tierCosts.length == 5, "There must be exactly 5 elements in the array");
    for (uint8 i = 0; i < 5; i++){
      require(_tierCosts[i] > 0, "Tier costs must be greater than zero");
    }
    require(coinCostPerTier[_coin][0] > 0, "Coin must be supported before prices can be updated");

    coinCostPerTier[_coin] = _tierCosts;
  }
  function getCostPerTier (
      address _coin
  ) public view returns (uint256[5] memory) {
      require (coinCostPerTier[_coin][0] > 0, "The requested coin is not supported");
      return coinCostPerTier[_coin];
  }

  function setJEDToken (address _jedCoin) public onlyOwner{
      jedCoin = _jedCoin;
  }
  function setKREDToken (address _kredCoin) public onlyOwner{
      kredCoin = _kredCoin;
  }
  function setAcceptedCoins (address[] memory _coins, uint256[5][] memory _costs) public onlyOwner{
    require (_coins.length > 0, "At least one coin must be specified");
    require (_coins.length == _costs.length, "You must provide costs for each coin that will be supported");
    /*for (uint16 i = 0; i < _costs.length; i++){
      //Check for length 5?
    }*/
    for (uint16 i = 0; i < _coins.length; i++){
        coinCostPerTier[_coins[i]] = _costs[i];
    }
  }
  function setRejectedCoins (address[] memory _coins) public onlyOwner{
    require(_coins.length > 0, "At least one coin must be specified");
    for (uint16 i = 0; i < _coins.length; i++){
        //set the cost to zero as this will result in the coin mint being rejected
        coinCostPerTier[_coins[i]] = [0,0,0,0,0];
    }
  }

  /**
   * @dev Regenerates the character properties if the NFT owner has enough JED
   *
   * Requirements:
   *
   * - There is a minimum time between regens which is based on how much JED is held by the user.
   *
   **/
  function regenProperties(uint256 _tokenId) public {
    require(_tokenId < _counter, "Token ID does not exist");
    require(msg.sender == ownerOf(_tokenId), "You must be the owner of the character to use this function");
    require(block.timestamp - tokenIdToCharacter[_tokenId].lastGenTime > 3 days, "You must wait at least 3 days before you can regen your character");

    IBEP20 jedToken = IBEP20(jedCoin);

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

    //Bill one dollar equiv in KRED for this fn
    uint256 coinCost = 1;
    uint256 coinDecimals = 10**IBEP20(kredCoin).decimals();
    IBEP20(kredCoin).transferFrom(
      msg.sender,
      owner(),
      coinCost * coinDecimals
    );
    //TODO do some actual regen here, but for now, just increase the first prop by 1
    tokenIdToCharacter[_tokenId].properties[0]++;

    tokenIdToCharacter[_tokenId].lastGenTime = block.timestamp;
  }



  // Provide methods to extract tokens accidentally transferred to the contract
  function withdrawBNB(uint256 _value) external onlyOwner {
    payable(owner()).transfer(_value);
  }
  function withdrawAltCoin(address _coin, uint256 _value) external onlyOwner {
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
    require(_tokenID < _counter, "Token ID not recognised");
    return tokenIdToCharacter[_tokenID].characterIndex;
  }
  function getCharacterTier(uint256 _tokenID) public view returns (uint8) {
    require(_tokenID < _counter, "Token ID not recognised");
    return tokenIdToCharacter[_tokenID].characterTier;
  }
  function getCharacterProperties(uint256 _tokenID) public view returns (uint8[5] memory) {
    require(_tokenID < _counter, "Token ID not recognised");
    return tokenIdToCharacter[_tokenID].properties;
  }
  function getCharacterLastGenTime(uint256 _tokenID) public view returns (uint256) {
    require(_tokenID < _counter, "Token ID not recognised");
    return tokenIdToCharacter[_tokenID].lastGenTime;
  }
}