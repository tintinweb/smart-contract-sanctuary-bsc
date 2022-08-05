/**
 *Submitted for verification at BscScan.com on 2022-08-05
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
    address public signAddr = 0xB04842023cb6619d5810af4e0E17eEf7EBBBE58D;
    address public jfToken = 0xbA4D717e148524ADAE0ea8E6123A60221F4C0eB1;
    address public fuelToken = 0x497Dd98488454d7A993921FE77c52Aa1d2e948fB;
    address public usdtToken  = 0x55d398326f99059fF775485246999027B3197955;

    address public claimAddr = 0x297675CCAA1991A4704F51d30079C41CD9263511;
    address public insureAddr = 0x2bbb7e47288bD9Bc964b7F8636898c1421D608Ce;
    address public basicAddr = 0xdB4a59A6bc38930949238020d1779219c8e83D13;

    uint256 public claimShareRate = 2000; // 20%

    uint256 public claimShareLimit = 10000e18; // 1W USDT

    address public aAddr = 0xc9E10f2c5371fBA1a9ccB8E332ef6F37d93696C0;
    address public bAddr = 0x5a43eB2f3e990F8e1E3c64CaF57bfaCd67a30Cbe;
    address public cAddr = 0xC83Da900B8306025cB1c7A71a6acD6C032de364A;
    address public dAddr = 0xb6dD44FF5494f8b2b32f767f4bF533E11F8227c2;
    address public ambassadorAddr = 0x6CbF53B12B11925718Fb186cD9e9a41512990F0f;

    uint256 public ambassadorFee = 150; 

    uint256 public aFee = 1750; 
    uint256 public bFee = 1293; 
    uint256 public cFee = 1188; 
    uint256 public dFee = 769; 



    constructor()public {}

    function permitBuy(address msgSender,address contractAddr,string memory funcName, uint256 _orderId,uint256 _amount0,uint256 _amount1,uint256 _amount2,uint256 deadline, uint8 v, bytes32 r, bytes32 s) private {
        require(block.timestamp <= deadline, "EXPIRED");
        uint256 tempNonce = nonces[msgSender]; 
        nonces[msgSender] = nonces[msgSender].add(1); 
        bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(msgSender, contractAddr, funcName,_orderId,_amount0,_amount1,_amount2,deadline, tempNonce))));
        address recoveredAddress = ecrecover(message, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == signAddr, 'INVALID_SIGNATURE');
    }
   
    function buy(uint256 _orderId,uint256 amount0 ,uint256 amount1, uint256 amount2,uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
        require(orderIds[_orderId] == 0, ' order id have been used!');
        orderIds[_orderId] = 1;
        permitBuy(msg.sender, address(this),"buy",_orderId,amount0,amount1,amount2,deadline, v, r, s);
        if (amount0 > 0) {
            uint256 ambassador = (amount0.mul(ambassadorFee)).div(10000);
            safeTransferFrom(usdtToken, msg.sender, aAddr, (amount0.mul(aFee)).div(100000)); 
            safeTransferFrom(usdtToken, msg.sender, bAddr, (amount0.mul(bFee)).div(100000)); 
            safeTransferFrom(usdtToken, msg.sender, cAddr, (amount0.mul(cFee)).div(100000)); 
            safeTransferFrom(usdtToken, msg.sender, dAddr, (amount0.mul(dFee)).div(100000)); 
            safeTransferFrom(usdtToken, msg.sender, ambassadorAddr, ambassador); 

            amount0 = amount0.sub(
                    (amount0.mul(
                    (aFee+bFee+cFee+dFee)
                    ).div(100000))
                    );
            amount0 = amount0.sub(ambassador);

            if (IERC20(usdtToken).balanceOf(claimAddr) <= claimShareLimit){
                uint256 claimAddrGet = (amount0.mul(claimShareRate)).div(10000);
                safeTransferFrom(usdtToken, msg.sender, claimAddr, claimAddrGet); 
                amount0 = amount0.sub(claimAddrGet);
            }

            safeTransferFrom(usdtToken, msg.sender, insureAddr, amount0); 
        }


        if (amount1 > 0){
            safeTransferFrom(fuelToken, msg.sender, basicAddr,amount1); 
        }

        if (amount2 > 0){
            safeTransferFrom(jfToken, msg.sender, basicAddr,amount2); 
        }


    }


    function updateSignAddr(address addr) public onlyOwner {
        require(addr != address(0),'Zero addr!');
        signAddr = addr;
    }

    function updateFuelToken(address _newFuelToken) public onlyOwner {
        require(_newFuelToken != address(0),'Zero addr!');
        fuelToken = _newFuelToken;
    }

    function updateJfToken(address _newjfToken) public onlyOwner {
        require(_newjfToken != address(0),'Zero addr!');
        jfToken = _newjfToken;
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


    function updateAAddr(address addr) public onlyOwner {
        require(addr != address(0),'Zero addr!');
        aAddr = addr;
    }

    function updateBAddr(address addr) public onlyOwner {
        require(addr != address(0),'Zero addr!');
        bAddr = addr;
    }

    function updateCAddr(address addr) public onlyOwner {
        require(addr != address(0),'Zero addr!');
        cAddr = addr;
    }

    function updateDAddr(address addr) public onlyOwner {
        require(addr != address(0),'Zero addr!');
        dAddr = addr;
    }


    function updateAmbassadorAddr(address addr) public onlyOwner {
        require(addr != address(0),'Zero addr!');
        ambassadorAddr = addr;
    }

    function updateABCDFee(uint256 A,uint256 B,uint256 C,uint256 D) public onlyOwner {
        aFee = A;
        bFee = B;
        cFee = C;
        dFee = D;
    }

    function updateAmbassadorFee(uint256 Fee) public onlyOwner {
        ambassadorFee = Fee;
    }

}