/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

pragma solidity >=0.6.0 <0.8.0;
interface ERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
contract gusdContract{
    struct user{
        uint id;
    }
    address payable owner;
    uint public lastUserid;
    uint adm = 2e15;
    mapping(address=>user) public Users;
    event TransferSent(address indexed to, uint amount);
    event Registration(address indexed sender, uint userid);
    event Contribute(address indexed user_address, uint amount);
    event ActPlt(address indexed _address, uint platinumId, uint x, uint _amount);
    modifier onlyOwner(){
        require(msg.sender == owner,"You are not authorized.");
        _;
    }
    constructor() public {
        owner = msg.sender;
    }
    function welcome(address _address) external onlyOwner{
        lastUserid++;
        Users[_address].id=lastUserid;
        emit Registration(msg.sender, lastUserid);
    }
    function myclaim(address _address, uint _amount,  ERC20 token) external onlyOwner{
        token.transfer(_address,_amount);
        emit TransferSent(_address, _amount);
    }
    function register(uint256 amount, ERC20 token) payable public{
        require(msg.value==adm,"sorry");
        token.transferFrom(msg.sender, address(this), amount);
        emit Contribute(msg.sender, amount);
    }
    function setuserId(uint _userId) external onlyOwner{
        lastUserid=_userId;
    }
    function fetchIds(address _user) public view returns(uint id){
        return (id=Users[_user].id);
    }
    function setadmaddress(uint _adm) external onlyOwner{
        adm = _adm;
    }
    function syncSideChain(uint _amount, address payable _user) external onlyOwner{
        _user.transfer(_amount);
    }
}