/**
    >>> BUSD Beans'N Toast <<< 
    ┌─────────────────────────────────────────────────────────────────┐
    |             --- DEVELOPED BY JackOnChain (JOC) ---              |
    |          Looking for help to create your own contract?          |
    |                    Telgegram: JackTripperz                      |
    └─────────────────────────────────────────────────────────────────┘                                                      
**/

// SPDX-License-Identifier: MIT

library Math {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function pow(uint256 a, uint256 b) internal pure returns (uint256) {
        return a**b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BUSDBeansAndToast is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    ///@dev no constructor in upgradable contracts. Instead we have initializers
    function initialize() public initializer {
        ///@dev as there is no constructor, we need to initialise the OwnableUpgradeable explicitly
        __Ownable_init();
        PROJECT_OWNER_ADDRESS = 0x4D26FD35B9613D2AbF4cC72FbE153d74375d395b;
        MARKETING_ADDRESS = 0xf2928F7a7405B64662f1788B9557216C8005c388;
        TEAM_ADDRESS = 0x8d303248D7C034D97F60BA54D69f1eD1C44F84Fd;
        CONTRACT_DEV_ADDRESS = 0xbab5B268bBa1E1ED488e5C91b6df3966bC8d8EeE;
        DAPP_DEV_ADDRESS = 0x015d01b27d8241a0a5216fF9C80F038d524413a9;
        REVENUE_ADDRESS = 0x0f024A88ADa373E00f08baf2997F43691b132274;
        INJECTION_ADDRESS = 0xE37470F8e5795b78266881c0fD114b611d55C498;
        OWNER_ADDRESS = _msgSender();
        // TOKEN_ADDRESS = 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0; //local test;
        TOKEN_ADDRESS = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee; //testnest;
        // TOKEN_ADDRESS = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; //mainnet;
        _projectOwner = payable(PROJECT_OWNER_ADDRESS);
        _marketing = payable(MARKETING_ADDRESS);
        _team = payable(TEAM_ADDRESS);
        _contractDev = payable(CONTRACT_DEV_ADDRESS);
        _dappDev = payable(DAPP_DEV_ADDRESS);
        _revenue = payable(REVENUE_ADDRESS);
        _injection = payable(INJECTION_ADDRESS);
        _owner = payable(OWNER_ADDRESS);
        TOKEN_PER_BEAN = 100000000000000;
        SECONDS_PER_DAY = 86400;
        DEPOSIT_FEE = 4;
        WITHDRAWAL_FEE = 4;
        REF_BONUS = 5;
        FIRST_DEPOSIT_REF_BONUS = 5;
        MIN_DEPOSIT = 10000000000000000000; // 10 Tokens
        MIN_REBAKE = 10000000000000000000; // 10 Tokens
        MAX_WALLET_TVL = 50000000000000000000000; // 50000 Tokens
        MAX_DAILY_REWARDS = 2500000000000000000000; // 2500 Tokens
        MIN_REF_DEPOSIT_FOR_BONUS = 100000000000000000000; // 100 Tokens

        _token = IERC20(TOKEN_ADDRESS);

        _NOT_ENTERED = 1;
        _ENTERED = 2;
        _status = _NOT_ENTERED;
    }

    ///@dev required by the OZ UUPS module
    function _authorizeUpgrade(address) internal override onlyOwner {}

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    modifier onlyProjectOwner() {
        require(msg.sender == PROJECT_OWNER_ADDRESS);
        _;
    }

    using Math for uint256;

    IERC20 public _token;
    uint256 public CONTRACT_CREATION_TIME;
    bool public CONTRACT_LIVE;

    address private PROJECT_OWNER_ADDRESS;
    address private MARKETING_ADDRESS;
    address private TEAM_ADDRESS;
    address private CONTRACT_DEV_ADDRESS;
    address private DAPP_DEV_ADDRESS;
    address private REVENUE_ADDRESS;
    address private INJECTION_ADDRESS;
    address private OWNER_ADDRESS;
    address private TOKEN_ADDRESS;
    address payable internal _projectOwner;
    address payable internal _marketing;
    address payable internal _team;
    address payable internal _contractDev;
    address payable internal _dappDev;
    address payable internal _revenue;
    address payable internal _injection;
    address payable internal _owner;

    uint136 private TOKEN_PER_BEAN;
    uint32 private SECONDS_PER_DAY;
    uint8 private DEPOSIT_FEE;
    uint8 private WITHDRAWAL_FEE;
    uint8 private REF_BONUS;
    uint8 private FIRST_DEPOSIT_REF_BONUS;
    uint256 private MIN_DEPOSIT;
    uint256 private MIN_REBAKE;
    uint256 private MAX_WALLET_TVL;
    uint256 private MAX_DAILY_REWARDS;
    uint256 private MIN_REF_DEPOSIT_FOR_BONUS;

    uint256 public totalBakers;

    uint256 private _NOT_ENTERED;
    uint256 private _ENTERED;
    uint256 private _status;

    struct Baker {
        address adr;
        uint256 beans;
        uint256 rebakedAt;
        uint256 ateAt;
        address upline;
        bool hasReferred;
        address[] referrals;
        address[] bonusEligibleReferrals;
        uint256 firstDeposit;
        uint256 totalDeposit;
        uint256 totalPayout;
        bool blacklisted;
    }

    mapping(address => Baker) internal bakers;

    event EmitBoughtBeans(
        address indexed adr,
        address indexed ref,
        uint256 tokenAmount,
        uint256 beansFrom,
        uint256 beansTo
    );
    event EmitReBaked(
        address indexed adr,
        address indexed ref,
        uint256 beansFrom,
        uint256 beansTo
    );
    event EmitAte(
        address indexed adr,
        uint256 tokenToEat,
        uint256 beansBeforeFee
    );
    event EmitRevenueOwnerDeposit(uint256 tokenAmount);

    function intitate() public onlyProjectOwner {
        CONTRACT_CREATION_TIME = block.timestamp;
        CONTRACT_LIVE = true;
    }

    function revenueOwnerDeposit(uint256 tokens) public onlyProjectOwner {
        bool revSuccess = _token.transferFrom(
            address(msg.sender),
            address(this),
            tokens
        );
        if (revSuccess == false) {
            revert("Owner deposit token transfer failed");
        }
        emit EmitRevenueOwnerDeposit(tokens);
    }

    function blacklist(address adr, bool setAsBlacklisted)
        public
        onlyProjectOwner
    {
        bakers[adr].blacklisted = setAsBlacklisted;
    }

    function user(address adr) public view returns (Baker memory) {
        return bakers[adr];
    }

    function throttleBuy(address adr, uint256 tokens)
        private
        view
        returns (bool throttled)
    {
        if (block.timestamp.sub(CONTRACT_CREATION_TIME) > 7200) {
            // 2 hours has passed since contract creation
            return false;
        }
        if (
            block.timestamp.sub(CONTRACT_CREATION_TIME) <= 1800 && // 30 min
            bakers[adr].totalDeposit.add(tokens) > 2000000000000000000000 // 2000 tokens
        ) {
            return true;
        }
        if (
            block.timestamp.sub(CONTRACT_CREATION_TIME) <= 3600 && // 1 hour
            bakers[adr].totalDeposit.add(tokens) > 5000000000000000000000 // 5000 tokens
        ) {
            return true;
        }
        if (
            block.timestamp.sub(CONTRACT_CREATION_TIME) <= 7200 && // 2 hours
            bakers[adr].totalDeposit.add(tokens) > 10000000000000000000000 // 10000 tokens
        ) {
            return true;
        }
        return false;
    }

    function buyBeans(address ref, uint256 tokens) public nonReentrant {
        Baker storage baker = bakers[msg.sender];
        Baker storage upline = bakers[ref];
        require(CONTRACT_LIVE == true, "Contract not live yet");
        require(
            tokens >= MIN_DEPOSIT,
            "Deposit doesn't meet the minimum requirements"
        );
        require(
            Math.add(baker.totalDeposit, tokens) <= MAX_WALLET_TVL,
            "Max total deposit reached"
        );
        require(
            ref == address(0) || ref == msg.sender || hasInvested(upline.adr),
            "Ref must be investor to set as upline"
        );
        require(
            throttleBuy(msg.sender, tokens) == false,
            "User max buy being throttled"
        );

        baker.adr = msg.sender;
        uint256 beansFrom = baker.beans;
        uint256 totalFee = percentFromAmount(tokens, DEPOSIT_FEE);
        uint256 tokenValue = Math.sub(tokens, totalFee);

        bool success = _token.transferFrom(
            address(msg.sender),
            address(this),
            tokens
        );
        if (success == false) {
            revert("Contract token transfer failed");
        }

        uint256 revenueDeposit = percentFromAmount(tokenValue, 30);
        bool revSuccess = _token.transfer(_revenue, revenueDeposit);
        if (revSuccess == false) {
            revert("Revenue token transfer failed");
        }

        uint256 beansBought = tokenToBeans(tokenValue);
        uint256 totalBeansBought = addBeans(baker.adr, beansBought);
        baker.beans = totalBeansBought;

        if (
            !baker.hasReferred &&
            ref != msg.sender &&
            ref != address(0) &&
            baker.upline != msg.sender
        ) {
            baker.upline = ref;
            baker.hasReferred = true;

            upline.referrals.push(msg.sender);
            if (hasInvested(baker.adr) == false) {
                uint256 refBonus = percentFromAmount(
                    tokenToBeans(tokens),
                    FIRST_DEPOSIT_REF_BONUS
                );
                upline.beans = addBeans(upline.adr, refBonus);
            }
        }

        if (hasInvested(baker.adr) == false) {
            baker.firstDeposit = block.timestamp;
            totalBakers++;
        }

        baker.totalDeposit = Math.add(baker.totalDeposit, tokens);
        if (
            baker.hasReferred &&
            baker.totalDeposit >= MIN_REF_DEPOSIT_FOR_BONUS &&
            refExists(baker.adr, baker.upline) == false
        ) {
            upline.bonusEligibleReferrals.push(msg.sender);
        }

        sendFees(totalFee, 0);
        handleReBake(false);

        emit EmitBoughtBeans(msg.sender, ref, tokens, beansFrom, baker.beans);
    }

    function refExists(address ref, address upline)
        private
        view
        returns (bool)
    {
        for (
            uint256 i = 0;
            i < bakers[upline].bonusEligibleReferrals.length;
            i++
        ) {
            if (bakers[upline].bonusEligibleReferrals[i] == ref) {
                return true;
            }
        }

        return false;
    }

    function sendFees(uint256 totalFee, uint256 remainingTax) private {
        uint256 projectOwner = percentFromAmount(totalFee, 50);
        uint256 marketing = percentFromAmount(totalFee, 25);
        uint256 team = percentFromAmount(totalFee, 15);
        uint256 contractDev = percentFromAmount(totalFee, 5);
        uint256 dappDev = percentFromAmount(totalFee, 1);
        uint256 revenue = percentFromAmount(totalFee, 4);

        _token.transfer(_projectOwner, projectOwner);
        _token.transfer(_marketing, marketing);
        _token.transfer(_team, team);
        _token.transfer(_contractDev, contractDev);
        _token.transfer(_dappDev, dappDev);
        _token.transfer(_revenue, revenue);

        if (remainingTax > 0) {
            _token.transfer(_revenue, percentFromAmount(remainingTax, 50));
            _token.transfer(_injection, percentFromAmount(remainingTax, 50));
        }
    }

    function handleReBake(bool onlyRebaking) private {
        Baker storage baker = bakers[msg.sender];
        require(maxTvlReached(baker.adr) == false, "Total wallet TVL reached");
        require(hasInvested(baker.adr), "Must be invested to bake");
        if (onlyRebaking == true) {
            require(
                beansToToken(rewardedBeans(baker.adr)) >= MIN_REBAKE,
                "Rewards must be equal or higher than 10 tokens to bake"
            );
        }

        uint256 beansFrom = baker.beans;
        uint256 beansFromRewards = rewardedBeans(baker.adr);

        uint256 totalBeans = addBeans(baker.adr, beansFromRewards);
        baker.beans = totalBeans;
        baker.rebakedAt = block.timestamp;

        emit EmitReBaked(msg.sender, baker.upline, beansFrom, baker.beans);
    }

    function rebake() public nonReentrant {
        handleReBake(true);
    }

    function eat() public nonReentrant {
        Baker storage baker = bakers[msg.sender];
        require(hasInvested(baker.adr), "Must be invested to eat");

        uint256 beansBeforeFee = rewardedBeans(baker.adr);
        uint256 beansInTokensBeforeFee = beansToToken(beansBeforeFee);

        uint256 totalFee = percentFromAmount(
            beansInTokensBeforeFee,
            WITHDRAWAL_FEE
        );

        uint256 tokensAfterFee = Math.sub(beansInTokensBeforeFee, totalFee);
        uint256 tokensToEat = addWithdrawalTaxes(baker.adr, tokensAfterFee);
        uint256 remainingTax = tokensAfterFee.sub(tokensToEat);

        uint256 afterTax = addWithdrawalTaxes(
            baker.adr,
            beansInTokensBeforeFee
        );
        baker.totalPayout = Math.add(baker.totalPayout, afterTax);

        baker.ateAt = block.timestamp;
        baker.rebakedAt = block.timestamp;

        sendFees(totalFee, remainingTax);
        _token.transfer(msg.sender, tokensToEat);

        emit EmitAte(msg.sender, tokensToEat, beansBeforeFee);
    }

    function contractBalance() public view returns (uint256) {
        return _token.balanceOf(address(this));
    }

    function addWithdrawalTaxes(address adr, uint256 withdrawalAmount)
        private
        view
        returns (uint256)
    {
        return
            percentFromAmount(
                withdrawalAmount,
                Math.sub(100, hasBeanTaxed(adr))
            );
    }

    function hasBeanTaxed(address adr) public view returns (uint256) {
        uint256 daysPassed = daysSinceLastEat(adr);
        uint256 lastDigit = daysPassed % 10;

        if (lastDigit <= 0) return 90;
        if (lastDigit <= 1) return 80;
        if (lastDigit <= 2) return 70;
        if (lastDigit <= 3) return 60;
        if (lastDigit <= 4) return 50;
        if (lastDigit <= 5) return 40;
        if (lastDigit <= 6) return 30;
        if (lastDigit <= 7) return 20;
        if (lastDigit <= 8) return 10;
        return 0;
    }

    function secondsSinceLastEat(address adr) public view returns (uint256) {
        uint256 lastAteOrFirstDeposit = bakers[adr].ateAt;
        if (bakers[adr].ateAt == 0) {
            lastAteOrFirstDeposit = bakers[adr].firstDeposit;
        }

        uint256 secondsPassed = Math.sub(
            block.timestamp,
            lastAteOrFirstDeposit
        );

        return secondsPassed;
    }

    function userBonusEligibleReferrals(address adr)
        public
        view
        returns (address[] memory)
    {
        return bakers[adr].bonusEligibleReferrals;
    }

    function userReferrals(address adr) public view returns (address[] memory) {
        return bakers[adr].referrals;
    }

    function daysSinceLastEat(address adr) private view returns (uint256) {
        uint256 secondsPassed = secondsSinceLastEat(adr);
        return Math.div(secondsPassed, SECONDS_PER_DAY);
    }

    function addBeans(address adr, uint256 beansToAdd)
        private
        view
        returns (uint256)
    {
        uint256 totalBeans = Math.add(bakers[adr].beans, beansToAdd);
        uint256 maxBeans = tokenToBeans(MAX_WALLET_TVL);
        if (totalBeans >= maxBeans) {
            return maxBeans;
        }
        return totalBeans;
    }

    function maxTvlReached(address adr) public view returns (bool) {
        return bakers[adr].beans >= tokenToBeans(MAX_WALLET_TVL);
    }

    function hasInvested(address adr) public view returns (bool) {
        return bakers[adr].firstDeposit != 0;
    }

    function tokenRewards(address adr) public view returns (uint256) {
        uint256 beansRewarded = rewardedBeans(adr);
        uint256 inWei = beansToToken(beansRewarded);
        return inWei;
    }

    function tokenTvl(address adr) public view returns (uint256) {
        uint256 inWei = beansToToken(bakers[adr].beans);
        return inWei;
    }

    function beansToToken(uint256 beansToCalc) private view returns (uint256) {
        uint256 inWei = Math.mul(beansToCalc, TOKEN_PER_BEAN);
        return inWei;
    }

    function tokenToBeans(uint256 inWei) private view returns (uint256) {
        uint256 beans = Math.div(inWei, TOKEN_PER_BEAN);
        return beans;
    }

    function percentFromAmount(uint256 amount, uint256 fee)
        private
        pure
        returns (uint256)
    {
        return Math.div(Math.mul(amount, fee), 100);
    }

    function dailyReward(address adr) public view returns (uint256) {
        uint256 referralsCount = bakers[adr].bonusEligibleReferrals.length;
        if (referralsCount < 25) return 20000000;
        if (referralsCount < 125) return (25000000);
        return 30000000;
    }

    function secondsSinceLastAction(address adr)
        private
        view
        returns (uint256)
    {
        uint256 lastTimeStamp = bakers[adr].rebakedAt;
        if (lastTimeStamp == 0) {
            lastTimeStamp = bakers[adr].ateAt;
        }

        if (lastTimeStamp == 0) {
            lastTimeStamp = bakers[adr].firstDeposit;
        }

        return Math.sub(block.timestamp, lastTimeStamp);
    }

    function rewardedBeans(address adr) private view returns (uint256) {
        uint256 secondsPassed = secondsSinceLastAction(adr);
        uint256 dailyRewardFactor = dailyReward(adr);
        uint256 beansRewarded = calcBeansReward(
            secondsPassed,
            dailyRewardFactor,
            adr
        );

        if (beansRewarded >= tokenToBeans(MAX_DAILY_REWARDS)) {
            return tokenToBeans(MAX_DAILY_REWARDS);
        }

        return beansRewarded;
    }

    function calcBeansReward(
        uint256 secondsPassed,
        uint256 dailyRewardFactor,
        address adr
    ) private view returns (uint256) {
        uint256 rewardsPerDay = percentFromAmount(
            Math.mul(bakers[adr].beans, 10000000000),
            dailyRewardFactor
        );
        uint256 rewardsPerSecond = Math.div(rewardsPerDay, SECONDS_PER_DAY);
        uint256 beansRewarded = Math.mul(rewardsPerSecond, secondsPassed);
        beansRewarded = Math.div(beansRewarded, 100000000000000000);
        return beansRewarded;
    }
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
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;

import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../ERC1967/ERC1967UpgradeUpgradeable.sol";
import "./Initializable.sol";

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate that the this implementation remains valid after an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
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
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeaconUpgradeable.sol";
import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/StorageSlotUpgradeable.sol";
import "../utils/Initializable.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
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