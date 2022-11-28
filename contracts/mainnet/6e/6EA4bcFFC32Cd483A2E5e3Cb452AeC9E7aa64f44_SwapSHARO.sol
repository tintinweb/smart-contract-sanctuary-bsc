pragma solidity >=0.6.2;

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

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

/// @notice Ownable contract used to manage the SwapSHARO contract.
abstract contract Ownable {
  address private _owner;

  address public pendingOwner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /// @notice Initializes the contract setting the deployer as the initial owner.
  constructor() {
    _transferOwnership(msg.sender);
  }

  /// @notice Throws if called by any account other than the owner.
  modifier onlyOwner() {
    require(owner() == msg.sender, "Ownable: caller is not the owner");
    _;
  }

  /// @notice Returns the address of the current owner.
  function owner() public view returns (address) {
    return _owner;
  }

  /// @notice Leaves the contract without owner. It will not be possible to call `onlyOwner` modifier anymore.
  /// @param isRenounce: Boolean parameter with which you confirm renunciation of ownership
  function renounceOwnership(bool isRenounce) public onlyOwner {
    if (isRenounce) _transferOwnership(address(0));
  }

  /// @notice Transfers ownership of the contract to a new account.
  /// @param newOwner: The address of the new owner of the contract
  /// @param direct: Boolean parameter that will be used to change the owner of the contract directly
  function transferOwnership(address newOwner, bool direct) external onlyOwner {
    if (direct) {
      require(newOwner != address(0), "Ownable: zero address");
      require(
        newOwner != _owner,
        "Ownable: newOwner must be a different address than the current owner"
      );

      _transferOwnership(newOwner);
      pendingOwner = address(0);
    } else {
      pendingOwner = newOwner;
    }
  }

  /// @notice The `pendingOwner` have only 30 seconds to confirm, if he wants to be the new owner of the contract.
  function claimOwnership() external {
    require(msg.sender == pendingOwner, "Ownable: caller != pending owner");

    _transferOwnership(pendingOwner);
    pendingOwner = address(0);
  }

  /// @notice Transfers ownership of the contract to a new account.
  /// @param newOwner: The address of the new owner of the contract
  function _transferOwnership(address newOwner) internal {
    _owner = newOwner;
    emit OwnershipTransferred(_owner, newOwner);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./Ownable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

interface IERC20 {
  function approve(address spender, uint256 amount) external returns (bool);
}

contract SwapSHARO is Ownable {
  IUniswapV2Router02 public uniswapV2Router;

  address public immutable SHARO =
    address(0x7F3dAf301c629BfA243CbbA6654370d929379657);

  event UpdateUniswapV2Router(
    address indexed newAddress,
    address indexed oldAddress
  );

  constructor() {
    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
      0x10ED43C718714eb63d5aA57B78B54704E256024E
    );
    uniswapV2Router = _uniswapV2Router;
  }

  function swapSHAROForBNB(
    uint256 amountIn,
    uint256 amountOutMin
  ) external onlyOwner {
    IERC20(SHARO).approve(address(this), amountIn);

    address[] memory path = new address[](2);
    path[0] = SHARO;
    path[1] = uniswapV2Router.WETH();

    uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
      amountIn,
      amountOutMin,
      path,
      owner(),
      block.timestamp
    );
  }

  function updateUniswapV2Router(address newAddress) external onlyOwner {
    require(
      newAddress != address(uniswapV2Router),
      "SwapSHARO: The router already has that address"
    );

    emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
    uniswapV2Router = IUniswapV2Router02(newAddress);
  }
}