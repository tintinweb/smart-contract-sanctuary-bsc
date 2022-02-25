/**
 *Submitted for verification at BscScan.com on 2022-02-25
*/

pragma solidity ^0.8.4;
//SPDX-License-Identifier: MIT Licensed
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account,uint tokenid) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function burn(uint256 amount) external ;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

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
contract presale{
    using  SafeMath for uint;
    using Address for address;
    IBEP20 public SKY;
    IBEP20 public USDT;
    address public owner;
    uint public price=0.1 ether ;
    uint256 initialprice=0.1 ether;
    uint256 updateprice=0.1 ether;
    uint256 _initialprice=0.1 ether;
    uint256 _updateprice=0.1 ether;
    uint256 presaletime;
    
    
    mapping (address => uint256) public balances;
    mapping (address => uint256) public balanceof;
     modifier onlyOwner() {
        require(msg.sender== owner,"BEP20: Not an owner");
        _; }
    event depositfundforSKY(address _user, uint256 _amount);
    event SKYtokentransfer(address buyer,uint256 _amount);
    event DepositfundsforUSDT(address _user, uint256 _amount);
    event USDTtokentransfer(address buyer,uint256 _amount);
    constructor (address _owner,IBEP20 _token,IBEP20 Token)
    {
     owner=_owner;
     SKY =_token;
     USDT= Token;
     presaletime=block.timestamp+30 days;
    }
    receive() external payable{}
    function DepositFundsforSKY(uint256 _amount)  public {
        require(!address(msg.sender).isContract(),"USDT:A contract address" );
        require(_amount>0,"USDT: invalid amount");
        require(block.timestamp < presaletime,"USDT: PreSale over");
        balances[msg.sender]+= _amount;
        USDT.transferFrom(msg.sender,owner,_amount);
        emit depositfundforSKY( msg.sender,balances[msg.sender]);

 }
   function ClaimSKYToken()public{
       require(updateprice!=initialprice,"Price not update");
       require(!address(msg.sender).isContract(),"USDT:A contract address" );
       uint256 amount = balances[msg.sender];
       balances[msg.sender] -=amount;
       SKY.transfer(msg.sender,amount.mul(10**18)/price);
       emit SKYtokentransfer(msg.sender, amount);
    }
   function updatePriceofsky(uint256 _tokenPerusdt) external onlyOwner{
       _initialprice= _updateprice;
        updateprice= _tokenPerusdt;
         }
    function DepositFundsforUSDT(uint256 _amount)  public {
        require(!address(msg.sender).isContract(),"USDT:A contract address" );
        require(_amount>0,"USDT: invalid amount");
        require(block.timestamp < presaletime,"USDT: PreSale over");
        balanceof[msg.sender]+=_amount;
        SKY.burn(_amount);
        emit DepositfundsforUSDT( msg.sender,balances[msg.sender]);

 }
function ClaimUSdtToken() public{
       require(updateprice!=initialprice,"Price not update");
       require(!address(msg.sender).isContract(),"USDT:A contract address" );
       uint256 amount = balanceof [msg.sender];
       balanceof[msg.sender] -= amount;
       USDT.transfer(msg.sender,amount*price);
       emit USDTtokentransfer(msg.sender, amount);
    }
   function updatePriceUSDT(uint256 _tokenPerusdt) external onlyOwner{
       _initialprice= updateprice;
        updateprice= _tokenPerusdt;
      }
function setpreSaleTime(uint256 _time) external onlyOwner{
        presaletime = _time;
    }
    
    function changeOwner(address payable _newOwner) external onlyOwner{
        owner = _newOwner;
    }
    function changeToken(address _token) external onlyOwner{
        SKY= IBEP20(_token);
    }
    
    function getCurrentTime() public view returns(uint256){
        return block.timestamp;
    }
    
    function contractBalanceusdt() external view returns(uint256){
        return address(this).balance;
    }
    
    function getContractTokenBalance() external view returns(uint256){
        return SKY.allowance(owner, address(this));
    }
    
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