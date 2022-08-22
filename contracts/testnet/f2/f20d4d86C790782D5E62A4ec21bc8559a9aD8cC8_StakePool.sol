// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "./OwnableUpgradeable.sol";
import "./SafeMathUpgradeable.sol";
import "./EnumerableSetUpgradeable.sol";
import "./Initializable.sol";

import "./IERC20Upgradeable.sol";
import "./SafeERC20Upgradeable.sol";

import "./IERC721Upgradeable.sol";
import "./IERC721ReceiverUpgradeable.sol";
import "./PausableUpgradeable.sol";

import "./BeaconProxy.sol";
import "./IBeacon.sol";
import "./UpgradeableBeacon.sol";

import "./CountersUpgradeable.sol";
import "./ReentrancyGuardUpgradeable.sol";

import "./ITicket.sol";

contract StakePool is Initializable, ReentrancyGuardUpgradeable, OwnableUpgradeable, PausableUpgradeable  {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    using SafeMathUpgradeable for uint256;

    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeMathUpgradeable for uint256;
    using CountersUpgradeable for CountersUpgradeable.Counter;

    event Stake(address user, address token, uint256 amount, uint256 timestamp);
    event Unstake(address user, address token, uint256 amount, uint256 timestamp);
    event Claim(address user, address nft, uint256 id, uint256 timestamp);


    IERC20Upgradeable public stakeToken;
    uint256 public stakeDuration;
    uint256 public stakeAmount; // fixed amount，100 XCV

    address public ticketNFT;
    mapping(address => bool) public isStaker;
    mapping(address => uint256) public lastUpdateAt;

    function initialize(
        address _multisig,
        address _stakeToken, // xcv 
        uint256 _stakeDuration, // 7 days ---> 2 hours
        uint256 _stakeAmount, // 100 xcv
        address _ticketNFT
    ) external initializer {
        require(_stakeAmount > 0, "zero amount");
        require(_stakeDuration > 0, "zero duration");
        stakeToken = IERC20Upgradeable(_stakeToken);
        __ReentrancyGuard_init();
        __Ownable_init();
        __Pausable_init();


        stakeDuration = _stakeDuration;
        stakeAmount = _stakeAmount;
        ticketNFT = _ticketNFT;

        transferOwnership(_multisig);
    }

    function stake() external nonReentrant whenNotPaused {
        require(!isStaker[msg.sender], "already staked");
        lastUpdateAt[msg.sender] = block.timestamp;
        isStaker[msg.sender] = true;

        stakeToken.safeTransferFrom(msg.sender, address(this), stakeAmount);

        emit Stake(msg.sender, address(stakeToken), stakeAmount, block.timestamp);
    }

    function unstake() external nonReentrant  {
        _unstake();
    }

    function _unstake() internal {
        require(isStaker[msg.sender], "msg.sender is not a staker");
        if (block.timestamp >= lastUpdateAt[msg.sender] + stakeDuration && !paused()) {
            _claim();
        }

        lastUpdateAt[msg.sender] = block.timestamp;
        isStaker[msg.sender] = false;

        stakeToken.safeTransfer(msg.sender, stakeAmount);

        emit Unstake(msg.sender, address(stakeToken), stakeAmount, block.timestamp);
    }

    function claim() external nonReentrant whenNotPaused {
        _claim();
    }

    function _claim() internal {
        require(block.timestamp >= lastUpdateAt[msg.sender] + stakeDuration, "require T + n days");
        require(isStaker[msg.sender], "No eligibility");

        lastUpdateAt[msg.sender] = block.timestamp;

        uint256 _id = ITicket(ticketNFT).totalSupply();
        ITicket(ticketNFT).mint(msg.sender, _id);

        emit Claim(msg.sender, ticketNFT, _id, block.timestamp);
    }

    function pause() external whenNotPaused onlyOwner {
        super._pause();
    }

    function unpause() external whenPaused onlyOwner {
        super._unpause();
    }

    function setStakeDuration(uint256 _newStakeDruation) external onlyOwner {
        require(_newStakeDruation > 0, "zero duration");
        stakeDuration = _newStakeDruation;
    }

}