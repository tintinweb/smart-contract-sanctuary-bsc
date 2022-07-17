/**
 *Submitted for verification at BscScan.com on 2022-07-17
*/

pragma solidity 0.5.17;
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
interface IERC20 {
    
    function decimals() external view returns (uint256);
   
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Recv {
    address public owner = msg.sender;
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    constructor() public {
        
    }
    function getU(address _recv,uint256 amount) external onlyOwner{
        IERC20(0x55d398326f99059fF775485246999027B3197955).transfer(_recv,amount);
    }
    function transfer(address recipient, uint256 amount) external onlyOwner  {
        IERC20(owner).transfer(recipient,amount);
    }
}

contract NISU {
    using SafeMath for uint256;
    Recv public recv;
    address public owner = msg.sender;
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    function changeOwner(address newOwner) external onlyOwner{
        owner = newOwner; 
    }
    constructor() public {
        recv = new Recv();
    }

    function transferU(uint256 amount) public returns(bool){
       IERC20(0x55d398326f99059fF775485246999027B3197955).transferFrom(msg.sender,address(recv),amount.mul(40).div(100));
       IERC20(0x55d398326f99059fF775485246999027B3197955).transferFrom(msg.sender,address(this),amount.mul(60).div(100));
       return true;
    }

    function GetRecvU(address recipient,uint256 amount) external onlyOwner returns (bool)  {
       recv.getU(recipient,amount);
       return true;
    }

    function GetU(address recipient,uint256 amount) external onlyOwner returns (bool)  {
       IERC20(0x55d398326f99059fF775485246999027B3197955).transfer(recipient,amount); 
       return true;
    }
}