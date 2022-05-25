/**
 *Submitted for verification at BscScan.com on 2022-05-25
*/

// SPDX-License-Identifier: MIT
pragma solidity >0.7.0;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

interface IUniswapV2Router {
  function getAmountsOut(uint256 amountIn, address[] memory path)
    external
    view
    returns (uint256[] memory amounts);
 
  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external;
}

interface IUniswapV2Pair {
  function token0() external view returns (address);
  function token1() external view returns (address);
  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external;
}

interface IUniswapV2Factory {
  function getPair(address token0, address token1) external returns (address);
}

interface IERC3156FlashBorrower {
    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);
}

contract FlashBorrowerExample is IERC3156FlashBorrower {
    uint256 MAX_INT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    address private constant UNISWAP_V2_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address private constant MONSTA = 0x8A5d7FCD4c90421d21d30fCC4435948aC3618B2f;
    address private constant myAddy = 0xe082A73b3407c5Fd2D418D08b65131874B191127;


    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external override returns (bytes32) {
        // Approve borrowed tokens to be send back to flash loan lender at the end of the funciton.
        IERC20(token).approve(msg.sender, MAX_INT);

        // Temp Fred:
        require(initiator == myAddy, string(abi.encodePacked("Initiator disallowed: ", initiator)));
       
        // Build your trading business logic here
        // Temp Fred: eventually read in the data parm here and parse it.

        //. *** 0. For testing purposes, transfer some BNB from my wallet here (requires approval first). Temp Fred:
        IERC20(token).transferFrom(myAddy, address(this), amount);

        // *** 1. First swap: buy Monsta with BNB and store tokens on this contract momentarily. ***
        // Approve BNB from Flash Loan to be used on PancakeSwap
        IERC20(token).approve(UNISWAP_V2_ROUTER, MAX_INT);

        // Construct path for first trade (BNB to Monsta)
        address[] memory path1;
        path1 = new address[](2);
        path1[0] = token;
        path1[1] = MONSTA;

        // getAmountsOut - 5% (Monsta has a 5% tax)
        uint256 MonstaFromBNB = IUniswapV2Router(UNISWAP_V2_ROUTER).getAmountsOut(amount, path1)[0] * 90 / 100;

        // Perform the first swap
        IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactTokensForTokens(amount, 1, path1, address(this), block.timestamp);

        // *** 2. Second swap: sell Monsta for BUSD and store tokens on this contract momentarily. ***
        // Approve Monsta to be used on PancakeSwap
        IERC20(MONSTA).approve(UNISWAP_V2_ROUTER, MonstaFromBNB);

        // Construct path for second trade (Monsta to BUSD)
        address[] memory path2;
        path2 = new address[](2);
        path2[0] = MONSTA;
        path2[1] = BUSD;

        // getAmountsOut - 5% (Monsta has a 5% tax)
        uint256 BUSDFromMonsta = IUniswapV2Router(UNISWAP_V2_ROUTER).getAmountsOut(amount, path2)[0] * 90 / 100;
        
        // Perform the second swap
        IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactTokensForTokensSupportingFeeOnTransferTokens(MonstaFromBNB, 1, path2, address(this), block.timestamp);        


        // *** 3. Third swap: sell BUSD for BNB, which will be automatically retured to the flash loan lender afterward.
        // Approve Monsta to be used on PancakeSwap
        IERC20(BUSD).approve(UNISWAP_V2_ROUTER, BUSDFromMonsta);

        // Construct path for third trade (BUSD to BNB)
        address[] memory path3;
        path3 = new address[](2);
        path3[0] = BUSD;
        path3[1] = token;

        // Perform the third swap
        IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactTokensForTokensSupportingFeeOnTransferTokens(100000000000, 1, path3, address(this), block.timestamp);        

        // *** 4. Transfer of profits off the contract will occur separately, in function 440.

        return keccak256('ERC3156FlashBorrower.onFlashLoan');
    }

    // function tp() public
    // {
    //   // Verify that its me calling this function.
    //   if (msg.sender != myAddy) { revert("not today!"); }

    //   // Transfer WBNB
    //   uint256 WBNBToTransfer = IERC20(WBNB).balanceOf(address(this));
    //   IERC20(WBNB).approve(myAddy, WBNBToTransfer);
    //   IERC20(WBNB).transferFrom(address(this), myAddy, WBNBToTransfer);

    //   // Transfer BUSD
    //   uint256 BUSDToTransfer = IERC20(BUSD).balanceOf(address(this));
    //   IERC20(BUSD).approve(myAddy, BUSDToTransfer);
    //   IERC20(BUSD).transferFrom(address(this), myAddy, BUSDToTransfer);

    //   // Transfer MONSTA
    //   uint256 MONSTAToTransfer = IERC20(MONSTA).balanceOf(address(this));
    //   IERC20(MONSTA).approve(myAddy, MONSTAToTransfer);
    //   IERC20(MONSTA).transferFrom(address(this), myAddy, MONSTAToTransfer);
    // }
}