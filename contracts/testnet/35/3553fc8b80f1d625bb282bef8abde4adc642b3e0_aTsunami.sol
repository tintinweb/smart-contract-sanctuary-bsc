/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

pragma solidity >=0.7.0 <0.9.0;
// SPDX-License-Identifier: Unlicense

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns(bool);
    function balanceOf(address account) external view returns(uint256);
    function allowance(address owner, address spender) external view returns(uint256);
    function transfer(address to, uint256 value) external returns (bool);
    
}

contract aTsunami {
	mapping (address => bool) public isStables;
	address payable treasury;
    address internal owner;
	uint256 public COST_IN_ETHER = 0.02 ether;
	uint256 public COST_IN_STABLES = 10 ether;
    
    constructor(address payable _treasury) {
        treasury = payable(_treasury);
        owner = payable(msg.sender);
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    function bulkAirDrop(IERC20 _token, address[] memory _to, uint256[] memory _value, address _baseToken) public payable returns (bool _success) {
        require(_to.length == _value.length, "Recievers and amounts are not the same");
        require(_token.allowance(msg.sender, address(this)) > sumOfAllValues(_value), "Allowance given to contract is not correct");
		
		if (isStables[_baseToken] = true) {
		IERC20 currencyToken = IERC20(_baseToken);
		require(currencyToken.allowance(address(msg.sender),address(this))>= COST_IN_STABLES);
		IERC20(currencyToken).transferFrom(address(msg.sender), address(treasury), COST_IN_STABLES);
		} else {
        require(msg.value >= COST_IN_ETHER);   
		}
        
		for (uint256 i = 0 ; i < _to.length ; i++) {
            _token.transferFrom(msg.sender, _to[i], _value[i]);
        }
		
		return true;
    }

    function sumOfAllValues(uint256[] memory _value) public pure returns(uint256) {
        uint256 sum = 0;
        for (uint256 i = 0 ; i < _value.length ; i++) {
            sum += _value[i];
        }

        return sum;
    }
	
	function disperseEther(address[] memory recipients, uint256[] memory values, address _baseToken) external payable returns (bool _success) {
		// input validation
		assert(recipients.length == values.length);
        uint256 totalqty = sumOfAllValues(values);
		
		if (isStables[_baseToken] = true) {
		IERC20 currencyToken = IERC20(_baseToken);
		require(currencyToken.allowance(address(msg.sender),address(this))>= COST_IN_STABLES);
		IERC20(currencyToken).transferFrom(address(msg.sender), address(treasury), COST_IN_STABLES);
		} else {
        require(msg.value >= (totalqty + COST_IN_ETHER));   
		}
		
		for (uint256 i = 0; i < recipients.length; i++) {
            payable(recipients[i]).transfer(values[i]);
        }
		
		return true;
    }
	
    function setIsStables(address currencyToken, bool state) public onlyOwner {
		isStables[currencyToken] = state;
    }

    function updateCosts(uint256 newCostInETH, uint256 newCostInUSD) public onlyOwner {
        COST_IN_ETHER = newCostInETH;
        COST_IN_STABLES = newCostInUSD;
    }

    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) public onlyOwner {
        IERC20(_tokenAddress).transfer(address(msg.sender), _tokenAmount);
        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }
	
	function withdraw() public onlyOwner {
	    require(address(this).balance > 0, 'Contract has no money');
        address payable wallet = payable(msg.sender);
        wallet.transfer(address(this).balance);    
    }  

    event AdminTokenRecovery(address tokenRecovered, uint256 amount);

	receive() external payable {}
}