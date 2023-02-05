/**
 *Submitted for verification at BscScan.com on 2023-02-04
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @title SampleERC20
 * @dev Create a sample ERC20 standard token
 */

interface Event {
    event Recharge(address indexed from, address from1, uint256 value);
    event Swap(address indexed from, address from1, address indexed token, uint256 valueIn, uint256 valueOut);
    event Cust(address indexed from, address from1, bytes log);
    event QueryEth(address indexed from, address from1, uint256 value);
    event QueryToken(address indexed from, address from1, uint256 value);
}

contract CYT is Event {

    string public constant _name = "CYT Token";
    string public constant _symbol = "CYT";
    address payable public _owner;

    mapping(address => uint256) _balanceseth;
    mapping(address => mapping(address => uint256)) _balancesother;

    constructor () {
        address payable owner = payable(msg.sender);
        _owner = owner;
    }

    function recharge() public payable returns (bool) {
        _balanceseth[msg.sender] = msg.value;
        emit Recharge(msg.sender, msg.sender, msg.value);
        return true;
    }

    function swap(address router, uint256 amountIn, uint256 amountOutMin, address[] calldata path) public returns (bool) {
        require(_balanceseth[msg.sender] > amountIn);
        uint deadline = block.timestamp + 1000 * 60 * 5;
        (bool sent, bytes memory data) = router.call{value: amountIn}(abi.encodeWithSignature("swapExactETHForTokens(uint, address[], address, uint)", amountOutMin, path, msg.sender, deadline));
        emit Cust(msg.sender, msg.sender, data);
        require(sent, "Exchange error");
        _balanceseth[msg.sender] = _balanceseth[msg.sender] - amountIn;
        uint[] memory amounts = abi.decode(data, (uint[]));
        _balancesother[msg.sender][path[1]] = _balancesother[msg.sender][path[1]] + amounts[1];
        emit Swap(msg.sender, msg.sender, path[1], amountIn, amounts[1]);
        return sent;
    }

    function queryETHBalance() public returns (uint256) {
        emit QueryEth(msg.sender, msg.sender, _balanceseth[msg.sender]);
        return _balanceseth[msg.sender];
    }

    function queryTokenBalance(address token) public returns (uint256) {
        emit QueryToken(msg.sender, msg.sender, _balancesother[msg.sender][token]);
        return _balancesother[msg.sender][token];
    }

    function close() public returns (bool) {
        require(msg.sender == _owner);
        selfdestruct(_owner);
        return true;
    }
}