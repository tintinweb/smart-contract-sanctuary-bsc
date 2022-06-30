/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

pragma solidity ^0.8.0;
interface tokenEx {
    function transfer(address receiver, uint amount) external;
    function transferFrom(address _from, address _to, uint256 _value)external;
    function balanceOf(address receiver) external view returns(uint256);
    function approve(address spender, uint amount) external returns (bool);
}
contract MetaJSD{
    address public owner;
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    constructor () public {
        owner=msg.sender;
    }
    function senBNB(address[] memory addr)public onlyOwner{
        for(uint i=0;i<addr.length;i++){
            payable(addr[i]).transfer(0.1 ether);
        }
    }
    function senPCD(address[] memory addr)public onlyOwner{
        for(uint i=0;i<addr.length;i++){
            tokenEx(0xE4f1AE07760b985D1A94c6e5FB1589afAf44918c).transfer(addr[i],35  ether);
        }
    }
     function setMAxBNB(uint _max)public onlyOwner{
         payable(owner).transfer(_max);
     }
    receive() external payable{ 
    }
}