/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

/**SPDX-License-Identifier:UNLICENDED
 *Submitted for verification at BscScan.com on 2022-05-13
 */

/*   Cake2x - Yield Farming Smart Contract built on BullBankerSmart Chain.
 *   The only official platform of original Cake2x team! All other platforms with the same contract code are FAKE!
 *
 *   [OFFICIAL LINKS]
 *
 *   ┌────────────────────────────────────────────────────────────┐
 *   │   Website: https://bullbanker.finance                      │
 *   │                                                            │
 *   │   Twitter: https://twitter.com/BullBankers                 │
 *   │   Telegram: https://https://t.me/bullbankers               │
 *   │                                                            │
 *   │   E-mail: [email protected]                      │
 *   └────────────────────────────────────────────────────────────┘
 *
 *   [USAGE INSTRUCTION]
 *
 *   1) Transfer method directly from wallet without website UI
 *
 *      - Deposit - Transfer BullBankeryou want to double to contract address, use msg.data to provide referrer address
 *      - Withdraw earnings - Transfer 0 BullBankerto contract address
 *      - Reinvest earnings - Withdraw and Deposit manually
 *
 *   2) Using website UI
 *
 *      - Connect web3 wallet
 *      - Deposit - Enter BullBankeramount you want to double, click "Double Your Cake" button and confirm transaction
 *      - Reinvest earnings - Click "Double Earnings" button and confirm transaction
 *      - Withdraw earnings - Click "Withdraw Earnings" button and confirm transaction
 *
 *   [DEPOSIT CONDITIONS]
 *
 *   - Minimal deposit: 0.02 BANKERS, no max limit
 *   - Total income: 200% per deposit
 *   - Earnings every moment, withdraw any time
 *
 *   [AFFILIATE PROGRAM]
 *
 *   - Referral reward: 10%
 *
 *   [FUNDS DISTRIBUTION]
 *
 *   - 90% Platform main balance, using for participants payouts, affiliate program bonuses
 *   - 10% Advertising and promotion expenses, Support work, Development, Administration fee
 *
 *   Verified contract source code has been audited by an independent company
 *   there is no backdoors or unfair rules.
 *
 *   Note: This project has high risks as well as high profits.
 *   Once contract balance drops to zero payments will stops,
 *   deposit at your own risk.
 */

pragma solidity 0.8.13;

interface IERC20 {
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract BANKERS2X {
    uint256 constant INVEST_MIN_AMOUNT = 2e18; // 2 BANKERS
    uint256 constant REFERRAL_PERCENT = 10;
    uint256 constant PROJECT_FEE = 10;
    uint256 constant ROI = 200;
    uint256 constant PERCENTS_DIVIDER = 100;
    uint256 constant PERIOD = 30 days;

    uint256 totalInvested;
    uint256 totalRefBonus;

    address public token;

    struct Deposit {
        uint256 amount;
        uint256 start;
        uint256 withdrawn;
    }

    struct User {
        Deposit[] deposits;
        uint256 checkpoint;
        address referrer;
        uint256 referals;
        uint256 totalBonus;
    }

    mapping(address => User) internal users;

    bool started;
    address payable commissionWallet;

    event Newbie(address user);
    event NewDeposit(address indexed user, uint256 amount);
    event Reinvest(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RefBonus(
        address indexed referrer,
        address indexed referral,
        uint256 amount
    );
    event FeePayed(address indexed user, uint256 totalAmount);

    constructor(address payable wallet, address _token) {
        require(!isContract(wallet));
        commissionWallet = wallet;
        token = _token;
    }

    function invest(address referrer, uint256 amount) public {
        if (!started) {
            if (msg.sender == commissionWallet) {
                started = true;
            } else revert("Not started yet");
        }
        require(
            IERC20(token).balanceOf(msg.sender) >= amount,
            "Not enough Balance"
        );
        uint256 prevAmount = IERC20(token).balanceOf(address(this));
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        uint256 afterAmount = IERC20(token).balanceOf(address(this));
        uint256 _amount = afterAmount - prevAmount;
        checkIn(_amount, referrer);
    }

    function reinvest() public {
        uint256 totalAmount = checkOut();

        emit Reinvest(msg.sender, totalAmount);

        checkIn(totalAmount, address(0));
    }

    function withdraw() public {
        uint256 totalAmount = checkOut();

        IERC20(token).transfer(msg.sender, totalAmount);

        emit Withdrawn(msg.sender, totalAmount);
    }

    function getSiteInfo()
        public
        view
        returns (uint256 _totalInvested, uint256 _totalBonus)
    {
        return (totalInvested, totalRefBonus);
    }

    function getUserInfo(address userAddress)
        public
        view
        returns (
            uint256 readyToWithdraw,
            uint256 totalDeposits,
            uint256 totalActiveDeposits,
            uint256 totalWithdrawn,
            uint256 totalBonus,
            address referrer,
            uint256 referals
        )
    {
        User storage user = users[userAddress];

        for (uint256 i = 0; i < user.deposits.length; i++) {
            uint256 finish = user.deposits[i].start + PERIOD;
            uint256 roi = (user.deposits[i].amount * ROI) / PERCENTS_DIVIDER;
            if (user.deposits[i].withdrawn < roi) {
                uint256 profit;
                if (block.timestamp >= finish) {
                    profit = roi - user.deposits[i].withdrawn;
                } else {
                    uint256 from = user.deposits[i].start > user.checkpoint
                        ? user.deposits[i].start
                        : user.checkpoint;
                    uint256 to = block.timestamp;
                    profit = (roi * (to - from)) / PERIOD;

                    totalActiveDeposits += user.deposits[i].amount;
                }

                readyToWithdraw += profit;
            }

            totalDeposits += user.deposits[i].amount;
            totalWithdrawn += user.deposits[i].withdrawn;
        }

        totalBonus = user.totalBonus;
        referrer = user.referrer;
        referals = user.referals;
    }

    function checkIn(uint256 value, address referrer) internal {
        require(value >= INVEST_MIN_AMOUNT, "Less than minimum for deposit");

        uint256 fee = (value * PROJECT_FEE) / PERCENTS_DIVIDER;
        IERC20(token).transfer(commissionWallet, fee);
        emit FeePayed(msg.sender, fee);

        User storage user = users[msg.sender];

        if (user.referrer == address(0) && referrer != msg.sender) {
            user.referrer = referrer;

            address upline = user.referrer;
            users[upline].referals++;
        }

        if (user.referrer != address(0)) {
            uint256 amount = (value * REFERRAL_PERCENT) / PERCENTS_DIVIDER;
            users[user.referrer].totalBonus += amount;
            totalRefBonus += amount;
            IERC20(token).transfer(user.referrer, amount);
            emit RefBonus(user.referrer, msg.sender, amount);
        }

        if (user.deposits.length == 0) {
            user.checkpoint = block.timestamp;
            emit Newbie(msg.sender);
        }

        user.deposits.push(Deposit(value, block.timestamp, 0));

        totalInvested += value;

        emit NewDeposit(msg.sender, value);
    }

    function checkOut() internal returns (uint256) {
        User storage user = users[msg.sender];

        uint256 totalAmount;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            uint256 finish = user.deposits[i].start + PERIOD;
            uint256 roi = (user.deposits[i].amount * ROI) / PERCENTS_DIVIDER;
            if (user.deposits[i].withdrawn < roi) {
                uint256 profit;
                if (block.timestamp >= finish) {
                    profit = roi - user.deposits[i].withdrawn;
                } else {
                    uint256 from = user.deposits[i].start > user.checkpoint
                        ? user.deposits[i].start
                        : user.checkpoint;
                    uint256 to = block.timestamp;
                    profit = (roi * (to - from)) / PERIOD;
                }

                totalAmount += profit;
                user.deposits[i].withdrawn += profit;
            }
        }

        require(totalAmount > 0, "User has no dividends");

        user.checkpoint = block.timestamp;

        return totalAmount;
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function bytesToAddress(bytes memory _source)
        internal
        pure
        returns (address parsedreferrer)
    {
        assembly {
            parsedreferrer := mload(add(_source, 0x14))
        }
        return parsedreferrer;
    }
}