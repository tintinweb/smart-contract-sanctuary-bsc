// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IScheduler.sol";
import "./interfaces/ISwap.sol";

contract Staking {
    IERC20 PENX;
    IERC20 PXLT;
    IERC20 USDC;
    ISwap router;
    IScheduler scheduler;
    bool isPaused = true;

    // uint256 secondsInDay = 86400;
    uint256 secondsInDay = 60;

    uint256 public withdrawFee = 500;

    uint256 accumulatedSetFee;

    address[] workerArray;
    mapping(address => WorkerInfo) public workerAddressToInfo;
    struct WorkerInfo {
        uint256 stakedSet;
        uint256 accruedPENX;
        uint256 stakingStart;
    }

    uint256 coefficient = 11000;

    event Withdraw(
        address account,
        uint256 PENX,
        uint256 PXLT,
        uint256 swappedFor,
        bool hasFee
    );

    modifier isNotPaused() {
        require(!isPaused);
        _;
    }

    constructor(
        IERC20 _PENX,
        IERC20 _PXLT,
        IERC20 _USDC,
        IScheduler _scheduler,
        ISwap _router
    ) {
        PENX = _PENX;
        PXLT = _PXLT;
        USDC = _USDC;
        scheduler = _scheduler;
        router = _router;
    }

    function addWorker(address worker, uint256 setAmount)
        internal
        returns (bool isNew)
    {
        WorkerInfo storage info = workerAddressToInfo[worker];
        info.stakedSet += setAmount;
        if (info.stakingStart == 0) {
            info.stakingStart = block.timestamp;
            isNew = true;
        }
    }

    function addSchedules(address[] memory workers, uint256[] memory amounts)
        public
    {
        require(scheduler.isOperator(msg.sender), "Caller is not an operator");
        require(workers.length == amounts.length, "Incorrect arrays length");
        uint256 totalAmount;
        for (uint256 i = 0; i < workers.length; ) {
            if (addWorker(workers[i], amounts[i])) {
                workerArray.push(workers[i]);
            }
            unchecked {
                i++;
            }
        }
        PXLT.transferFrom(msg.sender, address(this), totalAmount);
    }

    function increaseStakes() public {
        require(scheduler.isOperator(msg.sender), "Caller is not an operator");
        for (uint256 i = 0; i < workerArray.length; ) {
            WorkerInfo storage info = workerAddressToInfo[workerArray[i]];
            if (
                info.stakedSet > 0 &&
                scheduler.getWorkerRetirementDate(workerArray[i]) >=
                block.timestamp
            ) {
                uint256 totalSupply = PXLT.totalSupply();
                updateWorkerStake(info, totalSupply);
            }
            unchecked {
                i++;
            }
        }
    }

    function updateWorkerStake(WorkerInfo storage info, uint256 totalSupply)
        internal
    {
        uint256 secondsPassed = block.timestamp - info.stakingStart;
        uint256 leftoverSeconds = secondsPassed % secondsInDay;
        uint256 daysPassedSinceDeposit = (secondsPassed - leftoverSeconds) /
            secondsInDay;
        uint256 PENXtoAdd = (((info.stakedSet * sqrt(daysPassedSinceDeposit)) /
            (totalSupply / 1e18)) * coefficient) / 10000;
        info.accruedPENX += PENXtoAdd;
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    function withdrawPension() public {
        WorkerInfo storage info = workerAddressToInfo[msg.sender];
        require(info.stakedSet > 0, "Nothing to collect");

        bool hasFee;
        if (scheduler.getWorkerRetirementDate(msg.sender) < block.timestamp) {
            hasFee = true;
        }

        if (hasFee) {
            uint256 setFee = (info.stakedSet / 10000) * withdrawFee;
            uint256 penxFee = (info.accruedPENX / 10000) * withdrawFee;
            info.stakedSet -= setFee;
            accumulatedSetFee += setFee;
            info.accruedPENX -= penxFee;
        }

        address[] memory path = new address[](2);
        path[0] = address(PXLT);
        path[1] = address(USDC);
        PXLT.approve(address(router), info.stakedSet);
        uint256[] memory amounts = router.swapExactTokensForTokens(
            info.stakedSet,
            1,
            path,
            msg.sender,
            block.timestamp
        );
        PENX.transfer(address(this), info.accruedPENX);
        emit Withdraw(
            msg.sender,
            info.accruedPENX,
            info.stakedSet,
            amounts[1],
            hasFee
        );
        delete workerAddressToInfo[msg.sender];
    }
    
    function withdrawAccumulatedFee() public {
        require(scheduler.isAdmin(msg.sender), "Restricted method");
        PXLT.transferFrom(address(this), msg.sender, accumulatedSetFee);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IScheduler {

    function isOperator(address account) external view returns (bool);

    function isAdmin(address account) external view returns(bool);

    function getWorkerRetirementDate(address worker) external view returns(uint256);

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ISwap {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function factory() external pure returns (address);
}