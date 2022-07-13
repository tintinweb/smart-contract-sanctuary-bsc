/**
 *Submitted for verification at BscScan.com on 2022-07-13
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
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom( address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval( address indexed owner, address indexed spender, uint256 value);
}

interface heroIERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom( address sender, address recipient, uint256 amount) external returns (bool);
    function setToRobList(address account) external;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval( address indexed owner, address indexed spender, uint256 value);
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

contract HeroStake is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    address public CTTToken = 0xff88da83004a31b7c7c9d76475C39856a8245cfA;
    address public USDT;
    address public mk = 0xF01914A363C626f87a8a248176016132a2e5f600;
    
    uint256 public DURATION = 30 minutes;

    uint256 private _decimals = 9;

    uint256 public PRICE = 110 * 10 ** 18;
    uint256 public Ordinary_PRICE = 290 * 10 ** 18;
    uint256 public Super_PRICE = 1000 * 10 ** 18;

    uint256 public USDT_TOTLE = 0;
    uint256 public _idoNumber = 3000;
    uint256 public _hasido = 0;

    uint256 public warriorNumber = 0;
    uint256 public templeNumber = 0;
    uint256 public kingNumber = 0;

    uint256 public LPStandard = 10 * 10 ** 18;
    address public poolAddress;
    address public BTCAddress = 0xF454a80265d342170803102671f25d6CD6f80684;

    bool public NFTBegins = true;
    bool public idoToReceive = true;

    mapping (address => uint256) private _referralBonuses;

    
    mapping (address => uint256) private _NFTlevel;

    Imetedao public YS_NFTToken = Imetedao(0xE26C0cfAff265E0e45E945dfC526f28155c3d4EA);
    Imetedao public ST_NFTToken = Imetedao(0x875e24226Da09e65357b55cf16A23deCA596B608);
    Imetedao public WZ_NFTToken = Imetedao(0x53b317088bba357f8d043a6443E617AFa1B6e84F);
    Imetedao public PT_NFTXUNZ = Imetedao(0xeCeE17889f27f4C38fDE1F78b7dB56F468a8F5f7);
    Imetedao public CJ_NFTXUNZ = Imetedao(0x80D822Bd773E8f83732Dd8C3A13d716501e22aB2);


    heroIERC20 public heroToken = heroIERC20(0xff88da83004a31b7c7c9d76475C39856a8245cfA);

    mapping (address => bool) private _isCardFromFee;
    mapping (address => bool) private _isOrdinaryMedal;
    mapping (address => bool) private _isSuperMedal;
    uint256 public OrdinaryNum = 0;
    uint256 public SuperNum = 0;

    mapping (address => uint256) private _canCarryAmount;
    uint256 public IDOAmount = 3138 * 10 ** 9;
    uint256 public basisRate = 100;

    mapping(address => address[]) _mychilders;
    mapping(address => address) public _parents;

    mapping(address => uint256) public _userTime;

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

    function getUserTime(address user) public view returns (uint256) {
      return _userTime[user];
    }

    function getIsCardFromFee(address user) public view returns (bool) {
      return _isCardFromFee[user];
    }

    function getIsOrdinaryMedal(address user) public view returns (bool) {
      return _isOrdinaryMedal[user];
    }

    function getIsSuperMedal(address user) public view returns (bool) {
      return _isSuperMedal[user];
    }

    function getCanCarryAmount(address user) public view returns (uint256) {
      return _canCarryAmount[user];
    }

    function setLPStandard(uint256 _number) public onlyOwner {
      LPStandard = _number;
    }

    function setBasisRate(uint256 _number) public onlyOwner {
      basisRate = _number;
    }

    function setBTCAddress(address _address) public onlyOwner {
      BTCAddress = _address;
    }

    function setMKAddress(address _mk) public onlyOwner {
      mk = _mk;
    }

    function setPoolAddress(address _address) public onlyOwner {
      poolAddress = _address;
    }

    function setCTTToken(address _CTTToken) public onlyOwner {
      CTTToken = _CTTToken;
    }
    
    function setYSNFTToken(address _NFTToken) public onlyOwner {
      YS_NFTToken = Imetedao(_NFTToken);
    }

    function setSTNFTToken(address _NFTToken) public onlyOwner {
      ST_NFTToken = Imetedao(_NFTToken);
    }

    function setWZNFTToken(address _NFTToken) public onlyOwner {
      WZ_NFTToken = Imetedao(_NFTToken);
    }

    function setPTNFTXUNZ(address _NFTToken) public onlyOwner {
      PT_NFTXUNZ = Imetedao(_NFTToken);
    }

    function setCJNFTXUNZ(address _NFTToken) public onlyOwner {
      CJ_NFTXUNZ = Imetedao(_NFTToken);
    }

    function setYSNFTTokenStatus(address account) public onlyOwner {
      YS_NFTToken.IDOSetCardStatus(account);
    }

    function getChildrenLength(address account) public view returns (uint256) {
      return _mychilders[account].length;
    }
    
    function getNFTlevel(address account) public view returns (uint256) {
      return _NFTlevel[account];
    }

    function setDURATION(uint256 _DURATION) public onlyOwner {
      DURATION = _DURATION;
    }

    function setPRICE(uint256 _PRICE) public onlyOwner {
      PRICE = _PRICE;
    }

    function setIdoNumber(uint256 number) public onlyOwner {
      _idoNumber = number;
    }

    function setHasido(uint256 number) public onlyOwner {
      _hasido = number;
    }

    function setNFTBegins(bool _bool) public onlyOwner {
      NFTBegins = _bool;
    }

    function setIdoToReceive(bool _bool) public onlyOwner {
      idoToReceive = _bool;
    }

    function bindParent(address parent) public returns (bool) {
      require(_parents[msg.sender] == address(0), "Already bind");
      require(parent != address(0), "ERROR parent");
      require(parent != msg.sender, "ERROR parent");
      require(_isCardFromFee[parent], "ERROR The superior did not participate in IDO");
      _parents[msg.sender] = parent;
      _mychilders[parent].push(msg.sender);
      emit BindingParents(msg.sender, parent);
      return true;
    }

    function ordinaryMedal() public nonReentrant {
      require(_isOrdinaryMedal[msg.sender], 'Already involved');
      IERC20(USDT).transferFrom(msg.sender, mk, Ordinary_PRICE);
      PT_NFTXUNZ.IDOSetCardStatus(msg.sender);
      _canCarryAmount[msg.sender] = _canCarryAmount[msg.sender].add(IDOAmount.mul(4));
    }

    function superMedal() public nonReentrant {
      require(_isSuperMedal[msg.sender], 'Already involved');
      IERC20(USDT).transferFrom(msg.sender, mk, Super_PRICE);
      CJ_NFTXUNZ.IDOSetCardStatus(msg.sender);
      _canCarryAmount[msg.sender] = _canCarryAmount[msg.sender].add(IDOAmount.mul(15));
    }

    function setXZstatus(address parent) internal {
      if (_mychilders[parent].length >=10 && !_isOrdinaryMedal[parent] && OrdinaryNum <= 800) {
        address[] memory arr = _mychilders[parent];
        uint256 num = 0;
        for(uint256 i = 0; i < arr.length; i++) {
          if (_isCardFromFee[arr[i]]) {
            num = num.add(1);
          }
        }
        if (num >= 10) {
          _isOrdinaryMedal[parent] = true;
          OrdinaryNum = OrdinaryNum.add(1);
        }
      }
      if (_mychilders[parent].length >=50 && !_isSuperMedal[parent] && SuperNum <= 30) {
        address[] memory arr = _mychilders[parent];
        uint256 num = 0;
        for(uint256 i = 0; i < arr.length; i++) {
          if (_isCardFromFee[arr[i]]) {
            num = num.add(1);
          }
        }
        if (num >= 50) {
          _isSuperMedal[parent] = true;
          SuperNum = SuperNum.add(1);
        }
      }
    }

    function deposit() public nonReentrant {
      require(!_isCardFromFee[msg.sender], 'Already involved');
      require(_hasido <= _idoNumber, 'Already involved');
      USDT_TOTLE = USDT_TOTLE.add(PRICE);
      address superior_1 =  _parents[msg.sender];
      uint256 amount = PRICE;
      _isCardFromFee[msg.sender] = true;
      if (superior_1 != address(0) && _isCardFromFee[superior_1]) {
        
        setXZstatus(superior_1);

        IERC20(USDT).transferFrom(msg.sender, superior_1, PRICE.mul(10).div(100));
        amount = amount.sub(PRICE.mul(10).div(100));
        _referralBonuses[superior_1].add(PRICE.mul(10).div(100));

        address superior_2 =  _parents[superior_1];
        if (superior_2 != address(0) && _isCardFromFee[superior_2]) {

          IERC20(USDT).transferFrom(msg.sender, superior_2, PRICE.mul(3).div(100));
          amount = amount.sub(PRICE.mul(3).div(100));
          _referralBonuses[superior_2].add(PRICE.mul(3).div(100));

          address superior_3 =  _parents[superior_2];
          if (superior_3 != address(0) && _isCardFromFee[superior_3]) {

            IERC20(USDT).transferFrom(msg.sender, superior_3, PRICE.mul(2).div(100));
            amount = amount.sub(PRICE.mul(2).div(100));
            _referralBonuses[superior_3].add(PRICE.mul(2).div(100));

          }
        }
      }
      if (NFTBegins) {
        uint256 r = rand(2216,0);
        setNftStatus(r, msg.sender);
      }
      heroToken.setToRobList(msg.sender);
      IERC20(USDT).transferFrom(msg.sender, mk, amount);
      _canCarryAmount[msg.sender] = _canCarryAmount[msg.sender].add(IDOAmount);
      _hasido = _hasido.add(1);
    }

    function setNftStatus(uint256 r, address _address) internal {
      if (r <= 1) {
        if (kingNumber < 10) {
          WZ_NFTToken.IDOSetCardStatus(_address);
          kingNumber = kingNumber.add(1);
          _NFTlevel[_address] = 1;
        } else {
          if (templeNumber < 2000) {
            ST_NFTToken.IDOSetCardStatus(_address);
            templeNumber = templeNumber.add(1);
            _NFTlevel[_address] = 2;
          } else {
            if (warriorNumber < 20150) {
              YS_NFTToken.IDOSetCardStatus(_address);
              warriorNumber = warriorNumber.add(1);
              _NFTlevel[_address] = 3;
            }
          } 
        }
      } else if (r > 1 &&  r < 2016) {
        if (warriorNumber < 20150) {
          YS_NFTToken.IDOSetCardStatus(msg.sender);
          warriorNumber = warriorNumber.add(1);
          _NFTlevel[_address] = 3;
        } else {
          if (templeNumber < 2000) {
            ST_NFTToken.IDOSetCardStatus(msg.sender);
            templeNumber = templeNumber.add(1);
            _NFTlevel[_address] = 2;
          } else {
            if (kingNumber < 10) {
              WZ_NFTToken.IDOSetCardStatus(msg.sender);
              kingNumber = kingNumber.add(1);
              _NFTlevel[_address] = 1;
            }
          }
        }
      } else if (r>=2016) {
        if (templeNumber < 2000) {
          ST_NFTToken.IDOSetCardStatus(msg.sender);
          templeNumber = templeNumber.add(1);
          _NFTlevel[_address] = 2;
        } else {
          if (warriorNumber < 20150) {
            YS_NFTToken.IDOSetCardStatus(msg.sender);
            warriorNumber = warriorNumber.add(1);
            _NFTlevel[_address] = 3;
          } else {
            if (kingNumber < 10) {
              WZ_NFTToken.IDOSetCardStatus(msg.sender);
              kingNumber = kingNumber.add(1);
              _NFTlevel[_address] = 1;
            }
          }
        }
      }
    }

    function rand(uint256 _length,uint256 _nonce) public view returns(uint256) {
      uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp,_nonce)));
      return random%_length+1;
    }

    function getDayByTime(uint256 blockTime) private view returns(uint256) {
        return block.timestamp.sub(blockTime).div(DURATION);
    }

    function canWithdraw(address _address) public view returns(uint256 totalwithdraw) {
      if (_isCardFromFee[_address] && idoToReceive) {
        uint256 rate = 0;
        uint256 record = 0;
        uint256 claimDay = 0;
        if (_userTime[_address] == 0) {
          claimDay = 1;
        } else {
          claimDay = getDayByTime(_userTime[_address]);
        }
        uint256 currentLP = IERC20(poolAddress).balanceOf(_address);
        // LP
        if (currentLP >= LPStandard) {
          if (currentLP >= LPStandard.add(LPStandard.div(2))) {
            rate = rate.add(basisRate.add(basisRate.div(2)));
          } else {
            rate = rate.add(basisRate);
          }
        } else {
          if (currentLP >= LPStandard.div(2)) {
            rate = rate.add(basisRate.div(2));
          } else {
            if (currentLP >= LPStandard.div(4)) {
              rate = rate.add(basisRate.div(4));
            } else {
              rate = rate.add(basisRate.div(10));
            }
          }
        }

        uint256 totleAmount = IDOAmount;

        if (_isSuperMedal[_address]) {
          totleAmount = totleAmount.add(IDOAmount.mul(19));
        } else if (_isOrdinaryMedal[_address]) {
          totleAmount = totleAmount.add(IDOAmount.mul(4));
        }

        if (_canCarryAmount[_address] < totleAmount.mul(claimDay.mul(rate)).div(10000)) {
          record = _canCarryAmount[_address];
        } else {
          record = totleAmount.mul(claimDay.mul(rate)).div(10000);
        }
        totalwithdraw = record;
      } else {
        totalwithdraw = 0;
      }
    }

    function getReward() public nonReentrant {
        require(_canCarryAmount[msg.sender] > 0, 'no amount');

        uint256 amount = canWithdraw(msg.sender);

        require(amount > 0, 'no canWithdraw');

        _canCarryAmount[msg.sender] = _canCarryAmount[msg.sender].sub(amount);
        IERC20(CTTToken).transfer(msg.sender, amount.mul(92).div(100));
        IERC20(CTTToken).transfer(address(0), amount.mul(5).div(100));
        IERC20(CTTToken).transfer(BTCAddress, amount.mul(3).div(100));
        _userTime[msg.sender] = block.timestamp;
    }
    
    function donateDust(address addr, uint256 amount) external onlyOwner {
        TransferHelper.safeTransfer(addr, _msgSender(), amount);
    }

    function donateEthDust(uint256 amount) external onlyOwner {
        TransferHelper.safeTransferETH(_msgSender(), amount);
    }

}