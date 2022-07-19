/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

// SPDX-License-Identifier: MIT

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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

pragma solidity 0.8.9;

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
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
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }
}

contract LuckyBNBMiner is Context, Ownable {
    event SetLuckyWinner(address indexed adr);

    using SafeMath for uint256;

    uint256 private LEAFS_TO_HATCH_1_MINER = 1080000;//for final version should be seconds in a day
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private luckyFeeValue = 5;
    uint256 private referalValue = 8;
    bool private initialized = false;
    address payable private luckyWallet;
    mapping (address => uint256) private plantations;
    mapping (address => uint256) private claimedLeafs;
    mapping (address => uint256) private lastReplant;
    mapping (address => uint256) private boughtAmount;
    mapping (address => uint256) private tiers;
    address[] private possibleLuckyWinners;
    mapping (address => address) private referrals;
    uint256 private marketSeeds;

    constructor() {
        luckyWallet = payable(msg.sender);
    }

    // Buy new Leafs
    function buyLeafs(address ref) public payable {
        require(initialized);

        // Calculate the amount of Leafs bought
        uint256 leafsBought = calculateLeafsBuy(msg.value, SafeMath.sub(address(this).balance, msg.value));
        // Substract the luckyFee from the Leafs
        leafsBought = SafeMath.sub(leafsBought, luckyFee(leafsBought));
        // Calculate the fee for the Lucky wallet
        uint256 fee = luckyFee(msg.value);
        // Transfer fee to lucky wallet
        luckyWallet.transfer(fee);

        // Update boughtAmount by adding value to total and setting boughtTier1 to true
        boughtAmount[msg.sender] = SafeMath.add(boughtAmount[msg.sender], msg.value);

        if(tiers[msg.sender] != 3){
            // Only add to possibleLuckWinners if bought amount is > .1 bnb and not already in lucky winner
            if(tiers[msg.sender] == 0 && boughtAmount[msg.sender] >= .1 ether){
                possibleLuckyWinners.push(msg.sender);
                tiers[msg.sender] = 1;
            }

            // Set tiers to next tier
            if(tiers[msg.sender] == 1 && boughtAmount[msg.sender] >= .5 ether){
                tiers[msg.sender] = 2;
            }

            // Set tiers to next tier
            if(tiers[msg.sender] == 2 && boughtAmount[msg.sender] >= 1 ether){
                tiers[msg.sender] = 3;
            }
        }

        // Update claimedLeafs with newly bought Leafs
        claimedLeafs[msg.sender] = SafeMath.add(claimedLeafs[msg.sender], leafsBought);
        // Remine for new Leafs
        replant(ref);
    }

    // Replant
    function replant(address ref) public {
        require(initialized);

        // Sender cannot be same as referer
        if(ref == msg.sender) {
            ref = address(0);
        }

        // Only change referral address if not 0 address and not sender = referral
        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
        }

        // Get sender current Leafs
        uint256 leafsUsed = getMyLeafs(msg.sender);
        // Calculate new seeds
        uint256 newSeeds = SafeMath.div(leafsUsed, LEAFS_TO_HATCH_1_MINER);
        // Append plantations
        plantations[msg.sender] = SafeMath.add(plantations[msg.sender], newSeeds);
        // Reset claimedLeafs
        claimedLeafs[msg.sender] = 0;
        // Update last Remine
        lastReplant[msg.sender] = block.timestamp;
        // Send referral leafs
        claimedLeafs[referrals[msg.sender]] = SafeMath.add(claimedLeafs[referrals[msg.sender]], SafeMath.div(leafsUsed, referalValue));
        // Boost market to nerf miners hoarding
        marketSeeds = SafeMath.add(marketSeeds, SafeMath.div(leafsUsed, 5));
    }

    // Sell Leafs
    function sellLeafs() public {
        require(initialized);

        // Get sender current Leafs
        uint256 hasLeafs = getMyLeafs(msg.sender);
        // Calculate the value
        uint256 leafsValue = calculateLeafsSell(hasLeafs);
        // Calculate lucky fee
        uint256 fee = luckyFee(leafsValue);
        // Reset claimedLeafs
        claimedLeafs[msg.sender] = 0;
        // Update last Remine
        lastReplant[msg.sender] = block.timestamp;
        // Boost market to nerf miners hoarding
        marketSeeds = SafeMath.add(marketSeeds,hasLeafs);
        // Transfer a lucky fee to the luckyWallet
        luckyWallet.transfer(fee);
        // Transfer amount of BNB to sender
        payable (msg.sender).transfer(SafeMath.sub(leafsValue, fee));
    }

    // Calculate the rewards and show sender
    function leafRewards(address adr) public view returns(uint256) {
        // Get sender current Leafs
        uint256 hasLeafs = getMyLeafs(adr);
        // Calculate the value
        uint256 leafsValue = calculateLeafsSell(hasLeafs);
        return leafsValue;
    }

    // Calculate the trade
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN,bs), SafeMath.add(PSNH, SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs), SafeMath.mul(PSNH,rt)), rt)));
    }

    // Calculate a sell
    function calculateLeafsSell(uint256 leafs) public view returns(uint256) {
        return calculateTrade(leafs, marketSeeds, address(this).balance);
    }

    // Calculate a buy
    function calculateLeafsBuy(uint256 eth, uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth, contractBalance, marketSeeds);
    }

    // Calculate a simple buy
    function calculateLeafsBuySimple(uint256 eth) public view returns(uint256) {
        return calculateLeafsBuy(eth,address(this).balance);
    }

    // calculate a lucky fee
    function luckyFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount, luckyFeeValue),100);
    }

    // Get the current balance
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    // Get my miners
    function getMyPlantations(address adr) public view returns(uint256) {
        return plantations[adr];
    }

    // Get my Leafs
    function getMyLeafs(address adr) public view returns(uint256) {
        return SafeMath.add(claimedLeafs[adr], getLeafsSinceReplant(adr));
    }

    // Get my Leafs
    function getMyTier(address adr) public view returns(uint256) {
        return tiers[adr];
    }

    // Get my Leafs Since remine
    function getLeafsSinceReplant(address adr) public view returns(uint256) {
        uint256 secondsPassed = min(LEAFS_TO_HATCH_1_MINER, SafeMath.sub(block.timestamp,lastReplant[adr]));
        return SafeMath.mul(secondsPassed, plantations[adr]);
    }

    // min
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    // Seed the market
    function seedMarket() public payable onlyOwner {
        require(marketSeeds == 0);
        initialized = true;
        marketSeeds = 108000000000;
    }

    // Set a new lucky wallet
    function setLuckyWallet(address adr) public onlyOwner {
        require(initialized);
        emit SetLuckyWinner(adr);
        luckyWallet = payable(adr);
    }

    // Set a new lucky wallet
    function setLuckyWalletToDev() public onlyOwner {
        luckyWallet = payable(owner());
    }

    // Get all the lucky winners
    function getLuckyWinners() onlyOwner public view returns(address[] memory, uint256[] memory){
        uint256[] memory luckyWinnersTiers;
        address[] memory luckyWinnersAddresses;

        for (uint i = 0; i < possibleLuckyWinners.length; i++) {
            luckyWinnersAddresses[i] = possibleLuckyWinners[i];
            luckyWinnersTiers[i] = tiers[possibleLuckyWinners[i]];
        }
        return (luckyWinnersAddresses, luckyWinnersTiers);
    }
}