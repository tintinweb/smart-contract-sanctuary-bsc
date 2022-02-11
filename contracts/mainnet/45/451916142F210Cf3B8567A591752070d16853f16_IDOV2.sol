// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.4;

import "openzeppelin-upgradeable4/security/ReentrancyGuardUpgradeable.sol";
import "openzeppelin-upgradeable4/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "./libraries/BP.sol";
import "./libraries/UQ112x112.sol";
import "./interfaces/IIDOV2.sol";
import "./interfaces/IStaking.sol";
import "./interfaces/IWhitelist.sol";
import "./interfaces/ILotteryInfo.sol";
import "./interfaces/IRandomGenerator.sol";
import "./interfaces/IReferrersData.sol";
import "./interfaces/IReferralPool.sol";
import "./interfaces/IPool.sol";

/// @title IDO contract (2nd version)
contract IDOV2 is IIDOV2, UUPSUpgradeable, ReentrancyGuardUpgradeable {

    using ERC165Checker for address;
    using SafeERC20 for IERC20;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    address public override registry;
    address public override staking;
    address public override buyToken;
    address public override referralPool;
    address public override referrersData;
    address public override whitelist;
    address public override lotteryInfo;
    address public override randomGenerator;

    uint public override totalTickets;
    uint public override totalBoughtInToken;
    uint public override distributedAmountInToken;
    uint public override registrationStartTimestamp;
    uint public override registrationEndTimestamp;
    uint public override startTimestamp;
    uint public override maxTicketsPerUser;
    uint public override allocationPerTicketInBuyToken;
    uint public override openRoundMinStakingPower;
    uint public override openRoundMaxAllocationInBuyToken;
    uint public override maxAllocationInToken;
    uint128 public rangeStep;
    uint32 public override placements;
    uint16 public override easeInBP;

    mapping(address => uint) public override lotteryTicketsOf;
    mapping(address => uint) public override amountOf;

    Round public exclusiveRound;
    Round public openRound;
    Range[] public ranges;

    address private _projectFundsHolder;
    address private _referrerBreakageFundsHolder;

    /// @notice Initialize contract
    /// @param initializeParams Params for initialization
    function initialize(InitializeParams calldata initializeParams) initializer external {
        require(
            initializeParams.registry != address(0) &&
            initializeParams.staking != address(0) &&
            initializeParams.buyToken != address(0) &&
            initializeParams.projectFundsHolder != address(0) && 
            initializeParams.referrerBreakageFundsHolder != address(0) && 
            initializeParams.referralPool != address(0) &&
            initializeParams.referrersData != address(0) &&
            initializeParams.distributedAmountInToken != 0 &&
            initializeParams.registrationStartTimestamp != 0 &&
            initializeParams.registrationEndTimestamp != 0 &&
            initializeParams.startTimestamp != 0 &&
            initializeParams.maxTicketsPerUser != 0 &&
            initializeParams.openRoundMinStakingPower != 0 &&
            initializeParams.allocationPerTicketInBuyToken != 0 &&
            initializeParams.openRoundMaxAllocationInBuyToken != 0 &&
            initializeParams.placements > 0 && 
            initializeParams.easeInBP <= BP.DECIMAL_FACTOR,
            "IDOV2: ZERO"
        );
        require(
            initializeParams.whitelist.supportsInterface(type(IWhitelist).interfaceId) &&
            initializeParams.lotteryInfo.supportsInterface(type(ILotteryInfo).interfaceId) &&
            initializeParams.randomGenerator.supportsInterface(type(IRandomGenerator).interfaceId), 
            "IDOV2: ADDRESS_NOT_SUPPORTED"
        );
        require(
            initializeParams.registrationEndTimestamp > initializeParams.registrationStartTimestamp && 
            initializeParams.startTimestamp > initializeParams.registrationEndTimestamp, 
            "IDOV2: INVALID_TIME"
        );

        __ReentrancyGuard_init();

        registry = initializeParams.registry;
        staking = initializeParams.staking;
        buyToken = initializeParams.buyToken;
        _projectFundsHolder = initializeParams.projectFundsHolder;
        _referrerBreakageFundsHolder = initializeParams.referrerBreakageFundsHolder;
        referralPool = initializeParams.referralPool;
        whitelist = initializeParams.whitelist;
        referrersData = initializeParams.referrersData;
        lotteryInfo = initializeParams.lotteryInfo;
        randomGenerator = initializeParams.randomGenerator;

        registrationStartTimestamp = initializeParams.registrationStartTimestamp;
        maxTicketsPerUser = initializeParams.maxTicketsPerUser;
        openRoundMinStakingPower = initializeParams.openRoundMinStakingPower;
        allocationPerTicketInBuyToken = initializeParams.allocationPerTicketInBuyToken;
        openRoundMaxAllocationInBuyToken = initializeParams.openRoundMaxAllocationInBuyToken;
        placements = initializeParams.placements;
        easeInBP = initializeParams.easeInBP;
        rangeStep = initializeParams.rangeStep;

        for (uint i; i < initializeParams.ranges.length; ++i) {
            ranges.push(initializeParams.ranges[i]);
        }

        _setDistributedAmountInToken(initializeParams.distributedAmountInToken);
        _setRegistrationEndTimestamp(initializeParams.registrationEndTimestamp);
        _setStartTimestamp(initializeParams.startTimestamp);
        _setExclusiveRoundEnd(initializeParams.exclusiveRound.maxEndTimestamp);
        _setOpenRoundEnd(initializeParams.openRound.maxEndTimestamp);
        _setPrice(initializeParams.exclusiveRound.priceTokenPerBuyTokenInUQ);
    }

    /// @notice IDO info
    /// @param _account User's account
    /// @return _details Info
    function info(address _account) external view override returns (InfoIDODetails memory _details) {
        IStaking.InfoAccountDetails memory stakingDetails = IStaking(staking).info(_account);
        (uint32 stakingPowerInitialBreak, uint32 participationBreak) = IStaking(staking).stakingPowerData();
        _details = InfoIDODetails({
            buyToken: buyToken,
            referralPool: referralPool,
            distributedAmountInToken: distributedAmountInToken,
            registrationStartTimestamp: registrationStartTimestamp,
            registrationEndTimestamp: registrationEndTimestamp,
            startTimestamp: startTimestamp,
            totalBoughtInToken: totalBoughtInToken,
            lotteryTicketsOfAccount: lotteryTicketsOf[_account],
            stakingPowerOfAccount: stakingDetails.accountDetails.totalStakingPower,
            amountOfAccountInToken: amountOf[_account],
            availableRewardToClaim: IPool(referralPool).withdrawableRewardsOf(_account),
            lastIDOParticipationOfAccount: stakingDetails.accountDetails.lastIDOParticipation,
            stakingPowerForOneTicket: ILotteryInfo(lotteryInfo).stakingPowerForOneTicket(),
            openRoundMinStakingPower: openRoundMinStakingPower,
            allocationPerTicketInBuyToken: allocationPerTicketInBuyToken,
            maxTicketsPerUser: maxTicketsPerUser,
            openRoundMaxAllocationInBuyToken: openRoundMaxAllocationInBuyToken,
            stakingPowerInitialBreak: stakingPowerInitialBreak,
            participationBreak: participationBreak,
            exclusiveRound: exclusiveRound,
            openRound: openRound
        });
    }

    /// @notice Set ease in BP
    /// @param _easeInBP New ease in BP
    function setEaseInBP(uint16 _easeInBP) external override onlyRole(DEFAULT_ADMIN_ROLE) nonReentrant {
        require(_easeInBP <= BP.DECIMAL_FACTOR, "IDOV2: INVALID");
        require(IRandomGenerator(randomGenerator).seedOf(address(this)) == 0, "IDOV2: ALREADY_PLAYED");
        easeInBP = _easeInBP;
        emit SetEaseInBP(msg.sender, _easeInBP);
    }

    /// @notice Set distributed amount
    /// @param _distributedAmountInToken Amount
    function setDistributedAmountInToken(uint _distributedAmountInToken) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _setDistributedAmountInToken(_distributedAmountInToken);
    }

    /// @notice Set registration end
    /// @param _registrationEndTimestamp End
    function setRegistrationEndTimestamp(uint _registrationEndTimestamp) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _setRegistrationEndTimestamp(_registrationEndTimestamp);
    }

    /// @notice Set IDO start
    /// @param _startTimestamp New IDO start
    function setStartTimestamp(uint _startTimestamp) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _setStartTimestamp(_startTimestamp);
    }

    /// @notice Set exclusive round end
    /// @param _endTimestamp New exclusive timestamp
    function setExclusiveRoundEnd(uint _endTimestamp) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _setExclusiveRoundEnd(_endTimestamp);
    }

    /// @notice Set open round end
    /// @param _endTimestamp New end timestamp
    function setOpenRoundEnd(uint _endTimestamp) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _setOpenRoundEnd(_endTimestamp);
    }

    /// @notice Set price
    /// @param _priceTokenPerBuyTokenInUQ New price
    function setPrice(uint _priceTokenPerBuyTokenInUQ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _setPrice(_priceTokenPerBuyTokenInUQ);
    }

    /// @notice Set range allocations
    /// @param _allocations New allocations
    function setRangeAllocations(uint128[] calldata _allocations) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _setRangeAllocations(_allocations);
    }

    /// @notice Ask for unique seed. Only admin can call this function
    function requestSeed() external override onlyRole(DEFAULT_ADMIN_ROLE) nonReentrant {
        require(block.timestamp >= registrationEndTimestamp, "IDOV2: INVALID_TIME");
        IRandomGenerator(randomGenerator).requestRandom(address(this));
    }

    /// @notice IDO registration. User should pass KYC and has staking power in order to participate
    /// @param _registerParams Registration params
    function register(RegisterParams calldata _registerParams) 
        external
        override
        nonReentrant 
        requireKYC(_registerParams.signatures, _registerParams.signers)
        updateStakingPower(_registerParams.idsToUpdate)
    {
        require(block.timestamp >= registrationStartTimestamp && block.timestamp < registrationEndTimestamp, "IDOV2: INVALID_TIME");
        require(lotteryTicketsOf[msg.sender] == 0, "IDOV2: ALREADY_REGISTERED");
        require(IStaking(staking).canParticipate(msg.sender), "IDOV2: CANNOT_PARTICIPATE");
        IStaking.InfoAccountDetails memory stakingDetails = IStaking(staking).info(msg.sender);
        uint tickets = Math.min(ILotteryInfo(lotteryInfo).lotteryTicketsForPower(stakingDetails.accountDetails.totalStakingPower), maxTicketsPerUser);
        require(tickets > 0, "IDOV2: NO_TICKETS");
        lotteryTicketsOf[msg.sender] = tickets;
        totalTickets += tickets;
        ++ranges[tickets * ILotteryInfo(lotteryInfo).stakingPowerForOneTicket() / rangeStep].registeredUserCount;
        IStaking(staking).setLastRegistrationDate(msg.sender, block.timestamp);
        emit Register(msg.sender, tickets);
    }

    /// @notice Unregister for an IDO
    function unregister() external override nonReentrant {
        require(block.timestamp < registrationEndTimestamp, "IDOV2: INVALID_TIME");
        uint userTickets = lotteryTicketsOf[msg.sender];
        require(userTickets > 0, "IDOV2: NO_REGISTRATION");

        lotteryTicketsOf[msg.sender] = 0;
        totalTickets -= userTickets;
        --ranges[userTickets * ILotteryInfo(lotteryInfo).stakingPowerForOneTicket() / rangeStep].registeredUserCount;
        IStaking(staking).setLastRegistrationDate(msg.sender, 0);
        emit Unregister(msg.sender);
    }

    /// @notice Buy tokens (in exclusive round - only if won in the lottery)
    /// @param _buyParams Buy params
    function buy(BuyParams calldata _buyParams) 
        external
        override
        nonReentrant 
        requireKYC(_buyParams.signatures, _buyParams.signers)
        updateStakingPower(_buyParams.idsToUpdate)
    {
        require(block.timestamp >= startTimestamp && block.timestamp < openRound.maxEndTimestamp, "IDOV2: INVALID_TIME");
        require(totalBoughtInToken < distributedAmountInToken, "IDOV2: NO_TOKENS");

        IStaking.InfoAccountDetails memory stakingDetails = IStaking(staking).info(msg.sender);
        uint stakingPower = stakingDetails.accountDetails.totalStakingPower;

        uint amountInToken;
        uint maxAllocation;
        if (block.timestamp < exclusiveRound.maxEndTimestamp) { // if exclusive round
            uint lotteryTickets = victoryTicketsCount(msg.sender);
            uint requiredPower = _buyParams.amountInBuyToken * ILotteryInfo(lotteryInfo).stakingPowerForOneTicket() / allocationPerTicketInBuyToken;
            require(stakingPower >= requiredPower, "IDOV2: INVALID_STAKING_POWER");
            maxAllocation = (lotteryTickets * allocationPerTicketInBuyToken) * exclusiveRound.priceTokenPerBuyTokenInUQ / UQ112x112.Q112;
            amountInToken = _buyParams.amountInBuyToken * exclusiveRound.priceTokenPerBuyTokenInUQ / UQ112x112.Q112;
            IStaking(staking).setLastParticipationDate(msg.sender, block.timestamp);
            emit PrivateRoundBuy(msg.sender, _buyParams.amountInBuyToken, amountInToken);
        } else {
            require(stakingPower >= openRoundMinStakingPower, "IDOV2: INVALID_STAKING_POWER");
            maxAllocation = maxAllocationInToken;
            amountInToken = _buyParams.amountInBuyToken * openRound.priceTokenPerBuyTokenInUQ / UQ112x112.Q112;
            emit PublicRoundBuy(msg.sender, _buyParams.amountInBuyToken, amountInToken);
        }

        require(amountInToken > 0, "IDOV2: TOKEN_AMOUNT_TOO_SMALL");
        require((amountOf[msg.sender] + amountInToken) <= maxAllocation, "IDOV2: ALLOCATION");
        uint _totalBoughtInToken = totalBoughtInToken + amountInToken;
        require(_totalBoughtInToken <= distributedAmountInToken, "IDOV2: MAX");

        IERC20(buyToken).safeTransferFrom(msg.sender, _projectFundsHolder, _buyParams.amountInBuyToken);
        _addReferralsToReferralPool(msg.sender, _buyParams.amountInBuyToken * 500 / BP.DECIMAL_FACTOR);
        totalBoughtInToken = _totalBoughtInToken;
        amountOf[msg.sender] += amountInToken;
    }

    modifier onlyRole(bytes32 role) {
        require(IAccessControl(registry).hasRole(role, msg.sender), "IDOV2: FORBIDDEN");
        _;
    }

    modifier requireKYC(bytes[] calldata _signatures, address[] calldata _signers) {
        bytes memory data = abi.encode(msg.sender, address(this));
        require(IWhitelist(whitelist).isAddressWhitelisted(data, _signatures, _signers), "IDOV2: USER_SHOULD_PASS_KYC");
        _;
    }

    modifier updateStakingPower(uint[] calldata _idsToUpdate) {
        if (_idsToUpdate.length > 0) {
            IStaking(staking).updateStakingPower(msg.sender, _idsToUpdate);
        }
        _;
    }

    /// @notice Get number of tickets that won in the lottery
    /// @param _account User
    /// @return count Number of tickets
    function victoryTicketsCount(address _account) public override view returns (uint count) {
        uint seed = IRandomGenerator(randomGenerator).seedOf(address(this));
        if (seed == 0 || placements == 0 || totalTickets == 0) {
            return 0;
        }
        uint ticketCount = lotteryTicketsOf[_account];
        uint thresholdInBP = placements * BP.DECIMAL_FACTOR / totalTickets;
        thresholdInBP = Math.min(BP.DECIMAL_FACTOR, thresholdInBP * (BP.DECIMAL_FACTOR + easeInBP) / BP.DECIMAL_FACTOR);
        for (uint i; i < ticketCount; ++i) {
            uint randomInBP = uint(keccak256(abi.encode(seed, _account, i))) % BP.DECIMAL_FACTOR;
            if (randomInBP <= thresholdInBP) {
                count++;
            }
        }
    }

    function _authorizeUpgrade(address) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}

    function _addReferralsToReferralPool(address _account, uint _sharesToMint) private {
        (address parent, address grandparent) = IReferrersData(referrersData).parentsOf(_account);
        _addReferralToReferralPool(parent, _sharesToMint);
        _addReferralToReferralPool(grandparent, _sharesToMint);
    }

    function _addReferralToReferralPool(address _account, uint _sharesToMint) private {
        IPool(referralPool).mint(_account == address(0) ? _referrerBreakageFundsHolder : _account, _sharesToMint);
    }

    function _setDistributedAmountInToken(uint _distributedAmountInToken) private {
        distributedAmountInToken = _distributedAmountInToken;
        emit SetDistributedAmountInToken(msg.sender, _distributedAmountInToken);
    }

    function _setRegistrationEndTimestamp(uint _registrationEndTimestamp) private {
        require(_registrationEndTimestamp > registrationStartTimestamp, "IDOV2: INVALID");
        registrationEndTimestamp = _registrationEndTimestamp;
        emit SetRegistrationEndTimestamp(msg.sender, _registrationEndTimestamp);
    }

    function _setStartTimestamp(uint _startTimestamp) private {
        require(_startTimestamp > registrationEndTimestamp, "IDOV2: INVALID");
        startTimestamp = _startTimestamp;
        emit SetStartTimestamp(msg.sender, _startTimestamp);
    }

    function _setExclusiveRoundEnd(uint _endTimestamp) private {
        require(_endTimestamp > startTimestamp, "IDOV2: INVALID");
        exclusiveRound.maxEndTimestamp = _endTimestamp;
        emit SetExclusiveRoundEnd(msg.sender, _endTimestamp);
    }

    function _setOpenRoundEnd(uint _endTimestamp) private {
        require(_endTimestamp >= exclusiveRound.maxEndTimestamp, "IDOV2: INVALID");
        openRound.maxEndTimestamp = _endTimestamp;
        emit SetOpenRoundEnd(msg.sender, _endTimestamp);
    }

    function _setPrice(uint _priceTokenPerBuyTokenInUQ) private {
        require(_priceTokenPerBuyTokenInUQ > 0, "IDOV2: INVALID");
        exclusiveRound.priceTokenPerBuyTokenInUQ = _priceTokenPerBuyTokenInUQ;
        openRound.priceTokenPerBuyTokenInUQ = _priceTokenPerBuyTokenInUQ;
        maxAllocationInToken = openRoundMaxAllocationInBuyToken * _priceTokenPerBuyTokenInUQ / UQ112x112.Q112;
        emit SetPrice(msg.sender, _priceTokenPerBuyTokenInUQ);
    }

    function _setRangeAllocations(uint128[] calldata _allocations) private {
        require(_allocations.length == ranges.length, "IDOV2: INVALID_LENGTH");
        for (uint i; i < _allocations.length; ++i) {
            ranges[i].allocation = _allocations[i];
        }
    }
 
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;

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
abstract contract UUPSUpgradeable is Initializable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
        __ERC1967Upgrade_init_unchained();
        __UUPSUpgradeable_init_unchained();
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
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, new bytes(0), false);
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
        _upgradeToAndCallSecure(newImplementation, data, true);
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
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;
}

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
     * bearer except when using {_setupRole}.
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
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/
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
     *  /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/
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
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
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
        // (a + b) / 2 can overflow, so we distribute.
        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
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

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Library used to query support of an interface declared via {IERC165}.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */
library ERC165Checker {
    // As per the EIP-165 spec, no interface should ever match 0xffffffff
    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    /**
     * @dev Returns true if `account` supports the {IERC165} interface,
     */
    function supportsERC165(address account) internal view returns (bool) {
        // Any contract that implements ERC165 must explicitly indicate support of
        // InterfaceId_ERC165 and explicitly indicate non-support of InterfaceId_Invalid
        return
            _supportsERC165Interface(account, type(IERC165).interfaceId) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    /**
     * @dev Returns true if `account` supports the interface defined by
     * `interfaceId`. Support for {IERC165} itself is queried automatically.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        // query support of both ERC165 as per the spec and support of _interfaceId
        return supportsERC165(account) && _supportsERC165Interface(account, interfaceId);
    }

    /**
     * @dev Returns a boolean array where each value corresponds to the
     * interfaces passed in and whether they're supported or not. This allows
     * you to batch check interfaces for a contract where your expectation
     * is that some interfaces may not be supported.
     *
     * See {IERC165-supportsInterface}.
     *
     * _Available since v3.4._
     */
    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {
        // an array of booleans corresponding to interfaceIds and whether they're supported or not
        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        // query support of ERC165 itself
        if (supportsERC165(account)) {
            // query support of each interface in interfaceIds
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = _supportsERC165Interface(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    /**
     * @dev Returns true if `account` supports all the interfaces defined in
     * `interfaceIds`. Support for {IERC165} itself is queried automatically.
     *
     * Batch-querying can lead to gas savings by skipping repeated checks for
     * {IERC165} support.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {
        // query support of ERC165 itself
        if (!supportsERC165(account)) {
            return false;
        }

        // query support of each interface in _interfaceIds
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        // all interfaces supported
        return true;
    }

    /**
     * @notice Query if a contract implements an interface, does not check ERC165 support
     * @param account The address of the contract to query for support of an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return true if the contract at account indicates support of the interface with
     * identifier interfaceId, false otherwise
     * @dev Assumes that account contains a contract that supports ERC165, otherwise
     * the behavior of this method is undefined. This precondition can be checked
     * with {supportsERC165}.
     * Interface identification is specified in ERC-165.
     */
    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {
        bytes memory encodedParams = abi.encodeWithSelector(IERC165(account).supportsInterface.selector, interfaceId);
        (bool success, bytes memory result) = account.staticcall{gas: 30000}(encodedParams);
        if (result.length < 32) return false;
        return success && abi.decode(result, (bool));
    }
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0;

library BP {
    uint16 constant DECIMAL_FACTOR = 10000;
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0;

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))

// range: [0, 2**112 - 1]
// resolution: 1 / 2**112

library UQ112x112 {
    uint224 constant Q112 = 2**112;

    // encode a uint112 as a UQ112x112
    function encode(uint112 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112; // never overflows
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        z = x / uint224(y);
    }
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.4;

interface IIDOV2 {
    event SetEaseInBP(address sender, uint16 easeInBP);
    event Register(address indexed account, uint tickets);
    event Unregister(address indexed account);
    event PrivateRoundBuy(address indexed account, uint amountInBuyToken, uint amountInToken);
    event PublicRoundBuy(address indexed account, uint amountInBuyToken, uint amountInToken);

    event SetDistributedAmountInToken(address sender, uint distributedAmountInToken);
    event SetRegistrationEndTimestamp(address sender, uint timestamp);
    event SetStartTimestamp(address sender, uint timestamp);
    event SetExclusiveRoundEnd(address sender, uint timestamp);
    event SetOpenRoundEnd(address sender, uint timestamp);
    event SetPrice(address sender, uint end);

    struct Round {
        uint maxEndTimestamp;
        uint priceTokenPerBuyTokenInUQ;
    }

    struct Range {
        uint128 allocation;
        uint128 registeredUserCount;
    }

    struct InitializeParams {
        address registry;
        address staking;
        address buyToken;
        address projectFundsHolder;
        address referrerBreakageFundsHolder;
        address referralPool;
        address whitelist;
        address referrersData;
        address lotteryInfo;
        address randomGenerator;
        uint distributedAmountInToken;
        uint registrationStartTimestamp;
        uint registrationEndTimestamp;
        uint startTimestamp;
        uint maxTicketsPerUser;
        uint allocationPerTicketInBuyToken;
        uint openRoundMinStakingPower;
        uint openRoundMaxAllocationInBuyToken;
        uint32 placements;
        uint16 easeInBP;
        uint128 rangeStep;
        Round exclusiveRound;
        Round openRound;
        Range[] ranges;
    }

    struct InfoIDODetails {
        address buyToken;
        address referralPool;
        uint distributedAmountInToken;
        uint registrationStartTimestamp;
        uint registrationEndTimestamp;
        uint startTimestamp;
        uint totalBoughtInToken;
        uint lotteryTicketsOfAccount;
        uint stakingPowerOfAccount;
        uint amountOfAccountInToken;
        uint availableRewardToClaim;
        uint lastIDOParticipationOfAccount;
        uint stakingPowerForOneTicket;
        uint openRoundMinStakingPower;
        uint allocationPerTicketInBuyToken;
        uint openRoundMaxAllocationInBuyToken;
        uint maxTicketsPerUser;
        uint32 stakingPowerInitialBreak;
        uint32 participationBreak;
        Round exclusiveRound;
        Round openRound;
    }

    struct RegisterParams {
        uint[] idsToUpdate;
        bytes[] signatures;
        address[] signers;
    }

    struct BuyParams {
        uint amountInBuyToken;
        uint[] idsToUpdate;
        bytes[] signatures;
        address[] signers;
    }

    function registry() external view returns (address);
    function staking() external view returns (address);
    function buyToken() external view returns (address);
    function referralPool() external view returns (address);
    function referrersData() external view returns (address);
    function whitelist() external view returns (address);
    function lotteryInfo() external view returns (address);
    function randomGenerator() external view returns (address);

    function totalTickets() external view returns (uint);
    function totalBoughtInToken() external view returns (uint);
    function distributedAmountInToken() external view returns (uint);
    function registrationStartTimestamp() external view returns (uint);
    function registrationEndTimestamp() external view returns (uint);
    function startTimestamp() external view returns (uint);
    function maxTicketsPerUser() external view returns (uint);
    function allocationPerTicketInBuyToken() external view returns (uint);
    function openRoundMinStakingPower() external view returns (uint);
    function openRoundMaxAllocationInBuyToken() external view returns (uint);
    function placements() external view returns (uint32);
    function easeInBP() external view returns (uint16);
    function maxAllocationInToken() external view returns (uint);

    function lotteryTicketsOf(address) external view returns (uint);
    function amountOf(address) external view returns (uint);

    function info(address _account) external view returns (InfoIDODetails memory _details);
    function setEaseInBP(uint16 _easeInBP) external;
    function setDistributedAmountInToken(uint _distributedAmountInToken) external;
    function setRegistrationEndTimestamp(uint _registrationEndTimestamp) external;
    function setStartTimestamp(uint _startTimestamp) external;
    function setExclusiveRoundEnd(uint _endTimestamp) external;
    function setOpenRoundEnd(uint _endTimestamp) external;
    function setPrice(uint _priceTokenPerBuyTokenInUQ) external;
    function setRangeAllocations(uint128[] calldata _allocations) external;
    function requestSeed() external;
    function register(RegisterParams calldata registerParams) external;
    function unregister() external;
    function buy(BuyParams calldata buyParams) external;
    function victoryTicketsCount(address _account) external view returns (uint count);
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.4;

interface IStaking {
    event SetWhitelist(address whitelist);
    event SetMinTierReferrerBooster(uint16 minTierReferrerBooster);
    event SetMinReferrerStakeAmount(uint minReferrerStakeAmount);
    event Stake(address indexed account, address indexed referrer, uint stakeId);
    event Unstake(address indexed account, uint stakeId, uint amountInToken, uint exitFeeInToken);
    event SetStakingPowerData(uint32 stakingPowerInitialBreak, uint32 participationBreak);
    event SetLastRegistrationDate(address indexed caller, address account, uint registrationDate);
    event SetLastParticipationDate(address indexed caller, address account, uint participationDate);
    event UpdateStakingPowerForId(address indexed caller, address indexed account, uint id, uint stakingPower);

    struct Tier {
        // % booster for tier qualification
        uint16 boosterInBP;
        // amount of LIFT required to qualify for this tier
        uint240 thresholdInToken;
        // vesting period
        uint vestingLockPeriodInSeconds;
    }

    struct AccountDetails {
        uint totalBoostedStake; // 256
        uint totalStake; // 256
        uint totalStakingPower; // 256
        uint lastIDOParticipation; // 256
        address referrer; // 160
        uint16 referralBoosterInBP; // 160 + 16 = 176
        uint lastIDORegistration; // 256
    }

    struct StakeDetails {
        uint stakeId; // 256
        uint amountInToken; // 256
        uint stakingPower; // 256
        uint64 startDateInSeconds; // 64
        // in seconds this is 136 years
        uint32 durationInSeconds; // 64 + 32 = 96
        uint16 tierBoosterInBP; // 64 + 32 + 16 = 112
        uint8 nextTierIndex; // 64 + 32 + 16 + 8 = 120
        uint136 tierSnapshot; // 64 + 32 + 16 + 8 + 136 = 256
    }

    struct StakeIdentifier {
        address account;
        uint id;
    }

    struct InfoAccountDetails {
        uint8 tierLength; 
        Tier[] tiers; 
        AccountDetails accountDetails;
        uint minReferrerStakeAmount;
        uint32 stakingPowerInitialBreak;
        string whitelistLink;
    }

    struct StakeInfo {
        address referrer;
        uint8 row;
        uint8 column;
        uint amount;
    }

    struct PermitStakeDetails {
        uint amount;
        uint8 row;
        uint8 column;
        uint deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct StakeRewardDetails {
        uint amountInToken;
        uint earlyExitFee;
        uint stakeProfit;
    }

    struct PermitStakeDetailsWithReferrer {
        bytes[] signaturesUser;
        address referrer;
        bytes[] signaturesReferrer;
        address[] signers;
        uint amount;
        uint8 row;
        uint8 column;
        uint deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct StakeWithReferrerParams {
        bytes[] signaturesUser;
        address referrer;
        bytes[] signaturesReferrer;
        address[] signers;
        uint amount;
        uint8 row;
        uint8 column;
    }

    function registry() external view returns (address);
    function token() external view returns (address);
    function tokenPool() external view returns (address);
    function whitelist() external view returns (address);
    function referrersData() external view returns (address);
    function stakingPowerData() external view returns (uint32 stakingPowerInitialBreak, uint32 participationBreak);
    
    function minTierReferrerBooster() external view returns (uint16);
    function stakesCount() external view returns (uint);
    function minReferrerStakeAmount() external view returns (uint);

    function stakes(address, uint) external view returns (
        uint stakeId,
        uint amountInToken,
        uint stakingPower,
        uint64 startDateInSeconds,
        uint32 durationInSeconds,
        uint16 tierBoosterInBP,
        uint8 nextTierIndex,
        uint136 tierSnapshot
    );
    function lastTierSnapshot() external view returns (uint);
    function setWhitelist(address _whitelist) external;
    function setMinTierReferrerBooster(uint16 _minTierReferrerBooster) external;
    function setMinReferrerStakeAmount(uint _minReferrerStakeAmount) external;
    function stake(uint _amount, uint8 _row, uint8 _column) external;
    function stakeWithReferrer(StakeWithReferrerParams calldata _stakeParams) external;
    function stakeWithPermit(PermitStakeDetails calldata _details) external;
    function stakeWithPermitWithReferrer(PermitStakeDetailsWithReferrer calldata _details) external;
    function unstake(uint _id) external;
    function unstakeWithoutFee(address _address, uint _id) external;
    function setStakingPowerData(uint32 _stakingPowerInitialBreak, uint32 _participationBreak) external;
    function setTiers(Tier[] calldata _tiers, uint8 _tierLength, uint8 _firstEarlyUnstakeIndex) external;
    function info(address _account) external view returns (InfoAccountDetails memory details);
    function tierSnapshotInfo(uint _snapshotIndex) external view returns (
        Tier[] memory snapshot,
        uint8 columnCount,
        uint8 firstEarlyUnstakeIndex
    );
    function canParticipate(address _account) external view returns (bool);
    function expectedStakingPower(address _account, uint[] calldata _ids) external view returns (uint[] memory stakingPower);
    function expectedRewards(StakeIdentifier[] calldata _stakes) external view returns (uint[] memory rewards);
    function setLastRegistrationDate(address _account, uint _registrationDate) external;
    function setLastParticipationDate(address _account, uint _participationDate) external;
    function updateStakingPower(address _account, uint[] calldata _ids) external;
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.4;

interface IWhitelist {

    event SetSignaturesRequiredForValidation(address indexed sender, uint8 signaturesRequiredForValidation);

    function signaturesRequiredForValidation() external view returns (uint8);
    function registry() external view returns (address);
    function setSignaturesRequiredForValidation(uint8 _signaturesRequiredForValidation) external;
    function isAddressWhitelisted(bytes calldata _dataToSign, bytes[] calldata _signatures, address[] calldata _signers) external view returns (bool);
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.4;

interface ILotteryInfo {
    event SetStakingPowerForOneTicket(address sender, uint stakingPowerForOneTicket);

    function registry() external view returns(address);
    function stakingPowerForOneTicket() external view returns(uint);
    function setStakingPowerForOneTicket(uint _stakingPowerForOneTicket) external;
    function lotteryTicketsForPower(uint _stakingPower) external view returns (uint);
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.4;

interface IRandomGenerator {
    function registry() external view returns (address);
    function fee() external view returns (uint);

    function idoOf(bytes32) external view returns (address);
    function seedOf(address) external view returns (uint);

    function requestRandom(address _ido) external returns (bytes32 requestId);
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.4;

interface IReferrersData {
    event MigrateUser(address indexed user, address parent);
    event AddUser(address sender, address indexed user, address parent);

    function registry() external view returns (address);
    function parentOf(address) external view returns (address);

    function parentsOf(address _user) external view returns (address parent, address grandparent);
    function parentsOfUsers(address[] calldata _users) external view returns (address[] memory parents);

    function migrateUsers(address[] calldata _users, address[] calldata _parents) external;
    function addUser(address _user, address _parent) external;
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.4;

interface IReferralPool {
    event WithdrawForAccount(address indexed account, uint reward);

    function withdrawForAccount(address _account) external returns (uint);
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.4;

interface IPool {
    event SetToken(address token);
    event Mint(address indexed account, uint amount);
    event Burn(address indexed account, uint amount);
    event Withdraw(address indexed account, uint reward);

    function balanceOf(address _account) external view returns (uint);
    function registry() external view returns (address);
    function token() external view returns (address);
    function totalSupply() external view returns (uint);

    function setToken(address _token) external;
    function mint(address _account, uint _amount) external;
    function burn(address _account, uint _amount) external;
    function withdraw() external returns (uint);
    function withdrawableRewardsOf(address _account) external view returns (uint);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

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
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts v4.4.1 (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeaconUpgradeable.sol";
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
        __ERC1967Upgrade_init_unchained();
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
    function _upgradeToAndCallSecure(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        address oldImplementation = _getImplementation();

        // Initial upgrade and setup call
        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }

        // Perform rollback test if not already in progress
        StorageSlotUpgradeable.BooleanSlot storage rollbackTesting = StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            // Trigger rollback using upgradeTo from the new implementation
            rollbackTesting.value = true;
            _functionDelegateCall(
                newImplementation,
                abi.encodeWithSignature("upgradeTo(address)", oldImplementation)
            );
            rollbackTesting.value = false;
            // Check rollback was effective
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            // Finally reset to the new implementation and log the upgrade
            _upgradeTo(newImplementation);
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

pragma solidity ^0.8.0;

/*
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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