/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-01
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
    address private _previousOwner;
    uint256 private _lockTime;

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

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }
    
    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
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

  
contract EMC is ERC20, Ownable {
    using SafeMath for uint256;

    address public  uniswapV2Pair;

    bool public  swapFeeEnabled  = true; //关闭滑点 
    
    uint256 public buyTotalFee = 6; // 6% 
    uint256 public buyTokenRewardsFee = 4; // 4% 
    uint256 public buyMarketingFee = 1;    //1%
    uint256 public buyDeadFee = 1;  //1%
    
    uint256 public sendTotalFee = 6; // 6% 
    uint256 public sendTokenRewardsFee = 4;  // 4% 
    uint256 public sendMarketingFee = 1;  //1%
    uint256 public sendDeadFee = 1; //1%
    
    uint256 public sellTotalFee = 10; // 10% 
    uint256 public sellTokenRewardsFee = 4; // 4%
    uint256 public sellMarketingFee = 2;  //2%
    uint256 public sellDeadFee = 4; //4%
    
    uint256 public CakeAmountTokenRewardsFee; //累计奖励数量
    uint256 public CakeAmountMarketingFee;    //累计社区基金
    uint256 public CakeAmountDeadFee;    //累计社区基金

    mapping(address => bool) public _buyManager; 
    
    mapping(address => bool) public _isBlacklisted; 

     // exlcude from fees and max transaction amount
    mapping (address => bool) private _isExcludedFromFees; //手续费排除

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs; //交易对合约地址 

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    
    uint256 private totalSupply_ = 210000 ;
    
    string private name_ = "EmCash" ;
    string private symbol_ = "EmCash" ;
 
    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    address public _rewardsWalletAddress = 0xF84A0e100be6007E586b07EaA8858c8B0B646032;    //奖励地址
    address public _marketingWalletAddress = 0x9840b2171D22199DA4a113c020Bf8b3fdCB381b1;  //基金地址
    
    constructor() payable ERC20(name_, symbol_)  {
        uint256 totalSupply = totalSupply_ * (10**18);

        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(_rewardsWalletAddress, true);
        excludeFromFees(_marketingWalletAddress, true);
        excludeFromFees(address(this), true);

        //mint
        _mint(owner(), totalSupply);
    }

    receive() external payable {}
    
    
    function blacklistAddress(address account, bool value) external onlyOwner{
        _isBlacklisted[account] = value;
    }
    
    function setBuyManager(address account, bool value) external onlyOwner{
        _buyManager[account] = value;
    }
    
    function setSwapFeeEnabled(bool _enabled) public onlyOwner {
        swapFeeEnabled = _enabled;
    }
    
    function setUniswapPair(address pair) public onlyOwner {
        uniswapV2Pair = pair;
        automatedMarketMakerPairs[pair] = true;
    }
    
     

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        if(_isExcludedFromFees[account] != excluded){
            _isExcludedFromFees[account] = excluded;
            emit ExcludeFromFees(account, excluded);
        }
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }
    
    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }



    function updateRewardWallet(address payable wallet) external onlyOwner{
        _rewardsWalletAddress = wallet;
    }
    
    function updateMarketingWallet(address payable wallet) external onlyOwner{
        _marketingWalletAddress = wallet;
    }
    
    function updateDeadWallet(address addr) public onlyOwner {
        deadWallet = addr;
    }
    
    

    function setBuyTotalFee(uint256 amount) public onlyOwner {
        buyTotalFee = amount;
    }
    function setBuyTokenRewardsFee(uint256 amount) public onlyOwner {
        buyTokenRewardsFee = amount;
    }
    function setBuyMarketingFee(uint256 amount) public onlyOwner {
        buyMarketingFee = amount;
    }
    function setBuyDeadFee(uint256 amount) public onlyOwner {
        buyDeadFee = amount;
    }
    
    
    
    function setSendTotalFee(uint256 amount) public onlyOwner {
        sendTotalFee = amount;
    }
    function setSendTokenRewardsFee(uint256 amount) public onlyOwner {
        sendTokenRewardsFee = amount;
    }
    function setSendMarketingFee(uint256 amount) public onlyOwner {
        sendMarketingFee = amount;
    }
    function setSendDeadFee(uint256 amount) public onlyOwner {
        sendDeadFee = amount;
    }



    function setSellTotalFee(uint256 amount) public onlyOwner {
        sellTotalFee = amount;
    }
    function setSellTokenRewardsFee(uint256 amount) public onlyOwner {
        sellTokenRewardsFee = amount;
    }
    function setSellMarketingFee(uint256 amount) public onlyOwner {
        sellMarketingFee = amount;
    }
    function setSellDeadFee(uint256 amount) public onlyOwner {
        sellDeadFee = amount;
    }
    
    
    function historyCakeAmountTokenRewardsFee() public view virtual  returns (uint256) {
        return CakeAmountTokenRewardsFee;
    }
    
    
    function historyCakeAmountMarketingFee() public view virtual returns (uint256) {
        return CakeAmountMarketingFee;
    }
    
    
    function historyCakeAmountDeadFee() public view virtual returns (uint256) {
        return CakeAmountDeadFee;
    }
 
 
    //transfer 
    function _transfer( address from, address to, uint256 amount ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!_isBlacklisted[from] && !_isBlacklisted[to], 'Blacklisted address');

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        bool takeFee = true ;//true

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to] || !swapFeeEnabled) {
            takeFee = false;
        }

        if(takeFee) {
            uint256 fees; //total
            uint256 RFee; //dapp reward 
            uint256 MFee; //marketing 
            uint256 DFee; //dead 
            //buy
            if(automatedMarketMakerPairs[from]){
                RFee = amount.mul(buyTokenRewardsFee).div(100);
                CakeAmountTokenRewardsFee += RFee;
                MFee = amount.mul(buyMarketingFee).div(100);
                CakeAmountMarketingFee += MFee;
                DFee = amount.mul(buyDeadFee).div(100);
                CakeAmountDeadFee +=DFee;
                fees = RFee.add(MFee).add(DFee);
            } else if(automatedMarketMakerPairs[to]){
                RFee = amount.mul(sellTokenRewardsFee).div(100);
                CakeAmountTokenRewardsFee += RFee;
                MFee = amount.mul(sellMarketingFee).div(100);
                CakeAmountMarketingFee += MFee;
                DFee = amount.mul(sellDeadFee).div(100);
                CakeAmountDeadFee +=DFee;
                fees = RFee.add(MFee).add(DFee);
            } else{
                RFee = amount.mul(sendTokenRewardsFee).div(100);
                CakeAmountTokenRewardsFee += RFee;
                MFee = amount.mul(sendMarketingFee).div(100);
                CakeAmountMarketingFee += MFee;
                DFee = amount.mul(sendDeadFee).div(100);
                CakeAmountDeadFee +=DFee;
                fees = RFee.add(MFee).add(DFee);
            }
            
            amount = amount.sub(fees);
            if(DFee > 0){
                super._transfer(from, deadWallet, DFee);
            }
            if(RFee > 0) {
                super._transfer(from, _rewardsWalletAddress, RFee);
            }
            if(MFee > 0) {
                super._transfer(from, _marketingWalletAddress, MFee);
            }
        }
        super._transfer(from, to, amount);
    }
 
   
   
   
    function withdrawOf(address tokenAddress , address toAddress , uint256 amount ) public returns(bool) {
        uint256 initialBalance = IERC20(tokenAddress).balanceOf(address(this));
        if(initialBalance >= amount){
            IERC20(tokenAddress).transfer(toAddress, amount);
            return true;
        }
        return false;
    }
  
    
    
}