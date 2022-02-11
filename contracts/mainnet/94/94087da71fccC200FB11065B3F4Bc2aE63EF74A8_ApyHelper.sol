//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "../interfaces/IMasterChef.sol";
import "../interfaces/IUSDOracle.sol";
import "../interfaces/IPair.sol";

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract ApyHelper {

  IMasterChef public masterChef;
  IUSDOracle public usdOracle;
  address public cake;

  constructor(IMasterChef _chef, IUSDOracle _usdOracle, address _cake) {
    masterChef = _chef;
    usdOracle = _usdOracle;
    cake = _cake;
  }

  function lpPrice(address lpToken) public view returns (uint price) {
      uint lpSupply = IERC20(lpToken).totalSupply();
      address token0 = IPair(lpToken).token0();
      address token1 = IPair(lpToken).token1();
      (uint112 reserve0, uint112 reserve1, ) = IPair(lpToken).getReserves();
      uint amount0 = uint(reserve0) * 10**18 / lpSupply;
      uint amount1 = uint(reserve1) * 10**18 / lpSupply;

      uint price0 = usdOracle.getPrice(token0);
      uint price1 = usdOracle.getPrice(token1);

      uint decimal0 = IERC20Metadata(token0).decimals();
      uint decimal0Scale = 10 ** decimal0;

      uint decimal1 = IERC20Metadata(token1).decimals();
      uint decimal1Scale = 10 ** decimal1;

      return (amount0 * price0 / decimal0Scale) + (amount1 * price1 / decimal1Scale);
  }

  function lpApyInfo(uint pid) public view returns (
      uint takingTokenPrice,
      uint rewardTokenPrice,
      uint totalStaked, 
      uint tokenPerBlock) {
    (address lpToken, uint256 allocPoint, ,) = masterChef.poolInfo(pid);

    takingTokenPrice = lpPrice(lpToken);
    
    rewardTokenPrice = usdOracle.getPrice(cake);

    totalStaked = IERC20(lpToken).balanceOf(address(masterChef));
    uint cakeTotal = masterChef.cakePerBlock();
    uint totalAlloc = masterChef.totalAllocPoint();

    tokenPerBlock = allocPoint * cakeTotal / totalAlloc;
  }

}

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IMasterChef {
  function cake() external view returns (address) ;
  function poolLength() external view returns (uint256);

  function cakePerBlock() external view returns (uint256);
  function totalAllocPoint() external view returns (uint256);

  function poolInfo(uint pid) external view returns (address lpToken,  uint256 allocPoint, uint256 lastRewardBlock, uint256 accSushiPerShare);
  function userInfo(uint pid, address user)  external view returns (uint amount, uint rewardDebt);
  
  // View function to see pending SUSHIs on frontend.
  function pendingCake(uint256 _pid, address _user) external view returns (uint256);
  
  function deposit(uint256 _pid, uint256 _amount) external;
  function withdraw(uint256 _pid, uint256 _amount) external;
  function emergencyWithdraw(uint256 _pid) external;
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

interface IUSDOracle {
  // Must 8 dec, same as chainlink decimals.
  function getPrice(address token) external view returns (uint256);
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

// for PancakePair or UniswapPair
interface IPair {

  function factory() external view returns (address);
  function token0() external view returns (address);
  function token1() external view returns (address);
  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

  function mint(address to) external returns (uint liquidity);
  function burn(address to) external returns (uint amount0, uint amount1);
  function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
  function skim(address to) external;
  function sync() external;

  function balanceOf(address owner) external view returns (uint);

}

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}