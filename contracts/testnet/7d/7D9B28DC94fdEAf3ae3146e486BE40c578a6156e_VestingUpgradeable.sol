// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "./IRunnow.sol";

contract VestingUpgradeable is OwnableUpgradeable {
    address public runnow;

    event SetRUNNOW(address runnowAddress);
    event SetDistributeTime(uint256 time);

    uint256 public distributeTime;

    // uint256 private constant SECONDS_PER_MONTH = 30 days; //mainnet
    uint256 private constant SECONDS_PER_MONTH = 10 minutes; //testet

    uint256 private constant decimals = 18;

    uint256 public lastestDistributeMonth;

    address public seedSales;
    address public privateSales;
    address public publicSales;
    address public advisorsAndPartners;
    address public teamAndOperations;
    address public mktAndCommunity;
    address public gameTreasury;
    address public farmingAndStaking;
    address public liquidity;

    function initialize() public virtual initializer {
        __vesting_init(
            0x24e3eB44af807b54B8F425e25c1e4Eb575759aEC,
            1660806000,
            0x900B2491Be791b95561E0d3C283E18b0AE755E70,
            0x84AbF5D1CAE81cB7C661cba58Fc4d15757911128,
            0x71121E3eaFCb6a1e9b58BBF37C6B7a2E3e93e07d,
            0x15cB19F2DA6302Dc82ef3bbdfb11A37bD64D346d,
            0x04394a103f91C0389F9211811dfDCDBE81747924,
            0x32AdcEE090f422964D8b25b408c95a3623Da0E6B,
            0xF76A047E8d7D82BE61d21c73a54528D394fc828c,
            0x7A991826ac855d203b950411513E21990750C08C,
            0x83e973AF186b7515Cf6Eb9FDdF861b59E49942Fe
        );
        __Ownable_init();
    }

    function __vesting_init(
        address _runnowAddr,
        uint256 _distributeTime,
        address _seedSales,
        address _privateSales,
        address _publicSales,
        address _advisorsAndPartners,
        address _teamAndOperations,
        address _mktAndCommunity,
        address _gameTreasury,
        address _farmingAndStaking,
        address _liquidity
    ) internal {
        runnow = _runnowAddr;
        distributeTime = _distributeTime;
        require(
            _privateSales != address(0),
            "_privateSales cannot be address 0"
        );
        privateSales = _privateSales;
        require(_publicSales != address(0), "_publicSales cannot be address 0");
        publicSales = _publicSales;
        require(
            _advisorsAndPartners != address(0),
            "_advisorsAndPartners cannot be address 0"
        );
        advisorsAndPartners = _advisorsAndPartners;
        require(
            _teamAndOperations != address(0),
            "_teamAndOperations cannot be address 0"
        );
        teamAndOperations = _teamAndOperations;
        require(
            _mktAndCommunity != address(0),
            "_mktAndCommunity cannot be address 0"
        );
        mktAndCommunity = _mktAndCommunity;
        require(
            _gameTreasury != address(0),
            "_gameTreasury cannot be address 0"
        );
        gameTreasury = _gameTreasury;
        require(
            _farmingAndStaking != address(0),
            "_farmingAndStaking cannot be address 0"
        );
        farmingAndStaking = _farmingAndStaking;
        require(_seedSales != address(0), "_seedSales cannot be address 0");
        seedSales = _seedSales;
        require(_liquidity != address(0), "_liquidity cannot be address 0");
        liquidity = _liquidity;
    }

    function setAddress(
        address _seedSales,
        address _privateSales,
        address _publicSales,
        address _advisorsAndPartners,
        address _teamAndOperations,
        address _mktAndCommunity,
        address _gameTreasury,
        address _farmingAndStaking,
        address _liquidity
    ) external onlyOwner {
        require(
            _privateSales != address(0),
            "_privateSales cannot be address 0"
        );
        privateSales = _privateSales;
        require(_publicSales != address(0), "_publicSales cannot be address 0");
        publicSales = _publicSales;
        require(
            _advisorsAndPartners != address(0),
            "_advisorsAndPartners cannot be address 0"
        );
        advisorsAndPartners = _advisorsAndPartners;
        require(
            _teamAndOperations != address(0),
            "_teamAndOperations cannot be address 0"
        );
        teamAndOperations = _teamAndOperations;
        require(
            _mktAndCommunity != address(0),
            "_mktAndCommunity cannot be address 0"
        );
        mktAndCommunity = _mktAndCommunity;
        require(
            _gameTreasury != address(0),
            "_gameTreasury cannot be address 0"
        );
        gameTreasury = _gameTreasury;
        require(
            _farmingAndStaking != address(0),
            "_farmingAndStaking cannot be address 0"
        );
        farmingAndStaking = _farmingAndStaking;
        require(_seedSales != address(0), "_seedSales cannot be address 0");
        seedSales = _seedSales;
        require(_liquidity != address(0), "_liquidity cannot be address 0");
        liquidity = _liquidity;
    }

    function setRunnow(address newRunnow) external onlyOwner {
        require(address(newRunnow) != address(0));
        runnow = newRunnow;
        emit SetRUNNOW(address(newRunnow));
    }

    function setDistributeTime(uint256 time) external onlyOwner {
        require(distributeTime >= block.timestamp,"Can't set new distribute time");
        distributeTime = time;
        emit SetDistributeTime(time);
    }

    function distribute() external {
        require(
            block.timestamp >= distributeTime,
            "RUNNOWVesting: not claim time"
        );
        uint256 month = (block.timestamp - distributeTime) / SECONDS_PER_MONTH;
        require(
            lastestDistributeMonth <= month,
            "RUNNOWVesting: already claimed in this month"
        );

        uint256 amountForSeedSale;
        uint256 amountForPrivateSale;
        uint256 amountForPublicSale;
        uint256 amountForAdvisorsAndPartners;
        uint256 amountForTeamAndOperations;
        uint256 amountForMktAndCommunity;
        uint256 amountForGameTreasury;
        uint256 amountForFarmingAndStaking;
        uint256 amountForLiquidity;

        for (uint256 i = lastestDistributeMonth; i <= month; i++) {
            amountForPrivateSale += getAmountForPrivateSales(i);
            amountForPublicSale += getAmountForPublicSales(i);
            amountForAdvisorsAndPartners += getAmountForAdvisorsAndPartners(i);
            amountForTeamAndOperations += getAmountForTeamAndOperations(i);
            amountForMktAndCommunity += getAmountForMktAndCommunity(i);
            amountForGameTreasury += getAmountForGameTreasury(i);
            amountForFarmingAndStaking += getAmountForFarmingAndStaking(i);
            amountForSeedSale += getAmountForSeedSale(i);
            amountForLiquidity += getAmountForLiquidity(i);
        }
        bool remainVesting = amountForSeedSale == 0 &&
            amountForPrivateSale == 0 &&
            amountForPublicSale == 0 &&
            amountForAdvisorsAndPartners == 0 &&
            amountForTeamAndOperations == 0 &&
            amountForMktAndCommunity == 0 &&
            amountForGameTreasury == 0 &&
            amountForFarmingAndStaking == 0 &&
            amountForLiquidity == 0;
        require(
            month <= 36 || (month > 36 && !remainVesting),
            "RUNNOWVesting: expiry time"
        );
        if (amountForSeedSale > 0)
            IRunnow(runnow).mint(seedSales, amountForSeedSale);
        if (amountForPrivateSale > 0)
            IRunnow(runnow).mint(privateSales, amountForPrivateSale);
        if (amountForPublicSale > 0)
            IRunnow(runnow).mint(publicSales, amountForPublicSale);
        if (amountForAdvisorsAndPartners > 0)
            IRunnow(runnow).mint(
                advisorsAndPartners,
                amountForAdvisorsAndPartners
            );
        if (amountForTeamAndOperations > 0)
            IRunnow(runnow).mint(teamAndOperations, amountForTeamAndOperations);
        if (amountForMktAndCommunity > 0)
            IRunnow(runnow).mint(mktAndCommunity, amountForMktAndCommunity);
        if (amountForGameTreasury > 0)
            IRunnow(runnow).mint(gameTreasury, amountForGameTreasury);
        if (amountForFarmingAndStaking > 0)
            IRunnow(runnow).mint(farmingAndStaking, amountForFarmingAndStaking);
        if (amountForLiquidity > 0)
            IRunnow(runnow).mint(liquidity, amountForLiquidity);
        if (
            amountForSeedSale != 0 ||
            amountForPrivateSale != 0 ||
            amountForPublicSale != 0 ||
            amountForAdvisorsAndPartners != 0 ||
            amountForTeamAndOperations != 0 ||
            amountForMktAndCommunity != 0 ||
            amountForGameTreasury != 0 ||
            amountForFarmingAndStaking != 0 ||
            amountForLiquidity != 0
        ) lastestDistributeMonth = month + 1;
    }

    function getAmountForSeedSale(uint256 month)
        public
        view
        returns (uint256 amount)
    {
        uint256 maxAmount = 30_000_000 * 10**decimals;
        uint256 linearAmount = maxAmount / 12;
        if (month < 3 || month > 14) amount = 0;
        else if (month >= 3 && month <= 13) amount = linearAmount;
        else if (month == 14) amount = maxAmount - linearAmount * 11;
    }

    function getAmountForPrivateSales(uint256 month)
        public
        view
        returns (uint256 amount)
    {
        uint256 maxAmount = 40_000_000 * 10**decimals;
        uint256 linearAmount = maxAmount / 12;
        if (month < 3 || month > 14) amount = 0;
        else if (month >= 3 && month <= 13) amount = linearAmount;
        else if (month == 14) amount = maxAmount - linearAmount * 11;
    }

    function getAmountForPublicSales(uint256 month)
        public
        view
        returns (uint256 amount)
    {
        uint256 maxAmount = 60_000_000 * 10**decimals;

        if (month == 0) amount = maxAmount;
        else if (month > 0) amount = 0;
    }

    function getAmountForAdvisorsAndPartners(uint256 month)
        public
        view
        returns (uint256 amount)
    {
        uint256 maxAmount = 50_000_000 * 10**decimals;
        uint256 linearAmount = maxAmount / 24;
        if (month >= 0 && month < 12) amount = 0;
        else if (month >= 12 && month <= 34) amount = linearAmount;
        else if (month == 35) amount = maxAmount - linearAmount * 23;
        else if (month == 36) amount = 0;
    }

    function getAmountForTeamAndOperations(uint256 month)
        public
        view
        returns (uint256 amount)
    {
        uint256 maxAmount = 200_000_000 * 10**decimals;
        uint256 linearAmount = maxAmount / 24;
        if ((month >= 0 && month < 12) || month >= 36) amount = 0;
        else if (month >= 12 && month <= 34) amount = linearAmount;
        else if (month == 35) amount = maxAmount - linearAmount * 23;
    }

    function getAmountForMktAndCommunity(uint256 month)
        public
        view
        returns (uint256 amount)
    {
        uint256 maxAmount = 100_000_000 * 10**decimals;
        uint256 publicSaleAmount = 1_000_000 * 10**decimals;
        uint256 linearAmount = (maxAmount - publicSaleAmount) / 36;
        if (month > 36) amount = 0;
        else if (month == 0) amount = publicSaleAmount;
        else if (month >= 1 && month <= 35) amount = linearAmount;
        else if (month == 36) amount = maxAmount - linearAmount * 35;
    }

    function getAmountForGameTreasury(uint256 month)
        public
        view
        returns (uint256 amount)
    {
        uint256 maxAmount = 350_000_000 * 10**decimals;
        uint256 linearAmount = maxAmount / 36;
        if (month > 36 || month == 0) amount = 0;
        else if (month >= 1 && month < 36) amount = linearAmount;
        else if (month == 36) amount = maxAmount - linearAmount * 35;
    }

    function getAmountForFarmingAndStaking(uint256 month)
        public
        view
        returns (uint256 amount)
    {
        uint256 maxAmount = 150_000_000 * 10**decimals;
        uint256 linearAmount = maxAmount / 36;
        if (month > 36 || month == 0) amount = 0;
        else if (month > 0 && month <= 35) amount = linearAmount;
        else if (month == 36) amount = maxAmount - linearAmount * 35;
    }

    function getAmountForLiquidity(uint256 month)
        public
        view
        returns (uint256 amount)
    {
        uint256 maxAmount = 20_000_000 * 10**decimals;
        uint256 publicSaleAmount = 8_000_000 * 10**decimals;
        uint256 linearAmount = (maxAmount - publicSaleAmount) / 6;
        if (month == 0) amount = publicSaleAmount;
        else if (month > 6) amount = 0;
        else if (month >= 1 && month <= 5) amount = linearAmount;
        else if (month == 6)
            amount = maxAmount - publicSaleAmount - linearAmount * 5;
    }

    function getDistributeAmountForSeedSale() external view returns (uint256) {
        uint256 month = (block.timestamp - distributeTime) / SECONDS_PER_MONTH;
        uint256 amountForSeedSale;
        for (uint256 i = lastestDistributeMonth; i <= month; i++) {
            amountForSeedSale += getAmountForSeedSale(i);
        }
        return amountForSeedSale;
    }

    function getDistributeAmountForPrivateSales()
        external
        view
        returns (uint256)
    {
        uint256 month = (block.timestamp - distributeTime) / SECONDS_PER_MONTH;
        uint256 amountForPrivateSale;
        for (uint256 i = lastestDistributeMonth; i <= month; i++) {
            amountForPrivateSale += getAmountForPrivateSales(i);
        }
        return amountForPrivateSale;
    }

    function getDistributeAmountForPublicSales()
        external
        view
        returns (uint256)
    {
        uint256 month = (block.timestamp - distributeTime) / SECONDS_PER_MONTH;
        uint256 amountForPublicSale;
        for (uint256 i = lastestDistributeMonth; i <= month; i++) {
            amountForPublicSale += getAmountForPublicSales(i);
        }
        return amountForPublicSale;
    }

    function getDistributeAmountForAdvisorsAndPartners()
        external
        view
        returns (uint256)
    {
        uint256 month = (block.timestamp - distributeTime) / SECONDS_PER_MONTH;
        uint256 amountForAdvisorsAndPartner;
        for (uint256 i = lastestDistributeMonth; i <= month; i++) {
            amountForAdvisorsAndPartner += getAmountForAdvisorsAndPartners(i);
        }
        return amountForAdvisorsAndPartner;
    }

    function getDistributeAmountForTeamAndOperation()
        external
        view
        returns (uint256)
    {
        uint256 month = (block.timestamp - distributeTime) / SECONDS_PER_MONTH;
        uint256 amountForTeamAndOperations;
        for (uint256 i = lastestDistributeMonth; i <= month; i++) {
            amountForTeamAndOperations += getAmountForTeamAndOperations(i);
        }
        return amountForTeamAndOperations;
    }

    function getDistributeAmountForMktAndCommunity()
        external
        view
        returns (uint256)
    {
        uint256 month = (block.timestamp - distributeTime) / SECONDS_PER_MONTH;
        uint256 amountForMktAndCommunity;
        for (uint256 i = lastestDistributeMonth; i <= month; i++) {
            amountForMktAndCommunity += getAmountForMktAndCommunity(i);
        }
        return amountForMktAndCommunity;
    }

    function getDistributeAmountForGameTreasury()
        external
        view
        returns (uint256)
    {
        uint256 month = (block.timestamp - distributeTime) / SECONDS_PER_MONTH;
        uint256 amountForGameTreasury;
        for (uint256 i = lastestDistributeMonth; i <= month; i++) {
            amountForGameTreasury += getAmountForGameTreasury(i);
        }
        return amountForGameTreasury;
    }

    function getDistributeAmountForFarmingAndStaking()
        external
        view
        returns (uint256)
    {
        uint256 month = (block.timestamp - distributeTime) / SECONDS_PER_MONTH;
        uint256 amountForFarmingAndStaking;
        for (uint256 i = lastestDistributeMonth; i <= month; i++) {
            amountForFarmingAndStaking += getAmountForFarmingAndStaking(i);
        }
        return amountForFarmingAndStaking;
    }

    function getDistributeAmountForLiquidity() external view returns (uint256) {
        uint256 month = (block.timestamp - distributeTime) / SECONDS_PER_MONTH;
        uint256 amountForLiquidity;
        for (uint256 i = lastestDistributeMonth; i <= month; i++) {
            amountForLiquidity += getAmountForLiquidity(i);
        }
        return amountForLiquidity;
    }

    function setNewRunnowOwnership(address newRunnow) external onlyOwner {
        require(address(newRunnow) != address(0));
        IRunnow(runnow).transferOwnership(newRunnow);
        // emit SetRUNNOW(address(newRunnow));
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface IRunnow is IERC20Upgradeable {
    function mint(address to, uint256 amount) external;
    function transferOwnership(address newOwner) external;
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