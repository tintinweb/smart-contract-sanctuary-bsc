// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "./LinkedList.sol";

interface IERC20 {
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);
}

contract SubscriptionManager is ERC721Upgradeable, OwnableUpgradeable {
  using LinkedList for LinkedList.List;

  struct Subscription {
    uint256 id;
    address author;
    uint256 expiration;
    uint8 level; // index from 0 to `maxSubscriptionLevels`
    bool autoRenewal; // subscription autorenew
    uint16 period; // in month
    uint256 amount;
    uint256 cost;
  }

  struct SubscriptionLevel {
    uint256 price;
    uint8 accessLevel;
    uint256 availableSupply;
    bool limited;
    bool isActive;
  }

  // Mapping from token ID to subscription data
  mapping(uint256 => Subscription) public subscriptions;

  // Mapping from author to subscription levels [SubscriptionLevel, SubscriptionLevel, SubscriptionLevel]
  mapping(address => SubscriptionLevel[]) public subscriptionLevels;

  /**
   * @dev Mapping from user to structured linked lists of ids owned subscriptions by author
   * user => author => [LinkedList, LinkedList, LinkedList]
   */
  mapping(address => mapping(address => LinkedList.List[]))
    private userSubscriptionsByAuthor;

  struct AuthorReferralConfig {
    uint16 referrerShare; // share of referrer
    uint16 annualDiscount; // discount for a subscription for a year
  }

  /**
   * @dev Mapping from author to referral config
   * author => [AuthorReferralConfig]
   */
  mapping(address => AuthorReferralConfig) public authorReferralConfigs;

  struct UserRefData {
    address invitedBy;
    uint16 referrerShare; // fixing the share of referrer who invited the user
    uint16 referralShare; // referral share of user's referrer fee
  }

  /**
   * @dev Mapping from user to referral data by author
   * In one case, the user is a subscriber invited by another referrer (the referrer is saved in the `invitedBy` field),
   * in the other - user is a referrer who determines which part of his reward to share with the referral as a discount
   * user => author => UserRefData
   */
  mapping(address => mapping(address => UserRefData))
    public userRefDataByAuthor;

  uint256 public totalSupply;
  uint16 public serviceShare;
  uint16 public executorShare;
  uint256 public minPrice;
  uint8 public maxSubscriptionLevels;
  uint256 private constant DENOMINATOR = 10000;

  function initialize() public initializer {
    __ERC721_init("Subscriptions Club", "SUBCLUB");
    __Ownable_init();

    totalSupply = 0;
    serviceShare = 1000; // 10%
    executorShare = 1000; // 10% of serviceShare
    minPrice = 5 ether;
    maxSubscriptionLevels = 3;
  }

  IERC20 public token;

  event UpdateSubscription(
    address subscriber,
    address author,
    uint8 level,
    uint256 expiration,
    uint256 amount,
    uint16 period
  );

  event UpdateAutoRenew(
    address subscriber,
    address author,
    uint8 level,
    bool autoRenewal
  );

  event SetToken(address token);

  event SetServiceShare(uint16 share);

  event SetExecutorShare(uint16 share);

  event SetMinPrice(uint256 minPrice);

  event SetMaxSubscriptionLevels(uint8 maxSubscriptionLevels);

  event SetSubscriptionLevel(
    address author,
    uint256 price,
    uint8 level,
    uint256 availableSupply,
    bool limited,
    bool isActive,
    uint8 accessLevel
  );

  event SetReferrerShare(address author, uint16 share);

  event SetAnnualDiscount(address author, uint16 discount);

  event SetReferralShareOfReferrerFee(
    address referrer,
    address author,
    uint16 referralShare
  );

  function authorSubscriptionLevels(address author)
    external
    view
    returns (SubscriptionLevel[] memory)
  {
    return subscriptionLevels[author];
  }

  function userTopSubscriptionsByAuthor(address user, address author)
    public
    view
    returns (Subscription[] memory)
  {
    uint256 arrayLength = userSubscriptionsByAuthor[user][author].length;

    Subscription[] memory _subscriptions = new Subscription[](arrayLength);

    for (uint256 index = 0; index < arrayLength; index++) {
      _subscriptions[index] = userTopSubscriptionByAuthor(
        user,
        author,
        uint8(index)
      );
    }
    return _subscriptions;
  }

  function userTopSubscriptionByAuthor(
    address user,
    address author,
    uint8 level
  ) internal view returns (Subscription storage) {
    require(
      level < userSubscriptionsByAuthor[user][author].length,
      "No such level"
    );
    LinkedList.List storage subscriptionsList = userSubscriptionsByAuthor[user][
      author
    ][level];

    (, uint256 id) = subscriptionsList.getFirstNode();

    return subscriptions[id];
  }

  function mint(
    address to,
    address author,
    uint256 expiration,
    uint8 level,
    bool autoRenewal,
    uint16 period,
    uint256 amount,
    uint256 cost
  ) internal {
    uint256 tokenId = ++totalSupply;

    Subscription memory newSubscription = Subscription({
      id: tokenId,
      author: author,
      expiration: expiration,
      level: level,
      autoRenewal: autoRenewal,
      period: period,
      amount: amount,
      cost: cost
    });

    subscriptions[tokenId] = newSubscription;

    _safeMint(to, tokenId);
  }

  function subscribe(
    address author,
    uint256 period,
    uint8 level,
    bool autoRenewal,
    address referrer,
    uint256 amount
  ) external {
    require(amount > 0, "amount < 1");
    require(period > 0, "period < 1");
    require(level < subscriptionLevels[author].length, "Incorrect level");

    SubscriptionLevel storage subscriptionLevel = subscriptionLevels[author][
      level
    ];

    require(subscriptionLevel.isActive, "Inactive level");
    if (subscriptionLevel.limited)
      require(subscriptionLevel.availableSupply > 0, "Sold out");

    UserRefData storage userRefData = userRefDataByAuthor[msg.sender][author];
    if (
      userRefData.invitedBy == address(0) &&
      referrer != address(0) &&
      referrer != msg.sender
    ) {
      userRefData.invitedBy = referrer;
      userRefData.referrerShare = authorReferralConfigs[author].referrerShare;
    }
    referrer = userRefData.invitedBy;

    uint256 totalCost = calcAndDistributeFees(
      msg.sender,
      author,
      referrer,
      (subscriptionLevel.price * period * amount),
      period
    );

    mint(
      msg.sender,
      author,
      block.timestamp + period * 30 days, // expiration
      level,
      autoRenewal,
      uint16(period),
      amount,
      totalCost
    );

    if (subscriptionLevel.limited) subscriptionLevel.availableSupply--;
  }

  function calcAndDistributeFees(
    address subscriber,
    address author,
    address referrer,
    uint256 cost,
    uint256 period
  ) internal returns (uint256) {
    (
      uint256 totalCost,
      uint256 authorFee,
      uint256 referrerFee,
      uint256 adminFee,
      uint256 executorFee
    ) = calcCostAndFees(subscriber, author, referrer, cost, period);

    distributeFees(
      subscriber,
      author,
      referrer,
      authorFee,
      referrerFee,
      adminFee,
      executorFee
    );

    return totalCost;
  }

  function calcCostAndFees(
    address subscriber,
    address author,
    address referrer,
    uint256 cost,
    uint256 period
  )
    public
    view
    returns (
      uint256 totalCost,
      uint256 authorFee,
      uint256 referrerFee,
      uint256 adminFee,
      uint256 executorFee
    )
  {
    adminFee = (cost * uint256(serviceShare)) / DENOMINATOR;

    authorFee = cost - adminFee;

    uint256 annualDiscount = 0;
    if (authorReferralConfigs[author].annualDiscount > 0 && period > 1) {
      if (period > 12) period = 12;

      uint256 discountShare = ((authorReferralConfigs[author].annualDiscount /
        12) * period);
      annualDiscount = (authorFee * discountShare) / DENOMINATOR;

      authorFee -= annualDiscount;
    }

    referrerFee =
      (authorFee * userRefDataByAuthor[msg.sender][author].referrerShare) /
      DENOMINATOR;

    uint256 referralDiscount = 0;
    if (referrer != address(0) && referrerFee > 0) {
      uint16 referralShareOfReferrerFee = userRefDataByAuthor[referrer][author]
        .referralShare;

      if (referralShareOfReferrerFee == 0) {
        referralShareOfReferrerFee = userRefDataByAuthor[referrer][address(0)]
          .referralShare;
      }

      referralDiscount =
        (referrerFee * uint256(referralShareOfReferrerFee)) /
        DENOMINATOR;
    }

    authorFee -= referrerFee;
    referrerFee -= referralDiscount;
    totalCost = cost - referralDiscount - annualDiscount;

    if (msg.sender != subscriber) {
      executorFee = (adminFee * uint256(executorShare)) / DENOMINATOR;
      adminFee -= executorFee;
    }
  }

  function distributeFees(
    address subscriber,
    address author,
    address referrer,
    uint256 authorFee,
    uint256 referrerFee,
    uint256 adminFee,
    uint256 executorFee
  ) internal {
    if (referrer != address(0) && referrerFee > 0) {
      token.transferFrom(subscriber, referrer, referrerFee);
    }

    if (authorFee > 0) {
      token.transferFrom(subscriber, author, authorFee);
    }

    token.transferFrom(subscriber, owner(), adminFee);
    if (executorFee > 0)
      token.transferFrom(subscriber, msg.sender, executorFee);
  }

  function upgradeSubscription(
    address author,
    uint8 level,
    uint8 upgradeLevel,
    uint256 upgradeAmount,
    uint256 upgradePeriod
  ) external {
    require(upgradeAmount > 0, "upgradeAmount == 0");

    LinkedList.List[] storage userSubscriptionsList = userSubscriptionsByAuthor[
      msg.sender
    ][author];

    if (userSubscriptionsList.length <= level) {
      for (
        uint256 index = userSubscriptionsList.length;
        index <= level;
        index++
      ) {
        userSubscriptionsList.push();
      }
    }

    require(
      subscriptionLevels[author].length > upgradeLevel &&
        subscriptionLevels[author][upgradeLevel].isActive,
      "Level is not active"
    );

    Subscription storage subscription = userTopSubscriptionByAuthor(
      msg.sender,
      author,
      level
    );

    require(subscription.expiration > block.timestamp, "Can't be upgraded");

    uint256 costTillExpiration = (subscription.expiration - block.timestamp) *
      (subscription.cost / (uint256(subscription.period) * 30 days)); // (time till expiration in seconds) * (cost in seconds)

    uint256 upgradeCost = (subscriptionLevels[author][upgradeLevel].price *
      upgradePeriod *
      upgradeAmount) - costTillExpiration;

    uint256 totalCost = calcAndDistributeFees(
      msg.sender,
      author,
      userRefDataByAuthor[msg.sender][author].invitedBy,
      upgradeCost,
      upgradePeriod
    );

    if (subscription.level != upgradeLevel) {
      userSubscriptionsByAuthor[msg.sender][author][subscription.level].remove(
        subscription.id
      );

      userSubscriptionsByAuthor[msg.sender][author][upgradeLevel].insertSorted(
        IStructureInterface(address(this)),
        subscription.id
      );
    }
    subscription.cost = totalCost;
    subscription.expiration = (block.timestamp + upgradePeriod * 30 days);
    subscription.level = upgradeLevel;
    subscription.amount = upgradeAmount;
    subscription.period = uint16(upgradePeriod);

    emit UpdateSubscription(
      msg.sender,
      author,
      upgradeLevel,
      subscription.expiration,
      upgradeAmount,
      uint16(upgradePeriod)
    );
  }

  function renewSubscription(
    address subscriber,
    address author,
    uint8 level
  ) external {
    Subscription storage subscription = userTopSubscriptionByAuthor(
      subscriber,
      author,
      level
    );

    uint256 period = uint256(subscription.period);
    uint256 expiration = subscription.expiration;

    require(subscription.autoRenewal, "Not auto-renewable");
    require(
      expiration > block.timestamp && expiration < (block.timestamp + 1 days),
      "Can't be renewed"
    );

    SubscriptionLevel storage subscriptionLevel = subscriptionLevels[author][
      level
    ];
    require(subscriptionLevel.isActive, "Level is inactive");

    address referrer = userRefDataByAuthor[subscriber][author].invitedBy;

    (
      uint256 totalCost,
      uint256 authorFee,
      uint256 referrerFee,
      uint256 adminFee,
      uint256 executorFee
    ) = calcCostAndFees(
        subscriber,
        author,
        referrer,
        (subscriptionLevel.price * period * subscription.amount),
        period
      );

    require(subscription.cost <= totalCost, "pastCost > totalCost");

    distributeFees(
      subscriber,
      author,
      referrer,
      authorFee,
      referrerFee,
      adminFee,
      executorFee
    );

    subscription.expiration = (block.timestamp + period * 30 days);

    emit UpdateSubscription(
      subscriber,
      author,
      level,
      expiration,
      subscription.amount,
      uint16(period)
    );
  }

  function updateAutoRenewal(
    address author,
    uint8 level,
    bool autoRenewal
  ) external {
    Subscription storage subscription = userTopSubscriptionByAuthor(
      msg.sender,
      author,
      level
    );

    subscription.autoRenewal = autoRenewal;

    emit UpdateAutoRenew(msg.sender, author, level, autoRenewal);
  }

  function removeExpiredSubscriptions(uint256 start, uint256 limit) external {
    require(limit <= totalSupply, "limit > totalSupply");
    require(start < limit, "start < limit");

    for (uint256 id = start; id <= limit; id++) {
      if (
        subscriptions[id].expiration > 0 &&
        subscriptions[id].expiration < (block.timestamp - 1 days)
      ) {
        _burn(id);
      }
    }
  }

  function setSubscriptionLevel(
    uint256 price,
    uint8 level,
    uint256 availableSupply,
    bool limited,
    bool isActive,
    uint8 accessLevel
  ) external {
    if (msg.sender != owner()) require(price >= minPrice, "price < minPrice");

    if (limited) {
      require(availableSupply > 0, "availableSupply < 0");
    }

    SubscriptionLevel[] storage _authorSubscriptionLevels = subscriptionLevels[
      msg.sender
    ];

    require(
      level < maxSubscriptionLevels &&
        _authorSubscriptionLevels.length >= level,
      "Invalid level"
    );

    SubscriptionLevel memory newSubscriptionLevel = SubscriptionLevel({
      price: price,
      accessLevel: 0,
      availableSupply: availableSupply,
      limited: limited,
      isActive: isActive
    });

    if (level < _authorSubscriptionLevels.length) {
      newSubscriptionLevel.accessLevel = _authorSubscriptionLevels[level]
        .accessLevel;

      _authorSubscriptionLevels[level] = newSubscriptionLevel;
    } else {
      require(
        accessLevel <= _authorSubscriptionLevels.length,
        "Invalid accessLevel"
      );
      for (uint8 index = 0; index < _authorSubscriptionLevels.length; index++) {
        if (_authorSubscriptionLevels[index].accessLevel >= accessLevel) {
          _authorSubscriptionLevels[index].accessLevel++;
        }
      }

      newSubscriptionLevel.accessLevel = accessLevel;
      _authorSubscriptionLevels.push(newSubscriptionLevel);
    }

    emit SetSubscriptionLevel(
      msg.sender,
      price,
      level,
      availableSupply,
      limited,
      isActive,
      accessLevel
    );
  }

  function setToken(address _address) external onlyOwner {
    token = IERC20(_address);
    emit SetToken(_address);
  }

  function setServiceShare(uint16 share) external onlyOwner {
    require(share < DENOMINATOR);
    serviceShare = share;
    emit SetServiceShare(share);
  }

  function setExecutorShare(uint16 share) external onlyOwner {
    require(share < DENOMINATOR);
    executorShare = share;
    emit SetExecutorShare(share);
  }

  function setMinPrice(uint256 _minPrice) external onlyOwner {
    minPrice = _minPrice;
    emit SetMinPrice(_minPrice);
  }

  function setMaxSubscriptionLevels(uint8 _maxSubscriptionLevels)
    external
    onlyOwner
  {
    maxSubscriptionLevels = _maxSubscriptionLevels;
    emit SetMaxSubscriptionLevels(_maxSubscriptionLevels);
  }

  function setReferrerShare(uint16 share) external {
    require(share < DENOMINATOR);

    authorReferralConfigs[msg.sender].referrerShare = share;

    emit SetReferrerShare(msg.sender, share);
  }

  function setAnnualDiscount(uint16 discount) external {
    require(discount < DENOMINATOR);

    authorReferralConfigs[msg.sender].annualDiscount = discount;

    emit SetAnnualDiscount(msg.sender, discount);
  }

  function setReferralShareOfReferrerFeeByAuthor(
    address author,
    uint16 referralShare
  ) external {
    require(referralShare < DENOMINATOR);

    userRefDataByAuthor[msg.sender][author].referralShare = referralShare;

    emit SetReferralShareOfReferrerFee(msg.sender, author, referralShare);
  }

  function getValue(uint256 _id) external view returns (uint256) {
    return subscriptions[_id].expiration;
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal override {
    super._beforeTokenTransfer(from, to, tokenId);

    Subscription storage subscription = subscriptions[tokenId];
    address author = subscription.author;
    uint8 level = subscription.level;

    if (subscription.autoRenewal) subscription.autoRenewal = false;

    if (from != address(0) && to != address(0)) {
      require(author != owner(), "Forbidden");
    }

    if (from != address(0)) {
      userSubscriptionsByAuthor[from][author][level].remove(tokenId);
    }

    if (to == address(0)) {
      delete subscriptions[tokenId];
      return;
    }

    LinkedList.List[] storage userSubscriptionsList = userSubscriptionsByAuthor[
      to
    ][author];
    if (userSubscriptionsList.length <= level) {
      for (
        uint256 index = userSubscriptionsList.length;
        index <= level;
        index++
      ) {
        userSubscriptionsList.push();
      }
    }

    IStructureInterface structure = IStructureInterface(address(this));

    userSubscriptionsByAuthor[to][author][level].insertSorted(
      structure,
      tokenId
    );
  }
}

// TODO: upgradeSubscription push level to level's array

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
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
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/ERC721.sol)

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
    function __ERC721_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
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
        _setApprovalForAll(_msgSender(), operator, approved);
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

        _afterTokenTransfer(address(0), to, tokenId);
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

        _afterTokenTransfer(owner, address(0), tokenId);
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
        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
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
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
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

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[44] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IStructureInterface {
  function getValue(uint256 _id) external view returns (uint256);
}

/**
 * @title LinkedList
 * @author Vittorio Minacori (https://github.com/vittominacori)
 * @dev An utility library for using sorted linked list data structures in your Solidity project.
 */
library LinkedList {
  uint256 private constant _NULL = 0;
  uint256 private constant _HEAD = 0;

  bool private constant _PREV = false;
  bool private constant _NEXT = true;

  struct List {
    uint256 size;
    mapping(uint256 => mapping(bool => uint256)) list;
  }

  /**
   * @dev Checks if the node exists
   * @param self stored linked list from contract
   * @param _node a node to search for
   * @return bool true if node exists, false otherwise
   */
  function nodeExists(List storage self, uint256 _node)
    internal
    view
    returns (bool)
  {
    if (self.list[_node][_PREV] == _HEAD && self.list[_node][_NEXT] == _HEAD) {
      if (self.list[_HEAD][_NEXT] == _node) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  /**
   * @dev Returns the number of elements in the list
   * @param self stored linked list from contract
   * @return uint256
   */
  function sizeOf(List storage self) internal view returns (uint256) {
    return self.size;
  }

  /**
   * @dev Returns the link of a node `_node` in direction `_direction`.
   * @param self stored linked list from contract
   * @param _node id of the node to step from
   * @param _direction direction to step in
   * @return bool, uint256 true if node exists or false otherwise, node in _direction
   */
  function getAdjacent(
    List storage self,
    uint256 _node,
    bool _direction
  ) internal view returns (bool, uint256) {
    if (!nodeExists(self, _node)) {
      return (false, 0);
    } else {
      return (true, self.list[_node][_direction]);
    }
  }

  /**
   * @dev Returns the first link of list.
   * @param self stored linked list from contract
   * @return bool, uint256 true if node exists or false otherwise, next node
   */
  function getFirstNode(List storage self)
    internal
    view
    returns (bool, uint256)
  {
    return getAdjacent(self, _HEAD, _NEXT);
  }

  /**
   * @dev Can be used before `insert` to build an ordered list.
   * @dev Get the node and then `insertBefore` or `insertAfter` basing on your list order.
   * @dev If you want to order basing on other than `structure.getValue()` override this function
   * @param self stored linked list from contract
   * @param _structure the structure instance
   * @param _value value to seek
   * @return uint256 next node with a value less than _value
   */
  function getSortedSpot(
    List storage self,
    IStructureInterface _structure,
    uint256 _value
  ) internal view returns (uint256) {
    if (sizeOf(self) == 0) {
      return 0;
    }

    (, uint256 next) = getAdjacent(self, _HEAD, _NEXT);
    while ((next != 0) && (_value <= _structure.getValue(next))) {
      next = self.list[next][_NEXT];
    }
    return next;
  }

  /**
   * @dev Insert node `_new` before sorted spot.
   * @param self stored linked list from contract
   * @param _structure  the structure instance
   * @param _new  new node to insert
   * @return bool true if success, false otherwise
   */
  function insertSorted(
    List storage self,
    IStructureInterface _structure,
    uint256 _new
  ) internal returns (bool) {
    uint256 value = _structure.getValue(_new);
    uint256 sortedSpot = getSortedSpot(self, _structure, value);

    return insertBefore(self, sortedSpot, _new);
  }

  /**
   * @dev Insert node `_new` beside existing node `_node` in direction `_NEXT`.
   * @param self stored linked list from contract
   * @param _node existing node
   * @param _new  new node to insert
   * @return bool true if success, false otherwise
   */
  function insertAfter(
    List storage self,
    uint256 _node,
    uint256 _new
  ) internal returns (bool) {
    return _insert(self, _node, _new, _NEXT);
  }

  /**
   * @dev Insert node `_new` beside existing node `_node` in direction `_PREV`.
   * @param self stored linked list from contract
   * @param _node existing node
   * @param _new  new node to insert
   * @return bool true if success, false otherwise
   */
  function insertBefore(
    List storage self,
    uint256 _node,
    uint256 _new
  ) internal returns (bool) {
    return _insert(self, _node, _new, _PREV);
  }

  /**
   * @dev Removes an entry from the linked list
   * @param self stored linked list from contract
   * @param _node node to remove from the list
   * @return uint256 the removed node
   */
  function remove(List storage self, uint256 _node) internal returns (uint256) {
    if ((_node == _NULL) || (!nodeExists(self, _node))) {
      return 0;
    }
    _createLink(self, self.list[_node][_PREV], self.list[_node][_NEXT], _NEXT);
    delete self.list[_node][_PREV];
    delete self.list[_node][_NEXT];

    self.size -= 1; // NOT: SafeMath library should be used here to decrement.

    return _node;
  }

  /**
   * @dev Insert node `_new` beside existing node `_node` in direction `_direction`.
   * @param self stored linked list from contract
   * @param _node existing node
   * @param _new  new node to insert
   * @param _direction direction to insert node in
   * @return bool true if success, false otherwise
   */
  function _insert(
    List storage self,
    uint256 _node,
    uint256 _new,
    bool _direction
  ) private returns (bool) {
    if (!nodeExists(self, _new) && nodeExists(self, _node)) {
      uint256 c = self.list[_node][_direction];
      _createLink(self, _node, _new, _direction);
      _createLink(self, _new, c, _direction);

      self.size += 1; // NOT: SafeMath library should be used here to increment.

      return true;
    }

    return false;
  }

  /**
   * @dev Creates a bidirectional link between two nodes on direction `_direction`
   * @param self stored linked list from contract
   * @param _node existing node
   * @param _link node to link to in the _direction
   * @param _direction direction to insert node in
   */
  function _createLink(
    List storage self,
    uint256 _node,
    uint256 _link,
    bool _direction
  ) private {
    self.list[_link][!_direction] = _node;
    self.list[_node][_direction] = _link;
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

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
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
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