/**
 *Submitted for verification at BscScan.com on 2022-08-31
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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() public {
        owner = 0x2d71AdEcB7A4F75f7FB21816A980caC307D276d9;
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
interface ERC721 {
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;

    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
}

contract contract3 is Ownable {

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    using SafeMath for uint256;
    // depositSingle LP
    mapping(address => uint) public nonces;
    address public signAddress = 0x3872a1a80f783F37896f91209fe9387a2d2D0088;
    mapping(uint256 => uint256 ) public orderIds;
    mapping(uint256 => uint256 ) public orderIdsWithdraw;

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'EXPIRED');
        _;
    }

    event EventDepositSingle(address indexed from, uint256 tokenID, address tokenA, uint256 time); 
    event EventWithdrawSingle(address indexed from, address token, uint256 tokenID, uint256 time, uint256 numID); 
    event SetToken(address indexed from, address indexed token, uint256 now);
    event SetSign(address indexed from, address indexed addr, uint256 now);

   //depositSingle function
   function permit(string memory funcName, uint256 numID, address caller, address tokenNFT, uint256 tokenID, address _contract, uint256 deadline, uint8 v, bytes32 r, bytes32 s) private {
        require(block.timestamp <= deadline, "EXPIRED"); 
        uint256 tempNonce = nonces[caller]; 
        nonces[caller] = nonces[caller].add(1); 
  
        bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(caller, _contract, funcName, numID, tokenNFT, tokenID, deadline, tempNonce))));

        address recoveredAddress = ecrecover(message, v, r, s);

        require(recoveredAddress != address(0) && recoveredAddress == signAddress, 'INVALID_SIGNATURE');
    }

    //withdrawSingle function
     function permit2(string memory funcName, uint256 numID, address caller, address tokenNFT, uint256 tokenID, address _contract, uint256 deadline, uint8 v, bytes32 r, bytes32 s) private {
        require(block.timestamp <= deadline, "EXPIRED"); 
        uint256 tempNonce = nonces[caller]; 
        nonces[caller] = nonces[caller].add(1); 
  
        bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(caller, _contract, funcName, numID, tokenNFT, tokenID, deadline, tempNonce))));

        address recoveredAddress = ecrecover(message, v, r, s);

        require(recoveredAddress != address(0) && recoveredAddress == signAddress, 'INVALID_SIGNATURE');
    }


    function depositSingle(uint256 tokenID, address tokenNFT, uint256 numID, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public ensure(deadline) {
        require(orderIds[numID] == 0,"id has been generated"); 
        permit("depositSingle", numID, msg.sender, tokenNFT, tokenID,  address(this), deadline, v, r, s); 
        ERC721(tokenNFT).transferFrom(msg.sender, address(this), tokenID); 
        emit EventDepositSingle(msg.sender, tokenID, tokenNFT, block.timestamp); 
         orderIds[numID] =  block.number;
    }

    function withdrawSingle( uint256 tokenID, address tokenNFT, uint256 numID, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
        require(orderIdsWithdraw[numID] == 0,"id has been generated");
        permit2("withdrawSingle", numID, msg.sender, tokenNFT, tokenID,  address(this), deadline, v, r, s); 
        ERC721(tokenNFT).transferFrom(address(this),msg.sender,tokenID); 
        emit EventWithdrawSingle(msg.sender, tokenNFT, tokenID, block.timestamp, numID); 
         orderIdsWithdraw[numID] =  block.number;
    }

    //set signAddress
    function setSign(address signAddr) public onlyOwner{
        require(signAddr != address(0),"zero signAddr!");
        signAddress = signAddr;
        emit SetSign(msg.sender,signAddress, now);
    }

 



}