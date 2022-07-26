/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

pragma solidity 0.5.16;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
   */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
   */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
   */
    function symbol() external view returns (string memory);

    /**
    * @dev Returns the token name.
  */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
   */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
   */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
   */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
   */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract NBAToken is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    // 地址余额的数据映射
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    // 总量
    uint256 private _totalSupply;
    // 代币精度
    uint8 private _decimals;
    // 代币符号
    string private _symbol;
    // 代币名称
    string private _name;

    // 交易对地址存储（用户判断是否是在swap交易）
    mapping(address => bool) public automatedMarketMakerPairs;

    // 白名单列表，交易不扣手续费
    mapping(address => bool) public _isExcludedFromFee;

    //nft奖励列表
    uint256[] nftAbountList;
    address[] parentAbountAddressList;
    uint256[] parentAbountMoneyList;

    // 底池
    address public dichi_address = 0x64aA8da26975144199F0A7837452ec7f9E74a0e4;
    // 市值
    address public shizhi_address = 0x1ed77fE90e863A70dc9CDDB927F10dDE53910065;
    // 销售
    address public xiaoshou_address = 0xB78414d189224Fd5349E7e2575F7BbBbA3D15429;

    // 发展基金地址
    address private fazhan_fund_address = 0xaCdFbC30f1B5F12994fb372b202c4799D3eDAB89;
    // 公益基金地址
    address private gongyi_fund_address = 0x43869526B3948FFDF833B2e753055eD00A1e88aF;
    // NFT分润收款地址
    address private nft_profit_address = 0x43869526B3948FFDF833B2e753055eD00A1e88aF;
    // 卖家上级分润地址
    address private parent_profit_address = 0x43869526B3948FFDF833B2e753055eD00A1e88aF;

    // nft分润比例
    uint256 nftRate = 5;
    // 直推分润
    uint256 zhituiRate = 3;
    // 间推分润
    uint256 jiantuiRate = 2;
    // 发展基金比例
    uint256 fzjjRate = 3;
    // 公益基金比例
    uint256 gyjjRate = 2;

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    constructor() public {
        _name = "NBA";
        _symbol = "NBA";
        _decimals = 18;
        _totalSupply = 100000000 * 10 ** uint256(_decimals);

        // 一百万用于底池
        uint256 dichi_num = 1000000 * 10 ** uint256(_decimals);
        _balances[dichi_address] = dichi_num;
        emit Transfer(address(0), dichi_address, dichi_num);

        // 四百万用于市值
        uint256 shizhi_num = 4000000 * 10 ** uint256(_decimals);
        _balances[shizhi_address] = shizhi_num;
        emit Transfer(address(0), shizhi_address, shizhi_num);

        // 九千五百万用于销售
        uint256 xiaoshou_num = 95000000 * 10 ** uint256(_decimals);
        _balances[xiaoshou_address] = xiaoshou_num;
        emit Transfer(address(0), xiaoshou_address, xiaoshou_num);

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
    }

    // 获取交易卖出代币，nft所得分润记录
    function getNftAbountList()public view returns(uint256[] memory){
        return nftAbountList;
    }

    // 获取交易卖出代币，直推间推所得分润记录
    function getParentAbountMoneyList()public view returns(uint256[] memory){
        return parentAbountMoneyList;
    }

    // 获取交易卖出代币，地址记录
    function getParentAbountAddressList()public view returns(address[] memory){
        return parentAbountAddressList;
    }

    /**
     * @dev Returns the bep token owner.
   */
    function getOwner() external view returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token decimals.
   */
    function decimals() external view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
   */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
    * @dev Returns the token name.
  */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @dev See {BEP20-totalSupply}.
   */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
   */
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }


    /**
     * 
     * 设置交易对地址
     */
    function setAutomatedMarketMakerPair(address pair, bool value)
    public
    onlyOwner
    {
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    /**
     * 
     * 设置白名单，交易不扣15%手续费
     */
    function excludeFromFee(address account, bool excluded) public onlyOwner {
        if (_isExcludedFromFee[account] != excluded) {
            _isExcludedFromFee[account] = excluded;
        }
    }

    /**
     *
     *  批量设置白名单
     */ 
    function excludeMultipleAccountsFromFee(
        address[] memory accounts,
        bool excluded
    ) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = excluded;
        }
    }


    /**
     *
     *  设置nft收益地址
     */ 
    function setNftProfitAddress(address account) public onlyOwner {
        if(nft_profit_address != account){
            nft_profit_address = account;
        }
    }

    /**
     *
     *  设置卖家上级收益地址
     */ 
    function setParentProfitAddress(address account) public onlyOwner {
        if(parent_profit_address != account){
            parent_profit_address = account;
        }
    }

    /**
     *
     *  设置公益基金地址
     */ 
    function setGongyiFundAddress(address account) public onlyOwner {
        if(gongyi_fund_address != account){
            gongyi_fund_address = account;
        }
    }

    /**
     *
     *  设置发展基金地址
     */ 
    function setFazhanFundAddress(address account) public onlyOwner {
        if(fazhan_fund_address != account){
            fazhan_fund_address = account;
        }
    }
    
    function setNftRate(uint256 fee) public onlyOwner{
        nftRate = fee;
    }
    // 设置直推分润比例
    function setZhituiRate(uint256 fee) public onlyOwner{
        zhituiRate = fee;
    }
    // 设置间推分润比例
    function setJiantuiRate(uint256 fee) public onlyOwner{
        jiantuiRate = fee;
    }
    // 设置发展基金比例
    function setFzjjRate(uint256 fee) public onlyOwner{
        fzjjRate = fee;
    }
    // 设置公益基金比例
    function setGyjjRate(uint256 fee) public onlyOwner{
        gyjjRate = fee;
    }
    /**
     * @dev See {BEP20-transfer}.
   *
   * Requirements:
   *
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
   */
    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {BEP20};
   *
   * Requirements:
   * - `sender` and `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   * - the caller must have allowance for `sender`'s tokens of at least
   * `amount`.
   */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   * - `spender` must have allowance for the caller of at least
   * `subtractedValue`.
   */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
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
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");


        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        // 当接收地址是交易对地址时，说明是swap交易卖出，扣除15%
        if(automatedMarketMakerPairs[recipient]){
            // 到账数量85%
            uint256 rate = 100;
            rate = rate.sub(nftRate).sub(zhituiRate).sub(jiantuiRate).sub(fzjjRate).sub(gyjjRate);
            uint256 daozhang_num = rate.mul(amount).div(100);
            _balances[recipient] = _balances[recipient].add(daozhang_num);

            // nft 5%
            uint256 nftFee = nftRate.mul(amount).div(100);
            _balances[nft_profit_address] = _balances[nft_profit_address].add(nftFee);

            // 写入列表记录，线下系统查询并分润
            nftAbountList.push(nftFee);
            emit Transfer(sender, nft_profit_address, nftFee);

            // 卖家一代3% 二代 2%
            uint256 tjRate = zhituiRate.add(jiantuiRate);
            uint256 tjFee = tjRate.mul(amount).div(100);
            _balances[parent_profit_address] = _balances[parent_profit_address].add(tjFee);

            // 写入列表记录，线下系统查询并分润
            parentAbountAddressList.push(sender);
            parentAbountMoneyList.push(tjFee);
            emit Transfer(sender, parent_profit_address, tjFee);

            // 社区发展基金3%
            uint256 fzjjFee = fzjjRate.mul(amount).div(100);
            _balances[fazhan_fund_address] = _balances[fazhan_fund_address].add(fzjjFee);
            emit Transfer(sender, fazhan_fund_address, fzjjFee);

            // 公益基金2%
            uint256 gyjjFee = gyjjRate.mul(amount).div(100);
            _balances[gongyi_fund_address] = _balances[gongyi_fund_address].add(gyjjFee);
            emit Transfer(sender, gongyi_fund_address, gyjjFee);

        }else{
            _balances[recipient] = _balances[recipient].add(amount);
        }
        
        emit Transfer(sender, recipient, amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
   *
   * This is internal function is equivalent to `approve`, and can be used to
   * e.g. set automatic allowances for certain subsystems, etc.
   *
   * Emits an {Approval} event.
   *
   * Requirements:
   *
   * - `owner` cannot be the zero address.
   * - `spender` cannot be the zero address.
   */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}