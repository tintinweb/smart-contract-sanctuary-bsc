// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {Defii} from "../Defii.sol";

uint256 constant N_COINS = 2;

contract HelioBscHayBusd is Defii {
    IERC20 constant BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    IERC20 constant HAY = IERC20(0x0782b6d8c4551B9760e74c0545a9bCD90bdc41E5);
    IERC20 constant lpToken =
        IERC20(0xB6040A9F294477dDAdf5543a24E5463B8F2423Ae);

    IStableSwap constant stableSwap =
        IStableSwap(0x49079D07ef47449aF808A4f36c2a8dEC975594eC);
    IFarming constant farming =
        IFarming(0xf0fA2307392e3b0bD742437C6f80C6C56Fd8A37f);
    uint256 constant FARMING_PID = 1;

    function hasAllocation() external view override returns (bool) {
        (uint256 shares, , ) = farming.userInfo(FARMING_PID, address(this));
        return shares > 0;
    }

    function _enter() internal override {
        uint256 busdAmount = BUSD.balanceOf(address(this));
        BUSD.approve(address(stableSwap), busdAmount);
        uint256[N_COINS] memory amounts = [0, busdAmount];
        stableSwap.add_liquidity(amounts, 0);

        uint256 lpAmount = lpToken.balanceOf(address(this));
        lpToken.approve(address(farming), lpAmount);
        farming.deposit(1, lpAmount, false, address(this));
    }

    function _exit() internal override {
        uint256 lpAmount = farming.withdrawAll(FARMING_PID, true);
        uint256[N_COINS] memory amounts = [uint256(0), 0];
        stableSwap.remove_liquidity(lpAmount, amounts);

        uint256 hayAmount = HAY.balanceOf(address(this));
        HAY.approve(address(stableSwap), hayAmount);
        stableSwap.exchange(0, 1, hayAmount, (hayAmount * 999) / 1000);
    }

    function _harvest() internal override {
        uint256[] memory pids = new uint256[](1);
        pids[0] = FARMING_PID;
        uint256 hayAmount = farming.claim(address(this), pids);
        HAY.approve(address(stableSwap), hayAmount);
        stableSwap.exchange(0, 1, hayAmount, (hayAmount * 999) / 1000);
        withdrawERC20(BUSD);
    }

    function _withdrawFunds() internal override {
        withdrawERC20(BUSD);
    }
}

interface IStableSwap {
    function add_liquidity(
        uint256[N_COINS] memory amounts,
        uint256 min_mint_amount
    ) external;

    function remove_liquidity(
        uint256 _amount,
        uint256[N_COINS] memory min_amounts
    ) external;

    function exchange(
        uint256 i,
        uint256 j,
        uint256 dx,
        uint256 min_dy
    ) external;
}

interface IFarming {
    function deposit(
        uint256 _pid,
        uint256 _wantAmt,
        bool _claimRewards,
        address _userAddress
    ) external;

    function withdrawAll(uint256 _pid, bool _claimRewards)
        external
        returns (uint256);

    function claim(address _user, uint256[] calldata _pids)
        external
        returns (uint256);

    function userInfo(uint256 pid, address wallet)
        external
        view
        returns (
            uint256 shares,
            uint256 rewardDebt,
            uint256 claimable
        );
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "./interfaces/IDefiiFactory.sol";
import "./interfaces/IDefii.sol";


abstract contract Defii is IDefii {
    address public owner;
    address public factory;

    function init(address owner_, address factory_) external {
        require(owner == address(0), "Already initialized");
        owner = owner_;
        factory = factory_;
    }

    // owner functions
    function enter() external onlyOwner {
        _enter();
    }

    function runTx(address target, uint256 value, bytes memory data) external onlyOwner {
        (bool success,) = target.call{value: value}(data);
        require(success, "runTx failed");
    }

    // owner and executor functions
    function exit() external onlyOnwerOrExecutor {
        _exit();
    }
    function exitAndWithdraw() public onlyOnwerOrExecutor {
        _exit();
        _withdrawFunds();
    }

    function harvest() external onlyOnwerOrExecutor {
        _harvest();
    }

    function harvestWithParams(bytes memory params) external onlyOnwerOrExecutor {
        _harvestWithParams(params);
    }

    function withdrawFunds() external onlyOnwerOrExecutor {
        _withdrawFunds();
    }

    function withdrawERC20(IERC20 token) public onlyOnwerOrExecutor {
        _withdrawERC20(token);
    }

    function withdrawETH() public onlyOnwerOrExecutor {
        _withdrawETH();
    }
    receive() external payable {}

    // internal functions - common logic
    function _withdrawERC20(IERC20 token) internal {
        uint256 tokenAmount = token.balanceOf(address(this));
        if (tokenAmount > 0) {
            token.transfer(owner, tokenAmount);
        }
    }

    function _withdrawETH() internal {
        uint256 balance = address(this).balance;
        if (balance > 0) {
            (bool success,) = owner.call{value: balance}("");
            require(success, "Transfer failed");
        }
    }

    function hasAllocation() external view virtual returns (bool);
    // internal functions - defii specific logic
    function _enter() internal virtual;
    function _exit() internal virtual;
    function _harvest() internal virtual {
        revert("Use harvestWithParams");
    }
    function _withdrawFunds() internal virtual;
    function _harvestWithParams(bytes memory params) internal virtual {
        revert("Run harvest");
    }

    // modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier onlyOnwerOrExecutor() {
        require(msg.sender == owner || msg.sender == IDefiiFactory(factory).executor(), "Only owner or executor");
        _;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;


interface IDefiiFactory {
    function executor() view external returns (address executor);

    function createDefiiFor(address wallet) external;
    function createDefii() external;
    function getDefiiFor(address wallet) external view returns (address defii);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";

interface IDefii {
    function init(address owner_, address factory_) external;

    function enter() external;
    function runTx(address target, uint256 value, bytes memory data) external;

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