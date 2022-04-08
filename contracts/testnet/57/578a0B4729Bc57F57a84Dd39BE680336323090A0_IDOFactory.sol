// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "./IDO.sol";
 
contract IDOFactory is Ownable {
    uint256 public totalIdos;
    address[] public allIdos;
 
    address public feeAddress;
    event IdoCreated(address ido, string uri, uint256 index);
    event onFeeAddressChanged(address _feeAddress);
 
    constructor(address _feeAddress) {
        feeAddress = _feeAddress;
    }
 
    function changeFeeAddress(address _feeAddress) public onlyOwner {
        require(_feeAddress != address(0), "invalid address");
        feeAddress = _feeAddress;
        emit onFeeAddressChanged(feeAddress);
    }
 
    function createIDO(
        string memory _uri,
        address _tokenAddress,
        uint256 _tradeValue,
        uint256 _tokensForSale,
        uint256 _startDate,
        uint256 _endDate,
        uint256 _individualMinimumAmount,
        uint256 _individualMaximumAmount,
        bool _isTokenSwapAtomic,
        uint256 _minimumRaise,
        uint256 _feeAmount,
        bool _hasWhitelisting
    ) public onlyOwner {
        IDO _ido = new IDO(
            _tokenAddress,
            _tradeValue,
            _tokensForSale,
            _startDate,
            _endDate,
            _individualMinimumAmount,
            _individualMaximumAmount,
            _isTokenSwapAtomic,
            _minimumRaise,
            _feeAmount,
            _hasWhitelisting,
            feeAddress
        );
 
        _ido.setTokenURI(_uri);
        _ido.transferOwnership(msg.sender);
        emit IdoCreated(address(_ido), _uri, totalIdos);
        totalIdos = totalIdos + 1;
        allIdos.push(address(_ido));
    }
}

// SPDX-License-Identifier: GPL-3.0
 
 
 
pragma solidity ^0.8.0;
/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
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
     *
     * _Available since v2.4.0._
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
     *
     * _Available since v2.4.0._
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
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: GPL-3.0
 
 
 
pragma solidity ^0.8.0;
 
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);
 
    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);
 
    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);
 
    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);
 
    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);
 
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
    function allowance(address _owner, address spender) external view returns (uint256);
 
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

// SPDX-License-Identifier: GPL-3.0
 
import "@openzeppelin/contracts/access/Ownable.sol";
 
 
pragma solidity ^0.8.0;

contract IDOWhitelist is Ownable {
 
    mapping(address => bool) public whitelist;
    address[] public whitelistedAddresses;
    bool public hasWhitelisting = false;
 
    event AddedToWhitelist(address[] indexed accounts);
    event RemovedFromWhitelist(address indexed account);
 
    modifier onlyWhitelisted() {
        if(hasWhitelisting){
            require(isWhitelisted(msg.sender));
        }
        _;
    }
 
    constructor (bool _hasWhitelisting) {
        hasWhitelisting = _hasWhitelisting;
    }
 
    function add(address[] memory _addresses) public onlyOwner {
        for (uint i = 0; i < _addresses.length; i++) {
            require(whitelist[_addresses[i]] != true);
            whitelist[_addresses[i]] = true;
            whitelistedAddresses.push(_addresses[i]);
        }
        emit AddedToWhitelist(_addresses);
    }
 
    function remove(address _address, uint256 _index) public onlyOwner {
        require(_address == whitelistedAddresses[_index]);
        whitelist[_address] = false;
        delete whitelistedAddresses[_index];
        emit RemovedFromWhitelist(_address);
    }
 
    function getWhitelistedAddresses() public view returns(address[] memory) {
        return whitelistedAddresses;
    } 
 
    function isWhitelisted(address _address) public view returns(bool) {
        return whitelist[_address];
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
 
import "./IDOWhitelist.sol";
import "./IERC20.sol";
import "./SafeMath.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
 
 
contract IDO is Pausable, IDOWhitelist {
    using SafeMath for uint256;
    uint256 increment = 0;
 
    mapping(uint256 => Purchase) public purchases; /* Purchasers mapping */
    address[] public buyers; /* Current Buyers Addresses */
    uint256[] public purchaseIds; /* All purchaseIds */
    mapping(address => uint256[]) public myPurchases; /* Purchasers mapping */
 
    IERC20 public erc20;
    string public idoURI;
 
    bool public isSaleFunded = false;
    uint public decimals = 0;
 
    bool public unsoldTokensReedemed = false;
    uint256 public tradeValue; /* Price in Wei */
    uint256 public startDate; /* Start Date  */
    uint256 public endDate;  /* End Date  */
    uint256 public individualMinimumAmount = 0;  /* Minimum Amount Per Address */
    uint256 public individualMaximumAmount = 0;  /* Minimum Amount Per Address */
    uint256 public minimumRaise = 0;  /* Minimum Amount of Tokens that have to be sold */
    uint256 public tokensAllocated = 0; /* Tokens Available for Allocation - Dynamic */
    uint256 public tokensForSale = 0; /* Tokens Available for Sale */
    bool    public isTokenSwapAtomic; /* Make token release atomic or not */
    address payable public FEE_ADDRESS;
    uint256 public feePercentage = 1; /* Default Fee 1% */
 
    struct Purchase {
        uint256 amount;
        address purchaser;
        uint256 ethAmount;
        uint256 timestamp;
        bool wasFinalized /* Confirm the tokens were sent already */;
        bool reverted /* Confirm the tokens were sent already */;
    }
 
    event PurchaseEvent(uint256 amount, address indexed purchaser, uint256 timestamp);
 
    event onURIChanged(string uri);
 
    constructor(address _tokenAddress, uint256 _tradeValue, uint256 _tokensForSale, uint256 _startDate, 
        uint256 _endDate, uint256 _individualMinimumAmount, uint256 _individualMaximumAmount, bool _isTokenSwapAtomic, uint256 _minimumRaise,
        uint256 _feeAmount, bool _hasWhitelisting, address _FEE_ADDRESS
    )  IDOWhitelist(_hasWhitelisting) {
 
        /* Confirmations */
 
        require(block.timestamp < _endDate, "End Date should be further than current date");
        require(block.timestamp < _startDate, "Start Date Date should be further than current date");
        require(_startDate < _endDate, "End Date higher than Start Date");
        require(_tokensForSale > 0, "Tokens for Sale should be > 0");
        require(_tokensForSale > _individualMinimumAmount, "Tokens for Sale should be > Individual Minimum Amount");
        require(_individualMaximumAmount >= _individualMinimumAmount, "Individual Maximim AMount should be > Individual Minimum Amount");
        require(_minimumRaise <= _tokensForSale, "Minimum Raise should be < Tokens For Sale");
        require(_feeAmount >= feePercentage, "Fee Percentage has to be >= 1");
        require(_feeAmount <= 99, "Fee Percentage has to be < 100");
 
        FEE_ADDRESS=payable(_FEE_ADDRESS);
        startDate = _startDate; 
        endDate = _endDate;
        tokensForSale = _tokensForSale;
        tradeValue = _tradeValue;
 
        individualMinimumAmount = _individualMinimumAmount; 
        individualMaximumAmount = _individualMaximumAmount; 
        isTokenSwapAtomic = _isTokenSwapAtomic;
 
        if(!_isTokenSwapAtomic){ /* If raise is not atomic swap */
            minimumRaise = _minimumRaise;
        }
 
        erc20 = IERC20(_tokenAddress);
        decimals = erc20.decimals();
        feePercentage = _feeAmount;
    }
 
 
 
    function setTokenURI(string memory _idoURI) public onlyOwner {
        idoURI = _idoURI;
 
        emit onURIChanged(_idoURI);
    }
 
    /**
    * Modifier to make a function callable only when the contract has Atomic Swaps not available.
    */
    modifier isNotAtomicSwap() {
        require(!isTokenSwapAtomic, "Has to be non Atomic swap");
        _;
    }
 
     /**
    * Modifier to make a function callable only when the contract has Atomic Swaps not available.
    */
    modifier isSaleFinalized() {
        require(hasFinalized(), "Has to be finalized");
        _;
    }
 
     /**
    * Modifier to make a function callable only when the swap time is open.
    */
    modifier isSaleOpen() {
        require(isOpen(), "Has to be open");
        _;
    }
 
     /**
    * Modifier to make a function callable only when the contract has Atomic Swaps not available.
    */
    modifier isSalePreStarted() {
        require(isPreStart(), "Has to be pre-started");
        _;
    }
 
    /**
    * Modifier to make a function callable only when the contract has Atomic Swaps not available.
    */
    modifier isFunded() {
        require(isSaleFunded, "Has to be funded");
        _;
    }
 
 
    /* Get Functions */
    function isBuyer(uint256 purchase_id) public view returns (bool) {
        return (msg.sender == purchases[purchase_id].purchaser);
    }
 
    /* Get Functions */
    function totalRaiseCost() public view returns (uint256) {
        return (cost(tokensForSale));
    }
 
    function availableTokens() public view returns (uint256) {
        return erc20.balanceOf(address(this));
    }
 
    function tokensLeft() public view returns (uint256) {
        return tokensForSale - tokensAllocated;
    }
 
    function hasMinimumRaise() public view returns (bool){
        return (minimumRaise != 0);
    }
 
    /* Verify if minimum raise was not achieved */
    function minimumRaiseNotAchieved() public view returns (bool){
        require(cost(tokensAllocated) < cost(minimumRaise), "TotalRaise is bigger than minimum raise amount");
        return true;
    }
 
    /* Verify if minimum raise was achieved */
    function minimumRaiseAchieved() public view returns (bool){
        if(hasMinimumRaise()){
            require(cost(tokensAllocated) >= cost(minimumRaise), "TotalRaise is less than minimum raise amount");
        }
        return true;
    }
 
    function hasFinalized() public view returns (bool){
        return block.timestamp > endDate;
    }
 
    function hasStarted() public view returns (bool){
        return block.timestamp >= startDate;
    }
 
    function isPreStart() public view returns (bool){
        return block.timestamp < startDate;
    }
 
    function isOpen() public view returns (bool){
        return hasStarted() && !hasFinalized();
    }
 
    function hasMinimumAmount() public view returns (bool){
       return (individualMinimumAmount != 0);
    }
 
    function cost(uint256 _amount) public view returns (uint){
        return _amount.mul(tradeValue).div(10**decimals); 
    }
 
    function getPurchase(uint256 _purchase_id) external view returns (uint256, address, uint256, uint256, bool, bool){
        Purchase memory purchase = purchases[_purchase_id];
        return (purchase.amount, purchase.purchaser, purchase.ethAmount, purchase.timestamp, purchase.wasFinalized, purchase.reverted);
    }
 
    function getPurchaseIds() public view returns(uint256[] memory) {
        return purchaseIds;
    }
 
    function getBuyers() public view returns(address[] memory) {
        return buyers;
    }
 
    function getMyPurchases(address _address) public view returns(uint256[] memory) {
        return myPurchases[_address];
    }
 
    /* Fund - Pre Sale Start */
    function fund(uint256 _amount) public isSalePreStarted {
 
        /* Confirm transfered tokens is no more than needed */
        require(availableTokens().add(_amount) <= tokensForSale, "Transfered tokens have to be equal or less than proposed");
 
        /* Transfer Funds */
        require(erc20.transferFrom(msg.sender, address(this), _amount), "Failed ERC20 token transfer");
 
        /* If Amount is equal to needed - sale is ready */
        if(availableTokens() == tokensForSale){
            isSaleFunded = true;
        }
    }
 
    /* Action Functions */
    function swap(uint256 _amount) payable external whenNotPaused isFunded isSaleOpen onlyWhitelisted {
 
        /* Confirm Amount is positive */
        require(_amount > 0, "Amount has to be positive");
 
        /* Confirm Amount is less than tokens available */
        require(_amount <= tokensLeft(), "Amount is less than tokens available");
 
        /* Confirm the user has funds for the transfer, confirm the value is equal */
        require(msg.value == cost(_amount), "User has to cover the cost of the swap in ETH, use the cost function to determine");
 
        /* Confirm Amount is bigger than minimum Amount */
        require(_amount >= individualMinimumAmount, "Amount is smaller than minimum amount");
 
        /* Confirm Amount is smaller than maximum Amount */
        require(_amount <= individualMaximumAmount, "Amount is bigger than maximum amount");
 
        /* Verify all user purchases, loop thru them */
        uint256[] memory _purchases = getMyPurchases(msg.sender);
        uint256 purchaserTotalAmountPurchased = 0;
        for (uint i = 0; i < _purchases.length; i++) {
            Purchase memory _purchase = purchases[_purchases[i]];
            purchaserTotalAmountPurchased = purchaserTotalAmountPurchased.add(_purchase.amount);
        }
        require(purchaserTotalAmountPurchased.add(_amount) <= individualMaximumAmount, "Address has already passed the max amount of swap");
 
        if(isTokenSwapAtomic){
            /* Confirm transfer */
            require(erc20.transfer(msg.sender, _amount), "ERC20 transfer didnt work");
        }
 
        uint256 purchase_id = increment;
        increment = increment.add(1);
 
        /* Create new purchase */
        Purchase memory purchase = Purchase(_amount, msg.sender, msg.value, block.timestamp, isTokenSwapAtomic, false);
        purchases[purchase_id] = purchase;
        purchaseIds.push(purchase_id);
        myPurchases[msg.sender].push(purchase_id);
        buyers.push(msg.sender);
        tokensAllocated = tokensAllocated.add(_amount);
        emit PurchaseEvent(_amount, msg.sender, block.timestamp);
    }
 
    /* Redeem tokens when the sale was finalized */
    function redeemTokens(uint256 purchase_id) external isNotAtomicSwap isSaleFinalized whenNotPaused {
        /* Confirm it exists and was not finalized */
        require((purchases[purchase_id].amount != 0) && !purchases[purchase_id].wasFinalized, "Purchase is either 0 or finalized");
        require(isBuyer(purchase_id), "Address is not buyer");
        purchases[purchase_id].wasFinalized = true;
        require(erc20.transfer(msg.sender, purchases[purchase_id].amount), "ERC20 transfer failed");
    }
 
    /* Retrieve Minumum Amount */
    function redeemGivenMinimumGoalNotAchieved(uint256 purchase_id) external isSaleFinalized isNotAtomicSwap {
        require(hasMinimumRaise(), "Minimum raise has to exist");
        require(minimumRaiseNotAchieved(), "Minimum raise has to be reached");
        /* Confirm it exists and was not finalized */
        require((purchases[purchase_id].amount != 0) && !purchases[purchase_id].wasFinalized, "Purchase is either 0 or finalized");
        require(isBuyer(purchase_id), "Address is not buyer");
        purchases[purchase_id].wasFinalized = true;
        purchases[purchase_id].reverted = true;
        payable(msg.sender).transfer(purchases[purchase_id].ethAmount);
    }
 
    /* Admin Functions */
    function withdrawFunds() external onlyOwner whenNotPaused isSaleFinalized {
        require(minimumRaiseAchieved(), "Minimum raise has to be reached");
        FEE_ADDRESS.transfer(address(this).balance.mul(feePercentage).div(100)); /* Fee Address */
        payable( msg.sender).transfer(address(this).balance);
    }  
 
    function withdrawUnsoldTokens() external onlyOwner isSaleFinalized {
        require(!unsoldTokensReedemed);
        uint256 unsoldTokens;
        if(hasMinimumRaise() && 
            (cost(tokensAllocated) < cost(minimumRaise))){ /* Minimum Raise not reached */
                unsoldTokens = tokensForSale;
        }else{
            /* If minimum Raise Achieved Redeem All Tokens minus the ones */
            unsoldTokens = tokensForSale.sub(tokensAllocated);
        }
 
        if(unsoldTokens > 0){
            unsoldTokensReedemed = true;
            require(erc20.transfer(msg.sender, unsoldTokens), "ERC20 transfer failed");
        }
    }   
 
    function removeOtherERC20Tokens(address _tokenAddress, address _to) external onlyOwner isSaleFinalized {
        require(_tokenAddress != address(erc20), "Token Address has to be diff than the erc20 subject to sale"); // Confirm tokens addresses are different from main sale one
        IERC20 erc20Token = IERC20(_tokenAddress);
        require(erc20Token.transfer(_to, erc20Token.balanceOf(address(this))), "ERC20 Token transfer failed");
    } 
 
    /* Safe Pull function */
    function safePull() payable external onlyOwner whenPaused {
        payable(msg.sender).transfer(address(this).balance);
        erc20.transfer(msg.sender, erc20.balanceOf(address(this)));
    }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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