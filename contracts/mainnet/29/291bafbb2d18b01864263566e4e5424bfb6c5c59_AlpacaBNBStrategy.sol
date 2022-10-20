/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/math/SafeMath.sol

// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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

// File: contracts/Strategies/Interfaces/IVault.sol


pragma solidity ^0.8.4;

interface IVault {

  function totalToken() external view returns (uint256);

  function deposit(uint256 amountToken) external payable;

  function withdraw(uint256 share) external;

  function requestFunds(address targetedToken, uint256 amount) external;

  function token() external view returns (address);
}

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol

// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol

// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

abstract contract ERC165 is IERC165 {

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts/utils/Strings.sol

// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    function toString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// File: @openzeppelin/contracts/utils/Context.sol

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/security/Pausable.sol
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

abstract contract Pausable is Context {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    modifier whenPaused() {
        _requirePaused();
        _;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: @openzeppelin/contracts/access/IAccessControl.sol

// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

interface IAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address account) external;
}

// File: @openzeppelin/contracts/access/AccessControl.sol
// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// File: @openzeppelin/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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

// File: @openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

interface IERC20Permit {

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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
}

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol

// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

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

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
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

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: contracts/Helpers/Safe.sol

pragma solidity ^0.8.4;


abstract contract Safe {
  using SafeERC20 for IERC20;

  address target;

  constructor(address _target) {
    target = _target;
  }

  function _withdrawFunds() internal returns (bool) {
    (bool sent, ) = address(target).call{value: address(this).balance}("");
    require(sent, "Safe: Failed to send Ether");
    return sent;
  }

  function _withdrawFundsERC20(address tokenAddress) internal returns (bool) {
    IERC20 token = IERC20(tokenAddress);
    token.safeTransfer(target, token.balanceOf(address(this)));
    return true;
  }
}

// File: contracts/Strategies/IStrategy.sol

pragma solidity ^0.8.4;

interface IStrategy {
  struct Rewards {
    uint256 rewardsAmount;
    uint256 depositedAmount;
    uint256 timestamp;
  }

  /// @notice Deposits an initial or more liquidity in the external contract
  function deposit(uint256 amount) external payable returns (bool);

  /// @notice Withdraws all the funds deposited in the external contract
  function withdraw(uint256 amount) external returns (bool);

  function withdrawAll() external returns (bool);

  /// @notice This function will get all the rewards from the external service and send them to the invoker
  function gather() external;

  /// @notice Returns the amount staked plus the earnings
  function checkRewards() external view returns (Rewards memory);
}

// File: contracts/Strategies/Strategy.sol

pragma solidity ^0.8.4;

contract Strategy is IStrategy, Safe, AccessControl, Pausable {
  bytes32 public constant REBALANCER_ROLE = keccak256("REBALANCER_ROLE");

  /// @notice The amountDeposited MUST reflect the amount of native tokens currently deposited into other contracts. All deposits and withdraws so update this variable.
  uint256 public amountDeposited = 0;

  modifier onlyAdmin() {
    require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Strategy: ONLY_ADMIN");
    _;
  }

  modifier onlyRebalancer() {
    require(hasRole(REBALANCER_ROLE, msg.sender), "Strategy: ONLY_REBALANCER");
    _;
  }

  constructor(address _fundsTarget) Safe(_fundsTarget) {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
  }

  receive() external payable virtual {}

  event Gather();
  event Deposit(uint256);
  event Withdraw(uint256);

  function checkRewards() public view virtual override returns (IStrategy.Rewards memory) {
    uint256 rewards = address(this).balance - amountDeposited;
    IStrategy.Rewards memory result = IStrategy.Rewards(
      rewards,
      amountDeposited,
      block.timestamp * 1000
    );
    return result;
  }

  function deposit(uint256 depositValue)
    public
    payable
    virtual
    override
    onlyRebalancer
    whenNotPaused
    returns (bool)
  {
    require(
      depositValue == msg.value,
      "Strategy: Deposit Value Parameter does not equal payable amount"
    );
    amountDeposited += depositValue;
    emit Deposit(depositValue);
    return true;
  }

  function withdraw(uint256 amount)
    public
    virtual
    override
    onlyRebalancer
    whenNotPaused
    returns (bool)
  {
    require(
      amount <= amountDeposited,
      "Strategy: Amount Requested to Withdraw is Greater Than Amount Deposited"
    );
    (bool successTransfer, ) = address(msg.sender).call{value: amount}("");
    require(successTransfer, "Strategy: FAIL_SENDING_NATIVE");
    amountDeposited -= amount;
    emit Withdraw(amount);
    return successTransfer;
  }

  function withdrawAll() external virtual override onlyRebalancer whenNotPaused returns (bool) {
    uint256 balance = address(this).balance;
    (bool successTransfer, ) = address(msg.sender).call{value: balance}("");
    require(successTransfer, "Strategy: FAIL_SENDING_NATIVE");
    amountDeposited -= balance;
    return true;
  }

  function gather() public virtual override onlyRebalancer whenNotPaused {
    uint256 nativeAmount = address(this).balance - amountDeposited;
    (bool successTransfer, ) = address(msg.sender).call{value: nativeAmount}("");
    require(successTransfer, "Strategy: FAIL_SENDING_NATIVE");
    emit Gather();
  }

  function withdrawFunds() public onlyAdmin returns (bool) {
    return _withdrawFunds();
  }

  function withdrawFundsERC20(address tokenAddress) public onlyAdmin returns (bool) {
    return _withdrawFundsERC20(tokenAddress);
  }
}

// File: contracts/Strategies/Alpaca.sol

pragma solidity ^0.8.4;


contract AlpacaBNBStrategy is Strategy {

  using SafeMath for uint256;

  address public alpacaVault;
  address public rebalancer;

  event UpdateRebalancer(address rebalancer);
  event UpdateAlpacaVault(address alpacaVault);

  constructor(
    address _fundsTarget,
    address _rebalancer,
    address _alpacaVault
  ) Strategy(_fundsTarget) {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(REBALANCER_ROLE, msg.sender);
    rebalancer = payable(_rebalancer);
    alpacaVault = payable(_alpacaVault);
  }

  function checkRewards() public view virtual override returns (IStrategy.Rewards memory) {
    uint256 pendingRewards = rewardsAmount();
    IStrategy.Rewards memory result = IStrategy.Rewards(
      pendingRewards,
      amountDeposited,
      block.timestamp * 1000
    );
    return result;
  }

  function getTotalSupplyBNB() public view returns (uint256 bNBSupply) {
    uint256 totalBNBSupply = IVault(alpacaVault).totalToken();
    return totalBNBSupply;
  }

  function getTotalSupplyIBNB() public view returns (uint256 ibBNBSupply) {
    uint256 totalIBBNBSupply = IERC20(alpacaVault).totalSupply();
    return totalIBBNBSupply;
  }

  function getIBBNBToBNB(uint256 ibBNBValue) public view returns (uint256 balance) {
    uint256 bnbSupply = getTotalSupplyBNB();
    uint256 ibBNBSupply = getTotalSupplyIBNB();
    uint256 ibbnbToBNB = (ibBNBValue.mul(bnbSupply)).div(ibBNBSupply);
    return ibbnbToBNB;
  }

  function getBNBToIBBNB(uint256 bnbValue) public view returns (uint256 balance) {
    uint256 bnbSupply = getTotalSupplyBNB();
    uint256 ibBNBSupply = getTotalSupplyIBNB();
    uint256 bnbToIBNB = (bnbValue.mul(ibBNBSupply)).div(bnbSupply);
    return bnbToIBNB;
  }

  ///@notice Returns Alpaca Balance in BNB
  function getAlpacaBalance() public view returns (uint256 balance) {
    uint256 ibBNBBalance = IERC20(alpacaVault).balanceOf(address(this));
    uint256 balanceInAlpaca = getIBBNBToBNB(ibBNBBalance);
    return balanceInAlpaca;
  }

  function rewardsAmount() public view returns (uint256 rewards) {
    uint256 redeemValue = getAlpacaBalance();
    uint256 pendingRewards = redeemValue.sub(amountDeposited);
    return pendingRewards;
  }

  function gather() public virtual override onlyRebalancer whenNotPaused {
    uint256 toWithdraw = rewardsAmount();
    uint256 amountOfIBBNBToWithdraw = getBNBToIBBNB(toWithdraw);
    IVault(alpacaVault).withdraw(amountOfIBBNBToWithdraw);
    (bool successTransfer, ) = address(msg.sender).call{value: toWithdraw}("");
    require(successTransfer, "Alpaca Strategy: Fail sending funds to Rebalancer");
  }

  function deposit(uint256 depositValue)
    public
    payable
    virtual
    override
    onlyRebalancer
    whenNotPaused
    returns (bool)
  {
    require(
      depositValue == msg.value,
      "Alpaca Strategy: Deposit Value Parameter does not equal payable amount"
    );
    IVault(alpacaVault).deposit{value: depositValue}(depositValue);
    amountDeposited += depositValue;
    return true;
  }

  function withdraw(uint256 amount) public override onlyRebalancer whenNotPaused returns (bool) {
    require(
      amount <= amountDeposited,
      "Alpaca Strategy: Amount Requested to Withdraw is Greater Than Amount Deposited"
    );
    uint256 amountIBBNBWithdraw = getBNBToIBBNB(amount);
    IERC20(alpacaVault).approve(alpacaVault, amountIBBNBWithdraw);
    IVault(alpacaVault).withdraw(amountIBBNBWithdraw);
    (bool successTransfer, ) = address(msg.sender).call{value: amount}("");
    require(successTransfer, "Alpaca Strategy: Fail Sending Native to Rebalancer");
    amountDeposited -= amount;
    return true;
  }

  function withdrawAll() external virtual override onlyAdmin whenNotPaused returns (bool) {
    uint256 ibBNBBalance = IERC20(alpacaVault).balanceOf(address(this));
    IVault(alpacaVault).withdraw(ibBNBBalance);
    (bool successTransfer, ) = address(msg.sender).call{value: address(this).balance}("");
    require(successTransfer, "Alpaca Strategy: Fail to Withdraw All from Alpaca");
    amountDeposited = 0;
    return successTransfer;
  }

  function setAlpacaVault(address newAddress) public onlyAdmin {
    alpacaVault = newAddress;
    emit UpdateAlpacaVault(newAddress);
  }
}