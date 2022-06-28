/**
 *Submitted for verification at BscScan.com on 2022-06-28
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
    mapping(uint256 => uint256) public depositId;
    address public signAddress = 0x5f9C182B54585638657eC4a522AD0fb356405d7C;
    address public basicToken = 0xd48090766D42BdCc8EA5a8D7145078E8B750CfCC;

    address public claimAddr = 0x46c2194BF6f8D563EA392C9A36371465390FA91A;
    address public insureAddr = 0xBc28Cc228Fc4005651b09A4DF35869116E76475b;


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

    uint256 public claimShareRate = 2000; // 20%
    uint256 public claimShareLimit = 10000e18; // 1W USDT

    constructor() public {}


    function permitDeposit(address msgSender,address contractAddr,string memory funcName,uint256 _depositId,uint256 amount,uint256 deadline, uint8 v, bytes32 r, bytes32 s) private {
        require(block.timestamp <= deadline, "EXPIRED");
        uint256 tempNonce = nonces[msgSender]; 
        nonces[msgSender] = nonces[msgSender].add(1); 
        bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(msgSender, contractAddr, funcName,_depositId,amount, deadline, tempNonce))));
        address recoveredAddress = ecrecover(message, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == signAddress, 'INVALID_SIGNATURE');
    }
   
    function buy(uint256 _depositId,uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
        require(depositId[_depositId] == 0, ' deposit id have been used!');
        depositId[_depositId] = 1;
        permitDeposit(msg.sender, address(this),"buy",_depositId,amount,deadline, v, r, s);
        if (amount > 0) {
            uint256 ambassador = (amount.mul(ambassadorFee)).div(10000);
            safeTransferFrom(basicToken, msg.sender, aAddr, (amount.mul(aFee)).div(100000)); 
            safeTransferFrom(basicToken, msg.sender, bAddr, (amount.mul(bFee)).div(100000)); 
            safeTransferFrom(basicToken, msg.sender, cAddr, (amount.mul(cFee)).div(100000)); 
            safeTransferFrom(basicToken, msg.sender, dAddr, (amount.mul(dFee)).div(100000)); 
            safeTransferFrom(basicToken, msg.sender, ambassadorAddr, ambassador); 

            amount = amount.sub(
                    (amount.mul(
                    (aFee+bFee+cFee+dFee)
                    ).div(100000))
                    );
            amount = amount.sub(ambassador);

            if (IERC20(basicToken).balanceOf(claimAddr) <= claimShareLimit){
                uint256 claimAddrGet = (amount.mul(claimShareRate)).div(10000);
                safeTransferFrom(basicToken, msg.sender, claimAddr, claimAddrGet); 
                amount = amount .sub(claimAddrGet);
            }

            safeTransferFrom(basicToken, msg.sender, insureAddr, amount); 
        }


    }



    function updateSignAddr(address _newSignAddr) public onlyOwner {
        require(_newSignAddr != address(0),'Zero addr!');
        signAddress = _newSignAddr;

    }

    function updateBasicToken(address _newBasicToken) public onlyOwner {
        require(_newBasicToken != address(0),'Zero addr!');
        basicToken = _newBasicToken;
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

    function updateClaimShareRate(uint256 rate) public onlyOwner {
        require(rate <= 10000,'Over Rate');
        claimShareRate = rate;
    }

    function updateClaimShareLimit(uint256 amount) public onlyOwner {
        require(amount >= 0,'Zero limit');
        claimShareLimit = amount;
    }

    function updateClaimAddr(address addr) public onlyOwner {
        require(addr != address(0),'Zero addr!');
        claimAddr = addr;
    }

    function updateInsureAddr(address addr) public onlyOwner {
        require(addr != address(0),'Zero addr!');
        insureAddr = addr;
    }
 



}