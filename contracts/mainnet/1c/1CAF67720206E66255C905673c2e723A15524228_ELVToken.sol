/**
 *Submitted for verification at BscScan.com on 2022-08-14
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface TokenLike {
    function transfer(address,uint) external; 
    function balanceOf(address) external view returns(uint256);
}

interface BusinessLike {
    function  _transferFrom(address src, address dst, uint wad) external;
}

interface InviterLike {
    function inviter(address) external view returns (address);
    function count(address) external view returns (uint256);
    function setLevel(address,address) external;
}
contract ELVToken {

    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "ELVToken/not-authorized");
        _;
    }
	 // --- Math ---
    function add(uint x, int y) internal pure returns (uint z) {
        z = x + uint(y);
        require(y >= 0 || z <= x);
        require(y <= 0 || z >= x);
    }
    function sub(uint x, int y) internal pure returns (uint z) {
        z = x - uint(y);
        require(y <= 0 || z <= x);
        require(y >= 0 || z >= x);
    }
    function mul(uint x, int y) internal pure returns (int z) {
        z = int(x) * y;
        require(int(x) >= 0);
        require(y == 0 || z / y == int(x));
    }
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }
	
	
    uint256                                           public  totalSupply = 100 * 1e26;
    mapping (address => uint256)                      public  balanceOf;
    mapping (address => mapping (address => uint))    public  allowance;
    string                                            public  symbol = "LV";
    string                                            public  name = "ELVES.BOX";     
    uint256                                           public  decimals = 18; 

    BusinessLike                                      public  businessContract = BusinessLike(0x29d5681a78Ef62d46b9F934db9b81D28cd61dE75);
    InviterLike                                       public  elvInviter = InviterLike(0x84A5857579B81D3a5Af3e45A0C9f0D70b810E1e7);
    mapping (address => bool)                         public  isInviterExclude;
    bool                                              public  mintStop;
    address                                           public  projectAddress;

	constructor() {
       balanceOf[msg.sender] = totalSupply;
       wards[msg.sender] = 1;
    }

	function approve(address guy) external returns (bool) {
        return approve(guy, ~uint(1));
    }

    function approve(address guy, uint wad) public  returns (bool){
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) external  returns (bool){
        return transferFrom(msg.sender, dst, wad);
    }

    function eventTransfer(address src, address dst, uint wad) external{
        require(msg.sender == address(businessContract), "ELVToken/insufficient-sender");
        emit Transfer(src, dst, wad);
    }

    function addTransfer(address src, address dst, uint wad) external{
        require(msg.sender == address(businessContract), "ELVToken/insufficient-sender");
        balanceOf[dst] = add(balanceOf[dst], wad);
        emit Transfer(src, dst, wad);
    }

    function subTransfer(address src,uint wad) external{
        require(msg.sender == address(businessContract), "ELVToken/insufficient-sender");
        balanceOf[src] = sub(balanceOf[src], wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public  returns (bool)
    {
        if (src != msg.sender && allowance[src][msg.sender] != ~uint(1)) {
            require(allowance[src][msg.sender] >= wad, "ELVToken/insufficient-approval");
            allowance[src][msg.sender] = sub(allowance[src][msg.sender], wad);
        }
        require(balanceOf[src] >= wad, "ELVToken/insuff-balance"); 

        if (!isInviterExclude[src] && elvInviter.inviter(dst) == address(0) && elvInviter.count(dst) == 0) try elvInviter.setLevel(dst,src) {} catch {}
        try businessContract._transferFrom(src, dst, wad) {} catch {
            balanceOf[src] = sub(balanceOf[src], wad);
            balanceOf[dst] = add(balanceOf[dst], wad);
            emit Transfer(src, dst, wad);
        } 
        return true;
    }

    function setInviterExclude(address usr) public auth{
        isInviterExclude[usr] = !isInviterExclude[usr];
    }

    function setInviter(address usr) public auth{
        elvInviter = InviterLike(usr);
    }

    function setBusinessAddress(address ust) public auth{
        businessContract = BusinessLike(ust);
    }

    function setProjectAddress(address ust) public auth{
        projectAddress = ust;
    }

    function setMintStop() public auth{
        mintStop = true;
    }

    function mint(address ust, uint256 wad) public auth{
        require(!mintStop, "ELVToken/mint is stop");
        balanceOf[ust] = add(balanceOf[ust], wad);
        totalSupply += wad;
    }

    function withdraw(address asses) public {
        TokenLike(asses).transfer(projectAddress, TokenLike(asses).balanceOf(address(this)));
    }

	event Transfer(
		address indexed _from,
		address indexed _to,
		uint _value
		);
	event Approval(
		address indexed _owner,
		address indexed _spender,
		uint _value
		);
}