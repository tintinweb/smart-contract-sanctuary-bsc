/**
 *Submitted for verification at BscScan.com on 2022-05-30
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IUniswapV2Router01 {
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

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

interface IUniswapV2Factory {
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

interface IUniswapV2Pair {
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


    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
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

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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
    function _cast(address account, uint256 amount) internal virtual {
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

interface ITokenHelper {
    function claimProfit(address account, uint256 amount) external returns (bool);
    function getProfit(address account) external view returns (uint256);
}

contract TokenHelper is Ownable, ITokenHelper {
    using SafeMath for uint256;

    address[] public shareholders;
    uint256 public currentIndex;  
    mapping(address => bool) private _updated;
    mapping (address => uint256) public shareholderIndexes;
    mapping(address => uint256) private _profit;
    uint256 public unreleasedProfit;

    address public uniswapV2Pair;
    address public lpRewardToken;
    address public bizAddress;
    // 上次分红时间
    uint256 public LPRewardLastSendTime;

    event Earning(address to, uint256 amount);
    event Claim(address account, uint256 amount);

    constructor(address uniswapV2Pair_, address lpRewardToken_, address bizAddress_) {
        uniswapV2Pair = uniswapV2Pair_;
        lpRewardToken = lpRewardToken_;
        bizAddress = bizAddress_;
    }

    function resetLPRewardLastSendTime() public onlyOwner {
        LPRewardLastSendTime = 0;
    }

    // LP分红发放
    function process(uint256 gas) external onlyOwner {
        uint256 shareholderCount = shareholders.length;	

        if(shareholderCount == 0) return;
        uint256 nowbanance = unreleasedProfit;

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
                LPRewardLastSendTime = block.timestamp;
                return;
            }

            uint256 amount = nowbanance.mul(IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex])).div(IERC20(uniswapV2Pair).totalSupply());
            if( amount == 0) {
                currentIndex++;
                iterations++;
                continue;
            }
            if(unreleasedProfit  < amount) return;
            
            unreleasedProfit = unreleasedProfit.sub(amount);
            _profit[shareholders[currentIndex]] = _profit[shareholders[currentIndex]].add(amount);
            emit Earning(shareholders[currentIndex], amount);

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    // 根据条件自动将交易账户加入、退出流动性分红
    function setShare(address shareholder) external onlyOwner {
        if(_updated[shareholder] ){      
            if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);           
            return;  
        }
        if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return;  
        addShareholder(shareholder);	
        _updated[shareholder] = true;
          
      }
    function quitShare(address shareholder) internal {
        removeShareholder(shareholder);   
        _updated[shareholder] = false; 
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function transferToken(address token, address receiver, uint256 amount) external onlyOwner {
        IERC20(token).transfer(receiver, amount);
    }

    function updateUnreleasedProfit(uint256 amount) external onlyOwner {
        unreleasedProfit = unreleasedProfit.add(amount);
    }

    function setBizAddress(address _address) external onlyOwner {
        bizAddress = _address;
    }

    function getProfit(address account) public view override returns (uint256) {
        return _profit[account];
    }

    function claimProfit(address account, uint256 amount) public override returns (bool) {
        require(bizAddress != address(0) && _msgSender() == bizAddress, "TokenHelper: claimProfit failed");
        require(amount > 0, "TokenHelper: claim amount must be greater than 0");
        IERC20(lpRewardToken).transfer(bizAddress, amount);
        _profit[account] = _profit[account].sub(amount);
        emit Claim(account, amount);
        return true;
    }
    
}


contract GKToken is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;
    bool private swapping;

    uint256 public swapTokensAtAmount; 

    uint256 public _deadFee = 150;
    uint256 private _previousburnFee;
    address public deadWallet = 0x000000000000000000000000000000000000dEaD;

    uint256 public _liquidityFee = 150; 
    uint256 public _previousLiquidityFee;

    uint256 public _marketingFee = 100; 
    uint256 public _previousMarketingFee;
    address public marketingWalletAddress = 0x811558487a9b7c89165c9EDde05FFdD9738c89b0; 

    uint256 public _lpRewardFee = 350;
    uint256 public _previousLPRewardFee;

    uint256 public _inviteFee = 450;
    uint256 public _previousInviteFee;

    uint256 public AmountLiquidityFee;
    uint256 public AmountBurnFee;
    uint256 public BurnCount = 9900000 * 10 ** 18;
    bool public enableSellFee = true; 

    address public liquidityReceiveAddress;

    // address public bep20usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public bep20usdt = 0x853875823CacE9418c292D8B41C1c192D3Ab5f1a;
    address public gksAddress;
    address public bizAddress;
    
    mapping (address => bool) private _isExcludedFromFees;
 
    TokenHelper public tokenHelper;
    
    address private fromAddress;
    address private toAddress;
    mapping (address => bool) isDividendExempt;

    mapping(address => address) public inviter;
   
    uint256 public minPeriod = 24 hours;
    
    uint256 distributorGas = 200000;

    event SwapAndLiquify(uint256 usdtSwapped, uint256 usdtReceived, uint256 gksSwapped, uint256 gksReceived);
    
    constructor(address liquidityReceiveAddress_, address gksAddress_) payable ERC20("GK", "GK")  {
        uint256 totalSupply = 10000000 * (10**18);
        // swapTokensAtAmount = totalSupply.mul(2).div(10**6); // 0.002%;
        swapTokensAtAmount = 200 * (10**18);
        
        // IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xCc7aDc94F3D80127849D2b41b6439b7CF1eB4Ae0);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), bep20usdt);

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        liquidityReceiveAddress = liquidityReceiveAddress_;
        gksAddress = gksAddress_;
        tokenHelper = new TokenHelper(uniswapV2Pair, address(this), bizAddress);

        excludeFromFees(owner(), true);
        excludeFromFees(marketingWalletAddress, true);
        excludeFromFees(liquidityReceiveAddress, true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(tokenHelper), true);

        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0)] = true;
        isDividendExempt[address(tokenHelper)] = true;

        _cast(owner(), totalSupply);
    }

    receive() external payable {}

   
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        if(_isExcludedFromFees[account] != excluded){
            _isExcludedFromFees[account] = excluded;
        }
    }

    
    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
    }

   
    function setMarketingWallet(address payable wallet) external onlyOwner{
        marketingWalletAddress = wallet;
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    
    function setSwapTokensAtAmount(uint256 amount) public onlyOwner {
        swapTokensAtAmount = amount;
    }

    
    function setLiquidityFee(uint256 val) public onlyOwner {
        _liquidityFee = val;
    }

   
    function setMarketingFee(uint256 val) public onlyOwner {
        _marketingFee = val;
    }

  
   function setDeadFee(uint256 val) public onlyOwner {
        _deadFee = val;
    }

    function setLpRewardFee(uint256 val) public onlyOwner {
        _lpRewardFee = val;
    }

    function setGksAddress(address _address) public onlyOwner {
        gksAddress = _address;
    }

    function setBizAddress(address _address) public onlyOwner {
        bizAddress = _address;
        tokenHelper.setBizAddress(_address);
    }
   
    function setMinPeriod(uint256 number) public onlyOwner {
        minPeriod = number;
    }

    
    function setLiquidityReceiveAddress(address val) public onlyOwner {
        liquidityReceiveAddress = val;
    }

    function setEnableSellFee(bool enable_) public onlyOwner {
        enableSellFee = enable_;
    }
    
    function resetLPRewardLastSendTime() public onlyOwner {
        tokenHelper.resetLPRewardLastSendTime();
    }

   
    function updateDistributorGas(uint256 newValue) public onlyOwner {
        require(newValue >= 100000 && newValue <= 500000, "distributorGas must be between 200,000 and 500,000");
        require(newValue != distributorGas, "Cannot update distributorGas to same value");
        distributorGas = newValue;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if(amount == 0) { super._transfer(from, to, 0); return;}

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount && enableSellFee;
        if( canSwap &&
            !swapping &&
            from != uniswapV2Pair &&
            from != owner() &&
            to != owner()
        ) {
            swapping = true;
            if(AmountLiquidityFee > 0){
                swapAndLiquify(AmountLiquidityFee);
                AmountLiquidityFee = 0;
            }
            swapping = false;
        }

        bool takeFee = !swapping;
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to] || from == address(uniswapV2Router)) {
            takeFee = false;
        }
        
        if(takeFee) {
            amount = _takeCustomerFee(from, to, amount);
        }

        bool shouldSetInviter = balanceOf(to) == 0 &&
            inviter[to] == address(0) &&
            from != uniswapV2Pair;

        super._transfer(from, to, amount);

        if (shouldSetInviter) {
            inviter[to] = from;
        }

        if(fromAddress == address(0) )fromAddress = from;
        if(toAddress == address(0) )toAddress = to;  
        if(!isDividendExempt[fromAddress] && fromAddress != uniswapV2Pair )   try tokenHelper.setShare(fromAddress) {} catch {}
        if(!isDividendExempt[toAddress] && toAddress != uniswapV2Pair ) try tokenHelper.setShare(toAddress) {} catch {}
        fromAddress = from;
        toAddress = to;  

       if(  !swapping && 
            from != owner() &&
            to != owner() &&
            from != address(this) &&
            tokenHelper.LPRewardLastSendTime().add(minPeriod) <= block.timestamp
        ) {
            try tokenHelper.process(distributorGas) {} catch {}    
        }
    }

    function _takeCustomerFee(address from, address to, uint256 amount) private returns(uint256 amountAfter) {
        amountAfter = amount;

        if (from == uniswapV2Pair) {
            bool allBurn = balanceOf(to) > 0 && inviter[to] == address(0) && AmountBurnFee < BurnCount;
            if (allBurn) {
                amountAfter = takeBurnFee(from, amount, 1200);
            } else {
                amountAfter =  takeAllFee(from, to, amount);
            }
        } else if (to == uniswapV2Pair) {
            uint256 LFee = amount.mul(500).div(10000);
            if(LFee > 0) super._transfer(from, address(this), LFee);
            AmountLiquidityFee += LFee;
            amountAfter = amountAfter.sub(LFee);
        } else {
            amountAfter = takeBurnFee(from, amount, 300);
        }
    }

    function takeBurnFee(address from, uint256 amount, uint256 feeRate) private returns(uint256 amountAfter)  {
        amountAfter = amount;

        if(AmountBurnFee < BurnCount) {
            uint256 BFee = amount.mul(feeRate).div(10000);
            if(BFee > 0) super._transfer(from, deadWallet, BFee);
            AmountBurnFee += BFee;
            amountAfter = amountAfter.sub(BFee);
        }
    }
    
    function takeAllFee(address from, address to, uint256 amount) private returns(uint256 amountAfter) {
        amountAfter = amount;

        amountAfter = takeBurnFee(from, amount, _deadFee);

        uint256 MFee = amount.mul(_marketingFee).div(10000);
        if(MFee > 0) super._transfer(from, marketingWalletAddress, MFee);
        amountAfter = amountAfter.sub(MFee);

        uint256 LFee = amount.mul(_liquidityFee).div(10000);
        if(LFee > 0) super._transfer(from, address(this), LFee);
        AmountLiquidityFee += LFee;
        amountAfter = amountAfter.sub(LFee);

        uint256 LPFee = amount.mul(_lpRewardFee).div(10000);
        if (LPFee > 0) {
            super._transfer(from, address(tokenHelper), LPFee);
            tokenHelper.updateUnreleasedProfit(LPFee);
        }
        amountAfter = amountAfter.sub(LPFee);

        // inviteFee
        if (_inviteFee > 0) {
            uint256 IFee = _takeInviterFee(from, to, amount);
            amountAfter = amountAfter.sub(IFee);
        }
    }

    function _takeInviterFee(address sender, address recipient, uint256 amount) private returns(uint256 feeAmount) {
        if(AmountBurnFee >= BurnCount) {
            _inviteFee = 0;
            return 0;
        }

        uint256 IFee = amount.mul(_inviteFee).div(10000);
        address cur;
        if (sender == uniswapV2Pair) {
            cur = recipient;
        } else if (recipient == uniswapV2Pair) {
            cur = sender;
        } else {
            super._transfer(sender, deadWallet, IFee);
            feeAmount = IFee;
            return feeAmount;
        }

        uint256 accurRate;
        for (int256 i = 0; i < 6; i++) { 
            uint256 rate;
            if (i == 0) {
                rate = 150;
            } else if (i == 1) {
                rate = 100;
            } else {
                rate = 50;
            }
            cur = inviter[cur];
            if (cur == address(0)) {
                break;
            }
            accurRate = accurRate.add(rate);

            uint256 curTAmount = amount.div(10000).mul(rate);
            super._transfer(sender, cur, curTAmount);
        }
        if (_inviteFee > accurRate) {
            uint256 burn = amount.mul(_inviteFee.sub(accurRate)).div(10000);
            super._transfer(sender, deadWallet, burn);
        }

        feeAmount = IFee;
    }
 
    function swapAndLiquify(uint256 tokens) private {
       // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        _approve(address(this), address(uniswapV2Router), tokens);

        // swap token for usdt
        IERC20 usdtInstance = IERC20(bep20usdt);
        uint256 initUsdtBalance = usdtInstance.balanceOf(address(tokenHelper));
        swapTokensForUsdt(half);
        uint256 usdtOut = usdtInstance.balanceOf(address(tokenHelper)).sub(initUsdtBalance);

        // swap token for gks
        IERC20 gksInstance = IERC20(gksAddress);
        uint256 initGksBalance = gksInstance.balanceOf(address(tokenHelper));
        swapTokensForGks(otherHalf);
        uint256 gksOut = gksInstance.balanceOf(address(tokenHelper)).sub(initGksBalance);

        tokenHelper.transferToken(bep20usdt, address(this), usdtOut);
        tokenHelper.transferToken(gksAddress, address(this), gksOut);

        // approve token transfer to cover all possible scenarios
        usdtInstance.approve(address(uniswapV2Router), usdtOut);
        gksInstance.approve(address(uniswapV2Router), gksOut);

        // add the liquidity
        uniswapV2Router.addLiquidity(
            gksAddress,
            bep20usdt,
            gksOut,
            usdtOut,
            0,
            0,
            liquidityReceiveAddress,
            block.timestamp
        );
        emit SwapAndLiquify(half, usdtOut, otherHalf, gksOut);
    }

    function swapTokensForUsdt(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = bep20usdt;
        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(tokenHelper),
            block.timestamp
        );
    }

    function swapTokensForGks(uint256 tokenAmount) private {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = bep20usdt;
        path[2] = gksAddress;

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(tokenHelper),
            block.timestamp
        );
    }
    
}