// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {Defii} from "../Defii.sol";

contract TranchessBnbBbishopBusd is Defii {
    IERC20 constant BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    IERC20 constant CHESS = IERC20(0x20de22029ab63cf9A7Cf5fEB2b737Ca1eE4c82A6);
    IERC20 constant USDC = IERC20(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d);
    IERC20 constant lpToken =
        IERC20(0x3F586aA29C61488f25748911be3c52246c744fc2);

    IStableSwap constant pool =
        IStableSwap(0x999DB223F0807B164b783eE33d48782cc6E06742);
    IFund constant fund = IFund(0x2f40c245c66C5219e0615571a526C93883B456BB);
    IClaimRewards constant shareStaking =
        IClaimRewards(0xFa7b73009d635b0AB069cBe99C5a5D498F701c76);
    IClaimRewards constant liquidityGauge =
        IClaimRewards(0x3F586aA29C61488f25748911be3c52246c744fc2);
    IRouter constant pancakeSwapRouter =
        IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    uint256 constant TRANCHE_B = 1;

    function harvestParams() external view returns (bytes memory params) {
        address[] memory path = new address[](2);
        path[0] = address(CHESS);
        path[1] = address(USDC);

        // Price for 1.0 CHESS
        uint256[] memory prices = pancakeSwapRouter.getAmountsOut(1e18, path);
        params = abi.encode((prices[1] * 99) / 100);
    }

    function hasAllocation() external view override returns (bool) {
        return lpToken.balanceOf(address(this)) > 0;
    }

    function _enter() internal override {
        BUSD.transfer(address(pool), BUSD.balanceOf(address(this)));
        pool.addLiquidity(fund.getRebalanceSize(), address(this));
    }

    function _exit() internal override {
        uint256 version = fund.getRebalanceSize();

        (uint256 baseOut, ) = pool.removeLiquidity(
            version,
            lpToken.balanceOf(address(this)),
            0,
            0
        );

        fund.trancheTransfer(TRANCHE_B, address(pool), baseOut, version);
        uint256 realQuoteOut = pool.sell(
            version,
            pool.getQuoteOut(baseOut),
            address(this),
            bytes("")
        );

        // Slippage: 0.05%
        uint256 minQuoteOut = (baseOut * pool.getOraclePrice() * 995) /
            1000 /
            1e18;
        require(realQuoteOut >= minQuoteOut, "Slippage BISHOP -> BUSD");

        _claim();
        _sellReward(0);
    }

    function _harvestWithParams(bytes memory params) internal override {
        uint256 minPrice = abi.decode(params, (uint256));

        _claim();
        _sellReward(minPrice);
    }

    function _withdrawFunds() internal override {
        _withdrawERC20(BUSD);
    }

    function _claim() internal {
        shareStaking.claimRewards(address(this));
        liquidityGauge.claimRewards(address(this));
    }

    function _sellReward(uint256 minPrice) internal {
        uint256 chessBalance = CHESS.balanceOf(address(this));
        uint256 amountOutMin = (chessBalance * minPrice) / 1e18;

        if (minPrice > 0 && amountOutMin == 0) {
            return;
        }

        address[] memory path = new address[](2);
        path[0] = address(CHESS);
        path[1] = address(USDC);
        CHESS.approve(address(pancakeSwapRouter), chessBalance);
        pancakeSwapRouter.swapExactTokensForTokens(
            chessBalance,
            amountOutMin,
            path,
            address(this),
            block.timestamp
        );
        _withdrawERC20(USDC);
    }
}

interface IStableSwap {
    function addLiquidity(uint256 version, address recipient)
        external
        returns (uint256 lpOut);

    function removeLiquidity(
        uint256 version,
        uint256 lpIn,
        uint256 minBaseOut,
        uint256 minQuoteOut
    ) external returns (uint256 baseOut, uint256 quoteOut);

    function sell(
        uint256 version,
        uint256 quoteOut,
        address recipient,
        bytes calldata data
    ) external returns (uint256 realQuoteOut);

    function getQuoteOut(uint256 baseIn)
        external
        view
        returns (uint256 quoteOut);

    function getOraclePrice() external view returns (uint256);

    function currentVersion() external returns (uint256);
}

interface IClaimRewards {
    function claimRewards(address account) external;
}

interface IFund {
    function getRebalanceSize() external returns (uint256);

    function trancheTransfer(
        uint256 tranche,
        address recipient,
        uint256 amount,
        uint256 version
    ) external;
}

interface IRouter {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);
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