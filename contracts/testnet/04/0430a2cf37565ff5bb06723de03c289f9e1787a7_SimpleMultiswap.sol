/**
 *Submitted for verification at BscScan.com on 2022-06-21
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.15;

//import {IBakerySwapRouter} from './IBakerySwapRouter.sol';
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

/**
    Multiswap between PancakeSwap and BakerySwap
    Max range uint256: 115792089237316195423570985008687907853269984665640564039457584007913129639935
 */
contract SimpleMultiswap is Ownable{

    address private constant pancakeswapRouterAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    address private constant bakeryswapRouterAddress = 0xCDe540d7eAFE93aC5fE6233Bee57E1270D3E330F;

    IPancakeRouter02 private constant pancakeswapRouter = IPancakeRouter02(pancakeswapRouterAddress);
    IBakerySwapRouter private constant bakeryswapRouter = IBakerySwapRouter(bakeryswapRouterAddress);

    constructor() Ownable() {}

    /**
        payable: 0.02
        path1 (pancake): [0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd, 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684] [WBNB(native pancake), USDT]
        path2 (pancake): [0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684, 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7, 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd] [USDT, BUSD, WBNB(native pancake)]
                         [0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684, 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd] [USDT, WBNB(native pancake)]
        path3 (bakery):  [0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F, 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee]
        amountOutMin1: 0
        amountIn1: IERC20(path1[path1.length-1]).balanceOf(address(this)) ó IERC20(path1[path1.length-1]).balanceOf(owner()) ó IERC20(path1[path1.length-1]).balanceOf(msg.sender) o the output amount of the previous swap: previousAmountArray[previousAmountArray.length-1]
        amountOutMin2: 0
        amountOutMin3: 0
        deadlineOffset: 120
     */
    function multiSwap(address[] calldata path1, address[] calldata path2, address[] calldata path3, uint256 amountOutMin1, uint256 amountOutMin2, uint256 amountOutMin3, uint256 deadlineOffset) external payable onlyOwner{
       uint256[] memory amounts1 = _tradeFromBNBToTokenPancakeswap(amountOutMin1, path1, deadlineOffset);
       uint256[] memory amounts2 = _tradeFromTokenToBNBPancakeswap(amounts1[amounts1.length-1], amountOutMin2, path2, deadlineOffset);// Needs to approve in input token contract that the spender contract is allowed to spend the tokens from the signer wallet
       uint256[] memory amounts3 =_tradeFromBNBToTokenBakeryswap(amountOutMin3, path3, deadlineOffset);
    }


    function _tradeFromBNBToTokenPancakeswap(uint256 amountOutMin, address[] calldata path, uint256 deadlineOffset) private returns(uint256[] memory amounts){
        require(path.length >= 2, "Length of path needs to be 2 at least");

        amounts = pancakeswapRouter.swapExactETHForTokens{value: msg.value}(
            amountOutMin,
            path,
            owner(), // This could be changed to the current contract so the tokens will be returned to this contract so it will be transfered to the wallet/signer/owner at a later stage when desired
            block.timestamp + deadlineOffset
        );
    }

    function _tradeFromBNBToTokenBakeryswap(uint256 amountOutMin, address[] calldata path, uint256 deadlineOffset) private returns(uint256[] memory amounts){
        require(path.length >= 2, "Length of path needs to be 2 at least");

        amounts = bakeryswapRouter.swapExactBNBForTokens{value: msg.value}(
            amountOutMin,
            path,
            owner(),
            block.timestamp + deadlineOffset
        );
    }

    function _tradeFromTokenToBNBPancakeswap(uint256 amountIn, uint256 amountOutMin, address[] calldata path, uint256 deadlineOffset) private returns(uint256[] memory amounts){
        require(path.length >= 2, "Length of path needs to be 2 at least");

        // Approve that input token IERC20(path[0]) can be spent by the Router
        IERC20(path[0]).approve(
            address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3),
            amountIn // type(uint256).max
        ); 
        
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        // Remember to approve (outside of this contract, i.e. bscscan) that this input token IERC20(path[0]) can be spent by this contract SwapPancakeswap.

        amounts = pancakeswapRouter.swapExactTokensForETH(
            amountIn,
            amountOutMin,
            path,
            owner(),
            block.timestamp + deadlineOffset
        );
    }

    function _tradeFromTokenToBNBBakeryswap(uint256 amountIn,uint256 amountOutMin,address[] calldata path,uint256 deadlineOffset) private returns(uint256[] memory amounts){
        require(path.length >= 2, "Length of path needs to be 2 at least");

        // Approve that input token IERC20(path[0]) can be spent by the Router
        IERC20(path[0]).approve(
            address(0xCDe540d7eAFE93aC5fE6233Bee57E1270D3E330F),
            amountIn // type(uint256).max
        ); 
        
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        // Remember to approve (outside of this contract, i.e. bscscan) that this input token IERC20(path[0]) can be spent by this contract SwapBakeryswap.

        amounts = bakeryswapRouter.swapExactTokensForBNB(
            amountIn,
            amountOutMin,
            path,
            owner(),
            block.timestamp + deadlineOffset
        );
    }

    // Same four functions as above but the receiver can be configured so that it can be this very same contract, so that the wallet/owner/sender does not get the output
    // of the swaps but the contract is the one that receives the outputs. In order for the wallet/owner/sender to receive the tokens
    // a .transfer/.transferFrom function must be call at the end of the MultiSwap.
/*
    function multiSwap(address[] calldata path1, address[] calldata path2, address[] calldata path3, uint256 amountOutMin1, uint256 amountOutMin2, uint256 amountOutMin3, uint256 deadlineOffset) external payable onlyOwner{
       
       // Check if this contract has enough input token (native BNB) to initiate the swap, if not, try to borrow from the sender/owner/wallet
       
       uint256[] memory amounts1 = _tradeFromBNBToTokenPancakeswap(amountOutMin1, path1, deadlineOffset);
       _tradeFromTokenToBNBPancakeswap(amounts1[amounts1.length-1], amountOutMin2, path2, deadlineOffset);// Needs to approve in input token contract that the spender contract is allowed to spend the tokens from the signer wallet
    
        // transfer input token to the source/input wallet again. [TODO]
    }

    function _tradeFromBNBToTokenPancakeswap_fromToSpecified(uint256 amountOutMin, address[] calldata path, address from, address to, uint256 deadlineOffset) private {
        require(path.length >= 2, "Length of path needs to be 2 at least");

        pancakeswapRouter.swapExactETHForTokens{value: msg.value}(
            amountOutMin,
            path,
            address(this), // This could be changed to the current contract so the tokens will be returned to this contract and it will be transfered to the wallet/signer/owner at a later stage
            block.timestamp + deadlineOffset
        );
    }

    function _tradeFromBNBToTokenBakeryswap_fromToSpecified(uint256 amountOutMin, address[] calldata path, address from, address to, uint256 deadlineOffset) private  {
        require(path.length >= 2, "Length of path needs to be 2 at least");

        bakeryswapRouter.swapExactBNBForTokens{value: msg.value}(
            amountOutMin,
            path,
            address(this),
            block.timestamp + deadlineOffset
        );
    }

    function _tradeFromTokenToBNBPancakeswap_fromToSpecified(uint256 amountIn, uint256 amountOutMin,address[] calldata path, address from, address to, uint256 deadlineOffset) private {
        require(path.length >= 2, "Length of path needs to be 2 at least");

        // Approve that input token IERC20(path[0]) can be spent by the Router
        IERC20(path[0]).approve(
            address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3),
            amountIn // type(uint256).max
        ); 
        
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        // Remember to approve (outside of this contract, i.e. bscscan) that this input token IERC20(path[0]) can be spent by this contract SwapPancakeswap.

        pancakeswapRouter.swapExactTokensForETH(
            amountIn,
            amountOutMin,
            path,
            address(this),
            block.timestamp + deadlineOffset
        );
    }

    function _tradeFromTokenToBNBBakeryswap_fromToSpecified(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address from, address to, uint256 deadlineOffset) private {
        require(path.length >= 2, "Length of path needs to be 2 at least");

        // Approve that input token IERC20(path[0]) can be spent by the Router
        IERC20(path[0]).approve(
            address(0xCDe540d7eAFE93aC5fE6233Bee57E1270D3E330F),
            amountIn // type(uint256).max
        ); 
        
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        // Remember to approve (outside of this contract, i.e. bscscan) that this input token IERC20(path[0]) can be spent by this contract SwapBakeryswap.

        bakeryswapRouter.swapExactTokensForBNB(
            amountIn,
            amountOutMin,
            path,
            address(this),
            block.timestamp + deadlineOffset
        );
    }
*/
    // important to receive ETH
    receive() payable external {}
}