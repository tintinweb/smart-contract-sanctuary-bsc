// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <8.10.0;

import "../client/node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../client/node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../client/node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "./TokenSale.sol";

contract Token is  Ownable{
	using SafeMath for uint256;

    uint256 public id;
    uint256 pendingCount;
    uint256 _decimals = 10**18;
    uint256 public price;
    uint256 public totalPurchased;
    uint256 public totalSupply;
    bool public activePeriod;
    IERC20 public token;
    TokenSale tokensale;
    mapping(address => uint256) public contributers;
    mapping(address => uint256) funds;
    mapping(uint256 => Period) public periods;

    Purchased[] purchasedTokens;

    /* ========= Structs ======== */ 
    struct Period{
      uint256 startTime;
      uint256 endTime;
      uint256 price;
      uint256 amount;
      uint256 remaining;
      bool active;
    }

    struct Purchased{
        address _address;
        uint256 _amount;
        uint256 _price;
        uint256 _time;
    }

    /* ========= Modifiers ======== */ 
    modifier isActive() {
        require(activePeriod , "No active period");
        _;
    }

    modifier isValidate(uint256 _amount, uint256 _num) {
        _amount = _amount.mul(_decimals.div(10**_num));
        require(_amount >= getMinimumTokens() && _value(_amount) != 0, "The amount of tokens must be greater than minimum tokens");
        require(_amount <= periods[id].remaining, "No available tokens in active period");
        require(msg.sender != address(0),"Unknown address");
        _;
    }

    modifier onlyOwnToken(address _spender){
        require(msg.sender == owner() || msg.sender == _spender, "Permission denied for this address");
        _;
    }

    modifier onlyWhitelist(){
        require(tokensale.checkWhitelist(msg.sender) || msg.sender == owner(), "Permission denied for this address");
        _;
    }

    /* ========= Events ======== */ 
    event MintTokens(uint256 startTime, uint256 endTime, uint256 amount, uint256 price);

    constructor( address _tokensale, address _token) {
        tokensale = TokenSale(_tokensale);
        token = IERC20(_token);
    }

    /*====================================================================================
                            Increase Token Amount for Sale
    ====================================================================================*/
    function initialAmount(uint256 _amount) public onlyOwner{
        // _amount *= _decimals;
         //require(token.balanceOf(msg.sender) >= _amount, "error");
         token.transferFrom(msg.sender, address(this), _amount);
         totalSupply += _amount;
    }

    /*====================================================================================
                                        Minting Method
    ====================================================================================*/
    function mintTokens(uint256 _startTime, uint256 _endTime, uint256 _amount, uint256 _price) public onlyWhitelist returns(bool){
        _amount *= _decimals;
        _preValidateMint(_startTime, _endTime, _amount);
        _initialMint(_startTime, _endTime, _amount, _price);

        tokensale.addActivity(msg.sender, _amount, price, block.timestamp, id, "Mint");
        emit MintTokens(_startTime, _endTime, price, _amount);
        return true;
    }

    /*====================================================================================
                                            Token Methods
    ====================================================================================*/ 
	function requestToken(uint256 _amount, uint256 _num) payable public isActive isValidate(_amount, _num){
        _amount = _amount.mul(_decimals.div(10**_num));
        totalPurchased += _amount;
        contributers[msg.sender] += _amount;
        funds[msg.sender] += msg.value;
        periods[id].remaining = periods[id].remaining - _amount;
        updatePending(msg.sender, _amount);
        tokensale.addActivity(msg.sender, _amount, price, block.timestamp, id, "Request tokens");
        pendingCount++;
    }

    function approveToken(address _spender) public onlyOwner returns(bool){
        require(contributers[_spender] > 0, "This address doesn't have any pending tokens");
        token.transfer( _spender, contributers[_spender]);

        payable(owner()).transfer(funds[_spender]);
        deletePending(_spender);

        purchasedTokens.push(Purchased(_spender, contributers[_spender], price, block.timestamp));
        tokensale.addActivity(_spender, contributers[_spender], price, block.timestamp, id, "Approved");
        contributers[_spender] = funds[_spender] = 0;
        pendingCount--;
        return true;
    }

    function disApproveToken(address _spender) public onlyOwnToken(_spender) returns(bool){
        require(contributers[_spender] > 0, "This address doesn't have any pending tokens");
        payable(_spender).transfer(funds[_spender]);
        periods[id].remaining = periods[id].remaining + contributers[_spender];
        totalPurchased -= contributers[_spender];
        deletePending(_spender);
        tokensale.addActivity(_spender, contributers[_spender], price, block.timestamp, id, "Dis approved!");
        contributers[_spender] = funds[_spender] = 0;
        pendingCount--;
        return true;
    }

    function getPurchasedTokens(address _address) public view returns(Purchased[] memory){
        uint256 _length = purchasedTokens.length;
        Purchased[] memory _purchasedTokens = new Purchased[](_length); 
        for(uint256 i = 0; i < _length; i++){
            if(purchasedTokens[i]._address == _address){
            _purchasedTokens[i] = purchasedTokens[i];
            }
        }
        return _purchasedTokens;
    }

    function getMinimumTokens() public view returns(uint256){
        if ( _decimals > price) return  _decimals.div(price);
        return 1;
    }

    function withdraw() public onlyOwner{
        pendingCount = 0;
        tokensale.removeAllPending();
        deactivatePeriod();
        uint256 returnedTokens = tokensale.getReturnedTokens();
        uint256 amount = totalSupply.add(returnedTokens).sub(totalPurchased);
        totalSupply = 0;
        token.transfer(owner(), amount);
    }

    /*====================================================================================
                                    Period Methods
    ====================================================================================*/
    function getPeriods() public view returns(Period[] memory){
        Period[] memory _periods = new Period[](id);
        for(uint256 i = 0; i < id; i++){
            _periods[i] = periods[i + 1];
        }
        return _periods;
    }

    function getActivePeriod() public view returns(Period memory){
        Period memory _period = periods[id];
        return _period;
    }

    function deactivatePeriod() public onlyOwner returns(bool){
        if(pendingCount > 0) return false;
        periods[id].active = false;
        activePeriod = false;
        return true;
    }

    /*====================================================================================
                                User Methods
    ====================================================================================*/ 
    function addUser(address _address, string memory _name, string memory _email, string memory _role, string memory _about) public returns(bool){
        tokensale.addUser(_address, _name, _email, _role, _about);
        return true;
    }

    function addToWhitelist(address _address) public onlyOwner returns(bool){
        require(!tokensale.checkWhitelist(_address), "This address already exist");
        require(_address != address(0), "Unknown address");
        tokensale.addToWhitelist(_address);
        tokensale.addActivity(_address, 0, 0, block.timestamp, id, "Added to whitelist");
        return true;
    }
    
    function removeFromWhitelist(address _address) public returns(bool){
        if (tokensale.removeFromWhitelist(_address)) {
            tokensale.addActivity(_address, 0, 0, block.timestamp, id, "Removed from whitelist");
            return true;
        } 
        return false;
    }

    /*====================================================================================
                                        Internal Methods
    ====================================================================================*/ 
    function deletePending(address _spender) internal returns(bool){
         return tokensale.deletePending(_spender);
    }

    function updatePending(address _spender, uint256 _amount) internal returns(bool){
        return tokensale.updatePending(_spender, _amount);
    }

    function _preValidateMint(uint256 _startTime, uint256 _endTime, uint256 _amount) internal view{
        require( _startTime < _endTime && _endTime > block.timestamp, "Undefined time");
        require(_amount <= totalSupply && _amount > 0 , "The amount of tokens must be greater than 0 and less than total supply");
        require(_amount <= (totalSupply.sub(totalPurchased)), "No available tokens for this amount");
        require( pendingCount == 0, "There are token requests pending");
    }

    function _initialMint(uint256 _startTime, uint256 _endTime, uint256 _amount, uint256 _price) internal returns(bool){
        if(id > 0) periods[id].active = false;
        price = _price;
        id++;
        periods[id] = Period(_startTime, _endTime, _price, _amount, _amount, true);
        return activePeriod = true;
    }

    function _value(uint256 _amount) internal view returns(uint256){
        if ( _decimals > price) {
            return  _amount.div(_decimals.div(price));
        }
        return price.div(_decimals) * _amount;
    }

    /*====================================================================================
	   Fallback: reverts if Ether is sent to this smart-contract by mistake
    ====================================================================================*/ 
    fallback () external {revert();}
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.17 <8.10.0;

contract TokenSale{

    User[] users;
    address[] whitelist;
    Activity[] activities;
    Pending[] pendingTokens;
    uint256 returnedTokens;

    struct User{
        address _address;
        string full_name;
        string email;
        string role;
        string about;
    }

    struct Activity{
        address _address;
        uint256 _amount;
        uint256 _priceOfToken;
        uint256 _time;
        uint256 _indexOfPeriod;
        string _status;
    }

    struct Pending{
        address _address;
        uint256 _amount;
    }

    /*====================================================================================
                                User Methods
    ====================================================================================*/ 
    function addUser(address _address, string calldata _name, string calldata _email, string calldata _role, string calldata _about) external returns(bool){
        for (uint256 index = 0; index < users.length; index++) {
            if (msg.sender == users[index]._address) {
                users[index] = User(_address, _name, _email, _role, _about);
                return true;
            }  
        }
        users.push(User(_address, _name, _email, _role, _about));
        return true;
    }

    function getUser(address _address) public view returns(User memory){
        User memory _user;
        for (uint256 i = 0; i < users.length; i++) {
            if (users[i]._address == _address) { _user = users[i];}  
        }
        return _user;
    }

    function getUsersList() public view returns(User[] memory){
        uint256 _length = users.length;
        User[] memory _users = new User[](_length); 
        for(uint256 i = 0; i < _length; i++){
            _users[i] = users[i];
        }
        return _users;
    }

    /*====================================================================================
                                Whitelist Methods
    ====================================================================================*/ 
    function addToWhitelist(address _address) external returns(bool){
        whitelist.push(_address);
        return true;
    }
    
    function getWhitelisted() public view returns(address[] memory){
        address[] memory _whitelist = new address[] (whitelist.length);
        for(uint256 i = 0; i < whitelist.length; i++){
            _whitelist[i] = whitelist[i];
        }
        return _whitelist;
    }

    function removeFromWhitelist(address _address) external returns(bool){
        for (uint256 index = 0; index < whitelist.length; index++) {
            if (whitelist[index] == _address) {
                delete whitelist[index];
                return true;
            }
        }
        return false;
    }
    function checkWhitelist(address _address) external  view returns(bool){
        for(uint256 i = 0; i < whitelist.length; i++){
            if(_address == whitelist[i]) return true;
        }
        return false;
    } 
    /*====================================================================================
                                Activity Methods
    ====================================================================================*/ 
    function addActivity(address _address, uint256 _amount, uint256 _price, uint256 _time, uint256 _id, string memory _status) external returns(bool){
        activities.push(Activity(_address, _amount, _price, _time, _id, _status));
        return true;
    }

    function getActivities() public view returns(Activity[] memory){
        uint256 _length = activities.length;
        Activity[] memory _activities = new Activity[](_length); 
        for(uint256 i = 0; i < _length; i++){
            _activities[i] = activities[i];
        }
        return _activities;
    }

    function getPendingTokens() public view returns(Pending[] memory){
        uint256 _length = pendingTokens.length;
        Pending[] memory _pending  = new Pending[](_length);
        for(uint256 i = 0; i < _length; i++){
            _pending[i] = pendingTokens[i];
        }
        return _pending;
    }

    function deletePending(address _spender) external returns(bool){
        uint256 length = pendingTokens.length;
        for (uint256 index = 0; index < length; index++) {
            if (_spender == pendingTokens[index]._address) {
                delete pendingTokens[index];
            }  
        }
        return true;
    }

    function updatePending(address _spender, uint256 _amount) external returns(bool){
        uint256 length = pendingTokens.length;
        for (uint256 index = 0; index < length; index++) {
            if (_spender == pendingTokens[index]._address) {
                pendingTokens[index]._amount += _amount;
                return true;
            } 
        }
        Pending memory _pending = Pending(_spender, _amount);
        pendingTokens.push(_pending);
        return true;
    }

    function removeAllPending() external {
        uint256 length = pendingTokens.length;
        for (uint256 index = 0; index < length; index++) {
            returnedTokens += pendingTokens[index]._amount;
            delete pendingTokens[index];
        }
    }

    function getReturnedTokens() external view returns(uint256){
        return returnedTokens;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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