/**
 *Submitted for verification at BscScan.com on 2022-12-13
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
        owner = 0x3872a1a80f783F37896f91209fe9387a2d2D0088;
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
    // depositSingle LP
    mapping(address => uint) public nonces;
    address public signAddress = 0x3872a1a80f783F37896f91209fe9387a2d2D0088;
    address public tokenAddr = 0x13B914B74D4A8b5726b7677FaFe9C9414B53A40D; //LP
    mapping(uint256 => uint256 ) public orderIds;
    mapping(uint256 => uint256 ) public orderIdsWithdraw;

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'EXPIRED');
        _;
    }

    event EventDepositSingle(address indexed from, uint256 amount, address tokenA, uint256 time, uint256 day, uint256 numID); 
    event EventWithdrawSingle(address indexed from, address token, uint256 amount, uint256 time, uint256 numID); 
    event SetToken(address indexed from, address indexed token, uint256 now);
    event SetSignAddress(address indexed from, address indexed signAddress, uint256 now);

   //depositSingle function
   function permit(string memory funType, uint256 numID, address spender, address tokenA, uint256 amount, address _target, uint256 deadline, uint8 v, bytes32 r, bytes32 s) private {
        require(block.timestamp <= deadline, "EXPIRED"); 
        uint256 n = nonces[spender]; 
        nonces[spender] = nonces[spender].add(1); 
  
        bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(spender, _target, funType, numID, tokenA, amount, deadline, n))));

        address recoveredAddress = ecrecover(message, v, r, s);

        require(recoveredAddress != address(0) && recoveredAddress == signAddress, 'INVALID_SIGNATURE');
    }

    //withdrawSingle function
     function permit2(string memory funType, uint256 numID, address spender, address tokenA, uint256 amount, address _target, uint256 deadline, uint8 v, bytes32 r, bytes32 s) private {
        require(block.timestamp <= deadline, "EXPIRED"); 
        uint256 n = nonces[spender]; 
        nonces[spender] = nonces[spender].add(1); 
  
        bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(spender, _target, funType, numID, tokenA, amount, deadline, n))));

        address recoveredAddress = ecrecover(message, v, r, s);

        require(recoveredAddress != address(0) && recoveredAddress == signAddress, 'INVALID_SIGNATURE');
    }


    function depositSingle(uint256 amount, uint256 numID, uint256 deadline, uint8 v, bytes32 r, bytes32 s, uint256 day) public ensure(deadline) {
        require(orderIds[numID] == 0,"id has been generated"); 
        permit("depositSingle", numID, msg.sender, tokenAddr, amount,  address(this), deadline, v, r, s); 
        safeTransferFrom(tokenAddr, msg.sender, address(this), amount); 
        emit EventDepositSingle(msg.sender, amount, tokenAddr,block.timestamp, day, numID); 
        orderIds[numID] =  block.number;
    }

    
    function withdrawSingle( uint256 numID, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
       require(orderIdsWithdraw[numID] == 0,"id has been generated");
        require( amount > 0 , "amount0");  
        permit2("withdrawSingle", numID, msg.sender, tokenAddr, amount,  address(this), deadline, v, r, s); 
        safeTransfer(tokenAddr, msg.sender, amount); 
        emit EventWithdrawSingle(msg.sender, tokenAddr, amount, block.timestamp, numID); 
        orderIdsWithdraw[numID] =  block.number;
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