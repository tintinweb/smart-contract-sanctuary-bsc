/**
 *Submitted for verification at BscScan.com on 2022-06-26
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

//import {IPancakeRouter01} from './IPancakeRouter01.sol';
interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
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

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

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

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

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

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

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

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

//import {IPancakeRouter02} from './IPancakeRouter02.sol';
interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

//import {SafeMath} from './SafeMath.sol';
library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}

//import {UQ112x112} from './UQ112x112.sol';
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

//import {IWETH} from './IWETH.sol';
interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

//import {IPancakePair} from './IPancakePair.sol';
interface IPancakePair {
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


// Pancakeswap Router BSC Mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E
// Pancakeswap Router BSC Testnet: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
// Pancakeswap Factory BSC Testnet: 0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc
// USDT: 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684
// WBNB: 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd
// BUSD: 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7
// Default Pools: BNB-BUSD, BNB-USDT, BUSD-USDT, USDT-DAI, BUSD-ETH, USDT-ETH
//
// Path: [0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd, 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684]
// Max range uint256: 115792089237316195423570985008687907853269984665640564039457584007913129639935
// Video buenisimo: https://www.youtube.com/watch?v=qB2Ulx201wY
// https://amm.kiemtienonline360.com/
contract SwapPancakeswap is Ownable {

    using SafeMath for uint;
    using UQ112x112 for uint224;

    IPancakeRouter02 private constant pancakeswapRouter = IPancakeRouter02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);

    modifier ensureOffset(uint deadlineOffset) {
        require((block.timestamp+deadlineOffset) >= block.timestamp, 'EXPIRED');
        _;
    }

    constructor() Ownable() {}

    /**
    amountIn (uint256)
        - 500000000000000000 (0.5 USDT for example)
    amountOutMin (uint256) (not used, 0 by default):
        - 10000000
    path (address[]): I can use whatever ERC20 token I want that has liquidity in Pancakswap. Remember that if a use WBNB, I will get the ERC20 WBNB equivalent and not the native WBNB (BNB). The diffecence between
                      the native BNB and the ERC20 WBNB is that native BNB appears in the "Balance:" field in bscscan, and the ERC20 WBNB equivalente appears in the "Token:" drop-down list.
        - [0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684, 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7] [USDT, BUSD]
        - [0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684, 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd] [UDST, WBNB]
        - [0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684, 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd, 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7] [UDST, WBNB, BUSD]
    to (address)
        - owner()
    deadlineOffset (uint256):
        - current + deadlineOffset
     */
    function tradeExactTokenForToken(uint256 amountIn, address[] calldata path, uint256 deadlineOffset) external onlyOwner {
        require(path.length >= 2, "Length of path needs to be 2 at least");


        // Approve that input token IERC20(path[0]) can be spent by the Router
        IERC20(path[0]).approve(
            address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3),
            amountIn // type(uint256).max
        ); 
        // Very useful link: https://docs.uniswap.org/protocol/V2/guides/smart-contract-integration/trading-from-a-smart-contract
        //  This previous link practically confirms to me that the approve method needs to be called inside the contract because this way the signer is this contract 
        //  and not the wallet, because after the transfer of the source token from the wallet to the contract, THE CONTRACT is the one that has the tokens to buy/perform the swap,
        //  so THE CONTRACT should be the one signing the approval.


        // As the source token is ERC20 I have to make a transfer from the wallet to this 
        // contract, as it is the wallet that has the source token that I will use to buy.
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        // Remember to approve (outside of this contract, i.e. bscscan) that this input token IERC20(path[0]) can be spent by this contract SwapPancakeswap.
        // [TODO] I need to run the approve function outside of this solidity code because I do not know the address of this deployed contract before deploying it...
        // maybe I can investigate because maybe it is easy to calculate with "create2" assembly instruction, but I do not know: Token contract: (path[0]); spender: This deployed contract;
        // amount: max or whatever

        // [TODO] This can be optimiced by creating a contract that already has the tokens to buy/perform the swaps. This way I could get rid of the transferFrom function and maybe I would only need
        // to call the approve function once (with type(uint256).max amount).
        

        pancakeswapRouter.swapExactTokensForTokens(
            amountIn,
            0, // amountOutMin,
            path,
            owner(),
            block.timestamp + deadlineOffset
        );
    }

    /**
    swapExactETHForTokens
        payableAmount(BNB): 0.02 (se usan numeros decimales normales, no wei ni nada de eso, directamente 0.02BNB en este caso por ejemplo)
    amountOutMin (uint256) (not used, 0 by default):
        amountOutMin (uint256): 1000000000000000000 (aquí si se usa notacion wei, por lo que si quiero USDT como token de salida, sabemos que USDT tiene 18 decimales)
    path (address[]): Source token (input token) must always be WBNB, although it will be treated as native WBNB, that is, BNB. This means that the token WBNB that we might have in the wallet/contract will not get modified but the BNB field is the thing that matters
        [0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd, 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684] [WBNB (treated as native BNB), USDT]
        [0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd, 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7, 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684] [WBNB(native), BUSD, UDST]
    to (address): No need to specify this as it is hardcoded to the owner address
        0xe9f934b52B804549F1F3D377f902280bA43361aa
    deadlineOffset (uint256):
        It should be the unix epoc time (https://www.epochconverter.com/) deadline, but in our function we provide the offset because
        the current unix epoc time is automatically obtanined and then the offset is added to the current time resulting in the final deadline, for example something like: 1655653309
     */
    function tradeExactBNBForToken(address[] calldata path, uint256 deadlineOffset) external payable onlyOwner {
        require(path.length >= 2, "Length of path needs to be 2 at least");

        // As the source token is NOT ERC20 but the native BNB token, no transfer from the wallet to this contract 
        // is needed, as the BNB of the wallet will be used directly to transfer it to the contract 
        // with the {value: msg.value} part.
        pancakeswapRouter.swapExactETHForTokens{value: msg.value}( // [HINT]: Here we are using the global variable msg.value, but remember that we could use a hardcoded/dynamic wei value like {value: 10000000000000000}, which is 0.01BNB
            0, //amountOutMin,
            path,
            owner(),
            block.timestamp + deadlineOffset
        );
    }

    /**
    amountIn (uint256)
        - 5000000000000000000 (0.5 USDT for example)
    amountOutMin (uint256) (not used, 0 by default):
        - 10000000000000000 
    path (address[]): The output token must always be WBNB, although it will be treated as native WBNB, that is, BNB. This means that I will not get WBNB as the output token but I will get BNB directly
        - [0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684, 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd] [UDST, WBNB]
        - [0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684, 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7, 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd] [UDST, BUSD, WBNB]
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
            address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3),
            amountIn // type(uint256).max
        ); 
        
        // As the source token is ERC20 I have to make a transfer from the wallet to this 
        // contract, as it is the wallet that has the source token that I will use to buy.
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        // Remember to approve (outside of this contract, i.e. bscscan) that this input token IERC20(path[0]) can be spent by this contract SwapPancakeswap.

        pancakeswapRouter.swapExactTokensForETH(
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
        - 0x5126C1B8b4368c6F07292932451230Ba53a6eB7A (USDT-BUSD)
        - 0xF855E52ecc8b3b795Ac289f85F6Fd7A99883492b (USDT-WBNB)
        - 0xe0e92035077c39594793e61802a350347c320cf2 (BUSD-WBNB)
    inputIsToken0:
        - true if token0 is the input token, so token1 will be the output
        - false if token1 is the input token, so token0 will be the output
    path NOT USED, just the pair address:
        - [0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684, 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7] [USDT, BUSD] --> Pair Pancakeswap: 0x5126C1B8b4368c6F07292932451230Ba53a6eB7A
        - [0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684, 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd] [UDST, WBNB] --> Pair Pancakeswap: 0xF855E52ecc8b3b795Ac289f85F6Fd7A99883492b
    to (address)
        - owner()
    deadlineOffset (uint256):
        - current + deadlineOffset

    Ideas: 
        - No quiero usar el Factory ni el Router, todo tiene que hacerse con exclusivamente el Pair e indicando cuales de los dos tokens (token0, token1) es el input... yo creo
        que con solo esto es suficiente
        - Como trabajo directamente sobre el Pair, no tiene sentido establecer el address[] path ya que siempre será un path de dos tokens (token0 y token1) donde solo cambiará el token de input/output
        según sea el sentido del swap.
        - Como mucho podria plantearse que el fee sea pasado por parametro

    Pair USDT-BUSD Pancakeswap: 
        - bscscan: https://testnet.bscscan.com/address/0x5126C1B8b4368c6F07292932451230Ba53a6eB7A
        - Address: 0x5126C1B8b4368c6F07292932451230Ba53a6eB7A
        - token0: 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7 (BUSD)
        - token1: 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684 (USDT)
    Pair USDT-WBNB Pancakeswap: 
        - bscscan: https://testnet.bscscan.com/address/0xF855E52ecc8b3b795Ac289f85F6Fd7A99883492b
        - Address: 0xF855E52ecc8b3b795Ac289f85F6Fd7A99883492b
        - token0: 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684 (USDT)
        - token1: 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd (WBNB)
    Pair BUSD-WBNB Pancakeswap: 
        - bscscan: https://testnet.bscscan.com/address/0xe0e92035077c39594793e61802a350347c320cf2
        - Address: 0xe0e92035077c39594793e61802a350347c320cf2
        - token0: 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7 (BUSD)
        - token1: 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd (WBNB)
     */
    function tradeExactTokenForToken_pairMethod(uint256 amountIn, address pairAddress, bool inputIsToken0, address receiver, uint256 deadlineOffset) external onlyOwner ensureOffset(deadlineOffset){
        
        // Obtain reseves of both tokens in the pair. Remember that the reserve0 and reserve1 are ordered
        // by the ordering of the token0 and token1, so it would be important to handle this requirement properly
        // so that when calling this functions from the outside the inputIsToken0 parameter is correctly configured
        (uint112 reserve0, uint112 reserve1,) = IPancakePair(pairAddress).getReserves();

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
            IERC20(IPancakePair(pairAddress).token0()).transferFrom(msg.sender, address(pairAddress), amountIn);
        }else{
            IERC20(IPancakePair(pairAddress).token1()).transferFrom(msg.sender, address(pairAddress), amountIn);
        }
        // Remember to approve (outside of this contract, i.e. bscscan) that this input token IERC20(path[0]) can be spent by this contract SwapPancakeswap.

        // Now I can perform the swap using the pair contract
        //(uint amount0Out, uint amount1Out) = inputIsToken0 ? (uint(0), amountOut) : (amountOut, uint(0));
        if(inputIsToken0){
            IPancakePair(pairAddress).swap(uint(0), amountOut, receiver, new bytes(0)); // receiver should be the the owner(sender/wallet)... but if a concatenation of pair swaps is performed, then the receiver should be the next pair address in the "path" and just the last swap would have the owner in the receiver parameter
        }else{
            IPancakePair(pairAddress).swap(amountOut, uint(0), receiver, new bytes(0)); // receiver should be the the owner(sender/wallet)... but if a concatenation of pair swaps is performed, then the receiver should be the next pair address in the "path" and just the last swap would have the owner in the receiver parameter
        }
    }


    function tradeTokenForExactToken_pairMethod(uint256 amountOut, address pairAddress, bool inputIsToken0, address receiver, uint256 deadlineOffset) external onlyOwner ensureOffset(deadlineOffset){
        
        // Obtain reseves of both tokens in the pair. Remember that the reserve0 and reserve1 are ordered
        // by the ordering of the token0 and token1, so it would be important to handle this requirement properly
        // so that when calling this functions from the outside the inputIsToken0 parameter is correctly configured
        (uint112 reserve0, uint112 reserve1,) = IPancakePair(pairAddress).getReserves();
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
            IERC20(IPancakePair(pairAddress).token0()).transferFrom(msg.sender, address(pairAddress), amountIn);
        }else{
            IERC20(IPancakePair(pairAddress).token1()).transferFrom(msg.sender, address(pairAddress), amountIn);
        }
        // Remember to approve (outside of this contract, i.e. bscscan) that this input token IERC20(path[0]) can be spent by this contract SwapPancakeswap.


        // Now I can perform the swap using the pair contract
        //(uint amount0Out, uint amount1Out) = inputIsToken0 ? (uint(0), amountOut) : (amountOut, uint(0));
        if(inputIsToken0){
            IPancakePair(pairAddress).swap(uint(0), amountOut, receiver, new bytes(0)); // receiver should be the the owner(sender/wallet)... but if a concatenation of pair swaps is performed, then the receiver should be the next pair address in the "path" and just the last swap would have the owner in the receiver parameter
        }else{
            IPancakePair(pairAddress).swap(amountOut, uint(0), receiver, new bytes(0)); // receiver should be the the owner(sender/wallet)... but if a concatenation of pair swaps is performed, then the receiver should be the next pair address in the "path" and just the last swap would have the owner in the receiver parameter
        }
    }


    /**
    
     */
    function tradeExactBNBForToken_pairMethod(address pairAddress, address receiver, uint256 deadlineOffset) external payable onlyOwner {
        require(IPancakePair(pairAddress).token0()==address(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd) || IPancakePair(pairAddress).token1()==address(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd), 'PAIR_DOES_NOT_HAVE_WBNB');

        // Obtain reseves of both tokens in the pair. Remember that the reserve0 and reserve1 are ordered
        // by the ordering of the token0 and token1, so it would be important to handle this requirement properly
        // so that when calling this functions from the outside the inputIsToken0 parameter is correctly configured
        (uint112 reserve0, uint112 reserve1,) = IPancakePair(pairAddress).getReserves();

        require(msg.value > 0, 'INSUFFICIENT_INPUT_AMOUNT');
        require(reserve0 > 0 && reserve1 > 0, 'INSUFFICIENT_LIQUIDITY');
        


        uint amountOut = 0;
        if(IPancakePair(pairAddress).token0()==address(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd)){
            amountOut = getAmountOut(msg.value, reserve0, reserve1);
        }else{
            amountOut = getAmountOut(msg.value, reserve1, reserve0);
        }
        

        // Now that we know the amount of tokens that we are going to RECEIVE from the swap
        // we need to transfer the input tokens to the pair contract
        // As the source token is native ETH(BNB) the way to make a transfer from the wallet to this 
        // contract is a bit peculiar.
        // The way to deposit ETH(BNB) into the WETH contract is by the deposit function:
        IWETH(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd).deposit{value: msg.value}();
        //if(IPancakePair(pairAddress).token0()==0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd){
            assert(IWETH(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd).transfer(address(pairAddress), msg.value));
            //IERC20(IPancakePair(pairAddress).token0()).transferFrom(msg.sender, address(pairAddress), msg.value);
        //}else{
            //assert(IWETH(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd).transfer(address(pairAddress), msg.value));
            //IERC20(IPancakePair(pairAddress).token1()).transferFrom(msg.sender, address(pairAddress), msg.value);
        //}
        // Remember to approve (outside of this contract, i.e. bscscan) that this input token IERC20(path[0]) can be spent by this contract SwapPancakeswap.

        // Now I can perform the swap using the pair contract
        //(uint amount0Out, uint amount1Out) = pairAddress.token0()==0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd ? (uint(0), amountOut) : (amountOut, uint(0));
        if(IPancakePair(pairAddress).token0()==address(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd)){
            IPancakePair(pairAddress).swap(uint(0), amountOut, receiver, new bytes(0)); // receiver should be the the owner(sender/wallet)... but if a concatenation of pair swaps is performed, then the receiver should be the next pair address in the "path" and just the last swap would have the owner in the receiver parameter
        }else{
            IPancakePair(pairAddress).swap(amountOut, uint(0), receiver, new bytes(0)); // receiver should be the the owner(sender/wallet)... but if a concatenation of pair swaps is performed, then the receiver should be the next pair address in the "path" and just the last swap would have the owner in the receiver parameter
        }
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint112 reserveIn, uint112 reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'INSUFFICIENT_LIQUIDITY');

        uint amountInWithFee = amountIn.mul(998);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = uint(reserveIn).mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint112 reserveIn, uint112 reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'INSUFFICIENT_LIQUIDITY');

        uint numerator = uint(reserveIn).mul(amountOut).mul(1000);
        uint denominator = uint(reserveOut).sub(amountOut).mul(998);
        amountIn = (numerator / denominator).add(1);
    }

    

    /**
        Handy function that approves the addresses_being_approved to be spended by the spender_addresses that is placed
        in the same array position as the addresses_being_approved, 1:1 match
        Everything is approved with maximum allowance: 115792089237316195423570985008687907853269984665640564039457584007913129639935
        The good thing of running this function is that the owner is this contract, so we are allowing the spender_addresses to use 
        the address_being_approved on behalf of the owner (this contract)

        NOTE: Max amount of addresses that can be approved in a single call in this function is type(uint8).max, which is 256 address

        - For tradeFromExactTokenToToken:
            [0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684, 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684] [USDT(pancake), USDT(pancake)]
            [0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3, 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3] [PANCAKE_ROUTER, PANCAKE_ROUTER]
        - BORRAR?? No es necesario con el pair... lo unico que ncesita el pair es que dentro de USDT se apruebe este contract como spender. For tradeFromExactTokenToToken_pairMethod:
            [0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684, 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7] [USDT(pancake), BUSD(pancake)]
            [0xSwapPancakeswap, 0xSwapPancakeswap] [THIS_CONTRACT, THIS_CONTRACT]

            [0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684, 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684, 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7] [USDT(pancake), USDT(pancake), BUSD(pancake)]
            [0x5126C1B8b4368c6F07292932451230Ba53a6eB7A, 0xF855E52ecc8b3b795Ac289f85F6Fd7A99883492b, 0xe0e92035077c39594793e61802a350347c320cf2] [PAIR_CONTRACT, PAIR_CONTRACT, PAIR_CONTRACT]
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


    //receive() payable external {}
}