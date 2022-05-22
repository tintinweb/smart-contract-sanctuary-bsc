/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

/*  
██████╗ ███╗   ██╗██████╗ ███████╗ █████╗ ████████╗███████╗    ██╗██╗
██╔══██╗████╗  ██║██╔══██╗██╔════╝██╔══██╗╚══██╔══╝██╔════╝    ██║██║
██████╔╝██╔██╗ ██║██████╔╝█████╗  ███████║   ██║   ███████╗    ██║██║
██╔══██╗██║╚██╗██║██╔══██╗██╔══╝  ██╔══██║   ██║   ╚════██║    ██║██║
██████╔╝██║ ╚████║██████╔╝███████╗██║  ██║   ██║   ███████║    ██║██║
╚═════╝ ╚═╝  ╚═══╝╚═════╝ ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝    ╚═╝╚═╝ 
BNBeast Farm | earn money until 8% daily | Metaversing 
SPDX-License-Identifier: MIT
*/

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
pragma solidity 0.8.11;

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
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _msgSender());
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


contract BNBBeats is Context, Ownable {
    using SafeMath for uint256;

    uint256 private BEAST_TO_HATCH_1MINERS = 1080000;//for final version should be seconds in a day
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private marketingFeeValForBuy = 1;
    uint256 private devFeeValForBuy = 2;
    uint256 private feeValForSell = 3;
    bool private initialized = false;
    uint256 private DAYS_TO_SELL = 1 days;
    address payable private marketingWallet;
    address payable private devWallet;
    mapping (address => uint256) private hatcheryMiners;
    mapping (address => uint256) private claimedBeats;
    mapping (address => uint256) private lastHatch;
    mapping (address => uint256) private lastSelling;
    mapping (address => address) private referrals;
    uint256 private listeners;
    uint256 private marketBeats;
    
    constructor() {
        listeners = 0;
        marketingWallet = payable(0x0a61D672DB25cAc6bb653442A8360F6774DaD057);
        devWallet = payable(0x5FcCcbA0E1c826DCBdb3Ba59CEe5919ba4095eA4);
    }
    
    function hatchBeats(address ref) public {
        require(initialized);
        
        if(ref == msg.sender) {
            ref = address(0);
        }
        
        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
        }

        if(hatcheryMiners[msg.sender] == 0){
            listeners = listeners.add(1);
            lastSelling[msg.sender] = block.timestamp;
        }
        
        uint256 beatsUsed = getMyBeats(msg.sender);
        uint256 newMiners = SafeMath.div(beatsUsed,BEAST_TO_HATCH_1MINERS);
        hatcheryMiners[msg.sender] = SafeMath.add(hatcheryMiners[msg.sender],newMiners);
        claimedBeats[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;
        
        //send referral beats
        claimedBeats[referrals[msg.sender]] = SafeMath.add(claimedBeats[referrals[msg.sender]],SafeMath.div(beatsUsed,8));
        
        //boost market to nerf miners hoarding
        marketBeats=SafeMath.add(marketBeats,SafeMath.div(beatsUsed,5));
    }
    
    function sellBeats() public {
        require(initialized);
        require(validationSellBeats(_msgSender()), 'Only can seller every 24 hours');
        uint256 hasBeats = getMyBeats(msg.sender);
        uint256 beatsValue = calculateEggSell(hasBeats);
        uint256 fee = getAndPayFee(beatsValue,false);
        claimedBeats[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;
        lastSelling[msg.sender] = block.timestamp;
        marketBeats = SafeMath.add(marketBeats,hasBeats);
        payable (msg.sender).transfer(SafeMath.sub(beatsValue,fee));
    }

    function validationSellBeats(address wallet) private view returns(bool) {
        if(lastSelling[wallet].add(DAYS_TO_SELL) >= block.timestamp) {
            return wallet == owner() || wallet == marketingWallet || wallet == devWallet;
        }else {
            return true;
        }
    }
    
    function beatsRewards(address adr) public view returns(uint256) {
        uint256 hasBeats = getMyBeats(adr);
        uint256 eggValue = calculateEggSell(hasBeats);
        return eggValue;
    }
    
    function buyBeats(address ref) public payable {
        require(initialized);
        uint256 beatsBought = calculateEggBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
        uint256 fee = getAndPayFee(msg.value, true);
        beatsBought = SafeMath.sub(beatsBought,fee);
        claimedBeats[msg.sender] = SafeMath.add(claimedBeats[msg.sender],beatsBought);
        hatchBeats(ref);
    }
    
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    
    function calculateEggSell(uint256 beats) public view returns(uint256) {
        return calculateTrade(beats,marketBeats,address(this).balance);
    }
    
    function calculateEggBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketBeats);
    }
    
    function calculateEggBuySimple(uint256 eth) public view returns(uint256) {
        return calculateEggBuy(eth,address(this).balance);
    }
    
    function seedMarket() public payable onlyOwner {
        require(marketBeats == 0);
        initialized = true;
        marketBeats = 108000000000;
    }

    function setMarketing(address payable wallet) public onlyOwner {
        marketingWallet = wallet;
    }
    
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function getListeners() public view returns(uint256) {
        return listeners;
    }

    function getDaysForSell(address adr) public view returns (uint256) {
        return lastSelling[adr].add(DAYS_TO_SELL);
    }
    
    function getMyMiners(address adr) public view returns(uint256) {
        return hatcheryMiners[adr];
    }
    
    function getMyBeats(address adr) public view returns(uint256) {
        return SafeMath.add(claimedBeats[adr],getBeatsSinceLastHatch(adr));
    }
    
    function getBeatsSinceLastHatch(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(BEAST_TO_HATCH_1MINERS,SafeMath.sub(block.timestamp,lastHatch[adr]));
        return SafeMath.mul(secondsPassed,hatcheryMiners[adr]);
    }

    function getAndPayFee(uint256 amount, bool isBuy) private returns(uint256){
        uint256 devFeeCalculated = SafeMath.div(SafeMath.mul(amount, devFeeValForBuy),100);
        uint256 marketingFeeCalculated = SafeMath.div(SafeMath.mul(amount, marketingFeeValForBuy),100);
        uint256 feeCalculatedForSell = SafeMath.div(SafeMath.mul(amount, feeValForSell),100);
        payable(devWallet).transfer(isBuy ? devFeeCalculated : SafeMath.div(feeCalculatedForSell,2));
        payable(marketingWallet).transfer(isBuy ? marketingFeeCalculated : SafeMath.div(feeCalculatedForSell,2));
        return isBuy ? SafeMath.add(devFeeCalculated, marketingFeeCalculated) : feeCalculatedForSell;
    }
    
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}