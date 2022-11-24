/**
 *Submitted for verification at BscScan.com on 2022-11-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract DexRouterV2Tool {

    address public immutable owner;

    event Withdraw(uint256 amount);
    event Diposit(address addr, uint256 amount);

    // 创建合约实例的时候调用
    constructor() {
        owner = msg.sender;
    }

    fallback() external payable {
        deposit();
    }

    receive() external payable {
        deposit();
    }

    function withdraw(uint256 amount) external {
        require(msg.sender == owner, "Not owner address");
        uint256 balance = address(this).balance;
        require(balance < amount, "The amount withdrawn is too large");
        payable(msg.sender).transfer(amount);
        emit Withdraw(amount);
    }

    function deposit() public payable {
        if(msg.value > 0) {
            emit Diposit(msg.sender, msg.value);
        }
    }

    function getBalance() external view returns(uint256) {
        return address(this).balance;
    }

    function callSwap(uint amountIn, uint amountOutMin, address[] calldata path, uint deadline) external returns(bytes memory) {
        address router = address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);                         
        bytes memory payload = abi.encodeWithSignature("swapExactETHForTokens(uint256,address[],address,uint256)", amountOutMin, path, address(this), deadline);
        (bool success, bytes memory amounts) = router.call{value: amountIn}(payload);
        if(success) {
            return amounts;
        } else {
            return bytes(hex"00");
            //revert("call RouterSim failed!");
        }
        
    }
}



/**

["WBNB","BUSD"]
["10000000000000000000", "1"]
*/

// contract RouterSim {

//     event Swap(address sender, address to, uint amount, address[] path, uint deadline, uint value);

//     function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts) {
//         require(msg.value > 0, "no eth coins");
//         emit Swap(msg.sender, to, amountOutMin, path, deadline, msg.value);

//         amounts = new uint[](path.length);
//         amounts[0] = msg.value;
//         for (uint i=1; i < path.length; i++) {
//             amounts[i] = i;
//         }
        
//     }

//     function getBalance() public view returns(uint) {
//         return address(this).balance;
//     }
// }