/**
 *Submitted for verification at BscScan.com on 2022-07-07
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
        (bool success,) = to.call{value:value,gas:5000}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


// File contracts/interfaces/IFortSwap.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

/// @dev Defines methods for FortSwap
interface IFortSwap {

    /// @dev Swap for dcu with exact token amount
    /// @param tokenAmount Amount of token
    /// @return dcuAmount Amount of dcu acquired
    function swapForDCU(uint tokenAmount) external returns (uint dcuAmount);

    /// @dev Swap for token with exact dcu amount
    /// @param dcuAmount Amount of dcu
    /// @return tokenAmount Amount of token acquired
    function swapForToken(uint dcuAmount) external returns (uint tokenAmount);

    /// @dev Swap for exact amount of dcu
    /// @param dcuAmount Amount of dcu expected
    /// @return tokenAmount Amount of token paid
    function swapExactDCU(uint dcuAmount) external returns (uint tokenAmount);

    /// @dev Swap for exact amount of token
    /// @param tokenAmount Amount of token expected
    /// @return dcuAmount Amount of dcu paid
    function swapExactToken(uint tokenAmount) external returns (uint dcuAmount);
}


// File contracts/interfaces/IFortMapping.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

/// @dev The interface defines methods for Fort builtin contract address mapping
interface IFortMapping {

    /// @dev Address updated event
    /// @param name Address name
    /// @param oldAddress Old address
    /// @param newAddress New address
    event AddressUpdated(string name, address oldAddress, address newAddress);

    /// @dev Set the built-in contract address of the system
    /// @param dcuToken Address of dcu token contract
    /// @param fortDAO IFortDAO implementation contract address
    /// @param fortOptions IFortOptions implementation contract address
    /// @param fortFutures IFortFutures implementation contract address
    /// @param fortVaultForStaking IFortVaultForStaking implementation contract address
    /// @param nestPriceFacade INestPriceFacade implementation contract address
    function setBuiltinAddress(
        address dcuToken,
        address fortDAO,
        address fortOptions,
        address fortFutures,
        address fortVaultForStaking,
        address nestPriceFacade
    ) external;

    /// @dev Get the built-in contract address of the system
    /// @return dcuToken Address of dcu token contract
    /// @return fortDAO IFortDAO implementation contract address
    /// @return fortOptions IFortOptions implementation contract address
    /// @return fortFutures IFortFutures implementation contract address
    /// @return fortVaultForStaking IFortVaultForStaking implementation contract address
    /// @return nestPriceFacade INestPriceFacade implementation contract address
    function getBuiltinAddress() external view returns (
        address dcuToken,
        address fortDAO,
        address fortOptions,
        address fortFutures,
        address fortVaultForStaking,
        address nestPriceFacade
    );

    /// @dev Get address of dcu token contract
    /// @return Address of dcu token contract
    function getDCUTokenAddress() external view returns (address);

    /// @dev Get IFortDAO implementation contract address
    /// @return IFortDAO implementation contract address
    function getHedgeDAOAddress() external view returns (address);

    /// @dev Get IFortOptions implementation contract address
    /// @return IFortOptions implementation contract address
    function getHedgeOptionsAddress() external view returns (address);

    /// @dev Get IFortFutures implementation contract address
    /// @return IFortFutures implementation contract address
    function getHedgeFuturesAddress() external view returns (address);

    /// @dev Get IFortVaultForStaking implementation contract address
    /// @return IFortVaultForStaking implementation contract address
    function getHedgeVaultForStakingAddress() external view returns (address);

    /// @dev Get INestPriceFacade implementation contract address
    /// @return INestPriceFacade implementation contract address
    function getNestPriceFacade() external view returns (address);

    /// @dev Registered address. The address registered here is the address accepted by Fort system
    /// @param key The key
    /// @param addr Destination address. 0 means to delete the registration information
    function registerAddress(string calldata key, address addr) external;

    /// @dev Get registered address
    /// @param key The key
    /// @return Destination address. 0 means empty
    function checkAddress(string calldata key) external view returns (address);
}


// File contracts/interfaces/IFortGovernance.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev This interface defines the governance methods
interface IFortGovernance is IFortMapping {

    /// @dev Governance flag changed event
    /// @param addr Target address
    /// @param oldFlag Old governance flag
    /// @param newFlag New governance flag
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


// File contracts/FortBase.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev Base contract of Fort
contract FortBase {

    /// @dev Governance address changed event
    /// @param oldGovernance Old governance address
    /// @param newGovernance New governance address
    event GovernanceChanged(address oldGovernance, address newGovernance);

    /// @dev IFortGovernance implementation contract address
    address public _governance;

    /// @dev To support open-zeppelin/upgrades
    /// @param governance IFortGovernance implementation contract address
    function initialize(address governance) public virtual {
        require(_governance == address(0), "Fort:!initialize");
        emit GovernanceChanged(address(0), governance);
        _governance = governance;
    }

    /// @dev Rewritten in the implementation contract, for load other contract addresses. Call 
    ///      super.update(newGovernance) when overriding, and override method without onlyGovernance
    /// @param newGovernance IFortGovernance implementation contract address
    function update(address newGovernance) public virtual {
        address governance = _governance;
        require(governance == msg.sender || IFortGovernance(governance).checkGovernance(msg.sender, 0), "Fort:!gov");
        emit GovernanceChanged(governance, newGovernance);
        _governance = newGovernance;
    }

    // Fort will merger with NEST, One NEST, One COIN!
    function disable() internal pure {
        revert("Fort:One NEST, One COIN!");
    }

    //---------modifier------------

    modifier onlyGovernance() {
        require(IFortGovernance(_governance).checkGovernance(msg.sender, 0), "Fort:!gov");
        _;
    }
}


// File contracts/custom/FortFrequentlyUsed.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev This contract include frequently used data
contract FortFrequentlyUsed is FortBase {

    // Address of DCU contract
    address constant DCU_TOKEN_ADDRESS = 0xf56c6eCE0C0d6Fbb9A53282C0DF71dBFaFA933eF;

    // Address of NestOpenPrice contract
    address constant NEST_OPEN_PRICE = 0x09CE0e021195BA2c1CDE62A8B187abf810951540;
    
    // USDT base
    uint constant USDT_BASE = 1 ether;
}


// File contracts/FortSwap.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev Swap dcu with token
contract FortSwap is FortFrequentlyUsed, IFortSwap {

    // Target token address
    address constant TOKEN_ADDRESS = 0x55d398326f99059fF775485246999027B3197955;

    // K value, according to schedule, sell out nest from HedgeSwap pool on ethereum mainnet,
    // Exchange to usdt, and cross to BSC smart chain. Excluding exchange and cross chain consumption, 
    // a total of 952297.70usdt was obtained, address: 0x2bE88070a330Ef106E0ef77A45bd1F583BFcCf4E.
    // 77027.78usdt transferred to 0xc5229c9e1cbe1888b23015d283413a9c5e353ac7 as project expenditure.
    // 100000.00usdt transferred to the DAO address 0x9221295CE0E0D2E505CbeA635fa6730961FB5dFa for project funds.
    // The remaining 775269.92usdt transfer to the new usdt/dcu swap pool.
    // According to the price when nest/dcu swap pool stops, 1dcu=0.3289221986usdt,
    // The calculated number of dcu is 2357000.92.

    // 868,616.188258191063223411 DCU  868616188258191063223411
    // 200,000 BSC-USD                 200000000000000000000000
    uint constant K = 200000000000000000000000 * 868616188258191063223411;

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

        // The value of K is a fixed constant. Forging amountIn is useless.
        if (src == TOKEN_ADDRESS && dest == DCU_TOKEN_ADDRESS) {
            disable();
        } else if (src == DCU_TOKEN_ADDRESS && dest == TOKEN_ADDRESS) {
            amountOut = _swap(DCU_TOKEN_ADDRESS, TOKEN_ADDRESS, to);
        } else {
            revert("HS:pair not allowed");
        }

        mined = 0;
    }

    /// @dev Swap for dcu with exact token amount
    /// @param tokenAmount Amount of token
    /// @return dcuAmount Amount of dcu acquired
    function swapForDCU(uint tokenAmount) external override returns (uint dcuAmount) {
        disable();
    }

    /// @dev Swap for token with exact dcu amount
    /// @param dcuAmount Amount of dcu
    /// @return tokenAmount Amount of token acquired
    function swapForToken(uint dcuAmount) external override returns (uint tokenAmount) {
        TransferHelper.safeTransferFrom(DCU_TOKEN_ADDRESS, msg.sender, address(this), dcuAmount);
        tokenAmount = _swap(DCU_TOKEN_ADDRESS, TOKEN_ADDRESS, msg.sender);
    }

    /// @dev Swap for exact amount of dcu
    /// @param dcuAmount Amount of dcu expected
    /// @return tokenAmount Amount of token paid
    function swapExactDCU(uint dcuAmount) external override returns (uint tokenAmount) {
        disable();
    }

    /// @dev Swap for exact amount of token
    /// @param tokenAmount Amount of token expected
    /// @return dcuAmount Amount of dcu paid
    function swapExactToken(uint tokenAmount) external override returns (uint dcuAmount) {
       dcuAmount = _swapExact(DCU_TOKEN_ADDRESS, TOKEN_ADDRESS, tokenAmount, msg.sender);
    }

    // Swap exact amount of token for other
    function _swap(address src, address dest, address to) private returns (uint amountOut) {
        uint balance0 = IERC20(src).balanceOf(address(this));
        uint balance1 = IERC20(dest).balanceOf(address(this));

        amountOut = balance1 - K / balance0;
        TransferHelper.safeTransfer(dest, to, amountOut);
    }

    // Swap for exact amount of token by other
    function _swapExact(address src, address dest, uint amountOut, address to) private returns (uint amountIn) {
        uint balance0 = IERC20(src).balanceOf(address(this));
        uint balance1 = IERC20(dest).balanceOf(address(this));

        amountIn = K / (balance1 - amountOut) - balance0;
        TransferHelper.safeTransferFrom(src, msg.sender, address(this), amountIn);
        TransferHelper.safeTransfer(dest, to, amountOut);
    }
}