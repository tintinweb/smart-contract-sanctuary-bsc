// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.13;

interface IUSD {
    function owner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);
}

library TransferHelper {
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
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

contract LusdMarket {
    address public constant usdtAddress =
        0x55d398326f99059fF775485246999027B3197955;
    address public constant lusdAddress =
        0x1F20F26a747916FaB87C1Fe342fa4FA787f2B2BF;

    mapping(address => uint256) public userAmount;

    constructor() {}

    modifier onlyOwner() {
        require(
            msg.sender == IUSD(lusdAddress).owner(),
            "caller is not the owner"
        );
        _;
    }

    function buy(uint256 buy_amount) public {
        TransferHelper.safeTransferFrom(
            usdtAddress,
            msg.sender,
            address(this),
            buy_amount
        );
        TransferHelper.safeTransfer(lusdAddress, msg.sender, buy_amount);
        userAmount[msg.sender] += buy_amount;
    }

    function sell(uint256 sell_amount) public {
        require(userAmount[msg.sender] > sell_amount, "buy_lusd_amount");
        uint256 before_balance = IUSD(lusdAddress).balanceOf(address(this));
        TransferHelper.safeTransferFrom(
            lusdAddress,
            msg.sender,
            address(this),
            sell_amount
        );
        uint256 after_balance = IUSD(lusdAddress).balanceOf(address(this));
        uint256 add_balance = after_balance - before_balance;
        TransferHelper.safeTransfer(usdtAddress, msg.sender, add_balance);
        userAmount[msg.sender] -= sell_amount;
    }

    function withdrawToken(
        address token,
        address _to,
        uint256 amount
    ) external onlyOwner {
        TransferHelper.safeTransfer(token, _to, amount);
    }
}