/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

// File: contracts/contexts.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.2;

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
// File: contracts/IERC20.sol


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

    function burn(uint256 amount) external returns (bool);
}

// File: contracts/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.2;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
// File: contracts/Token-Tools-Create.sol



pragma solidity ^0.8.2;





contract Token is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) public blacklistmap;

    uint256 private _totalSupply;
    uint256 public pause;
    address private _owner;
    string private _name;
    string private _symbol;
    bool public burnable;
    bool public pausable;
    bool public blacklist;
    bool public mintable;
    uint256 public TotalSupply;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Blacklisted(address indexed blacklistedaddress);

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    constructor(string memory name_, string memory symbol_, address mintto,uint256 amount,bool _burnable,bool _pausesable,bool _blacklist,bool _mintable,uint256 _total) {
        _name = name_;
        _symbol = symbol_;
        mintable = _mintable;
        if (mintable){
            TotalSupply = _total;
        }
        else{
            TotalSupply = amount;
        }
        _mint(mintto, amount);
        pause=0;
        _transferOwnership(mintto);
        burnable = _burnable;
        pausable = _pausesable;
        blacklist = _blacklist;
        
    }

    function pauseUnpause() external onlyOwner{
        require(pausable,"The contract cant pause!");
        if (pause==0){
            pause = 1;
        }
        else{
            pause = 0;
        }
 

    }
 
    function mintowner(uint256 _amount) external onlyOwner{
        require(mintable,"The contract cant mintable!");
        _mint(msg.sender, _amount);

        
    }
 

    function blacklistUser(address user) external onlyOwner {
        require(blacklist,"The contract cant use blacklist!");
        bool _blacklisted = blacklistmap[user];

        if (_blacklisted){
            blacklistmap[user] = false;
        }
        else{
            blacklistmap[user] = true;
            emit Blacklisted(user);
        }
    }

   

    
    function name() public view virtual override returns (string memory) {
        return _name;
    }

   
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

   
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

   
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

   
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();

        _transfer(owner, to, amount);

        return true;
    }

     function burn(uint256 amount) public virtual override returns (bool) {
        require(burnable,"The contract is not burnable");
        address owner = _msgSender();

        _burn(owner, amount);

        return true;
    }


   
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

   
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

   
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

   
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!blacklistmap[msg.sender],"User blacklisted!");
        require(pause==0,"Contract paused!");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }



   
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        require(_totalSupply+amount<=TotalSupply,"Max minted!");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

   
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        require(!blacklistmap[msg.sender],"User blacklisted!");
        require(pause==0,"Contract paused!");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

  
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    //pausable contract
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(pause==0, "ERC20Pausable: token transfer while paused");
        require(!blacklistmap[msg.sender],"User blacklisted!");
    }

   
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

     function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

   
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        
        _transferOwnership(newOwner);
    }

  
    function _transferOwnership(address newOwner) internal virtual {
        require(pause==0,"Contract paused!");
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Factory is Context{
   address[] public deployedContracts;
   uint public contractsCount;
   Token public token;
   address private _owner;
   uint256 public balance;
   address public receiver;
   uint256 public baseamount;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        _checkOwner();
        _;
    }


    constructor(uint256 _baseamount){
        _transferOwnership(_msgSender());
        receiver = msg.sender;
        baseamount = _baseamount;
    }

      function setreceiver(address to) external onlyOwner {
        receiver = to;

    }

       function setbaseamount(uint256 _baseamount) external onlyOwner {
        baseamount = _baseamount;

    }

    function createContract(string memory name_, string memory symbol_, address mintto,uint256 amount,bool _burnable,bool _pausesable,bool _blacklist,bool _mintable,uint256 _total) payable public returns(address){
        uint256 countbool = 1;
        if (_burnable){
            countbool = countbool+1;
        }
        if (_pausesable){
            countbool = countbool+1;
        }
        if (_blacklist){
            countbool = countbool+1;
        }
        if (_mintable){
            countbool = countbool+1;
        }
        require(msg.value>=baseamount*countbool,"Amount is too low");
        balance = address(this).balance;
        token = new Token(name_, symbol_, mintto,amount,_burnable,_pausesable, _blacklist, _mintable, _total);
        deployedContracts.push(address(token));
        contractsCount++;
        return address(token);

    }
      function withdrawBNB() external onlyOwner {

      balance = address(this).balance;

      (bool success1, ) = payable(msg.sender).call{ value: balance }("");
      require(success1, "BNB withdraw failed");
      
      
  }
    function getDeployedContract(uint index) public view returns(address ){
        return deployedContracts[index];
    }
    
     function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

   
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        
        _transferOwnership(newOwner);
    }

  
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

  }