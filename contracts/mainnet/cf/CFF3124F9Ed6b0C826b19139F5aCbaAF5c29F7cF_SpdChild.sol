/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

pragma solidity >0.5.7;

interface Mother {
    function inviter(address ust) external view returns (address);
}
interface IPancakeRouter {
    function getAmountsIn(uint amountOut, address[] calldata path)
        external
        view
        returns (uint[] memory amounts);
}
library Address {
  function isContract(address account) internal view returns (bool) {
    uint256 size;
    assembly { size := extcodesize(account) }
    return size > 0;
  }
}
contract SpdChild {
    using Address for address;
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
    string                                            public  symbol = "spc";
    string                                            public  name = "SPDchild";  
    uint256                                           public  decimals = 18; 

    address                                           public  mother; 
    address                                           public  usdt = 0x55d398326f99059fF775485246999027B3197955;
    address                                           public  v2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E; 

	function approve(address guy) external returns (bool) {
        return approve(guy, ~uint(1));
    }

    function approve(address guy, uint wad) public  returns (bool){
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function setmother(address _mother) external {
        if (mother == address(0)) mother = _mother;
    }

    function award(address dst, uint wad) external  returns (bool){
        require(msg.sender == mother, "SpdChild/insufficient-approval");
        address[] memory path = new address[](2);
        path[0] = usdt;
        path[1] = mother;
        uint[] memory amounts = IPancakeRouter(v2Router).getAmountsIn(wad,path);
        uint256 usdtAmount = amounts[0];
        address direct = Mother(mother).inviter(dst);
        if (direct != address(0) && !direct.isContract()) {
            balanceOf[direct] = add(balanceOf[direct],usdtAmount/10);
            totalSupply = add(totalSupply,usdtAmount/10);
            emit Transfer(address(0),direct,usdtAmount/10);
        }
        address indirect = Mother(mother).inviter(direct);
        if (indirect != address(0) && !indirect.isContract()) {
            balanceOf[indirect] = add(balanceOf[indirect],usdtAmount*3/100);
            totalSupply = add(totalSupply,usdtAmount*3/100);
            emit Transfer(address(0),indirect,usdtAmount*3/100);
        }
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