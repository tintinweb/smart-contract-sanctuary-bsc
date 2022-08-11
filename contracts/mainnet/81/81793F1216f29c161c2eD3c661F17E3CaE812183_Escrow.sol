/**
 *Submitted for verification at BscScan.com on 2022-08-11
*/

// SPDX-License-Identifier: MIT

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/escrowNew.sol

/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/


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

contract Escrow is Ownable {

    using SafeMath for uint256;

    using Counters for Counters.Counter;

    Counters.Counter public dealCount;

    address public nativeTokenFeesReceiver;

    address public superAdmin;
    mapping(address => bool) public admins;

    address public platformNativeTokenAddress;

    mapping(address => bool) public allowedTokens;

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
  
    // Defining function modifier 'onlySeller'
    modifier onlySeller(uint256 _dealID) {
        require(msg.sender == deals[_dealID].seller, "ONLY_SELLER_CAN_EXECUTE_THIS_FUNCTION");
        _;
    }

    // Defining function modifier 'onlyAdmins'
    modifier onlyAdmins() {
        require(admins[msg.sender] ==  true || msg.sender ==  superAdmin, "ONLY_ADMIN+OR_SUPERADMIN_CAN_EXECUTE_THIS_FUNCTION");
        _;
    }

    // Defining function modifier 'onlySuperAdmin'
    modifier onlySuperAdmin() {
        require(msg.sender ==  superAdmin, "ONLY_SUPER_ADMIN_CAN_EXECUTE_THIS_FUNCTION");
        _;
    }

    constructor (address _adminAddress, address[] memory _admins, address _platformNativeTokenAddress, address _nativeTokenFeesReceiver, address[] memory _allowedTokens) {
        superAdmin = _adminAddress;
        nativeTokenFeesReceiver = _nativeTokenFeesReceiver;
        platformNativeTokenAddress = _platformNativeTokenAddress;
        for(uint256 i = 0; i < _admins.length; i++){
            admins[_admins[i]] = true;
        }
        for(uint256 i = 0; i < _allowedTokens.length; i++){
            allowedTokens[_allowedTokens[i]] = true;
        }
    }

    // Function for admin to add new admins
    function addNewAdmins(address[] memory _newAdmins) onlySuperAdmin public {
        for(uint256 i = 0; i < _newAdmins.length; i++){
            admins[_newAdmins[i]] = true;
        }
    }

    // Function for admin to remove any admin
    function removeAdmins(address[] memory _removeAdminsList) onlySuperAdmin public {
        for(uint256 i = 0; i < _removeAdminsList.length; i++){
            admins[_removeAdminsList[i]] = false;
        }
    }    

    // Function for admin to add new tokens
    function addToAllowedTokenList(address[] memory _allowedTokens) onlyAdmins public {
        for(uint256 i = 0; i < _allowedTokens.length; i++){
            allowedTokens[_allowedTokens[i]] = true;
        }
    }

    // Function for admin to remove any token
    function removeFromAllowedTokenList(address[] memory _removeTokensList) onlyAdmins public {
        for(uint256 i = 0; i < _removeTokensList.length; i++){
            allowedTokens[_removeTokensList[i]] = false;
        }
    }

    // Function to place an order
    function placeOrder(uint256 _dealID, address _token, address _buyer, address _seller, uint256 _amount, uint256 _dealPeriodInDays, uint256 _taxAmount) public {
        require(deals[_dealID].startTime == 0, "INVALID_DEAL_ID");
        require(allowedTokens[_token] == true, "INVALID_TOKEN_ADDRESS");
        require(IBEP20(_token).balanceOf(msg.sender) > _amount, "INSUFFICIENT_BUYER_TOKEN_BALANCE");
        require(IBEP20(platformNativeTokenAddress).balanceOf(msg.sender) > _amount, "INSUFFICIENT_BUYER_NATIVE_TOKEN_BALANCE");

        Deal memory deal = Deal(_dealID, _buyer, _seller, _amount, _token, block.timestamp, block.timestamp + _dealPeriodInDays * 1 days, State.await_delivery);
        deals[_dealID] = deal;
        
        // Transfer funds from buyer to contract address
        IBEP20(_token).transferFrom(msg.sender, address(this), _amount);
        IBEP20(platformNativeTokenAddress).transferFrom(msg.sender, nativeTokenFeesReceiver, _taxAmount);
        dealCount.increment();
    }

    // Function for buyer to update his address
    function updateBuyerAddress(uint256 _dealID, address _newBuyerAddress) public {
        require(deals[_dealID].buyer == msg.sender, "ONLY_BUYER");
        deals[_dealID].buyer = _newBuyerAddress;
    }

    // Function for seller to update his address
    function updateSellerAddress(uint256 _dealID, address _newSellerAddress) public {
        require(deals[_dealID].seller == msg.sender, "ONLY_SELLER");
        deals[_dealID].seller = _newSellerAddress;
    }

    // Function for admin to increase deadline for a particular deal
    function extendDealPeriod(uint256 _dealID, uint256 _dealPeriodInDays) onlyAdmins public {
        require(deals[_dealID].startTime != 0, "INVALID_DEAL_ID");
        deals[_dealID].endTime = deals[_dealID].endTime.add(_dealPeriodInDays * 1 days);
    }
    
    // Function for buyer to confirm delivery 
    function confirmDelivery(uint256 _dealID) instate(_dealID, State.await_delivery) public {
        require(msg.sender == deals[_dealID].buyer || msg.sender ==  superAdmin, "ONLY_BUYER_OR_SUPER_ADMIN_CAN_EXECUTE_THIS_FUNCTION");
        require(deals[_dealID].startTime != 0, "INVALID_DEAL_ID");
        deals[_dealID].dealState = State.delivered;
    }
      
    // Function for buyer/seller/admin/super-admin to cancel deal
    function cancelDeal(uint256 _dealID) public {
        if (deals[_dealID].dealState == State.await_delivery) {
            require(msg.sender == deals[_dealID].buyer || msg.sender == deals[_dealID].seller || admins[msg.sender] ==  true || msg.sender ==  superAdmin, "UNAUTHORIZED_ACCESS");
            require(deals[_dealID].startTime != 0, "INVALID_DEAL_ID");
        } else if (deals[_dealID].dealState == State.delivered) {
            require(deals[_dealID].startTime != 0, "INVALID_DEAL_ID");
        }
        deals[_dealID].dealState = State.cancelled;
    }

    // Function for admin to transfer the funds to seller if the order was delivered
    function transferPaymentToSeller(uint256 _dealID) onlyAdmins instate(_dealID, State.delivered) public {
        require(deals[_dealID].startTime != 0, "INVALID_DEAL_ID");
        // Transfer funds from contract to seller
        IBEP20(deals[_dealID].token).transfer(deals[_dealID].seller, deals[_dealID].amount);
        deals[_dealID].dealState = State.complete;
    }

    // Function for admin if buyer cancels the deal before confirming delivery
    function RefundPayment(uint256 _dealID) onlyAdmins instate(_dealID, State.cancelled) public {
        require(deals[_dealID].startTime != 0, "INVALID_DEAL_ID");
       // Transfer funds back to buyer
       IBEP20(deals[_dealID].token).transfer(deals[_dealID].buyer, deals[_dealID].amount);
       deals[_dealID].dealState = State.complete;
    }

    // Function for admin to withdraw funds for a deal if it expired
    function withdrawFunds(uint256 _dealID, address _receiver) onlyAdmins public {
        require(deals[_dealID].startTime != 0, "INVALID_DEAL_ID");
        require(block.timestamp > deals[_dealID].endTime, "Deal is yet to be expired");
        // Transfer funds to admin
        IBEP20(deals[_dealID].token).transfer(_receiver, deals[_dealID].amount);
    }

    function updateNativeTokenFeesReceiver(address _newNativeTokenFeesReceiver) onlyAdmins public {
        nativeTokenFeesReceiver = _newNativeTokenFeesReceiver;
    }
    
}