/**
 *Submitted for verification at BscScan.com on 2022-06-23
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 < 0.9.0;


library SafeMath {
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
     *
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
     *
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


// File: @openzeppelin/contracts/utils/Counters.sol

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

pragma solidity ^0.8.6;

interface IBEP20 {
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

    function _transfer(address _from, address _to, uint256 _value) external ;
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

contract Escrow {

    using SafeMath for uint256;

    using Counters for Counters.Counter;

    Counters.Counter public _dealIDs;

    address public admin;
    uint256 public adminFeePercentage;
    address public platformNativeTokenAddress;

    mapping(address => bool) allowedTokens;

    enum State{
        await_delivery, delivered, complete, cancelled
    }

    struct Deal {
        uint256 dealID;
        address buyer;
        address seller;
        uint256 amount;
        address token;
        uint256 startTime;
        uint256 endTime;
        State dealState;
    }

    mapping(uint256 => Deal) public deals;

    // Defining function modifier 'instate'
    modifier instate(uint256 _dealID, State expected_state){
          
        require(deals[_dealID].dealState == expected_state);
        _;
    }

   // Defining function modifier 'onlyBuyer'
    modifier onlyBuyer(uint256 _dealID) {
        require(msg.sender == deals[_dealID].buyer, "ONLY_BUYER_CAN_EXECUTE_THIS_FUNCTION");
        _;
    }
  
    // Defining function modifier 'onlySeller'
    modifier onlySeller(uint256 _dealID) {
        require(msg.sender == deals[_dealID].seller, "ONLY_SELLER_CAN_EXECUTE_THIS_FUNCTION");
        _;
    }

    // Defining function modifier 'onlyAdmin'
    modifier onlyAdmin() {
        require(msg.sender == admin, "ONLY_ADMIN_CAN_EXECUTE_THIS_FUNCTION");
        _;
    }

    constructor (address _adminAddress, uint256 _adminFeePercentage, address _platformNativeTokenAddress, address[] memory _allowedTokens) {
        admin = _adminAddress;
        adminFeePercentage = _adminFeePercentage;
        platformNativeTokenAddress = _platformNativeTokenAddress;
        for(uint256 i = 0; i < _allowedTokens.length; i++){
            allowedTokens[_allowedTokens[i]] = true;
        }
    }

    // Function for admin to update admin charges
    function updateAdminFeePercentage(uint256 _newAdminFeePercentage) onlyAdmin public {
        adminFeePercentage = _newAdminFeePercentage;
    }

    // Function for admin to add new tokens
    function addToAllowedTokenList(address[] memory _allowedTokens) onlyAdmin public {
        for(uint256 i = 0; i < _allowedTokens.length; i++){
            allowedTokens[_allowedTokens[i]] = true;
        }
    }

    // Function for admin to remove any token
    function removeFromAllowedTokenList(address[] memory _removeTokensList) onlyAdmin public {
        for(uint256 i = 0; i < _removeTokensList.length; i++){
            allowedTokens[_removeTokensList[i]] = false;
        }
    }

    // Function for buyer to place an order
    function placeOrder(uint256 _dealID, address _token, address _seller, uint256 _amount, uint256 _taxAmount, uint256 _dealPeriodInDays) public {
        require(deals[_dealID].startTime == 0, "INVALID_DEAL_ID");
        require(allowedTokens[_token] == true, "INVALID_TOKEN_ADDRESS");
        require(IBEP20(_token).balanceOf(msg.sender) > _amount, "INSUFFICIENT_BUYER_TOKEN_BALANCE");
        require(IBEP20(platformNativeTokenAddress).balanceOf(msg.sender) > _amount, "INSUFFICIENT_BUYER_NATIVE_TOKEN_BALANCE");

        Deal memory deal = Deal(_dealID, msg.sender, _seller, _amount, _token, block.timestamp, block.timestamp + _dealPeriodInDays * 1 days, State.await_delivery);
        deals[_dealID] = deal;
        // Transfer funds from buyer to contract address
        IBEP20(_token).transferFrom(msg.sender, address(this), _amount);
        IBEP20(platformNativeTokenAddress).transferFrom(msg.sender, admin, _taxAmount);
    }

    // Function for admin to increase deadline for a particular deal
    function extendDealPeriod(uint256 _dealID, uint256 _dealPeriodInDays) onlyAdmin public {
        require(deals[_dealID].startTime != 0, "INVALID_DEAL_ID");
        deals[_dealID].endTime = deals[_dealID].endTime.add(_dealPeriodInDays * 1 days);
    }
    
    // Function for buyer to confirm delivery 
    function confirmDelivery(uint256 _dealID) onlyBuyer(_dealID) instate(_dealID, State.await_delivery) public {
        require(deals[_dealID].startTime != 0, "INVALID_DEAL_ID");
        deals[_dealID].dealState = State.delivered;
    }
      
    // Function for buyer to cancel deal
    function cancelDeal(uint256 _dealID) onlyBuyer(_dealID) instate(_dealID, State.await_delivery) public {
        require(deals[_dealID].startTime != 0, "INVALID_DEAL_ID");
        deals[_dealID].dealState = State.cancelled;
    }

    // Function for admin to transfer the funds to seller if the order was delivered
    function tranfserPaymentToSeller(uint256 _dealID) onlyAdmin instate(_dealID, State.delivered) public {
        require(deals[_dealID].startTime != 0, "INVALID_DEAL_ID");
        // Transfer funds from contract to seller
        IBEP20(deals[_dealID].token).transfer(deals[_dealID].seller, deals[_dealID].amount);
        deals[_dealID].dealState = State.complete;
    }

    // Function for admin if buyer cancels the deal before confirming delivery
    function RefundPayment(uint256 _dealID) onlyAdmin instate(_dealID, State.cancelled) public {
        require(deals[_dealID].startTime != 0, "INVALID_DEAL_ID");
       // Transfer funds back to buyer
       IBEP20(deals[_dealID].token).transfer(deals[_dealID].buyer, deals[_dealID].amount);
       deals[_dealID].dealState = State.complete;
    }

    // Function for admin to withdraw funds for a deal if it expired
    function withdrawFunds(uint256 _dealID) onlyAdmin public {
        require(deals[_dealID].startTime != 0, "INVALID_DEAL_ID");
        require(block.timestamp > deals[_dealID].endTime, "Deal is yet to be expired");
        // Transfer funds to admin
        IBEP20(deals[_dealID].token).transfer(admin, deals[_dealID].amount);
    }
    
}