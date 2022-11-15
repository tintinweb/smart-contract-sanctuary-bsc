/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
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

library TransferHelper {

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



contract Deposit {
   using SafeMath for uint256;
  struct DepositSlip {
    uint256 deposit_type;
    uint256 createTime;
    uint256 expireTime;
    uint256 amount1;
    uint256 amount2;
    uint256 index;
    uint256 id;
    address token1;
    address token2;
  }
  mapping(uint256=>uint256) public depositTypes;

  event Mint(uint256 index,address user, address token1,address token2, uint256 amount1,uint256 amount2);
  event Burn(uint256 index,address user, address token1,address token2, uint256  amount1,uint256 amount2);
  
  mapping (address =>DepositSlip[]) public userDeposits;
  mapping (address=>mapping(address=>uint256)) private _depositList;
  address public receiveAddr;
  address public withdrawAddr;
  address public _executor;

  bool private _locking;
  modifier Locked{
     require(!_locking,"locked");
     _locking = true;
     _;
     _locking = false;
  }


  modifier onlyExecutor{
    require(msg.sender==_executor,"denied");
     _;
  }
  modifier onlyReceive{
      require(msg.sender==receiveAddr,"error");
      _;
  }
  constructor(address _receive_addr,address _withdraw_addr){
       withdrawAddr = _withdraw_addr;
       receiveAddr = _receive_addr;
       _executor = msg.sender;
       depositTypes[1] = 0;
       depositTypes[2] = 30;
       depositTypes[3] = 90;
       depositTypes[4] = 180;
       depositTypes[5] = 365;
       depositTypes[6] = 365*2; 
  }
  function setNewReceive(address new_address) public onlyReceive{
      receiveAddr = new_address;
  }
  
  function setNewWithdraw(address new_withdraw) public onlyReceive {
      withdrawAddr = new_withdraw;
  }
  function setNewExcutor(address new_executor) public onlyReceive{
      _executor = new_executor;
  }
  
 
  function setDepositAll(uint256 deposittype, address _token1,address _token2,address[] memory user_list,uint256[] memory value1_list,uint256[] memory value2_list) public onlyExecutor{
       require(_token1 != _token2,"token error");
       require(value1_list.length == value2_list.length ," value error");
       require(user_list.length == value1_list.length,"length error");
       require(value1_list.length<1000,"array error");
       for(uint256 index = 0 ;index<value1_list.length;index++){
           _mint(user_list[index],deposittype,_token1,_token2,value1_list[index],value2_list[index]);
       }
  }
  function mint(uint256 deposit_type,address _token1,address _token2, uint _value1,uint _value2) public payable returns (uint) {
      require(_token1!=_token2,"token error");
      address user = msg.sender;
      uint256 before_token1 = IERC20(_token1).balanceOf(receiveAddr);
      TransferHelper.safeTransferFrom(_token1,user,receiveAddr,_value1);
      uint256 after_token1 =  IERC20(_token1).balanceOf(receiveAddr);

      if(_token2 == address(0)){
        require(msg.value >= _value2,"num error");
       TransferHelper.safeTransferETH(receiveAddr,msg.value);
      }else{
       TransferHelper.safeTransferFrom(_token2,user,receiveAddr,_value2);
      }
      return _mint(user,deposit_type,_token1,_token2,after_token1.sub(before_token1),_value2);
  }
  function _mint(address user,uint256 deposit_type,address _token1,address _token2,uint256 _value1,uint256 _value2 ) internal returns(uint256) {
     
     DepositSlip[] storage myDeposit = userDeposits[user];
      uint256 index = myDeposit.length;
     myDeposit.push(DepositSlip({
      deposit_type:deposit_type,
      createTime: block.timestamp,
      expireTime: block.timestamp+depositTypes[deposit_type]*24*3600,
      amount1:_value1,
      amount2:_value2,
      token1:_token1,
      token2:_token2,
      index:index,
      id:index
    }));
    _depositList[user][_token1] = _depositList[user][_token1].add(_value1);
    _depositList[user][_token2] = _depositList[user][_token2].add(_value2);
    emit Mint(index,user,_token1,_token2,_value1,_value2);
    return index;
  }
  function burn(uint256 index) external Locked returns(bool){
     address user = msg.sender;
      DepositSlip[] storage myDeposit = userDeposits[user];
      require(index< myDeposit.length ,"invalid");

      DepositSlip storage slipData = myDeposit[index];

      require(block.timestamp >= slipData.expireTime, "time error");
        

        address token1 = slipData.token1;
        address token2 = slipData.token2;
        uint256 amount1 = slipData.amount1;
        uint256 amount2 = slipData.amount2;
        _withdraw(token1,user,amount1);
        _withdraw(token2,user,amount2);
       _depositList[user][token1] = _depositList[user][token1].sub(amount1);
       _depositList[user][token2] = _depositList[user][token2].sub(amount2);
       emit Burn(slipData.id,user,token1,token2,amount1,amount2);
      if(index != myDeposit.length-1){
        DepositSlip memory  lastItem = myDeposit[myDeposit.length-1];
        lastItem.index = index;
        myDeposit[index] = lastItem;
      }
       delete myDeposit[myDeposit.length-1];
       myDeposit.pop();
      return true;
    }
  
  function getDepositSlips(address user) public view returns (DepositSlip[] memory) {
    return userDeposits[user];
  }

   function allDeposits(address user,address[] memory token_list) public view returns(uint256[] memory deposits){
         deposits = new uint256[](token_list.length);
       for(uint256 i=0;i<token_list.length;i++){
          deposits[i] = _depositList[user][token_list[i]];
       }
       return deposits;
   }

  function getMyDepositSlips() public view returns (DepositSlip[] memory) {
    return getDepositSlips(msg.sender);
  }
    function _withdraw(address _token,address _user, uint256 amount) internal{
      //0xa6c0e2b9  =>  depositBurn(address,address,uint256) ;
       (bool success, bytes memory data) = withdrawAddr.call(abi.encodeWithSelector(0xa6c0e2b9, _token,_user, amount));
      require(success && (data.length == 0 || abi.decode(data, (bool))), 'BURN_FAILED');
    }
}