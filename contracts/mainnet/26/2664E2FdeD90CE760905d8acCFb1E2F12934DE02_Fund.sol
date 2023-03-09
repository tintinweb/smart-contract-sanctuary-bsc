/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol



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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol



pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol



pragma solidity ^0.8.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

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

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// File: Fund1.sol_flattened.sol


pragma solidity ^0.8.0;


//distribute profit by manager
//user can withdraw after lock time without profit.
//withdraw dont recieve profit, and contract have enough USDT to withdraw
//need token with 18 decimals.
//DAI:0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063
//USDT:0xc2132D05D31c914a87C6611C10748AEb04B58e8F
//deployed 
//polygon 


//execution reverted: UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT",
//maybe your swap amountIn is  too small

interface IUniswapV2Router02 {
    function WETH() external pure returns (address);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
        ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
        ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
    
    // token to ETH 
    /*
    function swapExactTokensForETH( 
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint  amounts);
    */

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
        ) external;

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)    external    returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)   external    returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
}


contract Fund is ERC20, Ownable {
    event Deposit(address, uint);
    event WithdrawEvent(address, uint);


    mapping(address => uint) LockTime;
    bool public locked = false;

  // SushiSwap
  //IUniswapV2Router02 private constant sushiRouter = IUniswapV2Router02(0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506);
  //address public sushiRouterAddress=0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;



  struct UserInfo {
    uint orderID;
    address payable UserAddress;
    uint InvestAmount;

  }
  mapping(uint256 => UserInfo) public Users;
  mapping(address => uint) public Userid;

//polygon
//sushiswap router:0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506 
//quickswap router:0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff
//dai:0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063
//usdt:0xc2132D05D31c914a87C6611C10748AEb04B58e8F
//bnb:0x3BA4c387f786bFEE076A58914F5Bd38d668B42c3
//shiba:0x6f8a06447Ff6FcF75d803135a7de15CE88C1d4ec
//avax:0x2C89bbc92BD86F8075d1DEcc58C7F4E0107f286b
//address[] public AllowTokens=[0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063,0xc2132D05D31c914a87C6611C10748AEb04B58e8F,
//0x3BA4c387f786bFEE076A58914F5Bd38d668B42c3,0x6f8a06447Ff6FcF75d803135a7de15CE88C1d4ec,
//0x2C89bbc92BD86F8075d1DEcc58C7F4E0107f286b];
//address  public WETH=0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;



//binance 
//pancakeswap router:0x10ED43C718714eb63d5aA57B78B54704E256024E
//dai:0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3
//eth:0x2170Ed0880ac9A755fd29B2688956BD959F933F8
//usdc:0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d
//matic:0xCC42724C6683B7E57334c4E856f4c9965ED682bD
//doge:0xbA2aE424d960c26247Dd6c32edC70B295c744C43
//dot:0x7083609fCE4d1d8Dc0C979AAb8c869Ea2C873402
//ltc:0x4338665CBB7B2485A8855A139b75D5e34AB0DB94
//shiba:0x2859e4544C4bB03966803b044A93563Bd2D0DD4D
//avax:0x1CE0c2827e2eF14D5C4f29a091d735A204794041
//babydoge:0xc748673057861a797275CD8A068AbB95A902e8de


address[] public AllowTokens=[0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3,0x2170Ed0880ac9A755fd29B2688956BD959F933F8,
0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d,0xCC42724C6683B7E57334c4E856f4c9965ED682bD,
0xbA2aE424d960c26247Dd6c32edC70B295c744C43,0x7083609fCE4d1d8Dc0C979AAb8c869Ea2C873402,
0x4338665CBB7B2485A8855A139b75D5e34AB0DB94,0x2859e4544C4bB03966803b044A93563Bd2D0DD4D,
0x1CE0c2827e2eF14D5C4f29a091d735A204794041,0xc748673057861a797275CD8A068AbB95A902e8de];

 

mapping(address => bool) public TokenMap; // default value for each key is false

uint public LockTimeDays=180;

uint public UserCount;
uint public MinProfit=100;
uint public FeePercent = 10;
uint public PoolBalance;


ERC20 public USDToken ;

address ContractOwner;

modifier noReentrant() {
    require(!locked, "No re-entrancy");
    locked = true;
    _;
    locked = false;
}



constructor(address _USD) ERC20("Fund", "FUND") {
    USDToken=ERC20(_USD);
  //  _mint(msg.sender, initialSupply);
  ContractOwner=msg.sender;
}

function depositUSDToken (uint256 amount) public noReentrant{
    // Increment the account balance for this address
    
    require(amount > 0, "You need to sell at least some tokens");
    uint256 allowance = USDToken.allowance(msg.sender, address(this));
    require(allowance >= amount, "Check the token allowance");

//user transfer USD to contract
USDToken.transferFrom(msg.sender, address(this), amount);

//contract mint contract token to user.
_mint(msg.sender, amount);       // minting same amount of tokens to for simplicity

bool InvestorExist=false;
for (uint i; i < UserCount; i++) {
    if (Users[i].UserAddress == msg.sender){
        Users[i].InvestAmount += amount;
        InvestorExist=true;
    }
}

if (!InvestorExist){
    Userid[msg.sender]=UserCount;
    Users[UserCount].InvestAmount += amount;
    Users[UserCount].UserAddress =payable (msg.sender) ;
}

LockTime[msg.sender]=block.timestamp + LockTimeDays * 1 days;

PoolBalance += amount;
UserCount++;
    // Trigger an event for this deposit
    //emit DepositEvent(from, tokens);
}



function Withdraw() external noReentrant{
    uint _shares = Users[Userid[msg.sender]].InvestAmount;
    require(USDToken.balanceOf(address(this)) >= _shares, "farm balance is insufficient");
    require(block.timestamp > LockTime[msg.sender], "you can withdraw after your lock time.");        
    require(_shares > 0, "your investment is zero");
    _burn( msg.sender, _shares);
    USDToken.transfer(msg.sender, _shares);
    Users[Userid[msg.sender]].InvestAmount=0;
    require(PoolBalance >= _shares, "PoolBalance >= _shares");

//update pool
PoolBalance -=_shares;
emit WithdrawEvent(msg.sender, _shares);
}



function Refund() external  onlyOwner{
  for (uint i; i < UserCount; i++) { 
      if  (Users[i].InvestAmount > 0){
        USDToken.transfer(Users[i].UserAddress, Users[i].InvestAmount);
        Users[i].InvestAmount=0;
      }
      
  }
}

//only send profit except capital
function DistributeProfit() external  onlyOwner{
    uint TotalProfit=USDToken.balanceOf(address(this)) - PoolBalance;
    require(TotalProfit > MinProfit, "No profit");
    
    for (uint i; i < UserCount; i++) { 
        require(Users[i].InvestAmount > 0,"user have no invest.");
        uint  CapitalAndProfit= Users[i].InvestAmount *  USDToken.balanceOf(address(this)) / totalSupply() ; 
        require(CapitalAndProfit > Users[i].InvestAmount,"Capital And Profit need > user Invest Amount");
        
        uint profit=CapitalAndProfit - Users[i].InvestAmount;
        uint Fee=(FeePercent * profit) / 100 ;
        uint UserProfit=profit - Fee;

        //send profit
        USDToken.transfer(Users[i].UserAddress, UserProfit);
        //Users[i].InvestAmount=0;

        //send fee
        USDToken.transfer(msg.sender, Fee);

    }

    //if (USDToken.balanceOf(address(this)) > 0 ){
   //   USDToken.transfer(msg.sender, USDToken.balanceOf(address(this)));
   // }
//PoolBalance =USDToken.balanceOf(address(this));



}



function TokenToEtherToTokenV2(address _RouterAddress, uint amountIn, 
    uint amountOutMin ,address FromTokenAddress,address ToTokenAddress) public onlyOwner {
    
    require( CheckAllowToken( FromTokenAddress) && CheckAllowToken( ToTokenAddress), "This token is not allow.");

    require(amountIn<=IERC20(FromTokenAddress).balanceOf(address(this)), "Token on contract is not enough");
    
    IERC20(FromTokenAddress).approve(_RouterAddress, type(uint256).max);
    
    uint deadline = block.timestamp + 500; 

    IUniswapV2Router02    Router = IUniswapV2Router02(_RouterAddress);
    

               // swap the ERC20 token for ETH
               uint ethFromSwap = Router.swapExactTokensForETH(
                amountIn,
                amountOutMin,
                _getPath(FromTokenAddress,Router.WETH()),
                address(this),
                deadline
                )[1];

               uint tokenAmount = Router.swapExactETHForTokens{value: ethFromSwap}(
                amountOutMin,
                _getPath(Router.WETH(),ToTokenAddress),
                address(this),
                deadline
                )[1];

 /*

 // make the swap
        Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountIn,
            amountOutMin, // accept any amount of ETH
            _getPath(FromTokenAddress,WETH),
            address(this),
            block.timestamp
        );




    Router.swapExactTokensForTokens(
        amountIn,
        amountOutMin,
        _getPath(FromTokenAddress,ToTokenAddress),
        address(this),
        deadline
        );

        */
    }

    function _getPath(address a,address b) public pure returns (address[] memory) {
        
        address[] memory path = new address[](2);
        path[0] = a;
        path[1] = b;
        
        return path;
    }


    function CheckAllowToken(address _TokenAddress) public view returns (bool) {
        for (uint i = 0; i < AllowTokens.length; i++) {
            if (AllowTokens[i] == _TokenAddress) {
                return true;
            }
        }

        return false;
    }

/*
function AddToken(address _TokenAddress) public onlyOwner {
    AllowTokens.push(_TokenAddress);
    TokenMap[_TokenAddress] = true;
 
}
*/


receive() payable external {}
    //(20 * 600) / 100 = 120  <->  600 * 20%



 /* useless.
function ShowProfit(address _user) public view returns (uint) {
    uint profit =  Users[Userid[_user]].InvestAmount * USDToken.balanceOf(address(this)) / totalSupply() ; 
    uint Fee=(FeePercent * profit) / 100 ;
    uint UserProfit=profit - Fee;
    return  UserProfit;

}
   
function ShowARR() public view returns (uint) { 

    if (USDToken.balanceOf(address(this)) >= PoolBalance){
        return 0;
    }else{
        return ((USDToken.balanceOf(address(this)) -  PoolBalance ) / PoolBalance )*100;
    }
    

}


function Swap(
    address Router, address FromTokenAddress, 
    address ToTokenAddress,uint TradeAmount
    ) external  onlyOwner {

require( CheckAllowToken( FromTokenAddress) && CheckAllowToken( ToTokenAddress), "This token is not allow.");

 require(TradeAmount<=IERC20(FromTokenAddress).balanceOf(address(this)), "Token on contract is not enough");
TokenToETHtoTokenV2(Router,TradeAmount, 1,FromTokenAddress,ToTokenAddress);
}
*/



/*
function TokenToTokenV2(address _RouterAddress, uint256 amountIn, 
    uint256 amountOutMin ,address FromTokenAddress,address ToTokenAddress) public {
 
    IERC20(FromTokenAddress).approve(_RouterAddress, type(uint256).max);
    
    uint256 deadline = block.timestamp + 300; 

    IUniswapV2Router02    Router = IUniswapV2Router02(_RouterAddress);
    
    Router.swapExactTokensForTokens(
        amountIn,
        amountOutMin,
        _getPath(FromTokenAddress,ToTokenAddress),
        address(this),
        deadline
        );
}
*/
}