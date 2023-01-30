/**
 *Submitted for verification at BscScan.com on 2023-01-29
*/

// File: https://github.com/pancakeswap/pancake-swap-periphery/blob/d769a6d136b74fde82502ec2f9334acc1afc0732/contracts/interfaces/IPancakeRouter01.sol

pragma solidity >=0.6.2;

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

// File: https://github.com/pancakeswap/pancake-swap-periphery/blob/d769a6d136b74fde82502ec2f9334acc1afc0732/contracts/interfaces/IPancakeRouter02.sol

pragma solidity >=0.6.2;


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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

// File: sandwich.sol


pragma solidity ^0.8.0;



contract sandwich {
    address public owner;
    address public ETHAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    //address public ETHAddress = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    //address public routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

    IERC20 contractETH = IERC20(ETHAddress);
    IERC20 contractTokenA;
    IERC20 contractTokenB;

    constructor(address botWallet) payable {
        owner = botWallet;
    }

    modifier onlyOwner {
      require(msg.sender == owner, "ONLY THE BOT CAN CALL THIS FUNCTION");
      _;
   }

    IERC20 ethContract = IERC20(ETHAddress);
    IPancakeRouter02 routerContract = IPancakeRouter02(routerAddress);

    function transferBackETH () public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function transferBackToken (address token) public onlyOwner {
        contractTokenA = IERC20(token);

        uint256 amount = contractTokenA.balanceOf(address(this));

        contractTokenA.transfer(msg.sender, amount);
    }

    function changeOwner (address newOwner) public onlyOwner {
        owner = newOwner;
    }

    function startSandwichETH (address tokenB, uint256 amountTokenA) public payable onlyOwner { 
        require (address(msg.sender).balance > amountTokenA, "insufficent amount on wallet");
        require (msg.value == amountTokenA, "Invalid transaction value"); 
        uint deadline = block.timestamp + 100;
        contractTokenB = IERC20(tokenB);

        address[] memory buyPath = new address[](2);
        buyPath[0] = address(ETHAddress);
        buyPath[1] = address(tokenB);

        address[] memory sellPath = new address[](2);
        sellPath[0] = address(tokenB);
        sellPath[1] = address(ETHAddress);

        contractETH.approve(routerAddress, address(this).balance);
        routerContract.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountTokenA}(0, buyPath , address(this), deadline);    

        uint256 balanceTokenB = contractTokenB.balanceOf(address(this));
        contractTokenB.approve(routerAddress, balanceTokenB);
        routerContract.swapExactTokensForETHSupportingFeeOnTransferTokens(balanceTokenB, 0, sellPath, address(this), deadline);
        
        uint256 newAmountTokenA = address(this).balance;        

        payable(msg.sender).transfer(newAmountTokenA);

    }

    function startSandwichSwapExactTokenSupportingFee (address tokenA, address tokenB, uint256 amountTokenA) public onlyOwner { 
        contractTokenA = IERC20(tokenA);
        contractTokenB = IERC20(tokenB);
        require (contractTokenA.balanceOf(msg.sender) >= amountTokenA, "insufficent amount on wallet");    
        uint deadline = block.timestamp + 100;


        address[] memory buyPath = new address[](2);
        buyPath[0] = address(tokenA);
        buyPath[1] = address(tokenB);

        address[] memory sellPath = new address[](2);
        sellPath[0] = address(tokenB);
        sellPath[1] = address(tokenA);

        contractTokenA.transferFrom(msg.sender, address(this), amountTokenA);
        contractTokenA.approve(routerAddress, contractTokenA.balanceOf(address(this)));
        routerContract.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountTokenA, 0, buyPath , address(this), deadline);    

        uint256 balanceTokenB = contractTokenB.balanceOf(address(this));
        contractTokenB.approve(routerAddress, balanceTokenB);
        routerContract.swapExactTokensForTokensSupportingFeeOnTransferTokens(balanceTokenB, 0, sellPath, address(this), deadline);
        
        uint256 newAmountTokenA = contractTokenA.balanceOf(address(this));     

        contractTokenA.transferFrom(address(this), msg.sender, newAmountTokenA);
        
    }

    function startSandwichSwapExactToken (address tokenA, address tokenB, uint256 amountTokenA) public onlyOwner { 
        contractTokenA = IERC20(tokenA);
        contractTokenB = IERC20(tokenB);
        require (contractTokenA.balanceOf(msg.sender) >= amountTokenA, "insufficent amount on wallet");    
        uint deadline = block.timestamp + 100;


        address[] memory buyPath = new address[](2);
        buyPath[0] = address(tokenA);
        buyPath[1] = address(tokenB);

        address[] memory sellPath = new address[](2);
        sellPath[0] = address(tokenB);
        sellPath[1] = address(tokenA);

        contractTokenA.transferFrom(msg.sender, address(this), amountTokenA);
        contractTokenA.approve(routerAddress, contractTokenA.balanceOf(address(this)));
        routerContract.swapExactTokensForTokens(amountTokenA, 0, buyPath , address(this), deadline);    

        uint256 balanceTokenB = contractTokenB.balanceOf(address(this));
        contractTokenB.approve(routerAddress, balanceTokenB);
        routerContract.swapExactTokensForTokens(balanceTokenB, 0, sellPath, address(this), deadline);
        
        uint256 newAmountTokenA = contractTokenA.balanceOf(address(this));     

        contractTokenA.transferFrom(address(this), msg.sender, newAmountTokenA);
        
    }

    fallback() external payable {}

    receive() external payable {}

}