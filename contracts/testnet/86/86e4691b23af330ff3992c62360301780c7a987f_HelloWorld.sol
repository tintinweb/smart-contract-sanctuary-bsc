/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

// SPDX-License-Identifier: MIT
// pragma solidity ^0.8.4;
pragma solidity 0.8.17;

contract HelloWorld {
    // 类型 可见性 变量名
    string public public_str = "Hello World!";
    uint256 private private_uint = 1;
    address public owner;
    uint256 constant PRICE = 100;

    constructor() {
        owner = msg.sender;
    }

    modifier OnlyOwner() {
        // msg 是evm 注入的全局信息
        // msg.sender 是交易发起人
        require(owner == msg.sender, "only owner can do!");
        _;
    }

    event Transfer(address from, address to, uint256 value);

    // 存储 key value
    mapping(address => uint256) public balances;

    function setBalance(address user, uint256 value) public OnlyOwner {
        balances[user] = value;
    }

    function transfer(address to, uint256 value) public {
        require(balances[msg.sender] >= value, "sender balance not enough!");
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
    }

    // payalbe表示方法可以接收ETH
    function buy() public payable {
        // msg.value 是用户发送的ETH
        require(msg.value > 0, "value invalid");
        balances[msg.sender] += msg.value * PRICE;
    }

    function refund(uint256 value) public {
        require(value > 0, "value invalid");
        require(balances[msg.sender] >= value, "sender balance not enough!");
        balances[msg.sender] -= value;
        // 合约内部 tranfer ETH
        payable(msg.sender).transfer(value / PRICE);
    }

    function sendAnyNFT(
        address to,
        address nft,
        uint256 tokenId
    ) public {
        // IERC721(nft).transferFrom(address(this), to, tokenId);
        nft.call(
            abi.encodeWithSignature(
                "transferFrom(address,address,uint256)",
                address(this),
                to,
                tokenId
            )
        );
    }

    receive() external payable {} //— for empty calldata (and any value)

    fallback() external payable {}
}