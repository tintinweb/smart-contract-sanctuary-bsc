//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "./SafeERC20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./ReentrancyGuard.sol";

contract Staking is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    struct PoolInfo {
        uint256 depositFee;
        uint256 withdrawFee;
        uint256 totalStaked;
        uint256 locktime;
        uint256 apr;
    }
    struct Lock {
        uint256 amount;
        uint256 locktime;
        uint256 endlocktime;
    }

    mapping(uint256 => mapping(address => Lock[])) public locks;
    address public token;
    address public feeWallet;

    mapping(uint256 => PoolInfo) public pools;

    constructor(address _token, address _feeWallet) {
        pools[0].apr = 250;
        pools[1].apr = 300;
        pools[2].apr = 500;

        pools[0].locktime = 1 seconds;
        pools[1].locktime = 2 seconds;
        pools[2].locktime = 3 seconds;

        pools[0].depositFee = 5;
        pools[1].depositFee = 10;
        pools[2].depositFee = 20;

        pools[0].withdrawFee = 5;
        pools[1].withdrawFee = 10;
        pools[2].withdrawFee = 20;

        token = _token;
        feeWallet = _feeWallet;
    }

    function deposit(uint256 _lockid, uint256 _amount) public {
        require(_lockid < 3, " Staking : Unavaliable Lock");
        require(
            IERC20(token).balanceOf(msg.sender) >= _amount,
            "Staking : Not enough balance"
        );

        uint256 beforeBalance = IERC20(token).balanceOf(address(this));
        IERC20(token).transferFrom(msg.sender, address(this), _amount);
        uint256 afterBalance = IERC20(token).balanceOf(address(this));
        uint256 amount = afterBalance - beforeBalance;
        uint256 feeAmount = amount.mul(pools[_lockid].depositFee).div(1000);
        IERC20(token).transfer(feeWallet, feeAmount);
        uint256 locklength = locks[_lockid][msg.sender].length;
        locks[_lockid][msg.sender].push();
        Lock storage _lock = locks[_lockid][msg.sender][locklength];
        _lock.amount = amount.sub(feeAmount);
        _lock.locktime = block.timestamp;
        _lock.endlocktime = block.timestamp + pools[_lockid].locktime;
        pools[_lockid].totalStaked = pools[_lockid].totalStaked.add(
            amount.sub(feeAmount)
        );
    }

    function withdrawableAmount(uint256 _lockid, address account)
        public
        view
        returns (uint256, uint256)
    {
        uint256 _stakedAmount = 0;
        uint256 _withdrawable = 0;
        for (uint256 i = 0; i < locks[_lockid][account].length; i++) {
            Lock storage _lock = locks[_lockid][account][i];
            if (block.timestamp >= _lock.endlocktime)
                _withdrawable = _withdrawable.add(_lock.amount);
            _stakedAmount = _stakedAmount.add(_lock.amount);
        }
        return (_stakedAmount, _withdrawable);
    }

    function pendingReward(uint256 _lockid, address account)
        public
        view
        returns (uint256, uint256)
    {
        uint256 _claimable = 0;
        uint256 _pending = 0;
        PoolInfo storage pool = pools[_lockid];
        for (uint256 i = 0; i < locks[_lockid][account].length; i++) {
            Lock storage _lock = locks[_lockid][account][i];
            if (block.timestamp >= _lock.endlocktime)
                _claimable = _claimable.add(
                    _lock
                        .amount
                        .mul(pool.apr)
                        .mul(block.timestamp - _lock.locktime)
                        .div(pool.locktime)
                        .div(100)
                );
            _pending = _pending.add(
                _lock
                    .amount
                    .mul(pool.apr)
                    .mul(block.timestamp - _lock.locktime)
                    .div(pool.locktime)
                    .div(100)
            );
        }
        return (_pending, _claimable);
    }

    function withdraw(uint256 _lockid, uint256 _amount) public {
        uint256 _stakedAmount;
        uint256 _withdrawable;
        PoolInfo storage pool = pools[_lockid];

        (_stakedAmount, _withdrawable) = withdrawableAmount(
            _lockid,
            msg.sender
        );
        require(
            _withdrawable >= _amount,
            "Staking : Not Enough Withdraw Amount"
        );
        uint256 feeAmount = _amount.mul(pools[_lockid].withdrawFee).div(100);
        uint256 tamount = _amount - feeAmount;
        uint256 amount = _amount;
        uint256 _pending = 0;
        for (uint256 i = 0; i < locks[_lockid][msg.sender].length; i++) {
            Lock storage _lock = locks[_lockid][msg.sender][i];
            if (block.timestamp >= _lock.endlocktime) {
                _pending = _pending.add(
                    _lock
                        .amount
                        .mul(pool.apr)
                        .mul(block.timestamp - _lock.locktime)
                        .div(pool.locktime)
                        .div(100)
                );
                _lock.locktime = block.timestamp;
                if (amount >= _lock.amount) {
                    _lock.amount = 0;
                    amount = amount.sub(_lock.amount);
                } else {
                    _lock.amount = _lock.amount.sub(amount);
                    amount = 0;
                    break;
                }
            }
        }

        IERC20(token).transfer(feeWallet, feeAmount);
        IERC20(token).transfer(msg.sender, tamount + _pending);

        pools[_lockid].totalStaked = pools[_lockid].totalStaked.sub(_amount);
    }

    function claim(uint256 _lockid) public {
        uint256 _pending = 0;
        PoolInfo storage pool = pools[_lockid];
        for (uint256 i = 0; i < locks[_lockid][msg.sender].length; i++) {
            Lock storage _lock = locks[_lockid][msg.sender][i];
            if (block.timestamp >= _lock.endlocktime) {
                _pending = _pending.add(
                    _lock
                        .amount
                        .mul(pool.apr)
                        .mul(block.timestamp - _lock.locktime)
                        .div(pool.locktime)
                        .div(100)
                );
                _lock.locktime = block.timestamp;
            }
        }
        require(_pending > 0, "There is no amount to claim");
        IERC20(token).transfer(msg.sender, _pending);
    }

    function setAPR(uint256 _lockid, uint256 _percent) external onlyOwner {
        pools[_lockid].apr = _percent;
    }

    function setDepositFee(uint256 _lockid, uint256 _fee) external onlyOwner {
        pools[_lockid].depositFee = _fee;
    }

    function setWithdrawFee(uint256 _lockid, uint256 _fee) external onlyOwner {
        pools[_lockid].withdrawFee = _fee;
    }

    function setFeeWallet(address _newAddress) external onlyOwner {
        feeWallet = _newAddress;
    }

    function removeStuckToken() external onlyOwner {
        IERC20(token).transfer(owner(), IERC20(token).balanceOf(address(this)));
    }
}