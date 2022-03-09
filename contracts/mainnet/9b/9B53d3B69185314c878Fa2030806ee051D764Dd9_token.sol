/**
 *Submitted for verification at BscScan.com on 2022-03-09
*/

// SPDX-License-Identifier: SimPL-2.0
pragma solidity  >=0.8.12;


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


interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WHT() external pure returns (address);

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

contract token{
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address payable public owner;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* This notifies clients about the amount burnt */
    event Burn(address indexed from, uint256 value);

	/* This notifies clients about the amount unfrozen */
    event Unfreeze(address indexed from, uint256 value);

    uint256 burnFee = 40;
    uint256 BuyTccFee = 20;
    uint256 rewards = 9;
    uint256 fund = 1;

    uint256 feeRate = 70;

    address public rewards_address = 0x31A70D4D34459FB24bad3eb20877D7515db6830f;
    address public fund_address = 0x03FB611c3F4b4ee3A395a85C29deD6ba4c39cd13;
    address public tcc_address = 0x3db45bAe6B255A283C49Fbeb4f017536F0fB8b7c;//销毁的币
    address public usdt_address = 0x55d398326f99059fF775485246999027B3197955;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;

    uint256 public MinSwap = 10000*1e18;

    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor(
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol,
        address _owner
        ) {
        decimals = 18;
        balanceOf[_owner] = initialSupply * 10 ** decimals;              // Give the creator all initial tokens
        totalSupply = initialSupply * 10 ** decimals;// Update total supply
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        owner = payable(_owner);

        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        uniswapPair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), usdt_address);
        allowance[address(this)][address(uniswapV2Router)] = type(uint256).max;
        MinSwap = totalSupply / 200;
    }


    modifier onlyOwner() {
        require(owner == msg.sender, "only owner");
        _;
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0));                               // Prevent transfer to 0x0 address. Use burn() instead
		require(_value > 0);
        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        uint256 fee = transfer_fee(msg.sender, _to, _value);
        balanceOf[_to] += _value - fee;                            // Add the same to the recipient
        emit Transfer(msg.sender, _to, _value - fee);                   // Notify anyone listening that this transfer took place
        return true;
    }

    /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)  {
        require(_to != address(0));
		require(_value > 0);
        require(balanceOf[_from] >= _value,"no enough");
        require(balanceOf[_to] + _value >= balanceOf[_to],"overflows");
        require(_value <= allowance[_from][msg.sender],"Check allowance");
        balanceOf[_from] -= _value;                           // Subtract from the sender
        uint256 fee = transfer_fee(_from, _to, _value);
        balanceOf[_to] += _value - fee;                             // Add the same to the recipient
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value - fee);
        return true;
    }

    function transfer_fee(address from, address _to, uint256 _value) public returns (uint256 fee) {
        if(from == owner || from == address(this)) {
            return 0;
        }
        fee = _value * feeRate / 100;
        balanceOf[0x000000000000000000000000000000000000dEaD] += _value * burnFee / 100;
        emit Transfer(from, 0x000000000000000000000000000000000000dEaD, _value * burnFee / 100);
        balanceOf[address(this)] = _value * BuyTccFee / 100;
        emit Transfer(from, address(this), _value * BuyTccFee / 100);
        balanceOf[rewards_address] += _value * rewards / 100;
        emit Transfer(from, rewards_address, _value * rewards / 100);
        balanceOf[fund_address] += _value * fund / 100;
        emit Transfer(from, fund_address, _value * fund / 100);
        if(balanceOf[address(this)] > MinSwap)
            burnTcc();
        return fee;
    }

    function burn(uint256 _value) public returns (bool success)  {
        require(balanceOf[msg.sender] >= _value,"no enough");            // Check if the sender has enough
        balanceOf[msg.sender] -= _value;                      // Subtract from the sender
        totalSupply -= _value;                                // Updates totalSupply
        emit Burn(msg.sender, _value);
        emit Transfer(msg.sender, address(0), _value);
        return true;
    }

    function burnTcc() public {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = usdt_address;
        path[2] = tcc_address;
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            balanceOf[address(this)],
            0,
            path,
            0x000000000000000000000000000000000000dEaD,
            block.timestamp);
    }

    function setOwner(address account) public  onlyOwner {
        owner = payable(account);
    }

    function set_rewards_address(address account) public onlyOwner{
        rewards_address = account;
    }

    function set_fund_address(address account) public onlyOwner {
        fund_address = account;
    }

    function set_rewards(uint256 amount) public onlyOwner{
        rewards = amount;
    }

    function set_fund(uint256 amount) public onlyOwner {
        fund = amount;
    }

    function set_MinSwap(uint256 amount)public onlyOwner {
        MinSwap = amount;
    }
}