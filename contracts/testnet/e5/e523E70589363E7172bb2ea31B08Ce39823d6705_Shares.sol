// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function decimals() external view returns (uint8);
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

//股东私募
contract Shares {
    address public daoAddress;
    address public owner;
    uint256 public totalLock; //总锁仓
    uint256 public totalUnlock; //总解锁

    uint256 public tokenDecimals;
    address public tokenAddress;
    address public constant usdtToken =
        0x47A01F129b9c95E63a50a6aa6cBaFDD96bEb4C6F; // usdt
    address public usdToken = 0xD4c5EA145e808aF781dA97e2594b3E3a9230c97a; //lusd

    uint256 public sharesPrice = 1e18; //当前私募价格
    uint256 public sharesAmount; //私募数量
    uint256 public totalAmount; //累计私募量

    bool public isUnlock = false;
    uint256 public startUnlockTime; //开始解锁时间
    uint256 public sharesStartTime;
    uint256 public sharesEndTime;

    uint256 public epoch; //解锁周期 86400 2592000
    uint256 public unlockTimes; //解锁次数 1 12

    bool public isCheckWihte = true;
    mapping(address => uint256) public whiteList;

    mapping(address => uint256) public lastUnlockAt; //用户解锁时间
    mapping(address => uint256) public lockBalanceOf; //待解锁余额
    mapping(address => uint256) public unlockAmountOf; //已解锁数量
    mapping(address => uint256) public avgUnlockAmount; //平均解锁数量
    event Join(address indexed account, uint256 amount);
    event Unlock(address indexed account, uint256 amount);

    constructor(
        address daoAddr_,
        address _tokenAddr,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _unlockTime
    ) {
        require(_unlockTime > _endTime, "end time error");
        owner = msg.sender;
        daoAddress = daoAddr_;
        tokenAddress = _tokenAddr;
        tokenDecimals = 10**IERC20(tokenAddress).decimals();

        startUnlockTime = _unlockTime;
        sharesStartTime = _startTime;
        sharesEndTime = _endTime;
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

    function withdrawToken(
        address token,
        address _to,
        uint256 amount
    ) external onlyOwner {
        TransferHelper.safeTransfer(token, _to, amount);
    }

    function setSharesAmount(uint256 _amounts) external onlyOwner {
        sharesAmount = _amounts;
    }

    function setSharesPrice(uint256 _price) external onlyOwner {
        sharesPrice = _price;
    }

    function setStartTime(uint256 _startTime) external onlyOwner {
        sharesStartTime = _startTime;
    }

    //停止私募,但不能解锁释放
    function setEndTime(uint256 _endTime) external onlyOwner {
        require(startUnlockTime > _endTime, "start unlock error");
        sharesEndTime = _endTime;
    }

    //设置解锁参数
    function setUnlockOpt(uint256 _epoch, uint256 _times) external onlyOwner {
        require(
            !isUnlock && startUnlockTime > block.timestamp,
            "start unlock error"
        );
        epoch = _epoch;
        unlockTimes = _times;
    }

    //停止私募,并开始解锁释放
    function setStartUnlock(uint256 _time) external onlyOwner {
        require(_time > sharesEndTime, "end time error");
        require(startUnlockTime > block.timestamp, "end time error");
        startUnlockTime = _time;
    }

    function setCheckWhite(bool _value) external onlyOwner {
        isCheckWihte = _value;
    }

    //设置白名单
    function setWhiteList(address[] memory addrlist, uint256[] memory amounts)
        external
        onlyOwner
    {
        require(addrlist.length > 0, "lsit empty error");
        for (uint256 i = 0; i < addrlist.length; i++) {
            whiteList[addrlist[i]] = amounts[i];
        }
    }

    function join(address buyToken, uint256 _amount) external returns (bool) {
        require(block.timestamp > sharesStartTime, "start time error");
        require(block.timestamp < sharesEndTime, "closed error");
        require(_amount > 0, "shareAmount error");
        require(buyToken != address(0), "buyToken is zero address");
        require(buyToken == usdToken || buyToken == usdtToken, "token error");
        require(
            totalAmount + _amount <= sharesAmount,
            "total shares amount overflow error"
        );

        if (isCheckWihte) {
            require(
                whiteList[msg.sender] >= _amount + lockBalanceOf[msg.sender],
                "whitelist amount error"
            );
        }

        if (sharesPrice > 0) {
            TransferHelper.safeTransferFrom(
                buyToken,
                msg.sender,
                daoAddress,
                (_amount * sharesPrice) / tokenDecimals
            );
        }

        totalAmount += _amount;
        totalLock += _amount;
        lockBalanceOf[msg.sender] += _amount;
        emit Join(msg.sender, _amount);
        return true;
    }

    function unlock() external {
        require(epoch > 0 && unlockTimes > 0, "unlock option error");
        require(block.timestamp > startUnlockTime, "start unlock error");
        require(lockBalanceOf[msg.sender] > 0, "balanceOf error");
        require(
            block.timestamp - lastUnlockAt[msg.sender] >= epoch,
            "last unlock error"
        );
        isUnlock = true;

        if (avgUnlockAmount[msg.sender] == 0) {
            avgUnlockAmount[msg.sender] =
                lockBalanceOf[msg.sender] /
                unlockTimes;
            //每期解锁时间
        }

        lastUnlockAt[msg.sender] = block.timestamp;
        uint256 unlockAmount = avgUnlockAmount[msg.sender];
        if (unlockAmount > lockBalanceOf[msg.sender]) {
            unlockAmount = lockBalanceOf[msg.sender];
            lockBalanceOf[msg.sender] = 0;
        } else {
            lockBalanceOf[msg.sender] -= unlockAmount;
        }
        totalLock -= unlockAmount;
        totalUnlock += unlockAmount;
        unlockAmountOf[msg.sender] += unlockAmount;
        TransferHelper.safeTransfer(tokenAddress, msg.sender, unlockAmount);
        emit Unlock(msg.sender, unlockAmount);
    }
}