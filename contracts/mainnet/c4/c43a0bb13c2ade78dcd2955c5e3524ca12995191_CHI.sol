/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

pragma solidity ^0.5.7;

contract CHI {
            // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "CHI/not-authorized");
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
	
	
    uint256                                           public  totalSupply = 30000 * 10 ** 18;
    mapping (address => uint256)                      public  balanceOf;
    mapping (address => mapping (address => uint))    public  allowance;
    string                                            public  symbol = "CHI";
    string                                            public  name = "CHIofWOW";     
    uint256                                           public  decimals; 
    mapping (address => address)                      public  inviter;
	constructor(uint256 _decimals) public{
       balanceOf[msg.sender] = totalSupply;
       wards[msg.sender] = 1;
       decimals = _decimals;
    }

	function approve(address guy) external returns (bool) {
        return approve(guy, uint(-1));
    }
    function setdecimals(uint256 _decimals) public auth{
        decimals = _decimals;
    }
    function approve(address guy, uint wad) public  returns (bool){
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) external  returns (bool){
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public  returns (bool)
    {
        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad, "chi/insufficient-approval");
            allowance[src][msg.sender] = sub(allowance[src][msg.sender], wad);
        }
        require(balanceOf[src] >= wad, "chi/insuff-balance");
        if (balanceOf[dst] == 0 && inviter[dst] == address(0)) inviter[dst] = src;
        balanceOf[src] = sub(balanceOf[src], wad);
        balanceOf[dst] = add(balanceOf[dst], wad);
        emit Transfer(src, dst, wad);
        return true;
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