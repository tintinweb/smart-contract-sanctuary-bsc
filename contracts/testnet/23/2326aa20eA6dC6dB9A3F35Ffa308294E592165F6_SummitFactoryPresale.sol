// SPDX-License-Identifier: UNLICENSED
// Developed by: dxsoftware.net

pragma solidity 0.7.6;

import "./SummitCustomPresale.sol";
import "./interfaces/ISummitCustomPresale.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SummitFactoryPresale is Ownable {
  mapping(address => address[]) public accountPresales;
  mapping(address => address[]) public tokenPresales; // token => presale

  address[] public presaleAddresses;
  address public serviceFeeReceiver;
  uint256 public preSaleFee = 0.001 ether;

  constructor(uint256 _preSaleFee, address _feeReceiver) {
    preSaleFee = _preSaleFee;
    serviceFeeReceiver = _feeReceiver;
  }

  function createPresale(
    address[2] memory _addresses, // tokenAdress, routerAddress
    uint256[4] memory _tokenDetails, // _tokenAmount, _presalePrice, _listingPrice, liquidityPercent
    uint256[4] memory _bnbAmounts, // minBuyBnb, maxBuyBnb, softcap, hardcap
    uint256 _liquidityLockTime,
    uint256 _startPresaleTime,
    uint256 _endPresaleTime,
    uint8 _feeType, // 0 or 1
    uint8 _refundType, // 0 refund, 1 burn
    bool _isWhiteListPhase
  ) external payable {
    require(msg.value >= preSaleFee, "Not Enough Fee");
    require(_startPresaleTime > block.timestamp, "Presale start time should be greater than block.timestamp");
    require(_endPresaleTime > _startPresaleTime, "Presale End time should be greater than presale start time");
    require(_bnbAmounts[0] <= _bnbAmounts[1], "MinBuybnb should be less than maxBuybnb");
    require(_bnbAmounts[2] >= (_bnbAmounts[3] * 50) / 100, "Softcap should be greater than or equal to 50% of hardcap");
    require(_tokenDetails[3] >= 51, "Liquidity Percentage should be Greater than or equal to 51%");

    if (tokenPresales[_addresses[0]].length > 0) {
      ISummitCustomPresale _presale = ISummitCustomPresale(
        tokenPresales[_addresses[0]][tokenPresales[_addresses[0]].length - 1]
      );
      require(_presale.isPresaleCancelled(), "Presale Already Exists");
    }

    SummitCustomPresale presale = new SummitCustomPresale(
      [msg.sender, _addresses[0], _addresses[1], serviceFeeReceiver],
      [_tokenDetails[1], _tokenDetails[2], _tokenDetails[3]],
      _bnbAmounts,
      _liquidityLockTime,
      _startPresaleTime,
      _endPresaleTime,
      _feeType,
      _refundType,
      _isWhiteListPhase
    );
    tokenPresales[_addresses[0]].push(address(presale));
    accountPresales[msg.sender].push(address(presale));
    presaleAddresses.push(address(presale));
    if (serviceFeeReceiver != address(this)) {
      address payable feeReceiver = payable(serviceFeeReceiver);
      feeReceiver.transfer(preSaleFee);
    }

    IERC20(_addresses[0]).transferFrom(msg.sender, address(presale), _tokenDetails[0]);
  }

  function getPresaleAddresses() external view returns (address[] memory) {
    return presaleAddresses;
  }

  function getTokenPresales(address _address) external view returns (address[] memory) {
    return tokenPresales[_address];
  }

  function getAccountPresales(address _address) external view returns (address[] memory) {
    return accountPresales[_address];
  }

  function setServiceFeeReceiver(address _feeReceiver) external onlyOwner {
    serviceFeeReceiver = _feeReceiver;
  }

  function withdraw(address _feeReceiver) public onlyOwner {
    address payable to = payable(_feeReceiver);
    to.transfer(address(this).balance);
  }

  function setFee(uint256 _fee) external onlyOwner {
    preSaleFee = _fee;
  }
}

// SPDX-License-Identifier: UNLICENSED
// Developed by: dxsoftware.net

pragma solidity 0.7.6;

pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./interfaces/ISummitswapRouter02.sol";
import "./interfaces/IERC20.sol";

contract SummitCustomPresale is Ownable, ReentrancyGuard {
  address private constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

  address public serviceFeeReceiver;
  address[] public contributors;
  address[] public whitelist;
  mapping(address => uint256) private contributorIndex;
  mapping(address => uint256) private whitelistIndex;
  mapping(address => uint256) public bought; // account => boughtAmount
  mapping(address => bool) public isTokenClaimed; // if account has claimed the tokens

  uint256 public constant FEE_DENOMINATOR = 10**9; // fee denominator
  uint256 public bnbFeeType0 = 50000000; // 5%
  uint256 public bnbFeeType1 = 20000000; //2 %
  uint256 public tokenFeeType1 = 20000000; // 2%
  uint256 public emergencyWithdrawFee = 100000000; // 10%
  uint256 public liquidity;

  struct PresaleInfo {
    address presaleToken;
    address router;
    uint256 presalePrice; // in wei
    uint256 listingPrice; // in wei
    uint256 liquidityLockTime; // in seconds
    uint256 minBuyBnb; // in wei
    uint256 maxBuyBnb; // in wei
    uint256 softCap; // in wei
    uint256 hardCap; // in wei
    uint256 liquidityPercentage;
    uint256 startPresaleTime;
    uint256 endPresaleTime;
    uint256 totalBought; // in wei
    uint8 feeType; // 0 == 5% raised Bnb || 1 == 2% raised Bnb and 2% raised tokens
    uint8 refundType; // 0 refund, 1 burn
    bool isWhiteListPhase;
    bool isClaimPhase;
    bool isPresaleCancelled;
    bool isWithdrawCancelledTokens;
  }
  PresaleInfo presale;

  constructor(
    address[4] memory _addresses, // owner, token, router, serviceFeeReceiver
    uint256[3] memory _tokenDetails, // _presalePrice, _listingPrice, liquidityPercent
    uint256[4] memory _bnbAmounts, // minBuyBnb, maxBuyBnb, softcap, hardcap
    uint256 _liquidityLockTime,
    uint256 _startPresaleTime,
    uint256 _endPresaleTime,
    uint8 _feeType,
    uint8 _refundType,
    bool _isWhiteListPhase
  ) {
    transferOwnership(_addresses[0]);
    serviceFeeReceiver = _addresses[3];
    presale.presaleToken = _addresses[1];
    presale.router = _addresses[2];
    presale.presalePrice = _tokenDetails[0];
    presale.listingPrice = _tokenDetails[1];
    presale.liquidityPercentage = (_tokenDetails[2] * FEE_DENOMINATOR) / 100;
    presale.liquidityLockTime = _liquidityLockTime;
    presale.minBuyBnb = _bnbAmounts[0];
    presale.maxBuyBnb = _bnbAmounts[1];
    presale.softCap = _bnbAmounts[2];
    presale.hardCap = _bnbAmounts[3];
    presale.startPresaleTime = _startPresaleTime;
    presale.endPresaleTime = _endPresaleTime;
    presale.feeType = _feeType;
    presale.refundType = _refundType;
    presale.isWhiteListPhase = _isWhiteListPhase;
  }

  // getters

  function getInfo() external view returns (PresaleInfo memory) {
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
    uint256 tokens = ((_amount * _price) / 10**18) / (10**(18 - uint256(IERC20(presale.presaleToken).decimals())));
    return tokens;
  }

  function buy() external payable nonReentrant {
    require(block.timestamp >= presale.startPresaleTime, "Presale Not started Yet");
    require(block.timestamp < presale.endPresaleTime, "Presale Ended");

    require(!presale.isClaimPhase, "Claim Phase has started");
    require(
      !presale.isWhiteListPhase || (whitelist.length > 0 && whitelist[whitelistIndex[msg.sender]] == msg.sender),
      "Address not Whitelisted"
    );

    require(bought[msg.sender] + msg.value <= presale.hardCap, "Cannot buy more than HardCap amount");
    require(msg.value >= presale.minBuyBnb, "msg.value is less than minBuyBnb");
    require(msg.value + bought[msg.sender] <= presale.maxBuyBnb, "msg.value is great than maxBuyBnb");
    presale.totalBought += msg.value;
    bought[msg.sender] += msg.value;

    if (contributors.length == 0 || !(contributors[contributorIndex[msg.sender]] == msg.sender)) {
      contributorIndex[msg.sender] = contributors.length;
      contributors.push(msg.sender);
    }
  }

  function claim() external nonReentrant {
    require(!presale.isPresaleCancelled, "Presale Cancelled");
    require(
      block.timestamp > presale.endPresaleTime || presale.hardCap == presale.totalBought,
      "Claim hasn't started yet"
    );
    require(presale.isClaimPhase, "Not Claim Phase");
    require(bought[msg.sender] > 0, "You do not have any tokens to claim");
    require(!isTokenClaimed[msg.sender], "Tokens already Claimed");

    uint256 userTokens = calculateBnbToPresaleToken(bought[msg.sender], presale.presalePrice);
    require(
      IERC20(presale.presaleToken).balanceOf(address(this)) >= userTokens,
      "Contract doesn't have enough presale tokens. Please contact owner to add more supply"
    );
    IERC20(presale.presaleToken).transfer(msg.sender, userTokens);
    isTokenClaimed[msg.sender] = true;
  }

  function removeContributor(address _address) internal {
    uint256 index = contributorIndex[_address];
    if (contributors[index] == _address) {
      contributorIndex[contributors[index]] = 0;
      contributors[index] = contributors[contributors.length - 1];
      contributorIndex[contributors[index]] = index == (contributors.length - 1) ? 0 : index;
      contributors.pop();
    }
  }

  function addLiquidity(uint256 amountToken, uint256 amountBNB) internal {
    IERC20(presale.presaleToken).approve(presale.router, amountToken);
    ISummitswapRouter02 summitswapV2Router = ISummitswapRouter02(presale.router);

    summitswapV2Router.addLiquidityETH{value: amountBNB}(
      presale.presaleToken,
      amountToken,
      0,
      0,
      owner(),
      block.timestamp
    );
  }

  function withdrawBNB() external nonReentrant {
    require(presale.isPresaleCancelled, "Presale Not Cancelled");
    require(bought[msg.sender] > 0, "You do not have any contributions");
    address payable msgSender = payable(msg.sender);
    msgSender.transfer(bought[msg.sender]);
    presale.totalBought = presale.totalBought - bought[msg.sender];
    bought[msg.sender] = 0;
    removeContributor(msg.sender);
  }

  function emergencyWithdrawBNB() external nonReentrant {
    require(block.timestamp >= presale.startPresaleTime, "Presale Not started Yet");
    require(block.timestamp < presale.endPresaleTime, "Presale Ended");
    require(bought[msg.sender] > 0, "You do not have any contributions");
    require(!presale.isPresaleCancelled, "Presale has been cancelled");
    require(!presale.isClaimPhase, "Presale claim phase");
    address payable msgSender = payable(msg.sender);
    uint256 bnbFeeAmount = (bought[msg.sender] * emergencyWithdrawFee) / FEE_DENOMINATOR;
    msgSender.transfer(bought[msg.sender] - bnbFeeAmount);
    payable(serviceFeeReceiver).transfer(bnbFeeAmount);

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

    uint256 feeBnb = presale.feeType == 0
      ? ((presale.totalBought * bnbFeeType0) / FEE_DENOMINATOR)
      : ((presale.totalBought * bnbFeeType1) / FEE_DENOMINATOR);
    uint256 feeToken = presale.feeType == 0 ? 0 : calculateBnbToPresaleToken(feeBnb, presale.presalePrice);
    uint256 raisedTokenAmount = calculateBnbToPresaleToken(presale.totalBought, presale.presalePrice);
    uint256 liquidityTokens = (calculateBnbToPresaleToken(presale.totalBought, presale.listingPrice) *
      presale.liquidityPercentage) / FEE_DENOMINATOR;
    uint256 contractBal = IERC20(presale.presaleToken).balanceOf(address(this));
    require(contractBal >= (raisedTokenAmount + feeToken + liquidityTokens), "Contract does not have enough Tokens");
    uint256 remainingTokenAmount = contractBal - liquidityTokens - raisedTokenAmount - feeToken;
    presale.isClaimPhase = true;

    addLiquidity(liquidityTokens, (presale.totalBought * presale.liquidityPercentage) / FEE_DENOMINATOR);

    payable(serviceFeeReceiver).transfer(feeBnb);
    if (feeToken > 0) {
      IERC20(presale.presaleToken).transfer(serviceFeeReceiver, feeToken);
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

  function toggleWhitelistPhase() external onlyOwner {
    presale.isWhiteListPhase = !presale.isWhiteListPhase;
  }

  function cancelPresale() external onlyOwner {
    presale.isClaimPhase = false;
    presale.isPresaleCancelled = true;
  }

  function setServiceFeeReceiver(address _feeReceiver) external onlyOwner {
    serviceFeeReceiver = _feeReceiver;
  }

  function withdrawBNBOwner(uint256 _amount, address _receiver) external onlyOwner {
    payable(_receiver).transfer(_amount);
  }
}

// SPDX-License-Identifier: UNLICENSED
// Developed by: dxsoftware.net

pragma solidity 0.7.6;

pragma experimental ABIEncoderV2;

interface ISummitCustomPresale {
  struct PresaleInfo {
    address presaleToken;
    address router;
    uint256 presalePrice; // in wei
    uint256 listingPrice; // in wei
    uint256 liquidityLockTime; // in seconds
    uint256 minBuyBnb; // in wei
    uint256 maxBuyBnb; // in wei
    uint256 softCap; // in wei
    uint256 hardCap; // in wei
    uint256 liquidityPercentage;
    uint256 startPresaleTime;
    uint256 endPresaleTime;
    uint256 totalBought; // in wei
    uint8 feeType; // 0 == 5% raised Bnb || 1 == 2% raised Bnb and 2% raised tokens
    uint8 refundType; // 0 refund, 1 burn
    bool isWhiteListPhase;
    bool isClaimPhase;
    bool isPresaleCancelled;
    bool isWithdrawCancelledTokens;
  }

  function getInfo() external view returns (PresaleInfo memory);

  function getContributors() external view returns (address[] memory);

  function getWhitelist() external view returns (address[] memory);

  function isPresaleCancelled() external view returns (bool);

  function calculateBnbToPresaleToken(uint256 _amount, uint256 _price) external view returns (uint256 tokens);

  function buy() external payable;

  function claim() external;

  function withdrawBNB() external;

  function emergencyWithdrawBNB() external;

  function addWhiteList(address[] memory addresses) external;

  function removeWhiteList(address[] memory addresses) external;

  function finalize() external payable;

  function withdrawCancelledTokens() external;

  function toggleWhitelistPhase() external;

  function cancelPresale() external;

  function setServiceFeeReceiver(address _feeReceiver) external;

  function withdrawBNBOwner(uint256 _amount, address _receiver) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
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