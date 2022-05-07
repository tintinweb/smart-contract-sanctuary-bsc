/**
 *Submitted for verification at BscScan.com on 2022-05-07
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

contract Auction is Ownable {
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
    address public signAddr = 0xD37F6d9c1a257880165cB5D8bf3B9488726f28FC;
    address public basicToken = 0xA28d2850c3daa45eDABaE8B8227c637B3F37B5aD;
    address public usdtToken  = 0x04fDd396F1cae1e3917D3F9367b3957f6Fd38434;
    address public blackAddr = 0xf991f107f619C727C09c764Df77E9b0032541005;
    address public luckyAddr = 0x86C8E8C8d03E71566b7Fb3d94A128f77CC0e0513;
    address public lastRoundAddr = 0x9fb57Ba8D69FF8e9Eb50b2A36743288bBcded544;
    address public netAddr = 0xfc6bf086382405c069D1fdE955b10eC728086BAC;
    address public nodeAddr = 0xB2E7D6c92082d91E6c5596A8d47fBAAbFa612Be3;
    address public stakeAddr = 0x8C2a7498d3117c8D602A6c6fc6a9D1f616d427FE;
    address public fundAddr = 0xcf3b338fF1E09C9576D87eaF7A0bdF56EeaAE7Db;
    address public rootAddr = 0xD37F6d9c1a257880165cB5D8bf3B9488726f28FC;

    constructor()public {}

    function permitBuy(address msgSender,address contractAddr,string memory funcName, uint256 _orderId,address _seller,uint256 _amount0,uint256 _amount1,uint256 deadline, uint8 v, bytes32 r, bytes32 s) private {
        require(block.timestamp <= deadline, "EXPIRED");
        uint256 tempNonce = nonces[msgSender]; 
        nonces[msgSender] = nonces[msgSender].add(1); 
        bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(msgSender, contractAddr, funcName,_orderId,_seller,_amount0,_amount1,deadline, tempNonce))));
        address recoveredAddress = ecrecover(message, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == signAddr, 'INVALID_SIGNATURE');
    }
   
    function buy(uint256 _orderId,address seller,uint256 amount0 ,uint256 amount1, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
        require(orderIds[_orderId] == 0, "buy orderId has been used!");
        orderIds[_orderId] = 1;
        permitBuy(msg.sender,address(this),"buy",_orderId,seller,amount0,amount1,deadline, v, r, s); 
        uint256 dynamic;
        uint256 luckyAddrGet;
        if (seller == rootAddr) {
            safeTransferFrom(usdtToken, msg.sender, seller, amount0);
            safeTransferFrom(basicToken, msg.sender, blackAddr, (amount1.mul(3)).div(9)); 
            dynamic = (amount1.mul(4)).div(9);
            luckyAddrGet = (amount1.mul(2)).div(9);

        }else {
            uint256 premium = ((amount1.mul(109)).div(100)).sub(amount1);
            uint256 sellerGet = amount1.add((premium.mul(3)).div(9));
            dynamic = (premium.mul(4)).div(9);
            luckyAddrGet = (premium.mul(2)).div(9);
            safeTransferFrom(basicToken, msg.sender, seller, sellerGet); 
        }
        safeTransferFrom(basicToken, msg.sender, luckyAddr, luckyAddrGet); 

        safeTransferFrom(basicToken, msg.sender, lastRoundAddr, (dynamic.mul(2000)).div(10000)); 
        safeTransferFrom(basicToken, msg.sender, netAddr, (dynamic.mul(2500)).div(10000)); 
        safeTransferFrom(basicToken, msg.sender, nodeAddr, (dynamic.mul(3000)).div(10000)); 
        safeTransferFrom(basicToken, msg.sender, stakeAddr, (dynamic.mul(2000)).div(10000)); 
        safeTransferFrom(basicToken, msg.sender, fundAddr, (dynamic.mul(500)).div(10000));

    }


    function updateSignAddr(address addr) public onlyOwner {
        require(addr != address(0),'Zero addr!');
        signAddr = addr;
    }

    function updateBasicToken(address _newBasicToken) public onlyOwner {
        require(_newBasicToken != address(0),'Zero addr!');
        basicToken = _newBasicToken;
    }

    function updateUsdtToken(address addr) public onlyOwner {
        require(addr != address(0),'Zero addr!');
        usdtToken = addr;
    }

    function updateBlackAddr(address addr) public onlyOwner {
        require(addr != address(0),'Zero addr!');
        blackAddr = addr;
    }

    function updateLuckyAddr(address addr) public onlyOwner {
        require(addr != address(0),'Zero addr!');
        luckyAddr = addr;
    }

    function updateLastRoundAddr(address addr) public onlyOwner {
        require(addr != address(0),'Zero addr!');
        lastRoundAddr = addr;
    }

    function updateNetAddr(address addr) public onlyOwner {
        require(addr != address(0),'Zero addr!');
        netAddr = addr;
    }

    function updateNodeAddr(address addr) public onlyOwner {
        require(addr != address(0),'Zero addr!');
        nodeAddr = addr;
    }

    function updateStakeAddr(address addr) public onlyOwner {
        require(addr != address(0),'Zero addr!');
        stakeAddr = addr;
    }

    function updateFundAddr(address addr) public onlyOwner {
        require(addr != address(0),'Zero addr!');
        fundAddr = addr;
    }

    function updateRootAddr(address addr) public onlyOwner {
        require(addr != address(0),'Zero addr!');
        rootAddr = addr;
    }

}