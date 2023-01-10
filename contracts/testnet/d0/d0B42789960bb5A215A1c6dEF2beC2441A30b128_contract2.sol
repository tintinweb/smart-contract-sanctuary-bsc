/**
 *Submitted for verification at BscScan.com on 2023-01-10
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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() public {
        owner = 0x68FDfAA88d492Ec702e57ff5dF80e250861F0590;
    }

    function CurrentOwner() public view returns (address){
        return owner;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
   }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


interface IERC20 {
    function balanceOf(address _owner) external view returns (uint256);
}

contract contract2 is Ownable {

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    using SafeMath for uint256;
    // deposit
    mapping(address => uint) public nonces;
    address public signAddress = 0x8885e3e0E93A9EE004fDccb9cfd485F5010ee0b5;
    address public tokenAddr = 0xa8D6be52C49b72af84fDD4e17da581eA78229b21; //GOD
    uint256 public constant TYPE_50 = 3; //50 || 50
    address public black = 0xd7E75700b7889D1aAD6F00644F61232153083ABC;
    mapping(uint256 => uint256 ) public orderIds;

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'EXPIRED');
        _;
    }

    event EventDeposit(address indexed from, address indexed token, uint256 amountA, uint256 amountB, uint256 time, uint256 dType);
    event SetToken(address indexed from, address indexed token, uint256 now);
    event SetSignAddress(address indexed from, address indexed signAddress, uint256 now);

  
   function permit(string memory funType, uint256 numID, address spender, address tokenA, uint256 amountA, uint256 amountB, address _target, uint256 dType, uint256 deadline, uint8 v, bytes32 r, bytes32 s) private {
        require(block.timestamp <= deadline, "EXPIRED"); 
        uint256 tempNonce = nonces[spender]; 
        nonces[spender] = nonces[spender].add(1); 
        bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(spender, _target, funType, numID, tokenA, amountA, amountB, dType, deadline, tempNonce))));
        address recoveredAddress = ecrecover(message, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == signAddress, 'INVALID_SIGNATURE');
        }

   function deposit(uint256 numID, address tokenA, uint256 amountA, uint256 amountB, uint256 dType, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
        require(orderIds[numID] == 0,"id has been generated"); 
        require(dType == TYPE_50, "invalid type");  
        permit("deposit", numID, msg.sender, tokenA, amountA, amountB, address(this), dType, deadline, v, r, s); 

        safeTransferFrom(tokenA, msg.sender, black, amountA); 
        safeTransferFrom(tokenAddr, msg.sender, black, amountB);  
        emit EventDeposit(msg.sender, tokenA, amountA, amountB, block.timestamp, dType); 
        orderIds[numID] =  block.number;
        }

     function setToken(address tokenAddress) public onlyOwner{
        require(tokenAddress != address(0),"zero address!");
        tokenAddr = tokenAddress;
         emit SetToken(msg.sender,tokenAddr, now);
    }

    function setSignAddress(address _signAddress) public onlyOwner{
        require(_signAddress != address(0),"zero address!");
        signAddress = _signAddress;
        emit SetSignAddress(msg.sender,signAddress, now);
    }

 



}