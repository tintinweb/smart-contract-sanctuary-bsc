// SPDX-License-Identifier: UNLICENSED
// Developed by: dxsoftware.net

pragma solidity 0.8.6;

pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./libraries/BokkyPooBahsDateTimeLibrary.sol";
import "./interfaces/ISummitswapRouter02.sol";
import "./interfaces/IERC20.sol";
import "../structs/PresaleInfo.sol";
import "../structs/PresaleFeeInfo.sol";
import "./shared/Ownable.sol";

contract SummitCustomPresale is Ownable, ReentrancyGuard {
  using BokkyPooBahsDateTimeLibrary for uint256;

  address private constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

  address public serviceFeeReceiver;
  address public defaultAdmin;
  address[] public contributors;
  address[] public whitelist;
  mapping(address => uint256) private contributorIndex;
  mapping(address => uint256) private whitelistIndex;
  mapping(address => uint256) public totalClaimToken;
  mapping(address => uint256) public bought; // account => boughtAmount
  mapping(address => bool) public isAdmin;

  string[8] private projectDetails;

  uint256 public constant FEE_DENOMINATOR = 10**9; // fee denominator
  uint256 public startDateClaim; // Timestamp

  PresaleInfo private presale;
  PresaleFeeInfo private feeInfo;

  function initialize(
    string[8] memory _projectDetails,
    PresaleInfo memory _presale,
    PresaleFeeInfo memory _feeInfo,
    address _serviceFeeReceiver,
    address _owner
  ) external {
    require(presale.startPresaleTime == 0, "Presale is Initialized.");
    projectDetails = _projectDetails;
    presale = _presale;
    feeInfo = _feeInfo;
    serviceFeeReceiver = _serviceFeeReceiver;
    _transferOwnership(_owner);

    presale.totalBought = 0;
    presale.isApproved = false;
    presale.isPresaleCancelled = false;
    presale.isClaimPhase = false;
    presale.isWithdrawCancelledTokens = false;

    isAdmin[msg.sender] = true;
    defaultAdmin = msg.sender;
  }

  modifier canBuy() {
    require(presale.isApproved, "Presale not Approved");
    require(block.timestamp >= presale.startPresaleTime, "Presale Not started Yet");
    require(block.timestamp < presale.endPresaleTime, "Presale Ended");

    require(!presale.isClaimPhase, "Claim Phase has started");
    require(
      !presale.isWhiteListPhase || (whitelist.length > 0 && whitelist[whitelistIndex[msg.sender]] == msg.sender),
      "Address not Whitelisted"
    );
    _;
  }

  modifier onlyAdmin() {
    require(isAdmin[msg.sender] || defaultAdmin == msg.sender, "Only admin or defaultAdmin can call this function");
    _;
  }

  modifier onlyDefaultAdmin() {
    require(defaultAdmin == msg.sender, "Only defaultAdmin can call this function");
    _;
  }

  // getters

  function getProjectsDetails() external view returns (string[8] memory) {
    return projectDetails;
  }

  function getFeeInfo() external view returns (PresaleFeeInfo memory) {
    return feeInfo;
  }

  function getPresaleInfo() external view returns (PresaleInfo memory) {
    return presale;
  }

  function getContributors() external view returns (address[] memory) {
    return contributors;
  }

  function getWhitelist() external view returns (address[] memory) {
    return whitelist;
  }

  function isPresaleCancelled() external view returns (bool) {
    return presale.isPresaleCancelled;
  }

  function calculateBnbToPresaleToken(uint256 _amount, uint256 _price) public view returns (uint256) {
    require(presale.presaleToken != address(0), "Presale token not set");

    uint256 pTDecimals = feeInfo.paymentToken == address(0) ? 18 : uint256(IERC20(feeInfo.paymentToken).decimals());

    uint256 tokens = ((_amount * _price) / 10**pTDecimals);

    return tokens * 10**((IERC20(presale.presaleToken).decimals()) - 18);
  }

  function getAvailableTokenToClaim(address _address) public view returns (uint256) {
    uint256 totalToken = calculateBnbToPresaleToken(bought[_address], presale.presalePrice);
    return ((totalToken * getTotalClaimPercentage()) / FEE_DENOMINATOR) - totalClaimToken[_address];
  }

  function getTotalClaimPercentage() private view returns (uint256) {
    uint256 currentClaimDate = block.timestamp;

    if (startDateClaim == 0 || startDateClaim > currentClaimDate) return 0;

    if (!presale.isVestingEnabled) {
      return FEE_DENOMINATOR;
    }

    (, , uint256 startClaimDay, , , ) = BokkyPooBahsDateTimeLibrary.timestampToDateTime(startDateClaim);
    (, , uint256 day, uint256 hour, , ) = BokkyPooBahsDateTimeLibrary.timestampToDateTime(currentClaimDate);
    uint256 interval = BokkyPooBahsDateTimeLibrary.diffMonths(startDateClaim, currentClaimDate);
    if (presale.claimIntervalDay > startClaimDay) {
      interval += 1;
    }
    if (day > presale.claimIntervalDay || (day == presale.claimIntervalDay && hour >= presale.claimIntervalHour)) {
      interval += 1;
    }
    uint256 totalIntervalPercentage = interval * presale.maxClaimPercentage > FEE_DENOMINATOR
      ? FEE_DENOMINATOR
      : interval * presale.maxClaimPercentage;
    return totalIntervalPercentage;
  }

  function addContributor(address _address) private {
    if (contributors.length == 0 || !(contributors[contributorIndex[_address]] == _address)) {
      contributorIndex[_address] = contributors.length;
      contributors.push(_address);
    }
  }

  function buy() external payable canBuy nonReentrant {
    require(feeInfo.paymentToken == address(0), "Payment token is not native coin");
    require(bought[msg.sender] + msg.value <= presale.hardCap, "Cannot buy more than HardCap amount");
    require(msg.value >= presale.minBuy, "Cannot buy less than minBuy");
    require(msg.value + bought[msg.sender] <= presale.maxBuy, "Cannot buy more than maxBuy");
    presale.totalBought += msg.value;
    bought[msg.sender] += msg.value;

    addContributor(msg.sender);
  }

  function buyCustomCurrency(uint256 contributionAmount) external canBuy nonReentrant {
    require(feeInfo.paymentToken != address(0), "Payment token is native coin");
    require(bought[msg.sender] + contributionAmount <= presale.hardCap, "Cannot buy more than HardCap amount");
    require(contributionAmount >= presale.minBuy, "contributionAmount is less than minBuy");
    require(contributionAmount + bought[msg.sender] <= presale.maxBuy, "contributionAmount is more than maxBuy");
    require(
      IERC20(feeInfo.paymentToken).allowance(msg.sender, address(this)) >= contributionAmount,
      "Increase allowance to contribute"
    );
    IERC20(feeInfo.paymentToken).transferFrom(msg.sender, address(this), contributionAmount);
    presale.totalBought += contributionAmount;
    bought[msg.sender] += contributionAmount;

    addContributor(msg.sender);
  }

  function claim(uint256 requestedAmount) external nonReentrant {
    require(!presale.isPresaleCancelled, "Presale Cancelled");
    require(
      block.timestamp > presale.endPresaleTime || presale.hardCap == presale.totalBought,
      "Claim hasn't started yet"
    );
    require(presale.isClaimPhase, "Not Claim Phase");
    require(bought[msg.sender] > 0, "You do not have any tokens to claim");

    uint256 remainingToken = calculateBnbToPresaleToken(bought[msg.sender], presale.presalePrice) -
      totalClaimToken[msg.sender];
    require(remainingToken >= requestedAmount, "User don't have enough token to claim");

    require(
      IERC20(presale.presaleToken).balanceOf(address(this)) >= requestedAmount,
      "Contract doesn't have enough presale tokens. Please contact owner to add more supply"
    );

    require(
      (requestedAmount <= getAvailableTokenToClaim(msg.sender)),
      "User claim more than max claim amount in this interval"
    );

    totalClaimToken[msg.sender] += requestedAmount;
    IERC20(presale.presaleToken).transfer(msg.sender, requestedAmount);
  }

  function removeContributor(address _address) private {
    uint256 index = contributorIndex[_address];
    if (contributors[index] == _address) {
      contributorIndex[contributors[index]] = 0;
      contributors[index] = contributors[contributors.length - 1];
      contributorIndex[contributors[index]] = index == (contributors.length - 1) ? 0 : index;
      contributors.pop();
    }
  }

  receive() external payable {}

  function addLiquidity(uint256 _amountToken, uint256 _amountRaised) internal {
    uint256 listingSS = 100; // listing percentage summitswap
    uint256 listingPS = 100; // listing percentage pancake
    if (presale.listingChoice == 0) {
      listingPS = 0;
    } else if (presale.listingChoice == 1) {
      listingSS = 0;
    } else if (presale.listingChoice == 2) {
      listingSS = 75;
      listingPS = 25;
    } else {
      listingSS = 25;
      listingPS = 75;
    }
    if (listingSS > 0) addLiquiditySS((_amountToken * listingSS) / 100, (_amountRaised * listingSS) / 100);
    if (listingPS > 0) {
      if (feeInfo.paymentToken == address(0)) {
        _addLiquidityETH((_amountToken * listingPS) / 100, (_amountRaised * listingPS) / 100, presale.router1);
      } else {
        _addLiquidityTokens(
          (_amountToken * listingPS) / 100,
          (_amountRaised * listingPS) / 100,
          presale.listingToken,
          presale.router1
        );
      }
    }
  }

  function addLiquiditySS(uint256 amountToken, uint256 amountRaised) private {
    if (feeInfo.paymentToken == address(0)) {
      if (presale.listingToken == address(0)) {
        _addLiquidityETH(amountToken, amountRaised, presale.router0);
      } else {
        swapETHForTokenAndLiquify(amountToken, amountRaised);
      }
    } else {
      if (presale.listingToken == address(0)) {
        swapTokenForETHAndLiquify(amountToken, amountRaised);
      } else {
        if (feeInfo.paymentToken == presale.listingToken) {
          _addLiquidityTokens(amountToken, amountRaised, presale.listingToken, presale.router0);
        } else {
          swapTokenForTokenAndLiquify(amountToken, amountRaised);
        }
      }
    }
  }

  function swapETHForTokenAndLiquify(uint256 amountToken, uint256 amountRaised) private {
    address[] memory path = new address[](2);
    path[0] = ISummitswapRouter02(presale.router0).WETH();
    path[1] = presale.listingToken;

    ISummitswapRouter02(presale.router0).swapExactETHForTokens{value: amountRaised}(
      0,
      path,
      address(this),
      block.timestamp
    );
    _addLiquidityTokens(
      amountToken,
      IERC20(presale.listingToken).balanceOf(address(this)),
      presale.listingToken,
      presale.router0
    );
  }

  function swapTokenForETHAndLiquify(uint256 amountToken, uint256 amountRaised) private {
    address[] memory path = new address[](2);
    path[0] = feeInfo.paymentToken;
    path[1] = ISummitswapRouter02(presale.router0).WETH();

    IERC20(feeInfo.paymentToken).approve(presale.router0, amountRaised);
    uint256[] memory amounts = ISummitswapRouter02(presale.router0).swapExactTokensForETH(
      amountRaised,
      0,
      path,
      address(this),
      block.timestamp
    );
    _addLiquidityETH(amountToken, amounts[1], presale.router0);
  }

  function swapTokenForTokenAndLiquify(uint256 amountToken, uint256 amountRaised) private {
    address[] memory path = new address[](3);
    path[0] = feeInfo.paymentToken;
    path[1] = ISummitswapRouter02(presale.router0).WETH();
    path[2] = presale.listingToken;

    IERC20(feeInfo.paymentToken).approve(presale.router0, amountRaised);
    ISummitswapRouter02(presale.router0).swapExactTokensForTokens(
      amountRaised,
      0,
      path,
      address(this),
      block.timestamp
    );
    _addLiquidityTokens(
      amountToken,
      IERC20(presale.listingToken).balanceOf(address(this)),
      presale.listingToken,
      presale.router0
    );
  }

  function _addLiquidityETH(
    uint256 amountToken,
    uint256 amountBNB,
    address router
  ) private {
    IERC20(presale.presaleToken).approve(router, amountToken);
    ISummitswapRouter02(router).addLiquidityETH{value: amountBNB}(
      presale.presaleToken,
      amountToken,
      0,
      0,
      address(this),
      block.timestamp
    );
  }

  function _addLiquidityTokens(
    uint256 amountToken,
    uint256 amountRaised,
    address listingToken,
    address router
  ) private {
    IERC20(presale.presaleToken).approve(router, amountToken);
    IERC20(listingToken).approve(router, amountRaised);
    ISummitswapRouter02(router).addLiquidity(
      presale.presaleToken,
      listingToken,
      amountToken,
      amountRaised,
      0,
      0,
      address(this),
      block.timestamp
    );
  }

  function withdrawPaymentToken() external nonReentrant {
    require(presale.isPresaleCancelled, "Presale Not Cancelled");
    require(bought[msg.sender] > 0, "You do not have any contributions");

    if (feeInfo.paymentToken == address(0)) {
      payable(msg.sender).transfer(bought[msg.sender]);
    } else {
      IERC20(feeInfo.paymentToken).transfer(msg.sender, bought[msg.sender]);
    }

    presale.totalBought = presale.totalBought - bought[msg.sender];
    bought[msg.sender] = 0;
    removeContributor(msg.sender);
  }

  function emergencyWithdrawPaymentToken() external nonReentrant {
    require(block.timestamp >= presale.startPresaleTime, "Presale Not started Yet");
    require(block.timestamp < presale.endPresaleTime, "Presale Ended");
    require(bought[msg.sender] > 0, "You do not have any contributions");
    require(!presale.isPresaleCancelled, "Presale has been cancelled");
    require(!presale.isClaimPhase, "Presale claim phase");

    uint256 feeAmount = (bought[msg.sender] * feeInfo.feeEmergencyWithdraw) / FEE_DENOMINATOR;

    if (feeInfo.paymentToken == address(0)) {
      payable(msg.sender).transfer(bought[msg.sender] - feeAmount);
      payable(serviceFeeReceiver).transfer(feeAmount);
    } else {
      IERC20(feeInfo.paymentToken).transfer(msg.sender, bought[msg.sender] - feeAmount);
      IERC20(feeInfo.paymentToken).transfer(serviceFeeReceiver, feeAmount);
    }
    presale.totalBought = presale.totalBought - bought[msg.sender];
    bought[msg.sender] = 0;
    removeContributor(msg.sender);
  }

  //////////////////
  // Owner functions

  function addWhiteList(address[] memory addresses) external onlyOwner {
    for (uint256 index = 0; index < addresses.length; index++) {
      if (whitelist.length == 0 || (whitelistIndex[addresses[index]] == 0 && addresses[index] != whitelist[0])) {
        whitelistIndex[addresses[index]] = whitelist.length;
        whitelist.push(addresses[index]);
      }
    }
  }

  function removeWhiteList(address[] memory addresses) external onlyOwner {
    for (uint256 index = 0; index < addresses.length; index++) {
      uint256 _whitelistIndex = whitelistIndex[addresses[index]];
      if (whitelist.length > 0 && whitelist[_whitelistIndex] == addresses[index]) {
        whitelistIndex[whitelist[_whitelistIndex]] = 0;
        whitelist[_whitelistIndex] = whitelist[whitelist.length - 1];
        whitelistIndex[whitelist[_whitelistIndex]] = _whitelistIndex == (whitelist.length - 1) ? 0 : _whitelistIndex;
        whitelist.pop();
      }
    }
  }

  function finalize() external payable onlyOwner nonReentrant {
    require(block.timestamp > presale.endPresaleTime || presale.hardCap == presale.totalBought, "Presale Not Ended");
    require(presale.totalBought >= presale.softCap, "Total bought is less than softCap. Presale failed");

    uint256 feePaymentToken = (presale.totalBought * feeInfo.feePaymentToken) / FEE_DENOMINATOR;
    uint256 feePresaleToken = calculateBnbToPresaleToken(
      (presale.totalBought * feeInfo.feePresaleToken) / FEE_DENOMINATOR,
      presale.presalePrice
    );

    uint256 raisedTokenAmount = calculateBnbToPresaleToken(presale.totalBought, presale.presalePrice);
    uint256 liquidityTokens = (
      calculateBnbToPresaleToken(
        (presale.totalBought * presale.liquidityPercentage) / FEE_DENOMINATOR,
        presale.listingPrice
      )
    ) - feePresaleToken;

    uint256 contractBal = IERC20(presale.presaleToken).balanceOf(address(this));
    require(
      contractBal >= (raisedTokenAmount + feePresaleToken + liquidityTokens),
      "Contract does not have enough Tokens"
    );
    uint256 remainingTokenAmount = contractBal - liquidityTokens - raisedTokenAmount - feePresaleToken;
    presale.isClaimPhase = true;
    startDateClaim = block.timestamp;

    addLiquidity(
      liquidityTokens,
      ((presale.totalBought * presale.liquidityPercentage) / FEE_DENOMINATOR) - feePaymentToken
    );

    if (feeInfo.paymentToken == address(0)) {
      payable(serviceFeeReceiver).transfer(feePaymentToken);
    } else {
      IERC20(feeInfo.paymentToken).transfer(serviceFeeReceiver, feePaymentToken);
    }

    if (feePresaleToken > 0) {
      IERC20(presale.presaleToken).transfer(serviceFeeReceiver, feePresaleToken);
    }

    if (remainingTokenAmount > 0) {
      if (presale.refundType == 0) {
        IERC20(presale.presaleToken).transfer(msg.sender, remainingTokenAmount);
      } else {
        IERC20(presale.presaleToken).transfer(BURN_ADDRESS, remainingTokenAmount);
      }
    }
  }

  function withdrawCancelledTokens() external onlyOwner {
    require(!presale.isWithdrawCancelledTokens, "Cancelled Tokens Already Withdrawn");
    require(presale.isPresaleCancelled, "Presale Not Cancelled");
    require(IERC20(presale.presaleToken).balanceOf(address(this)) > 0, "You do not have Any Tokens to Withdraw");
    uint256 tokenAmount = IERC20(presale.presaleToken).balanceOf(address(this));
    presale.isWithdrawCancelledTokens = true;
    IERC20(presale.presaleToken).transfer(msg.sender, tokenAmount);
  }

  function withdrawLpTokens(address[2] memory addresses, address _receiver) external onlyOwner {
    require(startDateClaim != 0, "Claim phase has not started");
    require(startDateClaim + presale.liquidityLockTime < block.timestamp, "Lp Tokens are locked");
    require(addresses[0] != presale.presaleToken && addresses[1] != presale.presaleToken, "address is presale token");
    if (addresses[0] != address(0)) {
      require(feeInfo.paymentToken == address(0) || addresses[0] != feeInfo.paymentToken, "address0 is paymentToken");
      uint256 lpBal0 = IERC20(addresses[0]).balanceOf(address(this));
      if (lpBal0 > 0) IERC20(addresses[0]).transfer(_receiver, lpBal0);
    }
    if (addresses[1] != address(0)) {
      require(feeInfo.paymentToken == address(0) || addresses[1] != feeInfo.paymentToken, "address1 is paymentToken");
      uint256 lpBal1 = IERC20(addresses[1]).balanceOf(address(this));
      if (lpBal1 > 0) IERC20(addresses[1]).transfer(_receiver, lpBal1);
    }
  }

  function toggleWhitelistPhase() external onlyOwner {
    presale.isWhiteListPhase = !presale.isWhiteListPhase;
  }

  function cancelPresale() external onlyOwner {
    presale.isClaimPhase = false;
    presale.isPresaleCancelled = true;
  }

  function withdrawBNBOwner(uint256 _amount, address _receiver) external onlyOwner {
    require(presale.isClaimPhase, "Claim phase has not started");
    payable(_receiver).transfer(_amount);
  }

  function withdrawPaymentTokenOwner(uint256 _amount, address _receiver) external onlyOwner {
    require(presale.isClaimPhase, "Claim phase has not started");
    IERC20(feeInfo.paymentToken).transfer(_receiver, _amount);
  }

  function updatePresaleAndApprove(
    PresaleInfo memory _presale,
    PresaleFeeInfo memory _feeInfo,
    string[8] memory _projectDetails
  ) external onlyAdmin {
    require(!presale.isApproved, "Presale is approved");
    presale = _presale;
    feeInfo = _feeInfo;
    projectDetails = _projectDetails;
    presale.isApproved = true;
    presale.isPresaleCancelled = false;
    presale.isClaimPhase = false;
    presale.isWithdrawCancelledTokens = false;
  }

  function approvePresale() external onlyAdmin {
    presale.isApproved = true;
  }

  function setServiceFeeReceiver(address _feeReceiver) external onlyAdmin {
    serviceFeeReceiver = _feeReceiver;
  }

  function assignAdmins(address[] calldata _admins) external onlyDefaultAdmin {
    for (uint256 i = 0; i < _admins.length; i++) {
      isAdmin[_admins[i]] = true;
    }
  }

  function revokeAdmins(address[] calldata _admins) external onlyDefaultAdmin {
    for (uint256 i = 0; i < _admins.length; i++) {
      isAdmin[_admins[i]] = false;
    }
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.6;

// ----------------------------------------------------------------------------
// BokkyPooBah's DateTime Library v1.00
//
// A gas-efficient Solidity date and time library
//
// https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
//
// Tested date range 1970/01/01 to 2345/12/31
//
// Conventions:
// Unit      | Range         | Notes
// :-------- |:-------------:|:-----
// timestamp | >= 0          | Unix timestamp, number of seconds since 1970/01/01 00:00:00 UTC
// year      | 1970 ... 2345 |
// month     | 1 ... 12      |
// day       | 1 ... 31      |
// hour      | 0 ... 23      |
// minute    | 0 ... 59      |
// second    | 0 ... 59      |
// dayOfWeek | 1 ... 7       | 1 = Monday, ..., 7 = Sunday
//
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018.
//
// GNU Lesser General Public License 3.0
// https://www.gnu.org/licenses/lgpl-3.0.en.html
// ----------------------------------------------------------------------------

library BokkyPooBahsDateTimeLibrary {
  uint256 constant SECONDS_PER_DAY = 24 * 60 * 60;
  uint256 constant SECONDS_PER_HOUR = 60 * 60;
  uint256 constant SECONDS_PER_MINUTE = 60;
  int256 constant OFFSET19700101 = 2440588;

  uint256 constant DOW_MON = 1;
  uint256 constant DOW_TUE = 2;
  uint256 constant DOW_WED = 3;
  uint256 constant DOW_THU = 4;
  uint256 constant DOW_FRI = 5;
  uint256 constant DOW_SAT = 6;
  uint256 constant DOW_SUN = 7;

  // ------------------------------------------------------------------------
  // Calculate the number of days from 1970/01/01 to year/month/day using
  // the date conversion algorithm from
  //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
  // and subtracting the offset 2440588 so that 1970/01/01 is day 0
  //
  // days = day
  //      - 32075
  //      + 1461 * (year + 4800 + (month - 14) / 12) / 4
  //      + 367 * (month - 2 - (month - 14) / 12 * 12) / 12
  //      - 3 * ((year + 4900 + (month - 14) / 12) / 100) / 4
  //      - offset
  // ------------------------------------------------------------------------
  function _daysFromDate(
    uint256 year,
    uint256 month,
    uint256 day
  ) internal pure returns (uint256 _days) {
    require(year >= 1970);
    int256 _year = int256(year);
    int256 _month = int256(month);
    int256 _day = int256(day);

    int256 __days = _day -
      32075 +
      (1461 * (_year + 4800 + (_month - 14) / 12)) /
      4 +
      (367 * (_month - 2 - ((_month - 14) / 12) * 12)) /
      12 -
      (3 * ((_year + 4900 + (_month - 14) / 12) / 100)) /
      4 -
      OFFSET19700101;

    _days = uint256(__days);
  }

  // ------------------------------------------------------------------------
  // Calculate year/month/day from the number of days since 1970/01/01 using
  // the date conversion algorithm from
  //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
  // and adding the offset 2440588 so that 1970/01/01 is day 0
  //
  // int L = days + 68569 + offset
  // int N = 4 * L / 146097
  // L = L - (146097 * N + 3) / 4
  // year = 4000 * (L + 1) / 1461001
  // L = L - 1461 * year / 4 + 31
  // month = 80 * L / 2447
  // dd = L - 2447 * month / 80
  // L = month / 11
  // month = month + 2 - 12 * L
  // year = 100 * (N - 49) + year + L
  // ------------------------------------------------------------------------
  function _daysToDate(uint256 _days)
    internal
    pure
    returns (
      uint256 year,
      uint256 month,
      uint256 day
    )
  {
    int256 __days = int256(_days);

    int256 L = __days + 68569 + OFFSET19700101;
    int256 N = (4 * L) / 146097;
    L = L - (146097 * N + 3) / 4;
    int256 _year = (4000 * (L + 1)) / 1461001;
    L = L - (1461 * _year) / 4 + 31;
    int256 _month = (80 * L) / 2447;
    int256 _day = L - (2447 * _month) / 80;
    L = _month / 11;
    _month = _month + 2 - 12 * L;
    _year = 100 * (N - 49) + _year + L;

    year = uint256(_year);
    month = uint256(_month);
    day = uint256(_day);
  }

  function timestampFromDate(
    uint256 year,
    uint256 month,
    uint256 day
  ) internal pure returns (uint256 timestamp) {
    timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY;
  }

  function timestampFromDateTime(
    uint256 year,
    uint256 month,
    uint256 day,
    uint256 hour,
    uint256 minute,
    uint256 second
  ) internal pure returns (uint256 timestamp) {
    timestamp =
      _daysFromDate(year, month, day) *
      SECONDS_PER_DAY +
      hour *
      SECONDS_PER_HOUR +
      minute *
      SECONDS_PER_MINUTE +
      second;
  }

  function timestampToDate(uint256 timestamp)
    internal
    pure
    returns (
      uint256 year,
      uint256 month,
      uint256 day
    )
  {
    (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
  }

  function timestampToDateTime(uint256 timestamp)
    internal
    pure
    returns (
      uint256 year,
      uint256 month,
      uint256 day,
      uint256 hour,
      uint256 minute,
      uint256 second
    )
  {
    (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    uint256 secs = timestamp % SECONDS_PER_DAY;
    hour = secs / SECONDS_PER_HOUR;
    secs = secs % SECONDS_PER_HOUR;
    minute = secs / SECONDS_PER_MINUTE;
    second = secs % SECONDS_PER_MINUTE;
  }

  function isValidDate(
    uint256 year,
    uint256 month,
    uint256 day
  ) internal pure returns (bool valid) {
    if (year >= 1970 && month > 0 && month <= 12) {
      uint256 daysInMonth = _getDaysInMonth(year, month);
      if (day > 0 && day <= daysInMonth) {
        valid = true;
      }
    }
  }

  function isValidDateTime(
    uint256 year,
    uint256 month,
    uint256 day,
    uint256 hour,
    uint256 minute,
    uint256 second
  ) internal pure returns (bool valid) {
    if (isValidDate(year, month, day)) {
      if (hour < 24 && minute < 60 && second < 60) {
        valid = true;
      }
    }
  }

  function isLeapYear(uint256 timestamp) internal pure returns (bool leapYear) {
    (uint256 year, , ) = _daysToDate(timestamp / SECONDS_PER_DAY);
    leapYear = _isLeapYear(year);
  }

  function _isLeapYear(uint256 year) internal pure returns (bool leapYear) {
    leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
  }

  function isWeekDay(uint256 timestamp) internal pure returns (bool weekDay) {
    weekDay = getDayOfWeek(timestamp) <= DOW_FRI;
  }

  function isWeekEnd(uint256 timestamp) internal pure returns (bool weekEnd) {
    weekEnd = getDayOfWeek(timestamp) >= DOW_SAT;
  }

  function getDaysInMonth(uint256 timestamp) internal pure returns (uint256 daysInMonth) {
    (uint256 year, uint256 month, ) = _daysToDate(timestamp / SECONDS_PER_DAY);
    daysInMonth = _getDaysInMonth(year, month);
  }

  function _getDaysInMonth(uint256 year, uint256 month) internal pure returns (uint256 daysInMonth) {
    if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
      daysInMonth = 31;
    } else if (month != 2) {
      daysInMonth = 30;
    } else {
      daysInMonth = _isLeapYear(year) ? 29 : 28;
    }
  }

  // 1 = Monday, 7 = Sunday
  function getDayOfWeek(uint256 timestamp) internal pure returns (uint256 dayOfWeek) {
    uint256 _days = timestamp / SECONDS_PER_DAY;
    dayOfWeek = ((_days + 3) % 7) + 1;
  }

  function getYear(uint256 timestamp) internal pure returns (uint256 year) {
    (year, , ) = _daysToDate(timestamp / SECONDS_PER_DAY);
  }

  function getMonth(uint256 timestamp) internal pure returns (uint256 month) {
    (, month, ) = _daysToDate(timestamp / SECONDS_PER_DAY);
  }

  function getDay(uint256 timestamp) internal pure returns (uint256 day) {
    (, , day) = _daysToDate(timestamp / SECONDS_PER_DAY);
  }

  function getHour(uint256 timestamp) internal pure returns (uint256 hour) {
    uint256 secs = timestamp % SECONDS_PER_DAY;
    hour = secs / SECONDS_PER_HOUR;
  }

  function getMinute(uint256 timestamp) internal pure returns (uint256 minute) {
    uint256 secs = timestamp % SECONDS_PER_HOUR;
    minute = secs / SECONDS_PER_MINUTE;
  }

  function getSecond(uint256 timestamp) internal pure returns (uint256 second) {
    second = timestamp % SECONDS_PER_MINUTE;
  }

  function addYears(uint256 timestamp, uint256 _years) internal pure returns (uint256 newTimestamp) {
    (uint256 year, uint256 month, uint256 day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    year += _years;
    uint256 daysInMonth = _getDaysInMonth(year, month);
    if (day > daysInMonth) {
      day = daysInMonth;
    }
    newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + (timestamp % SECONDS_PER_DAY);
    require(newTimestamp >= timestamp);
  }

  function addMonths(uint256 timestamp, uint256 _months) internal pure returns (uint256 newTimestamp) {
    (uint256 year, uint256 month, uint256 day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    month += _months;
    year += (month - 1) / 12;
    month = ((month - 1) % 12) + 1;
    uint256 daysInMonth = _getDaysInMonth(year, month);
    if (day > daysInMonth) {
      day = daysInMonth;
    }
    newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + (timestamp % SECONDS_PER_DAY);
    require(newTimestamp >= timestamp);
  }

  function addDays(uint256 timestamp, uint256 _days) internal pure returns (uint256 newTimestamp) {
    newTimestamp = timestamp + _days * SECONDS_PER_DAY;
    require(newTimestamp >= timestamp);
  }

  function addHours(uint256 timestamp, uint256 _hours) internal pure returns (uint256 newTimestamp) {
    newTimestamp = timestamp + _hours * SECONDS_PER_HOUR;
    require(newTimestamp >= timestamp);
  }

  function addMinutes(uint256 timestamp, uint256 _minutes) internal pure returns (uint256 newTimestamp) {
    newTimestamp = timestamp + _minutes * SECONDS_PER_MINUTE;
    require(newTimestamp >= timestamp);
  }

  function addSeconds(uint256 timestamp, uint256 _seconds) internal pure returns (uint256 newTimestamp) {
    newTimestamp = timestamp + _seconds;
    require(newTimestamp >= timestamp);
  }

  function subYears(uint256 timestamp, uint256 _years) internal pure returns (uint256 newTimestamp) {
    (uint256 year, uint256 month, uint256 day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    year -= _years;
    uint256 daysInMonth = _getDaysInMonth(year, month);
    if (day > daysInMonth) {
      day = daysInMonth;
    }
    newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + (timestamp % SECONDS_PER_DAY);
    require(newTimestamp <= timestamp);
  }

  function subMonths(uint256 timestamp, uint256 _months) internal pure returns (uint256 newTimestamp) {
    (uint256 year, uint256 month, uint256 day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    uint256 yearMonth = year * 12 + (month - 1) - _months;
    year = yearMonth / 12;
    month = (yearMonth % 12) + 1;
    uint256 daysInMonth = _getDaysInMonth(year, month);
    if (day > daysInMonth) {
      day = daysInMonth;
    }
    newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + (timestamp % SECONDS_PER_DAY);
    require(newTimestamp <= timestamp);
  }

  function subDays(uint256 timestamp, uint256 _days) internal pure returns (uint256 newTimestamp) {
    newTimestamp = timestamp - _days * SECONDS_PER_DAY;
    require(newTimestamp <= timestamp);
  }

  function subHours(uint256 timestamp, uint256 _hours) internal pure returns (uint256 newTimestamp) {
    newTimestamp = timestamp - _hours * SECONDS_PER_HOUR;
    require(newTimestamp <= timestamp);
  }

  function subMinutes(uint256 timestamp, uint256 _minutes) internal pure returns (uint256 newTimestamp) {
    newTimestamp = timestamp - _minutes * SECONDS_PER_MINUTE;
    require(newTimestamp <= timestamp);
  }

  function subSeconds(uint256 timestamp, uint256 _seconds) internal pure returns (uint256 newTimestamp) {
    newTimestamp = timestamp - _seconds;
    require(newTimestamp <= timestamp);
  }

  function diffYears(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _years) {
    require(fromTimestamp <= toTimestamp);
    (uint256 fromYear, , ) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
    (uint256 toYear, , ) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
    _years = toYear - fromYear;
  }

  function diffMonths(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _months) {
    require(fromTimestamp <= toTimestamp);
    (uint256 fromYear, uint256 fromMonth, ) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
    (uint256 toYear, uint256 toMonth, ) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
    _months = toYear * 12 + toMonth - fromYear * 12 - fromMonth;
  }

  function diffDays(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _days) {
    require(fromTimestamp <= toTimestamp);
    _days = (toTimestamp - fromTimestamp) / SECONDS_PER_DAY;
  }

  function diffHours(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _hours) {
    require(fromTimestamp <= toTimestamp);
    _hours = (toTimestamp - fromTimestamp) / SECONDS_PER_HOUR;
  }

  function diffMinutes(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _minutes) {
    require(fromTimestamp <= toTimestamp);
    _minutes = (toTimestamp - fromTimestamp) / SECONDS_PER_MINUTE;
  }

  function diffSeconds(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _seconds) {
    require(fromTimestamp <= toTimestamp);
    _seconds = toTimestamp - fromTimestamp;
  }
}

pragma solidity >=0.6.2;

import "./ISummitswapRouter01.sol";

interface ISummitswapRouter02 is ISummitswapRouter01 {
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

  // Supporting Fee cause We are sending fee
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

pragma solidity >=0.5.0;

interface IERC20 {
  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint8);

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

pragma solidity 0.8.6;

struct PresaleInfo {
  address presaleToken;
  address router0; // router SummitSwap
  address router1; // router pancakeSwap
  address listingToken; // address(0) is native Token
  uint256 presalePrice; // in wei
  uint256 listingPrice; // in wei
  uint256 liquidityLockTime; // in seconds
  uint256 minBuy; // in wei
  uint256 maxBuy; // in wei
  uint256 softCap; // in wei
  uint256 hardCap; // in wei
  uint256 liquidityPercentage;
  uint256 startPresaleTime;
  uint256 endPresaleTime;
  uint256 claimIntervalDay;
  uint256 claimIntervalHour;
  uint256 totalBought; // in wei
  uint256 maxClaimPercentage;
  uint8 refundType; // 0 refund, 1 burn
  uint8 listingChoice; // 0 100% SS, 1 100% PS, 2 (75% SS & 25% PS), 3 (75% PK & 25% SS)
  bool isWhiteListPhase;
  bool isClaimPhase;
  bool isPresaleCancelled;
  bool isWithdrawCancelledTokens;
  bool isVestingEnabled;
  bool isApproved;
}

pragma solidity 0.8.6;

struct PresaleFeeInfo {
  address paymentToken; // BNB/BUSD/ | address(0) native coin
  uint256 feePaymentToken; // BNB/BUSD/...
  uint256 feePresaleToken; // presaleToken
  uint256 feeEmergencyWithdraw;
}

pragma solidity >=0.6.6 <=0.8.6;

abstract contract Ownable {
  address private _owner;

  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  function isOwner(address account) public view returns (bool) {
    return account == _owner;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  modifier onlyOwner() {
    require(isOwner(msg.sender), "Ownable: caller is not the owner");
    _;
  }

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}

pragma solidity >=0.6.2;

interface ISummitswapRouter01 {
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