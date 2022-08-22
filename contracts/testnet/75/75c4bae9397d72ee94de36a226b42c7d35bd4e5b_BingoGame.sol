/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

pragma solidity >=0.4.22 <0.9.0;
// SPDX-License-Identifier: Unlicensed
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


// Dependency file: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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


// Dependency file: @openzeppelin/contracts/utils/Context.sol


// pragma solidity ^0.8.0;

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


// Dependency file: @openzeppelin/contracts/token/ERC20/ERC20.sol


// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
// import "@openzeppelin/contracts/utils/Context.sol";

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

contract Ownable {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}
library IterableSingleSet {
    // Iterable mapping from address to uint;
    struct userInfo{
        uint256 amount;
        uint256 nowtime;
        uint256 deadline;
        uint16 feeType;
    }
    struct Map {
         address[] keys;
        //mapping(address => uint256) values;
        mapping(address => uint256) indexOf;
        mapping(address => userInfo) userType;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) public view returns (uint256 _amount,uint16 _feeType,uint256 _deadline) {
        return (map.userType[key].amount,map.userType[key].feeType,map.userType[key].deadline);
    }

    function getIndexOfKey(Map storage map, address key)
        public
        view
        returns (int256)
    {
        if (!map.inserted[key]) {
            return -1;
        }
        return int256(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint256 index)
        public
        view
        returns (address)
    {
        return map.keys[index];
    }

    function size(Map storage map) public view returns (uint256) {
        return map.keys.length;
    }

    function set(
        Map storage map,
        address key,
        uint256 _amount,
        uint256 _deadline,
        uint16 _feeType
    ) public {
        if (map.inserted[key]) {
            map.userType[key].amount = _amount;
            map.userType[key].feeType=_feeType;
            map.userType[key].deadline=_deadline;
        } else {
            map.inserted[key] = true;
            map.userType[key].amount = _amount;
            map.userType[key].feeType=_feeType;
            map.userType[key].deadline=_deadline;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.userType[key];

        uint256 index = map.indexOf[key];
        uint256 lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];
        map.keys[index] = lastKey;
        map.keys.pop();
    }
}
contract BingoGame is Ownable {
     using SafeMath for uint256;
     uint constant internal SECONDS_PER_DAY = 24 * 60 * 60;
    address public betTokenAddress=address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);//usdt
    address public ticketTokenAddress=address(0x5023691b41DbA260104cD7CD90A708754BC72423);//txd
    uint256 public minBetAmount=0.001*10**18;
    uint256 public bingoReturnAmount=0.0004*10**18;
    uint256 public noBingoReturnAmount=0.00045*10**18;
    uint16 private _inviterFee0=10;//1代数1%
    uint16 private _inviterFee1=5;//2代数 0.5%
    mapping(address => address) public inviter;
    using IterableSingleSet for IterableSingleSet.Map;
    IterableSingleSet.Map private singleBingoMap;//用户数数量
    uint64 public setIndex=1;//totalSetCount
    uint64 public oneDayMaxSet=3;
    uint256 private oneSetRealCount=0;
    mapping (uint256 => address) private currentSetAddress;
     mapping (uint64 => IterableSingleSet.Map) private _MapAllSet;
     struct userTakePartInInfo{
        uint64[] setIndexArr;
        uint256 takePartInTime;
        uint32  oneDayCount;
        uint32  oneDayBingoCount;
        uint8 bingoCount;
        uint256 inviterEarnings;
    }
    mapping (address => userTakePartInInfo) private _UserAllSet;
    constructor() public {
    }
    event TakePartIn(uint32,address[]);
    event SetRealCount(uint256,uint256);
    event BingoAddress(address,address);
    function takePartIn(uint256 _betAmount,uint256 _index,uint256 _deadline) payable public returns (uint32,address[] memory){
      address[] memory _addArr;
      IterableSingleSet.Map  storage singleSet= _MapAllSet[setIndex];
      require(singleSet.inserted[msg.sender]!= true,"Have taken part in");
      userTakePartInInfo storage _userTakePartInInfo=  _UserAllSet[msg.sender];
      uint32 status=0;
      {
           if(_userTakePartInInfo.setIndexArr.length>0){
            uint256 nowtime=block.timestamp;
           if((nowtime- _userTakePartInInfo.takePartInTime)> SECONDS_PER_DAY){//repeat
              _userTakePartInInfo.takePartInTime=block.timestamp;
            _userTakePartInInfo.setIndexArr.push(setIndex);
            _userTakePartInInfo.oneDayCount=1; 
            _userTakePartInInfo.oneDayBingoCount=0;
           }else{
               //判断是否超过24限制的局数
               if((_userTakePartInInfo.oneDayCount+1)>oneDayMaxSet){
                   status=0;
                   emit TakePartIn(status,_addArr);
                return (status,_addArr);
               }else{
                _userTakePartInInfo.setIndexArr.push(setIndex);
                _userTakePartInInfo.oneDayCount++; 
               }
           }
        }else{
            _userTakePartInInfo.takePartInTime=block.timestamp;
            _userTakePartInInfo.setIndexArr.push(setIndex);
            _userTakePartInInfo.oneDayCount++;
        }  
      }
     
        require(_betAmount>=minBetAmount,"Too low");
        
        singleSet.set(msg.sender,_betAmount,_deadline,0);
        uint256 setLen=singleSet.keys.length;
        collectionBet(_betAmount);
        //uint256 singleSize=singleSet.size();
        //require(_amount>=vipAmount);
        if(_userTakePartInInfo.oneDayBingoCount<3){
            oneSetRealCount++;
            currentSetAddress[oneSetRealCount]=msg.sender;
        }
       uint bingo1=0;uint bingo2;
       address address1;address address2;
       if(setLen==oneDayMaxSet){//判断参与的人数是否等于一局允许的最大局数
            //starting bingo
            if(oneSetRealCount==oneDayMaxSet){//10人全部没有中奖3次
                emit SetRealCount(oneSetRealCount,oneDayMaxSet);
                bingo1=random(oneSetRealCount,msg.sender)+1;
                bingo2=random(oneSetRealCount,address(this))+1;
                emit SetRealCount(bingo1,bingo2);
                if(bingo1==bingo2){
                    if(bingo2+1>oneSetRealCount){
                        bingo2=bingo2-1;
                    }
                }
                address1=currentSetAddress[bingo1];
                address2=currentSetAddress[bingo2];
                emit BingoAddress(address1, address2);
                //bingoReturnSend(address1);
                //bingoReturnSend(address2);
                //twoNoBingoReturn(address1,address2);

            }else{
                if(oneSetRealCount>2)
                {
                    bingo1=random(oneSetRealCount,msg.sender)+1;
                    bingo2=random(oneSetRealCount,address(this))+1;
                    if(bingo1==bingo2){
                        if(bingo2+1>oneSetRealCount){
                            bingo2=bingo2-1;
                        }
                    }
                    address1=currentSetAddress[bingo1];
                    bingoReturnSend(address1);
                    address2=currentSetAddress[bingo2];
                    bingoReturnSend(address2);
                    twoNoBingoReturn(address1,address2);

                }else{
                    if(oneSetRealCount==0){//如果参与的10人中全部都已中奖3次，则开奖时全部按未中奖返还55U

                    }else{
                        if(oneSetRealCount==1){//只有一个中奖
                            address1=currentSetAddress[oneSetRealCount];
                            bingoReturnSend(address1);
                            oneNoBingoReturn(address1);

                        }else{//2 个全部中奖
                            bingo1=1;
                            bingo2=2;
                            address1=currentSetAddress[bingo1];
                            bingoReturnSend(address1);
                            address2=currentSetAddress[bingo2];
                            bingoReturnSend(address2);
                            twoNoBingoReturn(address1,address2);
                        }
                    }
                }
            }
            
        setIndex++;
        status=1;
        oneSetRealCount=0;
        emit TakePartIn(status,_addArr);
        _addArr[0]=address1;
        _addArr[1]=address2;
        return (status,_addArr);
      }
      status=100;
      emit TakePartIn(status,_addArr);
      return (status,_addArr);
    }
    function twoNoBingoReturn(address address1,address address2)private{
        //bingocount ++
        userTakePartInInfo storage _bingoTakePartInInfo=  _UserAllSet[address1];
        _bingoTakePartInInfo.oneDayBingoCount++;
        _bingoTakePartInInfo=  _UserAllSet[address2];
        _bingoTakePartInInfo.oneDayBingoCount++;
        for(uint i=1;i<=oneSetRealCount;i++){
            if(currentSetAddress[i]!=address1&&currentSetAddress[i]!=address2){
                noBingoReturnSend(currentSetAddress[i]);
                _takeInviterFee(currentSetAddress[i],noBingoReturnAmount);
            }
        }
    }
    function oneNoBingoReturn(address address1)private{
        //bingocount ++
        userTakePartInInfo storage _bingoTakePartInInfo=  _UserAllSet[address1];
        _bingoTakePartInInfo.oneDayBingoCount++;
        for(uint i=1;i<=oneSetRealCount;i++){
            if(currentSetAddress[i]!=address1){
                noBingoReturnSend(currentSetAddress[i]);
                _takeInviterFee(currentSetAddress[i],noBingoReturnAmount);
            }
        }
    }
    function _takeInviterFee(
        address sender,
        uint256 tAmount
    ) private {
        address cur = sender;
        if (cur == address(0)) {
            return;
        }
        for (int256 i = 0; i < 2; i++) {
            uint256 rate;
            if (i == 0) {
                rate = _inviterFee0;//20;
            } else if (i == 1) {
                rate = _inviterFee1;//10;
            } 
            cur = inviter[cur];
            if (cur != address(0)) {
                userTakePartInInfo storage _userTakePartInInfo=  _UserAllSet[cur];
                uint256 curRAmount = tAmount.mul(rate).div(1000);
                _userTakePartInInfo.inviterEarnings=_userTakePartInInfo.inviterEarnings.add(curRAmount);
            }
            
        }
    }
    function oneDayCount(address _account) public view returns (uint32) {
       userTakePartInInfo storage _userTakePartInInfo= _UserAllSet[_account];
       if(_userTakePartInInfo.setIndexArr.length>0){
            uint256 nowtime=block.timestamp;
           if((nowtime- _userTakePartInInfo.takePartInTime)> SECONDS_PER_DAY){//repeat
              return(0);
           }else{
                return (_userTakePartInInfo.oneDayCount);
           }
        }else{
            return(0);
        }
       //return (token.allowance(msg.sender, address(this)));
   }
   //转账到合约地址
   function collectionBet(uint256 _betAmount) private{
        ERC20 token = ERC20(betTokenAddress);
        token.transferFrom(msg.sender, address(this), _betAmount);
   }
   function withdrawInviterFee() public{//提现
        ERC20 erc20token = ERC20(betTokenAddress);
        userTakePartInInfo storage _userTakePartInInfo=  _UserAllSet[msg.sender];
        require(_userTakePartInInfo.inviterEarnings>0,"Inviter Fee is zero!"); 
        uint256 balance =erc20token.balanceOf(address(this));
        require(balance>=_userTakePartInInfo.inviterEarnings,"Inviter Fee is zero!"); 
        erc20token.transfer(msg.sender, _userTakePartInInfo.inviterEarnings);
   }
   function getSingleSetCount(uint64 _setIndex) public view returns(uint256, address[] memory){
       IterableSingleSet.Map  storage singleSet= _MapAllSet[_setIndex];
       return (singleSet.keys.length, singleSet.keys);
    }
    function getCurrentSetAddress(uint256 realIndex) public view returns(address){
        return currentSetAddress[realIndex];
    }
    // Whether the user has already take part in the game
    function getUserIsTakePartIn(uint64 _setIndex,address _userAdd) public view returns(bool){
       IterableSingleSet.Map  storage singleSet= _MapAllSet[_setIndex];
       return (singleSet.inserted[_userAdd]);
    }
   function getAllowance() public view returns (uint256) {
       ERC20 token = ERC20(betTokenAddress);
       return (token.allowance(msg.sender, address(this)));
   }
   function setApprove(uint256 _amount) public returns (bool) {
    ERC20 token = ERC20(betTokenAddress);
    return (token.approve(address(this), _amount));
   }
   function getBalanceOf(address _account) public view returns (uint256) {
    ERC20 token = ERC20(ticketTokenAddress);
    return (token.balanceOf(address(_account)));
   }
    function getUserSetInfoBySender(uint64 _setIndex) public view returns (uint256 _amount,uint16 _feeType,uint256 _deadline) {
        IterableSingleSet.Map  storage singleSet= _MapAllSet[_setIndex];
        return singleSet.get(msg.sender);
    }
    function getUserSetInfoBySender(uint64 _setIndex,address _userAdd) public view returns (uint256 _amount,uint16 _feeType,uint256 _deadline) {
        IterableSingleSet.Map  storage singleSet= _MapAllSet[_setIndex];
        return singleSet.get(_userAdd);
    }
   
    //receive() external payable {}
    function setOneDayMax(uint8 _oneDayMax) public onlyOwner {
        oneDayMaxSet = _oneDayMax;
    }
    function setInviter(address account,address _inviter) public {
        inviter[account] = _inviter;
    }
    function bingoReturnSend(address _account) private{
        ERC20 erc20token = ERC20(betTokenAddress);
        erc20token.transfer(_account, bingoReturnAmount);
    }
    function noBingoReturnSend(address _account) private{
        ERC20 erc20token = ERC20(betTokenAddress);
        erc20token.transfer(_account, noBingoReturnAmount);
    }
    function claim(address _token) public onlyOwner {
        if (_token == owner) {
            payable(owner).transfer(address(this).balance);
            return;
        }
        ERC20 erc20token = ERC20(_token);
        uint256 balance = erc20token.balanceOf(address(this));
        erc20token.transfer(owner, balance);
    }
    function random(uint number,address _address) public view returns(uint) {
    return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        _address))) % number;
    }
    receive() external payable {}
}