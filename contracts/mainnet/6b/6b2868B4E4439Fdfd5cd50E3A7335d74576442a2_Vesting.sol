// SPDX-License-Identifier: UNLICENSED

// Author: TrejGun
// Email: [email protected]
// Website: https://gemunion.io/
/// @author The Gemunion Team
/// @title A contract for Vesting GEMM
/// @dev A contract for vesting with unlocking by months for various coin holders

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Vesting is Ownable {

  using SafeERC20 for IERC20;

  // <================================ Variable and Constant ================================>
  //A variable for the token and start date
  IERC20 public _gemStoneToken;

  //constants of percentages of the total amount
  uint256 constant initialSupply = 499965990000000000000000000;
  uint256 constant teamPecentage = 2000; // 20%
  uint256 constant advisorsPecentage = 250; // 2.5%
  uint256 constant seedRoundPecentage = 200; // 2%
  uint256 constant privateSalePecentage = 933; // 9.33%
  uint256 constant publicSalePecentage = 500; // 5%
  uint256 constant liquidityBootstrappingPecentage = 617; // 6.17%
  uint256 constant partnershipsAndMarketingPecentage = 500; // 5%
  uint256 constant playerRewardPoolPecentage = 5000; // 50%

  //the total number of tokens according to the formula: (initialSupply * percent) / 10000
  uint256 teamTotal = _setInitialTotalBalance(teamPecentage);  // 20%
  uint256 advisorsTotal = _setInitialTotalBalance(advisorsPecentage);// 2.5%
  uint256 seedRoundTotal = _setInitialTotalBalance(seedRoundPecentage); // 2%
  uint256 privateSaleTotal = _setInitialTotalBalance(privateSalePecentage); // 9.33%
  uint256 publicSaleTotal = _setInitialTotalBalance(publicSalePecentage); // 5%
  uint256 liquidityBootstrappingTotal = _setInitialTotalBalance(liquidityBootstrappingPecentage);// 6.17%
  uint256 partnershipsAndMarketingTotal = _setInitialTotalBalance(partnershipsAndMarketingPecentage); // 5%
  uint256 playerRewardPoolTotal = _setInitialTotalBalance(playerRewardPoolPecentage); // 50%

  uint256 constant oneMonth = 2629743; // 1 month in seconds

  // <================================ Mapping and Array ================================>

  mapping(address => Share) public teamShares;
  mapping(address => Share) public advisorsShares;
  mapping(address => Share) public seedRoundsShares;
  mapping(address => Share) public privateSalesShares;
  mapping(address => Share) public publicSalesShares;
  mapping(address => uint256) public liquidityBootstrapping;
  mapping(address => uint256) public partnershipsandMarketing;
  mapping(address => uint256) public playerRewardPool;
  Share[] private shareStruct;
  Share[] private seedStruct;
  Share[] private advisorStruct;
  Share[] private privateStruct;
  Share[] private publicStruct;



  // <================================ Struct ================================>

  struct Share {
    uint256 releaseTime;
    uint256 lastWithdraw;
    uint256 value;
    uint256 valueInMonths;
    bool exist;
  }

  // <================================ EVENT ================================>

  event TokensTransferedToVestingBalance(address indexed sender, uint256 indexed amount);
  event TokensUnlocked(address indexed buyer, uint256 indexed unlockedAmount);
  event NewBuyer(address indexed buyer, uint256 indexed valueToByu);


  // <================================ CONSTRUCTOR AND INITIALIZER ================================>
  /// @notice the constructor assigns an address token
  /// @dev the address of the token that will be unblocked and sent by the token buyer
  /// @param gemStoneToken token address
  constructor(
    address gemStoneToken
  ){
    require(gemStoneToken != address(0), "IDO: GemStone token address must not be zero");
    _gemStoneToken = IERC20(gemStoneToken);
  }

  /// @notice the initialization function assigns the global variable _startDate the beginning of the westing and sends a token to this contract.
  /// @dev function for initialization when the fitting starts and sends a token to the contract, only the owner can call
  /// @notice the start time starts at 10 a.m. on the selected date
  function initialize() external onlyOwner {
    _gemStoneToken.safeTransferFrom(_msgSender(), address(this), initialSupply);
  }

  // <================================ FUNCTIONS ================================>

  /// @notice function for adding new holders and their number of tokens
  /// @dev addNewFolder function adds new users in the format of an array, an array of addresses and an array of value(only the owner can add)
  ///and to choose which group the token holders belong to, "code" from 1 to 5 where 1=team, 2=advisors, 3=seedRound, 4=privateSale, 5=publicSale
  /// @param addresses array of addresses
  /// @param values array of the number of tokens
  /// @param code which group does it belong to
  function addNewHolder(address[] memory addresses, uint256[] memory values, uint256 _startDate, uint256 code) public onlyOwner {
    require(code > 0 && code <= 5, "choose a number from 1 to 5");
    require(addresses.length == values.length, "the number of addresses and amounts must be the same");

    uint256 startDateWithCliff = _startDate + 15778458;
    if (code == 1) {
      Share memory newShard;
      for (uint256 i = 0; i < addresses.length; i++) {
        newShard.value = values[i];
        newShard.releaseTime = startDateWithCliff;
        newShard.lastWithdraw = startDateWithCliff;
        newShard.valueInMonths = newShard.value / 12;
        newShard.exist = true;
        shareStruct.push(newShard);
        teamShares[addresses[i]] = shareStruct[i];
        emit NewBuyer(addresses[i], values[i]);
      }
    } else if (code == 2) {
      Share memory newShard;
      for (uint256 i = 0; i < addresses.length; i++) {
        newShard.value = values[i];
        newShard.releaseTime = startDateWithCliff;
        newShard.lastWithdraw = startDateWithCliff;
        newShard.valueInMonths = newShard.value / 24;
        newShard.exist = true;
        advisorStruct.push(newShard);
        advisorsShares[addresses[i]] = advisorStruct[i];
        emit NewBuyer(addresses[i], values[i]);
      }
    } else if (code == 3) {
      Share memory newShard;
      for (uint256 i = 0; i < addresses.length; i++) {
        newShard.value = values[i];
        newShard.releaseTime = _startDate;
        newShard.lastWithdraw = _startDate;
        newShard.valueInMonths = newShard.value / 12;
        newShard.exist = true;
        seedStruct.push(newShard);
        seedRoundsShares[addresses[i]] = seedStruct[i];
        emit NewBuyer(addresses[i], values[i]);
      }
    } else if (code == 4) {
      Share memory newShard;
      for (uint256 i = 0; i < addresses.length; i++) {
        newShard.value = values[i];
        newShard.releaseTime = _startDate;
        newShard.lastWithdraw = _startDate;
        newShard.valueInMonths = newShard.value / 6;
        newShard.exist = true;
        privateStruct.push(newShard);
        privateSalesShares[addresses[i]] = privateStruct[i];
        emit NewBuyer(addresses[i], values[i]);
      }
    } else if (code == 5) {
      Share memory newShard;
      for (uint256 i = 0; i < addresses.length; i++) {
        newShard.value = values[i];
        newShard.releaseTime = _startDate;
        newShard.lastWithdraw = _startDate;
        newShard.valueInMonths = newShard.value / 3;
        newShard.exist = true;
        publicStruct.push(newShard);
        publicSalesShares[addresses[i]] = publicStruct[i];
        emit NewBuyer(addresses[i], values[i]);
      }
    }
  }

  /// @notice function for withdrawing team tokens
  /// @dev the function for withdraw the team of their tokens must be called by the token holder at least once a month
  function withdrawalTeamShare() external {
    address tokenOwner = _msgSender();
    require(teamShares[tokenOwner].exist == true, "account not exist");
    require(block.timestamp >= teamShares[tokenOwner].releaseTime, "Time is not up. Cannot release share");
    require(block.timestamp >= teamShares[tokenOwner].lastWithdraw + oneMonth, "A month of westing has not passed");
    require(teamShares[tokenOwner].value != 0, "There are no available unlocked tokens");
    require(teamTotal != 0, "There are no available unlocked tokens");

    uint256 totalMonth = _monthsSinceDate(teamShares[tokenOwner].lastWithdraw);
    uint256 totalUnlocked = teamShares[tokenOwner].valueInMonths * totalMonth;

    uint256 vestingThreeMonths = publicSalesShares[tokenOwner].releaseTime + 7889229 + oneMonth;

    if (vestingThreeMonths < block.timestamp) {
      uint256 value = teamShares[tokenOwner].value;
      teamTotal -= value;
      teamShares[tokenOwner].value = 0;
      teamShares[tokenOwner].valueInMonths = 0;
      teamShares[tokenOwner].lastWithdraw = block.timestamp;
      _gemStoneToken.safeTransfer(tokenOwner, value);
      emit TokensUnlocked(tokenOwner, value);
    } else if (teamShares[tokenOwner].value >= totalUnlocked) {
      teamShares[tokenOwner].value -= totalUnlocked;
      teamTotal -= totalUnlocked;
      teamShares[tokenOwner].lastWithdraw = block.timestamp;
      _gemStoneToken.safeTransfer(tokenOwner, totalUnlocked);
      emit TokensUnlocked(tokenOwner, totalUnlocked);
    } else if (teamShares[tokenOwner].value < totalUnlocked) {
      uint256 value = teamShares[tokenOwner].value;
      teamShares[tokenOwner].value -= value;
      teamTotal -= value;
      teamShares[tokenOwner].lastWithdraw = block.timestamp;
      _gemStoneToken.safeTransfer(tokenOwner, value);
      emit TokensUnlocked(tokenOwner, value);
    }
  }

  /// @notice function for withdrawing advisors tokens
  /// @dev the function for withdraw the advisors buyers of their tokens must be called by the token holder at least once a month
  function withdrawalAdvisorsShare() external {
    address tokenOwner = _msgSender();
    require(advisorsShares[tokenOwner].exist == true, "account not exist");
    require(block.timestamp >= advisorsShares[tokenOwner].releaseTime, "Time is not up. Cannot release share");
    require(block.timestamp >= advisorsShares[tokenOwner].lastWithdraw + oneMonth, "A month of westing has not passed");
    require(advisorsShares[tokenOwner].value != 0, "You don't have any tokens");
    require(advisorsTotal != 0, "There are no available unlocked tokens");

    uint256 totalMonth = _monthsSinceDate(advisorsShares[tokenOwner].lastWithdraw);
    uint256 totalUnlocked = advisorsShares[tokenOwner].valueInMonths * totalMonth;

    uint256 vestingThreeMonths = publicSalesShares[tokenOwner].releaseTime + 7889229 + oneMonth;

    if (vestingThreeMonths < block.timestamp) {
      uint256 value = advisorsShares[tokenOwner].value;
      advisorsTotal -= value;
      advisorsShares[tokenOwner].value = 0;
      advisorsShares[tokenOwner].valueInMonths = 0;
      advisorsShares[tokenOwner].lastWithdraw = block.timestamp;
      _gemStoneToken.safeTransfer(tokenOwner, value);
      emit TokensUnlocked(tokenOwner, value);
    } else if (advisorsShares[tokenOwner].value >= totalUnlocked) {
      advisorsShares[tokenOwner].value -= totalUnlocked;
      advisorsTotal -= totalUnlocked;
      advisorsShares[tokenOwner].lastWithdraw = block.timestamp;
      _gemStoneToken.safeTransfer(tokenOwner, totalUnlocked);
      emit TokensUnlocked(tokenOwner, totalUnlocked);
    } else if (advisorsShares[tokenOwner].value < totalUnlocked) {
      uint256 value = advisorsShares[tokenOwner].value;
      advisorsShares[tokenOwner].value -= value;
      advisorsTotal -= value;
      advisorsShares[tokenOwner].lastWithdraw = block.timestamp;
      _gemStoneToken.safeTransfer(tokenOwner, value);
      emit TokensUnlocked(tokenOwner, value);
    }
  }

  /// @notice function for withdrawing seed round tokens
  /// @dev the function for withdraw the seed round buyers of their tokens must be called by the token holder at least once a month
  function withdrawalSeedRoundShare() external {
    address tokenOwner = _msgSender();
    require(seedRoundsShares[tokenOwner].exist == true, "account not exist");
    require(block.timestamp >= seedRoundsShares[tokenOwner].releaseTime, "Time is not up. Cannot release share");
    require(block.timestamp >= seedRoundsShares[tokenOwner].lastWithdraw + oneMonth, "A month of westing has not passed");
    require(seedRoundsShares[tokenOwner].value != 0, "You don't have any tokens");
    require(seedRoundTotal != 0, " There are no available unlocked tokens");

    uint256 totalMonth = _monthsSinceDate(seedRoundsShares[tokenOwner].lastWithdraw);
    uint256 totalUnlocked = seedRoundsShares[tokenOwner].valueInMonths * totalMonth;

    uint256 vestingThreeMonths = publicSalesShares[tokenOwner].releaseTime + 7889229 + oneMonth;

    if (vestingThreeMonths < block.timestamp) {
      uint256 value = seedRoundsShares[tokenOwner].value;
      seedRoundTotal -= value;
      seedRoundsShares[tokenOwner].value = 0;
      seedRoundsShares[tokenOwner].valueInMonths = 0;
      seedRoundsShares[tokenOwner].lastWithdraw = block.timestamp;
      _gemStoneToken.safeTransfer(tokenOwner, value);
      emit TokensUnlocked(tokenOwner, value);
    } else if (seedRoundsShares[tokenOwner].value >= totalUnlocked) {
      seedRoundsShares[tokenOwner].value -= totalUnlocked;
      seedRoundTotal -= totalUnlocked;
      seedRoundsShares[tokenOwner].lastWithdraw = block.timestamp;
      _gemStoneToken.safeTransfer(tokenOwner, totalUnlocked);
      emit TokensUnlocked(tokenOwner, totalUnlocked);
    } else if (seedRoundsShares[tokenOwner].value < totalUnlocked) {
      uint256 value = seedRoundsShares[tokenOwner].value;
      seedRoundsShares[tokenOwner].value -= value;
      seedRoundTotal -= value;
      seedRoundsShares[tokenOwner].lastWithdraw = block.timestamp;
      _gemStoneToken.safeTransfer(tokenOwner, value);
      emit TokensUnlocked(tokenOwner, value);
    }
  }

  /// @notice function for withdrawing private sale tokens
  /// @dev the function for withdraw the private buyers of their tokens must be called by the token holder at least once a month
  function withdrawalPrivateSaleShare() external {
    address tokenOwner = _msgSender();
    require(privateSalesShares[tokenOwner].exist == true, "account not exist");
    require(block.timestamp >= privateSalesShares[tokenOwner].releaseTime, "Time is not up. Cannot release share");
    require(block.timestamp >= privateSalesShares[tokenOwner].lastWithdraw + oneMonth, "A month of westing has not passed");
    require(privateSalesShares[tokenOwner].value != 0, "You don't have any tokens");
    require(privateSaleTotal != 0, "There are no available unlocked tokens");

    uint256 totalMonth = _monthsSinceDate(privateSalesShares[tokenOwner].lastWithdraw);
    uint256 totalUnlocked = privateSalesShares[tokenOwner].valueInMonths * totalMonth;

    uint256 vestingThreeMonths = publicSalesShares[tokenOwner].releaseTime + 7889229 + oneMonth;

    if (vestingThreeMonths < block.timestamp) {
      uint256 value = privateSalesShares[tokenOwner].value;
      privateSaleTotal -= value;
      privateSalesShares[tokenOwner].value = 0;
      privateSalesShares[tokenOwner].valueInMonths = 0;
      privateSalesShares[tokenOwner].lastWithdraw = block.timestamp;
      _gemStoneToken.safeTransfer(tokenOwner, value);
      emit TokensUnlocked(tokenOwner, value);
    } else if (privateSalesShares[tokenOwner].value >= totalUnlocked) {
      privateSalesShares[tokenOwner].value -= totalUnlocked;
      privateSaleTotal -= totalUnlocked;
      privateSalesShares[tokenOwner].lastWithdraw = block.timestamp;
      _gemStoneToken.safeTransfer(tokenOwner, totalUnlocked);
      emit TokensUnlocked(tokenOwner, totalUnlocked);
    } else if (privateSalesShares[tokenOwner].value < totalUnlocked) {
      uint256 value = privateSalesShares[tokenOwner].value;
      privateSalesShares[tokenOwner].value -= value;
      privateSaleTotal -= value;
      privateSalesShares[tokenOwner].lastWithdraw = block.timestamp;
      _gemStoneToken.safeTransfer(tokenOwner, value);
      emit TokensUnlocked(tokenOwner, value);
    }
  }


  /// @notice function for withdrawing public sale tokens
  /// @dev the function for withdraw the public buyers of their tokens must be called by the token holder at least once a month
  function withdrawalPublicSaleShare() external {
    address tokenOwner = _msgSender();
    require(publicSalesShares[tokenOwner].exist == true, "account not exist");
    require(block.timestamp >= publicSalesShares[tokenOwner].releaseTime, "Time is not up. Cannot release share");
    require(block.timestamp >= publicSalesShares[tokenOwner].lastWithdraw + oneMonth, "A month of westing has not passed");
    require(publicSalesShares[tokenOwner].value != 0, " You don't have any tokens");
    require(publicSaleTotal != 0, "There are no available unlocked tokens");

    uint256 totalMonth = _monthsSinceDate(publicSalesShares[tokenOwner].lastWithdraw);
    uint256 totalUnlocked = publicSalesShares[tokenOwner].valueInMonths * totalMonth;

    uint256 vestingThreeMonths = publicSalesShares[tokenOwner].releaseTime + 7889229 + oneMonth;

    if (vestingThreeMonths < block.timestamp) {
      uint256 value = publicSalesShares[tokenOwner].value;
      publicSaleTotal -= value;
      publicSalesShares[tokenOwner].value = 0;
      publicSalesShares[tokenOwner].valueInMonths = 0;
      publicSalesShares[tokenOwner].lastWithdraw = block.timestamp;
      _gemStoneToken.safeTransfer(tokenOwner, value);
      emit TokensUnlocked(tokenOwner, value);
    } else if (publicSalesShares[tokenOwner].value >= totalUnlocked) {
      publicSalesShares[tokenOwner].value -= totalUnlocked;
      publicSaleTotal -= totalUnlocked;
      publicSalesShares[tokenOwner].lastWithdraw = block.timestamp;
      _gemStoneToken.safeTransfer(tokenOwner, totalUnlocked);
      emit TokensUnlocked(tokenOwner, totalUnlocked);
    } else if (publicSalesShares[tokenOwner].value < totalUnlocked) {
      uint256 value = publicSalesShares[tokenOwner].value;
      publicSalesShares[tokenOwner].value -= value;
      publicSaleTotal -= value;
      publicSalesShares[tokenOwner].lastWithdraw = block.timestamp;
      _gemStoneToken.safeTransfer(tokenOwner, value);
      emit TokensUnlocked(tokenOwner, value);
    }
  }

  /// @notice function for sending Liquidity Bootstrapping tokens
  /// @dev function for sending tokens for Liquidity Bootstrapping (only the owner can send)
  /// @param to  recipient's address
  /// @param value number of tokens
  function withdrawalLiquidityBootstrapping(address to, uint256 value) public onlyOwner {
    require(liquidityBootstrappingTotal != 0, "You don't have any tokens");
    require(liquidityBootstrappingTotal >= value, "a lot of tokens");
    _gemStoneToken.safeTransfer(to, value);
    liquidityBootstrapping[to] += value;
    liquidityBootstrappingTotal -= value;
    emit TokensUnlocked(to, value);
  }

  /// @notice function for sending Partner And Marketing tokens
  /// @dev function for sending tokens for Partner And Marketing (only the owner can send)
  /// @param to  recipient's address
  /// @param value number of tokens
  function withdrawalPartnerAndMarketing(address to, uint256 value) public onlyOwner {
    require(partnershipsAndMarketingTotal != 0, "You don't have any tokens");
    require(partnershipsAndMarketingTotal >= value, "a lot of tokens");
    _gemStoneToken.safeTransfer(to, value);
    partnershipsandMarketing[to] += value;
    partnershipsAndMarketingTotal -= value;
    emit TokensUnlocked(to, value);
  }

  /// @notice function for sending Player Reward Pool tokens
  /// @dev function for sending tokens for Player Reward Pool (only the owner can send)
  /// @param to  recipient's address
  /// @param value number of tokens
  function withdrawalPlayerRewardPool(address to, uint256 value) public onlyOwner {
    require(playerRewardPoolTotal != 0, "You don't have any tokens");
    require(playerRewardPoolTotal >= value, "a lot of tokens");
    _gemStoneToken.safeTransfer(to, value);
    playerRewardPool[to] += value;
    playerRewardPoolTotal -= value;
    emit TokensUnlocked(to, value);
  }

  /// @notice function for sending tokens from a contract
  /// @dev the function sends the token from the contract to the address (only the owner can send)
  /// @param to  recipient's address
  function withdrawTo(address to) public onlyOwner {
    uint256 value = _gemStoneToken.balanceOf(address(this));
    _gemStoneToken.safeTransfer(to, value);
    emit TokensUnlocked(to, value);
  }

  /// @notice function for counting the number of past months
  /// @dev the function counts the number of past months according to the formula: (current time is the last output) / month in seconds, according to unix time
  /// @param _timestamp  Time in a unix system
  function _monthsSinceDate(uint256 _timestamp) private view returns (uint256){
    return (block.timestamp - _timestamp) / 2592000;
  }


  /// @notice function for calculating percentages of the total amount of tokens
  /// @dev the function counts the total number of tokens by percentage, the amount of tokens for different groups of buyers by the formula: (initialSupply * percent) / 10000
  /// @param _percentage  percent from constants of percentages of the total amount
  function _setInitialTotalBalance(uint _percentage) private pure returns (uint256){
    return (initialSupply * _percentage) / 10000;
  }


  /// @notice function for viewing the balance on the contract
  /// @dev function for displaying the total number of tokens on the contract
  /// @return uint total number of tokens on the contract
  function getBalanceContract() public view returns (uint256){
    return _gemStoneToken.balanceOf(address(this));
  }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
        return functionCallWithValue(target, data, 0, errorMessage);
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}