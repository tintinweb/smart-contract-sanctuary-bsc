/**
 *Submitted for verification at BscScan.com on 2022-12-12
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

contract contract4 is Ownable {

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    using SafeMath for uint256;
    //
    mapping(address => uint) public nonces;
    address signAddress = 0x3872a1a80f783F37896f91209fe9387a2d2D0088;
    address tokenAddr = 0x12e3761575f0D681E767CFe676c5746A9BF39f4B; //nMER 
    address black = 0x7d1C99CDafD6960f5a6F26Fcd74003b1f386BB25; //black
    uint256 constant TYPE_80 = 5; //80-20
    uint256 constant TYPE_40 = 4; //40-60
    mapping(uint256 => uint256 ) public orderIds;


    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'EXPIRED');
        _;
    }

  
    event EventDeposit(address indexed from, address indexed token, uint256 amountA, uint256 amountB, uint256 time, uint256 dType, uint256 numID);
    event Remaining(address indexed from, address indexed token, uint256 amount, uint256 time);
    event SetToken(address indexed from, address indexed token, uint256 now);
    event SetSignAddress(address indexed from, address indexed signAddress, uint256 now);
    event SetBlack(address indexed from, address indexed black, uint256 now);


   function permit(string memory funType, uint256 numID, address spender, address tokenA, uint256 amountA, uint256 amountB, address _target, uint256 dType, uint256 deadline, uint8 v, bytes32 r, bytes32 s) private {
        require(block.timestamp <= deadline, "EXPIRED"); 
        uint256 n = nonces[spender]; 
        nonces[spender] = nonces[spender].add(1); 
  
        bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(spender, _target, funType, numID, tokenA, amountA, amountB, dType, deadline, n))));

        address recoveredAddress = ecrecover(message, v, r, s);

        require(recoveredAddress != address(0) && recoveredAddress == signAddress, 'INVALID_SIGNATURE');
        }


    
    function deposit(uint256 numID, address tokenA, uint256 amountA, uint256 amountB, uint256 dType, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
        require(dType == TYPE_80 || dType == TYPE_40, "invalid type");  
        require(orderIds[numID] == 0,"id has been generated"); 
        permit("deposit", numID, msg.sender, tokenA, amountA, amountB, address(this),  dType, deadline, v, r, s); 
        safeTransferFrom(tokenAddr, msg.sender, black, amountA); 
        safeTransferFrom(tokenA, msg.sender, black, amountB);  
        emit EventDeposit(msg.sender, tokenA, amountA, amountB, block.timestamp, dType, numID); 
        orderIds[numID] =  block.number;
        }

    

    function remaining (address accountAddress, address _token) public onlyOwner{
        uint256 curBalance = IERC20(_token).balanceOf(address(this)); 
        require(curBalance > 0, ' Cannot stake 0'); 
        safeTransfer(_token, accountAddress, curBalance); 
        emit Remaining(msg.sender, _token, curBalance, now);
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

    function setBlack(address _black) public onlyOwner{
        black = _black;
        emit SetBlack(msg.sender,black, now);
    }


}