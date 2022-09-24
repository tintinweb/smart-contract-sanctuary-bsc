// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./Common.sol";
import "./Param.sol";
import "./IERC20.sol";
import "./SwapInterface.sol";

contract Ecoin is IERC20, Ownable, Param {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    string public name = "Ecoin";
    string public symbol = "Ecoin";
    uint256 public decimals = 18;

    uint256 public totalSupply;

    IUniswapV2Router02 public uniswapV2Router = IUniswapV2Router02(uniswapV2RouterAddress);
    address public uniswapV2PairUSDT;
    address public uniswapV2PairBNB;

    uint8 private fundRate = 40;
    address private fundAddress;
    mapping(address => bool) private excluded;

    constructor(address _fundAddress) {
        _mint(owner(),  200000000 * (10 ** decimals));

        uniswapV2PairBNB = IUniswapV2Factory(uniswapV2Router.factory())
        .createPair(address(this), uniswapV2Router.WETH());
        uniswapV2PairUSDT = IUniswapV2Factory(uniswapV2Router.factory())
        .createPair(address(this), usdt);

        fundAddress = _fundAddress;
        excluded[owner()] = true;
        excluded[fundAddress] = true;
    }

    receive() external payable {}

    function setFundAddress(address _fundAddress) public onlyOwner {
        require(fundAddress != _fundAddress, "OKDao: same address");
        fundAddress = _fundAddress;
    }

    function transBNB(address payable addr, uint256 amount) public onlyOwner {
        require(addr != address(0), "OKDao: address is 0");
        require(amount > 0, "OKDao: amount equal to 0");
        require(amount <= address(this).balance, "OKDao: insufficient balance");
        addr.transfer(amount);
    }

    function transToken(address token, address addr, uint256 amount) public onlyOwner {
        require(addr != address(0), "OKDao: address is 0");
        require(amount > 0, "OKDao: amount equal to 0");
        require(amount <= IERC20(token).balanceOf(address(this)), "OKDao: insufficient balance");
        Address.functionCall(token, abi.encodeWithSelector(0xa9059cbb, addr, amount));
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "OKDao: transfer from the zero address");
        require(to != address(0), "OKDao: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "OKDao: transfer amount exceeds balance");

        _balances[from] = fromBalance - amount;

        uint256 finalAmount = _fee(from, to, amount);

        _balances[to] += finalAmount;

        emit Transfer(from, to, finalAmount);
    }

    function _mint(address account, uint256 amount) private {
        require(account != address(0), "OKDao: mint to the zero address");

        totalSupply += amount;
        _balances[account] += amount;

        emit Transfer(address(0), account, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "OKDao: approve from the zero address");
        require(spender != address(0), "OKDao: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) private {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "OKDao: insufficient allowance");

            _approve(owner, spender, currentAllowance - amount);
        }
    }

    function _fee(address from, address to, uint256 amount) private returns (uint256 finalAmount) {
        if (to == address(uniswapV2PairUSDT)) {
            address addr = (from == address(uniswapV2PairUSDT)) ? to : from;
            if (excluded[addr]) {
                finalAmount = amount;
            } else {
                finalAmount = _countFee(from, amount);
            }
        } else {
            finalAmount = amount;
        }
    }

    function _countFee(address from, uint256 amount) private returns (uint256 finalAmount) {
        uint256 fundFee = amount * fundRate / 1000;

        finalAmount = amount - fundFee;

        if (fundFee > 0) {
            _addBalance(from, fundAddress, fundFee);
        }
    }

    function _addBalance(address from, address to, uint256 amount) private {
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }
}