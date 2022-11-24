/**
 *Submitted for verification at BscScan.com on 2022-11-23
*/

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


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

// File: contracts/Presale.sol


pragma solidity ^0.8.7;



interface INFT{
    function mint(address to, string memory part, uint256 rarity, uint256 idstatic) external returns (uint256);
}

contract PresaleContract is Ownable{
    using SafeMath for uint256;

    uint256 public Sold_CommonBox;
    uint256 public Sold_RareBox;
    uint256 public Sold_EpicBox;
    uint256 public Sold_LegendaryBox;

    INFT private NFTc; //Contract NFT Components
    address private _owner;
    bool private _paused;
    uint256 private nonce;

    uint256 private  Price_CommonBox = 34000000000000000; //10 BUSD
    uint256 private  Price_RareBox = 130000000000000000; //40 BUSD
    uint256 private  Price_EpicBox = 540000000000000000; //160 BUSD
    uint256 private  Price_LegendaryBox = 2160000000000000000; //640 BUSD

    uint256 private  MaxSupply_CommonBox = 1000;
    uint256 private  MaxSupply_RareBox = 600;
    uint256 private  MaxSupply_EpicBox = 300;
    uint256 private  MaxSupply_LegendaryBox = 100;

    constructor(address _ContractFactory) {
        NFTc = INFT(_ContractFactory);
        _owner = _msgSender();
        _paused = false;
    }

    function buy_CommonBox() public payable IsPaused returns (bool){
        address _buyer = _msgSender();
        uint256 Amount = msg.value;
        require(Amount == Price_CommonBox, "insufficient amount");
        require(Sold_CommonBox <= MaxSupply_CommonBox, "all the Common boxes have been sold");

        NFTc.mint(_buyer, randomcomponent(), randomrarity(0,1), randomidstatic());
        NFTc.mint(_buyer, randomcomponent(), randomrarity(0,1), randomidstatic());
        NFTc.mint(_buyer, randomcomponent(), randomrarity(0,1), randomidstatic());
        Sold_CommonBox++;
        return true;
    }

    function buy_RareBox() public payable IsPaused returns (bool){
        address _buyer = _msgSender();
        uint256 Amount = msg.value;
        require(Amount == Price_RareBox, "insufficient amount");
        require(Sold_RareBox <= MaxSupply_RareBox, "all the Rare boxes have been sold");

        NFTc.mint(_buyer, randomcomponent(), randomrarity(2,3), randomidstatic());
        NFTc.mint(_buyer, randomcomponent(), randomrarity(2,3), randomidstatic());
        NFTc.mint(_buyer, randomcomponent(), randomrarity(2,3), randomidstatic());
        Sold_RareBox++;
        return true;
    }

    function buy_EpicBox() public payable IsPaused returns (bool){
        address _buyer = _msgSender();
        uint256 Amount = msg.value;
        require(Amount == Price_EpicBox, "insufficient amount");
        require(Sold_EpicBox <= MaxSupply_EpicBox, "all the Epic boxes have been sold");

        NFTc.mint(_buyer, "head", randomrarity(4,5), randomidstatic());
        NFTc.mint(_buyer, "body", randomrarity(4,5), randomidstatic());
        NFTc.mint(_buyer, "weapon", randomrarity(4,5), randomidstatic());
        Sold_EpicBox++;
        return true;
    }

    function buy_LegendaryBox() public payable IsPaused returns (bool){
        address _buyer = _msgSender();
        uint256 Amount = msg.value;
        require(Amount == Price_LegendaryBox, "insufficient amount");
        require(Sold_LegendaryBox <= MaxSupply_LegendaryBox, "all the Legendary boxes have been sold");

        NFTc.mint(_buyer, "head", randomrarity(6,7), randomidstatic());
        NFTc.mint(_buyer, "body", randomrarity(6,7), randomidstatic());
        NFTc.mint(_buyer, "weapon", randomrarity(6,7), randomidstatic());
        Sold_LegendaryBox++;
        return true;
    }


    function randomcomponent() internal returns (string memory){
        nonce++;
        uint256 Number = uint( keccak256( abi.encodePacked(block.timestamp, _msgSender(), nonce )) ) % 3;
        if(Number == 0){ return "head";
        }else if(Number == 1){ return "body";
        }else{ return "weapon"; }
    }
    function randomrarity(uint256 A, uint256 B) internal returns (uint256){
        nonce++;
        uint256 Number = uint( keccak256( abi.encodePacked(block.timestamp, _msgSender(), nonce )) ) % 100;
        if(Number <= 70){ return A;
        }else{ return B; }
    }
    function randomidstatic() internal returns (uint256){
        nonce++;
        return uint( keccak256( abi.encodePacked(block.timestamp, _msgSender(), nonce )) ) % 100;
    }



    modifier IsPaused() {require(_paused != true);  _; }
    function setPaused(bool Changepaused) public onlyOwner{ _paused = Changepaused; }
    function paused() public view returns (bool) { return _paused; }




}