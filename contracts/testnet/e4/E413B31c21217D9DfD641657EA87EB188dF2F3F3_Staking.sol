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
    uint256 public totalDepositedAmount;
    uint256 public totalInjectedAmount;
    uint256 public totalInterestClaimed;
    uint256 public totalPrincipalClaimed;

    uint256 public constant BASE_TIME_UNIT = 1 minutes;
    uint256 public constant MAX_DAY_REFUND = 15;
    uint256 public constant MAX_DAY_INTEREST = 30;
    uint256 public constant TOKEN_DECIMALS = 8;
    uint256 public constant MAX_DIVISOR = 1000000000; // 100%
    uint256 public constant DAY_PER_MONTH = 30;
    uint256 public constant MAX_DAY_EXTEND = 3;
    uint256 public constant SECOND_IN_MONTH = 86400 * 30;

    IERC20 public stakingToken;

    struct UserInfo {
        uint256 currentDeposited;

        // Interest
        uint256 interestClaimed; // add when claim interest
        uint256 lastClaimInterestTimestamp; // to calculate reward
        uint256 maxClaimInterestTimestamp; // to check re-stake

        // Principal
        uint256 currentPrincipal; // add when stake
        uint256 principalClaimed; // calculate when claim principal
        uint256 remainingPrincipal; // calculate when claim principal
        uint256 lastClaimPrincipalTimestamp; // set when stake first time and update when claim principal
        uint256 maxClaimPrincipalTimestamp; // set when stake first time

        // Time
        uint256 extendExpireTimestamp; // set when stake first time
    }

    mapping(address => UserInfo) public LIST_USER;

    event StakingToken(address userAddress, uint256 tokenAmount, uint256 totalStakingAmount);
    event ClaimInterest(address userAddress, uint256 tokenAmount);
    event WithdrawPrincipal(address userAddress, uint256 tokenAmount);

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
            if (allowClaimInterestTimestamp >= user.maxClaimInterestTimestamp) {
                // claim interest last time
                allowClaimInterestTimestamp = user.maxClaimInterestTimestamp;
                lastTime = true;
                tokenAmount = 0;
            }
            uint256 stakingDistanceTimestamp = allowClaimInterestTimestamp.sub(user.lastClaimInterestTimestamp);
            uint256 interestPercent = getInterestPercentSecond(user.currentDeposited) * stakingDistanceTimestamp;
            uint256 interestAmount = user.currentDeposited.mul(interestPercent).div(MAX_DIVISOR);
            if (interestAmount > 0) {
                stakingToken.safeTransfer(address(msg.sender), interestAmount);
                user.interestClaimed += interestAmount;
                totalInterestClaimed += interestAmount;
                emit ClaimInterest(msg.sender, interestAmount);
            }
            if (lastTime) {
                user.remainingPrincipal += user.currentDeposited;
                user.currentPrincipal = user.remainingPrincipal;
                user.currentDeposited = 0;
                user.interestClaimed = 0;
            }
        }

        user.lastClaimInterestTimestamp = block.timestamp;

        if (tokenAmount > 0) {
            // Add more token to stake
            // Transfer staking tokens to this contract
            stakingToken.safeTransferFrom(address(msg.sender), address(this), tokenAmount);
            // Increment the total amount deposited, current amount deposited
            user.currentDeposited = user.currentDeposited.add(tokenAmount);
            totalDepositedAmount += tokenAmount;
            emit StakingToken(msg.sender, tokenAmount, user.currentDeposited);
        }
    }

    function reStaking() external notContract whenRunning nonReentrant {
        UserInfo storage user = LIST_USER[msg.sender];
        require(user.lastClaimInterestTimestamp >= user.maxClaimInterestTimestamp, "Remaining interest");
        require(user.maxClaimInterestTimestamp < block.timestamp && block.timestamp <= user.extendExpireTimestamp, "Invalid time");
        require(user.currentPrincipal > 0, "No staking");
        require(user.principalClaimed <= 0, "Claimed principal");

        user.maxClaimInterestTimestamp = block.timestamp + (MAX_DAY_INTEREST * BASE_TIME_UNIT);
        user.extendExpireTimestamp = user.maxClaimInterestTimestamp + (MAX_DAY_EXTEND * BASE_TIME_UNIT);
        user.lastClaimPrincipalTimestamp = user.maxClaimInterestTimestamp;
        user.maxClaimPrincipalTimestamp = user.lastClaimPrincipalTimestamp + (MAX_DAY_REFUND * BASE_TIME_UNIT);
        user.currentDeposited = user.currentDeposited.add(user.currentPrincipal);
        totalDepositedAmount += user.currentDeposited;
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
            principalAmount = user.currentPrincipal.sub(user.principalClaimed);
            lastTime = true;
        } else {
            uint256 claimPrincipalDistanceTimestamp = allowClaimPrincipalTimestamp.sub(user.lastClaimPrincipalTimestamp);
            principalAmount = user.currentPrincipal.mul(claimPrincipalDistanceTimestamp).div(maxSecondRefund);
        }

        if (principalAmount > 0) {
            stakingToken.safeTransfer(address(msg.sender), principalAmount);
            user.principalClaimed += principalAmount;
            user.remainingPrincipal = user.currentPrincipal.sub(user.principalClaimed);
            totalPrincipalClaimed += principalAmount;
            emit WithdrawPrincipal(msg.sender, principalAmount);
        }
        user.lastClaimPrincipalTimestamp = block.timestamp;
        if (lastTime) {
            user.principalClaimed = 0;
            user.currentPrincipal = 0;
            user.lastClaimPrincipalTimestamp = 0;
            user.remainingPrincipal = 0;
        }
    }

    function calculatePendingPrincipal(address userAddress) public view returns (uint256 amount, uint256 from, uint256 to) {
        UserInfo storage user = LIST_USER[userAddress];
        uint256 maxSecondRefund = MAX_DAY_REFUND * BASE_TIME_UNIT;
        uint256 allowClaimPrincipalTimestamp = block.timestamp;
        uint256 principalAmount;
        if (allowClaimPrincipalTimestamp > user.maxClaimPrincipalTimestamp) {
            // claim principal last time
            principalAmount = user.currentPrincipal.sub(user.principalClaimed);
        } else {
            uint256 claimPrincipalDistanceTimestamp = allowClaimPrincipalTimestamp.sub(user.lastClaimPrincipalTimestamp);
            principalAmount = user.currentPrincipal.mul(claimPrincipalDistanceTimestamp).div(maxSecondRefund);
        }
        return (principalAmount, user.lastClaimPrincipalTimestamp, allowClaimPrincipalTimestamp);
    }

    function calculatePendingInterest(address userAddress) public view returns (uint256 amount, uint256 from, uint256 to) {
        UserInfo storage user = LIST_USER[userAddress];
        uint256 allowClaimInterestTimestamp = block.timestamp;
        if (allowClaimInterestTimestamp > user.maxClaimInterestTimestamp) {
            // claim interest last time
            allowClaimInterestTimestamp = user.maxClaimInterestTimestamp;
        }
        uint256 stakingDistanceTimestamp = allowClaimInterestTimestamp.sub(user.lastClaimInterestTimestamp);
        uint256 interestPercent = getInterestPercentSecond(user.currentDeposited) * stakingDistanceTimestamp;
        uint256 tokenAmount = user.currentDeposited.mul(interestPercent).div(MAX_DIVISOR);
        return (tokenAmount, user.lastClaimInterestTimestamp, allowClaimInterestTimestamp);
    }

    function getInterestPercentSecond(uint256 tokenAmount) internal pure returns (uint256) {
        uint256 multiplyDecimals = 10 ** TOKEN_DECIMALS;
        if (2000 * multiplyDecimals <= tokenAmount && tokenAmount <= 9999 * multiplyDecimals) {
            return 30000000 / SECOND_IN_MONTH;
            // 3%
        }
        if (10000 * multiplyDecimals <= tokenAmount && tokenAmount <= 49999 * multiplyDecimals) {
            return 40000000 / SECOND_IN_MONTH;
            // 4%
        }
        if (50000 * multiplyDecimals <= tokenAmount && tokenAmount <= 99999 * multiplyDecimals) {
            return 50000000 / SECOND_IN_MONTH;
            // 5%
        }
        if (100000 * multiplyDecimals <= tokenAmount && tokenAmount <= 249999 * multiplyDecimals) {
            return 60000000 / SECOND_IN_MONTH;
            // 6%
        }
        if (250000 * multiplyDecimals <= tokenAmount && tokenAmount <= 499999 * multiplyDecimals) {
            return 70000000 / SECOND_IN_MONTH;
            // 7%
        }
        if (500000 * multiplyDecimals <= tokenAmount) {
            return 90000000 / SECOND_IN_MONTH;
            // 9%
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
        totalInjectedAmount += _amount;
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