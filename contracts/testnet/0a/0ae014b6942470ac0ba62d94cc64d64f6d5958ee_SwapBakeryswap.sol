/**
 *Submitted for verification at BscScan.com on 2022-06-27
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

//import {IBakerySwapRouter} from './resources/IBakerySwapRouter.sol';
interface IBakerySwapRouter {
    function factory() external pure returns (address);

    function WBNB() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityBNB(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountBNBMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountBNB,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityBNB(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountBNBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountBNB);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityBNBWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountBNBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountBNB);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactBNBForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactBNB(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForBNB(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapBNBForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function removeLiquidityBNBSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountBNBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountBNB);

    function removeLiquidityBNBWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountBNBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountBNB);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactBNBForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForBNBSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

//import {IBakerySwapPair} from './resources/IBakerySwapPair.sol';
interface IBakerySwapPair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

//import {UQ112x112} from './resources/UQ112x112.sol';
library UQ112x112 {
    uint224 constant Q112 = 2**112;

    // encode a uint112 as a UQ112x112
    function encode(uint112 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112; // never overflows
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        z = x / uint224(y);
    }
}

//import {SafeMath} from './resources/SafeMath.sol';
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

//import {TransferHelper} from './resources/TransferHelper.sol';
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper: BNB_TRANSFER_FAILED');
    }
}

//import {IWBNB} from './resources/IWBNB.sol';
interface IWBNB {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;

    function balanceOf(address owner) external view returns (uint); // Added by me

    function approve(address spender, uint256 amount) external returns (bool); // Added by me
}

//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

//import "@openzeppelin/contracts/utils/Context.sol";
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

//import "@openzeppelin/contracts/access/Ownable.sol";
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


// Bakeryswap Router BSC Mainnet: 0xCDe540d7eAFE93aC5fE6233Bee57E1270D3E330F
// Bakeryswap Router BSC Testnet: 0xCDe540d7eAFE93aC5fE6233Bee57E1270D3E330F
// Bakeryswap Factory BSC Testnet: 0x01bF7C66c6BD861915CdaaE475042d3c4BaE16A7
// USDT: 0xD05A097B1Dc5Bd0733b9460fa562497278F55E36, 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684, 0x337610d27c682E347C9cD60BD4b3b107C9d34dDd (he encontrado hasta 3 versiones de USDT en este DEX)
// WBNB: 0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F
// BUSD: 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee
// Default Pools: BNB-BUSD, BNB-USDT, BUSD-USDT, USDT-DAI, BUSD-ETH, USDT-ETH
// Pair example: https://testnet.bscscan.com/address/0xAf5e8AA68dd1b61376aC4F6fa4D06A5A4AB6cafD#code [WBNB, BUSD]

// Path: [0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F, (0xD05A097B1Dc5Bd0733b9460fa562497278F55E36,0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684,0x337610d27c682E347C9cD60BD4b3b107C9d34dDd)]
// Max range uint256: 115792089237316195423570985008687907853269984665640564039457584007913129639935
// https://amm.kiemtienonline360.com/
contract SwapBakeryswap is Ownable {

    using SafeMath for uint;
    using UQ112x112 for uint224;

    IBakerySwapRouter private constant bakeryswapRouter = IBakerySwapRouter(0xCDe540d7eAFE93aC5fE6233Bee57E1270D3E330F);
    address private constant WBNB = 0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F;

    modifier ensureOffset(uint deadlineOffset) {
        require((block.timestamp+deadlineOffset) >= block.timestamp, 'EXPIRED');
        _;
    }


    constructor() Ownable() {}

    /**
    amountIn (uint256)
        - 500000000000000000 (0.5 USDT for example)
    path (address[]): I can use whatever ERC20 token I want that has liquidity in Bakeryswap. Remember that if a use WBNB, I will get the ERC20 WBNB equivalent and not the native WBNB (BNB). The diffecence between
                      the native BNB and the ERC20 WBNB is that native BNB appears in the "Balance:" field in bscscan, and the ERC20 WBNB equivalente appears in the "Token:" drop-down list.
        - [(0xD05A097B1Dc5Bd0733b9460fa562497278F55E36,0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684,0x337610d27c682E347C9cD60BD4b3b107C9d34dDd), 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee] [USDT, BUSD]
        - [(0xD05A097B1Dc5Bd0733b9460fa562497278F55E36,0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684,0x337610d27c682E347C9cD60BD4b3b107C9d34dDd), 0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F] [UDST, WBNB]
        - [(0xD05A097B1Dc5Bd0733b9460fa562497278F55E36,0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684,0x337610d27c682E347C9cD60BD4b3b107C9d34dDd), 0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F, 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee] [UDST, WBNB, BUSD]
    deadlineOffset (uint256):
        - current + deadlineOffset
     */
    function tradeExactTokenForToken(uint256 amountIn, address[] calldata path, uint256 deadlineOffset) external onlyOwner {
        require(path.length >= 2, "Length of path needs to be 2 at least");


        // Approve that input token IERC20(path[0]) can be spent by the Router
        IERC20(path[0]).approve(
            address(0xCDe540d7eAFE93aC5fE6233Bee57E1270D3E330F),
            amountIn // type(uint256).max
        ); 
        // Very useful link: https://docs.uniswap.org/protocol/V2/guides/smart-contract-integration/trading-from-a-smart-contract
        //  This previous link practically confirms to me that the approve method needs to be called inside the contract because this way the signer is this contract 
        //  and not the wallet, because after the transfer of the source token from the wallet to the contract, THE CONTRACT is the one that has the tokens to buy/perform the swap,
        //  so THE CONTRACT should be the one signing the approval.


        // As the source token is ERC20 I have to make a transfer from the wallet to this 
        // contract, as it is the wallet that has the source token that I will use to buy.
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        // Remember to approve (outside of this contract, i.e. bscscan) that this input token IERC20(path[0]) can be spent by this contract SwapBakeryswap.
        // [TODO] I need to run the approve function outside of this solidity code because I do not know the address of this deployed contract before deploying it...
        // maybe I can investigate because maybe it is easy to calculate with "create2" assembly instruction, but I do not know: Token contract: (path[0]); spender: This deployed contract;
        // amount: max or whatever

        // [TODO] This can be optimiced by creating a contract that already has the tokens to buy/perform the swaps. This way I could get rid of the transferFrom function and maybe I would only need
        // to call the approve function once (with type(uint256).max amount).
        

        bakeryswapRouter.swapExactTokensForTokens(
            amountIn,
            0, // amountOutMin,
            path,
            owner(), // to (receiver)
            block.timestamp + deadlineOffset
        );
    }

    /**
    tradeExactBNBForToken
        payableAmount(BNB): 0.02 (se usan numeros decimales normales, no wei ni nada de eso, directamente 0.02BNB en este caso por ejemplo)
    path (address[]): Source token (input token) must always be WBNB, although it will be treated as native WBNB, that is, BNB. This means that the token WBNB that we might have in the wallet/contract will not get modified but the BNB field is the thing that matters
        [0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F, 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee] [WBNB, BUSD]
        [0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F, (0xD05A097B1Dc5Bd0733b9460fa562497278F55E36,0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684,0x337610d27c682E347C9cD60BD4b3b107C9d34dDd)] [WBNB (treated as native BNB), USDT]
        [0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F, 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee, (0xD05A097B1Dc5Bd0733b9460fa562497278F55E36,0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684,0x337610d27c682E347C9cD60BD4b3b107C9d34dDd)] [WBNB(native), BUSD, UDST]
    deadlineOffset (uint256):
        It should be the unix epoc time (https://www.epochconverter.com/) deadline, but in our function we provide the offset because
        the current unix epoc time is automatically obtanined and then the offset is added to the current time resulting in the final deadline, for example something like: 1655653309
     
     This function needs to be "payable" as I will pay/send native BNB (ETHER) to this function as it is required by the swapExactBNBForTokens function, which needs native BNB as the input of the swap
     */
    function tradeExactBNBForToken(address[] calldata path, uint256 deadlineOffset) external payable onlyOwner {
        require(path.length >= 2, "Length of path needs to be 2 at least");

        // As the source token is NOT ERC20 but the native BNB token, no transfer from the wallet to this contract 
        // is needed, as the BNB of the wallet will be used directly to transfer it to the contract 
        // with the {value: msg.value} part.
        bakeryswapRouter.swapExactBNBForTokens{value: msg.value}( // [HINT]: Here we are using the global variable msg.value, but remember that we could use a hardcoded/dynamic wei value like {value: 10000000000000000}, which is 0.01BNB
            0, // amountOutMin,
            path,
            owner(), // to (receiver)
            block.timestamp + deadlineOffset
        );
    }

    /**
    amountIn (uint256)
        - 5000000000000000000 (0.5 USDT for example)
    path (address[]): The output token must always be WBNB, although it will be treated as native WBNB, that is, BNB. This means that I will not get WBNB as the output token but I will get BNB directly
        - [(0xD05A097B1Dc5Bd0733b9460fa562497278F55E36,0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684,0x337610d27c682E347C9cD60BD4b3b107C9d34dDd), 0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F] [UDST, WBNB]
        - [(0xD05A097B1Dc5Bd0733b9460fa562497278F55E36,0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684,0x337610d27c682E347C9cD60BD4b3b107C9d34dDd), 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee, 0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F] [UDST, BUSD, WBNB]
    to (address)
        - owner()
    deadlineOffset (uint256):
        - current + deadlineOffset

    This function does not need to be "payable" as I will not pay native BNB (ETHER) to this function, I will just receive BNB but not pay in BNB.
     */
    function tradeExactTokenForBNB(uint256 amountIn, address[] calldata path, uint256 deadlineOffset) external onlyOwner {
        require(path.length >= 2, "Length of path needs to be 2 at least");

        // Approve that input token IERC20(path[0]) can be spent by the Router
        IERC20(path[0]).approve(
            address(0xCDe540d7eAFE93aC5fE6233Bee57E1270D3E330F),
            amountIn // type(uint256).max
        ); 
        
        // As the source token is ERC20 I have to make a transfer from the wallet to this 
        // contract, as it is the wallet that has the source token that I will use to buy.
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        // Remember to approve (outside of this contract, i.e. bscscan) that this input token IERC20(path[0]) can be spent by this contract SwapBakeryswap.

        bakeryswapRouter.swapExactTokensForBNB(
            amountIn,
            0, // amountOutMin,
            path,
            owner(),
            block.timestamp + deadlineOffset
        );
    }




    /**
    amountIn (uint256)
        - 500000000000000000 (0.5 USDT for example)
    pairAddress:
        - 0x9ec56045FE732ee4e67aCD5830Fe79dDdFbCfa19 [0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684-0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F] [USDT-ẂBNB]
        - 0xa38661A1Aa00ab39ACD6f276Ed6a21C90A83Ae6b [0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F-0x337610d27c682E347C9cD60BD4b3b107C9d34dDd] [WBNB-USDT]
        - 0xAf5e8AA68dd1b61376aC4F6fa4D06A5A4AB6cafD (BUSD-WBNB)
    inputIsToken0:
        - true if token0 is the input token, so token1 will be the output
        - false if token1 is the input token, so token0 will be the output
    to (address)
        - owner()
    deadlineOffset (uint256):
        - current + deadlineOffset

    Remember to approve (outside of this contract, i.e. bscscan) that THE input token token0 or token1 can be spent by this contract SwapPancakeswap.
    115792089237316195423570985008687907853269984665640564039457584007913129639935

    Ideas: 
        - No quiero usar el Factory ni el Router, todo tiene que hacerse con exclusivamente el Pair e indicando cuales de los dos tokens (token0, token1) es el input... yo creo
        que con solo esto es suficiente
        - Como trabajo directamente sobre el Pair, no tiene sentido establecer el address[] path ya que siempre será un path de dos tokens (token0 y token1) donde solo cambiará el token de input/output
        según sea el sentido del swap.
        - Como mucho podria plantearse que el fee sea pasado por parametro


    Pair USDT-BUSD Bakeryswap: 
        - bscscan: https://testnet.bscscan.com/address/
        - Address: 
        - token0: 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee (BUSD)
        - token1: (0xD05A097B1Dc5Bd0733b9460fa562497278F55E36,0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684,0x337610d27c682E347C9cD60BD4b3b107C9d34dDd) (USDT)
    Pair USDT-WBNB Bakeryswap: 
        - bscscan: https://testnet.bscscan.com/address/
        - Address: 
        - token0: (0xD05A097B1Dc5Bd0733b9460fa562497278F55E36,0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684,0x337610d27c682E347C9cD60BD4b3b107C9d34dDd) (USDT)
        - token1: 0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F (WBNB)
            - Pair1: 0x9ec56045FE732ee4e67aCD5830Fe79dDdFbCfa19 [0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684-0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F] [USDT-ẂBNB]
            - Pair2: 0xa38661A1Aa00ab39ACD6f276Ed6a21C90A83Ae6b [0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F-0x337610d27c682E347C9cD60BD4b3b107C9d34dDd] [WBNB-USDT]
    Pair BUSD-WBNB Bakeryswap: 
        - bscscan: https://testnet.bscscan.com/address/0xAf5e8AA68dd1b61376aC4F6fa4D06A5A4AB6cafD
        - Address: 0xAf5e8AA68dd1b61376aC4F6fa4D06A5A4AB6cafD
        - token0: 0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F (WBNB)
        - token1: 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee (BUSD)
     */
    function tradeExactTokenForToken_pairMethod(uint256 amountIn, address pairAddress, bool inputIsToken0, address receiver, uint256 deadlineOffset) external onlyOwner ensureOffset(deadlineOffset){
        
        // Obtain reseves of both tokens in the pair. Remember that the reserve0 and reserve1 are ordered
        // by the ordering of the token0 and token1, so it would be important to handle this requirement properly
        // so that when calling this functions from the outside the inputIsToken0 parameter is correctly configured
        (uint112 reserve0, uint112 reserve1,) = IBakerySwapPair(pairAddress).getReserves();

        require(amountIn > 0, 'INSUFFICIENT_INPUT_AMOUNT');
        require(reserve0 > 0 && reserve1 > 0, 'INSUFFICIENT_LIQUIDITY');

        /*uint amountInWithFee = 0;
        uint numerator = 0;
        uint denominator = 0;
        uint amountOut = 0;*/

        uint amountOut = 0;

        if(inputIsToken0){
            /*
            amountInWithFee = amountIn.mul(998); //Fee
            numerator = amountInWithFee.mul(reserve1);
            denominator = uint(reserve0).mul(1000).add(amountInWithFee);
            amountOut = numerator / denominator;*/
            amountOut = getAmountOut(amountIn, reserve0, reserve1);
        }else{
            /*
            amountInWithFee = amountIn.mul(998); //Fee
            numerator = amountInWithFee.mul(reserve0);
            denominator = uint(reserve1).mul(1000).add(amountInWithFee);
            amountOut = numerator / denominator;*/
            amountOut = getAmountOut(amountIn, reserve1, reserve0);
        }
        

        // Now that we know the amount of tokens that we are going to RECEIVE from the swap
        // we need to transfer the input tokens to the pair contract
        // As the source token is ERC20 I have to make a transfer from the wallet to this 
        // contract, as it is the wallet that has the source token that I will use to buy.
        // Be aware that a contract centric approach will mean that the contract is the one having the tokens
        // so the transfer would go from this contract (address(this)) to the pair instead of from the wallet to the pair,
        // but in this code we are using a wallect centric approach so the wallet address is used
        if(inputIsToken0){
            IERC20(IBakerySwapPair(pairAddress).token0()).transferFrom(msg.sender, address(pairAddress), amountIn);
        }else{
            IERC20(IBakerySwapPair(pairAddress).token1()).transferFrom(msg.sender, address(pairAddress), amountIn);
        }
        // Remember to approve (outside of this contract, i.e. bscscan) that this input token IERC20(path[0]) can be spent by this contract SwapPancakeswap.

        // Now I can perform the swap using the pair contract
        //(uint amount0Out, uint amount1Out) = inputIsToken0 ? (uint(0), amountOut) : (amountOut, uint(0));
        if(inputIsToken0){
            IBakerySwapPair(pairAddress).swap(uint(0), amountOut, receiver); // receiver should be the the owner(sender/wallet)... but if a concatenation of pair swaps is performed, then the receiver should be the next pair address in the "path" and just the last swap would have the owner in the receiver parameter
        }else{
            IBakerySwapPair(pairAddress).swap(amountOut, uint(0), receiver); // receiver should be the the owner(sender/wallet)... but if a concatenation of pair swaps is performed, then the receiver should be the next pair address in the "path" and just the last swap would have the owner in the receiver parameter
        }
    }


    /**
    amountIn (uint256)
        - 500000000000000000 (0.5 USDT for example)
    pairAddress:
        - 0x9ec56045FE732ee4e67aCD5830Fe79dDdFbCfa19 [0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684-0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F] [USDT-ẂBNB]
        - 0xa38661A1Aa00ab39ACD6f276Ed6a21C90A83Ae6b [0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F-0x337610d27c682E347C9cD60BD4b3b107C9d34dDd] [WBNB-USDT]
        - 0xAf5e8AA68dd1b61376aC4F6fa4D06A5A4AB6cafD (BUSD-WBNB)
    inputIsToken0:
        - true if token0 is the input token, so token1 will be the output
        - false if token1 is the input token, so token0 will be the output
    receiver (address)
        - owner()
    deadlineOffset (uint256):
        - current + deadlineOffset

    Remember to approve (outside of this contract, i.e. bscscan) that THE input token token0 or token1 can be spent by this contract SwapPancakeswap.
    115792089237316195423570985008687907853269984665640564039457584007913129639935

    Ideas: 
        - No quiero usar el Factory ni el Router, todo tiene que hacerse con exclusivamente el Pair e indicando cuales de los dos tokens (token0, token1) es el input... yo creo
        que con solo esto es suficiente
        - Como trabajo directamente sobre el Pair, no tiene sentido establecer el address[] path ya que siempre será un path de dos tokens (token0 y token1) donde solo cambiará el token de input/output
        según sea el sentido del swap.
        - Como mucho podria plantearse que el fee sea pasado por parametro

    Pair USDT-BUSD Bakeryswap: 
        - bscscan: https://testnet.bscscan.com/address/
        - Address: 
        - token0: 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee (BUSD)
        - token1: (0xD05A097B1Dc5Bd0733b9460fa562497278F55E36,0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684,0x337610d27c682E347C9cD60BD4b3b107C9d34dDd) (USDT)
    Pair USDT-WBNB Bakeryswap: 
        - bscscan: https://testnet.bscscan.com/address/
        - Address: 
        - token0: (0xD05A097B1Dc5Bd0733b9460fa562497278F55E36,0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684,0x337610d27c682E347C9cD60BD4b3b107C9d34dDd) (USDT)
        - token1: 0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F (WBNB)
            - Pair1: 0x9ec56045FE732ee4e67aCD5830Fe79dDdFbCfa19 [0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684-0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F] [USDT-ẂBNB]
            - Pair2: 0xa38661A1Aa00ab39ACD6f276Ed6a21C90A83Ae6b [0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F-0x337610d27c682E347C9cD60BD4b3b107C9d34dDd] [WBNB-USDT]
    Pair BUSD-WBNB Bakeryswap: 
        - bscscan: https://testnet.bscscan.com/address/0xAf5e8AA68dd1b61376aC4F6fa4D06A5A4AB6cafD
        - Address: 0xAf5e8AA68dd1b61376aC4F6fa4D06A5A4AB6cafD
        - token0: 0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F (WBNB)
        - token1: 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee (BUSD)
     */
    function tradeTokenForExactToken_pairMethod(uint256 amountOut, address pairAddress, bool inputIsToken0, address receiver, uint256 deadlineOffset) external onlyOwner ensureOffset(deadlineOffset){
        
        // Obtain reseves of both tokens in the pair. Remember that the reserve0 and reserve1 are ordered
        // by the ordering of the token0 and token1, so it would be important to handle this requirement properly
        // so that when calling this functions from the outside the inputIsToken0 parameter is correctly configured
        (uint112 reserve0, uint112 reserve1,) = IBakerySwapPair(pairAddress).getReserves();
        require(amountOut > 0, 'INSUFFICIENT_INPUT_AMOUNT');
        require(reserve0 > 0 && reserve1 > 0, 'INSUFFICIENT_LIQUIDITY');


        uint amountIn = 0;
        if(inputIsToken0){
            amountIn = getAmountIn(amountOut, reserve0, reserve1);
        }else{
            amountIn = getAmountIn(amountOut, reserve1, reserve0);
        }
        

        // Now that we know the amount of tokens that we are going to SEND from the swap
        // we need to transfer the input tokens to the pair contract
        // As the source token is ERC20 I have to make a transfer from the wallet to this 
        // contract, as it is the wallet that has the source token that I will use to buy.
        // Be aware that a contract centric approach will mean that the contract is the one having the tokens
        // so the transfer would go from this contract (address(this)) to the pair instead of from the wallet to the pair,
        // but in this code we are using a wallect centric approach so the wallet address is used
        if(inputIsToken0){
            IERC20(IBakerySwapPair(pairAddress).token0()).transferFrom(msg.sender, address(pairAddress), amountIn);
        }else{
            IERC20(IBakerySwapPair(pairAddress).token1()).transferFrom(msg.sender, address(pairAddress), amountIn);
        }
        // Remember to approve (outside of this contract, i.e. bscscan) that this input token IERC20(path[0]) can be spent by this contract SwapPancakeswap.


        // Now I can perform the swap using the pair contract
        //(uint amount0Out, uint amount1Out) = inputIsToken0 ? (uint(0), amountOut) : (amountOut, uint(0));
        if(inputIsToken0){
            IBakerySwapPair(pairAddress).swap(uint(0), amountOut, receiver); // receiver should be the the owner(sender/wallet)... but if a concatenation of pair swaps is performed, then the receiver should be the next pair address in the "path" and just the last swap would have the owner in the receiver parameter
        }else{
            IBakerySwapPair(pairAddress).swap(amountOut, uint(0), receiver); // receiver should be the the owner(sender/wallet)... but if a concatenation of pair swaps is performed, then the receiver should be the next pair address in the "path" and just the last swap would have the owner in the receiver parameter
        }
    }


    /**
    tradeExactBNBForToken_pairMethod
        payableAmount(BNB): 0.02 (se usan numeros decimales normales, no wei ni nada de eso, directamente 0.02BNB en este caso por ejemplo)
    pairAddress:
        - 0x9ec56045FE732ee4e67aCD5830Fe79dDdFbCfa19 [0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684-0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F] [USDT-ẂBNB]
        - 0xa38661A1Aa00ab39ACD6f276Ed6a21C90A83Ae6b [0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F-0x337610d27c682E347C9cD60BD4b3b107C9d34dDd] [WBNB-USDT]
        - 0xAf5e8AA68dd1b61376aC4F6fa4D06A5A4AB6cafD (BUSD-WBNB)
    receiver (address)
        - owner()
    deadlineOffset (uint256):
        - current + deadlineOffset
    */
    function tradeExactBNBForToken_pairMethod(address pairAddress, address receiver, uint256 deadlineOffset) external payable onlyOwner ensureOffset(deadlineOffset){

        require(IBakerySwapPair(pairAddress).token0()==address(0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F) || IBakerySwapPair(pairAddress).token1()==address(0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F), 'PAIR_DOES_NOT_HAVE_WETH');

        // Obtain reseves of both tokens in the pair. Remember that the reserve0 and reserve1 are ordered
        // by the ordering of the token0 and token1, so it would be important to handle this requirement properly
        // so that when calling this functions from the outside the inputIsToken0 parameter is correctly configured
        (uint112 reserve0, uint112 reserve1,) = IBakerySwapPair(pairAddress).getReserves();

        require(msg.value > 0, 'INSUFFICIENT_INPUT_AMOUNT');
        require(reserve0 > 0 && reserve1 > 0, 'INSUFFICIENT_LIQUIDITY');
        

        uint amountOut = 0;
        if(IBakerySwapPair(pairAddress).token0()==address(0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F)){
            amountOut = getAmountOut(msg.value, reserve0, reserve1);
        }else{
            amountOut = getAmountOut(msg.value, reserve1, reserve0);
        }
        

        // Now that we know the amount of tokens that we are going to RECEIVE from the swap
        // we need to transfer the input tokens to the pair contract
        // As the source token is native ETH(BNB) the way to make a transfer from the wallet to this 
        // contract is a bit peculiar.
        // The way to deposit ETH(BNB) into the WETH contract is by the deposit function:
        IWBNB(WBNB).deposit{value: msg.value}();
        assert(IWBNB(WBNB).transfer(address(pairAddress), msg.value));
        // There is no need to approve (outside of this contract, i.e. bscscan) that this input token 0xc47e3819d527fD16de13dAfCF34F4FE50821665e can be spent by this contract SwapPancakeswap.

        // Now I can perform the swap using the pair contract
        //(uint amount0Out, uint amount1Out) = pairAddress.token0()==0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F ? (uint(0), amountOut) : (amountOut, uint(0));
        if(IBakerySwapPair(pairAddress).token0()==address(0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F)){
            IBakerySwapPair(pairAddress).swap(uint(0), amountOut, receiver); // receiver should be the the owner(sender/wallet)... but if a concatenation of pair swaps is performed, then the receiver should be the next pair address in the "path" and just the last swap would have the owner in the receiver parameter
        }else{
            IBakerySwapPair(pairAddress).swap(amountOut, uint(0), receiver); // receiver should be the the owner(sender/wallet)... but if a concatenation of pair swaps is performed, then the receiver should be the next pair address in the "path" and just the last swap would have the owner in the receiver parameter
        }
    }


    /**
    tradeExactBNBForToken_pairMethod
        payableAmount(BNB): 0.02 (se usan numeros decimales normales, no wei ni nada de eso, directamente 0.02BNB en este caso por ejemplo)
    amountOut:
        3000000000000000000 (3 USDT for example)
    pairAddress:
        - 0x9ec56045FE732ee4e67aCD5830Fe79dDdFbCfa19 [0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684-0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F] [USDT-ẂBNB]
        - 0xa38661A1Aa00ab39ACD6f276Ed6a21C90A83Ae6b [0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F-0x337610d27c682E347C9cD60BD4b3b107C9d34dDd] [WBNB-USDT]
        - 0xAf5e8AA68dd1b61376aC4F6fa4D06A5A4AB6cafD (BUSD-WBNB)
    receiver (address)
        - owner()
    deadlineOffset (uint256):
        - current + deadlineOffset
    */
    function tradeBNBForExactToken_pairMethod(uint amountOut, address pairAddress, address receiver, uint256 deadlineOffset) external payable onlyOwner ensureOffset(deadlineOffset){

        require(IBakerySwapPair(pairAddress).token0()==address(0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F) || IBakerySwapPair(pairAddress).token1()==address(0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F), 'PAIR_DOES_NOT_HAVE_WETH');

        // Obtain reseves of both tokens in the pair. Remember that the reserve0 and reserve1 are ordered
        // by the ordering of the token0 and token1, so it would be important to handle this requirement properly
        // so that when calling this functions from the outside the inputIsToken0 parameter is correctly configured
        (uint112 reserve0, uint112 reserve1,) = IBakerySwapPair(pairAddress).getReserves();

        require(amountOut > 0, 'INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserve0 > 0 && reserve1 > 0, 'INSUFFICIENT_LIQUIDITY');
        

        uint amountIn = 0;
        if(IBakerySwapPair(pairAddress).token0()==address(0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F)){
            amountIn = getAmountIn(amountOut, reserve0, reserve1);
        }else{
            amountIn = getAmountIn(amountOut, reserve1, reserve0);
        }
        

        // Now that we know the amount of tokens that we are going to SEND from the swap
        // we need to transfer the input tokens to the pair contract
        // As the source token is native ETH(BNB) the way to make a transfer from the wallet to this 
        // contract is a bit peculiar.
        // The way to deposit ETH(BNB) into the WETH contract is by the deposit function:
        IWBNB(WBNB).deposit{value: amountIn}();
        assert(IWBNB(WBNB).transfer(address(pairAddress), amountIn));
        // There is no need to approve (outside of this contract, i.e. bscscan) that this input token 0xc47e3819d527fD16de13dAfCF34F4FE50821665e can be spent by this contract SwapPancakeswap.

        // Now I can perform the swap using the pair contract
        //(uint amount0Out, uint amount1Out) = pairAddress.token0()==0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F ? (uint(0), amountOut) : (amountOut, uint(0));
        if(IBakerySwapPair(pairAddress).token0()==address(0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F)){
            IBakerySwapPair(pairAddress).swap(uint(0), amountOut, receiver); // receiver should be the the owner(sender/wallet)... but if a concatenation of pair swaps is performed, then the receiver should be the next pair address in the "path" and just the last swap would have the owner in the receiver parameter
        }else{
            IBakerySwapPair(pairAddress).swap(amountOut, uint(0), receiver); // receiver should be the the owner(sender/wallet)... but if a concatenation of pair swaps is performed, then the receiver should be the next pair address in the "path" and just the last swap would have the owner in the receiver parameter
        }

        // refund dust eth, if any
        if (msg.value > amountIn){
            TransferHelper.safeTransferBNB(receiver, msg.value - amountIn);
        }
    }


    /**
    amountIn (uint256)
        - 5000000000000000000 (0.5 USDT for example)
    pairAddress:
        - 0x9ec56045FE732ee4e67aCD5830Fe79dDdFbCfa19 [0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684-0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F] [USDT-ẂBNB]
        - 0xa38661A1Aa00ab39ACD6f276Ed6a21C90A83Ae6b [0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F-0x337610d27c682E347C9cD60BD4b3b107C9d34dDd] [WBNB-USDT]
        - 0xAf5e8AA68dd1b61376aC4F6fa4D06A5A4AB6cafD (BUSD-WBNB)
    receiver (address)
        - owner()
    deadlineOffset (uint256):
        - current + deadlineOffset

    Remember to approve (outside of this contract, i.e. bscscan) that this input token token0 or token1 (the one that is not WETH) can be spent by this contract SwapPancakeswap.
    115792089237316195423570985008687907853269984665640564039457584007913129639935

    This function does not need to be "payable" as I will not pay native BNB (ETHER) to this function, I will just receive BNB but not pay in BNB.
    */
    function tradeExactTokenForBNB_pairMethod(uint256 amountIn, address pairAddress, address receiver, uint256 deadlineOffset) external onlyOwner ensureOffset(deadlineOffset){
        
        require(IBakerySwapPair(pairAddress).token0()==address(0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F) || IBakerySwapPair(pairAddress).token1()==address(0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F), 'PAIR_DOES_NOT_HAVE_WETH');

        // Obtain reseves of both tokens in the pair. Remember that the reserve0 and reserve1 are ordered
        // by the ordering of the token0 and token1, so it would be important to handle this requirement properly
        // so that when calling this functions from the outside the inputIsToken0 parameter is correctly configured
        (uint112 reserve0, uint112 reserve1,) = IBakerySwapPair(pairAddress).getReserves();
        require(amountIn > 0, 'INSUFFICIENT_INPUT_AMOUNT');
        require(reserve0 > 0 && reserve1 > 0, 'INSUFFICIENT_LIQUIDITY');


        uint amountOut = 0;
        if(IBakerySwapPair(pairAddress).token0()!=address(0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F)){
            amountOut = getAmountOut(amountIn, reserve0, reserve1);
        }else{
            amountOut = getAmountOut(amountIn, reserve1, reserve0);
        }
        

        // Now that we know the amount of tokens that we are going to RECEIVE from the swap
        // we need to transfer the input tokens to the pair contract
        // As the source token is ERC20 I have to make a transfer from the wallet to this 
        // contract, as it is the wallet that has the source token that I will use to buy.
        // Be aware that a contract centric approach will mean that the contract is the one having the tokens
        // so the transfer would go from this contract (address(this)) to the pair instead of from the wallet to the pair,
        // but in this code we are using a wallect centric approach so the wallet address is used
        if(IBakerySwapPair(pairAddress).token0()!=address(0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F)){
            IERC20(IBakerySwapPair(pairAddress).token0()).transferFrom(msg.sender, address(pairAddress), amountIn);
        }else{
            IERC20(IBakerySwapPair(pairAddress).token1()).transferFrom(msg.sender, address(pairAddress), amountIn);
        }
        // Remember to approve (outside of this contract, i.e. bscscan) that this input token token0 or token1 (the one that is not WETH) can be spent by this contract SwapPancakeswap.

        // Now I can perform the swap using the pair contract. but the peculiarity of this swap is that the receiver is going to be this contract SwapPancakeswap address and not the owner(sender/wallet), t his is VERY important in order for the withdraw to work properly
        //(uint amount0Out, uint amount1Out) = IBakerySwapPair(pairAddress).token0()!=address(0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F) ? (uint(0), amountOut) : (amountOut, uint(0));
        if(IBakerySwapPair(pairAddress).token0()!=address(0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F)){
            IBakerySwapPair(pairAddress).swap(uint(0), amountOut, address(this)); // receiver should must be this contract, otherwise the IWBNB(...).withdraw function will not work
        }else{
            IBakerySwapPair(pairAddress).swap(amountOut, uint(0), address(this)); // receiver should must be this contract, otherwise the IWBNB(...).withdraw function will not work
        }

        require(IWBNB(WBNB).balanceOf(address(this)) > 0, 'INSUFFICIENT_WETH_AMOUNT_CONTRACT');
        require(IWBNB(WBNB).balanceOf(address(this)) >= amountOut, 'AMOUNTOUT_HIGHER_THAN_WETH_BALANCE');

        IWBNB(WBNB).withdraw(amountOut); // IMPORTANT: Remember that this contract is the one that needs to have the WETH(WBNB) 
                                                                               // tokens (this is done in the .swap by using address(this)), and also remember to have 
                                                                               // the receive/fallback function so that this contract can receive native ETH(BNB) 
                                                                               // from this withdraw operation
        TransferHelper.safeTransferBNB(receiver, amountOut); // receiver should be the owner()
    }

    /**
    amountOut (uint256)
        - 3500000000000000 (0.0035 BNB for example)
    pairAddress:
        - 0x9ec56045FE732ee4e67aCD5830Fe79dDdFbCfa19 [0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684-0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F] [USDT-ẂBNB]
        - 0xa38661A1Aa00ab39ACD6f276Ed6a21C90A83Ae6b [0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F-0x337610d27c682E347C9cD60BD4b3b107C9d34dDd] [WBNB-USDT]
        - 0xAf5e8AA68dd1b61376aC4F6fa4D06A5A4AB6cafD (BUSD-WBNB)
    receiver (address)
        - owner()
    deadlineOffset (uint256):
        - current + deadlineOffset

    Remember to approve (outside of this contract, i.e. bscscan) that this input token token0 or token1 (the one that is not WETH) can be spent by this contract SwapPancakeswap.
    115792089237316195423570985008687907853269984665640564039457584007913129639935

    This function does not need to be "payable" as I will not pay native BNB (ETHER) to this function, I will just receive BNB but not pay in BNB.
    */
    function tradeTokenForExactBNB_pairMethod(uint256 amountOut, address pairAddress, address receiver, uint256 deadlineOffset) external onlyOwner ensureOffset(deadlineOffset){
        
        require(IBakerySwapPair(pairAddress).token0()==address(0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F) || IBakerySwapPair(pairAddress).token1()==address(0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F), 'PAIR_DOES_NOT_HAVE_WETH');

        // Obtain reseves of both tokens in the pair. Remember that the reserve0 and reserve1 are ordered
        // by the ordering of the token0 and token1, so it would be important to handle this requirement properly
        // so that when calling this functions from the outside the inputIsToken0 parameter is correctly configured
        (uint112 reserve0, uint112 reserve1,) = IBakerySwapPair(pairAddress).getReserves();
        require(amountOut > 0, 'INSUFFICIENT_INPUT_AMOUNT');
        require(reserve0 > 0 && reserve1 > 0, 'INSUFFICIENT_LIQUIDITY');


        uint amountIn = 0;
        if(IBakerySwapPair(pairAddress).token0()!=address(0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F)){
            amountIn = getAmountIn(amountOut, reserve0, reserve1);
        }else{
            amountIn = getAmountIn(amountOut, reserve1, reserve0);
        }
        

        // Now that we know the amount of tokens that we are going to SEND from the swap
        // we need to transfer the input tokens to the pair contract
        // As the source token is ERC20 I have to make a transfer from the wallet to this 
        // contract, as it is the wallet that has the source token that I will use to buy.
        // Be aware that a contract centric approach will mean that the contract is the one having the tokens
        // so the transfer would go from this contract (address(this)) to the pair instead of from the wallet to the pair,
        // but in this code we are using a wallect centric approach so the wallet address is used
        if(IBakerySwapPair(pairAddress).token0()!=address(0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F)){
            IERC20(IBakerySwapPair(pairAddress).token0()).transferFrom(msg.sender, address(pairAddress), amountIn);
        }else{
            IERC20(IBakerySwapPair(pairAddress).token1()).transferFrom(msg.sender, address(pairAddress), amountIn);
        }
        // Remember to approve (outside of this contract, i.e. bscscan) that this input token token0 or token1 (the one that is not WETH) can be spent by this contract SwapPancakeswap.

        // Now I can perform the swap using the pair contract. but the peculiarity of this swap is that the receiver is going to be this contract SwapPancakeswap address and not the owner(sender/wallet), t his is VERY important in order for the withdraw to work properly
        //(uint amount0Out, uint amount1Out) = IBakerySwapPair(pairAddress).token0()!=address(0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F) ? (uint(0), amountOut) : (amountOut, uint(0));
        if(IBakerySwapPair(pairAddress).token0()!=address(0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F)){
            IBakerySwapPair(pairAddress).swap(uint(0), amountOut, address(this)); // receiver should must be this contract, otherwise the IWBNB(...).withdraw function will not work
        }else{
            IBakerySwapPair(pairAddress).swap(amountOut, uint(0), address(this)); // receiver should must be this contract, otherwise the IWBNB(...).withdraw function will not work
        }

        require(IWBNB(WBNB).balanceOf(address(this)) > 0, 'INSUFFICIENT_WETH_AMOUNT_CONTRACT');
        require(IWBNB(WBNB).balanceOf(address(this)) >= amountOut, 'AMOUNTOUT_HIGHER_THAN_WETH_BALANCE');

        IWBNB(WBNB).withdraw(amountOut); // IMPORTANT: Remember that this contract is the one that needs to have the WETH(WBNB) 
                                                                               // tokens (this is done in the .swap by using address(this)), and also remember to have 
                                                                               // the receive/fallback function so that this contract can receive native ETH(BNB) 
                                                                               // from this withdraw operation
        TransferHelper.safeTransferBNB(receiver, amountOut); // receiver should be the owner()
    }


    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint112 reserveIn, uint112 reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'INSUFFICIENT_LIQUIDITY');

        uint amountInWithFee = amountIn.mul(997); // As you can see, the swap in Bakery is 997 when in Pancakeswap it is 998, so be careful and check the fee of each DEX
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = uint(reserveIn).mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint112 reserveIn, uint112 reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'INSUFFICIENT_LIQUIDITY');

        uint numerator = uint(reserveIn).mul(amountOut).mul(1000);
        uint denominator = uint(reserveOut).sub(amountOut).mul(997); // As you can see, the swap in Bakery is 997 when in Pancakeswap it is 998, so be careful and check the fee of each DEX
        amountIn = (numerator / denominator).add(1);
    }

    

    /**
        Handy function that approves the addresses_being_approved to be spended by the spender_addresses that is placed
        in the same array position as the addresses_being_approved, 1:1 match
        Everything is approved with maximum allowance: 115792089237316195423570985008687907853269984665640564039457584007913129639935
        The good thing of running this function is that the owner is this contract, so we are allowing the spender_addresses to use 
        the address_being_approved on behalf of the owner (this contract)

        NOTE: Max amount of addresses that can be approved in a single call in this function is type(uint8).max, which is 256 address

        It is specially used with the Router approach, when using the Pairs to execute the swaps it is not needed
        - For tradeExactTokenForToken: Adapt to Bakery[TODO]
            [0xD05A097B1Dc5Bd0733b9460fa562497278F55E36, 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684, 0x337610d27c682E347C9cD60BD4b3b107C9d34dDd, 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee] [USDT(bakery), USDT(bakery)]
            [0xCDe540d7eAFE93aC5fE6233Bee57E1270D3E330F, 0xCDe540d7eAFE93aC5fE6233Bee57E1270D3E330F, 0xCDe540d7eAFE93aC5fE6233Bee57E1270D3E330F, 0xCDe540d7eAFE93aC5fE6233Bee57E1270D3E330F] [BAKERY_ROUTER, BAKERY_ROUTER, BAKERY_ROUTER]
     */
    function runApproval(address[] calldata addresses_being_approved, address[] calldata spender_addresses) external onlyOwner {
        require(addresses_being_approved.length == spender_addresses.length, "Both addresses_being_approved and spender_addresses musth have same length");
        require(addresses_being_approved.length >= 1, "Length of spender_addresses needs to be 1 at least");
        require(spender_addresses.length >= 1, "Length of spender_addresses needs to be 1 at least");
        
        for (uint8 index = 0; index < spender_addresses.length; index++) {
            IERC20(addresses_being_approved[index]).approve(
                address(spender_addresses[index]),
                type(uint256).max
            ); 
        }
    }

    // Returns the BNB(ETH) that is in this contract to the owner(sender actually, but as this function has onlyOwner modified it will be always de owner)
    function returnETH() external onlyOwner {
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use: https://solidity-by-example.org/sending-ether
        (bool sent, bytes memory data) = payable(msg.sender).call{value: address(this).balance}("");
        require(sent, "Failed to return Ether");
    }

    // Returns the specific token balance that is in this contract to the owner(sender actually, but as this function has onlyOwner modified it will be always de owner)
    function returnToken(address address_token) external onlyOwner {
        // Call returns a boolean value indicating success or failure.
        // I think it is more appropiate to use .transfer than .transferFrom
        bool sent = IERC20(address_token).transfer(msg.sender, IERC20(address_token).balanceOf(address(this)));
        require(sent, "Failed to return token");
    }

    // IMPORTANT: It is very important to have the receive/fallback functions in order to be able to
    // receive ETH(BNB), so without this functions the IWETH(WETH).withdraw(_value); would not work
    // because this contract could not receive any ETH(BNB)
    receive() external payable {}

    fallback() external payable {}

    function kill() public onlyOwner{ 
        selfdestruct(payable(owner())); 
    }
}