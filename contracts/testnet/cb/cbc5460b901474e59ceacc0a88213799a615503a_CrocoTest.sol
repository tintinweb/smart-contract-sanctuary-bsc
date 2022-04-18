/**
 *Submitted for verification at BscScan.com on 2022-04-18
*/

/**
 *Submitted for verification at BscScan.com on 2021-11-06
*/

// SPDX-License-Identifier: MIT

/*
    ,---,.                   ,-.                                  ,---,.                                                       
  ,'  .'  \              ,--/ /|                 ,---,          ,'  .'  \                                                      
,---.' .' |            ,--. :/ |               ,---.'|        ,---.' .' |                             ,---,                    
|   |  |: |            :  : ' /                |   | :        |   |  |: |                         ,-+-. /  | .--.--.           
:   :  :  /  ,--.--.   |  '  /      ,---.      |   | |        :   :  :  /   ,---.     ,--.--.    ,--.'|'   |/  /    '          
:   |    ;  /       \  '  |  :     /     \   ,--.__| |        :   |    ;   /     \   /       \  |   |  ,"' |  :  /`./          
|   :     \.--.  .-. | |  |   \   /    /  | /   ,'   |        |   :     \ /    /  | .--.  .-. | |   | /  | |  :  ;_            
|   |   . | \__\/: . . '  : |. \ .    ' / |.   '  /  |        |   |   . |.    ' / |  \__\/: . . |   | |  | |\  \    `.         
'   :  '; | ," .--.; | |  | ' \ \'   ;   /|'   ; |:  |        '   :  '; |'   ;   /|  ," .--.; | |   | |  |/  `----.   \        
|   |  | ; /  /  ,.  | '  : |--' '   |  / ||   | '/  '        |   |  | ; '   |  / | /  /  ,.  | |   | |--'  /  /`--'  /        
|   :   / ;  :   .'   \;  |,'    |   :    ||   :    :|        |   :   /  |   :    |;  :   .'   \|   |/     '--'.     /         
|   | ,'  |  ,     .-./'--'       \   \  /  \   \  /          |   | ,'    \   \  / |  ,     .-./'---'        `--'---'          
`----'     `--`---'                `----'    `----'           `----'       `----'   `--`---'                                   
Baked Beans - BSC BNB Miner
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

contract CrocoTest is Context, Ownable {
    using SafeMath for uint256;

    uint256 private TREATS_REQ_PER_DOG = 1080000;//for final version should be seconds in a day
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private devFeeVal = 3;
    bool private initialized = false;
    address payable private recAdd;
    mapping (address => uint256) private dogs;
    mapping (address => uint256) private claimedTreats;
    mapping (address => uint256) private lastTrained;
    mapping (address => address) private referrals;
    uint256 private marketTreats;
    
    constructor() {
        recAdd = payable(msg.sender);
    }
    
    function trainDogs(address ref) public {
        require(initialized);
        
        if(ref == msg.sender) {
            ref = address(0);
        }
        
        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
        }
        
        uint256 treatsUsed = getMyTreats(msg.sender);
        uint256 newDogs = SafeMath.div(treatsUsed,TREATS_REQ_PER_DOG);
        dogs[msg.sender] = SafeMath.add(dogs[msg.sender],newDogs);
        claimedTreats[msg.sender] = 0;
        lastTrained[msg.sender] = block.timestamp;
        
        //send referral treats
        claimedTreats[referrals[msg.sender]] = SafeMath.add(claimedTreats[referrals[msg.sender]],SafeMath.div(treatsUsed,8));
        
        //boost market to nerf dogs hoarding
        marketTreats=SafeMath.add(marketTreats,SafeMath.div(treatsUsed,5));
    }
    
    function sellTreats() public {
        require(initialized);
        uint256 hasTreats = getMyTreats(msg.sender);
        uint256 cratesWorth = calculateTreatsSell(hasTreats);
        uint256 fee = devFee(cratesWorth);
        claimedTreats[msg.sender] = 0;
        lastTrained[msg.sender] = block.timestamp;
        marketTreats = SafeMath.add(marketTreats,hasTreats);
        recAdd.transfer(fee);
        payable (msg.sender).transfer(SafeMath.sub(cratesWorth,fee));
    }
    
    function barkRewards(address adr) public view returns(uint256) {
        uint256 hasTreats = getMyTreats(adr);
        uint256 cratesWorth = calculateTreatsSell(hasTreats);
        return cratesWorth;
    }
    
    function adoptDogs(address ref) public payable {
        require(initialized);
        uint256 dogsAdopted = calculateDogsAdopted(msg.value,SafeMath.sub(address(this).balance,msg.value));
        dogsAdopted = SafeMath.sub(dogsAdopted,devFee(dogsAdopted));
        uint256 fee = devFee(msg.value);
        recAdd.transfer(fee);
        claimedTreats[msg.sender] = SafeMath.add(claimedTreats[msg.sender],dogsAdopted);
        trainDogs(ref);
    }
    
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    
    function calculateTreatsSell(uint256 treats) public view returns(uint256) {
        return calculateTrade(treats,marketTreats,address(this).balance);
    }
    
    function calculateDogsAdopted(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketTreats);
    }
    
    function calculateDogsAdoptedSimple(uint256 eth) public view returns(uint256) {
        return calculateDogsAdopted(eth,address(this).balance);
    }
    
    function devFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,devFeeVal),100);
    }
    
    function seedMarket() public payable onlyOwner {
        require(marketTreats == 0);
        initialized = true;
        marketTreats = 108000000000;
    }
    
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function getMyDogs(address adr) public view returns(uint256) {
        return dogs[adr];
    }
    
    function getMyTreats(address adr) public view returns(uint256) {
        return SafeMath.add(claimedTreats[adr],getTreatsSinceLastTrained(adr));
    }
    
    function getTreatsSinceLastTrained(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(TREATS_REQ_PER_DOG,SafeMath.sub(block.timestamp,lastTrained[adr]));
        return SafeMath.mul(secondsPassed,dogs[adr]);
    }
    
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}