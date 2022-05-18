/*

███╗   ███╗ ██████╗  ██████╗ ███╗   ██╗██████╗  █████╗ ███████╗███████╗
████╗ ████║██╔═══██╗██╔═══██╗████╗  ██║██╔══██╗██╔══██╗██╔════╝██╔════╝
██╔████╔██║██║   ██║██║   ██║██╔██╗ ██║██████╔╝███████║███████╗█████╗  
██║╚██╔╝██║██║   ██║██║   ██║██║╚██╗██║██╔══██╗██╔══██║╚════██║██╔══╝  
██║ ╚═╝ ██║╚██████╔╝╚██████╔╝██║ ╚████║██████╔╝██║  ██║███████║███████╗
╚═╝     ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝
                                                                       
...  Each Astronaut that lands on the Moon creates a dust storm sending particles for miles away.
 These dust storms could damage the bases of the other astronauts that came before. Every day the fuel of the shield generator
 needs to be refilled to keep the shield in optimum condition. Failure to do so results in damages to the MoonBase as the shield absorption 
 rate diminishes after each storm. The coins paid for repairs are distributed among the other astronauts.
 
https://project-moonshot.me

*/

pragma solidity ^0.6.12;
// SPDX-License-Identifier: Unlicensed

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
 
library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

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
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
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

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}

contract MoonBase is Context, Ownable {
    using SafeMath for uint256;

    address public tokenAddress = 0x5298AD82dD7C83eEaA31DDa9DEB4307664C60534;

    uint256 public MAX_AMOUNT = 100000000000000000;
    uint256 public moveCooldown = 2 minutes;
    uint256 public maxPlayers = 100;
    uint constant MAX_HEALTH = 100;
    uint public MAX_DAMAGE = 10;
    uint256 public moonStorms = 0;

    struct Player {
       uint256 balance;
       uint256 expiryTime;
       uint256 health;
       uint256 index;
    }
  
    mapping( address => Player ) private players;
    address[] private playerIndex;

    event SetTokenAddress(address newTokenContract);
  
    // Create the Moon
    constructor() public payable {
       
    }
 
    // Pseudo random numbers
    function notSoRandom() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, playerIndex.length)));
    }

    // Approve to spent 
    function approve(uint256 amount) external {
        IERC20(tokenAddress).approve( address(this), amount );
    }


    // a new player is hurling towards the moon
    function start(uint256 amount) external {
        require( players[ msg.sender ].expiryTime == 0 , "You are already playing");

        IERC20(tokenAddress).transferFrom( msg.sender, address(this), amount );
        players[ msg.sender ].balance = amount;
        players[ msg.sender ].health = MAX_HEALTH - 1;
        playerIndex.push(msg.sender);
        players[ msg.sender ].index = playerIndex.length - 1;

        step();
    }

    // every time the cooldown is up, the player can buy fuel to keep the shield of his moonbase running
    function buyFuel(uint256 amount) external {
        require( canPlay(), "Not your turn" );
        require( players[ msg.sender ].expiryTime > 0, "Press start to play");

        IERC20(tokenAddress).transferFrom( msg.sender, address(this), amount );

        uint256 amt = ( amount > MAX_AMOUNT ? MAX_AMOUNT : amount );
        uint256 health = MAX_HEALTH - 1;

        players[ msg.sender ].balance = players[ msg.sender ].balance.add( amount );
        players[ msg.sender ].health = health.mul(amt).div( MAX_AMOUNT );
        
        step();
    }

    // the player can decide to jump "ship" and leave for another Moon
    function emergencyEvacuation() external {
        require( players [ msg.sender ].expiryTime > 0, "Press start to play");
        require( players [ msg.sender ].balance > 0 , "You have nothing to withdraw");
        require( canPlay(), "Not your turn" );

        step();

        IERC20(tokenAddress).transfer( msg.sender, players[ msg.sender ].balance );

        uint index = players[ msg.sender ].index;

        players[ msg.sender ].balance = 0;
        players[ msg.sender ].expiryTime = 0; 
        players[ msg.sender ].health = 0;
        players[ msg.sender ].index = 0;
        
        playerIndex[ index ] = playerIndex[ playerIndex.length -1 ];
        players[ playerIndex[index] ].index = index;

        playerIndex.pop();
    }

    function gameMaker(uint256 maxAmount, uint256 periodSeconds, uint256 max, uint256 maxDamagePercent) external onlyOwner {
        MAX_AMOUNT = maxAmount;
        moveCooldown = periodSeconds;
        maxPlayers = max;
        MAX_DAMAGE = maxDamagePercent;
    }

    function isFull() public view returns (bool) {
        return ( playerIndex.length == maxPlayers);
    }

    function canPlay() public view returns (bool) {
        if( players[ msg.sender ].expiryTime == 0 )
            return true;
        if( players[ msg.sender ].expiryTime > block.timestamp )
            return true;
        return false;
    }

    function step() private {
        
        dustStorm();

        moonStorms = moonStorms + 1;

        players[ msg.sender ].expiryTime = block.timestamp + moveCooldown;
    }

    function dustStorm() private {

        // A suddon dust storm appears
        uint256 v = notSoRandom().mod( playerIndex.length );
        uint256 damage = notSoRandom().mod( MAX_DAMAGE );
        
        // The damage is calculated and someone has to pay for it 
        uint256 b = players[ playerIndex[v] ].balance;
        uint256 N = b.mul( damage ).div( MAX_DAMAGE );

        // The player can absorb some damage
        uint256 absorb = N.mul( players[ playerIndex[v] ].health ).div( MAX_HEALTH );
                N = N.sub( absorb );

        // N contains now physical damage
        uint256 X = IERC20(tokenAddress).balanceOf( address(this) );
                X = X.sub(b);

        uint256 K = N.div(X);
        uint256 rem = MAX_DAMAGE - damage;

        players[ playerIndex[v] ].balance = 0;
        players[ playerIndex[v] ].health =  players[ playerIndex[v] ].health.mul( rem ).div( MAX_HEALTH );

        for( uint256 i = 0; i < playerIndex.length; i ++ ) {
            address addr = playerIndex[i];
            players[ addr ].balance.add( (players[ addr ].balance.mul(K) ));

            if( players[ addr ].expiryTime < block.timestamp && players[ addr ].health != 0 ) {
                players[ addr ].health = 0;
            }
        }
        players[ playerIndex[v] ].balance = b.sub(N);

    }


    function setTokenAddress(address newTokenContract) external onlyOwner() {
        tokenAddress = newTokenContract;

        emit SetTokenAddress(tokenAddress);
    }

    function withdraw(address tokenContractAddress) external onlyOwner {
        uint256 amount = IERC20(tokenContractAddress).balanceOf(address(this));
        require(amount > 0);

        IERC20(tokenContractAddress).transfer( msg.sender , amount);

    }

    function withdrawBNB() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0);
        payable( msg.sender ).transfer( balance );
     
    }
  
}