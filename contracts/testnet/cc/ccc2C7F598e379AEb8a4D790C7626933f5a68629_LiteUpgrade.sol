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

contract LiteUpgrade {
    address public daoAddress;
    address public owner;
    uint256 public totalLock;
    uint256 public totalUnlock;

    uint256 public constant tokenDecimals = 18;
    address public immutable tokenAddress;
    address public immutable liteAddress;

    uint256 public upgradePrice = 1e18;
    uint256 public upgradeAmount = 3000000 * 1e18;
    uint256 public totalAmount;

    bool public isUnlock = false;
    uint256 public startUnlockTime;
    uint256 public upgradeStartTime;
    uint256 public upgradeEndTime;

    uint256 public epoch = 86400;
    uint256 public unlockTimes = 1;

    mapping(address => uint256) public lastUnlockAt;
    mapping(address => uint256) public lockBalanceOf;
    mapping(address => uint256) public unlockAmountOf;
    mapping(address => uint256) public avgUnlockAmount;
    event Upgrade(address indexed account, uint256 amount);
    event Unlock(address indexed account, uint256 amount);

    constructor(
        address _new_lite,
        address _lite,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _unlockTime
    ) {
        require(_unlockTime > _endTime, "end time error");
        owner = msg.sender;
        liteAddress = _lite;
        tokenAddress = _new_lite;

        startUnlockTime = _unlockTime;
        upgradeStartTime = _startTime;
        upgradeEndTime = _endTime;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "caller is not the owner");
        _;
    }

    function setOwner(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    function withdrawToken(
        address token,
        address _to,
        uint256 amount
    ) external onlyOwner {
        TransferHelper.safeTransfer(token, _to, amount);
    }

    function setUpgradeAmount(uint256 _amounts) external onlyOwner {
        upgradeAmount = _amounts;
    }

    function setUpgradePrice(uint256 _price) external onlyOwner {
        upgradePrice = _price;
    }

    function setUnlockOpt(uint256 _epoch, uint256 _times) external onlyOwner {
        require(!isUnlock, "start unlock error");
        epoch = _epoch;
        unlockTimes = _times;
    }

    function setUpgradeTime(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _unlockTime
    ) external onlyOwner {
        require(!isUnlock, "start unlock error");
        require(_unlockTime > _endTime, "end time error");
        upgradeStartTime = _startTime;
        upgradeEndTime = _endTime;
        startUnlockTime = _unlockTime;
    }

    function upgrade() external returns (bool) {
        require(block.timestamp > upgradeStartTime, "start time error");
        require(block.timestamp < upgradeEndTime, "closed error");
        uint256 _amount = IERC20(liteAddress).balanceOf(msg.sender);
        require(
            totalAmount + _amount <= upgradeAmount,
            "total amount overflow error"
        );

        TransferHelper.safeTransferFrom(
            liteAddress,
            msg.sender,
            address(this),
            _amount
        );

        totalAmount += _amount;
        totalLock += _amount;
        lockBalanceOf[msg.sender] += _amount;
        emit Upgrade(msg.sender, _amount);
        return true;
    }

    function unlock() external {
        require(block.timestamp > startUnlockTime, "start unlock error");
        require(epoch > 0 && unlockTimes > 0, "unlock option error");
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