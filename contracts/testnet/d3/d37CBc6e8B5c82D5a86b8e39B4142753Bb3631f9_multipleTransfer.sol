/**
 *Submitted for verification at BscScan.com on 2022-09-25
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.8.7;

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
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IRC20 {
    function totalSupply() external view returns (uint supply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    function decimals() external view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract multipleTransfer {
    using SafeMath for uint256;

    /*
        VERY SAFE FOR USE
        
        STEP 1 : approve token to this contract address
        STEP 2 : use function transfer with array of receiver and array of amount
        
        PS : if you need to send float amount, then set params divideDecimal with your decimal place for rounding or just pass 0 for interger

        @Contact : https://t.me/bitodev
    */
    
    function TRANSFER (address tokenAddress, address[] memory receivers, uint256[] memory amount, uint divideDecimal) public {
        require(receivers.length == amount.length, "Length not equal");
        IRC20 token = IRC20(tokenAddress);
        uint256 decimal = token.decimals();
        uint256 approvalAmount = token.allowance(msg.sender, address(this));
        uint256 totalSendAmount = 0;
        for(uint i = 0 ; i < amount.length; i ++) {
            totalSendAmount += amount[i] * (10 ** (decimal - divideDecimal));
        }
        require(approvalAmount >= totalSendAmount, "Exceed token approval amount");

        for(uint i = 0 ; i < receivers.length ; i++) {
            require(token.transferFrom(msg.sender, receivers[i], amount[i] * (10 ** (decimal - divideDecimal))));
        }
    }
}