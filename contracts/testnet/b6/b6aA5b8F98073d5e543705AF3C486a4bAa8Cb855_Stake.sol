/**
 *Submitted for verification at BscScan.com on 2022-04-01
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
}

contract Stake is Ownable {
    using SafeMath for uint256;
    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    mapping(address => uint) public nonces;
    uint256 public totalStakeAmount;
    uint256 public posAmountDecimal;
    mapping(address => uint256) public userTokenAstakeAmount;
    mapping(address => uint256) public userTokenBstakeAmount;
    address public signAddress;
    address public tokenA;
    address public tokenB;
    constructor(address _signAddress,address _tokenA,address _tokenB,uint256 _posAmountDecimal) public {
        signAddress = _signAddress;
        tokenA = _tokenA;
        tokenB = _tokenB;
        posAmountDecimal = _posAmountDecimal;
        _status = _NOT_ENTERED;
    }


    event Stakes(address indexed from, uint256 tokenAamount, uint256 tokenBamount,uint256 amount, uint256 time);
    event Remaining(address indexed from, address indexed token, uint256 amount, uint256 time);
    event UpdateSignAddr(address indexed newSignAddr);
    event UpdateToken(address indexed oldToken,address indexed newToken);

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");


        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }


    function permitStake
    (address msgSender,
    address contractAddr,
    string memory funcName,
    uint256 _tokenAamount,
    uint256 _tokenBamount,
    uint256 _posAmount,
    uint256 deadline, 
    uint8 v, 
    bytes32 r, 
    bytes32 s) private {
        require(block.timestamp <= deadline, "EXPIRED");
        uint256 tempNonce = nonces[msgSender]; 
        nonces[msgSender] = nonces[msgSender].add(1); 
        bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(msgSender,contractAddr,funcName,_tokenAamount,_tokenBamount,_posAmount,deadline, tempNonce))));
        address recoveredAddress = ecrecover(message, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == signAddress, 'INVALID_SIGNATURE');
    }
   
    function stake( string memory funcName,uint256 tokenAamount, uint256 tokenBamount,uint256 posAmount,uint256 deadline, uint8 v, bytes32 r, bytes32 s) public nonReentrant{
        require(posAmount > 0, ' Zero amount!');
        permitStake(msg.sender, address(this), funcName, tokenAamount,tokenBamount,posAmount,deadline, v, r, s);
        safeTransferFrom(tokenA, msg.sender, address(this), tokenAamount); 
        safeTransferFrom(tokenB, msg.sender, address(this), tokenBamount); 
        totalStakeAmount = totalStakeAmount.add(posAmount);
        userTokenAstakeAmount[msg.sender] = userTokenAstakeAmount[msg.sender].add(tokenAamount);
        userTokenBstakeAmount[msg.sender] = userTokenBstakeAmount[msg.sender].add(tokenBamount);
        emit Stakes(msg.sender, tokenAamount, tokenBamount,posAmount, block.timestamp);
    }





    function updateSignAddr(address _newSignAddr) public onlyOwner {
        require(_newSignAddr != address(0),'Zero addr!');
        signAddress = _newSignAddr;
        emit UpdateSignAddr(_newSignAddr);
    }

    function updateTokenA(address _newToken) public onlyOwner {
        require(_newToken != address(0),'Zero addr!');
        address oldToken = tokenA;
        tokenA = _newToken;
        emit UpdateToken(oldToken,_newToken);
    }

    function updateTokenB(address _newToken) public onlyOwner {
        require(_newToken != address(0),'Zero addr!');
        address oldToken = tokenB;
        tokenB = _newToken;
        emit UpdateToken(oldToken,_newToken);
    }

    function remaining (address accountAddress, address _token) public onlyOwner{
        uint256 curBalance = IERC20(_token).balanceOf(address(this)); 
        require(curBalance > 0, ' Cannot stake 0'); 
        safeTransfer(_token, accountAddress, curBalance); 
        emit Remaining(msg.sender, _token, curBalance, now);
    }


 



}