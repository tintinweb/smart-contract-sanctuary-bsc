// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import './interface/IParkSwap.sol';
import './pancake_swap/interfaces/IPancakeSwapV2Router02.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

contract ParkSwap is IParkSwap{

    using SafeMath for uint256;

    // Address of owner
    address private _owner;

    //Maturity duration
    uint256 private _maturityDuration;

    //Maturity duration
    uint256 private _maturityPercentage;

    IPancakeSwapV2Router02 public immutable pancakeswapV2Router;
    
    // Tokens Sold
    mapping(address=>uint256) private _soldTokens;

    struct TransactionsDetails{
           uint256 maturityTimeStamp;
           uint256 maturityAmount;
           bool redeemStatus;
    }
   
    struct TokenManager{
        uint256 totalTransactions;
        mapping(uint256=>TransactionsDetails) transactionId;
    }

    mapping(address=>mapping(address=>TokenManager)) private _tokenTracker;

    constructor(address owner_,uint256 maturityDuration_,uint256 maturityPercentage_,bool isMainNetwork_){
       _owner=owner_;
       _maturityDuration=maturityDuration_;
       _maturityPercentage=maturityPercentage_;

        //Initilizing Pancakeswap
        //TEST NETWORK PANCAKESWAP ADDRESS -0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        //MAIN NETWORK PANCAKESWAP ADDRESS -0x10ED43C718714eb63d5aA57B78B54704E256024E 
        address pancakeSwapV2RouterAddress;

        if(isMainNetwork_){
          pancakeSwapV2RouterAddress=0x10ED43C718714eb63d5aA57B78B54704E256024E;
        }
        else{
          pancakeSwapV2RouterAddress=0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
        }
        IPancakeSwapV2Router02 _pancakeswapV2Router = IPancakeSwapV2Router02(pancakeSwapV2RouterAddress);

        // set the rest of the contract variables
        pancakeswapV2Router = _pancakeswapV2Router;
    }

  function getParkSwapBNBBalance() external override view returns(uint256){
    return address(this).balance;
  }

  function getParkSwapTokenBalance(address tokenAddress_) external override view returns(uint256){
    IERC20 token=IERC20(tokenAddress_);
    return token.balanceOf(address(this));
  }

  function getParkSwapTokenSoldAmount(address tokenAddress_) external override view returns(uint256){
    return _soldTokens[tokenAddress_];
  }

  function getParkSwapTokenRemainingAmount(address tokenAddress_) public override view returns(uint256){
    IERC20 token=IERC20(tokenAddress_);
    return token.balanceOf(address(this)).sub(_soldTokens[tokenAddress_]);
  }

  function getTokenTransactionMaturityAmount(address tokenAddress_,address walletAddress_,uint256 transactionId_) external override view returns(uint256){
    return _tokenTracker[walletAddress_][tokenAddress_].transactionId[transactionId_].maturityAmount;
  }

  function getParkSwapCurrentMaturityDuration() external override view returns(uint256){
    return _maturityDuration;
  }

  function getParkSwapCurrentMaturityPercentage() external override view returns(uint256){
    return _maturityPercentage;
  }

  function getTransactionMaturityTimestamp(address tokenAddress_,address walletAddress_,uint256 transactionID_) external override view returns(uint256){
     return _tokenTracker[walletAddress_][tokenAddress_].transactionId[transactionID_].maturityTimeStamp;
  }

  function getTransactionMaturityStatus(address tokenAddress_,address walletAddress_,uint256 transactionID_) public override view returns(bool){
     return _tokenTracker[walletAddress_][tokenAddress_].transactionId[transactionID_].maturityTimeStamp<=block.timestamp;
  }

  function getTransactionRedeemStatus(address tokenAddress_,address walletAddress_,uint256 transactionID_) external override view returns(bool){
       return _tokenTracker[walletAddress_][tokenAddress_].transactionId[transactionID_].redeemStatus;
  }

  function getWalletTotalTransactions(address tokenAddress_,address walletAddress_) external override view returns(uint256){
    return _tokenTracker[walletAddress_][tokenAddress_].totalTransactions;
  }

  function getTokenValueOnPancakeSwap(address tokenAddress_) public override view returns(uint256){
        address[] memory path = new address[](2);
        path[1] = tokenAddress_;
        path[0] = pancakeswapV2Router.WETH();

        uint256[] memory value=pancakeswapV2Router.getAmountsOut(1, path);
        uint256 tokenValue = value[1];
    return tokenValue;
  }

  function getTokenValueWithAPY(address tokenAddress_,uint256 weiAmount_) public override view returns(uint256){

        uint256 price=getTokenValueOnPancakeSwap(tokenAddress_);
        uint256 tokenCount=(weiAmount_).div(price);
        uint256 apyAmount=(tokenCount.mul(_maturityPercentage)).div(100);
        uint256 maturityAmount= (tokenCount).add(apyAmount);
    return maturityAmount;
  }

  function swapToken(address tokenAddress_) external override payable returns(bool){
     
        require(msg.value>0,"Can not swap tokens with zero amount");
        uint256 price=getTokenValueOnPancakeSwap(tokenAddress_);
        require(msg.value>=price,"Can not swap tokens! Does not have required amount to swap");
        
        
        uint256 maturityAmount= getTokenValueWithAPY(tokenAddress_, msg.value);
        uint256 maturityDuration= block.timestamp.add(_maturityDuration);
        uint256 transactionID= _tokenTracker[msg.sender][tokenAddress_].totalTransactions.add(1);

        _tokenTracker[msg.sender][tokenAddress_].totalTransactions=transactionID;
        _tokenTracker[msg.sender][tokenAddress_].transactionId[transactionID].redeemStatus=false;
        _tokenTracker[msg.sender][tokenAddress_].transactionId[transactionID].maturityTimeStamp=maturityDuration;
        _tokenTracker[msg.sender][tokenAddress_].transactionId[transactionID].maturityAmount=maturityAmount;

        _soldTokens[tokenAddress_] = _soldTokens[tokenAddress_].add(maturityAmount);

        emit SwapToken(transactionID,maturityDuration,msg.sender);

        return true;

  }

  function redeemToken(address tokenAddress_,address toWalletAddress_,uint256 transactionID_) external override returns(bool){

    require(getTransactionMaturityStatus(tokenAddress_, msg.sender, transactionID_),"Tokens Maturity Period yet not completed");
    IERC20 token =IERC20(tokenAddress_);
    require(token.balanceOf(address(this))>=_tokenTracker[msg.sender][tokenAddress_].transactionId[transactionID_].maturityAmount,"Contract doest nat have required amount of token try again later");

    _tokenTracker[msg.sender][tokenAddress_].transactionId[transactionID_].redeemStatus=true;
    _soldTokens[tokenAddress_] = _soldTokens[tokenAddress_].sub(_tokenTracker[msg.sender][tokenAddress_].transactionId[transactionID_].maturityAmount);

    token.transfer(toWalletAddress_, _tokenTracker[msg.sender][tokenAddress_].transactionId[transactionID_].maturityAmount);

    emit RedeemToken(transactionID_,block.timestamp,msg.sender);

    return true;
  }

  function withdrawParkSwapUnsoldToken(address tokenAddress_,address toWalletAddress_,uint256 amount_) external override returns(bool){
    require(msg.sender==_owner," You do not have required authority"); 
    IERC20 token =IERC20(tokenAddress_);
    require(amount_<=(getParkSwapTokenRemainingAmount(tokenAddress_)),"Contract doest nat have required amount of token try again later");
    token.transfer(toWalletAddress_, amount_);
 
    emit WithdrawParkSwapUnsoldToken(tokenAddress_,msg.sender,amount_);
    return true;
  }

  function withdrawParkSwapBNB(address toWalletAddress_,uint256 amount_) external override returns(bool){
    require(msg.sender==_owner," You do not have required authority");
        require(address(this).balance>=amount_, "contract does not have sufficient BNB");
        payable(toWalletAddress_).transfer(amount_);
        emit  WithdrawParkSwapBNB(toWalletAddress_,amount_);
        return(true);
  }

  function setParkSwapCurrentMaturityTimeStamp(uint256 newTimeStamp_) external override returns(bool){
     require(msg.sender==_owner," You do not have required authority");
    
     emit SetParkSwapCurrentMaturityTimeStamp(_maturityDuration, newTimeStamp_);
     _maturityDuration=newTimeStamp_;
     return true;

  }

  function setParkSwapCurrentMaturityPercentage(uint256 newPercentage_) external override returns(bool){
     require(msg.sender==_owner," You do not have required authority");
     emit SetParkSwapCurrentMaturityPercentage( _maturityPercentage, newPercentage_);
     _maturityPercentage=newPercentage_;
     return true;
  }

   function transferParkSwapOwnerShip(address newOwner_) external override returns(bool){
      require(msg.sender==_owner," You do not have required authority");
      emit TransferParkSwapOwnerShip(newOwner_,_owner); 
     _owner=newOwner_;
     return true;
   }

    //Recives BNB
    receive() external payable {}

    fallback() external payable {}
}

//SPDX-License-Identifier:MIT
pragma solidity >=0.6.2;

import './IPancakeSwapV2Router01.sol';

interface IPancakeSwapV2Router02 is IPancakeSwapV2Router01 {
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

//SPDX-License-Identifier:MIT
pragma solidity >=0.6.2;

interface IPancakeSwapV2Router01 {
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

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

interface IParkSwap {

  event SwapToken(uint256 indexed transactionID_,uint256 indexed maturityTimeStamp_,address indexed toWalletAddress_);  

  event RedeemToken(uint256 indexed transactionID_,uint256 indexed withdrawTimeStamp_,address indexed toWalletAddress_); 

  event WithdrawParkSwapUnsoldToken(address indexed tokenAddress_,address indexed toWalletAddress_,uint256 indexed amount_);

  event WithdrawParkSwapBNB(address indexed toWalletAddress_,uint256 indexed amount_);

  event SetParkSwapCurrentMaturityTimeStamp(uint256 indexed oldMaturityTimeStamp_,uint256 indexed newMaturityTimeStamp_);

  event SetParkSwapCurrentMaturityPercentage(uint256 indexed oldMaturityPercentage_,uint256 indexed newMaturityPercentage_);

  event TransferParkSwapOwnerShip(address indexed newOwner_,address indexed oldOwner_); 

  function getParkSwapBNBBalance() external view returns(uint256);

  function getParkSwapTokenBalance(address tokenAddress_) external view returns(uint256);

  function getParkSwapTokenSoldAmount(address tokenAddress_) external view returns(uint256);

  function getParkSwapTokenRemainingAmount(address tokenAddress_) external view returns(uint256);

  function getTokenTransactionMaturityAmount(address tokenAddress_,address walletAddress_,uint256 transactionID_) external view returns(uint256);

  function getParkSwapCurrentMaturityDuration() external view returns(uint256);

  function getParkSwapCurrentMaturityPercentage() external view returns(uint256);

  function getTransactionMaturityTimestamp(address tokenAddress_,address walletAddress_,uint256 transactionID_) external view returns(uint256);

  function getTransactionMaturityStatus(address tokenAddress_,address walletAddress_,uint256 transactionID_) external view returns(bool);

  function getTransactionRedeemStatus(address tokenAddress_,address walletAddress_,uint256 transactionID_) external view returns(bool);

  function getWalletTotalTransactions(address tokenAddress_,address walletAddress_) external view returns(uint256);

  function getTokenValueOnPancakeSwap(address tokenAddress_) external view returns(uint256);

  function getTokenValueWithAPY(address tokenAddress_,uint256 weiAmount_) external view returns(uint256);

  function swapToken(address tokenAddress_) external payable returns(bool);

  function redeemToken(address tokenAddress_,address toWalletAddress_,uint256 transactionID_) external returns(bool);

  function withdrawParkSwapUnsoldToken(address tokenAddress_,address toWalletAddress_,uint256 amount_) external returns(bool);

  function withdrawParkSwapBNB(address toWalletAddress_,uint256 amount_) external returns(bool);

  function setParkSwapCurrentMaturityTimeStamp(uint256 newTimeStamp_) external  returns(bool);

  function setParkSwapCurrentMaturityPercentage(uint256 newPercentage_) external  returns(bool);

  function transferParkSwapOwnerShip(address newOwner_) external  returns(bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
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