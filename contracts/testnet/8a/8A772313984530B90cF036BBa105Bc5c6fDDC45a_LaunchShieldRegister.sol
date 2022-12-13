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

    function decimals() external view returns (uint256);

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

interface ILaunchShield {
    function setLaunchInfos(
        address launchTokenAddr,
        uint256 packageIndex,
        uint256 upfrontTokenIndex,
        uint256 launchTime,
        uint256 maxTx,
        uint256 maxWallet,
        address dexRouterAddr,
        address creator
    ) external;

    function setFeeInfos(
        address launchTokenAddr,
        uint256[] memory sellFees,
        uint256[] memory buyFees,
        address[] memory feeReceivers
    ) external;

    function setMaxTxWalletAmount(
        address launchTokenAddr,
        uint256 maxTx,
        uint256 maxWallet
    ) external;

    function setLaunchTime(address launchTokenAddr, uint256 launchTime)
        external;

    function setPackageIndex(address launchTokenAddr, uint256 packageIndex)
        external;

    function getPackageIndex(address launchTokenAddr)
        external
        view
        returns (uint256);

    function getLsCreator(address launchTokenAddr)
        external
        view
        returns (address);
}

contract LaunchShieldRegister is Ownable {
    using SafeERC20 for IERC20;

    address public dexRouterAddress =
        0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public usdtAddress = 0x55d398326f99059fF775485246999027B3197955;

    struct PackageInfos {
        uint256 percentOfTxFee; // %
        uint256 upfrontAmount; // usd (no wei or no decimals)
    }
    mapping(uint256 => PackageInfos) public packageInfos; // id => packageInfo
    uint256 public totalPackages;

    struct UpfrontTokenInfos {
        bool isStableCoin; // isStableCoin = false : non-stable coin, isStableCoin = true : stable-coin ($1)
        address tokenAddr;
    }
    mapping(uint256 => UpfrontTokenInfos) public upfrontTokenInfos; // id => packageInfo
    uint256 public totalUpfrontTokens;

    address feeReceiver;

    address public launchShieldCA;

    struct CreateLaunchMemVars {
        uint256 amountForCreationFee;
        uint256 decimals;
        address[] path;
        uint256 amountForUSDT;
        uint256[] amountsInForWETH;
        uint256[] amountsInForToken;
        uint256[] sellFees;
        uint256[] buyFees;
        address[] feeReceivers;
    }

    event CreatedNewLaunchShield(
        address creator,
        address launchTokenAddr,
        uint256 createdAt
    );

    constructor() {}

    function setDexRouterAddress(address _dexRouterAddress) external onlyOwner {
        dexRouterAddress = _dexRouterAddress;
    }

    function setUSDTAddress(address _usdtAddress) external onlyOwner {
        usdtAddress = _usdtAddress;
    }

    function setPackageInfo(uint256 _percentOfTxFee, uint256 _upfrontAmount)
        external
        onlyOwner
    {
        packageInfos[totalPackages].percentOfTxFee = _percentOfTxFee;
        packageInfos[totalPackages].upfrontAmount = _upfrontAmount;
        totalPackages++;
    }

    function modifyPackageInfo(
        uint256 _packageIndex,
        uint256 _percentOfTxFee,
        uint256 _upfrontAmount
    ) external onlyOwner {
        require(_packageIndex < totalPackages, "Wrong packageIndex!");
        packageInfos[_packageIndex].percentOfTxFee = _percentOfTxFee;
        packageInfos[_packageIndex].upfrontAmount = _upfrontAmount;
    }

    function setUpfrontTokenInfo(bool _isStableCoin, address _tokenAddr)
        external
        onlyOwner
    {
        upfrontTokenInfos[totalUpfrontTokens].isStableCoin = _isStableCoin;
        upfrontTokenInfos[totalUpfrontTokens].tokenAddr = _tokenAddr;
        totalUpfrontTokens++;
    }

    function modifyUpfrontTokenInfo(
        uint256 _upfrontTokenIndex,
        bool _isStableCoin,
        address _tokenAddr
    ) external onlyOwner {
        require(
            _upfrontTokenIndex < totalUpfrontTokens,
            "Wrong upfrontTokenIndex!"
        );
        upfrontTokenInfos[_upfrontTokenIndex].isStableCoin = _isStableCoin;
        upfrontTokenInfos[_upfrontTokenIndex].tokenAddr = _tokenAddr;
    }

    function createLaunchShield(
        address launchTokenAddr,
        uint256 packageIndex,
        uint256 upfrontTokenIndex,
        uint256 launchTime,
        uint256 maxTx,
        uint256 maxWallet,
        address dexRouterAddr,
        uint256[] memory sellFees,
        uint256[] memory buyFees,
        address[] memory feeReceivers
    ) external payable {
        require(
            upfrontTokenIndex < totalUpfrontTokens,
            "Wrong upfrontTokenIndex!"
        );
        require(packageIndex < totalPackages, "Wrong packageIndex!");
        require(maxTx > 0, "Wrong maxTx!");
        require(maxWallet > 0, "Wrong maxWallet!");
        require(sellFees.length == buyFees.length, "Fee Length is not same");
        require(sellFees.length == feeReceivers.length, "Length is not same");
        require(ILaunchShield(launchShieldCA).getLsCreator(launchTokenAddr) == address(0), "Already created launchshield");
        
        CreateLaunchMemVars memory memvar;
        if (
            packageInfos[packageIndex].upfrontAmount > 0 &&
            msg.sender != owner()
        ) {
            memvar.decimals = IERC20(usdtAddress).decimals();
            memvar.path = new address[](2);
            memvar.path[0] = IUniswapV2Router02(dexRouterAddress).WETH();
            memvar.path[1] = usdtAddress;
            memvar.amountForUSDT =
                packageInfos[packageIndex].upfrontAmount *
                (10**memvar.decimals);
            memvar.amountsInForWETH = IUniswapV2Router02(dexRouterAddress)
                .getAmountsIn(memvar.amountForUSDT, memvar.path);
            if (
                upfrontTokenInfos[upfrontTokenIndex].tokenAddr ==
                IUniswapV2Router02(dexRouterAddress).WETH()
            ) {
                memvar.amountForCreationFee =
                    (memvar.amountsInForWETH[0] * 95) /
                    100;
                require(
                    msg.value >= memvar.amountForCreationFee,
                    "Insufficient upfront!"
                );
            } else {
                if (upfrontTokenInfos[upfrontTokenIndex].isStableCoin) {
                    memvar.decimals = IERC20(
                        upfrontTokenInfos[upfrontTokenIndex].tokenAddr
                    ).decimals();
                    memvar.amountForCreationFee =
                        packageInfos[packageIndex].upfrontAmount *
                        (10**memvar.decimals);
                } else {
                    memvar.decimals = IERC20(
                        upfrontTokenInfos[upfrontTokenIndex].tokenAddr
                    ).decimals();
                    memvar.path[0] = upfrontTokenInfos[upfrontTokenIndex]
                        .tokenAddr;
                    memvar.path[1] = IUniswapV2Router02(dexRouterAddress)
                        .WETH();
                    memvar.amountsInForToken = IUniswapV2Router02(
                        dexRouterAddress
                    ).getAmountsIn(memvar.amountsInForWETH[0], memvar.path);
                    memvar.amountForCreationFee = memvar.amountsInForToken[0];
                }
                IERC20(upfrontTokenInfos[upfrontTokenIndex].tokenAddr)
                    .safeTransferFrom(
                        msg.sender,
                        address(this),
                        memvar.amountForCreationFee
                    );
            }
        }

        if (packageInfos[packageIndex].percentOfTxFee > 0) {
            memvar.sellFees = new uint256[](sellFees.length + 1);
            memvar.buyFees = new uint256[](sellFees.length + 1);
            memvar.feeReceivers = new address[](sellFees.length + 1);
            for (uint256 i = 0; i < sellFees.length; i++) {
                memvar.sellFees[i] = sellFees[i];
                memvar.buyFees[i] = buyFees[i];
                memvar.feeReceivers[i] = feeReceivers[i];
            }
            memvar.sellFees[sellFees.length] = packageInfos[packageIndex]
                .percentOfTxFee;
            memvar.buyFees[sellFees.length] = packageInfos[packageIndex]
                .percentOfTxFee;
            memvar.feeReceivers[sellFees.length] = feeReceiver;
            ILaunchShield(launchShieldCA).setFeeInfos(
                launchTokenAddr,
                memvar.sellFees,
                memvar.buyFees,
                memvar.feeReceivers
            );
        } else {
            ILaunchShield(launchShieldCA).setFeeInfos(
                launchTokenAddr,
                sellFees,
                buyFees,
                feeReceivers
            );
        }

        ILaunchShield(launchShieldCA).setLaunchInfos(
            launchTokenAddr,
            packageIndex,
            upfrontTokenIndex,
            launchTime,
            maxTx,
            maxWallet,
            dexRouterAddr,
            msg.sender
        );

        emit CreatedNewLaunchShield(
            msg.sender,
            launchTokenAddr,
            block.timestamp
        );
    }

    function modifyMaxTxWalletAmount(
        address launchTokenAddr,
        uint256 maxTx,
        uint256 maxWallet
    ) external {
        require(ILaunchShield(launchShieldCA).getLsCreator(launchTokenAddr) != address(0), "Not registered");
        require(
            ILaunchShield(launchShieldCA).getLsCreator(launchTokenAddr) == msg.sender || msg.sender == owner(),
            "Not a creator!"
        );
        ILaunchShield(launchShieldCA).setMaxTxWalletAmount(
            launchTokenAddr,
            maxTx,
            maxWallet
        );
    }

    function modifyLaunchTime(address launchTokenAddr, uint256 launchTime)
        external
    {
        require(ILaunchShield(launchShieldCA).getLsCreator(launchTokenAddr) != address(0), "Not registered");
        require(
            ILaunchShield(launchShieldCA).getLsCreator(launchTokenAddr) == msg.sender || msg.sender == owner(),
            "Not a creator!"
        );
        ILaunchShield(launchShieldCA).setLaunchTime(
            launchTokenAddr,
            launchTime
        );
    }

    function modifyPackageIndex(address launchTokenAddr, uint256 packageIndex)
        external 
        onlyOwner
    {        
        ILaunchShield(launchShieldCA).setPackageIndex(launchTokenAddr, packageIndex);
    }

    function modifyFeeInfos(
        address launchTokenAddr,
        uint256[] memory sellFees,
        uint256[] memory buyFees,
        address[] memory feeReceivers
    ) external {
        require(ILaunchShield(launchShieldCA).getLsCreator(launchTokenAddr) != address(0), "Not registered");
        require(
            ILaunchShield(launchShieldCA).getLsCreator(launchTokenAddr) == msg.sender || msg.sender == owner(),
            "Not a creator!"
        );
        uint256 percentOfTxFee = packageInfos[
            ILaunchShield(launchShieldCA).getPackageIndex(launchTokenAddr)
        ].percentOfTxFee;

        if (percentOfTxFee > 0) {
            uint256[] memory _sellFees = new uint256[](sellFees.length + 1);
            uint256[] memory _buyFees = new uint256[](sellFees.length + 1);
            address[] memory _feeReceivers = new address[](sellFees.length + 1);
            for (uint256 i = 0; i < sellFees.length; i++) {
                _sellFees[i] = sellFees[i];
                _buyFees[i] = buyFees[i];
                _feeReceivers[i] = feeReceivers[i];
            }
            _sellFees[sellFees.length] = percentOfTxFee;
            _buyFees[sellFees.length] = percentOfTxFee;
            _feeReceivers[sellFees.length] = feeReceiver;
            ILaunchShield(launchShieldCA).setFeeInfos(
                launchTokenAddr,
                _sellFees,
                _buyFees,
                _feeReceivers
            );
        } else {
            ILaunchShield(launchShieldCA).setFeeInfos(
                launchTokenAddr,
                sellFees,
                buyFees,
                feeReceivers
            );
        }
    }    

    function setLaunchShieldCA(address _launchShieldCA) external onlyOwner {
        launchShieldCA = _launchShieldCA;
    }

    function setFeeReceiver(address _feeReceiver) external onlyOwner {
        feeReceiver = _feeReceiver;
    }

    function getPackageInfos() external view returns(PackageInfos[] memory) {
        require(totalPackages > 0, "No packages registered");
        PackageInfos[] memory infos = new PackageInfos[](
            totalPackages
        );
        for (uint256 i = 0; i < totalPackages; i++) {
            infos[i] = packageInfos[i];
        }
        return (infos);        
    }

    function getUpfrontTokenInfos() external view returns(UpfrontTokenInfos[] memory) {
        require(totalUpfrontTokens > 0, "No upfront tokens registered");
        UpfrontTokenInfos[] memory infos = new UpfrontTokenInfos[](
            totalUpfrontTokens
        );
        for (uint256 i = 0; i < totalPackages; i++) {
            infos[i] = upfrontTokenInfos[i];
        }
        return (infos);
    }

    function withdrawToken(address _tokenAddress) external onlyOwner {
        uint256 bal = 0;
        if (_tokenAddress == IUniswapV2Router02(dexRouterAddress).WETH()) {
            //eth
            bal = address(this).balance;
            require(bal > 0, "No ETH!");
            (bool sent, ) = payable(msg.sender).call{value: bal}("");
            require(sent);
        } else {
            bal = IERC20(_tokenAddress).balanceOf(address(this));
            require(bal > 0, "No tokens!");
            IERC20(_tokenAddress).safeTransfer(msg.sender, bal);
        }
    }

    //to receive ETH from dexRouter when swapping
    receive() external payable {}
}