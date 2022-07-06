/**
 *Submitted for verification at BscScan.com on 2022-07-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.7;
interface HfFreeLike {
    function seed() external view returns(address);
    function technology() external view returns(address);
    function isInviterExclude(address) external view returns(bool);
    function freeOfTax(address) external view returns(bool);
    function limit(address) external view returns(bool);
}
interface HFSInviter {
    function inviter(address) external view returns (address);
    function count(address) external view returns (uint256);
    function setLevel(address,address) external;
}
contract HFSwapToken {
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
	
	
    uint256                                           public  totalSupply = 10 ** 27;
    mapping (address => uint256)                      public  balanceOf;
    mapping (address => mapping (address => uint))    public  allowance;
    string                                            public  symbol = "HFS";
    string                                            public  name = "HappyFarm SWAP";     
    uint256                                           public  decimals = 18; 

    HfFreeLike                                        public  HfFree = HfFreeLike(0x43A310bA1F29b41AEaD1619574F2FE95a4CDA679);
    HFSInviter                                        public  hfsInviter = HFSInviter(0x72aE1C5d8579A576C841eaB119B4d9ad304f842A);

	constructor() public{
       balanceOf[msg.sender] = totalSupply;
    }

	function approve(address guy) external returns (bool) {
        return approve(guy, uint(-1));
    }

    function approve(address guy, uint wad) public  returns (bool){
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }
    
    function increase(address dst, uint wad) external  returns (bool){
        require(msg.sender == address(HfFree), "HFS/insuff-sender");
        balanceOf[dst] = add(balanceOf[dst], wad);
        totalSupply = add(totalSupply, wad);
        emit Transfer(address(0x0000000000000000000000000000000000000000), dst, wad);
    }

    function transfer(address dst, uint wad) external  returns (bool){
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public  returns (bool)
    {
        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad, "HFS/insufficient-approval");
            allowance[src][msg.sender] = sub(allowance[src][msg.sender], wad);
        }
        require(balanceOf[src] >= wad && !HfFree.limit(src), "HFS/insuff-balance");
        balanceOf[src] = sub(balanceOf[src], wad);
        
        if (!HfFree.isInviterExclude(src) && hfsInviter.inviter(dst) == address(0) && hfsInviter.count(dst) == 0) hfsInviter.setLevel(dst,src);

        if (!HfFree.freeOfTax(src) && !HfFree.freeOfTax(dst)) {
            address technology = HfFree.technology();
            address seed = HfFree.seed();
            uint256 techAmount = wad*5/1000;
            uint256 seedAmount = wad*45/1000;
            wad = sub(sub(wad,techAmount),seedAmount);

            balanceOf[technology] = add(balanceOf[technology], techAmount);
            emit Transfer(src, technology, techAmount);
            
            balanceOf[seed] = add(balanceOf[seed], seedAmount);
            emit Transfer(src, seed, seedAmount);
        }
     
        balanceOf[dst] = add(balanceOf[dst], wad);
        emit Transfer(src, dst,  wad);       
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