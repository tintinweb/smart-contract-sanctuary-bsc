// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

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

contract usdMarket {
    address public immutable usdtAddress;
    address public immutable usdAddress;

    uint256 public totalBuyAmount;
    uint256 public totalSellAmount;
    mapping(address => uint256) public userBuyAmount;
    mapping(address => uint256) public userSellAmount;

    constructor(address usd_, address usdt_) {
        usdAddress = usd_;
        usdtAddress = usdt_;
    }

    modifier onlyOwner() {
        require(
            msg.sender == IUSD(usdAddress).owner(),
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
        totalBuyAmount += buy_amount;
        userBuyAmount[msg.sender] += buy_amount;
        TransferHelper.safeTransfer(usdAddress, msg.sender, buy_amount);
    }

    function sell(uint256 sell_amount) public {
        uint256 before_balance = IUSD(usdAddress).balanceOf(address(this));
        TransferHelper.safeTransferFrom(
            usdAddress,
            msg.sender,
            address(this),
            sell_amount
        );
        uint256 after_balance = IUSD(usdAddress).balanceOf(address(this));
        uint256 add_balance = after_balance - before_balance;
        totalSellAmount += sell_amount;
        userSellAmount[msg.sender] += sell_amount;
        TransferHelper.safeTransfer(usdtAddress, msg.sender, add_balance);
    }

    function withdrawToken(
        address token,
        address _to,
        uint256 amount
    ) external onlyOwner {
        TransferHelper.safeTransfer(token, _to, amount);
    }
}