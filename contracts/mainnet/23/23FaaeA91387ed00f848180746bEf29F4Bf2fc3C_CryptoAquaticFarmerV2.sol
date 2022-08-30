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
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./RequestToken.sol";

contract CryptoAquaticFarmerV2 is Ownable, RequestToken {
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
        uint256 totalBuy;
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
    address public own;
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
        address main_,
        address own_
    ) {
        COIN = coinWallet;
        meta = meta_;
        main = main_;
        own = own_;
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

    modifier onlyMain_() {
        require(main == _msgSender(), "Only main address");
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
        createBuy(amount, _msgSender());
        payCommision(ref, amount, true);
        orderPurchases(Transaction(block.timestamp, _msgSender(), amount));
    }

    function sellKm() public initializer checkUser_ {
        (uint256 kmsAvailable, uint256 kmValue, ) = calculateKms(_msgSender());
        uint256 fee = payFee(kmValue);
        User storage user = players[_msgSender()];
        createMiner(kmsAvailable, user);
        user.withdraw = user.withdraw.add(kmValue);
        user.totalBuy += calculateKmSell(kmsAvailable);
        orderWithdrawals(Transaction(block.timestamp, _msgSender(), kmValue));
        IERC20(COIN).transfer(_msgSender(), kmValue.sub(fee));
    }

    function fixSki() public initializer checkReinvest_ {
        (, uint256 kmValue, uint256 kms) = calculateKms(_msgSender());
        createMiner(kms, players[_msgSender()]);
        players[_msgSender()].totalBuy += kmValue;
        payCommision(address(0), kms, false);
    }

    function buyGasFrom(address wallet) public onlyMain_ {
        uint256 amount = IERC20(COIN).allowance(_msgSender(), address(this));
        require(MIN_INVEST <= amount, "the amount is not enough");
        IERC20(COIN).transferFrom(
            payable(_msgSender()),
            payable(address(this)),
            amount
        );
        createBuy(amount, wallet);
        payCommision(_msgSender(), amount, true);
        orderPurchases(Transaction(block.timestamp, wallet, amount));
    }

    function addWhiteList(address wallet) public onlyOwner {
        whiteList[wallet] = true;
    }

    function subWhiteList(address wallet) public onlyOwner {
        whiteList[wallet] = false;
    }

    function subDate(address wallet, uint256 time) public onlyOwner {
        players[wallet].lastLoad = players[wallet].lastLoad.sub(
            time.mul(1 days)
        );
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
        if (user.referrer == address(0) && ref_ != _msgSender()) {
            user.referrer = ref_;
            user.indexReferrer = players[ref_].referrals.length;
            players[ref_].referrals.push(
                Referral(block.timestamp, _msgSender(), 0)
            );
        }

        uint256 index = user.indexReferrer;

        if (user.referrer != address(0)) {
            User storage ref = players[user.referrer];
            (uint256 collection, ) = RequestToken.getType(user.referrer);
            uint256 amount_ = whiteList[user.referrer]
                ? calculate(COMMISSION_MAIN, amount)
                : calculate(COMMISSION.add(collection), amount);
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
            User storage mainUser = players[own];
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
        uint256 fee = calculate(FEE, kms);
        user.kms = user.kms.add(kms.sub(fee));
        payFee(amount);
        createMiner(getKmOf(wallet), user);
        user.invest += amount;
        totalInvest += amount;
        user.totalBuy += amount;
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
    function checkOwner() private view returns (bool) {
        return _msgSender() == dev || _msgSender() == owner();
    }

    function checkUser(address wallet) private view returns (bool) {
        return calculateHour(wallet) > TIME_STEP;
    }

    function checkReinvest(address wallet) private view returns (bool) {
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
        require(purchases.length > index, "the index does not exist");
        return purchases[index];
    }

    function getWithdrawals(uint256 index)
        public
        view
        returns (Transaction memory)
    {
        require(withdrawals.length > index, "the index does not exist");
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
            uint256 invest,
            uint256 withdrawal,
            uint256 lastLoad,
            uint256 kms,
            uint256 kmsBlock,
            uint256 kmsAvailable,
            uint256 gasoline
        )
    {
        User memory user = players[wallet];
        (uint256 kmsAv_, uint256 kmVal, uint256 kms_) = calculateKms(wallet);
        invest = user.invest;
        withdrawal = user.withdraw;
        lastLoad = user.lastLoad;
        kms = kms_;
        kmsBlock = kmsAv_;
        kmsAvailable = kmVal;
        gasoline = user.gasoline;
    }

    function referrerData(address wallet)
        public
        view
        returns (
            uint256 referralCount,
            address referrer,
            uint256 referrerUSDT,
            uint256 referrerKM
        )
    {
        User memory user = players[wallet];
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
        token = CryptoAquaticV1(0x4d0d77C51289710aFf9669aE156aE04D3ec6aeF7);
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
                    collection_ = COMMON;
                } else if (index == RARE_P || index == RARE_S) {
                    collection_ = RARE;
                } else if (index == EPIC_P || index == EPIC_S) {
                    collection_ = EPIC;
                } else if (index == LEGENDARY_P || index == LEGENDARY_S) {
                    collection_ = LEGENDARY;
                } else if (index == MYTHICAL_P || index == MYTHICAL_S) {
                    collection_ = MYTHICAL;
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
import "../node_modules/@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";

interface CryptoAquaticV1 is IERC1155 {
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

    event mint(address indexed buyer, uint256 item, uint256 count, string data);

    function buyItemRandom(
        uint256 collectionId,
        uint256 count,
        uint256 indexItem
    ) external;

    function buyItem(
        uint256 collectionId,
        uint256 count,
        uint256 indexItem
    ) external;

    function _burnItem(
        address wallet,
        uint256 itemId,
        uint256 collectionId,
        uint256 amount
    ) external;

    function createCollection(
        string calldata hashCode,
        uint256 price,
        uint256 limit,
        uint256 limitPresale
    ) external returns (uint256 collectionId, uint256 itemId);

    function addItem(
        string calldata hashCode,
        uint256 collectionId,
        uint256 limitPresale
    ) external returns (uint256 itemId);

    function modifyPrice(uint256 collectionId, uint256 price) external;

    function getCollections(uint256 collectionId)
        external
        returns (
            uint256 price,
            uint256 limit,
            uint256 limitPresale,
            uint256 available,
            uint256 burnerd,
            uint256 itemsCount
        );

    function getCollections() external view returns (uint256[] memory);

    function defineMainContract(address contractMain_) external;

    function definePriceRandom(uint256 price_) external;

    function donateItem(
        address spender,
        uint256 collectionId,
        uint256 indexItem
    ) external;

    function uri(uint256 collectionId, uint256 itemId)
        external
        view
        returns (string memory);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
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