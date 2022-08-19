/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol




interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// File: oracle/PriceConsumerV3.sol


pragma solidity ^0.8.7;


contract PriceConsumerV3 {

    AggregatorV3Interface internal priceFeed;

    /**
     * Network: BSC MAINNET
     * Aggregator: BNB/USD
     * Address: 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
     */
    constructor() {
        priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns (uint256) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return uint256(price / 1e8);
    }
}

// File: security/ReentrancyGuard.sol



pragma solidity ^0.8.0;
 
contract ReentrancyGuard { 
  uint256 private constant _NOT_ENTERED = 1;
  uint256 private constant _ENTERED = 2;

  uint256 private _status;

  constructor() {
    _status = _NOT_ENTERED;
  }

  modifier nonReentrant() {
    require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
    _status = _ENTERED;
    _;
    _status = _NOT_ENTERED;
  }
}
// File: utils/Address.sol



pragma solidity ^0.8.1;

library Address {
  function isContract(address account) internal view returns (bool) {
    return account.code.length > 0;
  }

  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, "Address: insufficient balance");

    (bool success, ) = recipient.call{value: amount}("");
    require(success, "Address: unable to send value, recipient may have reverted");
  }

  function functionCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionCall(target, data, "Address: low-level call failed");
  }

  function functionCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {
    return functionCallWithValue(target, data, 0, errorMessage);
  }

  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value
  ) internal returns (bytes memory) {
    return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
  }

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

  function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
    return functionStaticCall(target, data, "Address: low-level static call failed");
  }

  function functionStaticCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal view returns (bytes memory) {
    require(isContract(target), "Address: static call to non-contract");

    (bool success, bytes memory returndata) = target.staticcall(data);
    return verifyCallResult(success, returndata, errorMessage);
  }

  function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionDelegateCall(target, data, "Address: low-level delegate call failed");
  }

  function functionDelegateCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {
    require(isContract(target), "Address: delegate call to non-contract");

    (bool success, bytes memory returndata) = target.delegatecall(data);
    return verifyCallResult(success, returndata, errorMessage);
  }

  function verifyCallResult(
    bool success,
    bytes memory returndata,
    string memory errorMessage
  ) internal pure returns (bytes memory) {
    if (success) {
      return returndata;
    } else {
      if (returndata.length > 0) {
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
// File: utils/math/SafeMath.sol



pragma solidity ^0.8.0;

library SafeMath {
  function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
      uint256 c = a + b;
      if (c < a) return (false, 0);
      return (true, c);
    }
  }

  function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
      if (b > a) return (false, 0);
      return (true, a - b);
    }
  }

  function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
      if (a == 0) return (true, 0);
      uint256 c = a * b;
      if (c / a != b) return (false, 0);
      return (true, c);
    }
  }

  function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
      if (b == 0) return (false, 0);
      return (true, a / b);
    }
  }

  function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
      if (b == 0) return (false, 0);
      return (true, a % b);
    }
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    return a + b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return a - b;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    return a * b;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return a % b;
  }

  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    unchecked {
      require(b <= a, errorMessage);
      return a - b;
    }
  }

  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    unchecked {
      require(b > 0, errorMessage);
      return a / b;
    }
  }

  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    unchecked {
      require(b > 0, errorMessage);
      return a % b;
    }
  }
}
// File: token/ERC20/IERC20.sol



pragma solidity ^0.8.0;

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address to, uint256 amount) external returns (bool);

  function allowance(address owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(
      address from,
      address to,
      uint256 amount
  ) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}
// File: token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;



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

// File: utils/Context.sol



pragma solidity ^0.8.0;

abstract contract Context {
  function _msgSender() public view returns (address) {
    return msg.sender;
  }
  
  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }
}

// File: access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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
// File: crowdsale/Crowdsale.sol



pragma solidity ^0.8.0;








contract KriptonitaCrowdsale is ReentrancyGuard, Ownable, PriceConsumerV3 {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address[] private _whitelistUsers;

    bool private _isFinalized = false;

    bool private _isPaused = false;

    bool private _whitelistEnabled = false;

    IERC20 private _token;

    address payable private _wallet;

    uint256 private _rate = 20;

    uint256 private _weiRaised;

    uint256 private _openingTime;

    uint256 private _closingTime;

    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    event TimedCrowdsaleExtended(uint256 prevClosingTime, uint256 newClosingTime);

    modifier onlyWhileOpen {
        require(isOpen(), "TimedCrowdsale: not open");
        _;
    }

    function openingTime() public view returns (uint256) {
        return _openingTime;
    }

    function closingTime() public view returns (uint256) {
        return _closingTime;
    }

    function isOpen() public view returns (bool) {
        return block.timestamp >= _openingTime && block.timestamp <= _closingTime;
    }

    function hasClosed() public view returns (bool) {
        return block.timestamp > _closingTime;
    }

    function _extendTime(uint256 newClosingTime) internal {
        require(!hasClosed(), "TimedCrowdsale: already closed");
        // solhint-disable-next-line max-line-length
        require(newClosingTime > _closingTime, "TimedCrowdsale: new closing time is before current closing time");

        emit TimedCrowdsaleExtended(_closingTime, newClosingTime);
        _closingTime = newClosingTime;
    }

    constructor (address payable wallet_, IERC20 token_, uint256 openingTime_, uint256 closingTime_) {
        require(wallet_ != address(0), "Crowdsale: wallet is the zero address");
        require(address(token_) != address(0), "Crowdsale: token is the zero address");
        require(openingTime_ >= block.timestamp, "TimedCrowdsale: opening time is before current time");
        require(closingTime_ > openingTime_, "TimedCrowdsale: opening time is not before closing time");

        _openingTime = openingTime_;
        _closingTime = closingTime_;

        _wallet = wallet_;
        _token = token_;
    }

    receive () external payable {
        buyTokens(msg.sender);
    }

        // retorna se a venda é somente para usuários da lista de usuarios permitidos
    function isOnlyWhitelisted() public view returns (bool) {
        return _whitelistEnabled;
    }

    // retorna se a venda está finalizada
    function isFinalized() public returns (bool) {
        if(block.timestamp > _closingTime) {
            _isFinalized = true;
        }
        return _isFinalized;
    }

    // retorna se a venda está pausada
    function isPaused() public view returns (bool) {
        return _isPaused;
    }

    function token() public view returns (IERC20) {
        return _token;
    }

    function wallet() public view returns (address payable) {
        return _wallet;
    }

    function rate() public view returns (uint256) {
        return _rate;
    }

    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }

        // retorna o balanco de tokens do usuario
    function getBalanceOfUser(address user) public view returns (uint256) {
        return _token.balanceOf(user);
    }

    // retorna o balanco de tokens do contrato
    function getBalanceOfContract () public view returns (uint256) {
        return _token.balanceOf(address(this));
    }

    // adiciona um array de usuarios a lista de usuarios permitidos
    function addUsersToWhitelist(address[] calldata users) public onlyOwner {
        delete _whitelistUsers;
        for(uint i = 0; i < users.length; i++) {
        require (users[i] != address(0), "Crowdsale: user is the zero address");
        _whitelistUsers.push(users[i]);
        }
    }

    // verifica se um usuário esta na lista de usuarios permitidos
    function isWhitelisted(address user) public view returns (bool) {
        for(uint i = 0; i < _whitelistUsers.length; i++) {
        if(_whitelistUsers[i] == user) {
            return true;
        }
        }
        return false;
    }

    // adiciona um usuário a lista de usuarios permitidos
    function addUserToWhitelist(address user) public onlyOwner {
        require (user != address(0), "Crowdsale: user is the zero address");
        _whitelistUsers.push(user);
    }

    // remove um usuário da lista de usuarios permitidos
    function removeUserFromWhitelist(address user) public onlyOwner {
        require (user != address(0), "Crowdsale: user is the zero address");
        for(uint i = 0; i < _whitelistUsers.length; i++) {
        if(_whitelistUsers[i] == user) {
            delete _whitelistUsers[i];
        }
        }
    }

    function pause(bool trueOrFalse) public onlyOwner {
        _isPaused = trueOrFalse;
    }

    function finalize () public onlyOwner {
        require (!_isFinalized, "Crowdsale: already finalized");
        require (!_isPaused, "Crowdsale: paused");
        _isFinalized = true;
    }

    function setWhitelist(bool trueOrFalse) public onlyOwner {
        _whitelistEnabled = trueOrFalse;
    }

    function buyTokens(address beneficiary) public nonReentrant payable {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);

        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);

        // update state
        _weiRaised = _weiRaised.add(weiAmount);

        _processPurchase(beneficiary, tokens);
        emit TokensPurchased(msg.sender, beneficiary, weiAmount, tokens);

        _updatePurchasingState(beneficiary, weiAmount);

        _forwardFunds();
    }

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal onlyWhileOpen view {
        if(isOnlyWhitelisted()) {
            require(isWhitelisted(beneficiary), "Crowdsale: user is not whitelisted");
        }
        require(!_isFinalized, "Crowdsale: not finalized");
        require(!_isPaused, "Crowdsale: paused");
        require(getBalanceOfUser(beneficiary) <= 12000e18, "Crowdsale: beneficiary already has tokens");
        require(_getTokenAmount(weiAmount) <= 12000e18, "Crowdsale: The maximum amount for purchase is 600 dollars");
        require(_getTokenAmount(weiAmount) >= 18000e18, "Crowdsale: the minimum purchase amount is 100 dollars");
        require(beneficiary != address(0), "Crowdsale: beneficiary is the zero address");
        require(weiAmount > 0, "Crowdsale: purchase amount is zero");
        this;
    }

    function getRateBNB() public view returns (uint256) {
        return getLatestPrice().mul(_rate);
    }

    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {
        _token.safeTransfer(beneficiary, tokenAmount);
    }

    function _processPurchase(address beneficiary, uint256 tokenAmount) internal {
        _deliverTokens(beneficiary, tokenAmount);
    }

    function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal {
        // solhint-disable-previous-line no-empty-blocks
    }

    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        return weiAmount.mul(getRateBNB());
    }

    function _forwardFunds() internal {
        _wallet.transfer(msg.value);
    }

    function withdraw(uint _amount) public payable onlyOwner nonReentrant {
        require(getBalanceOfContract() >= _amount, "Crowdsale: not enough funds");
        _token.safeTransfer(owner(), _amount);
  }
}