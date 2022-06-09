// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./Constants.sol";
import "./interfaces/INftMinter.sol";

contract Sale is Ownable, ReentrancyGuard{
  using SafeERC20 for IERC20;
  using SafeMath for uint256;
  
  //address constant private BUSD_CONTRACT_ADDRESS = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // BUSD on mainnet
  //address constant AIR_NFT_ADDRESS = 0xF5db804101d8600c26598A1Ba465166c33CdAA4b; // AirNfts on mainnet
  //address constant HAPPY_COW_ADDRESS = 0xf470C4B8564B1069E34Eaf00B26e6892A5391d80; // HappyCow NFTs on mainnet

  address constant BUSD_CONTRACT_ADDRESS = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; // Fake BUSD on testnet, For TEST
  address constant AIR_NFT_ADDRESS = 0x74A9Bb4F6b05236507614cA70d32f65436064786; // Fake AirNfts on testnet, For TEST
  address constant HAPPY_COW_ADDRESS = 0xD220d3E1bab3A30f170E81b3587fa382BB4A6263; // Fake HappyCow NFTs on testnet, For TEST
  
  

  // Timestamp to start NFT Pack Sale
  uint public packSaleStart;
  // Timestamp to finish NFT Pack Sale
  uint public packSaleEnd;

  // NftMinter contract address
  address public minter;

  // Prices of NFT Packs by rarity
  mapping(Constants.Rarity => uint) public packPrices;

  // Price of Individual Land NFT (random rarity)
  uint public landPrice;
  // Price of Individual Cow NFT (Common rarity)
  uint public cowPrice;
  // Price of Individual Bull NFT (Common rarity)
  uint public bullPrice;

  //mapping(address => uint8) public whitelisted;
  mapping(address => mapping(uint8 => uint)) public whitelisted;

  // Supply of Land NFTs by rarity and type
  // Total supply of Land NFTs is 160, 000
  mapping(uint8 => mapping(uint8 => uint)) public landSupply;

  event LandBought(address owner);
  event CowBought(address owner);
  event BullBought(address owner);
  event CommonPackBought(address owner);
  event UncommonPackBought(address owner);
  event RarePackBought(address owner);
  event FreeCommonPackClaimed(address owner);
  event FreeUncommonPackClaimed(address owner);

  modifier onlyWhitelisted(uint8 _option) {
    require(whitelisted[msg.sender][_option] > 0, "Not whitelisted for NFT Pack");
    _;
  }

  function initialize(address _minter) public onlyOwner {
    require(_minter != address(0), "Minter contract must be non-zero address");

    // Set NFT Pack prices to 10, 15, 30 BUSD.
    packPrices[Constants.Rarity.COMMON] = 10*10**18;
    packPrices[Constants.Rarity.UNCOMMON] = 15*10**18;
    packPrices[Constants.Rarity.RARE] = 30*10**18;

    landPrice = 50*10**18;

    // Set total supply of Land by rarity and type
    landSupply[0][0] = 17000;
    landSupply[0][1] = 17000;
    landSupply[0][2] = 17000;
    landSupply[0][3] = 17000;
    landSupply[0][4] = 17000;

    landSupply[1][0] = 8000;
    landSupply[1][1] = 8000;
    landSupply[1][2] = 8000;
    landSupply[1][3] = 8000;
    landSupply[1][4] = 8000;

    landSupply[2][0] = 4000;
    landSupply[2][1] = 4000;
    landSupply[2][2] = 4000;
    landSupply[2][3] = 4000;
    landSupply[2][4] = 4000;

    landSupply[3][0] = 2000;
    landSupply[3][1] = 2000;
    landSupply[3][2] = 2000;
    landSupply[3][3] = 2000;
    landSupply[3][4] = 2000;

    landSupply[4][0] = 1000;
    landSupply[4][1] = 1000;
    landSupply[4][2] = 1000;
    landSupply[4][3] = 1000;
    landSupply[4][4] = 1000;

    minter = _minter;
  }

  function buyLand(uint256 _amount, uint256[] memory _seed) external {
    require(block.timestamp > packSaleEnd, "Pack Sale is not ended");
    _pay(msg.sender, landPrice * _amount);
    INftMinter minterContract = INftMinter(address(minter));
    for (uint256 i = 0 ; i< _amount; i++) {
      uint8 rarity = _rarityOfLandBySupply(_seed[i]);
      uint8 landType = _typeOfLandBySupply(rarity, _seed[i]);
      landSupply[rarity][landType] -= 1;
      minterContract.mintLand(msg.sender, (uint8)(rarity), landType);
    }
  }

  function buyCommonCow(uint256 _amount, uint256[] memory _seed) external {
    require(block.timestamp > packSaleEnd, "Pack Sale is not ended");

    _pay(msg.sender, cowPrice* _amount);
    INftMinter minterContract = INftMinter(address(minter));
    uint8 breed = 0;
    for(uint i = 0 ; i < _amount ; i ++) {
      breed = (uint8)(_rand(5, _seed[i]));
      minterContract.mintCow(msg.sender, (uint8)(Constants.Rarity.COMMON), breed);
    }
  }

  function buyCommonBull(uint256 _amount, uint256[] memory _seed) external {
    require(block.timestamp > packSaleEnd, "Pack Sale is not ended");

    _pay(msg.sender, bullPrice * _amount);
    INftMinter minterContract = INftMinter(address(minter));
    uint8 breed = 0;
    for(uint i = 0 ; i < _amount; i++) {
      breed = (uint8)(_rand(5,_seed[i]));
      minterContract.mintBull(msg.sender, (uint8)(Constants.Rarity.COMMON), breed);
    }
  }

  function buyCommonPack(uint256 _seed) external onlyWhitelisted(0) {
    require(block.timestamp > packSaleStart, "Pack Sale is not started");
    require(block.timestamp < packSaleEnd, "Pack Sale ended");

    _pay(msg.sender, (packPrices[Constants.Rarity.COMMON]));
    whitelisted[msg.sender][0] -= 1;
    _mintNftPack((uint8)(Constants.Rarity.COMMON), _seed);

    emit CommonPackBought(msg.sender);
  }

  function buyUncommonPack(uint256 _seed) external onlyWhitelisted(1) {
    require(block.timestamp > packSaleStart, "Pack Sale is not started");
    require(block.timestamp < packSaleEnd, "Pack Sale ended");

    _pay(msg.sender, (packPrices[Constants.Rarity.UNCOMMON]));
    whitelisted[msg.sender][1] -= 1;
    _mintNftPack((uint8)(Constants.Rarity.UNCOMMON), _seed);

    emit UncommonPackBought(msg.sender);
  }

  function buyRarePack(uint256 _seed) external onlyWhitelisted(2) {
    require(block.timestamp > packSaleStart, "Pack Sale is not started");
    require(block.timestamp < packSaleEnd, "Pack Sale ended");

    _pay(msg.sender, (packPrices[Constants.Rarity.RARE]));
    whitelisted[msg.sender][2] -= 1;
    _mintNftPack((uint8)(Constants.Rarity.RARE), _seed);

    emit RarePackBought(msg.sender);
  }

  function getFreeCommonPack(uint256 _seed) external onlyWhitelisted(3) {
    require(block.timestamp > packSaleStart, "Pack Sale is not started");
    require(block.timestamp < packSaleEnd, "Pack Sale ended");
    whitelisted[msg.sender][3] -= 1;
    _mintNftPack((uint8)(Constants.Rarity.COMMON), _seed);

    emit FreeCommonPackClaimed(msg.sender);
  }

  function getFreeUncommonPack(uint256 _seed) external onlyWhitelisted(4) {
    require(block.timestamp > packSaleStart, "Pack Sale is not started");
    require(block.timestamp < packSaleEnd, "Pack Sale ended");
    whitelisted[msg.sender][4] -= 1;
    _mintNftPack((uint8)(Constants.Rarity.UNCOMMON), _seed);

    emit FreeUncommonPackClaimed(msg.sender);
  }

  /*
    _community values
    0: Common members. Farmers hold 1 $COW or more
    1: Uncommon members. Top 10k holders
    2: Rare members. Top 1k holders
    3: Legendary members. Top 100 holders.
    4: HappyCow NFT holders.
    5: Genesis NFT holders.
  */

  function whitelist(uint8 _community, address[] memory _farmers) public onlyOwner {
    require(_community < 6, "Community identifier must be 0~5");

    // Common members
    if(_community == 0) {
      for(uint8 idx = 0;idx < _farmers.length;idx ++) {
        whitelisted[_farmers[idx]][0] += 1;
      }
    }

    // Uncommon members
    if(_community == 1) {
      for(uint8 idx = 0;idx < _farmers.length;idx ++) {
        whitelisted[_farmers[idx]][0] += 1;
        whitelisted[_farmers[idx]][1] += 1;
      }
    }

    // Rare members
    if(_community == 2) {
      for(uint8 idx = 0;idx < _farmers.length;idx ++) {
        whitelisted[_farmers[idx]][0] += 1;
        whitelisted[_farmers[idx]][1] += 1;
        whitelisted[_farmers[idx]][2] += 1;
      }
    }

    // Legendary members
    if(_community == 3) {
      for(uint8 idx = 0;idx < _farmers.length;idx ++) {
        whitelisted[_farmers[idx]][0] += 1;
        whitelisted[_farmers[idx]][1] += 1;
        whitelisted[_farmers[idx]][2] += 1;
        whitelisted[_farmers[idx]][4] += 1;
      }
    }

    // HappyCow NFT holders
    if(_community == 4) {
      for(uint8 idx = 0;idx < _farmers.length;idx ++) {

        IERC721 happyCowNft = IERC721(address(HAPPY_COW_ADDRESS));
        uint nftAmount = happyCowNft.balanceOf(_farmers[idx]);
        whitelisted[_farmers[idx]][0] += nftAmount;
        whitelisted[_farmers[idx]][1] += nftAmount;
        whitelisted[_farmers[idx]][2] += nftAmount;
        whitelisted[_farmers[idx]][3] += nftAmount;
      }
    }

    // Genesis NFT holders
    if(_community == 5) {
      for(uint8 idx = 0;idx < _farmers.length;idx ++) {
        uint genesisAmount = _genesisAmountOf(_farmers[idx]);
        whitelisted[_farmers[idx]][0] += genesisAmount;
        whitelisted[_farmers[idx]][1] += genesisAmount;
        whitelisted[_farmers[idx]][2] += genesisAmount;
        whitelisted[_farmers[idx]][3] += genesisAmount;
        whitelisted[_farmers[idx]][4] += genesisAmount;
      }
    }
  }

  function setLandPrice(uint _price) external onlyOwner {
    landPrice = _price;
  }

  function setCowPrice(uint _price) external onlyOwner {
    cowPrice = _price;
  }

  function setBullPrice(uint _price) external onlyOwner {
    bullPrice = _price;
  }

  function setPackSalePeriod(uint _start, uint _end) external onlyOwner {
    require(_end > _start, "Start time is lower than end time");
    packSaleStart = _start;
    packSaleEnd = _end;
  }

  function setMinterContract(address _newMinter) external onlyOwner{
    require(_newMinter != address(0), "Minter contract must be non-zero address");
    minter = _newMinter;
  }

  function withdrawBusd() external onlyOwner {
    IERC20 payContract = IERC20(address(BUSD_CONTRACT_ADDRESS));
    uint amountOf = payContract.balanceOf(address(this));
    payContract.transfer(msg.sender, amountOf);
  }

  function _pay(address _farmer, uint _amount) private {
    IERC20(address(BUSD_CONTRACT_ADDRESS)).transferFrom(_farmer, address(this), _amount);
  }

  function _mintNftPack(uint8 _rarity, uint256 _seed) private {
    INftMinter minterContract = INftMinter(address(minter));
    uint8 rand = (uint8)(_rand(5, _seed));
    landSupply[_rarity][rand] -= 1;
    minterContract.mintLand(msg.sender, _rarity, rand);
    for(uint _idx = 0;_idx < 20;_idx ++){
      rand = (rand + 3) % 5;
      minterContract.mintCow(msg.sender, _rarity, rand);
    }
    rand = (rand + 3) % 5;
    minterContract.mintBull(msg.sender, _rarity, rand);
  }

  /*
    rand: Generate simplest random number by keccak, block.timestamp, msg.sender. Use your own risk.
  */
  function _rand(uint _modulus, uint256 _seed) internal view returns (uint) {
    // randNonce ++; 
    // return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % _modulus;

    return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, _seed))) % _modulus;
  }

  function _rarityOfLandBySupply(uint256 _seed) internal view returns (uint8) {
    uint[5] memory landSupplyByRarity;
    uint totalLandSupply = 0;
    for(uint8 idxOfRarity = 0; idxOfRarity < 5;idxOfRarity ++) {
      landSupplyByRarity[idxOfRarity] = 0;
      for(uint8 idxOfType = 0; idxOfType < 5; idxOfType ++) {
        landSupplyByRarity[idxOfRarity] += landSupply[idxOfRarity][idxOfType];
      }
      totalLandSupply += landSupplyByRarity[idxOfRarity];
    }
    require(totalLandSupply >0, "mintalbe amount is 0");
    uint rand = _rand(totalLandSupply, _seed);
    if(rand < landSupplyByRarity[0]) {
      return 0;
    }
    rand -= landSupplyByRarity[0];
    if(rand < landSupplyByRarity[1]) {
      return 1;
    }
    rand -= landSupplyByRarity[1];
    if(rand < landSupplyByRarity[2]) {
      return 2;
    }
    rand -= landSupplyByRarity[2];
    if(rand < landSupplyByRarity[3]) {
      return 3;
    }
    return 4;
  }

  function _typeOfLandBySupply(uint8 _rarity, uint256 _seed) internal view returns (uint8) {
    uint landSupplyByRarity = 0;
    for(uint8 idxOfType = 0; idxOfType < 5; idxOfType ++) {
      landSupplyByRarity += landSupply[_rarity][idxOfType];
    }

    uint rand = _rand(landSupplyByRarity, _seed);
    if(rand < landSupply[_rarity][0]) {
      return 0;
    }
    rand -= landSupply[_rarity][0];
    if(rand < landSupply[_rarity][1]) {
      return 1;
    }
    rand -= landSupply[_rarity][1];
    if(rand < landSupply[_rarity][2]) {
      return 2;
    }
    rand -= landSupply[_rarity][2];
    if(rand < landSupply[_rarity][3]) {
      return 3;
    }
    return 4;
  }

  // Get amount of Genesis NFTs of a farmer.
  function _genesisAmountOf(address _farmer) private view returns(uint) {
    uint24[100] memory genesisTokenIds = [
      99968,163083,163084,163085,181582,181583,181587,181589,181591,181593,
      202963,202980,202988,202989,202995,203001,203007,203010,203015,203019,
      203024,203026,203030,203032,203035,203040,203044,203046,203049,203053,
      203055,203058,203059,203062,203066,203070,203072,203073,203075,203082,
      203084,203089,203091,203092,203094,203098,203101,203104,203107,203108,
      203110,203113,203115,203118,203120,203121,203126,203129,203133,203136,
      203138,203140,203144,203146,203151,203152,203155,203156,203158,203160,
      203163,203165,203168,203172,203174,203177,203179,203182,203185,203186,
      203188,203189,203193,203194,203197,203199,203201,203203,203206,203208,
      203209,203211,203213,203216,203217,203222,203225,203229,203231,203235
      ];
    uint genesisAmount = 0;
    for(uint8 idx = 0;idx < 100;idx ++) {
      IERC721 genesisNfts = IERC721(address(AIR_NFT_ADDRESS));
      if(genesisNfts.ownerOf(genesisTokenIds[idx]) == _farmer) {
        genesisAmount ++;
      }
    }
    return genesisAmount;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

interface INftMinter{

  function initialize(address _landCollAddr, address _cowCollAddr, address _bullCollAddr) external;

  function mintLand(address _owner, uint8 _rarity, uint8 _type) external;
  function mintCow(address _owner, uint8 _rarity, uint8 _breed) external;
  function mintBull(address _owner, uint8 _rarity, uint8 _breed) external;

  function landNftColl() external view returns (address);
  function setLandNftColl(address) external;
  function cowNftColl() external view returns (address);
  function setCowNftColl(address) external;
  function bullNftColl() external view returns (address);
  function setBullNftColl(address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

library Constants {
    enum Rarity {
        COMMON,
        UNCOMMON,
        RARE,
        LEGENDARY,
        HOLY
    }

    enum BreedType {
        HIGHLANDS,
        HOLSTEIN,
        HEREFORD,
        BRAHMAN,
        ANGUS
    }

    enum LandType {
        MOUNTAINS,
        PLAINS,
        WOODS,
        HILLS,
        JUNGLE
    }

    /* uint[] public constant cowsPerLandByRarity = [40, 80, 120, 200, 320];
    uint[] public constant bullsPerLandByRarity = [2, 4, 6, 10, 16];
    uint[] public constant landAmountByRarity = [85000, 40000, 20000, 10000, 5000]; */
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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