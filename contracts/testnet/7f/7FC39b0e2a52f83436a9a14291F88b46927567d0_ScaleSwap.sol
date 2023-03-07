/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

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

contract ScaleSwap is Ownable {
    using SafeERC20 for IERC20;

    struct FeeInfos {
        uint256[] buyFees; // i.e. 100% = 10000, 10% = 1000, 1% = 100, 0.5% = 50
        uint256[] sellFees; // i.e. 100% = 10000, 10% = 1000, 1% = 100, 0.5% = 50
        address[] feeReceivers;
        uint256 buyTotalFee;
        uint256 sellTotalFee;
        uint256 feeCollected;
        uint256 feeWithdrew;
    }

    // token address => fee
    mapping(address => FeeInfos) public tokenFeeInfos;

    struct PlatformFeeInfos {
        uint256 fee;
        address feeReceiver;
        address scaleTokenAddress;
        uint256 minAmtToHoldScale;
        uint256 feeCollected;
        uint256 feeWithdrew;
    }

    PlatformFeeInfos public platformFeeInfos;    

    // address public dexRouterAddress =
    //     0x10ED43C718714eb63d5aA57B78B54704E256024E;

    // testnet
    address public dexRouterAddress =
        0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

    // define to prevent Stack too deep
    struct SwapLocalInfos {
        address sellTokenAddress;
        address buyTokenAddress;
        uint256 totalFee;
        uint256 buyTokenFee;
        uint256 sellTokenFee;
        uint256 platformFee;
        uint256 totalFeeAmount;
        uint256 buyTokenFeeAmount;
        uint256 sellTokenFeeAmount;
        uint256 platformFeeAmount;
        uint256 amountToSwap;
        uint256 prevBalanceOfToken;
        uint256 amountToSend;
    }

    constructor() {
        platformFeeInfos = PlatformFeeInfos(
            30,
            msg.sender,
            0x24bBeAD6C019C50Ce3C6eD2e3a6B7179BC0f8B4f,
            10000 ether,
            0,
            0
        );
    }

    function getPlatformFee(address holder) internal view returns (uint256) {
        if (
            IERC20(platformFeeInfos.scaleTokenAddress).balanceOf(holder) <
            platformFeeInfos.minAmtToHoldScale
        ) {
            return platformFeeInfos.fee;
        }
        return 0;
    }

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable {
        require(path.length > 0, "ScaleSwap: Path doesn't exist");
        require(msg.value > 0, "ScaleSwap: Value can't be 0");

        SwapLocalInfos memory swapInfo;
        swapInfo.buyTokenAddress = path[path.length - 1];
        swapInfo.platformFee = getPlatformFee(msg.sender);
        swapInfo.buyTokenFee = tokenFeeInfos[swapInfo.buyTokenAddress]
            .buyTotalFee;
        swapInfo.totalFee = swapInfo.buyTokenFee + swapInfo.platformFee;

        // Calculate the new amount
        swapInfo.totalFeeAmount = (msg.value * swapInfo.totalFee) / 1e4;
        swapInfo.amountToSwap = msg.value - swapInfo.totalFeeAmount;

        // Run the swap
        swapInfo.prevBalanceOfToken = IERC20(swapInfo.buyTokenAddress)
            .balanceOf(address(this));
        IUniswapV2Router02(dexRouterAddress)
            .swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: swapInfo.amountToSwap
        }(amountOutMin, path, address(this), deadline);
        swapInfo.amountToSend =
            IERC20(swapInfo.buyTokenAddress).balanceOf(address(this)) -
            swapInfo.prevBalanceOfToken;

        IERC20(swapInfo.buyTokenAddress).safeTransfer(
            to,
            swapInfo.amountToSend
        );

        if (swapInfo.totalFeeAmount > 0) {
            swapInfo.buyTokenFeeAmount =
                (swapInfo.totalFeeAmount * swapInfo.buyTokenFee) /
                swapInfo.totalFee;
            tokenFeeInfos[swapInfo.buyTokenAddress].feeCollected += swapInfo
                .buyTokenFeeAmount;

            if (swapInfo.totalFeeAmount >= swapInfo.buyTokenFeeAmount) {
                swapInfo.platformFeeAmount =
                    swapInfo.totalFeeAmount -
                    swapInfo.buyTokenFeeAmount;
                platformFeeInfos.feeCollected += swapInfo.platformFeeAmount;
            }
        }
        withdrawTokenFeeAuto(swapInfo.buyTokenAddress, false);
        withdrawPlatformFeeAuto();
    }

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable {
        require(path.length > 0, "ScaleSwap: Path doesn't exist");
        require(msg.value > 0, "ScaleSwap: Value can't be 0");

        SwapLocalInfos memory swapInfo;
        swapInfo.buyTokenAddress = path[path.length - 1];
        swapInfo.platformFee = getPlatformFee(msg.sender);
        swapInfo.buyTokenFee = tokenFeeInfos[swapInfo.buyTokenAddress]
            .buyTotalFee;
        swapInfo.totalFee = swapInfo.buyTokenFee + swapInfo.platformFee;

        uint256 prevBalanceOfETH = address(this).balance;
        // Run the swap
        swapInfo.prevBalanceOfToken = IERC20(swapInfo.buyTokenAddress)
            .balanceOf(address(this));
        IUniswapV2Router02(dexRouterAddress).swapETHForExactTokens{
            value: msg.value
        }(amountOut, path, address(this), deadline);

        uint256 usedETHForSwap = prevBalanceOfETH - address(this).balance;

        swapInfo.amountToSend =
            IERC20(swapInfo.buyTokenAddress).balanceOf(address(this)) -
            swapInfo.prevBalanceOfToken;

        IERC20(swapInfo.buyTokenAddress).safeTransfer(
            to,
            swapInfo.amountToSend
        );

        swapInfo.totalFeeAmount =
            (usedETHForSwap * swapInfo.totalFee) /
            (1e4 - swapInfo.totalFee);

        if (swapInfo.totalFeeAmount > 0) {
            swapInfo.buyTokenFeeAmount =
                (swapInfo.totalFeeAmount * swapInfo.buyTokenFee) /
                swapInfo.totalFee;
            tokenFeeInfos[swapInfo.buyTokenAddress].feeCollected += swapInfo
                .buyTokenFeeAmount;

            if (swapInfo.totalFeeAmount >= swapInfo.buyTokenFeeAmount) {
                swapInfo.platformFeeAmount =
                    swapInfo.totalFeeAmount -
                    swapInfo.buyTokenFeeAmount;
                platformFeeInfos.feeCollected += swapInfo.platformFeeAmount;
            }
        }
        withdrawTokenFeeAuto(swapInfo.buyTokenAddress, false);
        withdrawPlatformFeeAuto();

        uint256 leftoverETH = 0;
        if (msg.value >= (usedETHForSwap + swapInfo.totalFeeAmount)) {
            leftoverETH = msg.value - usedETHForSwap - swapInfo.totalFeeAmount;
        }

        if (leftoverETH > 0) {
            // refund leftover ETH to user
            (bool sent, ) = payable(msg.sender).call{value: leftoverETH}("");
            require(sent, "Failed to send ETH");
        }
    }

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external {
        require(path.length > 0, "ScaleSwap: Path doesn't exist");
        require(amountIn > 0, "ScaleSwap: Value can't be 0");

        SwapLocalInfos memory swapInfo;
        swapInfo.sellTokenAddress = path[0];
        swapInfo.platformFee = getPlatformFee(msg.sender);
        swapInfo.sellTokenFee = tokenFeeInfos[swapInfo.sellTokenAddress]
            .sellTotalFee;
        swapInfo.totalFee = swapInfo.sellTokenFee + swapInfo.platformFee;

        // Transfer tokens from msg.sender to this
        IERC20(swapInfo.sellTokenAddress).safeTransferFrom(
            msg.sender,
            address(this),
            amountIn
        );

        if (
            IERC20(swapInfo.sellTokenAddress).allowance(
                address(this),
                dexRouterAddress
            ) < amountIn
        ) {
            IERC20(swapInfo.sellTokenAddress).approve(
                dexRouterAddress,
                IERC20(swapInfo.sellTokenAddress).totalSupply()
            );
        }

        // Run the swap
        uint256 prevBalanceOfETH = address(this).balance;

        IUniswapV2Router02(dexRouterAddress)
            .swapExactTokensForETHSupportingFeeOnTransferTokens(
                amountIn,
                amountOutMin,
                path,
                address(this),
                deadline
            );
        uint256 nowBalance = address(this).balance;
        swapInfo.totalFeeAmount =
            ((nowBalance - prevBalanceOfETH) * swapInfo.totalFee) /
            1e4;

        (bool sent, ) = payable(to).call{
            value: (nowBalance - prevBalanceOfETH - swapInfo.totalFeeAmount)
        }("");

        if (swapInfo.totalFeeAmount > 0) {
            swapInfo.sellTokenFeeAmount =
                (swapInfo.totalFeeAmount * swapInfo.sellTokenFee) /
                swapInfo.totalFee;
            tokenFeeInfos[swapInfo.sellTokenAddress].feeCollected += swapInfo
                .sellTokenFeeAmount;

            if (swapInfo.totalFeeAmount >= swapInfo.sellTokenFeeAmount) {
                swapInfo.platformFeeAmount =
                    swapInfo.totalFeeAmount -
                    swapInfo.sellTokenFeeAmount;
                platformFeeInfos.feeCollected += swapInfo.platformFeeAmount;
            }
        }

        withdrawTokenFeeAuto(swapInfo.sellTokenAddress, true);
        withdrawPlatformFeeAuto();

        require(sent);
    }

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external {
        require(path.length > 0, "ScaleSwap: Path doesn't exist");
        require(amountInMax > 0, "ScaleSwap: Value can't be 0");

        SwapLocalInfos memory swapInfo;
        swapInfo.sellTokenAddress = path[0];
        swapInfo.platformFee = getPlatformFee(msg.sender);
        swapInfo.sellTokenFee = tokenFeeInfos[swapInfo.sellTokenAddress]
            .sellTotalFee;
        swapInfo.totalFee = swapInfo.sellTokenFee + swapInfo.platformFee;

        // Transfer tokens from sender to this
        IERC20(swapInfo.sellTokenAddress).safeTransferFrom(
            msg.sender,
            address(this),
            amountInMax
        );

        if (
            IERC20(swapInfo.sellTokenAddress).allowance(
                address(this),
                dexRouterAddress
            ) < amountInMax
        ) {
            IERC20(swapInfo.sellTokenAddress).approve(
                dexRouterAddress,
                IERC20(swapInfo.sellTokenAddress).totalSupply()
            );
        }

        uint256 prevBalanceOfBuyToken = IERC20(swapInfo.buyTokenAddress)
            .balanceOf(address(this));

        swapInfo.amountToSwap =
            (amountOut * 1e4) /
            (1e4 - swapInfo.totalFee);

        // Run the swap
        swapInfo.prevBalanceOfToken = IERC20(swapInfo.sellTokenAddress)
            .balanceOf(address(this));
        IUniswapV2Router02(dexRouterAddress).swapTokensForExactETH(
            swapInfo.amountToSwap,
            amountInMax,
            path,
            address(this),
            deadline
        );

        uint256 usedSellTokenForSwap = swapInfo.prevBalanceOfToken -
            IERC20(swapInfo.sellTokenAddress).balanceOf(address(this));

        swapInfo.amountToSend =
            IERC20(swapInfo.buyTokenAddress).balanceOf(address(this)) -
            prevBalanceOfBuyToken;

        if (swapInfo.amountToSend >= amountOut) {
            swapInfo.totalFeeAmount = swapInfo.amountToSend - amountOut;
            swapInfo.amountToSend = amountOut;
        } else {
            swapInfo.totalFeeAmount = 0;
        }

        (bool sent, ) = payable(to).call{value: swapInfo.amountToSend}("");

        if (swapInfo.totalFeeAmount > 0) {
            swapInfo.sellTokenFeeAmount =
                (swapInfo.totalFeeAmount * swapInfo.sellTokenFee) /
                swapInfo.totalFee;
            tokenFeeInfos[swapInfo.sellTokenAddress].feeCollected += swapInfo
                .sellTokenFeeAmount;

            if (swapInfo.totalFeeAmount >= swapInfo.sellTokenFeeAmount) {
                swapInfo.platformFeeAmount =
                    swapInfo.totalFeeAmount -
                    swapInfo.sellTokenFeeAmount;
                platformFeeInfos.feeCollected += swapInfo.platformFeeAmount;
            }
        }

        withdrawTokenFeeAuto(swapInfo.sellTokenAddress, true);
        withdrawPlatformFeeAuto();

        uint256 leftoverSellToken = 0;
        if (amountInMax >= usedSellTokenForSwap) {
            leftoverSellToken = amountInMax - usedSellTokenForSwap;
        }

        // refund leftover SellToken to user
        IERC20(swapInfo.sellTokenAddress).safeTransfer(to, leftoverSellToken);
        require(sent);
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address[] calldata sellTokenToWETHpath,
        address to,
        uint256 deadline
    ) external {
        require(path.length > 0, "ScaleSwap: Path doesn't exist");
        require(amountIn > 0, "ScaleSwap: Value can't be 0");

        SwapLocalInfos memory swapInfo;
        swapInfo.sellTokenAddress = path[0];
        swapInfo.buyTokenAddress = path[path.length - 1];

        // Transfer tokens from sender to this
        IERC20(swapInfo.sellTokenAddress).safeTransferFrom(
            msg.sender,
            address(this),
            amountIn
        );

        swapInfo.amountToSwap = amountIn;
        swapInfo.platformFee = getPlatformFee(msg.sender);
        swapInfo.sellTokenFee = tokenFeeInfos[swapInfo.sellTokenAddress]
            .sellTotalFee;
        swapInfo.totalFee = swapInfo.sellTokenFee + swapInfo.platformFee;
        swapInfo.buyTokenFee =
            ((1e4 - swapInfo.totalFee) *
                tokenFeeInfos[swapInfo.buyTokenAddress].buyTotalFee) /
            1e4;

        swapInfo.totalFee = swapInfo.totalFee + swapInfo.buyTokenFee;
        swapInfo.totalFeeAmount = (amountIn * swapInfo.totalFee) / 1e4;
        swapInfo.amountToSwap = amountIn - swapInfo.totalFeeAmount;

        if (
            IERC20(swapInfo.sellTokenAddress).allowance(
                address(this),
                dexRouterAddress
            ) < swapInfo.amountToSwap
        ) {
            IERC20(swapInfo.sellTokenAddress).approve(
                dexRouterAddress,
                IERC20(swapInfo.sellTokenAddress).totalSupply()
            );
        }

        swapInfo.prevBalanceOfToken = IERC20(swapInfo.buyTokenAddress)
            .balanceOf(address(this));
        IUniswapV2Router02(dexRouterAddress)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                swapInfo.amountToSwap,
                amountOutMin,
                path,
                address(this),
                deadline
            );

        swapInfo.amountToSend =
            IERC20(swapInfo.buyTokenAddress).balanceOf(address(this)) -
            swapInfo.prevBalanceOfToken;

        IERC20(swapInfo.buyTokenAddress).safeTransfer(
            to,
            swapInfo.amountToSend
        );

        swapInfo.prevBalanceOfToken = address(this).balance;
        //check allowance
        if (
            IERC20(swapInfo.sellTokenAddress).allowance(
                address(this),
                dexRouterAddress
            ) < swapInfo.totalFeeAmount
        ) {
            IERC20(swapInfo.sellTokenAddress).approve(
                dexRouterAddress,
                IERC20(swapInfo.sellTokenAddress).totalSupply()
            );
        }

        IUniswapV2Router02(dexRouterAddress)
            .swapExactTokensForETHSupportingFeeOnTransferTokens(
                swapInfo.totalFeeAmount,
                0,
                sellTokenToWETHpath,
                address(this),
                deadline
            );

        swapInfo.totalFeeAmount =
            address(this).balance -
            swapInfo.prevBalanceOfToken;

        if (swapInfo.totalFeeAmount > 0) {
            swapInfo.sellTokenFeeAmount =
                (swapInfo.totalFeeAmount * swapInfo.sellTokenFee) /
                swapInfo.totalFee;
            swapInfo.platformFeeAmount =
                (swapInfo.totalFeeAmount * swapInfo.platformFee) /
                swapInfo.totalFee;

            tokenFeeInfos[swapInfo.sellTokenAddress].feeCollected += swapInfo
                .sellTokenFeeAmount;

            platformFeeInfos.feeCollected += swapInfo.platformFeeAmount;

            if (
                swapInfo.totalFeeAmount >=
                (swapInfo.sellTokenFeeAmount + swapInfo.platformFeeAmount)
            ) {
                tokenFeeInfos[swapInfo.buyTokenAddress]
                    .feeCollected += (swapInfo.totalFeeAmount -
                    swapInfo.sellTokenFeeAmount -
                    swapInfo.platformFeeAmount);
            }
        }

        withdrawTokenFeeAuto(swapInfo.sellTokenAddress, true);
        withdrawTokenFeeAuto(swapInfo.buyTokenAddress, false);
        withdrawPlatformFeeAuto();
    }

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address[] calldata sellTokenToWETHpath,
        address to,
        uint256 deadline
    ) external {
        require(amountInMax > 0, "ScaleSwap: Value can't be 0");
        require(path.length > 0, "ScaleSwap: Path doesn't exist");

        SwapLocalInfos memory swapInfo;
        swapInfo.sellTokenAddress = path[0];
        swapInfo.buyTokenAddress = path[path.length - 1];

        // Transfer tokens from sender to this
        IERC20(swapInfo.sellTokenAddress).safeTransferFrom(
            msg.sender,
            address(this),
            amountInMax
        );

        swapInfo.platformFee = getPlatformFee(msg.sender);
        swapInfo.sellTokenFee = tokenFeeInfos[swapInfo.sellTokenAddress]
            .sellTotalFee;
        swapInfo.totalFee = swapInfo.sellTokenFee + swapInfo.platformFee;
        swapInfo.buyTokenFee =
            ((1e4 - swapInfo.totalFee) *
                tokenFeeInfos[swapInfo.buyTokenAddress].buyTotalFee) /
            1e4;

        swapInfo.totalFee = swapInfo.totalFee + swapInfo.buyTokenFee;

        if (
            IERC20(swapInfo.sellTokenAddress).allowance(
                address(this),
                dexRouterAddress
            ) < amountInMax
        ) {
            IERC20(swapInfo.sellTokenAddress).approve(
                dexRouterAddress,
                IERC20(swapInfo.sellTokenAddress).totalSupply()
            );
        }

        uint256 prevBalanceOfBuyToken = IERC20(swapInfo.buyTokenAddress)
            .balanceOf(address(this));

        // Run the swap
        swapInfo.prevBalanceOfToken = IERC20(swapInfo.sellTokenAddress)
            .balanceOf(address(this));
        IUniswapV2Router02(dexRouterAddress).swapTokensForExactTokens(
            amountOut,
            amountInMax,
            path,
            address(this),
            deadline
        );

        uint256 usedSellTokenForSwap = swapInfo.prevBalanceOfToken -
            IERC20(swapInfo.sellTokenAddress).balanceOf(address(this));

        swapInfo.amountToSend =
            IERC20(swapInfo.buyTokenAddress).balanceOf(address(this)) -
            prevBalanceOfBuyToken;

        swapInfo.totalFeeAmount =
            (usedSellTokenForSwap * swapInfo.totalFee) /
            (1e4 - swapInfo.totalFee);

        IERC20(swapInfo.buyTokenAddress).safeTransfer(
            to,
            swapInfo.amountToSend
        );

        swapInfo.prevBalanceOfToken = address(this).balance;

        //check allowance
        if (
            IERC20(swapInfo.sellTokenAddress).allowance(
                address(this),
                dexRouterAddress
            ) < swapInfo.totalFeeAmount
        ) {
            IERC20(swapInfo.sellTokenAddress).approve(
                dexRouterAddress,
                IERC20(swapInfo.sellTokenAddress).totalSupply()
            );
        }

        IUniswapV2Router02(dexRouterAddress)
            .swapExactTokensForETHSupportingFeeOnTransferTokens(
                swapInfo.totalFeeAmount,
                0,
                sellTokenToWETHpath,
                address(this),
                deadline
            );

        uint256 totalETHFeeAmount = (address(this).balance -
            swapInfo.prevBalanceOfToken);

        if (totalETHFeeAmount > 0) {
            swapInfo.sellTokenFeeAmount =
                (totalETHFeeAmount * swapInfo.sellTokenFee) /
                swapInfo.totalFee;
            swapInfo.platformFeeAmount =
                (totalETHFeeAmount * swapInfo.platformFee) /
                swapInfo.totalFee;

            tokenFeeInfos[swapInfo.sellTokenAddress].feeCollected += swapInfo
                .sellTokenFeeAmount;

            platformFeeInfos.feeCollected += swapInfo.platformFeeAmount;

            if (
                totalETHFeeAmount >=
                (swapInfo.sellTokenFeeAmount + swapInfo.platformFeeAmount)
            ) {
                tokenFeeInfos[swapInfo.buyTokenAddress]
                    .feeCollected += (totalETHFeeAmount -
                    swapInfo.sellTokenFeeAmount -
                    swapInfo.platformFeeAmount);
            }
        }

        withdrawTokenFeeAuto(swapInfo.sellTokenAddress, true);
        withdrawTokenFeeAuto(swapInfo.buyTokenAddress, false);
        withdrawPlatformFeeAuto();

        uint256 leftoverSellToken = 0;
        if (amountInMax >= (usedSellTokenForSwap + swapInfo.totalFeeAmount)) {
            leftoverSellToken =
                amountInMax -
                usedSellTokenForSwap -
                swapInfo.totalFeeAmount;
        }

        // refund leftover SellToken to user
        IERC20(swapInfo.sellTokenAddress).safeTransfer(to, leftoverSellToken);
    }

    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path,
        address account
    ) public view returns (uint256[] memory) {
        require(path.length > 0, "ScaleSwap: Path doesn't exist");

        SwapLocalInfos memory swapInfo;
        swapInfo.sellTokenAddress = path[0];
        swapInfo.buyTokenAddress = path[path.length - 1];
        swapInfo.platformFee = getPlatformFee(account);
        swapInfo.sellTokenFee = tokenFeeInfos[swapInfo.sellTokenAddress]
            .sellTotalFee;
        swapInfo.totalFee = swapInfo.sellTokenFee + swapInfo.platformFee;
        swapInfo.buyTokenFee =
            ((1e4 - swapInfo.totalFee) *
                tokenFeeInfos[swapInfo.buyTokenAddress].buyTotalFee) /
            1e4;

        swapInfo.totalFee = swapInfo.totalFee + swapInfo.buyTokenFee;
        swapInfo.totalFeeAmount = (amountIn * swapInfo.totalFee) / 1e4;

        swapInfo.amountToSwap = amountIn - swapInfo.totalFeeAmount;

        return
            IUniswapV2Router02(dexRouterAddress).getAmountsOut(
                swapInfo.amountToSwap,
                path
            );
    }

    function getAmountsIn(
        uint256 amountOut,
        address[] calldata path,
        address account
    ) public view returns (uint256[] memory) {
        require(path.length > 0, "ScaleSwap: Path doesn't exist");

        SwapLocalInfos memory swapInfo;
        swapInfo.sellTokenAddress = path[0];
        swapInfo.buyTokenAddress = path[path.length - 1];
        swapInfo.platformFee = getPlatformFee(account);
        swapInfo.sellTokenFee = tokenFeeInfos[swapInfo.sellTokenAddress]
            .sellTotalFee;
        swapInfo.buyTokenFee = tokenFeeInfos[swapInfo.buyTokenAddress]
            .buyTotalFee;

        uint256[] memory amounts = IUniswapV2Router02(dexRouterAddress)
            .getAmountsIn(amountOut, path);

        uint256 amountInMax = (amounts[0] * 1e4) /
            (1e4 - swapInfo.sellTokenFee - swapInfo.platformFee);
        amountInMax = (amountInMax * 1e4) / (1e4 - swapInfo.buyTokenFee);

        amounts[0] = amountInMax;
        return amounts;
    }

    function withdrawTokenFeeAuto(address _tokenAddress, bool _isSellToken)
        internal
    {
        uint256 amountToWithdraw = tokenFeeInfos[_tokenAddress].feeCollected -
            tokenFeeInfos[_tokenAddress].feeWithdrew;

        if (amountToWithdraw > 0) {
            uint256 totalFee = tokenFeeInfos[_tokenAddress].buyTotalFee;
            if (_isSellToken)
                totalFee = tokenFeeInfos[_tokenAddress].sellTotalFee;
            for (
                uint256 i = 0;
                i < tokenFeeInfos[_tokenAddress].buyFees.length;
                i++
            ) {
                uint256 fee = tokenFeeInfos[_tokenAddress].buyFees[i];
                if (_isSellToken)
                    fee = tokenFeeInfos[_tokenAddress].sellFees[i];
                if (fee > 0) {
                    uint256 amountForThisFee = (amountToWithdraw * fee) /
                        totalFee;

                    (bool sent, ) = payable(
                        tokenFeeInfos[_tokenAddress].feeReceivers[i]
                    ).call{value: amountForThisFee}("");
                    require(sent);
                }
            }

            tokenFeeInfos[_tokenAddress].feeWithdrew += amountToWithdraw;
        }
    }

    function withdrawPlatformFeeAuto() internal {
        uint256 amountToWithdraw = platformFeeInfos.feeCollected -
            platformFeeInfos.feeWithdrew;

        if (amountToWithdraw > 0) {
            (bool sent, ) = payable(platformFeeInfos.feeReceiver).call{
                value: amountToWithdraw
            }("");
            require(sent);

            platformFeeInfos.feeWithdrew += amountToWithdraw;
        }
    }

    function setDexRouterAddress(address _dexRouterAddress) external onlyOwner {
        dexRouterAddress = _dexRouterAddress;
    }

    function setPlatformFeeReceiver(address recipient) external onlyOwner {
        platformFeeInfos.feeReceiver = recipient;
    }

    function setScaleTokenCA(address ca) external onlyOwner {
        platformFeeInfos.scaleTokenAddress = ca;
    }

    function setMinAmtToHoldScale(uint256 amount) external onlyOwner {
        platformFeeInfos.minAmtToHoldScale = amount;
    }

    function setPlatformFeeAmount(uint256 fee) external onlyOwner {
        platformFeeInfos.minAmtToHoldScale = fee;
    }

    function setPlatformFeeInfos(uint256 feeAmount, address recipient, address scaleTokenCA, uint256 minAmtToHoldScale) external onlyOwner {
        platformFeeInfos.minAmtToHoldScale = feeAmount;
        platformFeeInfos.feeReceiver = recipient;
        platformFeeInfos.scaleTokenAddress = scaleTokenCA;
        platformFeeInfos.minAmtToHoldScale = minAmtToHoldScale;
    }

        function setFeeInfos(
        address tokenCA,
        uint256[] memory sellFees,
        uint256[] memory buyFees,
        address[] memory feeReceivers
    ) external {
        require(
            sellFees.length == buyFees.length,
            "Fee Length is not same"
        );
        require(
            sellFees.length == feeReceivers.length,
            "Length is not same"
        );

        tokenFeeInfos[tokenCA].sellFees = sellFees;
        tokenFeeInfos[tokenCA].buyFees = buyFees;
        tokenFeeInfos[tokenCA].feeReceivers = feeReceivers;
        uint256 buyFeeTotal;
        uint256 sellFeeTotal;
        for (uint256 i = 0; i < sellFees.length; i++) {
            buyFeeTotal += buyFees[i];
            sellFeeTotal += sellFees[i];
        }

        require(
            buyFeeTotal <= 5000 && sellFeeTotal <= 5000,
            "Exceeds max fee"
        );

        tokenFeeInfos[tokenCA].buyTotalFee = buyFeeTotal;
        tokenFeeInfos[tokenCA].sellTotalFee = sellFeeTotal;
    }

    function withdrawToken(address _tokenAddress) external onlyOwner {
        uint256 bal = 0;
        if (_tokenAddress == IUniswapV2Router02(dexRouterAddress).WETH()) {
            //eth
            bal = address(this).balance;
            require(bal > 0, "ScaleSwap: No ETH");
            (bool sent, ) = payable(msg.sender).call{value: bal}("");
            require(sent);
        } else {
            bal = IERC20(_tokenAddress).balanceOf(address(this));
            require(bal > 0, "ScaleSwap: No tokens");
            IERC20(_tokenAddress).safeTransfer(msg.sender, bal);
        }
    }

    //to receive ETH from dexRouter when swapping
    receive() external payable {}
}