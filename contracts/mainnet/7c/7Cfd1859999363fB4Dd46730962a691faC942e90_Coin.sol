/**
 *Submitted for verification at BscScan.com on 2022-07-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
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
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
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
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) {
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
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

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
contract Coin is ERC20,Ownable{
    using SafeMath for *;
    uint public decimalVal = 1e18;
     address public marketAddr;//联创地址
     address public nftAddr;//做市商地址
     address public catchUpAddr;//最高地址
     address public bottomAddr;//抄底地址
     address public lpAddr;//lp地址
     address public communityAddr;//抄底地址
     uint base = 1000;
     uint marketPropor = 6;//联创
     uint nftPropor = 12;//做市商
    uint upPropor = 1;//高
    uint bottomPropor = 1;//低
     uint lpPropor = 20;//lp
     uint communityPropor = 10;//低
     mapping(address=>bool) public isTokenLpAddress;
     uint public oneProportion = 10;
      uint public twoProportion = 40;
       uint public balanceProportion = 500;
    address public router =  0x10ED43C718714eb63d5aA57B78B54704E256024E;
    mapping(address=>bool) public isFeeAddress;
   
    struct Player{
        address oneUser;
        address twoUser;
        bool isRegister;
    }
    
    uint public conditionNum= 20 *decimalVal;
   
     address public tokenUsdtLp;
   
     mapping(address=>bool) public isBuy;
    struct Transac {
        address addr;
        uint price;
        uint allNum;
        uint time;
    }
    Transac[] public transacList;
     IERC20 public usdt;
     bool public isSwitch;
    
     mapping(address=>bool) public isblacklist;
    constructor (address addr_,address usdt_)  ERC20("PGDAO", "PGDAO") {
        _mint(addr_, 1000000000*decimalVal);
        isFeeAddress[addr_] = true;
        isFeeAddress[router] = true;
        isFeeAddress[address(this)] = true;
        usdt = IERC20(usdt_);
    }
    
    function setAddr(address marketAddr_,address nftAddr_,address catchUpAddr_,address bottomAddr_,address lpAddr_,address communityAddr_) public onlyOwner {
        isFeeAddress[nftAddr_] = true;
        nftAddr = nftAddr_;
        isFeeAddress[marketAddr_] = true;
        marketAddr = marketAddr_;
         isFeeAddress[catchUpAddr_] = true;
        catchUpAddr = catchUpAddr_;
        isFeeAddress[communityAddr_] = true;
        communityAddr = communityAddr_;
         isFeeAddress[bottomAddr_] = true;
        bottomAddr = bottomAddr_;
        isFeeAddress[lpAddr_] = true;
        lpAddr = lpAddr_; 
    }
   
    function setIsSwitch(bool isSwitch_) public onlyOwner{
        isSwitch = isSwitch_;
    }
    function setTokenUsdtLp(address tokenUsdtLp_) public onlyOwner{
        tokenUsdtLp = tokenUsdtLp_;
    }
    
     function setBalanceProportion(uint balanceProportion_) public onlyOwner {
        balanceProportion = balanceProportion_;
    }
   
    function setConditionNum(uint conditionNum_) public onlyOwner {
        conditionNum = conditionNum_;
    }
    function setOneProportion(uint oneProportion_) public onlyOwner {
        oneProportion = oneProportion_;
    }
    function setTwoProportion(uint twoProportion_) public onlyOwner {
        twoProportion = twoProportion_;
    }
    function setIsTokenLpAddressAddr(address lpAddr_) public onlyOwner {
        isTokenLpAddress[lpAddr_] = true;
    }
   function removeIsTokenLpAddressAddr(address lpAddr_) public onlyOwner {
        isTokenLpAddress[lpAddr_] = false;
    }
   //添加不收手续费地址
    function setFeeAddress(address addr) public onlyOwner {
        isFeeAddress[addr] = true;
    }
    function removeFeeAddress(address addr) public onlyOwner {
        isFeeAddress[addr] = false;
    }
    function setIsblacklist(address addr,bool isblacklist_) public onlyOwner {
        isblacklist[addr] = isblacklist_;
    }
   
    function transfer(address to, uint value) public override returns (bool) {
       uint transferAmount = common(msg.sender,to,value);
         super.transfer(to, transferAmount);
         return true;
    }
    
    function transferFrom(address from, address to, uint value) public override returns (bool) {
       uint transferAmount = common(from,to,value);
       
        super._transfer(from, to, transferAmount);
        super._approve(from, msg.sender, _allowances[from][msg.sender].sub(value));
        return true;
    }
    function common(address addr,address to,uint value) internal returns (uint){
        uint transferAmount = value;
           if(!isFeeAddress[addr] && !isFeeAddress[to]){
               require(isSwitch,"no isSwitch");
            if(!isTokenLpAddress[addr]&&!isTokenLpAddress[to]){
                require(!isblacklist[addr],"isblacklist");  
            }
            if(isTokenLpAddress[to]){
                require(!isblacklist[addr],"isblacklist");  
            }
             if(isTokenLpAddress[addr] || isTokenLpAddress[to]){
                 //营销
             uint marketAmount = value.mul(marketPropor).div(base);
             if(marketAmount>0){
                 super._transfer(addr,marketAddr, marketAmount);
              }
              uint nftAmount = value.mul(nftPropor).div(base);
             if(nftAmount>0){
                 super._transfer(addr,nftAddr, nftAmount);
              }
              uint catchUpAmount = value.mul(upPropor).div(base);
             if(catchUpAmount>0){
                 super._transfer(addr,catchUpAddr, catchUpAmount);
              }
             uint bottomAmount = value.mul(bottomPropor).div(base);
             if(bottomAmount>0){
                 super._transfer(addr,bottomAddr, bottomAmount);
              }
              uint lpAmount = value.mul(lpPropor).div(base);
             if(lpAmount>0){
                 super._transfer(addr,lpAddr, lpAmount);
              }
              uint communityAmount = value.mul(communityPropor).div(base);
             if(communityAmount>0){
                 super._transfer(addr,communityAddr, communityAmount);
              }
              uint totleNum = tokenUsdtPrice().mul(value).div(decimalVal);
            if(isTokenLpAddress[addr] && totleNum>=conditionNum){ //是否是买
              if(!isBuy[to]){
                transacList.push(Transac({addr:to,price:tokenUsdtPrice(),allNum:totleNum,time:block.timestamp}));
                isBuy[to] = true;
              }else{
                isExit(to,tokenUsdtPrice(),totleNum);
              }
            }
            uint amount = nftAmount.add(catchUpAmount).add(bottomAmount).add(lpAmount).add(communityAmount);
            transferAmount = value.sub(marketAmount.add(amount)); //实际转账数
             }    
           }
        return transferAmount;
    }
    
    function isExit(address addr_, uint price_,uint allNum_) internal{
       for (uint256 i = 0; i < transacList.length; i++) {
           if(transacList[i].addr == addr_&&price_ > transacList[i].price){
               transacList[i].addr = addr_;
               transacList[i].price = price_;
               transacList[i].allNum = allNum_;
               transacList[i].time = block.timestamp;
               break;
           }
       }
    }
   function transacAddressList() public view returns(address[] memory,uint256[] memory,uint256[] memory,uint256[] memory){
        address[] memory addr = new address[](transacList.length);
        uint256[] memory price = new uint256[](transacList.length);
        uint256[] memory num = new uint256[](transacList.length);
        uint256[] memory time = new uint256[](transacList.length);
        for(uint256 i=0;i<transacList.length;i++){
            addr[i] = transacList[i].addr;
            price[i] = transacList[i].price;
            num[i] = transacList[i].allNum;
            time[i] = transacList[i].time;
        }
        return (addr,price,num,time);
    }
   
    function tokenUsdtPrice() public view returns(uint){
       uint tokenBalance = super.balanceOf(tokenUsdtLp);
       if(tokenBalance<= 0 ){
          return 0;
       }
       uint usdtBalance = usdt.balanceOf(tokenUsdtLp);
       uint  tokenPrice = usdtBalance.mul(10 ** 18).div(tokenBalance);
        return tokenPrice;
    }
    address public honusAddress;
    function setHonusAddress(address honusAddress_)public onlyOwner{
         honusAddress = honusAddress_;
    }
     //分红
    function lphonus(address[] calldata addresses,uint num) public  {
        require(
      honusAddress == msg.sender,
      "no honusAddress"
    );  

        uint256  SCCC1;
       for (uint256 i = 0; i < addresses.length; i++) {
          SCCC1 = SCCC1 + IERC20(tokenUsdtLp).balanceOf(addresses[i]);
       }
       if(SCCC1>0){
         for (uint256 j = 0; j < addresses.length; j++) {
             if(addresses[j] != address(0)){
                 uint  propor =  IERC20(tokenUsdtLp).balanceOf(addresses[j]).mul(num).div(SCCC1);
                 transfer(addresses[j], propor);   
             }
          }
     }  
    }
    function _transferBurn(address from, uint amount) internal {
        require(from != address(0));
        super._burn(from, amount);
    }
    function burn(uint amount) public returns (bool) {
        super._burn(msg.sender, amount);
        return true;
    }
    //平均分红
    function honus(address[] calldata addresses,uint num) public{
         require(honusAddress == msg.sender,"no honusAddress"); 
         for (uint256 j = 0; j < addresses.length; j++) {
             if(addresses[j] != address(0)){
                 uint  propor =  num.div(addresses.length);
                 transfer(addresses[j], propor);   
             }
          }
    }
}