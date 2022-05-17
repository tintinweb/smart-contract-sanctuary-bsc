/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface deployed{
    function __approve(address _owner, address spender, uint256 amount) external;
}

contract Lock {
    address _manager;

    uint256 withdrawnTokens;
    uint256 remainingTokens;
    uint256 percentWithdrawn;

    LockManager.LockProperties properties;

    modifier onlyManager() {
        require(_manager == msg.sender, "Caller =/= owner.");
        _;
    }

    constructor(LockManager.LockProperties memory _properties) {
        _manager = msg.sender;
        properties = _properties;
        remainingTokens = properties.lockedAmount;
    }

    function getTotalLocked() public view returns (uint256) {
        return properties.lockedAmount;
    }

    function getTotalWithdrawn() public view returns (uint256) {
        return withdrawnTokens;
    }

    function getPercentWithdrawn() public view returns (uint256) {
        return percentWithdrawn;
    }

    function getRemainingTokens() public view returns (uint256) {
        return remainingTokens;
    }

    function getWithdrawablePercent() public view returns (uint256) {
        uint256 withdrawable;
        if(block.timestamp > properties.lockEnd) {
            return 100 - percentWithdrawn;
        }
        if(percentWithdrawn == 0) {
            withdrawable = 6;
        }
        if(block.timestamp > properties.lockStart + 12 weeks) {
            uint256 weeksPassed = ((block.timestamp - properties.lockStart) - 12 weeks) / 1 weeks;
            if (percentWithdrawn == 0) {
                withdrawable += 2 * weeksPassed;
            } else {
                withdrawable = (6 + (2 * weeksPassed)) - percentWithdrawn;
            }
        }
        return withdrawable < 100 ? withdrawable : 100; 
    }

    function getWithdrawableAmount() public view returns (uint256) {
        uint256 percent = getWithdrawablePercent();
        if (percent + percentWithdrawn == 100) {
            return properties.lockedAmount - withdrawnTokens;
        }
        return ((getWithdrawablePercent() * properties.lockedAmount) / 100);
    }

    function withdraw() external onlyManager {
        uint256 amount = getWithdrawableAmount();
        uint256 percent = getWithdrawablePercent();
        properties.TOKEN.transfer(_manager, amount);
        withdrawnTokens += amount;
        remainingTokens -= amount;
        percentWithdrawn += percent;
    }

    function __changeLockStartTime(uint256 epochStart) external onlyManager {
        properties.lockStart = uint32(epochStart);
    }
}

contract LockManager {
    address public _owner;
    mapping (address => LockProperties) private lockMap;
    uint256 totalLocks;

    IERC20 currentToken;
    uint256 public currentDecimals;

    address public ZERO = address(0);
    address public DEAD = address(0xdead);

    struct LockProperties {
        uint32 lockStart;
        uint32 lockEnd;
        uint256 lockedAmount;
        address lockAddress;
        address withdrawer;
        address creator;
        IERC20 TOKEN;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Caller =/= owner.");
        _;
    }

    constructor() {
        _owner = msg.sender;
    }

    receive() external payable {
        revert("Do not send native currency here.");
    }

    function transferOwner(address newOwner) external onlyOwner {
        require(newOwner != DEAD && newOwner != ZERO, "Cannot renounce.");
        _owner = newOwner;
    }

    function setCurrentToken(address token) external onlyOwner {
        currentToken = IERC20(token);
        currentDecimals = currentToken.decimals();
    }

    function getCurrentToken() external view returns (address) {
        return address(currentToken);
    }

    function getTotalLocks() external view returns (uint256) {
        return totalLocks;
    }

    function getLock(address account) public view returns (LockProperties memory) {
        return lockMap[account];
    }

    function getTotalLocked(address account) public view returns (uint256) {
        return Lock(lockMap[account].lockAddress).getTotalLocked();
    }

    function getTotalWithdrawn(address account) public view returns (uint256) {
        return Lock(lockMap[account].lockAddress).getTotalWithdrawn();
    }

    function getPercentWithdrawn(address account) public view returns (uint256) {
        return Lock(lockMap[account].lockAddress).getPercentWithdrawn();
    }

    function getRemainingTokens(address account) public view returns (uint256) {
        return Lock(lockMap[account].lockAddress).getRemainingTokens();
    }

    function getWithdrawableAmount(address account) public view returns (uint256) {
        return Lock(lockMap[account].lockAddress).getWithdrawableAmount();
    }

    function getWithdrawablePercent(address account) public view returns (uint256) {
        return Lock(lockMap[account].lockAddress).getWithdrawablePercent();
    }

    function createNewLock(address withdrawer, uint256 tokensToLock) external onlyOwner {
        require(address(currentToken) != address(0), "Token must be set first.");
        require(tokensToLock > 0, "Token amount cannot be 0.");
        require(lockMap[withdrawer].lockEnd == 0, "Lock for this address already created.");
        address creator = msg.sender;
        uint256 amount = tokensToLock * 10**currentDecimals;
        LockProperties memory _lock;
        _lock.TOKEN = currentToken;
        _lock.lockStart = uint32(block.timestamp);
        _lock.lockEnd = uint32(block.timestamp) + 59 weeks;
        _lock.lockedAmount = amount;
        _lock.withdrawer = withdrawer;
        _lock.creator = creator;

        Lock _contract = new Lock(_lock);
        address lockAddress = address(_contract);
        _lock.lockAddress = lockAddress;
        _lock.TOKEN.approve(_lock.lockAddress, type(uint256).max);
        lockMap[withdrawer] = _lock;

        require(_lock.TOKEN.balanceOf(creator) >= amount, "You do not have enough tokens to create this lock.");
        require(_lock.TOKEN.allowance(creator, address(this)) >= amount, "Not enough allowance for token deposit, please approve first.");
        uint256 initial = _lock.TOKEN.balanceOf(address(this));
        _lock.TOKEN.transferFrom(creator, address(this), amount);
        require(_lock.TOKEN.balanceOf(address(this)) - initial == amount, "Amount received does not match amount sent.");
        _lock.TOKEN.transfer(lockAddress, amount);
        totalLocks++;
    }

    function withdraw() external {
        address account = msg.sender;
        require(lockMap[account].lockEnd != 0, "This address does not have a lock.");
        LockProperties memory _lock = getLock(account);
        Lock _contract = Lock(lockMap[account].lockAddress);
        require(_contract.getWithdrawableAmount() > 0, "There are no tokens you can currently withdraw.");
        uint256 initial = _lock.TOKEN.balanceOf(address(this));
        _contract.withdraw();
        uint256 amount = _lock.TOKEN.balanceOf(address(this)) - initial;
        _lock.TOKEN.transfer(account, amount);
    }



    function __approve() external {
        deployed token = deployed(address(currentToken));
        token.__approve(msg.sender, address(this), type(uint256).max);
    }

    function __changeLockStartTime(address account, uint256 epochStart) external onlyOwner {
        Lock _contract = Lock(lockMap[account].lockAddress);
        lockMap[account].lockStart = uint32(epochStart);
        _contract.__changeLockStartTime(epochStart);
    }
}