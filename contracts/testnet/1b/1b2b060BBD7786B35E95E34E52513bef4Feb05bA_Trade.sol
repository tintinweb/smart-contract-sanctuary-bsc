/**
 *Submitted for verification at BscScan.com on 2022-02-16
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;
pragma experimental ABIEncoderV2;

interface IERC165 {
   
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IBEP721 is IERC165 {
    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

interface IBEP20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC1155 is IERC165 {
   
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address account, address operator) external view returns (bool);

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Trade is Ownable{

    uint256 public royaltyPercent;
    uint256 public beneficiaryFee = 100;
    address public beneficiaryAddress;
    address public WheelsToken;
    address public signer;

    struct Sale {
        address owner;
        IBEP721 tokenAddress;
        uint256 tokenID;
        IBEP20 buyToken;
        uint256 buyAmount;
        uint256 expiryTime;
    }

    struct Sig {
		uint8 v;
		bytes32 r;
		bytes32 s;
	}

    mapping (bytes32 => bool) public hashVerify;
    mapping (address => bool) public isApproved;

    event BuyTokens(address indexed TokenOwner, address indexed TokenBuyer, uint256 TokenID, uint256 BuyingTime);
    event EmergencySafe(address indexed Receiver, address indexed TokenAddres, uint256 amount);
    event TakeNFT(address indexed Owner, address indexed NFTaddress, address indexed Receiver, uint256 TokenID);
    event UpdateRoyaltyFee(address indexed Owner, uint256 RoyaltyFee);
    event UpdateBeneficiaryFee(address indexed Owner, uint256 BeneficiaryFee);

    constructor (uint256 _royaltyPercent, address _beneficiaryAddress, address _wheelsToken, address _signer ) {
        royaltyPercent = _royaltyPercent;
        beneficiaryAddress = _beneficiaryAddress;
        WheelsToken = _wheelsToken;
        signer = _signer;
        isApproved[_wheelsToken] = true;
    }

    receive() external payable{}

    function buy(Sale calldata _saleToken, Sig calldata _sellerSig, Sig calldata _buyerSig, address _royaltyRecipent, uint256 _royaltyFee  ) external payable {
        require(_saleToken.expiryTime >= block.timestamp,"Sale time exceed");
        require(address(_saleToken.buyToken) == address(0x0) || isApproved[address(_saleToken.buyToken)],"Not approved Token");
        require(royaltyPercent >= _royaltyFee, "invalid royalty percentage");

        require(_saleToken.owner != msg.sender,"invalid seller");

        validateSellerSig( _saleToken, _sellerSig);
        validateBuyerSig( _saleToken, _buyerSig, _royaltyRecipent, _royaltyFee);

        TransferNFT( _saleToken);
        takeFee(_saleToken, _royaltyRecipent, _royaltyFee);

        emit BuyTokens(_saleToken.owner, _msgSender(), _saleToken.tokenID, block.timestamp);
    }

    function updateRoyaltyPercent(uint256 _royaltyPercent) external onlyOwner {
        royaltyPercent = _royaltyPercent;
        emit UpdateRoyaltyFee(msg.sender, _royaltyPercent);
    }

    function updateBeneficiaryFee(uint256 _beneficiaryFee) external onlyOwner {
        beneficiaryFee = _beneficiaryFee;
        emit UpdateBeneficiaryFee(msg.sender, _beneficiaryFee);
    }

    function takeFee(Sale calldata _saleToken, address _royaltyRecipent, uint256 _royaltyFee) internal {
        uint256 royaltyFee = _saleToken.buyAmount * (_royaltyFee) / (1e3);
        uint256 beneficiary = _saleToken.buyAmount * (beneficiaryFee) / (1e3);
        if(address(_saleToken.buyToken) == address(0x0)){
            require(msg.value >= _saleToken.buyAmount,"Invalid amount");
            require(payable(_royaltyRecipent).send(royaltyFee),"royalty transaction failed");
            require(payable(_saleToken.owner).send(_saleToken.buyAmount - royaltyFee - beneficiary),"owner transaction failed");
        } else {
            _saleToken.buyToken.transferFrom(_msgSender(),_royaltyRecipent,royaltyFee);
            _saleToken.buyToken.transferFrom(_msgSender(),address(this),beneficiary);
            _saleToken.buyToken.transferFrom(_msgSender(),_saleToken.owner,_saleToken.buyAmount - royaltyFee - beneficiary);
        }
    }

    function TransferNFT(Sale calldata _saleToken) internal {
        (_saleToken.tokenAddress).safeTransferFrom(_saleToken.owner, _msgSender(), _saleToken.tokenID);
    }

    function validateSellerSig(Sale calldata _saleToken, Sig calldata _signature) public {
        bytes32 msgHash = getSellerHash(_saleToken);
        bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", msgHash));
        require(!hashVerify[hash],"Claim :: signature already used");
        require(verifySignature(hash, _signature.v,_signature.r,_signature.s) == _saleToken.owner,"Claim :: not a signer address");
        hashVerify[hash] = true;
    }

    function validateBuyerSig(Sale calldata _saleToken, Sig calldata _signature,address _royaltyRecipent, uint256 _royaltyFee) public {
        bytes32 msgHash = getBuyerrHash(_saleToken, _royaltyRecipent, _royaltyFee);
        bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", msgHash));
        require(!hashVerify[hash],"Claim :: signature already used");
        require(verifySignature(hash, _signature.v,_signature.r,_signature.s) == _msgSender(),"Claim :: not a signer address");
        hashVerify[hash] = true;
    }

    function verifySignature(bytes32 msgHash, uint8 v,bytes32 r, bytes32 s)public pure returns(address returnAddress){
        returnAddress = ecrecover(msgHash, v, r, s);
    }

    function getBuyerrHash(Sale memory _saleToken, address _royaltyRecipent, uint256 _royaltyFee)public pure returns(bytes32 hash){
        hash = keccak256(abi.encodePacked(abi.encodePacked(_saleToken.owner,
                    _saleToken.tokenAddress,
                    _saleToken.tokenID,
                    _saleToken.buyToken,
                    _saleToken.buyAmount,
                    _saleToken.expiryTime,
                    _royaltyRecipent,
                    _royaltyFee)));
    }
    
    function getSellerHash(Sale memory _saleToken)public pure returns(bytes32 hash){
        hash = keccak256(abi.encodePacked(abi.encodePacked(_saleToken.owner,
                    _saleToken.tokenAddress,
                    _saleToken.tokenID,
                    _saleToken.buyToken,
                    _saleToken.buyAmount,
                    _saleToken.expiryTime)));
        
    }

    function takeNFT(address _NFTaddress,address _to, uint256 _tokenID) external onlyOwner {
        IBEP721(_NFTaddress).transferFrom(address(this), _to, _tokenID);

        emit TakeNFT(msg.sender, _NFTaddress, _to, _tokenID);
    }

    function emergencySafe(address token, address to, uint256 amount)external onlyOwner{
        if(token == address(0x0)){
            payable(to).transfer(amount);
        } else  {
            
            IBEP20(token).transfer(to, amount);
        }

        emit EmergencySafe(to, token, amount);
    }

}