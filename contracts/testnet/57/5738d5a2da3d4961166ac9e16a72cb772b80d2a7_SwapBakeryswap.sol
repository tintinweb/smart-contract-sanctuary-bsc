/**
 *Submitted for verification at BscScan.com on 2022-06-20
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

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
// USDT: 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684
// WBNB: 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd
// BUSD: 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7
// Default Pools: BNB-BUSD, BNB-USDT, BUSD-USDT, USDT-DAI, BUSD-ETH, USDT-ETH
//
// Path: [0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd, 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684]
// Max range uint256: 115792089237316195423570985008687907853269984665640564039457584007913129639935
// https://amm.kiemtienonline360.com/
contract SwapBakeryswap is Ownable {

    IBakerySwapRouter private constant bakeryswapRouter = IBakerySwapRouter(0xCDe540d7eAFE93aC5fE6233Bee57E1270D3E330F);

    constructor() Ownable() {}

    /**
    amountIn (uint256)
        - 500000000000000000 (0.5 USDT for example)
    amountOutMin (uint256):
        - 10000000
    path (address[]): I can use whatever ERC20 token I want that has liquidity in Bakeryswap. Remember that if a use WBNB, I will get the ERC20 WBNB equivalent and not the native WBNB (BNB). The diffecence between
                      the native BNB and the ERC20 WBNB is that native BNB appears in the "Balance:" field in bscscan, and the ERC20 WBNB equivalente appears in the "Token:" drop-down list.
        - [0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684, 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7] [USDT, BUSD]
        - [0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684, 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd] [UDST, WBNB]
        - [0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684, 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd, 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7] [UDST, WBNB, BUSD]
    to (address)
        - owner()
    deadlineOffset (uint256):
        - current + deadlineOffset
     */
    function tradeFromTokenToToken(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        uint256 deadlineOffset
    ) external onlyOwner {
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
    function tradeFromBNBToToken(
        uint256 amountOutMin,
        address[] calldata path,
        uint256 deadlineOffset
    ) external payable onlyOwner {
        require(path.length >= 2, "Length of path needs to be 2 at least");

        // As the source token is NOT ERC20 but the native BNB token, no transfer from the wallet to this contract 
        // is needed, as the BNB of the wallet will be used directly to transfer it to the contract 
        // with the {value: msg.value} part.
        bakeryswapRouter.swapExactBNBForTokens{value: msg.value}(
            amountOutMin,
            path,
            owner(),
            block.timestamp + deadlineOffset
        );
    }

    /**
    amountIn (uint256)
        - 5000000000000000000 (0.5 USDT for example)
    amountOutMin (uint256):
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
    function tradeFromTokenToBNB(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        uint256 deadlineOffset
    ) external onlyOwner {
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
            amountOutMin,
            path,
            owner(),
            block.timestamp + deadlineOffset
        );
    }

    //receive() payable external {}
}