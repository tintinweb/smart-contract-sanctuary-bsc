/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// File: contracts/BSnakeStake.sol



pragma solidity ^0.8.0;


//import "./CoinToken.sol";
//import "./BSnakeMint.sol";

interface SnakeTokenInterface {
	function balanceOf(address owner) external view returns (uint);
	function allowance(address owner, address spender) external view returns (uint256);
	function approve(address spender, uint value) external returns (bool);
	function transfer(address to, uint value) external returns (bool);
	function transferFrom(address from, address to, uint value) external returns (bool);
	function mint(address account, uint256 amount) external;
}
interface SnakeMintInterface {
    function transfer(address from, address to, uint256 tokenId) external;
	function transferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address owner);
	function approve(address to, uint256 tokenId) external;
	function setApprovalForAll(address to, bool approved) external;
}

contract BSnakeStake is Ownable {

    using SafeMath for uint256;

    
	uint256 public stakecommonFee       = 0.0024 ether;
    
	uint256 public stakerareFee         = 0.0048 ether;
    
	uint256 public stakestrangeFee      = 0.0072 ether;
    
	uint256 public stakeepicFee         = 0.0097 ether;
    
	uint256 public stakelegendaryFee    = 0.012 ether;
	
	// userAddress => isStaking boolean
    mapping(address => bool) public isStakingCommon;
	// userAddress => timeStamp
	mapping(address => uint256) public startTimeCommon;
	// userAddress => isStaking boolean
    mapping(address => bool) public isStakingRare;
	// userAddress => timeStamp
	mapping(address => uint256) public startTimeRare;
	// userAddress => isStaking boolean
    mapping(address => bool) public isStakingStrange;
	// userAddress => timeStamp
	mapping(address => uint256) public startTimeStrange;
	// userAddress => isStaking boolean
    mapping(address => bool) public isStakingEpic;
	// userAddress => timeStamp
	mapping(address => uint256) public startTimeEpic;
	// userAddress => isStaking boolean
    mapping(address => bool) public isStakingLegendary;
	// userAddress => timeStamp
	mapping(address => uint256) public startTimeLegendary;
	
	//CoinToken public cointoken;
	SnakeTokenInterface public cointoken;
	SnakeMintInterface public bsnakeMint;


    uint256 public totalStaked;
  
    // struct to store a stake's token, owner, and earning values
    struct Stake {
        uint256 tokenId;
        uint48 timestamp;
        address owner;
    }
    // maps tokenId to stake
    // tokenId => Stake
    mapping(uint256 => Stake) public vault;


	
	string public name = "Snake Staking Farm";
	
	event StakeCommonSnake(address indexed from);
	event StakeRareSnake(address indexed from);
	event StakeStrangeSnake(address indexed from);
	event StakeEpicSnake(address indexed from);
	event StakeLegendarySnake(address indexed from);
    event YieldWithdrawCommon(address indexed to, uint256 amount);
	event YieldWithdrawRare(address indexed to, uint256 amount);
	event YieldWithdrawStrange(address indexed to, uint256 amount);
	event YieldWithdrawEpic(address indexed to, uint256 amount);
	event YieldWithdrawLegendary(address indexed to, uint256 amount);

	//CoinToken _cointoken
    constructor(
		address _cointoken,
		address _bsnakeMint) {

		cointoken = SnakeTokenInterface(_cointoken);
		bsnakeMint = SnakeMintInterface(_bsnakeMint);

	}
	
	function stakeCommonSnake(uint256 tokenId) public payable {
        totalStaked = totalStaked.add(1);
        require(msg.value>=stakecommonFee, "Stake Fee is not correct");
        require(bsnakeMint.ownerOf(tokenId) == msg.sender, "not your token");
        require(vault[tokenId].tokenId == 0, 'already staked');

		bsnakeMint.setApprovalForAll(msg.sender, true);
		bsnakeMint.approve(msg.sender, tokenId);
		bsnakeMint.approve(address(this), tokenId);
	    bsnakeMint.transferFrom(msg.sender, address(this), tokenId);
        vault[tokenId] = Stake({
            owner: msg.sender,
            tokenId: uint256(tokenId),
            timestamp: uint48(block.timestamp)
        });

	   startTimeCommon[msg.sender] = block.timestamp;
       isStakingCommon[msg.sender] = true;
	   emit StakeCommonSnake(msg.sender);
	}
	
	function stakeRareSnake(uint256 tokenId) public payable {
	   require(msg.value==stakerareFee, "Stake Fee is not correct");
	   bsnakeMint.transfer(msg.sender, address(this), tokenId);
	   startTimeRare[msg.sender] = block.timestamp;
       isStakingRare[msg.sender] = true;
	   emit StakeRareSnake(msg.sender);
	}
	
	function stakeStrangeSnake(uint256 tokenId) public payable {
	   require(msg.value==stakestrangeFee, "Stake Fee is not correct");
	   bsnakeMint.transfer(msg.sender, address(this), tokenId);
	   startTimeStrange[msg.sender] = block.timestamp;
       isStakingStrange[msg.sender] = true;
	   emit StakeStrangeSnake(msg.sender);
	}
	
	function stakeEpicSnake(uint256 tokenId) public payable {
	   require(msg.value==stakeepicFee, "Stake Fee is not correct");
	   bsnakeMint.transfer(msg.sender, address(this), tokenId);
	   startTimeEpic[msg.sender] = block.timestamp;
       isStakingEpic[msg.sender] = true;
	   emit StakeEpicSnake(msg.sender);
	}
	
	function stakeLegendarySnake(uint256 tokenId) public payable {
	   require(msg.value==stakelegendaryFee, "Stake Fee is not correct");
	   bsnakeMint.transfer(msg.sender, address(this), tokenId);
	   startTimeLegendary[msg.sender] = block.timestamp;
       isStakingLegendary[msg.sender] = true;
	   emit StakeLegendarySnake(msg.sender);
	}

    
	
	function updatestakeCommonFee(uint256 _fee) external onlyOwner {
        require(_fee > 0);
        stakecommonFee = _fee;
    }

	
	function updatestakeRareFee(uint256 _fee) external onlyOwner {
        require(_fee > 0);
        stakerareFee = _fee;
    }

	
	function updatestakeStrangeFee(uint256 _fee) external onlyOwner {
        require(_fee > 0);
        stakestrangeFee = _fee;
    }

	
	function updatestakeEpicFee(uint256 _fee) external onlyOwner {
        require(_fee > 0);
        stakeepicFee = _fee;
    }

	
	function updatestakeLegendaryFee(uint256 _fee) external onlyOwner {
        require(_fee > 0);
        stakelegendaryFee = _fee;
    }
	
    ///      the yield of a common staked snake
    function withdrawYieldCommon(uint256 tokenId) public {
        Stake memory staked = vault[tokenId];
        uint256 stakedAt = staked.timestamp;

	    require(block.timestamp>= stakedAt + (60 seconds * 1), "1 minute did not pass yet");

        require(staked.owner == msg.sender, "not an owner");

		
		bsnakeMint.transferFrom(address(this), msg.sender, tokenId);
        uint256 toTransfer = 2 ether;

        //cointoken.mint(msg.sender, toTransfer);
		cointoken.approve(address(this), toTransfer);
        cointoken.transferFrom(address(this), msg.sender, toTransfer);
        delete vault[tokenId];
        totalStaked = totalStaked.sub(1);
        emit YieldWithdrawCommon(msg.sender, toTransfer);
    } 
	///      the yield of a rare staked snake
    function withdrawYieldRare(uint256 tokenId) public {
	    require(block.timestamp>=startTimeRare[msg.sender]*86400*7, "7 days did not pass yet");
		bsnakeMint.transfer(address(this), msg.sender, tokenId);
        uint256 toTransfer = 4;

        cointoken.mint(msg.sender, toTransfer);
        emit YieldWithdrawRare(msg.sender, toTransfer);
    } 
	///      the yield of a strange staked snake
    function withdrawYieldStrange(uint256 tokenId) public {
	    require(block.timestamp>=startTimeStrange[msg.sender]*86400*7, "7 days did not pass yet");
		bsnakeMint.transfer(address(this), msg.sender, tokenId);
        uint256 toTransfer = 6;

        cointoken.mint(msg.sender, toTransfer);
        emit YieldWithdrawStrange(msg.sender, toTransfer);
    } 
	///      the yield of a Epic staked snake
    function withdrawYieldEpic(uint256 tokenId) public {
	    require(block.timestamp>=startTimeEpic[msg.sender]*86400*7, "7 days did not pass yet");
		bsnakeMint.transfer(address(this), msg.sender, tokenId);
        uint256 toTransfer = 8;

        cointoken.mint(msg.sender, toTransfer);
        emit YieldWithdrawEpic(msg.sender, toTransfer);
    } 
	///      the yield of a Legendary staked snake
    function withdrawYieldLegendary(uint256 tokenId) public {
	    require(block.timestamp>=startTimeLegendary[msg.sender]*86400*7, "7 days did not pass yet");
		bsnakeMint.transfer(address(this), msg.sender, tokenId);
        uint256 toTransfer = 10;

        cointoken.mint(msg.sender, toTransfer);
        emit YieldWithdrawLegendary(msg.sender, toTransfer);
    } 
    function withdraw() external payable onlyOwner {
        address payable _owner = payable(owner());
        require(address(this).balance > 0);
        _owner.transfer(address(this).balance);
    }
}