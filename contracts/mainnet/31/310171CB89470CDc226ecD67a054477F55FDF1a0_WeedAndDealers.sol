/**
 *Submitted for verification at BscScan.com on 2022-04-12
*/

/*

                 (                  ) (       (                (        (    (     
 (  (            )\ )      (     ( /( )\ )    )\ )       (     )\ )     )\ ) )\ )  
 )\))(   '(   ( (()/(      )\    )\()|()/(   (()/(  (    )\   (()/( (  (()/((()/(  
((_)()\ ) )\  )\ /(_))  ((((_)( ((_)\ /(_))   /(_)) )\((((_)(  /(_)))\  /(_))/(_)) 
_(())\_)(|(_)((_|_))_    )\ _ )\ _((_|_))_   (_))_ ((_))\ _ )\(_)) ((_)(_)) (_))   
\ \((_)/ / __| __|   \   (_)_\(_) \| ||   \   |   \| __(_)_\(_) |  | __| _ \/ __|  
 \ \/\/ /| _|| _|| |) |   / _ \ | .` || |) |  | |) | _| / _ \ | |__| _||   /\__ \  
  \_/\_/ |___|___|___/   /_/ \_\|_|\_||___/   |___/|___/_/ \_\|____|___|_|_\|___/  
                                                                                                                                                            
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

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
    address public _marketing;
    address public _team;
    address public _web;
    address public _treasury;

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
        _marketing = 0xcAFcCA9d7B176275Dd8D54081347a906F2a1d25b;
        _team = 0xd0C849C5DA2BE10AAb1526E4F7330F6bb6C0558F;
        _web = 0x8C79bFCAB7dDfF3DEfA1c9C7EEd369fBaDB82424;
        _treasury = 0xb000e197e27065413da19087cb1C92648143B1c6;
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

contract WeedAndDealers is Context, Ownable {
    using SafeMath for uint256;

    uint256 private WEED_TO_SMOKE_1DEALERS = 1080000;
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private devFeeVal = 2;
    uint256 private marketingFeeVal = 2;
    uint256 private webFeeVal = 2;
    uint256 private teamFeeVal = 2;
    uint256 private treasuryFeeVal = 2;
    bool private initialized = false;
    address payable private recAdd;
    address payable private marketingAdd;
    address payable private teamAdd;
    address payable private webAdd;
    address payable private treasuryAdd;
    mapping(address => uint256) private weedDealers;
    mapping(address => uint256) private claimedWeed;
    mapping(address => uint256) private lastSmoke;
    mapping(address => address) private referrals;
    uint256 private marketWeed;

    constructor() {
        recAdd = payable(msg.sender);
        marketingAdd = payable(_marketing);
        teamAdd = payable(_team);
        webAdd = payable(_web);
        treasuryAdd = payable(_treasury);
    }

    function smokeWeed(address ref) public {
        require(initialized);

        if (ref == msg.sender) {
            ref = address(0);
        }

        if (
            referrals[msg.sender] == address(0) &&
            referrals[msg.sender] != msg.sender
        ) {
            referrals[msg.sender] = ref;
        }

        uint256 weedSmoked = getMyWeed(msg.sender);
        uint256 newDealers = SafeMath.div(weedSmoked, WEED_TO_SMOKE_1DEALERS);
        weedDealers[msg.sender] = SafeMath.add(
            weedDealers[msg.sender],
            newDealers
        );
        claimedWeed[msg.sender] = 0;
        lastSmoke[msg.sender] = block.timestamp;
        claimedWeed[referrals[msg.sender]] = SafeMath.add(
            claimedWeed[referrals[msg.sender]],
            SafeMath.div(weedSmoked, 8)
        );
        marketWeed = SafeMath.add(marketWeed, SafeMath.div(weedSmoked, 5));
    }

    function sellWeed() public {
        require(initialized);
        uint256 hasWeed = getMyWeed(msg.sender);
        uint256 weedValue = calculateWeedSell(hasWeed);
        uint256 fee1 = devFee(weedValue);
        uint256 fee2 = marketingFee(weedValue);
        uint256 fee3 = webFee(weedValue);
        uint256 fee4 = teamFee(weedValue);
        uint256 fee5 = treasuryFee(weedValue);
        claimedWeed[msg.sender] = 0;
        lastSmoke[msg.sender] = block.timestamp;
        marketWeed = SafeMath.add(marketWeed, hasWeed);
        recAdd.transfer(fee1);
        marketingAdd.transfer(fee2);
        teamAdd.transfer(fee3);
        webAdd.transfer(fee4);
        treasuryAdd.transfer(fee5);

        payable(msg.sender).transfer(SafeMath.sub(weedValue, fee1));
    }

    function weedRewards(address adr) public view returns (uint256) {
        uint256 hasWeed = getMyWeed(adr);
        uint256 weedValue = calculateWeedSell(hasWeed);
        return weedValue;
    }

    function buyWeed(address ref) public payable {
        require(initialized);
        uint256 weedBought = calculateWeedBuy(
            msg.value,
            SafeMath.sub(address(this).balance, msg.value)
        );
        weedBought = SafeMath.sub(weedBought, devFee(weedBought));
        weedBought = SafeMath.sub(weedBought, marketingFee(weedBought));
        weedBought = SafeMath.sub(weedBought, webFee(weedBought));
        weedBought = SafeMath.sub(weedBought, teamFee(weedBought));
        weedBought = SafeMath.sub(weedBought, treasuryFee(weedBought));

        uint256 fee1 = devFee(msg.value);
        uint256 fee2 = marketingFee(msg.value);
        uint256 fee3 = webFee(msg.value);
        uint256 fee4 = teamFee(msg.value);
        uint256 fee5 = treasuryFee(msg.value);
        recAdd.transfer(fee1);
        marketingAdd.transfer(fee2);
        teamAdd.transfer(fee3);
        webAdd.transfer(fee4);
        treasuryAdd.transfer(fee5);

        claimedWeed[msg.sender] = SafeMath.add(
            claimedWeed[msg.sender],
            weedBought
        );
        smokeWeed(ref);
    }

    function calculateTrade(
        uint256 rt,
        uint256 rs,
        uint256 bs
    ) private view returns (uint256) {
        return
            SafeMath.div(
                SafeMath.mul(PSN, bs),
                SafeMath.add(
                    PSNH,
                    SafeMath.div(
                        SafeMath.add(
                            SafeMath.mul(PSN, rs),
                            SafeMath.mul(PSNH, rt)
                        ),
                        rt
                    )
                )
            );
    }

    function calculateWeedSell(uint256 weed) public view returns (uint256) {
        return calculateTrade(weed, marketWeed, address(this).balance);
    }

    function calculateWeedBuy(uint256 eth, uint256 contractBalance)
        public
        view
        returns (uint256)
    {
        return calculateTrade(eth, contractBalance, marketWeed);
    }

    function calculateWeedBuySimple(uint256 eth) public view returns (uint256) {
        return calculateWeedBuy(eth, address(this).balance);
    }

    function devFee(uint256 amount) private view returns (uint256) {
        return SafeMath.div(SafeMath.mul(amount, devFeeVal), 100);
    }

    function marketingFee(uint256 amount) private view returns (uint256) {
        return SafeMath.div(SafeMath.mul(amount, marketingFeeVal), 100);
    }

    function webFee(uint256 amount) private view returns (uint256) {
        return SafeMath.div(SafeMath.mul(amount, webFeeVal), 100);
    }

    function teamFee(uint256 amount) private view returns (uint256) {
        return SafeMath.div(SafeMath.mul(amount, teamFeeVal), 100);
    }

    function treasuryFee(uint256 amount) private view returns (uint256) {
        return SafeMath.div(SafeMath.mul(amount, treasuryFeeVal), 100);
    }

    function openDealers() public payable onlyOwner {
        require(marketWeed == 0);
        initialized = true;
        marketWeed = 108000000000;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getMyDealers(address adr) public view returns (uint256) {
        return weedDealers[adr];
    }

    function getMyWeed(address adr) public view returns (uint256) {
        return SafeMath.add(claimedWeed[adr], getWeedSinceLastSmoke(adr));
    }

    function getWeedSinceLastSmoke(address adr) public view returns (uint256) {
        uint256 secondsPassed = min(
            WEED_TO_SMOKE_1DEALERS,
            SafeMath.sub(block.timestamp, lastSmoke[adr])
        );
        return SafeMath.mul(secondsPassed, weedDealers[adr]);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}