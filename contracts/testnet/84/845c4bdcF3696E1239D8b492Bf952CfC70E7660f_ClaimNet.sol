/**
 *Submitted for verification at BscScan.com on 2022-04-05
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

contract ClaimNet is Ownable {
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
    mapping(uint256 => uint256) public claimId;
    mapping(uint256 => uint256) public burnId;
    address public signAddress;
    address public basicToken;
    address public adminAddress;
    address public luckyAddress;
    constructor(address _signAddress,address _basicToken,address _adminAddress,address _luckyAddress) public {
        signAddress = _signAddress;
        basicToken = _basicToken;
        adminAddress = _adminAddress;
        luckyAddress = _luckyAddress;
    }

    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "Not admin");
        _;
    }


    event Claim(address indexed from, address indexed token, uint256 amout,uint256 claimId);
    event Remaining(address indexed from, address indexed token, uint256 amount, uint256 time);
    event Burn(address indexed burnUser, address indexed token, uint256 amout,uint256 burnId);
    event UpdateSignAddr(address indexed newSignAddr);
    event UpdateBasicToken(address indexed newBasicToken);
    event NewAdminAddress(address admin);
    event NewLuckyAddress(address admin);

    function permitClaim(address msgSender,address contractAddr,string memory funcName,uint256 _claimId,uint256 amount,uint256 deadline, uint8 v, bytes32 r, bytes32 s) private {
        require(block.timestamp <= deadline, "EXPIRED");
        uint256 tempNonce = nonces[msgSender]; 
        nonces[msgSender] = nonces[msgSender].add(1); 
        bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(msgSender, contractAddr, funcName, _claimId,amount, deadline, tempNonce))));
        address recoveredAddress = ecrecover(message, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == signAddress, 'INVALID_SIGNATURE');
    }
   

    function claim( uint256 _claimId,uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
        require(claimId[_claimId] == 0,"claim id have been used");
        claimId[_claimId] = 1;
        permitClaim(msg.sender, address(this),"claim",_claimId,amount,deadline, v, r, s);
        safeTransfer(basicToken, msg.sender, amount); 
        emit Claim(msg.sender, basicToken, amount,_claimId);
    }

    function burn( uint256 _burnId,address burnUser,uint256 amount) public onlyAdmin{
        require(burnId[_burnId] == 0,"burn id have been used");
        burnId[_burnId] = 1;
        safeTransfer(basicToken, luckyAddress, amount); 
        emit Burn(burnUser, basicToken, amount,_burnId);
    }


    function updateSignAddr(address _newSignAddr) public onlyOwner {
        require(_newSignAddr != address(0),'Zero addr!');
        signAddress = _newSignAddr;
        emit UpdateSignAddr(_newSignAddr);
    }

    function updateBasicToken(address _newBasicToken) public onlyOwner {
        require(_newBasicToken != address(0),'Zero addr!');
        basicToken = _newBasicToken;
        emit UpdateBasicToken(_newBasicToken);
    }

    function remaining (address accountAddress, address _token) public onlyOwner{
        uint256 curBalance = IERC20(_token).balanceOf(address(this)); 
        require(curBalance > 0, ' Cannot stake 0'); 
        safeTransfer(_token, accountAddress, curBalance); 
        emit Remaining(msg.sender, _token, curBalance, now);
    }

    function setAdmin(address _adminAddress) external onlyOwner {
        require(_adminAddress != address(0), "Cannot be zero address");
        adminAddress = _adminAddress;

        emit NewAdminAddress(_adminAddress);
    }

    function setLuckyAddr(address _luckyAddress) external onlyOwner {
        require(_luckyAddress != address(0), "Cannot be zero address");
        luckyAddress = _luckyAddress;

        emit NewLuckyAddress(_luckyAddress);
    }


 



}