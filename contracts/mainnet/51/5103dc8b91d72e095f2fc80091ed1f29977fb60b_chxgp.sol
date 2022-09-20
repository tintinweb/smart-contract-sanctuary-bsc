/**
 *Submitted for verification at BscScan.com on 2022-09-20
*/

pragma solidity 0.8.11;

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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

    function sub(uint256 a,uint256 b,string memory errorMessage) internal pure returns (uint256) {
      unchecked {
        require(b <= a, errorMessage);
        return a - b;
      }
    }

    function div(uint256 a,uint256 b,string memory errorMessage) internal pure returns (uint256) {
      unchecked {
        require(b > 0, errorMessage);
        return a / b;
      }
    }

    function mod(uint256 a,uint256 b,string memory errorMessage) internal pure returns (uint256) {
      unchecked {
        require(b > 0, errorMessage);
        return a % b;
      }
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

  constructor() {
    _transferOwnership(_msgSender());
  }

  function owner() public view virtual returns (address) {
      return _owner;
  }

  modifier onlyOwner() {
      require(owner() == _msgSender(), "Ownable: caller is not the owner");
      _;
  }

  function renounceOwnership() public virtual onlyOwner {
      _transferOwnership(address(0));
  }

  function transferOwnership(address newOwner) public virtual onlyOwner {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      _transferOwnership(newOwner);
  }

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

    function verifyCallResult(bool success,bytes memory returndata,string memory errorMessage) internal pure returns (bytes memory) {
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

  function safeApprove(IERC20 token,address spender,uint256 value) internal {
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

  function _callOptionalReturn(IERC20 token, bytes memory data) private {
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

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

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

contract chxgp is Ownable, ReentrancyGuard {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  address public USDT;
  address public mk_address;

  mapping (uint256 => address) private _addressByIndex;
  mapping (address => uint256) private _level;
  uint256 startNum = 1;
  mapping(address => address[]) _mychilders;
  mapping(address => address) public _parents;
  mapping (address => uint256) private _earnings;


  uint256 public BASE_PRICE = 1 * 10 ** 16;

  address[] private _addressList;

  constructor (address _USDT, address topAddress) {
    USDT = _USDT;
    mk_address = topAddress;
    _addressByIndex[startNum] = mk_address;
    _level[mk_address] = 8;
  }

  function getMyChilders(address user) public view returns (address[] memory) {
    return _mychilders[user];
  }

  function getParent(address user) public view returns (address) {
    return _parents[user];
  }

  function getLevel(address _address) public view returns (uint256) {
    return _level[_address];
  }

  function getEarnings(address _address) public view returns (uint256) {
    return _earnings[_address];
  }

  function getAddressBykey(uint256 _int) public view returns (address) {
    return _addressByIndex[_int];
  }

  function getAddressList() public view returns (address[] memory) {
    return _addressList;
  }

  function setPRICE(uint256 _BASE_PRICE) public onlyOwner {
      BASE_PRICE = _BASE_PRICE;
    }

  function deposit() public nonReentrant {
    startNum = startNum.add(1);
    uint256 index = startNum;
    _addressByIndex[startNum] = msg.sender;

    if (index.mod(3) == 2) {
      index = index.add(1);
    } else if (index.mod(3) == 1) {
      index = index.sub(1);
    } else if (index.mod(3) == 0) {
      index = index;
    } else {
      require(false, 'There is an error');
    }

    uint256 key = index.div(3);

    _parents[msg.sender] = _addressByIndex[key];
    _mychilders[_addressByIndex[key]].push(msg.sender);
    _addressList.push(msg.sender);

    address result;
    uint256 amount = 0;
    uint256 current_Level = 0;
    if(_level[msg.sender] == 0) {
      current_Level = 1;
      result =  getSuperiorAddress(msg.sender, 1);
      amount = BASE_PRICE;
      _level[msg.sender] = 1;
    } else if(_level[msg.sender] == 1) {
      current_Level = 2;
      result =  getSuperiorAddress(msg.sender, 2);
      amount = BASE_PRICE.mul(2);
      _level[msg.sender] = 2;
    } else if(_level[msg.sender] == 2) {
      current_Level = 3;
      result =  getSuperiorAddress(msg.sender, 3);
      amount = BASE_PRICE.mul(3);
      _level[msg.sender] = 3;
    } else if(_level[msg.sender] == 3) {
      current_Level = 4;
      result =  getSuperiorAddress(msg.sender, 4);
      amount = BASE_PRICE.mul(4);
      _level[msg.sender] = 4;
    } else if(_level[msg.sender] == 4) {
      current_Level = 5;
      result =  getSuperiorAddress(msg.sender, 5);
      amount = BASE_PRICE.mul(5);
      _level[msg.sender] = 5;
    } else if(_level[msg.sender] == 5) {
      current_Level = 6;
      result =  getSuperiorAddress(msg.sender, 6);
      amount = BASE_PRICE.mul(8);
      _level[msg.sender] = 6;
    } else if(_level[msg.sender] == 6) {
      current_Level = 7;
      result =  getSuperiorAddress(msg.sender, 7);
      amount = BASE_PRICE.mul(12);
      _level[msg.sender] = 7;
    } else if(_level[msg.sender] == 7) {
      current_Level = 8;
      result =  getSuperiorAddress(msg.sender, 8);
      amount = BASE_PRICE.mul(20);
      _level[msg.sender] = 8;
    } else {
      require(false, "The highest");
    }


    IERC20(USDT).transferFrom(msg.sender, mk_address, amount.mul(3).div(10));
    if (_level[result] >= current_Level) {
      IERC20(USDT).transferFrom(msg.sender, result, amount.mul(7).div(10));
      _earnings[result] = _earnings[result].add(amount.mul(7).div(10));
    } else {
      IERC20(USDT).transferFrom(msg.sender, mk_address, amount.mul(7).div(10));
    }

  }

  function getSuperiorAddress(address user, int256 cycles) public view returns (address) {
    address cur = user;
    address superior;
    for (int256 i = 0; i < cycles; i++) {
      cur = _parents[cur];
      if (cur == address(0)) {
        superior = mk_address;
        break;
      } else {
        superior = cur;
      }
    }
    return superior;
  }



  function donateDust(address addr, uint256 amount) external onlyOwner {
    TransferHelper.safeTransfer(addr, _msgSender(), amount);
  }

    function donateEthDust(uint256 amount) external onlyOwner {
    TransferHelper.safeTransferETH(_msgSender(), amount);
  }
}