/**
 *Submitted for verification at BscScan.com on 2022-08-30
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

contract contract1 is Ownable {

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    using SafeMath for uint256;
    // buy NFT
    mapping(address => uint) public nonces;
    address public signAddress = 0x3872a1a80f783F37896f91209fe9387a2d2D0088;
    address public tokenUSDT = 0xB195C90253927B941A96B59a2E38ABfa1dC3F69a; //USDT
    address public bonusPoolAddr = 0x2d71AdEcB7A4F75f7FB21816A980caC307D276d9; //bonus
    address public destroyAddr = 0xE3b0fd7Bc5C98878eB24C96DEc3b73D1A8703184; //destro
    address public rebateAddr = 0x8E787af95dd2041dE7965ff21343ecaaaAC0351e; //rebate claim
    uint256 public bonusAmount = 500000000000000000; //
    uint256 public destroyAmount = 1000000000000000000; //
    uint256 public rebateAmount = 8500000000000000000; //
    mapping(uint256 => uint256 ) public orderIds;
    mapping(address => uint256 ) public pool; 

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'EXPIRED');
        _;
    }

 

    event BuytNFT(address indexed from, address tokenNFT, uint256 tokenID, uint256 amount, uint256 time); 
    event SetToken(address indexed from, address indexed token, uint256 now);
    event SetSign(address indexed from, address indexed addr, uint256 now);
    event SetBonusPoolAddr(address indexed from, address indexed addr, uint256 now);
    event SetDestroyAddr(address indexed from, address indexed addr, uint256 now);
    event SetRebateAddr(address indexed from, address indexed addr, uint256 now);
    event SetBonusAmount(address indexed from, uint256 amount, uint256 now);
    event SetDestroyAmount(address indexed from, uint256 amount, uint256 now);
    event SetRebateAmount(address indexed from, uint256 amount, uint256 now);
    event TransferTOKEN(address indexed from, address indexed token, address recAddress, uint256 amount);

   //buyNFT function
   function permitNFT(string memory funcName, address caller, address _contract ,address tokenNFT, uint256 amount, uint256 tokenID, uint256 numID, uint256 deadline, uint8 v, bytes32 r, bytes32 s) private {
        require(block.timestamp <= deadline, "EXPIRED"); 
        uint256 tempNonce = nonces[caller]; 
        nonces[caller] = nonces[caller].add(1); 
        bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(caller, _contract, funcName, amount, tokenID, numID, tokenNFT, deadline, tempNonce))));
        address recoveredAddress = ecrecover(message, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == signAddress, 'INVALID_SIGNATURE');
    }

    function buyNFT( uint256 amount, address tokenNFT, uint256 tokenID, uint256 numID, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public ensure(deadline) {
        require(orderIds[numID] == 0,"id has been generated");
        permitNFT("buyNFT", msg.sender, address(this), tokenNFT,  amount, tokenID, numID, deadline, v, r, s); 
        bool decide =  ERC721(tokenNFT).isApprovedForAll(msg.sender, address(this));
        require(decide, "without authorization");
        
        uint256 _amount1 = amount.sub(bonusAmount); //0.5
        uint256 _amount2 = _amount1.sub(destroyAmount); //1
        uint256 remainingAmount = _amount2.sub(rebateAmount); //8.5

        safeTransferFrom(tokenUSDT, msg.sender, bonusPoolAddr, bonusAmount);
        safeTransferFrom(tokenUSDT, msg.sender, destroyAddr, destroyAmount);
        safeTransferFrom(tokenUSDT, msg.sender, rebateAddr, rebateAmount);
        safeTransferFrom(tokenUSDT, msg.sender, address(this), remainingAmount);

        ERC721(tokenNFT).safeTransferFrom(address(this),msg.sender,tokenID); 
        orderIds[numID] =  block.number;
        pool[tokenNFT] = pool[tokenNFT].add(bonusAmount);
        emit BuytNFT(msg.sender, tokenNFT, tokenID, remainingAmount, block.timestamp); 
    }

    //  function depositNFT( address buyAddr, uint256 tokenID) public { 
    //     bool falge =  ERC721(tokenNFT).isApprovedForAll(msg.sender, address(this));
    //     require(falge, "without authorization"); 
    //     ERC721(tokenNFT).safeTransferFrom(address(this),buyAddr,tokenID); 
    //     emit DepositNFT(msg.sender, tokenNFT, buyAddr, tokenID, block.timestamp); 
    // }

    // function depositUSDT(uint256 amount) public {
    //      safeTransferFrom(tokenUSDT, msg.sender, address(this), amount);  
    //     emit DepositUSDT(msg.sender, amount, tokenUSDT, block.timestamp); 
    // }

    //balanceOf NFT
    function getNFTbalanceOf(address _tokenNFT) public view returns(uint256){
        uint256 curBalance = ERC721(_tokenNFT).balanceOf(address(this));
        return curBalance;
    }

    //set tokenUSDT
     function setTokenUSDT(address tokenAddress) public onlyOwner{
        require(tokenAddress != address(0),"zero tokenAddress!");
        tokenUSDT = tokenAddress;
         emit SetToken(msg.sender,tokenUSDT, now);
    }


    //set signAddress
    function setSign(address signAddr) public onlyOwner{
        require(signAddr != address(0),"zero signAddr!");
        signAddress = signAddr;
        emit SetSign(msg.sender,signAddress, now);
    }

    //set setBonusPoolAddr
    function setBonusPoolAddr(address addr) public onlyOwner{
        require(addr != address(0),"zero signAddr!");
        bonusPoolAddr = addr;
        emit SetBonusPoolAddr(msg.sender,bonusPoolAddr, now);
    }

     //set setDestroyAddr
    function setDestroyAddr(address addr) public onlyOwner{
        require(addr != address(0),"zero signAddr!");
        destroyAddr = addr;
        emit SetDestroyAddr(msg.sender,destroyAddr, now);
    }

     //set setRebateAddr
    function setRebateAddr(address addr) public onlyOwner{
        require(addr != address(0),"zero signAddr!");
        rebateAddr = addr;
        emit SetRebateAddr(msg.sender,rebateAddr, now);
    }

   //set setBonusAmount
    function setBonusAmount(uint256 amount) public onlyOwner{
         require(amount > 0,"Amount cannot be less than 0");
        bonusAmount = amount;
        emit SetBonusAmount(msg.sender,bonusAmount, now);
    }

    //set setDestroyAmount
    function setDestroyAmount(uint256 amount) public onlyOwner{
         require(amount > 0,"Amount cannot be less than 0");
        destroyAmount = amount;
        emit SetDestroyAmount(msg.sender,destroyAmount, now);
    }

    //set setBonusAmount
    function setRebateAmount(uint256 amount) public onlyOwner{
         require(amount > 0,"Amount cannot be less than 0");
        rebateAmount = amount;
        emit SetRebateAmount(msg.sender,rebateAmount, now);
    }


    //transfet token
    function transferTOKEN(address tokenAddr, address recAddress) public onlyOwner{
        uint256 curBalance = IERC20(tokenAddr).balanceOf(address(this));
        require(curBalance > 0, ' Cannot stake 0'); 
        safeTransfer(tokenAddr, recAddress, curBalance);
        emit TransferTOKEN(msg.sender, tokenAddr, recAddress, curBalance);
    }

 



}