///@dev SPDX-License-Identifier: MIT

library Math {
    function add8(uint8 a, uint8 b) internal pure returns (uint8) {
        uint8 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }

    function pow(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0 && a != 0);
        return a ** b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

interface ICocktailNFT is IERC721 {
    function minted() external view returns (uint256);

    function safeMint(address to) external;
}

interface IFounderNFT is IERC721 {}

pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract SpeakEasy2 is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    ///@dev no constructor in upgradable contracts. Instead we have initializers
    function initialize() public initializer {
        ///@dev as there is no constructor, we need to initialise the OwnableUpgradeable explicitly
        __Ownable_init();
        SILVER_ADDRESS = 0xaC256FB4e7D7D2a882A4c2BE327a031b9cE78FEE;
        EMP_SILVER_ADDRESS = 0xc78BB9c34CdF873FcCF787AF8d84DE42af45c540;
        GOLD_ADDRESS = 0x284744e6D901e5aB25d918dD1dF3Eb0C2f1dF0a4;
        PLATINUM_ADDRESS = address(0);
        GT_ADDRESS = 0x77Fe17f2DFBBE22F40F017F104AfecE49bCCF006;
        MARGARITA_ADDRESS = 0x62755Fec3c20ed2CbC1f4DcE19dBc13fc4492e60;
        BLOODYMARY_ADDRESS = 0x40551fF067bB72266Cfc4f00c95b243d98cA3483;
        PINACOLADA_ADDRESS = 0x0Ce0fFFB109255cD610eF53d4f8Ec0AC7131028D;
        IRISHCOFFEE_ADDRESS = 0xEd35aC3c7f2DfAD24DF217A153F3609e20110fd6;
        OLDFASHIONED_ADDRESS = 0x7Ab0424183fc12585D44Bee81429819473Bbf026;
        FOUNDER_ADDRESS = 0x7baB11C737Aea754E23aefaBeA0213c931b4DE6b;
        MINTING_CONTRACT_ADDRESS = 0x26749cd89671b289F225Bc917A971E11553333f3;

        DEV_ADDRESS = 0xbab5B268bBa1E1ED488e5C91b6df3966bC8d8EeE;
        STAFF_ADDRESS = 0x266ad1b5BC8A484Be97B20632A1fAf36c09b6EE7;
        OPERATION_ADDRESS = 0x90849d08168D8D665cb45ae4BD3f9E6037C6E365;
        BANK_ADDRESS = 0xce238AddA1C558f213469d442128739a876fBB3d;
        OWNER_ADDRESS = _msgSender();
        _dev = payable(DEV_ADDRESS);
        _staff = payable(STAFF_ADDRESS);
        _bank = payable(BANK_ADDRESS);
        _owner = payable(OWNER_ADDRESS);
        SECONDS_PER_DAY = 86400;
        COMMON_POT_FEE = 5;
        REINVEST_POT_FEE = 3;
        STAFF_FEE = 2;
        DEV_FEE = 10;
        REF_BONUS = 5;
        MIN_DEPOSIT = 100000000000000000; ///@dev 0.1 BNB
        MAX_WEEKLY_REWARDS_IN_BNB = 2000000000000000000; ///@dev 2 BNB
        MAX_TOTAL_DEPOSIT_SIZE = 20000000000000000000; ///@dev 20 BNB
        MAX_REFS = 25;

        _EMPsilverMKCNFT = ICocktailNFT(EMP_SILVER_ADDRESS);
        _silverMKCNFT = ICocktailNFT(SILVER_ADDRESS);
        _goldMKCNFT = ICocktailNFT(GOLD_ADDRESS);
        _platinumMKCNFT = ICocktailNFT(PLATINUM_ADDRESS);
        _bloodyMaryNft = ICocktailNFT(BLOODYMARY_ADDRESS);
        _ginAndTonicNft = ICocktailNFT(GT_ADDRESS);
        _irishCoffeeNft = ICocktailNFT(IRISHCOFFEE_ADDRESS);
        _margaritaNft = ICocktailNFT(MARGARITA_ADDRESS);
        _oldFashionedNft = ICocktailNFT(OLDFASHIONED_ADDRESS);
        _pinaColadaNft = ICocktailNFT(PINACOLADA_ADDRESS);
        _founderNft = IFounderNFT(FOUNDER_ADDRESS);

        _NOT_ENTERED = 1;
        _ENTERED = 2;
        _status = _NOT_ENTERED;

        investorsCapEnabled = false;
        investorsCap = 1000;
    }

    ///@dev required by the OZ UUPS module
    function _authorizeUpgrade(address) internal override onlyOwner {}

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    using Math for uint256;

    ICocktailNFT public _EMPsilverMKCNFT;
    ICocktailNFT public _silverMKCNFT;
    ICocktailNFT public _goldMKCNFT;
    ICocktailNFT public _platinumMKCNFT;
    ICocktailNFT public _bloodyMaryNft;
    ICocktailNFT public _ginAndTonicNft;
    ICocktailNFT public _irishCoffeeNft;
    ICocktailNFT public _margaritaNft;
    ICocktailNFT public _oldFashionedNft;
    ICocktailNFT public _pinaColadaNft;
    IFounderNFT public _founderNft;

    address private MINTING_CONTRACT_ADDRESS;
    address private EMP_SILVER_ADDRESS;
    address private SILVER_ADDRESS;
    address private GOLD_ADDRESS;
    address private PLATINUM_ADDRESS;
    address private GT_ADDRESS;
    address private MARGARITA_ADDRESS;
    address private BLOODYMARY_ADDRESS;
    address private PINACOLADA_ADDRESS;
    address private IRISHCOFFEE_ADDRESS;
    address private OLDFASHIONED_ADDRESS;
    address private FOUNDER_ADDRESS;

    address private DEV_ADDRESS;
    address private STAFF_ADDRESS;
    address private OPERATION_ADDRESS;
    address private BANK_ADDRESS;
    address private OWNER_ADDRESS;
    address payable internal _dev;
    address payable internal _staff;
    address payable internal _bank;
    address payable internal _owner;

    uint32 private SECONDS_PER_DAY;
    uint8 private COMMON_POT_FEE;
    uint8 private REINVEST_POT_FEE;
    uint8 private STAFF_FEE;
    uint16 private DEV_FEE;
    uint8 private REF_BONUS;
    uint256 private MIN_DEPOSIT;
    uint256 private MAX_WEEKLY_REWARDS_IN_BNB;
    uint256 private MAX_TOTAL_DEPOSIT_SIZE;
    uint32 private MAX_REFS;

    uint256 public totalUsers;
    bool public investorsCapEnabled;
    uint256 public investorsCap;

    uint256 private _NOT_ENTERED;
    uint256 private _ENTERED;
    uint256 private _status;

    struct User {
        address adr;
        uint256 lastActionAt;
        uint256 lastDepositAt;
        uint256 lastClaimAt;
        uint256 lastReinvestAt;
        uint256 tvl;
        address upline;
        bool hasReferred;
        address[] referrals;
        uint256 firstDeposit;
        uint256 totalDeposit;
        uint256 totalPayout;
        uint256 reinvestBonusReward;
    }

    mapping(address => User) internal users;

    event EmitBought(
        address indexed adr,
        address indexed ref,
        uint256 bnbamount,
        uint256 bnbBefore,
        uint256 bnbAfter
    );
    event EmitReinvested(
        address indexed adr,
        address indexed ref,
        uint256 bnbBefore,
        uint256 bnbAfter
    );
    event EmitClaimed(
        address indexed adr,
        uint256 bnbToClaim,
        uint256 bnbToClaimBeforeFee
    );
    event LogBytes(bytes data);

    modifier onlyTeam() {
        require(msg.sender == OPERATION_ADDRESS || msg.sender == OWNER_ADDRESS);
        _;
    }

    function user(address adr) public view returns (User memory) {
        return users[adr];
    }

    function setInvestorsCap(
        bool enable,
        uint256 cap
    ) public onlyTeam returns (bool enabled, uint256 capSize) {
        investorsCapEnabled = enable;
        investorsCap = cap;
        return (investorsCapEnabled, investorsCap);
    }

    function minDeposit(uint256 value, address adr) public view returns (bool) {
        if (hasMembership(adr)) {
            return true;
        }
        return value >= MIN_DEPOSIT;
    }

    function deposit(address ref) public payable nonReentrant {
        require(
            hasInvested(msg.sender) == false,
            "This can only be called as the initial deposit"
        );
        require(
            investorsCapEnabled == false ||
                (investorsCapEnabled && totalUsers < investorsCap),
            "New investors are not allowed at this moment"
        );
        handleDeposit(msg.sender, msg.value, ref);
    }

    function handleDeposit(address sender, uint256 value, address ref) private {
        User storage signer = users[sender];
        User storage upline = users[ref];
        require(
            minDeposit(value, sender),
            "Deposit doesn't meet the minimum requirements"
        );
        require(
            Math.add(signer.totalDeposit, value) <= MAX_TOTAL_DEPOSIT_SIZE,
            "Max total deposit reached"
        );
        require(
            ref == address(0) || ref == sender || hasInvested(upline.adr),
            "Ref must be investor to set as upline"
        );
        require(
            maxReferralsReached(ref) == false,
            "Ref has too many referrals."
        );

        signer.adr = sender;
        uint256 tvlBefore = signer.tvl;

        uint256 potFee = percentFromAmount(value, COMMON_POT_FEE);
        uint256 devFee = percentFromAmount(potFee, DEV_FEE);
        potFee = potFee.sub(devFee);
        uint256 staffFee = percentFromAmount(value, STAFF_FEE);
        uint256 totalBnbFee = potFee.add(staffFee).add(devFee);

        uint256 bnbValue = Math.sub(value, totalBnbFee);
        signer.tvl = Math.add(signer.tvl, bnbValue);

        uint256 toBank = Math.div(bnbValue, 2);

        if (
            !signer.hasReferred &&
            ref != sender &&
            ref != address(0) &&
            hasMembership(ref)
        ) {
            signer.upline = ref;
            signer.hasReferred = true;

            upline.referrals.push(sender);
            if (hasInvested(signer.adr) == false) {
                uint256 refBonus = percentFromAmount(value, REF_BONUS);
                upline.tvl = upline.tvl.add(refBonus);
                if (upline.tvl > MAX_TOTAL_DEPOSIT_SIZE) {
                    upline.tvl = MAX_TOTAL_DEPOSIT_SIZE;
                }
            }
        }

        if (hasInvested(signer.adr) == false) {
            signer.firstDeposit = block.timestamp;
            totalUsers++;
        }

        signer.totalDeposit = Math.add(signer.totalDeposit, value);
        signer.lastActionAt = block.timestamp;
        signer.lastDepositAt = block.timestamp;

        _bank.transfer(toBank);
        sendFees(staffFee, devFee);

        emit EmitBought(sender, ref, value, tvlBefore, signer.tvl);
    }

    function teamAddresses()
        public
        view
        returns (address operation, address staff, address owner, address bank)
    {
        return (OPERATION_ADDRESS, STAFF_ADDRESS, OWNER_ADDRESS, BANK_ADDRESS);
    }

    function reinvest() public payable nonReentrant {
        User storage signer = users[msg.sender];
        require(hasInvested(signer.adr), "Must be invested to reinvest");
        require(
            canClaimOrReinvest(signer.adr),
            "7 days haven't passed since last action"
        );

        uint256 tvlBefore = signer.tvl;
        uint256 bnbRewardsBeforeFee = rewards(signer.adr);

        uint256 potFee = percentFromAmount(
            bnbRewardsBeforeFee,
            REINVEST_POT_FEE
        );
        uint256 devFee = percentFromAmount(potFee, DEV_FEE);
        potFee = potFee.sub(devFee);
        uint256 staffFee = percentFromAmount(bnbRewardsBeforeFee, STAFF_FEE);
        uint256 totalBnbFee = potFee.add(staffFee).add(devFee);

        uint256 bnbRewards = bnbRewardsBeforeFee.sub(totalBnbFee);

        signer.tvl = Math.add(signer.tvl, bnbRewards);
        signer.lastActionAt = block.timestamp;
        signer.lastReinvestAt = block.timestamp;

        signer.totalDeposit = Math.add(signer.totalDeposit, bnbRewards);
        if (signer.totalDeposit > MAX_TOTAL_DEPOSIT_SIZE) {
            signer.totalDeposit = MAX_TOTAL_DEPOSIT_SIZE;
        }
        if (signer.tvl > MAX_TOTAL_DEPOSIT_SIZE) {
            signer.tvl = MAX_TOTAL_DEPOSIT_SIZE;
        }

        signer.reinvestBonusReward = signer.reinvestBonusReward.add(10000); ///@dev adding 0.01% to daily reward

        emit EmitReinvested(msg.sender, signer.upline, tvlBefore, signer.tvl);

        if (msg.value > 0) {
            handleDeposit(msg.sender, msg.value, address(0));
        }

        sendFees(staffFee, devFee);
    }

    function claim() public nonReentrant {
        User storage signer = users[msg.sender];
        require(hasInvested(signer.adr), "Must be invested to claim");
        require(
            canClaimOrReinvest(signer.adr),
            "7 days haven't passed since last action"
        );
        require(
            maxPayoutReached(signer.adr) == false,
            "You have reached max payout"
        );

        uint256 rewardsBeforeFee = rewards(signer.adr);

        uint256 potFee = percentFromAmount(rewardsBeforeFee, COMMON_POT_FEE);
        uint256 devFee = percentFromAmount(potFee, DEV_FEE);
        potFee = potFee.sub(devFee);
        uint256 staffFee = percentFromAmount(rewardsBeforeFee, STAFF_FEE);
        uint256 totalBnbFee = potFee.add(staffFee).add(devFee);

        uint256 bnbToClaim = Math.sub(rewardsBeforeFee, totalBnbFee);

        if (
            Math.add(rewardsBeforeFee, signer.totalPayout) >=
            maxPayout(signer.adr)
        ) {
            bnbToClaim = Math.sub(maxPayout(signer.adr), signer.totalPayout);
            signer.totalPayout = maxPayout(signer.adr);
        } else {
            signer.totalPayout = Math.add(signer.totalPayout, bnbToClaim);
        }

        signer.lastActionAt = block.timestamp;
        signer.lastClaimAt = block.timestamp;

        sendFees(staffFee, devFee);
        payable(msg.sender).transfer(bnbToClaim);

        emit EmitClaimed(msg.sender, bnbToClaim, rewardsBeforeFee);
    }

    function hasMembership(address adr) public view returns (bool) {
        return
            _silverMKCNFT.balanceOf(adr) > 0 ||
            _goldMKCNFT.balanceOf(adr) > 0 ||
            _EMPsilverMKCNFT.balanceOf(adr) > 0;
    }

    function maxReferralsReached(
        address refAddress
    ) public view returns (bool) {
        return users[refAddress].referrals.length >= MAX_REFS;
    }

    function sendFees(uint256 staffFee, uint256 devFee) private {
        _dev.transfer(devFee);
        _staff.transfer(staffFee);
    }

    function maxPayoutReached(address adr) public view returns (bool) {
        return users[adr].totalPayout >= maxPayout(adr);
    }

    function maxPayout(address adr) public view returns (uint256) {
        return Math.mul(users[adr].totalDeposit, 3);
    }

    function hasInvested(address adr) public view returns (bool) {
        return users[adr].firstDeposit != 0;
    }

    function tvl(address adr) public view returns (uint256) {
        return Math.min(MAX_TOTAL_DEPOSIT_SIZE, users[adr].tvl);
    }

    function referrals(
        address adr
    ) public view returns (address[] memory downlines) {
        return users[adr].referrals;
    }

    function percentFromAmount(
        uint256 amount,
        uint256 fee
    ) private pure returns (uint256) {
        return Math.div(Math.mul(amount, fee), 100);
    }

    function canClaimOrReinvest(address adr) public view returns (bool) {
        return secondsSinceLastAction(adr) >= Math.mul(7, SECONDS_PER_DAY);
    }

    function rewards(address adr) public view returns (uint256) {
        uint256 secondsPassed = secondsSinceLastAction(adr);
        uint256 dailyRewardFactor = dailyRewards(adr);
        uint256 bnbRewarded = calcRewards(
            secondsPassed,
            dailyRewardFactor,
            adr
        );

        if (bnbRewarded >= MAX_WEEKLY_REWARDS_IN_BNB) {
            return MAX_WEEKLY_REWARDS_IN_BNB;
        }

        return bnbRewarded;
    }

    function secondsSinceLastAction(
        address adr
    ) private view returns (uint256) {
        return
            Math.min(
                Math.mul(SECONDS_PER_DAY, 7),
                Math.sub(block.timestamp, users[adr].lastActionAt)
            );
    }

    function dailyRewards(address adr) public view returns (uint256) {
        uint256 daily = rewardsFromSilverSet(adr);
        if (_goldMKCNFT.balanceOf(adr) > 0) {
            daily = rewardsFromGoldSet(adr);
        }
        return Math.min(1500000, daily);
    }

    function rewardsFromSilverSet(address adr) private view returns (uint256) {
        if (hasMembership(adr) == false)
            return Math.add(250000, users[adr].reinvestBonusReward); ///@dev 0.25% + reinvest bonus

        uint256 baseDaily = 500000; ///@dev 0.5%

        if (_founderNft.balanceOf(adr) > 0) {
            baseDaily = baseDaily.add(100000);
        }

        if (_oldFashionedNft.balanceOf(adr) > 0)
            return
                Math.add(
                    baseDaily.add(1000000),
                    users[adr].reinvestBonusReward
                ); ///@dev 1% + reinvest bonus
        if (_irishCoffeeNft.balanceOf(adr) > 0)
            return
                Math.add(baseDaily.add(800000), users[adr].reinvestBonusReward); ///@dev 0.8% + reinvest bonus
        if (_pinaColadaNft.balanceOf(adr) > 0)
            return
                Math.add(baseDaily.add(650000), users[adr].reinvestBonusReward); ///@dev 0.65% + reinvest bonus
        if (_bloodyMaryNft.balanceOf(adr) > 0)
            return
                Math.add(baseDaily.add(500000), users[adr].reinvestBonusReward); ///@dev 0.5% + reinvest bonus
        if (_margaritaNft.balanceOf(adr) > 0)
            return
                Math.add(baseDaily.add(350000), users[adr].reinvestBonusReward); ///@dev 0.35% + reinvest bonus
        if (_ginAndTonicNft.balanceOf(adr) > 0)
            return
                Math.add(baseDaily.add(250000), users[adr].reinvestBonusReward); ///@dev 0.25% + reinvest bonus

        return Math.add(baseDaily, users[adr].reinvestBonusReward); ///@dev (0.5% or 0.6%) + reinvest bonus
    }

    function rewardsFromGoldSet(address adr) private view returns (uint256) {
        if (hasMembership(adr) == false)
            return Math.add(250000, users[adr].reinvestBonusReward); ///@dev 0.25% + reinvest bonus

        return Math.add(750000, users[adr].reinvestBonusReward); ///@dev 0.75% + reinvest bonus
    }

    function calcRewards(
        uint256 secondsPassed,
        uint256 dailyRewardFactor,
        address adr
    ) private view returns (uint256) {
        uint256 userTvl = Math.min(MAX_TOTAL_DEPOSIT_SIZE, users[adr].tvl);
        uint256 rewardsPerDay = percentFromAmount(
            Math.mul(userTvl, 1000),
            dailyRewardFactor
        );
        uint256 rewardsPerSecond = Math.div(rewardsPerDay, SECONDS_PER_DAY);
        uint256 bnbRewarded = Math.mul(rewardsPerSecond, secondsPassed);
        bnbRewarded = Math.div(bnbRewarded, 1000000000);
        return bnbRewarded;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.1) (proxy/utils/Initializable.sol)

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
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
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
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
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
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/UUPSUpgradeable.sol)

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
     * implementation. It is used to validate the implementation's compatibility when performing an upgrade.
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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

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
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
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