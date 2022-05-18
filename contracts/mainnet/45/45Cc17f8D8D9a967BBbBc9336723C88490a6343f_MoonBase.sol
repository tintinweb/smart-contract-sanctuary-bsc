/*
 ██████   ██████    ███████       ███████    ██████   █████         
░░██████ ██████   ███░░░░░███   ███░░░░░███ ░░██████ ░░███          
 ░███░█████░███  ███     ░░███ ███     ░░███ ░███░███ ░███          
 ░███░░███ ░███ ░███      ░███░███      ░███ ░███░░███░███          
 ░███ ░░░  ░███ ░███      ░███░███      ░███ ░███ ░░██████          
 ░███      ░███ ░░███     ███ ░░███     ███  ░███  ░░█████          
 █████     █████ ░░░███████░   ░░░███████░   █████  ░░█████         
░░░░░     ░░░░░    ░░░░░░░       ░░░░░░░    ░░░░░    ░░░░░          
                                                                    
                                                                    
                                                                    
  █████████  ███████████    ███████    ███████████   ██████   ██████
 ███░░░░░███░█░░░███░░░█  ███░░░░░███ ░░███░░░░░███ ░░██████ ██████ 
░███    ░░░ ░   ░███  ░  ███     ░░███ ░███    ░███  ░███░█████░███ 
░░█████████     ░███    ░███      ░███ ░██████████   ░███░░███ ░███ 
 ░░░░░░░░███    ░███    ░███      ░███ ░███░░░░░███  ░███ ░░░  ░███ 
 ███    ░███    ░███    ░░███     ███  ░███    ░███  ░███      ░███ 
░░█████████     █████    ░░░███████░   █████   █████ █████     █████
 ░░░░░░░░░     ░░░░░       ░░░░░░░    ░░░░░   ░░░░░ ░░░░░     ░░░░░ 
                                                                    
                                                                                                   
... Each Astronaut that lands on the Moon causes a heavy MoonStorm to spawn, potentially wrecking havoc to a nearby MoonBase.
Who ever owns the MoonBase that is damaged must pay for the repairs. Players can protect their MoonBase by keeping their
Shield Generator running. If a Shield goes down, the Player is charged for the repair costs.  Each time the Player tanks full 
for 1,000,000,000 MSHOT the Shield is fully charged (99%). However, refueling could spawn another MoonStorm ...                                                                                                 
    
During your stay on the Moon, you will face great perils and you should keep the shield generator's fuel levels in optimal condition
especially in periods of green candles and increased volume.



Game mechanics:

A shield generator has 99 points
A Moonstorm generates the following damage points:
On Entry    : 0 - 16
When Fueling: 0 - 10
A shield absorbs the damage points in a 1:1 ratio
When the shield fails to absorb damage (Overkill or already down), the damage points will translate directly into a percentage of your in-game balance
The amount you paid is shared among the remaining players proportionally
    
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


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract MoonBase is Context, Ownable {
    using SafeMath for uint256;
    address public tokenAddress = 0x5298AD82dD7C83eEaA31DDa9DEB4307664C60534;
    uint256 public MAX_AMOUNT = 1000000000 * 10**9;

    uint256 public ENTRY_DAMAGE = 16;
    uint256 public FUEL_DAMAGE = 10;

    uint256 public maxPlayers = 100;
    uint256 constant MAX_shieldPower = 100;
    uint256 public MAX_DAMAGE = 10;
    uint256 public ONE_HUNDRED = 100;
    uint256 public moonStorms = 0;

    address public routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    IUniswapV2Router02 private uniswapV2Router;

    uint256 public buyFee = 1000;

    struct Player {
       uint256 balance;
       uint256 shieldPower;
       uint256 index;
       uint256 tokensReflected;
       uint256 damagePaid;
       uint256 shieldAbsorbed;
    }
  
    mapping( address => Player ) private players;
    address[] private playerIndex;

    event SetTokenAddress(address newTokenContract);
    
    event PlayerJoins(address ref, uint256 numPlayers);
    event PlayerLeaves(address ref, uint256 numPlayers);

    event ShieldDown(address ref, uint256 damage);
    event ShieldAbsorbs(address ref, uint256 absorb);

    event FuelShieldGenerator(address ref);

    event GameMakerSetRules(uint256 maxAmount, uint256 maxAddresses, uint256 maxDamagePercentEntry, uint256 maxDamagePercentFuel, uint256 fee);

    event SetRouterAddress(address ref);

    event WithdrawToken(address tokenContract);

    event Withdraw(address ref);
    
    // Create the Moon
    constructor() public payable {
        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    }
 
    // Setup internet in MoonBase
    function setRouterAddress(address newRouterAddress) external onlyOwner() {
        routerAddress = newRouterAddress;
        uniswapV2Router = IUniswapV2Router02(routerAddress);

        emit SetRouterAddress(newRouterAddress);
    }

    // Pseudo random numbers
    function notSoRandom() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, playerIndex.length)));
    }


    // Player wants to leave the game
    function quit() external {
        require( players [ msg.sender ].balance > 0 , "You have nothing to withdraw");
        
        IERC20(tokenAddress).transfer( msg.sender, players[ msg.sender ].balance );

        uint index = players[ msg.sender ].index;

        players[ msg.sender ].balance = 0;
        players[ msg.sender ].shieldPower = 0;
        players[ msg.sender ].index = 0;
        players[ msg.sender ].tokensReflected = 0;
        players[ msg.sender ].damagePaid = 0;
        players[ msg.sender ].shieldAbsorbed = 0;
        
        playerIndex[ index ] = playerIndex[ playerIndex.length - 1 ];
        players[ playerIndex[index] ].index = index;

        playerIndex.pop();

        emit PlayerLeaves( msg.sender, playerIndex.length );
    }

    function gameMaker(uint256 maxAmount, uint256 max, uint256 maxDamagePercentEntry, uint256 maxDamagePercentFuel, uint256 fee) external onlyOwner {

        require( maxDamagePercentEntry >= 0 && maxDamagePercentEntry <= 100);
        require( maxDamagePercentFuel >= 0 && maxDamagePercentFuel <= 100);
        require( fee >= 0 && fee <= 1000);
        
        MAX_AMOUNT = maxAmount;
        maxPlayers = max;
        ENTRY_DAMAGE = maxDamagePercentEntry;
        FUEL_DAMAGE = maxDamagePercentFuel;

        MAX_DAMAGE = ( FUEL_DAMAGE < ENTRY_DAMAGE ? FUEL_DAMAGE : ENTRY_DAMAGE);

        buyFee = fee;

        emit GameMakerSetRules(maxAmount, max, maxDamagePercentEntry, maxDamagePercentFuel, fee);
    }

    function slotsOpen() public view returns (uint256) {
        return maxPlayers - playerIndex.length;
    }

    function getPlayerData(address ref) public view returns (uint256, uint256, uint256, uint256, uint256) {
       return (
        players[ ref ].balance,
        players[ ref ].shieldPower,
        players[ ref ].tokensReflected,
        players[ ref ].shieldAbsorbed,
        players[ ref ].damagePaid
       );
    }

    function isFull() public view returns (bool) {
        return ( playerIndex.length == maxPlayers);
    }

    function step() private {
                
        // A sudden dust storm appears
        uint256 v = notSoRandom().mod( playerIndex.length );
        // The strength of the storm is between 0 and MAX_DAMAGE
        uint256 damage = notSoRandom().mod( MAX_DAMAGE );
        
        // The sandstorm hits a single player
        uint256 b = players[ playerIndex[v] ].balance;
        uint256 N = b.mul( damage ).div( ONE_HUNDRED );
        uint256 absorb = 0;

        if( damage <= players[ playerIndex[v] ].shieldPower ) {
            // The shield absorbs the damage
            absorb = N;
            players[ playerIndex[v] ].shieldPower = players[ playerIndex[v] ].shieldPower.sub(damage);

            emit ShieldAbsorbs( playerIndex[v], absorb);
        }
        else if( damage > players[ playerIndex[v] ].shieldPower ) {
            // The shield lost its strength, wealth is at risk
            uint256 tmp = damage - players[ playerIndex[v] ].shieldPower;
            absorb = b.mul(tmp).div( ONE_HUNDRED );
            players[ playerIndex[v] ].shieldPower = 0;

            emit ShieldDown( playerIndex[v], N.sub(absorb) );
        }
        
        // Calculate damage to pay
        N = N.sub(absorb);

        if( N > 0 ) {
            // Reflect the tokens paid for repairs to all players
            uint256 X = IERC20(tokenAddress).balanceOf( address(this) ).sub( b );

            players[ playerIndex[v] ].balance = 0;
            players[ playerIndex[v] ].damagePaid = players[ playerIndex[v] ].damagePaid.add(N);

            uint256 dustLeft = N;
            for( uint256 i = 0; i < playerIndex.length; i ++ ) {
                address addr = playerIndex[i];
                uint256 dust = N.mul( players[ addr ].balance ).div( X );
                players[ addr ].balance = players[ addr ].balance.add(dust);
                players[ addr ].tokensReflected = players[ addr ].tokensReflected.add(dust); 
                dustLeft = dustLeft.sub( dust );
            }

            players[ playerIndex[v] ].balance = b.sub(N).add(dustLeft);
        }

        moonStorms = moonStorms.add(1);
    }

    function setTokenAddress(address newTokenContract) external onlyOwner() {
        tokenAddress = newTokenContract;
        emit SetTokenAddress(tokenAddress);
    }

    function withdrawToken(address tokenContractAddress) external onlyOwner {
        uint256 amount = IERC20(tokenContractAddress).balanceOf(address(this));
        require(amount > 0);
        IERC20(tokenContractAddress).transfer( msg.sender , amount);

        emit WithdrawToken(tokenContractAddress);
    }

    // contract accumulates fee due to 10% on buy tax
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0);
        payable( msg.sender ).transfer( balance );

        emit Withdraw(msg.sender);
    }

    function isApproved(uint256 amount) public view returns (bool) {
        uint256 allowance = IERC20(tokenAddress).allowance(msg.sender, address(this));
        if( amount > 0 && allowance >= amount )
            return true;
        return false;
    }

    function start(uint256 amount) external {

        require( isApproved(amount), "Check the token allowance");

        IERC20(tokenAddress).transferFrom( msg.sender, address(this), amount );

        players[ msg.sender ].balance = amount;
        players[ msg.sender ].shieldPower = MAX_shieldPower - 1;
        playerIndex.push(msg.sender);
        players[ msg.sender ].index = playerIndex.length - 1;
        MAX_DAMAGE = ENTRY_DAMAGE;

        if( playerIndex.length >= 3 ) { 
            step();
        }
        
        emit PlayerJoins( msg.sender, playerIndex.length );
    }   

    function buyFuel(uint256 amount) external {

        require( isApproved(amount), "Check the token allowance");

        IERC20(tokenAddress).transferFrom( msg.sender, address(this), amount );

        uint256 shieldPower = MAX_shieldPower - 1;
        uint256 amt = ( amount > MAX_AMOUNT ? MAX_AMOUNT : amount );
        players[ msg.sender ].balance = players[ msg.sender ].balance.add( amount );
        players[ msg.sender ].shieldPower = shieldPower.mul(amt).div( MAX_AMOUNT );
        MAX_DAMAGE = FUEL_DAMAGE;

        if( playerIndex.length >= 3 ) { 
            step();
        }

        emit FuelShieldGenerator(msg.sender);
    } 

    function buyTokenWithBNB() public payable {
        uint256 amount = msg.value;
        address beneficiary = ( isFull() ? msg.sender : address(this));
        uint256 balance = IERC20(tokenAddress).balanceOf( address(this) );
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = tokenAddress;

        uint256 feeAmount = amount.mul(buyFee).div(1000);
        amount = amount - feeAmount;

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(0, path, beneficiary, block.timestamp+60);

        uint256 moonshotAmount = IERC20(tokenAddress).balanceOf( address(this) ).sub(balance);

        if( moonshotAmount > 0) {
            uint256 shieldPower = MAX_shieldPower - 1;
            if( players[msg.sender].balance == 0) {  // start
                players[ msg.sender ].balance = moonshotAmount;
                players[ msg.sender ].shieldPower = shieldPower;
                playerIndex.push(msg.sender);
                players[ msg.sender ].index = playerIndex.length - 1;
                MAX_DAMAGE = ENTRY_DAMAGE;
                emit PlayerJoins( msg.sender, playerIndex.length );
            }
            else {  // buyFuel
                uint256 amt = ( moonshotAmount > MAX_AMOUNT ? MAX_AMOUNT : moonshotAmount );
                players[ msg.sender ].balance = players[ msg.sender ].balance.add( moonshotAmount );
                players[ msg.sender ].shieldPower = shieldPower.mul(amt).div( MAX_AMOUNT );
                MAX_DAMAGE = FUEL_DAMAGE;
                emit FuelShieldGenerator(msg.sender);
            }

            if( playerIndex.length >= 3) { 
                step();
            }
        }
    }

    receive() external payable {
        buyTokenWithBNB();
    }

}