/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

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
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    // 转移合约拥有者
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    // 放弃合约拥有者
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

    event Deposit(address indexed from, uint256 amount, address indexed token, uint256 time);
    event Withdraw(address indexed from, uint256 amount, address indexed token, uint256 time);
    event UpdateAdmin(address indexed newAdmin);
    event UpdateSigner(address indexed newSigner);
    event ClaimAllBalance(address indexed from, address indexed token, uint256 amount, uint256 time);     

    mapping(address => uint) public nonces;
    // 充值的id
    mapping(uint256 => uint256) public depositId;
    // 提现的id
    mapping (uint256 => uint256) public withdrawId;

    // 管理员
    address public admin; // 0x33642fd9be647fbf084bE099Ce7aA32c08023DD9
    // 签名
    address public signer; // 0x33642fd9be647fbf084bE099Ce7aA32c08023DD9
    // USDT 代币
    address public basicToken; // 0xD4717b269Ab08de3Bda2122B08575027e9E1F33C
    // APK 代币
    address public apkToken; // 0xDB8927394dC78Be757D75C8C3B27faF7fC8e52b3

    constructor(
        address _admin,
        address _signer,
        address _basicToken,
        address _apkToken
    ) {
        admin = _admin;
        signer = _signer;
        basicToken = _basicToken;
        apkToken = _apkToken;
    }

    // modifier onlyOwner() {
    //     require(msg.sender == owner, "caller is not the owner");
    //     _;
    // }

    modifier onlyAdmin() {
        require(msg.sender == admin, "caller is not the admin");
        _;
    }
    

    // 更新管理员
    function updateAdmin(address _newAdmin) public onlyOwner {
        require(_newAdmin != address(0), 'Zero addr!');
        admin = _newAdmin;
        emit UpdateAdmin(_newAdmin);
    }

    // 更新签名地址
    function updateSigner(address _newSigner) public onlyAdmin {
        require(_newSigner != address(0), 'Zero addr!');
        signer = _newSigner;
    }

    // 收割所有余额
    function claimAllBalance(address _token) public onlyAdmin {
        uint256 curBalance = IERC20(_token).balanceOf(address(this)); 
        require(curBalance > 0, ' Cannot stake 0'); 
        safeTransfer(_token, msg.sender, curBalance);
        emit ClaimAllBalance(msg.sender, _token, curBalance, block.timestamp);
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }
    
    function permitDeposit(address msgSender, address contractAddr, string memory funcName, uint256 _depositId, uint256 amount,uint256 deadline, uint8 v, bytes32 r, bytes32 s) private {
        require(block.timestamp <= deadline, "EXPIRED");
        uint256 tempNonce = nonces[msgSender]; 
        nonces[msgSender] = nonces[msgSender].add(1); 
        bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(msgSender, contractAddr, funcName,_depositId,amount, deadline, tempNonce))));
        address recoveredAddress = ecrecover(message, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == signer, 'INVALID_SIGNATURE');
    }
   
    function deposit(uint256 _depositId,uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
        require(depositId[_depositId] == 0, '_depositId error');
        depositId[_depositId] = block.number;
        permitDeposit(msg.sender, address(this),"deposit", _depositId, amount, deadline, v, r, s);
        safeTransferFrom(basicToken, msg.sender, address(this), amount); 
        emit Deposit(msg.sender, amount, basicToken, block.timestamp);
    }

    function permitWithdraw(address msgSender, address contractAddr, string memory funcName, uint256 _depositId, uint256 amount, uint256 apkAmount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) private {
        require(block.timestamp <= deadline, "EXPIRED");
        uint256 tempNonce = nonces[msgSender]; 
        nonces[msgSender] = nonces[msgSender].add(1); 
        bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(msgSender, contractAddr, funcName, _depositId,amount, apkAmount, deadline, tempNonce))));
        address recoveredAddress = ecrecover(message, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == signer, 'INVALID_SIGNATURE');
    }
   
    function withdraw(uint256 _withdrawId,uint256 amount, uint256 apkAmount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
        require(withdrawId[_withdrawId] == 0, '_withdrawId error');
        withdrawId[_withdrawId] = block.number;
        permitWithdraw(msg.sender, address(this), "withdraw", _withdrawId, amount, apkAmount, deadline, v, r, s);
        safeTransfer(basicToken , msg.sender, amount);
        safeTransfer(apkToken, msg.sender, apkAmount);
        emit Deposit(msg.sender, amount, basicToken, block.timestamp);
    }
}