/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol


pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/utils/Counters.sol


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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// File: SafuuXSacrificeBSC.sol


pragma solidity 0.8.17;






contract SafuuXSacrificeBSC is Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter public nextSacrificeId;
    Counters.Counter public nextBTCIndex;

    address payable public safuuWallet;
    address payable public serviceWallet;
    bool public isSacrificeActive;
    bool public isBonusActive;
    uint256 public bonusStart;
    uint256 public safuuBonus;
    uint256 public totalSacrifice;
    uint256 public safuuPriceUSD;

    struct sacrifice {
        uint256 id;
        string txHash;
        string tokenSymbol;
        address accountAddress;
        uint256 tokenAmount;
        uint256 tokenPriceUSD;
        uint256 timestamp;
        uint256 bonus;
        uint256 btcIndex;
        string status;
    }

    mapping(uint256 => sacrifice) public Sacrifice;
    mapping(address => uint256) public BTCPledge;
    mapping(address => uint256) public BNBDeposit;
    mapping(address => mapping(address => uint256)) public BEP20Deposit;
    mapping(address => mapping(string => uint256[])) private AccountDeposits;

    mapping(string => address) public AllowedTokens;
    mapping(string => address) public ChainlinkContracts;
    mapping(uint256 => string) public SacrificeStatus;
    mapping(uint256 => uint256) public BonusPercentage;

    event BTCPledged(address indexed accountAddress, uint256 amount);
    event BNBDeposited(address indexed accountAddress, uint256 amount);
    event SAFUUDeposited(address indexed accountAddress, uint256 amount);
    event BEP20Deposited(
        string indexed symbol,
        address indexed accountAddress,
        uint256 amount
    );

    constructor(address payable _safuuWallet, address payable _serviceWallet) {
        safuuWallet = _safuuWallet;
        serviceWallet = _serviceWallet;
        _init();
    }

    function depositBNB() external payable nonReentrant {
        require(isSacrificeActive == true, "depositBNB: Sacrifice not active");
        require(msg.value > 0, "depositBNB: Amount must be greater than ZERO");

        nextSacrificeId.increment();
        uint256 priceFeed = getChainLinkPrice(ChainlinkContracts["BNB"]);
        BNBDeposit[msg.sender] += msg.value;
        AccountDeposits[msg.sender]["BNB"].push(nextSacrificeId.current());

        uint256 tokenPriceUSD = priceFeed / 1e4;
        totalSacrifice += tokenPriceUSD * (msg.value / 1e14);

        _createNewSacrifice(
            "BNB",
            msg.sender,
            msg.value,
            priceFeed,
            block.timestamp,
            getBonus(),
            0,
            SacrificeStatus[2]
        );

        uint256 safuuSplit = (msg.value * 998) / 1000;
        uint256 serviceSplit = (msg.value * 2) / 1000;
        safuuWallet.transfer(safuuSplit);
        serviceWallet.transfer(serviceSplit);

        emit BNBDeposited(msg.sender, msg.value);
    }

    function depositBEP20(string memory _symbol, uint256 _amount)
        external
        nonReentrant
    {
        require(
            isSacrificeActive == true,
            "depositBEP20: Sacrifice not active"
        );
        require(
            AllowedTokens[_symbol] != address(0),
            "depositBEP20: Address not part of allowed token list"
        );
        require(
            AllowedTokens[_symbol] != AllowedTokens["SAFUU"],
            "depositBEP20: SAFUU cannot be deposited here"
        );
        require(_amount > 0, "depositBEP20: Amount must be greater than ZERO");

        nextSacrificeId.increment();
        uint256 amount = _amount * 1e18;
        uint256 priceFeed = getChainLinkPrice(ChainlinkContracts[_symbol]);
        address tokenAddress = AllowedTokens[_symbol];
        BEP20Deposit[msg.sender][tokenAddress] += amount;
        AccountDeposits[msg.sender][_symbol].push(nextSacrificeId.current());

        uint256 tokenPriceUSD = priceFeed / 1e4;
        totalSacrifice += tokenPriceUSD * (amount / 1e14);

        _createNewSacrifice(
            _symbol,
            msg.sender,
            amount,
            priceFeed,
            block.timestamp,
            getBonus(),
            0,
            SacrificeStatus[2]
        );

        uint256 safuuSplit = (amount * 998) / 1000;
        uint256 serviceSplit = (amount * 2) / 1000;

        IERC20 token = IERC20(tokenAddress);
        token.transferFrom(msg.sender, safuuWallet, safuuSplit);
        token.transferFrom(msg.sender, serviceWallet, serviceSplit);

        emit BEP20Deposited(_symbol, msg.sender, amount);
    }

    function depositSafuu(uint256 _amount) external nonReentrant {
        require(
            isSacrificeActive == true,
            "depositSafuu: Sacrifice not active"
        );
        require(
            AllowedTokens["SAFUU"] != address(0),
            "depositSafuu: Address not part of allowed token list"
        );
        require(_amount > 0, "depositSafuu: Amount must be greater than ZERO");

        nextSacrificeId.increment();
        uint256 bonus = safuuBonus + getBonus();
        uint256 amount = _amount * 1e5;
        address tokenAddress = AllowedTokens["SAFUU"];
        BEP20Deposit[msg.sender][tokenAddress] += amount;
        AccountDeposits[msg.sender]["SAFUU"].push(nextSacrificeId.current());

        uint256 tokenPriceUSD = safuuPriceUSD / 10;
        totalSacrifice += tokenPriceUSD * (amount / 10);

        _createNewSacrifice(
            "SAFUU",
            msg.sender,
            amount,
            safuuPriceUSD,
            block.timestamp,
            bonus,
            0,
            SacrificeStatus[2]
        );

        IERC20 token = IERC20(tokenAddress);
        token.transferFrom(msg.sender, safuuWallet, amount);

        emit SAFUUDeposited(msg.sender, amount);
    }

    function pledgeBTC(uint256 _amount)
        external
        nonReentrant
        returns (uint256)
    {
        require(isSacrificeActive == true, "pledgeBTC: Sacrifice not active");
        require(_amount > 0, "pledgeBTC: Amount must be greater than ZERO");

        nextBTCIndex.increment();
        nextSacrificeId.increment();
        BTCPledge[msg.sender] += _amount;
        uint256 priceFeed = getChainLinkPrice(ChainlinkContracts["BTC"]);
        AccountDeposits[msg.sender]["BTC"].push(nextSacrificeId.current());

        uint256 tokenPriceUSD = priceFeed / 1e4;
        totalSacrifice += tokenPriceUSD * (_amount * 1e4);

        _createNewSacrifice(
            "BTC",
            msg.sender,
            _amount,
            priceFeed,
            block.timestamp,
            getBonus(),
            nextBTCIndex.current(),
            SacrificeStatus[1]
        );

        emit BTCPledged(msg.sender, _amount);
        return nextBTCIndex.current();
    }

    function _createNewSacrifice(
        string memory _symbol,
        address _account,
        uint256 _amount,
        uint256 _priceUSD,
        uint256 _timestamp,
        uint256 _bonus,
        uint256 _btcIndex,
        string memory _status
    ) internal {
        sacrifice storage newSacrifice = Sacrifice[nextSacrificeId.current()];
        newSacrifice.id = nextSacrificeId.current();
        newSacrifice.tokenSymbol = _symbol;
        newSacrifice.accountAddress = _account;
        newSacrifice.tokenAmount = _amount;
        newSacrifice.tokenPriceUSD = _priceUSD;
        newSacrifice.timestamp = _timestamp;
        newSacrifice.bonus = _bonus;
        newSacrifice.btcIndex = _btcIndex;
        newSacrifice.status = _status;
    }

    function updateSacrificeData(
        uint256 sacrificeId,
        string memory _txHash,
        uint256 _bonus,
        uint256 _status
    ) external onlyOwner {
        sacrifice storage updateSacrifice = Sacrifice[sacrificeId];
        updateSacrifice.txHash = _txHash;
        updateSacrifice.bonus = BonusPercentage[_bonus];
        updateSacrifice.status = SacrificeStatus[_status];
    }

    function setAllowedTokens(string memory _symbol, address _tokenAddress)
        public
        onlyOwner
    {
        AllowedTokens[_symbol] = _tokenAddress;
    }

    function setChainlink(string memory _symbol, address _tokenAddress)
        public
        onlyOwner
    {
        ChainlinkContracts[_symbol] = _tokenAddress;
    }

    function setSacrificeStatus(bool _isActive) external onlyOwner {
        isSacrificeActive = _isActive;
    }

    function setSafuuWallet(address payable _safuuWallet) external onlyOwner {
        safuuWallet = _safuuWallet;
    }

    function setServiceWallet(address payable _serviceWallet)
        external
        onlyOwner
    {
        serviceWallet = _serviceWallet;
    }

    function setSafuuPriceUSD(uint256 _safuuPriceUSD) external onlyOwner {
        safuuPriceUSD = _safuuPriceUSD;
    }

    function updateBonus(uint256 _day, uint256 _percentage) external onlyOwner {
        BonusPercentage[_day] = _percentage;
    }

    function recoverBNB() external onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }

    function recoverBEP20(IERC20 tokenContract, address to) external onlyOwner {
        tokenContract.transfer(to, tokenContract.balanceOf(address(this)));
    }

    function getCurrentSacrificeID() external view returns (uint256) {
        return nextSacrificeId.current();
    }

    function getCurrentBTCIndex() external view returns (uint256) {
        return nextBTCIndex.current();
    }

    function getAccountDeposits(address _account, string memory _symbol)
        public
        view
        returns (uint256[] memory)
    {
        return AccountDeposits[_account][_symbol];
    }

    function getChainLinkPrice(address contractAddress)
        public
        view
        returns (uint256)
    {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            contractAddress
        );
        (
            ,
            /*uint80 roundID*/
            int256 price, /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/
            ,
            ,

        ) = priceFeed.latestRoundData();
        return uint256(price);
    }

    function getPriceBySymbol(string memory _symbol)
        public
        view
        returns (uint256)
    {
        require(
            ChainlinkContracts[_symbol] != address(0),
            "getChainLinkPrice: Address not part of Chainlink token list"
        );

        return getChainLinkPrice(ChainlinkContracts[_symbol]);
    }

    function getBonus() public view returns (uint256) {
        uint256 noOfDays = (block.timestamp - bonusStart) / 86400 + 1;
        uint256 bonus = BonusPercentage[noOfDays];
        return bonus;
    }

    function _init() internal {
        isSacrificeActive = false;
        isBonusActive = false;
        safuuPriceUSD = 60000; // $0.60

        SacrificeStatus[1] = "pending";
        SacrificeStatus[2] = "completed";
        SacrificeStatus[3] = "cancelled";

        // ****** Mainnet Data ******
        setAllowedTokens("BUSD", 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        setAllowedTokens("USDC", 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d);
        setAllowedTokens("USDT", 0x55d398326f99059fF775485246999027B3197955);
        setAllowedTokens("SAFUU", 0xE5bA47fD94CB645ba4119222e34fB33F59C7CD90);

        setChainlink("BNB", 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);
        setChainlink("BTC", 0x264990fbd0A4796A3E3d8E37C4d5F87a3aCa5Ebf);
        setChainlink("BUSD", 0xcBb98864Ef56E9042e7d2efef76141f15731B82f);
        setChainlink("USDC", 0x51597f405303C4377E36123cBc172b13269EA163);
        setChainlink("USDT", 0xB97Ad0E74fa7d920791E90258A6E2085088b4320);
    }

    function activateBonus() external onlyOwner {
        require(
            isBonusActive == false,
            "activateBonus: Bonus already activated"
        );

        isBonusActive = true;
        bonusStart = block.timestamp;
        safuuBonus = 2400;
        BonusPercentage[1] = 5000; // 5000 equals 50%
        BonusPercentage[2] = 4500;
        BonusPercentage[3] = 4000;
        BonusPercentage[4] = 3500;
        BonusPercentage[5] = 3000;
        BonusPercentage[6] = 2500;
        BonusPercentage[7] = 2000;
        BonusPercentage[8] = 1500;
        BonusPercentage[9] = 1400;
        BonusPercentage[10] = 1300;
        BonusPercentage[11] = 1200;
        BonusPercentage[12] = 1100;
        BonusPercentage[13] = 1000;
        BonusPercentage[14] = 900;
        BonusPercentage[15] = 800;
        BonusPercentage[16] = 700;
        BonusPercentage[17] = 600;
        BonusPercentage[18] = 500;
        BonusPercentage[19] = 400;
        BonusPercentage[20] = 300;
        BonusPercentage[21] = 200;
        BonusPercentage[22] = 100;
        BonusPercentage[23] = 90;
        BonusPercentage[24] = 80;
        BonusPercentage[25] = 70;
        BonusPercentage[26] = 60;
        BonusPercentage[27] = 50;
        BonusPercentage[28] = 40;
        BonusPercentage[29] = 30;
        BonusPercentage[30] = 20;
        BonusPercentage[31] = 10;
        BonusPercentage[32] = 0;
    }
}