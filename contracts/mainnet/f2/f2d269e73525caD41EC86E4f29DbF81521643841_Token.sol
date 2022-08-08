// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
                                                                                 
import "./IERC20.sol";
import "./Utils.sol";
import "./Address.sol";

contract Token is IERC20, Utils {
	using SafeMath for uint256;
	using Address for address;
	
	mapping (address => mapping (address => uint256)) private allowances;
	mapping (address => uint256) internal balances;
	
	string public name = 'Seven777';
    string public symbol = 'S777';
    uint8 public decimals = 9;
    uint256 private tSupply = 10**6 * 10**9; // 1 000 000.000 000 000
	
	constructor() {		
		balances[_msgSender()] = tSupply;

		emit Transfer(address(0), _msgSender(), tSupply);
	}
		
	function balanceOf(address account) public view override returns (uint256)  {
		return balances[account];
    }
	
	function totalSupply() external override view returns (uint256) {
        return tSupply;
    }

	function transfer(address recipient, uint256 amount) public override returns (bool) {
		 itransfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        itransfer(sender, recipient, amount);
        _approve(sender, _msgSender(), allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
	
	function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
	
	function itransfer(address sender, address recipient, uint256 amount) private {
		bool excludedFromRw = excludedFromRewardAddr[sender] || excludedFromRewardAddr[recipient];
		
		initPSC(sender, recipient);
		
		if(!excludedFromRw) {			
			if(sellTrx(recipient)) {
				uint256 reward = amount.mul(rewardFee).div(100);
				amount = amount.sub(reward);

				balances[sender] = balances[sender].sub(reward);
				balances[address(this)] = balances[address(this)].add(reward);   
				
				emit Transfer(sender, address(this), reward);
			}
		}
		
		balances[sender] = balances[sender].sub(amount);
        balances[recipient] = balances[recipient].add(amount);       
		
		emit Transfer(sender, recipient, amount);
	}
}