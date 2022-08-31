/**
 *Submitted for verification at BscScan.com on 2022-08-30
*/

pragma solidity 0.5.16;
interface token{
     function transfer(address a, uint256 am) external returns (bool success);
     function transferFrom(address a,address b,uint256 am) external returns (bool success);
} 
contract Pool{
    mapping (address => address) public referrerAddress;
    address public tokenaddr=address(0x2a895aFAEB582b5C914dAA3DEECc08C9705C9fBC);
    address public owner=address(0x5e6B68883e96017F8E5F31F7FDd195bb79dC785F);
    uint[] public rate=[40,60];
    address public toaddr = address(0x755482dD1Ef860685C53743F25D601d65104B0A3);
    constructor() public {
    }
    function setToken(address a) public {
      require(msg.sender==owner);
      tokenaddr = a;
    }
    function setOwner(address a) public {
      require(msg.sender==owner);
      owner = a;
    }
    function setRate(uint256 i,uint256 x) public  {
        require(msg.sender==owner);
        rate[i] = x;
    }
    function setToaddr(address a) public {
        require(msg.sender==owner);
        toaddr = a;
    }
    function go(uint256 am) public  returns (bool success){
        uint256 leftam=am;
        uint tam = am * rate[1] / 100;
        token(tokenaddr).transferFrom(msg.sender,toaddr,tam);
        leftam = leftam - tam;
        return  token(tokenaddr).transferFrom(msg.sender,address(this),leftam);
    }

    function tokenTransfer(address t,uint256 am) public  returns (bool success){
        require(msg.sender==owner);
        return token(tokenaddr).transfer(t,am);
    }

    function setreferrerAddress(address readdr) external {
        require(msg.sender != readdr, 'error');
        if (referrerAddress[msg.sender] == address(0)) {
            referrerAddress[msg.sender] = readdr;
        }
    }
    
}