/**
 *Submitted for verification at BscScan.com on 2022-09-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

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

contract Center is Ownable {
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
    mapping(uint256 => uint256) public orderIds;
    address public signAddr = 0x5f9C182B54585638657eC4a522AD0fb356405d7C;
    address public token0  = 0xd48090766D42BdCc8EA5a8D7145078E8B750CfCC;
    address public token1  = 0x51D05057a2179763B2004D1F5420E6d26909A8C7;
    address public token2  = 0x51D05057a2179763B2004D1F5420E6d26909A8C7;
    address public insureAddr = 0x9e786b2711Dfdf85d2f6633a51f1A1b7F4f3c1b1;




    constructor()public {}

    function permitBuy(address msgSender,address contractAddr,string memory funcName, uint256 _orderId,uint256 _amount0,uint256 _amount1,uint256 _amount2,uint256 deadline, uint8 v, bytes32 r, bytes32 s) private {
        require(block.timestamp <= deadline, "EXPIRED");
        uint256 tempNonce = nonces[msgSender]; 
        nonces[msgSender] = nonces[msgSender].add(1); 
        bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(msgSender, contractAddr, funcName,_orderId,_amount0,_amount1,_amount2,deadline, tempNonce))));
        address recoveredAddress = ecrecover(message, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == signAddr, 'INVALID_SIGNATURE');
    }
   
    function buy(uint256 _orderId,uint256 amount0 ,uint256 amount1,uint256 amount2,uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
        require(orderIds[_orderId] == 0, "buy orderId has been used!");
        orderIds[_orderId] = 1;
        permitBuy(msg.sender,address(this),"buy",_orderId,amount0,amount1,amount2,deadline, v, r, s); 
        if (amount0 > 0){
            safeTransferFrom(token0, msg.sender, insureAddr,amount0); 
        }
        if (amount1 > 0){
            safeTransferFrom(token1, msg.sender, insureAddr,amount1); 
        }
        if (amount2 > 0){
            safeTransferFrom(token2, msg.sender, insureAddr,amount2); 
        }

    }


    function updateSignAddr(address addr) public onlyOwner {
        require(addr != address(0),'Zero addr!');
        signAddr = addr;
    }

    function updateToken0(address addr) public onlyOwner {
        require(addr != address(0),'Zero addr!');
        token0 = addr;
    }
    function updateToken1(address addr) public onlyOwner {
        require(addr != address(0),'Zero addr!');
        token1 = addr;
    }
    function updateToken2(address addr) public onlyOwner {
        require(addr != address(0),'Zero addr!');
        token2 = addr;
    }


    function updateInsureAddr(address addr) public onlyOwner {
        require(addr != address(0),'Zero addr!');
        insureAddr = addr;
    }



}