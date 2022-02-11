/**
 *Submitted for verification at BscScan.com on 2022-02-09
*/

// Sources flattened with hardhat v2.5.0 https://hardhat.org

// File @openzeppelin/contracts/token/ERC20/[email protected]

// SPDX-License-Identifier: MIT

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


// File contracts/libs/TransferHelper.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


// File contracts/interfaces/IFortSwap.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

/// @dev 定义dcu兑换合约接口
interface IFortSwap {

    /// @dev 使用确定数量的token兑换dcu
    /// @param tokenAmount token数量
    /// @return dcuAmount 兑换到的dcu数量
    function swapForDCU(uint tokenAmount) external returns (uint dcuAmount);

    /// @dev 使用确定数量的dcu兑换token
    /// @param dcuAmount dcu数量
    /// @return tokenAmount 兑换到的token数量
    function swapForToken(uint dcuAmount) external returns (uint tokenAmount);

    /// @dev 使用token兑换确定数量的dcu
    /// @param dcuAmount 预期得到的dcu数量
    /// @return tokenAmount 支付的token数量
    function swapExactDCU(uint dcuAmount) external returns (uint tokenAmount);

    /// @dev 使用dcu兑换确定数量的token
    /// @param tokenAmount 预期得到的token数量
    /// @return dcuAmount 支付的dcu数量
    function swapExactToken(uint tokenAmount) external returns (uint dcuAmount);
}


// File contracts/interfaces/IHedgeMapping.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

/// @dev The interface defines methods for Hedge builtin contract address mapping
interface IHedgeMapping {

    /// @dev 地址更新事件
    /// @param name 地址名称
    /// @param oldAddress 旧地址
    /// @param newAddress 新地址
    event AddressUpdated(string name, address oldAddress, address newAddress);

    /// @dev Set the built-in contract address of the system
    /// @param dcuToken Address of dcu token contract
    /// @param hedgeDAO IHedgeDAO implementation contract address
    /// @param hedgeOptions IHedgeOptions implementation contract address
    /// @param hedgeFutures IHedgeFutures implementation contract address
    /// @param hedgeVaultForStaking IHedgeVaultForStaking implementation contract address
    /// @param nestPriceFacade INestPriceFacade implementation contract address
    function setBuiltinAddress(
        address dcuToken,
        address hedgeDAO,
        address hedgeOptions,
        address hedgeFutures,
        address hedgeVaultForStaking,
        address nestPriceFacade
    ) external;

    /// @dev Get the built-in contract address of the system
    /// @return dcuToken Address of dcu token contract
    /// @return hedgeDAO IHedgeDAO implementation contract address
    /// @return hedgeOptions IHedgeOptions implementation contract address
    /// @return hedgeFutures IHedgeFutures implementation contract address
    /// @return hedgeVaultForStaking IHedgeVaultForStaking implementation contract address
    /// @return nestPriceFacade INestPriceFacade implementation contract address
    function getBuiltinAddress() external view returns (
        address dcuToken,
        address hedgeDAO,
        address hedgeOptions,
        address hedgeFutures,
        address hedgeVaultForStaking,
        address nestPriceFacade
    );

    /// @dev Get address of dcu token contract
    /// @return Address of dcu token contract
    function getDCUTokenAddress() external view returns (address);

    /// @dev Get IHedgeDAO implementation contract address
    /// @return IHedgeDAO implementation contract address
    function getHedgeDAOAddress() external view returns (address);

    /// @dev Get IHedgeOptions implementation contract address
    /// @return IHedgeOptions implementation contract address
    function getHedgeOptionsAddress() external view returns (address);

    /// @dev Get IHedgeFutures implementation contract address
    /// @return IHedgeFutures implementation contract address
    function getHedgeFuturesAddress() external view returns (address);

    /// @dev Get IHedgeVaultForStaking implementation contract address
    /// @return IHedgeVaultForStaking implementation contract address
    function getHedgeVaultForStakingAddress() external view returns (address);

    /// @dev Get INestPriceFacade implementation contract address
    /// @return INestPriceFacade implementation contract address
    function getNestPriceFacade() external view returns (address);

    /// @dev Registered address. The address registered here is the address accepted by Hedge system
    /// @param key The key
    /// @param addr Destination address. 0 means to delete the registration information
    function registerAddress(string calldata key, address addr) external;

    /// @dev Get registered address
    /// @param key The key
    /// @return Destination address. 0 means empty
    function checkAddress(string calldata key) external view returns (address);
}


// File contracts/interfaces/IHedgeGovernance.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev This interface defines the governance methods
interface IHedgeGovernance is IHedgeMapping {

    /// @dev 权限标记更新事件
    /// @param addr 目标地址
    /// @param oldFlag 旧权限标志
    /// @param newFlag 新权限标志
    event FlagChanged(address addr, uint oldFlag, uint newFlag);

    /// @dev Set governance authority
    /// @param addr Destination address
    /// @param flag Weight. 0 means to delete the governance permission of the target address. Weight is not 
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function setGovernance(address addr, uint flag) external;

    /// @dev Get governance rights
    /// @param addr Destination address
    /// @return Weight. 0 means to delete the governance permission of the target address. Weight is not 
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function getGovernance(address addr) external view returns (uint);

    /// @dev Check whether the target address has governance rights for the given target
    /// @param addr Destination address
    /// @param flag Permission weight. The permission of the target address must be greater than this weight 
    /// to pass the check
    /// @return True indicates permission
    function checkGovernance(address addr, uint flag) external view returns (bool);
}


// File contracts/HedgeBase.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev Base contract of Hedge
contract HedgeBase {

    /// @dev 治理权限变更事件
    /// @param oldGovernance 旧治理地址
    /// @param newGovernance 新治理地址
    event GovernanceChanged(address oldGovernance, address newGovernance);

    /// @dev IHedgeGovernance implementation contract address
    address public _governance;

    /// @dev To support open-zeppelin/upgrades
    /// @param governance IHedgeGovernance implementation contract address
    function initialize(address governance) public virtual {
        require(_governance == address(0), "Hedge:!initialize");
        emit GovernanceChanged(address(0), governance);
        _governance = governance;
    }

    /// @dev Rewritten in the implementation contract, for load other contract addresses. Call 
    ///      super.update(newGovernance) when overriding, and override method without onlyGovernance
    /// @param newGovernance IHedgeGovernance implementation contract address
    function update(address newGovernance) public virtual {

        address governance = _governance;
        require(governance == msg.sender || IHedgeGovernance(governance).checkGovernance(msg.sender, 0), "Hedge:!gov");
        emit GovernanceChanged(governance, newGovernance);
        _governance = newGovernance;
    }

    //---------modifier------------

    modifier onlyGovernance() {
        require(IHedgeGovernance(_governance).checkGovernance(msg.sender, 0), "Hedge:!gov");
        _;
    }
}


// File contracts/custom/HedgeFrequentlyUsed.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev Base contract of Hedge
contract HedgeFrequentlyUsed is HedgeBase {

    // Address of DCU contract
    address constant DCU_TOKEN_ADDRESS = 0x5Df87aE415206707fd52aDa20a5Eac2Ec70e8dbb;

    // Address of NestOpenPrice contract
    address constant NEST_OPEN_PRICE = 0xF2f9E62f52389EF223f5Fa8b9926e95386935277;
    
    // USDT代币的基数
    uint constant USDT_BASE = 1 ether;
}

// import "../interfaces/IHedgeGovernance.sol";
// // 主网部署时，需要使用上面的常量版本
// /// @dev Base contract of Hedge
// contract HedgeFrequentlyUsed is HedgeBase {

//     // Address of DCU contract
//     //address constant DCU_TOKEN_ADDRESS = ;
//     address DCU_TOKEN_ADDRESS;

//     // Address of NestPriceFacade contract
//     //address constant NEST_OPEN_PRICE = 0xB5D2890c061c321A5B6A4a4254bb1522425BAF0A;
//     address NEST_OPEN_PRICE;

//     // USDT代币地址（占位符，无用）
//     //address constant USDT_TOKEN_ADDRESS = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
//     //address USDT_TOKEN_ADDRESS;

//     // USDT代币的基数
//     uint constant USDT_BASE = 1 ether;

//     /// @dev Rewritten in the implementation contract, for load other contract addresses. Call 
//     ///      super.update(newGovernance) when overriding, and override method without onlyGovernance
//     /// @param newGovernance IHedgeGovernance implementation contract address
//     function update(address newGovernance) public override {

//         super.update(newGovernance);
//         (
//             DCU_TOKEN_ADDRESS,//address dcuToken,
//             ,//address hedgeDAO,
//             ,//address hedgeOptions,
//             ,//address hedgeFutures,
//             ,//address hedgeVaultForStaking,
//             NEST_OPEN_PRICE //address nestPriceFacade
//         ) = IHedgeGovernance(newGovernance).getBuiltinAddress();
//     }
// }


// File contracts/FortSwap.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev dcu兑换合约
contract FortSwap is HedgeFrequentlyUsed, IFortSwap {

    // 目标代币地址
    address constant TOKEN_ADDRESS = 0xDd4A68D8236247BDC159F7C5fF92717AA634cBCc;

    // TODO: 确定初始存入的DCU和USDT数量
    // K值，初始化存入1500万token，同时增发1500万dcu到资金池
    uint constant K = 800000 ether * 2600000 ether;

    constructor() {
    }

    /// @dev Swap token
    /// @param src Src token address
    /// @param dest Dest token address
    /// @param to The target address receiving the ETH
    /// @param payback As the charging fee may change, it is suggested that the caller pay more fees, 
    /// and the excess fees will be returned through this address
    /// @return amountOut The real amount of ETH transferred out of pool
    /// @return mined The amount of CoFi which will be mind by this trade
    function swap(
        address src, 
        address dest, 
        uint /*amountIn*/, 
        address to, 
        address payback
    ) external payable returns (
        uint amountOut, 
        uint mined
    ) {
        if (msg.value > 0) {
            // payable(payback).transfer(msg.value);
            TransferHelper.safeTransferETH(payback, msg.value);
        }

        // K值是固定常量，伪造amountIn没有意义
        if (src == TOKEN_ADDRESS && dest == DCU_TOKEN_ADDRESS) {
            amountOut = _swap(TOKEN_ADDRESS, DCU_TOKEN_ADDRESS, to);
        } else if (src == DCU_TOKEN_ADDRESS && dest == TOKEN_ADDRESS) {
            amountOut = _swap(DCU_TOKEN_ADDRESS, TOKEN_ADDRESS, to);
        } else {
            revert("HS:pair not allowed");
        }

        mined = 0;
    }

    /// @dev 使用确定数量的token兑换dcu
    /// @param tokenAmount token数量
    /// @return dcuAmount 兑换到的dcu数量
    function swapForDCU(uint tokenAmount) external override returns (uint dcuAmount) {
        TransferHelper.safeTransferFrom(TOKEN_ADDRESS, msg.sender, address(this), tokenAmount);
        dcuAmount = _swap(TOKEN_ADDRESS, DCU_TOKEN_ADDRESS, msg.sender);
    }

    /// @dev 使用确定数量的dcu兑换token
    /// @param dcuAmount dcu数量
    /// @return tokenAmount 兑换到的token数量
    function swapForToken(uint dcuAmount) external override returns (uint tokenAmount) {
        TransferHelper.safeTransferFrom(DCU_TOKEN_ADDRESS, msg.sender, address(this), dcuAmount);
        tokenAmount = _swap(DCU_TOKEN_ADDRESS, TOKEN_ADDRESS, msg.sender);
    }

    /// @dev 使用token兑换确定数量的dcu
    /// @param dcuAmount 预期得到的dcu数量
    /// @return tokenAmount 支付的token数量
    function swapExactDCU(uint dcuAmount) external override returns (uint tokenAmount) {
        tokenAmount = _swapExact(TOKEN_ADDRESS, DCU_TOKEN_ADDRESS, dcuAmount, msg.sender);
    }

    /// @dev 使用dcu兑换确定数量的token
    /// @param tokenAmount 预期得到的token数量
    /// @return dcuAmount 支付的dcu数量
    function swapExactToken(uint tokenAmount) external override returns (uint dcuAmount) {
       dcuAmount = _swapExact(DCU_TOKEN_ADDRESS, TOKEN_ADDRESS, tokenAmount, msg.sender);
    }

    // 使用确定数量的token兑换目标token
    function _swap(address src, address dest, address to) private returns (uint amountOut) {
        uint balance0 = IERC20(src).balanceOf(address(this));
        uint balance1 = IERC20(dest).balanceOf(address(this));

        amountOut = balance1 - K / balance0;
        TransferHelper.safeTransfer(dest, to, amountOut);
    }

    // 使用token兑换预期数量的token
    function _swapExact(address src, address dest, uint amountOut, address to) private returns (uint amountIn) {
        uint balance0 = IERC20(src).balanceOf(address(this));
        uint balance1 = IERC20(dest).balanceOf(address(this));

        amountIn = K / (balance1 - amountOut) - balance0;
        TransferHelper.safeTransferFrom(src, msg.sender, address(this), amountIn);
        TransferHelper.safeTransfer(dest, to, amountOut);
    }
}