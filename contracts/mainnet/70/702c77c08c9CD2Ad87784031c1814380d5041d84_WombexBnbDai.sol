// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {Defii} from "../Defii.sol";

contract WombexBnbDai is Defii {
    IERC20 constant DAI = IERC20(0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3);
    IERC20 constant WOM = IERC20(0xAD6742A35fB341A9Cc6ad674738Dd8da98b94Fb1);
    IERC20 constant WMX = IERC20(0xa75d9ca2a0a1D547409D82e1B06618EC284A2CeD);

    IAsset constant lpDai = IAsset(0x9D0a463D5dcB82008e86bF506eb048708a15dd84);
    IBooster constant booster = IBooster(0x9Ac0a3E8864Ea370Bf1A661444f6610dd041Ba1c);
    IPoolDepositor constant poolDepositor = IPoolDepositor(0xBc502Eb6c9bAD77929dabeF3155967E0ABfA9209);

    function hasAllocation() external view override returns (bool) {
        uint256 pid = poolDepositor.lpTokenToPid(address(lpDai));
        IBooster.PoolInfo memory poolInfo = booster.poolInfo(pid);
    
        IRewards rewardPool = IRewards(poolInfo.crvRewards);
        return rewardPool.balanceOf(address(this)) > 0;
    }

    function _enter() internal override {
        uint256 daiAmount = DAI.balanceOf(address(this));
        IPool pool = IPool(lpDai.pool());
        DAI.approve(address(pool), daiAmount);
        uint256 liquidity = pool.deposit(
            address(DAI),
            daiAmount,
            (daiAmount * 9995) / 10000,
            address(this),
            block.timestamp,
            false
        );

        uint256 pid = poolDepositor.lpTokenToPid(address(lpDai));
        require(address(lpDai) == booster.poolInfo(pid).lptoken);
        lpDai.approve(address(booster), liquidity);
        booster.deposit(pid, liquidity, true);
    }

    function _exit() internal override {
        _harvest();
        uint256 pid = poolDepositor.lpTokenToPid(address(lpDai));
        IBooster.PoolInfo memory poolInfo = booster.poolInfo(pid);
        IRewards rewardPool = IRewards(poolInfo.crvRewards);

        uint256 lpAmount = rewardPool.balanceOf(address(this));
        rewardPool.approve(address(poolDepositor), lpAmount);
        poolDepositor.withdraw(
            address(lpDai),
            rewardPool.balanceOf(address(this)),
            0,
            address(this)
        );
    }

    function _harvest() internal override {
        uint256 pid = poolDepositor.lpTokenToPid(address(lpDai));
        IBooster.PoolInfo memory poolInfo = booster.poolInfo(pid);
        IRewards rewarder = IRewards(poolInfo.crvRewards);
        rewarder.getReward();
        withdrawERC20(WOM);
        withdrawERC20(WMX);
    }

    function _withdrawFunds() internal override{
        withdrawERC20(DAI);
     }

}

interface IPool {
    function deposit(
        address token,
        uint256 amount,
        uint256 minimumLiquidity,
        address to,
        uint256 deadline,
        bool shouldStake
    ) external returns (uint256);

    function withdraw(
        address token,
        uint256 liquidity,
        uint256 minimumAmount,
        address to,
        uint256 deadline
    ) external returns (uint256 amount);
 
}

interface IPoolDepositor {
    function deposit(
        address _lptoken,
        uint256 _amount,
        uint256 _minLiquidity,
        bool _stake
    ) external;

    function withdraw(
        address _lptoken,
        uint256 _amount,
        uint256 _minOut,
        address _recipient
    ) external;

    function lpTokenToPid(address lpToken) external view returns(uint256);

}

interface IAsset is IERC20 {
    function pool() external view returns (address);
}

interface IBooster {
    struct PoolInfo {
        address lptoken;
        address token;
        address gauge;
        address crvRewards;
        bool shutdown;
    }

    function poolInfo(uint256 _pid) external view returns(PoolInfo memory);
    function deposit(uint256 _pid, uint256 _amount, bool _stake) external returns(bool);
}

interface IRewards is IERC20 {
    function getReward() external returns(bool);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "./interfaces/IDefiiFactory.sol";
import "./interfaces/IDefii.sol";

abstract contract Defii is IDefii {
    address public owner;
    address public factory;

    /// @notice Sets owner and factory addresses. Could run only once, called by factory.
    /// @param owner_ Owner (for ACL and transfers out)
    /// @param factory_ For validation and info about executor
    function init(address owner_, address factory_) external {
        require(owner == address(0), "Already initialized");
        owner = owner_;
        factory = factory_;
    }

    //////
    // owner functions
    //////

    /// @notice Enters to DEFI instrument. Could run only by owner.
    function enter() external onlyOwner {
        _enter();
    }

    /// @notice Runs custom transaction. Could run only by owner.
    /// @param target Address
    /// @param value Transaction value (e.g. 1 AVAX)
    /// @param data Enocded function call
    function runTx(
        address target,
        uint256 value,
        bytes memory data
    ) public onlyOwner {
        (bool success, ) = target.call{value: value}(data);
        require(success, "runTx failed");
    }

    /// @notice Runs custom multiple transactions. Could run only by owner.
    /// @param targets List of address
    /// @param values List of transactions value (e.g. 1 AVAX)
    /// @param datas List of enocded function calls
    function runMultipleTx(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata datas
    ) external onlyOwner {
        require(
            targets.length == values.length,
            "targets and values length not match"
        );
        require(
            targets.length == datas.length,
            "targets and datas length not match"
        );

        for (uint256 i = 0; i < targets.length; i++) {
            runTx(targets[i], values[i], datas[i]);
        }
    }

    //////
    // owner and executor functions
    //////

    /// @notice Exit from DEFI instrument. Could run by owner or executor. Don't withdraw funds to owner account.
    function exit() external onlyOnwerOrExecutor {
        _exit();
    }

    /// @notice Exit from DEFI instrument. Could run by owner or executor.
    function exitAndWithdraw() public onlyOnwerOrExecutor {
        _exit();
        _withdrawFunds();
    }

    /// @notice Claim rewards and withdraw to owner.
    function harvest() external onlyOnwerOrExecutor {
        _harvest();
    }

    /// @notice Claim rewards, sell it and and withdraw to owner.
    /// @param params Encoded params (use encodeParams function for it)
    function harvestWithParams(bytes memory params)
        external
        onlyOnwerOrExecutor
    {
        _harvestWithParams(params);
    }

    /// @notice Withdraw funds to owner (some hardcoded assets, which uses in instrument).
    function withdrawFunds() external onlyOnwerOrExecutor {
        _withdrawFunds();
    }

    /// @notice Withdraw ERC20 to owner
    /// @param token ERC20 address
    function withdrawERC20(IERC20 token) public onlyOnwerOrExecutor {
        _withdrawERC20(token);
    }

    /// @notice Withdraw native token to owner (e.g ETH, AVAX, ...)
    function withdrawETH() public onlyOnwerOrExecutor {
        _withdrawETH();
    }

    receive() external payable {}

    //////
    // internal functions - common logic
    //////

    function _withdrawERC20(IERC20 token) internal {
        uint256 tokenAmount = token.balanceOf(address(this));
        if (tokenAmount > 0) {
            token.transfer(owner, tokenAmount);
        }
    }

    function _withdrawETH() internal {
        uint256 balance = address(this).balance;
        if (balance > 0) {
            (bool success, ) = owner.call{value: balance}("");
            require(success, "Transfer failed");
        }
    }

    //////
    // internal functions - defii specific logic
    //////

    function _enter() internal virtual;

    function _exit() internal virtual;

    function _harvest() internal virtual {
        revert("Use harvestWithParams");
    }

    function _withdrawFunds() internal virtual;

    function _harvestWithParams(bytes memory params) internal virtual {
        revert("Run harvest");
    }

    //////
    // modifiers
    //////

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier onlyOnwerOrExecutor() {
        require(
            msg.sender == owner ||
                msg.sender == IDefiiFactory(factory).executor(),
            "Only owner or executor"
        );
        _;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

struct Info {
    address wallet;
    address defii;
    bool hasAllocation;
}

interface IDefiiFactory {
    function executor() external view returns (address executor);

    function getDefiiFor(address wallet) external view returns (address defii);

    function getAllWallets() external view returns (address[] memory);

    function getAllDefiis() external view returns (address[] memory);

    function getAllAllocations() external view returns (bool[] memory);

    function getAllInfos() external view returns (Info[] memory);

    function createDefii() external;

    function createDefiiFor(address owner) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

interface IDefii {
    function hasAllocation() external view returns (bool);

    function init(address owner_, address factory_) external;

    function enter() external;

    function runTx(
        address target,
        uint256 value,
        bytes memory data
    ) external;

    function runMultipleTx(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata datas
    ) external;

    function exit() external;

    function exitAndWithdraw() external;

    function harvest() external;

    function withdrawERC20(IERC20 token) external;

    function withdrawETH() external;

    function withdrawFunds() external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}