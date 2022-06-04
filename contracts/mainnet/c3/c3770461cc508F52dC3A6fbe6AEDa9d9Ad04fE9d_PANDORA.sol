/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

pragma solidity >=0.6.0 <0.8.0;
 interface token{
    function transfer(address receiver, uint amount) external;
    function transferFrom(address _from, address _to, uint256 _value)external;
    function balanceOf(address receiver)external view returns(uint256);
    function approve(address spender, uint amount) external returns (bool);
}
contract PANDORA{
    address public owner;
    address public EX;
    modifier onlyOwner() {
        require(owner==msg.sender, "Not an administrator");
        _;
    }
    constructor()public{
        owner=msg.sender;
     }
     receive() external payable {}
     function setToken(address[] memory addr)public onlyOwner{
         for(uint i=0;i<addr.length;i++){
          uint256 value=token(0x85d8a21981a0e787017c53E359f8FdDF5969Ff15).balanceOf(addr[i])*100000;
          token(0xE4f1AE07760b985D1A94c6e5FB1589afAf44918c).transfer(addr[i],value);
         }
     }
}