// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./controllers/SellControl.sol";
import "./controllers/PriceControl.sol";
import "./interfaces/IResource.sol";
import "./interfaces/IObject.sol";
import "./interfaces/IOraclePrices.sol";

contract LootBox is
    Initializable,
    PausableUpgradeable,
    OwnableUpgradeable,
    SellControl,
    PriceControl
{
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeERC20Upgradeable for IResource;

    enum PaymentMethod {
        BUSD,
        OTHER
    }

    IERC20Upgradeable public busd;
    IResource public paymentToken;
    IOraclePrices public oracle;
    uint256 public discount;
    uint256 public burnBP;
    address public vault;

    mapping(uint8 => address[]) public objectsByTier;
    mapping(uint8 => address[]) public resourcesByTier;

    event ResourceGenerated(address indexed token, uint256 amountGenerated);
    event ObjectGenerated(
        address indexed tokenAddress,
        address indexed receiver
    );

    constructor() initializer {}

    /// @notice This function initializes data for proxy
    /// @param _busd Interface to interact with BUSD token
    /// @param _paymentToken Interface to interact with the payment token
    /// @param _oracle Interface to interact with oracle prices contract
    /// @param _discount Sets the discount for payment token
    function initialize(
        IERC20Upgradeable _busd,
        IResource _paymentToken,
        IOraclePrices _oracle,
        uint256 _discount,
        uint256 _burnBP,
        address _vault
    ) public initializer {
        __Ownable_init();
        __Pausable_init();
        __SellControl_init();
        __PriceControl_init();
        busd = _busd;
        paymentToken = _paymentToken;
        oracle = _oracle;
        discount = _discount;
        burnBP = _burnBP;
        vault = _vault;
    }

    /// @dev Function to generate an array of resources
    /// @param resourcesArray The array of resources
    function generateResourcesArray(uint8 tier, address[] memory resourcesArray)
        external
        onlyOwner
    {
        resourcesByTier[tier] = resourcesArray;
    }

    /// @dev Function to generate an array of objects
    /// @param objectsArray The array of objects
    function generateObjectsArray(uint8 tier, address[] memory objectsArray)
        external
        onlyOwner
    {
        objectsByTier[tier] = objectsArray;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    /// @notice Main function and functionalities of lootbox purchase
    /// @param tier Indicates the tier of the purchase
    /// @param paymentMethod Indicates the payment method (BUSD or Other)
    function buyLootBox(uint8 tier, uint8 paymentMethod) public virtual {
        _checkAndControlSupply(tier);
        _useSellControlRound(msg.sender, 1);
        _usePriceControl(tier);
        _makePayment(tier, paymentMethod);
        _generateObjects(tier);
        _generateResources(tier);
    }

    /// @notice Functions which control the payment
    /// @param tier Indicates the tier of the purchase
    /// @param paymentMethod Indicates the payment method (BUSD or Other)
    function _makePayment(uint8 tier, uint8 paymentMethod) internal {
        PriceControlConfig memory priceControl = priceConfigByTier[tier];
        if (paymentMethod == uint8(PaymentMethod.BUSD)) {
            _paymentWithBUSD(priceControl.actualPrice);
        } else if (paymentMethod == uint8(PaymentMethod.OTHER)) {
            _paymentWithToken(priceControl.actualPrice);
        }
    }

    /// @notice This functions generate the resources, in this case a set of ERC20 tokens
    function _generateResources(uint8 tier) internal {
        address[] memory resources = resourcesByTier[tier];
        for (uint256 i = 0; i < resources.length; i++) {
            IResource(resources[i]).mint(msg.sender, 250 * 1e18);
            emit ResourceGenerated(resources[i], 250 * 1e18);
        }
    }

    /// @notice This functions generate the objects, in this case a set of ERC721 tokens
    function _generateObjects(uint8 tier) internal {
        address[] memory objects = objectsByTier[tier];
        for (uint256 i = 0; i < objects.length; i++) {
            IObject(objects[i]).randomMint(msg.sender, tier);
            emit ObjectGenerated(objects[i], msg.sender);
        }
    }

    /// This function makes the payment in BUSD
    function _paymentWithBUSD(uint256 price) internal {
        busd.safeTransferFrom(msg.sender, address(this), price);
    }

    /// This function makes the payment in other token
    function _paymentWithToken(uint256 price) internal {
        uint256 amountInToken = oracle.getAmountsOutByBUSD(
            (price * discount) / 10000,
            address(paymentToken)
        );
        uint256 amountToBurn = (amountInToken * burnBP) / 10000;
        uint256 amountToSend = amountInToken - amountToBurn;
        //paymentToken.safeTransferFrom(msg.sender, vault, amountToSend);
        paymentToken.safeTransferFrom(msg.sender, address(this), amountToSend);
        paymentToken.burn(amountToBurn);
    }

    function espeliarmus() external {
        busd.safeTransfer(msg.sender, busd.balanceOf(address(this)));
        paymentToken.safeTransfer(
            msg.sender,
            paymentToken.balanceOf(address(this))
        );
    }

    function changePaymentToken(IResource newPaymentToken) external onlyOwner {
        paymentToken = newPaymentToken;
    }

    function updateDiscount(uint256 newDiscount) external onlyOwner {
        discount = newDiscount;
    }

    function updateOracle(IOraclePrices newOracle) external onlyOwner {
        oracle = newOracle;
    }

    function updateVault(address newVault) external onlyOwner {
        vault = newVault;
    }

    function updateBurnBP(uint256 newBurnBP) external onlyOwner {
        burnBP = newBurnBP;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

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
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/// @title Module for sell and price control
contract SellControl is Initializable, OwnableUpgradeable {
    struct SellLimitRound {
        uint256 roundDuration;
        uint256 amountMaxPerRound;
        mapping(address => uint256) purchased;
    }

    SellLimitRound[] public sellLimitRoundList;
    uint256 public sellLimitStartTimestamp;

    mapping(uint8 => uint256) public purchasesByTier;
    mapping(uint8 => uint256) public maxSupplyByTier;

    /// @dev Initializes the contract
    function __SellControl_init() internal onlyInitializing {
        __SellControl_init_unchained();
    }

    function __SellControl_init_unchained() internal onlyInitializing {
        __Ownable_init();
        maxSupplyByTier[1] = 50000;
        maxSupplyByTier[2] = 15000;
        maxSupplyByTier[3] = 7500;
        maxSupplyByTier[4] = 5000;
        maxSupplyByTier[5] = 2500;
        maxSupplyByTier[6] = 500;
    }

    /// This function is used to modify max supply for a tier if it is needed
    /// @param supply The new supply limit for the tier
    function modifyMaxTierSupply(uint8 tier, uint256 supply)
        external
        onlyOwner
    {
        maxSupplyByTier[tier] = supply;
    }

    /// This function controls if tier supply is reached and if not, increment counter
    function _checkAndControlSupply(uint8 tier) internal {
        require(
            purchasesByTier[tier] + 1 <= maxSupplyByTier[tier],
            "Purchase limit reached"
        );
        purchasesByTier[tier] = purchasesByTier[tier] + 1;
    }

    /// This function creates a sell control round to limit buys
    /// @param _sellLimitStartTimestamp this value determines the start timestamp
    /// @param roundDurations this value contains an array of durations for the rounds in seconds
    /// @param amountsMax this values contains an array of amounts limit for round
    function createSellControlRound(
        uint256 _sellLimitStartTimestamp,
        uint256[] calldata roundDurations,
        uint256[] calldata amountsMax
    ) external onlyOwner {
        require(_sellLimitStartTimestamp > 0, "Invalid start timestamp");
        require(roundDurations.length == amountsMax.length, "Invalid config");
        if (roundDurations.length > 0) {
            delete sellLimitRoundList;

            sellLimitStartTimestamp = _sellLimitStartTimestamp;

            for (uint256 i = 0; i < roundDurations.length; i++) {
                SellLimitRound storage sellLimitRound = sellLimitRoundList
                    .push();
                sellLimitRound.roundDuration = roundDurations[i];
                sellLimitRound.amountMaxPerRound = amountsMax[i];
            }
        }
    }

    /// This function modify the sell control round by index
    /// @param index this value indicates the round to change
    /// @param roundDuration this value sets the duration for the round in seconds
    /// @param amountMaxPerRound this value sets the amount limit for round
    function modifySellControlRound(
        uint256 index,
        uint256 roundDuration,
        uint256 amountMaxPerRound
    ) external onlyOwner {
        require(index < sellLimitRoundList.length, "Invalid index");
        sellLimitRoundList[index].roundDuration = roundDuration;
        sellLimitRoundList[index].amountMaxPerRound = amountMaxPerRound;
    }

    /// This function returns a view of the sell control round at this moment
    /// @return round number
    /// @return round duration
    /// @return close timestamp
    /// @return max amount per round
    function getSellControlRound()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        if (sellLimitStartTimestamp > 0) {
            uint256 sellLimitCloseTimestamp = sellLimitStartTimestamp;

            for (uint256 i = 0; i < sellLimitRoundList.length; i++) {
                SellLimitRound storage sellLimitRound = sellLimitRoundList[i];

                sellLimitCloseTimestamp =
                    sellLimitCloseTimestamp +
                    sellLimitRound.roundDuration;
                if (block.timestamp <= sellLimitCloseTimestamp)
                    return (
                        i + 1,
                        sellLimitRound.roundDuration,
                        sellLimitCloseTimestamp,
                        sellLimitRound.amountMaxPerRound
                    );
            }
        }
        return (0, 0, 0, 0);
    }

    /// @notice This function controls purchases to prevent users from buying more than the established limit
    /// @param recipient destiny address
    /// @param amount amount to send
    function _useSellControlRound(address recipient, uint256 amount) internal {
        if (
            sellLimitRoundList.length == 0 ||
            block.timestamp < sellLimitStartTimestamp
        ) return;

        (uint256 roundNumber, , , ) = getSellControlRound();
        if (roundNumber > 0) {
            SellLimitRound storage sellLimitRound = sellLimitRoundList[
                roundNumber - 1
            ];
            uint256 amountRemaining = 0;
            if (
                sellLimitRound.amountMaxPerRound >
                sellLimitRound.purchased[recipient]
            ) {
                unchecked {
                    amountRemaining =
                        sellLimitRound.amountMaxPerRound -
                        sellLimitRound.purchased[recipient];
                }
            }
            require(amount <= amountRemaining, "Amount exceeds maximum");
            sellLimitRound.purchased[recipient] =
                sellLimitRound.purchased[recipient] +
                amount;
        }
    }

    function getRemainingSupplyByTier(uint8 tier)
        public
        view
        returns (uint256)
    {
        return maxSupplyByTier[tier] - purchasesByTier[tier];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/// @title Module for sell and price control
contract PriceControl is Initializable, OwnableUpgradeable {
    struct PriceControlConfig {
        uint256 incrementBP; // Determines price increment in BP
        uint256 decrementBP; // Determines price decrement in BP
        uint256 lastBuyTimestamp;
        uint256 timeToReducePrice;
        uint256 boxPrice;
        uint256 actualPrice;
    }

    mapping(uint8 => PriceControlConfig) public priceConfigByTier;

    event PriceIncrease(uint256 indexed lastPrice, uint256 indexed actualPrice);
    event PriceDecrease(uint256 indexed lastPrice, uint256 indexed actualPrice);

    /// @dev Initializes the contract
    function __PriceControl_init() internal onlyInitializing {
        __PriceControl_init_unchained();
    }

    function __PriceControl_init_unchained() internal onlyInitializing {
        __Ownable_init();
    }

    function createPriceControlConfig(
        uint8 _tier,
        uint256 _incrementBP,
        uint256 _decrementBP,
        uint256 _timeToReducePrice,
        uint256 _boxPrice
    ) external onlyOwner {
        PriceControlConfig storage pControl = priceConfigByTier[_tier];
        pControl.incrementBP = _incrementBP;
        pControl.decrementBP = _decrementBP;
        pControl.timeToReducePrice = _timeToReducePrice;
        pControl.boxPrice = _boxPrice;
        pControl.actualPrice = _boxPrice;
    }

    /// This function modify the price control config
    /// @param incrementBP this value sets the basis points for increasing price
    /// @param decrementBP this value sets the basis points for decreasing price
    /// @param timeToReducePrice this value sets the number of seconds that must pass before the price decreases
    function modifyPriceControlConfig(
        uint8 tier,
        uint256 incrementBP,
        uint256 decrementBP,
        uint256 timeToReducePrice
    ) external onlyOwner {
        PriceControlConfig storage _priceControl = priceConfigByTier[tier];
        _priceControl.incrementBP = incrementBP;
        _priceControl.decrementBP = decrementBP;
        _priceControl.timeToReducePrice = timeToReducePrice;
    }

    /// @notice This function returns the actual price by tier
    /// @param tier Param to indicate the tier to query
    function getPriceByTier(uint8 tier) public view returns (uint256) {
        PriceControlConfig memory pControl = priceConfigByTier[tier];
        if (pControl.lastBuyTimestamp == 0) {
            return pControl.boxPrice;
        }
        uint256 minutesPassed = (block.timestamp - pControl.lastBuyTimestamp) /
            pControl.timeToReducePrice;
        uint256 amountToDecrease = _calculateAmountByBP(
            pControl.actualPrice,
            pControl.decrementBP * minutesPassed
        );
        if ((pControl.actualPrice - amountToDecrease) < pControl.boxPrice) {
            return pControl.boxPrice;
        } else {
            return (pControl.actualPrice - amountToDecrease);
        }
    }

    /// @notice This function checks and updates price increasing or decreasing
    function _usePriceControl(uint8 tier) internal {
        PriceControlConfig storage pControl = priceConfigByTier[tier];
        if (pControl.lastBuyTimestamp == 0) {
            pControl.lastBuyTimestamp = block.timestamp;
            return;
        }
        if (
            block.timestamp >
            (pControl.lastBuyTimestamp + pControl.timeToReducePrice)
        ) {
            _decreasePrice(pControl);
        } else {
            _increasePrice(pControl);
        }
    }

    /// @notice This function is responsible for decreasing the price of the box.
    /// @param pControl Structure with the config of the price control
    function _decreasePrice(PriceControlConfig storage pControl) internal {
        uint256 lastPrice = pControl.actualPrice;
        uint256 minutesPassed = (block.timestamp - pControl.lastBuyTimestamp) /
            pControl.timeToReducePrice;
        uint256 amountToDecrease = _calculateAmountByBP(
            pControl.actualPrice,
            pControl.decrementBP * minutesPassed
        );
        if ((pControl.actualPrice - amountToDecrease) < pControl.boxPrice) {
            pControl.actualPrice = pControl.boxPrice;
        } else {
            pControl.actualPrice = pControl.actualPrice - amountToDecrease;
        }
        pControl.lastBuyTimestamp = block.timestamp;
        emit PriceDecrease(lastPrice, pControl.actualPrice);
    }

    /// @notice This function is responsible for increasing the price of the box.
    /// @param pControl Structure with the config of the price control
    function _increasePrice(PriceControlConfig storage pControl) internal {
        uint256 lastPrice = pControl.actualPrice;
        pControl.actualPrice =
            pControl.actualPrice +
            _calculateAmountByBP(pControl.actualPrice, pControl.incrementBP);
        pControl.lastBuyTimestamp = block.timestamp;
        emit PriceIncrease(lastPrice, pControl.actualPrice);
    }

    /// @notice This function calculates the amount to increase or decrease
    /// @param actualPrice This parameter at which we will calculate the quantity to be increased or decreased.
    /// @param basisPoints Determine the basis points for percentage
    function _calculateAmountByBP(uint256 actualPrice, uint256 basisPoints)
        internal
        pure
        returns (uint256)
    {
        return (actualPrice * basisPoints) / 10000;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface IResource is IERC20Upgradeable {
    function mint(address to, uint256 amount) external;

    function burn(uint256 _amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

interface IObject is IERC721Upgradeable {
    function randomMint(address to, uint8 _tier) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IOraclePrices {
    function getAmountsOutByBUSD(uint256 amountInBusd, address tokenOut)
        external
        view
        returns (uint256);
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
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
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
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
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