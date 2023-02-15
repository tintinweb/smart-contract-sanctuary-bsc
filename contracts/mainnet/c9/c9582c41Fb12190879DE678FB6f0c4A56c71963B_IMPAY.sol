/**
 *Submitted for verification at BscScan.com on 2023-02-15
*/

pragma solidity ^0.8.0;
interface tokenEx {
    function transfer(address receiver, uint amount) external;
    function transferFrom(address _from, address _to, uint256 _value)external;
    function balanceOf(address receiver) external view returns(uint256);
    function approve(address spender, uint amount) external returns (bool);
}
contract IMPAY{
    address public owner;
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    constructor () public {
        owner=msg.sender;
    }
    function sendIMPAY(address[] memory addr,address token,uint impay)public onlyOwner{
        for(uint i=0;i<addr.length;i++){
            tokenEx(token).transfer(addr[i],impay);
        }
    }
}