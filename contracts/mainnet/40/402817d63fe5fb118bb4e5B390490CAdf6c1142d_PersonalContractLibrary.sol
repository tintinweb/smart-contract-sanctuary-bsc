// SPDX-License-Identifier: GPLv2
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./../../Interfaces/IFactory.sol";
import "./../../Interfaces/IUniswapV2Pair.sol";
import "./../../Interfaces/ITokenConversionLibrary.sol";
import "./../../Interfaces/ITokenConversionStorage.sol";
import "./../../Interfaces/IStrategy.sol";

library PersonalContractLibrary {
  /**
  @notice Estimates current value after claim pending rewards of investment in invetment.token tokens
  @param tokenConversionLibrary library with ITokenConversion interface
  @param tokenConversionStorage store of pathes for exchage
  @param _lpPool pool in which investment currently
  @param _lpAmount expected amount of liquidity pool tokens
  @param _rewards addresses of possible rewards
  @param _toToken pool in which investment currently
  @return estimatedLiquidity estimated output of liquidity pool tokens in invetment.token
  @return estimatedRewards estimated output of rewards in invetment.token
  */
  function estimateInvestment(
    ITokenConversionLibrary tokenConversionLibrary,
    address tokenConversionStorage,
    IUniswapV2Pair _lpPool,
    uint256 _lpAmount,
    address[] calldata _rewards,
    address _toToken
  ) external view returns (
    uint256 estimatedLiquidity,
    uint256 estimatedRewards
  ) {
    for (uint256 i = 0; i < _rewards.length; i++) {
      uint256 balance = IERC20(_rewards[i]).balanceOf(address(this));
      estimatedRewards += tokenConversionLibrary.estimateTokenToToken(
        tokenConversionStorage,
        _rewards[i],
        _toToken,
        balance
      );
    }

    estimatedLiquidity = tokenConversionLibrary.estimatePoolOutput(
      tokenConversionStorage,
      _lpPool,
      _toToken,
      _lpAmount
    );
  }

  /**
  @notice Claim rewards from staking pool
  @param _strategy contract with claim rewards logic
  @param _stakeContractAddress address of staking contract
  @param _pid masterchef pid
  */
  function claimRewards(
    IStrategy _strategy,
    address _stakeContractAddress,
    uint256 _pid
  ) internal {
    (bool status, ) = address(_strategy).delegatecall(
      abi.encodeWithSelector(_strategy.claimRewards.selector, _stakeContractAddress, _pid)
    );
    require(status, 'claimRewards call failed');
  }

  /**
  @notice convert any tokens to any tokens.
  @param _toWhomToIssue is address of personal contract for this user
  @param _tokenToExchange address of token witch will be converted
  @param _tokenToConvertTo address of token witch will be returned
  @param _amount how much will be converted
  */
  function convertTokenToToken(
    IFactory _factory,
    address _toWhomToIssue,
    address _tokenToExchange,
    address _tokenToConvertTo,
    uint256 _amount,
    uint256 _minOutputAmount
  ) internal returns (uint256) {       
    (
      ITokenConversionLibrary tokenConversion,
      ITokenConversionStorage conversionStorage
    ) = _factory.getTokenConversion();

    (bool status, bytes memory result) = address(tokenConversion).delegatecall(
      abi.encodeWithSelector(
        tokenConversion.convertTokenToToken.selector,
        conversionStorage,
        _toWhomToIssue,
        _tokenToExchange,
        _tokenToConvertTo,
        _amount,
        _minOutputAmount
      )
    );

    require(status, 'convertTokenToToken call failed');
    return abi.decode(result, (uint256));
  }

  function approve(address _token, address _spender, uint256 _amount) internal {
    // in case SafeERC20: approve from non-zero to non-zero allowance
    IERC20(_token).approve(_spender, 0);
    IERC20(_token).approve(_spender, _amount);
  }
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
pragma solidity >=0.5.0;

interface IUniswapV2Pair {
  event Approval(address indexed owner, address indexed spender, uint value);
  event Transfer(address indexed from, address indexed to, uint value);

  function name() external pure returns (string memory);
  function symbol() external pure returns (string memory);
  function decimals() external pure returns (uint8);
  function totalSupply() external view returns (uint);
  function balanceOf(address owner) external view returns (uint);
  function allowance(address owner, address spender) external view returns (uint);

  function approve(address spender, uint value) external returns (bool);
  function transfer(address to, uint value) external returns (bool);
  function transferFrom(address from, address to, uint value) external returns (bool);

  function DOMAIN_SEPARATOR() external view returns (bytes32);
  function PERMIT_TYPEHASH() external pure returns (bytes32);
  function nonces(address owner) external view returns (uint);

  function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

  event Mint(address indexed sender, uint amount0, uint amount1);
  event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
  event Swap(
      address indexed sender,
      uint amount0In,
      uint amount1In,
      uint amount0Out,
      uint amount1Out,
      address indexed to
  );
  event Sync(uint112 reserve0, uint112 reserve1);

  function MINIMUM_LIQUIDITY() external pure returns (uint);
  function factory() external view returns (address);
  function token0() external view returns (address);
  function token1() external view returns (address);
  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
  function price0CumulativeLast() external view returns (uint);
  function price1CumulativeLast() external view returns (uint);
  function kLast() external view returns (uint);

  function mint(address to) external returns (uint liquidity);
  function burn(address to) external returns (uint amount0, uint amount1);
  function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
  function skim(address to) external;
  function sync() external;

  function initialize(address, address) external;
}

// SPDX-License-Identifier: GPLv2
pragma solidity 0.8.9;

interface ITokenConversionStorage {
  function exchangesInfo(uint256 index) external returns(
    string memory name,
    address router,
    address factory
  );
}

// SPDX-License-Identifier: GPLv2
pragma solidity 0.8.9;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IUniswapV2Pair.sol";

interface ITokenConversionLibrary {
  function convertTokenToToken(
    address _storageAddress,
    address payable _toWhomToIssue,
    address _fromToken,
    address _toToken,
    uint256 _amount,
    uint256 _minOutputAmount
  ) external returns (uint256);
  function convertArrayOfTokensToToken(
    address _storageAddress,
    address[] memory _tokens,
    address _convertToToken,
    address payable _toWhomToIssue,
    uint256 _minTokensRec
  ) external returns (uint256);
  function estimateTokenToToken(
    address _storageAddress,
    address _fromToken,
    address _toToken,
    uint256 _amount
  ) external view returns (uint256);
  function estimatePoolOutput(
    address _storageAddress,
    IUniswapV2Pair _lpPool,
    address _toToken,
    uint256 _lpAmount
  ) external view returns (uint256 amountOut);
}

// SPDX-License-Identifier: GPLv2
pragma solidity 0.8.9;

interface IStrategy {
  function stake(address, address, uint256, uint256, bytes memory) external;
  function unstake(address, uint256, uint256, bytes memory) external;
  function claimRewards(address, uint256) external;
}

// SPDX-License-Identifier: GPLv2
pragma solidity 0.8.9;

import "./ITokenConversionLibrary.sol";
import "./ITokenConversionStorage.sol";

interface IFactory {
  struct Exchange{
    string name;
    address inContractAddress;
    address outContractAddress;
  }

  struct RiskLevel {
    uint8 value;
    bool wholePlatform;
  }

  function yieldToken() external returns(address yieldToken);
  function isWhitelisted(address _target) external returns(bool isWhitelisted);
  function assertPoolApproved(address _stakeContract, address _liqudityPool, uint8 _riskLevel) external view;
  function enableApproveAssert() external;
  function claimInNativeSettings() external view returns(
    uint256 toDevelopment,
    uint256 toBurn,
    address toToken,
    address to
  );
  function claimInYieldSettings() external view returns(
    uint256 toDevelopment,
    uint256 toBurn,
    address toToken,
    address to
  );
  function getStrategy(uint256 _index) external view returns(address strategy);
  function getYieldStakeSettings() view external returns(
    address yieldStakeContract,
    address yieldStakePair,
    address yieldStakeRouter,
    address yieldStakeFactory,
    uint256 yieldStakeStrategy,
    uint256 yieldStakeLockSeconds,
    address yieldStakeRewardToken
  );
  function getTokenConversion() external view returns(
    ITokenConversionLibrary _library,
    ITokenConversionStorage _storage
  );
  function exchange() external view returns(address);
}