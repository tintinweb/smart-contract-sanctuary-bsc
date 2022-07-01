/**
 *Submitted for verification at BscScan.com on 2022-07-01
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

contract ITCCenter is Ownable {
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
    address public signAddr = 0xcbE6bdE2ca85D118645b88d5f5Ef4Fa24f620f3D;
    address public basicToken = 0x8747b0C7366C227748C38615ad060B243AFF76a6;
    address public usdtToken  = 0x55d398326f99059fF775485246999027B3197955;

    address public claimAddr = 0x4ead45f975fc4DdecFB23191C93f0D1232774889;
    address public insureAddr = 0x84fe498D221Ae55b011C8e05C4bb610cA7D1AfB3;
    address public basicAddr = 0x64b009359ce41EaE4242C6929B179A2e8cFa68ed;

    uint256 public claimShareRate = 2000; // 20%

    uint256 public claimShareLimit = 10000e18; // 1W USDT



    constructor()public {}

    function permitBuy(address msgSender,address contractAddr,string memory funcName, uint256 _orderId,uint256 _amount0,uint256 _amount1,uint256 deadline, uint8 v, bytes32 r, bytes32 s) private {
        require(block.timestamp <= deadline, "EXPIRED");
        uint256 tempNonce = nonces[msgSender]; 
        nonces[msgSender] = nonces[msgSender].add(1); 
        bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(msgSender, contractAddr, funcName,_orderId,_amount0,_amount1,deadline, tempNonce))));
        address recoveredAddress = ecrecover(message, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == signAddr, 'INVALID_SIGNATURE');
    }
   
    function buy(uint256 _orderId,uint256 amount0 ,uint256 amount1, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
        require(orderIds[_orderId] == 0, "buy orderId has been used!");
        orderIds[_orderId] = 1;
        permitBuy(msg.sender,address(this),"buy",_orderId,amount0,amount1,deadline, v, r, s); 
        if (amount0 > 0){
            if (IERC20(usdtToken).balanceOf(claimAddr) <= claimShareLimit){
                uint256 claimShare = (amount0.mul(claimShareRate)).div(10000);
                safeTransferFrom(usdtToken, msg.sender, claimAddr,claimShare); 
                amount0 = amount0.sub(claimShare);
            }
            
            safeTransferFrom(usdtToken, msg.sender, insureAddr,amount0); 
        }
        safeTransferFrom(basicToken, msg.sender, basicAddr,amount1); 


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

    function updateClaimAddr(address addr) public onlyOwner {
        require(addr != address(0),'Zero addr!');
        claimAddr = addr;
    }

    function updateInsureAddr(address addr) public onlyOwner {
        require(addr != address(0),'Zero addr!');
        insureAddr = addr;
    }

    function updateBasicAddr(address addr) public onlyOwner {
        require(addr != address(0),'Zero addr!');
        basicAddr = addr;
    }

    function updateClaimShareRate(uint256 rate) public onlyOwner {
        require(rate <= 10000,'Over Rate');
        claimShareRate = rate;
    }

    function updateClaimShareLimit(uint256 amount) public onlyOwner {
        require(amount >= 0,'Zero limit');
        claimShareLimit = amount;
    }


}