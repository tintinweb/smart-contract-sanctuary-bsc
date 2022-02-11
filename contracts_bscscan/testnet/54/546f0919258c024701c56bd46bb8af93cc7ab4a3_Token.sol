/**
 *Submitted for verification at BscScan.com on 2022-02-11
*/

// File: contracts/TokenBsc/SafeMath.sol


pragma solidity ^0.6.12;

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
        require(b <= a, "SafeMath: subtraction overflow");
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
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
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}
// File: contracts/TokenBsc/IERC20.sol


pragma solidity ^0.6.12;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
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
// File: contracts/TokenBsc/ERC20Detailed.sol


pragma solidity ^0.6.12;


/**
 * @dev Optional functions from the ERC20 standard.
 */
abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

// File: contracts/TokenBsc/ERC20.sol


pragma solidity ^0.6.12;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20Mintable}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
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
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    uint256 public MAX_STOP_BURN_FEE_TOTAL;
    uint256 public totalBurn;

    address internal fundAddress;
    address internal lpAddress;
    address internal devAddress;
    address internal burnAddress;
    bool public isSellFee;
    bool public isBuyFee;
    uint256 internal totalRate;
    uint256 internal sFundFee;
    uint256 internal sLpFee;
    uint256 internal bBurnFee;

    enum TradeType {Add, Remove, Buy, Sell, Customer}

    bool public canRemoveLiquidity;
    uint256 public canRemoveLiquidityFee;
    uint256 public totalBuyFee; 

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    mapping(address=>uint256) public _totalLp;
    mapping (address => bool) public isPair;
    address[] public pairKey;
    mapping (address => bool) public isRouter;

    event _TransferEvent(address msgSender, address txOrigin, address sender, address recipient, TradeType tradeType, uint256 _msgValue);
    event _TotalLpEvent(uint256 tempTotalLp, uint256 totalLp);
    event _CanRemoveLiquidityEvent(bool _canRemove);
    event _MsgData(bytes4 _msgSig, bytes _msgData);

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function transferOwner(address _owner) public {
        require(msg.sender == devAddress, "Operator must be contract owner!");
        devAddress = _owner;
    }

    function getTotalLp(address _pair) public view returns(uint256) {
        return IERC20(_pair).totalSupply();
    }

    function pairLength() public view returns(uint256 length) {
        length = pairKey.length;
    }

    function setFundAddress(address _fundAddress) public {
        require(msg.sender == devAddress, "Operator must be contract owner!");
        fundAddress = _fundAddress;
    }

    function setLpAddress(address _lpAddress) public {
        require(msg.sender == devAddress, "Operator must be contract owner!");
        lpAddress = _lpAddress;
    }

    function setPairStatus(address _pair, bool _isPair) public  {
        require(msg.sender == devAddress, "Operator must be contract owner!");
        isPair[_pair] = _isPair;

        bool isInPairKey;
        uint256 _pairIndex;
        if(pairKey.length>0){
            for(uint256 i=0; i<pairKey.length; i++){
                if(pairKey[i] == _pair){
                    isInPairKey = true;
                    _pairIndex = i;
                } 
            }
        }

        if(_isPair) {
            setTotalLp(_pair);
            if(!isInPairKey){
                pairKey.push(_pair);
            }
        } else {
            _totalLp[_pair] = 0;
            if(isInPairKey){
                for(uint256 i=_pairIndex; i<pairKey.length; i++){
                    pairKey[i] = pairKey[i+1];
                }

                pairKey.pop();
            } 
        }
    }

    function setRouterStatus(address _router, bool _isRouter) public  {
        require(msg.sender == devAddress, "Operator must be contract owner!");
        isPair[_router] = _isRouter;
    }

    function setIsSellFee(bool _isSellFee) public {
        require(msg.sender == devAddress, "Operator must be contract owner!");
        isSellFee = _isSellFee;
    }

    function setIsBuyFee(bool _isBuyFee) public {
        require(msg.sender == devAddress, "Operator must be contract owner!");
        isBuyFee = _isBuyFee;
    }

    function setCanRemoveLiquidity(bool _canRemoveLiquidity) public {
        require(msg.sender == devAddress, "Operator must be contract owner!");
        canRemoveLiquidity = _canRemoveLiquidity;
    }

    function setTotalLp(address _pair) public returns(bool) {
        _totalLp[_pair] = getTotalLp(_pair);
        return true;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
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
    function transfer(address recipient, uint256 amount) public override returns (bool) {

        TradeType tradetype;
        if(isPair[msg.sender]) {
            address _pair = address(msg.sender);
            tradetype = (_totalLp[_pair] == getTotalLp(_pair)) ? TradeType.Buy : TradeType.Remove;
            // tradetype =  TradeType.Buy;            
            emit _MsgData(msg.sig, msg.data);
        } else {
            tradetype = TradeType.Customer;            
        }       
        _transfer(msg.sender, recipient, amount, tradetype);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `value`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {

        TradeType tradetype;

        if(isPair[recipient]) {
            tradetype = TradeType.Sell;            
            emit _MsgData(msg.sig, msg.data);
        } else {
            tradetype = TradeType.Customer;
        }
        _transfer(sender, recipient, amount, tradetype);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(amount)
        );
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
    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
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
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(subtractedValue)
        );
        return true;
    }

    function burn(address account, uint256 amount) public returns (bool) {
        require(tx.origin == account, "ERC20: account must be  the operator!!");
        _burn(account, amount);
        return true;
    }

    function burnFrom(address account, uint256 amount) public returns(bool) {
        _burnFrom(account, amount);
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
        uint256 amount, 
        TradeType tradetype
    ) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");  
        require(
            amount <= _balances[sender],
            "ERC20: transfer amount must be less than account balance！"
        );        

        canRemoveLiquidity = canRemoveLiquidity ? true : totalBurn >= canRemoveLiquidityFee ? true : false;

        if (tradetype == TradeType.Buy && isBuyFee ) { // buy 

                _balances[sender] = _balances[sender].sub(amount);
                uint256 rLp = amount.mul(sLpFee).div(totalRate);
                uint256 rFund = amount.mul(sFundFee).div(totalRate);
                uint256 rAmount = amount.sub(rLp).sub(rFund);
                _balances[recipient] = _balances[recipient].add(rAmount);
                _balances[fundAddress] = _balances[fundAddress].add(rFund);
                _balances[lpAddress] = _balances[lpAddress].add(rLp);
                totalBuyFee = totalBuyFee.add(rLp).add(rFund);
                emit Transfer(sender, recipient, rAmount);

        } else if ( tradetype == TradeType.Remove &&  canRemoveLiquidity == false) { // remove
            require(canRemoveLiquidity, "Option not permitted now!");
            // emit _CanRemoveLiquidityEvent(canRemoveLiquidity);
        } else if ( tradetype == TradeType.Sell && isSellFee && totalBurn < MAX_STOP_BURN_FEE_TOTAL) { // sell
                uint256 bAmount = amount.mul(bBurnFee).div(totalRate);

                bAmount = bAmount <=
                    MAX_STOP_BURN_FEE_TOTAL.sub(totalBurn)
                    ? bAmount
                    : MAX_STOP_BURN_FEE_TOTAL.sub(totalBurn);
                require(
                    amount.add(bAmount) <= _balances[sender],
                    "ERC20: transfer amount must be less than account balance！"
                );

                _balances[recipient] = _balances[recipient].add(amount);
                _balances[sender] = _balances[sender].sub(amount);
                emit Transfer(sender, recipient, amount);
                                
                _burn(sender, bAmount);            
        } else {   // add and customer 
            _balances[recipient] = _balances[recipient].add(amount);
            _balances[sender] = _balances[sender].sub(amount);
            emit Transfer(sender, recipient, amount);
        }
        if(pairKey.length>0){
            for(uint256 i=0; i<pairKey.length; i++){
                _totalLp[pairKey[i]] = getTotalLp(pairKey[i]);
            }
        }
        emit _TransferEvent(msg.sender, tx.origin, sender, recipient, tradetype, msg.value);

    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

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
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        _balances[burnAddress] = _balances[burnAddress].add(value);
        totalBurn = totalBurn.add(value);

        emit Transfer(account, burnAddress, value);
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
    function _approve(
        address owner,
        address spender,
        uint256 value
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        if(pairKey.length>0){
            for(uint256 i=0; i<pairKey.length; i++){
                _totalLp[pairKey[i]] = getTotalLp(pairKey[i]);
            }
        }
        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Destoys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(
            account,
            msg.sender,
            _allowances[account][msg.sender].sub(amount)
        );
    }
}

// File: contracts/TokenBsc/Token.sol


pragma solidity ^0.6.12;



/**
 * @title SimpleToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `ERC20` functions.
 */
contract Token is ERC20, ERC20Detailed {
    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        address _fundAddress, 
        address _lpAddress, 
        address _devAddress, 
        bool _isSellFee,     // 1 为true 0 为false
        bool _isBuyFee,       // 1 为true 0 为false
        uint256 _bBurnFee,    // 销毁比例, 卖扣销毁， 每卖出一笔销毁卖出量的45%
        uint256 _sFundFee,    // 基金费率 10 为千分之一的十份 , 每买入一笔扣除0.5% 加入资金池
        uint256 _sLpFee,      // lp 分红池费率 , 每买入一笔操作4.5% 加入分红池
        uint256 _MAX_STOP_BURN_FEE_TOTAL,     // 最大销毁数，达到总发行量的80%即8000万时停止销毁
        uint256 _canRemoveLiquidityFee       // 开放移除流动性所需的销毁的数量，销毁达到总发行量的50%即5000万时开放移除流动性
    ) public ERC20Detailed(_name, _symbol, _decimals) {
        uint256 initialSupply = uint256(10**6);        // 初始化代币数量 不含小数点 10 后面9个0， 即1亿
        _mint(msg.sender, initialSupply * (10**uint256(_decimals)));               

        fundAddress = _fundAddress;    // 基金地址
        lpAddress = _lpAddress;      // 分红池地址
        devAddress = _devAddress;     // 开发者账号
        burnAddress = address(0x000000000000000000000000000000000000dEaD);    // 销毁地址
        isSellFee = _isSellFee;               // 卖出是否扣费 true 为扣费 false 为不扣费
        isBuyFee = _isBuyFee;                // 买入是否扣费 true 为扣费 false 为不扣费
        
        totalRate = 1000;    // 总比例， 1000为把代币分为一千份

        bBurnFee = _bBurnFee;      // 销毁比例, 卖扣销毁， 每卖出一笔销毁卖出量的45%
        sFundFee = _sFundFee;       // 基金费率 10 为千分之一的十份 , 每买入一笔扣除0.5% 加入资金池
        sLpFee = _sLpFee;         // lp 分红池费率 , 每买入一笔操作4.5% 加入分红池
        MAX_STOP_BURN_FEE_TOTAL = totalSupply().mul(_MAX_STOP_BURN_FEE_TOTAL).div(totalRate);  // 最大销毁数，达到总发行量的80%即8000万时停止销毁, 
        canRemoveLiquidityFee = totalSupply().mul(_canRemoveLiquidityFee).div(totalRate);   // 开放移除流动性所需的销毁的数量，销毁达到总发行量的50%即5000万时开放移除流动性
    }
}