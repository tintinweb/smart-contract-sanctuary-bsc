//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;
import "./IERC20.sol";

contract Erc20Test is IERC20 {
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor() {
        _totalSupply = 1000000;
        _balances[msg.sender] = _totalSupply;
    }

    function name() public pure override returns (string memory) {
        return "FakeERC2000";
    }

    function symbol() public pure override returns (string memory) {
        return "FK2";
    }

    function decimals() public pure override returns (uint8) {
        return 16;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address receiver, uint256 amount)
        public
        override
        returns (bool)
    {
        require(amount <= _balances[msg.sender], "loi roi");
        _balances[msg.sender] = _balances[msg.sender] - amount;
        _balances[receiver] = _balances[receiver] + amount;
        emit Transfer(msg.sender, receiver, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address buyer,
        uint256 amount
    ) public override returns (bool) {
        require(amount <= _balances[sender], "xx");
        require(amount <= _allowances[sender][msg.sender], "yy");
        _balances[sender] -= amount;
        _allowances[sender][msg.sender] -= amount;
        _balances[buyer] += amount;
        emit Transfer(sender, buyer, amount);
        return true;
    }

    function allowance(address owner, address delegate)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][delegate];
    }

    function approve(address delegate, uint256 amount)
        public
        override
        returns (bool)
    {
        _allowances[msg.sender][delegate] = amount;
        emit Approval(msg.sender, delegate, amount);
        return true;
    }
}