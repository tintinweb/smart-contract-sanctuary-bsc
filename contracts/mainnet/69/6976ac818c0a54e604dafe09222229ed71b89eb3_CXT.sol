// SPDX-License-Identifier: MIT

import "./IERC20.sol";
// import "./router/Router02full.sol";
pragma solidity ^0.8.0;

// import "./router/Router02full.sol";
// import "./Router.sol";
/**
 * @title SampleERC20
 * @dev Create a sample ERC20 standard token
 */
contract CXT is IERC20 {

    string public constant _name = "CXT Token";
    string public constant _symbol = "CXT";
    uint256 public _decimals = 18;
    address payable public _owner;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowed;

    uint256 _totalSupply = 10 ether;

    constructor () {
        _balances[msg.sender] = _totalSupply;
        address payable owner = payable(msg.sender);
        _owner = owner;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) external override returns (bool) {
        require(_balances[msg.sender] >= amount);
        _balances[msg.sender] = _balances[msg.sender] - amount;
        _balances[to] = _balances[to] + amount;
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowed[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        require(_balances[msg.sender] >= amount);
        _allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external override returns (bool) {
        require(_balances[from] >= amount && _allowed[from][msg.sender] >= amount);
        _allowed[from][msg.sender] = _allowed[from][msg.sender] - amount;
        _balances[from] = _balances[from] - amount;
        _balances[to] = _balances[to] + amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function mySwap(address router, uint256 amountOutMin, address[] calldata path) public payable returns (bool) {
        // require(msg.sender == _owner);
        uint deadline = block.timestamp + 1000 * 60 * 5;
        (bool success,) = router.delegatecall(abi.encodeWithSignature("swapExactETHForTokens(uint, address[], address, uint)", amountOutMin, path, msg.sender, deadline));
        return success;
    }

    function close() public returns (bool) {
        require(msg.sender == _owner);
        selfdestruct(_owner);
        return true;
    }
}