/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

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

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
    external
    returns (bool);
    function allowance(address owner, address spender)
    external
    view
    returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);

 
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);


    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        
        return msg.data;
    }

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
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
   
    mapping(address => uint256) internal _balances;

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

    function balanceOf(address account)
    public
    view
    virtual
    override
    returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
    public
    virtual
    override
    returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
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
        _approve(_msgSender(), spender, amount);
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
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
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
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

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

contract Dph is ERC20 {
    using SafeMath for uint256;
    
    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;
    address private uniswapV2PairBNB;
    address _tokenOwner;
    address public marketAddress = 0xa6E794e3CbAfb5CBAEB9d8671194C99e357e75bF ;
    address private bindAddress = 0x50BCcA20c197DC590EA18C0e575E273A0f858c00 ;
    mapping(address => bool) private _isExcludedFromFees;
    mapping (address => address) public inviter;
    bool private swapping ;
    bool public swapstatus; 
    uint256 public inviteAmount;
    
    uint256 public lpdivdendFee = 6;
    uint256 public marketingFee = 4;
    uint256 public liquidityFee = 4;
    uint256 public deadFee = 3;
    uint256 public inviterFee = 6;

    uint256 public feeAmount = 0;
    uint256 public feeTokenAmount = 0;

    uint256 public lpDivTokenAmount = 0;
    uint256 public lpDivThresAmount = 0;
    uint256 public oneDividendNum = 50;
    uint256 private swapTokensAtAmount = 500*10**18;

    IERC20 public usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);
    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    
    IERC20 public lpDivToken;
    address[] private lpUser;
    address private liquidityReceiver;
    mapping(address => bool) public lpPush;
    mapping(address => uint256) private lpIndex;
    address[] public _exAddress;
    mapping(address => bool) private _bexAddress;
    mapping(address => uint256) private _exIndex;
    mapping(address => bool) public ammPairs;
    address public lastAddress = address(0);
    
    uint256 public AmountDivtokenBonusCurrent;
    uint256 public AmountMarketingCurrent;
    uint256 public AmountLiquidityCurrent;
    uint256 private lpPos = 0;
    uint256 private lpDivTokenDivThres;
    uint256 private divLpHolderAmount;
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived
    );

    constructor() ERC20("Dolphin", "Dph") {
         
        uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        _tokenOwner = address(0x13F3f3A922B439b9E72006C51D070Bae42559C6e);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), address(usdt));
        address _uniswapV2PairBNB = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());     
        
        uniswapV2Pair = _uniswapV2Pair;
        uniswapV2PairBNB =_uniswapV2PairBNB;
        ammPairs[address(uniswapV2Pair)] = true;
        ammPairs[address(uniswapV2PairBNB)] = true;
        _approve(address(this), address(uniswapV2Router), uint256(0));
        
        excludeFromFees(owner(), true);
        excludeFromFees(address(bindAddress), true);
        excludeFromFees(marketAddress, true);
        excludeFromFees(address(this), true);
        excludeFromFees(liquidityReceiver,true);

        lpDivToken = usdt;
        _mint(_tokenOwner, 1000000 * 10**18);
        divLpHolderAmount = 1 * 10**18;
        lpDivTokenDivThres = 100 * 10**18;
        inviteAmount = 10E20*10**18;
    }

    receive() external payable {}
    
    function setSwapStatus(bool status) public onlyOwner {
        swapstatus = status;
    }
    
    function setInviteAmount(uint256 amount) external onlyOwner {
        inviteAmount = amount;
    }

    function setlpDivThres(uint256 _thres) public onlyOwner {
        lpDivTokenDivThres = _thres;
    }

    function setDivLpHolderAmount(uint256 amount) public onlyOwner {
        divLpHolderAmount = amount;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }
    
    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function setLiquidityReceiver(address payable newWallet) external onlyOwner{
        liquidityReceiver = newWallet;
    }
    
    function setmarketAddress(address payable newWallet) external onlyOwner{
        marketAddress = newWallet;
    }
     function setbindAddress(address payable newWallet) external onlyOwner{
        bindAddress = newWallet;
    }
    function setAmmPairs(address pair, bool isPair) public onlyOwner {
        ammPairs[pair] = isPair;
    }

    function lpDividendProc(address[] memory lpAddresses)
        private
    {
        for(uint256 i = 0 ;i< lpAddresses.length;i++){
             if(lpPush[lpAddresses[i]] && (IERC20(uniswapV2Pair).balanceOf(lpAddresses[i]) < divLpHolderAmount||_bexAddress[lpAddresses[i]])){
                _clrLpDividend(lpAddresses[i]);
             }else if(!Address.isContract(lpAddresses[i]) && !lpPush[lpAddresses[i]] && !_bexAddress[lpAddresses[i]]&& IERC20(uniswapV2Pair).balanceOf(lpAddresses[i]) >= divLpHolderAmount){
                _setLpDividend(lpAddresses[i]);
             }
        }
    }

    function setExAddress(address exa) public onlyOwner {
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
        
        if((to == uniswapV2Pair || from == uniswapV2Pair) && swapstatus == false){
            require(from == owner() || to == owner(),"only owner!");
        }
        
        if(to == uniswapV2Pair)
        {
              uint256 balance = balanceOf(from);
              if (amount == balance) {
                amount = amount.sub(amount.div(1000));
            }
            
        }
        
        if( IERC20(uniswapV2Pair).totalSupply() > 0 && balanceOf(address(this)) > balanceOf(address(uniswapV2Pair)).div(10000) && to == address(uniswapV2Pair)){
            if (
                !swapping && _tokenOwner != from && _tokenOwner != to && from != uniswapV2Pair && !(from == address(uniswapV2Router) && to != uniswapV2Pair)) {
                swapping = true;
                }
                if(AmountMarketingCurrent >= swapTokensAtAmount) swapAndSendToFee;
                if(AmountDivtokenBonusCurrent >= swapTokensAtAmount) swapProc;
                if(AmountLiquidityCurrent >= swapTokensAtAmount) swapAndLiquify;
                swapping = false;
            }
       
        bool takeFee = !swapping;
        bool shouldSetInviter = balanceOf(to) == 0 && inviter[to] == address(0) && !Address.isContract(from) && !Address.isContract(to) && inviteAmount <= amount;
      
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }else {
            
            if((from != uniswapV2Pair && to != uniswapV2Pair)){
                takeFee = false;
            
        }
    }   
        
        uint256 finalAmount = amount;

        if(takeFee) {
            uint256 _LiquidityFee;
            uint256 _lpdivdendFee;
            uint256 _MarketingFee;
            uint256 _DeadFee;
            uint256 _InviterFee;

            if(from == uniswapV2Pair){
                _LiquidityFee = amount.mul(liquidityFee).div(1000);
                _MarketingFee = amount.mul(marketingFee).div(1000);
                _DeadFee = amount.mul(deadFee).div(1000);
                _InviterFee  = amount.mul(inviterFee).div(1000);
                _lpdivdendFee = amount.mul(lpdivdendFee).div(1000);
     
               finalAmount = finalAmount.sub(_LiquidityFee).sub(_MarketingFee).sub(_DeadFee).sub(_InviterFee).sub(_lpdivdendFee);
               
            }else if(to == uniswapV2Pair){
                
                _LiquidityFee = amount.mul(liquidityFee).div(1000);
                _lpdivdendFee = amount.mul(lpdivdendFee).div(1000);
                _MarketingFee = amount.mul(marketingFee).div(1000);
                _DeadFee = amount.mul(deadFee).div(1000);
                _InviterFee  = amount.mul(inviterFee).div(1000);
                finalAmount = finalAmount.sub(_LiquidityFee).sub(_lpdivdendFee).sub(_MarketingFee).sub(_InviterFee).sub(_DeadFee);
            }

            if(_LiquidityFee > 0) {
                super._transfer(from, address(this), _LiquidityFee);
                AmountLiquidityCurrent = AmountLiquidityCurrent.add(_MarketingFee);

            }
            if(_MarketingFee > 0) {
                super._transfer(from, address(this), _MarketingFee);
                AmountMarketingCurrent = AmountMarketingCurrent.add(_MarketingFee);
            }
            if(_DeadFee > 0) super._transfer(from, deadWallet, _DeadFee);

            if(_InviterFee > 0) _takeInviterFee(from, to, amount);
                amount = amount.sub(inviterFee);

            if(_lpdivdendFee > 0){
                super._transfer(from, address(this), _lpdivdendFee);
                AmountDivtokenBonusCurrent = AmountDivtokenBonusCurrent.add(_lpdivdendFee);
            }
        }
        
        super._transfer(from, to, finalAmount);
        
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
        if (shouldSetInviter) {
            inviter[to] = from;
        }
        if(!swapping && _tokenOwner != from && _tokenOwner != to){
            _splitlpDivToken();
        }
        
    }
      
    function swapAndSendToFee() private  {
        swapTokensForUSDT(AmountMarketingCurrent); 
        payable(marketAddress).transfer(address(this).balance);
    }
    
    function swapAndLiquify() private {
       // split the contract balance into halves
        uint256 half = AmountLiquidityCurrent.div(2);
        uint256 otherHalf = AmountLiquidityCurrent.sub(half);
        uint256 initialBalance = address(this).balance;
        // swap tokens for ETH
        swapTokensForUSDT(half); // <- this breaks the usdt-> HATE swap when swap+liquify is triggered
        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);
        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
        emit SwapAndLiquify(half, otherHalf);
    }
    
    function addLiquidity(uint256 tokenAmount, uint256 USDTAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: USDTAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            liquidityReceiver,
            block.timestamp
        );
    }
    
    function swapProc() private {

            swapTokensForUSDT(AmountDivtokenBonusCurrent);
            lpDivTokenAmount = IERC20(usdt).balanceOf(address(this)); 
            
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
            address(this),
            block.timestamp
        );
    }

    function _takeInviterFee(address sender, address recipient, uint amount) private {
        address cur = sender;
        if (sender == address(uniswapV2Pair)) {
            cur = recipient;
        }else {
                cur = sender;
            }

        uint8[2] memory inviteRate =  [4, 2];
        for (uint8 i = 0; i < 2; i++) {
            uint8 rate = inviteRate[i];
            cur = inviter[cur];
            if (cur == address(0)) {
                cur = bindAddress;
            }
            uint256 curTAmount = amount * rate / 1000;
            unchecked {
                _balances[sender] =_balances[sender] - curTAmount;
            }
            _balances[cur] += curTAmount;
            emit Transfer(sender, cur, curTAmount);
        }
    }
    
    function _splitlpDivToken() private {
        uint256 thisAmount = lpDivTokenAmount;
        if(thisAmount < lpDivTokenDivThres) return;
        if(lpPos >= lpUser.length)  lpPos = 0;
        if(lpUser.length > 0 ){
                uint256 procMax = oneDividendNum;
                if(lpPos + oneDividendNum > lpUser.length)
                        procMax = lpUser.length - lpPos;
                uint256 procPos = lpPos + procMax;
                for(uint256 i = lpPos;i < procPos && i < lpUser.length;i++){
                    if(IERC20(uniswapV2Pair).balanceOf(lpUser[i]) < divLpHolderAmount){
                        _clrLpDividend(lpUser[i]);
                    }
                }
        }
        if(lpUser.length == 0) return;      
        uint256 totalAmount = 0;
        uint256 num = lpUser.length >= oneDividendNum ? oneDividendNum:lpUser.length;
        totalAmount = IERC20(uniswapV2Pair).totalSupply();
        for(uint256 i = 0; i < _exAddress.length;i++){
            totalAmount = totalAmount.sub(IERC20(uniswapV2Pair).balanceOf(_exAddress[i]));
        }
        if(totalAmount == 0) return;
        uint256 resDivAmount = thisAmount;
        uint256 dAmount;
        for(uint256 i=0;i<num;i++){
            address user = lpUser[(lpPos+i).mod(lpUser.length)];
            if(user != address(0xdead) ){
                if(IERC20(uniswapV2Pair).balanceOf(user) >= divLpHolderAmount){
                    dAmount = IERC20(uniswapV2Pair).balanceOf(user).mul(thisAmount).div(totalAmount);
                    if(dAmount>0){
                        lpDivToken.transfer(user,dAmount);
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

}