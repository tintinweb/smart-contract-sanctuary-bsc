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
    mapping(uint256 => uint256) public claimId;
    address public signAddress;
    address public basicToken;
    address public usdtToken;
    address public luckyPoolAddress;
    address public pancakeBuyer;
    address public usdtAwardPoolAddress;
    address public netAwardPoolAddress;
    address public holderAwardPoolAddress;
    constructor(
        address _signAddress,
        address _basicToken,
        address _usdtToken,
        address _luckyPoolAddress,
        address _pancakeBuyer,
        address _usdtAwardPoolAddress,
        address _netAwardPoolAddress,
        address _holderAwardPoolAddress
        )public {
        signAddress = _signAddress;
        basicToken = _basicToken;
        usdtToken = _usdtToken;
        luckyPoolAddress = _luckyPoolAddress;
        pancakeBuyer = _pancakeBuyer;
        usdtAwardPoolAddress = _usdtAwardPoolAddress;
        netAwardPoolAddress = _netAwardPoolAddress;
        holderAwardPoolAddress = _holderAwardPoolAddress;
        
    }


    event Claim(address indexed from, address indexed token, uint256 amout,uint256 claimId);
    event Buy(address indexed buyer, address indexed seller,uint256 amount, uint256 time);
    event Remaining(address indexed from, address indexed token, uint256 amount, uint256 time);
    event UpdateSignAddr(address indexed newSignAddr);
    event UpdateBasicToken(address indexed newBasicToken);
    event Burn(address indexed burnUser, address indexed token, uint256 amout);
    event NewAdminAddress(address admin);

    function permitBuy(address msgSender,address contractAddr,string memory funcName,address _seller,uint256 _basicTokenAmount,uint256 price, uint256 amount,uint256 deadline, uint8 v, bytes32 r, bytes32 s) private {
        require(block.timestamp <= deadline, "EXPIRED");
        uint256 tempNonce = nonces[msgSender]; 
        nonces[msgSender] = nonces[msgSender].add(1); 
        bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(msgSender, contractAddr, funcName,_seller,_basicTokenAmount,price,amount,deadline, tempNonce))));
        address recoveredAddress = ecrecover(message, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == signAddress, 'INVALID_SIGNATURE');
    }
   
    function buy(string memory funcName,address seller,uint256 basicTokenAmount ,uint256 price, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
        require(amount > 0, ' Zero amount!');
        permitBuy(msg.sender,address(this),funcName,seller,basicTokenAmount,price,amount,deadline, v, r, s); 
        uint256 premium = amount.sub(price);
        uint256 sellerGet = price.add((premium.mul(2)).div(9));
        uint256 dynamic = (premium.mul(5)).div(9);
        uint256 luckyPoolGet = (premium.mul(2)).div(9);

        safeTransferFrom(basicToken, msg.sender, address(this), basicTokenAmount); 
        safeTransferFrom(usdtToken, msg.sender, seller, sellerGet); 
        safeTransferFrom(usdtToken, msg.sender, luckyPoolAddress, luckyPoolGet); 

        safeTransferFrom(usdtToken, msg.sender, pancakeBuyer, (dynamic.mul(3000)).div(10000)); 
        safeTransferFrom(usdtToken, msg.sender, usdtAwardPoolAddress, (dynamic.mul(3000)).div(10000)); 
        safeTransferFrom(usdtToken, msg.sender, netAwardPoolAddress, (dynamic.mul(2500)).div(10000)); 
        safeTransferFrom(usdtToken, msg.sender, holderAwardPoolAddress, (dynamic.mul(1000)).div(10000)); 
        emit Buy(msg.sender, seller,amount, block.timestamp);
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

 



}