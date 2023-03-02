// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./MetaSpaceToken.sol";

contract MSTIDO is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    uint256 public constant max_sell_mst = 21700000000000000000000000; //310,000,000 X 7% = 21,700,000 MST
    uint256 public constant min_buy = 30000000000000000000; //30 USDT

    bool public bInit;
    address public mstAddress;
    address public usdtAddress;
    uint256 public mstPrice;
    address public recveiver;

    uint256 public totalUsdtAmount;
    uint256 public totalSoldAmount;

    event mstBought(address account, uint256 usdtAmount, uint256 mstAmount);

    constructor(address _mstAddress, address _usdtAddress, uint256 _mstPrice) {
        mstAddress = _mstAddress;
        usdtAddress = _usdtAddress;
        mstPrice = _mstPrice; // 1000 = 1000/10000 = 0.1  USDT
    }

    function initFund(uint256 mstAmount, address _recveiver) external onlyOwner nonReentrant {
        require(!bInit, "already inited");
        require(max_sell_mst == mstAmount, "Init ERR: max_sell_mst");
        require(_recveiver != owner() && _recveiver != address(0), "ERR: receiver err");
        require(IERC20(mstAddress).balanceOf(msg.sender) >= mstAmount, "ERR: insuff bal");
        require(IERC20(mstAddress).allowance(msg.sender, address(this)) >= mstAmount, "ERR: not approve");
        recveiver = _recveiver;
        require(IERC20(mstAddress).transferFrom(msg.sender, address(this), mstAmount), "Init ERR: transferFrom");
        bInit = true;
    }

    function setReceiver(address _recveiver) external onlyOwner nonReentrant {
        require(_recveiver != owner() && _recveiver != address(0), "ERR: receiver error");
        require(_recveiver != recveiver, "ERR: the same");
        recveiver = _recveiver;
    }

    function buyMST(uint256 usdtAmount) external nonReentrant {
        require(bInit, "Err: not inited");
        require(address(0) != msg.sender, "ERR: ZERO addr");
        require(owner() != msg.sender, "ERR: owner can't buy");
        require(!Address.isContract(msg.sender), "ERR: don't accept from contract");
        require(usdtAmount >= min_buy, "ERR: less than minimum");
        require(IERC20(usdtAddress).balanceOf(msg.sender) >= usdtAmount, "ERR: insuff USDT bal");
        require(IERC20(usdtAddress).allowance(msg.sender, address(this)) >= usdtAmount, "ERR: not approve");
        uint256 mstAmount = usdtAmount.mul(10000).div(mstPrice);
        require(mstAmount > 0, "ERR: price");
        require(mstAmount <= max_sell_mst.sub(totalSoldAmount), "ERR: insuff fund 1");
        require(IERC20(mstAddress).balanceOf(address(this)) >= mstAmount, "ERR: insuff fund 2");
        totalUsdtAmount = totalUsdtAmount.add(usdtAmount);
        totalSoldAmount = totalSoldAmount.add(mstAmount);
        require(IERC20(usdtAddress).transferFrom(msg.sender, recveiver, usdtAmount), "ERR: transferFrom");
        uint256 transferedMstAmount = ERC20Base(mstAddress).estimateTransferResult(address(this), msg.sender, mstAmount);
        require(IERC20(mstAddress).transfer(msg.sender, mstAmount), "ERR: transfer mst");
        emit mstBought(msg.sender, usdtAmount, transferedMstAmount);
    }

    function withdrawToken(address token, uint256 amount, address to) external onlyOwner nonReentrant {
        require(IERC20(token).balanceOf(address(this)) >= amount, "ERR: insuff token");
        require(IERC20(token).transfer(to, amount), "ERR: transfer token");
    }
}