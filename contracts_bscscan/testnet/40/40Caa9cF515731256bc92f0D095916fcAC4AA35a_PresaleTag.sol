/**
 *Submitted for verification at BscScan.com on 2022-02-07
*/

// File: @openzeppelin/contracts/utils/Strings.sol


// OpenZeppelin Contracts v4.4.0 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
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

// File: contracts/IERC20Burn.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol) + Burn function

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Burn {
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) external;

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
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

// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol


pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
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

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

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


// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

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

// File: contracts/preventa.sol


pragma solidity ^0.8.7;






contract PresaleTag is Ownable, ReentrancyGuard {
    address payable principalWallet =
        payable(0x9B88A2556C61945612e79c9108e5b6B5EBfa1B90);
    AggregatorV3Interface internal priceFeed;
    mapping(address => Vesting) public infoVesting;
    mapping(address => uint256) public balanceVesting;
    mapping(address => bool) public vesting;
    mapping(address => bool) public noVesting;
    mapping(address => bool) public invest;
    mapping(address => uint256) public quantityBuy;
    mapping(address => uint256) public quantityBuyIdo;
    mapping(address => bool) public withdrawalWhitelistStatus;
    uint256 totalBuy;
    uint256 public totalVesting;
    uint256 dateStartGame;
    bool _startGame;

    struct Vesting {
        uint256 firstBalance;
        uint256 numberWithdrawal;
        uint256 quote;
        uint256 lastBalance;
    }

    uint256 priceWhitelist = 6; // precio decimal USD
    uint256 maxWhitelist = 100; // precio en decimal BNB
    uint256 priceInvestor = 8; // precio decimal USD
    bool _firstTime;
    event Buy(address buyer, uint256 value);
    event TagBalanceGame(address buyer, uint256 value);
    event TagBalanceGameIdo(address buyer, uint256 value);
    event InvestorBuy(address buyer, uint256 initValue, uint256 balance);
    event FirstInvestor(address buyer, uint256 initValue, uint256 balance);
    event WithdrawalVesting(address buyer, uint256 value, uint256 balance);

    constructor() {
        // TESTNET
        priceFeed = AggregatorV3Interface(
            	0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
        );
        _startGame = false;
        _firstTime = true;
    }

    // Token TAG Address
    IERC20Burn public token =
        IERC20Burn(0xbf1e8F7941068c3542BA49063323F7FA4F40620a);

    function getLatestPrice() public view returns (int256) {
        (
            uint80 roundID,
            int256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }

    function buyWhitelist() external payable nonReentrant returns (bool) {
        require(
            token.balanceOf(address(this)) > 0,
            "El balance del token del contrato es igual a 0"
        );
        uint256 _first = msg.value * uint256(getLatestPrice());
        uint256 _cantTag = (_first) / (priceWhitelist * 10**6);
        require(
            (token.balanceOf(address(this)) - _cantTag) > totalVesting,
            "Solo existen la cantidad de tokens para vesting"
        );
        require(maxWhitelist * 10**16 > msg.value, "No puedes comprar mas TAG");
        require(
            (quantityBuy[msg.sender] + msg.value) < (maxWhitelist * 10**16),
            "No puedes comprar mas TAG"
        );
        require(
            token.balanceOf(address(this)) > _cantTag,
            "No existe esa cantidad para comprar"
        );

        principalWallet.transfer(msg.value);

        if (vesting[msg.sender]) {
            quantityBuy[msg.sender] = quantityBuy[msg.sender] + msg.value;
            uint256 expend = _cantTag / 2;
            token.transfer(msg.sender, expend);
            uint256 balanceGame = _cantTag - expend;
            emit TagBalanceGame(msg.sender, balanceGame);
        } else if (noVesting[msg.sender]) {
            quantityBuy[msg.sender] = quantityBuy[msg.sender] + msg.value;
            token.transfer(msg.sender, _cantTag);
        } else {
            require(1 < 0, "No estas en la whitelist");
        }
        totalBuy = totalBuy + msg.value;
        emit Buy(msg.sender, msg.value);
        return true;
    }


    function buyInvestors() external payable nonReentrant returns (bool) {
        require(invest[msg.sender], "No puedes usar esta funcion");
        uint256 _first = msg.value * uint256(getLatestPrice());
        uint256 _cantTag = (_first) / (priceInvestor * 10**6);
        require(
            (token.balanceOf(address(this)) - _cantTag) > totalVesting,
            "Solo existen la cantidad de tokens para vesting"
        );
        uint256 quote = _cantTag / 10;
        uint256 totalTransferFirst = quote * 5;
        infoVesting[msg.sender].firstBalance = _cantTag;
        infoVesting[msg.sender].numberWithdrawal = 0;
        infoVesting[msg.sender].quote = quote;
        infoVesting[msg.sender].lastBalance = _cantTag - totalTransferFirst;
        totalVesting = totalVesting + _cantTag - totalTransferFirst;
        principalWallet.transfer(msg.value);
        token.transfer(msg.sender, totalTransferFirst);
        emit InvestorBuy(msg.sender, _cantTag, _cantTag - totalTransferFirst);
        return true;
    }

    function initInvestors() external onlyOwner {
        require(_firstTime, "Esta funcion solo puede usarse una vez");
        address investor1 = 0x9cCfB722C794c3101B8Cd18Ed888F0620886415c;
        uint256 valueInvestor1 = 187500 * 10**18;
        firstInvestors(valueInvestor1, investor1);
        address investor2 = 0x8410B3f6cBa32c2d69696a2dC33b514d98957676;
        uint256 valueInvestor2 = 15500 * 10**18;
        firstInvestors(valueInvestor2, investor2);
        address investor3 = 0xEbEf318B1B9560fcd17E13dA56E43e959541b887;
        uint256 valueInvestor3 = 10000 * 10**18;
        firstInvestors(valueInvestor3, investor3);
        address investor4 = 0x166d867F48BBeA9Afe5dB6583780abA664dAB22e;
        uint256 valueInvestor4 = 10000 * 10**18;
        firstInvestors(valueInvestor4, investor4);
        address investor5 = 0x4a42331Bd1f963A80e91Fe1f98d88218Eb673FF6;
        uint256 valueInvestor5 = 10000 * 10**18;
        firstInvestors(valueInvestor5, investor5);
        address investor6 = 0xd2D35c1CAF760B7e30c4D2e680Ac3A08fBDaF159;
        uint256 valueInvestor6 = 15025 * 10**18;
        firstInvestors(valueInvestor6, investor6);
        _firstTime = false;
    }

    function firstInvestors(uint256 valueBuyed, address addressInvestor)
        internal
    {
        require(
            (token.balanceOf(address(this)) - valueBuyed) > totalVesting,
            "Solo existen la cantidad de tokens para vesting"
        );
        uint256 quote = valueBuyed / 10;
        uint256 totalTransferFirst = quote * 5;
        infoVesting[addressInvestor].firstBalance = valueBuyed;
        infoVesting[addressInvestor].numberWithdrawal = 0;
        infoVesting[addressInvestor].quote = quote;
        infoVesting[addressInvestor].lastBalance =
            valueBuyed -
            totalTransferFirst;
        totalVesting = totalVesting + valueBuyed - totalTransferFirst;
        token.transfer(addressInvestor, totalTransferFirst);
        emit FirstInvestor(
            addressInvestor,
            valueBuyed,
            valueBuyed - totalTransferFirst
        );
    }

    function withdrawalVesting() external returns (bool) {
        require(_startGame, "El juego aun no inicia");
        uint256 numberWithdrawal = infoVesting[msg.sender].numberWithdrawal + 1;
        require(infoVesting[msg.sender].lastBalance > 0, "No se tiene balance");
        infoVesting[msg.sender].numberWithdrawal = numberWithdrawal;
        uint256 timeWithdrawal = dateStartGame + (numberWithdrawal * 7 days);
        require(
            block.timestamp > timeWithdrawal,
            "Aun no puedes retirar tu dinero"
        );
        require(
            infoVesting[msg.sender].lastBalance >
                infoVesting[msg.sender].quote - 1,
            "No tienes la cantidad minima para retiro"
        );
        infoVesting[msg.sender].lastBalance =
            infoVesting[msg.sender].lastBalance -
            infoVesting[msg.sender].quote;
        totalVesting = totalVesting - infoVesting[msg.sender].quote;
        token.transfer(msg.sender, infoVesting[msg.sender].quote);
        emit WithdrawalVesting(
            msg.sender,
            infoVesting[msg.sender].quote,
            infoVesting[msg.sender].lastBalance
        );
        return true;
    }

    function startGame(bool status) external onlyOwner {
        _startGame = status;
        dateStartGame = block.timestamp;
    }


    function addToInvestor(address investor) external onlyOwner {
        invest[investor] = true;
    }

    function removeInvestor(address account) external onlyOwner {
        invest[account] = false;
    }

    function burnTokens() external onlyOwner {
        uint256 totalBurn = token.balanceOf(address(this)) - totalVesting;
        require(totalBurn > 0, "No existen tokens para quemar");
        token.burn(totalBurn);
    }
}