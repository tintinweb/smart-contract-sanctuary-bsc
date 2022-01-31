// SPDX-License-Identifier: MIT

pragma solidity 0.8.2;

import "./SummitToken.sol";
import "./Cartographer.sol";
import "./ExpeditionV2.sol";
import "./EverestToken.sol";
import "./PresetPausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";


contract SummitGlacier is Ownable, Initializable, ReentrancyGuard, PresetPausable {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.UintSet;

    SummitToken public summit;
    EverestToken public everest;
    Cartographer public cartographer;
    ExpeditionV2 public expeditionV2;

    bool public panic = false;
    uint256 public constant epochDuration = 3600 * 24 * 7;
    address constant burnAdd = 0x000000000000000000000000000000000000dEaD;

    struct UserLockedWinnings {
        uint256 winnings;
        uint256 bonusEarned;
        uint256 claimedWinnings;
    }

    uint8 public yieldLockEpochCount = 5;

    mapping(address => EnumerableSet.UintSet) userInteractingEpochs;    // List of epochs the user is interacting with (to help with frontend / user info)
    mapping(address => mapping(uint256 => UserLockedWinnings)) public userLockedWinnings;
    mapping(address => uint256) public userLifetimeWinnings;            // Public value for user information
    mapping(address => uint256) public userLifetimeBonusWinnings;       // Public value for user information

    event WinningsLocked(address indexed _userAdd, uint256 _lockedWinnings, uint256 _bonusWinnings);
    event WinningsHarvested(address indexed _userAdd, uint256 _epoch, uint256 _harvestedWinnings, bool _lockForEverest);
    event SetPanic(bool indexed _panic);
    event SetYieldLockEpochCount(uint256 _count);

    function initialize(
        address _summit,
        address _everest,
        address _cartographer,
        address _expeditionV2
    ) public onlyOwner {
        require(_summit != address(0), "Missing SummitToken");
        require(_everest != address(0), "Missing EverestToken");
        require(_cartographer != address(0), "Missing Cartographer");
        require(_expeditionV2 != address(0), "Missing ExpeditionV2");
        summit = SummitToken(_summit);
        everest = EverestToken(_everest);
        cartographer = Cartographer(_cartographer);
        expeditionV2 = ExpeditionV2(_expeditionV2);

        summit.approve(_everest, type(uint256).max);
    }


    function setPanic(bool _panic)
        public
        onlyOwner
    {
        panic = _panic;
        emit SetPanic(_panic);
    }


    // MODIFIERS


    modifier onlyCartographerOrExpedition() {
        require(msg.sender == address(cartographer) || msg.sender == address(expeditionV2), "Only cartographer or expedition");
        _;
    }


    // PUBLIC

    function getCurrentEpoch()
        public view
        returns (uint256)
    {
        return block.timestamp / epochDuration;
    }

    /// @dev Return if an epoch has matured
    function hasEpochMatured(uint256 _epoch)
        public view
        returns (bool)
    {
        return (getCurrentEpoch() - _epoch) >= yieldLockEpochCount;
    }

    function getEpochStartTimestamp(uint256 _epoch)
        public pure
        returns (uint256)
    {
        return _epoch * epochDuration;
    }

    /// @dev Epoch maturity timestamp
    function getEpochMatureTimestamp(uint256 _epoch)
        public view
        returns (uint256)
    {
        return getEpochStartTimestamp(_epoch) + (yieldLockEpochCount * epochDuration);
    }

    function getUserInteractingEpochs(address _userAdd)
        public view
        returns (uint256[] memory)
    {
        return userInteractingEpochs[_userAdd].values();
    }

    // FUNCTIONALITY




    /// @dev Update yield lock epoch count
    function setYieldLockEpochCount(uint8 _count)
        public onlyOwner
    {
        require(_count <= 12, "Invalid lock epoch count");
        yieldLockEpochCount = _count;
        emit SetYieldLockEpochCount(_count);
    }

    function addLockedWinnings(uint256 _lockedWinnings, uint256 _bonusWinnings, address _userAdd)
        external
        onlyCartographerOrExpedition
    {
        uint256 currentEpoch = getCurrentEpoch();
        UserLockedWinnings storage userEpochWinnings = userLockedWinnings[_userAdd][currentEpoch];
        userEpochWinnings.winnings += _lockedWinnings;
        userLifetimeWinnings[_userAdd] += _lockedWinnings;
        userEpochWinnings.bonusEarned += _bonusWinnings;
        userLifetimeBonusWinnings[_userAdd] += _bonusWinnings;
        userInteractingEpochs[_userAdd].add(currentEpoch);

        emit WinningsLocked(_userAdd, _lockedWinnings, _bonusWinnings);
    }

    /// @dev Harvest locked winnings, 50% tax taken on early harvest
    function harvestWinnings(uint256 _epoch, uint256 _amount, bool _lockForEverest)
        public whenNotPaused
        nonReentrant
    {
        UserLockedWinnings storage userEpochWinnings = userLockedWinnings[msg.sender][_epoch];

        // Winnings that haven't yet been claimed
        uint256 unclaimedWinnings = userEpochWinnings.winnings - userEpochWinnings.claimedWinnings;

        // Validate harvest amount
        require(_amount > 0 && _amount <= unclaimedWinnings, "Bad Harvest");

        // Harvest winnings by locking for everest in the expedition
        if (_lockForEverest) {
            everest.lockAndExtendLockDuration(
                _amount,
                everest.inflectionLockTime(),
                msg.sender
            );

        // Else check if epoch matured, harvest 100% if true, else harvest 50%, burn 25%, and send 25% to expedition contract to be distributed to EVEREST holders
        } else {
            bool epochMatured = hasEpochMatured(_epoch);
            if (panic || epochMatured) {
                IERC20(summit).safeTransfer(msg.sender, _amount);
            } else {
                IERC20(summit).safeTransfer(msg.sender, _amount / 2);
                IERC20(summit).safeTransfer(burnAdd, _amount / 4);
                IERC20(summit).safeTransfer(cartographer.expeditionTreasuryAdd(), _amount / 4);
            }
        }

        userEpochWinnings.claimedWinnings += _amount;

        if ((userEpochWinnings.winnings - userEpochWinnings.claimedWinnings) == 0) {
            userInteractingEpochs[msg.sender].remove(_epoch);
        }

        emit WinningsHarvested(msg.sender, _epoch, _amount, _lockForEverest);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.2;

import "./libs/ERC20Mintable.sol";
import "./PresetPausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract SummitToken is ERC20Mintable('SummitToken', 'SUMMIT'), ReentrancyGuard, PresetPausable, Initializable {
    using SafeERC20 for IERC20;

    IERC20 public oldSummit;
    uint256 constant swapRatio = 1000;
    address constant burnAdd = 0x000000000000000000000000000000000000dEaD;

    event SummitTokenSwap(address indexed user, uint256 oldSummitAmount, uint256 newSummitAmount);

    function initialize(address _oldSummit)
        public
        initializer onlyOwner
    {
        require(_oldSummit != address(0), "Missing Old Summit");
        oldSummit = IERC20(_oldSummit);
    }

    /// @dev Token swap from V1 token
    function tokenSwap(uint256 _amount)
        public whenNotPaused
        nonReentrant
    {
        require(address(oldSummit) != address(0), "Old SUMMIT not set");
        require(_amount <= oldSummit.balanceOf(msg.sender), "Not enough SUMMIT");
        
        oldSummit.safeTransferFrom(msg.sender, address(this), _amount);
        oldSummit.safeTransfer(burnAdd, _amount);

        uint256 newSummitAmount = _amount * swapRatio / 10000;
        _mint(msg.sender, newSummitAmount);

        emit SummitTokenSwap(msg.sender, _amount, newSummitAmount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.2;
import "./SummitToken.sol";
import "./CartographerOasis.sol";
import "./CartographerElevation.sol";
import "./EverestToken.sol";
import "./ElevationHelper.sol";
import "./SummitGlacier.sol";
import "./PresetPausable.sol";
import "./libs/SummitMath.sol";
import "./interfaces/ISubCart.sol";
import "./interfaces/IPassthrough.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";




/*
---------------------------------------------------------------------------------------------
--   S U M M I T . D E F I
---------------------------------------------------------------------------------------------


Summit is highly experimental.
It has been crafted to bring a new flavor to the defi world.
We hope you enjoy the Summit.defi experience.
If you find any bugs in these contracts, please claim the bounty (see docs)


Created with love by Architect and the Summit team





---------------------------------------------------------------------------------------------
--   S U M M I T   E C O S Y S T E M
---------------------------------------------------------------------------------------------


The Cartographer is the anchor of the summit ecosystem
The Cartographer is also the owner of the SUMMIT token


Features of the Summit Ecosystem
    - Cross pool compounding (Compound your winnings, even if they're not from the SUMMIT pool. Cross pool compounding vesting winnings locks them from withdrawl for the remainder of the round)
    - Standard Yield Farming (oasis farms mirror standard farms)

    - Yield Multiplying (yield is put into a pot, which allows winning of other user's yield reward)
    - Multiple elevations (2X elevation, 5X elevation, 10X elevation)
    - Shared token allocation (reward allocation is split by elevation multiplier and amount staked at elevation, to guarantee more rewards at higher elevation)
    - Reward vesting (No large dumps of SUMMIT token on wins)
    - Elevating (Deposit once, update strategy without paying tax)

    - Passthrough Strategy (to fund expeditions, on oasis and elevation farms)
    - Expedition (weekly drawings for summit holders to earn stablecoins and other high value tokens)

    - Random number generation immune to Block Withholding Attack through open source webserver
    - Stopwatch functionality through open source webserver
*/

contract Cartographer is Ownable, Initializable, ReentrancyGuard, PresetPausable {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;


    // ---------------------------------------
    // --   V A R I A B L E S
    // ---------------------------------------

    uint8 constant OASIS = 0;
    uint8 constant PLAINS = 1;
    uint8 constant MESA = 2;
    uint8 constant SUMMIT = 3;

    SummitToken public summit;
    bool public enabled = false;                                                // Whether the ecosystem has been enabled for earning

    uint256 public rolloverReward = 2e18;                                       // Amount of SUMMIT which will be rewarded for rolling over a round

    address public treasuryAdd;                                                 // Treasury address, see docs for spend breakdown
    address public expeditionTreasuryAdd;                                       // Expedition Treasury address, intermediate address to convert to stablecoins
    ElevationHelper public elevationHelper;
    address[4] public subCartographers;
    EverestToken public everest;
    SummitGlacier public summitGlacier;

    uint256 public summitPerSecond = 5e16;                                      // Amount of Summit minted per second to be distributed to users
    uint256 public treasurySummitBP = 200;                                      // Amount of Summit minted per second to the treasury

    uint16[4] public elevationPoolsCount;                                       // List of all pool identifiers (PIDs)

    mapping(address => address) public tokenPassthroughStrategy;                // Passthrough strategy of each stakable token

    uint256[4] public elevAlloc;                                                // Total allocation points of all pools at an elevation
    EnumerableSet.AddressSet tokensWithAlloc;                                   // List of tokens with an allocation set
    mapping(address => uint16) public tokenDepositFee;                          // Deposit fee for all farms of this token
    mapping(address => uint16) public tokenWithdrawalTax;                       // Tax for all farms of this token
    mapping(address => uint256) public tokenAlloc;                              // A tokens underlying allocation, which is modulated for each elevation

    mapping(address => mapping(uint8 => bool)) public poolExistence;            // Whether a pool exists for a token at an elevation
    mapping(address => mapping(uint8 => bool)) public tokenElevationIsEarning;  // If a token is earning SUMMIT at a specific elevation

    mapping(address => bool) public isNativeFarmToken;
    
    // First {taxDecayDuration} days from the last withdraw timestamp, no bonus builds. 7 days after that it builds by 1% each day
    // Any withdraw resets the bonus to 0% but starts building immediately, which sets the last withdraw timestamp to (current timestamp - {taxDecayDuration})
    mapping(address => mapping(address => uint256)) public tokenLastWithdrawTimestampForBonus; // Users' last withdraw timestamp for farm emission bonus
    uint256 public maxBonusBP = 700;

    mapping(address => mapping(address => uint256)) public tokenLastDepositTimestampForTax; // Users' last deposit timestamp for tax
    uint16 public baseMinimumWithdrawalTax = 100;
    uint256 public taxDecayDuration = 7 * 86400;
    uint256 constant public taxResetOnDepositBP = 500;



    // ---------------------------------------
    // --   E V E N T S
    // ---------------------------------------

    event SetTokenAllocation(address indexed token, uint256 alloc);
    event PoolCreated(address indexed token, uint8 elevation);
    event PoolUpdated(address indexed token, uint8 elevation, bool live);
    event Deposit(address indexed user, address indexed token, uint8 indexed elevation, uint256 amount);
    event ClaimElevation(address indexed user, uint8 indexed elevation, uint256 totalClaimed);
    event Rollover(address indexed user, uint256 elevation);
    event SwitchTotem(address indexed user, uint8 indexed elevation, uint8 totem);
    event Elevate(address indexed user, address indexed token, uint8 sourceElevation, uint8 targetElevation, uint256 amount);
    event EmergencyWithdraw(address indexed user, address indexed token, uint8 indexed elevation, uint256 amount);
    event Withdraw(address indexed user, address indexed token, uint8 indexed elevation, uint256 amount);
    event ElevateAndLockStakedSummit(address indexed user, uint8 indexed elevation, uint256 amount);
    event ClaimWinnings(address indexed user, uint256 amount);
    event SetExpeditionTreasuryAddress(address indexed user, address indexed newAddress);
    event SetTreasuryAddress(address indexed user, address indexed newAddress);
    event PassthroughStrategySet(address indexed token, address indexed passthroughStrategy);
    event PassthroughStrategyRetired(address indexed token, address indexed passthroughStrategy);

    event SetTokenDepositFee(address indexed _token, uint16 _feeBP);
    event SetTokenWithdrawTax(address indexed _token, uint16 _taxBP);
    event SetTaxDecayDuration(uint256 _taxDecayDuration);
    event SetBaseMinimumWithdrawalTax(uint16 _baseMinimumWithdrawalTax);
    event SetTokenIsNativeFarm(address indexed _token, bool _isNativeFarm);
    event SetMaxBonusBP(uint256 _maxBonusBP);
    event SummitOwnershipTransferred(address indexed _summitOwner);
    event SetRolloverRewardInNativeToken(uint256 _reward);
    event SetTotalSummitPerSecond(uint256 _amount);
    event SetSummitDistributionBPs(uint256 _treasuryBP);






    // ---------------------------------------
    // --  A D M I N I S T R A T I O N
    // ---------------------------------------


    /// @dev Constructor simply setting addresses on creation
    constructor(
        address _treasuryAdd,
        address _expeditionTreasuryAdd
    ) {
        require(_treasuryAdd != address(0), "Missing Treasury");
        require(_expeditionTreasuryAdd != address(0), "Missing Exped Treasury");
        treasuryAdd = _treasuryAdd;
        expeditionTreasuryAdd = _expeditionTreasuryAdd;
    }

    /// @dev Initialize, simply setting addresses, these contracts need the Cartographer address so it must be separate from the constructor
    function initialize(
        address _summit,
        address _ElevationHelper,
        address _CartographerOasis,
        address _CartographerPlains,
        address _CartographerMesa,
        address _CartographerSummit,
        address _everest,
        address _summitGlacier
    )
        external
        initializer onlyOwner
    {
        require(
            _summit != address(0) &&
            _ElevationHelper != address(0) &&
            _CartographerOasis != address(0) &&
            _CartographerPlains != address(0) &&
            _CartographerMesa != address(0) &&
            _CartographerSummit != address(0) &&
            _everest != address(0) &&
            _summitGlacier != address(0),
            "Contract is zero"
        );

        summit = SummitToken(_summit);

        elevationHelper = ElevationHelper(_ElevationHelper);

        subCartographers[OASIS] = _CartographerOasis;
        subCartographers[PLAINS] = _CartographerPlains;
        subCartographers[MESA] = _CartographerMesa;
        subCartographers[SUMMIT] = _CartographerSummit;

        everest = EverestToken(_everest);
        summit.approve(_everest, type(uint256).max);
        summitGlacier = SummitGlacier(_summitGlacier);

        // Initialize the subCarts with the address of elevationHelper
        for (uint8 elevation = OASIS; elevation <= SUMMIT; elevation++) {
            _subCartographer(elevation).initialize(_ElevationHelper, address(_summit));
        }
    }


    /// @dev Enabling the summit ecosystem with the true summit token, turning on farming
    function enable() external onlyOwner {
        // Prevent multiple instances of enabling
        require(!enabled, "Already enabled");
        enabled = true;

        // Setting and propagating the true summit address and launch timestamp
        elevationHelper.enable(block.timestamp);
        _subCartographer(OASIS).enable(block.timestamp);
    }

    /// @dev Transferring Summit Ownership - Huge timelock
    function migrateSummitOwnership(address _summitOwner)
        public
        onlyOwner
    {
        require(_summitOwner != address(0), "Missing Summit Owner");
        summit.transferOwnership(_summitOwner);
        emit SummitOwnershipTransferred(_summitOwner);
    }


    /// @dev Updating the dev address, can only be called by the current dev address
    /// @param _treasuryAdd New dev address
    function setTreasuryAdd(address _treasuryAdd) public {
        require(_treasuryAdd != address(0), "Missing address");
        require(msg.sender == treasuryAdd, "Forbidden");

        treasuryAdd = _treasuryAdd;
        emit SetTreasuryAddress(msg.sender, _treasuryAdd);
    }


    /// @dev Updating the expedition accumulator address
    /// @param _expeditionTreasuryAdd New expedition accumulator address
    function setExpeditionTreasuryAdd(address _expeditionTreasuryAdd) public onlyOwner {
        require(_expeditionTreasuryAdd != address(0), "Missing address");
        expeditionTreasuryAdd = _expeditionTreasuryAdd;
        emit SetExpeditionTreasuryAddress(msg.sender, _expeditionTreasuryAdd);
    }

    /// @dev Update the amount of native token equivalent to reward for rolling over a round
    function setRolloverRewardInNativeToken(uint256 _reward) public onlyOwner {
        require(_reward < 10e18, "Exceeds max reward");
        rolloverReward = _reward;
        emit SetRolloverRewardInNativeToken(_reward);
    }

    /// @dev Updating the total emission of the ecosystem
    /// @param _amount New total emission
    function setTotalSummitPerSecond(uint256 _amount) public onlyOwner {
        // Must be less than 1 SUMMIT per second
        require(_amount < 1e18, "Invalid emission");
        summitPerSecond = _amount;
        emit SetTotalSummitPerSecond(_amount);
    }

    /// @dev Updating the emission split profile
    /// @param _treasuryBP How much extra is minted for the treasury
    function setSummitDistributionBPs(uint256 _treasuryBP) public onlyOwner {
        // Require dev emission less than 25% of total emission
        require(_treasuryBP <= 250, "Invalid Distributions");
        treasurySummitBP = _treasuryBP;
        emit SetSummitDistributionBPs(_treasuryBP);
    }






    // -----------------------------------------------------------------
    // --   M O D I F I E R S (Many are split to save contract size)
    // -----------------------------------------------------------------

    function _onlySubCartographer(address _isSubCartographer) internal view {
        require(
            _isSubCartographer == subCartographers[OASIS] ||
            _isSubCartographer == subCartographers[PLAINS] ||
            _isSubCartographer == subCartographers[MESA] ||
            _isSubCartographer == subCartographers[SUMMIT],
            "Only subCarts"
        );
    }
    modifier onlySubCartographer() {
        _onlySubCartographer(msg.sender);
        _;
    }

    
    modifier nonDuplicated(address _token, uint8 _elevation) {
        require(!poolExistence[_token][_elevation], "Duplicated");
        _;
    }

    modifier nonDuplicatedTokenAlloc(address _token) {
        require(!tokensWithAlloc.contains(_token), "Duplicated token alloc");
        _;
    }
    modifier tokenAllocExists(address _token) {
        require(tokensWithAlloc.contains(_token), "Invalid token alloc");
        _;
    }
    modifier validAllocation(uint256 _allocation) {
        require(_allocation <= 10000, "Allocation must be <= 100X");
        _;
    }

    function _poolExists(address _token, uint8 _elevation) internal view {
        require(poolExistence[_token][_elevation], "Pool doesnt exist");

    }
    modifier poolExists(address _token, uint8 _elevation) {
        _poolExists(_token, _elevation);
        _;
    }

    // Elevation validation with min and max elevations (inclusive)
    function _validElev(uint8 _elevation, uint8 _minElev, uint8 _maxElev) internal pure {
        require(_elevation >= _minElev && _elevation <= _maxElev, "Invalid elev");
    }
    modifier isOasisOrElevation(uint8 _elevation) {
        _validElev(_elevation, OASIS, SUMMIT);
        _;
    }
    modifier isElevation(uint8 _elevation) {
        _validElev(_elevation, PLAINS, SUMMIT);
        _;
    }

    // Totem
    modifier validTotem(uint8 _elevation, uint8 _totem)  {
        require(_totem < elevationHelper.totemCount(_elevation), "Invalid totem");
        _;
    }





    // ---------------------------------------------------------------
    // --   S U B   C A R T O G R A P H E R   S E L E C T O R
    // ---------------------------------------------------------------

    function _subCartographer(uint8 _elevation) internal view returns (ISubCart) {
        require(_elevation >= OASIS && _elevation <= SUMMIT, "Invalid elev");
        return ISubCart(subCartographers[_elevation]);
    }





    // ---------------------------------------
    // --   T O K E N   A L L O C A T I O N
    // ---------------------------------------


    /// @dev Number of existing pools
    function poolsCount()
        public view
        returns (uint256)
    {
        uint256 count = 0;
        for (uint8 elevation = OASIS; elevation <= SUMMIT; elevation++) {
            count += elevationPoolsCount[elevation];
        }
        return count;
    }


    /// @dev List of tokens with a set allocation
    function tokensWithAllocation()
        public view
        returns (address[] memory)
    {
        return tokensWithAlloc.values();
    }


    /// @dev Create / Update the allocation for a token. This modifies existing allocations at each elevation for that token
    /// @param _token Token to update allocation for
    /// @param _allocation Updated allocation
    function setTokenAllocation(address _token, uint256 _allocation)
        public
        onlyOwner validAllocation(_allocation)
    {
        // Token is marked as having an existing allocation
        tokensWithAlloc.add(_token);

        // Update the tokens allocation at the elevations that token is active at
        for (uint8 elevation = OASIS; elevation <= SUMMIT; elevation++) {
            if (tokenElevationIsEarning[_token][elevation]) {
                elevAlloc[elevation] = elevAlloc[elevation] + _allocation - tokenAlloc[_token];
            }
        }

        // Update the token allocation
        tokenAlloc[_token] = _allocation;

        emit SetTokenAllocation(_token, _allocation);
    }


    /// @dev Register pool at elevation as live, add to shared alloc
    /// @param _token Token of the pool
    /// @param _elevation Elevation of the pool
    /// @param _isEarning Whether token is earning SUMMIT at elevation
    function setIsTokenEarningAtElevation(address _token, uint8 _elevation, bool _isEarning)
        external
        onlySubCartographer
    {
        // Early escape if token earning is already up to date
        if (tokenElevationIsEarning[_token][_elevation] == _isEarning) return;

        // Add the new allocation to the token's shared allocation and total allocation
        if (_isEarning) {
            elevAlloc[_elevation] += tokenAlloc[_token];

        // Remove the existing allocation to the token's shared allocation and total allocation
        } else {
            elevAlloc[_elevation] -= tokenAlloc[_token];
        }

        // Mark the token-elevation earning
        tokenElevationIsEarning[_token][_elevation] = _isEarning;
    }


    /// @dev Sets the passthrough strategy for a given token
    /// @param _token Token passthrough strategy applies to
    /// @param _passthroughStrategy Address of the new passthrough strategy
    function setTokenPassthroughStrategy(address _token, address _passthroughStrategy)
        public
        onlyOwner
    {
        // Validate that the strategy exists and tokens match
        require(_passthroughStrategy != address(0), "Passthrough strategy missing");
        require(address(IPassthrough(_passthroughStrategy).token()) == _token, "Token doesnt match passthrough strategy");

        _enactTokenPassthroughStrategy(_token, _passthroughStrategy);
    }


    /// @dev Retire passthrough strategy and return tokens to this contract
    /// @param _token Token whose passthrough strategy to remove
    function retireTokenPassthroughStrategy(address _token)
        public
        onlyOwner
    {
        require(tokenPassthroughStrategy[_token] != address(0), "No passthrough strategy to retire");
        address retiredTokenPassthroughStrategy = tokenPassthroughStrategy[_token];
        _retireTokenPassthroughStrategy(_token);

        emit PassthroughStrategyRetired(address(_token), retiredTokenPassthroughStrategy);
    }


    function _enactTokenPassthroughStrategy(address _token, address _passthroughStrategy)
        internal
    {
        // If strategy already exists for this pool, retire from it
        _retireTokenPassthroughStrategy(_token);

        // Deposit funds into new passthrough strategy
        IPassthrough(_passthroughStrategy).token().approve(_passthroughStrategy, type(uint256).max);
        IPassthrough(_passthroughStrategy).enact();

        // Set token passthrough strategy in state
        tokenPassthroughStrategy[_token] = _passthroughStrategy;

        emit PassthroughStrategySet(address(_token), _passthroughStrategy);
    }


    /// @dev Internal functionality of retiring a passthrough strategy
    function _retireTokenPassthroughStrategy(address _token) internal {
        // Early exit if token doesn't have passthrough strategy
        if(tokenPassthroughStrategy[_token] == address(0)) return;

        IPassthrough(tokenPassthroughStrategy[_token]).retire(expeditionTreasuryAdd, treasuryAdd);
        tokenPassthroughStrategy[_token] = address(0);
    }





    // ---------------------------------------
    // --   P O O L   M A N A G E M E N T
    // ---------------------------------------


    /// @dev Creates a new pool for a token at a specific elevation
    /// @param _token Token to create the pool for
    /// @param _elevation The elevation to create this pool at
    /// @param _live Whether the pool is available for staking (independent of rounds / elevation constraints)
    /// @param _withUpdate Whether to update all pools during this transaction
    function add(address _token, uint8 _elevation, bool _live, bool _withUpdate)
        public
        onlyOwner tokenAllocExists(_token) isOasisOrElevation(_elevation) nonDuplicated(_token, _elevation)
    {

        // Mass update if required
        if (_withUpdate) {
            massUpdatePools();
        }

        // Get the next available pool identifier and register pool
        poolExistence[_token][_elevation] = true;
        elevationPoolsCount[_elevation] += 1;

        // Create the pool in the appropriate sub cartographer
        _subCartographer(_elevation).add(_token, _live);

        emit PoolCreated(_token, _elevation);
    }


    /// @dev Update pool's live status and deposit tax
    /// @param _token Pool identifier
    /// @param _elevation Elevation of pool
    /// @param _live Whether staking is permitted on this pool
    /// @param _withUpdate whether to update all pools as part of this transaction
    function set(address _token, uint8 _elevation, bool _live, bool _withUpdate)
        public
        onlyOwner isOasisOrElevation(_elevation) poolExists(_token, _elevation)
    {
        // Mass update if required
        if (_withUpdate) {
            massUpdatePools();
        }

        // Updates the pool in the correct subcartographer
        _subCartographer(_elevation).set(_token, _live);

        emit PoolUpdated(_token, _elevation, _live);
    }


    /// @dev Does what it says on the box
    function massUpdatePools() public {
        for (uint8 elevation = OASIS; elevation <= SUMMIT; elevation++) {
            _subCartographer(elevation).massUpdatePools();
        }
    }





    // ------------------------------------------------------------------
    // --   R O L L O V E R   E L E V A T I O N   R O U N D
    // ------------------------------------------------------------------



    /// @dev Rolling over a round for an elevation and selecting winning totem.
    ///      Called by the webservice, but can also be called manually by any user (as failsafe)
    /// @param _elevation Elevation to rollover
    function rollover(uint8 _elevation)
        public whenNotPaused
        nonReentrant isElevation(_elevation)
    {
        // Ensure that the elevation is ready to be rolled over, ensures only a single user can perform the rollover
        elevationHelper.validateRolloverAvailable(_elevation);

        // Selects the winning totem for the round, storing it in the elevationHelper contract
        elevationHelper.selectWinningTotem(_elevation);

        // Update the round index in the elevationHelper, effectively starting the next round of play
        elevationHelper.rolloverElevation(_elevation);

        // Rollover active pools at the elevation
        _subCartographer(_elevation).rollover();

        // Give SUMMIT rewards to user that executed the rollover
        summit.mint(msg.sender, rolloverReward);

        emit Rollover(msg.sender, _elevation);
    }





    // -----------------------------------------------------
    // --   S U M M I T   E M I S S I O N
    // -----------------------------------------------------
    

    /// @dev Returns the modulated allocation of a token at elevation, escaping early if the pool is not live
    /// @param _token Tokens allocation
    /// @param _elevation Elevation to modulate
    /// @return True allocation of the pool at elevation
    function elevationModulatedAllocation(address _token, uint8 _elevation) public view returns (uint256) {
        // Escape early if the pool is not currently earning SUMMIT
        if (!tokenElevationIsEarning[_token][_elevation]) return 0;

        // Fetch the modulated base allocation for the token at elevation
        return elevationHelper.elevationModulatedAllocation(tokenAlloc[_token], _elevation);
    }


    /// @dev Shares of a token at elevation
    /// (@param _token, @param _elevation) Together identify the pool to calculate
    function _tokenElevationShares(address _token, uint8 _elevation) internal view returns (uint256) {
        // Escape early if the pool doesn't exist or is not currently earning SUMMIT
        if (!poolExistence[_token][_elevation] || !tokenElevationIsEarning[_token][_elevation]) return 0;

        return (
            _subCartographer(_elevation).supply(_token) *
            elevationModulatedAllocation(_token, _elevation)
        );
    }

    /// @dev The share of the total token at elevation emission awarded to the pool
    ///      Tokens share allocation to ensure that staking at higher elevation ALWAYS has higher APY
    ///      This is done to guarantee a higher ROI at higher elevations over a long enough time span
    ///      The allocation of each pool is based on the elevation, as well as the staked supply at that elevation
    /// @param _token The token (+ elevation) to evaluate emission for
    /// @param _elevation The elevation (+ token) to evaluate emission for
    /// @return The share of emission granted to the pool, raised to 1e12
    function tokenElevationEmissionMultiplier(address _token, uint8 _elevation)
        public view
        returns (uint256)
    {
        // Shares for all elevation are summed. For each elevation the shares are calculated by:
        //   . The staked supply of the pool at elevation multiplied by
        //   . The modulated allocation of the pool at elevation
        uint256 totalTokenShares = (
            _tokenElevationShares(_token, OASIS) +
            _tokenElevationShares(_token, PLAINS) +
            _tokenElevationShares(_token, MESA) +
            _tokenElevationShares(_token, SUMMIT)
        );

        // Escape early if nothing is staked in any of the token's pools
        if (totalTokenShares == 0) return 0;

        // Divide the target pool (token + elevation) shares by total shares (as calculated above)
        return _tokenElevationShares(_token, _elevation) * 1e12 / totalTokenShares;
    }


    /// @dev Emission multiplier of token based on its allocation
    /// @return Multiplier raised 1e12
    function tokenAllocEmissionMultiplier(address _token)
        public view
        returns (uint256)
    {
        // Sum allocation of all elevations with allocation multipliers
        uint256 tokenTotalAlloc = 0;
        uint256 totalAlloc = 0;
        for (uint8 elevation = OASIS; elevation <= SUMMIT; elevation++) {
            if (tokenElevationIsEarning[_token][elevation]) {
                tokenTotalAlloc += tokenAlloc[_token] * elevationHelper.elevationAllocMultiplier(elevation);
            }
            totalAlloc += elevAlloc[elevation] * elevationHelper.elevationAllocMultiplier(elevation);
        }

        if (totalAlloc == 0) return 0;

        return tokenTotalAlloc * 1e12 / totalAlloc;
    }


    /// @dev Uses the tokenElevationEmissionMultiplier along with timeDiff and token allocation to calculate the overall emission multiplier of the pool
    /// @param _lastRewardTimestamp Calculate the difference to determine emission event count
    /// (@param _token, @param elevation) Pool identifier for calculation
    /// @return Share of overall emission granted to the pool, raised to 1e12
    function _poolEmissionMultiplier(uint256 _lastRewardTimestamp, address _token, uint8 _elevation)
        internal view
        returns (uint256)
    {
        // Calculate overall emission granted over time span, calculated by:
        //   . Time difference from last reward timestamp
        //   . Tokens allocation as a fraction of total allocation
        //   . Pool's emission multiplier
        return (block.timestamp - _lastRewardTimestamp) * tokenAllocEmissionMultiplier(_token) * tokenElevationEmissionMultiplier(_token, _elevation) / 1e12;
    }


    /// @dev Uses _poolEmissionMultiplier along with staking summit emission to calculate the pools summit emission over the time span
    /// @param _lastRewardTimestamp Used for time span
    /// (@param _token, @param _elevation) Pool identifier
    /// @return emission of SUMMIT, not raised to any power
    function poolSummitEmission(uint256 _lastRewardTimestamp, address _token, uint8 _elevation)
        external view
        onlySubCartographer
        returns (uint256)
    {
        // Escape early if no time has passed
        if (block.timestamp <= _lastRewardTimestamp) { return 0; }

        // Emission multiplier multiplied by summitPerSecond, finally reducing back to true exponential
        return _poolEmissionMultiplier(_lastRewardTimestamp, _token, _elevation) * summitPerSecond / 1e12;
    }





    // -----------------------------------------------------
    // --   S W I T C H   T O T E M
    // -----------------------------------------------------


    /// @dev All funds at an elevation share a totem. This function allows switching staked funds from one totem to another
    /// @param _elevation Elevation to switch totem on
    /// @param _totem New target totem
    function switchTotem(uint8 _elevation, uint8 _totem)
        public whenNotPaused
        nonReentrant isElevation(_elevation) validTotem(_elevation, _totem)
    {
        // Executes the totem switch in the correct subcartographer
        _subCartographer(_elevation).switchTotem(_totem, msg.sender);

        emit SwitchTotem(msg.sender, _elevation, _totem);
    }





    // -----------------------------------------------------
    // --   P O O L   I N T E R A C T I O N S
    // -----------------------------------------------------


    /// @dev Get the user's tax for a token
    /// @param _userAdd user address
    /// @param _token token address
    function taxBP(address _userAdd, address _token)
        public view
        returns (uint16)
    {
        return _getTaxBP(_userAdd, _token);
    }
    function _getTaxBP(address _userAdd, address _token)
        public view
        returns (uint16)
    {
        uint256 lastDepositTimestampForTax = tokenLastDepositTimestampForTax[_userAdd][_token];

        uint256 tokenTax = uint256(tokenWithdrawalTax[_token]);
        uint256 tokenMinTax = isNativeFarmToken[_token] ? 0 : baseMinimumWithdrawalTax;

        // Early exit if min tax is greater than tax of this token
        if (tokenMinTax >= tokenTax) return uint16(tokenMinTax);

        return uint16(SummitMath.scaledValue(
            block.timestamp,
            lastDepositTimestampForTax, lastDepositTimestampForTax + taxDecayDuration,
            tokenTax, tokenMinTax
        ));
    }


    /// @dev Get bonus BP
    /// @param _userAdd user address
    /// @param _token token address
    function bonusBP(address _userAdd, address _token)
        public view
        returns (uint16)
    {
        return _getBonusBP(_userAdd, _token);
    }
    function _getBonusBP(address _userAdd, address _token)
        public view
        returns (uint16)
    {
        uint256 lastWithdrawTimestamp = tokenLastWithdrawTimestampForBonus[_userAdd][_token];

        // Early exit if last Withdraw Timestamp hasn't ever been ste
        if (lastWithdrawTimestamp == 0) return 0;

        return uint16(SummitMath.scaledValue(
            block.timestamp,
            lastWithdrawTimestamp + taxDecayDuration, lastWithdrawTimestamp + (taxDecayDuration * 2),
            0, maxBonusBP
        ));
    }


    /// @dev Users staked amount across all elevations
    /// @param _token Token to determine user's staked amount of
    function userTokenStakedAmount(address _userAdd, address _token)
        public view
        returns (uint256)
    {
        return _userTokenStakedAmount(_token, _userAdd);
    }

    function _userTokenStakedAmount(address _token, address _userAdd)
        internal view
        returns (uint256)
    {
        uint256 totalStaked = 0;
        for (uint8 elevation = OASIS; elevation <= SUMMIT; elevation++) {
            totalStaked += _subCartographer(elevation).userStakedAmount(_token, _userAdd);
        }
        return totalStaked;
    }


    /// @dev Stake funds with a pool, is also used to claim a single farm with a deposit amount of 0
    /// (@param _token, @param _elevation) Pool identifier
    /// @param _amount Amount to stake
    function deposit(address _token, uint8 _elevation, uint256 _amount)
        public whenNotPaused
        nonReentrant poolExists(_token, _elevation)
    {
        // Executes the deposit in the sub cartographer
        uint256 amountAfterTax = _subCartographer(_elevation)
            .deposit(
                _token,
                _amount,
                msg.sender,
                false
            );

        // Set initial value of token last withdraw timestamp (for bonus) if it hasn't already been set
        if (tokenLastWithdrawTimestampForBonus[msg.sender][_token] == 0) {
            tokenLastWithdrawTimestampForBonus[msg.sender][_token] = block.timestamp;
        }

        // Reset tax timestamp if user is depositing greater than {taxResetOnDepositBP}% of current staked amount
        if (_amount > (_userTokenStakedAmount(_token, msg.sender) * taxResetOnDepositBP / 10000)) {
            tokenLastDepositTimestampForTax[msg.sender][_token] = block.timestamp;
        }

        emit Deposit(msg.sender, _token, _elevation, amountAfterTax);
    }


    /// @dev Claim all rewards (or cross compound) of an elevation
    /// @param _elevation Elevation to claim all rewards from
    function claimElevation(uint8 _elevation)
        public whenNotPaused
        nonReentrant isOasisOrElevation(_elevation)
    {
        // Harvest across an elevation, return total amount claimed
        uint256 totalClaimed = _subCartographer(_elevation).claimElevation(msg.sender);
        
        emit ClaimElevation(msg.sender, _elevation, totalClaimed);
    }


    /// @dev Withdraw staked funds from a pool
    /// (@param _token, @param _elevation) Pool identifier
    function emergencyWithdraw(address _token, uint8 _elevation)
        public
        nonReentrant poolExists(_token, _elevation)
    {
        // Executes the withdrawal in the sub cartographer
        uint256 amountAfterTax = _subCartographer(_elevation)
            .emergencyWithdraw(
                _token,
                msg.sender
            );

        // Farm bonus handling, sets the last withdraw timestamp to 7 days ago (tax decay duration) to begin earning bonuses immediately
        // Update to the max of (current last withdraw timestamp, current timestamp - 7 days), which ensures the first 7 days are never building bonus
        tokenLastWithdrawTimestampForBonus[msg.sender][_token] = Math.max(
            tokenLastWithdrawTimestampForBonus[msg.sender][_token],
            block.timestamp - taxDecayDuration
        );

        emit EmergencyWithdraw(msg.sender, _token, _elevation, amountAfterTax);
    }


    /// @dev Withdraw staked funds from a pool
    /// (@param _token, @param _elevation) Pool identifier
    /// @param _amount Amount to withdraw, must be > 0 and <= staked amount
    function withdraw(address _token, uint8 _elevation, uint256 _amount)
        public whenNotPaused
        nonReentrant poolExists(_token, _elevation)
    {
        // Executes the withdrawal in the sub cartographer
        uint256 amountAfterTax = _subCartographer(_elevation)
            .withdraw(
                _token,
                _amount,
                msg.sender,
                false
            );

        // Farm bonus handling, sets the last withdraw timestamp to 7 days ago (tax decay duration) to begin earning bonuses immediately
        // Update to the max of (current last withdraw timestamp, current timestamp - 7 days), which ensures the first 7 days are never building bonus
        tokenLastWithdrawTimestampForBonus[msg.sender][_token] = Math.max(
            tokenLastWithdrawTimestampForBonus[msg.sender][_token],
            block.timestamp - taxDecayDuration
        );

        emit Withdraw(msg.sender, _token, _elevation, amountAfterTax);
    }


    /// @dev Elevate SUMMIT from the Elevation farms to the Expedition without paying any withdrawal tax
    /// @param _elevation Elevation to elevate from
    /// @param _amount Amount of SUMMIT to elevate
    function elevateAndLockStakedSummit(uint8 _elevation, uint256 _amount)
        public whenNotPaused
        nonReentrant poolExists(address(summit), _elevation)
    {
        require(_amount > 0, "Elevate non zero amount");

        // Withdraw {_amount} of {_token} from {_elevation} pool
        uint256 elevatedAmount = _subCartographer(_elevation)
            .withdraw(
                address(summit),
                _amount,
                msg.sender,
                true
            );

        // Lock withdrawn SUMMIT for EVEREST
        everest.lockAndExtendLockDuration(
            elevatedAmount,
            everest.minLockTime(),
            msg.sender
        );

        emit ElevateAndLockStakedSummit(msg.sender, _elevation, _amount);
    }


    /// @dev Validation step of Elevate into separate function
    /// @param _token Token to elevate
    /// @param _sourceElevation Elevation to withdraw from
    /// @param _targetElevation Elevation to deposit into
    /// @param _amount Amount to elevate
    function _validateElevate(address _token, uint8 _sourceElevation, uint8 _targetElevation, uint256 _amount)
        internal view
        poolExists(_token, _sourceElevation) poolExists(_token, _targetElevation)
    {
        require(_amount > 0, "Transfer non zero amount");
        require(_sourceElevation != _targetElevation, "Must change elev");
        require(
            _subCartographer(_sourceElevation).isTotemSelected(msg.sender) &&
            _subCartographer(_targetElevation).isTotemSelected(msg.sender),
            "Totem not selected"
        );
    }


    /// @dev Allows funds to be transferred between elevations without forcing users to pay a deposit tax
    /// @param _token Token to elevate
    /// @param _sourceElevation Elevation to withdraw from
    /// @param _targetElevation Elevation to deposit into
    /// @param _amount Amount to elevate
    function elevate(address _token, uint8 _sourceElevation, uint8 _targetElevation, uint256 _amount)
        public whenNotPaused
        nonReentrant
    {
        _validateElevate(_token, _sourceElevation, _targetElevation, _amount);

        // Withdraw {_amount} of {_token} from {_sourceElevation} pool
        uint256 elevatedAmount = _subCartographer(_sourceElevation)
            .withdraw(
                _token,
                _amount,
                msg.sender,
                true
            );
        
        // Deposit withdrawn amount of {_token} from source pool {elevatedAmount} into {_targetPid} pool
        elevatedAmount = _subCartographer(_targetElevation)
            .deposit(
                _token,
                elevatedAmount,
                msg.sender,
                true
            );

        emit Elevate(msg.sender, _token, _sourceElevation, _targetElevation, elevatedAmount);
    }





    // -----------------------------------------------------
    // --   Y I E L D   L O C K I N G
    // -----------------------------------------------------


    /// @dev Utility function to handle claiming Summit rewards with bonuses
    /// @return Claimed amount with bonuses included
    function claimWinnings(address _userAdd, address _token, uint256 _amount)
        external whenNotPaused
        onlySubCartographer
        returns (uint256)
    {
        uint256 tokenBonusBP = _getBonusBP(_userAdd, _token);
        uint256 bonusWinnings = _amount * tokenBonusBP / 10000;
        uint256 totalWinnings = _amount + bonusWinnings;

        // Mint Summit user has won, and additional mints for distribution
        summit.mint(address(summitGlacier), totalWinnings);
        summit.mint(treasuryAdd, totalWinnings * treasurySummitBP / 10000);

        // Send users claimable winnings to SummitGlacier.sol
        summitGlacier.addLockedWinnings(totalWinnings, bonusWinnings, _userAdd);

        emit ClaimWinnings(_userAdd, totalWinnings);

        return totalWinnings;
    }



    // -----------------------------------------------------
    // --   T O K E N   M A N A G E M E N T
    // -----------------------------------------------------

    /// @dev Utility function for depositing tokens into passthrough strategy
    function _passthroughDeposit(address _token, uint256 _amount) internal returns (uint256) {
        if (tokenPassthroughStrategy[_token] == address(0)) return _amount;
        return IPassthrough(tokenPassthroughStrategy[_token]).deposit(_amount, expeditionTreasuryAdd, treasuryAdd);
    }

    /// @dev Utility function for withdrawing tokens from passthrough strategy
    /// @param _token Token to withdraw from it's passthrough strategy
    /// @param _amount Amount requested to withdraw
    /// @return The true amount withdrawn from the passthrough strategy after the passthrough's tax was taken (if any)
    function _passthroughWithdraw(address _token, uint256 _amount) internal returns (uint256) {
        if (tokenPassthroughStrategy[_token] == address(0)) return _amount;
        return IPassthrough(tokenPassthroughStrategy[_token]).withdraw(_amount, expeditionTreasuryAdd, treasuryAdd);
    }


    /// @dev Transfers funds from user on deposit
    /// @param _userAdd Depositing user
    /// @param _token Token to deposit
    /// @param _amount Deposit amount before tax
    /// @return Deposit amount
    function depositTokenManagement(address _userAdd, address _token, uint256 _amount)
        external whenNotPaused
        onlySubCartographer
        returns (uint256)
    {
        // Transfers total deposit amount
        IERC20(_token).safeTransferFrom(_userAdd, address(this), _amount);

        // Take and distribute deposit fee
        uint256 amountAfterFee = _amount;
        if (tokenDepositFee[_token] > 0) {
            amountAfterFee = _amount * (10000 - tokenDepositFee[_token]) / 10000;
            _distributeTaxesAndFees(_token, _amount * tokenDepositFee[_token] / 10000);
        }

        // Deposit full amount to passthrough, return amount deposited
        return _passthroughDeposit(_token, amountAfterFee);
    }


    /// @dev Takes the remaining withdrawal tax (difference between total withdrawn amount and the amount expected to be withdrawn after the remaining tax)
    /// @param _token Token to withdraw
    /// @param _amount Funds above the amount after remaining withdrawal tax that was returned from the passthrough strategy
    function _distributeTaxesAndFees(address _token, uint256 _amount)
        internal
    {
        IERC20(_token).safeTransfer(treasuryAdd, _amount / 2);
        IERC20(_token).safeTransfer(expeditionTreasuryAdd, _amount / 2);
    }

    /// @dev Transfers funds to user on withdraw
    /// @param _userAdd Withdrawing user
    /// @param _token Token to withdraw
    /// @param _amount Withdraw amount
    /// @return Amount withdrawn after tax
    function withdrawalTokenManagement(address _userAdd, address _token, uint256 _amount)
        external
        onlySubCartographer
        returns (uint256)
    {
        // Withdraw full amount from passthrough (if any), if there is a tax that isn't covered by the increase in vault value this may be less than expected full amount
        uint256 amountAfterTax = _passthroughWithdraw(_token, _amount);

        // Amount user expects to receive after tax taken
        uint256 expectedWithdrawnAmount = (_amount * (10000 - _getTaxBP(_userAdd, _token))) / 10000;

        // Take any remaining tax (gap between what was actually withdrawn, and what the user expects to receive)
        if (amountAfterTax > expectedWithdrawnAmount) {
            _distributeTaxesAndFees(_token, amountAfterTax - expectedWithdrawnAmount);
            amountAfterTax = expectedWithdrawnAmount;
        }

        // Transfer funds back to user
        IERC20(_token).safeTransfer(_userAdd, amountAfterTax);

        return amountAfterTax;
    }
    
    
    
    
    
    
    // ---------------------------------------
    // --   W I T H D R A W A L   T A X
    // ---------------------------------------


    /// @dev Set the tax for a token
    function setTokenDepositFee(address _token, uint16 _feeBP)
        public
        onlyOwner
    {
        // Deposit fee will never be higher than 4%
        require(_feeBP <= 400, "Invalid fee > 4%");
        tokenDepositFee[_token] = _feeBP;
        emit SetTokenDepositFee(_token, _feeBP);
    }


    /// @dev Set the tax for a token
    function setTokenWithdrawTax(address _token, uint16 _taxBP)
        public
        onlyOwner
    {
        // Taxes will never be higher than 10%
        require(_taxBP <= 1000, "Invalid tax > 10%");
        tokenWithdrawalTax[_token] = _taxBP;
        emit SetTokenWithdrawTax(_token, _taxBP);
    }

    /// @dev Set the tax decaying duration
    function setTaxDecayDuration(uint256 _taxDecayDuration)
        public
        onlyOwner
    {
        require(_taxDecayDuration <= 14 days, "Invalid duration > 14d");
        taxDecayDuration = _taxDecayDuration;
        emit SetTaxDecayDuration(_taxDecayDuration);
    }

    /// @dev Set the minimum withdrawal tax
    function setBaseMinimumWithdrawalTax(uint16 _baseMinimumWithdrawalTax)
        public
        onlyOwner
    {
        require(_baseMinimumWithdrawalTax <= 1000, "Minimum tax outside 0%-10%");
        baseMinimumWithdrawalTax = _baseMinimumWithdrawalTax;
        emit SetBaseMinimumWithdrawalTax(_baseMinimumWithdrawalTax);
    }

    /// @dev Set whether a token is a native farm
    function setTokenIsNativeFarm(address _token, bool _isNativeFarm)
        public
        onlyOwner
    {
        isNativeFarmToken[_token] = _isNativeFarm;
        emit SetTokenIsNativeFarm(_token, _isNativeFarm);
    }

    /// @dev Set the maximum bonus BP for native farms
    function setMaxBonusBP(uint256 _maxBonusBP)
        public
        onlyOwner
    {
        require(_maxBonusBP <= 1000, "Max bonus is 10%");
        maxBonusBP = _maxBonusBP;
        emit SetMaxBonusBP(_maxBonusBP);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.2;

import "./ElevationHelper.sol";
import "./SummitToken.sol";
import "./EverestToken.sol";
import "./PresetPausable.sol";
import "./interfaces/ISubCart.sol";
import "./SummitGlacier.sol";
import "./BaseEverestExtension.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/*
---------------------------------------------------------------------------------------------
--   S U M M I T . D E F I
---------------------------------------------------------------------------------------------


Summit is highly experimental.
It has been crafted to bring a new flavor to the defi world.
We hope you enjoy the Summit.defi experience.
If you find any bugs in these contracts, please claim the bounty on immunefi.com


Created with love by Architect and the Summit team





---------------------------------------------------------------------------------------------
--   E X P E D I T I O N   E X P L A N A T I O N
---------------------------------------------------------------------------------------------


Expeditions offer a reward for holders of Summit.
Stake SUMMIT or SUMMIT LP (see MULTI-STAKING) in an expedition for a chance to win stablecoins and other high value tokens.
Expedition pots build during the week from passthrough staking usdc and deposit fees

Deposits open 24 hours before a round closes, at which point deposits are locked, and the winner chosen
After each round, the next round begins immediately (if the expedition hasn't ended)

Expeditions take place on the weekends, and each have 3 rounds (FRI / SAT / SUN)
Two DEITIES decide the fate of each round:


DEITIES (COSMIC BULL vs COSMIC BEAR):
    . Each round has a different chance of succeeding, between 50 - 90%
    . If the expedition succeeds, COSMIC BULL earns the pot, else COSMIC BEAR steals it
    
    . COSMIC BULL is a safer deity, always has a higher chance of winning
    . Users are more likely to stake with the safer deity so it's pot will be higher, thus the winnings per SUMMIT staked lower

    . COSMIC BEAR is riskier, with a smaller chance of winning, potentially as low as 10%
    . Users are less likely to stake with BULL as it may be outside their risk tolerance to shoot for a small % chance of win

    . Thus BEAR will usually have less staked, making it both riskier, and more rewarding on win

    . The SUMMIT team expect that because switching between DEITIES is both free and unlimited,
        users will collectively 'arbitrage' the two deities based on the chance of success.

    . For example, if a round's chance of success is 75%, we expect 75% of the staked funds in the pool to be with BULL (safer)
        though this is by no means guaranteed


MULTI-STAKING
    . Users can stake both their SUMMIT token and SUMMIT LP token in an expedition
    . This prevents users from needing to break and re-make their LP for every expedition
    . SUMMIT and SUMMIT LP can be staked simultaneously
    . Both SUMMIT and SUMMIT LP can be elevated into and out of the Expedition
    . The equivalent amount of SUMMIT within the staked SUMMIT LP is treated as the SUMMIT token, and can earn winnings
    . The equivalent amount of SUMMIT in staked SUMMIT LP is determined from the SUMMIT LP pair directly
    . We have also added summitLpEverestIncentiveMult (between 1X - 2X) which can increase the equivalent amount of SUMMIT in SUMMIT LP (updated on a 72 hour timelock)
    . summitLpEverestIncentiveMult will be updated to ensure users are willing to stake their SUMMIT LP rather than break it (this may never be necessary and will be actively monitored)

WINNINGS:
    . The round reward is split amongst all members of the winning DEITY, based on their percentage of the total amount staked in that deity
    . Calculations section omitted because it is simply division
    . Users may exit the pool at any time without fee
    . Users are not forced to collect their winnings between rounds, and are entered into the next round automatically (same deity) if they do not exit


*/



contract ExpeditionV2 is Ownable, Initializable, ReentrancyGuard, BaseEverestExtension, PresetPausable {
    using SafeERC20 for IERC20;

    // ---------------------------------------
    // --   V A R I A B L E S
    // ---------------------------------------

    SummitToken public summit;
    ElevationHelper elevationHelper;
    SummitGlacier public summitGlacier;
    uint8 constant EXPEDITION = 4;

    uint256 public expeditionDeityWinningsMult = 125;
    uint256 public expeditionRunwayRounds = 30;
    
    struct UserTokenInteraction {
        uint256 safeDebt;
        uint256 deityDebt;
        uint256 lifetimeWinnings;
    }
    struct UserExpeditionInfo {
        address userAdd;

        // Entry Requirements
        uint256 everestOwned;
        uint8 deity;
        bool deitySelected;
        uint256 deitySelectionRound;
        uint8 safetyFactor;
        bool safetyFactorSelected;

        // Expedition Interaction
        bool entered;
        uint256 prevInteractedRound;

        uint256 safeSupply;
        uint256 deitiedSupply;

        UserTokenInteraction summit;
        UserTokenInteraction usdc;
    }
    mapping(address => UserExpeditionInfo) public userExpeditionInfo;        // Users running staked information

    struct ExpeditionToken {
        IERC20 token;
        uint256 roundEmission;
        uint256 emissionsRemaining;
        uint256 markedForDist;
        uint256 distributed;
        uint256 safeMult;
        uint256[2] deityMult;
    }
    struct ExpeditionEverestSupplies {
        uint256 safe;
        uint256 deitied;
        uint256[2] deity;
    }
    struct ExpeditionInfo {
        bool live;                          // If the pool is manually enabled / disabled
        bool launched;

        uint256 roundsRemaining;            // Number of rounds of this expedition to run.

        ExpeditionEverestSupplies supplies;

        ExpeditionToken summit;
        ExpeditionToken usdc;
    }
    ExpeditionInfo public expeditionInfo;   // Expedition info

    



    // ---------------------------------------
    // --   E V E N T S
    // ---------------------------------------

    event UserJoinedExpedition(address indexed user, uint8 _deity, uint8 _safetyFactor, uint256 _everestOwned);
    event UserHarvestedExpedition(address indexed user, uint256 _summitHarvested, uint256 _usdcHarvested);

    event ExpeditionInitialized(address _usdcTokenAddress, address _elevationHelper);
    event ExpeditionEmissionsRecalculated(uint256 _roundsRemaining, uint256 _summitEmissionPerRound, uint256 _usdcEmissionPerRound);
    event ExpeditionFundsAdded(address indexed token, uint256 _amount);
    event ExpeditionDisabled();
    event ExpeditionEnabled();
    event Rollover(address indexed user);
    event DeitySelected(address indexed user, uint8 _deity, uint256 _deitySelectionRound);
    event SafetyFactorSelected(address indexed user, uint8 _safetyFactor);

    event SetExpeditionDeityWinningsMult(uint256 _deityMult);
    event SetExpeditionRunwayRounds(uint256 _runwayRounds);
    





    // ---------------------------------------
    // --  A D M I N I S T R A T I O N
    // ---------------------------------------


    /// @dev Constructor, setting address of cartographer
    constructor(
        address _summit,
        address _everest,
        address _summitGlacier
    ) {
        require(_summit != address(0), "Summit required");
        require(_everest != address(0), "Everest required");
        require(_summitGlacier != address(0), "SummitGlacier Required");
        summit = SummitToken(_summit);
        everest = EverestToken(_everest);
        summitGlacier = SummitGlacier(_summitGlacier);
    }


    /// @dev Initializes the expedition
    function initialize(address _usdcTokenAddress, address _elevationHelper)
        public
        initializer onlyOwner
    {
        require(_usdcTokenAddress != address(0), "USDC token missing");
        require(_elevationHelper != address(0), "Elevation Helper missing");

        // Initialize expedition itself
        expeditionInfo.summit.token = IERC20(address(summit));
        expeditionInfo.usdc.token = IERC20(_usdcTokenAddress);

        expeditionInfo.live = true;

        _recalculateExpeditionEmissions();

        // Initialize Elevation Helper
        elevationHelper = ElevationHelper(_elevationHelper);

        emit ExpeditionInitialized(_usdcTokenAddress, _elevationHelper);
    }






    // ------------------------------------------------------
    // --   M O D I F I E R S 
    // ------------------------------------------------------

    modifier validSafetyFactor(uint8 _safetyFactor) {
        require(_safetyFactor <= 100, "Invalid safety factor");
        _;
    }
    function _validUserAdd(address _userAdd) internal pure {
        require(_userAdd != address(0), "User address is zero");
    }
    modifier validUserAdd(address _userAdd) {
        _validUserAdd(_userAdd);
        _;
    }
    modifier validDeity(uint8 deity) {
        require(deity < 2, "Invalid deity");
        _;
    }
    modifier expeditionInteractionsAvailable() {
        require(!elevationHelper.endOfRoundLockoutActive(EXPEDITION), "Elev locked until rollover");
        _;
    }
    modifier userOwnsEverest() {
        require(userExpeditionInfo[msg.sender].everestOwned > 0, "Must own everest");
        _;
    }
    modifier userIsEligibleToJoinExpedition() {
        require(userExpeditionInfo[msg.sender].deitySelected, "No deity selected");
        require(userExpeditionInfo[msg.sender].safetyFactorSelected, "No safety factor selected");
        _;
    }
    




    // ---------------------------------------
    // --   U T I L S (inlined for brevity)
    // ---------------------------------------


    function supply()
        public view
        returns (uint256, uint256, uint256, uint256)
    {
        return (
            expeditionInfo.supplies.safe,
            expeditionInfo.supplies.deitied,
            expeditionInfo.supplies.deity[0],
            expeditionInfo.supplies.deity[1]
        );
    }
    
    function selectedDeity(address _userAdd)
        public view
        returns (uint8)
    {
        return userExpeditionInfo[_userAdd].deity;
    }

    /// @dev Divider is random number 50 - 90 that sets the random chance of each of the deities winning the round
    function currentDeityDivider()
        public view
        returns (uint256)
    {
        return elevationHelper.currentDeityDivider();
    }


    /// @dev The amount of reward token that exists to be rewarded by an expedition
    function remainingRewards()
        public view
        returns (uint256, uint256)
    {
        return (
            expeditionInfo.summit.emissionsRemaining,
            expeditionInfo.usdc.emissionsRemaining
        );
    }




    // ---------------------------------------
    // --   A D J U S T M E N T S
    // ---------------------------------------


    
    function setExpeditionDeityWinningsMult(uint256 _deityMult) public onlyOwner {
        require(_deityMult >= 100 && _deityMult <= 500, "Invalid deity mult (1X-5X)");
        expeditionDeityWinningsMult = _deityMult;
        emit SetExpeditionDeityWinningsMult(_deityMult);
    }
    function setExpeditionRunwayRounds(uint256 _runwayRounds) public onlyOwner {
        require(_runwayRounds >= 7 && _runwayRounds <= 90, "Invalid runway rounds (7-90)");
        expeditionRunwayRounds = _runwayRounds;
        emit SetExpeditionRunwayRounds(_runwayRounds);
    }





    // ---------------------------------------
    // --   E X P E D   M A N A G E M E N T
    // ---------------------------------------


    /// @dev Recalculate and set emissions of single reward token
    /// @return Whether this token has some emissions
    function _recalculateExpeditionTokenEmissions(ExpeditionToken storage expedToken)
        internal
        returns (bool)
    {
        uint256 fund = expedToken.token.balanceOf(address(this)) - expedToken.markedForDist;

        expedToken.emissionsRemaining = fund;
        expedToken.roundEmission = fund == 0 ? 0 : fund / expeditionRunwayRounds;

        return fund > 0;
    }


    /// @dev Recalculate and set expedition emissions
    function _recalculateExpeditionEmissions()
        internal
    {
        bool summitFundNonZero = _recalculateExpeditionTokenEmissions(expeditionInfo.summit);
        bool usdcFundNonZero = _recalculateExpeditionTokenEmissions(expeditionInfo.usdc);
        expeditionInfo.roundsRemaining = (summitFundNonZero || usdcFundNonZero) ? expeditionRunwayRounds : 0;
    }
    function recalculateExpeditionEmissions()
        public
        onlyOwner
    {
        _recalculateExpeditionEmissions();
        emit ExpeditionEmissionsRecalculated(expeditionInfo.roundsRemaining, expeditionInfo.summit.roundEmission, expeditionInfo.usdc.roundEmission);
    }

    /// @dev Add funds to the expedition
    function addExpeditionFunds(address _token, uint256 _amount)
        public
        nonReentrant
    {
        require (_token == address(expeditionInfo.summit.token) || _token == address(expeditionInfo.usdc.token), "Invalid token to add to expedition");
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);

        emit ExpeditionFundsAdded(_token, _amount);
    }

    /// @dev Turn off an expedition
    function disableExpedition()
        public
        onlyOwner
    {
        require(expeditionInfo.live, "Expedition already disabled");
        expeditionInfo.live = false;

        emit ExpeditionDisabled();
    }

    /// @dev Turn on a turned off expedition
    function enableExpedition()
        public
        onlyOwner
    {
        require(!expeditionInfo.live, "Expedition already enabled");
        expeditionInfo.live = true;

        emit ExpeditionEnabled();
    }



    // ---------------------------------------
    // --   P O O L   R E W A R D S
    // ---------------------------------------
    
    function rewards(address _userAdd)
        public view
        validUserAdd(_userAdd)
        returns (uint256, uint256)
    {
        // Calculate and return the harvestable winnings for this expedition
        return _harvestableWinnings(userExpeditionInfo[_userAdd]);
    }


    function _calculateEmissionMultipliers()
        internal view
        returns (uint256, uint256, uint256, uint256)
    {
        // Total Supply of the expedition
        uint256 deitiedSupplyWithBonus = expeditionInfo.supplies.deitied * expeditionDeityWinningsMult / 100;
        uint256 totalExpedSupply = deitiedSupplyWithBonus + expeditionInfo.supplies.safe;
        if (totalExpedSupply == 0) return (0, 0, 0, 0);

        // Calculate safe winnings multiplier or escape if div/0
        uint256 summitSafeEmission = (expeditionInfo.summit.roundEmission * 1e18 * expeditionInfo.supplies.safe) / totalExpedSupply;
        uint256 rewardSafeEmission = (expeditionInfo.usdc.roundEmission * 1e18 * expeditionInfo.supplies.safe) / totalExpedSupply;

        // Calculate winning deity's winnings multiplier or escape if div/0
        uint256 summitDeitiedEmission = (expeditionInfo.summit.roundEmission * 1e18 * deitiedSupplyWithBonus) / totalExpedSupply;
        uint256 rewardDeitiedEmission = (expeditionInfo.usdc.roundEmission * 1e18 * deitiedSupplyWithBonus) / totalExpedSupply;

        return (
            summitSafeEmission,
            rewardSafeEmission,
            summitDeitiedEmission,
            rewardDeitiedEmission
        );
    }


    /// @dev User's staked amount, and how much they will win with that stake amount
    /// @param _userAdd User to check
    /// @return (
    ///     guaranteedSummitYield
    ///     guaranteedUSDCYield
    ///     deitiedSummitYield
    ///     deitiedUSDCYield
    /// )
    function potentialWinnings(address _userAdd)
        public view
        validUserAdd(_userAdd)
        returns (uint256, uint256, uint256, uint256)
    {
        UserExpeditionInfo storage user = userExpeditionInfo[_userAdd];

        if (!user.entered || !expeditionInfo.live || !expeditionInfo.launched) return (0, 0, 0, 0);

        uint256 userSafeEverest = _getUserSafeEverest(user, user.safetyFactor);
        uint256 userDeitiedEverest = _getUserDeitiedEverest(user, user.safetyFactor);

        (uint256 summitSafeEmissionMultE18, uint256 usdcSafeEmissionMultE18, uint256 summitDeitiedEmissionMultE18, uint256 usdcDeitiedEmissionMultE18) = _calculateEmissionMultipliers();

        return(
            expeditionInfo.supplies.safe == 0 ? 0 : ((summitSafeEmissionMultE18 * userSafeEverest) / expeditionInfo.supplies.safe) / 1e18,
            expeditionInfo.supplies.safe == 0 ? 0 : ((usdcSafeEmissionMultE18 * userSafeEverest) / expeditionInfo.supplies.safe) / 1e18,
            expeditionInfo.supplies.deity[user.deity] == 0 ? 0 : ((summitDeitiedEmissionMultE18 * userDeitiedEverest) / expeditionInfo.supplies.deity[user.deity]) / 1e18,
            expeditionInfo.supplies.deity[user.deity] == 0 ? 0 : ((usdcDeitiedEmissionMultE18 * userDeitiedEverest) / expeditionInfo.supplies.deity[user.deity]) / 1e18
        );
    }




    // ------------------------------------------------------------------
    // --   R O L L O V E R   E L E V A T I O N   R O U N D
    // ------------------------------------------------------------------
    
    
    /// @dev Rolling over all expeditions
    ///      Expeditions set to open (expedition.startRound == nextRound) are enabled
    ///      Expeditions set to end are disabled
    function rollover()
        public whenNotPaused
        nonReentrant
    {
        // Ensure that the expedition is ready to be rolled over, ensures only a single user can perform the rollover
        elevationHelper.validateRolloverAvailable(EXPEDITION);

        // Selects the winning totem for the round, storing it in the elevationHelper contract
        elevationHelper.selectWinningTotem(EXPEDITION);

        // Update the round index in the elevationHelper, effectively starting the next round of play
        elevationHelper.rolloverElevation(EXPEDITION);

        uint256 currRound = elevationHelper.roundNumber(EXPEDITION);

        _rolloverExpedition(currRound);

        emit Rollover(msg.sender);
    }


    /// @dev Roll over a single expedition
    /// @param _currRound Current round
    function _rolloverExpedition(uint256 _currRound)
        internal
    {
        if (!expeditionInfo.live) return;

        if (!expeditionInfo.launched) {
            expeditionInfo.launched = true;
            return;
        }

        uint8 winningDeity = elevationHelper.winningTotem(EXPEDITION, _currRound - 1);

        // Calculate emission multipliers
        (uint256 summitSafeEmissionMultE18, uint256 usdcSafeEmissionMultE18, uint256 summitDeitiedEmissionMultE18, uint256 usdcDeitiedEmissionMultE18) = _calculateEmissionMultipliers();

        // Mark current round's emission to be distributed
        uint256 summitEmitted = (summitSafeEmissionMultE18 + summitDeitiedEmissionMultE18) / 1e18;
        uint256 usdcEmitted = (usdcSafeEmissionMultE18 + usdcDeitiedEmissionMultE18) / 1e18;
        expeditionInfo.summit.markedForDist += summitEmitted;
        expeditionInfo.usdc.markedForDist += usdcEmitted;
        expeditionInfo.summit.distributed += summitEmitted;
        expeditionInfo.usdc.distributed += usdcEmitted;
        expeditionInfo.summit.emissionsRemaining -= summitEmitted;
        expeditionInfo.usdc.emissionsRemaining -= usdcEmitted;

        // Update the guaranteed emissions mults
        if (expeditionInfo.supplies.safe > 0) {
            expeditionInfo.summit.safeMult += summitSafeEmissionMultE18 / expeditionInfo.supplies.safe;
            expeditionInfo.usdc.safeMult += usdcSafeEmissionMultE18 / expeditionInfo.supplies.safe;
        }
        // Update winning deity's running winnings mult
        if (expeditionInfo.supplies.deity[winningDeity] > 0) {
            expeditionInfo.summit.deityMult[winningDeity] += summitDeitiedEmissionMultE18 / expeditionInfo.supplies.deity[winningDeity];
            expeditionInfo.usdc.deityMult[winningDeity] += usdcDeitiedEmissionMultE18 / expeditionInfo.supplies.deity[winningDeity];
        }

        expeditionInfo.roundsRemaining -= 1;
    }
    


    

    // ------------------------------------------------------------
    // --   W I N N I N G S   C A L C U L A T I O N S 
    // ------------------------------------------------------------


    /// @dev User's 'safe' everest that is guaranteed to earn
    function _getUserSafeEverest(UserExpeditionInfo storage user, uint8 _safetyFactor)
        internal view
        returns (uint256)
    {
        return user.everestOwned * _safetyFactor / 100;
    }
    /// @dev User's total everest in the pot
    function _getUserDeitiedEverest(UserExpeditionInfo storage user, uint8 _safetyFactor)
        internal view
        returns (uint256)
    {
        return user.everestOwned * (100 - _safetyFactor) / 100;
    }

    /// @dev Calculation of winnings that are available to be harvested
    /// @return Total winnings for a user, including vesting on previous round's winnings (if any)
    function _harvestableWinnings(UserExpeditionInfo storage user)
        internal view
        returns (uint256, uint256)
    {
        uint256 currRound = elevationHelper.roundNumber(EXPEDITION);

        // If user interacted in current round, no winnings available
        if (!user.entered || user.prevInteractedRound == currRound) return (0, 0);

        uint256 safeEverest = _getUserSafeEverest(user, user.safetyFactor);
        uint256 deitiedEverest = _getUserDeitiedEverest(user, user.safetyFactor);

        return (
            ((safeEverest * (expeditionInfo.summit.safeMult - user.summit.safeDebt)) / 1e18) +
            ((deitiedEverest * (expeditionInfo.summit.deityMult[user.deity] - user.summit.deityDebt)) / 1e18),
            ((safeEverest * (expeditionInfo.usdc.safeMult - user.usdc.safeDebt)) / 1e18) +
            ((deitiedEverest * (expeditionInfo.usdc.deityMult[user.deity] - user.usdc.deityDebt)) / 1e18)
        );
    }
    


    

    // ------------------------------------------------------------
    // --   U S E R   I N T E R A C T I O N S
    // ------------------------------------------------------------


    /// @dev Update the users round interaction
    function _updateUserRoundInteraction(UserExpeditionInfo storage user)
        internal
    {
        uint256 currRound = elevationHelper.roundNumber(EXPEDITION);

        user.safeSupply = _getUserSafeEverest(user, user.safetyFactor);
        user.deitiedSupply = _getUserDeitiedEverest(user, user.safetyFactor);

        // Acc winnings per share of user's deity of both SUMMIT token and USDC token
        user.summit.safeDebt = expeditionInfo.summit.safeMult;
        user.usdc.safeDebt = expeditionInfo.usdc.safeMult;
        user.summit.deityDebt = expeditionInfo.summit.deityMult[user.deity];
        user.usdc.deityDebt = expeditionInfo.usdc.deityMult[user.deity];

        // Update the user's previous interacted round to be this round
        user.prevInteractedRound = currRound;
    }



    // ------------------------------------------------------------
    // --   E X P E D   H E L P E R S
    // ------------------------------------------------------------

    function _harvestExpedition(UserExpeditionInfo storage user)
        internal
        returns (uint256, uint256)
    {
        // Get calculated harvestable winnings
        (uint256 summitWinnings, uint256 usdcWinnings) = _harvestableWinnings(user);

        // Handle SUMMIT winnings
        if (summitWinnings > 0) {
            user.summit.lifetimeWinnings += summitWinnings;

            // Claim SUMMIT winnings (lock for 30 days)
            expeditionInfo.summit.token.safeTransfer(address(summitGlacier), summitWinnings);
            summitGlacier.addLockedWinnings(summitWinnings, 0, user.userAdd);
            expeditionInfo.summit.markedForDist -= summitWinnings;
        }

        // Transfer USDC winnings to user
        if (usdcWinnings > 0) {
            user.usdc.lifetimeWinnings += usdcWinnings;
            expeditionInfo.usdc.token.safeTransfer(user.userAdd, usdcWinnings);
            expeditionInfo.usdc.markedForDist -= usdcWinnings;
        }

        return (summitWinnings, usdcWinnings);
    }





    // ---------------------------------------
    // --   E V E R E S T
    // ---------------------------------------


    function syncEverestAmount()
        public whenNotPaused
        nonReentrant
    {
        _updateUserEverestAmount(
            msg.sender,
            _getUserEverest(msg.sender)
        );
    }


    function updateUserEverest(uint256 _everestAmount, address _userAdd)
        external override
        onlyEverestToken
    {
        _updateUserEverestAmount(
            _userAdd,
            _everestAmount
        );
    }

    function _updateUserEverestAmount(address _userAdd, uint256 _everestAmount)
        internal
    {
        UserExpeditionInfo storage user = _getOrCreateUserInfo(_userAdd);

        // Harvest winnings from expedition
        _harvestExpedition(user);

        // Save user's existing safe and deitied everest supplies
        uint256 existingSafeSupply = _getUserSafeEverest(user, user.safetyFactor);
        uint256 existingDeitiedSupply = _getUserDeitiedEverest(user, user.safetyFactor);

        // Update user's owned everest amount
        user.everestOwned = _everestAmount;

        // Update user
        _updateUserRoundInteraction(user);

        // Remove user's existing supplies from expedition, add new supplies
        if (user.entered) {
            expeditionInfo.supplies.safe = expeditionInfo.supplies.safe - existingSafeSupply + _getUserSafeEverest(user, user.safetyFactor);
            expeditionInfo.supplies.deitied = expeditionInfo.supplies.deitied - existingDeitiedSupply + _getUserDeitiedEverest(user, user.safetyFactor);
            expeditionInfo.supplies.deity[user.deity] = expeditionInfo.supplies.deity[user.deity] - existingDeitiedSupply + _getUserDeitiedEverest(user, user.safetyFactor);
        }
    }



    // ----------------------------------------------------------------------
    // --  E X P E D   D I R E C T   I N T E R A C T I O N S
    // ----------------------------------------------------------------------


    function _getOrCreateUserInfo(address _userAdd)
        internal
        returns (UserExpeditionInfo storage)
    {
        UserExpeditionInfo storage user = userExpeditionInfo[_userAdd];
        user.userAdd = _userAdd;
        return user;
    }


    /// @dev Select a user's deity, update the expedition's deities with the switched funds
    function selectDeity(uint8 _newDeity)
        public whenNotPaused
        nonReentrant validDeity(_newDeity) expeditionInteractionsAvailable
    {
        UserExpeditionInfo storage user = _getOrCreateUserInfo(msg.sender);

        // Early exit if deity is same as current
        require(!user.deitySelected || user.deity != _newDeity, "Deity must be different");

        // Harvest any winnings in this expedition
        _harvestExpedition(user);

        // Update user deity in state
        uint8 prevDeity = user.deity;
        user.deity = _newDeity;
        user.deitySelected = true;
        user.deitySelectionRound = elevationHelper.roundNumber(EXPEDITION);
        
        // Update user's interaction in this expedition
        _updateUserRoundInteraction(user);
        
        // Transfer deitied everest from previous deity to new deity
        if (user.entered) {
            expeditionInfo.supplies.deity[prevDeity] -= user.deitiedSupply;
            expeditionInfo.supplies.deity[_newDeity] += user.deitiedSupply;
        }

        emit DeitySelected(msg.sender, _newDeity, user.deitySelectionRound);
    }


    /// @dev Change the safety factor of a user
    function selectSafetyFactor(uint8 _newSafetyFactor)
        public whenNotPaused
        nonReentrant validSafetyFactor(_newSafetyFactor) expeditionInteractionsAvailable
    {
        UserExpeditionInfo storage user = _getOrCreateUserInfo(msg.sender);

        // Early exit if safety factor is the same
        require(!user.safetyFactorSelected || user.safetyFactor != _newSafetyFactor, "SafetyFactor must be different");

        // Harvest any winnings in this expedition
        _harvestExpedition(user);

        // Store existing supplies to update expedition supplies
        uint256 existingSafeSupply = user.safeSupply;
        uint256 existingDeitiedSupply = user.deitiedSupply;

        // Update safety factor in user state
        user.safetyFactor = _newSafetyFactor;
        user.safetyFactorSelected = true;
        
        // Update user's interaction in this expedition
        _updateUserRoundInteraction(user);

        // Remove safe and deitied everest from existing supply states
        if (user.entered) {
            expeditionInfo.supplies.safe = expeditionInfo.supplies.safe - existingSafeSupply + user.safeSupply;
            expeditionInfo.supplies.deitied = expeditionInfo.supplies.deitied - existingDeitiedSupply + user.deitiedSupply;
            expeditionInfo.supplies.deity[user.deity] = expeditionInfo.supplies.deity[user.deity] - existingDeitiedSupply + user.deitiedSupply;
        }

        emit SafetyFactorSelected(msg.sender, _newSafetyFactor);
    }


    /// @dev Select a user's deity, update the expedition's deities with the switched funds
    function selectDeityAndSafetyFactor(uint8 _newDeity, uint8 _newSafetyFactor)
        public whenNotPaused
        nonReentrant validDeity(_newDeity) expeditionInteractionsAvailable
    {
        UserExpeditionInfo storage user = _getOrCreateUserInfo(msg.sender);

        // Early exit if deity is same as current
        require(!user.deitySelected || user.deity != _newDeity, "Deity must be different");
        // Early exit if safety factor is the same
        require(!user.safetyFactorSelected || user.safetyFactor != _newSafetyFactor, "SafetyFactor must be different");

        // Harvest any winnings in this expedition
        _harvestExpedition(user);

        // Update user deity in state
        uint8 prevDeity = user.deity;
        user.deity = _newDeity;
        user.deitySelected = true;
        user.deitySelectionRound = elevationHelper.roundNumber(EXPEDITION);

        // Update safety factor in user state
        uint256 existingSafeSupply = user.safeSupply;
        uint256 existingDeitiedSupply = user.deitiedSupply;
        user.safetyFactor = _newSafetyFactor;
        user.safetyFactorSelected = true;
        
        // Update user's interaction in this expedition
        _updateUserRoundInteraction(user);
        
        if (user.entered) {
            // Transfer deitied everest from previous deity to new deity
            expeditionInfo.supplies.deity[prevDeity] -= user.deitiedSupply;
            expeditionInfo.supplies.deity[_newDeity] += user.deitiedSupply;
            
            // Remove safe and deitied everest from existing supply states
            expeditionInfo.supplies.safe = expeditionInfo.supplies.safe - existingSafeSupply + user.safeSupply;
            expeditionInfo.supplies.deitied = expeditionInfo.supplies.deitied - existingDeitiedSupply + user.deitiedSupply;
            expeditionInfo.supplies.deity[user.deity] = expeditionInfo.supplies.deity[user.deity] - existingDeitiedSupply + user.deitiedSupply;
        }

        emit DeitySelected(msg.sender, _newDeity, user.deitySelectionRound);
        emit SafetyFactorSelected(msg.sender, _newSafetyFactor);
    }


    function userSatisfiesExpeditionRequirements(address _userAdd)
        public view
        returns (bool, bool, bool)
    {
        return (
            userExpeditionInfo[_userAdd].everestOwned > 0,
            userExpeditionInfo[_userAdd].deitySelected,
            userExpeditionInfo[_userAdd].safetyFactorSelected
        );
    }

    function joinExpedition()
        public whenNotPaused
        userOwnsEverest userIsEligibleToJoinExpedition expeditionInteractionsAvailable
    {
        UserExpeditionInfo storage user = userExpeditionInfo[msg.sender];        

        // Mark user interacting with this expedition to the user's expeditions slot
        require(!user.entered, "Already entered");
        user.entered = true;

        // Update the user's round interaction with updated info
        _updateUserRoundInteraction(user);

        // Add users everest to exped supplies at current risk rate
        expeditionInfo.supplies.safe += user.safeSupply;
        expeditionInfo.supplies.deitied += user.deitiedSupply;
        expeditionInfo.supplies.deity[user.deity] += user.deitiedSupply;

        emit UserJoinedExpedition(msg.sender, user.deity, user.safetyFactor, user.everestOwned);
    }

    function harvestExpedition()
        public whenNotPaused
        nonReentrant userOwnsEverest expeditionInteractionsAvailable
    {
        UserExpeditionInfo storage user = userExpeditionInfo[msg.sender];        
        require(user.entered, "Must be entered to harvest");

        (uint256 summitHarvested, uint256 usdcHarvested) = _harvestExpedition(user);
        _updateUserRoundInteraction(user);

        emit UserHarvestedExpedition(msg.sender, summitHarvested, usdcHarvested);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.2;

import "./BaseEverestExtension.sol";
import "./PresetPausable.sol";
import "./libs/SummitMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


// EverestToken, governance token of Summit DeFi
contract EverestToken is ERC20('EverestToken', 'EVEREST'), Ownable, ReentrancyGuard, PresetPausable {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    // ---------------------------------------
    // --   V A R I A B L E S
    // ---------------------------------------

    IERC20 public summit;

    bool public panic = false;

    uint256 public constant daySeconds = 24 * 3600;

    uint256 public minLockTime = 7 days;
    uint256 public inflectionLockTime = 30 days;
    uint256 public maxLockTime = 365 days;
    
    uint256 public minEverestLockMult = 1000;
    uint256 public inflectionEverestLockMult = 10000;
    uint256 public maxEverestLockMult = 25000;

    uint256 public totalSummitLocked;
    uint256 public weightedAvgSummitLockDurations;

    EnumerableSet.AddressSet whitelistedTransferAddresses;

    struct UserEverestInfo {
        address userAdd;

        uint256 everestOwned;
        uint256 everestLockMultiplier;
        uint256 lockDuration;
        uint256 lockRelease;
        uint256 summitLocked;
    }
    mapping(address => UserEverestInfo) public userEverestInfo;

    // Other contracts that hook into the user's amount of everest, max 3 extensions
    // Will be used for the DAO, as well as everest pools in the future
    EnumerableSet.AddressSet everestExtensions;


    constructor(address _summit) {
        require(_summit != address(0), "SummitToken missing");
        summit = IERC20(_summit);

        // Add burn / mintFrom address as whitelisted address
        whitelistedTransferAddresses.add(address(0));
        // Add this address as a whitelisted address
        whitelistedTransferAddresses.add(address(this));
    }
    
    
    // ---------------------------------------
    // --   E V E N T S
    // ---------------------------------------

    event SummitLocked(address indexed user, uint256 _summitLocked, uint256 _lockDuration, uint256 _everestAwarded);
    event LockDurationIncreased(address indexed user, uint256 _lockDuration, uint256 _additionalEverestAwarded);
    event LockedSummitIncreased(address indexed user, bool indexed _increasedWithClaimableWinnings, uint256 _summitLocked, uint256 _everestAwarded);
    event LockedSummitWithdrawn(address indexed user, uint256 _summitRemoved, uint256 _everestBurned);
    event PanicFundsRecovered(address indexed user, uint256 _summitRecovered);

    event SetMinLockTime(uint256 _lockTimeDays);
    event SetInflectionLockTime(uint256 _lockTimeDays);
    event SetMaxLockTime(uint256 _lockTimeDays);
    event SetMinEverestLockMult(uint256 _lockMult);
    event SetInflectionEverestLockMult(uint256 _lockMult);
    event SetMaxEverestLockMult(uint256 _lockMult);
    event SetLockTimeRequiredForTaxlessSummitWithdraw(uint256 _lockTimeDays);
    event SetLockTimeRequiredForLockedSummitDeposit(uint256 _lockTimeDays);
    event AddWhitelistedTransferAddress(address _transferAddress);
    event SetPanic(bool _panic);

    event EverestExtensionAdded(address indexed extension);
    event EverestExtensionRemoved(address indexed extension);



    // ------------------------------------------------------
    // --   M O D I F I E R S 
    // ------------------------------------------------------

    modifier validLockDuration(uint256 _lockDuration) {
        require (_lockDuration >= minLockTime && _lockDuration <= maxLockTime, "Invalid lock duration");
        _;
    }
    modifier userNotAlreadyLockingSummit() {
        require (userEverestInfo[msg.sender].everestOwned == 0, "Already locking summit");
        _;
    }
    modifier userLockDurationSatisfied() {
        require(userEverestInfo[msg.sender].lockRelease != 0, "User doesnt have a lock release");
        require(block.timestamp >= userEverestInfo[msg.sender].lockRelease, "Lock still in effect");
        _;
    }
    modifier userEverestInfoExists(address _userAdd) {
        require(userEverestInfo[_userAdd].userAdd == _userAdd, "User doesnt exist");
        _;
    }
    modifier userOwnsEverest(address _userAdd) {
        require (userEverestInfo[_userAdd].everestOwned > 0, "Must own everest");
        _;
    }
    modifier validEverestAmountToBurn(uint256 _everestAmount) {
        require (_everestAmount > 0 && _everestAmount <= userEverestInfo[msg.sender].everestOwned, "Bad withdraw");
        _;
    }
    modifier onlyPanic() {
        require(panic, "Not in panic");
        _;
    }
    modifier notPanic() {
        require(!panic, "Not available during panic");
        _;
    }


    // ---------------------------------------
    // --   A D J U S T M E N T S
    // ---------------------------------------



    function setMinLockTime(uint256 _lockTimeDays) public onlyOwner {
        require(_lockTimeDays <= inflectionLockTime && _lockTimeDays >= 1 && _lockTimeDays <= 30, "Invalid minimum lock time (1-30 days)");
        minLockTime = _lockTimeDays * daySeconds;
        emit SetMinLockTime(_lockTimeDays);
    }
    function setInflectionLockTime(uint256 _lockTimeDays) public onlyOwner {
        require(_lockTimeDays >= minLockTime && _lockTimeDays <= maxLockTime && _lockTimeDays >= 7 && _lockTimeDays <= 365, "Invalid inflection lock time (7-365 days)");
        inflectionLockTime = _lockTimeDays * daySeconds;
        emit SetInflectionLockTime(_lockTimeDays);
    }
    function setMaxLockTime(uint256 _lockTimeDays) public onlyOwner {
        require(_lockTimeDays >= inflectionLockTime && _lockTimeDays >= 7 && _lockTimeDays <= 730, "Invalid maximum lock time (7-730 days)");
        maxLockTime = _lockTimeDays * daySeconds;
        emit SetMaxLockTime(_lockTimeDays);
    }
    function setMinEverestLockMult(uint256 _lockMult) public onlyOwner {
        require(_lockMult >= 100 && _lockMult <= 50000, "Invalid lock mult");
        minEverestLockMult = _lockMult;
        emit SetMinEverestLockMult(_lockMult);
    }
    function setInflectionEverestLockMult(uint256 _lockMult) public onlyOwner {
        require(_lockMult >= 100 && _lockMult <= 50000, "Invalid lock mult");
        inflectionEverestLockMult = _lockMult;
        emit SetInflectionEverestLockMult(_lockMult);
    }
    function setMaxEverestLockMult(uint256 _lockMult) public onlyOwner {
        require(_lockMult >= 100 && _lockMult <= 50000, "Invalid lock mult");
        maxEverestLockMult = _lockMult;
        emit SetMaxEverestLockMult(_lockMult);
    }





    // ------------------------------------------------------------
    // --   F U N C T I O N A L I T Y
    // ------------------------------------------------------------


    /// @dev Update the average lock duration
    function _updateAvgSummitLockDuration(uint256 _amount, uint256 _lockDuration, bool _isLocking)
        internal
    {
        // The weighted average of the change being applied
        uint256 deltaWeightedAvg = _amount * _lockDuration;

        // Update the lock multiplier and the total amount locked
        if (_isLocking) {
            totalSummitLocked += _amount;
            weightedAvgSummitLockDurations += deltaWeightedAvg;
        } else {
            totalSummitLocked -= _amount;
            weightedAvgSummitLockDurations -= deltaWeightedAvg;
        }
    }
    function avgSummitLockDuration()
        public view
        returns (uint256)
    {
        // Early escape if div/0
        if (totalSummitLocked == 0) return 0;

        // Return the average from the weighted average lock duration 
        return weightedAvgSummitLockDurations / totalSummitLocked;
    }

    /// @dev Lock period multiplier
    function _lockDurationMultiplier(uint256 _lockDuration)
        internal view
        returns (uint256)
    {
        if (_lockDuration <= inflectionLockTime) {
            return SummitMath.scaledValue(
                _lockDuration,
                minLockTime, inflectionLockTime,
                minEverestLockMult, inflectionEverestLockMult
            );
        }
        return SummitMath.scaledValue(
            _lockDuration,
            inflectionLockTime, maxLockTime,
            inflectionEverestLockMult, maxEverestLockMult
        );
    }

    /// @dev Transfer everest to the burn address.
    function _burnEverest(address _userAdd, uint256 _everestAmount)
        internal
    {
        IERC20(address(this)).safeTransferFrom(_userAdd, address(this), _everestAmount);
        _burn(address(this), _everestAmount);
    }

    /// @dev Lock Summit for a duration and earn everest
    /// @param _summitAmount Amount of SUMMIT to deposit
    /// @param _lockDuration Duration the SUMMIT will be locked for
    function lockSummit(uint256 _summitAmount, uint256 _lockDuration)
        public whenNotPaused
        nonReentrant notPanic userNotAlreadyLockingSummit validLockDuration(_lockDuration)
    {
        // Validate and deposit user's SUMMIT
        require(_summitAmount <= summit.balanceOf(msg.sender), "Exceeds balance");
        if (_summitAmount > 0) {    
            summit.safeTransferFrom(msg.sender, address(this), _summitAmount);
        }

        // Calculate the lock multiplier and EVEREST award
        uint256 everestLockMultiplier = _lockDurationMultiplier(_lockDuration);
        uint256 everestAward = (_summitAmount * everestLockMultiplier) / 10000;
        
        // Mint EVEREST to the user's wallet
        _mint(msg.sender, everestAward);

        // Create and initialize the user's everestInfo
        UserEverestInfo storage everestInfo = userEverestInfo[msg.sender];
        everestInfo.userAdd = msg.sender;
        everestInfo.everestOwned = everestAward;
        everestInfo.everestLockMultiplier = everestLockMultiplier;
        everestInfo.lockRelease = block.timestamp + _lockDuration;
        everestInfo.lockDuration = _lockDuration;
        everestInfo.summitLocked = _summitAmount;

        // Update average lock duration with new summit locked
        _updateAvgSummitLockDuration(_summitAmount, _lockDuration, true);

        // Update the EVEREST in the expedition
        _updateEverestExtensionsUserEverestOwned(everestInfo);

        emit SummitLocked(msg.sender, _summitAmount, _lockDuration, everestAward);
    }


    /// @dev Increase the lock duration of user's locked SUMMIT
    function increaseLockDuration(uint256 _lockDuration)
        public whenNotPaused
        nonReentrant notPanic userEverestInfoExists(msg.sender) userOwnsEverest(msg.sender) validLockDuration(_lockDuration)
    {
        uint256 additionalEverestAward = _increaseLockDuration(_lockDuration, msg.sender);
        emit LockDurationIncreased(msg.sender, _lockDuration, additionalEverestAward);
    }
    function _increaseLockDuration(uint256 _lockDuration, address _userAdd)
        internal
        returns (uint256)
    {
        UserEverestInfo storage everestInfo = userEverestInfo[_userAdd];
        require(_lockDuration > everestInfo.lockDuration, "Lock duration must strictly increase");

        // Update average lock duration by removing existing lock duration, and adding new duration
        _updateAvgSummitLockDuration(everestInfo.summitLocked, everestInfo.lockDuration, false);
        _updateAvgSummitLockDuration(everestInfo.summitLocked, _lockDuration, true);

        // Calculate and validate the new everest lock multiplier
        uint256 everestLockMultiplier = _lockDurationMultiplier(_lockDuration);
        require(everestLockMultiplier >= everestInfo.everestLockMultiplier, "New lock duration must be greater");

        // Calculate the additional EVEREST awarded by the extended lock duration
        uint256 additionalEverestAward = ((everestInfo.summitLocked * everestLockMultiplier) / 10000) - everestInfo.everestOwned;

        // Increase the lock release
        uint256 lockRelease = block.timestamp + _lockDuration;

        // Mint EVEREST to the user's address
        _mint(_userAdd, additionalEverestAward);

        // Update the user's running state
        everestInfo.everestOwned += additionalEverestAward;
        everestInfo.everestLockMultiplier = everestLockMultiplier;
        everestInfo.lockRelease = lockRelease;
        everestInfo.lockDuration = _lockDuration;

        // Update the expedition with the user's new EVEREST amount
        _updateEverestExtensionsUserEverestOwned(everestInfo);

        return additionalEverestAward;
    }


    /// @dev Internal locked SUMMIT amount increase, returns the extra EVEREST earned by the increased lock duration
    function _increaseLockedSummit(uint256 _summitAmount, UserEverestInfo storage everestInfo, address _summitOriginAdd)
        internal
        returns (uint256)
    {
        // Validate and deposit user's funds
        require(_summitAmount <= summit.balanceOf(_summitOriginAdd), "Exceeds balance");
        if (_summitAmount > 0) {
            summit.safeTransferFrom(_summitOriginAdd, address(this), _summitAmount);
        }

        // Calculate the extra EVEREST that is awarded by the deposited SUMMIT
        uint256 additionalEverestAward = (_summitAmount * everestInfo.everestLockMultiplier) / 10000;
        
        // Mint EVEREST to the user's address
        _mint(everestInfo.userAdd, additionalEverestAward);

        // Increase running balances of EVEREST and SUMMIT
        everestInfo.everestOwned += additionalEverestAward;
        everestInfo.summitLocked += _summitAmount;

        // Update average lock duration with new summit locked
        _updateAvgSummitLockDuration(_summitAmount, everestInfo.lockDuration, true);

        // Update the expedition with the users new EVEREST info
        _updateEverestExtensionsUserEverestOwned(everestInfo);

        return additionalEverestAward;
    }

    /// @dev Increase the duration of already locked SUMMIT, exit early if user is already locked for a longer duration
    /// @return Amount of additional everest earned by this increase of lock duration
    function _increaseLockDurationAndReleaseIfNecessary(UserEverestInfo storage everestInfo, uint256 _lockDuration)
        internal
        returns (uint256)
    {
        // Early escape if lock release already satisfies requirement
        if ((block.timestamp + _lockDuration) <= everestInfo.lockRelease) return 0;

        // If required lock duration is satisfied, but lock release needs to be extended: Update lockRelease exclusively
        if (_lockDuration <= everestInfo.lockDuration) {
            everestInfo.lockRelease = block.timestamp + _lockDuration;
            return 0;
        }

        // Lock duration increased: earn additional EVEREST and update lockDuration and lockRelease
        return _increaseLockDuration(_lockDuration, everestInfo.userAdd);
    }

    /// @dev Lock additional summit and extend duration to arbitrary duration
    function lockAndExtendLockDuration(uint256 _summitAmount, uint256 _lockDuration, address _userAdd)
        public whenNotPaused
        nonReentrant notPanic userEverestInfoExists(_userAdd) userOwnsEverest(_userAdd) validLockDuration(_lockDuration)
    {
        UserEverestInfo storage everestInfo = userEverestInfo[_userAdd];

        // Increase the lock duration of the current locked SUMMIT
        uint256 additionalEverestAward = _increaseLockDurationAndReleaseIfNecessary(everestInfo, _lockDuration);

        // Increase the amount of locked summit by {_summitAmount} and increase the EVEREST award
        additionalEverestAward += _increaseLockedSummit(
            _summitAmount,
            everestInfo,
            msg.sender
        );
        
        emit LockedSummitIncreased(_userAdd, true, _summitAmount, additionalEverestAward);
    }

    /// @dev Increase the users Locked Summit and earn everest
    function increaseLockedSummit(uint256 _summitAmount)
        public whenNotPaused
        nonReentrant notPanic userEverestInfoExists(msg.sender) userOwnsEverest(msg.sender)
    {
        uint256 additionalEverestAward = _increaseLockedSummit(
            _summitAmount,
            userEverestInfo[msg.sender],
            msg.sender
        );

        emit LockedSummitIncreased(msg.sender, false, _summitAmount, additionalEverestAward);
    }

    /// @dev Decrease the Summit and burn everest
    function withdrawLockedSummit(uint256 _everestAmount)
        public whenNotPaused
        nonReentrant notPanic userEverestInfoExists(msg.sender) userOwnsEverest(msg.sender) userLockDurationSatisfied validEverestAmountToBurn(_everestAmount)
    {
        UserEverestInfo storage everestInfo = userEverestInfo[msg.sender];
        require (_everestAmount <= everestInfo.everestOwned, "Bad withdraw");

        uint256 summitToWithdraw = _everestAmount * 10000 / everestInfo.everestLockMultiplier;

        everestInfo.everestOwned -= _everestAmount;
        everestInfo.summitLocked -= summitToWithdraw;

        // Update average summit lock duration with removed summit
        _updateAvgSummitLockDuration(summitToWithdraw, everestInfo.lockDuration, false);

        summit.safeTransfer(msg.sender, summitToWithdraw);
        _burnEverest(msg.sender, _everestAmount);

        _updateEverestExtensionsUserEverestOwned(everestInfo);

        emit LockedSummitWithdrawn(msg.sender, summitToWithdraw, _everestAmount);
    }

    
    
    
    
    
    // ----------------------------------------------------------------------
    // --   W H I T E L I S T E D   T R A N S F E R
    // ----------------------------------------------------------------------

    function addWhitelistedTransferAddress(address _whitelistedAddress) public onlyOwner {
        require(_whitelistedAddress != address(0), "Whitelisted Address missing");
        whitelistedTransferAddresses.add(_whitelistedAddress);
        emit AddWhitelistedTransferAddress(_whitelistedAddress);
    }

    function getWhitelistedTransferAddresses() public view returns (address[] memory) {
        return whitelistedTransferAddresses.values();
    }

    function _beforeTokenTransfer(address sender, address recipient, uint256) internal view override {
        require(whitelistedTransferAddresses.contains(sender) || whitelistedTransferAddresses.contains(recipient), "Not a whitelisted transfer");
    }

    
    
    
    // ----------------------------------------------------------------------
    // --   E V E R E S T   E X T E N S I O N S
    // ----------------------------------------------------------------------



    /// @dev Add an everest extension
    function addEverestExtension(address _extension)
        public
        onlyOwner
    {
        require(_extension != address(0), "Missing extension");
        require(everestExtensions.length() < 5, "Max extension cap reached");
        require(!everestExtensions.contains(_extension), "Extension already exists");
        everestExtensions.add(_extension);

        emit EverestExtensionAdded(_extension);
    }

    /// @dev Remove an everest extension
    function removeEverestExtension(address _extension)
        public
        onlyOwner
    {
        require(_extension != address(0), "Missing extension");
        require(everestExtensions.contains(_extension), "Extension doesnt exist");

        everestExtensions.remove(_extension);

        emit EverestExtensionRemoved(_extension);
    }

    /// @dev Return list of everest extensions
    function getEverestExtensions()
        public view
        returns (address[] memory)
    {
        return everestExtensions.values();
    }

    /// @dev Get user everest owned
    function getUserEverestOwned(address _userAdd)
        public view
        returns (uint256)
    {
        return userEverestInfo[_userAdd].everestOwned;
    }

    function _updateEverestExtensionsUserEverestOwned(UserEverestInfo storage user)
        internal
    {
        // Iterate through and update each extension with the user's everest amount
        for (uint8 extensionIndex = 0; extensionIndex < everestExtensions.length(); extensionIndex++) {
            BaseEverestExtension(everestExtensions.at(extensionIndex)).updateUserEverest(user.everestOwned, user.userAdd);
        }
    }





    // -------------------------------------
    // --   P A N I C
    // -------------------------------------



    /// @dev Turn on or off panic mode
    function setPanic(bool _panic)
        public
        onlyOwner
    {
        panic = _panic;
        emit SetPanic(_panic);
    }


    /// @dev Panic recover locked SUMMIT if something has gone wrong
    function panicRecoverFunds()
        public
        nonReentrant userEverestInfoExists(msg.sender) onlyPanic
    {
        UserEverestInfo storage everestInfo = userEverestInfo[msg.sender];

        uint256 recoverableSummit = everestInfo.summitLocked;
        summit.safeTransfer(msg.sender, recoverableSummit);

        everestInfo.userAdd = address(0);
        everestInfo.everestOwned = 0;
        everestInfo.summitLocked = 0;
        everestInfo.lockRelease = 0;
        everestInfo.lockDuration = 0;
        everestInfo.everestLockMultiplier = 0;

        emit PanicFundsRecovered(msg.sender, recoverableSummit);
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

contract PresetPausable is AccessControlEnumerable {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bool public paused;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(PAUSER_ROLE, msg.sender);
        paused = false;
    }

    event Paused(address account);
    event Unpaused(address account);

    function _whenNotPaused() internal view {
        require(!paused, "Pausable: paused");
    }
    modifier whenNotPaused() {
        _whenNotPaused();
        _;
    }
    
    modifier whenPaused() {
        require(paused, "Pausable: not paused");
        _;
    }

    function pause() public virtual whenNotPaused {
        require(hasRole(PAUSER_ROLE, msg.sender), "Must have pauser role");
        paused = true;
        emit Paused(_msgSender());
    }

    function unpause() public virtual whenPaused {
        require(hasRole(PAUSER_ROLE, msg.sender), "Must have pauser role");
        paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

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
     * by making the `nonReentrant` function external, and make it call a
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
    function transfer(address recipient, uint256 amount) external returns (bool);

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
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
        IERC20 token,
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
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
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
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
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

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20Mintable is ERC20, Ownable {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) public onlyOwner virtual {
        _mint(to, amount);
    }
}

// SPDX-License-Identifier: MIT

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
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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

// SPDX-License-Identifier: MIT

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

pragma solidity ^0.8.0;

import "./IAccessControlEnumerable.sol";
import "./AccessControl.sol";
import "../utils/structs/EnumerableSet.sol";

/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Overload {grantRole} to track enumerable memberships
     */
    function grantRole(bytes32 role, address account) public virtual override(AccessControl, IAccessControl) {
        super.grantRole(role, account);
        _roleMembers[role].add(account);
    }

    /**
     * @dev Overload {revokeRole} to track enumerable memberships
     */
    function revokeRole(bytes32 role, address account) public virtual override(AccessControl, IAccessControl) {
        super.revokeRole(role, account);
        _roleMembers[role].remove(account);
    }

    /**
     * @dev Overload {renounceRole} to track enumerable memberships
     */
    function renounceRole(bytes32 role, address account) public virtual override(AccessControl, IAccessControl) {
        super.renounceRole(role, account);
        _roleMembers[role].remove(account);
    }

    /**
     * @dev Overload {_setupRole} to track enumerable memberships
     */
    function _setupRole(bytes32 role, address account) internal virtual override {
        super._setupRole(role, account);
        _roleMembers[role].add(account);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IAccessControl.sol";

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable is IAccessControl {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC165.sol";

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
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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

pragma solidity 0.8.2;

import "./Cartographer.sol";
import "./interfaces/ISubCart.sol";
import "./SummitToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";



/*
---------------------------------------------------------------------------------------------
--   S U M M I T . D E F I
---------------------------------------------------------------------------------------------


Summit is highly experimental.
It has been crafted to bring a new flavor to the defi world.
We hope you enjoy the Summit.defi experience.
If you find any bugs in these contracts, please claim the bounty (see docs)


Created with love by Architect and the Summit team





---------------------------------------------------------------------------------------------
--   O A S I S   E X P L A N A T I O N
---------------------------------------------------------------------------------------------


The OASIS is the safest of the elevations.
OASIS pools exactly mirror standard yield farming experiences of other projects.
OASIS pools guarantee yield, and no multiplying or risk takes place at this elevation.
The OASIS does not have totems in the contract, however in the frontend funds staked in the OASIS are represented by the OTTER.

*/
contract CartographerOasis is ISubCart, Initializable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;


    // ---------------------------------------
    // --   V A R I A B L E S
    // ---------------------------------------

    Cartographer public cartographer;
    uint256 public launchTimestamp = 1672527600;                        // 2023-1-1, will be updated when summit ecosystem switched on
    uint8 constant OASIS = 0;                                           // Named constant to make reusable elevation functions easier to parse visually
    address public summitTokenAddress;
    
    struct UserInfo {
        uint256 debt;                                                   // Debt is (accSummitPerShare * staked) at time of staking and is used in the calculation of yield.
        uint256 staked;                                                 // The amount a user invests in an OASIS pool
    }

    mapping(address => EnumerableSet.AddressSet) userInteractingPools;

    struct OasisPoolInfo {
        address token;                                                   // Reward token yielded by the pool

        uint256 supply;                                                 // Running total of the amount of tokens staked in the pool
        bool live;                                                      // Turns on and off the pool
        uint256 lastRewardTimestamp;                                    // Latest timestamp that SUMMIT distribution occurred
        uint256 accSummitPerShare;                                      // Accumulated SUMMIT per share, raised to 1e12
    }

    EnumerableSet.AddressSet poolTokens;

    mapping(address => OasisPoolInfo) public poolInfo;              // Pool info for each oasis pool
    mapping(address => mapping(address => UserInfo)) public userInfo;    // Users running staking information
    
    





    // ---------------------------------------
    // --  A D M I N I S T R A T I O N
    // ---------------------------------------


    /// @dev Constructor simply setting address of the cartographer
    constructor(address _Cartographer)
    {
        require(_Cartographer != address(0), "Cartographer required");
        cartographer = Cartographer(_Cartographer);
    }

    /// @dev Unused initializer as part of the SubCartographer interface
    function initialize(address, address _summitTokenAddress)
        external override
        initializer onlyCartographer
    {
        require(_summitTokenAddress != address(0), "SummitToken is zero");
        summitTokenAddress = _summitTokenAddress;
    }

    /// @dev Enables the Summit ecosystem with a timestamp, called by the Cartographer
    function enable(uint256 _launchTimestamp)
        external override
        onlyCartographer
    {
        launchTimestamp = _launchTimestamp;
    }
    





    // -----------------------------------------------------------------
    // --   M O D I F I E R S (Many are split to save contract size)
    // -----------------------------------------------------------------

    modifier onlyCartographer() {
        require(msg.sender == address(cartographer), "Only cartographer");
        _;
    }
    modifier validUserAdd(address userAdd) {
        require(userAdd != address(0), "User not 0");
        _;
    }
    modifier nonDuplicated(address _token) {
        require(!poolTokens.contains(_token), "duplicated!");
        _;
    }
    modifier poolExists(address _token) {
        require(poolTokens.contains(_token), "Pool doesnt exist");
        _;
    }
    




    // ---------------------------------------
    // --   U T I L S (inlined for brevity)
    // ---------------------------------------
    

    function supply(address _token) external view override returns (uint256) {
        return poolInfo[_token].supply;
    }
    function isTotemSelected(address) external pure override returns (bool) {
        return true;
    }
    function userStakedAmount(address _token, address _userAdd) external view override returns (uint256) {
        return userInfo[_token][_userAdd].staked;
    }

    function getUserInteractingPools(address _userAdd) public view returns (address[] memory) {
        return userInteractingPools[_userAdd].values();
    }
    function getPools() public view returns (address[] memory) {
        return poolTokens.values();
    }



    // ---------------------------------------
    // --   P O O L   M A N A G E M E N T
    // ---------------------------------------


    /// @dev Creates a pool at the oasis
    /// @param _token Pool token
    /// @param _live Whether the pool is enabled initially
    function add(address _token, bool _live)
        external override
        onlyCartographer nonDuplicated(_token)
    {
        // Add token to poolTokens
        poolTokens.add(_token);

        // Create the initial state of the pool
        poolInfo[_token] = OasisPoolInfo({
            token: _token,

            supply: 0,
            live: _live,
            accSummitPerShare: 0,
            lastRewardTimestamp: block.timestamp
        });
    }

    
    /// @dev Update a given pools deposit or live status
    /// @param _token Pool token identifier
    /// @param _live If pool is available for staking
    function set(address _token, bool _live)
        external override
        onlyCartographer poolExists(_token)
    {
        OasisPoolInfo storage pool = poolInfo[_token];

        updatePool(_token);

        // Update internal pool states
        pool.live = _live;
        
        // Update IsEarning in Cartographer
        _updateTokenIsEarning(pool);
    }


    /// @dev Mark whether this token is earning at this elevation in the Cartographer
    ///   Live must be true
    ///   Launched must be true
    ///   Staked supply must be non zero
    function _updateTokenIsEarning(OasisPoolInfo storage pool)
        internal
    {
        cartographer.setIsTokenEarningAtElevation(
            pool.token,
            OASIS,
            pool.live && pool.supply > 0
        );
    }


    /// @dev Update all pools to current timestamp before other pool management transactions
    function massUpdatePools()
        external override
        onlyCartographer
    {
        for (uint16 index = 0; index < poolTokens.length(); index++) {
            updatePool(poolTokens.at(index));
        }
    }
    

    /// @dev Bring reward variables of given pool current
    /// @param _token Pool identifier to update
    function updatePool(address _token)
        public
        poolExists(_token)
    {
        OasisPoolInfo storage pool = poolInfo[_token];

        // Early exit if pool already current
        if (pool.lastRewardTimestamp == block.timestamp) { return; }

        // Early exit if pool not launched, has 0 supply, or isn't live.
        // Still update last rewarded timestamp to prevent over emitting on first block on return to live
        if (block.timestamp < launchTimestamp || pool.supply == 0 || !pool.live) {
            pool.lastRewardTimestamp = block.timestamp;
            return;
        }

        // Ensure that pool doesn't earn rewards from before summit ecosystem launched
        if (pool.lastRewardTimestamp < launchTimestamp) {
            pool.lastRewardTimestamp = launchTimestamp;
            return;
        }

        // Mint Summit according to pool allocation and token share in pool, retrieve amount of summit minted for staking
        uint256 summitReward = cartographer.poolSummitEmission(pool.lastRewardTimestamp, pool.token, OASIS);

        // Update accSummitPerShare with the amount of staking summit minted.
        pool.accSummitPerShare = pool.accSummitPerShare + (summitReward * 1e12 / pool.supply);

        // Bring last reward timestamp current
        pool.lastRewardTimestamp = block.timestamp;
    }
    




    // ---------------------------------------
    // --   P O O L   R E W A R D S
    // ---------------------------------------


    /// @dev Claimable rewards of a pool
    function _poolClaimableRewards(OasisPoolInfo storage pool, UserInfo storage user)
        internal view
        poolExists(pool.token)
        returns (uint256)
    {
        // Temporary accSummitPerShare to bring rewards current if last reward timestamp is behind current timestamp
        uint256 accSummitPerShare = pool.accSummitPerShare;

        // Bring current if last reward timestamp is in past
        if (block.timestamp > launchTimestamp && block.timestamp > pool.lastRewardTimestamp && pool.supply != 0 && pool.live) {

            // Fetch the pool's summit yield emission to bring current
            uint256 poolSummitEmission = cartographer.poolSummitEmission(
                pool.lastRewardTimestamp < launchTimestamp ? launchTimestamp : pool.lastRewardTimestamp,
                pool.token,
                OASIS);

            // Recalculate accSummitPerShare with additional yield emission included
            accSummitPerShare = accSummitPerShare + (poolSummitEmission * 1e12 / pool.supply);
        }

        return (user.staked * accSummitPerShare / 1e12) - user.debt;
    }


    /// @dev Fetch guaranteed yield rewards of the pool
    /// @param _token Pool to fetch rewards from
    /// @param _userAdd User requesting rewards info
    /// @return claimableRewards: Amount of Summit available to Claim
    function poolClaimableRewards(address _token, address _userAdd)
        public view
        poolExists(_token) validUserAdd(_userAdd)
        returns (uint256)
    {
        return _poolClaimableRewards(
            poolInfo[_token],
            userInfo[_token][_userAdd]
        );
    }




    /// @dev Claimable rewards across an entire elevation
    /// @param _userAdd User Claiming
    function elevClaimableRewards(address _userAdd)
        public view
        validUserAdd(_userAdd)
        returns (uint256)
    {
        // Claim rewards of users active pools
        uint256 claimable = 0;

        // Iterate through pools the user is interacting, get claimable amount, update pool
        address[] memory interactingPools = userInteractingPools[_userAdd].values();
        for (uint8 index = 0; index < interactingPools.length; index++) {
            // Claim winnings
            claimable += _poolClaimableRewards(
                poolInfo[interactingPools[index]],
                userInfo[interactingPools[index]][_userAdd]
            );
        }
        
        return claimable;
    }






    // ------------------------------------------------------------------
    // --   Y I E L D    G A M B L I N G   S T U B S
    // ------------------------------------------------------------------
    

    function rollover() external override {}
    function switchTotem(uint8, address) external override {}




    // -----------------------------------------------------
    // --   P O O L   I N T E R A C T I O N S
    // -----------------------------------------------------


    /// @dev Increments or decrements user's pools at elevation staked, and adds to  / removes from users list of staked pools
    function _markUserInteractingWithPool(address _token, address _userAdd, bool _interacting) internal {
        // Early escape if interacting state already up to date
        if (userInteractingPools[_userAdd].contains(_token) == _interacting) return;

        // Validate staked pool cap
        require(!_interacting || userInteractingPools[_userAdd].length() < 12, "Staked pool cap (12) reached");

        if (_interacting) {
            userInteractingPools[_userAdd].add(_token);
        } else {
            userInteractingPools[_userAdd].remove(_token);
        }
    }

    /// @dev Claim an entire elevation
    /// @param _userAdd User Claiming
    function claimElevation(address _userAdd)
        external override
        validUserAdd(_userAdd) onlyCartographer
        returns (uint256)
    {
        // Claim rewards of users active pools
        uint256 claimable = 0;

        // Iterate through pools the user is interacting, get claimable amount, update pool
        address[] memory interactingPools = userInteractingPools[_userAdd].values();
        for (uint8 index = 0; index < interactingPools.length; index++) {
            // Claim winnings
            claimable += _unifiedClaim(
                poolInfo[interactingPools[index]],
                userInfo[interactingPools[index]][_userAdd],
                _userAdd
            );
        }
        
        return claimable;
    }

    /// @dev Stake funds in an OASIS pool
    /// @param _token Pool to stake in
    /// @param _amount Amount to stake
    /// @param _userAdd User wanting to stake
    /// @param _isElevate Whether this is the deposit half of an elevate tx
    /// @return Amount deposited after deposit fee taken
    function deposit(address _token, uint256 _amount, address _userAdd, bool _isElevate)
        external override
        nonReentrant onlyCartographer poolExists(_token) validUserAdd(_userAdd)
        returns (uint256)
    {
        // Claim earnings from pool
        _unifiedClaim(
            poolInfo[_token],
            userInfo[_token][_userAdd],
            _userAdd
        );

        // Deposit amount into pool
        return _unifiedDeposit(
            poolInfo[_token],
            userInfo[_token][_userAdd],
            _amount,
            _userAdd,
            _isElevate
        );
    }


    /// @dev Emergency withdraw without rewards
    /// @param _token Pool to emergency withdraw from
    /// @param _userAdd User emergency withdrawing
    /// @return Amount emergency withdrawn
    function emergencyWithdraw(address _token, address _userAdd)
        external override
        nonReentrant onlyCartographer poolExists(_token) validUserAdd(_userAdd)
        returns (uint256)
    {
        OasisPoolInfo storage pool = poolInfo[_token];
        UserInfo storage user = userInfo[_token][_userAdd];

        // Signal cartographer to perform withdrawal function
        uint256 amountAfterFee = cartographer.withdrawalTokenManagement(_userAdd, _token, user.staked);

        // Update pool running supply total with amount withdrawn
        pool.supply -= user.staked;

        // Reset user's staked and debt     
        user.staked = 0;
        user.debt = 0;

        // If the user is interacting with this pool after the meat of the transaction completes
        _markUserInteractingWithPool(_token, _userAdd, false);

        // Return amount withdrawn
        return amountAfterFee;
    }



    /// @dev Withdraw staked funds from pool
    /// @param _token Pool to withdraw from
    /// @param _amount Amount to withdraw
    /// @param _userAdd User withdrawing
    /// @param _isElevate Whether this is the withdraw half of an elevate tx
    /// @return True amount withdrawn
    function withdraw(address _token, uint256 _amount, address _userAdd, bool _isElevate)
        external override
        nonReentrant onlyCartographer poolExists(_token) validUserAdd(_userAdd)
        returns (uint256)
    {
        _unifiedClaim(
            poolInfo[_token],
            userInfo[_token][_userAdd],
            _userAdd
        );

        // Withdraw amount from pool
        return _unifiedWithdraw(
            poolInfo[_token],
            userInfo[_token][_userAdd],
            _amount,
            _userAdd,
            _isElevate
        );
    }




    /// @dev Shared Claim functionality with cross compounding built in
    /// @param pool OasisPoolInfo of pool to withdraw from
    /// @param user UserInfo of withdrawing user
    /// @param _userAdd User address
    /// @return Amount claimable
    function _unifiedClaim(OasisPoolInfo storage pool, UserInfo storage user, address _userAdd)
        internal
        returns (uint256)
    {
        updatePool(pool.token);

        // Check claimable rewards and withdraw if applicable
        uint256 claimable = (user.staked * pool.accSummitPerShare / 1e12) - user.debt;

        // Claim rewards, replace claimable with true claimed amount with bonuses included
        if (claimable > 0) {
            claimable = cartographer.claimWinnings(_userAdd, pool.token, claimable);
        }

        // Set debt, may be overwritten in subsequent deposit / withdraw, but may not so it needs to be set here
        user.debt = user.staked * pool.accSummitPerShare / 1e12;

        // Return amount Claimed / claimable
        return claimable;
    }


    /// @dev Internal shared deposit functionality for elevate or standard deposit
    /// @param pool OasisPoolInfo of pool to deposit into
    /// @param user UserInfo of depositing user
    /// @param _amount Amount to deposit
    /// @param _userAdd User address
    /// @param _isInternalTransfer Flag to switch off certain functionality if transfer is exclusively within summit ecosystem
    /// @return Amount deposited after fee taken
    function _unifiedDeposit(OasisPoolInfo storage pool, UserInfo storage user, uint256 _amount, address _userAdd, bool _isInternalTransfer)
        internal
        returns (uint256)
    {
        updatePool(pool.token);

        uint256 amountAfterFee = _amount;

        // Handle taking fees and adding to running supply if amount depositing is non zero
        if (_amount > 0) {

            // Only move tokens (and take fee) on external transactions
            if (!_isInternalTransfer) {
                amountAfterFee = cartographer.depositTokenManagement(_userAdd, pool.token, _amount);
            }
            
            // Increment running pool supply with amount after fee taken
            pool.supply += amountAfterFee;

            // Update IsEarning in Cartographer
            _updateTokenIsEarning(pool);
        }
        
        // Update user info with new staked value, and calculate new debt
        user.staked += amountAfterFee;
        user.debt = user.staked * pool.accSummitPerShare / 1e12;

        // If the user is interacting with this pool after the meat of the transaction completes
        _markUserInteractingWithPool(pool.token, _userAdd, user.staked > 0);

        // Return amount staked after fee        
        return amountAfterFee;
    }

    
    /// @dev Withdraw functionality shared between standardWithdraw and elevateWithdraw
    /// @param pool OasisPoolInfo of pool to withdraw from
    /// @param user UserInfo of withdrawing user
    /// @param _amount Amount to withdraw
    /// @param _userAdd User address
    /// @param _isInternalTransfer Flag to switch off certain functionality for elevate withdraw
    /// @return Amount withdrawn
    function _unifiedWithdraw(OasisPoolInfo storage pool, UserInfo storage user, uint256 _amount, address _userAdd, bool _isInternalTransfer)
        internal
        returns (uint256)
    {
        // Validate amount attempting to withdraw
        require(_amount > 0 && user.staked >= _amount, "Bad withdrawal");

        updatePool(pool.token);

        // Signal cartographer to perform withdrawal function if not elevating funds
        // Elevated funds remain in the cartographer, or in the passthrough target, so no need to withdraw from anywhere as they would be immediately re-deposited
        uint256 amountAfterFee = _amount;
        if (!_isInternalTransfer) {
            amountAfterFee = cartographer.withdrawalTokenManagement(_userAdd, pool.token, _amount);
        }

        // Update pool running supply total with amount withdrawn
        pool.supply -= _amount;

        // Update IsEarning in Cartographer
        _updateTokenIsEarning(pool);

        // Update user's staked and debt     
        user.staked -= _amount;
        user.debt = user.staked * pool.accSummitPerShare / 1e12;

        // If the user is interacting with this pool after the meat of the transaction completes
        _markUserInteractingWithPool(pool.token, _userAdd, user.staked > 0);

        // Return amount withdrawn
        return amountAfterFee;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.2;

import "./Cartographer.sol";
import "./ElevationHelper.sol";
import "./interfaces/ISubCart.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";


/*
---------------------------------------------------------------------------------------------
--   S U M M I T . D E F I
---------------------------------------------------------------------------------------------


Summit is highly experimental.
It has been crafted to bring a new flavor to the defi world.
We hope you enjoy the Summit.defi experience.
If you find any bugs in these contracts, please claim the bounty (see docs)


Created with love by Architect and the Summit team





---------------------------------------------------------------------------------------------
--   Y I E L D   G A M B L I N G   E X P L A N A T I O N
---------------------------------------------------------------------------------------------

Funds are staked in elevation farms, and the resulting yield is risked to earn a higher yield multiplier
The staked funds are safe from risk, and cannot ever be lost

STAKING:
    . 3 tiers exist: 2K - plains / 5K - mesa / 10K - summit
    . Each tier has a set of TOTEMs
    . Users select a totem to represent them at the 'multiplying table', shared by all pools at that elevation
    . Funds are staked / withdrawn in the same way as traditional pools / farms, represented by their selected totem
    . Over time, a user's BET builds up as traditional staking does
    . Instead of the staking yield being immediately available, it is risked against the yields of other stakers
    . BETs build over the duration of a ROUND
    . The summed BETs of all users is considered the POT for that round

ROUNDS:
    . Each tier has a different round duration: 2 hours - plains / 4 hours - mesa / 10 hours - summit
    . At the end of each round, the round is ROLLED OVER
    . The ROLLOVER selects a TOTEM as the winner for that round
    . All users represented by that TOTEM are considered winners of that round
    . The winning TOTEM wins the entire pot
    . Winning users split the whole pot, effectively earning the staking rewards of the other users
    . Winnings vest over the duration of the next round
    

    


---------------------------------------------------------------------------------------------
--   Y I E L D   G A M B L I N G   C A L C U L A T I O N S   O V E R V I E W
---------------------------------------------------------------------------------------------



POOL:
    . At the end of each round, during the 'rollover' process, the following is saved in `poolRoundInfo` to be used in user's winnings calculations:
        - endAccSummitPerShare - the accSummitPerShare when the round ended
        - winningsMultiplier - how much each user's yield reward is multiplied by: (pool roundRewards) / (pool winning totem roundRewards)
        - precomputedFullRoundMult - (the change in accSummitPerShare over the whole round) * (winningsMultiplier)


USER:
    . The user's funds can be left in a pool over multiple rounds without any interaction
    . On the fly calculation of all previous rounds winnings (if any) must be fast and efficient
    

    . Any user interaction with a pool updates the following in UserInfo:
        - user.prevInteractedRound - Marks that the current round is the user last interaction with this pool
        - user.staked - Amount staked in the pool
        - user.roundDebt - The current accSummitPerShare, used to calculate the rewards earned by the user from the current mid-round point, to the end of the round
        - user.roundRew - The user may interact with the same round multiple times without losing any existing farmed rewards, this stores any accumulated rewards that have built up mid round, and is increased with each subsequent round interaction in the same round
    

*/

contract CartographerElevation is ISubCart, Initializable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;



    // ---------------------------------------
    // --   V A R I A B L E S
    // ---------------------------------------

    Cartographer public cartographer;
    ElevationHelper public elevationHelper;
    uint8 public elevation;
    address public summitTokenAddress;


    struct UserInfo {
        // Yield Multiplying
        uint256 prevInteractedRound;                // Round the user last made a deposit / withdrawal / claim
        uint256 staked;                             // The amount of token the user has in the pool
        uint256 roundDebt;                          // Used to calculate user's first interacted round reward
        uint256 roundRew;                           // Running sum of user's rewards earned in current round

        uint256 winningsDebt;                       // AccWinnings of user's totem at time of deposit
    }

    struct UserElevationInfo {
        address userAdd;

        uint8 totem;
        bool totemSelected;
        uint256 totemSelectionRound;
    }
    
    mapping(address => EnumerableSet.AddressSet) userInteractingPools;
    
    struct RoundInfo {                              
        uint256 endAccSummitPerShare;               // The accSummitPerShare at the end of the round, used for back calculations
        uint256 winningsMultiplier;                 // Rewards multiplier: TOTAL POOL STAKED / WINNING TOTEM STAKED
        uint256 precomputedFullRoundMult;           // Gas optimization for back calculation: accSummitPerShare over round multiplied by winnings multiplier
    }

    struct ElevationPoolInfo {
        address token;                               // Address of reward token contract
        
        bool launched;                              // If the start round of the pool has passed and it is open for staking / rewards
        bool live;                                  // If the pool is running, in lieu of allocPoint
        bool active;                                // Whether the pool is active, used to keep pool alive until round rollover

        uint256 lastRewardTimestamp;                // Last timestamp that SUMMIT distribution occurs.
        uint256 accSummitPerShare;                  // Accumulated SUMMIT per share, raised 1e12. See below.

        uint256 supply;                             // Running total of the token amount staked in this pool at elevation
        uint256[] totemSupplies;                    // Running total of LP in each totem to calculate rewards
        uint256 roundRewards;                       // Rewards of entire pool accum over round
        uint256[] totemRoundRewards;                // Rewards of each totem accum over round

        uint256[] totemRunningPrecomputedMult;      // Running winnings per share for each totem
    }

    
    EnumerableSet.AddressSet private poolTokens;
    EnumerableSet.AddressSet private activePools;

    mapping(address => ElevationPoolInfo) public poolInfo;              // Pool info for each elevation pool
    mapping(address => mapping(uint256 => RoundInfo)) public poolRoundInfo;      // The round end information for each round of each pool
    mapping(address => mapping(address => UserInfo)) public userInfo;            // Users running staking / vesting information
    mapping(address => UserElevationInfo) public userElevationInfo;// User's totem info at each elevation

    mapping(uint256 => uint256) public roundWinningsMult;









    // ---------------------------------------
    // --  A D M I N I S T R A T I O N
    // ---------------------------------------


    /// @dev Constructor, setting address of cartographer
    constructor(address _Cartographer, uint8 _elevation)
    {
        require(_Cartographer != address(0), "Cartographer required");
        require(_elevation >= 1 && _elevation <= 3, "Invalid elevation");
        cartographer = Cartographer(_Cartographer);
        elevation = _elevation;
    }


    /// @dev Set address of ElevationHelper during initialization
    function initialize(address _ElevationHelper, address _summitTokenAddress)
        external override
        initializer onlyCartographer
    {
        require(_ElevationHelper != address(0), "Contract is zero");
        require(_summitTokenAddress != address(0), "SummitToken is zero");
        elevationHelper = ElevationHelper(_ElevationHelper);
        summitTokenAddress = _summitTokenAddress;
    }

    /// @dev Unused enable summit stub
    function enable(uint256) external override {}
    





    // ------------------------------------------------------
    // --   M O D I F I E R S 
    // ------------------------------------------------------

    function _onlyCartographer() internal view {
        require(msg.sender == address(cartographer), "Only cartographer");
    }
    modifier onlyCartographer() {
        _onlyCartographer();
        _;
    }
    function _totemSelected(address _userAdd) internal view returns (bool) {
        return userElevationInfo[_userAdd].totemSelected;
    }
    modifier userHasSelectedTotem(address _userAdd) {
        require(_totemSelected(_userAdd), "Totem not selected");
        _;
    }
    function _validUserAdd(address _userAdd) internal pure {
        require(_userAdd != address(0), "User address is zero");
    }
    modifier validUserAdd(address _userAdd) {
        _validUserAdd(_userAdd);
        _;
    }
    modifier nonDuplicated(address _token) {
        require(!poolTokens.contains(_token), "Duplicated");
        _;
    }
    modifier validTotem(uint8 _totem) {
        require(_totem < elevationHelper.totemCount(elevation), "Invalid totem");
        _;
    }
    modifier elevationTotemSelectionAvailable() {
        require(!elevationHelper.endOfRoundLockoutActive(elevation) || elevationHelper.elevationLocked(elevation), "Totem selection locked");
        _;
    }
    function _elevationInteractionsAvailable() internal view {
        require(!elevationHelper.endOfRoundLockoutActive(elevation), "Elev locked until rollover");
    }
    modifier elevationInteractionsAvailable() {
        _elevationInteractionsAvailable();
        _;
    }
    function _poolExists(address _token) internal view {
        require(poolTokens.contains(_token), "Pool doesnt exist");
    }
    modifier poolExists(address _token) {
        _poolExists(_token);
        _;
    }
    




    // ---------------------------------------
    // --   U T I L S (inlined for brevity)
    // ---------------------------------------
    

    function supply(address _token) external view override returns (uint256) {
        return poolInfo[_token].supply;
    }
    function _getUserTotem(address _userAdd) internal view returns (uint8) {
        return userElevationInfo[_userAdd].totem;
    }
    function isTotemSelected(address _userAdd) external view override returns (bool) {
        return _totemSelected(_userAdd);
    }
    function userStakedAmount(address _token, address _userAdd) external view override returns (uint256) {
        return userInfo[_token][_userAdd].staked;
    }

    function getUserInteractingPools(address _userAdd) public view returns (address[] memory) {
        return userInteractingPools[_userAdd].values();
    }
    function getPools() public view returns (address[] memory) {
        return poolTokens.values();
    }
    function getActivePools() public view returns (address[] memory) {
        return activePools.values();
    }
    function totemSupplies(address _token) public view poolExists(_token) returns (uint256[] memory) {
        return poolInfo[_token].totemSupplies;
    }


    /// @dev Calculate the emission to bring the selected pool current
    function emissionToBringPoolCurrent(ElevationPoolInfo memory pool) internal view returns (uint256) {
        // Early escape if pool is already up to date or not live
        if (block.timestamp == pool.lastRewardTimestamp || pool.supply == 0 || !pool.live || !pool.launched) return 0;
        
        // Get the (soon to be) awarded summit emission for this pool over the timespan that would bring current
        return cartographer.poolSummitEmission(pool.lastRewardTimestamp, pool.token, elevation);
    }


    /// @dev Calculates up to date pool round rewards and totem round rewards with pool's emission
    /// @param _token Pool identifier
    /// @return Up to date versions of round rewards.
    ///         [poolRoundRewards, ...totemRoundRewards]
    function totemRoundRewards(address _token)
        public view
        poolExists(_token)
        returns (uint256[] memory)
    {
        ElevationPoolInfo storage pool = poolInfo[_token];
        uint8 totemCount = elevationHelper.totemCount(elevation);
        uint256[] memory roundRewards = new uint256[](totemCount + 1);

        // Gets emission that would bring the pool current from last reward timestamp
        uint256 emissionToBringCurrent = emissionToBringPoolCurrent(pool);

        // Add total emission to bring current to pool round rewards
        roundRewards[0] = pool.roundRewards + emissionToBringCurrent;

        // For each totem, increase round rewards proportionally to amount staked in that totem compared to full pool's amount staked
        for (uint8 i = 0; i < totemCount; i++) {

            // If pool or totem doesn't have anything staked, the totem's round rewards won't change with the new emission
            if (pool.supply == 0 || pool.totemSupplies[i] == 0) {
                roundRewards[i + 1] = pool.totemRoundRewards[i];

            // Increase the totem's round rewards with a proportional amount of the new emission
            } else {
                roundRewards[i + 1] = pool.totemRoundRewards[i] + (emissionToBringCurrent * pool.totemSupplies[i] / pool.supply);
            }
        }

        // Return up to date round rewards
        return roundRewards;
    }
    




    // ---------------------------------------
    // --   P O O L   M A N A G E M E N T
    // ---------------------------------------

    function _markPoolActive(ElevationPoolInfo storage pool, bool _active)
        internal
    {
        if (pool.active == _active) return;

        require(!_active || (activePools.length() < 24), "Too many active pools");

        pool.active = _active;
        if (_active) {
            activePools.add(pool.token);
        } else {
            activePools.remove(pool.token);
        }
    }


    /// @dev Creates a new elevation yield multiplying pool
    /// @param _token Token of the pool (also identifier)
    /// @param _live Whether the pool is enabled initially
    /// @param _token Token yielded by pool
    function add(address _token, bool _live)
        external override
        onlyCartographer nonDuplicated(_token)
    {
        // Register pool token
        poolTokens.add(_token);

        // Create the initial state of the elevation pool
        poolInfo[_token] = ElevationPoolInfo({
            token: _token,

            launched: false,
            live: _live,
            active: false, // Will be made active in the add active pool below if _live is true

            supply: 0,
            accSummitPerShare : 0,
            lastRewardTimestamp : block.timestamp,

            totemSupplies : new uint256[](elevationHelper.totemCount(elevation)),
            roundRewards : 0,
            totemRoundRewards : new uint256[](elevationHelper.totemCount(elevation)),

            totemRunningPrecomputedMult: new uint256[](elevationHelper.totemCount(elevation))
        });

        if (_live) _markPoolActive(poolInfo[_token], true);
    }
    
    
    /// @dev Update a given pools deposit or live status
    /// @param _token Pool token
    /// @param _live If pool is available for staking
    function set(address _token, bool _live)
        external override
        onlyCartographer poolExists(_token)
    {
        ElevationPoolInfo storage pool = poolInfo[_token];
        updatePool(_token);

        // If pool is live, add to active pools list
        if (_live) _markPoolActive(pool, true);
        // Else pool is becoming inactive, which will be reflected at the end of the round in pool rollover function

        // Update IsEarning in Cartographer
        _updateTokenIsEarning(pool);

        // Update internal pool states
        pool.live = _live;
    }


    /// @dev Mark whether this token is earning at this elevation in the Cartographer
    ///   Active must be true
    ///   Launched must be true
    ///   Staked supply must be non zero
    function _updateTokenIsEarning(ElevationPoolInfo storage pool)
        internal
    {
        cartographer.setIsTokenEarningAtElevation(
            pool.token,
            elevation,
            pool.active && pool.launched && pool.supply > 0
        );
    }


    /// @dev Update all pools to current timestamp before other pool management transactions
    function massUpdatePools()
        external override
        onlyCartographer
    {
        for (uint16 index = 0; index < poolTokens.length(); index++) {
            updatePool(poolTokens.at(index));
        }
    }


    /// @dev Bring reward variables of given pool current
    /// @param _token Pool token
    function updatePool(address _token)
        public
        poolExists(_token)
    {
        ElevationPoolInfo storage pool = poolInfo[_token];

        // Early exit if the pool is already current
        if (pool.lastRewardTimestamp == block.timestamp) return;

        // Early exit if pool not launched, not live, or supply is 0
        // Timestamp still updated before exit to prevent over emission on return to live
        if (!pool.launched || pool.supply == 0 || !pool.live) {
            pool.lastRewardTimestamp = block.timestamp;
            return;
        }

        // Mint Summit according to time delta, pools token share and elevation, and tokens allocation share
        uint256 summitReward = cartographer.poolSummitEmission(pool.lastRewardTimestamp, pool.token, elevation);

        // Update accSummitPerShare with amount of summit minted for pool
        pool.accSummitPerShare += summitReward * 1e12 / pool.supply;
        
        // Update the overall pool summit rewards for the round (used in winnings multiplier at end of round)
        pool.roundRewards += summitReward;

        // Update each totem's summit rewards for the round (used in winnings multiplier at end of round)
        for (uint8 i = 0; i < pool.totemRoundRewards.length; i++) {
            pool.totemRoundRewards[i] += summitReward * pool.totemSupplies[i] / pool.supply;
        }     

        // Update last reward timestamp   
        pool.lastRewardTimestamp = block.timestamp;
    }
    




    // ---------------------------------------
    // --   P O O L   R E W A R D S
    // ---------------------------------------


    /// @dev Fetch claimable yield rewards amount of the pool
    /// @param _token Pool token to fetch rewards from
    /// @param _userAdd User requesting rewards info
    /// @return claimableRewards - Amount of Summit available to claim
    function poolClaimableRewards(address _token, address _userAdd)
        public view
        poolExists(_token) validUserAdd(_userAdd)
        returns (uint256)
    {
        ElevationPoolInfo storage pool = poolInfo[_token];
        UserInfo storage user = userInfo[_token][_userAdd];

        // Return claimable winnings
        return _claimableWinnings(pool, user, _userAdd);
    }


    /// @dev Fetch claimable yield rewards amount of the elevation
    /// @param _userAdd User requesting rewards info
    /// @return elevClaimableRewards: Amount of Summit available to claim across the elevation
    function elevClaimableRewards(address _userAdd)
        public view
        validUserAdd(_userAdd)
        returns (uint256)
    {
        // Claim rewards of users active pools
        uint256 claimable = 0;

        // Iterate through pools the user is interacting, get claimable amount, update pool
        address[] memory interactingPools = userInteractingPools[_userAdd].values();
        for (uint8 index = 0; index < interactingPools.length; index++) {
            // Claim winnings
            claimable += _claimableWinnings(
                poolInfo[interactingPools[index]],
                userInfo[interactingPools[index]][_userAdd],
                _userAdd
            );
        }
        
        return claimable;
    }



    /// @dev The user's yield generated across their active pools at this elevation, and the hypothetical winnings based on that yield
    /// @param _userAdd User to sum and calculate
    /// @return (
    ///     elevationYieldContributed - Total yieldContributed across all pools of this elevation
    ///     elevationPotentialWinnings - Total potential winnings from that yield for the user's selected totem
    /// )
    function elevPotentialWinnings(address _userAdd)
        public view
        validUserAdd(_userAdd)
        returns (uint256, uint256)
    {
        // Early exit if user hasn't selected their totem yet
        if (!userElevationInfo[_userAdd].totemSelected) return (0, 0);
        uint8 userTotem = userElevationInfo[_userAdd].totem;

        // Iterate through active pools of elevation, sums {users yield contributed, total rewards earned (all totems), and winning totems's rewards}
        uint256 userTotalYieldContributed = 0;
        uint256 elevTotalRewards = 0;
        uint256 userTotemTotalWinnings = 0;
        for (uint16 index = 0; index < activePools.length(); index++) {
            // Add live round rewards of pool and winning totem to elevation round reward accumulators
            (uint256 poolUserYieldContributed, uint256 poolRewards, uint256 poolUserTotemWinnings) = _liveUserAndPoolRoundRewards(
                activePools.at(index),
                userTotem,
                _userAdd
            );
            userTotalYieldContributed += poolUserYieldContributed;
            elevTotalRewards += poolRewards;
            userTotemTotalWinnings += poolUserTotemWinnings;
        }

        // Calculate the winnings multiplier of the users totem (assuming it wins)
        uint256 elevWinningsMult = userTotemTotalWinnings == 0 ? 0 : elevTotalRewards * 1e12 / userTotemTotalWinnings;

        return (
            userTotalYieldContributed,
            userTotalYieldContributed * elevWinningsMult / 1e12
        );
    }



    /// @dev The user's yield generated and contributed to this elevations round pot from a specific pool
    /// @param _token Pool token to check
    /// @param _userAdd User to check
    /// @return The yield from staking, which has been contributed during the current round
    function poolYieldContributed(address _token, address _userAdd)
        public view
        poolExists(_token) validUserAdd(_userAdd)
        returns (uint256)
    {
        // Calculate current accSummitPerShare to bring the pool current
        (uint256 accSummitPerShare,) = _liveAccSummitPerShare(poolInfo[_token]);

        // Return yield generated hypothetical yield (what the user would have earned if this was standard staking) with brought current accSummitPerShare
        return _liveYieldContributed(
            poolInfo[_token],
            userInfo[_token][_userAdd],
            accSummitPerShare
        );
    }


    /// @dev Calculates the accSummitPerShare if the pool was brought current and awarded summit emissions
    /// @param pool Elevation pool
    /// @return (
    ///     liveAccSummitPerShare - What the current accSummitPerShare of the pool would be if brought current
    ///     summitEmission - The awarded emission to the pool that would bring it current
    /// )
    function _liveAccSummitPerShare(ElevationPoolInfo memory pool)
        internal view
        returns (uint256, uint256)
    {
        // Calculate emission to bring the pool up to date
        uint256 emissionToBringCurrent = emissionToBringPoolCurrent(pool);

        // Calculate the new accSummitPerShare with the emission to bring current, and return both values
        return (
            pool.accSummitPerShare + (pool.supply == 0 ? 0 : (emissionToBringCurrent * 1e12 / pool.supply)),
            emissionToBringCurrent
        );
    }


    /// @dev The staking rewards that would be earned during the current round under standard staking conditions
    /// @param pool Pool info
    /// @param user User info
    /// @param accSummitPerShare Is brought current before call
    function _liveYieldContributed(ElevationPoolInfo memory pool, UserInfo storage user, uint256 accSummitPerShare)
        internal view
        returns (uint256)
    {
        uint256 currRound = elevationHelper.roundNumber(elevation);
        return user.prevInteractedRound == currRound ?

            // Change in accSummitPerShare from current timestamp to users previous interaction timestamp (factored into user.roundDebt)
            (user.staked * accSummitPerShare / 1e12) - user.roundDebt + user.roundRew :

            // Change in accSummitPerShare from current timestamp to beginning of round's timestamp (stored in previous round's endAccRewPerShare)
            user.staked * (accSummitPerShare - poolRoundInfo[pool.token][currRound - 1].endAccSummitPerShare) / 1e12;
    }


    /// @dev Brings the pool's round rewards, and the user's selected totem's round rewards current
    ///      Round rewards are the total amount of yield generated by a pool over the duration of a round
    ///      totemRoundRewards is the total amount of yield generated by the funds staked in each totem of the pool
    /// @param _token Pool token identifier
    /// @param _userTotem User's totem, gas saving
    /// @param _userAdd User's address to return yield generated totem to bring current
    /// @return (
    ///     userPoolYieldContributed - How much yield the user has contributed to the pot from this pool
    ///     liveRoundRewards - The brought current round rewards of the pool
    ///     liveUserTotemRoundRewards - The brought current round rewards of the user's selected totem
    /// )
    function _liveUserAndPoolRoundRewards(address _token, uint8 _userTotem, address _userAdd)
        internal view
        returns (uint256, uint256, uint256)
    {
        ElevationPoolInfo storage pool = poolInfo[_token];

        (uint256 liveAccSummitPerShare, uint256 emissionToBringCurrent) = _liveAccSummitPerShare(pool);

        return (
            // User's yield generated
            userInteractingPools[_userAdd].contains(_token) ? _liveYieldContributed(
                poolInfo[_token],
                userInfo[_token][_userAdd],
                liveAccSummitPerShare
            ) : 0,

            // Round rewards with the total emission to bring current added
            pool.roundRewards + emissionToBringCurrent,

            // Calculate user's totem's round rewards
            pool.supply == 0 || pool.totemSupplies[_userTotem] == 0 ? 
                
                // Early exit with current round rewards of user's totem if pool or user's totem has 0 supply (would cause div/0 error)
                pool.totemRoundRewards[_userTotem] :

                // Add the proportion of total emission that would be granted to the user's selected totem to that totem's round rewards
                // Proportion of total emission earned by each totem is (totem's staked supply / pool's staked supply)
                pool.totemRoundRewards[_userTotem] + (((emissionToBringCurrent * 1e12 * pool.totemSupplies[_userTotem]) / pool.supply) / 1e12)
        );
    }





    // ------------------------------------------------------------------
    // --   R O L L O V E R   E L E V A T I O N   R O U N D
    // ------------------------------------------------------------------
    
    
    /// @dev Sums the total rewards and winning totem rewards from each pool and determines the elevations winnings multiplier, then rolling over all active pools
    function rollover()
        external override
        onlyCartographer
    {
        uint256 prevRound = elevationHelper.roundNumber(elevation) == 0 ? 0 : elevationHelper.roundNumber(elevation) - 1;
        uint8 winningTotem = elevationHelper.winningTotem(elevation, prevRound);

        // Iterate through active pools of elevation, sum total rewards earned (all totems), and winning totems's rewards
        uint256 elevTotalRewards = 0;
        uint256 winningTotemRewards = 0;
        address[] memory pools = activePools.values();
        for (uint16 index = 0; index < pools.length; index++) {
            // Bring pool current
            updatePool(pools[index]);

            // Add round rewards of pool and winning totem to elevation round reward accumulators
            elevTotalRewards += poolInfo[pools[index]].roundRewards;
            winningTotemRewards += poolInfo[pools[index]].totemRoundRewards[winningTotem];
        }

        // Calculate the winnings multiplier of the round that just ended from the combined reward amounts
        roundWinningsMult[prevRound] = winningTotemRewards == 0 ? 0 : elevTotalRewards * 1e12 / winningTotemRewards;

        // Update and rollover all active pools
        for (uint16 index = 0; index < pools.length; index++) {
            // Rollover Pool
            rolloverPool(pools[index], prevRound, roundWinningsMult[prevRound]);
        }
    }
    
    
    /// @dev Roll over a single pool and create a new poolRoundInfo entry
    /// @param _token Pool to roll over
    /// @param _prevRound Round index of the round that just ended
    /// @param _winningsMultiplier Winnings mult of the winning totem based on rewards of entire elevation
    function rolloverPool(address _token, uint256 _prevRound, uint256 _winningsMultiplier)
        internal
    {
        ElevationPoolInfo storage pool = poolInfo[_token];

        // Remove pool from active pool list if it has been marked for removal
        if (!pool.live) _markPoolActive(pool, false);

        // Launch pool if it hasn't been, early exit since it has no earned rewards before launch
        if (!pool.launched) {
            pool.launched = true;
            _updateTokenIsEarning(pool);
            return;
        }

        // The change in accSummitPerShare from the end of the previous round to the end of the current round
        uint256 deltaAccSummitPerShare = pool.accSummitPerShare - poolRoundInfo[_token][_prevRound - 1].endAccSummitPerShare;
        uint256 precomputedFullRoundMult = deltaAccSummitPerShare * _winningsMultiplier / 1e12;

        // Increment running precomputed mult with previous round's data
        pool.totemRunningPrecomputedMult[elevationHelper.winningTotem(elevation, _prevRound)] += precomputedFullRoundMult;

        // Adding a new entry to the pool's poolRoundInfo for the most recently closed round
        poolRoundInfo[_token][_prevRound] = RoundInfo({
            endAccSummitPerShare: pool.accSummitPerShare,
            winningsMultiplier: _winningsMultiplier,
            precomputedFullRoundMult: precomputedFullRoundMult
        });

        // Resetting round reward accumulators to begin accumulating over the next round
        pool.roundRewards = 0;
        pool.totemRoundRewards = new uint256[](elevationHelper.totemCount(elevation));
    }
    



    // ------------------------------------------------------------
    // --   W I N N I N G S   C A L C U L A T I O N S 
    // ------------------------------------------------------------
    
    
    /// @dev Calculation of round rewards of the first round interacted
    /// @param user Users staking info
    /// @param round Passed in instead of used inline in this function to prevent stack too deep error
    /// @param _totem Totem to determine if round was won and winnings warranted
    /// @return Winnings from round
    function _userFirstInteractedRoundWinnings(UserInfo storage user, RoundInfo memory round, uint8 _totem)
        internal view
        returns (uint256)
    {
        if (_totem != elevationHelper.winningTotem(elevation, user.prevInteractedRound)) return 0;

        return ((user.staked * round.endAccSummitPerShare / 1e12) - user.roundDebt + user.roundRew) * round.winningsMultiplier / 1e12;
    }


    /// @dev Calculation of winnings that are available to be claimed
    /// @param pool Pool info
    /// @param user UserInfo
    /// @param _userAdd User's address passed through for win check
    /// @return Total claimable winnings for a user, including vesting on previous round's winnings (if any)
    function _claimableWinnings(ElevationPoolInfo storage pool, UserInfo storage user, address _userAdd)
        internal view
        returns (uint256)
    {
        uint256 currRound = elevationHelper.roundNumber(elevation);

        // Exit early if no previous round exists to have winnings, or user has already interacted this round
        if (!pool.launched || user.prevInteractedRound == currRound) return 0;

        uint8 totem = _getUserTotem(_userAdd);
        uint256 claimable = 0;

        // Get winnings from first user interacted round if it was won (requires different calculation)
        claimable += _userFirstInteractedRoundWinnings(user, poolRoundInfo[pool.token][user.prevInteractedRound], totem);

        // Escape early if user interacted during previous round
        if (user.prevInteractedRound == currRound - 1) return claimable;

        // The change in precomputed mult of the user's first interacting round, this value doesn't exist when user.winningsDebt is set, so must be included here
        uint256 firstInteractedRoundDeltaPrecomputedMult = totem == elevationHelper.winningTotem(elevation, user.prevInteractedRound) ?
            poolRoundInfo[pool.token][user.prevInteractedRound].precomputedFullRoundMult :
            0;
        uint256 winningsDebtAtEndOfFirstInteractedRound = user.winningsDebt + firstInteractedRoundDeltaPrecomputedMult;

        // Add multiple rounds of precomputed mult delta for all rounds between first interacted and most recent round
        claimable += user.staked * (pool.totemRunningPrecomputedMult[totem] - winningsDebtAtEndOfFirstInteractedRound) / 1e12;

        return claimable;
    }
    


    

    // ------------------------------------------------------------
    // --   W I N N I N G S   I N T E R A C T I O N S
    // ------------------------------------------------------------
    
    /// @dev Claim any available winnings, and 
    /// @param pool Pool info
    /// @param user User info
    /// @param _userAdd USer's address used for redeeming rewards and checking for if rounds won
    function _claimWinnings(ElevationPoolInfo storage pool, UserInfo storage user, address _userAdd)
        internal
        returns (uint256)
    {
        // Get user's winnings available for claim
        uint256 claimable = _claimableWinnings(pool, user, _userAdd);

        // Claim winnings if any available, return claimed amount with bonuses applied
        if (claimable > 0) {
            return cartographer.claimWinnings(_userAdd, pool.token, claimable);
        }

        return claimable;
    }


    /// @dev Update the users round interaction
    /// @param pool Pool info
    /// @param user User info
    /// @param _totem Totem (potentially new totem)
    /// @param _amount Amount depositing / withdrawing
    /// @param _isDeposit Flag to differentiate deposit / withdraw
    function _updateUserRoundInteraction(ElevationPoolInfo storage pool, UserInfo storage user, uint8 _totem, uint256 _amount, bool _isDeposit)
        internal
    {
        uint256 currRound = elevationHelper.roundNumber(elevation);

        // User already interacted this round, update the current round reward by adding staking rewards between two interactions this round
        if (user.prevInteractedRound == currRound) {
            user.roundRew += (user.staked * pool.accSummitPerShare / 1e12) - user.roundDebt;

        // User has no staked value, create a fresh round reward
        } else if (user.staked == 0) {
            user.roundRew = 0;

        // User interacted in some previous round, create a fresh round reward based on the current staked amount's staking rewards from the beginning of this round to the current point
        } else {
            // The accSummitPerShare at the beginning of this round. This is known to exist because a user has already interacted in a previous round
            uint256 roundStartAccSummitPerShare = poolRoundInfo[pool.token][currRound - 1].endAccSummitPerShare;

            // Round rew is the current staked amount * delta accSummitPerShare from the beginning of the round until now
            user.roundRew = user.staked * (pool.accSummitPerShare - roundStartAccSummitPerShare) / 1e12;
        }
        
        // Update the user's staked amount with either the deposit or withdraw amount
        if (_isDeposit) user.staked += _amount;
        else user.staked -= _amount;
        
        // Fresh calculation of round debt from the new staked amount
        user.roundDebt = user.staked * pool.accSummitPerShare / 1e12;

        // Acc Winnings Per Share of the user's totem
        user.winningsDebt = pool.totemRunningPrecomputedMult[_totem];

        // Update the user's previous interacted round to be this round
        user.prevInteractedRound = currRound;
    }

    


    

    // ------------------------------------------------------------
    // --   E L E V A T I O N   T O T E M S
    // ------------------------------------------------------------


    /// @dev Increments or decrements user's pools at elevation staked, and adds to  / removes from users list of staked pools
    function _markUserInteractingWithPool(address _token, address _userAdd, bool _interacting) internal {
        // Early escape if interacting state already up to date
        if (userInteractingPools[_userAdd].contains(_token) == _interacting) return;

        // Validate staked pool cap
        require(!_interacting || userInteractingPools[_userAdd].length() < 12, "Staked pool cap (12) reached");

        if (_interacting) {
            userInteractingPools[_userAdd].add(_token);
        } else {
            userInteractingPools[_userAdd].remove(_token);
        }
    }
    
    
    /// @dev All funds at an elevation share a totem. This function allows switching staked funds from one totem to another
    /// @param _totem New target totem
    /// @param _userAdd User requesting switch
    function switchTotem(uint8 _totem, address _userAdd)
        external override
        nonReentrant onlyCartographer validTotem(_totem) validUserAdd(_userAdd) elevationTotemSelectionAvailable
    {
        uint8 prevTotem = _getUserTotem(_userAdd);

        // Early exit if totem is same as current
        require(!_totemSelected(_userAdd) || prevTotem != _totem, "Totem must change");

        // Iterate through pools the user is interacting with and update totem
        uint256 claimable = 0;
        address[] memory interactingPools = userInteractingPools[_userAdd].values();
        for (uint8 index = 0; index < interactingPools.length; index++) {
            claimable += _switchTotemForPool(interactingPools[index], prevTotem, _totem, _userAdd);
        }

        // Update user's totem in state
        userElevationInfo[_userAdd].totem = _totem;
        userElevationInfo[_userAdd].totemSelected = true;
        userElevationInfo[_userAdd].totemSelectionRound = elevationHelper.roundNumber(elevation);
    }


    /// @dev Switch users funds (if any staked) to the new totem
    /// @param _token Pool identifier
    /// @param _prevTotem Totem the user is leaving
    /// @param _newTotem Totem the user is moving to
    /// @param _userAdd User doing the switch
    function _switchTotemForPool(address _token, uint8 _prevTotem, uint8 _newTotem, address _userAdd)
        internal
        returns (uint256)
    {
        UserInfo storage user = userInfo[_token][_userAdd];
        ElevationPoolInfo storage pool = poolInfo[_token];

        uint256 claimable = _unifiedClaim(
            pool,
            user,
            _newTotem,
            _userAdd
        );

        // Transfer supply and round rewards from previous totem to new totem
        pool.totemSupplies[_prevTotem] -= user.staked;
        pool.totemSupplies[_newTotem] += user.staked;
        pool.totemRoundRewards[_prevTotem] -= user.roundRew;
        pool.totemRoundRewards[_newTotem] += user.roundRew;

        return claimable;
    }
    


    

    // ------------------------------------------------------------
    // --   P O O L   I N T E R A C T I O N S
    // ------------------------------------------------------------


    /// @dev User interacting with pool getter
    function _userInteractingWithPool(UserInfo storage user)
        internal view
        returns (bool)
    {
        return (user.staked + user.roundRew) > 0;
    }



    /// @dev Claim an entire elevation's winnings
    /// @param _userAdd User claiming
    function claimElevation(address _userAdd)
        external override
        validUserAdd(_userAdd) elevationInteractionsAvailable onlyCartographer
        returns (uint256)
    {

        // Claim rewards of users active pools
        uint256 claimable = 0;

        // Iterate through pools the user is interacting, get claimable amount, update pool
        address[] memory interactingPools = userInteractingPools[_userAdd].values();
        for (uint8 index = 0; index < interactingPools.length; index++) {
            // Claim winnings
            claimable += _unifiedClaim(
                poolInfo[interactingPools[index]],
                userInfo[interactingPools[index]][_userAdd],
                _getUserTotem(_userAdd),
                _userAdd
            );
        }
        
        return claimable;
    }

    
    /// @dev Wrapper around cartographer token management on deposit
    function _depositTokenManagement(address _token, uint256 _amount, address _userAdd)
        internal
        returns (uint256)
    {
        return cartographer.depositTokenManagement(_userAdd, _token, _amount);
    }

    function _depositValidate(address _token, address _userAdd)
        internal view
        userHasSelectedTotem(_userAdd) poolExists(_token) validUserAdd(_userAdd) elevationInteractionsAvailable
    { return; }

    
    /// @dev Stake funds in a yield multiplying elevation pool
    /// @param _token Pool to stake in
    /// @param _amount Amount to stake
    /// @param _userAdd User wanting to stake
    /// @param _isElevate Whether this is the deposit half of an elevate tx
    /// @return Amount deposited after deposit fee taken
    function deposit(address _token, uint256 _amount, address _userAdd, bool _isElevate)
        external override
        nonReentrant onlyCartographer
        returns (uint256)
    {
        // User has selected their totem, pool exists, user is valid, elevation is open for interactions
        _depositValidate(_token, _userAdd);

        // Claim earnings from pool
        _unifiedClaim(
            poolInfo[_token],
            userInfo[_token][_userAdd],
            _getUserTotem(_userAdd),
            _userAdd
        );

        // Deposit amount into pool
        return _unifiedDeposit(
            poolInfo[_token],
            userInfo[_token][_userAdd],
            _amount,
            _userAdd,
            _isElevate
        );
    }


    /// @dev Emergency Withdraw reset user
    /// @param pool Pool info
    /// @param _userAdd USer's address used for redeeming rewards and checking for if rounds won
    function _emergencyWithdrawResetUser(ElevationPoolInfo storage pool, address _userAdd) internal {
        userInfo[pool.token][_userAdd] = UserInfo({
            roundRew: 0,
            staked: 0,
            roundDebt: 0,
            winningsDebt: 0,
            prevInteractedRound: 0
        });
    }


    /// @dev Emergency withdraw without rewards
    /// @param _token Pool to emergency withdraw from
    /// @param _userAdd User emergency withdrawing
    /// @return Amount emergency withdrawn
    function emergencyWithdraw(address _token, address _userAdd)
        external override
        nonReentrant onlyCartographer poolExists(_token) validUserAdd(_userAdd)
        returns (uint256)
    {
        ElevationPoolInfo storage pool = poolInfo[_token];
        UserInfo storage user = userInfo[_token][_userAdd];

        uint256 staked = user.staked;

        // Reset User Info
        _emergencyWithdrawResetUser(pool, _userAdd);
        
        // Signal cartographer to perform withdrawal function
        uint256 amountAfterFee = cartographer.withdrawalTokenManagement(_userAdd, _token, staked);

        // Remove withdrawn amount from pool's running supply accumulators
        pool.totemSupplies[_getUserTotem(_userAdd)] -= staked;
        pool.supply -= staked;

        // If the user is interacting with this pool after the meat of the transaction completes
        _markUserInteractingWithPool(_token, _userAdd, false);

        // Return amount withdraw
        return amountAfterFee;
    }


    /// @dev Withdraw staked funds from pool
    /// @param _token Pool to withdraw from
    /// @param _amount Amount to withdraw
    /// @param _userAdd User withdrawing
    /// @param _isElevate Whether this is the withdraw half of an elevate tx
    /// @return True amount withdrawn
    function withdraw(address _token, uint256 _amount, address _userAdd, bool _isElevate)
        external override
        nonReentrant onlyCartographer poolExists(_token) validUserAdd(_userAdd) elevationInteractionsAvailable
        returns (uint256)
    {
        // Claim earnings from pool
        _unifiedClaim(
            poolInfo[_token],
            userInfo[_token][_userAdd],
            _getUserTotem(_userAdd),
            _userAdd
        );

        // Withdraw amount from pool
        return _unifiedWithdraw(
            poolInfo[_token],
            userInfo[_token][_userAdd],
            _amount,
            _userAdd,
            _isElevate
        );
    }


    /// @dev Claim winnings from a pool
    /// @param pool ElevationPoolInfo of pool to withdraw from
    /// @param user UserInfo of withdrawing user
    /// @param _totem Users Totem (new totem if necessary)
    /// @param _userAdd User address
    /// @return Amount claimable
    function _unifiedClaim(ElevationPoolInfo storage pool, UserInfo storage user, uint8 _totem, address _userAdd)
        internal
        returns (uint256)
    {
        updatePool(pool.token);

        // Claim available winnings, returns claimed amount with bonuses applied
        uint256 claimable = _claimWinnings(pool, user, _userAdd);

        // Update the users round interaction, may be updated again in the same tx, but must be updated here to maintain state
        _updateUserRoundInteraction(pool, user, _totem, 0, true);

        // Update users pool interaction status, may be updated again in the same tx, but must be updated here to maintain state
        _markUserInteractingWithPool(pool.token, _userAdd, _userInteractingWithPool(user));

        // Return amount claimed / claimable
        return claimable;
    }


    /// @dev Internal shared deposit functionality for elevate or standard deposit
    /// @param pool Pool info of pool to deposit into
    /// @param user UserInfo of depositing user
    /// @param _amount Amount to deposit
    /// @param _userAdd User address
    /// @param _isInternalTransfer Flag to switch off certain functionality for elevate deposit
    /// @return Amount deposited after fee taken
    function _unifiedDeposit(ElevationPoolInfo storage pool, UserInfo storage user, uint256 _amount, address _userAdd, bool _isInternalTransfer)
        internal
        returns (uint256)
    {
        updatePool(pool.token);
        uint8 totem = _getUserTotem(_userAdd);

        uint256 amountAfterFee = _amount;

        // Take deposit fee and add to running supplies if amount is non zero
        if (_amount > 0) {

            // Only take deposit fee on standard deposit
            if (!_isInternalTransfer)
                amountAfterFee = _depositTokenManagement(pool.token, _amount, _userAdd);

            // Adding staked amount to running supply accumulators
            pool.totemSupplies[totem] += amountAfterFee;
            pool.supply += amountAfterFee;

            _updateTokenIsEarning(pool);
        }
        
        // Update / create users interaction with the pool
        _updateUserRoundInteraction(pool, user, totem, amountAfterFee, true);

        // Update users pool interaction status
        _markUserInteractingWithPool(pool.token, _userAdd, _userInteractingWithPool(user));

        // Return true amount deposited in pool
        return amountAfterFee;
    }


    /// @dev Withdraw functionality shared between standardWithdraw and elevateWithdraw
    /// @param pool Pool to withdraw from
    /// @param user UserInfo of withdrawing user
    /// @param _amount Amount to withdraw
    /// @param _userAdd User address
    /// @param _isInternalTransfer Flag to switch off certain functionality for elevate withdraw
    /// @return Amount withdrawn
    function _unifiedWithdraw(ElevationPoolInfo storage pool, UserInfo storage user, uint256 _amount, address _userAdd, bool _isInternalTransfer)
        internal
        returns (uint256)
    {
        // Validate amount attempting to withdraw
        require(_amount > 0 && user.staked >= _amount, "Bad withdrawal");
        
        uint8 totem = _getUserTotem(_userAdd);

        // Bring pool to present
        updatePool(pool.token);

        // Update the users interaction in the pool
        _updateUserRoundInteraction(pool, user, totem, _amount, false);
        
        // Signal cartographer to perform withdrawal function if not elevating funds
        // Elevated funds remain in the cartographer, or in the passthrough target, so no need to withdraw from anywhere as they would be immediately re-deposited
        uint256 amountAfterFee = _amount;
        if (!_isInternalTransfer) {
            amountAfterFee = cartographer.withdrawalTokenManagement(_userAdd, pool.token, _amount);
        }

        // Remove withdrawn amount from pool's running supply accumulators
        pool.totemSupplies[totem] -= _amount;
        pool.supply -= _amount;

        _updateTokenIsEarning(pool);

        // If the user is interacting with this pool after the meat of the transaction completes
        _markUserInteractingWithPool(pool.token, _userAdd, _userInteractingWithPool(user));

        // Return amount withdraw
        return amountAfterFee;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "./interfaces/ISummitRNGModule.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";



/*
---------------------------------------------------------------------------------------------
--   S U M M I T . D E F I
---------------------------------------------------------------------------------------------


Summit is highly experimental.
It has been crafted to bring a new flavor to the defi world.
We hope you enjoy the Summit.defi experience.
If you find any bugs in these contracts, please claim the bounty (see docs)


Created with love by Architect and the Summit team





---------------------------------------------------------------------------------------------
--   E L E V A T I O N   H E L P E R
---------------------------------------------------------------------------------------------


ElevationHelper.sol handles shared functionality between the elevations / expedition
Handles the allocation multiplier for each elevation
Handles the duration of each round



*/

contract ElevationHelper is Ownable {
    // ---------------------------------------
    // --   V A R I A B L E S
    // ---------------------------------------

    address public cartographer;                                            // Allows cartographer to act as secondary owner-ish
    address public expeditionV2;

    // Constants for elevation comparisons
    uint8 constant OASIS = 0;
    uint8 constant PLAINS = 1;
    uint8 constant MESA = 2;
    uint8 constant SUMMIT = 3;
    uint8 constant EXPEDITION = 4;
    uint8 constant roundEndLockoutDuration = 120;

    
    uint16[5] public allocMultiplier = [100, 110, 125, 150, 100];            // Alloc point multipliers for each elevation    
    uint16[5] public pendingAllocMultiplier = [100, 110, 125, 150, 100];     // Pending alloc point multipliers for each elevation, updated at end of round for elevation, instantly for oasis   
    uint8[5] public totemCount = [1, 2, 5, 10, 2];                          // Number of totems at each elevation

    
    uint256 constant baseRoundDuration = 3600;                              // Duration (seconds) of the smallest round chunk
    uint256[5] public durationMult = [0, 2, 2, 2, 6];                      // Number of round chunks for each elevation
    uint256[5] public pendingDurationMult = [0, 2, 2, 2, 6];               // Duration mult that takes effect at the end of the round

    uint256[5] public unlockTimestamp;                                      // Time at which each elevation unlocks to the public
    uint256[5] public roundNumber;                                          // Current round of each elevation
    uint256[5] public roundEndTimestamp;                                    // Time at which each elevation's current round ends
    mapping(uint256 => uint256) public expeditionDeityDivider;                // Higher / lower integer for each expedition round

    mapping(uint8 => mapping(uint256 => uint256)) public totemWinsAccum;    // Accumulator of the total number of wins for each totem
    mapping(uint8 => mapping(uint256 => uint8)) public winningTotem;        // The specific winning totem for each elevation round


    address public summitRNGModuleAdd;                                      // VRF module address



    // ---------------------------------------
    // --   E V E N T S
    // ---------------------------------------

    event WinningTotemSelected(uint8 indexed elevation, uint256 indexed round, uint8 indexed totem);
    event DeityDividerSelected(uint256 indexed expeditionRound, uint256 indexed deityDivider);
    event UpgradeSummitRNGModule(address indexed _summitRNGModuleAdd);
    event SetElevationRoundDurationMult(uint8 indexed _elevation, uint8 _mult);
    event SetElevationAllocMultiplier(uint8 indexed _elevation, uint16 _allocMultiplier);



    
    // ---------------------------------------
    // --   I N I T I A L I Z A T I O N
    // ---------------------------------------

    /// @dev Creates ElevationHelper contract with cartographer as owner of certain functionality
    /// @param _cartographer Address of main Cartographer contract
    constructor(address _cartographer, address _expeditionV2) {
        require(_cartographer != address(0), "Cartographer missing");
        require(_expeditionV2 != address(0), "Expedition missing");
        cartographer = _cartographer;
        expeditionV2 = _expeditionV2;
    }

    /// @dev Turns on the Summit ecosystem across all contracts
    /// @param _enableTimestamp Timestamp at which Summit was enabled, used to set unlock points for each elevation
    function enable(uint256 _enableTimestamp)
        external
        onlyCartographer
    {
        // The next top of hour from the enable timestamp
        uint256 nextHourTimestamp = _enableTimestamp + (3600 - (_enableTimestamp % 3600));

        // Setting when each elevation of the ecosystem unlocks
        unlockTimestamp = [
            nextHourTimestamp,                       // Oasis - throwaway
            nextHourTimestamp + 0 days,              // Plains
            nextHourTimestamp + 1 days,              // Mesa
            nextHourTimestamp + 2 days,              // Summit
            nextHourTimestamp + 3 days               // Expedition
        ];

        // The first 'round' ends when the elevation unlocks
        roundEndTimestamp = unlockTimestamp;
        
        // Timestamp of the first seed round starting
        ISummitRNGModule(summitRNGModuleAdd).setSeedRoundEndTimestamp(unlockTimestamp[PLAINS] - roundEndLockoutDuration);
    }



    // ---------------------------------------
    // --   M O D I F I E R S
    // ---------------------------------------

    modifier onlyCartographer() {
        require(msg.sender == cartographer, "Only cartographer");
        _;
    }
    modifier onlyCartographerOrExpedition() {
        require(msg.sender == cartographer || msg.sender == expeditionV2, "Only cartographer or expedition");
        _;
    }
    modifier allElevations(uint8 _elevation) {
        require(_elevation <= EXPEDITION, "Bad elevation");
        _;
    }
    modifier elevationOrExpedition(uint8 _elevation) {
        require(_elevation >= PLAINS && _elevation <= EXPEDITION, "Bad elevation");
        _;
    }
    





    // ---------------------------------------
    // --   U T I L S (inlined for brevity)
    // ---------------------------------------


    /// @dev Allocation multiplier of an elevation
    /// @param _elevation Desired elevation
    function elevationAllocMultiplier(uint8 _elevation) public view returns (uint256) {
        return uint256(allocMultiplier[_elevation]);
    }
    
    /// @dev Duration of elevation round in seconds
    /// @param _elevation Desired elevation
    function roundDurationSeconds(uint8 _elevation) public view returns (uint256) {
        return durationMult[_elevation] * baseRoundDuration;
    }

    /// @dev Current round of the expedition
    function currentExpeditionRound() public view returns (uint256) {
        return roundNumber[EXPEDITION];
    }

    /// @dev Deity divider (random offset which skews chances of each deity winning) of the current expedition round
    function currentDeityDivider() public view returns (uint256) {
        return expeditionDeityDivider[currentExpeditionRound()];
    }

    /// @dev Modifies a given alloc point with the multiplier of that elevation, used to set a single allocation for a token while each elevation is set automatically
    /// @param _allocPoint Base alloc point to modify
    /// @param _elevation Fetcher for the elevation multiplier
    function elevationModulatedAllocation(uint256 _allocPoint, uint8 _elevation) external view allElevations(_elevation) returns (uint256) {
        return _allocPoint * allocMultiplier[_elevation];
    }

    /// @dev Checks whether elevation is is yet to be unlocked for farming
    /// @param _elevation Which elevation to check
    function elevationLocked(uint8 _elevation) external view returns (bool) {
        return block.timestamp <= unlockTimestamp[_elevation];
    }

    /// @dev Checks whether elevation is locked due to round ending in next {roundEndLockoutDuration} seconds
    /// @param _elevation Which elevation to check
    function endOfRoundLockoutActive(uint8 _elevation) external view returns (bool) {
        if (roundEndTimestamp[_elevation] == 0) return false;
        return block.timestamp >= (roundEndTimestamp[_elevation] - roundEndLockoutDuration);
    }

    /// @dev The next round available for a new pool to unlock at. Used to add pools but not start them until the next rollover
    /// @param _elevation Which elevation to check
    function nextRound(uint8 _elevation) external view returns (uint256) {
        return block.timestamp <= unlockTimestamp[_elevation] ? 1 : (roundNumber[_elevation] + 1);
    }

    /// @dev Whether a round has ended
    /// @param _elevation Which elevation to check
    function roundEnded(uint8 _elevation) internal view returns (bool) {
        return block.timestamp >= roundEndTimestamp[_elevation];
    }

    /// @dev Seconds remaining in round of elevation
    /// @param _elevation Which elevation to check time remaining of
    function timeRemainingInRound(uint8 _elevation) public view returns (uint256) {
        return roundEnded(_elevation) ? 0 : roundEndTimestamp[_elevation] - block.timestamp;
    }

    /// @dev Getter of fractional amount of round remaining
    /// @param _elevation Which elevation to check progress of
    /// @return Fraction raised to 1e12
    function fractionRoundRemaining(uint8 _elevation) external view returns (uint256) {
        return timeRemainingInRound(_elevation) * 1e12 / roundDurationSeconds(_elevation);
    }

    /// @dev Getter of fractional progress through round
    /// @param _elevation Which elevation to check progress of
    /// @return Fraction raised to 1e12
    function fractionRoundComplete(uint8 _elevation) external view returns (uint256) {
        return ((roundDurationSeconds(_elevation) - timeRemainingInRound(_elevation)) * 1e12) / roundDurationSeconds(_elevation);
    }

    /// @dev Start timestamp of current round
    /// @param _elevation Which elevation to check
    function currentRoundStartTime(uint8 _elevation) external view returns(uint256) {
        return roundEndTimestamp[_elevation] - roundDurationSeconds(_elevation);
    }




    
    // ------------------------------------------------------------------
    // --   P A R A M E T E R S
    // ------------------------------------------------------------------

    /// @dev Upgrade the RNG module when VRF becomes available on FTM, will only use `getRandomNumber` functionality
    /// @param _summitRNGModuleAdd Address of new VRF randomness module
    function upgradeSummitRNGModule (address _summitRNGModuleAdd)
        public
        onlyOwner
    {
        require(_summitRNGModuleAdd != address(0), "SummitRandomnessModule missing");
        summitRNGModuleAdd = _summitRNGModuleAdd;
        emit UpgradeSummitRNGModule(_summitRNGModuleAdd);
    }


    /// @dev Update round duration mult of an elevation
    function setElevationRoundDurationMult(uint8 _elevation, uint8 _mult)
        public
        onlyOwner elevationOrExpedition(_elevation)
    {
        require(_mult > 0, "Duration mult must be non zero");
        pendingDurationMult[_elevation] = _mult;
        emit SetElevationRoundDurationMult(_elevation, _mult);
    }


    /// @dev Update emissions multiplier of an elevation
    function setElevationAllocMultiplier(uint8 _elevation, uint16 _allocMultiplier)
        public
        onlyOwner allElevations(_elevation)
    {
        require(_allocMultiplier <= 300, "Multiplier cannot exceed 3X");
        pendingAllocMultiplier[_elevation] = _allocMultiplier;
        if (_elevation == OASIS) {
            allocMultiplier[_elevation] = _allocMultiplier;
        }
        emit SetElevationAllocMultiplier(_elevation, _allocMultiplier);
    }



    // ------------------------------------------------------------------
    // --   R O L L O V E R   E L E V A T I O N   R O U N D
    // ------------------------------------------------------------------


    /// @dev Validates that the selected elevation is able to be rolled over
    /// @param _elevation Which elevation is attempting to be rolled over
    function validateRolloverAvailable(uint8 _elevation)
        external view
    {
        // Elevation must be unlocked for round to rollover
        require(block.timestamp >= unlockTimestamp[_elevation], "Elevation locked");
        // Rollover only becomes available after the round has ended, if timestamp is before roundEnd, the round has already been rolled over and its end timestamp pushed into the future
        require(block.timestamp >= roundEndTimestamp[_elevation], "Round already rolled over");
    }


    /// @dev Uses the seed and future block number to generate a random number, which is then used to select the winning totem and if necessary the next deity divider
    /// @param _elevation Which elevation to select winner for
    function selectWinningTotem(uint8 _elevation)
        external
        onlyCartographerOrExpedition elevationOrExpedition(_elevation)
    {
        uint256 rand = ISummitRNGModule(summitRNGModuleAdd).getRandomNumber(_elevation, roundNumber[_elevation]);

        // Uses the random number to select the winning totem
        uint8 winner = chooseWinningTotem(_elevation, rand);

        // Updates data with the winning totem
        markWinningTotem(_elevation, winner);

        // If necessary, uses the random number to generate the next deity divider for expeditions
        if (_elevation == EXPEDITION)
            setNextDeityDivider(rand);
    }


    /// @dev Final step in the rollover pipeline, incrementing the round numbers to bring current
    /// @param _elevation Which elevation is being updated
    function rolloverElevation(uint8 _elevation)
        external
        onlyCartographerOrExpedition
    {
        // Incrementing round number, does not need to be adjusted with overflown rounds
        roundNumber[_elevation] += 1;

        // Failsafe to cover multiple rounds needing to be rolled over if no user rolled them over previously (almost impossible, but just in case)
        uint256 overflownRounds = ((block.timestamp - roundEndTimestamp[_elevation]) / roundDurationSeconds(_elevation));
        
        // Brings current with any extra overflown rounds
        roundEndTimestamp[_elevation] += roundDurationSeconds(_elevation) * overflownRounds;

        // Updates round duration if necessary
        if (pendingDurationMult[_elevation] != durationMult[_elevation]) {
            durationMult[_elevation] = pendingDurationMult[_elevation];
        }

        // Adds the duration of the current round (updated if necessary) to the current round end timestamp
        roundEndTimestamp[_elevation] += roundDurationSeconds(_elevation);

        // Updates elevation allocation multiplier if necessary
        if (pendingAllocMultiplier[_elevation] != allocMultiplier[_elevation]) {
            allocMultiplier[_elevation] = pendingAllocMultiplier[_elevation];
        }
    }


    /// @dev Simple modulo on generated random number to choose the winning totem (inlined for brevity)
    /// @param _elevation Which elevation the winner will be selected for
    /// @param _rand The generated random number to select with
    function chooseWinningTotem(uint8 _elevation, uint256 _rand) internal view returns (uint8) {
        if (_elevation == EXPEDITION)
            return (_rand % 100) < currentDeityDivider() ? 0 : 1;

        return uint8((_rand * totemCount[_elevation]) / 100);
    }


    /// @dev Stores selected winning totem (inlined for brevity)
    /// @param _elevation Elevation to store at
    /// @param _winner Selected winning totem
    function markWinningTotem(uint8 _elevation, uint8 _winner) internal {
        totemWinsAccum[_elevation][_winner] += 1;
        winningTotem[_elevation][roundNumber[_elevation]] = _winner;   

        emit WinningTotemSelected(_elevation, roundNumber[_elevation], _winner);
    }


    /// @dev Sets random deity divider (50 - 90) for next expedition round (inlined for brevity)
    /// @param _rand Same rand that chose winner
    function setNextDeityDivider(uint256 _rand) internal {
        // Number between 50 - 90 based on previous round winning number, helps to balance the divider between the deities
        uint256 expedSelector = (_rand % 100);
        uint256 divider = 50 + ((expedSelector * 40) / 100);
        expeditionDeityDivider[currentExpeditionRound() + 1] = divider;

        emit DeityDividerSelected(currentExpeditionRound() + 1, divider);
    }


    
    
    // ------------------------------------------------------------------
    // --   F R O N T E N D
    // ------------------------------------------------------------------
    
    /// @dev Fetcher of historical data for past winning totems
    /// @param _elevation Which elevation to check historical winners of
    /// @return Array of 20 values, first 10 of which are win count accumulators for each totem, last 10 of which are winners of previous 10 rounds of play
    function historicalWinningTotems(uint8 _elevation) public view allElevations(_elevation) returns (uint256[] memory, uint256[] memory) {

        uint256 round = roundNumber[_elevation];
        uint256 winHistoryDepth = Math.min(10, round);

        uint256[] memory winsAccum = new uint256[](totemCount[_elevation]);
        uint256[] memory prevWinHistory = new uint256[](winHistoryDepth);

        if (_elevation > OASIS) {
            uint256 prevRound = round == 0 ? 0 : round - 1;
            for (uint8 i = 0; i < totemCount[_elevation]; i++) {
                winsAccum[i] = totemWinsAccum[_elevation][i];
            }
            for (uint8 j = 0; j < winHistoryDepth; j++) {
                prevWinHistory[j] = winningTotem[_elevation][prevRound - j];
            }
        }

        return (winsAccum, prevWinHistory);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

library SummitMath {

    function scaledValue(uint256 scalar, uint256 minBound, uint256 maxBound, uint256 minResult, uint256 maxResult)
        internal pure
        returns (uint256)
    {
        require(minBound <= maxBound, "Invalid scaling range");
        if (minResult == maxResult) return minResult;
        if (scalar <= minBound) return minResult;
        if (scalar >= maxBound) return maxResult;
        if (maxResult > minResult) {
            return (((scalar - minBound) * (maxResult - minResult) * 1e12) / (maxBound - minBound) / 1e12) + minResult;
        }
        return (((maxBound - scalar) * (minResult - maxResult) * 1e12) / (maxBound - minBound) / 1e12) + maxResult;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


interface ISubCart {
    function initialize(address _elevationHelper, address _summit) external;
    function enable(uint256 _launchTimestamp) external;
    function add(address _token, bool _live) external;
    function set(address _token, bool _live) external;
    function massUpdatePools() external;

    function rollover() external;

    function switchTotem(uint8 _totem, address _userAdd) external;
    function claimElevation(address _userAdd) external returns (uint256);
    function deposit(address _token, uint256 _amount, address _userAdd, bool _isElevate) external returns (uint256);
    function emergencyWithdraw(address _token, address _userAdd) external returns (uint256);
    function withdraw(address _token, uint256 _amount, address _userAdd, bool _isElevate) external returns (uint256);
 
    function supply(address _token) external view returns (uint256);
    function isTotemSelected(address _userAdd) external view returns (bool);

    function userStakedAmount(address _token, address _userAdd) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


/// @dev Passthrough is an interface to send tokens to another contract and use the reward token in the Summit ecocystem
interface IPassthrough {
    function token() external view returns (IERC20);
    function enact() external;
    function deposit(uint256, address, address) external returns (uint256);
    function withdraw(uint256, address, address) external returns (uint256);
    function retire(address, address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.2;

import "./EverestToken.sol";

abstract contract BaseEverestExtension {

    EverestToken public everest;

    modifier onlyEverestToken() {
        require(msg.sender == address(everest), "Only callable by ExpeditionV2");
        _;
    }

    function _getUserEverest(address _userAdd)
        internal view
        returns (uint256)
    {
        return everest.getUserEverestOwned(_userAdd);
    }

    function updateUserEverest(uint256 _everestAmount, address _userAdd)
        external virtual;
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.2;


interface ISummitRNGModule {
    function getRandomNumber(uint8 elevation, uint256 roundNumber) external view returns (uint256);
    function setSeedRoundEndTimestamp(uint256 _seedRoundEndTimestamp) external;
}