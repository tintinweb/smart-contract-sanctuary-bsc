/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
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



contract Withdraw {
     using SafeMath for uint256;

  event TokenWithdraw(address user, address token, uint256 amount,uint256 amount2);

  event TokenReward(address user, address token, uint256 amount);
  
  mapping (address =>mapping(address=>uint256)) public userWithdraws;
 
  mapping (address =>uint256) public totalWithdraws;

  uint256 public fee;
  bool private _locking;
  modifier Locked{
     require(!_locking,"locked");
     _locking = true;
     _;
     _locking = false;
  }
  address private _executor;
  address private _depositContract;
  
  modifier onlyExecutor{
    require(msg.sender==_executor,"denied");
     _;
  }
  modifier onlyDeposit{
     require(msg.sender==_depositContract,"denied");
     _;
  }
   constructor(){
    _executor = msg.sender;
   }
    receive() external payable {

    }
    function setExecutor(address newExecutor) public onlyExecutor{
      _executor = newExecutor;
    }
    function setFee(uint256 newFee) public onlyExecutor {//1000
        fee = newFee;
    }
    function setDepositContract(address contract_addr) public onlyExecutor{
      _depositContract = contract_addr;
    }
  
     function depositBurn(address _token,address _user,uint256 amount ) public onlyDeposit returns(bool){
            _saveReward(_user,_token,amount);
            return true;
     }
     function resetReward(address _token,address[]  memory _accounts, uint256[] memory _amounts) public onlyExecutor returns(bool){
         require(_accounts.length == _amounts.length, "the accounts size and amounts size not equals");
        require(_accounts.length <=1000,"max num");
        uint256 size = _accounts.length;
        for(uint256 index = 0; index< size; index++){
           address user = _accounts[index];
           uint256 new_amount = _amounts[index];
           uint256 old_amount = userWithdraws[user][_token];
           if(new_amount>old_amount){
              userWithdraws[user][_token] = new_amount;
              totalWithdraws[_token] = totalWithdraws[_token].add(new_amount.sub(old_amount));
           }else{
             userWithdraws[user][_token] = new_amount;
             totalWithdraws[_token] = totalWithdraws[_token].sub(old_amount.sub(new_amount));
           }
        }
        return true;
     }
    function sendReward(address _token,address[]  memory _accounts, uint256[] memory _amounts) public onlyExecutor returns(bool) {
        require(_accounts.length == _amounts.length, "the accounts size and amounts size not equals");
        require(_accounts.length <=1000,"max num");
        
        uint256 size = _accounts.length;

        for(uint256 index = 0; index< size; index++){
           address user = _accounts[index];
           uint256 amount = _amounts[index];
           _saveReward(user,_token,amount);
        }
        return true;
    }
    function _saveReward(address user,address _token, uint256 amount) internal{
       userWithdraws[user][_token] = userWithdraws[user][_token].add(amount);
       totalWithdraws[_token] = totalWithdraws[_token].add(amount);
       emit TokenReward(user,_token,amount);
    }
   function userBalanceOf(address user,address _token) public view returns(uint256){
     return userWithdraws[user][_token];
   }
   function tokenBalanceOf(address _token) public view returns(uint256){
     return totalWithdraws[_token];
   }
   function allBalances(address user,address[] memory token_list) public view returns(uint256[] memory balances){
         balances = new uint256[](token_list.length);
       for(uint256 i=0;i<token_list.length;i++){
          balances[i] = userWithdraws[user][token_list[i]];
       }
       return balances;
   }
   function withdrawAll(address _token) public returns(bool){
     return withdraw(_token,userBalanceOf(msg.sender,_token));
   }
  function withdraw(address _token, uint256 amount) public Locked returns(bool){
      address user = msg.sender;
      uint256 balance = userBalanceOf(user,_token);
      require(balance >= amount,"amount is too large");
      
      userWithdraws[user][_token] = userWithdraws[user][_token].sub(amount);
      totalWithdraws[_token] = totalWithdraws[_token].sub(amount);
      uint256 fee_value = amount.mul(fee).div(1000);
      if(amount>0)  {
        
        if(_token == address(0)){
        TransferHelper.safeTransferETH(user,amount-fee_value);
      }else{
       TransferHelper.safeTransfer(_token,user,amount-fee_value);
      }
      emit TokenWithdraw(msg.sender, _token, amount,amount-fee_value);


      }
    
      return true;
    }
}