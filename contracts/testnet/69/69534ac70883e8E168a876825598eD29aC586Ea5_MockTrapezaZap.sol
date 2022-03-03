// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;

import "../libraries/SafeERC20.sol";
import "../libraries/SafeMath.sol";
import "../libraries/Address.sol";

import "../interfaces/IERC20.sol";
import "../interfaces/IStakingV2.sol";
import "../interfaces/IStakingHelper.sol";
import "../interfaces/IPancakePair.sol";
import "../interfaces/IPancakeRouter02.sol";
import "../interfaces/IBond.sol";
import "../interfaces/IWETH.sol";

import "../types/TrapezaControlled.sol";

contract MockTrapezaZap is TrapezaControlled {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint256;

  /* ======== STATE VARIABLES ======== */

  address private constant WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
  address private constant BUSD = 0x331Af5B7C8AAf123986f0e3A40F11E2e74D9353E;
  address private constant FIDL = 0x109ecFa5FA985349033C4789D3386c0beE6Cc62B;

  IPancakeRouter02 private constant router = IPancakeRouter02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
  IStakingV2 private stakingV2 = IStakingV2(0x119b879011fC52Fd50A27E7ce645426C0F56c87b);

  mapping(address => bool) private HasApprovedRouter;
  address[] public supportTokens;
  mapping(IBond => uint8) public BondIsLP; // 0 not whitelisted, 1 not LP, 2 is LP

  event ZapAndBonded(address indexed, address indexed, uint256);
  event ZapAndStaked(address indexed, uint256);

  /* ====== MANAGEMENT FUNCTIONS ====== */

  function approveForRouter(address token) public onlyManager {
    if (HasApprovedRouter[token]) return;

    IERC20(token).approve(address(router), uint256(-1));
    HasApprovedRouter[token] = true;
    supportTokens.push(token);
  }

  function addBond(IBond bond, bool isLP) public onlyManager {
    BondIsLP[bond] = isLP ? 2 : 1;
    address p = bond.principle();
    IERC20(p).approve(address(bond), uint256(-1));

    if (isLP) {
      IPancakePair pair = IPancakePair(p);
      approveForRouter(pair.token0());
      approveForRouter(pair.token1());
    }
  }

  function rescueToken(address[] calldata tokens) external onlyManager {
    for (uint256 i = 0; i < tokens.length; i++) {
      IERC20 token = IERC20(tokens[i]);
      uint256 amount = token.balanceOf(address(this));
      token.safeTransfer(manager(), amount);
    }
  }

  function sweep() external onlyManager {
    for (uint256 i = 0; i < supportTokens.length; i++) {
      address token = supportTokens[i];

      if (token == address(0) || token == WBNB) continue;

      uint256 amount = IERC20(token).balanceOf(address(this));

      if (amount > 0) {
        _swapDirect(token, amount, WBNB);
      }
    }

    IWETH(WBNB).withdraw(IERC20(WBNB).balanceOf(address(this)));
    payable(manager()).transfer(payable(address(this)).balance);
  }

  function swapStakingVersion(address newStakingVer) external onlyManager {
    stakingV2 = IStakingV2(newStakingVer);
  }

  // allow receiving BNB
  receive() external payable {}

  /* ======== CONSTRUCTOR ======== */
  constructor() {
    require(router.WETH() == WBNB, "pancake router error");

    approveForRouter(WBNB);
    approveForRouter(BUSD);
    approveForRouter(FIDL);
    IERC20(FIDL).approve(address(stakingV2), uint256(-1));
    //FIDL-BUSD
    addBond(IBond(0x4efdD07fF0d9BB976419e117BaC5D2A7b99F1C4c), true);
    //BUSD
    addBond(IBond(0x67BE82ff2116e4a91C18d18077905dfA6eC37A5c), false);
  }

  /* ======== INTERNAL FUNCTIONS ======== */

  function uintToStr(uint256 _i) internal pure returns (string memory _uintAsString) {
    //convert uint to string, used in revert message
    if (_i == 0) {
      return "0";
    }

    uint256 j = _i;
    uint256 len;

    while (j != 0) {
      len++;
      j /= 10;
    }

    bytes memory bstr = new bytes(len);
    uint256 k = len;

    while (_i != 0) {
      k = k - 1;

      uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
      bytes1 b1 = bytes1(temp);

      bstr[k] = b1;
      _i /= 10;
    }
    return string(bstr);
  }

  function _swapDirect(
    address _from,
    uint256 amount,
    address _to
  ) internal returns (uint256) {
    //no need to swap
    if (_from == _to) return amount;

    address[] memory path;

    path = new address[](2);
    path[0] = _from;
    path[1] = _to;

    uint256[] memory amounts = router.swapExactTokensForTokens(amount, 0, path, address(this), block.timestamp);

    return amounts[amounts.length - 1];
  }

  function _swapByPath(address[] calldata path, uint256 amount) internal returns (uint256) {
    //no need to swap
    if (path.length == 1) return amount;

    uint256[] memory amounts = router.swapExactTokensForTokens(amount, 0, path, address(this), block.timestamp);

    return amounts[amounts.length - 1];
  }

  /**
   * @notice user input a token or BNB, swap it to FIDL (direct or byPath),
   * stake to gFIDL, and output gFIDL to user
   */

  /* ====== ZAP AND STAKE ======*/

  function _ZapAndStake(
    address token,
    uint256 amount,
    uint256 minOutAmount
  ) internal {
    uint256 fidlAmount;

    if (token != FIDL) {
      fidlAmount = _swapDirect(token, amount, FIDL);
    } else {
      fidlAmount = amount;
    }

    require(
      fidlAmount >= minOutAmount,
      string(abi.encodePacked("slippage exceeds, can only preview ", uintToStr(fidlAmount)))
    );

    stakingV2.stake(msg.sender, fidlAmount, true);
    emit ZapAndStaked(msg.sender, fidlAmount);
  }

  function ZapAndStake(
    address token,
    uint256 amount,
    uint256 minOutAmount
  ) public {
    IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

    return _ZapAndStake(token, amount, minOutAmount);
  }

  function BNBZapAndStake(uint256 minOutAmount) external payable {
    uint256 amount = msg.value;
    IWETH(WBNB).deposit{ value: amount }();

    return _ZapAndStake(WBNB, amount, minOutAmount);
  }

  function _ZapAndStakeByPath(
    address[] calldata path,
    uint256 amount,
    uint256 minOutAmount
  ) public {
    require(path[path.length - 1] == FIDL, "path should ends with FIDL");

    uint256 fidlAmount = _swapByPath(path, amount);
    require(
      fidlAmount >= minOutAmount,
      string(abi.encodePacked("slippage exceeds, can only receive", uintToStr(fidlAmount)))
    );

    stakingV2.stake(msg.sender, fidlAmount, true);
  }

  function ZapAndStakeByPath(
    address[] calldata path,
    uint256 amount,
    uint256 minOutAmount
  ) external {
    address token = path[0];
    IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

    return _ZapAndStakeByPath(path, amount, minOutAmount);
  }

  function BNBZapAndStakeByPath(address[] calldata path, uint256 minOutAmount) external payable {
    uint256 amount = msg.value;
    IWETH(WBNB).deposit{ value: amount }();

    require(path[0] == WBNB, "path should start with WBNB");
    return _ZapAndStakeByPath(path, amount, minOutAmount);
  }

  /**
   * @notice user input a token or BNB, swap it to bond principle (direct or byPath),
   * buy bond for user
   */

  /* ====== ZAP AND BOND USE DIRECT SWAP ======*/

  function _swapToLPDirect(
    address token,
    uint256 amount,
    IPancakePair pair
  ) internal returns (uint256 lpAmount) {
    //assume that token has been transfered to this contract
    //swap and add liquidity, receive LP to this
    address token0 = pair.token0();
    address token1 = pair.token1();
    uint256 sellAmount = amount.div(2);

    pair.skim(address(this));

    //_swapDirect will not swap when token == token0
    uint256 token0Amount = _swapDirect(token, sellAmount, token0);
    uint256 token1Amount = _swapDirect(token, sellAmount, token1);
    (, , lpAmount) = router.addLiquidity(
      token0,
      token1,
      token0Amount,
      token1Amount,
      0,
      0,
      address(this),
      block.timestamp
    );
  }

  function _Bond(
    IBond bond,
    uint256 principleAmount,
    uint256 minOutAmount
  ) internal {
    //redeem pending reward before deposit
    if (bond.pendingPayoutFor(msg.sender) > 0) {
      bond.redeem(msg.sender, false);
    }

    uint256 bp = bond.bondPrice();
    uint256 outAmount = bond.deposit(principleAmount, bp, msg.sender);

    require(
      outAmount >= minOutAmount,
      string(abi.encodePacked("slippage exceeds, cam only receive", uintToStr(outAmount)))
    );

    emit ZapAndBonded(address(bond), msg.sender, outAmount);
  }

  function _ZapAndBond(
    address token,
    uint256 amount,
    IBond bond,
    uint256 minOutAmount
  ) internal {
    uint8 isLP = BondIsLP[bond];

    require(isLP > 0, "bond not whitelisted");

    address principle = bond.principle();
    uint256 principleAmount;

    if (isLP == 2) {
      IPancakePair pair = IPancakePair(principle);
      //token -> LP
      principleAmount = _swapToLPDirect(token, amount, pair);
    } else {
      //token -> principle token
      principleAmount = _swapDirect(token, amount, principle);
    }

    return _Bond(bond, principleAmount, minOutAmount);
  }

  function ZapAndBond(
    address token,
    uint256 amount,
    IBond bond,
    uint256 minOutAmount
  ) external {
    IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

    return _ZapAndBond(token, amount, bond, minOutAmount);
  }

  function BNBZapAndBond(IBond bond, uint256 minOutAmount) external payable {
    uint256 amount = msg.value;
    IWETH(WBNB).deposit{ value: amount }();

    return _ZapAndBond(WBNB, amount, bond, minOutAmount);
  }

  /* ====== ZAP AND BOND USE BY PATH SWAP FOR LP ====== */

  function _swapToLPByPath(
    address token,
    uint256 amount,
    address[] calldata path0,
    address[] calldata path1,
    IPancakePair pair
  ) internal returns (uint256 lpAmount) {
    //assume that token has been transfered to this contract
    //swap and add liquidity, receive LP to this
    address token0 = pair.token0();
    address token1 = pair.token1();
    uint256 sellAmount = amount.div(2);

    pair.skim(address(this));

    require(path0[0] == token && path0[path0.length - 1] == token0, "incorrect path0");
    uint256 token0Amount = _swapByPath(path0, sellAmount);

    require(path1[0] == token && path1[path1.length - 1] == token1, "incorrect path1");
    uint256 token1Amount = _swapByPath(path1, sellAmount);

    (, , lpAmount) = router.addLiquidity(
      token0,
      token1,
      token0Amount,
      token1Amount,
      0,
      0,
      address(this),
      block.timestamp
    );
  }

  function _ZapAndBondByPathLP(
    address token,
    uint256 amount,
    address[] calldata path0,
    address[] calldata path1,
    IBond bond,
    uint256 minOutAmount
  ) internal {
    uint8 isLP = BondIsLP[bond];

    require(isLP == 2, "onlyLP is supported for _ZapAndBondByPathLP");

    address principle = bond.principle();
    IPancakePair pair = IPancakePair(principle);

    //token -> LP
    uint256 principleAmount = _swapToLPByPath(token, amount, path0, path1, pair);

    return _Bond(bond, principleAmount, minOutAmount);
  }

  function ZapAndBondByPathLP(
    address token,
    uint256 amount,
    address[] calldata path0,
    address[] calldata path1,
    IBond bond,
    uint256 minOutAmount
  ) external {
    IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

    return _ZapAndBondByPathLP(token, amount, path0, path1, bond, minOutAmount);
  }

  function BNBZapAndBondByPathLP(
    address[] calldata path0,
    address[] calldata path1,
    IBond bond,
    uint256 minOutAmount
  ) external payable {
    uint256 amount = msg.value;
    IWETH(WBNB).deposit{ value: amount }();

    return _ZapAndBondByPathLP(WBNB, amount, path0, path1, bond, minOutAmount);
  }

  /* ====== ZAP AND BOND USE BY PATH SWAP FOR TOKEN ====== */

  function _ZapAndBondByPathToken(
    address token,
    uint256 amount,
    address[] calldata path,
    IBond bond,
    uint256 minOutAmount
  ) internal {
    uint8 isLP = BondIsLP[bond];
    require(isLP == 1, "only Token is supported for _ZapAndBondByPahtToken");

    address principle = bond.principle();
    require(path[0] == token && path[path.length - 1] == principle, "incorrect path");

    //token -> LP
    uint256 principleAmount = _swapByPath(path, amount);

    return _Bond(bond, principleAmount, minOutAmount);
  }

  function ZAPAndBondByPathToken(
    address token,
    uint256 amount,
    address[] calldata path,
    IBond bond,
    uint256 minOutAmount
  ) external {
    IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

    return _ZapAndBondByPathToken(token, amount, path, bond, minOutAmount);
  }

  function BNBZapAndBondByPathToken(
    address[] calldata path,
    IBond bond,
    uint256 minOutAmount
  ) external payable {
    uint256 amount = msg.value;

    IWETH(WBNB).deposit{ value: amount }();
    require(path[0] == WBNB, "path sould start with WBNB");

    return _ZapAndBondByPathToken(WBNB, amount, path, bond, minOutAmount);
  }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.7.5;

import { IERC20 } from "../interfaces/IERC20.sol";

/// @notice Safe IERC20 and ETH transfer library that safely handles missing return values.
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v3-periphery/blob/main/contracts/libraries/TransferHelper.sol)
/// Taken from Solmate
library SafeERC20 {
  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 amount
  ) internal {
    (bool success, bytes memory data) = address(token).call(
      abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, amount)
    );

    require(success && (data.length == 0 || abi.decode(data, (bool))), "TRANSFER_FROM_FAILED");
  }

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 amount
  ) internal {
    (bool success, bytes memory data) = address(token).call(
      abi.encodeWithSelector(IERC20.transfer.selector, to, amount)
    );

    require(success && (data.length == 0 || abi.decode(data, (bool))), "TRANSFER_FAILED");
  }

  function safeApprove(
    IERC20 token,
    address to,
    uint256 amount
  ) internal {
    (bool success, bytes memory data) = address(token).call(
      abi.encodeWithSelector(IERC20.approve.selector, to, amount)
    );

    require(success && (data.length == 0 || abi.decode(data, (bool))), "APPROVE_FAILED");
  }

  function safeTransferETH(address to, uint256 amount) internal {
    (bool success, ) = to.call{ value: amount }(new bytes(0));

    require(success, "ETH_TRANSFER_FAILED");
  }
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.7.5;

// TODO(zx): Replace all instances of SafeMath with OZ implementation
library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;
    assert(a == b * c + (a % b)); // There is no case in which this doesn't hold

    return c;
  }

  // Only used in the  BondingCalculator.sol
  function sqrrt(uint256 a) internal pure returns (uint256 c) {
    if (a > 3) {
      c = a;
      uint256 b = add(div(a, 2), 1);
      while (b < c) {
        c = b;
        b = div(add(div(a, b), b), 2);
      }
    } else if (a != 0) {
      c = 1;
    }
  }
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.7.5;

// TODO(zx): replace with OZ implementation.
library Address {
  /**
   * @dev Returns true if `account` is a contract.
   *
   * [IMPORTANT]
   * ====
   * It is unsafe to assume that an address for which this function returns
   * false is an externally-owned account (EOA) and not a contract.
   *
   * Among others, `isContract` will return false for the following
   * types of addresses:
   *
   *  - an externally-owned account
   *  - a contract in construction
   *  - an address where a contract will be created
   *  - an address where a contract lived, but was destroyed
   * ====
   */
  function isContract(address account) internal view returns (bool) {
    // This method relies in extcodesize, which returns 0 for contracts in
    // construction, since the code is only stored at the end of the
    // constructor execution.

    uint256 size;
    // solhint-disable-next-line no-inline-assembly
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
  }

  /**
   * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
   * `recipient`, forwarding all available gas and reverting on errors.
   *
   * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
   * of certain opcodes, possibly making contracts go over the 2300 gas limit
   * imposed by `transfer`, making them unable to receive funds via
   * `transfer`. {sendValue} removes this limitation.
   *
   * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
   *
   * IMPORTANT: because control is transferred to `recipient`, care must be
   * taken to not create reentrancy vulnerabilities. Consider using
   * {ReentrancyGuard} or the
   * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
   */
  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, "Address: insufficient balance");

    // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
    (bool success, ) = recipient.call{ value: amount }("");
    require(success, "Address: unable to send value, recipient may have reverted");
  }

  /**
   * @dev Performs a Solidity function call using a low level `call`. A
   * plain`call` is an unsafe replacement for a function call: use this
   * function instead.
   *
   * If `target` reverts with a revert reason, it is bubbled up by this
   * function (like regular Solidity function calls).
   *
   * Returns the raw returned data. To convert to the expected return value,
   * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
   *
   * Requirements:
   *
   * - `target` must be a contract.
   * - calling `target` with `data` must not revert.
   *
   * _Available since v3.1._
   */
  function functionCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionCall(target, data, "Address: low-level call failed");
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
   * `errorMessage` as a fallback revert reason when `target` reverts.
   *
   * _Available since v3.1._
   */
  function functionCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {
    return _functionCallWithValue(target, data, 0, errorMessage);
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
   * but also transferring `value` wei to `target`.
   *
   * Requirements:
   *
   * - the calling contract must have an ETH balance of at least `value`.
   * - the called Solidity function must be `payable`.
   *
   * _Available since v3.1._
   */
  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value
  ) internal returns (bytes memory) {
    return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
  }

  /**
   * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
   * with `errorMessage` as a fallback revert reason when `target` reverts.
   *
   * _Available since v3.1._
   */
  // function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
  //     require(address(this).balance >= value, "Address: insufficient balance for call");
  //     return _functionCallWithValue(target, data, value, errorMessage);
  // }
  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value,
    string memory errorMessage
  ) internal returns (bytes memory) {
    require(address(this).balance >= value, "Address: insufficient balance for call");
    require(isContract(target), "Address: call to non-contract");

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = target.call{ value: value }(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }

  function _functionCallWithValue(
    address target,
    bytes memory data,
    uint256 weiValue,
    string memory errorMessage
  ) private returns (bytes memory) {
    require(isContract(target), "Address: call to non-contract");

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
    if (success) {
      return returndata;
    } else {
      // Look for revert reason and bubble it up if present
      if (returndata.length > 0) {
        // The easiest way to bubble the revert reason is using memory via assembly

        // solhint-disable-next-line no-inline-assembly
        assembly {
          let returndata_size := mload(returndata)
          revert(add(32, returndata), returndata_size)
        }
      } else {
        revert(errorMessage);
      }
    }
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
   * but performing a static call.
   *
   * _Available since v3.3._
   */
  function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
    return functionStaticCall(target, data, "Address: low-level static call failed");
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
   * but performing a static call.
   *
   * _Available since v3.3._
   */
  function functionStaticCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal view returns (bytes memory) {
    require(isContract(target), "Address: static call to non-contract");

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = target.staticcall(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
   * but performing a delegate call.
   *
   * _Available since v3.3._
   */
  function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionDelegateCall(target, data, "Address: low-level delegate call failed");
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
   * but performing a delegate call.
   *
   * _Available since v3.3._
   */
  function functionDelegateCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {
    require(isContract(target), "Address: delegate call to non-contract");

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = target.delegatecall(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }

  function _verifyCallResult(
    bool success,
    bytes memory returndata,
    string memory errorMessage
  ) private pure returns (bytes memory) {
    if (success) {
      return returndata;
    } else {
      // Look for revert reason and bubble it up if present
      if (returndata.length > 0) {
        // The easiest way to bubble the revert reason is using memory via assembly

        // solhint-disable-next-line no-inline-assembly
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

// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.7.5;

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.7.5;

interface IStakingV2 {
  function stake(
    address _to,
    uint256 _amount,
    bool _claim
  ) external returns (uint256);

  function unstake(
    address _to,
    uint256 _amount,
    bool _rebasing
  ) external returns (uint256);

  function index() external view returns (uint256);
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;

interface IStakingHelper {
  function stake(uint256 _amount, address _recipient) external returns (bool);

  function claim(address _recipient) external;
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;

interface IPancakePair {
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);

  function name() external pure returns (string memory);

  function symbol() external pure returns (string memory);

  function decimals() external pure returns (uint8);

  function totalSupply() external view returns (uint256);

  function balanceOf(address owner) external view returns (uint256);

  function allowance(address owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 value) external returns (bool);

  function transfer(address to, uint256 value) external returns (bool);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool);

  function DOMAIN_SEPARATOR() external view returns (bytes32);

  function PERMIT_TYPEHASH() external pure returns (bytes32);

  function nonces(address owner) external view returns (uint256);

  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  event Mint(address indexed sender, uint256 amount0, uint256 amount1);
  event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
  event Swap(
    address indexed sender,
    uint256 amount0In,
    uint256 amount1In,
    uint256 amount0Out,
    uint256 amount1Out,
    address indexed to
  );
  event Sync(uint112 reserve0, uint112 reserve1);

  function MINIMUM_LIQUIDITY() external pure returns (uint256);

  function factory() external view returns (address);

  function token0() external view returns (address);

  function token1() external view returns (address);

  function getReserves()
    external
    view
    returns (
      uint112 reserve0,
      uint112 reserve1,
      uint32 blockTimestampLast
    );

  function price0CumulativeLast() external view returns (uint256);

  function price1CumulativeLast() external view returns (uint256);

  function kLast() external view returns (uint256);

  function mint(address to) external returns (uint256 liquidity);

  function burn(address to) external returns (uint256 amount0, uint256 amount1);

  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external;

  function skim(address to) external;

  function sync() external;

  function initialize(address, address) external;
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;

import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
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

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;

interface IBond {
  function principle() external returns (address);

  function bondPrice() external view returns (uint256 price_);

  function deposit(
    uint256 _amount,
    uint256 _maxPrice,
    address _depositor
  ) external returns (uint256);

  function redeem(address _recipient, bool _stake) external returns (uint256);

  function pendingPayoutFor(address _depositor) external view returns (uint256 pendingPayout_);
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;

interface IWETH {
  function approve(address spender, uint256 value) external returns (bool);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function deposit() external payable;

  function withdraw(uint256 amount) external;
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;

import "../interfaces/ITrapezaAuthority.sol";

contract TrapezaControlled is ITrapezaAuthority {
  address internal _owner;
  address internal _newOwner;

  event OwnershipPushed(address indexed previousOwner, address indexed newOwner);
  event OwnershipPulled(address indexed previousOwner, address indexed newOwner);

  constructor() {
    _owner = msg.sender;
    emit OwnershipPushed(address(0), _owner);
  }

  function manager() public view override returns (address) {
    return _owner;
  }

  modifier onlyManager() {
    require(_owner == msg.sender, "Ownable: caller is not the owner");
    _;
  }

  function renounceManagement() public virtual override onlyManager {
    emit OwnershipPushed(_owner, address(0));
    _owner = address(0);
  }

  function pushManagement(address newOwner_) public virtual override onlyManager {
    require(newOwner_ != address(0), "Ownable: new owner is the zero address");
    emit OwnershipPushed(_owner, newOwner_);
    _newOwner = newOwner_;
  }

  function pullManagement() public virtual override {
    require(msg.sender == _newOwner, "Ownable: must be new owner to pull");
    emit OwnershipPulled(_owner, _newOwner);
    _owner = _newOwner;
  }
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;

interface IPancakeRouter01 {
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

  function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

  function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;

interface ITrapezaAuthority {
  function manager() external view returns (address);

  function renounceManagement() external;

  function pushManagement(address newOwner_) external;

  function pullManagement() external;
}