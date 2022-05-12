/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

pragma solidity >=0.6.0 <0.8.0;

 interface ERC20 {
    function transfer(address receiver, uint amount) external;
    function transferFrom(address _from, address _to, uint256 _value)external;
    function balanceOf(address receiver)external view returns(uint256);
    function timeFoundation()external view returns(uint256);
    function totalSupply() external view returns (uint);
    function withdraw(address addr,uint _value)external;
}
contract CrossChainBridge{
    address public owner;
    uint256 public backValue;
    address  CrossChainBridgeAddress;//垮链桥地址
    mapping(uint256=>uint256)public balanceOf;
    mapping(uint256=>address) public userAddress;
    uint256 public intID;
    uint256 public OutIDout;
    constructor (address _CrossChainBridgeAddress) public {
        CrossChainBridgeAddress=_CrossChainBridgeAddress;//垮链桥地址
        owner=msg.sender;
        intID=1;
        OutIDout=1;
    }
    modifier onlyOwner() {
        require(owner==msg.sender, "Not an administrator");
        _;
    }
    receive() external payable {}
    function setAddress(uint256 _jsd) public {
        ERC20(0x738050710753DB53eF237CAa00074051363E42A8).transferFrom(msg.sender,address(this),_jsd);
        balanceOf[intID]=_jsd;
        userAddress[intID]=msg.sender;
        intID++;
    }
    function BridgeChain(address addr,uint256 value) public{
        require(msg.sender == CrossChainBridgeAddress,"Not a cross link bridge address");
        ERC20(0x738050710753DB53eF237CAa00074051363E42A8).transfer(addr,value);
        OutIDout++;
    }
}