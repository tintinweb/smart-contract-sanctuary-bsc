// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./MetaSpaceToken.sol";

contract MSTIDO is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    uint256 public constant max_sell_mst = 21700000000000000000000000; //310,000,000 X 7% = 21,700,000 MST
    uint256 public constant min_buy = 30000000000000000000; //30 USDT

    bool public bInit;
    bool public bStart;
    address public mstAddress;
    address public usdtAddress;
    uint256 public mstPrice;
    address public recveiver;

    uint256 public totalUsdtAmount;
    uint256 public totalSoldAmount;

    event mstBought(address account_, uint256 usdtAmount_, uint256 mstAmount_);

    constructor(address _mstAddress, address _usdtAddress, uint256 _mstPrice) {
        mstAddress = _mstAddress;
        usdtAddress = _usdtAddress;
        mstPrice = _mstPrice; // 1000 = 1000/10000 = 0.1  USDT
    }

    function initFund(uint256 _mstAmount, address _recveiver) external onlyOwner nonReentrant {
        require(!bInit, "already inited");
        require(!bStart, "err: impossible");
        require(max_sell_mst == _mstAmount, "Init ERR: max_sell_mst");
        require(_recveiver != owner() && _recveiver != address(0), "ERR: receiver err");
        require(IERC20(mstAddress).balanceOf(msg.sender) >= _mstAmount, "ERR: insuff bal");
        require(IERC20(mstAddress).allowance(msg.sender, address(this)) >= _mstAmount, "ERR: not approve");
        recveiver = _recveiver;
        bInit = true;
        require(IERC20(mstAddress).transferFrom(msg.sender, address(this), _mstAmount), "Init ERR: transferFrom");
    }

    function setPrice(uint256 _mstPrice) external onlyOwner nonReentrant {
        require(_mstPrice != mstPrice, "the same");
        mstPrice = _mstPrice;
    }

    function setStart(bool _startFlag) external onlyOwner nonReentrant {
        require(bInit, "Err: can't set start state duo to not inited");
        require(_startFlag != bStart, "the same");
        bStart = _startFlag;
    }

    function setReceiver(address _recveiver) external onlyOwner nonReentrant {
        require(_recveiver != owner() && _recveiver != address(0), "ERR: receiver error");
        require(_recveiver != recveiver, "ERR: the same");
        recveiver = _recveiver;
    }

    function buyMST(uint256 _usdtAmount) external nonReentrant {
        require(bInit, "Err: not inited");
        require(bStart, "Err: not started");
        require(address(0) != msg.sender, "ERR: ZERO addr");
        require(owner() != msg.sender, "ERR: owner can't buy");
        require(!Address.isContract(msg.sender), "ERR: don't accept from contract");
        require(_usdtAmount >= min_buy, "ERR: less than minimum");
        require(IERC20(usdtAddress).balanceOf(msg.sender) >= _usdtAmount, "ERR: insuff USDT bal");
        require(IERC20(usdtAddress).allowance(msg.sender, address(this)) >= _usdtAmount, "ERR: not approve");
        uint256 _mstAmount = _usdtAmount.mul(10000).div(mstPrice);
        require(_mstAmount > 0, "ERR: price");
        require(_mstAmount <= max_sell_mst.sub(totalSoldAmount), "ERR: insuff fund 1");
        require(IERC20(mstAddress).balanceOf(address(this)) >= _mstAmount, "ERR: insuff fund 2");
        totalUsdtAmount = totalUsdtAmount.add(_usdtAmount);
        totalSoldAmount = totalSoldAmount.add(_mstAmount);
        require(IERC20(usdtAddress).transferFrom(msg.sender, recveiver, _usdtAmount), "ERR: transferFrom");
        uint256 transferedMstAmount = ERC20Base(mstAddress).estimateTransferResult(address(this), msg.sender, _mstAmount);
        require(IERC20(mstAddress).transfer(msg.sender, _mstAmount), "ERR: transfer mst");
        emit mstBought(msg.sender, _usdtAmount, transferedMstAmount);
    }

    function withdrawToken(address _token, uint256 _amount, address _to) external onlyOwner nonReentrant {
        require(IERC20(_token).balanceOf(address(this)) >= _amount, "ERR: insuff token");
        require(IERC20(_token).transfer(_to, _amount), "ERR: transfer token");
    }
}