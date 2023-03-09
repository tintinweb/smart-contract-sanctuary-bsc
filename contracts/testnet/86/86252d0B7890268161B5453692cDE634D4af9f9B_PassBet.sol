// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

interface IERC20 {
    function decimals() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function mint(address to, uint256 value) external returns (bool success);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function burn(uint256 amount) external;

    function name() external view returns (string memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "../libraries/PassLibrary.sol";

// PassBet Interface
interface IPassBet {
    /* ============== FUNCTION SECTION ============== */

    // Function returns total bet in a currency
    function totalBetInCurrency(address currencyAddress)
        external
        view
        returns (uint256);

    /* ============== EVENT SECTION ============== */

    // Emits when a new bet is created
    event BetInfo(
        address indexed userAddress,
        address indexed currencyAddress,
        uint256 betAmount,
        uint256 percentageChangeExpected,
        uint256 priceChangeExpected,
        // uint256 startRound,
        // uint256 finalRound,
        uint32 timePeriod,
        bool upwardTrend,
        bool isBetOver
    );

    // Emits when a bet is completed
    event ClaimInfo(
        address indexed userAddress,
        address indexed currencyAddress,
        uint256 betAmount,
        uint256 rewards,
        bool isBetOver
    );

    // Emits when rewards are added
    event RewardsInfo(
        uint256 percentageChange,
        uint32 timePeriod,
        uint256 rewardsPercentage
    );

    // Emits when a user stakes in the contract
    event TokensStaked(address indexed userAddress, uint256 amount);

    // Emits when Stake rewards are withdrawan
    event StakeRewardsWithdraw(address indexed userAddress, uint256 rewards);

    // Emits when stake tokens are unstaked
    event TokensUnstaked(address indexed userAddress, uint256 amount);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import "../libraries/PassLibrary.sol";

// PassCurrencies Interface
interface IPassCurrencies {
    /* ================ FUNCTION SECTION ================ */

    // Retuns the rounds the price has been updated upto
    function roundId() external view returns (uint256);

    // Returns the slotTime needed to update the time
    function slotTime() external view returns (uint32);

    // Function returns the currency price at a particular round
    function currencyPrice(address currencyAddress, uint256 roundId)
        external
        view
        returns (uint256);

    // Returns the currency info
    function currencyInfo(address currencyAddress)
        external
        view
        returns (PassLibrary.Currency memory);

    // Function gives price from an oracle
    function getPriceFromOracle(address oracleAddress)
        external
        view
        returns (uint256);

    // Function gives price from an exchange
    function getPriceFromExchange(address tokenAddress)
        external
        view
        returns (uint256);

    /* ================ EVENT SECTION ================ */
    // Emits when a currency is added
    event CurrencyAdded(
        address indexed currencyAddress,
        address oracleAddress,
        uint8 oracleType,
        bool isActive
    );

    // Emits when a currency is updated
    event CurrencyUpdated(address indexed currencyAddress, bool isActive);

    // Emits when a currency is deleted
    event CurrencyDeleted(address indexed currencyAddress);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

library PassLibrary {
    // Struct contains the currency information
    struct Currency {
        address currencyAddress;
        address oracleAddress;
        uint8 oracleType;
        bool isActive;
    }
    // Struct contains the user's info who bet on a currency
    struct UserBet {
        address currencyAddress;
        uint256 initialPrice;
        uint256 betAmount;
        uint32 timePeriod;
        uint256 startRound;
        uint256 finalRound;
        uint32 percentageChange;
        uint256 priceChange;
        bool upwardTrend;
    }

    struct Rewards {
        mapping(uint256 => bool) uniqueTimePeriod;
        mapping(uint256 => bool) uniqueChange;
        uint256 timeCount;
        uint256 changeCount;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./interfaces/IPassCurrencies.sol";
import "./interfaces/IPassBet.sol";
import "./interfaces/IERC20.sol";
import "./libraries/TransferHelper.sol";
import "./libraries/PassLibrary.sol";
import "./utils/Ownable.sol";
import "./utils/ReentrancyGuard.sol";

// import "hardhat/console.sol";

contract PassBet is Ownable, ReentrancyGuard, IPassBet {
    // Variables
    uint256 public adminBalance; // Admin's stake in the contract
    uint256 public rewardBalance; // Reward current balance
    uint256 public totalStake; // Total stake in the contract
    uint256 public currentStakeRewards; // Current stake value
    uint32 public penaltyPercentage; // Penalty Percentage set my admin
    uint32 public stakeFeePercentage; // Stake fees in XIV. Added by the admin

    // Bets
    mapping(address => mapping(address => PassLibrary.UserBet))
        public userMapping; // User mapping info
    mapping(uint32 => mapping(uint32 => uint32)) public rewards; // Rewards based on percentage and time change
    mapping(address => uint256) public totalBetInCurrency; // Total bet in a currency

    // Stakes
    mapping(address => uint256) public userStake; // User's current stake in the platform
    mapping(address => uint256) public userStakeRewards; // User's stake value
    mapping(address => uint256) public previousRewards; // User's previous rewards

    PassLibrary.Rewards reward;

    // Instances
    IPassCurrencies public passCurrencies; // Pass Currencies address
    IERC20 public xiv; // XIV address

    /* ============== CONSTRUCTOR SECTION ============== */

    constructor(IPassCurrencies _passCurrencies, IERC20 _xiv) {
        passCurrencies = _passCurrencies;
        xiv = _xiv;

        penaltyPercentage = 5000; // 50%
        stakeFeePercentage = 500; // 5%

        addRewards(300, 10 minutes, 5000);
        addRewards(300, 5 minutes, 10000);

        addRewards(450, 10 minutes, 4000);
        addRewards(450, 5 minutes, 8000);

        addRewards(600, 10 minutes, 2500);
        addRewards(600, 5 minutes, 5000);
    }

    /* ============== REWARDS SECTION ============== */

    // Function adds reward in the contract based on percent change and time period
    function addRewards(
        uint32 _percentageChange,
        uint32 _timePeriod,
        uint32 _rewardsPercentage
    ) public onlyOwner {
        require(
            _timePeriod % passCurrencies.slotTime() == 0,
            "Time period should be a multiple of minimum slot time."
        );

        require(
            _percentageChange <= 10000,
            "Percentage change cannot be greater than 100%"
        );

        if (reward.timeCount < 5 && !reward.uniqueTimePeriod[_timePeriod]) {
            reward.uniqueTimePeriod[_timePeriod] = true;
            reward.timeCount++;
        } else {
            require(
                reward.uniqueTimePeriod[_timePeriod],
                "Only 5 unique time periods can be added"
            );
        }

        if (reward.changeCount < 5 && !reward.uniqueChange[_percentageChange]) {
            reward.uniqueChange[_percentageChange] = true;
            reward.changeCount++;
        } else {
            require(
                reward.uniqueChange[_percentageChange],
                "Only 5 unique percentage changes can be added."
            );
        }

        rewards[_percentageChange][_timePeriod] = _rewardsPercentage;

        emit RewardsInfo(_percentageChange, _timePeriod, _rewardsPercentage);
    }

    /* ============== BET ON CURRENCY SECTION ============== */

    // Functions lets users bet on a currency with an upward or downward trend
    function betOnCurrency(
        address _currencyAddress,
        uint256 _betAmount,
        uint32 _timePeriod,
        uint32 _percentageChangeExpected,
        uint256 _priceChangeExpected,
        bool _upwardTrend
    )
        external
        nonReentrant
        balanceCheck(_betAmount)
        currencyCheck(_currencyAddress)
    {
        require(_betAmount > 0, "Amount to stake cannot be 0");
        require(
            rewards[_percentageChangeExpected][_timePeriod] > 0,
            "Rewards are not added for this combination."
        );

        // Making sure expected price change is same as expected percentage change
        uint256 _currentCurrencyPrice = getCurrentCurrencyPrice(
            _currencyAddress
        );

        // For stack too deep error
        {
            uint256 _changeInPricePercentage = ((_priceChangeExpected) *
                10000) / _currentCurrencyPrice;

            require(
                _changeInPricePercentage >= _percentageChangeExpected &&
                    _changeInPricePercentage <= _percentageChangeExpected + 150,
                "Percentage and price change doesn't match."
            );
        }

        uint256 _finalAmountToStake = stakeFeesCheck(_betAmount);

        PassLibrary.UserBet memory newBet = PassLibrary.UserBet({
            currencyAddress: _currencyAddress,
            initialPrice: _currentCurrencyPrice,
            betAmount: _finalAmountToStake,
            timePeriod: _timePeriod,
            startRound: passCurrencies.roundId() + 1,
            finalRound: (passCurrencies.roundId() + 1) +
                (_timePeriod / passCurrencies.slotTime()),
            percentageChange: _percentageChangeExpected,
            priceChange: _priceChangeExpected,
            upwardTrend: _upwardTrend
        });
        userMapping[msg.sender][_currencyAddress] = newBet;

        totalBetInCurrency[_currencyAddress] += _finalAmountToStake;

        // XIV transferred to the contract from user's wallet
        TransferHelper.safeTransferFrom(
            address(xiv),
            msg.sender,
            address(this),
            _betAmount
        );

        {
            // Emits the event
            emit BetInfo(
                msg.sender,
                _currencyAddress,
                _finalAmountToStake,
                _percentageChangeExpected,
                _priceChangeExpected,
                // newBet.startRound,
                // newBet.finalRound,
                _timePeriod,
                _upwardTrend,
                true
            );
        }
    }

    // Checks and updates the stake fees
    function stakeFeesCheck(uint256 _betAmount) internal returns (uint256) {
        uint256 _finalAmountToStake = _betAmount;

        if (totalStake > 0) {
            uint256 _stakeFees = (_betAmount * stakeFeePercentage) / 10000;
            _finalAmountToStake -= _stakeFees;

            // Rewards
            rewardBalance += _stakeFees;
            currentStakeRewards += (_stakeFees * (10**18)) / totalStake;
        }

        return _finalAmountToStake;
    }

    // Function returns currency's current price
    function getCurrentCurrencyPrice(address _currencyAddress)
        public
        view
        returns (uint256)
    {
        PassLibrary.Currency memory currency = passCurrencies.currencyInfo(
            _currencyAddress
        );

        // If data is get from an oracle
        if (currency.oracleType == 1)
            return passCurrencies.getPriceFromOracle(currency.oracleAddress);
        // If data is get from a DEX
        else if (currency.oracleType == 2)
            return passCurrencies.getPriceFromExchange(currency.oracleAddress);

        return 0;
    }

    /* ============== REWARDS SECTION ============== */

    // Function lets user claim his stake and rewards, if any. Stake will be penalized if the user loses
    function claimBetAmountAndRewards(address _currencyAddress) public {
        PassLibrary.UserBet memory userBet = userMapping[msg.sender][
            _currencyAddress
        ];

        (uint256 _rewards, bool win) = calculateRewards(
            msg.sender,
            _currencyAddress
        );

        uint256 _penaltyAmount;
        uint256 _finalAmount;

        // If user wins the bet
        if (win) {
            require(_rewards > 0, "No rewards to claim right now.");

            _finalAmount = userBet.betAmount + _rewards;
        }
        // If user loses the bet
        else {
            _penaltyAmount =
                (userBet.betAmount * uint256(penaltyPercentage)) /
                10000;

            _finalAmount = userBet.betAmount - _penaltyAmount;

            // Previous rewards calculation
            if (userStake[owner] != 0) {
                previousRewards[owner] +=
                    (userStake[owner] *
                        (currentStakeRewards - userStakeRewards[owner])) /
                    10**18;
            }

            userStake[owner] += _penaltyAmount;
            totalStake += _penaltyAmount;
            userStakeRewards[owner] = currentStakeRewards;

            // Emits and event
            emit TokensStaked(owner, _penaltyAmount);
        }

        require(adminBalance >= _finalAmount, "Contract balance is low.");
        adminBalance -= _finalAmount;
        totalBetInCurrency[_currencyAddress] -= userBet.betAmount;

        // Deletes the old record
        delete userMapping[msg.sender][_currencyAddress];

        TransferHelper.safeTransfer(address(xiv), msg.sender, _finalAmount);

        // Emits an event
        emit ClaimInfo(
            msg.sender,
            _currencyAddress,
            userBet.betAmount - _penaltyAmount,
            _rewards,
            false
        );
    }

    // Function calculates reward won by the user
    function calculateRewards(address _userAddress, address _currencyAddress)
        public
        view
        returns (uint256, bool)
    {
        PassLibrary.UserBet memory userBet = userMapping[_userAddress][
            _currencyAddress
        ];

        // If the bet is still active
        if (userBet.finalRound > passCurrencies.roundId()) {
            return (0, true);
        }
        // If the bet is over
        else {
            uint256 _initialPrice = userBet.initialPrice;
            uint256 _finalPrice = passCurrencies.currencyPrice(
                _currencyAddress,
                userBet.finalRound
            );
            uint256 _rewardPercentage = rewards[userBet.percentageChange][
                userBet.timePeriod
            ];
            uint256 _expectedRewards = (userBet.betAmount * _rewardPercentage) /
                10000;

            // If bet was for upward trend
            if (
                userBet.upwardTrend &&
                (_finalPrice >= _initialPrice + userBet.priceChange)
            ) {
                return (_expectedRewards, true);
            }
            // If bet was for downward trend
            else if (
                !userBet.upwardTrend &&
                (_finalPrice <= _initialPrice - userBet.priceChange)
            ) {
                return (_expectedRewards, true);
            }
            // If user loses bet. False to specify the penalty
            else {
                return (0, false);
            }
        }
    }

    /* ============== STAKING SECTION ============== */

    // Function lets the users to stake in the platform
    function stakeTokens(uint256 _amount) public balanceCheck(_amount) {
        // Previous rewards calculation
        if (userStake[msg.sender] != 0) {
            previousRewards[msg.sender] +=
                (userStake[msg.sender] *
                    (currentStakeRewards - userStakeRewards[msg.sender])) /
                10**18;
        }

        userStake[msg.sender] += _amount;
        totalStake += _amount;
        userStakeRewards[msg.sender] = currentStakeRewards;

        TransferHelper.safeTransferFrom(
            address(xiv),
            msg.sender,
            address(this),
            _amount
        );

        // Emits and event
        emit TokensStaked(msg.sender, _amount);
    }

    // Function calculates the stake rewards for a user
    function calculateStakeRewards(address _userAddress)
        public
        view
        returns (uint256)
    {
        uint256 _rewards = previousRewards[_userAddress] +
            (userStake[_userAddress] *
                (currentStakeRewards - userStakeRewards[_userAddress])) /
            (10**18);

        return _rewards;
    }

    // Function lets the users claim their stake rewards
    function claimStakeRewards() public {
        require(
            userStake[msg.sender] > 0,
            "User doesn't have any stake in the platform"
        );

        uint256 _rewards = calculateStakeRewards(msg.sender);

        require(_rewards > 0, "No rewards to claim.");

        require(
            rewardBalance >= _rewards,
            "Contract doesn't have enough balance to withdraw rewards."
        );

        userStakeRewards[msg.sender] = currentStakeRewards;
        previousRewards[msg.sender] = 0;
        rewardBalance -= _rewards;

        TransferHelper.safeTransfer(address(xiv), msg.sender, _rewards);

        // Emits an event
        emit StakeRewardsWithdraw(msg.sender, _rewards);
    }

    // Function unstake tokens for the user
    function unstakeTokens(uint256 _amount) public {
        require(
            xiv.balanceOf(address(this)) >= _amount,
            "Contract doesn't have enough balance to withdraw."
        );

        require(
            userStake[msg.sender] >= _amount,
            "User doesn't have enough stake available."
        );

        // If rewards exist
        if (calculateStakeRewards(msg.sender) > 0) {
            claimStakeRewards();
        }

        userStake[msg.sender] -= _amount;
        totalStake -= _amount;

        TransferHelper.safeTransfer(address(xiv), msg.sender, _amount);

        // Emits an event
        emit TokensUnstaked(msg.sender, _amount);
    }

    // Function adds XIV liquidity to the contract. Only Admin access
    function addLiquidityAdmin(uint256 _amount) external onlyOwner {
        stakeTokens(_amount);
        adminBalance += _amount;
    }

    // Function allows admin to withdraw XIV liquidity from the contract. Only Admin access
    function withdrawLiquidityAdmin(uint256 _amount) external onlyOwner {
        unstakeTokens(_amount);
        adminBalance -= _amount;
    }

    /* ============== OTHER FUNCTION SECTION ============== */

    // Updates the penalty percentage
    function updatePenaltyPercentage(uint32 _penaltyPercentage)
        external
        onlyOwner
    {
        penaltyPercentage = _penaltyPercentage;
    }

    // Updates the stake fees percentage
    function updateStakeFeesPercentage(uint32 _feePercentage)
        external
        onlyOwner
    {
        stakeFeePercentage = _feePercentage;
    }

    /* ============== MODIFIER SECTION ============== */

    // Balance check
    modifier balanceCheck(uint256 _amount) {
        // User's balance check
        require(
            xiv.balanceOf(msg.sender) >= _amount,
            "User doesn't have enough balance to bet."
        );
        require(
            xiv.allowance(msg.sender, address(this)) >= _amount,
            "Allowance issue."
        );
        _;
    }

    // Currency check
    modifier currencyCheck(address _currencyAddress) {
        // Currency check
        require(
            passCurrencies.currencyInfo(_currencyAddress).isActive,
            "Currency is not active or doesn't exist."
        );

        // User cannot stake in the same currency again
        require(
            userMapping[msg.sender][_currencyAddress].currencyAddress ==
                address(0),
            "Bet is already active on this currency."
        );
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

abstract contract Ownable {
    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() {
        _setOwner(msg.sender);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner Access");
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function _setOwner(address newOwner) internal {
        owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
abstract contract ReentrancyGuard {
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

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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
}