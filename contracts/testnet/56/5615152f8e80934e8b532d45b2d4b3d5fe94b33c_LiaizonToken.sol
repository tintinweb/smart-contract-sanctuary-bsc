/**
 *Submitted for verification at BscScan.com on 2022-09-06
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, a minter address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;
    address public minter;

    /**
      * @dev The Ownable constructor sets the original `owner` of the contract to the sender
      * account.
    */
    constructor() {
        owner = msg.sender;
        minter = msg.sender;
    }

    /**
      * @dev Throws if called by any account other than the owner.
      */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
      * @dev Throws if called by any account other than the minter.
      */
    modifier onlyMinter() {
        require(msg.sender == minter);
        _;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function changeOwner(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
        emit OwnerChanged(owner);
    }

    /**
    * @dev Allows the current owner to transfer control of the minting.
    * @param newMinter The address to transfer ownership to.
    */
    function changeMinter(address newMinter) public onlyOwner {
        minter = newMinter;
        emit MinterChanged(minter);
    }

    /**
     * @dev Emitted when the owner is changed
     */
    event OwnerChanged(address indexed owner);

    /**
     * @dev Emitted when the owner is changed
     */
    event MinterChanged(address indexed minter);

}

/**
 * @title IERC20
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     * Returns a boolean value indicating whether the operation succeeded.
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     * Returns a boolean value indicating whether the operation succeeded.
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract ERC20 is Ownable, IERC20 {
    using SafeMath for uint;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;

    uint256 public totalSupply;
    uint256 public circulatingSupply;
    uint8 public decimals;
    string public name;
    string public symbol;

    // additional variables for use if transaction fees ever became necessary
    uint public basisPointsRate = 0;
    uint public maximumFee = 0;


    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        uint fee = (amount.mul(basisPointsRate)).div(100);
        if (fee > maximumFee) {
            fee = maximumFee;
        }
        uint sendAmount = amount.sub(fee);
        if (fee > 0){
            _transfer(msg.sender, owner, fee);
        }
        _transfer(msg.sender, to, sendAmount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address account, address spender) public view virtual override returns (uint256) {
        return allowances[account][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address account = msg.sender;
        _approve(account, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        uint fee = (amount.mul(basisPointsRate)).div(100);
        if (fee > maximumFee) {
            fee = maximumFee;
        }
        uint sendAmount = amount.sub(fee);
        if (fee > 0){
            _transfer(from, owner, fee);
        }
        _transfer(from, to, sendAmount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender).add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(owner, spender, currentAllowance.sub(subtractedValue));
        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");


        uint256 fromBalance = balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        
        balances[from] = fromBalance.sub(amount);
        // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
        // decrementing then incrementing.
        balances[to] = balances[to].add(amount);
        
        emit Transfer(from, to, amount);

    }

    
    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender,  uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            _approve(owner, spender, currentAllowance.sub(amount));
        }
    }

}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    /**
     * @dev Emitted when the contract is paused
     */
    event Pause();
  
    /**
     * @dev Emitted when the contract is resumed
     */
    event Unpause();

    bool public paused = false;


    /**
    * @dev Modifier to make a function callable only when the contract is not paused.
    */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
    * @dev Modifier to make a function callable only when the contract is paused.
    */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
    * @dev called by the owner to pause, triggers stopped state
    */
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }

    /**
    * @dev called by the owner to unpause, returns to normal state
    */
    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
}


/**
 * @title BlackList
 * @dev Base contract which allows to diable an evil user and destroy its funds.
 */
contract BlackList is Ownable, ERC20 {
    using SafeMath for uint;


    mapping (address => bool) private isBlackListed;

    /**
    * @dev called by the owner to pause, triggers stopped state
    */
    function getBlackListStatus(address account) public view returns (bool) {
        return isBlackListed[account];
    }

    
    function addBlackList(address evilUser) public onlyOwner {
        isBlackListed[evilUser] = true;
        emit AddedBlackList(evilUser);
    }

    function removeBlackList(address clearedUser) public onlyOwner {
        isBlackListed[clearedUser] = false;
        emit RemovedBlackList(clearedUser);
    }

    function destroyBlackFunds(address blackListedUser) public onlyOwner {
        require(isBlackListed[blackListedUser]);
        uint dirtyFunds = balanceOf(blackListedUser);
        balances[blackListedUser] = 0;
        circulatingSupply = circulatingSupply.sub(dirtyFunds);
        emit DestroyedBlackFunds(blackListedUser, dirtyFunds);
    }

    /**
     * @dev Emitted when an account is added to blacklist
     */
    event AddedBlackList(address indexed user);

    /**
     * @dev Emitted when an account is removed from blacklist
     */
    event RemovedBlackList(address indexed user);

    /**
     * @dev Emitted when the funds of a blacklisted user is destroyed
     */
    event DestroyedBlackFunds(address indexed blackListedUser, uint dirtyFunds);

}


contract LiaizonToken is Pausable, ERC20, BlackList {
    using SafeMath for uint;

    address public upgradedAddress;
    bool public deprecated;


    /**
     * @dev Sets the values for {totalSupply}, {name}, {symbol} and {decimals}.
     *
     * All of these values are immutable: they can only be set once during
     * construction.
     */
    constructor() {
        totalSupply = 10000000;
        circulatingSupply = 0;
        name = "Liaizon Token";
        symbol = "Liaizon";
        decimals = 18;
        deprecated = false;
    }


    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     * - the caller must not be blacklisted
     */
    function transfer(address to, uint amount) public override whenNotPaused returns (bool){
        require(!getBlackListStatus(msg.sender));
        super.transfer(to, amount);
        return true;
    }


    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     * - `from` must not be blacklisted
     */
    function transferFrom(address from, address to, uint amount) public override whenNotPaused returns (bool){
        require(!getBlackListStatus(from));
        super.transferFrom(from, to, amount);
        return true;
    }

    /**
     * @dev deprecate current contract in favour of a new one
     */
    function deprecate(address _upgradedAddress) public onlyOwner {
        deprecated = true;
        upgradedAddress = _upgradedAddress;
        emit Deprecate(upgradedAddress);
    }

    
    /**
     * @dev Mints `amount` tokens and moves to `account`.
     * Returns a boolean value indicating whether the operation succeeded.
     * Emits a {Minted} event.
     */
    function mint(address account, uint amount) public onlyMinter returns (bool){
        require(amount > 0);
        require(circulatingSupply.add(amount) < totalSupply);
        
        balances[account] = balances[account].add(amount);
        circulatingSupply = circulatingSupply.add(amount);
        emit Minted(account, amount);

        return true;
    }

    /**
     * @dev Burns `amount` tokens from `account` balance.
     * Returns a boolean value indicating whether the operation succeeded.
     * Emits a {Burned} event.
     */
    function burn(address account, uint amount) public onlyMinter returns (bool){
        require(amount > 0);
        require(balances[account] >= amount);

        circulatingSupply = circulatingSupply.sub(amount);
        balances[account] = balances[account].sub(amount);
        emit Burned(account, amount);

        return true;
    }


    /**
     * @dev Set `newBasisPoints` and `newMaxFee`
     * Returns a boolean value indicating whether the operation succeeded.
     * Emits a {FeeParamsChanged} event.
     */
    function setParams(uint newBasisPoints, uint newMaxFee) public onlyOwner returns (bool){
        // Ensure transparency by hardcoding limit beyond which fees can never be added
        require(newBasisPoints <= 20);
        require(newMaxFee <= 100);

        basisPointsRate = newBasisPoints;
        maximumFee = newMaxFee;

        emit FeeParamsChanged(basisPointsRate, maximumFee);

        return true;
    }


    /**
     * @dev Emitted when new tokens are Minted
     */
    event Minted(address indexed account, uint amount);

    /**
     * @dev Emitted when new tokens are Burned
     */
    event Burned(address indexed account, uint amount);

    /**
     * @dev Emitted when the contract is deprecated
     */
    event Deprecate(address newAddress);

    /**
     * @dev Emitted if the contract ever adds fees
     */
    event FeeParamsChanged(uint feeBasisPoints, uint maxFee);

}