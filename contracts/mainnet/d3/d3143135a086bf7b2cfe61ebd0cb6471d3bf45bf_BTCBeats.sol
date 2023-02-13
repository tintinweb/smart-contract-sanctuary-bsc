/**
 *Submitted for verification at BscScan.com on 2023-02-12
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-14
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface ERC20 {
    function balanceOf(address tokenOwner)
        external
        view
        returns (uint256 balance);

    function allowance(address tokenOwner, address spender)
        external
        view
        returns (uint256 remaining);

    function transfer(address to, uint256 tokens)
        external
        returns (bool success);

    function approve(address spender, uint256 tokens)
        external
        returns (bool success);

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint256 tokens
    );
}

interface BUSDBirdStake {
    function userInfo(address _addr)
        external
        view
        returns (
            uint256 for_withdraw,
            uint256 total_invested,
            uint256 total_withdrawn,
            uint256 total_match_bonus,
            uint256[5] memory structure
        );
}

contract BTCBeats is Ownable {
    using SafeMath for uint256;

    address public BUSD = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c;

    uint256 private EGGS_TO_HATCH_1MINERS = 1080000;
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private devFeeVal = 2;
    uint256 private mrkFeeVal = 2;
    uint256 private prjFeeVal = 2;
    uint256 private totalFee = 6;
    uint256 private referrerCommissionVal = 14;
    uint256 private priceWhiteList = 6800000000000000 wei;
    address payable public dev1Address;
    address payable public dev2Address;
    address payable public prjAddress;
    address payable public mrkAddress;
    bool private initialized = false;
    uint256 public marketEggs;

    struct User {
        uint256 invest;
        uint256 withdraw;
        uint256 hatcheryMiners;
        uint256 claimedEggs;
        uint256 lastHatch;
        uint256 checkpoint;
        address referrals;
        uint256 referrer;
        uint256 amountBNBReferrer;
        uint256 amountEggsReferrer;
    }

    mapping(address => User) public users;
    mapping(address => bool) public whiteList;

    uint256 public totalInvested;
    uint256 internal constant TIME_STEP = 1 days;

    constructor() {
        dev1Address = payable(0x7B548CcE7FAf29716d73D6E983efB8886ecE93f3);
        prjAddress = payable(0x17aBbDB866843DB44f0B7946e0A4B497F2fd144C);
        mrkAddress = payable(0xf8db7110f814af8D5116CBae9C37c44015898A36);
        marketEggs = 108000000000;
    }

    modifier initializer() {
        require(initialized, "initialized is false");
        _;
    }

    modifier checkUser_() {
        require(checkUser(), "try again later");
        _;
    }

    modifier checkOwner_() {
        require(checkOwner(), "try again later");
        _;
    }

    function checkOwner() public view returns (bool) {
        return
            msg.sender == dev1Address ||
            msg.sender == mrkAddress ||
            msg.sender == owner();
    }

    function checkUser() public view returns (bool) {
        uint256 check = block.timestamp.sub(users[msg.sender].checkpoint);
        if (check > TIME_STEP) {
            return true;
        }
        return false;
    }

    function hatchEggs(address ref) public {
        if (ref == msg.sender) {
            ref = address(0);
        }

        User storage user = users[msg.sender];
        if (user.referrals == address(0) && user.referrals != msg.sender) {
            user.referrals = ref;
        }

        uint256 eggsUsed = getMyEggs(msg.sender);
        uint256 newMiners = SafeMath.div(eggsUsed, EGGS_TO_HATCH_1MINERS);
        user.hatcheryMiners = SafeMath.add(user.hatcheryMiners, newMiners);
        user.claimedEggs = 0;
        user.lastHatch = block.timestamp;
        user.checkpoint = block.timestamp;

        //send referral eggs
        User storage referrals_ = users[user.referrals];
        referrals_.claimedEggs = SafeMath.add(
            referrals_.claimedEggs,
            (eggsUsed * 8) / 100
        );
    }

    function sellEggs() external checkUser_ {
        User storage user = users[msg.sender];
        uint256 hasEggs = getMyEggs(msg.sender);
        uint256 eggValue;

        uint256 devFee = (eggValue * devFeeVal) / 100;
        uint256 mrkFee = (eggValue * mrkFeeVal) / 100;
        uint256 prjFee = (eggValue * prjFeeVal) / 100;

        ERC20(BUSD).transfer(payable(dev1Address), devFee);
        ERC20(BUSD).transfer(payable(mrkAddress), mrkFee);
        ERC20(BUSD).transfer(payable(prjAddress), prjFee);

        uint256 eggsUsed = hasEggs;
        uint256 newMiners = SafeMath.div(eggsUsed, EGGS_TO_HATCH_1MINERS);
        user.hatcheryMiners = SafeMath.add(user.hatcheryMiners, newMiners);
        user.claimedEggs = 0;
        user.lastHatch = block.timestamp;
        user.checkpoint = block.timestamp;

        marketEggs = SafeMath.add(marketEggs, hasEggs);
        user.withdraw += eggValue;
        ERC20(BUSD).transfer(
            payable(msg.sender),
            SafeMath.sub(eggValue, (devFee + devFee + mrkFee + prjFee))
        );
    }

    function calculateMyEggs(address adr)
        private
        view
        returns (
            uint256 hasEggs,
            uint256 eggValue,
            uint256 eggs
        )
    {
        uint256 eggs_ = getMyEggs(msg.sender);
        uint256 hasEggs_ = eggs_;
        uint256 eggsValue_;
        if (whiteList[adr]) {
            eggsValue_ = calculateEggSell(
                SafeMath.div(hasEggs_, SafeMath.div(250, 100))
            );
            hasEggs_ -= (hasEggs_ / SafeMath.div(250, 100));
        } else {
            eggsValue_ = calculateEggSell(SafeMath.div(hasEggs_, 8));
            hasEggs_ -= (hasEggs_ / 8);
        }
        hasEggs = hasEggs_;
        eggValue = eggsValue_;
        eggs = calculateEggSell(eggs_);
    }

    function beanRewards(address adr) public view returns (uint256) {
        uint256 hasEggs = getMyEggs(adr);
        uint256 eggValue = calculateEggSell(hasEggs);
        return eggValue;
    }

    function buyEggs(address ref, uint256 amount) external {
        User storage user = users[msg.sender];

        if (ref == msg.sender) {
            user.referrals = mrkAddress;
        } else if (user.referrals == address(0)) {
            user.referrals = ref;
            users[ref].referrer = users[ref].referrer.add(1);
        }

        ERC20(BUSD).transferFrom(address(msg.sender), address(this), amount);

        uint256 eggsBought = calculateEggBuy(
            amount,
            SafeMath.sub(ERC20(BUSD).balanceOf(address(this)), amount)
        );
        eggsBought = SafeMath.sub(eggsBought, (eggsBought * totalFee) / 100);
        uint256 devFee = (amount * devFeeVal) / 100;
        uint256 mrkFee = (amount * mrkFeeVal) / 100;
        uint256 prjFee = (amount * prjFeeVal) / 100;

        ERC20(BUSD).transfer(payable(dev1Address), devFee);
        ERC20(BUSD).transfer(payable(mrkAddress), mrkFee);
        ERC20(BUSD).transfer(payable(prjAddress), prjFee);

        user.invest += amount;
        user.claimedEggs = SafeMath.add(user.claimedEggs, eggsBought);
        hatchEggs(ref);
        sendReferral(ref, SafeMath.div(SafeMath.mul(amount, 13), 100));
        totalInvested += amount;
    }

    function sendReferral(address ref, uint256 amount) private {
        ERC20(BUSD).transfer(ref, amount);
    }

    function calculateTrade(
        uint256 rt,
        uint256 rs,
        uint256 bs
    ) private view returns (uint256) {
        uint256 a = PSN.mul(bs);
        uint256 b = PSNH;
        uint256 c = PSN.mul(rs);
        uint256 d = PSNH.mul(rt);
        uint256 h = c.add(d).div(rt);
        return a.div(b.add(h));
    }

    function calculateEggSell(uint256 eggs) public view returns (uint256) {
        uint256 _cal = calculateTrade(
            eggs,
            marketEggs,
            ERC20(BUSD).balanceOf(address(this))
        );
        _cal += _cal.mul(5).div(100);
        return _cal;
    }

    function calculateEggBuy(uint256 eth, uint256 contractBalance)
        public
        view
        returns (uint256)
    {
        return calculateTrade(eth, contractBalance, marketEggs);
    }

    function calculateEggBuySimple(uint256 eth) public view returns (uint256) {
        return calculateEggBuy(eth, ERC20(BUSD).balanceOf(address(this)));
    }

    function seedMarket() public onlyOwner {
        require(marketEggs == 0);
        initialized = true;
        marketEggs = 108000000000;
    }

    function getBalance() public view returns (uint256) {
        return ERC20(BUSD).balanceOf(address(this));
    }

    function getMyMiners(address adr) public view returns (uint256) {
        User memory user = users[adr];
        return user.hatcheryMiners;
    }

    function getMyEggs(address adr) public view returns (uint256) {
        User memory user = users[adr];
        return SafeMath.add(user.claimedEggs, getEggsSinceLastHatch(adr));
    }

    function getEggsSinceLastHatch(address adr) public view returns (uint256) {
        User memory user = users[adr];
        uint256 secondsPassed = min(
            EGGS_TO_HATCH_1MINERS,
            SafeMath.sub(block.timestamp, user.lastHatch)
        );
        return SafeMath.mul(secondsPassed, user.hatcheryMiners);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function getSellEggs(address user_) public view returns (uint256 eggValue) {
        uint256 hasEggs = getMyEggs(user_);
        eggValue = calculateEggSell(hasEggs);
    }

    function getPublicData()
        external
        view
        returns (uint256 _totalInvest, uint256 _balance)
    {
        _totalInvest = totalInvested;
        _balance = ERC20(BUSD).balanceOf(address(this));
    }

    function userData(address user_)
        external
        view
        returns (
            uint256 hatcheryMiners_,
            uint256 claimedEggs_,
            uint256 lastHatch_,
            uint256 sellEggs_,
            uint256 eggsMiners_,
            uint256 referrer,
            uint256 rewards_,
            address referrals_,
            uint256 checkpoint
        )
    {
        User memory user = users[user_];
        hatcheryMiners_ = getMyMiners(user_);
        claimedEggs_ = getMyEggs(user_);
        lastHatch_ = user.lastHatch;
        referrals_ = user.referrals;
        rewards_ = eggsMiners_;
        referrer = user.referrer;
        sellEggs_ = getSellEggs(user_);
        eggsMiners_ = getEggsSinceLastHatch(user_);
        checkpoint = user.checkpoint;
    }

    function addToWhiteList(address adr) external checkOwner_ {
        addWhiteList(adr);
    }

    function addWhiteList(address adr) private {
        whiteList[adr] = true;
    }

    function removeToWhiteList(address adr) external checkOwner_ {
        whiteList[adr] = false;
    }

    function getDate() public view returns (uint256) {
        return block.timestamp;
    }
}