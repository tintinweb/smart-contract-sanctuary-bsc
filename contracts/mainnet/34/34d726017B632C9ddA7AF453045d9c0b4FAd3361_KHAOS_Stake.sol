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
***  ██╗  ██╗██╗  ██╗ █████╗  ██████╗ ███████╗   ███████╗████████╗ █████╗ ██╗  ██╗███████╗
***  ██║ ██╔╝██║  ██║██╔══██╗██╔═══██╗██╔════╝   ██╔════╝╚══██╔══╝██╔══██╗██║ ██╔╝██╔════╝
***  █████╔╝ ███████║███████║██║   ██║███████╗   ███████╗   ██║   ███████║█████╔╝ █████╗  
***  ██╔═██╗ ██╔══██║██╔══██║██║   ██║╚════██║   ╚════██║   ██║   ██╔══██║██╔═██╗ ██╔══╝  
***  ██║  ██╗██║  ██║██║  ██║╚██████╔╝███████║██╗███████║   ██║   ██║  ██║██║  ██╗███████╗
***  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝
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



contract KHAOS_Stake is Context, Ownable, ReentrancyGuard {
    
    using SafeMath for uint256;
    using Address for address;
    
    address public _tokenAddress;
    address public _pairAddress;

    uint256 public _stakeTotal;
    uint256 public _tempStakeTotal;
    uint256 public _dividentsTotal;
    
    address[] public _stakeMembers;
    address[] public _tempStakeMembers;

    mapping (address => uint256) public _stakeAmounts;
    mapping (address => uint256) public _tempStakeAmounts;
    
    mapping (address => uint256) public _bounsAmounts;

    uint256 public _lastTotalAmount;
    uint256 public _lastDividendsAmount;
    uint256 public _lastProcessedIndex;
    
    bool public _isAuto;
    
    //0.01%
    uint256 public _minAutoAmount = 100 * 10**9 * 10**9;
    
    uint256 public _minValidAmount = 10 ** 18;
    
    bool private _lockFlag;
   
    event StakeLPEvent(address sender, uint256 lpAmount);
    event UnstakeLPEvent(address sender, uint256 lpAmount);
    event Dividends(uint256 processCount, uint256 currIndex, uint256 totalCount);
    
    modifier lockDividend {
        _lockFlag = true;
        _;
        _lockFlag = false;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    constructor(address tokenAddress, address pairAddress) public {
        _tokenAddress = tokenAddress;
        _pairAddress = pairAddress;
        _isAuto = true;
        _lockFlag = false;
    }

    function deskboard() view public isHuman returns(uint256 lpTotal, uint256 stakeNumber,uint256 dividendsTotal, uint256 pooledBNB, uint256 pooledToken) {
        dividendsTotal = _dividentsTotal;
        lpTotal = _stakeTotal;
        stakeNumber = _stakeMembers.length;
        pooledBNB = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c).balanceOf(_pairAddress);
        pooledToken = IERC20(_tokenAddress).balanceOf(_pairAddress);
    }
    
    function getMyInfo(address sender) view public isHuman returns(uint256 stakeLP, uint256 holdLP, uint256 bonusTotal) {
        stakeLP = _stakeAmounts[sender];
        bonusTotal = _bounsAmounts[sender];
        holdLP = IERC20(_pairAddress).balanceOf(sender);
    }

    function getList() view public isHuman returns(address[] memory members, uint256[] memory amounts, uint256[] memory percents) {
        uint256 max = 1000;
        if(_stakeMembers.length < max) {
            max = _stakeMembers.length;
        }
        
        members = new address[](max);
        amounts = new uint256[](max);
        percents = new uint256[](max);
        for(uint256 i=0; i<max; i++) {
            members[i] = _stakeMembers[i];
            amounts[i] = _stakeAmounts[members[i]];
            percents[i] = (amounts[i] * (10 ** 18)).div(_stakeTotal);
        }
    }

    function stakeLP(uint256 lpAmount) public isHuman nonReentrant {
        uint256 balance = IERC20(_pairAddress).balanceOf(_msgSender());
        if(lpAmount == 0) {
            lpAmount = balance;
        }
        require(lpAmount > 0, "State:LP amount error");
        require(lpAmount <= balance, "State:LP insufficient funds");
        
        uint256 allowAmount = IERC20(_pairAddress).allowance(_msgSender(), address(this));
        require(allowAmount >= lpAmount, "State:LP approve error");
    
        bool result = IERC20(_pairAddress).transferFrom(_msgSender(), address(this), lpAmount);
        require(result, "State:LP transfer error");
        
        _stakeAmounts[_msgSender()] = _stakeAmounts[_msgSender()].add(lpAmount);
        _stakeTotal = _stakeTotal.add(lpAmount);

        _addMember(_msgSender());
        
        emit StakeLPEvent(_msgSender(), lpAmount);
    }

    function unstakeLP(uint256 lpAmount) public isHuman nonReentrant {
        uint256 currAmount = _stakeAmounts[_msgSender()];
        if(lpAmount == 0) {
            lpAmount = currAmount;
        }
        require(currAmount != 0, "State:you have no pledge");
        require(lpAmount <= currAmount, "State:LP insufficient funds");

        _stakeTotal = _stakeTotal.sub(lpAmount);
        _stakeAmounts[_msgSender()] = _stakeAmounts[_msgSender()].sub(lpAmount);

        bool result = IERC20(_pairAddress).transfer(_msgSender(), lpAmount);
        require(result, "State:LP transfer error");

        if(_stakeAmounts[_msgSender()] == 0 || _stakeAmounts[_msgSender()] < _minValidAmount) {
            _removeMember(_msgSender());
        }
        
        emit UnstakeLPEvent(_msgSender(), lpAmount);
    }

    function processDividend() public {
        if(!_isAuto) {
            return;
        }
        if(_stakeTotal == 0 || _stakeMembers.length == 0) {
            return;
        }
        if(!_lockFlag) {
            if(_lastDividendsAmount == 0) {
                _dividendsInit();
            } else if(_lastDividendsAmount > 0) {
                _dividentsNext(0);
            }
        }
    }
    
    function processDividendManual() public onlyOwner {
        if(_stakeTotal == 0 || _stakeMembers.length == 0) {
            return;
        }
        if(_lastDividendsAmount == 0) {
            _dividendsInit();
        } else if(_lastDividendsAmount > 0) {
            _dividentsNext(0);
        }
    }
    
    function _dividendsInit() lockDividend private {
        if(_lastDividendsAmount > 0) {
            return;
        }
        uint256 balance = IERC20(_tokenAddress).balanceOf(address(this));
        if(balance == 0) {
            return;
        }
        if(balance < _minAutoAmount) {
            return;
        }
        _lastDividendsAmount = balance;
        _lastProcessedIndex = 0;
        _lastTotalAmount = _lastDividendsAmount;
        _tempStakeTotal = _stakeTotal;
        _tempStakeMembers = new address[](_stakeMembers.length);
        for(uint256 i=0; i<_stakeMembers.length; i++) {
            address target = _stakeMembers[i];
            _tempStakeMembers[i] = target;
            _tempStakeAmounts[target] = _stakeAmounts[target];
        }
    }
    
    function _dividentsNext(uint256 gas) lockDividend private  {
        
        uint256 tokenBalance = IERC20(_tokenAddress).balanceOf(address(this));
        if(tokenBalance < _lastDividendsAmount) {
            return;
        }
        if(gas == 0) {
            //use by default 300,000 gas to process auto-claiming dividends
            gas = 300000;
        }
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 processCount = 0;
        
        uint256 currIndex = _lastProcessedIndex;

        while (gasUsed < gas && _lastDividendsAmount > 0) {
            address account = _tempStakeMembers[currIndex];
            uint256 percent = (_tempStakeAmounts[account] * (10 ** 18)).div(_tempStakeTotal);
            uint256 payAmount = _lastTotalAmount.mul(percent).div(10 ** 18);
            _lastDividendsAmount = _lastDividendsAmount.sub(payAmount);
            bool result = IERC20(_tokenAddress).transfer(account, payAmount);
            if(result) {
                _dividentsTotal = _dividentsTotal.add(payAmount);
                _bounsAmounts[account] = _bounsAmounts[account].add(payAmount);
            }
            processCount++;

            uint256 newGasLeft = gasleft();
            if (gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }
            gasLeft = newGasLeft;
            
            currIndex++;
            if (currIndex >= _tempStakeMembers.length) {
                _lastDividendsAmount = 0;
                break;
            }
        }
        _lastProcessedIndex = currIndex;
        if(_lastDividendsAmount == 0) {
            _dividentsDone();
        }
        
        emit Dividends(processCount, _lastProcessedIndex, _tempStakeMembers.length);
    }
    
    function _dividentsDone() private {
        for(uint256 i=0; i<_tempStakeMembers.length; i++) {
            delete _tempStakeAmounts[_tempStakeMembers[i]];
        }
        delete _tempStakeMembers;
    }
    
    function setTokenAddress(address tokenAddress) public onlyOwner {
        _tokenAddress = tokenAddress;
    }
    function setPairAddress(address pairAddress) public onlyOwner {
        _pairAddress = pairAddress;
    }
    function setAuto(bool flag) public onlyOwner {
        _isAuto = flag;
    }
    function setMinAutoAmount(uint256 amount) public onlyOwner {
        _minAutoAmount = amount;
    }

    function _addMember(address member) private {
        bool isFound = false;
        for(uint256 i=0; i<_stakeMembers.length; i++) {
            if(_stakeMembers[i] == member) {
                isFound = true;
                break;
            }
        }
        if(!isFound) {
            _stakeMembers.push(member);
        }
    }

    function _removeMember(address member) private {
        for(uint256 i=0; i<_stakeMembers.length; i++) {
            if(_stakeMembers[i] == member) {
                _stakeMembers[i]=_stakeMembers[_stakeMembers.length-1];
                _stakeMembers.pop();
                break;
            }
        }
    }
}