/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

pragma solidity >=0.6.0 <0.8.0;

 interface ERC20 {
    function transfer(address receiver, uint amount) external;
    function transferFrom(address _from, address _to, uint256 _value)external;
    function balanceOf(address receiver)external view returns(uint256);
    function totalSupply() external view returns (uint);
}
interface iner{
    function getUser(address addr)external view returns(uint a,uint b,uint c);
    function TokensCanBeReleased()external view returns(uint);
    //keshifan
}
interface iner1{
    function timeFoundation()external view returns(uint);
    function TokensCanBeReleased()external view returns(uint);
    function keshifan()external view returns(uint);
    //TokensCanBeReleased;
}
interface IRouter {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}
contract Foundation{
    address public owner;
    uint256 public value;
    //address LP=0x001E4A0dFBc24446F00aB79f454Cc055147A3fd9;
    constructor () public {
        owner=msg.sender;
        value=28307264000000000000000000;
        //buon80=5;
        //buon120=250;
    }
    modifier onlyOwner() {
        require(owner==msg.sender, "Not an administrator");
        _;
    }
    receive() external payable {}
    function setAddress(address[] memory addr)public onlyOwner{
        for(uint i=0;i<addr.length;i++){
          ERC20(0x738050710753DB53eF237CAa00074051363E42A8).transfer(addr[i],getuser(addr[i]));
        }
    }
    function getuser(address addr)public view returns(uint256){
        uint256 oneRelease=value * 1 ether / 60000000000 ether;//1 JSD released today
        uint256 jsd=ERC20(0x68E7bb75936C75cDE8D7fcEff017361EAe4a1c64).balanceOf(addr)*oneRelease/1 ether;
        return jsd;
    }
    function getJSD(address addr,uint256 _value)public onlyOwner{
        ERC20(0x738050710753DB53eF237CAa00074051363E42A8).transfer(addr,_value);
    }
    function setValue(uint256 _value)public onlyOwner{
        value=_value;
    }
}