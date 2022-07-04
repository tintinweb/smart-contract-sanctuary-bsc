// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./Ownable.sol";
import "./SafeERC20.sol";
import "./Pausable.sol";
import "./ITaskMaster.sol";

contract WayaVault is Ownable, Pausable {
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 shares; // number of shares for a user
        uint256 lastDepositedTime; // keeps track of deposited time for potential penalty
        uint256 wayaAtLastUserAction; // keeps track of waya deposited at the last user action
        uint256 lastUserActionTime; // keeps track of the last user action time
    }

    IERC20 public immutable primaryToken; // Waya token
    IERC20 public immutable receiptTaken; // Gaya token

    ITaskMaster public immutable taskmaster;

    mapping(address => UserInfo) public userInfo;

    uint256 public totalShares;
    uint256 public lastHarvestedTime;
    address public Contract_Manager;
    address public Financial_Controller;

    uint256 public constant MAX_PERFORMANCE_FEE = 500; // 5%
    uint256 public constant MAX_CALL_FEE = 100; // 1%
    uint256 public constant MAX_WITHDRAW_FEE = 100; // 1%
    uint256 public constant MAX_WITHDRAW_FEE_PERIOD = 72 hours; // 3 days

    uint256 constant MAX_INT = 2**256 - 1;

    uint256 public performanceFee = 200; // 2%
    uint256 public callFee = 25; // 0.25%
    uint256 public withdrawFee = 10; // 0.1%
    uint256 public withdrawFeePeriod = 72 hours; // 3 days

    event Deposit(address indexed sender, uint256 amount, uint256 shares, uint256 lastDepositedTime);
    event Withdraw(address indexed sender, uint256 amount, uint256 shares);
    event Harvest(address indexed sender, uint256 performanceFee, uint256 callFee);
    event Pause();
    event Unpause();

    /**
     * @notice Constructor
     * @param _primaryToken: Waya token contract
     * @param _receiptToken: Gaya token contract
     * @param _taskmaster: TaskMaster contract
     * @param _contract_Manager: address of the Contract_Manager
     * @param _financial_Controller: address of the Financial_Controller (collects fees)
     */
    constructor(
        IERC20 _primaryToken,
        IERC20 _receiptToken,
        ITaskMaster _taskmaster,
        address _contract_Manager,
        address _financial_Controller
    ) {
        primaryToken = _primaryToken;
        receiptTaken = _receiptToken;
        taskmaster = _taskmaster;
        Contract_Manager = _contract_Manager;
        Financial_Controller = _financial_Controller;

        // Infinite approve
        IERC20(_primaryToken).safeApprove(address(_taskmaster), MAX_INT);
    }

    /**
     * @notice Checks if the msg.sender is the Contract_Manager address
     */
    modifier onlyContractManager() {
        require(msg.sender == Contract_Manager, "Contract_Manager: wut?");
        _;
    }

    /**
     * @notice Checks if the msg.sender is a contract or a proxy
     */
    modifier notContract() {
        require(!_isContract(msg.sender), "contract not allowed");
        require(msg.sender == tx.origin, "proxy contract not allowed");
        _;
    }

    /**
     * @notice Deposits funds into the Waya Vault
     * @dev Only possible when contract not paused.
     * @param _amount: number of tokens to deposit (in WAYA)
     */
    function deposit(uint256 _amount) external whenNotPaused notContract {
        require(_amount > 0, "Nothing to deposit");

        uint256 pool = balanceOf();
        primaryToken.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 currentShares = 0;
        if (totalShares != 0) {
            currentShares = (_amount *totalShares) / pool;
        } else {
            currentShares = _amount;
        }
        UserInfo storage user = userInfo[msg.sender];

        user.shares = user.shares + currentShares;
        user.lastDepositedTime = block.timestamp;

        totalShares = totalShares + currentShares;

        user.wayaAtLastUserAction = (user.shares * balanceOf()) / totalShares;
        user.lastUserActionTime = block.timestamp;

        _earn();

        emit Deposit(msg.sender, _amount, currentShares, block.timestamp);
    }

    /**
     * @notice Withdraws all funds for a user
     */
    function withdrawAll() external notContract {
        withdraw(userInfo[msg.sender].shares);
    }

    /**
     * @notice Reinvests WAYA tokens into TaskMaster
     * @dev Only possible when contract not paused.
     */
    function harvest() external notContract whenNotPaused {
        ITaskMaster(taskmaster).leaveStaking(0);

        uint256 bal = available();
        uint256 currentPerformanceFee = (bal * performanceFee) / 10000;
        primaryToken.safeTransfer(Financial_Controller, currentPerformanceFee);

        uint256 currentCallFee = (bal * callFee) / 10000;
        primaryToken.safeTransfer(msg.sender, currentCallFee);

        _earn();

        lastHarvestedTime = block.timestamp;

        emit Harvest(msg.sender, currentPerformanceFee, currentCallFee);
    }

    /**
     * @notice Sets Contract_Manager address
     * @dev Only callable by the contract owner.
     */
    function setContractManager(address _contract_Manager) external onlyOwner {
        require(_contract_Manager != address(0), "Cannot be zero address");
        Contract_Manager = _contract_Manager;
    }

    /**
     * @notice Sets Financial_Controller address
     * @dev Only callable by the contract owner.
     */
    function setFinancialController(address _financial_Controller) external onlyOwner {
        require(_financial_Controller != address(0), "Cannot be zero address");
        Financial_Controller = _financial_Controller;
    }

    /**
     * @notice Sets performance fee
     * @dev Only callable by the contract Contract_Manager.
     */
    function setPerformanceFee(uint256 _performanceFee) external onlyContractManager {
        require(_performanceFee <= MAX_PERFORMANCE_FEE, "performanceFee cannot be more than MAX_PERFORMANCE_FEE");
        performanceFee = _performanceFee;
    }

    /**
     * @notice Sets call fee
     * @dev Only callable by the contract Contract_Manager.
     */
    function setCallFee(uint256 _callFee) external onlyContractManager {
        require(_callFee <= MAX_CALL_FEE, "callFee cannot be more than MAX_CALL_FEE");
        callFee = _callFee;
    }

    /**
     * @notice Sets withdraw fee
     * @dev Only callable by the contract Contract_Manager.
     */
    function setWithdrawFee(uint256 _withdrawFee) external onlyContractManager {
        require(_withdrawFee <= MAX_WITHDRAW_FEE, "withdrawFee cannot be more than MAX_WITHDRAW_FEE");
        withdrawFee = _withdrawFee;
    }

    /**
     * @notice Sets withdraw fee period
     * @dev Only callable by the contract Contract_Manager.
     */
    function setWithdrawFeePeriod(uint256 _withdrawFeePeriod) external onlyContractManager {
        require(
            _withdrawFeePeriod <= MAX_WITHDRAW_FEE_PERIOD,
            "withdrawFeePeriod cannot be more than MAX_WITHDRAW_FEE_PERIOD"
        );
        withdrawFeePeriod = _withdrawFeePeriod;
    }

    /**
     * @notice Withdraws from TaskMaster to Vault without caring about rewards.
     * @dev EMERGENCY ONLY. Only callable by the contract Contract_Manager.
     */
    function emergencyWithdraw() external onlyContractManager {
        ITaskMaster(taskmaster).emergencyWithdraw(0);
    }

    /**
     * @notice Withdraw unexpected primaryTokens sent to the Waya Vault
     */
    function inCaseTokensGetStuck(address _token) external onlyContractManager {
        require(_token != address(primaryToken), "Token cannot be same as deposit token");
        require(_token != address(receiptTaken), "Token cannot be same as receipt token");

        uint256 amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(msg.sender, amount);
    }

    /**
     * @notice Triggers stopped state
     * @dev Only possible when contract not paused.
     */
    function pause() external onlyContractManager whenNotPaused {
        _pause();
        emit Pause();
    }

    /**
     * @notice Returns to normal state
     * @dev Only possible when contract is paused.
     */
    function unpause() external onlyContractManager whenPaused {
        _unpause();
        emit Unpause();
    }

    /**
     * @notice Calculates the expected harvest reward from third party
     * @return Expected reward to collect in WAYA
     */
    function calculateHarvestWayaRewards() external view returns (uint256) {
        uint256 amount = ITaskMaster(taskmaster).pendingWaya(0, address(this));
        amount = amount + available();
        uint256 currentCallFee = (amount * callFee) / 10000;

        return currentCallFee;
    }

    /**
     * @notice Calculates the total pending rewards that can be restaked
     * @return Returns total pending waya rewards
     */
    function calculateTotalPendingWayaRewards() external view returns (uint256) {
        uint256 amount = ITaskMaster(taskmaster).pendingWaya(0, address(this));
        amount = amount + available();

        return amount;
    }

    /**
     * @notice Calculates the price per share
     */
    function getPricePerFullShare() external view returns (uint256) {
        return totalShares == 0 ? 1e18 : (balanceOf() * (1e18)) / totalShares;
    }

    /**
     * @notice Withdraws from funds from the Waya Vault
     * @param _shares: Number of shares to withdraw
     */
    function withdraw(uint256 _shares) public notContract {
        UserInfo storage user = userInfo[msg.sender];
        require(_shares > 0, "Nothing to withdraw");
        require(_shares <= user.shares, "Withdraw amount exceeds balance");

        uint256 currentAmount = (balanceOf() * _shares) / totalShares;
        user.shares = user.shares - _shares;
        totalShares = totalShares - _shares;

        uint256 bal = available();
        if (bal < currentAmount) {
            uint256 balWithdraw = currentAmount - bal;
            ITaskMaster(taskmaster).leaveStaking(balWithdraw);
            uint256 balAfter = available();
            uint256 diff = balAfter - bal;
            if (diff < balWithdraw) {
                currentAmount = bal - diff;
            }
        }

        if (block.timestamp < user.lastDepositedTime + withdrawFeePeriod) {
            uint256 currentWithdrawFee = (currentAmount * withdrawFee) / 10000;
            primaryToken.safeTransfer(Financial_Controller, currentWithdrawFee);
            currentAmount = currentAmount - currentWithdrawFee;
        }

        if (user.shares > 0) {
            user.wayaAtLastUserAction = (user.shares * balanceOf()) / totalShares;
        } else {
            user.wayaAtLastUserAction = 0;
        }

        user.lastUserActionTime = block.timestamp;

        primaryToken.safeTransfer(msg.sender, currentAmount);

        emit Withdraw(msg.sender, currentAmount, _shares);
    }

    /**
     * @notice Custom logic for how much the vault allows to be borrowed
     * @dev The contract puts 100% of the tokens to work.
     */
    function available() public view returns (uint256) {
        return primaryToken.balanceOf(address(this));
    }

    /**
     * @notice Calculates the total underlying tokens
     * @dev It includes tokens held by the contract and held in TaskMaster
     */
    function balanceOf() public view returns (uint256) {
        (uint256 amount, ) = ITaskMaster(taskmaster).userInfo(0, address(this));
        return primaryToken.balanceOf(address(this)) + amount;
    }

    /**
     * @notice Deposits tokens into TaskMaster to earn staking rewards
     */
    function _earn() internal {
        uint256 bal = available();
        if (bal > 0) {
            ITaskMaster(taskmaster).enterStaking(bal);
        }
    }

    /**
     * @notice Checks if address is a contract
     * @dev It prevents contract from being targetted
     */
    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}