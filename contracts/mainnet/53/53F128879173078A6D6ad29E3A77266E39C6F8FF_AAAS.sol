/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

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
interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

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

interface IFlashBorrower {
    /**
     * @dev Receive a flash loan.
     * @param initiator The initiator of the loan.
     * @param tokenToBorrow The loan currency, must be an approved stable coin.
     * @param tokenToRepay The repayment currency, must be an approved stable coin.
     * @param amount The amount of tokens lent.
     * @param fee The additional amount of tokens to repay.
     * @param data Arbitrary data structure, intended to contain user-defined parameters.
     * @return The keccak256 hash of "ERC3156FlashBorrower.onFlashLoan"
     */
    function onFlashLoan(
        address initiator,
        address tokenToBorrow,
        address tokenToRepay,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);
}

interface IFlashLender {
    /**
     * @dev The amount of currency available to be lent.
     * @param token The loan currency.
     * @return The amount of `token` that can be borrowed.
     */
    function maxFlashLoan(address token) external view returns (uint256);

    /**
     * @dev The fee to be charged for a given loan.
     * @param token The loan currency.
     * @param amount The amount of tokens lent.
     * @return The amount of `token` to be charged for the loan, on top of the returned principal.
     */
    function flashFee(address token, uint256 amount) external view returns (uint256);

    /**
     * @dev Initiate a flash loan.
     * @param receiver The receiver of the tokens in the loan, and the receiver of the callback.
     * @param tokenToBorrow The loan currency, must be an approved stable coin
     * @param tokenToRepay The Repayment currency, must be an approved stable coin
     * @param amount The amount of tokens lent.
     * @param data Arbitrary data structure, intended to contain user-defined parameters.
     */
    function flashLoan(
        IFlashBorrower receiver,
        address tokenToBorrow,
        address tokenToRepay,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}

/**
    Arbitrage As A Service Contract
 */
contract AAAS is IFlashBorrower{

    /** Wrapped BNB */
    address constant WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    /** Wallet To Receive Dev Percent Of Profit Generated */
    address public feeReceiver;

    /** Flash Loan Provider */
    address public provider;

    /** Callback Success */
    bytes32 public constant CALLBACK_SUCCESS = keccak256('ERC3156FlashBorrower.onFlashLoan');

    /** Number Of Projects Listed */
    uint64 public nListed;

    /** Total Value Borrowed */
    uint256 public totalValueBorrowed;

    /** Total Profit Generated */
    uint256 public totalValueGained;

    /** Listed Project Structure */
    struct ListedProject {
        string name;
        address receiveAddress;
        uint256 amountEarned;
        uint256 earnPercentage;
    }

    /** ID -> Listed Project */
    mapping ( uint64 => ListedProject ) public listedProjects;

    /** Swap Information */
    address[] DEXes;
    address[] token0;
    address[] token1;

    /** Contract Operator */
    address public operator;
    modifier onlyOperator(){
        require(msg.sender == operator, 'Only Operator');
        _;
    }

    constructor(
        address feeReceiver_
    ){
        feeReceiver = feeReceiver_;
        operator = msg.sender;
        provider = 0x7FEeb737D07F24eAa76F146295f0f3D4ad9c2Adc;
    }

    /**
     * @dev Receive a flash loan.
     * @param initiator The initiator of the loan.
     * @param tokenToBorrow The loan currency, must be an approved stable coin.
     * @param tokenToRepay The repayment currency, must be an approved stable coin.
     * @param amount The amount of tokens lent.
     * @param fee The additional amount of tokens to repay.
     * @param data Arbitrary data structure, intended to contain user-defined parameters.
     * @return The keccak256 hash of "ERC3156FlashBorrower.onFlashLoan"
     */
    function onFlashLoan(
        address initiator,
        address tokenToBorrow,
        address tokenToRepay,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external override returns (bytes32) {

        data;
        initiator;
        tokenToBorrow;

        // cycle through swaps
        for (uint i = 0; i < DEXes.length; i++) {
            handleSwaps(
                DEXes[i], 
                token0[i], 
                token1[i], 
                token0[i] == WETH ? address(this).balance : IERC20(token0[i]).balanceOf(address(this))
            );
        }

        // check profitability
        require(
            amount + fee <= IERC20(tokenToRepay).balanceOf(address(this)),
            'Non Profitable'
        );

        // repay flash loan
        IERC20(tokenToRepay).transfer(
            address(provider),
            amount + fee
        );

        // increment amount borrowed
        totalValueBorrowed += amount;

        // increment fee generated
        totalValueGained += IERC20(tokenToRepay).balanceOf(address(this));

        return CALLBACK_SUCCESS;
    }

    // BNB -> Token0 on Sushi Swap
    // Token0 -> BNB on Pancake Swap

    // Token0: [BNB, Token0]
    // Token1: [Token0, BNB]
    // DEXES:  [Sushi, Pancake]
    function trigger(
        address[] calldata token0_,
        address[] calldata token1_,
        address[] calldata DEXes_,
        uint64 projectIndex,
        uint256 borrowAmount,
        uint256 gasCost
    ) external {

        // Save Input Data To State
        token0 = token0_;
        token1 = token1_;
        DEXes = DEXes_;

        // Tokens To Borrow / Repay
        address tokenToBorrow = token0_[0];
        address tokenToRepay  = token1_[token1_.length - 1];

        // Trigger Flash Loan, Handle Data In onFlashLoan
        IFlashLender(provider).flashLoan(
            IFlashBorrower(address(this)),
            tokenToBorrow,
            tokenToRepay,
            borrowAmount,
            ''
        );

        // Divvy Up Remainder
        uint remainder = IERC20(tokenToRepay).balanceOf(address(this));
        require(
            remainder >= gasCost,
            'Non Profitable'
        );

        // Amount For Fee Receiver To Receive
        uint toReceive = shouldForwardProfitsToProject(projectIndex, remainder, gasCost) ?
            gasCost + ( ( ( remainder - gasCost ) * ( 100 - listedProjects[projectIndex].earnPercentage ) ) / 100 )  :
            remainder;

        // refund gas
        if (toReceive > 0) {
            IERC20(tokenToRepay).transfer(
                feeReceiver,
                toReceive
            );
        }

        // send listed project the remaining tokens
        uint leftOver = IERC20(tokenToRepay).balanceOf(address(this));
        if (leftOver > 0) {
            listedProjects[projectIndex].amountEarned += leftOver;
            IERC20(tokenToRepay).transfer(
                listedProjects[projectIndex].receiveAddress,
                leftOver
            );
        }

        // delete saved data
        delete DEXes;
        delete token0;
        delete token1;
    }

    function shouldForwardProfitsToProject(uint64 index, uint remainder, uint gasCost) public view returns (bool) {
        return 
            index < nListed && 
            remainder >= gasCost + 10**16 && 
            listedProjects[index].receiveAddress != address(0) &&
            listedProjects[index].earnPercentage > 0;
    }

    function handleSwaps(
        address DEX, 
        address _token0, 
        address _token1, 
        uint256 amount
    ) internal {

        if (_token1 == WETH) {
            // DEX Sell 
            _sellTokenForBNB(DEX, _token0, amount);
        } else if (_token0 == WETH) {
            // DEX Buy
            _buyTokenWithBNB(DEX, _token1, amount);
        } else {
            // DEX Swap
            _swapTokenForToken(DEX, _token0, _token1, amount);
        }
    }


    // DEX Router Swaps

    function _swapTokenForToken(address DEX, address tokenIn, address tokenOut, uint256 amountTokenIn) internal {

        IUniswapV2Router02 router = IUniswapV2Router02(DEX);

        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;

        // make approval
        IERC20(tokenIn).approve(DEX, amountTokenIn);

        // make the swap
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountTokenIn, 0, path, address(this), block.timestamp + 3000);
    
        // clear saved data
        delete path;
    }

    function _sellTokenForBNB(address DEX, address token, uint256 amount) internal {

        IUniswapV2Router02 router = IUniswapV2Router02(DEX);

        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = router.WETH();

        // make approval
        IERC20(token).approve(DEX, amount);

        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(amount, 0, path, address(this), block.timestamp + 3000);

        // clear saved data
        delete path;
    }

    function _buyTokenWithBNB(address DEX, address token, uint256 amount) internal {
        IUniswapV2Router02 router = IUniswapV2Router02(DEX);

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = token;

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(0, path, address(this), block.timestamp + 3000);
    
        // clear saved data
        delete path;
    }

    // operator functions
    function withdraw(address token) external onlyOperator {
        IERC20(token).transfer(operator, IERC20(token).balanceOf(address(this)));
    }

    function withdraw() external onlyOperator {
        (bool s,) = payable(operator).call{value: address(this).balance}("");
        require(s);
    }

    function changeOwner(address newOwner) external onlyOperator {
        operator = newOwner;
    }

    function changeFeeRecipient(address newRecipient) external onlyOperator {
        feeReceiver = newRecipient;
    }

    function registerProject(string calldata projectName, address receiveWallet, uint256 earnPercentage) external onlyOperator {
        listedProjects[nListed].name = projectName;
        listedProjects[nListed].receiveAddress = receiveWallet;
        listedProjects[nListed].earnPercentage = earnPercentage;
        nListed++;
    }

    function updateListing(
        uint64 projectIndex,
        string calldata projectName, 
        address receiveWallet, 
        uint256 earnPercentage
    ) external onlyOperator {
        listedProjects[projectIndex].name = projectName;
        listedProjects[projectIndex].receiveAddress = receiveWallet;
        listedProjects[projectIndex].earnPercentage = earnPercentage;
    }

    function setProvider(address nFlashProvider) external onlyOperator {
        provider = nFlashProvider;
    }

    // On BNB Received
    receive() external payable {}

}