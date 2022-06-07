//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import {IUniswapV2Router02} from "./interface/IUniswapV2Router02.sol";
import {IJoeRouter02} from "./interface/IJoeRouter02.sol";

contract OrbitExchange is Ownable {
    // Supported DEX Routers by Embr
    mapping(address => bool) public dexRouters;
    // Custom AVAX DEX Routers, supported by Embr
    mapping(address => bool) public customAvaxDexRouters;

    struct FeeInfos {
        uint256 treasuryFee; // i.e. 100% = 10000, 10% = 1000, 1% = 100, 0.5% = 50
        uint256 lpFee;
        uint256 buyBackFee;
        address treasuryFeeReceiver;
        address lpFeeReceiver;
        address buyBackFeeReceiver;
        uint256 totalFee;
        address withdrawer;
        uint256 feeCollected;
        uint256 feeWithdrew;
    }

    // token address => fee
    mapping(address => FeeInfos) tokenFeeInfos;

    // Events
    event DexRouterSet(address dexRouterAddress);
    event FeeSet(uint256 fee);
    event CustomAvaxDexRouterSet(address customAvaxDexRouterAddress);
    event Withdraw(address recipient, uint256 amount);

    /**
     * @param _dexRouterAddresses router addresses of DEX
     */
    constructor(address[] memory _dexRouterAddresses) {
        for (uint256 i = 0; i < _dexRouterAddresses.length; i++) {
            require(
                _dexRouterAddresses[i] != address(0),
                "OrbitExchange: DEX Router address can't be 0"
            );
            dexRouters[_dexRouterAddresses[i]] = true;
        }
    }

    /**
     * @param amountOutMin min amount of buyToken
     * @param path swap path
     * @param to address where buyToken will be transferred
     * @param deadline time limit for tx to be executed
     * @param dexRouterAddress dex router address
     */
    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        address dexRouterAddress
    ) external payable returns (uint256[] memory amounts) {
        address tokenAddress = path[path.length - 1];
        uint256 fee = tokenFeeInfos[tokenAddress].totalFee;

        // Check zero address
        require(to != address(0), "OrbitExchange: To address can't be 0");
        require(
            dexRouterAddress != address(0),
            "OrbitExchange: DEX Router address can't be 0"
        );

        // Check if the exchange supported on our Swap
        require(
            dexRouters[dexRouterAddress],
            "OrbitExchange: DEX is not supported by us!"
        );

        // Amount should be bigger than 0
        require(msg.value > 0, "OrbitExchange: Value can't be 0!");

        // Calculate the new amount
        uint256 feeAmount = (msg.value * fee) / 1e4;
        uint256 amountToSwap = msg.value - feeAmount;
        uint256 amountOutMinNew = (amountOutMin * (1e4 - fee)) / 1e4;

        // Run the swap
        if (customAvaxDexRouters[dexRouterAddress]) {
            IJoeRouter02(dexRouterAddress)
                .swapExactAVAXForTokensSupportingFeeOnTransferTokens{
                value: amountToSwap
            }(amountOutMinNew, path, to, deadline);
        } else {
            IUniswapV2Router02(dexRouterAddress)
                .swapExactETHForTokensSupportingFeeOnTransferTokens{
                value: amountToSwap
            }(amountOutMinNew, path, to, deadline);
        }
    }

    function withdrawEthFee(address tokenAddress) external {
        uint256 amountToWithdraw = tokenFeeInfos[tokenAddress].feeCollected -
            tokenFeeInfos[tokenAddress].feeWithdrew;
        require(
            msg.sender == tokenFeeInfos[tokenAddress].withdrawer,
            "OrbitExchange: You are not allowed to call this function"
        );
        require(
            amountToWithdraw > 0,
            "OrbitExchange: Fee is not available to withdraw"
        );
        uint256 lpAmount = (amountToWithdraw *
            tokenFeeInfos[tokenAddress].lpFee) /
            tokenFeeInfos[tokenAddress].totalFee;
        uint256 treasuryAmount = (amountToWithdraw *
            tokenFeeInfos[tokenAddress].treasuryFee) /
            tokenFeeInfos[tokenAddress].totalFee;
        uint256 buyBackAmount = amountToWithdraw - lpAmount - treasuryAmount;

        bool success = false;

        tokenFeeInfos[tokenAddress].feeWithdrew += amountToWithdraw;

        if (lpAmount > 0) {
            (success, ) = payable(tokenFeeInfos[tokenAddress].lpFeeReceiver)
                .call{value: lpAmount}("");
            require(success, "OrbitExchange: LP Fee Tranfer Failed!");
        }

        if (treasuryAmount > 0) {
            (success, ) = payable(
                tokenFeeInfos[tokenAddress].treasuryFeeReceiver
            ).call{value: treasuryAmount}("");
            require(success, "OrbitExchange: Treasury Fee Tranfer Failed!");
        }

        if (buyBackAmount > 0) {
            (success, ) = payable(
                tokenFeeInfos[tokenAddress].buyBackFeeReceiver
            ).call{value: buyBackAmount}("");
            require(success, "OrbitExchange: Buyback Fee Tranfer Failed!");
        }

        emit Withdraw(msg.sender, tokenFeeInfos[tokenAddress].feeCollected);
    }

    // Admin Related functions

    function setFeeInfos(
        address _tokenAddress,
        uint256 _treasuryFee,
        uint256 _lpFee,
        uint256 _buyBackFee,
        address _treasuryFeeReceiver,
        address _lpFeeReceiver,
        address _buyBackFeeReceiver,
        address _withdrawer
    ) external onlyOwner {
        tokenFeeInfos[_tokenAddress].treasuryFee = _treasuryFee;
        tokenFeeInfos[_tokenAddress].lpFee = _lpFee;
        tokenFeeInfos[_tokenAddress].buyBackFee = _buyBackFee;
        tokenFeeInfos[_tokenAddress].treasuryFeeReceiver = _treasuryFeeReceiver;
        tokenFeeInfos[_tokenAddress].lpFeeReceiver = _lpFeeReceiver;
        tokenFeeInfos[_tokenAddress].buyBackFeeReceiver = _buyBackFeeReceiver;
        tokenFeeInfos[_tokenAddress].withdrawer = _withdrawer;
        tokenFeeInfos[_tokenAddress].totalFee =
            _treasuryFee +
            _lpFee +
            _buyBackFee;
    }

    function setDexRouter(address _dexRouterAddress) external onlyOwner {
        // Check zero address
        require(
            _dexRouterAddress != address(0),
            "OrbitExchange: DEX Router address can't be 0"
        );
        dexRouters[_dexRouterAddress] = true;
        emit DexRouterSet(_dexRouterAddress);
    }

    function setCustomAvaxRouter(address _customAvaxDexRouterAddress)
        external
        onlyOwner
    {
        // Check zero address
        require(
            _customAvaxDexRouterAddress != address(0),
            "OrbitExchange: DEX Router address can't be 0"
        );
        customAvaxDexRouters[_customAvaxDexRouterAddress] = true;
        emit CustomAvaxDexRouterSet(_customAvaxDexRouterAddress);
    }

    function withdraw(address payable recipient, uint256 amountEther)
        external
        onlyOwner
    {
        require(
            recipient != address(0),
            "OrbitExchange: recipient address can't be 0"
        );
        require(
            address(this).balance >= amountEther,
            "OrbitExchange: Not enough ETH"
        );
        bool success = false;
        (success, ) = recipient.call{value: amountEther}("");
        require(success, "OrbitExchange: Tranfer Failed!");

        emit Withdraw(recipient, amountEther);
    }

    //to receive ETH from dexRouter when swapping
    receive() external payable {}
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

import "./IUniswapV2Router01.sol";

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

pragma solidity >=0.6.2;

import "./IJoeRouter01.sol";

interface IJoeRouter02 is IJoeRouter01 {
    function removeLiquidityAVAXSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountAVAXMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountAVAX);

    function removeLiquidityAVAXWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountAVAXMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountAVAX);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactAVAXForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForAVAXSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

pragma solidity >=0.6.2;

interface IJoeRouter01 {
    function factory() external pure returns (address);

    function WAVAX() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityAVAX(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountAVAXMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountAVAX,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityAVAX(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountAVAXMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountAVAX);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityAVAXWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountAVAXMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountAVAX);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactAVAXForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactAVAX(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForAVAX(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapAVAXForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}