/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

// SPDX-License-Identifier: Unlicense
pragma solidity >=0.7.0 <0.9.0;

// Contract code designed by @EVMlord for https://tteb.finance

abstract contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}

interface ERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom( address from, address to, uint value) external returns (bool ok);
    function allowance(address owner, address spender) external view returns(uint256);
}


contract aTsunami is Ownable {

    uint256 public feeInETH = 0.02 ether;


	function sendEth(address[] memory _to, uint256[] memory _value) public payable returns (bool _success) {
		// input validation
		assert(_to.length == _value.length);
		assert(_to.length <= 255);
        uint256 fee = (sumOfAllValues(_value) + feeInETH);
        require(msg.value > fee);

        uint256 remain_value = msg.value - feeInETH;

		// loop through to addresses and send value
		for (uint8 i = 0; i < _to.length; i++) {
            require(remain_value >= _value[i]);
            remain_value = remain_value - _value[i];

			payable(_to[i]).transfer(_value[i]);
		}

        payable(owner).transfer(feeInETH);

		return true;
	}

	function sendErc20(address _tokenAddress, address[] memory _to, uint256[] memory _value) public payable returns (bool _success) {
		// input validation
		assert(_to.length == _value.length);
		assert(_to.length <= 255);
        require(msg.value >= feeInETH);

		// use the erc20 abi
		ERC20 token = ERC20(_tokenAddress);
        // loop through to addresses and send value
		for (uint8 i = 0; i < _to.length; i++) {
			assert(token.transferFrom(msg.sender, _to[i], _value[i]) == true);
		}
        payable(owner).transfer(feeInETH);

		return true;
	}


    function sumOfAllValues(uint256[] memory _value) public pure returns(uint256) {
        uint256 sum = 0;
        for (uint256 i = 0 ; i < _value.length ; i++) {
            sum += _value[i];
        }

        return sum;
    }

    function setFeeInETH(uint256 newFeeInETH) public onlyOwner {
        feeInETH = newFeeInETH;
    }

    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) public onlyOwner {
        ERC20(_tokenAddress).transfer(address(msg.sender), _tokenAmount);
        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }
	
	function withdraw() public onlyOwner {
	    require(address(this).balance > 0, 'Contract has no money');
        address payable wallet = payable(msg.sender);
        wallet.transfer(address(this).balance);    
    }  

    event AdminTokenRecovery(address tokenRecovered, uint256 amount);

	receive() external payable {
        address payable wallet = payable(owner);
        wallet.transfer(msg.value);
    }
// Contract code designed by @EVMlord for https://tteb.finance
}