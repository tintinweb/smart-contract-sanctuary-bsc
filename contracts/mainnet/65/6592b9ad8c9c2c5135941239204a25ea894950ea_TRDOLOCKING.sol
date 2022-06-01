/**
 *Submitted for verification at BscScan.com on 2022-06-01
*/

pragma solidity 0.4.25;
contract TRDOLOCKING {
    using SafeMath for uint256;
     IBEP20 public token;
     


    address public owner;

   
    uint256 public withdrawn;
    uint256 public last_release;
    uint256 release_amt = 2500000 * 10 ** 18;

    
    


    event TokenReleased(uint amount);
    constructor(IBEP20 tokenAdd) public {
        owner = msg.sender;
        token = tokenAdd;
        last_release = block.timestamp;
    }
    function release() payable external {

       require(msg.sender == owner, 'permission denied');
       require(block.timestamp >=  last_release.add(90  days),'Immature call'); 

        token.transfer(owner,release_amt);
        last_release = block.timestamp;
        withdrawn = withdrawn.add(release_amt);

       emit TokenReleased(release_amt);
       
    }

    function withdraw_bnb_amount(address _add) external{

        require(msg.sender==owner,'permission Denied');
       _add.transfer(address(this).balance);


    }


    
  
   

   

 
    
}



library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

}
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