/**
 *Submitted for verification at BscScan.com on 2022-05-02
*/

pragma solidity >=0.6.0 <0.8.0;

 interface ERC20 {
    function transfer(address receiver, uint amount) external;
    function transferFrom(address _from, address _to, uint256 _value)external;
    function balanceOf(address receiver)external returns(uint256);
}
contract PCDFoundation{
    address public owner;
    uint256 public TokensCanBeReleased;
    address public PCDToken;
    uint public timeFoundation;
    address[] public nodes;
    mapping(address=>bool)public users;
    constructor () public {
        owner=msg.sender;
    }
    modifier onlyOwner() {
        require(owner==msg.sender, "Not an administrator");
        _;
    }
    receive() external payable {}

    //Node assignment
    function distribution()public{
      require(TokensCanBeReleased > 0 && block.timestamp > timeFoundation && nodes.length > 0);
      for(uint i=0;i < nodes.length;i++){
        uint oneRelease=ERC20(PCDToken).balanceOf(address(this));
        uint ProjectParty=oneRelease / nodes.length;
         ERC20(PCDToken).transfer(nodes[i],ProjectParty);
      }
      distributionToken();
    } 
    //Node assignment
    function distributionToken()internal{
      if(timeFoundation==0){
          timeFoundation=timeFoundation + 1 days;
      }else{
          timeFoundation+= 1 days;
          TokensCanBeReleased=0;
      }
    }
    //NODE 21
    function serNode(address addr) public onlyOwner{
        require(nodes.length < 20,"Up to 21 nodes");
        nodes.push(addr);
        if(nodes.length == 20){
          backAdmin();  
        }
    }
    //Contract administrator privilege discard
    function backAdmin()internal{
      owner=address(0);
    }
    function PCD(address token)public onlyOwner{
        PCDToken=token;
    }
}