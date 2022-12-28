/**
 *Submitted for verification at BscScan.com on 2022-12-27
*/

// File: OrderBook/IGrootV2Router01.sol

pragma solidity >=0.6.2;

interface IGrootV2Router01 {
    function factory() external pure returns (address);
    function WMATIC() external pure returns (address);

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
    function addLiquidityMATIC(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountMATICMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountMATIC, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityMATIC(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountMATICMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountMATIC);
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
    function removeLiquidityMATICWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountMATICMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountMATIC);
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

    // main functions 
    
    function swapExactMATICForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapExactTokensForMATIC(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    
    // main functions

    function swapTokensForExactMATIC(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapMATICForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
// File: OrderBook/IGrootV2Router02.sol

pragma solidity >=0.6.2;


interface IGrootV2Router02 is IGrootV2Router01 {
    function removeLiquidityMATICSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountMaticMin,
        address to,
        uint deadline
    ) external returns (uint amountMatic);
    function removeLiquidityMATICWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountMaticMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountMatic);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactMATICForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForMATICSupportingFeeOnTransferTokens(
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

// File: OrderBook/orderBook.sol



pragma solidity ^0.8.0;

/**
 * @notice Mixin that provide separate owner and admin roles for RBAC
 */



contract OrderBook {

    IGrootV2Router02 private IRouterGroot;
  
    struct mySellThroughMarket{
        address _address;
        uint256 _amount;
        string _pairA;
        string _pairB; 
        address _pairAAddress;
        address _pairBAddress;
    }
    
    constructor(IGrootV2Router02 _IRouterGroot) {
        IRouterGroot = _IRouterGroot;
    } 

    mapping(address=>mapping(string=>mapping(string=>mySellThroughMarket))) sellMartketLevel;

    event buyPairsData(address _address, uint256 _amount, address[] _pairAAddress, uint256 _transferAmount);


    function buyMarketLevel(address[] calldata _pairAAddress, address _address, uint256 _mintAmountOut) public payable returns(uint[] memory amounts){
        uint deadline = block.timestamp + 300 seconds;
          address BAddress = 0xa4E346Ec1DEf9B2A721ba46760a980eF553883aB;
         (bool success,bytes memory returndata)=BAddress.delegatecall(
            abi.encodeWithSelector(IRouterGroot.swapExactMATICForTokens.selector,_mintAmountOut,_pairAAddress,_address,deadline)
        );
        if(success == false) revert("Function call reverted");
    }

    function sellMarketLevel(uint _amount,address[] calldata _pairAAddress, address _address, uint _mintAmountOut) public returns(uint[] memory amounts){
        uint deadline = block.timestamp + 300 seconds;
          address BAddress = 0xa4E346Ec1DEf9B2A721ba46760a980eF553883aB;
         (bool success,bytes memory returndata)=BAddress.delegatecall(
            abi.encodeWithSelector(IRouterGroot.swapExactTokensForMATIC.selector,_amount,_mintAmountOut,_pairAAddress,_address,deadline)
        );
        if(success == false) revert("Function call reverted");
    }

    // function buyMarketLevel(address _tokenIn, address _address, uint256 _amount, address[] calldata _pairAAddress, uint256 _mintAmountOut) public payable returns(uint[] memory amounts){
    //     // swapExactMATICForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    //     // swapExactTokensForMATIC(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    //     IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amount);
    //     IERC20(_tokenIn).approve(address(IRouterGroot), _amount);
    //     uint deadline = block.timestamp;
    //     // uint256 amount = msg.value;
    //     return IRouterGroot.swapExactMATICForTokens(_mintAmountOut,_pairAAddress,_address,deadline);
    // }

    // function buyMarketLevelBuyDelicateCalls(address[] calldata _pairAAddress, address _address, uint256 _mintAmountOut) public payable returns(uint[] memory amounts){
    //     uint deadline = block.timestamp + 300 seconds;
    //      (bool success,bytes memory returndata)=address(IRouterGroot).delegatecall(
    //         abi.encodeWithSelector(IRouterGroot.swapExactMATICForTokens.selector,_mintAmountOut,_pairAAddress,_address,deadline)
    //     );
    // }

    // // function sellMarketLevel(address _tokenIn, address _address, uint256 _amount, address[] calldata _pairAAddress, uint256 _mintAmountOut) public returns(uint[] memory amounts){
    // //     // swapExactMATICForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    // //     // swapExactTokensForMATIC(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    // //     IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amount);
    // //      IERC20(_tokenIn).approve(address(IRouterGroot), _amount);
    // //     uint deadline = block.timestamp;
    // //     // uint256 amount = msg.value;
    // //     return IRouterGroot.swapExactTokensForMATIC(_amount,_mintAmountOut,_pairAAddress,_address,deadline);
    // // }

    function getAmountOutMin(address[] calldata path, uint256 _amountIn) external view returns (uint256) {
        uint256[] memory amountOutMins = IRouterGroot.getAmountsOut(_amountIn, path);
        return amountOutMins[path.length -1];  
    }
}