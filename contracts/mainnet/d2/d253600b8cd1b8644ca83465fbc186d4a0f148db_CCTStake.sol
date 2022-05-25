/**
 *Submitted for verification at BscScan.com on 2022-05-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

library Address {
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

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
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

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

contract CCTStake is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    address public CTTToken;
    address public USDT;
    address public mk;
    address public LPAddress;
    
    uint256 public DURATION = 1 days;

    uint256 private _decimals = 9;

    uint256 public PRICE = 6 * 10 ** 18;

    uint256 public USDT_TOTLE = 0;

    mapping (address => bool) private _isExcludedFromFee;

    mapping (address => uint256) private _canCarryAmount;

    mapping (address => uint256) private whiteAmountList;

    mapping (address => bool) private whiteList;

    uint256 whiteNumber = 167000000 * 10 ** _decimals;

    bool public bonusesSwitch = false;

    uint256 shortNumber = 400000000000 * 10 ** _decimals;

    uint256 MIN_LP_AMOUNT = 5 * 10 ** _decimals;

    uint256 public firstRoundAmount = 0;
    bool public firstSwitch = true;
    uint256 public secondRoundAmount = 0;
    bool public secondSwitch = false;
    uint256 public thirdRoundAmount = 0;
    bool public thirdSwitch = false;

    uint256 public DIS_1_AMOUNT = 10000000 * 10 ** _decimals;
    uint256 public DIS_2_AMOUNT = 5000000 * 10 ** _decimals;
    uint256 public DIS_3_AMOUNT = 2500000 * 10 ** _decimals;

    mapping(address => address[]) _mychilders;
    mapping(address => address) public _parents;

    mapping(address => uint256) public _userTime;

    mapping(address => uint256) public _userWhiteTime;

    mapping(address => UserInfo) public userInfo;

    event BindingParents(address indexed user, address inviter);

    struct UserInfo {
      uint256 level;
    }

    constructor (address _mk, address _CTTToken, address _USDT) {
      mk = _mk;
      CTTToken = _CTTToken;
      USDT = _USDT;
    }

    function getMyChilders(address user) public view returns (address[] memory) {
      return _mychilders[user];
    }

    function getParent(address user) public view returns (address) {
      return _parents[user];
    }

    function getUserTime(address user) public view returns (uint256) {
      return _userTime[user];
    }

    function getUserWhiteTime(address user) public view returns (uint256) {
      return _userWhiteTime[user];
    }

    function getIsExcludedFromFee(address user) public view returns (bool) {
      return _isExcludedFromFee[user];
    }

    function getWhiteList(address user) public view returns (bool) {
      return whiteList[user];
    }

    function getWhiteAmountList(address user) public view returns (uint256) {
      return whiteAmountList[user];
    }

    function getCanCarryAmount(address user) public view returns (uint256) {
      return _canCarryAmount[user];
    }

    function getUSDTTotal() public view returns (uint256) {
      return USDT_TOTLE;
    }

    function setSwitch(bool switch1, bool switch2, bool switch3) public onlyOwner {
      firstSwitch = switch1;
      secondSwitch = switch2;
      thirdSwitch = switch3;
    }

    function setBonusesSwitch(bool _bonusesSwitch) public onlyOwner {
      bonusesSwitch = _bonusesSwitch;
    }
    
    function setWhiteList(address user) public onlyOwner {
      whiteList[user] = true;
      whiteAmountList[user] = whiteAmountList[user].add(whiteNumber);
    }

    function setLP(address _LPAddress) public onlyOwner {
      LPAddress = _LPAddress;
    }

    function setDURATION(uint256 _DURATION) public onlyOwner {
      DURATION = _DURATION;
    }

    function setMIN_LP_AMOUNT(uint256 _MIN_LP_AMOUNT) public onlyOwner {
      MIN_LP_AMOUNT = _MIN_LP_AMOUNT;
    }

    function setPRICE(uint256 _PRICE) public onlyOwner {
      PRICE = _PRICE;
    }

    function bindParent(address parent) public returns (bool) {
      require(_parents[msg.sender] == address(0), "Already bind");
      require(parent != address(0), "ERROR parent");
      require(parent != msg.sender, "ERROR parent");
      _parents[msg.sender] = parent;
      _mychilders[parent].push(msg.sender);
      emit BindingParents(msg.sender, parent);
      return true;
    }

    function deposit_1() public nonReentrant {
      require(firstSwitch, 'no start');
      require(!_isExcludedFromFee[msg.sender], "CTT: Already involved");
      require(firstRoundAmount < shortNumber, "CTT: Already involved");

      UserInfo storage user = userInfo[msg.sender];
      user.level = 1;

      _canCarryAmount[msg.sender] = _canCarryAmount[msg.sender].add(DIS_1_AMOUNT);
      firstRoundAmount = firstRoundAmount.add(DIS_1_AMOUNT);
      USDT_TOTLE = USDT_TOTLE.add(PRICE);
      _isExcludedFromFee[msg.sender] = true;
      IERC20(USDT).transferFrom(msg.sender, mk, PRICE);
    }

    function deposit_2() public nonReentrant {
      require(secondSwitch, 'no start');
      require(!_isExcludedFromFee[msg.sender], "CTT: Already involved");
      require(secondRoundAmount < shortNumber, "CTT: Already involved");

      UserInfo storage user = userInfo[msg.sender];
      user.level = 2;

      _canCarryAmount[msg.sender] = _canCarryAmount[msg.sender].add(DIS_2_AMOUNT);
      secondRoundAmount = secondRoundAmount.add(DIS_2_AMOUNT);
      USDT_TOTLE = USDT_TOTLE.add(PRICE);
      _isExcludedFromFee[msg.sender] = true;
      IERC20(USDT).transferFrom(msg.sender, mk, PRICE);
    }

    function deposit_3() public nonReentrant {
      require(thirdSwitch, 'no start');
      require(!_isExcludedFromFee[msg.sender], "CTT: Already involved");
      require(thirdRoundAmount < shortNumber, "CTT: Already involved");

      UserInfo storage user = userInfo[msg.sender];
      user.level = 3;

      _canCarryAmount[msg.sender] = _canCarryAmount[msg.sender].add(DIS_3_AMOUNT);
      thirdRoundAmount = thirdRoundAmount.add(DIS_3_AMOUNT);
      USDT_TOTLE = USDT_TOTLE.add(PRICE);
      _isExcludedFromFee[msg.sender] = true;
      IERC20(USDT).transferFrom(msg.sender, mk, PRICE);
    }

    function getWhiteReward() public nonReentrant {
        require(whiteList[msg.sender], 'no white');
        require(_userWhiteTime[msg.sender] > 0, 'no amount');
        require(block.timestamp > _userWhiteTime[msg.sender].add(DURATION), 'No time to');
        require(IERC20(LPAddress).balanceOf(msg.sender) > MIN_LP_AMOUNT, 'LP is insufficient');

        uint256 amount = whiteAmountList[msg.sender];
        uint256 shiteCanCarrey = whiteNumber.div(180);
        _userWhiteTime[msg.sender] = block.timestamp;
        if(amount > 0 && amount >= shiteCanCarrey) {
            whiteAmountList[msg.sender] = whiteAmountList[msg.sender].sub(shiteCanCarrey);
            IERC20(CTTToken).transfer(msg.sender, shiteCanCarrey);
        } else {
            IERC20(CTTToken).transfer(msg.sender, whiteAmountList[msg.sender]);
            whiteAmountList[msg.sender] = 0;
        }
    }

    function getReward() public nonReentrant {
        require(bonusesSwitch, 'no start');
        require(_canCarryAmount[msg.sender] > 0, 'no amount');
        require(block.timestamp > _userTime[msg.sender].add(DURATION), 'No time to');
        require(IERC20(LPAddress).balanceOf(msg.sender) > MIN_LP_AMOUNT, 'LP is insufficient');

        UserInfo storage user = userInfo[msg.sender];
        uint256 reflect = 0;
        if (user.level == 1) {
            reflect = DIS_1_AMOUNT.div(180);
        } else if (user.level == 2) {
            reflect = DIS_2_AMOUNT.div(180);
        } else if (user.level == 3) {
            reflect = DIS_3_AMOUNT.div(180);
        }

        _userTime[msg.sender] = block.timestamp;
        address superior =  _parents[msg.sender];
        if (_canCarryAmount[msg.sender] > 0 && _canCarryAmount[msg.sender] >= reflect) {
            _canCarryAmount[msg.sender] = _canCarryAmount[msg.sender].sub(reflect);
            IERC20(CTTToken).transfer(msg.sender, reflect);
            if (superior != address(0) && IERC20(LPAddress).balanceOf(superior) > MIN_LP_AMOUNT) {
                IERC20(CTTToken).transfer(superior, reflect);
            }
        } else {
            IERC20(CTTToken).transfer(msg.sender, _canCarryAmount[msg.sender]);
            if (superior != address(0) && IERC20(LPAddress).balanceOf(superior) > MIN_LP_AMOUNT) {
                IERC20(CTTToken).transfer(superior, _canCarryAmount[msg.sender]);
            }
            _canCarryAmount[msg.sender] = 0;
        }
    }

    
    function donateDust(address addr, uint256 amount) external onlyOwner {
        TransferHelper.safeTransfer(addr, _msgSender(), amount);
    }

    function donateEthDust(uint256 amount) external onlyOwner {
        TransferHelper.safeTransferETH(_msgSender(), amount);
    }

}