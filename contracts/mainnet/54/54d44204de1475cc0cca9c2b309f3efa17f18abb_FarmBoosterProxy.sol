// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./SafeERC20.sol";
import "./ReentrancyGuard.sol";
import "./IChiefFarmer.sol";
import "./IFarmBooster.sol";

contract FarmBoosterProxy is ReentrancyGuard {
    using SafeERC20 for IERC20;

    // The address of the farm booster proxy factory
    address public immutable FARM_BOOSTER_PROXY_FACTORY;
    IChiefFarmer public ChiefFarmer;
    IERC20 public WAYA;
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
     * @param _ChiefFarmer: the address of the ChiefFarmer
     * @param _Waya: the address of the waya token
     */
    function initialize(
        address _admin,
        address _farmBooster,
        address _ChiefFarmer,
        address _Waya
    ) external {
        require(!isInitialized, "Operations: Already initialized");
        require(msg.sender == FARM_BOOSTER_PROXY_FACTORY, "Operations: Not factory");

        // Make this contract initialized
        isInitialized = true;
        admin = _admin;
        farmBooster = IFarmBooster(_farmBooster);
        ChiefFarmer = IChiefFarmer(_ChiefFarmer);
        WAYA = IERC20(_Waya);
    }

    /**
     * @notice Deposit LP tokens to pool.
     * @dev It can only be called by admin.
     * @param _pid The id of the pool.
     * @param _amount Amount of LP tokens to deposit.
     */
    function deposit(uint256 _pid, uint256 _amount) external nonReentrant onlyAdmin {
        uint256 poolLength = ChiefFarmer.poolLength();
        require(_pid < poolLength, "Pool is not exist");
        address lpAddress = ChiefFarmer.lpToken(_pid);
        IERC20(lpAddress).safeTransferFrom(msg.sender, address(this), _amount);
        if (!lpApproved[lpAddress]) {
            IERC20(lpAddress).approve(address(ChiefFarmer), type(uint256).max);
            lpApproved[lpAddress] = true;
        }
        ChiefFarmer.deposit(_pid, _amount);
        harvestWaya();
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
        uint256 poolLength = ChiefFarmer.poolLength();
        require(_pid < poolLength, "Pool is not exist");
        ChiefFarmer.withdraw(_pid, _amount);
        address lpAddress = ChiefFarmer.lpToken(_pid);
        IERC20(lpAddress).safeTransfer(msg.sender, _amount);
        harvestWaya();
        farmBooster.updatePoolBoostMultiplier(msg.sender, _pid);
        emit WithdrawByProxy(msg.sender, address(this), _pid, _amount);
    }

    /**
     * @notice Withdraw without caring about the rewards. EMERGENCY ONLY.
     * @dev It can only be called by admin.
     * @param _pid The id of the pool.
     */
    function emergencyWithdraw(uint256 _pid) external nonReentrant onlyAdmin {
        uint256 poolLength = ChiefFarmer.poolLength();
        require(_pid < poolLength, "Pool is not exist");
        ChiefFarmer.emergencyWithdraw(_pid);
        address lpAddress = ChiefFarmer.lpToken(_pid);
        IERC20(lpAddress).safeTransfer(msg.sender, IERC20(lpAddress).balanceOf(address(this)));
        harvestWaya();
        farmBooster.updatePoolBoostMultiplier(msg.sender, _pid);
        emit EmergencyWithdrawByProxy(msg.sender, address(this), _pid);
    }

    function harvestWaya() internal {
        uint256 wayaBalance = WAYA.balanceOf(address(this));
        if (wayaBalance > 0) {
            WAYA.safeTransfer(msg.sender, wayaBalance);
        }
    }
}