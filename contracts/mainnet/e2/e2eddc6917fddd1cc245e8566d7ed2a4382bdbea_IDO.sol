/**
 *Submitted for verification at BscScan.com on 2022-12-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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


/**
* @dev Smart contract for the sale of tokens for BUSD.
* During the deployment, you must specify the address of the token being sold. 
* Later it can be changed using the setToken function.
* BUSD address: 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
* https://bscscan.com/token/0xe9e7cea3dedca5984780bafc599bd69add087d56
* IMPORTENT: Before the start of the token sale, it is necessary 
* to transfer tokens to the address of the contract.
* Before sending BUSD from the buyer's balance, 
* it is necessary to call the "approve" function.
*/
contract IDO is Ownable, Pausable {
    IERC20 private immutable BUSD;
    IERC20 public TOKEN;
    /**
    * @dev RATE = n * 10 ** 18
    * fee = n %
    */
    uint public RATE;
    uint public fee;

    event SetToken(address newToken);
    event SetRate(uint newRate);
    event WithdrawBUSD(address to, uint amount);
    event WithdrawToken(address to, uint amount);
    event BuyTokens(address buyer, uint amount, uint cost, uint costFee);
    event SetFee(uint newFee);

    constructor(address _token) {
        BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        require(_token != address(0));
        TOKEN = IERC20(_token);
        RATE = 1e18 / 10;
        fee = 1;
    }

    /**
    * @dev Sets the address of the tokens being sold.
    */
    function  setToken(address _newToken) external onlyOwner {
        require(_newToken != address(0), "Address _newToken can't be zero!");
        TOKEN = IERC20(_newToken);
        emit SetToken(_newToken);
    }

    /**
    * @dev Sets the value of tokens.
    * _newRate the new value must be specified from the calculation:
    * cost = _newRate / 100  (busd)
    * for example:
    * cost 1$ - _newRate = 100
    * cost 2$ - _newRate = 200
    * cost 0.1$ - _newRate = 10
    * cost 0.01$ - _newRate = 1
    */
    function setRate(uint _newRate) external onlyOwner {
        require(_newRate != RATE, "This value has already been set!");
        require(_newRate != 0, "Value RATE can't be zero!");
        RATE = 1e18 * _newRate / 100;
        emit SetRate(_newRate);
    }

    /**
    * @dev Sets the transaction fee in %.
    * The commission may be zero.
    * setFee(0)
    */
    function setFee(uint _newFee) external onlyOwner {
        require(fee != _newFee, "This value has already been set!");
        require(_newFee <= 100, "The fee cannot be more than 100 percent");
        fee = _newFee;
        emit SetFee(_newFee);
    }

    /**
    * @dev The function debits BUSD from the buyer's balance and sends tokens.
    * To make a transaction, you need permission to withdraw funds from the wallet from the buyer (approve).
    */
    function buyToken(uint _value) external whenNotPaused {
        require(_value > 0, "Value can't be zero!");
        uint _valueToken = _value * 1e18;
        uint _costToken = _value * RATE;
        uint _devFee = _costToken * fee / 100;
        uint _costTotal = _costToken + _devFee;
        require(balanceToken() >= _valueToken, "Not enough tokens in shop!");
        require(BUSD.allowance(msg.sender, address(this)) >= _costTotal, "BUSD is't approved!");
        BUSD.transferFrom(msg.sender, address(this), _costTotal);
        TOKEN.transfer(msg.sender, _valueToken);
        emit BuyTokens(msg.sender, _value, _costTotal, _devFee);
    }
    
    /**
    * @dev Returns the balance of tokens on the contract.
    */
    function balanceToken() public view returns(uint) {
        return TOKEN.balanceOf(address(this));
    }

    /**
    * @dev Returns the balance of BUSD on the contract.
    */
    function balanceBUSD() public view returns(uint) {
        return BUSD.balanceOf(address(this));
    }

    /**
    * @dev Returns the number of BUSD allowed to be debited.
    */
    function approveBUSD() public view returns(uint) {
        return BUSD.allowance(msg.sender, address(this));
    }

    /**
    * @dev The contract owner transfers BUSD from the contract to the specified address.
    */
    function withdrawBUSD(address _to) external onlyOwner {
        uint _amountBUSD = balanceBUSD();
        require(_amountBUSD > 0, "Balance BUSD equel zero!");
        BUSD.transfer(_to, _amountBUSD);
        emit WithdrawBUSD(_to, _amountBUSD);
    }

    /**
    * @dev The contract owner transfers tokens from the contract to the specified address.
    */
    function withdrawToken(address _to) external onlyOwner {
        uint _amountTokens = balanceToken();
        require(_amountTokens > 0, "Balance tokens equel zero!");
        TOKEN.transfer(_to, _amountTokens);
        emit WithdrawToken(_to, _amountTokens);
    }

    /**
    * @dev The function of renouncing the ownership of the contract is blocked.
    */
    function renounceOwnership() public override onlyOwner {
        revert("you cannot give up ownership of the contract!");
    }

    /**
    * @dev The function temporarily stops token sales.
    */
    function pause() public onlyOwner {
        _pause();
    }

    /**
    * @dev The function resumes token sales.
    */
    function unpause() public onlyOwner {
        _unpause();
    }
}