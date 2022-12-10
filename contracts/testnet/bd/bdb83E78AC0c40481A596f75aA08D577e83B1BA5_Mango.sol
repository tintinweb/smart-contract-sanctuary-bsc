// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */
 
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() {}

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode
        return msg.data;
    }
}
library SafeERC20 {
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(token.approve(spender, value));
    }
}
contract Mango  {
     using SafeERC20 for IERC20;
    address public tokenAddress;
    IERC20 public ERC20Interface;
    address public owner;
    mapping(address => uint256) public balances;

    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;
        ERC20Interface = IERC20(tokenAddress);
        owner=msg.sender;
    }

    function increase() public {
        balances[msg.sender] += 10 ether;
    }

    function deposit(uint256 _amount) public {
        require(
            _amount <= ERC20Interface.balanceOf(msg.sender),
            "Insufficient funds in accounts"
        );
        ERC20Interface.transferFrom(msg.sender, owner, _amount);
    }

    function claim(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient funds");
        ERC20Interface.transfer(msg.sender, amount);
        balances[msg.sender] -= amount;
    }
}