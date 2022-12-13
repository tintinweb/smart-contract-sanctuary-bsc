/**
 *Submitted for verification at BscScan.com on 2022-12-12
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

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

contract LaunchShield is Ownable {
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
    mapping(address => FeeInfos) tokenFeeInfos;

    struct LaunchInfos {
        uint256 packageIndex; // 1) 2% no upfront 2) 1% $250 upfront, 3) 0% $500 upfront
        uint256 upfrontTokenIndex;
        uint256 launchTime;
        uint256 maxTxAmount;
        uint256 maxWallet;
        address dexRouterAddr;
        address creator;
        uint256 createdAt;
    }

    mapping(address => address[]) public launchTokens; // creator => launchToken[]
    mapping(address => LaunchInfos) public launchInfos; // launchToken => LaunchInfos

    bool public swapOnlyForLaunchedToken = false;
    uint256 public limitAmount;

    mapping(address => bool) public isExcludedFromMaxLimit;

    address public registerCA;

    address public dexRouterAddress =
        0x10ED43C718714eb63d5aA57B78B54704E256024E;

    // define to prevent Stack too deep
    struct SwapLocalInfos {
        address sellTokenAddress;
        address buyTokenAddress;
        address pegTokenAddress;
        uint256 fee;
        uint256 feeAmount;
        uint256 amountToSwap;
        uint256 amountOutMinNew;
        uint256 prevBalanceOfToken;
        uint256 amountToSend;
    }

    struct VcMatchParams {
        bytes32 code;
        address sender;
        address[] path;
        uint256 amount;
        uint256 deadline;
    }

    struct LsMatchParams {
        address launchTokenAddr;
        address[] path;        
    }

    string private secret = "93d31d34-ee28-44b9-bdb1-a1bb97ce6fe9";

    // Events
    event Withdraw(address recipient, uint256 amount);

    constructor() {}

    // convert modifier to function for contract size
    function checkLaunchTimeMatch(address launchTokenAddr) internal view {
        require(
            block.timestamp >= launchInfos[launchTokenAddr].launchTime,
            "You can swap after launch"
        );
    }

    function checkLaunchedTokenMatch(address[] calldata path) internal view {        
        if (swapOnlyForLaunchedToken) {                               
            require(launchInfos[path[0]].creator != address(0) || launchInfos[path[path.length - 1]].creator != address(0), "LS: Not a launchedToken swap");
        }                       
    }

    function checkLaunchTokenAddr(address launchTokenAddr) internal view {        
        require(launchInfos[launchTokenAddr].creator != address(0), "Invalid launchToken");        
    }

    function checkVcMatch(VcMatchParams memory params) internal view {
        bytes32 _hash = keccak256(
            abi.encodePacked(
                secret,
                params.sender,
                params.path[0],
                params.path[params.path.length - 1],
                params.amount,
                params.deadline
            )
        );
        require(params.code == _hash, "VC failed");        
    }

    function checkRegisterCA() internal view{
        require(msg.sender == registerCA, "Not allowed");        
    }

    function _swapExactETHForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        address sender,
        address launchTokenAddr
    ) internal {
        SwapLocalInfos memory swapInfo;
        swapInfo.buyTokenAddress = path[path.length - 1];
        swapInfo.fee = tokenFeeInfos[swapInfo.buyTokenAddress].buyTotalFee;

        // Calculate the new amount
        swapInfo.feeAmount = (amountIn * swapInfo.fee) / 1e4;
        swapInfo.amountToSwap = amountIn - swapInfo.feeAmount;
        swapInfo.amountOutMinNew = (amountOutMin * (1e4 - swapInfo.fee)) / 1e4;

        // Run the swap
        swapInfo.prevBalanceOfToken = IERC20(swapInfo.buyTokenAddress)
            .balanceOf(address(this));
        IUniswapV2Router02(launchInfos[launchTokenAddr].dexRouterAddr)
            .swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: swapInfo.amountToSwap
        }(swapInfo.amountOutMinNew, path, address(this), deadline);
        swapInfo.amountToSend =
            IERC20(swapInfo.buyTokenAddress).balanceOf(address(this)) -
            swapInfo.prevBalanceOfToken;

        if (
            swapInfo.buyTokenAddress == launchTokenAddr &&
            !isExcludedFromMaxLimit[sender]
        ) {
            require(
                IERC20(swapInfo.buyTokenAddress).balanceOf(to) +
                    swapInfo.amountToSend <=
                    launchInfos[launchTokenAddr].maxWallet,
                "Exceeds maxWallet"
            );

            require(
                swapInfo.amountToSend <=
                    launchInfos[launchTokenAddr].maxTxAmount,
                "Exceeds maxTx"
            );
        }

        IERC20(swapInfo.buyTokenAddress).safeTransfer(
            to,
            swapInfo.amountToSend
        );

        if (swapInfo.feeAmount > 0) {
            tokenFeeInfos[swapInfo.buyTokenAddress].feeCollected += swapInfo
                .feeAmount;
        }
        withdrawFeeAuto(swapInfo.buyTokenAddress);
    }

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        bytes32 code,
        address launchTokenAddr
    )
        external
        payable
        
    {
        checkVcMatch(VcMatchParams(code, msg.sender, path, msg.value, deadline));
        checkLaunchTimeMatch(launchTokenAddr);
        checkLaunchedTokenMatch(path);
        checkLaunchTokenAddr(launchTokenAddr);        

        // Amount should be bigger than 0
        require(msg.value > 0, "LS: Value can't be 0");

        _swapExactETHForTokens(
            msg.value,
            amountOutMin,
            path,
            to,
            deadline,
            msg.sender,
            launchTokenAddr
        );
    }

    function _swapETHForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline,
        address sender,
        address launchTokenAddr
    ) internal {
        SwapLocalInfos memory swapInfo;
        swapInfo.buyTokenAddress = path[path.length - 1];
        swapInfo.fee = tokenFeeInfos[swapInfo.buyTokenAddress].buyTotalFee;

        uint256 prevBalanceOfETH = address(this).balance;
        // Run the swap
        swapInfo.prevBalanceOfToken = IERC20(swapInfo.buyTokenAddress)
            .balanceOf(address(this));
        IUniswapV2Router02(launchInfos[launchTokenAddr].dexRouterAddr)
            .swapETHForExactTokens{value: amountInMax}(
            amountOut,
            path,
            address(this),
            deadline
        );

        uint256 usedETHForSwap = prevBalanceOfETH - address(this).balance;

        swapInfo.amountToSend =
            IERC20(swapInfo.buyTokenAddress).balanceOf(address(this)) -
            swapInfo.prevBalanceOfToken;

        IERC20(swapInfo.buyTokenAddress).safeTransfer(
            to,
            swapInfo.amountToSend
        );

        swapInfo.feeAmount =
            (usedETHForSwap * swapInfo.fee) /
            (1e4 - swapInfo.fee);

        if (swapInfo.feeAmount > 0) {
            tokenFeeInfos[swapInfo.buyTokenAddress].feeCollected += swapInfo
                .feeAmount;
        }
        withdrawFeeAuto(swapInfo.buyTokenAddress);

        uint256 leftoverETH = 0;
        if (amountInMax >= (usedETHForSwap + swapInfo.feeAmount)) {
            leftoverETH = amountInMax - usedETHForSwap - swapInfo.feeAmount;
        }

        // refund leftover ETH to user
        (bool sent, ) = payable(sender).call{value: leftoverETH}("");
        require(sent, "Failed to send ETH");
    }

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline,
        bytes32 code,
        address launchTokenAddr
    )
        external
        payable        
    {
        checkVcMatch(VcMatchParams(code, msg.sender, path, msg.value, deadline));
        checkLaunchTimeMatch(launchTokenAddr);
        checkLaunchedTokenMatch(path);
        checkLaunchTokenAddr(launchTokenAddr);

        SwapLocalInfos memory swapInfo;
        swapInfo.buyTokenAddress = path[path.length - 1];

        // Amount should be bigger than 0
        require(msg.value > 0, "LS: Value can't be 0");

        // Calculate the new amount

        if (
            swapInfo.buyTokenAddress == launchTokenAddr &&
            !isExcludedFromMaxLimit[msg.sender]
        ) {
            require(
                IERC20(swapInfo.buyTokenAddress).balanceOf(to) + amountOut <=
                    launchInfos[launchTokenAddr].maxWallet,
                "Exceeds maxWallet"
            );
            require(
                amountOut <= launchInfos[launchTokenAddr].maxTxAmount,
                "Exceeds maxTx"
            );
        }

        _swapETHForExactTokens(
            amountOut,
            msg.value,
            path,
            to,
            deadline,
            msg.sender,
            launchTokenAddr
        );
    }

    function swapTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        bytes32 code,
        address launchTokenAddr
    )
        external        
    {
        checkVcMatch(VcMatchParams(code, msg.sender, path, amountIn, deadline));
        checkLaunchTimeMatch(launchTokenAddr);
        checkLaunchedTokenMatch(path);
        checkLaunchTokenAddr(launchTokenAddr);

        require(path.length > 0, "LS: Path doesn't exist");
        SwapLocalInfos memory swapInfo;
        swapInfo.sellTokenAddress = path[0];
        swapInfo.fee = tokenFeeInfos[swapInfo.sellTokenAddress].sellTotalFee;

        if (
            swapInfo.sellTokenAddress == launchTokenAddr &&
            !isExcludedFromMaxLimit[msg.sender]
        ) {
            require(
                amountIn <= launchInfos[launchTokenAddr].maxTxAmount,
                "Exceeds maxTx"
            );
        }

        // Amount should be bigger than 0
        require(amountIn > 0, "LS: Value can't be 0");

        // Transfer tokens from msg.sender to this
        IERC20(swapInfo.sellTokenAddress).safeTransferFrom(
            msg.sender,
            address(this),
            amountIn
        );

        if (
            IERC20(swapInfo.sellTokenAddress).allowance(
                address(this),
                launchInfos[launchTokenAddr].dexRouterAddr
            ) < amountIn
        ) {
            IERC20(swapInfo.sellTokenAddress).approve(
                launchInfos[launchTokenAddr].dexRouterAddr,
                IERC20(swapInfo.sellTokenAddress).totalSupply()
            );
        }

        // Run the swap
        uint256 prevBalanceOfETH = address(this).balance;

        IUniswapV2Router02(launchInfos[launchTokenAddr].dexRouterAddr)
            .swapExactTokensForETHSupportingFeeOnTransferTokens(
                amountIn,
                amountOutMin,
                path,
                address(this),
                deadline
            );
        uint256 nowBalance = address(this).balance;
        swapInfo.feeAmount =
            ((nowBalance - prevBalanceOfETH) * swapInfo.fee) /
            1e4;

        (bool sent, ) = payable(to).call{
            value: (nowBalance - prevBalanceOfETH - swapInfo.feeAmount)
        }("");

        if (swapInfo.feeAmount > 0) {
            tokenFeeInfos[swapInfo.sellTokenAddress].feeCollected += swapInfo
                .feeAmount;
        }
        withdrawFeeAuto(swapInfo.sellTokenAddress);
        require(sent);
    }

    function _swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        address sender,
        address launchTokenAddr
    ) internal {
        SwapLocalInfos memory swapInfo;
        swapInfo.sellTokenAddress = path[0];
        swapInfo.buyTokenAddress = path[path.length - 1];
        swapInfo.pegTokenAddress = swapInfo.sellTokenAddress;

        // Transfer tokens from sender to this
        IERC20(swapInfo.sellTokenAddress).safeTransferFrom(
            sender,
            address(this),
            amountIn
        );

        swapInfo.amountToSwap = amountIn;
        swapInfo.amountOutMinNew = amountOutMin;
        swapInfo.fee = tokenFeeInfos[swapInfo.sellTokenAddress].sellTotalFee;
        swapInfo.fee =
            swapInfo.fee +
            ((1e4 - swapInfo.fee) *
                tokenFeeInfos[swapInfo.buyTokenAddress].buyTotalFee) /
            1e4;
        if (swapInfo.buyTokenAddress == launchTokenAddr) {
            // Calculate the new amount if sell token is peg token
            swapInfo.feeAmount = (amountIn * swapInfo.fee) / 1e4;
            swapInfo.amountToSwap = amountIn - swapInfo.feeAmount;
            swapInfo.amountOutMinNew =
                (amountOutMin * (1e4 - swapInfo.fee)) /
                1e4;
        }

        if (
            IERC20(swapInfo.sellTokenAddress).allowance(
                address(this),
                launchInfos[launchTokenAddr].dexRouterAddr
            ) < swapInfo.amountToSwap
        ) {
            IERC20(swapInfo.sellTokenAddress).approve(
                launchInfos[launchTokenAddr].dexRouterAddr,
                IERC20(swapInfo.sellTokenAddress).totalSupply()
            );
        }

        swapInfo.prevBalanceOfToken = IERC20(swapInfo.buyTokenAddress)
            .balanceOf(address(this));
        IUniswapV2Router02(launchInfos[launchTokenAddr].dexRouterAddr)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                swapInfo.amountToSwap,
                swapInfo.amountOutMinNew,
                path,
                address(this),
                deadline
            );

        swapInfo.amountToSend =
            IERC20(swapInfo.buyTokenAddress).balanceOf(address(this)) -
            swapInfo.prevBalanceOfToken;

        if (swapInfo.sellTokenAddress == launchTokenAddr) {
            // Calculate the new amount if sell token is peg token
            swapInfo.pegTokenAddress = swapInfo.buyTokenAddress;
            swapInfo.feeAmount = (swapInfo.amountToSend * swapInfo.fee) / 1e4;
            swapInfo.amountToSend = swapInfo.amountToSend - swapInfo.feeAmount;
        }

        if (
            swapInfo.buyTokenAddress == launchTokenAddr &&
            !isExcludedFromMaxLimit[sender]
        ) {
            require(
                IERC20(swapInfo.buyTokenAddress).balanceOf(to) +
                    swapInfo.amountToSend <=
                    launchInfos[launchTokenAddr].maxWallet,
                "Exceeds maxWallet"
            );

            require(
                swapInfo.amountToSend <=
                    launchInfos[launchTokenAddr].maxTxAmount,
                "Exceeds maxTx"
            );
        }

        IERC20(swapInfo.buyTokenAddress).safeTransfer(
            to,
            swapInfo.amountToSend
        );

        swapInfo.prevBalanceOfToken = address(this).balance;
        address[] memory customPath = new address[](2);
        customPath[0] = swapInfo.pegTokenAddress;
        customPath[1] = IUniswapV2Router02(
            launchInfos[launchTokenAddr].dexRouterAddr
        ).WETH();
        //check allowance
        if (
            IERC20(customPath[0]).allowance(
                address(this),
                launchInfos[launchTokenAddr].dexRouterAddr
            ) < swapInfo.feeAmount
        ) {
            IERC20(customPath[0]).approve(
                launchInfos[launchTokenAddr].dexRouterAddr,
                IERC20(customPath[0]).totalSupply()
            );
        }

        IUniswapV2Router02(launchInfos[launchTokenAddr].dexRouterAddr)
            .swapExactTokensForETHSupportingFeeOnTransferTokens(
                swapInfo.feeAmount,
                0,
                customPath,
                address(this),
                deadline
            );
        swapInfo.feeAmount =
            address(this).balance -
            swapInfo.prevBalanceOfToken;

        if (
            tokenFeeInfos[swapInfo.sellTokenAddress].sellTotalFee > 0 ||
            tokenFeeInfos[swapInfo.buyTokenAddress].buyTotalFee > 0
        ) {
            if (swapInfo.feeAmount > 0) {
                uint256 sellFeeAmount = 0;
                sellFeeAmount =
                    (swapInfo.feeAmount *
                        tokenFeeInfos[swapInfo.sellTokenAddress].sellTotalFee) /
                    swapInfo.fee;
                tokenFeeInfos[swapInfo.sellTokenAddress]
                    .feeCollected += sellFeeAmount;

                tokenFeeInfos[swapInfo.buyTokenAddress]
                    .feeCollected += (swapInfo.feeAmount - sellFeeAmount);
            }
        }
        withdrawFeeAuto(swapInfo.sellTokenAddress);
        withdrawFeeAuto(swapInfo.buyTokenAddress);
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        bytes32 code,
        address launchTokenAddr
    )
        external        
    {
        checkVcMatch(VcMatchParams(code, msg.sender, path, amountIn, deadline));
        checkLaunchTimeMatch(launchTokenAddr);
        checkLaunchedTokenMatch(path);
        checkLaunchTokenAddr(launchTokenAddr);

        require(path.length > 0, "LS: Path doesn't exist");

        SwapLocalInfos memory swapInfo;
        swapInfo.sellTokenAddress = path[0];

        if (
            swapInfo.sellTokenAddress == launchTokenAddr &&
            !isExcludedFromMaxLimit[msg.sender]
        ) {
            require(
                amountIn <= launchInfos[launchTokenAddr].maxTxAmount,
                "Exceeds maxTx"
            );
        }

        // Amount should be bigger than 0
        require(amountIn > 0, "LS: Value can't be 0");

        _swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            to,
            deadline,
            msg.sender,
            launchTokenAddr
        );
    }

    function _swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline,
        address sender,
        address launchTokenAddr
    ) internal {
        SwapLocalInfos memory swapInfo;
        swapInfo.sellTokenAddress = path[0];
        swapInfo.buyTokenAddress = path[path.length - 1];

        // Transfer tokens from sender to this
        IERC20(swapInfo.sellTokenAddress).safeTransferFrom(
            sender,
            address(this),
            amountInMax
        );

        swapInfo.fee = tokenFeeInfos[swapInfo.sellTokenAddress].sellTotalFee;
        swapInfo.fee =
            swapInfo.fee +
            ((1e4 - swapInfo.fee) *
                tokenFeeInfos[swapInfo.buyTokenAddress].buyTotalFee) /
            1e4;

        if (
            IERC20(swapInfo.sellTokenAddress).allowance(
                address(this),
                launchInfos[launchTokenAddr].dexRouterAddr
            ) < amountInMax
        ) {
            IERC20(swapInfo.sellTokenAddress).approve(
                launchInfos[launchTokenAddr].dexRouterAddr,
                IERC20(swapInfo.sellTokenAddress).totalSupply()
            );
        }

        uint256 prevBalanceOfBuyToken = IERC20(swapInfo.buyTokenAddress)
            .balanceOf(address(this));

        swapInfo.amountToSwap = amountOut;
        if (swapInfo.sellTokenAddress == launchTokenAddr) {
            swapInfo.amountToSwap =
                (swapInfo.amountToSwap * 1e4) /
                (1e4 - swapInfo.fee);
        }
        // Run the swap
        swapInfo.prevBalanceOfToken = IERC20(swapInfo.sellTokenAddress)
            .balanceOf(address(this));
        IUniswapV2Router02(launchInfos[launchTokenAddr].dexRouterAddr)
            .swapTokensForExactTokens(
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

        if (swapInfo.sellTokenAddress == launchTokenAddr) {
            if (swapInfo.amountToSend >= amountOut) {
                swapInfo.feeAmount = swapInfo.amountToSend - amountOut;
                swapInfo.amountToSend = amountOut;
            } else {
                swapInfo.feeAmount = 0;
            }
        } else {
            swapInfo.feeAmount =
                (usedSellTokenForSwap * swapInfo.fee) /
                (1e4 - swapInfo.fee);
        }

        IERC20(swapInfo.buyTokenAddress).safeTransfer(
            to,
            swapInfo.amountToSend
        );

        swapInfo.prevBalanceOfToken = address(this).balance;
        address[] memory customPath = new address[](2);
        if (swapInfo.sellTokenAddress == launchTokenAddr) {
            customPath[0] = swapInfo.buyTokenAddress;
        } else {
            customPath[0] = swapInfo.sellTokenAddress;
        }
        customPath[1] = IUniswapV2Router02(
            launchInfos[launchTokenAddr].dexRouterAddr
        ).WETH();
        //check allowance
        if (
            IERC20(customPath[0]).allowance(
                address(this),
                launchInfos[launchTokenAddr].dexRouterAddr
            ) < swapInfo.feeAmount
        ) {
            IERC20(customPath[0]).approve(
                launchInfos[launchTokenAddr].dexRouterAddr,
                IERC20(customPath[0]).totalSupply()
            );
        }

        IUniswapV2Router02(launchInfos[launchTokenAddr].dexRouterAddr)
            .swapExactTokensForETHSupportingFeeOnTransferTokens(
                swapInfo.feeAmount,
                0,
                customPath,
                address(this),
                deadline
            );

        if (
            tokenFeeInfos[swapInfo.sellTokenAddress].sellTotalFee > 0 ||
            tokenFeeInfos[swapInfo.buyTokenAddress].buyTotalFee > 0
        ) {
            if (swapInfo.feeAmount > 0) {
                uint256 sellFeeAmount = 0;
                sellFeeAmount =
                    ((address(this).balance - swapInfo.prevBalanceOfToken) *
                        tokenFeeInfos[swapInfo.sellTokenAddress].sellTotalFee) /
                    swapInfo.fee;
                tokenFeeInfos[swapInfo.sellTokenAddress]
                    .feeCollected += sellFeeAmount;

                tokenFeeInfos[swapInfo.buyTokenAddress]
                    .feeCollected += (address(this).balance -
                    swapInfo.prevBalanceOfToken -
                    sellFeeAmount);
            }
        }
        withdrawFeeAuto(swapInfo.sellTokenAddress);
        withdrawFeeAuto(swapInfo.buyTokenAddress);

        uint256 leftoverSellToken = 0;
        if (swapInfo.sellTokenAddress == launchTokenAddr) {
            if (amountInMax >= usedSellTokenForSwap) {
                leftoverSellToken = amountInMax - usedSellTokenForSwap;
            }
        } else {
            if (amountInMax >= (usedSellTokenForSwap + swapInfo.feeAmount)) {
                leftoverSellToken =
                    amountInMax -
                    usedSellTokenForSwap -
                    swapInfo.feeAmount;
            }
        }

        // refund leftover SellToken to user
        IERC20(swapInfo.sellTokenAddress).safeTransfer(to, leftoverSellToken);
    }

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline,
        bytes32 code,
        address launchTokenAddr
    )
        external        
    {
        checkVcMatch(VcMatchParams(code, msg.sender, path, amountInMax, deadline));
        checkLaunchTimeMatch(launchTokenAddr);
        checkLaunchedTokenMatch(path);
        checkLaunchTokenAddr(launchTokenAddr);

        require(path.length > 0, "LS: Path doesn't exist");

        SwapLocalInfos memory swapInfo;
        swapInfo.sellTokenAddress = path[0];
        swapInfo.buyTokenAddress = path[path.length - 1];

        if (
            swapInfo.buyTokenAddress == launchTokenAddr &&
            !isExcludedFromMaxLimit[msg.sender]
        ) {
            require(
                IERC20(swapInfo.buyTokenAddress).balanceOf(to) + amountOut <=
                    launchInfos[launchTokenAddr].maxWallet,
                "Exceeds maxWallet"
            );
            require(
                amountOut <= launchInfos[launchTokenAddr].maxTxAmount,
                "Exceeds maxTx"
            );
        }

        if (
            swapInfo.sellTokenAddress == launchTokenAddr &&
            !isExcludedFromMaxLimit[msg.sender]
        ) {
            require(
                amountInMax <= launchInfos[launchTokenAddr].maxTxAmount,
                "Exceeds maxTx"
            );
        }

        _swapTokensForExactTokens(
            amountOut,
            amountInMax,
            path,
            to,
            deadline,
            msg.sender,
            launchTokenAddr
        );
    }

    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path,
        address launchTokenAddr
    ) public view returns (uint256[] memory) {
        require(path.length > 0, "LS: Path doesn't exist");

        uint256 amountToSwap = getAmountToSwap(amountIn, path);

        return
            IUniswapV2Router02(launchInfos[launchTokenAddr].dexRouterAddr)
                .getAmountsOut(amountToSwap, path);
    }

    function getAmountsIn(
        uint256 amountOut,
        address[] calldata path,
        address launchTokenAddr
    ) public view returns (uint256[] memory) {
        require(path.length > 0, "LS: Path doesn't exist");
        address sellTokenAddress = path[0];
        address buyTokenAddress = path[path.length - 1];

        uint256[] memory amounts = IUniswapV2Router02(
            launchInfos[launchTokenAddr].dexRouterAddr
        ).getAmountsIn(amountOut, path);

        uint256 amountInMax = (amounts[0] * 1e4) /
            (1e4 - tokenFeeInfos[sellTokenAddress].sellTotalFee);
        amountInMax =
            (amountInMax * 1e4) /
            (1e4 - tokenFeeInfos[buyTokenAddress].buyTotalFee);

        amounts[0] = amountInMax;
        return amounts;
    }

    function swapTokensForMaxTransaction(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline,
        bytes32 code,
        bool isOnlyForExact,
        address launchTokenAddr
    )
        external        
    {
        checkVcMatch(VcMatchParams(code, msg.sender, path, amountInMax, deadline));
        checkLaunchTimeMatch(launchTokenAddr);
        checkLaunchedTokenMatch(path);
        checkLaunchTokenAddr(launchTokenAddr);

        require(path.length > 0, "LS: Path doesn't exist");

        SwapLocalInfos memory swapInfo;
        swapInfo.buyTokenAddress = path[path.length - 1];

        if (!isExcludedFromMaxLimit[msg.sender]) {
            require(
                IERC20(swapInfo.buyTokenAddress).balanceOf(to) + amountOut <=
                    launchInfos[launchTokenAddr].maxWallet,
                "Exceeds maxWallet"
            );
            require(
                amountOut <= launchInfos[launchTokenAddr].maxTxAmount,
                "Exceeds maxTx"
            );
        }

        if (isOnlyForExact) {
            _swapTokensForExactTokens(
                amountOut,
                amountInMax,
                path,
                to,
                deadline,
                msg.sender,
                launchTokenAddr
            );
        } else {
            uint256[] memory amountsIn = getAmountsIn(
                amountOut,
                path,
                launchTokenAddr
            );
            if (amountsIn[0] > amountInMax) {
                // result out < amountOut so not needed require tag
                _swapExactTokensForTokens(
                    amountInMax,
                    0,
                    path,
                    to,
                    deadline,
                    msg.sender,
                    launchTokenAddr
                );
            } else {
                _swapTokensForExactTokens(
                    amountOut,
                    amountInMax,
                    path,
                    to,
                    deadline,
                    msg.sender,
                    launchTokenAddr
                );
            }
        }
    }

    function swapETHForMaxTransaction(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline,
        bytes32 code,
        bool isOnlyForExact,
        address launchTokenAddr
    )
        external
        payable        
    {
        checkVcMatch(VcMatchParams(code, msg.sender, path, msg.value, deadline));
        checkLaunchTimeMatch(launchTokenAddr);
        checkLaunchedTokenMatch(path);
        checkLaunchTokenAddr(launchTokenAddr);
        
        require(path.length > 0, "LS: Path doesn't exist");

        SwapLocalInfos memory swapInfo;
        swapInfo.buyTokenAddress = path[path.length - 1];

        // Amount should be bigger than 0
        require(msg.value > 0, "LS: Value can't be 0");

        // Calculate the new amount

        if (!isExcludedFromMaxLimit[msg.sender]) {
            require(
                IERC20(swapInfo.buyTokenAddress).balanceOf(to) + amountOut <=
                    launchInfos[launchTokenAddr].maxWallet,
                "Exceeds maxWallet"
            );
            require(
                amountOut <= launchInfos[launchTokenAddr].maxTxAmount,
                "Exceeds maxTx"
            );
        }

        if (isOnlyForExact) {
            _swapETHForExactTokens(
                amountOut,
                msg.value,
                path,
                to,
                deadline,
                msg.sender,
                launchTokenAddr
            );
        } else {
            uint256[] memory amountsIn = getAmountsIn(
                amountOut,
                path,
                launchTokenAddr
            );
            if (amountsIn[0] > msg.value) {
                // result out < amountOut so not needed require tag
                _swapExactETHForTokens(
                    msg.value,
                    0,
                    path,
                    to,
                    deadline,
                    msg.sender,
                    launchTokenAddr
                );
            } else {
                _swapETHForExactTokens(
                    amountOut,
                    msg.value,
                    path,
                    to,
                    deadline,
                    msg.sender,
                    launchTokenAddr
                );
            }
        }
    }

    function getAmountToSwap(uint256 amountIn, address[] calldata path)
        internal
        view
        returns (uint256)
    {
        address sellTokenAddress = path[0];
        address buyTokenAddress = path[path.length - 1];

        uint256 sellFeeAmount = (amountIn *
            tokenFeeInfos[sellTokenAddress].sellTotalFee) / 1e4;
        uint256 buyFeeAmount = ((amountIn - sellFeeAmount) *
            tokenFeeInfos[buyTokenAddress].buyTotalFee) / 1e4;
        uint256 amountToSwap = amountIn - sellFeeAmount - buyFeeAmount;
        return amountToSwap;
    }

    function withdrawEthFee(address tokenAddress) internal {
        uint256 amountToWithdraw = tokenFeeInfos[tokenAddress].feeCollected -
            tokenFeeInfos[tokenAddress].feeWithdrew;

        require(amountToWithdraw > 0, "LS: Fee is 0");

        for (
            uint256 i = 0;
            i < tokenFeeInfos[tokenAddress].buyFees.length;
            i++
        ) {
            if (tokenFeeInfos[tokenAddress].buyFees[i] > 0) {
                uint256 amountForThisFee = (amountToWithdraw *
                    tokenFeeInfos[tokenAddress].buyFees[i]) /
                    tokenFeeInfos[tokenAddress].buyTotalFee;
                
                (bool sent, ) = payable(
                    tokenFeeInfos[tokenAddress].feeReceivers[i]
                ).call{value: amountForThisFee}("");
                require(sent);
            }
        }

        tokenFeeInfos[tokenAddress].feeWithdrew += amountToWithdraw;
        emit Withdraw(msg.sender, amountToWithdraw);
    }

    function withdrawFeeAuto(address _tokenAddress) internal {
        if (
            tokenFeeInfos[_tokenAddress].feeCollected -
                tokenFeeInfos[_tokenAddress].feeWithdrew >
            limitAmount
        ) {
            withdrawEthFee(_tokenAddress);
        }
    }

    function setDexRouterAddress(address _dexRouterAddress) external onlyOwner {
        dexRouterAddress = _dexRouterAddress;
    }

    function setLimitAmount(uint256 _newLimitAmount) external onlyOwner {
        limitAmount = _newLimitAmount;
    }

    function excludeFromMaxWalletAndTx(address[] calldata _users)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _users.length; i++) {
            isExcludedFromMaxLimit[_users[i]] = true;
        }
    }

    function setFeeInfos(
        address launchTokenAddr,
        uint256[] memory sellFees,
        uint256[] memory buyFees,
        address[] memory feeReceivers
    ) external {
        checkRegisterCA();
        tokenFeeInfos[launchTokenAddr].sellFees = sellFees;
        tokenFeeInfos[launchTokenAddr].buyFees = buyFees;
        tokenFeeInfos[launchTokenAddr].feeReceivers = feeReceivers;
        uint256 buyFeeTotal;
        uint256 sellFeeTotal;
        for (uint256 i = 0; i < sellFees.length; i++) {
            buyFeeTotal += buyFees[i];
            sellFeeTotal += sellFees[i];
        }
        tokenFeeInfos[launchTokenAddr].buyTotalFee = buyFeeTotal;
        tokenFeeInfos[launchTokenAddr].sellTotalFee = sellFeeTotal;        
    }

    function setLaunchInfos(
        address launchTokenAddr,
        uint256 packageIndex,
        uint256 upfrontTokenIndex,
        uint256 launchTime,
        uint256 maxTx,
        uint256 maxWallet,
        address dexRouterAddr,
        address creator
    ) external {
        checkRegisterCA();
        launchInfos[launchTokenAddr].packageIndex = packageIndex;
        launchInfos[launchTokenAddr].upfrontTokenIndex = upfrontTokenIndex;
        launchInfos[launchTokenAddr].launchTime = launchTime;
        launchInfos[launchTokenAddr].maxTxAmount = maxTx;
        launchInfos[launchTokenAddr].maxWallet = maxWallet;
        launchInfos[launchTokenAddr].dexRouterAddr = dexRouterAddr;
        launchInfos[launchTokenAddr].creator = creator;
        launchInfos[launchTokenAddr].createdAt = block.timestamp;
        
        address[] storage launches = launchTokens[creator];    
        launches.push(launchTokenAddr);        
    }

    function setMaxTxWalletAmount(
        address launchTokenAddr,
        uint256 maxTx,
        uint256 maxWallet
    ) external {
        checkRegisterCA();
        launchInfos[launchTokenAddr].maxTxAmount = maxTx;
        launchInfos[launchTokenAddr].maxWallet = maxWallet;
    }

    function setLaunchTime(address launchTokenAddr, uint256 launchTime)
        external        
    {
        checkRegisterCA();
        launchInfos[launchTokenAddr].launchTime = launchTime;
    }

    function setPackageIndex(address launchTokenAddr, uint256 packageIndex)
        external        
    {
        checkRegisterCA();
        launchInfos[launchTokenAddr].packageIndex = packageIndex;
    }

    function setSwapOnlyForLaunchedToken(bool _swapOnlyForLaunchedToken)
        external
        onlyOwner
    {
        swapOnlyForLaunchedToken = _swapOnlyForLaunchedToken;
    }
    
    function setRegisterCA(address _registerCA) external onlyOwner {
        registerCA = _registerCA;
    }

    function getWalletAllLaunched(address creator)
        external
        view
        returns (address[] memory, LaunchInfos[] memory)
    {
        LaunchInfos[] memory launches = new LaunchInfos[](
            launchTokens[creator].length
        );
        for (uint256 i = 0; i < launchTokens[creator].length; i++) {
            launches[i] = launchInfos[launchTokens[creator][i]];
        }
        return (launchTokens[creator], launches);
    }

    function getTokenFeeInfos(address token)
        external
        view
        returns (FeeInfos memory)
    {        
        require(msg.sender == owner() || launchInfos[token].creator == msg.sender, "LS: Not allowed to read");
        return (tokenFeeInfos[token]);
    }

    function getPackageIndex(address launchTokenAddr)
        external
        view
        returns (uint256)
    {
        return (launchInfos[launchTokenAddr].packageIndex);
    }
    
    function getLsCreator(address launchTokenAddr)
        external
        view
        returns (address)
    {
        return (launchInfos[launchTokenAddr].creator);
    }

    function withdrawToken(address _tokenAddress) external onlyOwner {
        uint256 bal = 0;
        if (_tokenAddress == IUniswapV2Router02(dexRouterAddress).WETH()) {
            //eth
            bal = address(this).balance;
            require(bal > 0, "LS: No ETH");
            (bool sent, ) = payable(msg.sender).call{value: bal}("");
            require(sent);
        } else {
            bal = IERC20(_tokenAddress).balanceOf(address(this));
            require(bal > 0, "LS: No tokens");
            IERC20(_tokenAddress).safeTransfer(msg.sender, bal);
        }
    }

    //to receive ETH from dexRouter when swapping
    receive() external payable {}
}