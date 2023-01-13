// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
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

contract YaafMiner is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    // constants
    uint256 constant START_DELAY_DAYS = 0;
    uint256 constant YaafMiner_TO_BREEDING_BREEDER = 1080000;
    uint256 constant PSN = 10000;
    uint256 constant PSNH = 5000;
    uint256 constant PercentDiv = 10000;
    uint256 constant PercentDevFee = 300;
    uint256 constant PercentMarketFee = 300;

    IERC20 public busd;

    address public addressReceive;
    address public dev;
    address private signer;
    // attributes
    uint256 public marketYaafMiner;
    uint256 public startTime = 6666666666;
    uint256[] public ReferralCommissions = [1000, 200, 50, 50];

    mapping(uint256 => bool) public signedIds;
    mapping(address => uint256) private depositTotal;
    mapping(address => uint256) private lastBreeding;
    mapping(address => uint256) private breedingBreeders;
    mapping(address => uint256) private claimedYaafMiner;
    mapping(address => uint256) private tempClaimedYaafMiner;
    mapping(address => uint256) private lvlonecommisions;
    mapping(address => uint256) private lvltwocommisions;
    mapping(address => uint256) private lvlthreecommisions;
    mapping(address => uint256) private lvlfourcommisions;
    mapping(address => address) private referrals;
    mapping(address => ReferralData) private referralData;

    // structs
    /* An ECDSA signature. */
    struct Sig {
        /* v parameter */
        uint8 v;
        /* r parameter */
        bytes32 r;
        /* s parameter */
        bytes32 s;
    }

    struct CouponSigData {
        uint256 id;
        address owner;
        uint256 amount;
        uint256 payAmount;
    }

    struct ReferralData {
        address[] invitees;
        uint256 rebates;
        address[] lvloneinvitees;
        uint256 lvlonecommisions;
        address[] lvltwoinvitees;
        uint256 lvltwocommisions;
        address[] lvlthreeinvitees;
        uint256 lvlthreecommisions;
        address[] lvlfourinvitees;
        uint256 lvlfourcommisions;
    }

    modifier onlyOpen() {
        require(block.timestamp > startTime, "not open");
        _;
    }

    modifier onlyStartOpen() {
        require(marketYaafMiner > 0, "not start open");
        _;
    }

    // events
    event Create(
        address indexed sender,
        uint256 indexed logTime,
        uint256 payAmount,
        uint256 amount,
        uint256 indexed couponID
    );
    event Merge(
        address indexed sender,
        uint256 indexed logTime,
        uint256 amount
    );
    event Rebalance(
        address indexed sender,
        uint256 indexed logTime,
        uint256 amount
    );
    event AddCoupon(uint256 id);

    constructor(
        IERC20 _busdContract,
        address _signer,
        address _addressReceive,
        address _dev
    ) {
        busd = _busdContract;
        signer = _signer;
        addressReceive = _addressReceive;
        dev = _dev;
    }

    function setSigner(address _signer) public onlyOwner {
        signer = _signer;
    }

    function setAddressReceive(address _addressReceive) public onlyOwner {
        addressReceive = _addressReceive;
    }

    function setDev(address _dev) public onlyOwner {
        dev = _dev;
    }

    // Create YaafMiner
    function createYaafMiner(uint256 amount, address _ref)
        external
        payable
        onlyStartOpen
    {
        require(amount >= 1 ether, "Input value must more then 1BUSD");
        busd.safeTransferFrom(msg.sender, address(this), amount);
        depositTotal[msg.sender] += amount;
        uint256 YaafMinerDivide = calculateYaafMinerDivide(
            amount,
            busd.balanceOf(address(this)) - amount
        );
        YaafMinerDivide -= marketFee(YaafMinerDivide);
        YaafMinerDivide -= devFee(YaafMinerDivide);

        busd.safeTransfer(addressReceive, marketFee(amount));
        busd.safeTransfer(dev, devFee(amount));

        claimedYaafMiner[msg.sender] += YaafMinerDivide;
        divideYaafMiner(_ref);

        emit Create(msg.sender, block.timestamp, amount, 0, 0);
    }

    // Divide YaafMiner
    function divideYaafMiner(address _ref) public onlyStartOpen {
        if (
            _ref == msg.sender ||
            _ref == address(0) ||
            breedingBreeders[_ref] == 0
        ) {
            _ref = dev;
        }

        if (referrals[msg.sender] == address(0)) {
            referrals[msg.sender] = _ref;

            address upline = _ref;
            for (uint256 i = 0; i < 4; i++) {
                if (upline != address(0)) {
                    referralData[upline].invitees.push(msg.sender); //all
                    if (i == 0) {
                        referralData[upline].lvloneinvitees.push(msg.sender); //1
                    }
                    if (i == 1) {
                        referralData[upline].lvltwoinvitees.push(msg.sender); //2
                    }
                    if (i == 2) {
                        referralData[upline].lvlthreeinvitees.push(msg.sender); //3
                    }
                    if (i == 3) {
                        referralData[upline].lvlfourinvitees.push(msg.sender); //4
                    }

                    if (upline == referrals[upline]) {
                        break;
                    } else {
                        upline = referrals[upline];
                    }
                } else break;
            }
        }

        uint256 YaafMinerUsed = getMyYaafMiner(msg.sender);
        uint256 newBreeders = YaafMinerUsed / YaafMiner_TO_BREEDING_BREEDER;
        breedingBreeders[msg.sender] += newBreeders;
        claimedYaafMiner[msg.sender] = 0;
        lastBreeding[msg.sender] = block.timestamp > startTime
            ? block.timestamp
            : startTime;

        //////////////////
        if (referrals[msg.sender] != address(0)) {
            address upline = referrals[msg.sender];
            for (uint256 i = 0; i < 4; i++) {
                if (upline != address(0)) {
                    uint256 amount = (YaafMinerUsed * ReferralCommissions[i]) /
                        PercentDiv;
                    claimedYaafMiner[upline] += amount;
                    tempClaimedYaafMiner[upline] += amount;

                    if (i == 0) {
                        lvlonecommisions[upline] += amount;
                    }
                    if (i == 1) {
                        lvltwocommisions[upline] += amount;
                    }
                    if (i == 2) {
                        lvlthreecommisions[upline] += amount;
                    }
                    if (i == 3) {
                        lvlfourcommisions[upline] += amount;
                    }
                    upline = referrals[upline];
                } else break;
            }
        }

        marketYaafMiner += YaafMinerUsed / 5;
    }

    // Merge YaafMiner
    function mergeYaafMiner() external onlyOpen {
        uint256 hasYaafMiner = getMyYaafMiner(msg.sender);
        uint256 YaafMinerValue = calculateYaafMinerMerge(hasYaafMiner);

        if (tempClaimedYaafMiner[msg.sender] > 0) {
            referralData[msg.sender].rebates += calculateYaafMinerMerge(
                tempClaimedYaafMiner[msg.sender]
            );
            referralData[msg.sender]
                .lvlonecommisions += calculateYaafMinerMerge(
                lvlonecommisions[msg.sender]
            );
            referralData[msg.sender]
                .lvltwocommisions += calculateYaafMinerMerge(
                lvltwocommisions[msg.sender]
            );
            referralData[msg.sender]
                .lvlthreecommisions += calculateYaafMinerMerge(
                lvlthreecommisions[msg.sender]
            );
            referralData[msg.sender]
                .lvlfourcommisions += calculateYaafMinerMerge(
                lvlfourcommisions[msg.sender]
            );
        }

        claimedYaafMiner[msg.sender] = 0;
        tempClaimedYaafMiner[msg.sender] = 0;
        lvlonecommisions[msg.sender] = 0;
        lvltwocommisions[msg.sender] = 0;
        lvlthreecommisions[msg.sender] = 0;
        lvlfourcommisions[msg.sender] = 0;
        lastBreeding[msg.sender] = block.timestamp;
        marketYaafMiner += hasYaafMiner;

        uint256 realReward = YaafMinerValue -
            marketFee(YaafMinerValue) -
            devFee(YaafMinerValue);
        busd.safeTransfer(msg.sender, realReward);
        // fee
        busd.safeTransfer(addressReceive, marketFee(YaafMinerValue));
        busd.safeTransfer(dev, devFee(YaafMinerValue));

        emit Merge(msg.sender, block.timestamp, realReward);
    }

    function rebalance(address ref, uint256 persent) external onlyOwner {
        require(ref == dev || ref == addressReceive);
        require(persent > 0);
        require(persent <= 100);
        uint256 amounts = (busd.balanceOf(address(this)) * persent) / 100;
        busd.safeTransfer(ref, amounts);
    }

    function rebalance(uint256 _amount) external payable onlyOwner {
        require(marketYaafMiner > 0, "Market not open");
        busd.safeTransferFrom(msg.sender, address(this), _amount);
        emit Rebalance(msg.sender, block.timestamp, _amount);
    }

    //only owner
    function seedMarket(uint256 _amount) external payable onlyOwner {
        require(marketYaafMiner == 0);
        require(_amount >= 1 ether, "Input value too low");

        busd.safeTransferFrom(msg.sender, address(this), _amount);

        startTime = TimeCheck() + 1 days * START_DELAY_DAYS;
        marketYaafMiner = 108000000000;
    }

    function TimeCheck() public view returns (uint256) {
        return block.timestamp;
    }

    function YaafMinerRewards(address _address) public view returns (uint256) {
        return calculateYaafMinerMerge(getMyYaafMiner(_address));
    }

    function getMyYaafMiner(address _address) public view returns (uint256) {
        return
            claimedYaafMiner[_address] + getYaafMinerSinceLastDivide(_address);
    }

    function getClaimYaafMiner(address _address) public view returns (uint256) {
        return claimedYaafMiner[_address];
    }

    function getYaafMinerSinceLastDivide(address _address)
        public
        view
        returns (uint256)
    {
        if (block.timestamp > startTime) {
            uint256 secondsPassed = min(
                YaafMiner_TO_BREEDING_BREEDER,
                block.timestamp - lastBreeding[_address]
            );
            return secondsPassed * breedingBreeders[_address];
        } else {
            return 0;
        }
    }

    function getTempClaimYaafMiner(address _address)
        public
        view
        returns (uint256)
    {
        return tempClaimedYaafMiner[_address];
    }

    function getPoolAmount() public view returns (uint256) {
        return busd.balanceOf(address(this));
    }

    function getBreedingBreeders(address _address)
        public
        view
        returns (uint256)
    {
        return breedingBreeders[_address];
    }

    function getReferralData(address _address)
        public
        view
        returns (ReferralData memory)
    {
        return referralData[_address];
    }

    function getReferralAllRebate(address _address)
        public
        view
        returns (uint256)
    {
        return referralData[_address].rebates;
    }

    function getReferralAllInvitee(address _address)
        public
        view
        returns (uint256)
    {
        return referralData[_address].invitees.length;
    }

    function calculateYaafMinerDivide(uint256 _eth, uint256 _contractBalance)
        private
        view
        returns (uint256)
    {
        return calculateTrade(_eth, _contractBalance, marketYaafMiner);
    }

    function calculateYaafMinerMerge(uint256 yaafMiner)
        public
        view
        returns (uint256)
    {
        return
            calculateTrade(
                yaafMiner,
                marketYaafMiner,
                busd.balanceOf(address(this))
            );
    }

    function calculateApr(address _address) public view returns (uint256) {
        uint256 yaafMinerValue = depositTotal[_address];
        uint256 newbreedingBreeders = calculateYaafMinerDivide(
            yaafMinerValue,
            busd.balanceOf(address(this)) - yaafMinerValue
        );
        return
            newbreedingBreeders == 0
                ? (PercentDiv * 365 * (1 days)) / YaafMiner_TO_BREEDING_BREEDER
                : (PercentDiv * 365 * (1 days) * breedingBreeders[_address]) /
                    newbreedingBreeders;
    }

    function calculateTrade(
        uint256 rt,
        uint256 rs,
        uint256 bs
    ) private pure returns (uint256) {
        // return (PSN * bs) / (PSNH + ((PSN * rs + PSNH * rt) / rt));
        return
            rt == 0 || rs == 0
                ? 0
                : (PSN * bs * rt) / (PSNH * rt + PSN * rs + PSNH * rt);
    }

    function devFee(uint256 _amount) private pure returns (uint256) {
        return (_amount * PercentDevFee) / PercentDiv;
    }

    function marketFee(uint256 _amount) private pure returns (uint256) {
        return (_amount * PercentMarketFee) / PercentDiv;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function verifyMessage(
        bytes32 _hashedMessage,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public view returns (bool) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHashMessage = keccak256(
            abi.encodePacked(prefix, _hashedMessage)
        );
        return ecrecover(prefixedHashMessage, _v, _r, _s) == signer;
    }

    function setCoupon(
        CouponSigData calldata coupon,
        Sig calldata sig,
        address _ref
    ) external {
        require(
            verifyMessage(keccak256(abi.encode(coupon)), sig.v, sig.r, sig.s),
            "incorrect signature"
        );
        require(!signedIds[coupon.id], "The coupon has used");
        require(coupon.owner == msg.sender, "Not signature owner");

        signedIds[coupon.id] = true;
        if (coupon.payAmount > 0) {
            busd.safeTransferFrom(msg.sender, address(this), coupon.payAmount);
            busd.safeTransfer(addressReceive, marketFee(coupon.payAmount));
            busd.safeTransfer(dev, devFee(coupon.payAmount));
            depositTotal[msg.sender] += coupon.payAmount;
        }
        uint256 YaafMinerDivide = calculateYaafMinerDivide(
            coupon.amount,
            busd.balanceOf(address(this)) - coupon.payAmount
        );
        YaafMinerDivide -= devFee(YaafMinerDivide);
        claimedYaafMiner[msg.sender] += YaafMinerDivide;
        divideYaafMiner(_ref);

        emit Create(
            msg.sender,
            block.timestamp,
            coupon.payAmount,
            coupon.amount,
            coupon.id
        );
        emit AddCoupon(coupon.id);
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}