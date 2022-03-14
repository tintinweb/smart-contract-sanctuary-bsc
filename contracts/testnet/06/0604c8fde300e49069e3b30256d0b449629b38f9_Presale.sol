/**
 *Submitted for verification at BscScan.com on 2022-03-13
*/

pragma solidity ^0.8.0;
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}
interface IToken {
  function remainingMintableSupply() external view returns (uint256);
  function calculateTransferTaxes(address _from, uint256 _value) external view returns (uint256 adjustedValue, uint256 taxAmount);
  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool);
  function transfer(address to, uint256 value) external returns (bool);
  function balanceOf(address who) external view returns (uint256);
  function mintedSupply() external returns (uint256);
  function allowance(address owner, address spender)
  external
  view
  returns (uint256);
  function approve(address spender, uint256 value) external returns (bool);
    function whitelist(address addrs) external returns(bool);
    function addAddressesToWhitelist(address[] memory addrs)  external returns(bool success) ;
}
contract Presale{
    using SafeMath for uint256;
    IToken public token;
     uint256 public presalePrice = 6050000000000000 ;
     address payable public owner;
      mapping(address => bool) public whitelist;
      mapping(address=> uint256) public limit;
      uint256 public limitperwallet=827000000000000000000;
    event WhitelistedAddressAdded(address addr);
    event WhitelistedAddressRemoved(address addr);
    constructor (IToken _Token) 
    {     
         token = _Token;
         owner = payable(msg.sender);
    }
        modifier onlyowner() {
        require(owner == msg.sender, 'you are not owner');
        _;
    }
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
  function pause() onlyowner whenNotPaused public {
    paused = true;
    emit Pause();
  }
  function unpause() onlyowner whenPaused public {
    paused = false;
    emit Unpause();
  }
    function calculateSplashforWT(uint256 amount) public view returns(uint256) 
    {
        return (presalePrice.mul(amount));
    }
    function Buy(uint256 _amount) public  payable whenNotPaused
    {   
        require(limit[msg.sender].add(_amount)<=limitperwallet,"Limit exceeded");
        require(whitelist[msg.sender], "You are not Whitelist" );
        uint256 amount = calculateSplashforWT(_amount);
        require(msg.value>= amount.div(1E18) , "low price");
        token.transfer(msg.sender,_amount);
        limit[msg.sender]+=_amount;
    }
    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], 'not whitelisted');
        _;
    }
    function addAddressToWhitelist(address addr) onlyowner public returns(bool success) {
        if (!whitelist[addr]) {
            whitelist[addr] = true;
            emit WhitelistedAddressAdded(addr);
            success = true;
        }
    }
     function addAddressesToWhitelist(address[] memory addrs) onlyowner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addAddressToWhitelist(addrs[i])) {
                success = true;
            }
        }
    }
        function checkContractBalance() public view returns(uint256) 
    {
        return address(this).balance;
    }
        function WithdrawAVAX(uint256 amount) public onlyowner
    {     require(checkContractBalance()>=amount,"contract have not enough balance");  
          owner.transfer(amount);
    }
            function WithdrawSplash(uint256 amount) public onlyowner
    {
        token.transfer(address(msg.sender),amount);
    }
    function updatePresalePrice(uint256 amount) public onlyowner{
    presalePrice=amount;
    }
     function updateWalletLimit(uint256 amount) public onlyowner{
    limitperwallet=amount;
     }
}