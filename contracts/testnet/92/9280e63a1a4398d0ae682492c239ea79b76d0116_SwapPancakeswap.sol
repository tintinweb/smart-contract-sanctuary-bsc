/**
 *Submitted for verification at BscScan.com on 2022-06-19
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

//import {IPancakeRouter01} from './IPancakeRouter01.sol';
interface IPancakeRouter01 {
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

//import {IPancakeRouter02} from './IPancakeRouter02.sol';
interface IPancakeRouter02 is IPancakeRouter01 {
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
    event Approval(address indexed owner, address indexed spender, uint256 value);

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



contract SwapPancakeswap is Ownable{

    // Pancakeswap Router BSC Mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E
    // Pancakeswap Router BSC Testnet: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
    // Pancakeswap Factory BSC Testnet: 0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc
    // USDT: 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684
    // WBNB: 0xae13d989dac2f0debff460ac112a837c89baa7cd
    // Pair WBNB-USDT: 0xF855E52ecc8b3b795Ac289f85F6Fd7A99883492b
    // Before running the swap several approvals need to be completed:
    //      - Owner needs to approve that source token can be spent by the SwapPancakeswap contract:
    //          - If the origin token of the swap is USDT, then just go to the USDT token contract and approve Pancakeswap Router to spend X amount
    //      - When the source token is BNB, there is no need to approve anything as this "token" is not WBNB but the native BNB. In this case, the function
    //        swapExactTokensForTokens(...) cannot be called but the BNB(ETH) swap function equivalent instead: swapExactETHForTokens(...) or similar functions with the ETH word.
    //      - 
    // Path: [0xae13d989dac2f0debff460ac112a837c89baa7cd, 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684]
    // Max range uint256: 115792089237316195423570985008687907853269984665640564039457584007913129639935
    IPancakeRouter02 private constant pancakeswapRouter = IPancakeRouter02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);

    constructor() Ownable() {
        //IERC20(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684).safeApprove(address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3), type(uint256).max);
        //IERC20(0xae13d989dac2f0debff460ac112a837c89baa7cd).safeApprove(address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3), type(uint256).max);
    }

    /**
    amountIn (uint256)
        - 500000000000000000
    amountOutMin (uint256):
        - 10000000
    path (address[])
        - [0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684, 0xae13d989dac2f0debff460ac112a837c89baa7cd]
    to (address)
        - owner()
    deadline (uint256):
        - 1655667152 + deadlineOffset
     */
    function tradeFromTokenToToken(uint256 amountIn, uint256 amountOutMin, address[] calldata path, uint256 deadlineOffset) external onlyOwner{       
       require(path.length >= 2, "Length of path needs to be 2 at least");

        pancakeswapRouter.swapExactTokensForTokens{gas: gasleft()}(
            amountIn,
            amountOutMin,
            path,
            owner(),
            block.timestamp + deadlineOffset
        );
    }

    /**
    swapExactETHForTokens
        payableAmount(BNB): 0.02 (se usan numeros decimales normales, no wei ni nada de eso, directamente 0.02BNB en este caso por ejemplo)
    amountOutMin (uint256): 
        amountOutMin (uint256): 1000000000000000000 (aquí si se usa notacion wei, por lo que si quiero USDT como token de salida, sabemos que USDT tiene 18 decimales p)
    path (address[]):
        path (address[]): [0xae13d989dac2f0debff460ac112a837c89baa7cd, 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684] // [WBNB, USDT]
    to (address): No need to specify this as it is hardcoded to the owner address
        to (address): 0xe9f934b52B804549F1F3D377f902280bA43361aa
    deadlineOffset (uint256):
        deadlineOffset (uint256): It should be the unix epoc time (https://www.epochconverter.com/) deadline, but in our function we provide the offset because
        the current unix epoc time is automatically obtanined and then the offset is added to the current time resulting in the final deadline, for example something like: 1655653309
     */
    function tradeFromBNBToToken(uint256 amountOutMin, address[] calldata path, uint256 deadlineOffset) external payable onlyOwner{       
        require(path.length >= 2, "Length of path needs to be 2 at least");
               
        pancakeswapRouter.swapExactETHForTokens{value: msg.value}(
            amountOutMin,
            path,
            owner(),
            block.timestamp + deadlineOffset
        );
    }

    function previewSwap(address receiverAddress, uint256 amountIn, address[] calldata path) external view returns(bool,uint256) {
        require(path.length >= 2, "Length of path needs to be 2 at least");

        uint256 inputTokenBalance = IERC20(path[0]).balanceOf(receiverAddress);
        
        uint[] memory amounts = pancakeswapRouter.getAmountsOut(amountIn, path);
        
        uint256 outputTokenBalance = amounts[amounts.length-1];

        if (path[0]==path[path.length-1]) {
            return ( (outputTokenBalance - inputTokenBalance)>0 ? true:false, outputTokenBalance - inputTokenBalance);
        } else {
            return (false, 0);
        }
    }


    receive() payable external {}
}