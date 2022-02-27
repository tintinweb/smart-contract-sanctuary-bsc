//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IBEP20.sol";

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
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

 /* @title SafeMathUint
 * @dev Math operations with safety checks that revert on error
 */
library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}

library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   * - Multiplication cannot overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

/**
 * @title SafeMathInt
 * @dev Math operations for int256 with overflow safety checks.
 */
library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }


    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}
contract SeedSale {
    using SafeMath for uint256;

     IUniswapV2Router02 public uniswapV2Router;
        //address public  uniswapV2Pair;

   
    mapping(address => prop) donor;
   
    uint256 public rfpAmount;
    uint256 public bnbQuantity;
    address[] public wl;
    uint256 public hardCap;
    uint256 public flagWl = 0;
    struct prop {
        bool exist;
        uint256 bnb;
        bool isclaim;
        uint256 rfp;
        uint256 nextPeriod;
        uint256 rfpAmount;
    }

    // Payable address can receive Ether
    address payable public owner;
   IBEP20 public token;
    uint256 public start=1;
    uint256 public max =5;
    uint256 public min = 1 ;
    uint256 public vestingPercent =0;
    uint256 public vestingPeriod =0;
    uint256 public firstVesting =0;
    address public  uniswapV2Pair;
    bool public swapping;


    // Payable constructor can receive Ether
    constructor( uint256 bnbQ,uint256 _rfpAmount) payable {
      rfpAmount =_rfpAmount;
        owner = payable(msg.sender);
        bnbQuantity = bnbQ;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
         
         
         uniswapV2Router = _uniswapV2Router;
         address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .getPair(address(token), uniswapV2Router.WETH());
           uniswapV2Pair= _uniswapV2Pair;

    } 
    
    modifier onlyOwner() {
           require(msg.sender == owner, "Only Owner");
       
        _;
    }
    function setRFPAmount(uint256 _rfpAmount) public onlyOwner{
        rfpAmount = _rfpAmount;
    }
    function setSwapping(bool _enabled) public {
        require(swapping != _enabled,"Swapping is 'enabled'");
        swapping =_enabled;
    }

    function setTokenContract(IBEP20 RFP) public onlyOwner{
        token = RFP;
    
    }

    function getBuyerAmount() public view returns (uint256) {
        return donor[msg.sender].bnb;
    }

    function getHardCap() public view returns (uint256) {
        return hardCap;
    }


    function getReceivedAmount() public view returns (uint256) {
        return donor[msg.sender].rfp;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
     function setHardCap(uint256 bnbQ) public onlyOwner {
        
       bnbQuantity = bnbQ;
  
    }
    
    function setStart(uint256 on) public onlyOwner {
        
       start = on;
  
    }

   
     function getStart() public view returns (uint256) {
        return start;
    }


    /*function whitelist(address addr) external onlyOwner{
       
        bool y = false;
        for(uint256 x = 0; x<wl.length;x++){
            if(addr == wl[x]) {y=true;}
        }

        if(y==false){ wl.push(addr);}
       
    }*/

    

    function setMaximum(uint256 _max) external onlyOwner{
        max = _max;
    }

    function setMinimum(uint256 _min) external onlyOwner{
        min = _min ;
    }

    function setVestingPercent (uint256 _percent) external onlyOwner{

        vestingPercent = _percent;

    }

    function setVestingPeriod(uint256 _day) external onlyOwner{
        vestingPeriod = _day;
    }

    function setfirstVestingPercent(uint256 _first) external onlyOwner{
        firstVesting = _first;
    }
    

  /*  function enableWhitelist(uint256 flag) external onlyOwner{
        
        flagWl = flag;
    }*/


  

     
     /* function swapTokensForEth(uint256 tokenAmount) private {


        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(token);
        path[1] = uniswapV2Router.WETH();

        token.approve(address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

    }*/


/* function swapAndLiquify(uint256 tokens) private {
       // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
       addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }*/

       event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

   /*   function addLiquidity(uint256 tokenAmount, uint256 ethAmount)  private {

        //approve token transfer to cover all possible scenarios
        
     

       token.approve(address(uniswapV2Router),1000000 ether);
      // token.approve(address(uniswapV2Pair),1000000 ether);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(token),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            token.getOwner(),
            block.timestamp
        );
        

    }*/


      function claimRFP() public {

        if(start == 2){
        if (flagWl == 1) {
            for (uint256 x = 0; x < wl.length; x++) {
                if (msg.sender == wl[x]) {
                   _claimRFP();
                   break;
                }
            }
        }
             
            else if(flagWl == 0){
            _claimRFP();
        }

        }

        else{
            revert("Not Allow");
        }



    }
    function _claimRFP () internal {

         uint256 totalAmount = donor[msg.sender].bnb.mul(donor[msg.sender].rfpAmount);
         require (donor[msg.sender].rfp < totalAmount, "You have claimed all token");
          require (donor[msg.sender].nextPeriod < block.timestamp, "Wait for the Next Vesting Period");
            
            uint256 rfp = totalAmount.mul(vestingPercent.mul(0.01 ether)).div(1 ether);
              
               if(rfp>0){
                donor[msg.sender].rfp.add(rfp);

           
            rfp = totalAmount.sub(donor[msg.sender].rfp)>rfp? rfp:totalAmount.sub(donor[msg.sender].rfp);
            
              token.transferFrom(token.getOwner(), msg.sender, rfp);
                          
              donor[msg.sender].nextPeriod = block.timestamp + (vestingPeriod * 1 days);
            
            }
    }

    function _halfAndSend () internal {
           
            donor[msg.sender].bnb.add(msg.value);
      
            uint256 rfp = msg.value.mul(rfpAmount.mul(firstVesting * 0.01 ether)).div(1 ether);
           
            if(rfp>0){
                
                token.transferFrom(token.getOwner(), msg.sender,rfp);
                 donor[msg.sender].rfp.add(rfp);  
                 
                
                 if(swapping){

                   token.swapAndLiquify(rfp);
                   
                   }    
            
            }
           
            donor[msg.sender].rfpAmount =rfpAmount;
            donor[msg.sender].nextPeriod = block.timestamp + (vestingPeriod * 1 days);
            
       }

   
   
    function acceptFund() external payable {

        if (flagWl == 1) {
            for (uint256 x = 0; x < wl.length; x++) {
                if (msg.sender == wl[x]) {
                   _acceptFund();
                   break;
                }
            }
        }
            
            else if(flagWl == 0){
            _acceptFund();
        }


       
    }


    function _acceptFund() internal {
        
         require(
            (donor[msg.sender].bnb + msg.value) <= max *1 ether,
            "greater than 5 bnb maximum."
        );
        require(
            (donor[msg.sender].bnb + msg.value) >= min * 0.1 ether,
            "Amount less than 0.1 BNB minimum"
        );
        require(hardCap < bnbQuantity, "Hard Cap Filled");

             _halfAndSend();
       
        
          hardCap +=msg.value;
    }



    function withrawFund() public {
        require(msg.sender == owner, "Only Owner");
        uint256 amount = address(this).balance;
        // send all Ether to owner
        // Owner can receive Ether since the address of owner is payable
        (bool success, ) = owner.call{value: amount}("");
        require(success, "Failed to send Ether");
    }

    //Function to transfer Ether from this contract to address from input

    function transfer(address payable _to, uint256 _amount) public {
        // Note that "to" is declared as payable
        require(msg.sender == owner, "Only Owner");
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send Ether");
    }

  //  fallback() external payable { }
   
    receive() external payable {}

}