/**
 *Submitted for verification at BscScan.com on 2022-09-22
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

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

interface IOwnable { 
    function owner() external view returns (address);
}

contract SKPSwapper {

    // Token
    IERC20 public constant token = IERC20(0x1234AE511876FCAaCe685fcDC292d9589A88dC2b);

    // Recipients Of Fees
    address public Marketing = 0x4d690E7adFdbf1955d89363F91a811d8D16D77E8;
	address public NFT = 0xe82d1E44a1f8a37f74A718Ee797F29Eb3aE1D84A;
	address public SKPFund = 0xCCf3a5F0B38074BaE1D3fa7736C0b97186f12B88;

    // Fee
    uint256 public _fee = 6;

    // router
    IUniswapV2Router02 public constant router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    // path
    address[] path;
    address[] sellPath;

    // swapper disabled
    bool swapperEnabled = true;

    // Governance based on token
    modifier onlyOwner(){
        require(msg.sender == IOwnable(address(token)).owner(), 'Only Owner');
        _;
    }

    constructor() {
        path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(token);
    }

    function setFee(uint fee) external onlyOwner {
        _fee = fee;
    }

    function setAddresses(address Marketing_, address NFT_, address SKPFund_) external onlyOwner {
        Marketing = Marketing_;
		NFT = NFT_;
		SKPFund = SKPFund_;
    }
    function withdraw(address _token) external onlyOwner {
        IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(address(this)));
    }

    function withdraw() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }

    function buyToken(address recipient_, uint minOut) external payable {
        _buyToken(recipient_, msg.value, minOut);
    }

    function buyToken(address recipient_) external payable {
        _buyToken(recipient_, msg.value, 0);
    }

    function buyToken() external payable {
        _buyToken(msg.sender, msg.value, 0);
    }

    function sellWithRecipient(uint256 amount, address recipient_, uint minOut) external {
        _sell(amount, recipient_, minOut);
    }
    
    function sell(uint256 amount, uint minOut) external {
        _sell(amount, msg.sender, minOut);
    }

    function _sell(uint256 amount, address recipient_, uint minOut) internal {

        // disable swapper
        swapperEnabled = false;

        // transfer in tokens
        require(
            IERC20(token).transferFrom(
                msg.sender,
                address(this),
                amount
            ),
            'ERR On Token Transfer'
        );

        // balance after transfer in
        uint bal = IERC20(token).balanceOf(address(this));

        // approve and sell tokens
        IERC20(token).approve(address(router), bal);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            bal,
            0,
            sellPath,
            address(this),
            block.timestamp + 100
        );

        // ensure min out
        require(
            address(this).balance >= minOut,
            'ERR: Min Out'
        );

        // re enable swapper
        swapperEnabled = true;

        // take fees
        uint fee = ( address(this).balance * _fee ) / 100;
        uint sFund = ( fee * 3 ) / 8;
        uint nFund = ( fee * 3 ) / 8;
        uint mFund = ( fee * 2 ) / 8;

        // distribute fees
		_send(Marketing, mFund);
		_send(NFT, nFund);
        _send(SKPFund, sFund);
		
        // send rest to caller
        _send(recipient_, address(this).balance);
    }

    receive() external payable {
        if (swapperEnabled) {
            _buyToken(msg.sender, msg.value, 0);
        }
    }

    function _buyToken(address recipient_, uint value, uint minOut) internal {
        require(
            value > 0,
            'Zero Value'
        );
        require(
            recipient_ != address(0),
            'Recipient Cannot Be Zero'
        );

        // take fees
        uint fee = ( value * _fee ) / 100;
		uint sFund = ( fee * 3 ) / 8;
        uint nFund = ( fee * 3 ) / 8;
        uint mFund = ( fee * 2 ) / 8;

        // distribute fees
        _send(Marketing, mFund);
		_send(NFT, nFund);
        _send(SKPFund, sFund);

        // buy token
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: address(this).balance}(
            minOut,
            path,
            address(this),
            block.timestamp + 300
        );

        IERC20(token).transfer(
            recipient_,
            IERC20(token).balanceOf(address(this))
        );
    }

    function _send(address to, uint val) internal {
        (bool s,) = payable(to).call{value: val}("");
        require(s);
    }
}