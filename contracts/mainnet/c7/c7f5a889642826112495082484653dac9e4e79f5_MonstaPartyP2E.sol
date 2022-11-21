/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

// File @openzeppelin/contracts/utils/introspection/[email protected]


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

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


// File @openzeppelin/contracts/token/ERC721/[email protected]


// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)



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


// File @openzeppelin/contracts-upgradeable/proxy/utils/[email protected]



// solhint-disable-next-line compiler-version


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


// File @openzeppelin/contracts-upgradeable/utils/[email protected]





/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}


// File @openzeppelin/contracts-upgradeable/access/[email protected]






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
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}


// File @openzeppelin/contracts-upgradeable/utils/math/[email protected]





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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


// File contracts/MonstaPartyP2E.sol




// import 'hardhat/console.sol';



interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function balanceOfAt(address account, uint256 snapshotId) external view returns (uint256);

  function totalSupplyAt(uint256 snapshotId) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function burn(uint256 amount) external;

  function approve(address spender, uint256 amount) external returns (bool);
}

interface ISwapRouter {
  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable;

  function WETH() external pure returns (address);
}

interface ICakeMonsterDCNFT {
  function hasLevelQualified(address account, uint256 level) external view returns (bool);
}

interface IMonstaPartyNFT {
  function getRandom(uint256 tokenId) external view returns (uint256);

  function getRequestCount(address minter) external view returns (uint256);

  function getHatchTime(uint256 tokenId) external view returns (uint256);

  function mintRequests() external view returns (uint256);
}

interface IMonstaPartyGen1NFT {
  function mint(address to, uint256 tokenId) external;

  function exists(uint256 tokenId) external view returns (bool);
}

struct NftInfo {
  uint256 xp;
  uint256 rewards;
  uint256 generation;
  uint256 hatchTime;
  uint256 lastFeedTime;
  uint256 lastXpUpdateTime;
  uint256 lastRewardsClaimTime;
  mapping(uint256 => uint256) dailyFeedCount;
  uint256 totalFeedBNB;
  uint256 rewardTracker;
  uint256 random;
  uint256 extraRobberies;
  uint256 lastEnergyDrinkTime;
}

contract MonstaPartyP2E is OwnableUpgradeable {
  /* PUBLIC */

  mapping(uint256 => NftInfo) public infos;

  uint256 public totalXp;
  uint256 public rewardsTotal;
  uint256 public mintingStartTime;
  uint256 public rewardPerXp;

  uint256 public buyPriceDC;
  uint256 public buyPriceWL;
  uint256 public buyPriceALL;

  uint256 public feedPrice1;
  uint256 public feedPrice2;
  uint256 public feedPrice3;

  mapping(address => bool) public whitelist;

  /* PRIVATE */

  address private ADDRESS_MONSTA_PARTY_NFT;
  address private ADDRESS_CAKE_MONSTER;
  address private ADDRESS_CAKE_MONSTER_RESERVE;
  address private ADDRESS_CAKE_MONSTER_DC_NFT;
  address private ADDRESS_SWAP_ROUTER;
  address private ADDRESS_CAKE;
  address private ADDRESS_MK_DEV;

  event Feed(address indexed from, uint256 indexed tokenId, uint256 amountBNB, uint256 amountXP);
  event Claim(address indexed from, uint256 indexed tokenId);

  mapping(uint256 => uint256) public lastDailyGrowthClaim;

  // V3
  mapping(uint256 => uint256) public lastStealTimes;
  mapping(uint256 => uint256) public stolenRewards;
  mapping(uint256 => uint256) public currentSteals;
  mapping(uint256 => uint256[]) public currentStealParticipants;
  mapping(uint256 => uint256) public currentStealWinning;

  // V4
  address private ADDRESS_MONSTA_PARTY_GEN1_NFT;

  event StealAttempt(
    address indexed attacker,
    uint256 indexed attackerTokenId,
    uint256 indexed victimTokenId
  );

  event StealSuccess(
    address indexed attacker,
    uint256 indexed attackerTokenId,
    uint256 indexed victimTokenId,
    uint256 rewardsAmount
  );

  // V6

  uint256 public feedPrice4;
  mapping(uint256 => uint256) public lastFeed4;

  // V7
  uint256 public lastVictimTokenId;

  // V8
  uint256 public energyDrinkPrice1;
  uint256 public energyDrinkPrice2;
  uint256 public energyDrinkPrice3;

  // V10
  address public ADDRESS_MONSTA_PARTY_ARCADE;

  event EnergyDrinkBought(address indexed from, uint256 indexed tokenId, uint256 amount);

  event StealStarted(
    address indexed attacker,
    uint256 indexed attackerTokenId,
    uint256 indexed victimTokenId
  );

  function initialize(
    address _ADDRESS_MONSTA_PARTY_NFT,
    address _ADDRESS_CAKE_MONSTER,
    address _ADDRESS_CAKE_MONSTER_RESERVE,
    address _ADDRESS_CAKE_MONSTER_DC_NFT,
    address _ADDRESS_SWAP_ROUTER,
    address _ADDRESS_CAKE,
    address _ADDRESS_MK_DEV
  ) external initializer {
    __Ownable_init();

    ADDRESS_MONSTA_PARTY_NFT = _ADDRESS_MONSTA_PARTY_NFT;
    ADDRESS_CAKE_MONSTER = _ADDRESS_CAKE_MONSTER;
    ADDRESS_CAKE_MONSTER_RESERVE = _ADDRESS_CAKE_MONSTER_RESERVE;
    ADDRESS_CAKE_MONSTER_DC_NFT = _ADDRESS_CAKE_MONSTER_DC_NFT;
    ADDRESS_SWAP_ROUTER = _ADDRESS_SWAP_ROUTER;
    ADDRESS_CAKE = _ADDRESS_CAKE;
    ADDRESS_MK_DEV = _ADDRESS_MK_DEV;

    buyPriceDC = 0.308 ether;
    buyPriceWL = 0.386 ether;
    buyPriceALL = 0.463 ether;
    feedPrice1 = 0.005 ether;
    feedPrice2 = 0.015 ether;
    feedPrice3 = 0.035 ether;
  }

  /* MODIFIERS */

  modifier onlyMP() {
    require(msg.sender == ADDRESS_MONSTA_PARTY_NFT);
    _;
  }

  modifier onlyArcade() {
    require(msg.sender == ADDRESS_MONSTA_PARTY_ARCADE);
    _;
  }

  /* OWNER */

  function upgrade() public onlyOwner {}

  function setAddresMkDev(address _addy) public onlyOwner {
    ADDRESS_MK_DEV = _addy;
  }

  function startMinting() public onlyOwner {
    mintingStartTime = block.timestamp;
  }

  function stopMinting() public onlyOwner {
    mintingStartTime = 0;
  }

  function setFoodPrices(
    uint256 _feedPrice1,
    uint256 _feedPrice2,
    uint256 _feedPrice3,
    uint256 _feedPrice4
  ) external onlyOwner {
    feedPrice1 = _feedPrice1;
    feedPrice2 = _feedPrice2;
    feedPrice3 = _feedPrice3;
    feedPrice4 = _feedPrice4;
  }

  function setWhitelistMulti(address[] memory addys, bool add) external onlyOwner {
    for (uint256 i = 0; i < addys.length; i++) {
      whitelist[addys[i]] = add;
    }
  }

  function setMonstaPartyArcade(address _monstaPartyArcade) external onlyOwner {
    ADDRESS_MONSTA_PARTY_ARCADE = _monstaPartyArcade;
  }

  function addExtraRewards(uint256 amount) external onlyOwner {
    if (totalXp == 0) {
      return;
    }

    rewardPerXp += amount / totalXp;
    rewardsTotal += amount;
  }

  function addCustomXP(uint256 tokenId, uint256 amount) external onlyOwner {
    NftInfo storage info = infos[tokenId];

    addXp(info, amount);
  }

  function removeCustomXP(uint256 tokenId, uint256 amount) external onlyOwner {
    NftInfo storage info = infos[tokenId];

    removeXp(info, amount);
  }

  function addArcadeXp(uint256 tokenId, uint256 xpToAdd) external onlyArcade {
    NftInfo storage info = infos[tokenId];

    addXp(info, xpToAdd);
  }

  /** BNB DEPOSIT HANDLERS **/

  // function feedMulti(uint256[] calldata tokenIds) external payable {
  //   for (uint256 i = 0; i < tokenIds.length; i++) {
  //     feed(tokenIds[i]);
  //   }
  // }

  function feed(uint256 tokenId) public payable {
    require(isTokenOwner(tokenId), 'Token not owned by caller');
    require(
      msg.value == feedPrice1 || msg.value == feedPrice3 || msg.value == feedPrice4,
      'Feeding BNB value invalid (hard refresh app)'
    );
    require(
      currentSteals[tokenId] == 0 || block.timestamp > currentSteals[tokenId] + 15 minutes,
      'Robbery in progress!'
    );

    NftInfo storage info = infos[tokenId];

    if (info.hatchTime == 0) {
      activate(tokenId);
    }

    require(info.hatchTime > 0, 'Egg not activated');
    require((info.hatchTime - 1 days) <= block.timestamp, 'Egg not hatched yet');
    require(info.dailyFeedCount[block.timestamp / 1 days] < 20, 'Max 20 feedings per day');

    // Send 10% BNB to MK/DEV for caviar
    if (msg.value == feedPrice4) {
      (bool success, ) = ADDRESS_MK_DEV.call{ value: _pct(100000, msg.value) }('');
      require(success, 'Failed to send BNB');
    }

    buyMonsta();

    // Update XP by feeding
    uint256 feedingXp = 0;

    if (msg.value == feedPrice1) {
      feedingXp = _pseudoRandom(_msgSender(), tokenId, 6, 11);
    } else if (msg.value == feedPrice3) {
      feedingXp = _pseudoRandom(_msgSender(), tokenId, 26, 41);
    } else if (msg.value == feedPrice4) {
      feedingXp = 690;

      require(lastFeed4[tokenId] < block.timestamp - 7 days, 'Max once a week');
      lastFeed4[tokenId] = block.timestamp;
    }

    addXp(info, feedingXp);

    info.lastFeedTime = block.timestamp;
    info.lastXpUpdateTime = block.timestamp;
    info.dailyFeedCount[block.timestamp / 1 days]++;
    info.totalFeedBNB += msg.value;

    // Upgrade monster if XP reached 10K
    if (info.xp >= 10000 && info.generation == 0) {
      info.generation++;
      // info.hatchTime = block.timestamp + (_pseudoRandom(_msgSender(), tokenId, 1, 5) * 1 days);
    }

    emit Feed(_msgSender(), tokenId, msg.value, feedingXp);
  }

  function energyDrink(uint256 tokenId) external payable {
    require(isTokenOwner(tokenId), 'Token not owned by caller');
    require(
      msg.value == energyDrinkPrice1 || msg.value == energyDrinkPrice2,
      'Feeding BNB value invalid'
    );

    NftInfo storage info = infos[tokenId];

    if (info.hatchTime == 0) {
      activate(tokenId);
    }

    require(info.hatchTime > 0, 'Egg not activated');
    require((info.hatchTime - 1 days) <= block.timestamp, 'Egg not hatched yet');

    require(
      info.lastEnergyDrinkTime < block.timestamp - 24 hours,
      'Energy drinks can only be bought once in 24 hours'
    );

    // Send 50% BNB to MK/DEV
    (bool success, ) = ADDRESS_MK_DEV.call{ value: _pct(500000, msg.value) }('');
    require(success, 'Failed to send BNB');

    // Update extra robberies count
    uint256 addRobberies = 0;
    if (msg.value == energyDrinkPrice1) {
      addRobberies += 1;
    } else if (msg.value == energyDrinkPrice2) {
      addRobberies += 2;
    }

    require(info.extraRobberies + addRobberies <= 10, 'Max 10 energy drinks in total allowed');

    info.extraRobberies += addRobberies;
    info.lastEnergyDrinkTime = block.timestamp;

    emit EnergyDrinkBought(_msgSender(), tokenId, addRobberies);
  }

  receive() external payable {
    buyMonsta();
  }

  /** PUBLIC **/

  function canBuy(
    address, // minter,
    uint256, // mintAmount,
    uint256 // bnbValue
  ) public view returns (bool allow, string memory reason) {
    return (false, 'Sold out');
  }

  function claim(uint256 tokenId) external {
    require(isTokenOwner(tokenId), 'Token not owned by caller');
    require(
      currentSteals[tokenId] == 0 || block.timestamp > currentSteals[tokenId] + 15 minutes,
      'Robbery in progress!'
    );

    NftInfo storage info = infos[tokenId];

    require(info.hatchTime > 0, 'Feed at least once to start claiming');

    require(
      info.lastFeedTime > block.timestamp - 10 days,
      'Inactive for more than 10 days, feed at least once to claim'
    );

    claimXpRewards(info, tokenId);
    claimMonstaRewards(info, tokenId);

    emit Claim(_msgSender(), tokenId);
  }

  function getInfo(uint256 tokenId)
    external
    view
    returns (
      uint256,
      uint256,
      uint256,
      uint256,
      uint256,
      uint256,
      uint256,
      uint256,
      uint256,
      uint256
    )
  {
    NftInfo storage info = infos[tokenId];

    uint256 xpClaimAmount = getXpClaimAmount(tokenId);
    uint256 rewardClaimAmount = getRewardClaimAmount(tokenId);

    return (
      info.xp,
      info.rewards,
      info.generation,
      info.hatchTime,
      info.lastFeedTime,
      info.dailyFeedCount[block.timestamp / 1 days],
      info.totalFeedBNB,
      xpClaimAmount,
      rewardClaimAmount,
      info.extraRobberies
    );
  }

  function getXpClaimAmount(uint256 tokenId) public view returns (uint256) {
    uint256 prevDay = lastDailyGrowthClaim[tokenId];
    uint256 today = block.timestamp / 1 days;

    if (prevDay == 0) {
      prevDay = IMonstaPartyNFT(ADDRESS_MONSTA_PARTY_NFT).getHatchTime(tokenId) / 1 days;

      if (prevDay > today) {
        return 0;
      }
    }

    uint256 dailyGrowth = (today - prevDay) * 5;

    if (dailyGrowth > 50) {
      dailyGrowth = 50;
    }

    return dailyGrowth;
  }

  function getRewardClaimAmount(uint256 tokenId) public view returns (uint256) {
    NftInfo storage info = infos[tokenId];

    uint256 rewardXpMul = info.xp * rewardPerXp;

    if (info.rewardTracker >= rewardXpMul) {
      return 0;
    }

    return rewardXpMul - info.rewardTracker;
  }

  function getBuyPrice(uint256) public pure returns (uint256) {
    return 0;
  }

  function attemptSteal(uint256 attackerTokenId, uint256 victimTokenId) external {
    (bool canStealResult, string memory reason) = canSteal(attackerTokenId, victimTokenId);
    require(canStealResult, reason);

    NftInfo storage infoAttacker = infos[attackerTokenId];

    if (
      currentSteals[victimTokenId] == 0 ||
      currentSteals[victimTokenId] < block.timestamp - 30 minutes
    ) {
      // Start new steal
      lastVictimTokenId = victimTokenId;
      currentSteals[victimTokenId] = block.timestamp;
      currentStealWinning[victimTokenId] = attackerTokenId;
      delete currentStealParticipants[victimTokenId];

      emit StealStarted(_msgSender(), attackerTokenId, victimTokenId);
    } else {
      // Join current steal

      // Determine current winning stealer
      NftInfo storage infoWinner = infos[currentStealWinning[victimTokenId]];

      // Determine if attacker would've been chosen as a potential winner
      if (
        _pseudoRandom(
          _msgSender(),
          attackerTokenId,
          0,
          currentStealParticipants[victimTokenId].length + 1
        ) <= 1
      ) {
        // Determine winning chance between current winner and this one
        uint256 attackXp = infoAttacker.xp;
        if (attackXp > 20000) {
          attackXp = 20000;
        }
        uint256 chance = (attackXp * 1000) / infoWinner.xp;
        if (attackXp >= infoWinner.xp) {
          uint256 pick = _pseudoRandom(_msgSender(), attackerTokenId, 0, chance);

          if (pick > 500) {
            currentStealWinning[victimTokenId] = attackerTokenId;
          }
        } else {
          uint256 pick = _pseudoRandom(_msgSender(), attackerTokenId, 0, 1000);

          if (pick < chance / 2) {
            currentStealWinning[victimTokenId] = attackerTokenId;
          }
        }
      }
    }

    // Add attacker to list
    currentStealParticipants[victimTokenId].push(attackerTokenId);

    uint256 cooldown = 24 hours;
    if (infoAttacker.xp >= 10000) {
      cooldown = 12 hours;
    }
    if (lastStealTimes[attackerTokenId] > block.timestamp - cooldown) {
      // If still cooling down, then deduct extra robberies
      infoAttacker.extraRobberies--;
    } else {
      // Track steal time of attacker
      lastStealTimes[attackerTokenId] = block.timestamp;
    }

    emit StealAttempt(_msgSender(), attackerTokenId, victimTokenId);
  }

  function getStealProgress(uint256 victimTokenId) public view returns (uint256) {
    if (currentSteals[victimTokenId] == 0) {
      return 0; // No steal in progress
    }

    if (block.timestamp <= currentSteals[victimTokenId] + 15 minutes) {
      return 1; // Steal in progress
    }

    return 2; // Steal finished
  }

  function steal(uint256 attackerTokenId, uint256 victimTokenId) external {
    require(attackerTokenId > 0, 'TokenID 0 not allowed');

    require(getStealProgress(victimTokenId) == 2, 'Stealing not available');
    require(currentStealWinning[victimTokenId] == attackerTokenId, 'No successful steal');
    require(currentSteals[victimTokenId] > block.timestamp - 30 minutes, 'Steal expired');

    NftInfo storage infoAttacker = infos[attackerTokenId];
    NftInfo storage infoVictim = infos[victimTokenId];

    // Reset steal progress
    currentStealWinning[victimTokenId] = 0;
    delete currentStealParticipants[victimTokenId];

    // Unlock victim
    currentSteals[victimTokenId] = 0;

    uint256 victimClaimRewardsAmount = getRewardClaimAmount(victimTokenId);
    uint256 victimXpClaimAmount = getXpClaimAmount(victimTokenId);

    // Add rewards to tracker of victim, so there's no claim amount left
    infoVictim.rewardTracker = infoVictim.xp * rewardPerXp;

    // Also track amount of stolen rewards on victim
    stolenRewards[victimTokenId] += victimClaimRewardsAmount;

    // Reset daily pxp
    infoVictim.lastXpUpdateTime = block.timestamp;
    lastDailyGrowthClaim[victimTokenId] = block.timestamp / 1 days;

    // Burn pxp from victim (NOT NOW)
    // removeXp(infoVictim, victimXpClaimAmount);

    // Add pxp to attacker
    addXp(infoAttacker, victimXpClaimAmount);

    uint256 burnAmount = victimClaimRewardsAmount / 2;
    uint256 rewardAmount = victimClaimRewardsAmount - burnAmount;

    // Burn 50%)
    IERC20(ADDRESS_CAKE_MONSTER).burn(burnAmount);

    // Reward 50%
    IERC20(ADDRESS_CAKE_MONSTER).transfer(
      IERC721(ADDRESS_MONSTA_PARTY_NFT).ownerOf(attackerTokenId),
      rewardAmount
    );

    infoAttacker.rewards += rewardAmount;

    emit StealSuccess(_msgSender(), attackerTokenId, victimTokenId, victimClaimRewardsAmount);
  }

  function canSteal(uint256 attackerTokenId, uint256 victimTokenId)
    public
    view
    returns (bool, string memory)
  {
    // Check if caller owns attacker token id
    if (!isTokenOwner(attackerTokenId)) {
      return (false, 'Token not owned by caller');
    }

    // Check if another robbery is in progress
    if (
      lastVictimTokenId != victimTokenId &&
      currentSteals[lastVictimTokenId] >= block.timestamp - 15 minutes
    ) {
      return (false, 'Other robbery in progress');
    }

    NftInfo storage infoAttacker = infos[attackerTokenId];
    NftInfo storage infoVictim = infos[victimTokenId];

    // Check if steal is finished and not claimed yet (or max 30 mins, 15 mins since finish stealing)
    if (
      getStealProgress(victimTokenId) > 2 &&
      currentSteals[victimTokenId] >= block.timestamp - 30 minutes
    ) {
      return (false, 'Steal already happened, wait for claim or timeout');
    }

    uint256 cooldown = 24 hours;
    if (infoAttacker.xp >= 10000) {
      cooldown = 12 hours;
    }

    // Check if attacker token can steal or needs to cool down first
    if (
      lastStealTimes[attackerTokenId] > block.timestamp - cooldown &&
      infoAttacker.extraRobberies == 0
    ) {
      return (false, 'Attacker is cooling down');
    }

    // Check if last feed time < 12 hours
    if (infoAttacker.lastFeedTime < block.timestamp - 12 hours) {
      return (false, 'Attacker is too hungry to attack');
    }

    // Check if victim is inactive can be stealed from
    // Last feed should be > 10 days
    if (infoVictim.lastFeedTime > block.timestamp - 10 days) {
      return (false, 'Victim is active');
    }

    // Victim rewards should > 0
    if (getRewardClaimAmount(victimTokenId) == 0) {
      return (false, 'Victim has no rewards pending');
    }

    return (true, 'OK');
  }

  struct GameState {
    bool isVictimActive;
    uint256 victimOutstandingXp;
    uint256 victimOutstandingRewards;
    uint256 victimLastFeedTime;
    uint256 robberLastFeedTime;
    bool robberHungry;
    bool robberCoolingDown;
    uint256[] participants;
    uint256 robberyStartTime;
    bool robberyInProgress;
    bool robberyFinished;
    uint256 robberyWinnerTokenId;
    bool robberyWinnerCaller;
  }

  function getGameState(uint256 attackerTokenId, uint256 victimTokenId)
    external
    view
    returns (GameState memory state)
  {
    NftInfo storage attackerInfo = infos[attackerTokenId];
    NftInfo storage victimInfo = infos[victimTokenId];

    state.isVictimActive = victimInfo.lastFeedTime > block.timestamp - 10 days; // Is victim active?

    state.victimOutstandingXp = getXpClaimAmount(victimTokenId); // Outstanding pxp of victim
    state.victimOutstandingRewards = getRewardClaimAmount(victimTokenId); // Outstanding rewards of victim
    state.victimLastFeedTime = victimInfo.lastFeedTime; // Last feed time of victim
    state.robberLastFeedTime = attackerInfo.lastFeedTime; // Last feed time of robber
    state.robberHungry = attackerInfo.lastFeedTime < block.timestamp - 12 hours; // Robber hungry?
    state.robberCoolingDown =
      lastStealTimes[attackerTokenId] >
      block.timestamp - (attackerInfo.xp >= 10000 ? 12 hours : 24 hours); // Robber cooling down?
    state.participants = currentStealParticipants[victimTokenId]; // Current participants in robbery
    state.robberyStartTime = currentSteals[victimTokenId]; // Robbery start time
    state.robberyInProgress = block.timestamp <= currentSteals[victimTokenId] + 15 minutes; // Robbery in progress
    state.robberyFinished =
      block.timestamp > currentSteals[victimTokenId] + 15 minutes &&
      block.timestamp < currentSteals[victimTokenId] + 30 minutes; // Robbery finished and claimable
    state.robberyWinnerTokenId = state.robberyInProgress
      ? 10000
      : currentStealWinning[victimTokenId];
    state.robberyWinnerCaller = state.robberyInProgress
      ? false
      : isTokenOwner(currentStealWinning[victimTokenId]);
  }

  /** PUBLIC GEN-1 */
  function mintGen1(uint256 tokenId) external {
    require(isTokenOwner(tokenId), 'Token not owned by caller');
    require(
      !IMonstaPartyGen1NFT(ADDRESS_MONSTA_PARTY_GEN1_NFT).exists(tokenId),
      'Gen-1 already minted'
    );

    NftInfo storage info = infos[tokenId];

    require(info.xp >= 10000, 'PXP must be larger than 10,000');

    IMonstaPartyGen1NFT(ADDRESS_MONSTA_PARTY_GEN1_NFT).mint(_msgSender(), tokenId);

    // Create new random value
    info.random = _pseudoRandom(_msgSender(), tokenId, 1, 10);
  }

  function upgradeToGen1(uint256 tokenId) external payable {
    require(isTokenOwner(tokenId), 'Token not owned by caller');
    require(
      !IMonstaPartyGen1NFT(ADDRESS_MONSTA_PARTY_GEN1_NFT).exists(tokenId),
      'Gen-1 already minted'
    );

    NftInfo storage info = infos[tokenId];

    require(info.xp < 10000, 'PXP must be less than 10,000');

    uint256 xpNeeded = 10000 - info.xp;

    // Calc upgrade costs
    uint256 costs = xpNeeded * 0.0016 ether;

    require(msg.value >= costs, 'Insufficient amount');

    IMonstaPartyGen1NFT(ADDRESS_MONSTA_PARTY_GEN1_NFT).mint(_msgSender(), tokenId);

    // Create new random value
    info.random = _pseudoRandom(_msgSender(), tokenId, 1, 10);

    addXp(info, xpNeeded);

    (bool success, ) = address(0x3F4a2737bcc610eE757265d680f81C3D3CbbbFf8).call{ value: msg.value }(
      ''
    );
    require(success, 'Failed to send BNB');
  }

  /** PRIVATE/INTERNAL/OVERRIDES **/

  function buyMonsta() private {
    uint256 bnbBalance = address(this).balance;

    if (bnbBalance < 0.3 ether) {
      // Skip buying until threshold is reached
      return;
    }

    // Send 6% BNB to MK/DEV
    (bool success1, ) = ADDRESS_MK_DEV.call{ value: _pct(40000, bnbBalance) }('');
    require(success1, 'Failed to send BNB');

    // Send 4% BNB to MP Multisig
    (bool success2, ) = address(0xeC0de011604878A977976835ebBc06bF0d814Cd7).call{
      value: _pct(60000, bnbBalance)
    }('');
    require(success2, 'Failed to send BNB');

    bnbBalance = address(this).balance;

    // Buy $MONSTA
    uint256 monstaBalanceBefore = IERC20(ADDRESS_CAKE_MONSTER).balanceOf(address(this));

    _swapEthToToken(ADDRESS_CAKE_MONSTER, bnbBalance);

    uint256 monstaBalanceAfter = IERC20(ADDRESS_CAKE_MONSTER).balanceOf(address(this));

    require(monstaBalanceAfter > monstaBalanceBefore, 'Could not buy $MONSTA');

    uint256 monstaDiff = SafeMathUpgradeable.sub(monstaBalanceAfter, monstaBalanceBefore);

    addReward(monstaDiff);
  }

  function activate(uint256 tokenId) private {
    require(isTokenOwner(tokenId), 'Token not owned by caller');

    NftInfo storage info = infos[tokenId];

    require(info.hatchTime == 0, 'Egg already activated');

    uint256 randomValue = IMonstaPartyNFT(ADDRESS_MONSTA_PARTY_NFT).getRandom(tokenId);

    require(randomValue > 0, 'Token not minted');

    info.generation = 0;
    info.hatchTime = IMonstaPartyNFT(ADDRESS_MONSTA_PARTY_NFT).getHatchTime(tokenId);
    info.lastFeedTime = 0;
    info.lastXpUpdateTime = block.timestamp;
    info.random = randomValue;

    // Set random init xp
    addXp(info, (randomValue % 200) + 50);
  }

  function addXp(NftInfo storage info, uint256 amount) private {
    if (info.xp >= 100000) {
      return;
    }

    info.xp += amount;
    totalXp += amount;

    uint256 diff = 0;
    if (info.xp > 100000) {
      diff = info.xp - 100000;
      info.xp = 100000;
      totalXp -= diff;
    }

    info.rewardTracker += rewardPerXp * (amount - diff);
    info.lastXpUpdateTime = block.timestamp;
  }

  function removeXp(NftInfo storage info, uint256 amount) private {
    info.xp -= amount;
    totalXp -= amount;

    info.rewardTracker -= rewardPerXp * amount;
    info.lastXpUpdateTime = block.timestamp;
  }

  function addReward(uint256 amount) private {
    if (totalXp == 0) {
      return;
    }

    rewardPerXp += amount / totalXp;
    rewardsTotal += amount;
  }

  function claimMonstaRewards(NftInfo storage info, uint256 tokenId) private {
    uint256 reward = getRewardClaimAmount(tokenId);

    info.rewardTracker = info.xp * rewardPerXp;

    if (reward > 0) {
      info.rewards += reward;

      // Send reward
      IERC20(ADDRESS_CAKE_MONSTER).transfer(_msgSender(), reward);
    }
  }

  function claimXpRewards(NftInfo storage info, uint256 tokenId) private {
    // Calculate XP growth since last update
    uint256 dailyGrowth = getXpClaimAmount(tokenId);

    addXp(info, dailyGrowth);

    lastDailyGrowthClaim[tokenId] = block.timestamp / 1 days;
  }

  function isTokenOwner(uint256 tokenId) private view returns (bool) {
    return IERC721(ADDRESS_MONSTA_PARTY_NFT).ownerOf(tokenId) == _msgSender();
  }

  /** UTILS **/

  function _pct(uint256 pct10000, uint256 amount) private pure returns (uint256) {
    return SafeMathUpgradeable.div(SafeMathUpgradeable.mul(pct10000, amount), 1000000);
  }

  function _share(
    uint256 a,
    uint256 b,
    uint256 c
  ) private pure returns (uint256) {
    return
      SafeMathUpgradeable.div(
        SafeMathUpgradeable.mul(SafeMathUpgradeable.div(SafeMathUpgradeable.mul(a, 10000), b), c),
        10000
      );
  }

  function _pseudoRandom(
    address addy,
    uint256 tokenId,
    uint256 rangeStart,
    uint256 rangeEnd
  ) public view returns (uint256) {
    return
      (uint256(keccak256(abi.encodePacked(block.timestamp, addy, tokenId))) %
        (rangeEnd - rangeStart)) + rangeStart;
  }

  function _swapEthToToken(address _tokenOut, uint256 _amountIn) private {
    address[] memory path = new address[](2);
    path[0] = ISwapRouter(ADDRESS_SWAP_ROUTER).WETH();
    path[1] = _tokenOut;

    ISwapRouter(ADDRESS_SWAP_ROUTER).swapExactETHForTokensSupportingFeeOnTransferTokens{
      value: _amountIn
    }(0, path, address(this), block.timestamp);
  }

  function _swapEthToTokenToAddress(
    address _tokenOut,
    uint256 _amountIn,
    address _to
  ) private {
    address[] memory path = new address[](2);
    path[0] = ISwapRouter(ADDRESS_SWAP_ROUTER).WETH();
    path[1] = _tokenOut;

    ISwapRouter(ADDRESS_SWAP_ROUTER).swapExactETHForTokensSupportingFeeOnTransferTokens{
      value: _amountIn
    }(0, path, _to, block.timestamp);
  }
}