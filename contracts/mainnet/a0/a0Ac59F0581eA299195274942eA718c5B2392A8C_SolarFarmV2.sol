// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/*
 * @author ~ 🅧🅘🅟🅩🅔🅡 ~ (https://twitter.com/Xipzer | https://t.me/Xipzer)
 *
 * ░██████╗░█████╗░██╗░░░░░░█████╗░██████╗░  ███████╗░█████╗░██████╗░███╗░░░███╗  ██╗░░░██╗██████╗░
 * ██╔════╝██╔══██╗██║░░░░░██╔══██╗██╔══██╗  ██╔════╝██╔══██╗██╔══██╗████╗░████║  ██║░░░██║╚════██╗
 * ╚█████╗░██║░░██║██║░░░░░███████║██████╔╝  █████╗░░███████║██████╔╝██╔████╔██║  ╚██╗░██╔╝░░███╔═╝
 * ░╚═══██╗██║░░██║██║░░░░░██╔══██║██╔══██╗  ██╔══╝░░██╔══██║██╔══██╗██║╚██╔╝██║  ░╚████╔╝░██╔══╝░░
 * ██████╔╝╚█████╔╝███████╗██║░░██║██║░░██║  ██║░░░░░██║░░██║██║░░██║██║░╚═╝░██║  ░░╚██╔╝░░███████╗
 * ╚═════╝░░╚════╝░╚══════╝╚═╝░░╚═╝╚═╝░░╚═╝  ╚═╝░░░░░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░░░░╚═╝  ░░░╚═╝░░░╚══════╝
 *
 * Solar Farm V2.0 [Gen 4] - BSC BNB Miner
 *
 * Telegram: https://t.me/SolarFarmMinerOfficial
 * Twitter: https://twitter.com/SolarFarmMiner
 * dApp: https://app.solarfarm.finance/
 */

contract SolarFarmV2 is OwnableUpgradeable
{
    uint private gridPower;
    uint private returnsIndex;

    uint private buyDampener;
    uint private sellDampener;
    uint private compoundDampener;

    uint private compoundCooldown;
    uint private baseCompoundBonus;
    uint private maxCompoundBonus;

    uint private compoundBonusThreshold;
    uint private minCompoundsThreshold;
    uint private allowanceThreshold;

    uint private baseAbuseFee;
    uint private dumpAbuseFee;
    uint private dumpAbusePenalty;
    uint private spamAbuseFee;
    uint private spamAbusePenalty;

    uint private referralReward;

    uint private gridFee;
    uint private maxGridFee;

    bool private minerInitialized;
    bool private solarGuardActivated;

    address payable private gridTechnician;

    mapping(address => UserData) private users;
    mapping(address => bool) private botUsers;

    struct UserData
    {
        uint solarPanels;
        uint storedPower;
        uint allowance;
        uint freshValue;
        uint amountSold;
        uint amountDeposited;
        uint sellsCount;
        uint totalCompoundsCount;
        uint currentCompoundsCount;
        uint lastSellTimestamp;
        uint lastCompoundTimestamp;
        uint lastActionTimestamp;
        uint compoundBonusTier;
        address referrer;
        address[] referees;
    }

    uint private shootingStarTimestamp;
    uint private shootingStarAbusePenalty;
    uint private shootingStarAmplifier;

    event MinerActivated(uint timestamp);
    event ShootingStar(uint amplifier, uint timestamp);
    event DumpPenaltyChanged(uint penalty, uint timestamp);
    event SpamPenaltyChanged(uint penalty, uint timestamp);
    event BuyDampenerChanged(uint dampener, uint timestamp);
    event SellDampenerChanged(uint dampener, uint timestamp);
    event CompoundDampenerChanged(uint dampener, uint timestamp);
    event GridFeeChanged(uint fee, uint timestamp);
    event PanelsPurchased(uint amount, uint timestamp);
    event PowerSold(uint amount, uint timestamp);

//    function initialize(address payable technicianAddress) external initializer
//    {
//        __Ownable_init();
//
//        gridPower = 108000000000;
//        returnsIndex = 604800;
//
//        buyDampener = 100;
//        sellDampener = 500;
//        compoundDampener = 200;
//
//        compoundCooldown = 5400;
//        baseCompoundBonus = 15;
//        maxCompoundBonus = 150;
//
//        compoundBonusThreshold = 3;
//        minCompoundsThreshold = 15;
//        allowanceThreshold = 5;
//
//        baseAbuseFee = 500;
//        dumpAbuseFee = 500;
//        dumpAbusePenalty = 100;
//        spamAbuseFee = 750;
//        spamAbusePenalty = 50;
//
//        referralReward = 100;
//
//        gridFee = 60;
//        maxGridFee = 100;
//
//        minerInitialized = false;
//        solarGuardActivated = false;
//
//        gridTechnician = technicianAddress;
//    }

    function getTotalValueLocked() public view returns (uint)
    {
        return address(this).balance;
    }

    function getSolarPanels(address user) public view returns (uint)
    {
        return users[user].solarPanels;
    }

    function getRemainingAllowance(address user) public view returns (uint)
    {
        return users[user].allowance;
    }

    function getFreshValue(address user) public view returns (uint)
    {
        return users[user].freshValue;
    }

    function getAmountSold(address user) public view returns (uint)
    {
        return users[user].amountSold;
    }

    function getAmountDeposited(address user) public view returns (uint)
    {
        return users[user].amountDeposited;
    }

    function getSellsCount(address user) public view returns (uint)
    {
        return users[user].sellsCount;
    }

    function getTotalCompoundsCount(address user) public view returns (uint)
    {
        return users[user].totalCompoundsCount;
    }

    function getCurrentCompoundsCount(address user) public view returns (uint)
    {
        return users[user].currentCompoundsCount;
    }

    function getLastSellTimestamp(address user) public view returns (uint)
    {
        return users[user].lastSellTimestamp;
    }

    function getLastCompoundTimestamp(address user) public view returns (uint)
    {
        return users[user].lastCompoundTimestamp;
    }

    function getCompoundBonusTier(address user) public view returns (uint)
    {
        return users[user].compoundBonusTier;
    }

    function getReferrer(address user) public view returns (address)
    {
        return users[user].referrer;
    }

    function getReferees(address user) public view returns (address[] memory)
    {
        return users[user].referees;
    }

    function getBotStatus(address user) public view returns (bool)
    {
        return botUsers[user];
    }

    function getShootingStarStatus() public view returns (bool)
    {
        if (block.timestamp > shootingStarTimestamp)
            if (block.timestamp - shootingStarTimestamp <= 86400)
                return true;

        return false;
    }

    function checkStarAbuseStatus() public view returns (bool)
    {
        if (block.timestamp > shootingStarTimestamp)
        {
            if (block.timestamp - shootingStarTimestamp <= 172800)
                return true;
        }
        else
            if (shootingStarTimestamp - block.timestamp <= 86400)
                return true;

        return false;
    }

    function checkBaseAbuseStatus(address user, uint amount) public view returns (bool)
    {
        if (amount >= users[user].allowance)
            return true;
        return false;
    }

    function checkDumpAbuseStatus(address user, uint amount) public view returns (bool)
    {
        if (amount >= users[user].freshValue)
            return true;
        return false;
    }

    function checkSpamAbuseStatus(address user) public view returns (bool)
    {
        if (users[user].currentCompoundsCount < minCompoundsThreshold)
            return true;
        return false;
    }

    function checkRewardsBalance(address user) public view returns (uint)
    {
        return computeSellTrade(checkPowerTotal(user));
    }

    function checkPowerTotal(address user) public view returns (uint)
    {
        return users[user].storedPower + checkFreshPower(user);
    }

    function checkFreshPower(address user) public view returns (uint)
    {
        uint sessionDuration = checkMinimum(returnsIndex, block.timestamp - users[user].lastActionTimestamp);

        return sessionDuration * users[user].solarPanels;
    }

    function checkMinimum(uint a, uint b) private pure returns (uint)
    {
        return a < b ? a : b;
    }

    function computeFraction(uint amount, uint numerator) private pure returns (uint)
    {
        return (amount * numerator) / 1000;
    }

    function computeTrade(uint a, uint b, uint c) private view returns (uint)
    {
        return computeFraction((a * b) / c, 1000 - gridFee);
    }

    function computeBuyTrade(uint amount) private view returns (uint)
    {
        uint balance = address(this).balance - amount;

        return computeTrade(gridPower, amount, balance);
    }

    function computeSellTrade(uint amount) private view returns (uint)
    {
        return computeTrade(address(this).balance, amount, gridPower);
    }

    function computeSimulatedBuy(uint amount) public view returns (uint)
    {
        return computeTrade(gridPower, amount, address(this).balance);
    }

    function computeSimulatedSell(uint amount) public view returns (uint)
    {
        return computeSellTrade(amount);
    }

    function setDumpAbusePenalty(uint penalty) external onlyOwner
    {
        require(penalty <= 500, "SolarGuard: Penalty value exceeds 50%!");

        dumpAbusePenalty = penalty;
        emit DumpPenaltyChanged(penalty, block.timestamp);
    }

    function setSpamAbusePenalty(uint penalty) external onlyOwner
    {
        require(penalty <= 500, "SolarGuard: Penalty value exceeds 50%!");

        spamAbusePenalty = penalty;
        emit SpamPenaltyChanged(penalty, block.timestamp);
    }

    function setBuyDampener(uint dampener) external onlyOwner
    {
        require(dampener <= 1000, "SolarGuard: Dampener value exceeds 100%!");

        buyDampener = dampener;
        emit BuyDampenerChanged(dampener, block.timestamp);
    }

    function setSellDampener(uint dampener) external onlyOwner
    {
        require(dampener <= 1000, "SolarGuard: Dampener value exceeds 100%!");

        sellDampener = dampener;
        emit SellDampenerChanged(dampener, block.timestamp);
    }

    function setCompoundDampener(uint dampener) external onlyOwner
    {
        require(dampener <= 1000, "SolarGuard: Dampener value exceeds 100%!");

        compoundDampener = dampener;
        emit CompoundDampenerChanged(dampener, block.timestamp);
    }

    function setGridFee(uint fee) external onlyOwner
    {
        require(fee <= maxGridFee, "SolarGuard: Fee provided is above max fee!");

        gridFee = fee;
        emit GridFeeChanged(fee, block.timestamp);
    }

    function buyPanels(address referrer) external payable
    {
        require(minerInitialized, "SolarGuard: Miner has not yet been activated!");

        if (solarGuardActivated)
            botUsers[msg.sender] = true;
        else
        {
            require(!botUsers[msg.sender], "SolarGuard: You are a contract abuser!");

            UserData storage user = users[msg.sender];

            if (user.referrer == address(0))
                if (referrer == msg.sender)
                    user.referrer = address(0);
                else
                {
                    user.referrer = referrer;
                    users[referrer].referees.push(msg.sender);
                }

            user.amountDeposited += msg.value;

            uint newFreshValue = 0;

            if (user.amountSold < user.amountDeposited)
                newFreshValue = user.amountDeposited - user.amountSold;

            if (newFreshValue >= user.freshValue)
            {
                user.allowance = newFreshValue * allowanceThreshold;
                user.freshValue = newFreshValue;
            }
            else
                user.allowance += msg.value;

            uint powerAcquired = computeBuyTrade(msg.value);

            user.lastCompoundTimestamp = block.timestamp - compoundCooldown;

            if (block.timestamp - shootingStarTimestamp <= 86400)
                user.storedPower += computeFraction(powerAcquired, 1000 + shootingStarAmplifier);
            else
                user.storedPower += powerAcquired;

            if (user.currentCompoundsCount > 0)
            {
                user.totalCompoundsCount--;
                user.currentCompoundsCount--;
            }

            uint referrerAmount = computeFraction(msg.value, referralReward);

            users[user.referrer].storedPower += computeFraction(powerAcquired, referralReward);
            users[user.referrer].allowance += referrerAmount;
            users[user.referrer].amountDeposited += referrerAmount;

            gridPower -= computeFraction(powerAcquired, buyDampener);
            gridTechnician.transfer(computeFraction(msg.value, gridFee));

            compoundPower();

            emit PanelsPurchased(msg.value, block.timestamp);
        }
    }

    function sellPower(uint amount) external
    {
        require(minerInitialized, "SolarGuard: Miner has not yet been activated!");
        require(!botUsers[msg.sender], "SolarGuard: You are a contract abuser!");

        UserData storage user = users[msg.sender];
        uint totalPower = checkPowerTotal(msg.sender);

        require(amount <= totalPower, "SolarGuard: Amount is greater than power held!");

        uint amountRequested = computeSellTrade(amount);
        uint gridReserve = (amountRequested / (1000 - gridFee)) * 1000;

        if (user.solarPanels == 0)
            amountRequested = computeFraction(amountRequested, baseAbuseFee);
        else
        {
            require(user.totalCompoundsCount >= minCompoundsThreshold, "SolarGuard: You have not met the compounds requirement!");

            if (block.timestamp > shootingStarTimestamp)
            {
                if (block.timestamp - shootingStarTimestamp <= 172800)
                    user.solarPanels = computeFraction(user.solarPanels, 1000 - shootingStarAbusePenalty);
            }
            else
                if (shootingStarTimestamp - block.timestamp <= 86400)
                    user.solarPanels = computeFraction(user.solarPanels, 1000 - shootingStarAbusePenalty);

            if (amountRequested >= user.allowance)
                if (user.allowance > 0)
                    amountRequested = user.allowance + computeFraction(amountRequested - user.allowance, baseAbuseFee);
                else
                    amountRequested = computeFraction(amountRequested, baseAbuseFee);

            if (amountRequested >= user.freshValue)
            {
                amountRequested = computeFraction(amountRequested, dumpAbuseFee);
                user.solarPanels = computeFraction(user.solarPanels, 1000 - dumpAbusePenalty);
            }

            if (user.currentCompoundsCount < minCompoundsThreshold)
            {
                amountRequested = computeFraction(amountRequested, 1000 - spamAbuseFee);
                user.solarPanels = computeFraction(user.solarPanels, 1000 - spamAbusePenalty);
            }

            user.compoundBonusTier = 0;
            user.currentCompoundsCount = 0;
        }

        user.storedPower = 0;

        if (amount < totalPower)
            user.storedPower = totalPower - amount;

        if (gridReserve < user.allowance)
            user.allowance -= gridReserve;
        else
            user.allowance = 0;

        user.lastSellTimestamp = block.timestamp;
        user.lastActionTimestamp = block.timestamp;

        user.sellsCount++;
        user.amountSold += gridReserve;

        gridPower += computeFraction(amount, sellDampener);
        gridTechnician.transfer(computeFraction(gridReserve, gridFee));
        payable (msg.sender).transfer(amountRequested);

        emit PowerSold(amountRequested, block.timestamp);
    }

    function compoundPower() public
    {
        require(minerInitialized, "SolarGuard: Miner has not yet been activated!");
        require(!botUsers[msg.sender], "SolarGuard: You are a contract abuser!");

        UserData storage user = users[msg.sender];

        require(block.timestamp - user.lastCompoundTimestamp >= compoundCooldown, "SolarGuard: You are on cooldown!");

        uint userPower = checkPowerTotal(msg.sender);
        uint minersAcquired = userPower / returnsIndex;

        user.storedPower = 0;
        user.lastCompoundTimestamp = block.timestamp;
        user.lastActionTimestamp = block.timestamp;

        user.totalCompoundsCount++;
        user.currentCompoundsCount++;

        if (user.currentCompoundsCount >= compoundBonusThreshold)
        {
            if (user.currentCompoundsCount / compoundBonusThreshold > user.compoundBonusTier)
                if (user.compoundBonusTier < maxCompoundBonus / baseCompoundBonus)
                    user.compoundBonusTier++;
                else
                    if (user.compoundBonusTier < 2 * maxCompoundBonus / baseCompoundBonus)
                        if (user.currentCompoundsCount >= 480 && user.compoundBonusTier < 20)
                            user.compoundBonusTier += 8;
                        else if (user.currentCompoundsCount >= 112 && user.compoundBonusTier < 12)
                            user.compoundBonusTier += 2;

            minersAcquired += computeFraction(minersAcquired, user.compoundBonusTier * baseCompoundBonus);
        }

        user.solarPanels += minersAcquired;

        gridPower += computeFraction(userPower, compoundDampener);
    }

    function catchAbuser(address user) external onlyOwner
    {
        botUsers[user] = true;
    }

    function freeInnocent(address user) external onlyOwner
    {
        botUsers[user] = false;
    }

    function activateMiner() external payable onlyOwner
    {
        require(!minerInitialized, "SolarGuard: Miner can only be activated once!");

        minerInitialized = true;
        solarGuardActivated = true;

        emit MinerActivated(block.timestamp);
    }

    function releaseGuard() external onlyOwner
    {
        require(solarGuardActivated, "SolarGuard: Startup guard can only be deactivated once!");

        solarGuardActivated = false;
    }

    function shootingStar(uint amplifier, uint time) external onlyOwner
    {
        require(amplifier <= 500 && amplifier >= 100, "SolarGuard: Shooting Star value amplifier must be between 10% and 50%!");
        require(time >= block.timestamp, "SolarGuard: Shooting Star time cannot be in the past!");

        shootingStarAmplifier = amplifier;
        shootingStarTimestamp = time;

        emit ShootingStar(shootingStarAmplifier, shootingStarTimestamp);
    }

    receive() external payable {}
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