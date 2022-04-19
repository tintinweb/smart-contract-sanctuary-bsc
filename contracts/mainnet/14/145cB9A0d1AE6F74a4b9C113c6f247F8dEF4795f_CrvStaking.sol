/**
 *Submitted for verification at BscScan.com on 2022-04-19
*/

pragma solidity >=0.6.12;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () public {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;
        _status = _NOT_ENTERED;
    }
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

contract CrvStaking is Ownable, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public immutable crvToken;
    IERC721 public immutable nft;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 lastRewardBlock;
        uint256 accCrvPerShare;
    }

    uint256 constant MAX_Crv_SUPPLY = 100000000 ether;
    uint256 constant MAX_Crv_Deposit = 1000 ether;
    uint256 public apr = 20;

    mapping(uint256 => UserInfo) public userInfo;

    constructor(
        IERC20 _crvToken,
        IERC721 _nft
    ) public {
        crvToken = _crvToken;
        nft = _nft;
    }

    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        if(crvToken.totalSupply() >= MAX_Crv_SUPPLY) return 0;
        return _to.sub(_from);
    }

    function getOwnerWithNftID(uint256 _pid) public view returns (address) {
        return nft.ownerOf(_pid);
    }

    function pendingCrv(uint256 _pid) external view returns (uint256) {
        UserInfo storage user = userInfo[_pid];
        uint256 accCrvPerShare = user.accCrvPerShare;

        if (block.number > user.lastRewardBlock && user.amount != 0) {
            uint256 multiplier = getMultiplier(user.lastRewardBlock, block.number);
            accCrvPerShare = user.accCrvPerShare.add(multiplier.mul(1e18).mul(apr).div(100).div(10512000));
        }
        return user.amount.mul(accCrvPerShare).div(1e18).sub(user.rewardDebt);
    }

    function updateUser(uint256 _pid) public {
        UserInfo storage user = userInfo[_pid];
        if (block.number <= user.lastRewardBlock) {
            return;
        }

        if (user.amount == 0) {
            user.lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = getMultiplier(user.lastRewardBlock, block.number);
        user.accCrvPerShare = user.accCrvPerShare.add(multiplier.mul(1e18).mul(apr).div(100).div(10512000));
        user.lastRewardBlock = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount) external nonReentrant {
        require(address(msg.sender) == getOwnerWithNftID(_pid), "you are not owner of nft");
        UserInfo storage user = userInfo[_pid];        
        updateUser(_pid);

        if (user.amount > 0) {
            uint256 pending = user.amount.mul(user.accCrvPerShare).div(1e18).sub(user.rewardDebt);
            if (pending > 0) {
                safeCrvTransfer(getOwnerWithNftID(_pid), pending);        
            }
        }

        if (_amount > 0) {
            uint256 balanceBefore = crvToken.balanceOf(address(this));
            crvToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            _amount = crvToken.balanceOf(address(this)) - balanceBefore;
            require(_amount > 0, "we dont accept deposits of 0 size");
            user.amount = user.amount.add(_amount);
            require(user.amount <= MAX_Crv_Deposit, "you can't deposit bigger amount than maximum amount.");
        }
        user.rewardDebt = user.amount.mul(user.accCrvPerShare).div(1e18);
    }    

    function withdraw(uint256 _pid, uint256 _amount) external nonReentrant {
        require(address(msg.sender) == getOwnerWithNftID(_pid), "you are not owner of nft");
        UserInfo storage user = userInfo[_pid];
        require(user.amount >= _amount, "withdraw: not good");
        updateUser(_pid);
        uint256 pending = user.amount.mul(user.accCrvPerShare).div(1e18).sub(user.rewardDebt);
        if (pending > 0) {
            safeCrvTransfer(getOwnerWithNftID(_pid), pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            crvToken.safeTransfer(getOwnerWithNftID(_pid), _amount);
        }
        user.rewardDebt = user.amount.mul(user.accCrvPerShare).div(1e18);
    }

    function emergencyWithdraw(uint256 _pid) external nonReentrant {
        require(address(msg.sender) == getOwnerWithNftID(_pid), "you are not owner of nft");
        UserInfo storage user = userInfo[_pid];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        crvToken.safeTransfer(getOwnerWithNftID(_pid), amount);
    }

    function safeCrvTransfer(address _to, uint256 _amount) internal {
        uint256 crvBalance = crvToken.balanceOf(address(this));
        bool transferSuccess = false;
        if (_amount > crvBalance) {
            transferSuccess = crvToken.transfer(_to, crvBalance);
        } else {
            transferSuccess = crvToken.transfer(_to, _amount);
        }
        require(transferSuccess, "safeCrvTransfer: Transfer failed");
    }

    function setMultiplier(uint256 _apr) external onlyOwner {
        apr = _apr;
    }

}