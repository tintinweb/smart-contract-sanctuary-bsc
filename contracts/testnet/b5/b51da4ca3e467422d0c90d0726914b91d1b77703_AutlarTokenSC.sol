/**
 *Submitted for verification at BscScan.com on 2022-11-22
*/

//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.12;
interface IBEP20 {
    /* Get Total Supply */
    function totalSupply() external view returns (uint256);
    /* Get Decimal Places */
    function decimals() external view returns (uint8);
    /* Get Token Symbol OR Short Name */
    function symbol() external view returns (string memory);
    /* Get Token Name */
    function name() external view returns (string memory);
    /* Get Owner Wallet Address */
    function getOwner() external view returns (address);
    /* Get Balance of GST Token of any Wallet Address */
    function balanceOf(address account) external view returns (uint256);
    /* Transfer GST Token on Any Address */
    function transfer(address recipient, uint256 amount) external returns (bool);
    /* Check Allowance of An User of Spender Platform */
    function allowance(address _owner, address spender) external view returns (uint256);
    /* Approve The Amount for Allowance on Spender Platform */
    function approve(address spender, uint256 amount) external returns (bool);
    /* Transfer From Is Basically Used For Transfer on Spender Address After approve the Amount for Spend */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    /* Transfer Event */
    event Transfer(address indexed from, address indexed to, uint256 value);
    /* Approval Event */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
/* Abstract Contract */
//pragma solidity ^0.6.0;
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/bnbereum/solidity/issues/2691
        return msg.data;
    }
}
/* Library For Airthmatic Operation */
// pragma solidity ^0.6.12;
library SafeMath {
    /* Addition of Two Number */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    /* Subscription of Two Number */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    /* Multiplication of Two Number */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    /* Divison of Two Number */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    /* Modulus of Two Number */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
pragma solidity >=0.4.24 <0.7.0;


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
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");
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

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}

pragma solidity ^0.6.0;

contract AutlarTokenSC is Context, IBEP20, Initializable {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isIncludedForFee;

    uint256 private _totalSupply;
    uint256 private _maximumSupply;
    uint public _maxTransactionLimits=10000000000000000;
    uint public _minTransactionLimits=10;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalBurnet;
    uint256 private _totalMinted;

    bool public isSellTaxApplicable = false;
    uint public _sellburnPer=1;
    uint public _sellliquidityPer=2;
    uint public _sellMarketingPer=3;

    bool public isBuyTaxApplicable = false;
    uint public _buyburnPer=1;
    uint public _buyliquidityPer=2;
    uint public _buyMarketingfPer=3;

    mapping (address => bool) public checkUserBlocked;
     mapping (address => bool) private _isExcludedFromFee;
    bool private paused = false;
    bool private canPause = true;

    address private _owner;
    bool private _mintable;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Pause();
    event Unpause();
    event UpdateBurnPer();
    event UpdateLiquidityPer();
    event UpdateMarketingPer();
    event BlockWalletAddress();
    event UnblockWalletAddress();
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    /**
     * @dev sets initials supply and the owner
     */
    function initialize(string memory name, string memory symbol, uint8 decimals,uint256 maximumSupply, uint256 amount, bool mintable, address owner) public initializer {
        _owner = owner;
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _mintable = mintable;
        _maximumSupply=maximumSupply;
        _mint(owner, amount);
    }
    
   function pause() onlyOwner public {
        require(canPause == true);
        paused = true;
        emit Pause();
   } 
   
   /**
   * @dev called by the owner to unpause, returns to normal state
   */
    
    function unpause() onlyOwner public {
        require(paused == true);
        paused = false;
        emit Unpause();
    }    

    function excludeFromFee(address account) public onlyOwner {
        _isIncludedForFee[account] = false;
    }
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
  

    /**
    * @dev called by the owner to enable and disable Sell Tax
    */

    function _isSellTax(bool status) public onlyOwner {
        isSellTaxApplicable=status;
    }

    /**
    * @dev called by the owner to enable and disable Buy Tax
    */

    function _isBuyTax(bool status) public onlyOwner {
        isBuyTaxApplicable=status;
    }

    /**
    * @dev called by the owner to include address for fee
    */

    function includeInFee(address account) public onlyOwner {
        _isIncludedForFee[account] = true;
    }

    /**
    * @dev called for check account is included for fee or not
    */

    function isIncludedForFee(address account) public view returns(bool) {
        return _isIncludedForFee[account];
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");

        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    /**
     * @dev Returns if the token is mintable or not
     */
    function mintable() external view returns (bool) {
        return _mintable;
    }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external override view returns (address) {
        return _owner;
    }

    /**
     * @dev Returns the bep token minted.
     */
    function getMintedQty() external view returns (uint256) {
        return _totalMinted;
    }

    /**
     * @dev Returns the bep token burnet.
     */
    function getBurnetQty() external view returns (uint256) {
        return _totalBurnet;
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external override view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external override view returns (string memory) {
        return _symbol;
    }

    /**
    * @dev Returns the token name.
    */
    function name() external override view returns (string memory) {
        return _name;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() external override view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) external override view returns (uint256) {
        return _balances[account];
    }

  
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
      function _verifyMaxTransactionLimits(uint256 maxTransactionLimits) public onlyOwner {
        _maxTransactionLimits=maxTransactionLimits;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender) external override view returns (uint256) {
        return _allowances[owner][spender];
    }

   
    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

   
    function mint(uint256 amount) public onlyOwner returns (bool) {
        require(_mintable, "This token is not mintable");

        _mint(_msgSender(), amount);
        return true;
    }

    /**
   * @dev Burn `amount` tokens and decreasing the total supply.
   */
    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }
   function _transfer(address sender, address recipient, uint256 amount) internal {

      require(sender != address(0), "BEP20: transfer from the zero address.");
      require(recipient != address(0), "BEP20: transfer to the zero address.");
      require(paused != true, "BEP20: Token Is Paused now.");
      require(amount<=_maxTransactionLimits,"Maximum Transaction Limit Exceed.");

      //indicates if fee should be deducted from transfer
     bool sellFeeStatus = false;
      bool buyFeeStatus = false;   
        
      //if any account belongs to _isIncludedForFee account then take the fee start Fee Here

      //If User Coin Buy Then Sender Will Be Router Address of Any Defi Exchange
      if(_isIncludedForFee[sender] && isBuyTaxApplicable==true){
        buyFeeStatus = true;
      }

      //If User Coin Sell Then Receiver Will Be Router Address of Any Defi Exchange
      else if(_isIncludedForFee[recipient] && isSellTaxApplicable==true){
      sellFeeStatus = true;
        require(amount <= _maxTransactionLimits, "Transfer amount exceeds the maxTxAmount.");
      }

      //if any account belongs to _isIncludedForFee account then take the fee end Fee Here

      uint256 netamount=amount;

      if(sellFeeStatus == true) {

      _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");

      _balances[recipient] = _balances[recipient].add(netamount);

    }
    else {

      _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
      _balances[recipient] = _balances[recipient].add(amount);  
    }
    emit Transfer(sender, recipient, amount);
    }


    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");
        require(paused != true, "BEP20: Token Is Paused now");
        require(_maximumSupply >= _totalSupply.add(amount),"Mint Can Not Exceed Maximum Supply");

        _totalSupply = _totalSupply.add(amount);
        _totalMinted = _totalMinted.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
      function block_WalletAddress(address WalletAddress) onlyOwner public {
        checkUserBlocked[WalletAddress] = true;
        emit BlockWalletAddress();
    }
     function unblock_WalletAddress(address WalletAddress) onlyOwner public {
        checkUserBlocked[WalletAddress] = false;
        emit UnblockWalletAddress();
    }
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");
        require(paused != true, "BEP20: Token Is Paused now");
        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        
        _totalSupply = _totalSupply.sub(amount);
        _totalBurnet = _totalBurnet.add(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        require(paused != true, "BEP20: Token Is Paused now");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

  
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
        }
}