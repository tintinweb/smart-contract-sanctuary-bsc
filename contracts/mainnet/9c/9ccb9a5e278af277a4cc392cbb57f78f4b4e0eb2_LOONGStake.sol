/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC165 {
  function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface Imetedao {
  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
  event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
  event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
  function balanceOf(address owner) external view returns (uint256 balance);
  function ownerOf(uint256 tokenId) external view returns (address owner);
  function safeTransferFrom( address from, address to, uint256 tokenId, bytes calldata data) external;
  function safeTransferFrom(address from, address to, uint256 tokenId) external;
  function transferFrom(address from, address to, uint256 tokenId) external;
  function approve(address to, uint256 tokenId) external;
  function setApprovalForAll(address operator, bool _approved) external;
  function getApproved(uint256 tokenId) external view returns (address operator);
  function isApprovedForAll(address owner, address operator) external view returns (bool);
  function IDOSetCardStatus(address account) external;
}


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

contract LOONGStake is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    address public USDT;
    address public mk = 0xAC0d9b9253cddF935fB5Edbd990067E42b8BDEC1;
    
    uint256 private _decimals = 9;

    uint256 public PRICE_1 = 100 * 10 ** 18;
    uint256 public PRICE_2 = 500 * 10 ** 18;

    uint256 public USDT_TOTLE = 0;

    Imetedao public TsingLungNFT = Imetedao(0xFc6c261a583200dB15914aBa606Cd6aEFe858484);
    Imetedao public dragonNFT = Imetedao(0xC1E8a654d9d59870bCD9C76e32c551720b20C390);

    uint256 public TsingLungNum = 0;
    uint256 public DragonNum = 0;

    mapping (address => bool) private _isGoldCardFromFee;
    mapping (address => bool) private _isSilverCardFromFee;

    mapping (address => uint256) private _referralBonuses;

    mapping (address => bool) private _alreadyRec;

    uint256 public lines_1 = 0;
    uint256 public lines_2 = 0;

    mapping(address => address[]) _mychilders;
    mapping(address => address) public _parents;

    event BindingParents(address indexed user, address inviter);

    constructor (address _USDT) {
      USDT = _USDT;
    }

    function getMyChilders(address user) public view returns (address[] memory) {
      return _mychilders[user];
    }

    function getParent(address user) public view returns (address) {
      return _parents[user];
    }

    function getAlreadyRec(address user) public view returns (bool) {
      return _alreadyRec[user];
    }

    function getReferralBonuses(address user) public view returns (uint256) {
      return _referralBonuses[user];
    }

    function getIsgoldCardFromFee(address user) public view returns (bool) {
      return _isGoldCardFromFee[user];
    }

    function getIsSilverCardFromFee(address user) public view returns (bool) {
      return _isSilverCardFromFee[user];
    }

    function setTsingLungNFT(address _TsingLungNFT) public onlyOwner {
      TsingLungNFT = Imetedao(_TsingLungNFT);
    }

    function setDragonNFT(address _dragonNFT) public onlyOwner {
      dragonNFT = Imetedao(_dragonNFT);
    }
    
    function getChildrenLength(address account) public view returns (uint256) {
      return _mychilders[account].length;
    }

    function setPRICE(uint256 _PRICE_1) public onlyOwner {
      PRICE_1 = _PRICE_1;
    }

    function bindParent(address parent) public returns (bool) {
      require(_parents[msg.sender] == address(0), "Already bind");
      require(parent != address(0), "ERROR parent");
      require(parent != msg.sender, "ERROR parent");
      require(_isGoldCardFromFee[parent] || _isSilverCardFromFee[parent] || parent == owner(), "ERROR The superior did not participate in IDO");
      _parents[msg.sender] = parent;
      _mychilders[parent].push(msg.sender);
      emit BindingParents(msg.sender, parent);
      return true;
    }

    function setNFTstatus(address parent) internal {
      if (_mychilders[parent].length >= 10 && (TsingLungNum < 1000 || DragonNum < 10000) && !_alreadyRec[parent]) {
        address[] memory arr = _mychilders[parent];
        uint256 num = 0;
        for(uint256 i = 0; i < arr.length; i++) {
          if (_isGoldCardFromFee[arr[i]] || _isSilverCardFromFee[arr[i]]) {
            num = num.add(1);
          }
        }
        if (num >= 10) {
          if (_isGoldCardFromFee[parent]) {
            TsingLungNFT.IDOSetCardStatus(parent);
            TsingLungNum = TsingLungNum.add(1);
          } else {
            dragonNFT.IDOSetCardStatus(parent);
            DragonNum = DragonNum.add(1);
          }
          _alreadyRec[parent] = true;
        }
      }
    }

    function deposit(uint256 _glod) public nonReentrant {
      require(!_isGoldCardFromFee[msg.sender] && !_isSilverCardFromFee[msg.sender], "Already involved");
      address superior_1 =  _parents[msg.sender];
      if (_glod == 1) {
        require(lines_1 < 2000, 'IDO: Has ended');
        lines_1 = lines_1.add(1);
        _isGoldCardFromFee[msg.sender] = true;

        uint256 amount = PRICE_2;
        if (superior_1 != address(0) && (_isGoldCardFromFee[superior_1] || _isSilverCardFromFee[superior_1])) {
          
          setNFTstatus(superior_1);

          IERC20(USDT).transferFrom(msg.sender, superior_1, PRICE_2.mul(10).div(100));
          amount = amount.sub(PRICE_2.mul(10).div(100));
          _referralBonuses[superior_1].add(PRICE_2.mul(10).div(100));

          address superior_2 =  _parents[superior_1];
          if (superior_2 != address(0) && (_isGoldCardFromFee[superior_2] || _isSilverCardFromFee[superior_2])) {

            IERC20(USDT).transferFrom(msg.sender, superior_2, PRICE_2.mul(5).div(100));
            amount = amount.sub(PRICE_2.mul(5).div(100));
            _referralBonuses[superior_2].add(PRICE_2.mul(5).div(100));

            address superior_3 =  _parents[superior_2];
            if (superior_3 != address(0) && (_isGoldCardFromFee[superior_3] || _isSilverCardFromFee[superior_3])) {
              IERC20(USDT).transferFrom(msg.sender, superior_3, PRICE_2.mul(5).div(100));
              amount = amount.sub(PRICE_2.mul(5).div(100));
              _referralBonuses[superior_3].add(PRICE_2.mul(5).div(100));
            }
          }
        }
        USDT_TOTLE = USDT_TOTLE.add(PRICE_2);
        IERC20(USDT).transferFrom(msg.sender, mk, amount);
        TsingLungNFT.IDOSetCardStatus(msg.sender);
      } else {
        require(lines_2 < 20000, 'IDO: Has ended');
        lines_2 = lines_2.add(1);
        _isSilverCardFromFee[msg.sender] = true;

        uint256 amount = PRICE_1;
        if (superior_1 != address(0) && (_isGoldCardFromFee[superior_1] || _isSilverCardFromFee[superior_1])) {

          setNFTstatus(superior_1);

          IERC20(USDT).transferFrom(msg.sender, superior_1, PRICE_1.mul(10).div(100));
          amount = amount.sub(PRICE_1.mul(10).div(100));
          _referralBonuses[superior_1].add(PRICE_1.mul(10).div(100));
        }
        USDT_TOTLE = USDT_TOTLE.add(PRICE_1);
        IERC20(USDT).transferFrom(msg.sender, mk, amount);
        dragonNFT.IDOSetCardStatus(msg.sender);
      }
    }

    function donateDust(address addr, uint256 amount) external onlyOwner {
        TransferHelper.safeTransfer(addr, _msgSender(), amount);
    }

    function donateEthDust(uint256 amount) external onlyOwner {
        TransferHelper.safeTransferETH(_msgSender(), amount);
    }

}