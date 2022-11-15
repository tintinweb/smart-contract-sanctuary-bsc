/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

/*  
██████╗ ███╗   ██╗██████╗ ███████╗ █████╗ ████████╗███████╗    ██╗██╗██╗
██╔══██╗████╗  ██║██╔══██╗██╔════╝██╔══██╗╚══██╔══╝██╔════╝    ██║██║██║
██████╔╝██╔██╗ ██║██████╔╝█████╗  ███████║   ██║   ███████╗    ██║██║██║
██╔══██╗██║╚██╗██║██╔══██╗██╔══╝  ██╔══██║   ██║   ╚════██║    ██║██║██║
██████╔╝██║ ╚████║██████╔╝███████╗██║  ██║   ██║   ███████║    ██║██║██║
╚═════╝ ╚═╝  ╚═══╝╚═════╝ ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝    ╚═╝╚═╝╚═╝ 
BNBeast Farm | earn money until 8% daily | Metaversing 
SPDX-License-Identifier: MIT
*/

pragma solidity ^0.8.13;

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

contract BNBBeatsV2 {
    struct User {
        uint256 invest;
        uint256 withdraw;
        uint256 hatcheryMiners;
        uint256 claimedBeats;
        uint256 lastHatch;
        uint256 checkpoint;
        address referrals;
    }
    mapping(address => User) public users;
    mapping(address => bool) public whiteList;

    function getBalance() public view returns (uint256) {}
}

contract BNBBeatsV3 is Ownable {
    using SafeMath for uint256;

    uint256 private BEATS_TO_HATCH_1MINERS = 1080000; //for final version should be seconds in a day
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private balanceLimit = 100;
    uint256 private priceWhiteList = 35 ether;
    uint256 private devFeeVal = 5;
    uint256 private referrerCommissionVal = 1350;
    bool private initialized = false;
    address payable public devAddress;
    address payable public ownerAddress;
    address payable public mktAddress;
    address payable public originAddress;
    BNBBeatsV2 private contractOrigin;
    ERC20 private tokenBUSD;

    uint256 public marketBeats;
    uint256 private players;

    struct UserV3 {
        uint256 invest;
        uint256 investOrigin;
        uint256 withdraw;
        uint256 withdrawOrigin;
        uint256 hatcheryMiners;
        uint256 claimedBeats;
        uint256 lastHatch;
        uint256 checkpoint;
        bool originDone;
        address referrals;
        uint256 referrer;
        uint256 amountBNBReferrer;
        uint256 amountBEATSReferrer;
    }

    struct UserResponse {
        uint256 lastHatch_;
        uint256 rewards_;
        uint256 amountAvailableReinvest_;
        uint256 availableWithdraw_;
        uint256 beatsMiners_;
        address referrals_;
        uint256 referrer;
        uint256 checkpoint;
        uint256 referrerBNB;
        uint256 referrerBEATS;
    }

    mapping(address => UserV3) public users;
    mapping(address => UserV3) public usersOrigin;
    mapping(address => bool) public whiteList;

    uint256 public totalInvested;
    uint256 internal constant TIME_STEP = 1 days;

    constructor() {
        devAddress = payable(0xd33B0b6FdB041A5c5A5AeB3c53735a375bC1c847);
        ownerAddress = payable(0x4326B1a04Bb726924A537E25acEF7eE1c53627A1);
        mktAddress = payable(0xAE49aB6c4C131C3c871b1f57832c3f51608B99A6);
        originAddress = payable(0xAE49aB6c4C131C3c871b1f57832c3f51608B99A6);
        marketBeats = 108000000000;
        contractOrigin = BNBBeatsV2(0x0EB6b3438150BBA686399b0DC82B9E7B3dC94880);
        tokenBUSD = ERC20(address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56));
    }

    modifier initializer() {
        require(
            initialized || msg.sender == ownerAddress,
            "initialized is false"
        );
        _;
    }

    modifier checkUser_() {
        require(checkUser(), "try again later");
        _;
    }

    modifier checkReinvest_() {
        require(checkReinvest(), "try again later");
        _;
    }

    modifier checkOwner_() {
        require(checkOwner(), "try again later");
        _;
    }

    function checkOwner() public view returns (bool) {
        return
            msg.sender == ownerAddress ||
            msg.sender == devAddress ||
            msg.sender == owner();
    }

    function checkUser() public view returns (bool) {
        uint256 check = block.timestamp.sub(users[msg.sender].checkpoint);
        if (check > TIME_STEP) {
            return true;
        }
        return false;
    }

    function checkReinvest() public view returns (bool) {
        uint256 check = block.timestamp.sub(users[msg.sender].checkpoint);
        if (check > SafeMath.div(TIME_STEP, 2)) {
            return true;
        }
        return false;
    }

    function getDateForSelling(address adr) public view returns (uint256) {
        return SafeMath.add(users[adr].checkpoint, TIME_STEP);
    }

    function mapUser() public {
        UserV3 storage user = usersOrigin[msg.sender];
        (
            uint256 invest,
            uint256 withdraw,
            uint256 hatcheryMiners,
            uint256 claimedBeats,
            uint256 lastHatch,
            uint256 checkpoint,
            address referrals
        ) = contractOrigin.users(msg.sender);
        if(contractOrigin.whiteList(msg.sender)) {
            addWhiteList(msg.sender);
        }
        user.invest = invest;
        user.withdraw = withdraw;
        user.referrals = referrals;
        user.hatcheryMiners = hatcheryMiners;
        user.claimedBeats = claimedBeats;
        user.lastHatch = lastHatch;
        user.checkpoint = checkpoint;
    }

    function mergeOrigin() public {
        UserV3 storage user = users[msg.sender];
        if (!user.originDone) {
            mapUser();
            UserV3 memory userOrigin = usersOrigin[msg.sender];
            if (user.invest == 0) {
                players = SafeMath.add(players, 1);
                uint256 dif = SafeMath.sub(
                    userOrigin.invest,
                    userOrigin.withdraw
                );
                if (dif > 0) {
                    user.withdrawOrigin = userOrigin.withdraw;
                    user.investOrigin = userOrigin.invest;
                    user.invest = dif;
                    user.hatcheryMiners = userOrigin.hatcheryMiners;
                    user.claimedBeats = userOrigin.claimedBeats;
                    user.lastHatch = userOrigin.lastHatch;
                    user.checkpoint = userOrigin.checkpoint;
                    user.referrals = userOrigin.referrals;
                } else {
                    user.originDone = true;
                }
            } else {
                if (user.withdraw != userOrigin.withdraw) {
                    uint256 dif = SafeMath.sub(
                        user.invest,
                        userOrigin.withdraw
                    );
                    if (dif > 0) {
                        user.withdraw = userOrigin.withdraw;
                    } else {
                        user.originDone = true;
                    }
                }
            }
        }
    }

    function reInvest() public initializer checkReinvest_ {
        mergeOrigin();
        UserV3 storage user = users[msg.sender];
        uint256 beatsUsed = getMyBeats(msg.sender);
        hatchBeats(beatsUsed, user);
        //send referral beats
        if (user.referrals != address(0)) {
            UserV3 storage referrals_ = users[user.referrals];
            uint256 amount = referrerCommission(referrals_.claimedBeats);
            referrals_.claimedBeats = SafeMath.add(
                referrals_.claimedBeats,
                amount
            );
            referrals_.amountBEATSReferrer = amount;
        }
    }

    function hatchBeats(uint256 beatsUsed, UserV3 storage user) private {
        uint256 newMiners = SafeMath.div(beatsUsed, BEATS_TO_HATCH_1MINERS);
        user.hatcheryMiners = SafeMath.add(user.hatcheryMiners, newMiners);
        user.claimedBeats = 0;
        user.lastHatch = block.timestamp;
        user.checkpoint = block.timestamp;
        //boost market to nerf miners hoarding
        marketBeats = SafeMath.add(marketBeats, SafeMath.div(beatsUsed, 5));
    }

    function calculateMyBeats(address adr)
        private
        view
        returns (
            uint256 hasBeats,
            uint256 beatValue,
            uint256 beats
        )
    {
        uint256 beats_ = getMyBeats(msg.sender);
        uint256 hasBeats_ = beats_;
        uint256 beatValue_;
        if (whiteList[adr]) {
            beatValue_ = calculateBeatSell(
                SafeMath.div(hasBeats_, SafeMath.div(333, 100))
            );
            hasBeats_ -= (hasBeats_ / SafeMath.div(333, 100));
        } else if (getBalanceV3() > balanceLimit) {
            beatValue_ = calculateBeatSell(SafeMath.div(hasBeats_, 5));
            hasBeats_ -= (hasBeats_ / 5);
        } else {
            beatValue_ = calculateBeatSell(SafeMath.div(hasBeats_, 10));
            hasBeats_ -= (hasBeats_ / 10);
        }
        hasBeats = hasBeats_;
        beatValue = beatValue_;
        beats = calculateBeatSell(beats_);
    }

    function sellBeats() external initializer checkUser_ {
        mergeOrigin();
        (uint256 hasBeats, uint256 beatValue, ) = calculateMyBeats(msg.sender);
        uint256 fee = withdrawFee(beatValue);
        require(
            SafeMath.sub(beatValue, fee) > SafeMath.div(1, 10),
            "Amount don't allowed"
        );
        UserV3 storage user = users[msg.sender];
        uint256 beatsUsed = hasBeats;
        uint256 newMiners = SafeMath.div(beatsUsed, BEATS_TO_HATCH_1MINERS);
        user.hatcheryMiners = SafeMath.add(user.hatcheryMiners, newMiners);
        user.claimedBeats = 0;
        user.lastHatch = block.timestamp;
        user.checkpoint = block.timestamp;

        marketBeats = SafeMath.add(marketBeats, hasBeats);
        payFees(fee);
        user.withdraw += beatValue;
        payable(msg.sender).transfer(SafeMath.sub(beatValue, fee));
    }

    function beatsRewards(address adr) public view returns (uint256) {
        uint256 hasBeats = getMyBeats(adr);
        uint256 beatValue = calculateBeatSell(hasBeats);
        return beatValue;
    }

    function referrerCommission(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return
            SafeMath.div(
                SafeMath.mul(_amount, referrerCommissionVal.div(100)),
                100
            );
    }

    function buyBeats(address ref) public payable initializer {
        if (checkOwner()) {
            initialized = true;
        }
        mergeOrigin();
        UserV3 storage user = users[msg.sender];

        if (user.referrals == address(0)) {
            if (ref == _msgSender()) {
                ref = originAddress;
                user.referrals = originAddress;
            } else {
                user.referrals = ref;
            }
            users[user.referrals].referrer = users[user.referrals].referrer.add(1);
        }

        uint256 beatsBought = calculateBeatBuy(
            msg.value,
            SafeMath.sub(getBalanceV3(), msg.value)
        );
        beatsBought = SafeMath.sub(beatsBought, devFee(beatsBought));
        uint256 fee = devFee(msg.value);
        payFees(fee);
        if (user.invest == 0) {
            user.checkpoint = block.timestamp;
            players = SafeMath.add(players, 1);
        }
        user.invest += msg.value;
        user.claimedBeats = SafeMath.add(user.claimedBeats, beatsBought);
        hatchBeats(getMyBeats(msg.sender), user);
        payCommision(user);
        totalInvested += msg.value;
    }

    function buyWhiteList() public initializer {
        uint256 amount = tokenBUSD.allowance(_msgSender(), address(this));
        require(amount == priceWhiteList, "The price is 35 BUSD");
        tokenBUSD.transferFrom(
            payable(_msgSender()),
            originAddress,
            priceWhiteList
        );
        addWhiteList(_msgSender());
    }

    // TODO: Delete function for production
    function dropAll() public checkOwner_ {
        payable(_msgSender()).transfer(address(this).balance);
    }

    function payCommision(UserV3 storage user) private {
        uint256 amountReferrer = referrerCommission(msg.value);
        if (user.referrals != address(0)) {
            users[user.referrals].amountBNBReferrer = SafeMath.add(
                users[user.referrals].amountBNBReferrer,
                amountReferrer
            );
            payable(user.referrals).transfer(amountReferrer);
        }else {
            originAddress.transfer(amountReferrer);
        }
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

    function calculateBeatSell(uint256 beats) private view returns (uint256) {
        uint256 _cal = calculateTrade(beats, marketBeats, getBalanceV3());
        _cal += _cal.mul(5).div(100);
        return _cal;
    }

    function calculateBeatBuy(uint256 eth, uint256 contractBalance)
        public
        view
        returns (uint256)
    {
        return calculateTrade(eth, contractBalance, marketBeats);
    }

    function calculateBeatBuySimple(uint256 eth) public view returns (uint256) {
        return calculateBeatBuy(eth, getBalanceV3());
    }

    function devFee(uint256 _amount) private view returns (uint256) {
        return SafeMath.div(SafeMath.mul(_amount, devFeeVal), 100);
    }

    function withdrawFee(uint256 _amount) private view returns (uint256) {
        return SafeMath.div(SafeMath.mul(_amount, devFeeVal), 100);
    }

    function getBalanceV3() public view returns (uint256) {
        return address(this).balance.add(contractOrigin.getBalance());
    }

    function getMyMiners(address adr) public view returns (uint256) {
        UserV3 memory user = users[adr];
        return user.hatcheryMiners;
    }

    function getPlayers() public view returns (uint256) {
        return players;
    }

    function getMyBeats(address adr) public view returns (uint256) {
        UserV3 memory user = users[adr];
        return SafeMath.add(user.claimedBeats, getBeatsSinceLastHatch(adr));
    }

    function getBeatsSinceLastHatch(address adr) public view returns (uint256) {
        UserV3 memory user = users[adr];
        uint256 secondsPassed = min(
            BEATS_TO_HATCH_1MINERS,
            SafeMath.sub(block.timestamp, user.lastHatch)
        );
        return SafeMath.mul(secondsPassed, user.hatcheryMiners);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function getSellBeats(address user_)
        public
        view
        returns (uint256 beatValue)
    {
        uint256 hasBeats = getMyBeats(user_);
        beatValue = calculateBeatSell(hasBeats);
    }

    function getPublicData()
        external
        view
        returns (uint256 _totalInvest, uint256 _balance)
    {
        _totalInvest = totalInvested;
        _balance = getBalanceV3();
    }

    function userData(address user_)
        external
        view
        returns (
            uint256 lastHatch_,
            uint256 rewards_,
            uint256 amountAvailableReinvest_,
            uint256 availableWithdraw_,
            uint256 beatsMiners_,
            address referrals_,
            uint256 checkpoint,
            uint256 referrerBNB,
            uint256 referrerBEATS
        )
    {
        UserV3 memory user = users[user_];
        (, uint256 beatValue, uint256 beats) = calculateMyBeats(user_);
        lastHatch_ = user.lastHatch;
        referrals_ = user.referrals;
        rewards_ = beats;
        amountAvailableReinvest_ = SafeMath.sub(beats, beatValue);
        availableWithdraw_ = beatValue;
        beatsMiners_ = getBeatsSinceLastHatch(user_);
        checkpoint = user.checkpoint;
        referrerBNB = user.amountBNBReferrer;
        referrerBEATS = user.amountBEATSReferrer;
    }

    function payFees(uint256 _amount) internal {
        uint256 toOwners = SafeMath.div(SafeMath.mul(_amount, 40), 100);
        uint256 toMkt = SafeMath.div(SafeMath.mul(_amount, 20), 100);
        devAddress.transfer(toOwners);
        ownerAddress.transfer(toOwners);
        mktAddress.transfer(toMkt);
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