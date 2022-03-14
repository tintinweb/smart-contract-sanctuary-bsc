/**
 *Submitted for verification at BscScan.com on 2022-03-14
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
pragma experimental ABIEncoderV2;

interface IBEP165 {
   
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IBEP721 is IBEP165 {
    
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

interface IBEP721Enumerable is IBEP721 {

    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);
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

interface IBEP1155 is IBEP165 {
   
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
    uint256 public beneficiaryFee = 20;
    address public WheelsToken;
    address public signer;
    uint256 public currentDistribution = 1;
    address public TOAXstore;
    
    struct distribution{
        uint256 totalDistribution;
        uint256 reserve;
        uint256 NFTTotalSupply;
        uint256 distributionTime;
    }

    struct NFTdetails{
        uint256 NFTID;
        uint256 lastClaimID;
        uint256 claimAmount;
        uint256 claimTime;
    }

    struct Sale {
        address owner;
        IBEP721 tokenAddress;
        uint256 tokenID;
        address buyer;
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
    mapping (uint256 => NFTdetails) private NFTInfo;
    mapping (uint256 => distribution) private distributionInfo;

    event AcceptBidding(address indexed TokenOwner, address indexed TokenBuyer, uint256 TokenID, uint256 BuyingTime);
    event EmergencySafe(address indexed Receiver, address indexed TokenAddres, uint256 amount);
    event TakeNFT(address indexed Owner, address indexed NFTaddress, address indexed Receiver, uint256 TokenID);
    event ClaimDistributionReward(address indexed caller, uint256 NFTID, uint256 claimAmount);
    event RareNFTReward(address indexed caller, uint256 rewardTokens, uint256 NFTID);
    event DistributeTokens(address indexed caller, distribution DistributionLevel, uint256 distributionID);

    constructor (uint256 _royaltyPercent,  address _wheelsToken, address _signer, address _TOAXstore ) {
        royaltyPercent = _royaltyPercent;
        WheelsToken = _wheelsToken;
        signer = _signer;
        TOAXstore = _TOAXstore;
    }

    receive() external payable{}

    function viewDistributionDetails(uint256 _distributionID) external view returns(distribution memory){
        require(_distributionID <= currentDistribution &&  _distributionID > 0,"Invalid Distribution ID");
        return distributionInfo[_distributionID];
    }

    function viewNFTDetails(uint256 _NFTID) external view returns(NFTdetails memory){
        return NFTInfo[_NFTID];
    }

    function acceptBid(Sale calldata _saleToken, Sig calldata _BuyerSig, Sig calldata _SignerSig, address _royaltyRecipent, uint256 _royaltyFee  ) external {
        require(_saleToken.expiryTime >= block.timestamp,"Sale time exceed");
        require(WheelsToken == address(_saleToken.buyToken),"Invalid Wheel token");
        require(royaltyPercent >= _royaltyFee, "invalid royalty pBEPentage");
        require(_saleToken.owner == msg.sender,"invalid seller");

        prepareBuyerSig( _saleToken, _BuyerSig);
        prepareSigner( _saleToken, _SignerSig, _royaltyRecipent, _royaltyFee);

        TransferNFT( _saleToken);
        takeFee(_saleToken, _royaltyRecipent, _royaltyFee);

        emit AcceptBidding(_saleToken.buyer, _msgSender(), _saleToken.tokenID, block.timestamp);
    }

    function updateRoyaltyPBEPent(uint256 _royaltyPBEPent) external onlyOwner {
        royaltyPercent = _royaltyPBEPent;
    }

    function updateBeneficiaryFee(uint256 _beneficiaryFee) external onlyOwner {
        beneficiaryFee = _beneficiaryFee;
    }

    function takeFee(Sale calldata _saleToken, address _royaltyRecipent, uint256 _royaltyFee) internal {
        uint256 royaltyFee = _saleToken.buyAmount * (_royaltyFee) / (1e3);
        uint256 beneficiary = _saleToken.buyAmount * (beneficiaryFee) / (1e3);
        distributionInfo[currentDistribution].totalDistribution += beneficiary;
        _saleToken.buyToken.transferFrom(_saleToken.buyer,_royaltyRecipent,royaltyFee);
        _saleToken.buyToken.transferFrom(_saleToken.buyer,address(this),beneficiary);
        _saleToken.buyToken.transferFrom(_saleToken.buyer,_saleToken.owner,_saleToken.buyAmount - royaltyFee - beneficiary);
    }

    function TransferNFT(Sale calldata _saleToken) internal {
        (_saleToken.tokenAddress).safeTransferFrom(_saleToken.owner, _saleToken.buyer, _saleToken.tokenID);
    }

    function prepareBuyerSig(Sale calldata _saleToken, Sig calldata _signature) internal {
        bytes32 msgHash = getBuyerHash(_saleToken);
        bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", msgHash));
        validateHash(msgHash);
        require(_saleToken.buyer == verifySignature(hash, _signature.v,_signature.r,_signature.s),"Invalid buyer signature");
    }

    function prepareSigner(Sale calldata _saleToken, Sig calldata _signature,address _royaltyRecipent, uint256 _royaltyFee) internal {
        bytes32 msgHash = getSignerHash(_saleToken, _royaltyRecipent, _royaltyFee);
        bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", msgHash));
        validateHash( msgHash);
        require(signer == verifySignature(hash, _signature.v,_signature.r,_signature.s),"Invalid Signer checker signature");
    }

    function validateHash(bytes32 hash) internal{
        require(!hashVerify[hash],"hash already declared");
        hashVerify[hash] = true;
    }

    function verifySignature(bytes32 msgHash, uint8 v,bytes32 r, bytes32 s)public pure returns(address returnAddress){
        returnAddress = ecrecover(msgHash, v, r, s);
    }

    function getSignerHash(Sale memory _saleToken, address _royaltyRecipent, uint256 _royaltyFee)public pure returns(bytes32 hash){
        hash = keccak256(abi.encodePacked(abi.encodePacked(_saleToken.owner,
                    _saleToken.tokenAddress,
                    _saleToken.tokenID,
                    _saleToken.buyToken,
                    _saleToken.buyAmount,
                    _saleToken.expiryTime,
                    _royaltyRecipent,
                    _royaltyFee)));
    }
    
    function getBuyerHash(Sale memory _saleToken)public pure returns(bytes32 hash){
        hash = keccak256(abi.encodePacked(abi.encodePacked(_saleToken.owner,
                    _saleToken.tokenAddress,
                    _saleToken.tokenID,
                    _saleToken.buyToken,
                    _saleToken.buyAmount,
                    _saleToken.expiryTime)));
    }

    function getRewardHash(address _account, uint256 _expiryTime, uint256 _tokenAmount) public view returns(bytes32 hash) {
        hash = keccak256(abi.encodePacked(abi.encodePacked(_account,_expiryTime,_tokenAmount,address(this))));
    }

    function distribute() external onlyOwner{
        distribution storage level = distributionInfo[currentDistribution];
        uint256 NFTsupply = IBEP721Enumerable(TOAXstore).totalSupply();
        level.NFTTotalSupply = NFTsupply;
        level.distributionTime = block.timestamp;
        level.reserve = calculateToken(NFTsupply);

        emit DistributeTokens(msg.sender, level, currentDistribution);

        currentDistribution++;
    }

    function calculateToken(uint256 supply) internal view returns(uint256) {
        distribution storage distributes = distributionInfo[currentDistribution];
        uint256 totalAmount = distributes.totalDistribution;
        return totalAmount / supply;
    }

    function claimReward(uint256 _NFTID) external {
        NFTdetails storage user = NFTInfo[_NFTID];
        uint256 NFTsupply = IBEP721Enumerable(TOAXstore).totalSupply();
        require(msg.sender == IBEP721(TOAXstore).ownerOf(_NFTID),"caller is not the owner of ID");
        require(user.lastClaimID != currentDistribution,"user already Claimed");
        require(NFTsupply >= _NFTID,"ID not minted");
        uint256 totalReward;
        for(uint256 i = currentDistribution; i > user.lastClaimID; i--){
            distribution storage level = distributionInfo[i];
            if(level.NFTTotalSupply >= _NFTID){
                totalReward += level.reserve;
            } else {
                break;
            }
        }

        user.lastClaimID = currentDistribution;
        user.claimAmount += totalReward;
        user.claimTime = block.timestamp;

        IBEP20(WheelsToken).transfer(msg.sender, totalReward);

        emit ClaimDistributionReward(msg.sender, _NFTID, totalReward);
    }

    function getClaimHash(address _account,uint256 NFTID, uint256 _expiryTime, uint256 _tokenAmount) internal view returns(bytes32 ){
        return keccak256(abi.encodePacked(abi.encodePacked(_account,NFTID,_expiryTime,_tokenAmount,address(this))));
    }

    function validateSignature(Sig calldata _signature,address _account,uint256 NFTID, uint256 _expiryTime, uint256 _tokenAmount ) internal {
        bytes32 hash = getClaimHash(_account,NFTID,_expiryTime,_tokenAmount);
        validateHash(hash);
        hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        require(signer == verifySignature(hash,_signature.v,_signature.r,_signature.s),"Invalid signer signature");
    }

    function claimRareNFTReward(address _tokenAddress,uint256 _tokenAmount, uint256 _NFTID, uint256 _expiryTime, Sig calldata _signature) external {
        require(_expiryTime >= block.timestamp,"Invalid time");
        validateSignature(_signature, msg.sender,_NFTID, _expiryTime, _tokenAmount );
        IBEP20(_tokenAddress).transfer(msg.sender, _tokenAmount);

        emit RareNFTReward(msg.sender, _tokenAmount, _NFTID);
    }

    function takeNFT(address _NFTaddress,address _to, uint256 _tokenID) external onlyOwner {
        IBEP721(_NFTaddress).transferFrom(address(this), _to, _tokenID);

        emit TakeNFT(msg.sender, _NFTaddress, _to, _tokenID);
    }

    function updateWheels(address _wheels) external onlyOwner{
        WheelsToken = _wheels;
    }

    function updateTOAXstore(address _TOAXstore) external onlyOwner{
        TOAXstore = _TOAXstore;
    }

    function updateSigner(address _signer) external onlyOwner{
        signer = _signer;
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