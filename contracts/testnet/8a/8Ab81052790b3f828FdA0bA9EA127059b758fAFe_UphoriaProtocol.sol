// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0; 

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

interface IBEP20 {

    /**  
     * @dev Returns the total tokens supply  
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

/*
* @title Uphoria Protocol
* @author lileddie.eth / Enefte Studio
*/
contract UphoriaProtocol is Initializable, IBEP20 {

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 public _totalSupply;
    uint256 public MAX_PRESALE_SUPPLY;
    uint256 public _decimals;
    uint256 public TOKEN_PRICE;
    uint256 public presaleOpens;
    uint256 public presaleCloses;
    
    string private _name;
    string private _symbol;
    
    address private _owner;
    address private _teamWallet;
    address private _marketingWallet;

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender]+=(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        require(_allowances[msg.sender][spender] >= subtractedValue, "decreased allowance below zero");
        _approve(msg.sender, spender, _allowances[msg.sender][spender]-=subtractedValue);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "Cannot approve from the 0 address");
        require(spender != address(0), "Cannot approve to the 0 address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }  

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        return false;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        return false;
    }

    /**  
     * @dev recovers any tokens stuck in Contract's balance
     * NOTE! if ownership is renounced then it will not work
     */
    function recoverTokens(address tokenAddress, address recipient, uint256 amountToRecover, uint256 recoverFeePercentage) public onlyOwner
    {
        IBEP20 token = IBEP20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance >= amountToRecover, "Not Enough Tokens in contract to recover");
        token.transfer(recipient, amountToRecover);
    }

    /**
    * @notice minting process for the presale
    *
    * @param _amount number of tokens to be minted
    */
    function mint(uint256 _amount) external payable  {
        require(block.timestamp >= presaleOpens && block.timestamp <= presaleCloses, "Purchase: window closed");
        require(_totalSupply + _amount <= MAX_PRESALE_SUPPLY, "Not enough left");
        require(TOKEN_PRICE * _amount <= msg.value, 'missing value');
        _balances[msg.sender] += _amount;
        _totalSupply += _amount;
        emit Transfer(address(0), msg.sender, _amount);
    }

    function _burn(uint256 amount) internal virtual {
        uint256 accountBalance = _balances[msg.sender];

        require(accountBalance >= amount, "Burn amount exceeds balance");

        _balances[msg.sender] -= amount;
        _totalSupply -= amount;

        emit Transfer(msg.sender, address(0), amount);
    }

    /**
    * @notice set the timestamp of when the presale should begin
    *
    * @param _openTime the unix timestamp the presale opens
    * @param _closeTime the unix timestamp the presale closes
    */
    function setPresaleTimes(uint256 _openTime, uint256 _closeTime) external onlyOwner {
        presaleOpens = _openTime;
        presaleCloses = _closeTime;
    }
    
    /**
    * @notice set the price of the NFT for main sale
    *
    * @param _price the price in wei
    */
    function setTokenPrice(uint256 _price) external onlyOwner {
        TOKEN_PRICE = _price;
    }
    
    /**
    * @notice set the amount available in presale
    *
    * @param _amount to allocate to presale
    */
    function setPresaleAmount(uint256 _amount) external onlyOwner {
        MAX_PRESALE_SUPPLY = _amount;
    }
    
    /**
    * @notice return the total number of tokens that exist.
    */
    function totalSupply() public view virtual returns(uint256){
        return _totalSupply;
    }

    /**
     * @notice Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @notice Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _owner = newOwner;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    /**
    * @notice Initialize the contract and it's inherited contracts, data is then stored on the proxy for future use/changes
    *
    */
    function initialize() public initializer {  
        
        _owner = payable(msg.sender);
        _teamWallet = payable(msg.sender);
        _marketingWallet = payable(msg.sender);

        MAX_PRESALE_SUPPLY = 5250000000000000000000000;
        TOKEN_PRICE = 1800000000000000; 
        presaleOpens = 0;
        presaleCloses = 9999999999999;
        _decimals = 18;
        _name = "Uphoria Protocol";
        _symbol = "UP";

         _balances[_teamWallet] += 7000000000000000000000000; // 7m to burn
         _balances[_teamWallet] += 1470000000000000000000000; // 7% team
         _balances[_marketingWallet] += 1470000000000000000000000; // marketing 7%
         _balances[_marketingWallet] += 1470000000000000000000000; // private sales 7%
         _totalSupply = 11410000000000000000000000;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}