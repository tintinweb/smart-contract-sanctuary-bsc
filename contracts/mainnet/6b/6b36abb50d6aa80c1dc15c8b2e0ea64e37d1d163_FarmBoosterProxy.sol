// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./SafeERC20.sol";
import "./ReentrancyGuard.sol";
import "./IMasterChefV2.sol";
import "./IFarmBooster.sol";

contract FarmBoosterProxy is ReentrancyGuard {
    using SafeERC20 for IERC20;

    // The address of the farm booster proxy factory
    address public immutable FARM_BOOSTER_PROXY_FACTORY;
    IMasterChefV2 public masterchefV2;
    IERC20 public corisToken;
    IFarmBooster public farmBooster;

    address public admin;
    // Whether it is initialized
    bool public isInitialized;
    // Record whether lp was approved
    mapping(address => bool) public lpApproved;

    event DepositByProxy(address indexed user, address indexed proxy, uint256 indexed pid, uint256 amount);
    event WithdrawByProxy(address indexed user, address indexed proxy, uint256 indexed pid, uint256 amount);
    event EmergencyWithdrawByProxy(address indexed user, address indexed proxy, uint256 indexed pid);

    /**
     * @notice Constructor
     */
    constructor() {
        FARM_BOOSTER_PROXY_FACTORY = msg.sender;
    }

    /**
     * @notice Checks if the msg.sender is the admin address.
     */
    modifier onlyAdmin() {
        require(msg.sender == admin, "admin: wut?");
        _;
    }

    /**
     * @notice It initializes the contract
     * @dev It can only be called once.
     * @param _admin: the admin address
     * @param _farmBooster: the farm booster address
     * @param _masterchefV2: the address of the Masterchef V2
     * @param _corisToken: the address of the coris token
     */
    function initialize(
        address _admin,
        address _farmBooster,
        address _masterchefV2,
        address _corisToken
    ) external {
        require(!isInitialized, "Operations: Already initialized");
        require(msg.sender == FARM_BOOSTER_PROXY_FACTORY, "Operations: Not factory");

        // Make this contract initialized
        isInitialized = true;
        admin = _admin;
        farmBooster = IFarmBooster(_farmBooster);
        masterchefV2 = IMasterChefV2(_masterchefV2);
        corisToken = IERC20(_corisToken);
    }

    /**
     * @notice Deposit LP tokens to pool.
     * @dev It can only be called by admin.
     * @param _pid The id of the pool.
     * @param _amount Amount of LP tokens to deposit.
     */
    function deposit(uint256 _pid, uint256 _amount) external nonReentrant onlyAdmin {
        uint256 poolLength = masterchefV2.poolLength();
        require(_pid < poolLength, "Pool is not exist");
        address lpAddress = masterchefV2.lpToken(_pid);
        IERC20(lpAddress).safeTransferFrom(msg.sender, address(this), _amount);
        if (!lpApproved[lpAddress]) {
            IERC20(lpAddress).approve(address(masterchefV2), type(uint256).max);
            lpApproved[lpAddress] = true;
        }
        masterchefV2.deposit(_pid, _amount);
        harvestCoris();
        farmBooster.updatePoolBoostMultiplier(msg.sender, _pid);
        emit DepositByProxy(msg.sender, address(this), _pid, _amount);
    }

    /**
     * @notice Withdraw LP tokens from pool.
     * @dev It can only be called by admin.
     * @param _pid The id of the pool.
     * @param _amount Amount of LP tokens to withdraw.
     */
    function withdraw(uint256 _pid, uint256 _amount) external nonReentrant onlyAdmin {
        uint256 poolLength = masterchefV2.poolLength();
        require(_pid < poolLength, "Pool is not exist");
        masterchefV2.withdraw(_pid, _amount);
        address lpAddress = masterchefV2.lpToken(_pid);
        IERC20(lpAddress).safeTransfer(msg.sender, _amount);
        harvestCoris();
        farmBooster.updatePoolBoostMultiplier(msg.sender, _pid);
        emit WithdrawByProxy(msg.sender, address(this), _pid, _amount);
    }

    /**
     * @notice Withdraw without caring about the rewards. EMERGENCY ONLY.
     * @dev It can only be called by admin.
     * @param _pid The id of the pool.
     */
    function emergencyWithdraw(uint256 _pid) external nonReentrant onlyAdmin {
        uint256 poolLength = masterchefV2.poolLength();
        require(_pid < poolLength, "Pool is not exist");
        masterchefV2.emergencyWithdraw(_pid);
        address lpAddress = masterchefV2.lpToken(_pid);
        IERC20(lpAddress).safeTransfer(msg.sender, IERC20(lpAddress).balanceOf(address(this)));
        harvestCoris();
        farmBooster.updatePoolBoostMultiplier(msg.sender, _pid);
        emit EmergencyWithdrawByProxy(msg.sender, address(this), _pid);
    }

    function harvestCoris() internal {
        uint256 corisBalance = corisToken.balanceOf(address(this));
        if (corisBalance > 0) {
            corisToken.safeTransfer(msg.sender, corisBalance);
        }
    }
}