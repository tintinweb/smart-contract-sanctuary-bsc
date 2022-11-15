// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import 'Ownable.sol';
import 'SafeERC20.sol';
import 'IERC20.sol';
import 'ReentrancyGuard.sol';
import 'SafeMath.sol';
import 'Runnable.sol';

contract Staking is ReentrancyGuard, Ownable, Runnable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public injectorAddress;
    address public operatorAddress;

    uint256 public constant BASE_TIME_UNIT = 1 minutes;
    uint256 public constant MAX_DAY_REFUND = 30; // 90
    uint256 public constant MAX_DAY_INTEREST = 60; // 270
    uint256 public constant TOKEN_DECIMALS = 8;
    uint256 public constant MAX_DIVISOR = 100000; // 100%
    uint256 public constant DAY_PER_MONTH = 30;
    uint256 public constant MAX_DAY_EXTEND = 3;

    IERC20 public stakingToken;

    struct UserInfo {
        uint256 currentDeposited;

        // Interest
        uint256 totalInterestClaimed; // add when claim interest
        uint256 lastClaimInterestTimestamp; // to calculate reward
        uint256 maxClaimInterestTimestamp; // to check re-stake

        // Principal
        uint256 currentPrincipal; // add when stake
        uint256 totalPrincipalClaimed; // calculate when claim principal
        uint256 remainingPrincipal; // calculate when claim principal
        uint256 lastClaimPrincipalTimestamp; // set when stake first time and update when claim principal
        uint256 maxClaimPrincipalTimestamp; // set when stake first time

        // Time
        uint256 extendExpireTimestamp; // set when stake first time
    }

    mapping(address => UserInfo) public LIST_USER;

    event StakingToken(address userAddress, uint256 tokenAmount, uint256 totalStakingAmount);

    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    modifier onlyOperator() {
        require(msg.sender == operatorAddress, "Not operator");
        _;
    }

    modifier onlyOwnerOrInjector() {
        require((msg.sender == owner()) || (msg.sender == injectorAddress), "Not owner or injector");
        _;
    }

    /**
     * @notice Constructor
     * @param _stakingToken: address of the staking token
     */
    constructor(address _stakingToken) {
        stakingToken = IERC20(_stakingToken);
    }

    /**
     * @notice Staking token
     * @param tokenAmount: amount of token
     * @dev Callable by users
     */
    function staking(uint256 tokenAmount) external notContract whenRunning nonReentrant {
        UserInfo storage user = LIST_USER[msg.sender];

        // New staking
        if (user.currentDeposited == 0) {
            require(user.lastClaimInterestTimestamp >= user.maxClaimInterestTimestamp, "Remaining interest");
            require(tokenAmount >= 2000 * (10 ** TOKEN_DECIMALS), "Invalid min amount");
            user.maxClaimInterestTimestamp = block.timestamp + (MAX_DAY_INTEREST * BASE_TIME_UNIT);
            user.extendExpireTimestamp = user.maxClaimInterestTimestamp + (MAX_DAY_EXTEND * BASE_TIME_UNIT);
            user.lastClaimPrincipalTimestamp = user.maxClaimInterestTimestamp;
            user.maxClaimPrincipalTimestamp = user.lastClaimPrincipalTimestamp + (MAX_DAY_REFUND * BASE_TIME_UNIT);
        } else {
            // Claim interest
            uint256 allowClaimInterestTimestamp = block.timestamp;
            bool lastTime = false;
            if (allowClaimInterestTimestamp > user.maxClaimInterestTimestamp) {
                // claim interest last time
                allowClaimInterestTimestamp = user.maxClaimInterestTimestamp;
                lastTime = true;
            }
            uint256 stakingDistanceTimestamp = allowClaimInterestTimestamp.sub(user.lastClaimInterestTimestamp);
            uint256 interestPercentPerSecond = getInterestPercentMonth(user.currentDeposited).div(DAY_PER_MONTH).div(BASE_TIME_UNIT);
            uint256 interestPercent = interestPercentPerSecond * stakingDistanceTimestamp;
            uint256 interestAmount = user.currentDeposited.div(MAX_DIVISOR).mul(interestPercent);
            if (interestAmount > 0) {
                stakingToken.safeTransfer(address(msg.sender), interestAmount);
                user.totalInterestClaimed += interestAmount;
            }
            if (lastTime) {
                user.currentPrincipal = user.remainingPrincipal + user.currentDeposited;
                user.currentDeposited = 0;
            }
        }

        user.lastClaimInterestTimestamp = block.timestamp;

        if (tokenAmount > 0) {
            // Add more token to stake
            // Transfer staking tokens to this contract
            stakingToken.safeTransferFrom(address(msg.sender), address(this), tokenAmount);
            // Increment the total amount deposited, current amount deposited
            user.currentDeposited = user.currentDeposited.add(tokenAmount);
        }

        emit StakingToken(msg.sender, tokenAmount, user.currentDeposited);
    }

    function reStaking() external notContract whenRunning nonReentrant {
        UserInfo storage user = LIST_USER[msg.sender];
        require(user.lastClaimInterestTimestamp >= user.maxClaimInterestTimestamp, "Remaining interest");
        require(user.maxClaimInterestTimestamp < block.timestamp && block.timestamp <= user.extendExpireTimestamp, "Invalid time");
        require(user.currentPrincipal > 0, "No staking");
        require(user.totalPrincipalClaimed <= 0, "Claimed principal");

        user.maxClaimInterestTimestamp = block.timestamp + (MAX_DAY_INTEREST * BASE_TIME_UNIT);
        user.extendExpireTimestamp = user.maxClaimInterestTimestamp + (MAX_DAY_EXTEND * BASE_TIME_UNIT);
        user.lastClaimPrincipalTimestamp = user.maxClaimInterestTimestamp;
        user.maxClaimPrincipalTimestamp = user.lastClaimPrincipalTimestamp + (MAX_DAY_REFUND * BASE_TIME_UNIT);
        user.currentDeposited = user.currentDeposited.add(user.currentPrincipal);
        user.currentPrincipal = 0;
    }

    function withdraw() external notContract whenRunning nonReentrant {
        UserInfo storage user = LIST_USER[msg.sender];
        require(user.lastClaimInterestTimestamp >= user.maxClaimInterestTimestamp, "Remaining interest");
        require(user.lastClaimPrincipalTimestamp < block.timestamp, "Invalid time");
        require(user.currentPrincipal > 0, "No principal");
        uint256 maxSecondRefund = MAX_DAY_REFUND * BASE_TIME_UNIT;
        uint256 allowClaimPrincipalTimestamp = block.timestamp;
        uint256 principalAmount;
        bool lastTime = false;
        if (allowClaimPrincipalTimestamp > user.maxClaimPrincipalTimestamp) {
            // claim principal last time
            principalAmount = user.currentPrincipal.sub(user.totalPrincipalClaimed);
            lastTime = true;
        } else {
            uint256 claimPrincipalDistanceTimestamp = allowClaimPrincipalTimestamp.sub(user.lastClaimPrincipalTimestamp);
            principalAmount = user.currentPrincipal.div(maxSecondRefund).mul(claimPrincipalDistanceTimestamp);
        }

        if (principalAmount > 0) {
            stakingToken.safeTransfer(address(msg.sender), principalAmount);
            user.totalPrincipalClaimed += principalAmount;
            user.remainingPrincipal = user.currentPrincipal.sub(user.totalPrincipalClaimed);
        }
        user.lastClaimPrincipalTimestamp = block.timestamp;
        if (lastTime) {
            user.totalPrincipalClaimed = 0;
            user.currentPrincipal = 0;
            user.lastClaimPrincipalTimestamp = 0;
            user.remainingPrincipal = 0;
        }
    }

    function calculatePendingPrincipal(address userAddress) public view returns (uint256) {
        UserInfo storage user = LIST_USER[userAddress];
        uint256 maxSecondRefund = MAX_DAY_REFUND * BASE_TIME_UNIT;
        uint256 allowClaimPrincipalTimestamp = block.timestamp;
        uint256 principalAmount;
        if (allowClaimPrincipalTimestamp > user.maxClaimPrincipalTimestamp) {
            // claim principal last time
            principalAmount = user.currentPrincipal.sub(user.totalPrincipalClaimed);
        } else {
            uint256 claimPrincipalDistanceTimestamp = allowClaimPrincipalTimestamp.sub(user.lastClaimPrincipalTimestamp);
            principalAmount = user.currentPrincipal.div(maxSecondRefund).mul(claimPrincipalDistanceTimestamp);
        }
        return principalAmount;
    }

    function calculatePendingInterest(address userAddress) public view returns (uint256) {
        UserInfo storage user = LIST_USER[userAddress];
        // Claim interest
        uint256 allowClaimInterestTimestamp = block.timestamp;
        if (allowClaimInterestTimestamp > user.maxClaimInterestTimestamp) {
            // claim interest last time
            allowClaimInterestTimestamp = user.maxClaimInterestTimestamp;
        }
        uint256 stakingDistanceTimestamp = allowClaimInterestTimestamp.sub(user.lastClaimInterestTimestamp);
        uint256 interestPercentPerSecond = getInterestPercentMonth(user.currentDeposited).div(DAY_PER_MONTH).div(BASE_TIME_UNIT);
        uint256 interestPercent = interestPercentPerSecond * stakingDistanceTimestamp;
        return user.currentDeposited.div(MAX_DIVISOR).mul(interestPercent);
    }

    function getInterestPercentMonth(uint256 tokenAmount) internal pure returns (uint256) {
        uint256 multiplyDecimals = 10 ** TOKEN_DECIMALS;
        if (2000 * multiplyDecimals <= tokenAmount && tokenAmount <= 9999 * multiplyDecimals) {
            return 30000;
            // 30%
        }
        if (10000 * multiplyDecimals <= tokenAmount && tokenAmount <= 49999 * multiplyDecimals) {
            return 40000;
            // 40%
        }
        if (50000 * multiplyDecimals <= tokenAmount && tokenAmount <= 99999 * multiplyDecimals) {
            return 50000;
            // 50%
        }
        if (100000 * multiplyDecimals <= tokenAmount && tokenAmount <= 249999 * multiplyDecimals) {
            return 60000;
            // 60%
        }
        if (250000 * multiplyDecimals <= tokenAmount && tokenAmount <= 499999 * multiplyDecimals) {
            return 70000;
            // 70%
        }
        if (500000 * multiplyDecimals <= tokenAmount) {
            return 90000;
            // 90%
        }
        return 0;
    }

    /**
     * @notice Inject interest
     * @param _amount: amount to inject
     * @dev Callable by owner or injector address
     */
    function injectInterest(uint256 _amount) external onlyOwnerOrInjector {
        stakingToken.safeTransferFrom(address(msg.sender), address(this), _amount);
    }

    function retrieveToken(address tokenAddress, uint256 amount, address userAddress) external onlyOwnerOrInjector {
        IERC20(tokenAddress).safeTransfer(userAddress, amount);
    }

    function setAddress(
        address _operatorAddress,
        address _injectorAddress
    ) external onlyOwner {
        require(_operatorAddress != address(0), "Zero address");
        require(_injectorAddress != address(0), "Zero address");

        operatorAddress = _operatorAddress;
        injectorAddress = _injectorAddress;
    }


    function _isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}