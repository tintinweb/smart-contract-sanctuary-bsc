// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

// import "hardhat/console.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "./utils/InterestHelper.sol";
import "../token/ERC20/utils/ERC20FallbackUpgradeable.sol";

contract BithotelMasterChefUpgradeable is
    Initializable,
    AccessControlUpgradeable,
    ERC20FallbackUpgradeable,
    InterestHelper,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable
{
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /**
     *
     * @dev User reflects the info of each user
     *
     *
     * @param {totalDeposited} how many tokens the user staked
     * @param {totalWithdrawn} how many tokens withdrawn so far
     * @param {lastPayout} time at which last claim was done
     * @param {depositTime} Time of last deposit
     * @param {totalClaimed} Total claimed by the user
     *
     */
    struct UserInfo {
        uint256 totalDeposit;
        uint256 totalWithdrawn;
        uint256 depositTime;
        uint256 lastPayout;
        uint256 totalClaimed;
    }

    /**
     *
     * @dev PoolInfo reflects the info of each pools
     *
     * If APY is 12%, we provide 120 as input. lockPeriodInDays
     * would be the number of days which the claim is locked.
     * So if we want to lock claim for 1 month, lockPeriodInDays would be 30.
     *
     * @param {token} Token used as deposit/reward
     * @param {apy} Percentage of yield produced by the pool
     * @param {lockPeriodInDays} Amount of time claim will be locked
     * @param {startDate} starting time of pool
     * @param {endDate} ending time of pool in unix timestamp
     * @param {minContrib} Minimum amount to be staked
     * @param {maxContrib} Maximum amount that can be staked
     * @param {hardCap} Maximum amount a pool can hold
     *
     */
    struct PoolInfo {
        address token;
        uint256 apy;
        uint256 lockPeriodInDays;
        uint256 startDate;
        uint256 endDate;
        uint256 minContribution;
        uint256 hardCap;
        uint256 totalDeposit;
        uint256 totalPoolReward;
    }

    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant TIMELOCK_CONTROLLER_ROLE = keccak256("TIMELOCK_CONTROLLER_ROLE");

    CountersUpgradeable.Counter private _sNextPid;

    PoolInfo[] private _pools;
    mapping(uint256 => mapping(address => UserInfo)) private _userInfo; // Info of each user that stakes tokens.

    address private _sTimelockController;
    address private _thisAddress;
    address private _wallet;
    bool public initializerRan;
    bool private _isFeeEnabled;
    uint8 private _feePercentage; //Percentage of fee deducted (/1000)

    event Deposit(
        address indexed tokenAddress,
        address indexed userAddress,
        uint256 indexed pid,
        uint256 amount,
        uint256 time
    );
    event Withdraw(
        address indexed tokenAddress,
        address indexed userAddress,
        uint256 indexed pid,
        uint256 amount,
        uint256 time
    );
    event AddedTokenToPool(
        uint256 pid,
        address token,
        uint256 apy,
        uint256 lockPeriodInDays,
        uint256 startDate,
        uint256 endDate,
        uint256 minContribution,
        uint256 hardCap
    );
    event ChangedPoolInfo(
        uint256 pid,
        address token,
        uint256 apy,
        uint256 lockPeriodInDays,
        uint256 startDate,
        uint256 endDate,
        uint256 minContribution,
        uint256 hardCap,
        uint256 totalPoolReward
    );
    event ChangedIsFeeEnabled(bool value);
    event ChangedFeePercentage(uint8 newFeePercentage);
    event ChangedTimelockController(address newTimelockController);
    event ChangedWallet(address newWallet);
    event Claim(address indexed tokenAddress, address indexed userAddress, uint256 amount, uint256 time);

    event Reinvest(address indexed addr, uint256 amount, uint256 time);
    event Stake(address indexed addr, uint256 amount, uint256 time);
    event Unstake(address indexed addr, uint256 amount, uint256 time);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {
        // solhint-disable-previous-line no-empty-blocks
    }

    function initialize(
        address wallet,
        address mTimelockController,
        uint8 feePercentage_
    ) public initializer {
        __AccessControl_init();
        __UUPSUpgradeable_init();
        __ERC20Fallback_init_unchained();
        __InterestHelper_init_unchained();
        __Pausable_init();
        __ReentrancyGuard_init();
        __BithotelMasterChef_init_unchained(wallet, mTimelockController, feePercentage_);
    }

    // solhint-disable-next-line func-name-mixedcase
    function __BithotelMasterChef_init_unchained(
        address wallet,
        address mTimelockController,
        uint8 feePercentage_
    ) internal onlyInitializing {
        // solhint-disable-next-line reason-string
        require(wallet != address(0), "BithotelMasterChef: wallet is the zero address");
        // solhint-disable-next-line reason-string
        require(mTimelockController != address(0), "BithotelMasterChef: timelock controller is the zero address");

        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(TIMELOCK_CONTROLLER_ROLE, mTimelockController);
        _grantRole(UPGRADER_ROLE, _msgSender());

        _sNextPid.increment();

        _sTimelockController = mTimelockController;
        _thisAddress = address(this);
        _wallet = wallet;
        _isFeeEnabled = true;
        _feePercentage = feePercentage_;
        initializerRan = true;

        _add(0, 0x0000000000000000000000000000000000000000, 0, 0, 0, 0, 0, 0); //add 0 Pool so _pools array with information will starts with 1
    }

    function version() external pure virtual returns (string memory) {
        return "1.0";
    }

    function depositReward(
        uint256 pid,
        IERC20Upgradeable token,
        uint256 amount
    ) external nonReentrant onlyRole(TIMELOCK_CONTROLLER_ROLE) {
        _beforeDepositReward(pid, token, amount);
        address sender = _msgSender();

        PoolInfo storage pool = _pools[pid];
        pool.totalPoolReward += amount;
        _receiveTokens(token, sender, _thisAddress, amount);
        emit Deposit(pool.token, sender, pid, amount, 0);
        _afterDepositReward(pid, token, amount);
    }

    function setIsFeeEnabled(bool value) external onlyRole(TIMELOCK_CONTROLLER_ROLE) {
        // solhint-disable-next-line reason-string
        require(_isFeeEnabled != value, "BithotelMasterChef: isFeeEnabled already set");
        _isFeeEnabled = value;
        emit ChangedIsFeeEnabled(value);
    }

    function changeListingFeePercentage(uint8 newFeePercentage) external onlyRole(TIMELOCK_CONTROLLER_ROLE) {
        // solhint-disable-next-line reason-string
        require(newFeePercentage != _feePercentage, "BithotelMasterChef: feePercentage already set");
        _feePercentage = newFeePercentage;
        emit ChangedFeePercentage(newFeePercentage);
    }

    function changeTimelockContoller(address newTimelockController) external onlyRole(TIMELOCK_CONTROLLER_ROLE) {
        // solhint-disable-next-line reason-string
        require(newTimelockController != _sTimelockController, "BithotelMasterChef: timelockController already set");
        _sTimelockController = newTimelockController;
        emit ChangedTimelockController(newTimelockController);
    }

    function changeWallet(address newWallet) external onlyRole(TIMELOCK_CONTROLLER_ROLE) {
        // solhint-disable-next-line reason-string
        require(newWallet != _wallet, "BithotelMasterChef: wallet already set");
        _wallet = newWallet;
        emit ChangedWallet(newWallet);
    }

    /**
     *
     * @dev add new pool
     *
     */
    function addPool(
        address token,
        uint256 apy,
        uint256 lockPeriodInDays,
        uint256 startDate,
        uint256 endDate,
        uint256 minContribution,
        uint256 hardCap
    ) external virtual onlyRole(TIMELOCK_CONTROLLER_ROLE) {
        uint256 pid = getNextPid();

        _add(pid, token, apy, lockPeriodInDays, startDate, endDate, minContribution, hardCap);
        emit AddedTokenToPool(pid, token, apy, lockPeriodInDays, startDate, endDate, minContribution, hardCap);

        _sNextPid.increment();
    }

    /**
     *
     * @dev update the given pool's Info
     *
     */
    function set(
        uint256 pid,
        address token,
        uint256 apy,
        uint256 lockPeriodInDays,
        uint256 startDate,
        uint256 endDate,
        uint256 minContribution,
        uint256 hardCap
    ) external virtual onlyRole(TIMELOCK_CONTROLLER_ROLE) {
        // solhint-disable-next-line reason-string
        require(pid > 0, "BithotelMasterChef: pid is the zero value");

        PoolInfo storage pool = _pools[pid];

        pool.token = token;
        pool.apy = apy;
        pool.lockPeriodInDays = lockPeriodInDays;
        pool.startDate = startDate;
        pool.endDate = endDate;
        pool.minContribution = minContribution;
        pool.hardCap = hardCap;

        emit ChangedPoolInfo(
            pid,
            token,
            apy,
            lockPeriodInDays,
            startDate,
            endDate,
            minContribution,
            hardCap,
            pool.totalPoolReward
        );
    }

    function stake(uint256 pid, uint256 amount) external virtual whenNotPaused nonReentrant returns (bool) {
        // solhint-disable-next-line reason-string
        require(pid < getNextPid(), "BithotelMasterChef: non existing pid");

        address sender = _msgSender();

        PoolInfo storage pool = _pools[pid];
        IERC20Upgradeable token = IERC20Upgradeable(pool.token);

        _beforeStake(pid, token, sender, amount);

        UserInfo storage user = _userInfo[pid][sender];

        _receiveTokens(token, sender, _thisAddress, amount);

        reinvest(pid);
        _stake(pid, sender, amount, false);
        emit Deposit(pool.token, sender, pid, amount, block.timestamp);

        _afterStake(pid, sender, amount);

        return true;
    }

    function unStake(uint256 pid, uint256 amount) external virtual whenNotPaused nonReentrant returns (bool) {
        address sender = _msgSender();

        // solhint-disable-next-line reason-string
        require(pid < getNextPid(), "BithotelMasterChef: non existing pid");

        PoolInfo storage pool = _pools[pid];
        UserInfo storage user = _userInfo[pid][sender];
        IERC20Upgradeable token = IERC20Upgradeable(pool.token);

        _beforeUnStake(pid, token, sender, amount);
        _claim(pid, amount, token, sender);

        user.totalDeposit -= amount;
        pool.totalDeposit -= amount;
        emit Unstake(_msgSender(), amount, block.timestamp);

        _sendTokens(token, sender, amount);
        emit Withdraw(pool.token, sender, pid, amount, block.timestamp);

        _afterUnStake(pid, sender, amount);
    }

    /**
     *
     * @dev Reinvest accumulated TOKEN reward for all pools
     *
     * @return {bool} status of reinvest
     */
    function reinvestAll() external returns (bool) {
        uint256 len = poolsLength();
        for (uint256 pid = 0; pid < len; ++pid) {
            reinvest(pid);
        }

        return true;
    }

    function getWallet() public view virtual returns (address) {
        return _wallet;
    }

    function getTimelockController() public view virtual returns (address) {
        return _sTimelockController;
    }

    function getNextPid() public view virtual returns (uint256) {
        return _sNextPid.current();
    }

    /**
     *
     * @dev get length of the pools
     *
     * @return {uint256} length of the pools
     *
     */
    function poolsLength() public view virtual returns (uint256) {
        return _pools.length - 1; // don't count 0 pid
    }

    /**
     *
     * @dev get info of all pools
     *
     * @return {PoolInfo[]} Pool info struct
     *
     */
    function getPools() public view virtual returns (PoolInfo[] memory) {
        return _pools;
    }

    /**
     *
     * @dev get info of a pool bu pid
     *
     * @return {PoolInfo} Pool info struct
     *
     */
    function getPool(uint256 pid) public view virtual returns (PoolInfo memory) {
        return _pools[pid];
    }

    function poolTotalDeposit(uint256 pid) public view virtual returns (uint256) {
        return _pools[pid].totalDeposit;
    }

    function getPoolToken(uint256 pid) public view virtual returns (address) {
        return _pools[pid].token;
    }

    function getPoolApy(uint256 pid) public view virtual returns (uint256) {
        return _pools[pid].apy;
    }

    function getPoolLockPeriodInDays(uint256 pid) public view virtual returns (uint256) {
        return _pools[pid].lockPeriodInDays;
    }

    function getPoolStartDate(uint256 pid) public view virtual returns (uint256) {
        return _pools[pid].startDate;
    }

    function getPoolEndDate(uint256 pid) public view virtual returns (uint256) {
        return _pools[pid].endDate;
    }

    function getPoolMinContribution(uint256 pid) public view virtual returns (uint256) {
        return _pools[pid].minContribution;
    }

    function getPoolHardcap(uint256 pid) public view virtual returns (uint256) {
        return _pools[pid].hardCap;
    }

    function getPoolTotalReward(uint256 pid) public view virtual returns (uint256) {
        return _pools[pid].totalPoolReward;
    }

    function getUserInfo(uint256 pid, address userAddress) public view virtual returns (UserInfo memory) {
        return _userInfo[pid][userAddress];
    }

    function getUserTotalDeposit(uint256 pid, address userAddress) public view virtual returns (uint256) {
        return _userInfo[pid][userAddress].totalDeposit;
    }

    function getUserTotalClaimed(uint256 pid, address userAddress) public view virtual returns (uint256) {
        return _userInfo[pid][userAddress].totalClaimed;
    }

    function getUserTotalWithdrawn(uint256 pid, address userAddress) public view virtual returns (uint256) {
        return _userInfo[pid][userAddress].totalWithdrawn;
    }

    function payout(uint256 pid, address userAddress) public view virtual returns (uint256 value) {
        UserInfo memory user = _userInfo[pid][userAddress];
        PoolInfo memory pool = _pools[pid];

        uint256 from = user.lastPayout > user.depositTime ? user.lastPayout : user.depositTime;
        uint256 to = block.timestamp > pool.endDate ? pool.endDate : block.timestamp;

        if (from < to) {
            uint256 rayValue = yearlyRateToRay((pool.apy * 10**18) / 1000);
            value = (accrueInterest(user.totalDeposit, rayValue, to - from)) - user.totalDeposit;
        }
        return value;
    }

    function isFeeEnabled() public view returns (bool) {
        return _isFeeEnabled;
    }

    function feePercentage() public view returns (uint8) {
        return _feePercentage;
    }

    /**
     *
     * @dev check whether user can claim or not
     *
     * @param {pid}  id of the pool
     * @param {  function canClaim(uint256 pid, address userAddress)
     } address of the user
     *
     * @return {bool} Status of claim
     *
     */

    function canClaim(uint256 pid, address userAddress) public view virtual returns (bool) {
        UserInfo storage user = _userInfo[pid][userAddress];
        PoolInfo storage pool = _pools[pid];

        return block.timestamp >= user.depositTime + (pool.lockPeriodInDays * 1 days);
    }

    function pause() public virtual {
        _beforePause();
        _pause();
    }

    function unpause() public virtual {
        _beforeUnpause();
        _unpause();
    }

    /**
     *
     * @dev Reinvest accumulated TOKEN reward for a single pool
     *
     * @param {pid} pool identifier
     *
     * @return {bool} status of reinvest
     */

    function reinvest(uint256 pid) public returns (bool) {
        address sender = _msgSender();
        uint256 amount = payout(pid, sender);
        PoolInfo storage pool = _pools[pid];
        require(getPoolTotalReward(pid) > 0, "Pool has no reward to be reinvested");
        require(getPoolTotalReward(pid) >= amount, "Pool has insufficient reward to be reinvested");
        pool.totalPoolReward -= amount;
        if (amount > 0) {
            _stake(pid, sender, amount, true);
            emit Reinvest(sender, amount, block.timestamp);
        }
        return true;
    }

    /**
     *
     * @dev add new pool
     *
     */
    function _add(
        uint256 pid,
        address token,
        uint256 apy,
        uint256 lockPeriodInDays,
        uint256 startDate,
        uint256 endDate,
        uint256 minContribution,
        uint256 hardCap
    ) internal virtual {
        _pools.push(
            PoolInfo({
                token: token,
                apy: apy,
                lockPeriodInDays: lockPeriodInDays,
                startDate: startDate,
                endDate: endDate,
                minContribution: minContribution,
                hardCap: hardCap,
                totalDeposit: 0,
                totalPoolReward: 0
            })
        );
    }

    function _stake(
        uint256 pid,
        address sender,
        uint256 amount,
        bool _isReinvest
    ) internal {
        UserInfo storage user = _userInfo[pid][sender];
        PoolInfo storage pool = _pools[pid];

        user.totalDeposit += amount;
        pool.totalDeposit += amount;
        user.lastPayout = block.timestamp;

        if (!_isReinvest) {
            user.depositTime = block.timestamp;
        }

        emit Stake(sender, amount, block.timestamp);
    }

    function _claim(
        uint256 pid,
        uint256 claimAmount,
        IERC20Upgradeable token,
        address sender
    ) internal virtual {
        UserInfo storage user = _userInfo[pid][sender];
        PoolInfo storage pool = _pools[pid];

        uint256 amount = payout(pid, sender);
        require(getPoolTotalReward(pid) > 0, "BithotelMasterChef: no reward to withdraw");
        require(getPoolTotalReward(pid) >= amount, "BithotelMasterChef: not enough reward to withdraw");
        pool.totalPoolReward -= amount;

        if (amount > 0) {
            user.totalWithdrawn += amount;

            if (isFeeEnabled()) {
                uint256 feeAmount = (amount * feePercentage()) / 1000;
                _sendTokens(token, _wallet, feeAmount);
                amount -= feeAmount;
            }
            _sendTokens(token, sender, amount);
            user.lastPayout = block.timestamp;
            user.totalClaimed += amount;
            emit Claim(pool.token, sender, amount, block.timestamp);
        }
    }

    /**
     * @dev Hook that is called before deposit reward tokens.
     *
     * Calling conditions:
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeDepositReward(
        uint256 pid,
        IERC20Upgradeable token,
        uint256 amount
    ) internal view virtual {
        require(pid != 0, "BithotelMasterChef: pid is zero");
        require(address(token) != address(0), "BithotelMasterChef: token is the zero address");
        require(amount > 0, "BithotelMasterChef: amount is zero");
    }

    /**
     * @dev Hook that is called before any stake of tokens.
     *
     * Calling conditions:
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeStake(
        uint256 pid,
        IERC20Upgradeable token,
        address sender,
        uint256 amount
    ) internal view virtual {
        // solhint-disable-next-line reason-string
        require(pid != 0, "BithotelMasterChef: pid is the zero value");

        // solhint-disable-next-line reason-string
        require(amount > 0, "BithotelMasterChef: amount is the zero value");

        // solhint-disable-next-line reason-string
        require(address(token) != address(0), "BithotelMasterChef: token is the zero address");

        PoolInfo memory pool = _pools[pid];
        // solhint-disable-next-line reason-string
        require(amount >= getPoolMinContribution(pid), "BithotelMasterChef: amount is less than minContribution");

        // solhint-disable-next-line reason-string
        require(pool.startDate <= block.timestamp, "BithotelMasterChef: pool not open yet");
        uint256 stopDeposit = pool.endDate - (pool.lockPeriodInDays * 1 days);
        // solhint-disable-next-line reason-string
        require(block.timestamp <= stopDeposit, "BithotelMasterChef: staking is disabled for this pool");

        require((poolTotalDeposit(pid) + amount) <= pool.hardCap, "BithotelMasterChef: cap reached");

        // solhint-disable-next-line reason-string
        require(token.balanceOf(sender) >= amount, "BithotelMasterChef: insufficient balance");
        // solhint-disable-next-line reason-string
        require(token.allowance(sender, _thisAddress) >= amount, "BithotelMasterChef: insufficient allowance");
    }

    /**
     * @dev Hook that is called before any unstake of tokens.
     *
     * Calling conditions:
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeUnStake(
        uint256 pid,
        IERC20Upgradeable token,
        address sender,
        uint256 amount
    ) internal view virtual {
        // solhint-disable-next-line reason-string
        require(pid != 0, "BithotelMasterChef: pid is the zero value");

        // solhint-disable-next-line reason-string
        require(amount > 0, "BithotelMasterChef: amount is the zero value");
        // solhint-disable-next-line reason-string
        require(canClaim(pid, sender), "BithotelMasterChef: claim not available");

        require(getUserTotalDeposit(pid, sender) >= amount, "BithotelMasterChef: insufficient deposit balance");

        // solhint-disable-next-line reason-string
        require(amount <= token.balanceOf(_thisAddress), "BithotelMasterChef: insufficient token balance");
    }

    /**
     * @dev Hook that is called after deposited reward
     *
     * Calling conditions:
     *
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterDepositReward(
        uint256 pid,
        IERC20Upgradeable token,
        uint256 amount
    ) internal view virtual {}

    /**
     * @dev Hook that is called after any token stake
     *
     * Calling conditions:
     *
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterStake(
        uint256 pid,
        address sender,
        uint256 amount
    ) internal view virtual {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev Hook that is called after any token unstake
     *
     * Calling conditions:
     *
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterUnStake(
        uint256 pid,
        address sender,
        uint256 amount
    ) internal view virtual {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev SafeTransferFrom beneficiary. Override this method to modify the way in which the sale ultimately gets and sends
     * its tokens.
     * @param token Address of the token being received
     * @param beneficiary Address performing the listing
     * @param to Address the tokenAmount sent to
     * @param tokenAmount Number of tokens to be emitted
     */
    function _receiveTokens(
        IERC20Upgradeable token,
        address beneficiary,
        address to,
        uint256 tokenAmount
    ) internal virtual {
        token.safeTransferFrom(beneficiary, to, tokenAmount);
    }

    /**
     * @dev Source of tokens. Override this method to modify the way in which the tokenescrow ultimately gets and sends
     * its tokens.
     * @param token Address of the IERC20 token
     * @param to address Recipient of the tokens
     * @param tokenAmount Number of tokens to be emitted
     */
    function _sendTokens(
        IERC20Upgradeable token,
        address to,
        uint256 tokenAmount
    ) internal virtual {
        token.safeTransfer(to, tokenAmount);
    }

    /**
     * @dev Validation of an fallback redeem. Use require statements to revert state when conditions are not met.
     * Use `super` in contracts that inherit from BithotelMasterChef to extend their validations.
     * Example from BithotelMasterChef.sol"s _prevalidateFallbackRedeem method:
     *     super._prevalidateFallbackRedeem(token, payee, amount);
     *
     * @param mToken The token address of IERC20 token
     * @param to Address performing the token deposit
     * @param amount Number of tokens deposit
     *
     * Requirements:
     *
     * - `msg.sender` must be owner.
     * - `token` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - this address must have a token balance of at least `amount`.
     * - must be admin
     */
    function _prevalidateFallbackRedeem(
        address mToken,
        address to,
        uint256 amount
    ) internal view virtual override(ERC20FallbackUpgradeable) onlyRole(TIMELOCK_CONTROLLER_ROLE) {
        super._prevalidateFallbackRedeem(mToken, to, amount);
    }

    /**
     * @dev Hook that is called before pause.
     */
    function _beforePause()
        internal
        view
        virtual
        onlyRole(TIMELOCK_CONTROLLER_ROLE)
    // solhint-disable-next-line no-empty-blocks
    {

    }

    /**
     * @dev Hook that is called before unpause.
     */
    function _beforeUnpause()
        internal
        view
        virtual
        onlyRole(TIMELOCK_CONTROLLER_ROLE)
    // solhint-disable-next-line no-empty-blocks
    {

    }

    function _authorizeUpgrade(address newImplementation) internal virtual override onlyRole(UPGRADER_ROLE) {
        // solhint-disable-previous-line no-empty-blocks
    }

    uint256[50] private __gap;
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
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControlUpgradeable.sol";
import "../utils/ContextUpgradeable.sol";
import "../utils/StringsUpgradeable.sol";
import "../utils/introspection/ERC165Upgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
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
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
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
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
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
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
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

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
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
library CountersUpgradeable {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;


import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract DSMath is Initializable {
    uint public wad;
    uint public ray;

    // solhint-disable-next-line func-name-mixedcase
    function __DSMath_init_unchained() internal onlyInitializing {
        wad = 10 ** 18;
        ray = 10 ** 27;
    }
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    function wmul(uint x, uint y) internal view returns (uint z) {
        z = add(mul(x, y), wad / 2) / wad;
    }
    function rmul(uint x, uint y) internal view returns (uint z) {
        z = add(mul(x, y), ray / 2) / ray;
    }
    function wdiv(uint x, uint y) internal view returns (uint z) {
        z = add(mul(x, wad), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal view returns (uint z) {
        z = add(mul(x, ray), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint x, uint n) internal view returns (uint z) {
        z = n % 2 != 0 ? x : ray;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}


/**
* @title Interest
* @author Nick Ward
* @dev Uses DSMath's wad and ray math to implement (approximately)
* continuously compounding interest by calculating discretely compounded
* interest compounded every second.
*/
contract InterestHelper is Initializable, DSMath {

    // solhint-disable-next-line func-name-mixedcase
    function __InterestHelper_init_unchained() internal onlyInitializing {
        __DSMath_init_unchained();
    }

    //// Fixed point scale factors
    // wei -> the base unit
    // wad -> wei * 10 ** 18. 1 ether = 1 wad, so 0.5 ether can be used
    //      to represent a decimal wad of 0.5
    // ray -> wei * 10 ** 27

    // Go from wad (10**18) to ray (10**27)
    function wadToRay(uint wad_) internal pure returns (uint) {
        return wad_ * (10 ** 9);
    }

    // Go from wei to ray (10**27)
    function weiToRay(uint wei_) internal pure returns (uint) {
        return wei_ * (10 ** 27);
    } 

    /**
     * @dev Uses an approximation of continuously compounded interest 
     * (discretely compounded every second)
     * @param _principal The principal to calculate the interest on.
     *   Accepted in wei.
     * @param _rate The interest rate. Accepted as a ray representing 
     *   1 + the effective interest rate per second, compounded every 
     *   second. As an example:
     *   I want to accrue interest at a nominal rate (i) of 5.0% per year 
     *   compounded continuously. (Effective Annual Rate of 5.127%).
     *   This is approximately equal to 5.0% per year compounded every 
     *   second (to 8 decimal places, if max precision is essential, 
     *   calculate nominal interest per year compounded every second from 
     *   your desired effective annual rate). Effective Rate Per Second = 
     *   Nominal Rate Per Second compounded every second = Nominal Rate 
     *   Per Year compounded every second * conversion factor from years 
     *   to seconds
     *   Effective Rate Per Second = 0.05 / (365 days/yr * 86400 sec/day) = 1.5854895991882 * 10 ** -9
     *   The value we want to send this function is 
     *   1 * 10 ** 27 + Effective Rate Per Second * 10 ** 27
     *   = 1000000001585489599188229325
     *   This will return 5.1271096334354555 Dai on a 100 Dai principal 
     *   over the course of one year (31536000 seconds)
     * @param _age The time period over which to accrue interest. Accepted
     *   in seconds.
     * @return The new principal as a wad. Equal to original principal + 
     *   interest accrued
     */
    function accrueInterest(uint _principal, uint _rate, uint _age) public view returns (uint) {
        return rmul(_principal, rpow(_rate, _age));
    }

    /**
     * @dev Takes in the desired nominal interest rate per year, compounded
     *   every second (this is approximately equal to nominal interest rate
     *   per year compounded continuously). Returns the ray value expected
     *   by the accrueInterest function 
     * @param _rateWad A wad of the desired nominal interest rate per year,
     *   compounded continuously. Converting from ether to wei will effectively
     *   convert from a decimal value to a wad. So 5% rate = 0.05
     *   should be input as yearlyRateToRay( 0.05 ether )
     * @return 1 * 10 ** 27 + Effective Interest Rate Per Second * 10 ** 27
     */
    function yearlyRateToRay(uint _rateWad) public view returns (uint) {
        return add(wadToRay(1 ether), rdiv(wadToRay(_rateWad), weiToRay(365*86400)));
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

abstract contract ERC20FallbackUpgradeable is Initializable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    event TokenWithdrawn(address token, address indexed to, uint256 value);

    // solhint-disable-next-line func-name-mixedcase
    function __ERC20Fallback_init_unchained() internal onlyInitializing {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev Faalback Redeem tokens. The ability to redeem token whe okenst are accidentally sent to the contract
     * @param mToken Address of the IERC20 token
     * @param mTo address Recipient of the recovered tokens
     * @param mAmount Number of tokens to be emitted
     */
    /// #if_succeeds {:msg "the contract has sufficient balance at the start"} old(IERC20Upgradeable(mToken).balanceOf(this) >= mAmount); 
    /// #if_succeeds {:msg "the contract has less balance"} IERC20Upgradeable(mToken).balanceOf(this) - mAmount == IERC20Upgradeable(mToken).balanceOf(this); 
    /// #if_succeeds {:msg "the receiver receives mAmount"} this != mTo ==> old(IERC20Upgradeable(mToken).balanceOf(mTo) + mAmount) == IERC20Upgradeable(mToken).balanceOf(mTo);
    function fallbackRedeem(
        address mToken,
        address mTo,
        uint256 mAmount
    ) public virtual {
        _prevalidateFallbackRedeem(mToken, mTo, mAmount);

        _processFallbackRedeem(mToken, mTo, mAmount);
        emit TokenWithdrawn(mToken, mTo, mAmount);

        _updateFallbackRedeem(mToken, mTo, mAmount);
        _postValidateFallbackRedeem(mToken, mTo, mAmount);
    }

    /**
     * @dev Validation of an fallback redeem. Use require statements to revert state when conditions are not met.
     * Use `super` in contracts that inherit from TokenEscrow to extend their validations.
     * Example from TokenEscrow.sol"s _prevalidateFallbackRedeem method:
     *     super._prevalidateFallbackRedeem(token, payee, amount);
     *
     * @param mToken Address of the IERC20 token
     * @param mTo address Recipient of the recovered tokens
     * @param mAmount Number of tokens to be emitted
     *
     * Requirements:
     *
     * - `msg.sender` must be owner.
     * - `token` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - this address must have a token balance of at least `amount`.
     */
    function _prevalidateFallbackRedeem(
        address mToken,
        address mTo,
        uint256 mAmount
    ) internal view virtual {
        // solhint-disable-next-line reason-string
        require(mToken != address(0), "ERC20Fallback: token is the zero address");
        // solhint-disable-next-line reason-string
        require(mTo != address(0), "ERC20Fallback: cannot recover to zero address");
        // solhint-disable-next-line reason-string
        require(mAmount != 0, "ERC20Fallback: amount is 0");

        uint256 balance = IERC20Upgradeable(mToken).balanceOf(address(this));
        require(balance >= mAmount, "ERC20Fallback: no token to release");
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    }

    /**
     * @dev Executed when fallbackRedeem has been validated and is ready to be executed. Doesn"t necessarily emit/send
     * tokens.
     * @param mToken Address of the IERC20 token
     * @param mTo address Recipient of the recovered tokens
     * @param mAmount Number of tokens to be emitted
     */
    function _processFallbackRedeem(
        address mToken,
        address mTo,
        uint256 mAmount
    ) internal virtual {
        _deliverTokens(mToken, mTo, mAmount);
    }

    /**
     * @dev Override for extensions that require an internal state to check for validity fallback redeem,
     * etc.)
     * @param mToken Address of the IERC20 token
     * @param mTo address Recipient of the recovered tokens
     * @param mAmount Number of tokens to be emitted
     */
    function _updateFallbackRedeem(
        address mToken,
        address mTo,
        uint256 mAmount
    ) internal virtual {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev Validation of an executed fallback redeem. Observe state and use revert statements to undo rollback when valid
     * conditions are not met.
     * @param mToken Address of the IERC20 token
     * @param mTo address Recipient of the recovered tokens
     * @param mAmount Number of tokens to be emitted
     */
    function _postValidateFallbackRedeem(
        address mToken,
        address mTo,
        uint256 mAmount
    ) internal view virtual {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev Source of tokens. Override this method to modify the way in which the tokenescrow ultimately gets and sends
     * its tokens.
     * @param mToken Address of the IERC20 token
     * @param mTo address Recipient of the recovered tokens
     * @param mAmount Number of tokens to be emitted
     */
    function _deliverTokens(
        address mToken,
        address mTo,
        uint256 mAmount
    ) internal virtual returns (bool) {
        IERC20Upgradeable(mToken).safeTransfer(mTo, mAmount);
        return true;
    }
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
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

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
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
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