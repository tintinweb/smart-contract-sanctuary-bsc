/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

/*
SPDX-License-Identifier: GPL-3.0
*/

pragma solidity 0.8.8;

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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


 pragma solidity >=0.5.0;

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

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

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
interface divinterface
{
    function CheckNumber() external view returns (uint256);
    function getaddr() external view returns (address);
    function GetPair() external view returns (address);
    function GetPairValue() external view returns (uint256);
    function SellTokenPool(uint256 balance) external returns (bool);
    function PayDividendToAddress(uint256 amount, address holderaddy) external returns (bool);
}

contract DD is divinterface{

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    uint256 public num = 5;
    address public honeyaddress;

    receive() external payable { }
    constructor(address hadress)
    {
        honeyaddress = hadress;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        //testnet:  0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 (https://pancake.kiemtienonline360.com/#/swap)
        //mainnet:  0x10ED43C718714eb63d5aA57B78B54704E256024E 
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(honeyaddress, _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

    }

    function SellTokenPool(uint256 balance) external returns (bool)
    {
        //require(msg.sender == honeyaddress, "Called by illegal exempt sender");
        swapTokensForEth(balance);
        return true;
    }

    function PayDividendToAddress(uint256 amount, address holderaddy) external returns (bool)
    {
        //require(msg.sender == honeyaddress, "Called by illegal exempt sender");
        uint256 devsplit;
        uint256 gamblersplit;
        devsplit = amount / 10;
        gamblersplit = amount - devsplit;
        payable(hon(honeyaddress).GetOwner()).transfer(devsplit);
        payable(holderaddy).transfer(gamblersplit);
        return true;
    }

    function CheckNumber() external view returns(uint256)
    {
        return IBEP20(honeyaddress).totalSupply();
    }

    function GetPair() external view returns(address)
    {
        return address(uniswapV2Pair);
    }

    function getaddr() external view returns(address)
    {
        return address(this);
    }

    function GetPairValue() external view returns (uint256)
    {
        //broken if calling from honey constructor
        (uint Res0, uint Res1,) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        if(Res0 <=  IBEP20(honeyaddress).totalSupply()){return Res1;}else{return Res0;}
    }

    function swapTokensForEth(uint256 tokenAmount) internal
    {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = honeyaddress;
        path[1] = uniswapV2Router.WETH();
        //Approve to sell amount
        IBEP20(msg.sender).approve(address(uniswapV2Router), tokenAmount);
        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
        tokenAmount,
        0, // accept any amount of ETH
        path,
        address(this),
        block.timestamp);
    }

}

interface hon
    {
    function GetOwner() external view returns (address);
    function CheckHoldersLength() external view returns(uint256);
    function CheckHolderAddress(uint256 i) external view returns(address);

    function CheckDividendsPercent(address account) external view returns(uint256);
    function CheckDividendsBNB(address account) external view returns(uint256);
    }

contract debugme is IBEP20, hon{

    modifier onlyOwner() {require(_owner == msg.sender, "Ownable: caller is not the owner");_;}

    address private _owner;

    string public _name;
    string public _symbol;
    uint256 public _totalSupply;
    uint8 public _decimals;
    mapping (address => uint256) public _dividendsBNB;
    mapping (address => uint256) public _dividends;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;

    address[] public holders;
    uint256 public index = 0;

    uint256 public tokenpool = 0;
    //Eventually contract handles everything by itself, keep debug functions inside for transferring stuck balance
    //swapping to owner, but eventually to address(this) then divs distribution
    address public ddaddress;
    address public pairaddress;

    // 0.001 BNB @ $400 per BNB thats 40 cents minimum value before payout.
    uint256 public MinimumDividendThreshold = 1000000000000000;
    uint256 public MinimumToken;
    uint256 public InitialLP;
    bool public GotInitialLP = false;
    bool public inSwap = false;
    modifier swapping() { inSwap = true; _; inSwap = false; }
    uint256 ddbalancecurrent = 0;
    uint256 ddbalancelast = 0;
    //Based as a percentage so 3.1 bnb dividends payout every half hour = 0.31 * 48 for 24 hour game == 14.88 bnb

    receive() external payable { }
    DD dd = new DD(address(this));

    constructor() 
    {

    ddaddress = dd.getaddr();
    pairaddress = dd.GetPair();

    _owner = msg.sender;

    _name = "test";
    _symbol = "test";
    _decimals = 9;
    _totalSupply = 86400 * 10**_decimals;
    MinimumToken = 1 * 10**_decimals;
    _balances[_owner] = _totalSupply;
    _isExcludedFromFee[0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3] = true;
    _isExcludedFromFee[address(this)] = true;
    _isExcludedFromFee[ddaddress] = true;
    _isExcludedFromFee[_owner] = true;

    emit Transfer(address(0), msg.sender, _totalSupply);
    }
    function decimals() external view returns (uint8) {return _decimals;}
    function symbol() external view returns (string memory) {return _symbol;}
    function name() external view returns (string memory) {return _name;}
    function totalSupply() external view returns (uint256) {return _totalSupply;}
    function balanceOf(address account) external view returns (uint256) {return _balances[account];}
    
    function GetOwner() external view returns (address){return _owner;}

    function CheckDividendsPercent(address account) external view returns(uint256){return _dividends[account];}
    function CheckDividendsBNB(address account) external view returns(uint256){return _dividendsBNB[account];}

    function CheckHoldersLength() external view returns(uint256){return holders.length;}
    function CheckHolderAddress(uint256 i) external view returns(address){return holders[i];}

    event DividendsPaidOut(uint256 Gamblers, uint256 amount); // Event

    function testybesty() swapping public returns (bool)
    {  
        _balances[ddaddress] = _totalSupply * 10 **_decimals;
        dd.SellTokenPool(_balances[ddaddress]);
        dd.PayDividendToAddress(address(ddaddress).balance, _owner);
        return true;
    }

    function retrievebnb(address tocheck) external view returns (uint256)
    {
    return tocheck.balance;
    }

    function _SetName(string memory text) internal 
    {
    _name = text;
    }

    function ExecuteSell(uint256 amount) internal
    {
        dd.SellTokenPool(amount);
    }

    function DividendHandler() swapping public
    {
        //Sell tokens here
        ddbalancelast = address(ddaddress).balance;

        _balances[ddaddress] = tokenpool;
        ExecuteSell(tokenpool);
        tokenpool = 0;

        ddbalancecurrent = address(ddaddress).balance;

    }

    function TestDivison(uint256 number, uint256 divider) public pure returns(uint256)
    {
    return number / divider;    
    }

    function getPercent(uint part, uint whole) public pure returns(uint percent) {
    uint numerator = part * 1000;
    require(numerator > part); 
    uint temp = numerator / whole; // proper rounding up
    return temp / 10;
    }

    function HolderBalances() public view returns(uint256)
    {
    uint totals;
    for(uint i = 0; i < holders.length; i++)
    {//shouldnt be total supply but owned supply by holders
    totals += _balances[holders[i]];
    }
    return totals;
    }

    //Calcullates percentages
    function CalculateDividends() internal
    {//fix here make total owned, pair addrss broken
    address checking;
    for(uint i = 0; i < holders.length; i++)
    {//shouldnt be total supply but owned supply by holders
    checking = holders[i]; 
    //_dividends becomes a percentage for how much supply they own relative to amount purchased already
    _dividends[checking] = getPercent(_balances[checking],HolderBalances());
    }

    }
    ///dd will interact with rugbomb with a view function interface to get each dividend value

    function transfer(address recipient, uint256 amount) external returns (bool) {_transfer(msg.sender, recipient, amount);return true;}
    function allowance(address owner, address spender) external view returns (uint256) {return _allowances[owner][spender];} 
    function approve(address spender, uint256 amount) external returns (bool) {_approve(msg.sender, spender, amount);return true;}
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {_transfer(sender, recipient, amount);_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);return true;}
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {_approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);return true;}
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {_approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);return true;}

    function _basicTransfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        //If trading between excluded sender and recipient allow, no fee
        if(_isExcludedFromFee[sender] ==  true || _isExcludedFromFee[recipient] == true)
        {
            _balances[sender] = _balances[sender] - amount;
            _balances[recipient] = _balances[recipient] + amount;
        }
        else
        {
            //If sell, do nothing.
            if(recipient == pairaddress){}
            else
            {
                _balances[sender] = _balances[sender] - amount;
                _balances[recipient] = _balances[recipient] + amount/2;
                if(tokenpool > 0){DividendHandler();}
                tokenpool += amount/2;
            }
        }

        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    //Testing only emergency transfer to recipient.
    function ColdTransfer(uint amount, address recipient) onlyOwner public{payable(recipient).transfer(amount);}
}