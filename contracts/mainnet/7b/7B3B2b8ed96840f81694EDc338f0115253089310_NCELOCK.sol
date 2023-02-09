/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library TransferHelper {
    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }
}

interface IUniswapRouter {
    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);
}

contract NCELOCK {
    address public owner;
    address public daoAddress = 0xceB72f4c4D793dD9d54eca2D0cCCad09f0B67E2e;
    uint256 public constant totalLock = 3000000 ether;
    address public constant tokenAddress =
        0xAc9697195B34A6DC59d0c86D9992d9F29C85743A;

    address public constant routerAddress =
        0x10ED43C718714eb63d5aA57B78B54704E256024E; // uniswapRouter
    address public constant usdtAddress =
        0x55d398326f99059fF775485246999027B3197955; // usdt

    uint256 public constant startUnlockPrice = 10 ether;
    uint256 public constant epoch = 1095 days;
    address public constant burnAddress =
        0x000000000000000000000000000000000000dEaD;

    uint256 public constant avgUnlockAmount = totalLock / epoch;
    uint256 public lockBalanceOf = totalLock;
    uint256 public totalUnlock;
    uint256 public startUnlockTime;
    uint256 public lastUnlockAt;

    event Unlock(address indexed account, uint256 amount);
    event StartUnlock(uint256 indexed blocknum);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "caller is not the owner");
        _;
    }

    function setOwner(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    function setDaoAddr(address newAddr) external onlyOwner {
        daoAddress = newAddr;
    }

    function startUnlock() external {
        address[] memory path = new address[](2);
        path[0] = tokenAddress;
        path[1] = usdtAddress;
        uint256[] memory amounts = IUniswapRouter(routerAddress).getAmountsOut(
            1 ether,
            path
        );
        uint256 price = amounts[1];
        require(price >= startUnlockPrice, "price is too low");

        startUnlockTime = block.timestamp;
        lastUnlockAt = startUnlockTime;
        emit StartUnlock(block.number);
    }

    function unlock() external {
        require(startUnlockTime > 0, "start unlock error");
        require(avgUnlockAmount > 0, "unlock amount error");
        require(lockBalanceOf > 0, "balanceOf error");
        require(block.timestamp - lastUnlockAt > 0, "unlock time error");

        uint256 unlockAmount = (block.timestamp - lastUnlockAt) *
            avgUnlockAmount;
        lastUnlockAt = block.timestamp;

        if (unlockAmount > lockBalanceOf) {
            unlockAmount = lockBalanceOf;
            lockBalanceOf = 0;
        } else {
            lockBalanceOf -= unlockAmount;
        }

        totalUnlock += unlockAmount;
        TransferHelper.safeTransfer(tokenAddress, daoAddress, unlockAmount);
        emit Unlock(daoAddress, unlockAmount);
    }

    function burn(uint256 _amount) external onlyOwner {
        TransferHelper.safeTransfer(tokenAddress, burnAddress, _amount);
    }
}