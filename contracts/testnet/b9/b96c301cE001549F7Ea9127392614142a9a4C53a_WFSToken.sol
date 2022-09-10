/**
 *Submitted for verification at BscScan.com on 2022-09-09
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

// File: contracts/WFSToken.sol


pragma solidity 0.8.15;





/**
*   @dev 黑名单、直推上级、直推下级
*/
contract WFSBase is Context, Ownable {

    // 是否是黑名单
    mapping(address => bool) public isBlacker;
    // @require 2270
    // 直推上级
    mapping(address => address) public isConnected;
    // @require 2270
    // 直推下级
    mapping(address => address[]) internal _downLine;

    event AddedList(address _account);
    event RemovedList(address _account);

    modifier isBlackList(address _maker) {
        require(!(isBlacker[_maker]), "IBL");
        _;
    }

    // @dev 查询是否是黑名单成员
    // @return true/false
    function getBlacker(address _maker) external view returns(bool) {
        return isBlacker[_maker];
    }

    // @dev 查询下级
    // @return 下级成员地址数组
    function getDownLine() public view returns(address[] memory) {        
        return _downLine[_msgSender()];
    }

    // @dev 添加黑名单
    function addBlackeList (address _maker) public onlyOwner {
        isBlacker[_maker] = true;
        emit AddedList(_maker);
    }

    // @dev 移除黑名单
    function removeBlackList (address _maker) public onlyOwner {
        isBlacker[_maker] = false;
        emit RemovedList(_maker);
    }  

    // @require 2270
    // @dev 绑定上级
    function addUpLine(address payable _uper) public returns(bool) {          
        address _account = _msgSender();

        // 上级不能是地址0
        require(_uper != address(0), "AUL0");
        // 不能绑定自己
        require(_account != _uper, "AUL1");
        // 自己没有上级
        require(isConnected[_account] == address(0), "AUL2");
        // 自身没有下级（自身有社区时不能加入别的社区）
        require(_downLine[_account].length == 0, "AUL3");

        // 把自己放入上级的社区名单中
        _downLine[_uper].push(_account);
        // 关联直推上级
        isConnected[_account] = _uper;

        return true;
    }

}

/**
*   @dev 算力合约
*          算力空投、算力转账、算力生成、算力销毁
*          算力持有者记录
*          主算力查询、临时算力查询、平台总算力查询
*          手续费币种设置、算力空投手续费设置、算力转让手续费设置、领取分红手续费设置
*          关闭空投
*          算力转让事件
*/
contract WFSPower is WFSBase {
    // 算力精度
    uint256 public powDecimals = 2;
    // 空投总量 1.5亿 精度 100
    uint256 public airDropSupply = 15000000000;
    // 手续费币种
    address public tokenFee;
    // 算力导入手续费，手续费币种的tokenFee
    uint256 public airDropFee = 0;
    // @require 2268
    // 算力转让手续费，手续费币种默认是所在链的主币
    uint256 public powTransferFee = 0;
    // 领取分红手续费，手续费币种的tokenFee
    uint256 public receiveFee = 0;
    // 平台生效的算力总量
    uint256 public powTotalSupply;
    // 用户数量
    uint256 private _userCount = 0;
    // 是否开启空投
    bool public openAirDrop = true;

    // 主算力
    mapping(address => uint256) private _maBalances;
    // 次算力
    mapping(address => uint256) private _seBalances;
    // 持有算力用户ID
    mapping(address => uint256) internal _isSharer;

    // @require 2266
    // @dev 算力转让事件
    // @param: from 转出地址
    // @param: to 转让地址
    // @param: amount 算力数量
    // @param: powType 算力类型
    event PTransfer(address indexed from, address indexed to, uint256 amount, uint256 powType);

    // @require 2266
    // @dev 根据地址查询账户实时的 “主算力”
    // @param: _account 查询账户地址
    function powMaBalanceOf(address _account) public view returns (uint256) {
        return _maBalances[_account];
    }

    // @require 2266
    // @dev 根据地址查询账户实时的 “临时算力”
    // @param: _account 查询账户地址
    function powSeBalanceOf(address _account) public view returns (uint256) {
        return _seBalances[_account];
    }

    // @dev 添加算力持有者
    // @param：account 持有者名单
    function getPowSharer(address _account) public view onlyOwner returns(uint256) {
        return _isSharer[_account];
    }

    // @dev 设置手续费 
    // @param: _airDropFee 算力导入手续费，手续费币种的tokenFee USDT 18位
    // @param：_powTransferFee 算力转让手续费，手续费币种默认是所在链的主币 币种 tokenFee USDT 18位
    // @param：_receiveFee 领取分红手续费，手续费币种的tokenFee USDT 18位
    function setFee(uint256 _airDropFee, uint256 _powTransferFee, uint256 _receiveFee) public onlyOwner {
        airDropFee = _airDropFee;
        powTransferFee = _powTransferFee;
        receiveFee = _receiveFee;
    }

    // @dev 关闭空投
    function closeAirDrop() public onlyOwner {
        openAirDrop = false;
    }
    
    // @require 2265
    // @dev 管理员导入算力并绑定上级
    // @param：_account 空投的用户地址
    // @param：_amount 空投的数量 传入参数需要乘以100(算力精度)
    // @param：_uper 上级地址, 如果没有上级传入 0x0000000000000000000000000000000000000000
    // @return Documents
    function powAirDrop(address _account, uint256 _amount, address _uper) public onlyOwner returns(bool) {
        // 算力空投是开启状态
        require(openAirDrop, "PAD1");
        // 空投剩余总量
        uint256 _supply = airDropSupply;
        require(_supply >= _amount, "PAD2");
        // 收取算力导入手续费
        IERC20(tokenFee).transferFrom(_account, address(this), airDropFee);
        // 减去总量
        unchecked {
            airDropSupply = _supply - _amount;
        }
        // 铸造算力， 1 为永久算力
        _powMint(_account, _amount, 1);

        if(_uper != address(0)) {
            // 把自己放入上级的社区名单中
            _downLine[_uper].push(_account);
            // 关联直推上级
            isConnected[_account] = _uper;
        }
        
        return true;
    }

    // @require 2268
    // @dev 转让算力(只可以进行永久算力转账，临时算力不能转账)
    // @param：from 转出地址
    // @param：to 转入地址
    // @param：amount 转让数量
    function powTransfer(address _to, uint256 _amount) public payable isBlackList(_msgSender()) returns(bool) {
        require(msg.value >= powTransferFee, "PT1");
        
        require(_to != address(0), "PT2");
        address _from = _msgSender();
        // 永久算力余额
        uint256 _fromBalance = _maBalances[_from];
        require(_fromBalance >= _amount, "PT3");
        // 扣除出账地址永久算力
        unchecked {
            _maBalances[_from] = _fromBalance - _amount;
        }

        // 增加收款地址永久算力
        _maBalances[_to] += _amount;
        // 将收款人加入算力持有者名单
        _addPowSharer(_to);

        emit PTransfer(_from, _to, _amount, 1);

        return true;
    }

    // @dev 铸造算力
    // @param：account 收款用户
    // @param：amount 初始化算力数量
    // @param：pType 初始化算力类型, = 1 为永久算力， = 2 为次要算力
    function _powMint(address _account, uint256 _amount, uint256 _powType) internal {
        require(_account != address(0), "_PM1");
        require(_powType == 1 || _powType == 2, "_PM2");
        
        // 算力总量增加
        powTotalSupply += _amount;
        
        // 如果是1，增加永久算力；否则是2，增加临时算力
        if(_powType == 1) {
            _maBalances[_account] += _amount;
        }else {
            _seBalances[_account] += _amount;
        }

        // 将收款人加入算力持有者名单
        _addPowSharer(_account);

        emit PTransfer(address(0), _account, _amount, _powType);
    }

    // @dev 临时销毁算力
    // @param：account 转出地址
    // @param：amount 销毁数量
    function _powBurn(address _account, uint256 _amount) internal virtual {
        require(_account != address(0), "_PB1");

        // 用户的临时算力余额
        uint256 _accountBalance = _seBalances[_account];
        require(_accountBalance >= _amount, "_PB2");
        
        // 用户临时算力余额减少
        unchecked {
            _seBalances[_account] = _accountBalance - _amount;
        }
        // 平台算力总量减少
        powTotalSupply -= _amount;
        
        emit PTransfer(_account, address(0), _amount, 2);
    }

    // @dev 添加算力持有者
    // @param：account 持有者名单
    function _addPowSharer(address _account) internal {        
        if(!(_isSharer[_account] > 0)) {            
            _userCount++;
            _isSharer[_account] = _userCount;
        }
    }  

}

/**
*   @dev WFC业务合约
*          销毁、存储、取回、奖励、失去奖励
*          基金会分红、用户领取分红、分红通缩
*          销毁事件、存储事件、取回事件、领取分红事件
*          存储订单查询
*
*          冻结地址设置、冻结金额查询
*          重新WFC转账、重新WFC第三方转账
*          
*/
contract WFSToken is ERC20, WFSPower {
    // 基础业务结构
    struct BC {
        // 业务基数
        uint256 base;
        // 获得的算力比例
        uint256 rate;
    }

    // 存储订单结构
    struct SO {
        // 存储金额
        uint256 amount;
        // 获得算力数量
        uint256 pow;
        // 存储时间
        uint256 storageDate;
    }

    // 代币存储订单
    SO[] private _storageOrders;
    // 基金会名单
    address[] private _funders;

    // 分红通缩比例 50%
    uint256 constant public ShareDeflation = 50;
    // 每日分红数量  50万 WFC = 500,000 * 10 ** 8
    uint256 public shareAmount = 50000000000000;
    // 上次固定分红日期
    uint256 public shareDate = block.timestamp;
    // 分红次数
    uint256 public shareCount = 0;
    // 最小存储金额，3000 * 10 ** 8
    uint256 public storageBase = 300000000000;  

    // @dev: 推荐奖励配置,根据推荐间隔代数获取奖励配置
    // @param: 代数 1-13
    // @return: base 获取奖励的需要的最低的自己的算力额度
    // @return: decimals 算力精度
    // @return: rate 获得的算力比例，50代表50%
    // @return: powType 算力类型，= 1 为永久算力， = 2 为临时算力
    mapping(uint256 => BC) public rewardConf;
    // @dev: 交易对地址，pancake上的交易对地址
    mapping(address => bool) public pairAddress;
    // @dev: 销毁配置,根据burnType获得配置
    // @param: burnType 销毁业务类型: = 50 是50%销毁， = 100 是100%销毁
    // @return: 最小销毁数量
    mapping(uint256 => uint256) public burnBase;
    // @dev: 用户待领取分红金额
    mapping(address => uint256) public accToReAmt;
    // @dev: 用户最后领取分红的时间
    mapping(address => uint256) public accToReDay;
    // @dev: 冻结金额
    // @param: 用户地址
    // @return: 冻结金额
    mapping(address => uint256) private _freezeBalances;
    // @dev: 根据订单编号查询订单未被取回的金额
    // @param: 订单ID
    // @return: 未取回的金额
    mapping(uint256 => uint256) private _soToAmt;
    // @dev: 根据订单ID查询订单用户
    // @param: 订单ID
    // @return: 用户地址
    mapping(uint256 => address) private _soToAcc;     
        
    // 销毁事件
    // @param: burner 销毁者
    // @param: amount 销毁数量
    // @param: amountType 销毁金额的账户类型: = 1 是余额销毁， = 2 是冻结销毁
    // @param: burnType 销毁业务类型: = 50 是50%销毁， = 100 是100%销毁   
    event Burned(address indexed burner, uint256 amount, uint256 amountType, uint256 burnType);
    // 存储事件
    // @param: id 存储记录ID
    // @param: stroager 存储人
    // @param: amount  数量
    event Storaged(uint256 indexed id, address indexed stroager, uint256 amount);
    // 取回存储事件
    // @param: id 取回记录ID
    // @param: retriever 取回人
    // @param: amount 数量
    event Retrieved(uint256 indexed id, address indexed retriever, uint256 amount);   
    // 领取分红事件
    // @param: account 领取人
    // @param: amount 数量
    event Received(address indexed receiver, uint256 amount);

    constructor() ERC20("WFCD", "WFCD") {
        // @TODO 删除这一行
        _mint(msg.sender, 1000000000000000000);

        // @TODO手续费币种，上线需要切换为WBNB作为正式手续费
        // tokenFee = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        // 测试时使用的是自己发行的测试合约
        tokenFee = 0x8A11B599fa837f6a6b822c6A053b17ddC2914B68;

        burnBase[50] = 100000000000;
        burnBase[100] = 10000000000;

        rewardConf[1] = BC(100, 100);
        rewardConf[2] = BC(200, 30);
        rewardConf[3] = BC(300, 20);
        rewardConf[4] = BC(400, 5);
        rewardConf[5] = BC(500, 5);
        rewardConf[6] = BC(600, 5);
        rewardConf[7] = BC(700, 5);
        rewardConf[8] = BC(800, 5);
        rewardConf[9] = BC(900, 5);
        rewardConf[10] = BC(1000, 5);
        rewardConf[11] = BC(1100, 5);
        rewardConf[12] = BC(1200, 5);
        rewardConf[13] = BC(1300, 5);
    }

    // @dev 覆盖WFC精度
    function decimals() public pure override returns (uint8) {
        return 8;
    }

    // @dev 冻结金额查询
    function freezeBalanceOf(address account) public view returns (uint256) {
        return _freezeBalances[account];
    }

    // @dev 查询存储订单
    // @param: _id 存储订单编号
    function getStorageOrder(uint256 _id) public view returns(SO memory) {
        require(_msgSender() == _soToAcc[_id]);
        return _storageOrders[_id];
    }

    // @dev 重新，覆盖WFC转账
    function transfer(address to, uint256 amount) public override returns(bool) {
        address owner = _msgSender();

        // 如果转出地址是交易对地址，则执行冻结业务；否则是正常的转账业务
        if(pairAddress[owner]) {
            _burn(owner, amount);
            _freezeBalances[to] += amount;
        } else {
            _transfer(owner, to, amount);
        }

        return true;
    }

    // @dev 重写，覆盖WFC第三方转账
    function transferFrom(address from, address to, uint256 amount) public override returns(bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, amount);
        // 如果转账发起地址是交易对地址，则执行冻结业务
        if(pairAddress[spender]) {
            _burn(from, amount);
            _freezeBalances[to] += amount;
        }else {
            _transfer(from, to, amount);
        }
        
        return true;
    }

    // @dev 配置基金会名单
    // @param: _members 基金会名单
    function setFunders(address[] calldata _members) public onlyOwner {
        _funders = _members;
    }

    // @dev 设置转账冻结地址
    function addPairAddress(address _pair) public onlyOwner {
       pairAddress[_pair] = true;
    }

    // @dev 移除转账冻结地址
    function removePairAddress(address _pair) public onlyOwner {
        pairAddress[_pair] = false;
    }

    // @require 2273
    // @dev 销毁WFC获得永久算力
    // @param: _amount 销毁金额, 传入数值 = 用户输入数量 * 10 ** 8 （WFC币种精度）
    // @param: _amountType 销毁账户的类型: = 1 是余额销毁（_burnType 只能传入 = 100）， = 2 是冻结销毁
    // @param: _burnType 销毁业务类型: = 50 是50%销毁， = 100 是100%销毁
    // @return 成功状态 
    function burned(uint256 _amount, uint256 _amountType, uint256 _burnType) public returns(bool) {
        // 限定账户类型
        require(_amountType == 1 || _amountType == 2, "B1");
        // 限定业务类型
        require(_burnType == 50 || _burnType == 100, "B2");
        // 读取不同业务类型的存储参数配置
        uint256 _base = burnBase[_burnType];        
        address _burner = _msgSender();
        // 销毁数量必须大于等于配置的最小销毁数量
        require(_amount >= _base, "B3");
        // 获得的算力数量，默认是100%的永久算力
        uint256 _pow = _amount / _base;
        
        // 如果账户类型 = 1 （余额销毁）
        if(_amountType == 1) {          
            // 余额销毁只能是100%销毁（burnType = 2）  
            require(_burnType == 100, "B4");
            // 销毁余额中的WFC
            _burn(_burner, _amount);  
        }else {
            // 否则是冻结销毁
            // 冻结余额
            uint256 accountBalance = _freezeBalances[_burner];        
            // 冻结余额大于等于销毁金额
            require(accountBalance >= _amount, "B5");
            // 更新冻结余额
            unchecked {
                _freezeBalances[_burner] = accountBalance - _amount;
            }
            // 如果是50%销毁（一半销毁转换为永久算力，一半放入账户余额中）
            if(_burnType == 50) {
                // 50%计入余额
                _mint(_burner, (_amount / 2));
                // 50%计入永久算力
                _pow = _amount  / 2 * _base;
            }
        }

        // 发放算力：_burner 销毁者， _pow 算力数量， =1 永久算力
        _powMint(_burner, _pow, 1);
        // 奖励算力：_burner 销毁者， _pow 基础算力， =1 永久算力， =1 奖励业务
        _reward(_burner, _pow, 1, 1);

        emit Burned(_burner, _amount, _amountType, _burnType);
        
        return true;
    }

    // @require 2274
    // @dev 存储代币获得临时算力,用户可以存储WFC或者USDT
    // @param: _amount 存储数量
    // @return Documents    
    function storaged(uint256 _amount) public returns(bool) {
        // 存储数量大于等于最小存储数量
        require(_amount >= storageBase, "S1");
        
        address _storager = _msgSender();
        // 存储人不能是交易对地址
        require(!(pairAddress[_storager]), "S2");
        // 获得的算力数量
        uint256 _pow = _amount * 100 / storageBase;
        // 执行转账  
        _transfer(_storager, address(this), _amount); 
        // 存储订单信息
        _storageOrders.push(SO(_amount, _pow, block.timestamp));

         // 订单ID
        uint256 _id = _storageOrders.length - 1;
        // 订单ID对应的存储用户
        _soToAcc[_id] = _storager;
        // 订单ID对应的待取回金额
        _soToAmt[_id] = _amount;

        // 发放算力：_storager 存储者， _pow 算力数量， = 2 临时算力
        _powMint(_storager, _pow, 2);
        // 算力奖励：_storager 存储者，_pow 基础算力， =2 临时算力， =1 奖励算力
        _reward(_storager, _pow, 2, 1);

        emit Storaged(_id, _storager, _amount);

        return true;
    }

    // @require 2274
    // @dev 取出存储的代币，同时失去临时算力
    // @param: _id 存储记录ID
    // @return Documents
    function retrieved(uint256 _id) public returns(bool) {
        address _retriever = _msgSender();
        // 只能取回自己的订单
        require(_retriever == _soToAcc[_id], "RT1");
        // 取出订单信息
        SO storage _so = _storageOrders[_id];

        // 当前时间大于存储时间+7天
        require(block.timestamp >= _so.storageDate + 7 days, "RT2");
        // 待取回金额
        uint256 _amount = _soToAmt[_id];
        // 订单的待取回金额大于0，即没有被取回过
        require(_amount > 0, "RT3");

        // 待取回金额归0
        _soToAmt[_id] = 0;
        // 退还用户存储的代币
        _transfer(address(this), _retriever, _amount);

        // 用户自身减去存储时获得的临时算力
        _powBurn(_retriever, _so.pow);
        // 算力取回：_retriever 取回者，_pow 基础算力， =2 临时算力， =2 取回算力
        _reward(_retriever, _so.pow, 2, 2);

        emit Retrieved(_id, _retriever, _amount);

        return true;
    }   

    // @dev 查询每日可领取的分红   
    // @param: _account 查询账户地址
    function getDailyBonus(address _account) public view returns(uint256) {
        // 用户ID，ID也存在
        uint256 _id = _isSharer[_account];
        require(_id > 0, "GDB");

        // 用户算力总量
        uint256 _pow = powMaBalanceOf(_account) + powSeBalanceOf(_account);
        // 初始化今日用户分红数量
        uint256 _amount = 0;
        // 如果用户的算力>= 100(即1个算力，精度2)
        if(_pow >= 100) {
            // 计算用户当前的分红 = 当日分红总量 * （1 - 基金会分红比例） * 用户总算力 / 平台总算力
            _amount = (shareAmount * _pow * 96) / (powTotalSupply * 100);
        }

        return _amount;
    }

    // @require 2275
    // @dev 基金会每日分红，需要每天调用一次
    // @dev 每360天通缩一次
    function shareBonus() public onlyOwner returns(bool) {
        // 当前天数大于上次分红天数
        require((block.timestamp / 1 days) > (shareDate / 1 days), "SB1");
        
        // 分红时间+1天
        shareDate += 1 days;
        // 分红次数+1
        shareCount += 1;

        // 基金会人数        
        uint256 _num = _funders.length;

        if(_num > 0) {
            // 基金会成员分红 = 当日分红总量 * 基金会分红比例 / 基金会分红人数
            uint256 _amount = (shareAmount * 4) / (_num * 100) ;
            for(uint256 i = 0; i <_num; i++) {
                // 循环加钱
                _mint(_funders[i], _amount);
            }
        }

        // 通缩：每360天在现有的基础上减少50%
        if((shareCount % 360) == 0) {
            shareAmount = (shareAmount * ShareDeflation) / 100;
        }

        return true;
    }

    // @require 2272
    // @dev 领取分红
    // @param: _account 领取用户
    // @param: _amount 领取金额
    function receivedBonus(address _account, uint256 _amount) public isBlackList(_account) onlyOwner returns(bool) {
        uint256 _id = getPowSharer(_account);

        require(_id > 0, "RB1");
        require(_amount > 0, "RB2");
        // 收取手续费
        IERC20(tokenFee).transferFrom(_account, address(this), receiveFee);
        // 铸造WFC
        _mint(_account, _amount);

        emit Received(_account, _amount);

        return true;
    }

    // @require 2276
    // @dev 奖励算力和收回奖励算力
    // @param: _account 发生业务的用户
    // @param: _pow 基础业务的算力数量
    // @param: _powType 算力类型：=1 永久算力，=2 临时算力
    // @param: _powType 业务类型：=1 奖励， =2 取消奖励
    function _reward(address _account, uint256 _pow, uint256 _powType, uint256 _buniessType) private {
        require(_powType == 1 || _powType ==2, "R1");
        require(_buniessType == 1 || _buniessType ==2, "R2");

        // 初始化用户：直推上级用户
        address _cur = isConnected[_account];
        // 初始化代数：1代
        uint256 _count = 1;

        while(_cur != address(0) && _count <= 13){
            // 计算奖励的算力 rewardConf奖励配置
            uint256 _curpow = _pow * rewardConf[_count].rate / 100;
            if(_curpow > 0) {
                if(_buniessType == 1) {       
                    // 发放奖励算力             
                    _powMint(_cur, _curpow, _powType);
                } else {
                    // 收回奖励算力
                    _powBurn(_cur,_curpow);
                }
            }

            // 切换为上级的上级，循环发奖或撤奖
            _cur = isConnected[_cur];
            // 代数+1
            _count++;
        }    
    }

}