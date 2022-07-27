/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
pragma experimental ABIEncoderV2;

interface IBEP165 {
   
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IWBNB {

    function transfer(address to, uint amount) external returns (bool);
    function transferFrom(address from, address to, uint amount) external returns (bool);
    function balanceOf(address account ) external returns(uint256);
    function deposit() external payable;
    function withdraw(uint256 amount) external ;
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external returns(uint256);
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
    address public WBNB;
    bool public isBNBTrade;

    struct rewardAmount{
        uint256 totalBNBdistribution;
        uint256 totalWheelsDistribution;
        uint256 BNBReserve;
        uint256 wheelsReserve;
    }
    
    struct distribution{
        rewardAmount distAmounts;
        uint256 NFTTotalSupply;
        uint256 distributionTime;
    }

    struct NFTdetails{
        uint256 NFTID;
        uint256 lastClaimID;
        uint256 BNBclaim;
        uint256 wheelsClaim;
        uint256 claimTime;
    }

    struct Sale {
        address owner;
        IBEP721 tokenAddress;
        uint256 tokenID;
        address buyer;
        address buyToken;
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
    mapping (address => bool) public isApprovedToken;

    event AcceptBidding(address indexed TokenOwner, address indexed TokenBuyer, uint256 TokenID, uint256 BuyingTime);
    event buyToken(address indexed TokenOwner, address indexed TokenBuyer, uint256 TokenID, uint256 BuyingTime);
    event EmergencySafe(address indexed Receiver, address indexed TokenAddres, uint256 amount);
    event TakeNFT(address indexed Owner, address indexed NFTaddress, address indexed Receiver, uint256 TokenID);
    event ClaimDistributionReward(address indexed caller, uint256 NFTID, uint256 wheelReward, uint256 BNBreward);
    event RareNFTReward(address indexed caller, uint256 rewardTokens, uint256 NFTID);
    event DistributeTokens(address indexed caller, distribution DistributionLevel, uint256 distributionID);

    constructor (uint256 _royaltyPercent,  address _wheelsToken, address _signer, address _TOAXstore, address _wBNB ) {
        royaltyPercent = _royaltyPercent;
        WheelsToken = _wheelsToken;
        WBNB = _wBNB;
        isApprovedToken[_wheelsToken] = true;
        isApprovedToken[_wBNB] = true;
        isApprovedToken[address(0x0)] = true;
        signer = _signer;
        TOAXstore = _TOAXstore;
        isBNBTrade = true;
    }

    receive() external payable{}

    function viewDistributionDetails(uint256 _distributionID) external view returns(distribution memory){
        require(_distributionID <= currentDistribution &&  _distributionID > 0,"Invalid Distribution ID");
        return distributionInfo[_distributionID];
    }

    function setApproveToken(address tokenAddress, bool status) external onlyOwner{
        isApprovedToken[tokenAddress] = status;
    }

    function viewNFTDetails(uint256 _NFTID) external view returns(NFTdetails memory){
        return NFTInfo[_NFTID];
    }

    function setTradingCoin(bool _isBNBTrade) external onlyOwner {
        require(isBNBTrade != _isBNBTrade,"already in this type of trading");
        isBNBTrade = _isBNBTrade;
    }

    function acceptBid(Sale calldata _saleOrder, Sig calldata _BuyerSig, Sig calldata _SignerSig, address _royaltyRecipent, uint256 _royaltyFee  ) external {
        require(isApprovedToken[address(_saleOrder.buyToken)],"unAuthorized buy token");
        require(_saleOrder.expiryTime >= block.timestamp,"Sale time exceed");
        require(royaltyPercent >= _royaltyFee, "invalid royalty Percentage");
        require(_saleOrder.owner == _msgSender(),"invalid seller");

        require(prepareBuyerSig( _saleOrder, _BuyerSig) == _saleOrder.buyer,"Invalid signature");
        prepareSigner( _saleOrder, _SignerSig, _royaltyRecipent, _royaltyFee);

        TransferNFT( _saleOrder);
        takeFee(_saleOrder, _royaltyRecipent, _royaltyFee);

        emit AcceptBidding(_msgSender(), _saleOrder.buyer, _saleOrder.tokenID, block.timestamp);
    }

    function buy(Sale calldata _saleOrder, Sig calldata _SignerSig, address _royaltyRecipent, uint256 _royaltyFee  ) external payable {
        require(_saleOrder.expiryTime >= block.timestamp,"Sale time exceed");
        require(isApprovedToken[address(_saleOrder.buyToken)],"unAuthorized buy token");
        require(royaltyPercent >= _royaltyFee, "invalid royalty Percentage");
        require(_saleOrder.owner != _msgSender(),"caller is owner");
        require(_saleOrder.buyer == _msgSender(),"caller is not a buyer");

        prepareSigner( _saleOrder, _SignerSig, _royaltyRecipent, _royaltyFee);

        TransferNFT( _saleOrder);
        takeFee(_saleOrder, _royaltyRecipent, _royaltyFee);

        emit buyToken(_saleOrder.owner, _msgSender(), _saleOrder.tokenID, block.timestamp);
    }

    function updateRoyaltyPBEPent(uint256 _royaltyPBEPent) external onlyOwner {
        royaltyPercent = _royaltyPBEPent;
    }

    function updateBeneficiaryFee(uint256 _beneficiaryFee) external onlyOwner {
        beneficiaryFee = _beneficiaryFee;
    }

    function takeFee(Sale calldata _saleOrder, address _royaltyRecipent, uint256 _royaltyFee) internal {

        distribution storage dist = distributionInfo[currentDistribution];
        uint256 royaltyFee = _saleOrder.buyAmount * (_royaltyFee) / (1e3);
        uint256 beneficiary = _saleOrder.buyAmount * (beneficiaryFee) / (1e3);
        if(_saleOrder.buyToken == WBNB  || _saleOrder.buyToken == address(0x0) ){ dist.distAmounts.totalBNBdistribution += beneficiary; }
        if(_saleOrder.buyToken == WheelsToken){ dist.distAmounts.totalWheelsDistribution += beneficiary; }
        if(_saleOrder.buyToken == address(0x0) && isBNBTrade){
            require(_saleOrder.buyAmount <= msg.value,"invalid BNB");
            
            require(payable(_royaltyRecipent).send(royaltyFee),"Royalty transaction failed");
            require(payable(_saleOrder.owner).send(_saleOrder.buyAmount - royaltyFee - beneficiary),"Royalty transaction failed");
        } 
        if(_saleOrder.buyToken != address(0x0) && !isBNBTrade){
            IBEP20(_saleOrder.buyToken).transferFrom(_saleOrder.buyer,_royaltyRecipent,royaltyFee);
            IBEP20(_saleOrder.buyToken).transferFrom(_saleOrder.buyer,address(this),beneficiary);
            IBEP20(_saleOrder.buyToken).transferFrom(_saleOrder.buyer,_saleOrder.owner,_saleOrder.buyAmount - royaltyFee - beneficiary);
        }
    }

    function TransferNFT(Sale calldata _saleOrder) internal {
        (_saleOrder.tokenAddress).safeTransferFrom(_saleOrder.owner, _saleOrder.buyer, _saleOrder.tokenID);
    }

    function prepareBuyerSig(Sale calldata _saleOrder, Sig calldata _signature) internal returns(address) {
        bytes32 msgHash = getBuyerHash(_saleOrder);
        bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", msgHash));
        validateHash(msgHash);
        return verifySignature(hash, _signature.v,_signature.r,_signature.s);
    }

    function prepareSigner(Sale calldata _saleOrder, Sig calldata _signature,address _royaltyRecipent, uint256 _royaltyFee) internal {
        bytes32 msgHash = getSignerHash(_saleOrder, _royaltyRecipent, _royaltyFee);
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

    function getSignerHash(Sale memory _saleOrder, address _royaltyRecipent, uint256 _royaltyFee)public pure returns(bytes32 hash){
        hash = keccak256(abi.encodePacked(abi.encodePacked(_saleOrder.owner,
                    _saleOrder.tokenAddress,
                    _saleOrder.tokenID,
                    _saleOrder.buyToken,
                    _saleOrder.buyAmount,
                    _saleOrder.expiryTime,
                    _royaltyRecipent,
                    _royaltyFee)));
    }
    
    function getBuyerHash(Sale memory _saleOrder)public pure returns(bytes32 hash){
        hash = keccak256(abi.encodePacked(abi.encodePacked(_saleOrder.owner,
                    _saleOrder.tokenAddress,
                    _saleOrder.tokenID,
                    _saleOrder.buyToken,
                    _saleOrder.buyAmount,
                    _saleOrder.expiryTime)));
    }

    function getRewardHash(address _account, uint256 _expiryTime, uint256 _tokenAmount) public view returns(bytes32 hash) {
        hash = keccak256(abi.encodePacked(abi.encodePacked(_account,_expiryTime,_tokenAmount,address(this))));
    }

    function distribute() external onlyOwner{
        distribution storage level = distributionInfo[currentDistribution];
        uint256 NFTsupply = IBEP721Enumerable(TOAXstore).totalSupply();
        level.NFTTotalSupply = NFTsupply;
        level.distributionTime = block.timestamp;
        uint256 bal = IWBNB(WBNB).balanceOf(address(this));
        IWBNB(WBNB).withdraw(bal);

        (uint256 BNBreward, uint256 wheelsReward) = calculateToken(NFTsupply);
        
        level.distAmounts.BNBReserve = BNBreward;
        level.distAmounts.wheelsReserve = wheelsReward;

        emit DistributeTokens(msg.sender, level, currentDistribution);

        currentDistribution++;
    }

    function calculateToken(uint256 supply) internal view returns(uint256 totalAmount1, uint256 totalAmount2) {
        distribution storage distributes = distributionInfo[currentDistribution];
        totalAmount1 = distributes.distAmounts.totalBNBdistribution / supply;
        totalAmount2 = distributes.distAmounts.totalWheelsDistribution / supply;
    }

    function claimReward(uint256 _NFTID) external {
        NFTdetails storage user = NFTInfo[_NFTID];
        uint256 NFTsupply = IBEP721Enumerable(TOAXstore).totalSupply();
        require(msg.sender == IBEP721(TOAXstore).ownerOf(_NFTID),"caller is not the owner of ID");
        require(user.lastClaimID != currentDistribution,"user already Claimed");
        require(NFTsupply >= _NFTID,"ID not minted");
        uint256 BNBreward;
        uint256 wheelReward;
        for(uint256 i = (currentDistribution - 1); i > user.lastClaimID; i--){
            distribution storage level = distributionInfo[i];
            if(level.NFTTotalSupply >= _NFTID){
                BNBreward += level.distAmounts.BNBReserve;
                wheelReward += level.distAmounts.wheelsReserve;
            } else {
                break;
            }
        }

        user.lastClaimID = (currentDistribution - 1);
        user.wheelsClaim += wheelReward;
        user.BNBclaim += BNBreward;
        user.claimTime = block.timestamp;

        IBEP20(WheelsToken).transfer(msg.sender, wheelReward);
        require(payable(_msgSender()).send(BNBreward),"BNB reward failed");

        emit ClaimDistributionReward(msg.sender, _NFTID, wheelReward, BNBreward);
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