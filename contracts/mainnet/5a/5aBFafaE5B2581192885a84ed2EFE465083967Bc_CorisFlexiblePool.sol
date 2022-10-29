// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./SafeBEP20.sol";
import "./Pausable.sol";
import "./ICorisPool.sol";

contract CorisFlexiblePool is Ownable, Pausable {
    using SafeBEP20 for IBEP20;

    struct UserInfo {
        uint256 shares; // number of shares for a user
        uint256 lastDepositedTime; // keeps track of deposited time for potential penalty
        uint256 corisAtLastUserAction; // keeps track of coris deposited at the last user action
        uint256 lastUserActionTime; // keeps track of the last user action time
    }

    IBEP20 public immutable token; // Coris token
    ICorisPool public immutable corisPool; //Coris pool

    mapping(address => UserInfo) public userInfo;

    uint256 public totalShares;
    address public admin;
    address public treasury;
    bool public staking = true;

    uint256 public constant MAX_PERFORMANCE_FEE = 2000; // 20%
    uint256 public constant MAX_WITHDRAW_FEE = 500; // 5%
    uint256 public constant MAX_WITHDRAW_FEE_PERIOD = 1 weeks; // 1 week
    uint256 public constant MAX_WITHDRAW_AMOUNT_BOOSTER = 10010; // 1.001
    uint256 public constant MIN_DEPOSIT_AMOUNT = 0.00001 ether;
    uint256 public constant MIN_WITHDRAW_AMOUNT = 0.00001 ether;
    uint256 public constant MIN_WITHDRAW_AMOUNT_BOOSTER = 10000; // 1

    //When call corispool.withdrawByAmount function,there will be a loss of precision, so need to withdraw more.
    uint256 public withdrawAmountBooster = 10001; // 1.0001
    uint256 public performanceFee = 200; // 2%
    uint256 public withdrawFee = 10; // 0.1%
    uint256 public withdrawFeePeriod = 72 hours; // 3 days

    event DepositCoris(address indexed sender, uint256 amount, uint256 shares, uint256 lastDepositedTime);
    event WithdrawShares(address indexed sender, uint256 amount, uint256 shares);
    event ChargePerformanceFee(address indexed sender, uint256 amount, uint256 shares);
    event ChargeWithdrawFee(address indexed sender, uint256 amount);
    event Pause();
    event Unpause();
    event NewAdmin(address admin);
    event NewTreasury(address treasury);
    event NewPerformanceFee(uint256 performanceFee);
    event NewWithdrawFee(uint256 withdrawFee);
    event NewWithdrawFeePeriod(uint256 withdrawFeePeriod);
    event NewWithdrawAmountBooster(uint256 withdrawAmountBooster);

    /**
     * @notice Constructor
     * @param _token: Coris token contract
     * @param _corisPool: CorisPool contract
     * @param _admin: address of the admin
     * @param _treasury: address of the treasury (collects fees)
     */
    constructor(
        IBEP20 _token,
        ICorisPool _corisPool,
        address _admin,
        address _treasury
    ) {
        token = _token;
        corisPool = _corisPool;
        admin = _admin;
        treasury = _treasury;

        // Infinite approve
        IBEP20(_token).safeApprove(address(_corisPool), type(uint256).max);
    }

    /**
     * @notice Checks if the msg.sender is the admin address
     */
    modifier onlyAdmin() {
        require(msg.sender == admin, "admin: wut?");
        _;
    }

    /**
     * @notice Deposits funds into the Coris Flexible Pool.
     * @dev Only possible when contract not paused.
     * @param _amount: number of tokens to deposit (in CORIS)
     */
    function deposit(uint256 _amount) external whenNotPaused {
        require(staking, "Not allowed to stake");
        require(_amount > MIN_DEPOSIT_AMOUNT, "Deposit amount must be greater than MIN_DEPOSIT_AMOUNT");
        UserInfo storage user = userInfo[msg.sender];
        //charge performanceFee
        bool chargeFeeFromDeposite;
        uint256 currentPerformanceFee;
        uint256 performanceFeeShares;
        if (user.shares > 0) {
            uint256 totalAmount = (user.shares * balanceOf()) / totalShares;
            uint256 earnAmount = totalAmount - user.corisAtLastUserAction;
            currentPerformanceFee = (earnAmount * performanceFee) / 10000;
            if (currentPerformanceFee > 0) {
                performanceFeeShares = (currentPerformanceFee * totalShares) / balanceOf();
                user.shares -= performanceFeeShares;
                totalShares -= performanceFeeShares;
                if (_amount >= currentPerformanceFee) {
                    chargeFeeFromDeposite = true;
                } else {
                    // withdrawByAmount have a MIN_WITHDRAW_AMOUNT limit ,so need to withdraw more than MIN_WITHDRAW_AMOUNT.
                    uint256 withdrawAmount = currentPerformanceFee < MIN_WITHDRAW_AMOUNT
                        ? MIN_WITHDRAW_AMOUNT
                        : currentPerformanceFee;
                    //There will be a loss of precision when call withdrawByAmount, so need to withdraw more.
                    withdrawAmount = (withdrawAmount * withdrawAmountBooster) / 10000;
                    corisPool.withdrawByAmount(withdrawAmount);

                    currentPerformanceFee = available() >= currentPerformanceFee ? currentPerformanceFee : available();
                    token.safeTransfer(treasury, currentPerformanceFee);
                    emit ChargePerformanceFee(msg.sender, currentPerformanceFee, performanceFeeShares);
                }
            }
        }
        uint256 pool = balanceOf();
        token.safeTransferFrom(msg.sender, address(this), _amount);
        if (chargeFeeFromDeposite) {
            token.safeTransfer(treasury, currentPerformanceFee);
            emit ChargePerformanceFee(msg.sender, currentPerformanceFee, performanceFeeShares);
            pool -= currentPerformanceFee;
        }
        uint256 currentShares;
        if (totalShares != 0) {
            currentShares = (_amount * totalShares) / pool;
        } else {
            currentShares = _amount;
        }

        user.shares += currentShares;
        user.lastDepositedTime = block.timestamp;

        totalShares += currentShares;

        _earn();

        user.corisAtLastUserAction = (user.shares * balanceOf()) / totalShares;
        user.lastUserActionTime = block.timestamp;

        emit DepositCoris(msg.sender, _amount, currentShares, block.timestamp);
    }

    /**
     * @notice Withdraws funds from the Coris Flexible Pool
     * @param _shares: Number of shares to withdraw
     */
    function withdraw(uint256 _shares) public {
        UserInfo storage user = userInfo[msg.sender];
        require(_shares > 0, "Nothing to withdraw");
        require(_shares <= user.shares, "Withdraw amount exceeds balance");
        //charge performanceFee
        uint256 totalAmount = (user.shares * balanceOf()) / totalShares;
        uint256 earnAmount = totalAmount - user.corisAtLastUserAction;
        uint256 currentPerformanceFee;
        uint256 performanceFeeShares;
        if (earnAmount > 0) {
            currentPerformanceFee = (earnAmount * performanceFee) / 10000;
            performanceFeeShares = (currentPerformanceFee * totalShares) / balanceOf();
            user.shares -= performanceFeeShares;
            totalShares -= performanceFeeShares;
        }
        //Update withdraw shares
        if (_shares > user.shares) {
            _shares = user.shares;
        }
        //The current pool balance should not include currentPerformanceFee.
        uint256 currentAmount = (_shares * (balanceOf() - currentPerformanceFee)) / totalShares;
        user.shares -= _shares;
        totalShares -= _shares;
        uint256 withdrawAmount = currentAmount + currentPerformanceFee;
        if (staking) {
            // withdrawByAmount have a MIN_WITHDRAW_AMOUNT limit ,so need to withdraw more than MIN_WITHDRAW_AMOUNT.
            withdrawAmount = withdrawAmount < MIN_WITHDRAW_AMOUNT ? MIN_WITHDRAW_AMOUNT : withdrawAmount;
            //There will be a loss of precision when call withdrawByAmount, so need to withdraw more.
            withdrawAmount = (withdrawAmount * withdrawAmountBooster) / 10000;
            corisPool.withdrawByAmount(withdrawAmount);
        }

        uint256 currentWithdrawFee;
        if (block.timestamp < user.lastDepositedTime + withdrawFeePeriod) {
            currentWithdrawFee = (currentAmount * withdrawFee) / 10000;
            currentAmount -= currentWithdrawFee;
        }
        //Combine two fees to reduce gas
        uint256 totalFee = currentPerformanceFee + currentWithdrawFee;
        if (totalFee > 0) {
            totalFee = available() >= totalFee ? totalFee : available();
            token.safeTransfer(treasury, totalFee);
            if (currentPerformanceFee > 0) {
                emit ChargePerformanceFee(msg.sender, currentPerformanceFee, performanceFeeShares);
            }
            if (currentWithdrawFee > 0) {
                emit ChargeWithdrawFee(msg.sender, currentWithdrawFee);
            }
        }

        currentAmount = available() >= currentAmount ? currentAmount : available();
        token.safeTransfer(msg.sender, currentAmount);

        if (user.shares > 0) {
            user.corisAtLastUserAction = (user.shares * balanceOf()) / totalShares;
        } else {
            user.corisAtLastUserAction = 0;
        }

        user.lastUserActionTime = block.timestamp;

        emit WithdrawShares(msg.sender, currentAmount, _shares);
    }

    /**
     * @notice Withdraws all funds for a user
     */
    function withdrawAll() external {
        withdraw(userInfo[msg.sender].shares);
    }

    /**
     * @notice Sets admin address
     * @dev Only callable by the contract owner.
     */
    function setAdmin(address _admin) external onlyOwner {
        require(_admin != address(0), "Cannot be zero address");
        admin = _admin;
        emit NewAdmin(admin);
    }

    /**
     * @notice Sets treasury address
     * @dev Only callable by the contract owner.
     */
    function setTreasury(address _treasury) external onlyOwner {
        require(_treasury != address(0), "Cannot be zero address");
        treasury = _treasury;
        emit NewTreasury(treasury);
    }

    /**
     * @notice Sets performance fee
     * @dev Only callable by the contract admin.
     */
    function setPerformanceFee(uint256 _performanceFee) external onlyAdmin {
        require(_performanceFee <= MAX_PERFORMANCE_FEE, "performanceFee cannot be more than MAX_PERFORMANCE_FEE");
        performanceFee = _performanceFee;
        emit NewPerformanceFee(performanceFee);
    }

    /**
     * @notice Sets withdraw fee
     * @dev Only callable by the contract admin.
     */
    function setWithdrawFee(uint256 _withdrawFee) external onlyAdmin {
        require(_withdrawFee <= MAX_WITHDRAW_FEE, "withdrawFee cannot be more than MAX_WITHDRAW_FEE");
        withdrawFee = _withdrawFee;
        emit NewWithdrawFee(withdrawFee);
    }

    /**
     * @notice Sets withdraw fee period
     * @dev Only callable by the contract admin.
     */
    function setWithdrawFeePeriod(uint256 _withdrawFeePeriod) external onlyAdmin {
        require(
            _withdrawFeePeriod <= MAX_WITHDRAW_FEE_PERIOD,
            "withdrawFeePeriod cannot be more than MAX_WITHDRAW_FEE_PERIOD"
        );
        withdrawFeePeriod = _withdrawFeePeriod;
        emit NewWithdrawFeePeriod(withdrawFeePeriod);
    }

    /**
     * @notice Sets withdraw amount booster
     * @dev Only callable by the contract admin.
     */
    function setWithdrawAmountBooster(uint256 _withdrawAmountBooster) external onlyAdmin {
        require(
            _withdrawAmountBooster >= MIN_WITHDRAW_AMOUNT_BOOSTER,
            "withdrawAmountBooster cannot be less than MIN_WITHDRAW_AMOUNT_BOOSTER"
        );
        require(
            _withdrawAmountBooster <= MAX_WITHDRAW_AMOUNT_BOOSTER,
            "withdrawAmountBooster cannot be more than MAX_WITHDRAW_AMOUNT_BOOSTER"
        );
        withdrawAmountBooster = _withdrawAmountBooster;
        emit NewWithdrawAmountBooster(withdrawAmountBooster);
    }

    /**
     * @notice Withdraws from Coris Pool without caring about rewards.
     * @dev EMERGENCY ONLY. Only callable by the contract admin.
     */
    function emergencyWithdraw() external onlyAdmin {
        require(staking, "No staking coris");
        staking = false;
        corisPool.withdrawAll();
    }

    /**
     * @notice Withdraw unexpected tokens sent to the Coris Flexible Pool
     */
    function inCaseTokensGetStuck(address _token) external onlyAdmin {
        require(_token != address(token), "Token cannot be same as deposit token");

        uint256 amount = IBEP20(_token).balanceOf(address(this));
        IBEP20(_token).safeTransfer(msg.sender, amount);
    }

    /**
     * @notice Triggers stopped state
     * @dev Only possible when contract not paused.
     */
    function pause() external onlyAdmin whenNotPaused {
        _pause();
        emit Pause();
    }

    /**
     * @notice Returns to normal state
     * @dev Only possible when contract is paused.
     */
    function unpause() external onlyAdmin whenPaused {
        _unpause();
        emit Unpause();
    }

    /**
     * @notice Calculates the price per share
     */
    function getPricePerFullShare() external view returns (uint256) {
        return totalShares == 0 ? 1e18 : (balanceOf() * 1e18) / totalShares;
    }

    /**
     * @notice Custom logic for how much the pool to be borrowed
     * @dev The contract puts 100% of the tokens to work.
     */
    function available() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    /**
     * @notice Calculates the total underlying tokens
     * @dev It includes tokens held by the contract and held in CorisPool
     */
    function balanceOf() public view returns (uint256) {
        (uint256 shares, , , , , , , , ) = corisPool.userInfo(address(this));
        uint256 pricePerFullShare = corisPool.getPricePerFullShare();

        return token.balanceOf(address(this)) + (shares * pricePerFullShare) / 1e18;
    }

    /**
     * @notice Deposits tokens into CorisPool to earn staking rewards
     */
    function _earn() internal {
        uint256 bal = available();
        if (bal > 0) {
            corisPool.deposit(bal, 0);
        }
    }
}