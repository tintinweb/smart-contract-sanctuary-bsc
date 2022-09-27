// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;
interface IERC1155 {
    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address account, address operator) external view returns (bool);

    // function uri(uint256 _tokenID) external view returns (string memory);
    // function setUri(uint256 id) external view returns (string memory);

    function supportsTokenInterface(uint256 _tokenID) external view returns(bytes4);
    function getSupportTokenInterface(uint256 _classID) external view returns(bytes4);
}


interface IRigelDecentralizedP2PSystem {
    
    function getTotalUserLock(address account) external view returns(bool, bool);
}

interface IERC20 {
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


struct CouncilsBadge {
    bytes   Rank;
    uint256 minAmountToStake;
    uint256 maxAmountOnDisputeToJoin;
    uint256 WrongVotesFee;
}

struct MerchantsBadge {
    bytes     Rank;
    bytes     otherRank;
    address[] tokenAddresses;
    uint256[] tokenClass;
    uint256   maxAmountOnDisputeToJoin;
    uint256   WrongVotesFee;
}

struct MerchantStore {
    address user;
    address NFT;
    bytes   Rank;
    bytes   voteRank;
    uint256 TokenID;
    uint256 maxAmountToJoin;
    uint256 time;
}

struct CouncilMembersStore {
    address user;
    bytes Rank;
    uint256 amount;
    uint256 maxAmountToJoin;
    uint256 time;
}
 
// "Rigel's Protocol: Amount too Low to Earn Badge."
error Insufficient_Amount();
// "Rigel's Protocol: Input Amount greater than output Amount"
error higher_input();
// "Rigel's Protocol: Can't stake token with Zero Balance."
error Zero_balance();
// "Rigel's Protocol: Invalid own token."
error Invalid_Token();
// "Rigel's Protocol: Invalid tokenID."
error Invalid_ID();
// Rigel's Protocol: Kindly ensure that you are not on any dispute
error isResolving();
// Rigel's Protocol: Kindly Ensure You'r not on debt
error isOnLocked();

error unEqualLength();
error currentlyStaked();

/**
 * @dev silently declare mapping for the products on Rigel's Protocol Decentralized P2P network
 */
interface stakeEvents {

    event EarnBadge(bytes badge, address indexed user, uint256 amount, uint256 time);
    
    event EarnNFTBadge(bytes badge, address indexed user, uint256 amount, uint256 time);

    event looseBadge(bytes badge, address indexed user, uint256 time);

    event SetP2PContract(address indexed p2pContract);

    event SetLockFunds(uint256 lockInterval, uint256 volume);
    
    event SetCouncilBadge(
        bytes rank,
        uint256 minimumAmount,
        uint256 maxDisputeAmount,
        uint256 wrongVotesFees
    );


    event SetMerchantBadge(
        bytes _rank,
        bytes CMrank,
        address[] indexed contractAddr,
        uint256[] uri,
        uint256 maxDisputeAmount,
        uint256 wrongVotesFees
    );

    event SetStakeAddr(address indexed rgpStake);

    event SetRefFeesPercent(uint256 whitelist, uint256 nonWhitelist);

    event EmmergencyWithdrawalOfETH(uint256 amount);

    event WithdrawTokenFromContract(address indexed tokenAddress, uint256 _amount, address indexed _receiver);
}

abstract contract Ownable {

    mapping(address => bool) private isAdminAddress;
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {        
        isAdminAddress[_msgSender()] = true;
        _owner = _msgSender();
    }

    function _adminSet(address _admin, bool status) internal {
        isAdminAddress[_admin] = status;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyAdmin() {
        require(isAdminAddress[_msgSender()], "Access Denied: Need Admin Accessibility");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
     function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract stakeStorage is stakeEvents {

    mapping (address =>  MerchantStore) private merchantStore;
    mapping (address => CouncilMembersStore) private councilStore;
    mapping (bytes => MerchantsBadge) private merchantsBadge;
    CouncilsBadge[] private councilMembersBadge;
    uint256 private wrongLock;
    uint256 private totalVotes;
    address private RGP;
    address private P2PAddress;
    address private devAddress;
    uint private unlocked = 1;


    constructor(address _rgp, address _dev) {
        RGP = _rgp;
        devAddress = _dev;
    }

    // ***************** //
    // *** MODIFIERS *** //
    // ***************** //
    modifier lock() {
        require(unlocked == 1, "Rigel's Protocol: Locked");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    modifier currentlyLocked() {
        (bool resolving, bool Lck) = getP2Pdetails(msg.sender);
        if(resolving) revert isResolving();       
        if(Lck) revert isOnLocked();
        _;
    }

    function _setP2P(address p2pContract) internal {
        P2PAddress = p2pContract;
        emit SetP2PContract(p2pContract);
    }

    function _setLockFunds(uint256 _totalJoin, uint256 _wrongLock) internal {
        totalVotes = _totalJoin;
        wrongLock = _wrongLock;
        emit SetLockFunds(_totalJoin, _wrongLock);
    }


    function _council(
        bytes memory _rank,
        uint256 minStake,
        uint256 maxDisputeAmount,
        uint256 wrongVoteFeeInRGP
    ) internal {
        CouncilsBadge memory createDispute = CouncilsBadge(
            _rank,
            minStake,
            maxDisputeAmount,
            wrongVoteFeeInRGP
        );
        councilMembersBadge.push(createDispute);

        emit SetCouncilBadge(_rank, minStake, maxDisputeAmount, wrongVoteFeeInRGP);
    }


    function _badgeForCouncilMembers(uint256 indexedOfID) internal view returns(CouncilsBadge memory storeCM) {
        storeCM = councilMembersBadge[indexedOfID];
    }

    function _merchantBadge(
        bytes calldata _rank,
        bytes calldata _rankForCM,
        address[] memory contractAddr,
        uint256[] memory _uri,
        uint256 _maxAmountOnDisputeToJoin,
        uint256 wrongVotesFees) internal {
        MerchantsBadge memory m = MerchantsBadge(
            _rank,
            _rankForCM,
            contractAddr,
            _uri,
            _maxAmountOnDisputeToJoin,
            wrongVotesFees
        );
        merchantsBadge[_rank] = m;
        merchantsBadge[_rankForCM] = m;
        emit SetMerchantBadge(_rank, _rankForCM, contractAddr, _uri, _maxAmountOnDisputeToJoin,wrongVotesFees);
    }

    function _getSetsBadgeForMerchant(bytes memory _badge) internal view returns(
        bytes  memory   Rank,
        bytes  memory   otherRank,
        address[] memory tokenAddresses,
        uint256[] memory classOfTokens,
        uint256 maxRequireJoin,
        uint256 wrongVotesFees
    ) {
        return (
            merchantsBadge[_badge].Rank,
            merchantsBadge[_badge].otherRank,
            merchantsBadge[_badge].tokenAddresses,
            merchantsBadge[_badge].tokenClass,
            merchantsBadge[_badge].maxAmountOnDisputeToJoin,
            merchantsBadge[_badge].WrongVotesFee
        );
    }

    function _getSetsBadgeForMerchants(bytes memory _badge) internal view returns(MerchantsBadge memory _merchants) {
        return merchantsBadge[_badge];
    }

    function _earn20(uint256 badgeID, uint256 amount) internal returns(bytes memory) {
        CouncilMembersStore storage userInfo = councilStore[msg.sender];
        if ((amount + userInfo.amount) < councilMembersBadge[badgeID].minAmountToStake)  revert Insufficient_Amount();

        IERC20(RGP).transferFrom(msg.sender, address(this), amount);
        bytes memory rank = councilMembersBadge[badgeID].Rank;
        userInfo.user = msg.sender;
        userInfo.Rank = rank;
        userInfo.amount += amount;
        userInfo.maxAmountToJoin = councilMembersBadge[badgeID].maxAmountOnDisputeToJoin;
        userInfo.time = block.timestamp;        
        emit EarnBadge(rank, msg.sender, amount, block.timestamp);
        return rank;
    }

    function loose20(uint256 amount) internal returns (bytes memory) {
        CouncilMembersStore storage userInfo = councilStore[msg.sender];
        uint256 s_amount = userInfo.amount;

        if (amount > s_amount) revert higher_input();

        userInfo.amount = s_amount - amount;

        uint256 s_newAmount = userInfo.amount;
        uint256 lent = councilMembersBadge.length;
        for (uint256 i; i < lent; ) {
            uint256 reqAmount = councilMembersBadge[i].minAmountToStake;
            if (s_newAmount >= reqAmount) {
                userInfo.Rank = councilMembersBadge[i].Rank;
                userInfo.maxAmountToJoin = councilMembersBadge[i].maxAmountOnDisputeToJoin;
                userInfo.time = block.timestamp;
                break;
            } else {
                userInfo.Rank = "";
                userInfo.maxAmountToJoin = 0;
                userInfo.time = block.timestamp;
            }
            unchecked {
                i++;
            }
        }
        bytes memory s_rank = userInfo.Rank;
        IERC20(RGP).transfer(msg.sender, amount);     
        emit EarnBadge(s_rank, msg.sender, s_newAmount, block.timestamp);
        return s_rank;
    }

    function earn1155(bytes calldata _rank, uint256 tokenID) internal {
        (bool wiH, address tokenAddr) = isQualifiedWithNFTs(_rank, msg.sender, tokenID);
        if (wiH != true) revert Zero_balance();
        if (tokenAddr == address(0))  revert Invalid_Token();
        if(merchantStore[msg.sender].user != address(0)) revert currentlyStaked();
        IERC1155(tokenAddr).safeTransferFrom(msg.sender, address(this), tokenID, 1, "");
        bytes memory s_rank = merchantsBadge[_rank].otherRank;
        MerchantStore memory store = 
            MerchantStore(msg.sender, tokenAddr, _rank, s_rank, tokenID, merchantsBadge[_rank].maxAmountOnDisputeToJoin, block.timestamp);
        merchantStore[msg.sender] = store;
        emit EarnNFTBadge(_rank, msg.sender, tokenID, block.timestamp);
    }

    function loose1155() internal {
        MerchantStore storage userInfo = merchantStore[msg.sender];
        address s_nftAddress = userInfo.NFT;
        uint256 s_tokenID = userInfo.TokenID;
        if(s_tokenID == 0) revert Invalid_ID();
        if (!(IERC1155(s_nftAddress).isApprovedForAll(s_nftAddress, address(this)))) {
            IERC1155(s_nftAddress).setApprovalForAll(s_nftAddress, true);
        }
        bytes memory s_rank = userInfo.Rank;
        userInfo.user = address(0);
        userInfo.Rank = "";
        userInfo.voteRank = "";
        userInfo.time = block.timestamp;
        userInfo.maxAmountToJoin = 0;
        IERC1155(userInfo.NFT).safeTransferFrom(address(this), msg.sender, s_tokenID, 1, "");
        userInfo.NFT = address(0);
        userInfo.TokenID = 0;
        emit looseBadge(s_rank, msg.sender, block.timestamp);
    }

    function _internalCheck(bytes4 token1, bytes4 token2) internal pure returns(bool status) {
        if (keccak256(abi.encodePacked(token1)) == keccak256(abi.encodePacked(token2))) {
            status = true;
        } else {
            status =false;
        }
    }


    function isQualifiedWithNFTs(bytes calldata _rank, address account, uint256 tokenID) internal view returns(bool whatIhave, address iHave) {
        uint256 len = merchantsBadge[_rank].tokenAddresses.length; 
        for(uint256 j; j < len; ) {
            uint256 bal = IERC1155(merchantsBadge[_rank].tokenAddresses[j]).balanceOf(account, tokenID);
            if (bal != 0) {

                bytes4 set = IERC1155(merchantsBadge[_rank].tokenAddresses[j]).supportsTokenInterface(tokenID);
                bytes4 setURI = IERC1155(merchantsBadge[_rank].tokenAddresses[j]).getSupportTokenInterface(merchantsBadge[_rank].tokenClass[j]);

                if (_internalCheck(set, setURI )) {
                    whatIhave = true;
                    iHave = merchantsBadge[_rank].tokenAddresses[j];
                    break;
                } else {
                    whatIhave = false;
                    iHave = address(0);
                }
            } else {
                whatIhave = false;
                iHave = address(0);
            }
            unchecked {
                j++;
            }
        }
    }

    function getP2Pdetails(address account) public view returns(bool, bool ) {
        (
            bool resolving,
            bool isLocked
        ) = IRigelDecentralizedP2PSystem(P2PAddress).getTotalUserLock(account);
        return (resolving, isLocked);
    }

    // ********************************* //
    // *** EXTERNAL VIEW FUNCTIONS *** //
    // ******************************* //

    function getLockPeriodData() external view returns(uint256, uint256) {
        return (totalVotes, wrongLock);
    }

    function getMerchantStore(address account) external view returns(MerchantStore memory trade) {
        trade = merchantStore[account];
    }

    function getMyRank(address account) external view returns(uint256) {       

        if(councilStore[account].amount != 0 ) {
            return(councilStore[account].maxAmountToJoin);
        } else {
            return(merchantStore[account].maxAmountToJoin);
        }
    }

        
    function rigelToken() external view returns(address) {        
        return RGP;
    }

    function dev() external view returns(address) {
        return devAddress;
    }

    function p2pContractAddress() external view returns(address) {
        return P2PAddress;
    }

    // ********************************* //
    // *** PUBLIC VIEW FUNCTIONS *** //
    // ******************************* //
    function getCouncilMemberStore(address account) public view returns(CouncilMembersStore memory trade) {
        trade = councilStore[account];
    }


}

abstract contract Badge is stakeStorage,Ownable {

    constructor (address _rigelToken, address _devAddress) stakeStorage(_rigelToken, _devAddress) {}

        
    function setCouncilBadge(
        bytes[] memory _rank,
        uint256[] memory _minimumStakeAmount,
        uint256[] memory _maximumDisputeAmountToJoin,
        uint256[] memory _wrongVotesFees
    ) external onlyOwner  {
        uint256 lent = _rank.length;
        if(
            lent != _minimumStakeAmount.length &&
            _maximumDisputeAmountToJoin.length != _wrongVotesFees.length 
        ) revert unEqualLength();
        
        for(uint256 i; i < lent; ) {
            _council(_rank[i], _minimumStakeAmount[i], _maximumDisputeAmountToJoin[i], _wrongVotesFees[i]);
            unchecked {
                i++;
            }
        }
    }

    function setMerchantBadge(
        bytes calldata _rank, 
        bytes calldata _rankForCM, 
        address[] memory contractAddr,
        uint256[] memory classOfTokens,
        uint256 _maxAmountOnDisputeToJoin,
        uint256 wrongVotesFees
    ) external onlyOwner{
        _merchantBadge(
            _rank, 
            _rankForCM,
            contractAddr,
            classOfTokens,
            _maxAmountOnDisputeToJoin,
            wrongVotesFees
        );
    }


    function getSetsBadgeForMerchant(bytes memory _badge) external view returns(
        bytes  memory   Rank,
        bytes  memory   otherRank,
        address[] memory tokenAddresses,
        uint256[] memory _tokenClass,
        uint256 maxRequireJoin,
        uint256 wrongVotesFees
    ) {
        (
            Rank,
            otherRank,
            tokenAddresses,
            _tokenClass,
            maxRequireJoin,
            wrongVotesFees
        ) = _getSetsBadgeForMerchant(_badge);
    }

    function getSetsBadgeForMerchants(bytes[] memory _badge) external view returns(MerchantsBadge[] memory _merchants) {
        uint256 lent = _badge.length;
        _merchants = new MerchantsBadge[](lent);
        for(uint256 i; i < lent; ) {
            _merchants[i] = _getSetsBadgeForMerchants(_badge[i]);
            unchecked {
                i++;
            }
        }
        return _merchants;
    }

    function getSetsBadgeForCouncilMembers(uint256[] memory indexedOfID) external view returns(CouncilsBadge[] memory storeCM) {
        uint256 lent = indexedOfID.length;
        storeCM = new CouncilsBadge[](lent);
        for(uint256 i; i< lent; ) {
            storeCM[i] = _badgeForCouncilMembers(indexedOfID[i]);
            unchecked {
                i++;
            }
        }
        return storeCM;
    }
}

contract ERC1155Holder{
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public pure returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public pure returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}

contract RigelCouncilMemberStake is ERC1155Holder, Badge {  

    constructor (address _rigelToken, address _devAddress) Badge(_rigelToken, _devAddress) {}

    // ********************************* //
    // *** EXTERNAL WRITE FUNCTIONS *** //
    // ******************************* //
    function setP2PContract(address p2pContract) external onlyOwner {
        _setP2P(p2pContract);
    }

    function setLockFunds(uint256 _totalJoin, uint256 wrongLock) external onlyOwner {
        _setLockFunds(_totalJoin,wrongLock);
    }

    function earnRGPBadge(uint256 badgeID, uint256 amount) external returns(bytes memory rank){
        rank = _earn20(badgeID,amount );
        return rank;
    }

    function looseRGPBadge(uint256 amount) external currentlyLocked() returns(bytes memory newRank) {
        newRank = loose20(amount);
        return newRank;
    }

    function earnNFTBadge(bytes calldata _rank, uint256 tokenID) external  {
        earn1155(_rank, tokenID);
    }
    
    function looseNFTBadge() external lock currentlyLocked() {
        loose1155();
    }

    
    receive() external payable{}

    // ************************ //
    // *** OWNER FUNCTIONS *** //
    // *********************** //

    function emmergencyWithdrawalOfETH(uint256 amount) external onlyOwner{
        payable(owner()).transfer(amount);
    }

    function withdrawTokenFromContract(address tokenAddress, uint256 _amount, address _receiver) external onlyOwner {
        IERC20(tokenAddress).transferFrom(address(this),_receiver, _amount);
    }

}