/**
 *Submitted for verification at BscScan.com on 2022-07-17
*/

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
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

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


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

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
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
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
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

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
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
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

// File: 合约.sol

pragma solidity ^0.8.15;






contract Token is ERC20, Ownable {

    address public pair;
    //lp合约地址
    IERC20 _LP = IERC20(0xCDB82DeA49BD62c1ef4822599a2B8356a08B7276);
    IERC20 _USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
    //nft合约地址
    address _nftAddress = 0x088efD5f72Afb675Ad85996b9C8f2bf4240b25d5;
    address public holdAddr = 0x0000000000000000000000000000000000000001;
    mapping(address => uint256) private _balances;
    //交易开关
    bool public swapEnable = true;
    //代币分红奖池
    uint256 public tokenBouns;
    //lp分红奖池
    uint256 public lpBouns;
    //lp总额度
    uint256 public lpTotalAmount;
    //lp分红领取状态
    mapping(address => bool) private _lpStatusMapping;
    //代币分红最后领取时间
    mapping(address => uint256) private _tokenReceiveLastTime;
    //领取时间间隔
    uint256 times = 3 days;
    //当前代币分红状态
    bool public _thisTokenStatus = false;
    //地址组
    address[] profitList;
    //lp质押映射
    mapping(address => PledgeOrder) public _orders;
    //ido开启时间
    uint256 public startTime;
    //ido开关
    bool public idoEnable = false;
    //推荐关系
    mapping(address => address) public commond;
    //推荐人ido数量
    mapping(address => uint256) public commondIdo;
    //已经mint数量
    mapping(address => uint256) public useMint;
    //白名单
    mapping(address => bool) private allowList;

    //是否存在质押记录 质押总额 
    struct PledgeOrder {
        bool isExist;
        uint256 totalAmount;
    }

    constructor() ERC20("Meteorite", "MTE") {
        _mint(msg.sender, 100000000 * 10 ** 18);
        allowList[msg.sender] = true;
    }

    function ido(uint256 _uAmount) external {
        require(idoEnable, "ido no open");
        require(_uAmount>= 100 * 10 ** 18 && _uAmount <= 500 * 10 ** 18, "amount error");
        _USDT.transferFrom(msg.sender, address(this), _uAmount);
        if(block.timestamp - startTime > 30 days){
            idoEnable = false;
            super._transfer(address(this), holdAddr, 80000000 * 10 ** decimals() - tokenBouns - lpBouns);
            return;
        }
        uint256 tokenAmount = _uAmount * 10;
        super._transfer(address(this), msg.sender, tokenAmount);
        commondIdo[commond[msg.sender]] ++;
    }
    
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        add_next_add(recipient);
        if(allowList[sender] || allowList[recipient]){
            super._transfer(sender, recipient, amount);
            return;
        }
        if(pair != address(0)){
            if(!allowList[sender] && !allowList[recipient]){
                require(swapEnable, "swap off");
            }
            if(sender == pair){
                uint x = amount * 7 / 100;
                super._transfer(sender, address(this), x);
                super._transfer(sender, recipient, amount - x);
                tokenBouns += amount / 100;
                lpBouns += amount * 6 / 100;
            }else if(recipient == pair){
                uint x = amount / 100;
                super._transfer(sender, address(this), x);
                Intergenerational_rewards(sender, x * 8);
                tokenBouns += amount / 100;
                super._transfer(sender, _nftAddress, x * 3);
                super._transfer(sender, recipient, x * 88);
            }else{
                super._transfer(sender, recipient, amount);
            }
        }else{
            super._transfer(sender, recipient, amount);
        }
    }


    function setPair(address _pair) public onlyOwner {
        pair = _pair;
    }

    mapping(address=>address)public pre_add;

    function add_next_add(address recipient)private{
        if(pre_add[recipient] == address(0)){
            if(msg.sender == pair)return;
            pre_add[recipient]=msg.sender;
        }
    }

    function Intergenerational_rewards(address sender,uint amount)private{
        address pre = pre_add[sender];
        uint total = amount;
        uint a;
        if(pre!=address(0)){
            a = amount/4;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            a = amount/8;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            a = amount/16;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            a = amount/16;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            a = amount/16;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            a = amount/16;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            a = amount/8;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            a = amount/4;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(total!=0){
            _balances[address(this)] += total;
            emit Transfer(sender, address(this), total);
        }
    }

    //lp质押
    function pledgeLp(uint256 _amount) public {
        require(address(msg.sender) == address(tx.origin), "no contract");
        _LP.transferFrom(msg.sender, address(this), _amount);
        if(_orders[msg.sender].isExist == false){
            createOrder(_amount);
            profitList.push(msg.sender);
        }else{
            PledgeOrder storage order=_orders[msg.sender];
            order.totalAmount += _amount;
        }
        lpTotalAmount += _amount;
    }

    function createOrder(uint256 trcAmount) private {
        _orders[msg.sender] = PledgeOrder(
            true,
            trcAmount
        );
    }
    
    //设置交易开关
    function setSwapEnable(bool _pair) public onlyOwner {
        swapEnable = _pair;
    }

    //设置白名单
    function setAllow(address _target, bool _bool) external onlyOwner{
        allowList[_target] = _bool;
    }

    //修改lp地址
    function setLp(address _target) external onlyOwner{
        _LP = IERC20(_target);
    }

    //ido开关
    function setIdoEnable(bool _target) external onlyOwner{
        idoEnable = _target;
        startTime = block.timestamp;
    }

    //分配lp分红领取次数，不领取下次失效
    function doLpProfit() external onlyOwner{
        for(uint i = 0; i < profitList.length; i++) {
            _lpStatusMapping[profitList[i]] = true;
        }
    }

    //提取lp收益
    function takeLpProfit() external {
        require(address(msg.sender) == address(tx.origin), "no contract");
        require(_lpStatusMapping[msg.sender], "no reward");
        require(balanceOf(msg.sender) >= 1000 * 10 * 18, "balance Insufficient");
        PledgeOrder storage order = _orders[msg.sender];
        require(lpBouns > 0, "no tokenBalance");
        uint256 profit = order.totalAmount * lpBouns / lpTotalAmount;
        super._transfer(address(this), msg.sender, profit);
    }

    //提取token收益
    function takeTokenProfit() external {
        require(address(msg.sender) == address(tx.origin), "no contract");
        require(block.timestamp - _tokenReceiveLastTime[msg.sender] >= times, "time no come");
        require(balanceOf(msg.sender) >= 1000 * 10 * 18, "balance Insufficient");
        require(tokenBouns > 0, "no tokenBalance");
        uint256 profit = balanceOf(msg.sender) * tokenBouns / 61000000 * 10 ** 18;
        _tokenReceiveLastTime[msg.sender] = block.timestamp;
        super._transfer(address(this), msg.sender, profit);
    }

    //修改持币分红间隔
    function setTimes(uint256 _seconds) external onlyOwner{
        times = _seconds;
    }

    //修改nft地址
    function setNFTAddress(address _target) external onlyOwner{
        _nftAddress = _target;
    }

    //绑定推进关系
    function bind(address _target) external{
        commond[msg.sender] = _target;
    }

    //查询推荐人
    function getBind(address _target) external view returns(address){
        return commond[_target];
    }

    //增加mint次数
    function addIdoAmount(address _target) external{
        useMint[_target] ++;
    }

    //查询推荐人ido数量
    function getBindIdoAmount(address _target) external view returns(uint256){
        return commondIdo[_target];
    }

    //已经mint数量
    function getMintAmount(address _target) external view returns(uint256){
        return useMint[_target];
    }
    //代币提现
    function withdraw(address _token, address _target, uint256 _amount) external onlyOwner {
        require(IERC20(_token).balanceOf(address(this)) >= _amount, "no balance");
		IERC20(_token).transfer(_target, _amount);
    }
}