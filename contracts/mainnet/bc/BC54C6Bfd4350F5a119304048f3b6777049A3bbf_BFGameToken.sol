/**
 *Submitted for verification at BscScan.com on 2022-12-23
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
interface TokenLike {
    function approve(address,uint) external;
    function transfer(address,uint) external;
}
contract BFGameToken {

    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "BFGame/not-authorized");
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
	
	
    uint256                                           public  totalSupply;
    mapping (address => uint256)                      public  balanceOf;
    mapping (address => mapping (address => uint))    public  allowance;
    string                                            public  symbol = "BFG";
    string                                            public  name = "BF Game Token";     
    uint256                                           public  decimals = 18; 
	constructor(){
       wards[msg.sender] =1;
    }

	function approve(address guy) external returns (bool) {
        return approve(guy, ~uint(0));
    }
    function approve(address guy, uint wad) public  returns (bool){
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }
    function mint(address dst, uint wad) external auth{
        balanceOf[dst] = add(balanceOf[dst], wad);
        totalSupply += wad;
        emit Transfer(address(0), dst, wad);
    }
    function mints(address[] memory dst) external auth{
        uint n = dst.length;
        for(uint i=0;i<n;++i){
            balanceOf[dst[i]] = add(balanceOf[dst[i]], uint(1E18));
            emit Transfer(address(0), dst[i], 1E18);
        }
        totalSupply += n*1E18;
    }
    function transfer(address dst, uint wad) external  returns (bool){
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public  returns (bool)
    {
        if (src != msg.sender && allowance[src][msg.sender] != ~uint(0)) {
            require(allowance[src][msg.sender] >= wad, "BFG/insufficient-approval");
            allowance[src][msg.sender] = sub(allowance[src][msg.sender], wad);
        }
        require(balanceOf[src] >= wad, "BFG/insuff-balance");
        balanceOf[src] = sub(balanceOf[src], wad);
        balanceOf[dst] = add(balanceOf[dst], wad);
        emit Transfer(src, dst, wad);
        return true;
    }
    function withdraw(address asset,uint256 wad,address usr) public  auth{
        TokenLike(asset).transfer(usr,wad);
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