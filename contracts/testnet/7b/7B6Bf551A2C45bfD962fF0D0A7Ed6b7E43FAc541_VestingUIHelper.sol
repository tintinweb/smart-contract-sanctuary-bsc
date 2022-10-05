// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IVestingUIHelper.sol";
import "./interfaces/IVesting.sol";

/// @title Vesting
/// @dev Multiple vesting realese contract.
contract VestingUIHelper is IVestingUIHelper {
  /// @notice Address of Vesting contract.
  IVesting public immutable VESTING;
  /// @notice Vested token.
  IERC20 public immutable VESTED_TOKEN;

  /// @dev Constructor. Sets the Vesting and ERC-20 token contracts address.
  /// @param _vesting Address of vesting;
  /// @param _token Address of token.
  constructor(address _vesting, address _token) {
    if (_vesting == address(0) || _token == address(0)) {
      revert ZeroAddress();
    }
    VESTING = IVesting(_vesting);
    VESTED_TOKEN = IERC20(_token);
  }

  /// @dev Gets all info about vested token.
  /// @return Data about values of the vested token.
  function getVestedTokenUIData() external view override returns (VestedTokenUIData memory) {
    VestedTokenUIData memory data = VestedTokenUIData({
      totalTokenAllocation: _getTotalTokenAllocation(),
      totalTokensInVestings: _getTotalTokensInVestings(),
      totalUnusedTokens: _getUnusedTokens(),
      vestedToken: address(VESTED_TOKEN)
    });

    return data;
  }

  /// @dev Gets all user's info about vesting by his id.
  /// @param _user Address of user.
  /// @param _id Vesting's id.
  /// @return User's data about values of the vesting.
  function getUserVestingUIData(address _user, uint256 _id)
    external
    view
    override
    returns (UserVestingUIData memory)
  {
    if (_user == address(0)) {
      revert ZeroAddress();
    }

    IVesting.Vesting memory userVesting = VESTING.getUserVestingById(_user, _id);

    UserVestingUIData memory data = UserVestingUIData({
      startDate: userVesting.vestingSchedule.startDate,
      vestingDuration: userVesting.vestingSchedule.vestingDuration,
      totalAmount: userVesting.amount,
      claimedAmount: userVesting.claimedAmount,
      unclaimedAmount: VESTING.getWithdrawableAmount(_user)
    });

    return data;
  }

  /// @dev Gets total token allocation.
  /// @return Amount of tokens on the vesting contract.
  function _getTotalTokenAllocation() internal view returns (uint256) {
    return VESTED_TOKEN.balanceOf(address(VESTING));
  }

  /// @dev Gets amount of tokens which are used in vestings.
  /// @return Amount of reserved tokens.
  function _getTotalTokensInVestings() internal view returns (uint256) {
    return VESTING.getTotalTokensInVestings();
  }

  /// @dev Gets amount of tokens that are not used in any vesting.
  /// @return Amount of unused tokens.
  function _getUnusedTokens() internal view returns (uint256) {
    return _getTotalTokenAllocation() - _getTotalTokensInVestings();
  }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

/// @title Interface for a vesting contract
interface IVesting {
  /// @notice Structure which describe vesting.
  /// @dev It is used for saving data about vesting.
  /// @param vestingSchedule object which decribe vesting sheduel.
  /// @param amount amount of tokens for vesting.
  /// @param claimedAmount amount of claimed tokens by beneficiary.
  /// @param beneficiary address of beneficiary.
  struct Vesting {
    LinearVestingSchedule vestingSchedule;
    uint256 amount;
    uint256 claimedAmount;
    address beneficiary;
  }

  /// @notice Structure which describe vesting schedule.
  /// @dev It is used for calculations of withdrawable tokens.
  /// @param startDate timeStamp of start date.
  /// @param vestingDuration duration of vesting period.
  struct LinearVestingSchedule {
    uint256 startDate;
    uint256 vestingDuration;
  }

  /// @notice It is generated when owner add vesting for some beneficiary.
  /// @param beneficiary address of beneficiary.
  /// @param amount amount of tokens for vesting.
  /// @param schedule object which describe vesting schedule.
  event VestingAdded(address indexed beneficiary, uint256 amount, LinearVestingSchedule schedule);

  /// @notice It is generated when beneficiary withdraws tokens.
  /// @param beneficiary address of beneficiary.
  /// @param amount amount of withdrawn tokens.
  event VestingWithdrawn(address indexed beneficiary, uint256 amount);

  /// @dev Beneficiary or token address is zero.
  error ZeroAddress();

  /// @dev Zero amount of tokens.
  error ZeroAmount();

  /// @dev Zero duration of vesting.
  error ZeroDuration();

  /// @dev Arrays of function parameters have different lengths.
  /// The values of `beneficiaries`, `amounts` and `vestings` must be the same.
  /// @param beneficiaries number of beneficiaries.
  /// @param amounts number of amounts.
  /// @param vestings number of vestings.
  error ParametersLengthMismatch(uint256 beneficiaries, uint256 amounts, uint256 vestings);

  /// @dev There are no tokens that are not used in vestings.
  error NoAvailableTokens();

  /// @dev Vesting with `id` does not exist.
  /// @param id invalid vesting id.
  error VestingDoesNotExist(uint256 id);

  /// @dev Incorrect vesting period. `startdate` must be greater
  /// than `currentTimestamp`.
  /// @param startDate timeStamp of start date.
  /// @param currentTimestamp current timestamp.
  error IncorrectVestingPeriod(uint256 startDate, uint256 currentTimestamp);

  /// @dev Insufficient balance for transfer. Needed `required` but only
  /// `available` available.
  /// @param available balance available.
  /// @param required requested amount to transfer.
  error InsufficientBalance(uint256 available, uint256 required);

  /// Beneficiary has no vesting for release.
  /// @param account address of the beneficiary
  error UserHasNoVestings(address account);

  /// @dev Create vesting
  /// @param _beneficiary Address of beneficiary
  /// @param _amount Amount of tokens for vesting
  /// @param _vestingSchedule Vesting schedule for vesting
  function createVesting(
    address _beneficiary,
    uint256 _amount,
    LinearVestingSchedule calldata _vestingSchedule
  ) external;

  /// @dev Create multiple vestings
  /// @param _beneficiaries Addresses of beneficiaries
  /// @param _amounts Amount of tokens for vesting
  /// @param _vestingSchedules Vesting schedule for vestings
  function createVestingsBatch(
    address[] calldata _beneficiaries,
    uint256[] calldata _amounts,
    LinearVestingSchedule[] calldata _vestingSchedules
  ) external;

  /// @dev Add tokens for vesting
  /// @param _amount Amount of tokens for vesting
  function addTokensForVesting(uint256 _amount) external;

  /// @dev Allow to withdraw tokens what are not used for any vestings
  function emergencyWithdraw() external;

  /// @dev Withdraw tokens from vesting by beneficiary (msg.sender)
  function withdraw() external;

  /// @dev Shows withdrawable amount for beneficiary
  /// @param _beneficiary address to show vested amount for
  /// @return amount of tokens which _beneficiary can withdraw
  function getWithdrawableAmount(address _beneficiary) external view returns (uint256);

  /// @dev Gets amount of tokens which are used in vestings
  /// @return Amount of reserved tokens
  function getTotalTokensInVestings() external view returns (uint256);

  /// @dev Gets info about user's vesting by his id
  /// @param _user address of user
  /// @param _id vesting's id
  /// @return info about values of the vesting
  function getUserVestingById(address _user, uint256 _id) external view returns (Vesting memory);
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

interface IVestingUIHelper {
  /// @notice Structure which describe vested token for UI.
  /// @dev It is used for saving data about token.
  /// @param totalTokenAllocation amount of tokens on the contract.
  /// @param totalTokensInVestings amount of tokens which are reserved in another vestings.
  /// @param totalUnusedTokens amount of unused tokens.
  /// @param vestedToken address of vested token.
  struct VestedTokenUIData {
    uint256 totalTokenAllocation;
    uint256 totalTokensInVestings;
    uint256 totalUnusedTokens;
    address vestedToken;
  }

  /// @notice Structure which describe user's vesting for UI.
  /// @dev It is used for saving data about vesting.
  /// @param startDate timeStamp of start date.
  /// @param vestingDuration duration of vesting period.
  /// @param totalAmount amount of tokens for vesting.
  /// @param claimedAmount amount of claimed tokens by user.
  /// @param unclaimedAmount amount of withdrawable tokens.
  struct UserVestingUIData {
    uint256 startDate;
    uint256 vestingDuration;
    uint256 totalAmount;
    uint256 claimedAmount;
    uint256 unclaimedAmount;
  }

  /// @dev Beneficiary or token address is zero.
  error ZeroAddress();

  /// @dev Gets all info about vested token.
  /// @return Data about values of the vested token.
  function getVestedTokenUIData() external view returns (VestedTokenUIData memory);

  /// @dev Gets all user's info about vesting by his id.
  /// @param _user Address of user.
  /// @param _id Vesting's id.
  /// @return User's data about values of the vesting.
  function getUserVestingUIData(address _user, uint256 _id)
    external
    view
    returns (UserVestingUIData memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}