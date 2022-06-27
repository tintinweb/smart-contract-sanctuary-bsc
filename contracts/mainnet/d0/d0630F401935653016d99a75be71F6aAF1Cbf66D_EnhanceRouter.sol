/**
 *Submitted for verification at BscScan.com on 2022-06-27
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface ISwap   {

    function quote(uint256 nativeAmount, uint256 tokenAmount) external view returns (uint256);
    function swapNativeForTokens() external payable returns (uint256);
    function swapTokensForNative(uint256 amount_) external returns (uint256);
    function swapTokensForNativeWithPermit(uint256 amount_, uint256 deadline_, uint8 v_, bytes32 r_, bytes32 s_) external;
}

/// @title bit library
/// @notice old school bit bits
library bits {

    /// @notice check if only a specific bit is set
    /// @param slot the bit storage slot
    /// @param bit the bit to be checked
    /// @return return true if the bit is set
    function only(uint slot, uint bit) internal pure returns (bool) {
        return slot == bit;
    }

    /// @notice checks if any of the bits_ are set
    /// @param slot the bit storage to slot
    /// @param bits_ the or list of bits_ to slot
    /// @return true of any of the bits_ are set otherwise false
    function any(uint slot, uint bits_) internal pure returns(bool) {
        return (slot & bits_) != 0;
    }

    /// @notice checks if all of the bits_ are set
    /// @param slot the bit storage
    /// @param bits_ the list of bits_ required
    /// @return true if all of the bits_ are set in the sloted variable
    function all(uint slot, uint bits_) internal pure returns(bool) {
        return bits_ == 0 ? slot == bits_ : (slot & bits_) == bits_;
    }

    /// @notice set bits_ in this storage slot
    /// @param slot the storage slot to set
    /// @param bits_ the list of bits_ to be set
    /// @return a new uint with bits_ set
    /// @dev bits_ that are already set are not cleared
    function set(uint slot, uint bits_) internal pure returns(uint) {
        return slot | bits_;
    }

    function toggle(uint slot, uint bits_) internal pure returns (uint) {
        return slot ^ bits_;
    }

    function isClear(uint slot, uint bits_) internal pure returns(bool) {
        return !all(slot, bits_);
    }

    /// @notice clear bits_ in the storage slot
    /// @param slot the bit storage variable
    /// @param bits_ the list of bits_ to clear
    /// @return a new uint with bits_ cleared
    function clear(uint slot, uint bits_) internal pure returns(uint) {
        return slot & ~(bits_);
    }

    /// @notice clear & set bits_ in the storage slot
    /// @param slot the bit storage variable
    /// @param bits_ the list of bits_ to clear
    /// @return a new uint with bits_ cleared and set
    function reset(uint slot, uint bits_) internal pure returns(uint) {
        slot = clear(slot, type(uint).max);
        return set(slot, bits_);
    }

}

/// @notice Emitted when a check for
error FlagsInvalid(address account, uint256 set, uint256 cleared);

/// @title UsingFlags contract
/// @notice Use this contract to implement unique permissions or attributes
// @dev you have up to 255 flags you can use. Be careful not to use the same flag more than once.
abstract contract UsingFlags {
    /// @notice a helper library to check if a flag is set
    using bits for uint256;
    /// @notice storage for the flags
    mapping(address => uint256) internal _flags;

    /// @notice checks of the required flags are set or cleared
    /// @param account_ the account to check
    /// @param set_ the flags that must be set
    /// @param cleared_ the flags that must be cleared
    modifier requires(address account_, uint256 set_, uint256 cleared_) {
        if (!_flags[account_].all(set_) && _flags[account_].all(cleared_)) revert FlagsInvalid(account_, set_, cleared_);
        _;
    }

    /// @notice getFlags returns the currently set flags
    /// @param account_ the account to check
    function getFlags(address account_) public view returns (uint256) {
        return _flags[account_];
    }

    /// @notice set and clear flags for the given account
    /// @param account_ the account to modify flags for
    /// @param set_ the flags to set
    /// @param clear_ the flags to clear
    function _setFlags(address account_, uint256 set_, uint256 clear_) internal virtual {
        _flags[account_] = _flags[account_].set(set_).clear(clear_);
    }

}

/// @notice This error is emitted when attempting to use the initializer twice
error InitializationRecursion();

/// @title UsingInitializer
/// @notice Use this contract in conjunction with UsingUUPS to allow initialization instead of construction
/// @author FYB3R STUDIOS
abstract contract UsingInitializer is UsingFlags {
    using bits for uint256;

    /// @notice modifier to prevent double initialization
    modifier initializer() {
        if (_flags[address(this)].all(INITIALIZED_FLAG())) revert InitializationRecursion();
        _;
        _setFlags(address(this), INITIALIZED_FLAG(), 0);
    }

    /// @notice helper function to check if the contract has been initialized
    function initialized() public view returns (bool) {
        return _flags[address(this)].all(INITIALIZED_FLAG());
    }

    /// @notice the value of the initializer flag
    function INITIALIZED_FLAG() public pure virtual returns (uint256);
}

error UniswapAdapterUnsupportedToken();
error UniswapAdapterPaymentFailed();
/// @title Uniswap Adapter for FYB3R swaps
/// @dev this is a temprorary version until the fyb3r network is live
abstract contract UniswapAdapter is UsingInitializer {

    /// @notice forward receive calls
    fallback() external payable virtual  {
        _forward();
    }

    receive() external payable {}

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts) {
        if (path[path.length - 1] != _getTokenStorage()) revert UniswapAdapterUnsupportedToken();
        amounts = new uint[](2);
        (amounts[0], amounts[1]) = (msg.value, ISwap(_getSwapStorage()).swapNativeForTokens{value: msg.value}());
        IERC20(_getTokenStorage()).transfer(to, amounts[1]);
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable {
        if (path[path.length - 1] != _getTokenStorage()) revert UniswapAdapterUnsupportedToken();
        uint amount = ISwap(_getSwapStorage()).swapNativeForTokens{value: msg.value}();
        IERC20(_getTokenStorage()).transfer(to, amount);
    }

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts) {
        if (path[0] != _getTokenStorage()) revert UniswapAdapterUnsupportedToken();
        amounts = new uint[](2);
        IERC20(_getTokenStorage()).transferFrom(msg.sender, address(this), amountOut);
        uint256 balance = address(this).balance;
        (amounts[0], amounts[1]) = (amountOut, ISwap(_getSwapStorage()).swapTokensForNative(amountOut));
        (bool success,) = payable(msg.sender).call{value: address(this).balance - balance}("");
        if (!success) revert UniswapAdapterPaymentFailed();
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external {
        if (path[0] != _getTokenStorage()) revert UniswapAdapterUnsupportedToken();
        IERC20(_getTokenStorage()).transferFrom(msg.sender, address(this), amountIn);
        uint256 balance = address(this).balance;
        ISwap(_getSwapStorage()).swapTokensForNative(amountIn);
        (bool success,) = payable(msg.sender).call{value: address(this).balance - balance}("");
        if (!success) revert UniswapAdapterPaymentFailed();
    }

    /// @notice forward any call that doesn't exist in this contract to the router
    function _forward() internal {
        address router = _getRouterStorage();
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := call(gas(), router, 0, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function _getRouterStorage() internal virtual view returns (address);
    function _getTokenStorage() internal virtual view returns (address);
    function _getSwapStorage() internal virtual view returns (address);

    function INITIALIZED_FLAG() public pure override returns (uint256) {
        return 1 << 255;
    }

    /// @notice the flag used to authorize changing state variables and upgrades
    /// @return uint256 bit flag
    function ADMIN_FLAG() public pure returns (uint256) {
        return INITIALIZED_FLAG() >> 1;
    }
}

contract UniswapAdapterWithStorage is UniswapAdapter {

    address _router;
    uint96 _reserved0; // Reserved for future use
    address _swap;
    uint96 _reserved1; // Reserved for future use
    address _token;
    uint96 _reserved2; // Reserved for future use

    function _initializeUniswapAdapterWithStorage(address router_, address swap_, address token_) internal  {
        _router = router_;
        _swap = swap_;
        _token = token_;
        IERC20(_token).approve(swap_, type(uint).max);
        _setFlags(msg.sender, ADMIN_FLAG(), 0);
    }

    function initialize(address router_, address swap_, address token_) external initializer {
        _initializeUniswapAdapterWithStorage(router_, swap_, token_);
    }

    function setRouter(address router_) public requires(msg.sender, ADMIN_FLAG(), 0) {
        _router = router_;
    }

    function setSwap(address swap_) public requires(msg.sender, ADMIN_FLAG(), 0) {
        _swap = swap_;
    }

    function _getRouterStorage() internal view override returns (address) {
        return _router;
    }

    function _getSwapStorage() internal view override returns (address) {
        return _swap;
    }

    function _getTokenStorage() internal view override returns (address) {
        return _token;
    }

    function destroy() external requires(msg.sender, ADMIN_FLAG(), 0) {
        selfdestruct(payable(msg.sender));
    }
}

/// @title Enhance Router
/// @author [email protected]
/// @dev this contract encapsulates the logic of the Uniswap v2 router. Use the IUnswapV2Router02 interface to interact with this contract
contract EnhanceRouter is UniswapAdapterWithStorage {

}