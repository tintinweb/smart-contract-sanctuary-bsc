/*
  _____                       ____                  _             _                     _   _      
 |  ___|_ _ _ __ _ __ ___    / ___|_ __ _   _ _ __ | |_ ___      / \   __ _ _   _  __ _| |_(_) ___ 
 | |_ / _` | '__| '_ ` _ \  | |   | '__| | | | '_ \| __/ _ \    / _ \ / _` | | | |/ _` | __| |/ __|
 |  _| (_| | |  | | | | | | | |___| |  | |_| | |_) | || (_) |  / ___ \ (_| | |_| | (_| | |_| | (__ 
 |_|  \__,_|_|  |_| |_| |_|  \____|_|   \__, | .__/ \__\___/  /_/   \_\__, |\__,_|\__,_|\__|_|\___|
                                        |___/|_|                         |_|                       
FARM CRYPTO AQUATIC | GAME OF Non Fungible Token | Miner of USDT | Project development by MetaversingCo
SPDX-License-Identifier: MIT
*/
pragma solidity >=0.8.14;

import "../node_modules/@openzeppelin/contracts/utils/Context.sol";
import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./RequestToken.sol";

contract CryptoAquaticFarmer is Ownable, RequestToken {
    using SafeMath for uint256;
    struct Transaction {
        uint256 time;
        address wallet;
        uint256 amount;
    }

    struct Referral {
        uint256 time;
        address wallet;
        uint256 amount;
    }

    struct User {
        uint256 invest;
        uint256 withdraw;
        uint256 gasoline;
        uint256 kms;
        uint256 lastLoad;
        address referrer;
        Referral[] referrals;
        uint256 indexReferrer;
        uint256 rewardUSDT;
        uint256 rewardKm;
    }

    // Variable
    address public dev;
    address public meta;
    address public main;
    address public COIN;
    bool public initialized;
    uint256 public market;
    uint256 public totalInvest;
    uint256 public playersCount;
    Transaction[5] public purchases;
    Transaction[5] public withdrawals;

    // Mapping
    mapping(address => User) public players;
    mapping(address => bool) public whiteList;

    // Constructor
    constructor(
        address coinWallet,
        address meta_,
        address main_
    ) {
        COIN = coinWallet;
        meta = meta_;
        main = main_;
        dev = owner();
        market = 108000000000;
    }

    // Modifier
    modifier initializer() {
        require(initialized || _msgSender() == main, "initialized is false");
        _;
    }

    modifier checkUser_() {
        require(checkUser(_msgSender()), "try again later");
        _;
    }

    modifier checkReinvest_() {
        require(checkReinvest(_msgSender()), "try again later");
        _;
    }

    modifier checkOwner_() {
        require(checkOwner(), "try again later");
        _;
    }

    // Functions writers

    function buyGas(address ref) public initializer {
        uint256 amount = IERC20(COIN).allowance(_msgSender(), address(this));
        require(MIN_INVEST <= amount, "the amount is not enough");
        IERC20(COIN).transferFrom(
            payable(_msgSender()),
            payable(address(this)),
            amount
        );
        uint256 fee = payFee(amount);
        payCommision(ref, amount, true);
        createBuy(amount.sub(fee), _msgSender());
        orderPurchases(Transaction(block.timestamp, _msgSender(), amount));
    }

    function sellKm() public initializer checkUser_ {
        (uint256 kmsAvailable, uint256 kmValue, ) = calculateKms(_msgSender());
        uint256 fee = payFee(kmValue);
        User storage user = players[_msgSender()];
        createMiner(kmsAvailable, user);
        user.withdraw = user.withdraw.add(kmValue);
        orderPurchases(Transaction(block.timestamp, _msgSender(), kmValue));
        IERC20(COIN).transfer(_msgSender(), kmValue.sub(fee));
    }

    function fixSki() public initializer checkReinvest_ {
        (, , uint256 kms) = calculateKms(_msgSender());
        createMiner(kms, players[_msgSender()]);
        payCommision(address(0), kms, false);
    }

    // Functions to use in writers
    function payFee(uint256 amount) private returns (uint256) {
        uint256 fee = calculate(FEE, amount);
        IERC20(COIN).transfer(payable(dev), fee.div(2));
        IERC20(COIN).transfer(payable(meta), fee.div(2));
        return fee;
    }

    function payCommision(
        address ref_,
        uint256 amount,
        bool isBuy
    ) private {
        User storage user = players[_msgSender()];
        if (
            user.referrer == address(0) &&
            ref_ != _msgSender() &&
            user.invest == 0
        ) {
            user.referrer = ref_;
            user.indexReferrer = players[ref_].referrals.length;
            players[ref_].referrals.push(
                Referral(block.timestamp, _msgSender(), 0)
            );
        }

        uint256 index = user.indexReferrer;

        if (user.referrer != address(0)) {
            User storage ref = players[user.referrer];
            (uint256 collection, ) = RequestToken.getType(_msgSender());
            uint256 amount_ = calculate(COMMISSION.add(collection), amount);
            if (isBuy) {
                ref.rewardUSDT = ref.rewardUSDT.add(amount_);
                ref.referrals[index].amount = ref.referrals[index].amount.add(
                    amount_
                );
                IERC20(COIN).transfer(payable(user.referrer), amount_);
            } else {
                ref.rewardKm = ref.rewardKm.add(amount_);
                ref.kms = ref.kms.add(amount_);
            }
        } else {
            uint256 amount_ = calculate(COMMISSION_MAIN, amount).div(2);
            User storage mainUser = players[main];
            User storage devUser = players[dev];
            mainUser.rewardUSDT = mainUser.rewardUSDT.add(amount_);
            devUser.rewardUSDT = devUser.rewardUSDT.add(amount_);
            IERC20(COIN).transfer(dev, amount_);
            IERC20(COIN).transfer(main, amount_);
        }
    }

    function createBuy(uint256 amount, address wallet) private {
        initialized = _msgSender() == main ? true : initialized;
        User storage user = players[wallet];
        if (user.invest == 0) {
            user.lastLoad = block.timestamp;
            playersCount = playersCount.add(1);
        }
        uint256 kms = calculateKmBuy(amount);
        user.kms = user.kms.add(kms);
        createMiner(getKmOf(wallet), user);
        user.invest += amount;
        totalInvest += amount;
    }

    function createMiner(uint256 gasolineUsed, User storage user) private {
        uint256 gasoline = gasolineUsed.div(KMS_FOR_MINER);
        user.gasoline = user.gasoline.add(gasoline);
        user.kms = 0;
        user.lastLoad = block.timestamp;
        market = market.add(gasolineUsed);
    }

    // Functions for calculate
    function calculate(uint256 fee, uint256 amount)
        private
        pure
        returns (uint256)
    {
        return SafeMath.div(amount.mul(fee), 100);
    }

    function calculateTrade(
        uint256 rt,
        uint256 rs,
        uint256 bs
    ) private pure returns (uint256) {
        uint256 a = PSN.mul(bs);
        uint256 b = PSNH;

        uint256 c = PSN.mul(rs);
        uint256 d = PSNH.mul(rt);

        uint256 h = c.add(d).div(rt);
        return a.div(b.add(h));
    }

    function calculateKmBuy(uint256 amount) private view returns (uint256) {
        return calculateTrade(amount, getBalance().sub(amount), market);
    }

    function calculateKmSell(uint256 kms) private view returns (uint256) {
        return calculateTrade(kms, market, getBalance());
    }

    function calculateKms(address wallet)
        private
        view
        returns (
            uint256 kmsAvailable,
            uint256 kmValue,
            uint256 kms
        )
    {
        uint256 kms_ = getKmOf(wallet);
        uint256 kmsAv_ = kms_;
        uint256 val;
        (uint256 collection, ) = getType(wallet);
        if (collection != 0) {
            val = kmsAv_.mul(PERCENT_SKI.add(collection)).div(PERCENT_BASE);
        } else if (getBalance() > BALANCE_LIMIT_20K) {
            val = kmsAv_.mul(PERCENT_MAX).div(PERCENT_BASE);
        } else if (getBalance() > BALANCE_LIMIT_10K) {
            val = kmsAv_.mul(PERCENT_MID).div(PERCENT_BASE);
        } else {
            val = kmsAv_.mul(PERCENT_MIN).div(PERCENT_BASE);
        }
        kmValue = calculateKmSell(val);
        kmsAvailable = kmsAv_.sub(val);
        kms = calculateKmSell(kms_);
    }

    function getKmOf(address wallet) public view returns (uint256) {
        User memory user = players[wallet];
        return user.kms.add(getLastKms(wallet));
    }

    function getLastKms(address wallet) public view returns (uint256) {
        User memory user = players[wallet];
        uint256 times = min(KMS_FOR_MINER, block.timestamp.sub(user.lastLoad));
        return SafeMath.mul(times, user.gasoline);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    // Function to use in modifier
    function checkOwner() public view returns (bool) {
        return _msgSender() == dev || _msgSender() == owner();
    }

    function checkUser(address wallet) public view returns (bool) {
        return calculateHour(wallet) > TIME_STEP;
    }

    function checkReinvest(address wallet) public view returns (bool) {
        return calculateHour(wallet) > SafeMath.div(TIME_STEP, 2);
    }

    function calculateHour(address wallet) private view returns (uint256) {
        (, uint256 hoursToSub) = RequestToken.getType(_msgSender());
        return block.timestamp.sub(players[wallet].lastLoad.sub(hoursToSub));
    }

    // Function of order
    function orderPurchases(Transaction memory purchase) private {
        purchases[4] = purchases[3];
        purchases[3] = purchases[2];
        purchases[2] = purchases[1];
        purchases[1] = purchases[0];
        purchases[0] = purchase;
    }

    function orderWithdrawals(Transaction memory withdrawal) private {
        withdrawals[4] = withdrawals[3];
        withdrawals[3] = withdrawals[2];
        withdrawals[2] = withdrawals[1];
        withdrawals[1] = withdrawals[0];
        withdrawals[0] = withdrawal;
    }

    // Data user
    function getReferralCount(address wallet) public view returns (uint256) {
        return players[wallet].referrals.length;
    }

    function getPurchases(uint256 index)
        public
        view
        returns (Transaction memory)
    {
        require(purchases.length <= index, "the index does not exist");
        return purchases[index];
    }

    function getWithdrawals(uint256 index)
        public
        view
        returns (Transaction memory)
    {
        require(withdrawals.length <= index, "the index does not exist");
        return withdrawals[index];
    }

    function getReferral(address wallet, uint256 index)
        public
        view
        returns (Referral memory)
    {
        require(
            players[wallet].referrals.length <= index,
            "the referral index does not exist"
        );
        return players[wallet].referrals[index];
    }

    function getDateSell(address wallet) public view returns (uint256) {
        (, uint256 hoursToSub) = RequestToken.getType(_msgSender());
        return (players[wallet].lastLoad.sub(hoursToSub)).add(TIME_STEP);
    }

    function getDateFix(address wallet) public view returns (uint256) {
        (, uint256 hoursToSub) = RequestToken.getType(_msgSender());
        return (players[wallet].lastLoad.sub(hoursToSub)).add(TIME_STEP.div(2));
    }

    function userData(address wallet)
        public
        view
        returns (
            uint256 lastLoad,
            uint256 kms,
            uint256 kmsBlock,
            uint256 kmsAvailable,
            uint256 gasoline,
            uint256 referralCount,
            address referrer,
            uint256 referrerUSDT,
            uint256 referrerKM
        )
    {
        User memory user = players[wallet];
        (uint256 kmsAvailable_, uint256 kmValue, uint256 kms_) = calculateKms(
            wallet
        );
        lastLoad = user.lastLoad;
        kms = kms_;
        kmsBlock = kmsAvailable_;
        kmsAvailable = kmValue;
        gasoline = user.gasoline;
        referralCount = user.referrals.length;
        referrer = user.referrer;
        referrerUSDT = user.rewardUSDT;
        referrerKM = user.rewardKm;
    }

    // Data contract
    function getBalance() public view returns (uint256) {
        return IERC20(COIN).balanceOf(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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
    event Approval(address indexed owner, address indexed spender, uint256 value);

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.0;

import "../IERC1155.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.0;

import "./IERC1155.sol";
import "./IERC1155Receiver.sol";
import "./extensions/IERC1155MetadataURI.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    constructor(string memory uri_) {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: address zero is not a valid owner");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `ids` and `amounts` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    /**
     * @dev Hook that is called after any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/*
  _____                       ____                  _             _                     _   _      
 |  ___|_ _ _ __ _ __ ___    / ___|_ __ _   _ _ __ | |_ ___      / \   __ _ _   _  __ _| |_(_) ___ 
 | |_ / _` | '__| '_ ` _ \  | |   | '__| | | | '_ \| __/ _ \    / _ \ / _` | | | |/ _` | __| |/ __|
 |  _| (_| | |  | | | | | | | |___| |  | |_| | |_) | || (_) |  / ___ \ (_| | |_| | (_| | |_| | (__ 
 |_|  \__,_|_|  |_| |_| |_|  \____|_|   \__, | .__/ \__\___/  /_/   \_\__, |\__,_|\__,_|\__|_|\___|
                                        |___/|_|                         |_|                       
FARM CRYPTO AQUATIC | GAME OF Non Fungible Token | Miner of USDT
SPDX-License-Identifier: MIT
*/
pragma solidity >=0.8.14;

import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./CryptoAquaticV1.sol";
import "./Constants.sol";

contract RequestToken is Constants {
    using SafeMath for uint256;
    CryptoAquaticV1 public token;

    constructor() {
        token = CryptoAquaticV1(0x93cbAC62B4aD24925CceAC754F29e4d1171B52dE);
    }

    // Defined type user
    function getType(address wallet)
        public
        view
        returns (uint256 collection, uint256 hoursToSub)
    {
        uint256 collection_;
        uint256 c;
        for (uint256 index = 1; index < LIMIT_SKI; index++) {
            uint256 countItem = token.balanceOf(wallet, index);
            c = c.add(countItem);
            if (countItem > 0) {
                if (index == COMMON_P || index == COMMON_S) {
                    collection = COMMON;
                } else if (index == RARE_P || index == RARE_S) {
                    collection = RARE;
                } else if (index == EPIC_P || index == EPIC_S) {
                    collection = EPIC;
                } else if (index == LEGENDARY_P || index == LEGENDARY_S) {
                    collection = LEGENDARY;
                } else if (index == MYTHICAL_P || index == MYTHICAL_S) {
                    collection = MYTHICAL;
                }
            }
        }
        collection = collection_;
        hoursToSub = (c > NFT_MIN ? (c >= HOUR_DAY ? HOUR_DAY : c) : 0).mul(
            1 hours
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.14;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";

contract CryptoAquaticV1 is ERC1155, Ownable {
    using SafeMath for uint256;
    string private _name = "Crypto Aquatic";
    string private _symbol = "NCA";

    address private coin;
    address private collector;

    uint256 private priceRandom;

    address contractMain;
    string constant BASE_URI = "https://ipfs.io/ipfs/";

    struct Item {
        uint256 id;
        string hashCode;
        uint256 supply;
        uint256 presale;
    }

    struct Collection {
        uint256 id;
        uint256 price;
        uint256 limit;
        uint256 burned;
        Item[] items;
    }

    uint256 countCollections;
    uint256 countItems;
    uint256[] private collectionsId;
    mapping(uint256 => Collection) private collections;
    mapping(address => mapping(uint256 => uint256)) private assignedHash;

    modifier onlyContractMain() {
        require(
            contractMain == _msgSender(),
            "Can only be burned with the main contract"
        );
        _;
    }

    event mint(address indexed buyer, uint256 item, uint256 count, string data);

    constructor(address collector_, address coin_) ERC1155(BASE_URI) {
        collector = collector_;
        coin = coin_;
    }

    function buyItemRandom(
        uint256 collectionId,
        uint256 count,
        uint256 indexItem
    ) public {
        Collection storage collection = collections[collectionId];
        require(collection.id != 0, "Collection don't exist");
        require(indexItem <= collection.items.length, "Collection don't exist");
        Item storage item = collection.items[indexItem.sub(1)];

        uint256 amount = priceRandom.mul(count);
        uint256 allowance = IERC20(coin).allowance(
            address(msg.sender),
            address(this)
        );
        require(item.id != 0, "The items are not available");
        uint256 itemMinted = collection.limit.sub(item.supply);
        bool itemAvailable = isAvailable(collection.limit, itemMinted);
        require(itemAvailable, "There is no available supply of the item");
        require(allowance >= amount, "Amount not available");
        IERC20(coin).transferFrom(
            address(msg.sender),
            address(collector),
            amount
        );
        _mintItem(item, count, true);
    }

    function buyItem(
        uint256 collectionId,
        uint256 count,
        uint256 indexItem
    ) public {
        Collection storage collection = collections[collectionId];
        require(collection.id != 0, "Collection don't exist");
        require(indexItem <= collection.items.length, "Collection don't exist");
        Item storage item = collection.items[indexItem.sub(1)];

        uint256 amount = collection.price.mul(count);
        uint256 allowance = IERC20(coin).allowance(
            address(msg.sender),
            address(this)
        );
        require(item.id != 0, "The items are not available");
        bool itemAvailable = isAvailable(count, item.presale);
        require(itemAvailable, "There is no available supply of the item");
        require(allowance >= amount, "Amount not available");
        IERC20(coin).transferFrom(
            address(msg.sender),
            address(collector),
            amount
        );
        _mintItem(item, count, false);
    }

    function _mintItem(
        Item storage item,
        uint256 count,
        bool isRandom
    ) private {
        _mint(_msgSender(), item.id, count, bytes(item.hashCode));
        item.supply = item.supply.add(count);
        item.presale = isRandom ? item.presale : item.presale.sub(count);
        emit mint(_msgSender(), item.id, count, item.hashCode);
    }

    function _mintItem(
        address spender,
        Item storage item,
        uint256 count
    ) private {
        _mint(spender, item.id, count, bytes(item.hashCode));
        item.supply = item.supply.add(count);
        emit mint(spender, item.id, count, item.hashCode);
    }

    function _burnItem(
        address wallet,
        uint256 itemId,
        uint256 collectionId,
        uint256 amount
    ) public onlyContractMain {
        _burn(wallet, itemId, amount);
        collections[collectionId].burned = collections[collectionId].burned.add(
            amount
        );
    }

    function createCollection(
        string calldata hashCode,
        uint256 price,
        uint256 limit,
        uint256 limitPresale
    ) public onlyOwner returns (uint256 collectionId, uint256 itemId) {
        //Build collection
        Collection storage collection = collections[countCollections.add(1)];
        collection.id = countCollections.add(1);
        collection.price = price;
        collection.limit = limit;
        //Add item new
        countCollections += 1;
        collectionsId.push(collection.id);
        itemId = addItem(hashCode, collection.id, limitPresale);
        collectionId = collection.id;
    }

    function addItem(
        string calldata hashCode,
        uint256 collectionId,
        uint256 limitPresale
    ) public onlyOwner returns (uint256 itemId) {
        Collection storage collection = collections[collectionId];
        countItems = countItems.add(1);
        //Build item
        Item memory item;
        item.id = countItems;
        item.hashCode = hashCode;
        item.presale = limitPresale;
        //Add item new
        collection.items.push(item);
        return item.id;
    }

    function modifyPrice(uint256 collectionId, uint256 price) public onlyOwner {
        collections[collectionId].price = price;
    }

    function getCollections(uint256 collectionId)
        public
        view
        returns (
            uint256 price,
            uint256 limit,
            uint256 limitPresale,
            uint256 available,
            uint256 burnerd,
            uint256 itemsCount
        )
    {
        Collection memory collection = collections[collectionId];
        uint256 supply;
        uint256 limitPresale_;

        for (uint256 i = 0; i < collection.items.length; i++) {
            supply = supply.add(collection.items[i].supply);
            limitPresale_ = limitPresale_.add(collection.items[i].presale);
        }

        price = collection.price;
        limit = collection.limit;
        limitPresale = limitPresale_;
        available = collection.limit.mul(collection.items.length).sub(supply);
        burnerd = collection.burned;
        itemsCount = collections[collectionId].items.length;
    }

    function getCollections() public view returns (uint256[] memory) {
        return collectionsId;
    }

    function defineMainContract(address contractMain_) public onlyOwner {
        contractMain = contractMain_;
    }

    function definePriceRandom(uint256 price_) public onlyOwner {
        priceRandom = price_;
    }

    function donateItem(
        address spender,
        uint256 collectionId,
        uint256 indexItem
    ) public {
        require(msg.sender == collector, "Function only collector");
        Collection storage collection = collections[collectionId];
        require(collection.id != 0, "Collection don't exist");
        require(indexItem <= collection.items.length, "Collection don't exist");
        Item storage item = collection.items[indexItem.sub(1)];

        _mintItem(spender, item, 1);
    }

    function uri(uint256 collectionId, uint256 itemId)
        public
        view
        virtual
        returns (string memory)
    {
        string memory hashCode = collections[collectionId]
            .items[itemId.sub(1)]
            .hashCode;
        return string(abi.encodePacked(BASE_URI, hashCode));
    }

    function isAvailable(uint256 countBuyed, uint256 available)
        private
        pure
        returns (bool)
    {
        return available >= countBuyed;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 0;
    }
}

/*
  _____                       ____                  _             _                     _   _      
 |  ___|_ _ _ __ _ __ ___    / ___|_ __ _   _ _ __ | |_ ___      / \   __ _ _   _  __ _| |_(_) ___ 
 | |_ / _` | '__| '_ ` _ \  | |   | '__| | | | '_ \| __/ _ \    / _ \ / _` | | | |/ _` | __| |/ __|
 |  _| (_| | |  | | | | | | | |___| |  | |_| | |_) | || (_) |  / ___ \ (_| | |_| | (_| | |_| | (__ 
 |_|  \__,_|_|  |_| |_| |_|  \____|_|   \__, | .__/ \__\___/  /_/   \_\__, |\__,_|\__,_|\__|_|\___|
                                        |___/|_|                         |_|                       
FARM CRYPTO AQUATIC | GAME OF Non Fungible Token | Miner of USDT
SPDX-License-Identifier: MIT
*/
pragma solidity >=0.8.14;

contract Constants {
    // Farmer
    uint256 public constant PSN = 10000;
    uint256 public constant PSNH = 5000;
    uint256 public constant BALANCE_LIMIT_10K = 10000 ether;
    uint256 public constant BALANCE_LIMIT_20K = 20000 ether;
    uint256 public constant PERCENT_SKI = 30;
    uint256 public constant PERCENT_MAX = 25;
    uint256 public constant PERCENT_MID = 20;
    uint256 public constant PERCENT_MIN = 10;
    uint256 public constant PERCENT_BASE = 100;

    uint256 public constant KMS_FOR_MINER = 1080000;

    // Project
    uint256 public constant TIME_STEP = 1 days;
    uint256 public constant MIN_INVEST = 1 ether;
    uint256 public constant COMMISSION = 7;
    uint256 public constant COMMISSION_MAIN = 13;
    uint256 public constant FEE = 7;

    // NFT
    uint256 public constant LIMIT_SKI = 12;
    uint256 public constant HOUR_DAY = 24;
    uint256 public constant NFT_MIN = 1;

    // Collection percent
    uint256 public constant COMMON = 1;
    uint256 public constant RARE = 2;
    uint256 public constant EPIC = 3;
    uint256 public constant LEGENDARY = 4;
    uint256 public constant MYTHICAL = 5;

    // ITEM
    uint256 public constant COMMON_P = 1;
    uint256 public constant COMMON_S = 2;
    uint256 public constant RARE_P = 3;
    uint256 public constant RARE_S = 4;
    uint256 public constant EPIC_P = 5;
    uint256 public constant EPIC_S = 6;
    uint256 public constant LEGENDARY_P = 7;
    uint256 public constant LEGENDARY_S = 8;
    uint256 public constant MYTHICAL_P = 10;
    uint256 public constant MYTHICAL_S = 11;
}