// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./coin.sol";

interface ReadI {
  function checkArmyAmount(address) external view returns (uint256);

  function checkSpecOpsAmount(address) external view returns (uint256);

  function checkSpaceForceAmount(address) external view returns (uint256);

  function checkPlayers() external view returns (uint256);

  function checkTimestamp(address) external view returns (uint256);

  function readRefCode(address) external view returns (uint256);

  function checkRefed(address) external view returns (bool);

  function readReferals(address) external view returns (address[] memory);

  function checkRefMoney(address) external view returns (uint256);
}

contract ArmiesV4 {
  address private Owner;
  AI private tokenContract1;
  IERC20 private tokenContract2;
  ReadI private oldGameContract;

  uint8 tokendecimals;

  // Army Attributes.
  uint256 taxAmount = 15;
  uint8 constant armyPrice = 100;
  uint256 specOpsPrice = 0.015 ether;
  uint8 constant specOpsPriceInArmies = 10;
  uint256 spaceForcePrice = 0.15 ether;
  uint8 constant spaceForcePriceInSpecOps = 10;
  uint256 starPrice = 0.1 ether;
  uint256[] armyRefPerc = [2000, 1000, 500, 250, 125];
  uint256 constant armyYieldTime = 27;
  uint256 armyYield = 156250;

  bool armiespaused = true;

  // Contract Variables.
  uint256 totalArmies = 0;
  uint256 totalSpecOps = 0;
  uint256 totalSpaceForce = 0;
  uint256 totalPlayers = 0;
  address[] playerList;

  // User structure
  struct User {
    bool merged;
    // Army stats
    uint256 armies;
    uint256 specOps;
    uint256 spaceForce;
    uint8 stars;
    uint256 timestamp;
    uint256 buffer;
    // Referral values
    uint256 refCode;
    bool refed;
    address[] referals;
    address referrer;
    uint256 refMoney;
  }
  mapping(address => User) users;

  mapping(uint256 => address) refOwner;

  mapping(address => bool) blacklists;

  event Ownership(
    address indexed owner,
    address indexed newOwner,
    bool indexed added
  );

  constructor(
    AI _tokenContract1,
    IERC20 _tokenContract2,
    ReadI _oldGameContract,
    address _owner
  ) {
    Owner = _owner;
    tokenContract1 = _tokenContract1;
    tokenContract2 = _tokenContract2;
    oldGameContract = _oldGameContract;
    tokendecimals = tokenContract1.decimals();
  }

  modifier OnlyOwners() {
    require((msg.sender == Owner), "You are not the owner of the token");
    _;
  }

  modifier BlacklistCheck() {
    require(blacklists[msg.sender] == false, "You are in the blacklist");
    _;
  }

  modifier ArmiesStopper() {
    require(armiespaused == false, "Armies code is currently stopped.");
    _;
  }

  event ArmiesCreated(address indexed who, uint256 indexed amount);
  event SpecOpsCreated(address indexed who, uint256 indexed amount);
  event SpaceForceCreated(address indexed who, uint256 indexed amount);
  event StarsCreated(address indexed who, uint256 indexed amount);

  event Blacklist(
    address indexed owner,
    address indexed blacklisted,
    bool indexed added
  );

  // # User Write functions

  function createArmies(uint256 _amount) public ArmiesStopper BlacklistCheck {
    uint256 userBalance = tokenContract2.balanceOf(msg.sender);
    uint256 bonus = 0;
    uint256 price = _amount * armyPrice * 10 ** tokendecimals;
    User storage currentUser = users[msg.sender];

    _transferClaimToRef(msg.sender);

    if (!currentUser.merged) {
      if (
        (oldGameContract.checkArmyAmount(msg.sender) > 0) ||
        (oldGameContract.checkSpecOpsAmount(msg.sender) > 0) ||
        (oldGameContract.checkSpaceForceAmount(msg.sender) > 0)
      ) {
        _merge(msg.sender);
      } else {
        currentUser.merged = true;
      }
    }
    if (currentUser.refed && ((currentUser.buffer + _amount) / 10 > 0)) {
      bonus = (currentUser.buffer + _amount) / 10;
      currentUser.buffer = (currentUser.buffer + _amount) % 10;
    }

    require(userBalance >= price, "You do not have enough SOLDAT!");
    tokenContract2.transferFrom(msg.sender, address(this), price);

    if (
      currentUser.armies == 0 &&
      currentUser.specOps == 0 &&
      currentUser.spaceForce == 0
    ) {
      totalPlayers += 1;
      playerList.push(msg.sender);
    }

    currentUser.armies += _amount + bonus;
    totalArmies += _amount + bonus;

    if (currentUser.timestamp == 0) {
      currentUser.timestamp = block.timestamp;
    }

    emit ArmiesCreated(msg.sender, _amount + bonus);
  }

  function reinvest(uint256 _amount) public ArmiesStopper BlacklistCheck {
    User storage currentUser = users[msg.sender];
    require(((block.timestamp - currentUser.timestamp) / armyYieldTime) > 0);
    uint256 userBalance = currentUser.refMoney + checkArmyMoney(msg.sender);
    uint256 price = _amount * armyPrice * 10 ** tokendecimals;
    require(userBalance >= price, "You do not have enough SOLDAT!");

    if (currentUser.refed) {
      _refDistribute(msg.sender, price);
    }
    uint256 left = userBalance - price;
    currentUser.timestamp +=
      ((block.timestamp - currentUser.timestamp) / armyYieldTime) *
      armyYieldTime;

    currentUser.refMoney = left;

    currentUser.armies += _amount;
    totalArmies += _amount;

    emit ArmiesCreated(msg.sender, _amount);
  }

  function claimArmyMoney(address _who) public ArmiesStopper BlacklistCheck {
    User storage currentUser = users[_who];
    require(((block.timestamp - currentUser.timestamp) / armyYieldTime) > 0);
    uint256 _amount = checkArmyMoney(_who);
    require(_amount + currentUser.refMoney > 0);

    if (currentUser.refed) {
      _refDistribute(_who, _amount);
    }

    currentUser.timestamp +=
      ((block.timestamp - currentUser.timestamp) / armyYieldTime) *
      armyYieldTime;
    uint256 _tax = ((_amount + currentUser.refMoney) * taxAmount) / 100;

    tokenContract2.transfer(_who, _amount + currentUser.refMoney - _tax);
    currentUser.refMoney = 0;
  }

  function createSpecOps(
    uint256 _amount
  ) public payable ArmiesStopper BlacklistCheck {
    User storage currentUser = users[msg.sender];
    uint256 userArmies = checkArmyAmount(msg.sender);
    uint256 price = _amount * specOpsPrice;
    uint256 priceInArmies = _amount * specOpsPriceInArmies;

    require(msg.value >= price, "Not enough BNB provided!");
    require(
      userArmies >= priceInArmies,
      "The army amount is lower than the requirement"
    );

    _transferClaimToRef(msg.sender);

    currentUser.armies -= priceInArmies;
    currentUser.specOps += _amount;

    totalArmies -= priceInArmies;
    totalSpecOps += _amount;

    emit SpecOpsCreated(msg.sender, _amount);
  }

  function createSpaceForce(
    uint256 _amount
  ) public payable ArmiesStopper BlacklistCheck {
    User storage currentUser = users[msg.sender];
    uint256 userSpecOps = checkSpecOpsAmount(msg.sender);
    uint256 price = _amount * spaceForcePrice;
    uint256 priceInSpecOps = _amount * spaceForcePriceInSpecOps;

    require(msg.value >= price, "The amount is lower than the requirement");
    require(
      userSpecOps >= priceInSpecOps,
      "The army amount is lower than the requirement"
    );

    _transferClaimToRef(msg.sender);

    currentUser.specOps -= priceInSpecOps;
    currentUser.spaceForce += _amount;

    totalSpecOps -= priceInSpecOps;
    totalSpaceForce += _amount;

    emit SpaceForceCreated(msg.sender, _amount);
  }

  function createStars(
    uint8 _amount
  ) public payable ArmiesStopper BlacklistCheck {
    User storage currentUser = users[msg.sender];

    require(_amount != 0, "You cannot create 0 stars.");

    require(
      _amount <= 3 - currentUser.stars,
      "You cannot create more than 3 stars."
    );

    uint256 price = _amount * starPrice;
    require(msg.value >= price, "The amount is lower than the requirement.");

    _transferClaimToRef(msg.sender);
    currentUser.stars += _amount;

    emit StarsCreated(msg.sender, _amount);
  }

  function getRefd(uint256 _ref) public {
    address _referree = msg.sender;
    User storage currentUser = users[msg.sender];
    address _referrer = readRef(_ref);
    address[] memory _addresses = readRefLevels(_referrer);
    for (uint8 i = 0; i < _addresses.length; ) {

      require(
        _addresses[i] != msg.sender,
        "You cannot enter your own referral chain"
      );
      i++;
    }
    require(
      currentUser.armies == 0 &&
        currentUser.specOps == 0 &&
        currentUser.spaceForce == 0,
      "You are not eligible to getting referred!"
    );
    require(refOwner[_ref] != address(0), "Referral code does not exist!");
    require(_referrer != msg.sender, "You cannot refer yourself!");
    require(currentUser.refed == false, "You are already referred!");
    currentUser.referrer = _referrer;
    users[_referrer].referals.push(_referree);
    currentUser.refed = true;
  }

  function createRef() public {
    User storage currentUser = users[msg.sender];
    require(currentUser.refCode == 0, "You already have a referral code.");
    uint256 rand = uint256(
      keccak256(abi.encodePacked(msg.sender, block.number - 1))
    );
    uint256 result = uint256(rand % (10 ** 12));
    require(
      readRef(result) == address(0),
      "Generated code already exists. Transaction has been refunded. Please try again."
    );
    refOwner[result] = msg.sender;
    currentUser.refCode = result;
  }

  // # Read functions

  function totalArmyAmount() public view returns (uint256) {
    return (totalArmies);
  }

  function totalSpecOpsAmount() public view returns (uint256) {
    return (totalSpecOps);
  }

  function totalSpaceForceAmount() public view returns (uint256) {
    return (totalSpaceForce);
  }

  function checkArmyAmount(address _who) public view returns (uint256) {
    return (users[_who].armies);
  }

  function checkSpecOpsAmount(address _who) public view returns (uint256) {
    return (users[_who].specOps);
  }

  function checkSpaceForceAmount(address _who) public view returns (uint256) {
    return (users[_who].spaceForce);
  }

  function checkStarsAmount(address _who) public view returns (uint256) {
    return (users[_who].stars);
  }

  function checkMerge(address _who) public view returns (bool) {
    return users[_who].merged;
  }

  function checkPlayers() public view returns (uint256) {
    return (totalPlayers);
  }

  function checkPlayerList() public view returns (address[] memory) {
    return playerList;
  }

  function checkArmyMoney(address _who) public view returns (uint256) {
    User storage currentUser = users[_who];

    uint256 _cycles = ((block.timestamp - currentUser.timestamp) /
      armyYieldTime);

    uint256 _amount = (currentUser.armies *
      armyYield +
      currentUser.specOps *
      (armyYield * 16) +
      currentUser.spaceForce *
      (armyYield * 20 * (12 + currentUser.stars))) * _cycles;

    return _amount;
  }

  function checkRefMoney(address _who) public view returns (uint256) {
    return users[_who].refMoney;
  }

  function checkTimestamp(address _who) public view returns (uint256) {
    return users[_who].timestamp;
  }

  function readRef(uint256 _ref) public view returns (address) {
    return refOwner[_ref];
  }

  function readRefCode(address _who) public view returns (uint256) {
    return users[_who].refCode;
  }

  function checkRefed(address _who) public view returns (bool) {
    return users[_who].refed;
  }

  function checkReferrer(address _who) public view returns (address) {
    return users[_who].referrer;
  }

  function readReferals(address _who) public view returns (address[] memory) {
    return users[_who].referals;
  }

  function readBuffer(address _who) public view returns(uint256) {
    return users[_who].buffer;
  }

  function readRefLevels(address _who) public view returns (address[] memory) {
    address[] memory addresses = new address[](_findIterations(_who));
    for (uint i = 0; i < 5; ) {
      _who = checkReferrer(_who);
      if (_who == address(0)) break;
      addresses[i] = _who;
      i++;
    }
    return addresses;
  }

  // # Internal functions

  function _transferClaimToRef(address _who) internal ArmiesStopper {
    User storage currentUser = users[_who];
    uint256 userBalance = checkArmyMoney(_who);
    currentUser.refMoney += userBalance;
    currentUser.timestamp +=
      ((block.timestamp - currentUser.timestamp) / armyYieldTime) *
      armyYieldTime;
  }

  function _merge(address _who) internal ArmiesStopper {
    User storage currentUser = users[_who];
    require(!currentUser.merged, "This account is already merged!");

    uint256 oldAllArmies = oldGameContract.checkArmyAmount(_who) * 10;
    uint256 oldAllSpecOps = oldGameContract.checkSpecOpsAmount(_who) * 100;
    uint256 oldAllSpaceForce = oldGameContract.checkSpaceForceAmount(_who) *
      1000;
    uint256 newArmies = (oldAllArmies + oldAllSpecOps + oldAllSpaceForce) / 100;
    currentUser.armies = newArmies;
    if (newArmies > 0) {
      totalPlayers++;
      playerList.push(_who);
    }
    currentUser.merged = true;
  }

  function _refDistribute(
    address _bottomAddr,
    uint256 _toDistribute
  ) internal ArmiesStopper {
    address[] memory list = readRefLevels(_bottomAddr);
    for (uint8 i = 0; i < list.length; ) {
      users[list[i]].refMoney += (_toDistribute * armyRefPerc[i]) / 10000;
      i++;
    }
  }

  function _findIterations(
    address _who
  ) internal view returns (uint8 iterations) {
    for (uint8 i = 0; i < 5; ) {
      _who = checkReferrer(_who);
      if (_who == address(0)) break;
      i++;
      iterations = i;
    }
  }

  // # Owner functions

  function addBlacklistMember(address _who) public OnlyOwners {
    blacklists[_who] = true;
    emit Blacklist(msg.sender, _who, true);
  }

  function transferOwner(address _who) public OnlyOwners returns (bool) {
    Owner = _who;
    emit Ownership(msg.sender, _who, true);
    return true;
  }

  function removeBlacklistMember(address _who) public OnlyOwners {
    blacklists[_who] = false;
    emit Blacklist(msg.sender, _who, false);
  }

  function checkBlacklistMember(address _who) public view returns (bool) {
    return blacklists[_who];
  }

  function changeTax(uint256 _to) public OnlyOwners {
    taxAmount = _to;
  }

  function stopArmies(bool _status) public OnlyOwners {
    armiespaused = _status;
  }

  function changeBNBprices(
    uint256 _specOps,
    uint256 _spaceForce,
    uint256 _starPrice
  ) public OnlyOwners {
    specOpsPrice = _specOps;
    spaceForcePrice = _spaceForce;
    starPrice = _starPrice;
  }

  function changeUserArmies(address _who, uint256 _amount) public OnlyOwners {
    _transferClaimToRef(_who);
    totalArmies -= users[_who].armies;
    users[_who].armies = _amount;
    totalArmies += _amount;
  }

  function changeUserSpecOps(address _who, uint256 _amount) public OnlyOwners {
    _transferClaimToRef(_who);
    totalSpecOps -= users[_who].specOps;
    users[_who].specOps = _amount;
    totalSpecOps += _amount;
  }

  function changeUserSpaceForce(
    address _who,
    uint256 _amount
  ) public OnlyOwners {
    _transferClaimToRef(_who);
    totalSpaceForce -= users[_who].spaceForce;
    users[_who].spaceForce = _amount;
    totalSpaceForce += _amount;
  }

  function withdrawToken() public OnlyOwners {
    require(tokenContract2.balanceOf(address(this)) > 0);
    tokenContract2.transfer(Owner, tokenContract2.balanceOf(address(this)));
  }

  function withdraw() public OnlyOwners {
    require(address(this).balance > 0);
    payable(Owner).transfer(address(this).balance);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface AI {
    function decimals() external view returns (uint8);
}

contract SOLDAT is ERC20, AI {
    uint8 public constant _decimals = 8;

    address private Owner;

    address private gameContract;

    address public RewardPool = 0x0718753cdF10f3D874C476988ab1a76025462959;

    mapping(address => bool) blacklists;

    event Blacklist(
        address indexed owner,
        address indexed blacklisted,
        bool indexed added
    );
    event Ownership(
        address indexed owner,
        address indexed newOwner,
        bool indexed added
    );

    constructor(address _owner) ERC20("Soldatiki", "SOLDAT") {
        Owner = _owner;
        _mint(msg.sender, 1300000 * 10**_decimals);
        _mint(RewardPool, 48700000 * 10**_decimals); 


    }

    modifier OnlyOwners() {
        require(
            (msg.sender == Owner),
            "You are not the owner of the token"
        );
        _;
    }

    modifier BlacklistCheck() {
        require(blacklists[msg.sender] == false, "You are in the blacklist");
        _;
    }

    function decimals() public pure override(AI, ERC20) returns (uint8) {
        return _decimals;
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        BlacklistCheck
        returns (bool)
    {
        require(balanceOf(msg.sender) >= amount, "You do not have enough SOLDAT");
        require(recipient != address(0), "The receiver address has to exist");

        _transfer(msg.sender, recipient, amount);

        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override BlacklistCheck returns (bool) {
        
        if (msg.sender == gameContract) {
            _transfer(sender, recipient, amount);
        } else {
        if (sender == gameContract) {
            _spendAllowance(sender, msg.sender, amount);
            _transfer(sender, recipient, amount);
        }  else {
            _spendAllowance(sender, msg.sender, amount);
            _transfer(sender, recipient, amount);
        }
        }
        
        return true;
    }

    function addBlacklistMember(address _who) public OnlyOwners {
        blacklists[_who] = true;
        emit Blacklist(msg.sender, _who, true);
    }

    function removeBlacklistMember(address _who) public OnlyOwners {
        blacklists[_who] = false;
        emit Blacklist(msg.sender, _who, false);
    }

    function checkBlacklistMember(address _who) public view returns (bool) {
        return blacklists[_who];
    }

    function transferOwner(address _who) public OnlyOwners returns (bool) {
        Owner = _who;
        emit Ownership(msg.sender, _who, true);
        return true;
    }

    function addGameContract(address _contract) public OnlyOwners {
        gameContract = _contract;
        _transfer(RewardPool, gameContract, balanceOf(RewardPool));
        RewardPool = _contract;
    }

    function withdraw() public OnlyOwners {
        require(address(this).balance > 0);
        payable(Owner).transfer(address(this).balance);
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}