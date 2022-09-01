// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import './interface/IParkSale.sol';
import './pancake_swap/interfaces/IPancakeSwapV2Router02.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract ParkSale is IParkSale{

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
           bool withdrawStatus;
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

  function getBNBBalance() external view returns(uint256){
    return address(this).balance;
  }

  function getTokenBalance(address tokenAddress_) external view returns(uint256){
    IERC20 token=IERC20(tokenAddress_);
    return token.balanceOf(address(this));
  }

  function getTokenSoldAmount(address tokenAddress_) external view returns(uint256){
    return _soldTokens[tokenAddress_];
  }

  function getTokenTransactionMaturityAmount(address tokenAddress_,address walletAddress_,uint256 transactionId_) external view returns(uint256){
    return _tokenTracker[walletAddress_][tokenAddress_].transactionId[transactionId_].maturityAmount;
  }

  function getCurrentMaturityDuration() external view returns(uint256){
    return _maturityDuration;
  }

  function getCurrentMaturityPercentage() external view returns(uint256){
    return _maturityPercentage;
  }

  function getMaturityTimestamp(address tokenAddress_,address walletAddress_,uint256 transactionID_) external view returns(uint256){
     return _tokenTracker[walletAddress_][tokenAddress_].transactionId[transactionID_].maturityTimeStamp;
  }

  function getMaturityStatus(address tokenAddress_,address walletAddress_,uint256 transactionID_) public view returns(bool){
     return _tokenTracker[walletAddress_][tokenAddress_].transactionId[transactionID_].maturityTimeStamp<=block.timestamp;
  }

  function getWithdrawStatus(address tokenAddress_,address walletAddress_,uint256 transactionID_) external view returns(bool){
       return _tokenTracker[walletAddress_][tokenAddress_].transactionId[transactionID_].withdrawStatus;
  }

  function getTotalTransactions(address tokenAddress_,address walletAddress_) external view returns(uint256){
    return _tokenTracker[walletAddress_][tokenAddress_].totalTransactions;
  }

  function purchaseToken(address tokenAddress_) external payable returns(bool){
     
       require(msg.value>0,"Can not purchase tokens with zero amount");
       // generate the pancakes swap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = tokenAddress_;
        path[1] = pancakeswapV2Router.WETH();

        // make the swap
        uint256[] memory value=pancakeswapV2Router.getAmountsOut(1, path);
        uint256 price = value[1];
        require(msg.value>price,"Can not purchase tokens! Does not have Enough amount to purchase 1 token");

        uint256 maturityAmount= (msg.value/price)+(((msg.value/price)*_maturityPercentage)/100);
        uint256 maturityDuration= block.timestamp+_maturityDuration;
        uint256 transactionID=_tokenTracker[msg.sender][tokenAddress_].totalTransactions+1;

        _tokenTracker[msg.sender][tokenAddress_].totalTransactions=transactionID;
        _tokenTracker[msg.sender][tokenAddress_].transactionId[transactionID].withdrawStatus=false;
        _tokenTracker[msg.sender][tokenAddress_].transactionId[transactionID].maturityTimeStamp=maturityDuration;
        _tokenTracker[msg.sender][tokenAddress_].transactionId[transactionID].maturityAmount=maturityAmount;

        _soldTokens[tokenAddress_] += maturityAmount;

        return true;

  }

  function withdrawToken(address tokenAddress_,address walletAddress_,uint256 transactionID_) external returns(bool){

    require( getMaturityStatus( tokenAddress_, walletAddress_, transactionID_),"Tokens Maturity Period yet not completed");
    IERC20 token =IERC20(tokenAddress_);
    require(token.balanceOf(address(this))>=_tokenTracker[msg.sender][tokenAddress_].transactionId[transactionID_].maturityAmount,"Contract doest nat have required amount of token try  later");
    token.transfer(walletAddress_, _tokenTracker[msg.sender][tokenAddress_].transactionId[transactionID_].maturityAmount);
    _tokenTracker[msg.sender][tokenAddress_].transactionId[transactionID_].withdrawStatus=true;

    return true;
  }

  function withdrawUnsoldToken(address tokenAddress_,address walletAddress_,uint256 amount_) external returns(bool){
    require(msg.sender==_owner," You do not have required authority");
    IERC20 token =IERC20(tokenAddress_);
    require(amount_<=(token.balanceOf(address(this))- _soldTokens[tokenAddress_]),"Contract doest nat have required amount of token try  later");
    token.transfer(walletAddress_, amount_);

    return true;
  }

  function withdrawBNB(address toWalletAddress_,uint256 amount_) external returns(bool){
    require(msg.sender==_owner," You do not have required authority");
        require(address(this).balance>=amount_, "contract does not have sufficient BNB");
        payable(toWalletAddress_).transfer(amount_);
        return(true);
  }

  function setCurrentMaturityTimeStamp(uint256 newTimeStamp_) external  returns(bool){
     require(msg.sender==_owner," You do not have required authority");
     _maturityDuration=newTimeStamp_;
     return true;

  }

  function setCurrentMaturityPercentage(uint256 newPercentage_) external  returns(bool){
     require(msg.sender==_owner," You do not have required authority");
     _maturityPercentage=newPercentage_;
     return true;
  }

   function transferOwnerShip(address newOwner_) external  returns(bool){
      require(msg.sender==_owner," You do not have required authority");
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

interface IParkSale {

  event PurchaseToken(uint256 indexed transactionID_,uint256 indexed maturityTimeStamp_,address indexed purchaseWalletAddress_);  

  event WithdrawToken(uint256 indexed transactionID_,uint256 indexed withdrawTimeStamp_,address indexed withdrawWalletAddress_); 

  event WithdrawUnsoldToken(address indexed tokenAddress_,address indexed walletAddress_,uint256 indexed amount_);

  event WithdrawBNB(address indexed toWalletAddress_,uint256 indexed amount_);

  event SetCurrentMaturityTimeStamp(uint256 oldMaturityTimeStamp_,uint256 newMaturityTimeStamp_);

  event SetCurrentMaturityPercentage(uint256 oldMaturityPercentage_,uint256 newMaturityPercentage_);

  function getBNBBalance() external view returns(uint256);

  function getTokenBalance(address tokenAddress_) external view returns(uint256);

  function getTokenSoldAmount(address tokenAddress_) external view returns(uint256);

  function getTokenTransactionMaturityAmount(address tokenAddress_,address walletAddress_,uint256 transactionId_) external view returns(uint256);

  function getCurrentMaturityDuration() external view returns(uint256);

  function getCurrentMaturityPercentage() external view returns(uint256);

  function getMaturityTimestamp(address tokenAddress_,address walletAddress_,uint256 transactionID_) external view returns(uint256);

  function getMaturityStatus(address tokenAddress_,address walletAddress_,uint256 transactionID_) external view returns(bool);

  function getWithdrawStatus(address tokenAddress_,address walletAddress_,uint256 transactionID_) external view returns(bool);

  function getTotalTransactions(address tokenAddress_,address walletAddress_) external view returns(uint256);

  function purchaseToken(address tokenAddress_) external payable returns(bool);

  function withdrawToken(address tokenAddress_,address walletAddress_,uint256 transactionID_) external returns(bool);

  function withdrawUnsoldToken(address tokenAddress_,address walletAddress_,uint256 amount_) external returns(bool);

  function withdrawBNB(address toWalletAddress_,uint256 amount_) external returns(bool);

  function setCurrentMaturityTimeStamp(uint256 newTimeStamp_) external  returns(bool);

  function setCurrentMaturityPercentage(uint256 newPercentage_) external  returns(bool);

  function transferOwnerShip(address newOwner_) external  returns(bool);
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