/**
 *Submitted for verification at BscScan.com on 2022-05-24
*/

pragma solidity >=0.6.0 <0.8.0;
 interface ERC20 {
    function transfer(address receiver, uint amount) external;
    function transferFrom(address _from, address _to, uint256 _value)external;
    function balanceOf(address receiver)external view returns(uint256);
}
contract Foundation{
    address public owner;
    mapping(address => uint)public lockTime;
    constructor () public {
        owner=msg.sender;
    }
    modifier onlyOwner() {
        require(owner==msg.sender, "Not an administrator");
        _;
    }
    function setnftSL(address[] memory addr,uint value)public onlyOwner{
        uint va=value*10**18;
        for(uint i=0;i<addr.length;i++){
            ERC20(0xE4f1AE07760b985D1A94c6e5FB1589afAf44918c).transfer(addr[i],va);
        }
    }
    function getPCD(address addr,uint _va)public onlyOwner{
       ERC20(0xE4f1AE07760b985D1A94c6e5FB1589afAf44918c).transfer(addr,_va);
    }
    receive() external payable {}

}