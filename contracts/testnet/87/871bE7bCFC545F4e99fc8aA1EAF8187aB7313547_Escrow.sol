// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


interface IDexRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
}

interface IDexFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}



contract Escrow {
  address payable public owner;
  uint256 public totalBalance;
  enum PaymentStatus { Pending, Completed, Refunded }
  IERC20  StriptoToken;
  IDexRouter public immutable uniswapV2Router;
  address WBNB = address(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd);
  //address public immutable uniswapV2Pair;
  struct Payment {
    address buyer;
    uint256 amount;
    uint256 itemId;
    uint createdOn;
    PaymentStatus status;
  }

 using Counters for Counters.Counter;
 Counters.Counter private _paymentIds; // Id for each individual item

 mapping(uint256 => Payment) private payments;

  event Deposit(address depositor, uint256 deposited);
  constructor() {

     owner  =  payable(msg.sender);
     StriptoToken  = IERC20(0x65329C66933d8fE9BaA666dFEB2d0F57f315f27e); // Strip token address
    
     IDexRouter _uniswapV2Router = IDexRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
    // uniswapV2Pair = IDexFactory(_uniswapV2Router.factory()).createPair(address(StriptoToken), _uniswapV2Router.WETH());
     
     uniswapV2Router = _uniswapV2Router;

   
  }

  modifier onlyOwner() {
      require(msg.sender == owner, "Must be an owner.");
        _;
  }

function depositToEscrow(uint256 _itemId,address sender) external payable returns (uint256){
          uint256 _amount=msg.value;
          _paymentIds.increment();
          uint256 paymentId = _paymentIds.current();
          payments[paymentId] = Payment(address(sender), _amount,_itemId,block.timestamp,PaymentStatus.Pending);
          totalBalance += _amount; 
          uint256 paymentCount = _paymentIds.current();
          uint256 amount =0;
          for (uint256 i = 0; i < paymentCount; i++) {
              
              if (payments[i + 1].itemId == _itemId && payments[i + 1].status==PaymentStatus.Pending) {
                   amount += payments[i + 1].amount;
                 
              }

          }
          emit Deposit(msg.sender, msg.value); 
          return amount;

}

  function depositPayment(uint256 _itemId,address sender) external payable returns (uint256) {
         uint256 _amount=msg.value;
         address[] memory path = new address[](2);
         path[0] = address(StriptoToken);
         path[1] = WBNB;

       
       // make the swap

       require(StriptoToken.approve(address(uniswapV2Router), (_amount + 10000)), 'Uniswap approval failed');

       uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _amount,
            0, 
            path,
            address(this),
            block.timestamp
        ); 
          _paymentIds.increment();
           uint256 paymentId = _paymentIds.current();
          payments[paymentId] = Payment(address(sender), _amount,_itemId,block.timestamp,PaymentStatus.Pending);
          totalBalance += _amount; 
          uint256 paymentCount = _paymentIds.current();
          uint256 amount =0;
          
          for (uint256 i = 0; i < paymentCount; i++) {
              
              if (payments[i + 1].itemId == _itemId && payments[i + 1].status==PaymentStatus.Pending) {
                   amount += payments[i + 1].amount;
                 
              }

          }

          return amount;

  }

  function getEscrowItemBalance(uint256 _itemId) public view returns (uint256){
             uint256 paymentCount = _paymentIds.current();
             uint256 amount =0;
            
             for (uint256 i = 0; i < paymentCount; i++) {
                if (payments[i + 1].itemId == _itemId && payments[i + 1].status==PaymentStatus.Pending) {
                     amount += payments[i + 1].amount;
                   
                }
            }

            return amount;
          
  }

  function withdrawStrippedAmount(uint256 _itemId, address _toAddress) onlyOwner external returns (uint256){
             uint256 paymentCount = _paymentIds.current();
             uint256 amount =0;
            
            for (uint256 i = 0; i < paymentCount; i++) {
                if (payments[i + 1].itemId == _itemId && payments[i + 1].status==PaymentStatus.Pending) {
                    amount += payments[i + 1].amount;
                    payments[i + 1].status=PaymentStatus.Completed;
                   
                }
            }
            require(totalBalance>=amount, "Insufficient tokens in Escrow.");
            payable(_toAddress).transfer(amount);
            totalBalance = totalBalance-amount;
            return totalBalance;
             
  }





}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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