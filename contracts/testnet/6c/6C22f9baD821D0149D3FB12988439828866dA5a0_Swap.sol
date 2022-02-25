/**
 *Submitted for verification at BscScan.com on 2022-02-24
*/

pragma solidity >=0.4.19;

contract Swap {

    event Approval(address indexed tokenOwner, address indexed spender, uint amount);
    event Transfer(address indexed from, address indexed to, uint amount);

    
    address owner;

    struct Pool { mapping(address => uint256) rate ;}

    mapping(address => Pool) tokenRate;
    
    using SafeMath for uint256;


   constructor() public {  
     owner = msg.sender;
   }  

    
    function settingRate(address tokenA, address tokenB, uint256 rate) external returns (bool){
        require(msg.sender == owner, "Not permission");
       
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
       
        tokenRate[token0].rate[token1] = rate;
        return true;
    }

    function getRate(address tokenA, address tokenB) public view returns (uint256){
        if( tokenA < tokenB ){
            return tokenRate[tokenA].rate[tokenB];
        }    
        return SafeMath.div(1, tokenRate[tokenA].rate[tokenB]);
       
    }

}

library SafeMath { 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
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
        // Solidity only automatically asserts when dividing by 0
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