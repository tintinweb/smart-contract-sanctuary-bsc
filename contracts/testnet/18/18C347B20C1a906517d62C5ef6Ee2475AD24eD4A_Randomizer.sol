// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

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
pragma solidity 0.8.0;

import "./0-context.sol";

/**
 * @dev The contract has an owner address, and provides basic authorization control whitch
 * simplifies the implementation of user permissions. This contract is based on the source code at:
 * https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/ownership/Ownable.sol
 */
contract Ownable is Context
{

  /**
   * @dev Error constants.
   */
  string public constant NOT_CURRENT_OWNER = "018001";
  string public constant CANNOT_TRANSFER_TO_ZERO_ADDRESS = "018002";

  /**
   * @dev Current owner address.
   */
  address public owner;

  /**
   * @dev An event which is triggered when the owner is changed.
   * @param previousOwner The address of the previous owner.
   * @param newOwner The address of the new owner.
   */
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The constructor sets the original `owner` of the contract to the sender account.
   */
  constructor()
  {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner()
  {
    require(msg.sender == owner, NOT_CURRENT_OWNER);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(
    address _newOwner
  )
    public
    virtual
    onlyOwner
  {
    require(_newOwner != address(0), CANNOT_TRANSFER_TO_ZERO_ADDRESS);
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }

}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */

library SafeMath {
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
    function add(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./5-types.sol";

interface IRandomizer {
  function upgrade(Types.Pet[] memory pets) external returns(
    uint256[] memory toBurnIds,
    Types.Pet[] memory newPets,
    Types.UpgradeResult
  );
  
  function getPosibilityWithCurrentSetting(Types.Pet[] memory pets) external view returns(uint256[4] memory toBurnIds);
  
  function getPetClasses(uint256 quantity) external returns(Types.PetClass[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./0-safe-math.sol";
import "./0-ownable.sol";
import "./5-types.sol";
import "./5-irandomizer.sol";
import "./9-blacklister.sol";

/*
// USDC: 0x2791bca1f2de4661ed88a30c99a7a9449aa84174
// USDT: 0xc2132D05D31c914a87C6611C10748AEb04B58e8F
// WETH: 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619
// WBTC: 0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6
// WMATIC: 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270

[
  "0x853Ee4b2A13f8a742d64C8F088bE7bA2131f670d",
  "0x6e7a5FAFcec6BB1e78bAE2A1F0B612012BF14827",
  "0x2cF7252e74036d1Da831d11089D326296e64a728"
]
*/

interface Pair {
  function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
}

contract Randomizer is IRandomizer, Ownable {
  using SafeMath for uint256;
  
  uint256 public upgradeCount = 0;
  Blacklister public blacklister;
  
  constructor(Blacklister _blacklister) {
    blacklister = _blacklister;
    initMilestones();
    initTwoRanges();
  }
  
  uint256 public winCount = 0;

  function upgrade(Types.Pet[] memory allPets) external override returns(
    uint256[] memory toBurnIds,
    Types.Pet[] memory newPets,
    Types.UpgradeResult upgradeResult
  ) {
    uint256 randomValue = getRandom(block.timestamp, tx.origin, upgradeCount++, allPets[0].id);
    upgradeResult = getUpgradeResult(allPets, randomValue);
    if (upgradeResult != Types.UpgradeResult.FAIL) winCount++;

    uint256 NOT_EXISTS_ID = 0;
    Types.Pet memory biggestPet = getBiggestPet(allPets, NOT_EXISTS_ID);
    newPets = getNewPets(upgradeResult, biggestPet, randomValue, getTwoRanges());
    toBurnIds = getToBurnIds(allPets, biggestPet, upgradeResult);
    return (toBurnIds, newPets, upgradeResult);
  }

  function ensurePetsNotInBlacklist(Types.Pet[] memory allPets) public view {
    uint256 length = allPets.length;
    for (uint256 index = 0; index < length; index++) {
      blacklister.ensurePetNotInBlacklist(allPets[index].id);
    }
  }
  
  function setBlacklister(Blacklister _blacklister) public onlyOwner {
    blacklister = _blacklister;
  }

  function getToBurnIds(
    Types.Pet[] memory allPets,
    Types.Pet memory biggestPet,
    Types.UpgradeResult upgradeResult
  ) public pure returns(uint256[] memory result) {
    if (upgradeResult == Types.UpgradeResult.FAIL) {
      result = new uint256[](1);
      result[0] = biggestPet.id;
      return result;
    }

    result = new uint256[](allPets.length);
    for (uint256 index = 0; index < allPets.length; index++) {
      result[index] = allPets[index].id;
    }
    return result;
  }

  function getNewPets(
    Types.UpgradeResult upgradeResult,
    Types.Pet memory biggestPet,
    uint256 randomValue,
    TwoRange[] memory _twoRanges
  ) public pure returns(Types.Pet[] memory result) {
    uint256 newLevel = uint256(int256(biggestPet.level) + getAddedLevel(upgradeResult));
    if (newLevel == 0) {
      result = new Types.Pet[](0);
      return result;
    }

    uint256 MAX_LEVEL = 19;
    if (newLevel <= MAX_LEVEL) {
      result = new Types.Pet[](1);
      result[0] = getNewPetByLevelAndRandom(newLevel, randomValue, _twoRanges, biggestPet.cl);
      return result;
    }

    uint256 numberOfNewPets = newLevel - MAX_LEVEL + 1;
    result = new Types.Pet[](numberOfNewPets);
    for (uint256 count = 1; count <= numberOfNewPets; count++) {
      result[count - 1] = getNewPetByLevelAndRandom(MAX_LEVEL, randomValue, _twoRanges, biggestPet.cl);
    }
    return result;
  }

  function multipleRandom(uint256 length, uint256 anyValue) public view returns (Types.Pet[] memory result) {
    result = new Types.Pet[](length);
    for (uint256 index = 0; index < length; index++) {
      result[index] = testRandom(anyValue + index);
    }
  }

  function getPetClasses(uint256 quantity) public override returns(Types.PetClass[] memory result) {
    uint256 random = getRandom(block.timestamp, tx.origin, upgradeCount += quantity, quantity);
    result = new Types.PetClass[](quantity);
    for (uint256 index = 0; index < quantity; index++) {
      uint256 randomIn100 = random % 100;
      random = random / 100;
      result[index] = getPetClassByRandom(randomIn100);
    }
  }

  function getPetClassByRandom(uint256 value) public pure returns(Types.PetClass) {
    if (value <= 20) return Types.PetClass.TEAL;
    if (value <= 40) return Types.PetClass.SILVER;
    if (value <= 60) return Types.PetClass.BURGUNDY;
    if (value <= 80) return Types.PetClass.BLOND;
    return Types.PetClass.PURPLE;
  }

  function testRandom(uint256 anyValue) public view returns (Types.Pet memory) {
    uint256 randomValue = getRandom(block.timestamp, tx.origin, upgradeCount + 1, anyValue);
    uint256 level = 19;
    return getNewPetByLevelAndRandom(
      level,
      randomValue,
      twoRanges,
      Types.PetClass.TEAL
    );
  }
  
  uint256 public SPACE_BETWEEN_TWO_3_STARS_PETS = 10000;
  
  function setSpace(uint256 newValue) public onlyOwner {
    SPACE_BETWEEN_TWO_3_STARS_PETS = newValue;
  }

  function getTwoRanges() public view returns (TwoRange[] memory result) {
    uint256 _winCount = winCount;
    if (_winCount == 0 || _winCount % SPACE_BETWEEN_TWO_3_STARS_PETS != 0) return twoRanges;
    result = new TwoRange[](1);
    result[0] = TwoRange({ randomStart: 0, randomEnd: 1000, indexStart: 80, indexEnd: 100 });
    return result;
  }

  function getNewPetByLevelAndRandom(uint256 level, uint256 randomValue, TwoRange[] memory _twoRanges, Types.PetClass cl) public pure returns(Types.Pet memory) {
    uint256 MAX_RANDOM = 1000;
    uint256 factor = MAX_RANDOM + 1;
    return Types.Pet({
      id: 0,
      level: level,
      hp: getIndexFromRandomValue(randomValue / 1e3 % factor, _twoRanges),
      mp: getIndexFromRandomValue(randomValue / 1e6 % factor, _twoRanges),
      st: getIndexFromRandomValue(randomValue / 1e9 % factor, _twoRanges),
      ag: getIndexFromRandomValue(randomValue / 1e12 % factor, _twoRanges),
      it: getIndexFromRandomValue(randomValue / 1e15 % factor, _twoRanges),
      cl: cl
    });
  }

  struct TwoRange {
    uint256 randomStart;
    uint256 randomEnd;
    uint256 indexStart;
    uint256 indexEnd;
  }
  
  TwoRange[] public twoRanges;
  /*
    [
      [0, 700, 0, 30],
      [700, 800, 30, 50],
      [800, 1000, 50, 100]
    ]
  */

  function initTwoRanges() internal {
    // random 0 -> 1000
    // index 0 -> 100
    uint256 MAX_RANDOM = 1000;
    TwoRange[] memory initialValue = new TwoRange[](3);
    initialValue[0] = TwoRange({ randomStart: 0, randomEnd: 700, indexStart: 0, indexEnd: 30 });
    initialValue[1] = TwoRange({ randomStart: 700, randomEnd: 800, indexStart: 30, indexEnd: 50 });
    initialValue[2] = TwoRange({ randomStart: 800, randomEnd: MAX_RANDOM, indexStart: 50, indexEnd: 100 });
    setTwoRanges(initialValue);
  }

  function setTwoRanges(TwoRange[] memory newTwoRanges) public onlyOwner {
    uint256 currentLength = twoRanges.length;
    for(uint256 index = 0; index < currentLength; index++) twoRanges.pop();
    for(uint256 index = 0; index < newTwoRanges.length; index++) {
      twoRanges.push(newTwoRanges[index]);
    }
  }

  function getIndexFromRandomValue(uint256 randomValue, TwoRange[] memory _twoRanges) public pure returns(uint256) {
    uint256 MAX_RANDOM = 1000;
    uint256 normalizedRandomValue = randomValue > MAX_RANDOM ? MAX_RANDOM : randomValue;
    TwoRange memory twoRange = getRangeByRandomValue(_twoRanges, normalizedRandomValue);
    return getY2Uint(twoRange.randomStart, twoRange.indexStart, twoRange.randomEnd, twoRange.indexEnd, normalizedRandomValue);
  }
  
  function getY2Uint(uint256 x0, uint256 y0, uint256 x1, uint256 y1, uint256 x2) public pure returns(uint256) {
    bool isJustOnePoint = x0 == x1 && x1 == x2 && y0 == y1;
    if (isJustOnePoint) return y0;
    
    bool isInvalidCase = x0 == x1 && y0 != y1;
    require(!isInvalidCase, 'INVALID_POINTS');
    return (x2 - x0) * (y1 - y0) / (x1 - x0) + y0;
  }

  function getRangeByRandomValue(TwoRange[] memory _twoRanges, uint256 randomValue) private pure returns(TwoRange memory result) {
    uint256 length = _twoRanges.length;
    for (uint256 index = 0; index < length; index++) {
      TwoRange memory twoRange = _twoRanges[index];
      if (randomValue <= twoRange.randomEnd) return twoRange;
    }
  }
  
  Pair[] public pairs;
  
  function setPairs(Pair[] memory _pairs) public onlyOwner {
    pairs = _pairs;
  }

  function getOutsideValue() public view returns(uint256) {
    uint256 result = 0;
    uint256 length = pairs.length;
    for (uint256 index = 0; index < length; index++) {
      uint112 reserve;
      (reserve, ,) = pairs[index].getReserves();
      result += reserve;
    }
    return result;
  }

  function getRandom(uint256 timestamp, address sender, uint256 _upgradeCount, uint256 firstTokenId) public view returns(uint256) {
    return uint256(keccak256(abi.encodePacked(timestamp, sender, _upgradeCount, firstTokenId, getOutsideValue())));
  }

  function getAddedLevel(Types.UpgradeResult upgradeResult) public pure returns(int256) {
    if (upgradeResult == Types.UpgradeResult.INCREASE_1_LEVEL) return 1;
    if (upgradeResult == Types.UpgradeResult.INCREASE_2_LEVELS) return 2;
    if (upgradeResult == Types.UpgradeResult.INCREASE_3_LEVELS) return 3;
    return -1;
  }

  enum CompareResult {
    FIRST_BIGGER_THAN_SECOND,
    FIRST_SMALLER_THAN_SECOND,
    FIRST_EQUAL_SECOND
  }

  function getBonusPoint(Types.Pet memory biggest, Types.Pet memory secondBiggest) public pure returns(uint256) {
    if (biggest.level != secondBiggest.level) return getTotalPetIndex(biggest);
    return getTotalPetIndex(biggest) + getTotalPetIndex(secondBiggest);
  }

  function getTotalPetIndex(Types.Pet memory pet) public pure returns(uint256) {
    return pet.hp + pet.mp + pet.st + pet.ag + pet.it;
  }

  function compare(Types.Pet memory first, Types.Pet memory second) public pure returns(CompareResult) {
    if (first.level > second.level) return CompareResult.FIRST_BIGGER_THAN_SECOND;
    if (first.level < second.level) return CompareResult.FIRST_SMALLER_THAN_SECOND;
    uint256 firstTotal = getTotalPetIndex(first);
    uint256 secondTotal = getTotalPetIndex(second);

    if (firstTotal > secondTotal) return CompareResult.FIRST_BIGGER_THAN_SECOND;
    if (firstTotal < secondTotal) return CompareResult.FIRST_SMALLER_THAN_SECOND;
    return CompareResult.FIRST_EQUAL_SECOND;
  }

  function getBiggestPet(Types.Pet[] memory allPets, uint256 skipId) public pure returns(Types.Pet memory result) {
    uint256 length = allPets.length;
    for (uint256 index = 0; index < length; index++) {
      if (allPets[index].id == skipId) continue;
      if (compare(result, allPets[index]) != CompareResult.FIRST_SMALLER_THAN_SECOND) continue;
      result = allPets[index];
    }
    return result;
  }

  uint256[] public PET_PRICES_FOR_SELLER = [
    0,
    1 ether,
    2.1 ether,
    4.2 ether,
    8.8 ether,
    18.2 ether,
    37.7 ether,
    78.2 ether,
    162.7 ether,
    339.2 ether,
    708.5 ether,
    1482.9 ether,
    3110.7 ether,
    6540.5 ether,
    13785.8 ether,
    29131.4 ether,
    61723.5 ether,
    131146.2 ether,
    279468.9 ether,
    597370.7 ether
  ];

  function getTotalValue(Types.Pet[] memory allPets, uint256[] memory _PET_PRICES_FOR_SELLER) public pure returns(uint256) {
    uint256 total = 0;
    for (uint256 index = 0; index < allPets.length; index++) {
      Types.Pet memory pet = allPets[index];
      total += _PET_PRICES_FOR_SELLER[pet.level];
    }
    return total;
  }

  uint256[4][] baseRates = [
    [uint256(0), uint256(0), uint256(0), uint256(0)],
    [uint256(2500), uint256(6200), uint256(1000), uint256(300)],
    [uint256(2488), uint256(6203), uint256(1007), uint256(302)],
    [uint256(2475), uint256(6207), uint256(1014), uint256(304)],
    [uint256(2463), uint256(6210), uint256(1021), uint256(306)],
    [uint256(2450), uint256(6213), uint256(1028), uint256(308)],
    [uint256(2438), uint256(6216), uint256(1035), uint256(311)],
    [uint256(2426), uint256(6219), uint256(1043), uint256(313)],
    [uint256(2414), uint256(6221), uint256(1050), uint256(315)],
    [uint256(2402), uint256(6224), uint256(1057), uint256(317)],
    [uint256(2390), uint256(6226), uint256(1065), uint256(319)],
    [uint256(2378), uint256(6228), uint256(1072), uint256(322)],
    [uint256(2366), uint256(6230), uint256(1080), uint256(324)],
    [uint256(2354), uint256(6232), uint256(1087), uint256(326)],
    [uint256(2342), uint256(6234), uint256(1095), uint256(328)],
    [uint256(2331), uint256(6236), uint256(1103), uint256(331)],
    [uint256(2319), uint256(6238), uint256(1110), uint256(333)],
    [uint256(2307), uint256(6136), uint256(1221), uint256(335)],
    [uint256(2296), uint256(5901), uint256(1466), uint256(338)]
];

  function getUpgradeResult(Types.Pet[] memory allPets, uint256 randomValue) public view returns(Types.UpgradeResult) {
    ensurePetsNotInBlacklist(allPets);
    uint256[4] memory posibility = getPosibility(
      allPets,
      baseRates,
      PET_PRICES_FOR_SELLER,
      milestones
    );
    return getUpgradeResultByRandomValueAndPosibility(posibility, randomValue);
  }

  function getPosibility(
    Types.Pet[] memory allPets,
    uint256[4][] memory _baseRates,
    uint256[] memory _PET_PRICES_FOR_SELLER,
    Milestone[] memory _milestones
  ) public pure returns(uint256[4] memory result) {
    uint256 NOT_EXISTS_ID = 0;
    Types.Pet memory biggestPet = getBiggestPet(allPets, NOT_EXISTS_ID);
    Types.Pet memory secondBiggestPet = getBiggestPet(allPets, biggestPet.id);
    uint256[4] memory posibilityWithoutBonusPoints = getPossibilityWithoutBonusPoints(
      _baseRates[biggestPet.level],
      getTotalValue(allPets, _PET_PRICES_FOR_SELLER),
      _PET_PRICES_FOR_SELLER[biggestPet.level + 1],
      _milestones
    );
    return getPossibilityWithBonusPoints(
      posibilityWithoutBonusPoints,
      getBonusPoint(biggestPet, secondBiggestPet)
    );
  }

  function getPosibilityWithCurrentSetting(Types.Pet[] memory allPets) public view override returns(uint256[4] memory) {
    return getPosibility(allPets, baseRates, PET_PRICES_FOR_SELLER, milestones);
  }

  function getUpgradeResultByRandomValueAndPosibility(uint256[4] memory posibility, uint256 randomValue) public pure returns(Types.UpgradeResult) {
    uint256 modded = randomValue % 10000;
    if (modded < posibility[0]) return Types.UpgradeResult.FAIL;
    if (modded < posibility[0] + posibility[1]) return Types.UpgradeResult.INCREASE_1_LEVEL;
    if (modded < posibility[0] + posibility[1] + posibility[2]) return Types.UpgradeResult.INCREASE_2_LEVELS;
    return Types.UpgradeResult.INCREASE_2_LEVELS;
  }

  struct Milestone {
    uint256 percentage;
    int down1;
    int up1;
    int up2;
    int up3;
  }
  
  Milestone[] milestones;

  function initMilestones() internal {
    milestones.push(Milestone({ percentage: 70, down1: 0, up1: -20, up2: -75, up3: -75 }));
    milestones.push(Milestone({ percentage: 80, down1: 0, up1: -20, up2: -50, up3: -50 }));
    milestones.push(Milestone({ percentage: 90, down1: 0, up1: 0, up2: 0, up3: 0 }));
    milestones.push(Milestone({ percentage: 130, down1: -50, up1: 0, up2: 100, up3: 100 }));
  }

  function getPercentage(uint256 allPetsValue, uint256 nextLevelPrice) public pure returns(uint256) {
    uint256 percentage = allPetsValue * 100 / nextLevelPrice;
    uint256 MIN_PERCENTAGE = 70;
    require(percentage >= MIN_PERCENTAGE, 'NOT_ENOUGH_PETS');

    uint256 MAX_PERCENTAGE = 130;
    return percentage < MAX_PERCENTAGE ? percentage : MAX_PERCENTAGE;
  }

  function getPossibilityWithoutBonusPoints(
    uint256[4] memory levelBaseRates,
    uint256 allPetsValue,
    uint256 nextLevelPrice,
    Milestone[] memory _milestones
  ) public pure returns (uint256[4] memory result) {
    uint256 percentage = getPercentage(allPetsValue, nextLevelPrice);
    Milestone memory milestone = calculateMilestone(
      percentage,
      findLowerMilestone(percentage, _milestones),
      findUpperMilestone(percentage, _milestones)
    );
    return applyMilestone(levelBaseRates, milestone);
  }

  function getPossibilityWithBonusPoints(uint256[4] memory withoutBonusPointsRates, uint256 bonusPoint) public pure returns (uint256[4] memory result) {
    uint256 MEANING_POINT = 400;
    uint256 MAX_POINT = 1000;
    if (bonusPoint < MEANING_POINT) return withoutBonusPointsRates;
    Milestone memory milestone = calculateMilestone(
      bonusPoint,
      Milestone({ percentage: MEANING_POINT, down1: 0, up1: 0, up2: 0, up3: 0 }),
      Milestone({ percentage: MAX_POINT, down1: -66, up1: 0, up2: 100, up3: 250 })
    );
    return applyMilestone(withoutBonusPointsRates, milestone);
  }

  function getY2(uint256 x0, int256 y0, uint256 x1, int256 y1, uint256 x2) public pure returns(int256) {
    bool isJustOnePoint = x0 == x1 && x1 == x2 && y0 == y1;
    if (isJustOnePoint) return y0;
    
    bool isInvalidCase = x0 == x1 && y0 != y1;
    require(!isInvalidCase, 'INVALID_POINTS');
    return int256(x2 - x0) * (y1 - y0) / int256(x1 - x0) + y0;
  }

  function calculateMilestone(uint256 percentage, Milestone memory lower, Milestone memory upper) public pure returns(Milestone memory result) {
    result.down1 = getY2(lower.percentage, lower.down1, upper.percentage, upper.down1, percentage);
    result.up1 = getY2(lower.percentage, lower.up1, upper.percentage, upper.up1, percentage);
    result.up2 = getY2(lower.percentage, lower.up2, upper.percentage, upper.up2, percentage);
    result.up3 = getY2(lower.percentage, lower.up3, upper.percentage, upper.up3, percentage);
    result.percentage = percentage;
    return result;
  }

  function findLowerMilestone(uint256 percentage, Milestone[] memory _milestones) public pure returns(Milestone memory) {
    for (int256 index = int256(_milestones.length - 1); index >= 0; index--) {
      if (percentage < _milestones[uint256(index)].percentage) continue;
      return _milestones[uint256(index)];
    }
    revert('INVALID_PERCENTAGE');
  }
  
  function findUpperMilestone(uint256 percentage, Milestone[] memory _milestones) public pure returns(Milestone memory) {
    uint256 length = _milestones.length;
    for (uint256 index = 0; index < length; index++) {
      if (percentage > _milestones[uint256(index)].percentage) continue;
      return _milestones[uint256(index)];
    }
    revert('INVALID_PERCENTAGE');
  }

  function getNewRate(uint256 rate, int256 change) public pure returns(uint256) {
    return uint256(int256(rate) + int256(rate) * change / 100);
  }

  function min(uint256 a, uint256 b) public pure returns(uint256) {
    return a < b ? a : b;
  }

  function applyMilestone(uint256[4] memory rates, Milestone memory milestone) public pure returns (uint256[4] memory result) {
    result = [rates[0], rates[1], rates[2], rates[3]];
    result[0] = getNewRate(rates[0], milestone.down1);
    result[1] = getNewRate(rates[1], milestone.up1);
    result[2] = min(getNewRate(rates[2], milestone.up2), 6736);
    result[3] = min(getNewRate(rates[3], milestone.up3), 2343);
    if (milestone.down1 == 0) {
      result[0] = 10000 - (result[1] + result[2] + result[3]);
      return result;
    }
    if (milestone.up1 == 0) {
      result[1] = 10000 - (result[0] + result[2] + result[3]);
      return result;
    }
    return result;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

interface Types {
  enum PetClass {
    TEAL,
    SILVER,
    BURGUNDY,
    BLOND,
    PURPLE
  }
    
  struct Pet {
    uint256 id;
    uint256 level;
    uint256 hp;
    uint256 mp;
    uint256 st;
    uint256 ag;
    uint256 it;
    PetClass cl;
  }

  enum UpgradeResult {
    FAIL,
    INCREASE_1_LEVEL,
    INCREASE_2_LEVELS,
    INCREASE_3_LEVELS
  }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./0-ownable.sol";
import "./0-ierc20.sol";

contract Blacklister is Ownable {

  mapping(address => bool) public accountBlackList;

  event AddAccountBlacklist(address account);

  function addAccountBackList(address[] memory accounts) public onlyOwner {
    uint256 length = accounts.length;
    for (uint256 index = 0; index < length; index++) {
      accountBlackList[accounts[index]] = true;
      emit AddAccountBlacklist(accounts[index]);
    }
  }

  event RemoveAccountBlacklist(address account);

  function removeAccountBlackList(address[] memory accounts) public onlyOwner {
    uint256 length = accounts.length;
    for (uint256 index = 0; index < length; index++) {
      accountBlackList[accounts[index]] = false;
      emit RemoveAccountBlacklist(accounts[index]);
    }
  }

  function ensureAccountNotInBlacklist(address account) public view {
    require(!accountBlackList[account], "BLACKLISTED");
  }

  mapping(uint256 => bool) public petBlackList;

  event AddPetBlacklist(uint256 id);

  function addPetBackList(uint256[] memory ids) public onlyOwner {
    uint256 length = ids.length;
    for (uint256 index = 0; index < length; index++) {
      petBlackList[ids[index]] = true;
      emit AddPetBlacklist(ids[index]);
    }
  }

  event RemovePetBlacklist(uint256 id);

  function removePetBlackList(uint256[] memory ids) public onlyOwner {
    uint256 length = ids.length;
    for (uint256 index = 0; index < length; index++) {
      petBlackList[ids[index]] = false;
      emit RemovePetBlacklist(ids[index]);
    }
  }

  function ensurePetNotInBlacklist(uint256 id) public view {
    require(!petBlackList[id], "BLACKLISTED");
  }

  function withdrawMatic() public onlyOwner {
    payable(msg.sender).transfer(address(this).balance);
  }

  function withdrawToken(uint256 amount, IERC20 erc20) public onlyOwner {
    erc20.transfer(owner, amount);
  }
}