//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../interfaces/ISingleBond.sol";
import "../interfaces/IEpoch.sol";
import "../interfaces/IRouter.sol";
import "../interfaces/IPool.sol";
import "../interfaces/IController.sol";
import "../interfaces/IUSDOracle.sol";

interface IFarming {
  function assetPool(address dyToken) external view returns(address);
}

contract BondReader {
  uint256 private constant SCALE = 1e12;

  ISingleBond private bond;
  address private duet;
  IRouter private router;
  IFarming private farming;
  IController private controller;

  constructor(address _controller, address _bond, address _farming,
      address _duet, address _router) {
    controller = IController(_controller);
    bond = ISingleBond(_bond);
    farming = IFarming(_farming);
    duet = _duet;
    router = IRouter(_router);
  }

  function epochUsdVaule(address epoch) public view returns(uint256 p) {
    (address oracle, , ) = controller.getValueConf(duet);
    uint price = IUSDOracle(oracle).getPrice(duet);
    require(price != 0, "no duet price");
    p = epochPrice(epoch) * price / 1e18;
  }

  // duet as currency of price
  function epochPrice(address epoch) public view returns(uint256 p)  {

      address[] memory paths = new address[](2);
      paths[0] = epoch;
      paths[1] =  duet;

      try router.getAmountsOut(1e18, paths) returns (uint[] memory amounts) {
        p = amounts[1];
      } catch (bytes memory /*lowLevelData*/) {
        p = 1e18;
      }
  }


  function poolPendingAward(address pool, address user) external view returns(
    address[] memory epochs, uint256[] memory awards, uint[] memory ends) {
  
      IPool p = IPool(pool);
      (epochs, awards) = p.pending(user);
      uint len = epochs.length;
      ends = new uint[](len);

      for( uint256 i = 0; i < epochs.length; i++ ){
        ends[i] = IEpoch(epochs[i]).end();
      }
  }

  function myBonds(address user) external view returns(uint256[] memory balances,
    uint[] memory ends,
    uint[] memory prices,
    uint[] memory totals
    ) {
    address[] memory epochs = bond.getEpoches();
    uint len = epochs.length;
    balances = new uint[](len);
    ends = new uint[](len);
    prices = new uint[](len);
    totals = new uint[](len);

    address[] memory paths = new address[](2);
    paths[1] =  duet;

    for( uint256 i = 0; i < epochs.length; i++ ){
      balances[i] = IERC20(epochs[i]).balanceOf(user);
      ends[i] = IEpoch(epochs[i]).end();
      totals[i] = IERC20(epochs[i]).totalSupply();

      paths[0] = epochs[i];

      try router.getAmountsOut(1e18, paths) returns (uint[] memory amounts) {
        prices[i] = amounts[1];
      } catch (bytes memory /*lowLevelData*/) {
        prices[i] = 1e18;
      }
    }
  }

  // 
  function bondsPerBlock(address poolAddr, uint blockSecs) external view returns(address[] memory epochs, uint256[] memory awards) {
    IPool pool = IPool(poolAddr);
    epochs = pool.getEpoches();

    uint len = epochs.length;
    awards = new uint[](len);

    for(uint256 i = 0; i< len; i++) {
      (, uint epochPerSecond) = pool.epochInfos(epochs[i]);
      awards[i] = epochPerSecond * blockSecs;
    }
  }


  function calcDYTokenBondAward(address dyToken, uint time, uint256 amount) external view returns(
    address[] memory epochs, 
    uint256[] memory rewards, 
    uint[] memory values) {
    address poolAddr = farming.assetPool(dyToken);
    if (poolAddr == address(0)) {
      return (epochs, rewards, values);
    }
    
    IPool pool = IPool(poolAddr);
    epochs = pool.getEpoches();

    uint totalAmount = pool.totalAmount();
    if (totalAmount < amount) {
      totalAmount = amount;
    }

    uint len = epochs.length;

    rewards = new uint[](len);
    values = new uint[](len);

    for(uint256 i = 0; i< epochs.length; i++) {
      (, uint epochPerSecond) = pool.epochInfos(epochs[i]);
      rewards[i] = epochPerSecond * time * amount / totalAmount;
      values[i] = epochUsdVaule(epochs[i]) * rewards[i] / 1e18;
    }

  }

  

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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

pragma solidity >=0.8.0;

interface ISingleBond {
  function getEpoches() external view returns(address[] memory);
  function getEpoch(uint256 id) external view returns(address);
  function redeem(address[] memory epochs, uint[] memory amounts, address to) external;
  function redeemOrTransfer(address[] memory epochs, uint[] memory amounts, address to) external;
  function multiTransfer(address[] memory epochs, uint[] memory amounts, address to) external;
}

pragma solidity >=0.8.0;

interface IEpoch {
  function end() external view returns (uint256);
  function bond() external view returns (address);
}

pragma solidity >=0.8.0;

interface IRouter {
  function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
}

pragma solidity >=0.8.0;

interface IPool {
    function getEpoches() external view returns(address[] memory);
    function totalAmount() external view returns (uint);
    // function epoches(uint256 id) external view returns(address);
    function epochInfos(address) external view returns (uint256, uint256);
    function pending(address user) external view returns (address[] memory epochs, uint256[] memory rewards);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IController {
  function dyTokens(address) external view returns (address);
  function getValueConf(address _underlying) external view returns (address oracle, uint16 dr, uint16 pr);
  function getValueConfs(address token0, address token1) external view returns (address oracle0, uint16 dr0, uint16 pr0, address oracle1, uint16 dr1, uint16 pr1);

  function strategies(address) external view returns (address);
  function dyTokenVaults(address) external view returns (address);

  function beforeDeposit(address , address _vault, uint) external view;
  function beforeBorrow(address _borrower, address _vault, uint256 _amount) external view;
  function beforeWithdraw(address _redeemer, address _vault, uint256 _amount) external view;
  function beforeRepay(address _repayer , address _vault, uint256 _amount) external view;

  function joinVault(address _user, bool isDeposit) external;
  function exitVault(address _user, bool isDeposit) external;

  function userValues(address _user, bool _dp) external view returns(uint totalDepositValue, uint totalBorrowValue);
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

interface IUSDOracle {
  // Must 8 dec, same as chainlink decimals.
  function getPrice(address token) external view returns (uint256);
}