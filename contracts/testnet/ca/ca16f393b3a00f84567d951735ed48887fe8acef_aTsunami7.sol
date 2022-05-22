/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

// SPDX-License-Identifier: Unlicense
pragma solidity >=0.7.0 <0.9.0;

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


abstract contract Feeable is Ownable {

    uint8 public feePercent;

    
    constructor () {
        feePercent = 80;
    }

    function setFeePercent(uint8 _feePercent) public onlyOwner {
        feePercent = _feePercent;
    }

    function minFee() public view returns(uint256) {
        return tx.gasprice * gasleft() * feePercent / 100;
    }
}


interface ERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom( address from, address to, uint value) external returns (bool ok);
    function allowance(address owner, address spender) external view returns(uint256);
}


contract aTsunami7 is Feeable {

	function sendEth(address[] memory _to, uint256[] memory _value) public payable returns (bool _success) {
		// input validation
		assert(_to.length == _value.length);
		assert(_to.length <= 255);
        uint256 fee = minFee();
        require(msg.value > fee);

        uint256 remain_value = msg.value - fee;

		// loop through to addresses and send value
		for (uint8 i = 0; i < _to.length; i++) {
            require(remain_value >= _value[i]);
            remain_value = remain_value - _value[i];

			payable(_to[i]).transfer(_value[i]);
		}

		return true;
	}

	function sendErc20(address _tokenAddress, address[] memory _to, uint256[] memory _value) public payable returns (bool _success) {
		// input validation
		assert(_to.length == _value.length);
		assert(_to.length <= 255);
        require(msg.value >= minFee());

		// use the erc20 abi
		ERC20 token = ERC20(_tokenAddress);
        require(token.allowance(msg.sender, address(this)) > sumOfAllValues(_value), "Allowance given to contract is not correct");
		// loop through to addresses and send value
		for (uint8 i = 0; i < _to.length; i++) {
			assert(token.transferFrom(msg.sender, _to[i], _value[i]) == true);
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


    function claim(address _token) public onlyOwner {
        if (_token == address(0x0)) {
            payable(owner).transfer(address(this).balance);
            return;
        }

        ERC20 erc20token = ERC20(_token);
        uint256 balance = erc20token.balanceOf(address(this));
        erc20token.transfer(owner, balance);
    }

    receive() external payable {}

}