/**
 *Submitted for verification at BscScan.com on 2022-07-16
*/

pragma solidity ^0.5.7;

interface InviterLike {
    function getTotalReward(address ust) external view returns (uint256, uint256);
}
interface VaultLike {
    function harve() external;
}
interface TokenLike {
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;
    function balanceOf(address) external view  returns (uint);
}
contract EatSe {
        // --- Auth ---
    uint256 public live;
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "EatSe/not-authorized");
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
	
	
    uint256                                           public  totalSupply = 150000 * 1E18;
    mapping (address => uint256)                      public  _balanceOf;
    mapping (address => mapping (address => uint))    public  allowance;
    string                                            public  symbol = "EATSE";
    string                                            public  name = "EatSwap eat";     
    uint256                                           public  decimals = 18; 

    InviterLike public inviter = InviterLike(0x392c1bdD4f0f94cF7C36069FEF3a0790AeFAF319);
    TokenLike public eat = TokenLike(0x0f77144eba9c24545aA520a03f9874C4f1f4850F);
    address public vault = 0x67665d4Cec9E1f4738a2b9AE9E397970b3E75dBe;

	constructor() public{
       wards[msg.sender] = 1;
    }

    function approve(address guy, uint wad) public  returns (bool){
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) external  returns (bool){
        require(dst == address(this), "EatSe/insufficient-dst");
        if (eat.balanceOf(vault) < wad) VaultLike(vault).harve();
        if (balanceOf(msg.sender) >= wad && eat.balanceOf(vault) >= wad) {
            eat.transferFrom(vault,msg.sender,wad);
            _balanceOf[msg.sender] = add(_balanceOf[msg.sender],wad);
        }
        emit Transfer(msg.sender, dst, wad);
        return true;
    }

    function balanceOf(address dst) public  view returns (uint256){
        (uint256 eatamount,) = inviter.getTotalReward(dst);
        return sub(eatamount,_balanceOf[dst]);
    }

    function transferFrom(address src, address dst, uint wad)public  returns (bool){}

    function withdraw(address asses,uint256 wad, address usr)public auth {
        TokenLike(asses).transfer(usr, wad);
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