// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

library TransferHelper {
    function safeTransfer(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
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
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

interface IUniswapRouter {
    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);
}

contract Bank {
    address public owner; // 合约的拥有者
    address public routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // uniswapRouter
    address public usdtAddress = 0x55d398326f99059fF775485246999027B3197955; // usdt
    address public tokenAddress;
    uint256 public baseToken = 1 ether;
    uint256 public basePrice = 1 ether; // 基础价格
    uint256 public tokenPrice = 0; // 代币价格
    uint256 public unlockAmount = 100000 ether; // 每次解锁量
    uint256 public totalUnlockAmount = 7500000 ether; // 总解锁量
    address public dao = 0x9a89814d53453FBf7c7709877d5bcA335071B9D1; // dao
    address public burnAddress = 0x000000000000000000000000000000000000dEaD;

    constructor(address owner_) {
        owner = owner_;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "caller is not the owner");
        _;
    }

    function initalize(address _token) external {
        require(tokenAddress == address(0));
        tokenAddress = _token;
    }

    // 计算兑换价格
    function getSwapPrice(
        uint256 amount,
        address tokenA,
        address tokenB
    ) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = tokenA;
        path[1] = tokenB;
        uint256[] memory amounts = IUniswapRouter(routerAddress).getAmountsOut(
            amount,
            path
        );
        return amounts[1];
    }

    function unlock() external onlyOwner {
        uint256 _price = getSwapPrice(baseToken, tokenAddress, usdtAddress);
        uint256 _priceUint = _price / basePrice; // 去除小数
        require(_priceUint > tokenPrice, "price is too low");

        uint256 _unlockAmount = (_priceUint - tokenPrice) * unlockAmount;
        uint256 totalAmount = IERC20(tokenAddress).balanceOf(address(this));
        if (_unlockAmount > totalAmount) {
            _unlockAmount = totalAmount;
        }
        require(_unlockAmount > 0, "unlock amount error");

        totalUnlockAmount += _unlockAmount;
        tokenPrice = _priceUint;
        TransferHelper.safeTransfer(tokenAddress, dao, _unlockAmount);
    }

    function burn(uint256 _amount) external onlyOwner {
        TransferHelper.safeTransfer(tokenAddress, burnAddress, _amount);
    }

    function setOwner(address _owner) external onlyOwner {
        owner = _owner;
    }

    function setDao(address _dao) external onlyOwner {
        dao = _dao;
    }
}