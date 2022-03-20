/**
 *Submitted for verification at BscScan.com on 2022-03-20
*/

// SPDX-License-Identifier: SimPL-2.0
pragma solidity 0.6.12;

/**
***
***
***  
***  
*** 
***  ██╗  ██╗██╗  ██╗ █████╗  ██████╗ ███████╗████████╗███████╗ █████╗ ███╗   ███╗
***  ██║ ██╔╝██║  ██║██╔══██╗██╔═══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗████╗ ████║
***  █████╔╝ ███████║███████║██║   ██║███████╗   ██║   █████╗  ███████║██╔████╔██║
***  ██╔═██╗ ██╔══██║██╔══██║██║   ██║╚════██║   ██║   ██╔══╝  ██╔══██║██║╚██╔╝██║
***  ██║  ██╗██║  ██║██║  ██║╚██████╔╝███████║██╗██║   ███████╗██║  ██║██║ ╚═╝ ██║
***  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝
***                                                                               
***  
*** 
*** 
***   website:  https://khaos.finance
*** 
*/

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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

library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
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
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

contract Ownable is Context {
    
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () public {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function waiveOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }
    
    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
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

    constructor() public {
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

    modifier isHuman() {
        require(tx.origin == msg.sender, "sorry humans only");
        _;
    }
}


contract KHAOS_Team is Context, Ownable, ReentrancyGuard {
    
    using SafeMath for uint256;
    using Address for address;

    address public _tokenAddress;

    address[] public _members;
    mapping (address => uint256) public _bonusAmounts;
    
    //0.01%
    uint256 public _minProcessAmount = 100 * 10**9 * 10**9;
    
    event Bonus(uint256 total, uint256 count);

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    constructor(address tokenAddress) public {
       _tokenAddress = tokenAddress;
    }

    function doBonus() public nonReentrant {
        uint256 balance = IERC20(_tokenAddress).balanceOf(address(this));
        require(balance >= _minProcessAmount, "Less than the minimum processing quantity");
        require(_members.length > 0, "At least 1 member is required");
        
        uint256 payTotal = 0;
        uint256 payCount = 0;
        
        uint256 payAmount = balance.div(_members.length);
        for(uint256 i=0; i<_members.length; i++) {
            bool result = IERC20(_tokenAddress).transfer(_members[i], payAmount);
            if(result) {
                payTotal = payTotal.add(payAmount);
                _bonusAmounts[_members[i]] = _bonusAmounts[_members[i]].add(payAmount);
                payCount++;
            }
        }
        
        emit Bonus(payTotal, payCount);
    }
    
    function setTokenAddress(address tokenAddress) public onlyOwner {
        _tokenAddress = tokenAddress;
    }
    
    function setMinProcessAmount(uint256 amount) public onlyOwner {
        _minProcessAmount = amount;
    }

    function addMember(address member) public onlyOwner {
        bool isFound = false;
        for(uint256 i=0; i<_members.length; i++) {
            if(_members[i] == member) {
                isFound = true;
                break;
            }
        }
        if(!isFound) {
            _members.push(member);
        }
    }
    
    function addBatchMembers(address[] memory targets) public onlyOwner {
        require(targets.length > 0, "Target length error");
        for(uint256 i=0; i<targets.length; i++) {
            addMember(targets[i]);
        }
    }

    function removeMember(address member) public onlyOwner{
        for(uint256 i=0; i<_members.length; i++) {
            if(_members[i] == member) {
                _members[i] = _members[_members.length - 1];
                _members.pop();
                break;
            }
        }
    }
    
    function removeBatchMembers(address[] memory targets) public onlyOwner {
        require(targets.length > 0, "Target length error");
        for(uint256 i=0; i<targets.length; i++) {
            removeMember(targets[i]);
        }
    }
    
    function getMemberLen() view public returns(uint256) {
        return _members.length;
    }
    
    function isMember(address target) view public returns(bool) {
        for(uint256 i=0; i<_members.length; i++) {
            if(_members[i] == target) {
                return true;
            }
        }
        return false;
    }

}