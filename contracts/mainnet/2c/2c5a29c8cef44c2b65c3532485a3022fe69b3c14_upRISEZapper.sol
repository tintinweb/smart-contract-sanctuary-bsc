/**
 *Submitted for verification at BscScan.com on 2023-01-23
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-18
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

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

interface IUP {

    function mintWithBacking(uint256 numTokens, address recipient) external returns (uint256);
    function sell(uint256 tokenAmount) external returns (uint256);
    function sellTo(uint256 tokenAmount, address recipient) external returns (uint256);
}

contract upRISEZapper {

    // constants
    IERC20 public constant BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    IUniswapV2Router02 public constant router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    // UP Token
    address public UP; //0x5376A83112100Ff1567b2782e0d99c6d949b5509
    address public ALWAYSUP; //0xb2F0C73E7aa6369D9a8F16856f48d5635d3d6173

    address public admin;

    constructor() {
        UP = 0x5376A83112100Ff1567b2782e0d99c6d949b5509;
        ALWAYSUP = 0x869Ec35f5e970773d24B7cbDe94650E06a09871c;
        admin = msg.sender;
    }

    receive() external payable {
        
        zapWithBnb(0);

    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Caller is not admin!");
        _;
    }


    function zapWithBnb(uint256 minOut) public payable {

        // convert token to Underlying
        _convert();
        
        // require minOut
        uint256 bal = BUSD.balanceOf(address(this));
        require(
            bal >= minOut,
            'Min Out'
        );

        BUSD.approve(UP, bal);
    
        IUP(UP).mintWithBacking(bal, address(this));

        uint256 upBal = IERC20(UP).balanceOf(address(this));

        IERC20(UP).approve(ALWAYSUP, bal);

        IUP(ALWAYSUP).mintWithBacking(upBal, msg.sender);

        _refundDust(msg.sender);

    }

    function zapUpRise(uint256 amount, bool _isUP) external {

        
        if(_isUP){

            uint256 userUPBalance = IERC20(UP).balanceOf(msg.sender);
            
            require(userUPBalance > 0 && amount <= userUPBalance, 'Insufficient Balance');

            IUP(ALWAYSUP).mintWithBacking(userUPBalance, msg.sender);

        }else{
            require(BUSD.transferFrom(msg.sender, address(this), amount), 'Failure Transfer From');

            uint256 bal = BUSD.balanceOf(address(this));

            BUSD.approve(UP, bal);

            IUP(UP).mintWithBacking(bal, address(this));

            uint256 upBal = IERC20(UP).balanceOf(address(this));

            IERC20(UP).approve(ALWAYSUP, bal);
       
            IUP(ALWAYSUP).mintWithBacking(upBal, msg.sender);
        }

        _refundDust(msg.sender);
    }

    function unzapUpRiseBusd(uint256 amount) external {
        
        require(IERC20(ALWAYSUP).transferFrom(msg.sender, address(this), amount), 'Failure Transfer From');

        uint256 bal = IERC20(ALWAYSUP).balanceOf(address(this));

        IERC20(ALWAYSUP).approve(ALWAYSUP, bal);

        IUP(ALWAYSUP).sell(bal);

        uint256 upBal = IERC20(UP).balanceOf(address(this));

        IERC20(UP).approve(UP, bal);
       
        IUP(UP).sellTo(upBal, msg.sender);

        _refundDust(msg.sender);
    }

    function _convert() internal {

            address[] memory path = new address[](2);
            path[0] = router.WETH();
            path[1] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

            router.swapExactETHForTokens{
                value: address(this).balance
            }(0, path, address(this), block.timestamp + 10);

            delete path;

    }

    function _refundDust(address recipient) internal {
        
        uint bal0 = BUSD.balanceOf(address(this));
        if (bal0 > 0) {
            BUSD.transfer(
                recipient,
                bal0
            );
        }
    }

    function changeUP(address _new) external onlyAdmin {
        UP = _new;
    }

    function changeALWAYSUP(address _new) external onlyAdmin {
        ALWAYSUP = _new;
    }

    function changeAdmin(address _new) external onlyAdmin {
        admin = _new;
    }

}