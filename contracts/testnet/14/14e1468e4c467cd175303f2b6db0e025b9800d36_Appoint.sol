/**
 *Submitted for verification at BscScan.com on 2022-09-15
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

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
  }
}


interface IERC20 {
    function balanceOf(address _owner) external view returns (uint256);
}

contract Appoint is Ownable {
    using SafeMath for uint256;
    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    mapping(address => uint) public nonces;
    mapping(uint256 => uint256) public depositId;

    address public signAddress = 0x33642fd9be647fbf084bE099Ce7aA32c08023DD9;
    address public basicToken = 0x49D8eF67F99e755AA81e4ed104E2a454723c6172;
    address public receiver = 0x05009559CE854f45048EECaF72B6Ecbb7385B8c9;
    constructor() public {

    }

    modifier onlyReceiver(){
        require(msg.sender == receiver, "caller is not the receiver");
        _;
    }

        modifier onlySigner(){
        require(msg.sender == signAddress, "caller is not the signer");
        _;
    }

    event Deposit(address indexed from, uint256 amount, address indexed token, uint256 time);



    function permitDeposit(address msgSender,address contractAddr,string memory funcName,uint256 _depositId,uint256 amount,uint256 deadline, uint8 v, bytes32 r, bytes32 s) private {
        require(block.timestamp <= deadline, "EXPIRED");
        uint256 tempNonce = nonces[msgSender]; 
        nonces[msgSender] = nonces[msgSender].add(1); 
        bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(msgSender, contractAddr, funcName,_depositId,amount, deadline, tempNonce))));
        address recoveredAddress = ecrecover(message, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == signAddress, 'INVALID_SIGNATURE');
    }
   
    function deposit(uint256 _depositId,uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
        require(depositId[_depositId] == 0, ' Zero amount!');
        depositId[_depositId] = 1;
        permitDeposit(msg.sender, address(this),"deposit",_depositId,amount,deadline, v, r, s);
        safeTransferFrom(basicToken, msg.sender, receiver, amount); 
        emit Deposit(msg.sender, amount, basicToken, block.timestamp);
    }



    function updateSignAddr(address _newSignAddr) public onlySigner {
        require(_newSignAddr != address(0),'Zero addr!');
        signAddress = _newSignAddr;

    }

    function updateBasicToken(address _newBasicToken) public onlySigner {
        require(_newBasicToken != address(0),'Zero addr!');
        basicToken = _newBasicToken;

    }

    function updateReceiver(address addr) public onlyReceiver {
        require(addr != address(0),'Zero addr!');
        receiver = addr;

    }


}