// contracts/bitmon/BitmonTeamVestingTest1.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * Bitmon Paradise Team tokens vesting contract.
 */
contract BitmonTeamVestingTest1 {
    // Tokens vesting stage structure with vesting date and tokens allowed to unlock
    struct VestingStage {
        uint256 date;
        uint256 tokensUnlockedAmount;
    }

    // Address of BMP token
    IERC20 public immutable bmp;

    // Address for receiving tokens
    address public immutable destinationAddress;

    // Num of stages
    uint8 public constant NUM_STAGES = 9;

    // Array for storing all vesting stages with structure defined above
    VestingStage[NUM_STAGES] public stages;

    // Total amount of tokens sent
    uint256 public initialTokensBalance;

    // Amount of tokens already sent
    uint256 public tokensSent;

    // Event raised on each successful withdraw
    event Withdraw(uint256 amount, uint256 timestamp);

    /**
     * @dev We are filling vesting stages array right when the contract is deployed.
     * @param _bmp Address of BMP Token that will be locked on contract.
     * @param _destinationAddress Address of tokens receiver when it is unlocked.
     */
    constructor(address _bmp, address _destinationAddress) {
        require(_bmp != address(0), "zero address");
        require(_destinationAddress != address(0), "zero address");

        bmp = IERC20(_bmp);
        destinationAddress = _destinationAddress;
        initVestingStages();
    }

    /**
     * @dev Setup array with vesting stages dates and amounts.
     */
    function initVestingStages() internal {
        stages[0].date = 1647619200;
        stages[1].date = 1647705600;
        stages[2].date = 1647792000;
        stages[3].date = 1647878400;
        stages[4].date = 1647964800;
        stages[5].date = 1648051200;
        stages[6].date = 1648137600;
        stages[7].date = 1648224000;
        stages[8].date = 1648310400;

        stages[0].tokensUnlockedAmount = 640000000000000000000000;
        stages[1].tokensUnlockedAmount = 960000000000000000000000;
        stages[2].tokensUnlockedAmount = 1280000000000000000000000;
        stages[3].tokensUnlockedAmount = 1600000000000000000000000;
        stages[4].tokensUnlockedAmount = 1920000000000000000000000;
        stages[5].tokensUnlockedAmount = 2240000000000000000000000;
        stages[6].tokensUnlockedAmount = 2560000000000000000000000;
        stages[7].tokensUnlockedAmount = 2880000000000000000000000;
        stages[8].tokensUnlockedAmount = 3200000000000000000000000;
    }

    /**
     * @dev Main method for release tokens from vesting.
     */
    function release() external {
        require(
            // solhint-disable-next-line not-rely-on-time
            block.timestamp >= stages[0].date,
            "still not first release time"
        );
        // Setting initial tokens balance on a first release
        if (initialTokensBalance == 0) {
            setInitialTokensBalance();
            // check that full amount is deposited on the contract
            require(initialTokensBalance >= stages[NUM_STAGES - 1].tokensUnlockedAmount, "not full funded");
        }
        uint256 tokensToSend = getAvailableTokensToRelease();
        require(tokensToSend > 0, "no tokens to release");

        sendTokens(tokensToSend);
    }

    /**
     * @dev Set initial tokens balance when making the first release.
     */
    function setInitialTokensBalance() private {
        initialTokensBalance = bmp.balanceOf(address(this));
    }

    /**
     * @dev Calculate tokens amount that is sent to withdrawAddress.
     * Returns the amount of tokens that can be sent.
     */
    function getAvailableTokensToRelease() public view returns (uint256 tokensToSend) {
        uint256 tokensUnlockedAmount = getTokensUnlockedAmount();
        // In the case of stuck tokens we allow the withdrawal of them all after vesting period ends.
        if (tokensUnlockedAmount == stages[NUM_STAGES - 1].tokensUnlockedAmount) {
            tokensToSend = bmp.balanceOf(address(this));
        } else {
            unchecked {
                // no overflow because the limits are well-known
                tokensToSend = tokensUnlockedAmount - tokensSent;
            }
        }
    }

    /**
     * @dev Get tokens unlocked amount on current stage.
     * Returns the amount of tokens allowed to be sent.
     */
    function getTokensUnlockedAmount() private view returns (uint256) {
        uint256 allowedAmount;

        for (uint256 i = 0; i < NUM_STAGES; i++) {
            // solhint-disable-next-line not-rely-on-time
            if (block.timestamp >= stages[i].date) {
                allowedAmount = stages[i].tokensUnlockedAmount;
            }
        }

        return allowedAmount;
    }

    /**
     * @dev Send tokens to destinationAddress.
     * @param tokensToSend Amount of tokens will be sent.
     */
    function sendTokens(uint256 tokensToSend) private {
        // Updating tokens sent counter
        unchecked {
            // no overflow because the limits are well-known
            tokensSent = tokensSent + tokensToSend;
        }
        // Sending allowed tokens amount
        bmp.transfer(destinationAddress, tokensToSend);
        // Raising event
        // solhint-disable-next-line not-rely-on-time
        emit Withdraw(tokensToSend, block.timestamp);
    }

    /**
     * @dev Get detailed info about stage.
     * Provides ability to get attributes of every stage from external callers, ie Web3, truffle tests, etc.
     * @param index Vesting stage number. Ordered by ascending date and starting from zero.
     *
     * Returns:
     *  {
     *    "date": "Date of stage in unix timestamp format.",
     *    "tokensUnlockedAmount": "Amount of tokens allowed to be withdrawn."
     * }
     */
    function getStageAttributes(uint8 index) external view returns (uint256 date, uint256 tokensUnlockedAmount) {
        return (stages[index].date, stages[index].tokensUnlockedAmount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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