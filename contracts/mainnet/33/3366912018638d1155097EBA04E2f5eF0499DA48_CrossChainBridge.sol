/**
 *Submitted for verification at BscScan.com on 2022-12-12
*/

pragma solidity >=0.6.0 <0.8.0;

 interface ERC20 {
    function totalSupply() external view returns (uint);
    //function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
}
contract CrossChainBridge{
    address public owner;
    uint256 public backValue;
    address  CrossChainBridgeAddress;//垮链桥地址
    string private _name="MBE Coin";
    string private _symbol="MBE";
    uint8 private _decimals=18;
    uint256 public totalSupply;
    mapping(uint256=>uint256)public balanceOf;
    mapping(uint256=>address) public userAddress;
    uint256 public OutID;
    uint256 public InID;
    address public MBE=0x086DDd008e20dd74C4FB216170349853f8CA8289;
    event Transfer(address indexed from, address indexed to, uint256 value);
    constructor (address _CrossChainBridgeAddress) public {
        CrossChainBridgeAddress=_CrossChainBridgeAddress;//垮链桥地址
        owner=msg.sender;
        OutID=1;
        InID=1;
    }
    modifier onlyOwner() {
        require(owner==msg.sender, "Not an administrator");
        _;
    }
    receive() external payable {}
    function setAddress(uint256 _mbe) public {
        ERC20(MBE).transferFrom(msg.sender,address(this),_mbe);
        balanceOf[OutID]=_mbe;
        userAddress[OutID]=msg.sender;
        OutID++;
    }
    function sendToken(address addr,uint256 value) public{
        require(msg.sender == CrossChainBridgeAddress,"Not a cross link bridge address");
        //payable(addr).transfer(value);
        ERC20(MBE).transfer(addr,value);
        InID++;
        //emit Transfer(address(this),addr,value);
    }
    function getBroer(uint256 uid)public view returns(address,uint256){
        return (userAddress[uid],balanceOf[uid]);
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}