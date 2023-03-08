// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IAssetCertificate is IERC721 {
    function mint(address account) external returns (uint256);

    function burn(uint256 tokenId) external;

    function nextTokenId() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IColumbusFarm {
    function deposit(
        address _sender,
        uint256 _pid,
        uint256 _amount
    ) external;

    function withdraw(
        address _sender,
        uint256 _pid,
        uint256 _amount
    ) external;

    function claim(uint256 _pid) external;

    function claimAll() external;

    function pendingYES(uint256 _pid, address _user)
        external
        view
        returns (uint256);

    function emergencyWithdraw(uint256 _pid) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IStrategyToken is IERC20 {
    function balance() external view returns (uint256);

    function balanceStrategy() external view returns (uint256);

    function calcPoolValueInToken() external view returns (uint256);

    function getPricePerFullShare() external view returns (uint256);

    function sharesToAmount(uint256 shares_) external view returns (uint256);

    function amountToShares(uint256 amount_) external view returns (uint256);

    function wantAddress() external view returns (address);

    function keeper() external view returns (address);

    function setKeeper(address keeper_) external;

    function setGovernor(address governor_) external;

    function governor() external view returns (address);

    function pause(bool depositPaused_, bool withdrawPaused_) external;

    /**
     * @return Whether or not deposit actions are paused
     */
    function isDepositPaused() external view returns (bool);

    /**
     * @return Whether or not withdraw actions are paused
     */
    function isWithdrawPaused() external view returns (bool);

    function deposit(uint256 _amount, uint256 _minShares)
        external
        returns (uint256);

    function withdraw(uint256 _shares, uint256 _minAmount)
        external
        returns (uint256);

    function setGovAddress(address _govAddress) external;
}

interface IColumbusVault is IStrategyToken {
    function strategies(uint256 idx) external view returns (address);

    function depositActiveCount() external view returns (uint256);

    function withdrawActiveCount() external view returns (uint256);

    function strategyCount() external view returns (uint256);

    function ratios(address _strategy) external view returns (uint256);

    function depositActive(address _strategy) external view returns (bool);

    function withdrawActive(address _strategy) external view returns (bool);

    function ratioTotal() external view returns (uint256);

    function findMostOverLockedStrategy(uint256 withdrawAmt)
        external
        view
        returns (address, uint256);

    function findMostLockedStrategy() external view returns (address, uint256);

    function findMostInsufficientStrategy()
        external
        view
        returns (address, uint256);

    function getBalanceOfOneStrategy(address strategyAddress)
        external
        view
        returns (uint256 bal);

    // doesn"t guarantee that withdrawing shares returned by this function will always be successful.
    function getMaxWithdrawableShares() external view returns (uint256);

    function rebalance() external;

    function changeRatio(uint256 index, uint256 value) external;

    function inCaseTokensGetStuck(
        address _token,
        uint256 _amount,
        address _to
    ) external;

    function updateAllStrategies() external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "contracts/interfaces/IColumbusFarm.sol";
import "contracts/interfaces/IAssetCertificate.sol";
import "contracts/interfaces/IColumbusVault.sol";

contract ColumbusStaking is
    Initializable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    OwnableUpgradeable
{
    using SafeERC20 for IERC20;
    struct UserInfo {
        uint256 shares; // number of shares for a user.
        uint256 userBoostedShare; // boost share, in order to give the user higher reward. The user only enjoys the reward, so the principal needs to be recorded as a debt.
        // uint256 lastDepositedTime; // keep track of deposited time for potential penalty.
        // uint256 stakedTokenAtLastUserAction; // keep track of stakedToken deposited at the last user action.
        // uint256 lastUserActionTime; // keep track of the last user action time.
        uint256 lockStartTime; // lock start time.
        uint256 lockEndTime; // lock end time.
        // bool locked; //lock status.
        uint256 lockedAmount; // amount deposited during lock period.
        uint256 pendingYESReward; // yes Reward Overdue Weight
    }

    // The staked token
    IERC20 public stakedToken;

    // The YES token
    IERC20 public YES;

    IAssetCertificate public assetCertificate;

    IColumbusFarm public columbusFarm;
    mapping(uint256 => UserInfo) public proofs;
    mapping(address => UserInfo) public userInfo;

    uint256 internal _nextId;
    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;
    // mapping(address => uint256[]) private _userProofs;

    uint256 public totalShares;
    address public columbus;
    address public treasury;
    address public vault;
    uint256 public poolPID;
    uint256 public totalBoostDebt; // total boost debt.
    uint256 public totalLockedAmount; // total lock amount.

    uint256 public accOverdueShares; // Accumulated overdue fee

    uint256 public constant MIN_LOCK_DURATION = 1 weeks; // 1 week
    uint256 public constant MAX_LOCK_DURATION_LIMIT = 1000 days; // 1000 days
    uint256 public constant BOOST_WEIGHT_LIMIT = 5000 * 1e10; // 5000%
    uint256 public constant PRECISION_FACTOR = 1e12; // precision factor.
    uint256 public constant PRECISION_FACTOR_SHARE = 1e28; // precision factor for share.
    uint256 public constant MAX_OVERDUE_FEE = 100 * 1e10; // 100%

    uint256 public MAX_LOCK_DURATION = 365 days; // 365 days
    uint256 public DURATION_FACTOR = 365 days; // 365 days, in order to calculate user additional boost.
    uint256 public DURATION_FACTOR_OVERDUE = 90 days; // 90 days, in order to calculate overdue fee.
    uint256 public BOOST_WEIGHT = 2000 * 1e10; // 2000%

    uint256 public UNLOCK_FREE_DURATION = 1 weeks; // 1 week // 解锁自由持续时间

    uint256 public minDepositAmount;
    uint256 public minWithdrawAmount;

    uint256 public overdueFee = 100 * 1e10; // 100%

    event Deposit(
        address indexed sender,
        uint256 amount,
        uint256 shares,
        uint256 duration,
        uint256 lastDepositedTime
    );
    event Withdraw(address indexed sender, uint256 amount, uint256 shares);
    event Harvest(address indexed sender, uint256 amount);
    event Pause();
    event Unpause();
    event Init();
    event Lock(
        address indexed sender,
        uint256 lockedAmount,
        uint256 shares,
        uint256 lockedDuration,
        uint256 blockTimestamp
    );
    event Unlock(
        address indexed userid,
        uint256 amount,
        uint256 blockTimestamp
    );
    event NewVault(address vault);
    event NewTreasury(address treasury);
    event NewColumbus(address columbus);
    event NewMaxLockDuration(uint256 maxLockDuration);
    event NewDurationFactor(uint256 durationFactor);
    event NewBoostWeight(uint256 boostWeight);
    event NewOverdueFee(uint256 overdueFee);

    /**
     * @notice Constructor
     * @param _stakedToken: staked Token contract
     * @param _yes: YES Token contract
     * @param _columbusFarm: ColumbusFarm contract
     * @param _assetCertificate: AssetCertificate contract
     * @param _vault: address of the vault
     * @param _pid: yes pool ID in ColumbusFarm
     */
    function initialize(
        IERC20 _stakedToken,
        IERC20 _yes,
        IColumbusFarm _columbusFarm,
        IAssetCertificate _assetCertificate,
        address _vault,
        address _treasury,
        uint256 _pid
    ) public initializer {
        __Ownable_init();

        stakedToken = _stakedToken;
        YES = _yes;
        columbusFarm = _columbusFarm;
        assetCertificate = _assetCertificate;
        vault = _vault;
        treasury = _treasury;
        poolPID = _pid;

        MAX_LOCK_DURATION = 365 days;
        DURATION_FACTOR = 365 days;
        DURATION_FACTOR_OVERDUE = 90 days;
        BOOST_WEIGHT = 2000 * 1e10;
        UNLOCK_FREE_DURATION = 1 weeks;
        overdueFee = 100 * 1e10; // 100%

        _nextId = 1;
        approveToken();
    }

    function init(IERC20 dummyToken) external onlyOwner {
        uint256 balance = dummyToken.balanceOf(msg.sender);
        require(balance != 0, "Balance must exceed 0");
        dummyToken.safeTransferFrom(msg.sender, address(this), balance);
        dummyToken.approve(address(columbusFarm), balance);
        columbusFarm.deposit(address(this), poolPID, balance);
        emit Init();
    }

    function approveToken() public {
        if (vault != address(0)) {
            stakedToken.approve(vault, type(uint256).max);
        }
    }

    /**
     * @notice Checks if the msg.sender is the columbus address.
     */
    modifier onlyColumbus() {
        require(msg.sender == columbus, "Not columbus");
        _;
    }

    /**
     * @notice Update user share When need to unlock or charges a fee.
     * @param _proofId: User Id
     */
    function updateUserShare(uint256 _proofId, address _user) internal {
        UserInfo storage user;
        if (_proofId > 0) {
            user = proofs[_proofId];
        } else {
            user = userInfo[_user];
        }

        // if (user.shares > 0 && user.locked) {
        if (user.shares > 0 && user.lockEndTime > 0) {
            // Calculate the user's current token amount and update related parameters.
            uint256 currentShares = (balanceOf() * (user.shares)) /
                totalShares -
                user.userBoostedShare;
            // Calculation YES reward
            uint256 sharesPercent = (user.shares * PRECISION_FACTOR_SHARE) /
                totalShares;

            uint256 pendingYESReward = (yesAvailable() * sharesPercent) /
                PRECISION_FACTOR_SHARE;

            if ((user.lockEndTime + UNLOCK_FREE_DURATION) < block.timestamp) {
                uint256 earnShares = currentShares -
                    IColumbusVault(vault).amountToShares(user.lockedAmount);

                uint256 overdueDuration = block.timestamp -
                    user.lockEndTime -
                    UNLOCK_FREE_DURATION;

                if (overdueDuration > DURATION_FACTOR_OVERDUE) {
                    overdueDuration = DURATION_FACTOR_OVERDUE;
                }

                // Rates are calculated based on the user's overdue duration.
                uint256 overdueWeight = (overdueDuration * overdueFee) /
                    DURATION_FACTOR_OVERDUE;

                uint256 currentOverdueShares = (earnShares * overdueWeight) /
                    PRECISION_FACTOR;

                uint256 overdueYesFee = (pendingYESReward * overdueWeight) /
                    PRECISION_FACTOR;

                if (overdueYesFee > 0) {
                    YES.safeTransfer(treasury, overdueYesFee);
                }
                pendingYESReward -= overdueYesFee;

                accOverdueShares += currentOverdueShares;
                currentShares -= currentOverdueShares;
            }

            totalBoostDebt -= user.userBoostedShare;
            user.userBoostedShare = 0;
            totalShares -= user.shares;

            //Charge a overdue fee after the free duration has expired.
            // Calculation YES reward
            user.pendingYESReward += pendingYESReward;

            // uint256 currentShares = currentAmount;
            user.shares = currentShares;
            totalShares += currentShares;
            // After the lock duration, update related parameters.
            if (user.lockEndTime < block.timestamp) {
                // user.locked = false;
                user.lockStartTime = 0;
                user.lockEndTime = 0;
                totalLockedAmount -= user.lockedAmount;
                user.lockedAmount = 0;
                emit Unlock(_user, currentShares, block.timestamp);
            }
        }
    }

    function depositFromColumbus(
        uint256 _amount,
        address _user,
        uint256 _lockDuration
    ) external payable onlyColumbus whenNotPaused {
        require(
            _lockDuration >= MIN_LOCK_DURATION,
            "Minimum lock period is one week"
        );
        require(
            _amount > minDepositAmount,
            "Deposit amount must be greater than MIN_DEPOSIT_AMOUNT"
        );

        uint256 _proofId = assetCertificate.mint(_user);
        _deposit(_user, _proofId, _amount, _lockDuration);
    }

    /**
     * @notice Deposit funds into the YES Pool.
     * @dev Only possible when contract not paused.
     * @param _amount: number of tokens to deposit (in YES)
     * @param _lockDuration: Token lock duration
     */
    function deposit(uint256 _amount, uint256 _lockDuration)
        external
        whenNotPaused
    {
        _deposit(msg.sender, 0, _amount, _lockDuration);
    }

    /**
     * @notice The operation of deposite.
     * @param _amount: number of tokens to deposit (in YES)
     * @param _lockDuration: Token lock duration
     * @param _user: User address
     */
    function _deposit(
        address _user,
        uint256 _proofId,
        uint256 _amount,
        uint256 _lockDuration
    ) internal {
        require(_amount > 0 || _lockDuration > 0, "Nothing to deposit");

        require(
            stakedToken.balanceOf(msg.sender) >= _amount,
            "Insufficient amount"
        );
        UserInfo storage user = userInfo[_user];
        if (_proofId > 0) {
            user = proofs[_proofId];
        }
        if (user.shares == 0 || _amount > 0) {
            require(
                _amount > minDepositAmount,
                "Deposit amount must be greater than MIN_DEPOSIT_AMOUNT"
            );
        }
        // Calculate the total lock duration and check whether the lock duration meets the conditions.
        uint256 totalLockDuration = _lockDuration;

        if (user.lockEndTime >= block.timestamp) {
            // Adding funds during the lock duration is equivalent to re-locking the position, needs to update some variables.
            if (_amount > 0) {
                user.lockStartTime = block.timestamp;
                totalLockedAmount -= user.lockedAmount;
                user.lockedAmount = 0;
            }
            totalLockDuration += user.lockEndTime - user.lockStartTime;
        }

        require(
            _lockDuration == 0 || totalLockDuration >= MIN_LOCK_DURATION,
            "Minimum lock period is one week"
        );

        require(
            totalLockDuration < MAX_LOCK_DURATION,
            "Maximum lock period exceeded"
        );

        // Harvest tokens from BoostFarm.
        harvest();
        // Harvest staked token from vault.
        IColumbusVault(vault).updateAllStrategies();

        // Update user share.
        updateUserShare(_proofId, _user);

        // Update lock duration.
        if (_lockDuration > 0) {
            if (user.lockEndTime < block.timestamp) {
                user.lockStartTime = block.timestamp;
                user.lockEndTime = block.timestamp + _lockDuration;
            } else {
                user.lockEndTime += _lockDuration;
            }
            // user.locked = true;
        }

        require(
            user.lockEndTime > user.lockStartTime,
            "The lockEndTime must be greater than lockStartTime"
        );

        uint256 currentShares;
        uint256 userCurrentLockedBalance;
        uint256 currentAmount;
        uint256 pool = balanceOf();
        if (_amount > 0) {
            stakedToken.safeTransferFrom(msg.sender, address(this), _amount);
            uint256 sharesToMint = IColumbusVault(vault).deposit(_amount, 0);
            currentAmount = sharesToMint;
        }

        // Calculate lock funds
        // if (user.shares > 0 && user.locked) {
        if (user.shares > 0) {
            // 计算以前的share
            userCurrentLockedBalance = (pool * user.shares) / totalShares;

            currentAmount += userCurrentLockedBalance;
            totalShares -= user.shares;
            user.shares = 0;

            // Update lock amount
            if (user.lockStartTime == block.timestamp) {
                user.lockedAmount = userCurrentLockedBalance;
                totalLockedAmount += user.lockedAmount;
            }
        }

        if (totalShares != 0) {
            currentShares =
                (currentAmount * totalShares) /
                (pool - userCurrentLockedBalance);
        } else {
            currentShares = currentAmount;
        }

        // Calculate the boost weight share.
        // Calculate boost share.
        uint256 boostWeight = ((user.lockEndTime - user.lockStartTime) *
            BOOST_WEIGHT) / DURATION_FACTOR;

        uint256 boostShares = (boostWeight * currentShares) / PRECISION_FACTOR;
        currentShares += boostShares;
        user.shares += currentShares;

        // Calculate boost share , the user only enjoys the reward, so the principal needs to be recorded as a debt.
        uint256 userBoostedShare = (boostWeight * currentAmount) /
            PRECISION_FACTOR;
        user.userBoostedShare += userBoostedShare;
        totalBoostDebt += userBoostedShare;

        // Update lock amount.
        user.lockedAmount += _amount;
        totalLockedAmount += _amount;

        emit Lock(
            _user,
            user.lockedAmount,
            user.shares,
            (user.lockEndTime - user.lockStartTime),
            block.timestamp
        );

        // if (_amount > 0 || _lockDuration > 0) {
        //     user.lastDepositedTime = block.timestamp;
        // }

        totalShares += currentShares;

        // user.stakedTokenAtLastUserAction =
        //     (user.shares * balanceOf()) /
        //     totalShares -
        //     user.userBoostedShare;
        // user.lastUserActionTime = block.timestamp;

        emit Deposit(
            _user,
            _amount,
            currentShares,
            _lockDuration,
            block.timestamp
        );
    }

    /**
     * @notice Withdraw funds from the Cake Pool.
     * @param _amount: Number of amount to withdraw
     */
    function withdrawByAmount(uint256 _amount) public whenNotPaused {
        require(
            _amount > minWithdrawAmount,
            "Withdraw amount must be greater than MIN_WITHDRAW_AMOUNT"
        );
        _withdraw(0, msg.sender, 0, _amount);
    }

    /**
     * @notice Withdraw funds from the Yes Pool.
     * @param _shares: Number of amount to withdraw
     */
    function withdraw(uint256 _shares) public whenNotPaused {
        require(_shares > 0, "Nothing to withdraw");
        _withdraw(0, msg.sender, _shares, 0);
    }

    /**
     * @notice Withdraw all funds for a user
     */
    function withdrawAll() external {
        withdraw(userInfo[msg.sender].shares);
    }

    function claim(uint256 _proofId) external {
        require(
            _proofId > 0 && msg.sender == assetCertificate.ownerOf(_proofId),
            "This assetCertificatedoes not belong to you"
        );
        _withdraw(_proofId, msg.sender, proofs[_proofId].shares, 0);
    }

    /**
     * @notice The operation of withdraw.
     * @param _amount: Number of amount to withdraw
     */
    function _withdraw(
        uint256 _proofId,
        address _user,
        uint256 _shares,
        uint256 _amount
    ) internal {
        UserInfo storage user = userInfo[_user];
        if (_proofId > 0) {
            user = proofs[_proofId];
        }

        require(_shares <= user.shares, "Withdraw amount exceeds balance");
        require(user.lockEndTime < block.timestamp, "Still in lock");

        // Calculate the percent of withdraw shares, when unlocking or calculating the Performance fee, the shares will be updated.
        uint256 currentShare = _shares;
        uint256 sharesPercent = (_shares * PRECISION_FACTOR_SHARE) /
            user.shares;

        // Harvest YES token from ColumbusFarm.
        harvest();
        // Harvest staked token from vault.
        IColumbusVault(vault).updateAllStrategies();

        // Update user share.
        updateUserShare(_proofId, _user);
        if (_shares == 0 && _amount > 0) {
            currentShare = IColumbusVault(vault).amountToShares(_amount);
            if (currentShare > user.shares) {
                currentShare = user.shares;
            }
        } else {
            currentShare =
                (sharesPercent * user.shares) /
                PRECISION_FACTOR_SHARE;
        }

        // Calculate withdraw fee
        // if ((block.timestamp < user.lastDepositedTime + withdrawFeePeriod)) {
        //     uint256 feeRate = withdrawFee;
        //     uint256 currentWithdrawFee = (currentAmount * feeRate) / 10000;
        //     token.safeTransfer(treasury, currentWithdrawFee);
        //     currentAmount -= currentWithdrawFee;
        // }

        // SafeTransfer YES
        if (user.pendingYESReward > 0) {
            _safeYESTransfer(_user, user.pendingYESReward);
            user.pendingYESReward = 0;
        }

        uint256 bal = IColumbusVault(vault).withdraw(currentShare, 0);
        _stakedTokenTransfer(_user, bal);

        user.shares -= currentShare;
        totalShares -= currentShare;

        if (user.shares == 0 && _proofId > 0) {
            assetCertificate.burn(_proofId);
            delete proofs[_proofId];
        }

        // if (user.shares > 0) {
        //     // user.stakedTokenAtLastUserAction =
        //     //     (user.shares * balanceOf()) /
        //     //     totalShares;
        // } else {
        //     // user.stakedTokenAtLastUserAction = 0;
        //     if (_proofId > 0) {
        //         assetCertificate.burn(_proofId);
        //         delete proofs[_proofId];
        //     }
        // }

        // user.lastUserActionTime = block.timestamp;

        emit Withdraw(msg.sender, _amount, currentShare);
    }

    /**
     * @notice Harvest pending YES tokens from ColumbusFarm
     */
    function harvest() internal {
        uint256 _pendingYES = columbusFarm.pendingYES(poolPID, address(this));
        if (_pendingYES > 0) {
            uint256 balBefore = yesAvailable();
            columbusFarm.claim(poolPID);
            uint256 balAfter = yesAvailable();
            emit Harvest(msg.sender, (balAfter - balBefore));
        }
    }

    function withdrawOverdueFee(address to_) external onlyOwner {
        uint256 bal = IColumbusVault(vault).withdraw(accOverdueShares, 0);
        _stakedTokenTransfer(to_, bal);
        accOverdueShares = 0;
    }

    /**
     * @notice Set treasury address
     * @dev Only callable by the contract owner.
     */
    function setVault(address _vault) external onlyOwner {
        require(_vault != address(0), "Cannot be zero address");
        vault = _vault;
        approveToken();
        emit NewVault(vault);
    }

    function setTreasury(address _treasury) external onlyOwner {
        require(_treasury != address(0), "Cannot be zero address");
        treasury = _treasury;
        // approveToken();
        emit NewTreasury(treasury);
    }

    /**
     * @notice Set overdue fee
     * @dev Only callable by the contract admin.
     */
    function setOverdueFee(uint256 _overdueFee) external onlyOwner {
        require(
            _overdueFee <= MAX_OVERDUE_FEE,
            "overdueFee cannot be more than MAX_OVERDUE_FEE"
        );
        overdueFee = _overdueFee;
        emit NewOverdueFee(_overdueFee);
    }

    /**
     * @notice Set MAX_LOCK_DURATION
     * @dev Only callable by the contract admin.
     */
    function setMaxLockDuration(uint256 _maxLockDuration) external onlyOwner {
        require(
            _maxLockDuration <= MAX_LOCK_DURATION_LIMIT,
            "MAX_LOCK_DURATION cannot be more than MAX_LOCK_DURATION_LIMIT"
        );
        MAX_LOCK_DURATION = _maxLockDuration;
        emit NewMaxLockDuration(_maxLockDuration);
    }

    /**
     * @notice Set DURATION_FACTOR
     * @dev Only callable by the contract admin.
     */
    function setDurationFactor(uint256 _durationFactor) external onlyOwner {
        require(_durationFactor > 0, "DURATION_FACTOR cannot be zero");
        DURATION_FACTOR = _durationFactor;
        emit NewDurationFactor(_durationFactor);
    }

    /**
     * @notice Set BOOST_WEIGHT
     * @dev Only callable by the contract admin.
     */
    function setBoostWeight(uint256 _boostWeight) external onlyOwner {
        require(
            _boostWeight <= BOOST_WEIGHT_LIMIT,
            "BOOST_WEIGHT cannot be more than BOOST_WEIGHT_LIMIT"
        );
        BOOST_WEIGHT = _boostWeight;
        emit NewBoostWeight(_boostWeight);
    }

    function setMinDepositAmount(uint256 _minDepositAmount) external onlyOwner {
        minDepositAmount = _minDepositAmount;
    }

    function setMinWithdrawAmount(uint256 _minWithdrawAmount)
        external
        onlyOwner
    {
        minWithdrawAmount = _minWithdrawAmount;
    }

    function setColumbus(address _columbus) external onlyOwner {
        require(_columbus != address(0), "Cannot be zero address");
        columbus = _columbus;
        emit NewColumbus(columbus);
    }

    /**
     * @notice Withdraw unexpected tokens sent to the YES Pool
     */
    function inCaseTokensGetStuck(address _token) external onlyOwner {
        require(
            _token != address(stakedToken),
            "Token cannot be same as deposit token"
        );

        uint256 amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(msg.sender, amount);
    }

    /**
     * @notice Trigger stopped state
     * @dev Only possible when contract not paused.
     */
    function pause() external onlyOwner whenNotPaused {
        _pause();
        emit Pause();
    }

    /**
     * @notice Return to normal state
     * @dev Only possible when contract is paused.
     */
    function unpause() external onlyOwner whenPaused {
        _unpause();
        // emit Unpause();
    }

    /**
     * @notice Current pool available balance
     * @dev The contract puts 100% of the tokens to work.
     */
    function yesAvailable() public view returns (uint256) {
        return YES.balanceOf(address(this));
    }

    /**
     * @notice Current pool available balance
     * @dev The contract puts 100% of the tokens to work.
     */
    function available() public view returns (uint256 banlance) {
        banlance = stakedToken.balanceOf(address(this));
        banlance +=
            IColumbusVault(vault).balanceOf(address(this)) -
            accOverdueShares;
    }

    /**
     * @notice Calculates the total underlying tokens
     * @dev It includes tokens held by the contract and the boost debt amount.
     */
    function balanceOf() public view returns (uint256) {
        return available() + totalBoostDebt;
    }

    /**
     * @dev View function to see pending YESs on frontend.
     * @param user_ User who receive rewards.
     * @param proofId_ The proof Id.
     * @return amount Amount of reward.
     */
    function pendingYES(address user_, uint256 proofId_)
        external
        view
        returns (uint256)
    {
        UserInfo storage user = userInfo[user_];
        if (proofId_ > 0) {
            user = proofs[proofId_];
        }

        // Calculation YES reward
        uint256 sharesPercent = (user.shares * PRECISION_FACTOR_SHARE) /
            totalShares;
        uint256 pendingYESReward = (yesAvailable() * sharesPercent) /
            PRECISION_FACTOR_SHARE;
        return pendingYESReward;
    }

    /**
     * @dev View function to see pending Compounding Rewards on frontend.
     * @param user_ User who receive rewards.
     * @param proofId_ The proof Id.
     * @return amount Amount of reward.
     */
    function pendingCompoundingRewards(address user_, uint256 proofId_)
        external
        view
        returns (uint256)
    {
        UserInfo storage user = userInfo[user_];
        if (proofId_ > 0) {
            user = proofs[proofId_];
        }

        uint256 currentShares = (balanceOf() * (user.shares)) /
            totalShares -
            user.userBoostedShare;
        return IColumbusVault(vault).sharesToAmount(currentShares);
    }

    /// @notice Safe transfer function, just in case if rounding error causes pool to not have enough STGs.
    /// @param _to The address to transfer tokens to
    /// @param _amount The quantity to transfer
    function _safeYESTransfer(address _to, uint256 _amount) internal {
        IERC20 yes = IERC20(YES);
        uint256 yesBal = yes.balanceOf(address(this));
        if (_amount > yesBal) {
            yes.safeTransfer(_to, yesBal);
        } else {
            yes.safeTransfer(_to, _amount);
        }
    }

    function _stakedTokenTransfer(address _to, uint256 _amount) internal {
        uint256 balance = stakedToken.balanceOf(address(this));
        if (_amount > balance) {
            stakedToken.safeTransfer(_to, balance);
        } else {
            stakedToken.safeTransfer(_to, _amount);
        }
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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