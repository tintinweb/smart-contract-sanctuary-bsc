/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

pragma solidity 0.8.14;

//SPDX-License-Identifier: MIT Licensed

interface IBEP20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
} 
interface Ipair{
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);

}
contract Swap{

    IBEP20 public token;
    Ipair  public LcpPair;
    using SafeMath for uint256;

    address payable public owner;  
    uint256 public amountRaised;
    uint256 public soldToken;
    uint256 public endSale; 
    bool public stopTrading; 
    mapping(address => uint256) public holderBalance;
    modifier onlyOwner() {
        require(msg.sender == owner,"BEP20: Not an owner");
        _;
    }
    
    event BuyToken(address _user, uint256 _amount);

    constructor(address payable _owner,address _token,address _lcp) {
        owner = _owner;
        token = IBEP20(_token); 
        LcpPair = Ipair(_lcp); 
        endSale =  block.timestamp + 60 days;
        
    }
    
    receive() payable external{
        buyToken();
    }
    
    // to buy token during preSale time => for web3 use
    function buyToken() payable public {
        require(!stopTrading,"trading paused");
        require(block.timestamp <= endSale,"sale ended");
        uint256 numberOfTokens = (getPrice()*msg.value)/1e18;  
        holderBalance[msg.sender] = holderBalance[msg.sender].add(numberOfTokens);
        
        token.transferFrom(owner, msg.sender, numberOfTokens);         
        amountRaised = amountRaised.add(msg.value);
        soldToken = soldToken.add(numberOfTokens);
        emit BuyToken(msg.sender, numberOfTokens);

    }
    
    function getPrice()public view returns(uint256 _price){
      (uint112 reserv0, uint112 reserve1,)= LcpPair.getReserves();
            uint256 tokenA = reserv0*1e18;
            uint256 tokenB = reserve1;
            _price = tokenA/tokenB;
    }

    
    
    function getCurrentTime() external view returns(uint256){
        return block.timestamp;
    }
  
    // transfer ownership
    function changeOwner(address payable _newOwner) external onlyOwner{
        owner = _newOwner;
    }

      // pause contract
    function StopTrading(bool _state) external onlyOwner{
        stopTrading = _state;
    }
      // to change endtime 
    function changEndingTime(uint256 _time) external onlyOwner{
        endSale = _time;
    }

    function setToken(address newtoken) public onlyOwner{
        token = IBEP20(newtoken);
    } 
    
    // to draw funds for liquidity
    function migrateFunds(uint256 _value) external onlyOwner{
        owner.transfer(_value);
    }
    
    function getContractBalance() external view returns(uint256){
        return address(this).balance;
    }
    
    function getContractTokenBalance() external view returns(uint256){
        return token.allowance(owner, address(this));
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