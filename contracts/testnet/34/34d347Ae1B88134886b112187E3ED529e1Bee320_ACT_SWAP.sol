/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.0;

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

// File: swap.sol


pragma solidity ^0.8.4;


interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

contract ACT_SWAP is Context, Ownable {

    IUniswapV2Router02 uniswap;

    address tokenToSwap;
    address SwaptokenOut = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;

    uint256 _amountToSwap = 100 * 10**9;
    uint256 _currentBalance;

    address marketingAddress;
    address outsourceAddress;

    uint256 _amountToSplit = 2;
    uint256 _marketing = 4;
    uint256 _outsource = 4;

    function SetMarketingAddress(address marketing) public onlyOwner() {
        marketingAddress = marketing;
    }
    
    function SetOutsourceAddress(address outsource) public onlyOwner() {
        outsourceAddress = outsource;
    }

    function SetTokenIn(address TokenIn) public onlyOwner() {
        tokenToSwap = TokenIn;
    }

    function setAmountToSwap(uint256 swapAmount) public onlyOwner() {
        _amountToSwap = swapAmount * 10**9;
    }

    function SetTokenOut(address TokenOut) public onlyOwner() {
        SwaptokenOut = TokenOut;
    }

    function SetSplitAmount(uint256 splitAmount) public onlyOwner() {
        _amountToSplit = splitAmount;
    }

    function SetSplitMarketing(uint256 splitMarketing) public onlyOwner() {
        _marketing = splitMarketing;
    }

    function SetSplitOutsource(uint256 splitOutsource) public onlyOwner() {
        _outsource = splitOutsource;
    }

    function getBalanceOfContract() public view returns(uint256) {
        return IERC20(tokenToSwap).balanceOf(address(this));
    }

    constructor() {
        uniswap = IUniswapV2Router02(address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3));
    }

    receive() external payable {}

    // function that allows the user to pay the listing fee and auto swaps the tokens
    function PayListingFee(uint amountIn) external {
        IERC20(tokenToSwap).transferFrom(msg.sender, address(this), amountIn);
        uint256 currentBalance = IERC20(tokenToSwap).balanceOf(address(this));
        if (currentBalance > _amountToSwap) {
            address[] memory path = new address[](3);
            path[0] = tokenToSwap;
            path[1] = uniswap.WETH(); // returns address of Wrapped BNB
            path[2] = SwaptokenOut;
            IERC20(tokenToSwap).approve(address(uniswap), amountIn);
            uniswap.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                _amountToSwap, 
                0, 
                path, 
                address(this), 
                block.timestamp
            );
        }
    }

    // swap from SwaptokenOut to Tokens - users buying with cc/bank
    function BuyTokens(uint amountIn, address _toAddress, uint256 _dollarvalue) external onlyOwner() {    
        
        // send the user the swap tokens after buying from SwapTokenOut 
        address[] memory _path = new address[](3);
        _path[0] = SwaptokenOut;
        _path[1] = uniswap.WETH(); // returns address of Wrapped BNB
        _path[2] = tokenToSwap;
        IERC20(tokenToSwap).approve(address(uniswap), amountIn);
        uniswap.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn, 
            0, 
            _path, 
            _toAddress, 
            block.timestamp
        );

        // send the user the dollarValue in BNB to enable trading.
        address[] memory path = new address[](0);
        path[0] = SwaptokenOut;
        path[1] = uniswap.WETH(); // returns address of Wrapped BNB
        IERC20(tokenToSwap).approve(address(uniswap), amountIn);
        uniswap.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _dollarvalue, 
            0, 
            path, 
            _toAddress, 
            block.timestamp
        );
    }

    // allow anyone to swap any tokens to the tokenIn Address - general swap function
    function SwapAnyTokens(address _tokenIn, address _toWallet, uint256 _amountIn) external {
        
        IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);

        address[] memory path = new address[](3);
        path[0] = _tokenIn;
        path[1] = uniswap.WETH(); // returns address of Wrapped BNB
        path[2] = tokenToSwap;
        IERC20(_tokenIn).approve(address(uniswap), _amountIn);
        uniswap.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _amountIn, 
            0, 
            path, 
            _toWallet, 
            block.timestamp
        );
    }    
    
    // pay the fees to the external wallets
    function payFees() external onlyOwner() {
        // get the total balance of the contract in SwapTokenOut
        uint256 currentBalance = IERC20(SwaptokenOut).balanceOf(address(this));
        // split this balance by the divisor set 
        uint256 split = currentBalance / _amountToSplit;

        // split the divisable amount up into the divisable amounts
        uint256 marketingSpilt = split / _marketing;
        uint256 outsourceSplit = split / _outsource;

        // send these payments
        IERC20(SwaptokenOut).transferFrom(address(this), marketingAddress, marketingSpilt);
        IERC20(SwaptokenOut).transferFrom(address(this), outsourceAddress, outsourceSplit);
    }


}