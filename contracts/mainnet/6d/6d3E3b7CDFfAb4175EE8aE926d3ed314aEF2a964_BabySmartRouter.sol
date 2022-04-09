// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/Context.sol";
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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

interface IBabyBaseRouter {

    function factory() external view returns (address);
    function WETH() external view returns (address);
    function swapMining() external view returns (address);
    function routerFeeReceiver() external view returns(address);

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IBabyFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function expectPairFor(address token0, address token1) external view returns (address);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IBabyPair {
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

interface IBabySmartRouter {

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address[] calldata factories,
        uint[] calldata fees,
        address to,
        uint deadline
    ) external  returns (uint[] calldata amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address[] calldata factories,
        uint[] calldata fees,
        address to,
        uint deadline
    ) external  returns (uint[] calldata amounts);

    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address[] calldata factories, 
        uint[] calldata fees, 
        address to, 
        uint deadline
    ) external  payable returns (uint[] calldata amounts);

    function swapTokensForExactETH(
        uint amountOut, 
        uint amountInMax, 
        address[] calldata path, 
        address[] calldata factories, 
        uint[] calldata fees, 
        address to, 
        uint deadline
    ) external  returns (uint[] calldata amounts);

    function swapExactTokensForETH(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        address[] calldata factories, 
        uint[] calldata fees, 
        address to, 
        uint deadline
    ) external  returns (uint[] calldata amounts);

    function swapETHForExactTokens(
        uint amountOut, 
        address[] calldata path, 
        address[] calldata factories, 
        uint[] calldata fees, 
        address to, 
        uint deadline
    ) external  payable returns (uint[] calldata amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address[] calldata factories,
        uint[] calldata fees,
        address to,
        uint deadline
    ) external ;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address[] calldata factories,
        uint[] calldata fees,
        address to,
        uint deadline
    ) external  payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address[] calldata factories,
        uint[] calldata fees,
        address to,
        uint deadline
    ) external ;

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

interface ISwapMining {
    function swap(address account, address input, address output, uint256 amount) external returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

import '../interfaces/IBabyFactory.sol';
import '../interfaces/IBabyPair.sol';
import "./SafeMath.sol";

library BabyLibrarySmartRouter {
    using SafeMath for uint;

    uint constant FEE_BASE = 10000;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'BabyLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'BabyLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal view returns (address pair) {
        return IBabyFactory(factory).getPair(tokenA, tokenB);
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IBabyPair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'BabyLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'BabyLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'BabyLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'BabyLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    function getAmountOutWithFee(uint amountIn, uint reserveIn, uint reserveOut, uint fee) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'BabyLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'BabyLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(FEE_BASE.sub(fee));
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(FEE_BASE).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'BabyLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'BabyLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    function getAmountInWithFee(uint amountOut, uint reserveIn, uint reserveOut, uint fee) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'BabyLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'BabyLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(FEE_BASE);
        uint denominator = reserveOut.sub(amountOut).mul(FEE_BASE.sub(fee));
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'BabyLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAggregationAmountsOut(address[] memory factories, uint[] memory fees, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2 && path.length - 1 == factories.length && factories.length == fees.length, 'BabyLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factories[i], path[i], path[i + 1]);
            amounts[i + 1] = getAmountOutWithFee(amounts[i], reserveIn, reserveOut, fees[i]);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'BabyLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }

    function getAggregationAmountsIn(address[] memory factories, uint[] memory fees, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2 && path.length - 1 == factories.length && factories.length == fees.length, 'BabyLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factories[i - 1], path[i - 1], path[i]);
            amounts[i - 1] = getAmountInWithFee(amounts[i], reserveIn, reserveOut, fees[i - 1]);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.4.0;

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
        require(c >= a, 'SafeMath: addition overflow');

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
        return sub(a, b, 'SafeMath: subtraction overflow');
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
        require(c / a == b, 'SafeMath: multiplication overflow');

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
        return div(a, b, 'SafeMath: division by zero');
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
        return mod(a, b, 'SafeMath: modulo by zero');
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IBabyBaseRouter.sol";
import "../libraries/SafeMath.sol";

contract BabyBaseRouter is IBabyBaseRouter, Ownable {
    using SafeMath for uint;

    address public immutable override factory;
    address public immutable override WETH;
    address public override swapMining;
    address public override routerFeeReceiver;

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'BabyRouter: EXPIRED');
        _;
    }

    function setSwapMining(address _swapMininng) public onlyOwner {
        swapMining = _swapMininng;
    }
    
    function setRouterFeeReceiver(address _receiver) public onlyOwner {
        routerFeeReceiver = _receiver;
    }

    constructor(address _factory, address _WETH, address _swapMining, address _routerFeeReceiver) {
        factory = _factory;
        WETH = _WETH;
        swapMining = _swapMining;
        routerFeeReceiver = _routerFeeReceiver;
    }

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../libraries/BabyLibrarySmartRouter.sol";
import "../interfaces/IBabySmartRouter.sol";
import "../libraries/TransferHelper.sol";
import "../interfaces/ISwapMining.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/IWETH.sol";
import "./BabyBaseRouter.sol";

contract BabySmartRouter is BabyBaseRouter, IBabySmartRouter {
    using SafeMath for uint;

    address immutable public normalRouter;

    constructor(
        address _factory, 
        address _WETH, 
        address _swapMining, 
        address _routerFeeReceiver,
        address _normalRouter
    ) BabyBaseRouter(_factory, _WETH, _swapMining, _routerFeeReceiver) {
        normalRouter = _normalRouter;
    }

    function routerFee(address _factory, address _user, address _token, uint _amount) internal returns (uint) {
        if (routerFeeReceiver != address(0) && _factory == factory) {
            uint fee = _amount.mul(1).div(1000);
            if (fee > 0) {
                if (_user == address(this)) {
                    TransferHelper.safeTransfer(_token, routerFeeReceiver, fee);
                } else {
                    TransferHelper.safeTransferFrom(
                        _token, msg.sender, routerFeeReceiver, fee
                    );
                }
                _amount = _amount.sub(fee);
            }
        }
        return _amount;
    }

    fallback() external payable {
        babyRouterDelegateCall(msg.data);
    }

    function babyRouterDelegateCall(bytes memory data) internal {
        (bool success, ) = normalRouter.delegatecall(data);

        assembly {
            let free_mem_ptr := mload(0x40)
            returndatacopy(free_mem_ptr, 0, returndatasize())

            switch success
            case 0 { revert(free_mem_ptr, returndatasize()) }
            default { return(free_mem_ptr, returndatasize()) }
        }
    }

    function isBabyRouter(address[] memory _factories) internal view returns (bool) {
        for (uint i = 0; i < _factories.length; i ++) {
            if (_factories[i] != factory) {
                return false;
            }
        }
        return true;
    }

    function _swap(
        uint[] memory amounts, 
        address[] memory path, 
        address[] memory factories, 
        address _to
    ) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = BabyLibrarySmartRouter.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            if (swapMining != address(0)) {
                ISwapMining(swapMining).swap(msg.sender, input, output, amountOut);
            }
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < path.length - 2 ? address(this) : _to;
            IBabyPair(BabyLibrarySmartRouter.pairFor(factories[i], input, output)).swap(
                amount0Out, amount1Out, to, new bytes(0)
            );
            if (i < path.length - 2) {
                amounts[i + 1] = routerFee(factories[i + 1], address(this), path[i + 1], amounts[i + 1]);
                TransferHelper.safeTransfer(path[i + 1], BabyLibrarySmartRouter.pairFor(factories[i + 1], output, path[i + 2]), amounts[i + 1]);
            }
        }
    }

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] memory path,
        address[] memory factories,
        uint[] memory fees,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        amounts = BabyLibrarySmartRouter.getAggregationAmountsOut(factories, fees, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'BabyRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        amounts[0] = routerFee(factories[0], msg.sender, path[0], amounts[0]);
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, BabyLibrarySmartRouter.pairFor(factories[0], path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, factories, to);
    }

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] memory path,
        address[] memory factories,
        uint[] memory fees,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        amounts = BabyLibrarySmartRouter.getAggregationAmountsIn(factories, fees, amountOut, path);
        require(amounts[0] <= amountInMax, 'BabyRouter: EXCESSIVE_INPUT_AMOUNT');
        amounts[0] = routerFee(factories[0], msg.sender, path[0], amounts[0]);
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, BabyLibrarySmartRouter.pairFor(factories[0], path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, factories, to);
    }

    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] memory path, 
        address[] memory factories, 
        uint[] memory fees, 
        address to, 
        uint deadline
    ) external virtual override payable ensure(deadline) returns (uint[] memory amounts) {
        require(path[0] == WETH, 'BabyRouter: INVALID_PATH');
        amounts = BabyLibrarySmartRouter.getAggregationAmountsOut(factories, fees,  msg.value, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'BabyRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0]}();
        amounts[0] = routerFee(factories[0], msg.sender, path[0], amounts[0]);
        assert(IWETH(WETH).transfer(BabyLibrarySmartRouter.pairFor(factories[0], path[0], path[1]), amounts[0]));
        _swap(amounts, path, factories, to);
    }

    function swapTokensForExactETH(
        uint amountOut, 
        uint amountInMax, 
        address[] memory path, 
        address[] memory factories, 
        uint[] memory fees, 
        address to, 
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        require(path[path.length - 1] == WETH, 'BabyRouter: INVALID_PATH');
        amounts = BabyLibrarySmartRouter.getAggregationAmountsIn(factories, fees, amountOut, path);
        require(amounts[0] <= amountInMax, 'BabyRouter: EXCESSIVE_INPUT_AMOUNT');
        amounts[0] = routerFee(factories[0], msg.sender, path[0], amounts[0]);
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, BabyLibrarySmartRouter.pairFor(factories[0], path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, factories, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    function swapExactTokensForETH(
        uint amountIn, 
        uint amountOutMin, 
        address[] memory path, 
        address[] memory factories, 
        uint[] memory fees, 
        address to, 
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        require(path[path.length - 1] == WETH, 'BabyRouter: INVALID_PATH');
        amounts = BabyLibrarySmartRouter.getAggregationAmountsOut(factories, fees, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'BabyRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        amounts[0] = routerFee(factories[0], msg.sender, path[0], amounts[0]);
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, BabyLibrarySmartRouter.pairFor(factories[0], path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, factories, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    function swapETHForExactTokens(
        uint amountOut, 
        address[] memory path, 
        address[] memory factories, 
        uint[] memory fees, 
        address to, 
        uint deadline
    ) external virtual override payable ensure(deadline) returns (uint[] memory amounts) {
        require(path[0] == WETH, 'BabyRouter: INVALID_PATH');
        amounts = BabyLibrarySmartRouter.getAggregationAmountsIn(factories, fees, amountOut, path);
        require(amounts[0] <= msg.value, 'BabyRouter: EXCESSIVE_INPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0]}();
        amounts[0] = routerFee(factories[0], msg.sender, path[0], amounts[0]);
        assert(IWETH(WETH).transfer(BabyLibrarySmartRouter.pairFor(factories[0], path[0], path[1]), amounts[0]));
        _swap(amounts, path, factories, to);
        // refund dust eth, if any
        if (msg.value > amounts[0]) TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]);
    }

    function _swapSupportingFeeOnTransferTokens(
        address[] memory path, 
        address[] memory factories, 
        uint[] memory fees, 
        address _to
    ) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = BabyLibrarySmartRouter.sortTokens(input, output);
            IBabyPair pair = IBabyPair(BabyLibrarySmartRouter.pairFor(factories[i], input, output));
            //uint amountInput;
            //uint amountOutput;
            uint[] memory amounts = new uint[](2);
            { // scope to avoid stack too deep errors
            (uint reserve0, uint reserve1,) = pair.getReserves();
            (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
            amounts[0] = IERC20(input).balanceOf(address(pair)).sub(reserveInput);
            amounts[1] = BabyLibrarySmartRouter.getAmountOutWithFee(amounts[0], reserveInput, reserveOutput, fees[i]);
            }
            if (swapMining != address(0)) {
                ISwapMining(swapMining).swap(msg.sender, input, output, amounts[i + 1]);
            }
            (amounts[0], amounts[1]) = input == token0 ? (uint(0), amounts[1]) : (amounts[1], uint(0));
            address to = i < path.length - 2 ? address(this) : _to;
            pair.swap(amounts[0], amounts[1], to, new bytes(0));
            if (i < path.length - 2) {
                routerFee(factories[i + 1], address(this), output, IERC20(output).balanceOf(address(this)));
                TransferHelper.safeTransfer(path[i + 1], BabyLibrarySmartRouter.pairFor(factory, output, path[i + 2]), IERC20(output).balanceOf(address(this)));
            }
        }
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] memory path,
        address[] memory factories,
        uint[] memory fees,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) {
        amountIn = routerFee(factories[0], msg.sender, path[0], amountIn);
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, BabyLibrarySmartRouter.pairFor(factories[0], path[0], path[1]), amountIn
        );
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, factories, fees,  to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'BabyRouter: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] memory path,
        address[] memory factories,
        uint[] memory fees,
        address to,
        uint deadline
    ) external virtual override payable ensure(deadline) {
        require(path[0] == WETH, 'BabyRouter');
        uint amountIn = msg.value;
        IWETH(WETH).deposit{value: amountIn}();
        amountIn = routerFee(factories[0], msg.sender, path[0], amountIn);
        assert(IWETH(WETH).transfer(BabyLibrarySmartRouter.pairFor(factories[0], path[0], path[1]), amountIn));
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, factories, fees, to);
        uint balanceAfter = IERC20(path[path.length - 1]).balanceOf(to);
        require(
            balanceAfter.sub(balanceBefore) >= amountOutMin,
            'BabyRouter: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] memory path,
        address[] memory factories,
        uint[] memory fees,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) {
        require(path[path.length - 1] == WETH, 'BabyRouter: INVALID_PATH');
        amountIn = routerFee(factories[0], msg.sender, path[0], amountIn);
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, BabyLibrarySmartRouter.pairFor(factories[0], path[0], path[1]), amountIn
        );
        _swapSupportingFeeOnTransferTokens(path, factories, fees, address(this));
        uint amountOut = IERC20(WETH).balanceOf(address(this));
        require(amountOut >= amountOutMin, 'BabyRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).withdraw(amountOut);
        TransferHelper.safeTransferETH(to, amountOut);
    }
}