/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol


pragma solidity ^0.8.0;

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(uint80 _roundId)
    external
    view
    returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );

    function latestRoundData()
    external
    view
    returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
}

// File: contracts/getprice.sol


pragma solidity ^0.8.0;


/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   * - Multiplication cannot overflow.
   */
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

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
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

contract ERC20 is Context, IERC20,Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint256 private _totalUSDT;
    string private _name;
    string private _symbol;

    AggregatorV3Interface internal priceFeed;

    mapping(address => address[])  private team1; // user -> teams1
    mapping(address => address[])  private team2; // user -> teams2
    mapping(address => address)    private boss;  // user -> boss
    mapping(address => address[])  private usdtPayPersons;
    mapping(address => address)    private isBuy;  // user -> isBuy
    mapping(address => uint256)    private lockAmount;  // user --> lockAmount
    mapping(address => address)    private lockAddr;  // user --> lockAmount
    uint256 private pubSaleAmount;
    uint256 private pubSaleAlreadyAmount;





    uint256 private power1 = 5;
    uint256 private power2 = 3;
    uint256 public ratio = 3;
    //address private _owner;


    //address asset = 0x55d398326f99059fF775485246999027B3197955;
    address asset = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;
    uint256 private ethOne = 1 * 10 ** 15;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor () {
        _name = "TA01";
        _symbol = "TA01";
        _totalSupply = 0;
        //_owner = msg.sender;
        _mint(msg.sender,200000000000000000000);
        pubSaleAmount = _totalSupply * 12 / 100;
        //priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);
        priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
    }


    function getLatestPrice() public view returns (int) {
        (
        /*uint80 roundID*/,
        int price,
        /*uint startedAt*/,
        /*uint timeStamp*/,
        /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return price;
    }



    function isActive() public view returns(bool) {
        if (boss[_msgSender()] == address(0)) {
            return false;
        }else{
            return true;
        }
    }

    function getInvite() public view returns(address) {
        if (boss[_msgSender()] == address(0)) {
            return address(0);
        }else{
            return boss[_msgSender()];
        }
    }

    function setRatio(uint256 ratio) onlyOwner public{
        // require(msg.sender==_owner);
        ratio = ratio;
    }

    function activeAddress() public view returns(address,address) {
        return (boss[_msgSender()],boss[boss[_msgSender()]]);
    }

    function payBuyBnb(address invite) public  payable {
        address addr1;
        address addr2;
        uint256 powerBalance;

        if (boss[_msgSender()] == address(0) && _msgSender() != invite && invite != address(0)) {
            boss[_msgSender()] = invite;
            team1[invite].push(_msgSender());

            address invite2 = boss[invite];
            if (invite2 != address(0)) {
                team2[invite2].push(_msgSender());
            }
        }

        int priceBn = getLatestPrice();
        uint256 priceBnb = uint256( priceBn / (1 *10 **8));

        pubSaleAlreadyAmount +=msg.value * priceBnb * ratio;
        require(pubSaleAmount>=pubSaleAlreadyAmount,"only can sell 12% max");
        require(msg.value >= ethOne);
        //require(isActive());
        require(msg.value.mul(ratio)<_totalSupply);
        (addr1,addr2) = activeAddress();
        if(addr1!=address(0)){
            payable(addr1).transfer(msg.value * power1 / 100);
            powerBalance+=power1;
        }
        if(addr2!=address(0)){
            payable(addr2).transfer(msg.value * power2 / 100);
            powerBalance+=power2;
        }

        payable(owner()).transfer(msg.value * (100-powerBalance) / 100);
        _mintToBuy(_msgSender(),msg.value * priceBnb * ratio);
        _totalUSDT+=msg.value * (100-powerBalance) / 100 * priceBnb /(1*10**18);

        if (isBuy[_msgSender()] == address(0)){
            isBuy[_msgSender()] = owner();
            usdtPayPersons[owner()].push(_msgSender());
        }
    }

    function payBuyUSDT(uint256 amount,address invite) public {
        address addr1;
        address addr2;
        uint256 powerBalance;
        //require(amount >=10,"less than 10 usdt");

        if (boss[_msgSender()] == address(0) && _msgSender() != invite && invite != address(0)) {
            boss[_msgSender()] = invite;
            team1[invite].push(_msgSender());

            address invite2 = boss[invite];
            if (invite2 != address(0)) {
                team2[invite2].push(_msgSender());
            }
        }
        //require(isActive());
        require(amount * ratio *10**18<=_totalSupply);
        pubSaleAlreadyAmount +=amount * ratio *10**18;
        require(pubSaleAmount>=pubSaleAlreadyAmount,"only can sell 12% max");

        (addr1,addr2) = activeAddress();
        IERC20 token = IERC20(asset);

        if(addr1!=address(0)){
            token.transferFrom(_msgSender(),addr1,amount * 10 ** 18 * power1 / 100);
            powerBalance+=power1;
        }
        if(addr2!=address(0)){
            token.transferFrom(_msgSender(),addr2,amount * 10 ** 18 * power2 / 100);
            powerBalance+=power2;
        }


        token.transferFrom(_msgSender(),owner(),amount * 10 ** 18 * (100 - powerBalance) / 100);
        _mintToBuy(_msgSender(),amount * ratio *10**18);
        _totalUSDT+=amount * (100-powerBalance) / (100);
        if (isBuy[_msgSender()] == address(0)){
            isBuy[_msgSender()] = owner();
            usdtPayPersons[owner()].push(_msgSender());
        }
    }



    //
    function transFerPri(address toAddr,uint256 amount) onlyOwner public {
        _mintToBuy(toAddr,amount * (ratio));
        if(lockAddr[toAddr] == address(0)){
            lockAddr[toAddr] = toAddr;
            lockAmount[toAddr] = amount * (ratio) ;
        }else{
            lockAmount[toAddr] = amount * (ratio)  + lockAmount[toAddr];
        }
    }

    // si
    function releasePri(address toAddr,uint256 amount) onlyOwner public {
        if(lockAddr[toAddr] == address(0)){
            return;
        }else{
            require(lockAmount[toAddr]>=amount,"release amount big than balance");
            lockAmount[toAddr] = lockAmount[toAddr].sub(amount);
            if(lockAmount[toAddr]==amount){
                lockAddr[toAddr] = address(0);
            }
        }
    }


    function getUSDTAmount() public view  returns(uint256){
        return _totalUSDT;
    }

    function getUSDTPersons() public view  returns(uint256){
        return usdtPayPersons[owner()].length;
    }

    function getAlreadtSellA() public view returns(uint256){
        return pubSaleAlreadyAmount;
    }

    function _mintToBuy(address account, uint256 amount) internal {
        uint256 amountD = amount;
        require(account != address(0), "BEP20: mint to the zero address");
        _balances[owner()] = _balances[owner()].sub(amountD, "BEP20: burn amount exceeds balance");
        _balances[account] = _balances[account].add(amountD);
        emit Transfer(owner(), account, amountD);
    }

    function sumInvitePower(address addr) public view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < team1[addr].length; i++) {
            address team = team1[addr][i];
            total += power1;
        }
        for (uint256 i = 0; i < team2[addr].length; i++) {
            address team = team2[addr][i];
            total += power2;
        }
        return total;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overloaded;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
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
    /*    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
            _transfer(_msgSender(), recipient, amount);
            return true;
        }*/


    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        address sender = _msgSender();
        if(lockAddr[sender] == address(0)){
            _transfer(_msgSender(), recipient, amount);
            return true;
        }else{
            uint256 lockAm  = lockAmount[sender];
            uint256 senderBalance = _balances[sender];
            require(senderBalance.sub(amount)>=lockAm, "ERC20: transfer amount must be more than lock balance");
            _transfer(_msgSender(), recipient, amount);
            return true;
        }
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
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        if(lockAddr[sender] == address(0)){
            _transfer(sender, recipient, amount);
        }else{
            uint256 lockAm  = lockAmount[sender];
            uint256 senderBalance = _balances[sender];
            require(senderBalance.sub(amount)>=lockAm, "ERC20: transfer amount must be more than lock balance");
            _transfer(sender, recipient, amount);
        }

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

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
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

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
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
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

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

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
    function _approve(address owner, address spender, uint256 amount) internal virtual {
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
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}