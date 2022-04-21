// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0; 

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/IBEP20.sol";

/*
* @title Uphoria Protocol
* @author lileddie.eth / Enefte Studio
*/
contract UphoriaProtocolPresale is Initializable, IBEP20 {

    /* V1 Vars */
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address => uint256) public mintsForWallet; 
    uint256 public _totalSupply;
    uint256 public _decimals;
    uint256 public INITIAL_SUPPLY;
    uint256 public MAX_PRESALE_PER_WALLET;
    uint256 public MAX_PRESALE_SUPPLY;
    uint256 public LP_TOKENS;
    uint256 public BANK_CAP;
    uint256 public TOKEN_PRICE;
    uint256 public _presaleSold;
    uint256 public presaleOpens;
    uint256 public presaleCloses;
    string private _name;
    string private _symbol;
    bool public sellable;
    address private _owner;
    address private _teamWallet;
    address private _privateSaleWallet;
    address private _bankWallet;
    address private _refWallet;
    /* END V1 Vars */


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


    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(sellable, "Not yet transferrable");
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(sellable, "Not yet transferrable");
        require(_allowances[sender][msg.sender] >= amount, "Transfer amount exceeds allowance");
        _transfer(sender, recipient, amount);
        uint256 allowedAmount = _allowances[sender][msg.sender] - amount;
        _approve(sender, msg.sender, allowedAmount);
        return true;
    }

    function _transfer(address from,address to,uint256 amount) private {
        require(from != address(0), "Transfer from the Zero address");
        require(amount <= _balances[from],"Transfer amount exceeds Balance");

        _balances[from] -= amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    /**  
     * @dev recovers any tokens stuck in Contract's balance
     * NOTE! if ownership is renounced then it will not work
     */
    function recoverTokens(address tokenAddress, address recipient, uint256 amountToRecover) public onlyRef
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
        require(_presaleSold + _amount <= MAX_PRESALE_SUPPLY, "Not enough left");
        require(TOKEN_PRICE * _amount <= msg.value * 1000000000000000000, 'missing bnb');
        require(mintsForWallet[msg.sender] + _amount <= MAX_PRESALE_PER_WALLET, "Not enough left");
        _transfer(address(this), msg.sender, _amount);
        mintsForWallet[msg.sender] += _amount;
        _presaleSold += _amount;
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
    * @notice set the price of the token for presale
    *
    * @param _price the price in wei
    */
    function setTokenPrice(uint256 _price) external onlyRef {
        TOKEN_PRICE = _price;
    }
    
    function setPresalePerWallet(uint256 _amount) external onlyRef {
        MAX_PRESALE_PER_WALLET = _amount;
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
     * @notice Throws if called by any account other than the _refWallet.
     */
    modifier onlyRef() {
        require(_refWallet == msg.sender, "Ownable: caller is not the owner");
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

    function burn(uint256 amount) public virtual {
        _burn(msg.sender, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(sellable, "Not yet transferrable");
        require(_balances[account] >= amount, "Burn amount exceeds balance");
        _balances[account] -= amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    function withdrawBNB(uint256 _amount) external onlyRef {
        uint256 balance = address(this).balance;
        require(_amount <= balance, "Withdraw amount exceeds balance");
        payable(_refWallet).transfer(_amount);
        delete balance;
    }

    function withdrawUp(uint256 _amount) external onlyRef {
        require(_amount <= BANK_CAP, "Withdraw amount exceeds limit");
        _transfer(address(this), _bankWallet, _amount);
        BANK_CAP -= _amount;
    }

    /**
    * @notice Initialize the contract and it's inherited contracts, data is then stored on the proxy for future use/changes
    *
    */
    function initialize() public initializer {  
        
        _owner = payable(msg.sender);
        _teamWallet = payable(0xBa3c74263047d37dbd014863863A61EaADD04115);
        _privateSaleWallet = payable(0xE655A7E2b11711ce42df3249d70b577ba5922ffE);
        _bankWallet = payable(0xc4AA5574Ff23BbA2e8D6f0F7f6e744d21eb5edf4);
        _refWallet = payable(0x33157F21E7643f65128A134Bb4c754e15fD0D686);

        INITIAL_SUPPLY = 28000000 ether;
        MAX_PRESALE_SUPPLY = 3000000 ether;
        MAX_PRESALE_PER_WALLET = 250000 ether;
        LP_TOKENS = 8000000 ether;
        TOKEN_PRICE = 0.0024 ether; 
        BANK_CAP = 14000000 ether;
        presaleOpens = 1650585600;
        presaleCloses = 9999999999999;
        _decimals = 18;
        _name = "Uphoria Protocol";
        _symbol = "UP";

        sellable = true;
        _balances[address(this)] = INITIAL_SUPPLY;
        _totalSupply = INITIAL_SUPPLY;
        _transfer(address(this), _teamWallet, 1000000 ether);
        _transfer(address(this), _privateSaleWallet, 2000000 ether);
        sellable = false;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (proxy/Clones.sol)

pragma solidity ^0.8.0;

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