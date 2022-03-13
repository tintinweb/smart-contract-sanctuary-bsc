pragma solidity ^0.8.4;
pragma experimental ABIEncoderV2;
import './interfaces/IERC20.sol';
import './interfaces/IUniswapV2Router02.sol';
import './libraries/PancakeLibrary.sol';
import './interfaces/IPancakePair.sol';





interface IPancakeFactory {
        function getPair(address tokenA, address tokenB) external view returns (address pair);
   }

interface IERC3156FlashBorrower {
    /*
     * @dev Receive a flash loan.
     * @param initiator The initiator of the loan.
     * @param token The loan currency.
     * @param amount The amount of tokens lent.
     * @param fee The additional amount of tokens to repay.
     * @param data Arbitrary data structure, intended to contain user-defined parameters.
     * @return The keccak256 hash of "ERC3156FlashBorrower.onFlashLoan"
     */
    function onFlashLoan(
       address initiator,
       address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data

    ) external returns (bytes32);
}

interface IERC3156FlashLender {
   function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}

/*
*  FlashBorrowerExample is a simple smart contract that enables
*  to borrow and returns a flash loan.
*/
contract EqualizerContract is IERC3156FlashBorrower {

    uint public MAX_INT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    address public admin;
       address constant WETH = 0xA1c9379E7Fab5af351cAaeF694210DC0A13aBBC0;  //testnet
        address constant pancakeV2Router = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;  //testnet
     //  address constant pancakeV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
       address constant pancakeV1Router = 0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F;
      // address constant apeRouter = 0xcF0feBd3f17CEf5b47b0cD257aCf6025c5BFf3b7;  //mainnet  
      // address constant apeFactory = 0x0841BD0B734E4F5853f0dD8d7Ea041c241fb0Da6;  //mainnet
      address constant apeFactory = 0x006031e2eFbBE9764A9276Dd0436d138FB4ac3B3;   //testnet--maybe backwards from apeRouter
      address constant apeRouter = 0xaC00460afef1D85C86964E80CDD4007B288CEaFD;  //testnet

       event Log(string message, uint[] amountRequired);
       uint constant deadline = 10 days;
     

    constructor( ) public {
      admin = msg.sender;
      }

     //For `flashloanProviderAddress, search for FlashLoanProvider here:
    //https://docs.equalizer.finance/equalizer-deep-dive/smart-contracts
    function initiateFlashloan(
      address flashloanProviderAddress, 
      address token, 
      uint256 amount, 
      address token1,
      uint256 amount1,
       
      bytes calldata data
      
    ) external {
    bytes memory data = abi.encode( token1, amount1);
             
      IERC3156FlashLender(flashloanProviderAddress).flashLoan(
       IERC3156FlashBorrower(address(this)),
        token,
        amount,
        data
          );
        }

    // @dev ERC-3156 Flash loan callback
    function onFlashLoan(
        address _initiator,
        address _token,
        uint256 _amount,
        uint256 _fee,
        bytes calldata _data

     ) external override returns (bytes32) {
     
     //address factory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;   pancakev2 mainnet
     address factory = 0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc;    // testnet
     address token = _token;  
     uint amount = _amount;
                                                                                                
      IERC20(token).approve(msg.sender, MAX_INT);
     
       (address token1, uint amount1) = abi.decode(_data, (address, uint));


        address[] memory path = new address[](2);
        address[] memory path1 = new address[](2);
        uint amountToken = amount == 0 ? amount1 : amount;  //This will pick the borrowed token
   
 //        address pairAddress = IPancakeFactory(factory).getPair(token, token1);
 //   require(pairAddress != address(0), 'This pool does not exist');
    
     IERC20(token).approve(pancakeV2Router, amountToken);

 //   IPancakePair(pairAddress).swap(
 //     amount, 
 //     amount1, 
 //     msg.sender, 
 //     '0'
 //   );
   
     //    address token0 = IPancakePair(msg.sender).token0();
     //     token1 = IPancakePair(msg.sender).token1();

      //   require(
      //   msg.sender == PancakeLibrary.pairFor(factory, token0, token1), 
      //   'Unauthorized'
     //); 
       //  require(amount == 0 || amount1 == 0);

    


        path[0] = amount == 0 ? token1 : token;
         path[1] = amount == 0 ? token : token1;
       
       
    // uint [] memory amountRequired = PancakeLibrary.getAmountsIn(
    //  factory, 
    //  amountToken, 
    //  path
    //); 

//    uint[] memory amountsOut = PancakeLibrary.getAmountsOut(factory, amountToken, path);
        
       

  
   // IUniswapV2Router02(pancakeV2Router).swapExactTokensForETH(
   //    amountToken, 
   //    0, 
   //    path, 
   //    0x79c00901a1983e4613C1C8fe0e5fCD3129Ae27EA, 
    //  block.timestamp
   // );
//*/
       // path1[0] = amount == 0 ? token : token1;
       // path1[1] = amount == 0 ? token1 : token;

    //    uint amountToken1 = amount1 == 0 ? amount1 : amount;
       
    //  IERC20(token1).approve(address (apeRouter), amountToken);
       
   //      uint [] memory amountRequired = PancakeLibrary.getAmountsIn(
   //   apeFactory, 
   //   amountToken, 
   //   path
   // ); 

     // emit Log('Here is the amountRequired Array', amountRequired);

   // IUniswapV2Router02(apeRouter).swapExactTokensForTokens(
   // amountToken, 
   // 1,   // amountRequired[0]
   //   path, 
   //   msg.sender, 
   //   block.timestamp
   // );
  // 





    // uint[] memory amounts1Out  = PancakeLibrary.getAmountsOut(factory, amountsOut[1], path1);

    

        // Return success to the lender, he will transfer get the funds back if allowance is set accordingly
       return keccak256('ERC3156FlashBorrower.onFlashLoan');
         
    }
     
        
    //function withdraw(address recipient, address token, uint amount) external {
    //  require(msg.sender == admin, 'only admin');
      //IERC20(token).transfer(recipient, amount);
    //  emit Log('token returned', amount)
      
   // } 
     
}

pragma solidity >=0.8.0;
 
import '../interfaces/IPancakePair.sol';

library PancakeLibrary {
   
    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint160(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5' // init code hash
            )))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IPancakePair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'PancakeLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA * (reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'PancakeLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn * (9975);
        uint numerator = amountInWithFee * (reserveOut);
        uint denominator = reserveIn * (10000) + (amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'PancakeLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn * (amountOut) * (10000);
        uint denominator = reserveOut - (amountOut) * (9975);
        amountIn = (numerator / denominator) + (1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'PancakeLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'PancakeLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

pragma solidity ^0.8.0;

import './IUniswapV2Router01.sol';

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

pragma solidity ^0.8.0;


interface IUniswapV2Router01 {
    function factory() external view returns (address);
    function WETH() external view returns (address);

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

pragma solidity >=0.8.0;

interface IPancakePair {
      function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;   
   function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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