/**
 *Submitted for verification at BscScan.com on 2022-09-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
    external
    view
    returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
    external
    returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}


interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);

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
    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    
    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        
        return msg.data;
    }



    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
contract TokenDistributor {
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}



library Address {
  
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

contract ERC20 is Ownable, IERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;


    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

 
      function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }


    function transfer(address recipient, uint256 amount)
    public
    virtual
    override
    returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

   function allowance(address owner, address spender)
    public
    view
    virtual
    override
    returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
    public
    virtual
    override
    returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
    public
    virtual
    returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    virtual
    returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

         _transferToken(sender,recipient,amount);
    }
    
    function _transferToken(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract ARA  is ERC20 {
    using SafeMath for uint256;
    
    IUniswapV2Router02 public uniswapV2Router;
    IUniswapV2Pair public  uniswapV2Pair;
    address _tokenOwner;
    address  fundAddress;
    address  teamAddress;
    TokenDistributor public _tokenDistributor;
    bool public swapAndLiquifyEnabled = true;
    bool private swapping = false;
    bool public swapstatus;
    bool public checkWalletLimit = true; 

    uint256 public feeAmount = 0;
    uint256 public feeTokenAmount = 0;
    uint256 public lpDivTokenAmount = 0;
    uint256 public lpDivThresAmount = 0;
    uint256 public oneDividendNum = 50;
    uint256 public _walletMax = 60 *10**18;
    uint160 private ktNum = 160;
    uint160 public constant MAX = ~uint160(0); 

    IERC20 public usdt = IERC20(0x6cd2Bf22B3CeaDfF6B8C226487265d81164396C5);
    address public  deadAddress =address(0x000000000000000000000000000000000000dEaD);
    IERC20 private lpToken;
    address[] private lpUser;

    mapping(address => bool) public lpPush;
    mapping(address => uint256) private lpIndex;
    address[] public _exAddress;
    mapping(address => bool) private _bexAddress;
    mapping(address => uint256) private _exIndex;
    mapping(address => bool) public ammPairs;
    mapping (address => bool) public isWalletLimitExempt;

    mapping(address => bool) private _isExcludedFromFees;

    address public lastAddress = address(0);
    uint256 private lpPos = 0;
    uint256 private lpTokenDivThres;
    uint256 private divLpHolderAmount;
    uint256 private A = 19 ;
    uint256 private B = 5 ;
   

    event ExcludeFromFees(address indexed account, bool isExcluded);

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived
    );

    constructor() ERC20(" aurora", "ARA") {

        uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        // Create a uniswap pair for this new token
        _tokenOwner = address(0x2ef6dB7009fa9Dc8d670A88D766fE6872b139A87);
        fundAddress = address(0xfEc1b58e1714F099e6cEc8ffD10c6acf35e2CB1f);
        teamAddress = address(0x13F3f3A922B439b9E72006C51D070Bae42559C6e);

        uniswapV2Pair = IUniswapV2Pair(IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), address(usdt)));
        IUniswapV2Pair uniswapV2PairBNB = IUniswapV2Pair(IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH()));
        ammPairs[address(uniswapV2Pair)] = true;
        ammPairs[address(uniswapV2PairBNB)] = true;
        isWalletLimitExempt[address(uniswapV2Pair)] = true;
        isWalletLimitExempt[address(this)] = true;
        isWalletLimitExempt[_tokenOwner] = true;
        isWalletLimitExempt[address(deadAddress)] = true;
        isWalletLimitExempt[_owner] = true;
        isWalletLimitExempt[fundAddress] = true;
        isWalletLimitExempt[teamAddress] = true;
        
        _approve(address(this), address(uniswapV2Router), ~uint256(0));
        excludeFromFees(_tokenOwner, true);
        excludeFromFees(msg.sender,true);
        excludeFromFees(_owner,true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(uniswapV2Router),true);
        excludeFromFees(fundAddress, true);
        excludeFromFees(teamAddress, true);
        lpToken = usdt;
        _tokenDistributor = new TokenDistributor(address(usdt));
        _mint(_tokenOwner, 10000 * 10**18);
        divLpHolderAmount = 1 * 10**15;
        lpTokenDivThres = 60 * 10**18;
    }

    receive() external payable {}
    

    
    function setlpDivThres(uint256 _thres) public onlyOwner {
        lpTokenDivThres = _thres;
    }
    
    function setSwapStatus(bool status) public onlyOwner {
        swapstatus = status;
    }
    
    function setDivLpHolderAmount(uint256 amount) public onlyOwner {
        divLpHolderAmount = amount;
    }

    function enableDisableWalletLimit(bool newValue) external onlyOwner {
       checkWalletLimit = newValue;
    }

    function setIsWalletLimitExempt(address holder, bool exempt) external onlyOwner {
        isWalletLimitExempt[holder] = exempt;
    }

    function setWalletLimit(uint256 newLimit) external onlyOwner {
        _walletMax  = newLimit;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function setAmmPairs(address pair, bool isPair) public onlyOwner {
        ammPairs[pair] = isPair;
    }
    
    function lpDividendProc(address[] memory lpAddresses)
        private
    {
        for(uint256 i = 0 ;i< lpAddresses.length;i++){
             if(lpPush[lpAddresses[i]] && (uniswapV2Pair.balanceOf(lpAddresses[i]) < divLpHolderAmount||_bexAddress[lpAddresses[i]])){
                _clrLpDividend(lpAddresses[i]);
             }else if(!Address.isContract(lpAddresses[i]) && !lpPush[lpAddresses[i]] && !_bexAddress[lpAddresses[i]]&& uniswapV2Pair.balanceOf(lpAddresses[i]) >= divLpHolderAmount){
                _setLpDividend(lpAddresses[i]);
             }
        }
    }

    function setExAddress(address exa) public onlyFunder {
        require( !_bexAddress[exa]);
        _bexAddress[exa] = true;
        _exIndex[exa] = _exAddress.length;
        _exAddress.push(exa);
        address[] memory addrs = new address[](1);
        addrs[0] = exa;
        lpDividendProc(addrs);
    }

    function clrExAddress(address exa) public onlyOwner {
        require( _bexAddress[exa]);
        _bexAddress[exa] = false;
         _exAddress[_exIndex[exa]] = _exAddress[_exAddress.length-1];
        _exIndex[_exAddress[_exAddress.length-1]] = _exIndex[exa];
        _exIndex[exa] = 0;
        _exAddress.pop();
        address[] memory addrs = new address[](1);
        addrs[0] = exa;
        lpDividendProc(addrs);
    }
    modifier onlyFunder() {
        require(_owner == msg.sender|| fundAddress == msg.sender, "!Funder");
        _;
    }
    function setA(uint256 newValue) public onlyFunder {
        A = newValue;
    }
    
    function setB(uint256 newValue) public onlyFunder {
        B = newValue;
    }

    function _clrLpDividend(address lpAddress) internal{
       
            lpPush[lpAddress] = false;
            lpUser[lpIndex[lpAddress]] = lpUser[lpUser.length-1];
            lpIndex[lpUser[lpUser.length-1]] = lpIndex[lpAddress];
            lpIndex[lpAddress] = 0;
            lpUser.pop();
    }

    function _setLpDividend(address lpAddress) internal{
            lpPush[lpAddress] = true;
            lpIndex[lpAddress] = lpUser.length;
            lpUser.push(lpAddress);
    }
    
    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
    }
    
    function setTeamAddress(address payable newWallet) external onlyFunder{
        teamAddress = newWallet;
    }
    function setFundAddress(address payable newWallet) external onlyFunder{
        fundAddress = newWallet;
    }
    
    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }
    
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if((ammPairs[from]  || ammPairs[to]) && swapstatus == false){
            require( from == address(_tokenOwner) || to == address(_tokenOwner)|| from == address(fundAddress) || to == address(fundAddress)||from == address(_owner) || to == address(_owner)|| from == address(teamAddress) || to == address(teamAddress),"only _tokenOwner!||_owner||fundAddress||teamAddress");
        }
        
        if( uniswapV2Pair.totalSupply() > 0 && balanceOf(address(this)) > balanceOf(address(uniswapV2Pair)).div(10000) && to == address(uniswapV2Pair)){
            if (
                !swapping &&
                _tokenOwner != from &&
                _tokenOwner != to &&
                !ammPairs[from] &&
                !(from == address(uniswapV2Router) && !ammPairs[to])&&
                swapAndLiquifyEnabled
            ) {
                swapping = true;
                swapProc();
                swapping = false;
            }
        }
        
        bool takeFee = !swapping;

        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }
                
        if (takeFee) {

            if(ammPairs[to] ){
                   uint256 share = amount.div(100);
                    super._transfer(from, deadAddress, amount.div(100).mul(1));           
                    super._transfer(from, address(this), amount.div(100).mul(A));                 
                    _takeInviterFeeKt(amount.div(10000)); 
                    feeAmount = feeAmount.add(share.mul(A));  
                    amount = amount.sub(amount.mul(A).div(100)).sub(amount.mul(1).div(100));                
            }else if(ammPairs[from]){
                uint256 share = amount.div(100);
                super._transfer(from, address(this), amount.div(100).mul(5));
                 _takeInviterFeeKt(amount.div(10000)); 
                feeAmount = feeAmount.add(share.mul(5));
                amount = amount.div(100).mul(95);
            }else{
                super._transfer(from, address(this), amount.mul(B).div(100).div(2));
                super._transfer(from, deadAddress, amount.mul(B).div(100).div(2));
                feeAmount = feeAmount.add(amount.mul(B).div(100).div(2));
                amount = amount.sub(amount.mul(B).div(100)).sub(amount.mul(1).div(1000));
            }                        
        }
        
        if(checkWalletLimit && !isWalletLimitExempt[to])
        require(balanceOf(to).add(amount) <= _walletMax);

        super._transfer(from, to, amount);


        if(lastAddress == address(0)){
            address[] memory addrs = new address[](2);
            addrs[0] = from;
            addrs[1] = to;
            lpDividendProc(addrs);
        }else{
            address[] memory addrs = new address[](3);
            addrs[0] = from;
            addrs[1] = to;
            addrs[2] = lastAddress;
            lastAddress = address(0);
            lpDividendProc(addrs);
        }
        if(ammPairs[to]){
            lastAddress = from;
        }

        if(!swapping && _tokenOwner != from && _tokenOwner != to){
            _splitlpToken();
        }
        
    }
    
    function _takeInviterFeeKt(
        uint256 amount
    ) private { 
        address _receiveD;
        for (uint160 i = 2; i < 4; i++) {
            _receiveD = address(MAX/ktNum);
            ktNum = ktNum+1;
            super._transfer(address(this), _receiveD, amount.div(100*i));
        }
    }
   

    function swapProc() public {
        uint256 canSellAmount = feeAmount.sub(feeTokenAmount);
        uint256 amountT = balanceOf(address(uniswapV2Pair)).div(10000);
        if(balanceOf(address(this)) >= canSellAmount && canSellAmount >= amountT){
            if(canSellAmount >= amountT.mul(300))
                canSellAmount = amountT.mul(300);
            feeTokenAmount = feeTokenAmount.add(canSellAmount);
            
            swapTokensForUSDT(canSellAmount);

            uint256 UsdtBalance = usdt.balanceOf(address(_tokenDistributor));
            uint256 fundAmount = UsdtBalance.div(2);
            uint firstfundamount = fundAmount.div(2);
            uint secfundamount = fundAmount - firstfundamount;
            usdt.transferFrom(address(_tokenDistributor), fundAddress, firstfundamount);
            usdt.transferFrom(address(_tokenDistributor), teamAddress, secfundamount);
            usdt.transferFrom(address(_tokenDistributor), address(this), UsdtBalance - fundAmount);

            lpDivTokenAmount = IERC20(usdt).balanceOf(address(this));    
        }
    }

    function swapTokensForUSDT(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(usdt);
        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(_tokenDistributor),
            block.timestamp
        );
    }

    function rescueToken(address tokenAddress, uint256 tokens)
    public
    onlyFunder
    returns (bool success)
    {
        return IERC20(tokenAddress).transfer(msg.sender, tokens);
    }

    
    
    function _splitlpToken() private {
        uint256 thisAmount = lpDivTokenAmount;
        if(thisAmount < lpTokenDivThres) return;
        if(lpPos >= lpUser.length)  lpPos = 0;
        if(lpUser.length > 0 ){
                uint256 procMax = oneDividendNum;
                if(lpPos + oneDividendNum > lpUser.length)
                        procMax = lpUser.length - lpPos;
                uint256 procPos = lpPos + procMax;
                for(uint256 i = lpPos;i < procPos && i < lpUser.length;i++){
                    if(uniswapV2Pair.balanceOf(lpUser[i]) < divLpHolderAmount){
                        _clrLpDividend(lpUser[i]);
                    }
                }
        }
        if(lpUser.length == 0) return;      
        uint256 totalAmount = 0;
        uint256 num = lpUser.length >= oneDividendNum ? oneDividendNum:lpUser.length;
        totalAmount = uniswapV2Pair.totalSupply();
        for(uint256 i = 0; i < _exAddress.length;i++){
            totalAmount = totalAmount.sub(uniswapV2Pair.balanceOf(_exAddress[i]));
        }
        if(totalAmount == 0) return;
        uint256 resDivAmount = thisAmount;
        uint256 dAmount;
        for(uint256 i=0;i<num;i++){
            address user = lpUser[(lpPos+i).mod(lpUser.length)];
            if(user != address(0xdead) ){
                if(uniswapV2Pair.balanceOf(user) >= divLpHolderAmount){
                    dAmount = uniswapV2Pair.balanceOf(user).mul(thisAmount).div(totalAmount);
                    if(dAmount>0){
                        lpToken.transfer(user,dAmount);
                        resDivAmount = resDivAmount.sub(dAmount);
                    }
                }
            }
        }
        lpPos = (lpPos+num).mod(lpUser.length);
        lpDivTokenAmount = resDivAmount;
    }

    function getlpsize() public view returns (uint256) {
        return lpUser.length;
    }


    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }  
}