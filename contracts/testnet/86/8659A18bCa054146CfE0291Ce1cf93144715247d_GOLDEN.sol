/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-23
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-22
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
   
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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

interface IERC20 {
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

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }


    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}

 

contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;

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
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
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

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
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

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
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

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
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
     * will be to transferred to `to`.
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
}

 
 

contract GOLDEN is ERC20, Ownable {
    using SafeMath for uint256;
    
    bool public  swapFeeEnabled   = true; //not fee
   
    uint256 public sellRewardsLpFee = 3;     //3
    uint256 public sellRewardsDevelopFee = 2;//2
    uint256 public sellMarketingFee = 3 ;    //3
    uint256 public sellDeadFee = 2 ;         //2

    uint256 public CakeAmountRewardsLPFee;      // 
    uint256 public CakeAmountRewardsDevelopFee; // 
    uint256 public CakeAmountMarketingFee;      // 
    uint256 public CakeAmountDeadFee;           // 
 
    address public _deadWallet                  = 0x000000000000000000000000000000000000dEaD;  //
    address public _rewardsLpWalletAddress      = 0xc78D997a710264Adf81bE7EbCdb193f05B7160B2;  //
    address public _rewardsDevelopWalletAddress = 0x65B144C728cFF5630f8De4E88898F92ABb99188B;  //
    address public _marketingWalletAddress      = 0x44d1ebF8D40161A4dAAF132776ebF363dF7034cB;  //
 
   
    address public _uniswapV2Pair;
   
    mapping(address => bool)  private _isExcludedFromFees; 
    mapping(address => bool)  public  _automatedMarketMakerPairs;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    string  private name_   = "GOLDEN WORLD" ;
    string  private symbol_ = "GOLD" ;
    uint256 private totalSupply_ = 21000000;


    receive() external payable {}

    constructor() payable ERC20(name_, symbol_)  {
        uint256 totalSupply = totalSupply_ * (10**18);
        setExcludeFromFees(owner(), true);
        setExcludeFromFees(_rewardsLpWalletAddress, true);
        setExcludeFromFees(_rewardsDevelopWalletAddress, true);
        setExcludeFromFees(_marketingWalletAddress, true);
        setExcludeFromFees(address(this), true);
        _mint(owner(), totalSupply);
    }

    //enabled 
    function setSwapFeeEnabled(bool _enabled) public onlyOwner {
        swapFeeEnabled = _enabled;
    }
    
    //fee
    function setSellRewardsLpFee(uint256 amount) public onlyOwner {
        sellRewardsLpFee = amount;
    }
    function setSellRewardsDevelopFee(uint256 amount) public onlyOwner {
        sellRewardsDevelopFee = amount;
    }
    function setSellMarketingFee(uint256 amount) public onlyOwner {
        sellMarketingFee = amount;
    }
    function setSellDeadFee(uint256 amount) public onlyOwner {
        sellDeadFee = amount;
    }
    
     //address 
    function setDeadWallet(address addr) public onlyOwner {
        _deadWallet = addr;
    }
    function setRewardsLpWallet(address payable wallet) external onlyOwner{
        _rewardsLpWalletAddress = wallet;
    }
    function setRewardsDevelopWallet(address payable wallet) external onlyOwner{
        _rewardsDevelopWalletAddress = wallet;
    }
    function setMarketingWallet(address payable wallet) external onlyOwner{
        _marketingWalletAddress = wallet;
    }
     
     
    //mapping set 
    function setExcludeFromFees(address account, bool value) public onlyOwner {
        require(_isExcludedFromFees[account] != value, "ExcludedFromFees is already set to that value");
         _isExcludedFromFees[account] = value;
         emit ExcludeFromFees(account, value);
    }
    function setExcludeMultipleFromFees(address[] calldata accounts, bool value) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = value;
        }
        emit ExcludeMultipleAccountsFromFees(accounts, value);
    }
    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
       require(_automatedMarketMakerPairs[pair] != value, "Automated market maker pair is already set to that value");
        _automatedMarketMakerPairs[pair] = value;
    }     
    
    //mapping get
    function getExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }
 
    function getAutomatedMarketMakerPair(address account) public view returns(bool) {
        return _automatedMarketMakerPairs[account];
    }
   
    function withdrawOf(address tokenAddress , address toAddress , uint256 amount ) public onlyOwner returns(bool) {
        uint256 initialBalance = IERC20(tokenAddress).balanceOf(address(this));
        if(initialBalance >= amount){
            IERC20(tokenAddress).transfer(toAddress, amount);
            return true;
        }
        return false;
    }
    
    //override
    function _transfer( address from, address to, uint256 amount ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
 
        bool takeFee = true;
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to] || !swapFeeEnabled) {
            takeFee = false;
        }

        if(takeFee) {
            uint256 fees;
            uint256 LPFee;      //  3%
            uint256 DevelopFee; //  2%
            uint256 MarketFee;  //  3%
            uint256 DeadFee;    //  2%
             
            if(_automatedMarketMakerPairs[to]){
                LPFee = amount.mul(sellRewardsLpFee).div(100);
                    CakeAmountRewardsLPFee += LPFee;
                DevelopFee = amount.mul(sellRewardsDevelopFee).div(100);
                    CakeAmountRewardsDevelopFee += DevelopFee;
                MarketFee  = amount.mul(sellMarketingFee).div(100);
                    CakeAmountMarketingFee += MarketFee;
                DeadFee = amount.mul(sellDeadFee).div(100);
                    CakeAmountDeadFee += DeadFee;

                fees = LPFee.add(DevelopFee).add(MarketFee).add(DeadFee);
                if(LPFee>0){
                    super._transfer(from, _rewardsLpWalletAddress, LPFee);
                }
                if(DevelopFee>0){
                    super._transfer(from, _rewardsDevelopWalletAddress, DevelopFee);
                }
                if(MarketFee>0){
                    super._transfer(from, _marketingWalletAddress, MarketFee);
                }
                if(DeadFee>0){
                    super._transfer(from, _deadWallet, DeadFee);
                }
            }
            amount = amount.sub(fees);
        }
        super._transfer(from, to, amount); 
    }
}