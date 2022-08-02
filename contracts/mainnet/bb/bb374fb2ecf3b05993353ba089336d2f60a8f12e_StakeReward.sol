// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./SafeERC20.sol";
import "./IERC20.sol";
import "./ERC20.sol";
import "./ReentrancyGuard.sol";

interface IFonos {
  function mint(address to, uint256 amount) external;
  function burn(address to, uint256 amount) external;
}

contract StakeReward is ReentrancyGuard {
    using SafeERC20 for IERC20;

    // The address of the smart stacke reward factory

    // Whether a limit is set for users
    bool public userLimit;

    // Accrued token per share
    uint256 public accTokenPerShare;

    // Block numbers available for user limit (after start block)
    uint256 public numberBlocksForUserLimit;

    // The precision factor
    uint256 public PRECISION_FACTOR = 1e12;

    // The reward token
    IERC20 public rewardToken;

    // The staked token
    IERC20 public stakedToken;

    address public owner;
    uint256 public lastReleaseTime;
    uint256 public totalStaking;
    IFonos fonos;
    // Info of each user that stakes tokens (stakedToken)
    mapping(address => UserInfo) public userInfo;

    struct UserInfo {
        uint256 amount; // How many staked tokens the user has provided
        uint256 rewardDebt; // Reward debt
    }

    event Deposit(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event TokenRecovery(address indexed token, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Release(uint256 time, uint256 releaseBalance, uint256 totalStaking);

    /**
     * @notice Constructor
     */
    constructor(
        IERC20 _stakedToken,
        IERC20 _rewardToken,
        IFonos _fonos,
        uint256 _lastReleaseTime) {
        owner = msg.sender;
        stakedToken = _stakedToken;
        rewardToken = _rewardToken;
        fonos = _fonos;
        lastReleaseTime = _lastReleaseTime;
    }

    /*
     * @notice Deposit staked tokens and collect reward tokens (if any)
     * @param _amount: amount to withdraw (in rewardToken)
     */
    function deposit(uint256 _amount) external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];

        _updatePool();

        if (user.amount > 0) {
            uint256 pending = (user.amount * accTokenPerShare) /
                PRECISION_FACTOR -
                user.rewardDebt;
            if (pending > 0) {
                rewardToken.safeTransfer(address(msg.sender), pending);
            }
        }

        if (_amount > 0) {
            user.amount = user.amount + _amount;
            stakedToken.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
            totalStaking += _amount;
            fonos.mint(msg.sender, _amount);
        }

        user.rewardDebt = (user.amount * accTokenPerShare) / PRECISION_FACTOR;

        emit Deposit(msg.sender, _amount);
    }

    /*
     * @notice Withdraw staked tokens and collect reward tokens
     * @param _amount: amount to withdraw (in rewardToken)
     */
    function withdraw(uint256 _amount) external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "Amount to withdraw too high");

        _updatePool();

        uint256 pending = (user.amount * accTokenPerShare) /
            PRECISION_FACTOR -
            user.rewardDebt;

        if (_amount > 0) {
            totalStaking -= _amount;
            fonos.burn(msg.sender, _amount);
            user.amount = user.amount - _amount;
            stakedToken.safeTransfer(address(msg.sender), _amount);
        }

        if (pending > 0) {
            rewardToken.safeTransfer(address(msg.sender), pending);
        }

        user.rewardDebt = (user.amount * accTokenPerShare) / PRECISION_FACTOR;

        emit Withdraw(msg.sender, _amount);
    }

    /*
     * @notice Withdraw staked tokens without caring about rewards rewards
     * @dev Needs to be for emergency.
     */
    function emergencyWithdraw() external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        uint256 amountToTransfer = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;

        if (amountToTransfer > 0) {
            stakedToken.safeTransfer(address(msg.sender), amountToTransfer);
            fonos.burn(msg.sender, amountToTransfer);
            totalStaking -= amountToTransfer;
        }

        emit EmergencyWithdraw(msg.sender, user.amount);
    }

    /**
     * @notice Allows the owner to recover tokens sent to the contract by mistake
     * @param _token: token address
     * @dev Callable by owner
     */
    function recoverToken(address _token) external {
        require(msg.sender == owner);
        require(
            _token != address(stakedToken),
            "Operations: Cannot recover staked token"
        );
        require(
            _token != address(rewardToken),
            "Operations: Cannot recover reward token"
        );

        uint256 balance = IERC20(_token).balanceOf(address(this));
        require(balance != 0, "Operations: Cannot recover zero balance");

        IERC20(_token).safeTransfer(address(msg.sender), balance);

        emit TokenRecovery(_token, balance);
    }

    /*
     * @notice View function to see pending reward on frontend.
     * @param _user: user address
     * @return Pending reward for a given user
     */
    function pendingReward(address _user) external view returns (uint256) {
        UserInfo memory user = userInfo[_user];
        return
            (user.amount * accTokenPerShare) /
            PRECISION_FACTOR -
            user.rewardDebt;
    }

    /*
     * @notice Update reward variables of the given pool to be up-to-date.
     */
    function _updatePool() internal {
        if (block.timestamp - lastReleaseTime < 1 days) {
            return;
        }
        uint256 balance = getReleaseToken();
        lastReleaseTime += 1 days;
        
        accTokenPerShare =
            accTokenPerShare +
            (balance * PRECISION_FACTOR) /
            totalStaking;
      
        emit Release(block.timestamp, balance, totalStaking);
    }
    function getReleaseToken() public view returns(uint256){
      uint256 balance = rewardToken.balanceOf(address(this));
      if(balance < totalStaking)
        return 0;
      return (balance - totalStaking) / 20;
    }
    function hasUserLimit() external pure returns (bool) {
        return false;
    }
}