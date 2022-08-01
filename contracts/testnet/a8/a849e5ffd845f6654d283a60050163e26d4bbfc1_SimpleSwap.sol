/**
 *Submitted for verification at BscScan.com on 2022-08-01
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

/**
 *Submitted for verification at BscScan.com on 2021-12-17
*/

pragma solidity ^0.5.17;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract Ownable {
    address private owner;
    address private adminer;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() public {
        owner = msg.sender;
    }

    function CurrentOwner() public view returns (address){
        return owner;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


interface IERC20 {
    function balanceOf(address _owner) external view returns (uint256);
    function decimals() external view returns (uint8);
}

contract SimpleSwap is Ownable {
    using SafeMath for uint256;
    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    address public jfToken  = 0x0cD83F9Bc4d1Eab6f5F14845379d09c419F3a10d;
    address public fuelToken = 0xd48090766D42BdCc8EA5a8D7145078E8B750CfCC;
    address public usdt = 0xd48090766D42BdCc8EA5a8D7145078E8B750CfCC;

    uint256 public jfPrice = 5000;
    uint256 public fuelPrice = 4000;
    uint256 public basicPrice = 10000;

    address public usdtReceiver = 0xD37F6d9c1a257880165cB5D8bf3B9488726f28FC;


    constructor() public {}
   
    function swapJf(uint256 amount) public {
        uint256 usdtAmount = (amount.mul(jfPrice)).div(basicPrice);
        uint8 usdtDecimal = IERC20(usdt).decimals();
        uint8 jfTokenDecimal = IERC20(jfToken).decimals();
        if ( usdtDecimal > jfTokenDecimal){
            usdtAmount = usdtAmount.mul(10**(usdtDecimal - jfTokenDecimal));
        }
        if ( jfTokenDecimal > usdtDecimal){
            usdtAmount = usdtAmount.mul(10**(jfTokenDecimal - usdtDecimal));
        }
        safeTransferFrom(usdt, msg.sender, usdtReceiver,usdtAmount); 
        safeTransfer(jfToken, msg.sender, amount);
    }




 



}