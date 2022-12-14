/**
 *Submitted for verification at BscScan.com on 2022-12-14
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.1;


library EnumerableSet {
    struct Set {
        
        bytes32[] _values;
        
        mapping(bytes32 => uint256) _indexes;
    }

    
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
           

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastValue;
               
                set._indexes[lastValue] = valueIndex; 
            }

           
            set._values.pop();

           
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

   
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

   
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

   
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

   

    struct Bytes32Set {
        Set _inner;
    }

    
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

   
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

   

    struct AddressSet {
        Set _inner;
    }

   
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

       
        assembly {
            result := store
        }

        return result;
    }

    

    struct UintSet {
        Set _inner;
    }

  
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

       
        assembly {
            result := store
        }

        return result;
    }
}




pragma solidity ^0.8.1;



contract Context {
    
    constructor() {}

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}


interface IERC165 {
   
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


interface IERC721 is IERC165 {
    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

   
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

   
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    
    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

   
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

  
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

   
    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

  
    function setApprovalForAll(address operator, bool _approved) external;

   
    function isApprovedForAll(address owner, address operator) external view returns (bool);

   
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

   
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

   
    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

 
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

  
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


library SafeMath {
  
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

   
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
       
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

   
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    
    function div(int256 a, int256 b) internal pure returns (int256) {
        
        require(b != -1 || a != MIN_INT256);

        
        return a / b;
    }

   
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

   
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

   
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }


    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}

interface IERC20 {
    
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


library Address {
 
    function isContract(address account) internal view returns (bool) {
        
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, 'Address: low-level call failed');
    }

    
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

   
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
    }

    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

       
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
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

interface IERC721Receiver {
    
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface DividendPayingTokenOptionalInterface {
  
  function withdrawableDividendOf(address _owner) external view returns(uint256);

  
  function withdrawnDividendOf(address _owner) external view returns(uint256);

 
  function accumulativeDividendOf(address _owner) external view returns(uint256);
}

interface DividendPayingTokenInterface {
 
  function dividendOf(address _owner) external view returns(uint256);


  function distributeDividends() external payable;


  function withdrawDividend() external;

  
  event DividendsDistributed(
    address indexed from,
    uint256 weiAmount
  );

  event DividendWithdrawn(
    address indexed to,
    uint256 weiAmount
  );
}

contract DividendPayingToken is DividendPayingTokenInterface, DividendPayingTokenOptionalInterface, Ownable {
  using SafeMath for uint256;
  using SafeMathUint for uint256;
  using SafeMathInt for int256;

  
  uint256 constant internal magnitude = 2**128;

  uint256 internal magnifiedDividendPerShare;
 
  address public immutable token = address(0x55d398326f99059fF775485246999027B3197955);
                                                                                    
 
  mapping(address => int256) internal magnifiedDividendCorrections;
  mapping(address => uint256) internal withdrawnDividends;
  
  mapping (address => uint256) public holderBalance;
  uint256 public totalBalance;

  uint256 public totalDividendsDistributed;
  uint256 public totalDividendsWaitingToSend;

 
  receive() external payable {
    distributeDividends();
  }

 
    
  function distributeDividends() public override payable {
    require(false, "Cannot send BNB directly to tracker as it is unrecoverable"); // 
  }
  
  function distributeTokenDividends() external onlyOwner {
    if(totalBalance > 0){

        uint256 tokensToAdd;
        uint256 balance = IERC20(token).balanceOf(address(this));

        if(totalDividendsWaitingToSend < balance){
            tokensToAdd = balance - totalDividendsWaitingToSend;
        } else {
            tokensToAdd = 0;
        }

        if (tokensToAdd > 0) {
        magnifiedDividendPerShare = magnifiedDividendPerShare.add(
            (tokensToAdd).mul(magnitude) / totalBalance
        );
        emit DividendsDistributed(msg.sender, tokensToAdd);

        totalDividendsDistributed = totalDividendsDistributed.add(tokensToAdd);
        totalDividendsWaitingToSend = totalDividendsWaitingToSend.add(tokensToAdd);
        }
    }
  }

 
  function withdrawDividend() external virtual override {
    _withdrawDividendOfUser(payable(msg.sender));
  }

  
  function _withdrawDividendOfUser(address payable user) internal returns (uint256) {
    uint256 _withdrawableDividend = withdrawableDividendOf(user);
    if (_withdrawableDividend > 0) {
      withdrawnDividends[user] = withdrawnDividends[user].add(_withdrawableDividend);
      if(totalDividendsWaitingToSend >= _withdrawableDividend){
        totalDividendsWaitingToSend -= _withdrawableDividend;
      }
      else {
        totalDividendsWaitingToSend = 0;  
      }
      emit DividendWithdrawn(user, _withdrawableDividend);
      bool success = IERC20(token).transfer(user, _withdrawableDividend);

      if(!success) {
        withdrawnDividends[user] = withdrawnDividends[user].sub(_withdrawableDividend);
        return 0;
      }

      return _withdrawableDividend;
    }

    return 0;
  }



  function dividendOf(address _owner) external view override returns(uint256) {
    return withdrawableDividendOf(_owner);
  }


  function withdrawableDividendOf(address _owner) public view override returns(uint256) {
    return accumulativeDividendOf(_owner).sub(withdrawnDividends[_owner]);
  }

 
  function withdrawnDividendOf(address _owner) external view override returns(uint256) {
    return withdrawnDividends[_owner];
  }



  function accumulativeDividendOf(address _owner) public view override returns(uint256) {
    return magnifiedDividendPerShare.mul(holderBalance[_owner]).toInt256Safe()
      .add(magnifiedDividendCorrections[_owner]).toUint256Safe() / magnitude;
  }


  function _increase(address account, uint256 value) internal {
    magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account]
      .sub( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );
  }


  function _reduce(address account, uint256 value) internal {
    magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account]
      .add( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );
  }

  function _setBalance(address account, uint256 newBalance) internal {
    uint256 currentBalance = holderBalance[account];
    holderBalance[account] = newBalance;
    if(newBalance > currentBalance) {
      uint256 increaseAmount = newBalance.sub(currentBalance);
      _increase(account, increaseAmount);
      totalBalance += increaseAmount;
    } else if(newBalance < currentBalance) {
      uint256 reduceAmount = currentBalance.sub(newBalance);
      _reduce(account, reduceAmount);
      totalBalance -= reduceAmount;
    }
  }
}


contract DividendTracker is DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    struct Map {
        address[] keys;
        mapping(address => uint) values;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;
    }

    function get(address key) private view returns (uint) {
        return tokenHoldersMap.values[key];
    }

    function getIndexOfKey(address key) private view returns (int) {
        if(!tokenHoldersMap.inserted[key]) {
            return -1;
        }
        return int(tokenHoldersMap.indexOf[key]);
    }

    function getKeyAtIndex(uint index) private view returns (address) {
        return tokenHoldersMap.keys[index];
    }



    function size() private view returns (uint) {
        return tokenHoldersMap.keys.length;
    }

    function set(address key, uint val) private {
        if (tokenHoldersMap.inserted[key]) {
            tokenHoldersMap.values[key] = val;
        } else {
            tokenHoldersMap.inserted[key] = true;
            tokenHoldersMap.values[key] = val;
            tokenHoldersMap.indexOf[key] = tokenHoldersMap.keys.length;
            tokenHoldersMap.keys.push(key);
        }
    }

    function remove(address key) private {
        if (!tokenHoldersMap.inserted[key]) {
            return;
        }

        delete tokenHoldersMap.inserted[key];
        delete tokenHoldersMap.values[key];

        uint index = tokenHoldersMap.indexOf[key];
        uint lastIndex = tokenHoldersMap.keys.length - 1;
        address lastKey = tokenHoldersMap.keys[lastIndex];

        tokenHoldersMap.indexOf[lastKey] = index;
        delete tokenHoldersMap.indexOf[key];

        tokenHoldersMap.keys[index] = lastKey;
        tokenHoldersMap.keys.pop();
    }

    Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping (address => bool) public excludedFromDividends;

    mapping (address => uint256) public lastClaimTimes;

    uint256 public claimWait;
    uint256 public immutable minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account);
    event IncludeInDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor() {
    	claimWait = 1;
        minimumTokenBalanceForDividends = 1 * (10**18); //must hold 10,000+ tokens
    }

    function excludeFromDividends(address account) external onlyOwner {
    	excludedFromDividends[account] = true;

    	_setBalance(account, 0);
    	remove(account);

    	emit ExcludeFromDividends(account);
    }
    
    function includeInDividends(address account) external onlyOwner {
    	require(excludedFromDividends[account]);
    	excludedFromDividends[account] = false;

    	emit IncludeInDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 1200 && newClaimWait <= 86400, "Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "Dividend_Tracker: Cannot update claimWait to same value");
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }

    function getLastProcessedIndex() external view returns(uint256) {
    	return lastProcessedIndex;
    }

    function getNumberOfTokenHolders() external view returns(uint256) {
        return tokenHoldersMap.keys.length;
    }

   

    function getAccount(address _account)
        public view returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            uint256 secondsUntilAutoClaimAvailable) {
        account = _account;

        index = getIndexOfKey(account);

        iterationsUntilProcessed = -1;

        if(index >= 0) {
            if(uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(int256(lastProcessedIndex));
            }
            else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length > lastProcessedIndex ?
                                                        tokenHoldersMap.keys.length.sub(lastProcessedIndex) :
                                                        0;


                iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
            }
        }


        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);

        lastClaimTime = lastClaimTimes[account];

        nextClaimTime = lastClaimTime > 0 ?
                                    lastClaimTime.add(claimWait) :
                                    0;

        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ?
                                                    nextClaimTime.sub(block.timestamp) :
                                                    0;
    }

    function getAccountAtIndex(uint256 index)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
    	if(index >= size()) {
            return (0x0000000000000000000000000000000000000000, -1, -1, 0, 0, 0, 0, 0);
        }

        address account = getKeyAtIndex(index);

        return getAccount(account);
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
    	if(lastClaimTime > block.timestamp)  {
    		return false;
    	}

    	return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    function setBalance(address payable account, uint256 newBalance) external onlyOwner {
    	if(excludedFromDividends[account]) {
    		return;
    	}

    	if(newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
    		set(account, newBalance);
    	}
    	else {
            _setBalance(account, 0);
    		remove(account);
    	}

    	processAccount(account, true);
    }
    
    
    function process(uint256 gas) external returns (uint256, uint256, uint256) {
    	uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;

    	if(numberOfTokenHolders == 0) {
    		return (0, 0, lastProcessedIndex);
    	}

    	uint256 _lastProcessedIndex = lastProcessedIndex;

    	uint256 gasUsed = 0;

    	uint256 gasLeft = gasleft();

    	uint256 iterations = 0;
    	uint256 claims = 0;

    	while(gasUsed < gas && iterations < numberOfTokenHolders) {
    		_lastProcessedIndex++;

    		if(_lastProcessedIndex >= tokenHoldersMap.keys.length) {
    			_lastProcessedIndex = 0;
    		}

    		address account = tokenHoldersMap.keys[_lastProcessedIndex];

    		if(canAutoClaim(lastClaimTimes[account])) {
    			if(processAccount(payable(account), true)) {
    				claims++;
    			}
    		}

    		iterations++;

    		uint256 newGasLeft = gasleft();

    		if(gasLeft > newGasLeft) {
    			gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
    		}
    		gasLeft = newGasLeft;
    	}

    	lastProcessedIndex = _lastProcessedIndex;

    	return (iterations, claims, lastProcessedIndex);
    }

    function processAccount(address payable account, bool automatic) public onlyOwner returns (bool) {
        uint256 amount = _withdrawDividendOfUser(account);

    	if(amount > 0) {
    		lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
    		return true;
    	}

    	return false;
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
       
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

       
        _status = _ENTERED;

        _;

     
        _status = _NOT_ENTERED;
    }
}

contract GRINCHELONSTAKING is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.UintSet;

    DividendTracker public dividendTracker;

    IERC20 public immutable REWARDTOKEN = IERC20(0xC52d731EaD9fbE213037d6D0E9126B44Dc995cb7);

   
   struct UserInfo {
        uint256 amount;     
        uint256 multipliedAmount;
        uint256 rewardDebt; 
    }

    
    struct PoolInfo {
        IERC20 lpToken;         
        uint256 allocPoint;       
        uint256 lastRewardTimestamp;  
        uint256 accTokensPerShare; 
    }

    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardToken;
    mapping (address => uint256) public holderUnlockTime;

    mapping (address => uint256) public holderNftsStakedAmount;

    mapping (address => mapping (address => EnumerableSet.UintSet)) private holderNftsStaked;

    mapping (address => bool) public isValidNftToStake;

    uint256 public totalStaked;
    uint256 public totalStakedMultiplied;
    uint256 public rewardsPerSecond;
    uint256 public lockDuration;
    uint256 public exitPenaltyPerc;

   
    PoolInfo[] public poolInfo;
    
    mapping (address => UserInfo) public userInfo;
   
    uint256 private totalAllocPoint = 0;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event StakedNFT(address indexed nftAddress, uint256 indexed tokenId, address indexed sender);
    event UnstakedNFT(address indexed nftAddress, uint256 indexed tokenId, address indexed sender);

    constructor(
    ) {
        stakingToken = IERC20(0xC52d731EaD9fbE213037d6D0E9126B44Dc995cb7);
        rewardToken = IERC20(0xC52d731EaD9fbE213037d6D0E9126B44Dc995cb7);

        dividendTracker = new DividendTracker();

        rewardsPerSecond = 0.058 * 1e18;
        lockDuration = 0;
        exitPenaltyPerc = 0;

        // staking pool
        poolInfo.push(PoolInfo({
            lpToken: stakingToken,
            allocPoint: 1000,
            lastRewardTimestamp: 99999999999,
            accTokensPerShare: 0
        }));

        totalAllocPoint = 1000;
    }

    function getHolderNfts(address nftAddress, address wallet) external view returns (uint256[] memory){
        return holderNftsStaked[wallet][nftAddress].values();
    }

    function stopReward() external onlyOwner {
        updatePool(0);
        rewardsPerSecond = 0;
    }

    function updateNftToStake(address nftAddress, bool enabledToStake) external onlyOwner {
        isValidNftToStake[nftAddress] = enabledToStake;
    }

    function startReward() external onlyOwner {
        require(poolInfo[0].lastRewardTimestamp == 99999999999, "Can only start rewards once");
        poolInfo[0].lastRewardTimestamp = block.timestamp;
    }

    function stakeNft(address nftAddress, uint256 tokenId) external nonReentrant {
        require(isValidNftToStake[nftAddress], "NFT address not valid to stake");
        require(holderNftsStaked[msg.sender][nftAddress].length() < 3, "Cannot stake more than 3 of the same NFT");
        
        IERC721 nft = IERC721(nftAddress);
        
        UserInfo storage user = userInfo[msg.sender];
        PoolInfo storage pool = poolInfo[0];

        require(nft.getApproved(tokenId) == address(this), "Must approve token to be sent");

        updatePool(0);

        if (user.amount > 0) {
            uint256 pending = user.multipliedAmount.mul(pool.accTokensPerShare).div(1e12).sub(user.rewardDebt);
            if(pending >= rewardsRemaining()){
                pending = rewardsRemaining();
            }
            if(pending > 0) {
                rewardToken.transfer(address(msg.sender), pending);
            }
        }

        nft.transferFrom(msg.sender, address(this), tokenId);
        holderNftsStakedAmount[msg.sender] += 1;
        holderNftsStaked[msg.sender][nftAddress].add(tokenId);

        totalStakedMultiplied -= user.multipliedAmount;
        user.multipliedAmount = user.amount * getStakingMultiplier(msg.sender) / 100;
        totalStakedMultiplied += user.multipliedAmount;

        user.rewardDebt = user.multipliedAmount.mul(pool.accTokensPerShare).div(1e12);

        emit StakedNFT(nftAddress, tokenId, msg.sender);
    }

    function unstakeNft(address nftAddress, uint256 tokenId) external nonReentrant {
        require(holderNftsStaked[msg.sender][nftAddress].contains(tokenId), "Can only unstake a tokenID allocated from this NFT address for the sender");
        
        IERC721 nft = IERC721(nftAddress);

        UserInfo storage user = userInfo[msg.sender];
        PoolInfo storage pool = poolInfo[0];

        updatePool(0);

        if (user.amount > 0) {
            uint256 pending = user.multipliedAmount.mul(pool.accTokensPerShare).div(1e12).sub(user.rewardDebt);
            if(pending >= rewardsRemaining()){
                pending = rewardsRemaining();
            }
            if(pending > 0) {
                rewardToken.transfer(address(msg.sender), pending);
            }
        }

        nft.transferFrom(address(this), msg.sender, tokenId);
        holderNftsStakedAmount[msg.sender] -= 1;
        holderNftsStaked[msg.sender][nftAddress].remove(tokenId);

        totalStakedMultiplied -= user.multipliedAmount;
        user.multipliedAmount = user.amount * getStakingMultiplier(msg.sender) / 100;
        totalStakedMultiplied += user.multipliedAmount;

        user.rewardDebt = user.multipliedAmount.mul(pool.accTokensPerShare).div(1e12);

        emit UnstakedNFT(nftAddress, tokenId, msg.sender);
    }

    
    function getStakingMultiplier(address holder) public view returns (uint256) {
        if(holderNftsStakedAmount[holder] == 0){
            return 100;
        }
       
        return 100 + (holderNftsStakedAmount[holder]*30);
    }

   
    function pendingReward(address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[_user];
        if(pool.lastRewardTimestamp == 99999999999){
            return 0;
        }
        uint256 accTokensPerShare = pool.accTokensPerShare;
        uint256 lpSupply = totalStakedMultiplied;
        if (block.timestamp > pool.lastRewardTimestamp && lpSupply != 0) {
            uint256 tokenReward = calculateNewRewards().mul(pool.allocPoint).div(totalAllocPoint);
            accTokensPerShare = accTokensPerShare.add(tokenReward.mul(1e12).div(lpSupply));
        }
        return user.multipliedAmount.mul(accTokensPerShare).div(1e12).sub(user.rewardDebt);
    }

   
    function updatePool(uint256 _pid) internal {
     
        if(REWARDTOKEN.balanceOf(address(this)) > 0){
            REWARDTOKEN.transfer(address(dividendTracker), REWARDTOKEN.balanceOf(address(this)));
        }
    
        dividendTracker.distributeTokenDividends();
        PoolInfo storage pool = poolInfo[_pid];
        if (block.timestamp <= pool.lastRewardTimestamp) {
            return;
        }
        uint256 lpSupply = totalStakedMultiplied;
        if (lpSupply == 0) {
            pool.lastRewardTimestamp = block.timestamp;
            return;
        }
        uint256 tokenReward = calculateNewRewards().mul(pool.allocPoint).div(totalAllocPoint);
        pool.accTokensPerShare = pool.accTokensPerShare.add(tokenReward.mul(1e12).div(lpSupply));
        pool.lastRewardTimestamp = block.timestamp;
    }

   
    function massUpdatePools() public onlyOwner {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

   
    function deposit(uint256 _amount) public nonReentrant {
        if(holderUnlockTime[msg.sender] == 0){
            holderUnlockTime[msg.sender] = block.timestamp + lockDuration;
        }
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[msg.sender];

        updatePool(0);
        if (user.amount > 0) {
            uint256 pending = user.multipliedAmount.mul(pool.accTokensPerShare).div(1e12).sub(user.rewardDebt);
            if(pending >= rewardsRemaining()){
                pending = rewardsRemaining();
            }
            if(pending > 0) {
                rewardToken.transfer(address(msg.sender), pending);
            }
        }
        uint256 amountTransferred = 0;
        if(_amount > 0) {
            uint256 initialBalance = pool.lpToken.balanceOf(address(this));
            pool.lpToken.transferFrom(address(msg.sender), address(this), _amount);
            amountTransferred = pool.lpToken.balanceOf(address(this)) - initialBalance;
            totalStakedMultiplied -= user.multipliedAmount;
            user.amount = user.amount.add(amountTransferred);
            user.multipliedAmount = user.amount * getStakingMultiplier(msg.sender) / 100;
            totalStaked += amountTransferred;
            totalStakedMultiplied += user.multipliedAmount;
        }

        dividendTracker.setBalance(payable(msg.sender), user.amount);
        user.rewardDebt = user.multipliedAmount.mul(pool.accTokensPerShare).div(1e12);

        emit Deposit(msg.sender, _amount);
    }

    

    function withdraw(uint256 _amount) public nonReentrant {

        require(holderUnlockTime[msg.sender] <= block.timestamp, "May not do normal withdraw early");
        
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[msg.sender];

        updatePool(0);
        uint256 pending = user.multipliedAmount.mul(pool.accTokensPerShare).div(1e12).sub(user.rewardDebt);
        if(pending >= rewardsRemaining()){
            pending = rewardsRemaining();
        }
        if(pending > 0) {
            rewardToken.transfer(payable(address(msg.sender)), pending);
        }

        if(_amount > 0) {
            user.amount -= _amount;
            user.multipliedAmount = user.amount * getStakingMultiplier(msg.sender) / 100;
            totalStaked -= _amount;
            totalStakedMultiplied -= _amount * getStakingMultiplier(msg.sender) / 100;
            pool.lpToken.transfer(address(msg.sender), _amount);
        }

        dividendTracker.setBalance(payable(msg.sender), user.amount);
        user.rewardDebt = user.multipliedAmount.mul(pool.accTokensPerShare).div(1e12);
        
        if(user.amount > 0){
            holderUnlockTime[msg.sender] = block.timestamp + lockDuration;
        } else {
            holderUnlockTime[msg.sender] = 0;
        }

        emit Withdraw(msg.sender, _amount);
    }

    
    function emergencyWithdraw() external nonReentrant {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[msg.sender];
        uint256 _amount = user.amount;
        totalStaked -= _amount;
        totalStakedMultiplied -= user.multipliedAmount;
        
        if(holderUnlockTime[msg.sender] >= block.timestamp){
            _amount -= _amount * exitPenaltyPerc / 100;
        }
        holderUnlockTime[msg.sender] = 0;
        pool.lpToken.transfer(address(msg.sender), _amount);
        user.amount = 0;
        user.multipliedAmount = 0;
        user.rewardDebt = 0;
        dividendTracker.setBalance(payable(msg.sender), 0);
        emit EmergencyWithdraw(msg.sender, _amount);
    }

 
    function emergencyRewardWithdraw(uint256 _amount) external onlyOwner {
        require(_amount <= rewardsRemaining(), 'not enough tokens to take out');
        rewardToken.transfer(address(msg.sender), _amount);
    }

    function calculateNewRewards() public view returns (uint256) {
        PoolInfo storage pool = poolInfo[0];
        if(pool.lastRewardTimestamp > block.timestamp){
            return 0;
        }
        return ((block.timestamp - pool.lastRewardTimestamp) * rewardsPerSecond);
    }

    function rewardsRemaining() public view returns (uint256){
        return rewardToken.balanceOf(address(this)) - totalStaked;
    }

    function updateRewardsPerSecond(uint256 newRewardsPerSecond) external onlyOwner {
        require(rewardsPerSecond <= 1, "Rewards per second must be below 1");
        updatePool(0);
        rewardsPerSecond = newRewardsPerSecond * 1e18;
    }

    function updateExitPenalty(uint256 newPenaltyPerc) external onlyOwner {
        require(newPenaltyPerc <= 20, "May not set higher than 20%");
        exitPenaltyPerc = newPenaltyPerc;
    }

    function claim() external nonReentrant {
        dividendTracker.processAccount(payable(msg.sender), false);
    }
}