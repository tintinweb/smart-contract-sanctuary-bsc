/**
 *Submitted for verification at BscScan.com on 2022-06-16
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

library Context {

    struct context {
        mapping(address => bool) isAdminAddress;
        address _owner;
    }

    function diamondContext() internal pure returns(context storage ds) {
        bytes32 storagePosition = keccak256("Rigel Decentralized P2P Context.");
        assembly {ds.slot := storagePosition}
    }
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
// Rigel's Protocol: unEqual length of Arg
error unEqualLength();

abstract contract Ownable {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {        
        Context.context storage ds = Context.diamondContext();
        ds.isAdminAddress[_msgSender()] = true;
        ds._owner = _msgSender();
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        Context.context storage ds = Context.diamondContext();
        return ds._owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyAdmin() {
        Context.context storage ds = Context.diamondContext();
        require(ds.isAdminAddress[_msgSender()], "Access Denied: Need Admin Accessibility");
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
        Context.context storage ds = Context.diamondContext();
        address oldOwner = ds._owner;
        ds._owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

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
    uint256[] requireURI;
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
    uint256 amount;
    uint256 time;
}

struct CouncilMembersStore {
    address user;
    bytes Rank;
    uint256 amount;
    uint256 maxAmountToJoin;
    uint256 time;
}

/**
 * @dev silently declare mapping for the products on Rigel's Protocol Decentralized P2P network
 */
library RigelMappedStake {
    struct libStorage {
        mapping (address => MerchantStore) merchantStore;
        mapping (address => CouncilMembersStore) councilStore;
        mapping (bytes => MerchantsBadge)  merchantsBadge;
        CouncilsBadge[] councilMembersBadge;
        uint256 wrongLock;
        uint256 totalVotes;
        address RGP;
        address P2PAddress;
        address devAddress;
    }

    function diamondStorage() internal pure returns(libStorage storage ds) {
        bytes32 storagePosition = keccak256("Rigel Decentralized P2P System.");
        assembly {ds.slot := storagePosition}
    }

}

/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * ////IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
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

abstract contract Badge is stakeEvents,Ownable {
    
    function _council(
        bytes memory _rank,
        uint256 minStake,
        uint256 maxDisputeAmount,
        uint256 wrongVoteFeeInRGP
    ) internal {
        RigelMappedStake.libStorage storage ds = RigelMappedStake.diamondStorage();
        CouncilsBadge memory createDispute = CouncilsBadge(
            _rank,
            minStake,
            maxDisputeAmount,
            wrongVoteFeeInRGP
        );
        ds.councilMembersBadge.push(createDispute);
       
    }

    function _badgeForCouncilMembers(uint256 indexedOfID) internal view returns(CouncilsBadge memory storeCM) {
        RigelMappedStake.libStorage storage ds = RigelMappedStake.diamondStorage();
        storeCM = ds.councilMembersBadge[indexedOfID];
    }
    
    function setCouncilBadge(
        bytes[] memory _rank,
        uint256[] memory _minimumStakeAmount,
        uint256[] memory _maximumDisputeAmountToJoin,
        uint256[] memory _wrongVotesFees
    ) external onlyOwner  {
        if(
            _rank.length != _minimumStakeAmount.length &&
            _maximumDisputeAmountToJoin.length != _wrongVotesFees.length 
        ) revert unEqualLength();
        for(uint256 i; i < _rank.length; i++) {

            _council(_rank[i], _minimumStakeAmount[i], _maximumDisputeAmountToJoin[i], _wrongVotesFees[i]);

            emit SetCouncilBadge(_rank[i], _minimumStakeAmount[i], _maximumDisputeAmountToJoin[i], _wrongVotesFees[i]);
        }
    }

    function setMerchantBadge(
        bytes calldata _rank, 
        bytes calldata _rankForCM, 
        address[] memory contractAddr,
        uint256[] memory _uri,
        uint256 _maxAmountOnDisputeToJoin,
        uint96 wrongVotesFees
    ) external onlyOwner{
        RigelMappedStake.libStorage storage ds = RigelMappedStake.diamondStorage();
        MerchantsBadge memory m = MerchantsBadge(
            _rank, 
            _rankForCM,
            contractAddr,
            _uri,
            _maxAmountOnDisputeToJoin,
            wrongVotesFees
        );
        ds.merchantsBadge[_rank] = m;
        ds.merchantsBadge[_rankForCM] = m;
        emit SetMerchantBadge(_rank, _rankForCM, contractAddr, _uri, _maxAmountOnDisputeToJoin,wrongVotesFees);
    }


    function getSetsBadgeForMerchant(bytes memory _badge) external view returns(
        bytes  memory   Rank,
        bytes  memory   otherRank,
        address[] memory tokenAddresses,
        uint256[] memory requireURI,
        uint256 maxRequireJoin,
        uint256 wrongVotesFees
    ) {
        RigelMappedStake.libStorage storage ds = RigelMappedStake.diamondStorage();
        MerchantsBadge memory storeMerchant = ds.merchantsBadge[_badge];
        return (
            storeMerchant.Rank,
            storeMerchant.otherRank,
            storeMerchant.tokenAddresses,
            storeMerchant.requireURI,
            storeMerchant.maxAmountOnDisputeToJoin,
            storeMerchant.WrongVotesFee
        );
    }

    function getSetsBadgeForMerchants(bytes[] memory _badge) external view returns(MerchantsBadge[] memory _merchants) {
        RigelMappedStake.libStorage storage ds = RigelMappedStake.diamondStorage();
        _merchants = new MerchantsBadge[](_badge.length);
        for(uint256 i; i < _badge.length; i++) {
            _merchants[i] = ds.merchantsBadge[_badge[i]];
        }
        return _merchants;
    }

    function getSetsBadgeForCouncilMembers(uint256[] memory indexedOfID) external view returns(CouncilsBadge[] memory storeCM) {
        storeCM = new CouncilsBadge[](indexedOfID.length);
        for(uint256 i; i< indexedOfID.length; i++) {
            storeCM[i] = _badgeForCouncilMembers(indexedOfID[i]);
        }
        return storeCM;
    }
}

interface IERC1155 {
    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function setUri(uint256 id) external view returns (string memory);
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address account, address operator) external view returns (bool);
    function uri(uint256 _tokenID) external view returns (string memory);
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

interface IRigelDecentralizedP2PSystem {
    
    function getTotalUserLock(address account) external view returns(bool, bool);
}

// add votes counts
contract RigelCouncilMemberStake is ERC1155Holder, Badge {    
    constructor (address _rigelToken, address _devAddress) {
        RigelMappedStake.libStorage storage ds = RigelMappedStake.diamondStorage();
        ds.RGP = _rigelToken;
        ds.devAddress = _devAddress;
    }

    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, "Rigel's Protocol: Locked");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function setP2PContract(address p2pContract) external onlyOwner {
        RigelMappedStake.libStorage storage ds = RigelMappedStake.diamondStorage();
        ds.P2PAddress = p2pContract;

        emit SetP2PContract(p2pContract);
    }

    function setLockFunds(uint256 _totalJoin, uint256 wrongLock) external onlyOwner {
        RigelMappedStake.libStorage storage ds = RigelMappedStake.diamondStorage();
        ds.totalVotes = _totalJoin;
        ds.wrongLock = wrongLock;

        emit SetLockFunds(_totalJoin, wrongLock);
    }

    function earnRGPBadge(uint256 badgeID, uint256 amount) external returns(bytes memory){
        RigelMappedStake.libStorage storage ds = RigelMappedStake.diamondStorage();
        CouncilsBadge memory readDispute = ds.councilMembersBadge[badgeID];
        CouncilMembersStore storage userInfo = ds.councilStore[_msgSender()];
        if ((amount + userInfo.amount) < readDispute.minAmountToStake)  revert Insufficient_Amount();
        IERC20(ds.RGP).transferFrom(_msgSender(), address(this), amount);
        userInfo.user = _msgSender();
        userInfo.Rank = readDispute.Rank;
        userInfo.amount += amount;
        userInfo.maxAmountToJoin = readDispute.maxAmountOnDisputeToJoin;
        userInfo.time = block.timestamp;
        emit EarnBadge(readDispute.Rank, _msgSender(), amount, block.timestamp);
        return readDispute.Rank;
    }

    function looseRGPBadge(uint256 amount) external returns(bytes memory) {
        RigelMappedStake.libStorage storage ds = RigelMappedStake.diamondStorage();
        CouncilMembersStore storage userInfo = ds.councilStore[_msgSender()];
        if (amount > userInfo.amount) revert higher_input();
        (bool resolving, bool Lck) = getP2Pdetails(_msgSender());
        if(resolving) revert isResolving();       
        if(Lck) revert isOnLocked();
        userInfo.amount = userInfo.amount - amount;
        uint256 lent = ds.councilMembersBadge.length;
        for (uint256 i; i < lent; i++) {
            uint256 reqAmount = ds.councilMembersBadge[i].minAmountToStake;
            if (userInfo.amount >= reqAmount) {
                userInfo.Rank = ds.councilMembersBadge[i].Rank;
                userInfo.maxAmountToJoin = ds.councilMembersBadge[i].maxAmountOnDisputeToJoin;
                userInfo.time = block.timestamp;
                break;
            } else {
                userInfo.Rank = "";
                userInfo.maxAmountToJoin = 0;
                userInfo.time = block.timestamp;
            }
        }
        IERC20(ds.RGP).transfer(_msgSender(), amount);     
        emit EarnBadge(userInfo.Rank, _msgSender(), userInfo.amount, userInfo.time);
        return userInfo.Rank;
    }

    function earnNFTBadge(bytes calldata _rank, uint256 tokenID) external returns(bytes memory, bytes memory) {
        RigelMappedStake.libStorage storage ds = RigelMappedStake.diamondStorage();
        MerchantsBadge memory tradeMine = ds.merchantsBadge[_rank]; 
        (bool wiH, address tokenAddr) = isQualifiedWithNFTs(_rank, _msgSender(), tokenID);
        if (wiH != true) revert Zero_balance();
        if (tokenAddr == address(0))  revert Invalid_Token();
        IERC1155(tokenAddr).safeTransferFrom(_msgSender(), address(this), tokenID, 1, "");
        MerchantStore memory store = MerchantStore(_msgSender(), tokenAddr, _rank, tradeMine.otherRank, tokenID, tradeMine.maxAmountOnDisputeToJoin,0, block.timestamp);
        ds.merchantStore[_msgSender()] = store;
        emit EarnNFTBadge(_rank, _msgSender(), tokenID, block.timestamp);
        return (_rank, tradeMine.otherRank);
    }
    
    function looseNFTBadge() external lock returns(bytes memory) {
        RigelMappedStake.libStorage storage ds = RigelMappedStake.diamondStorage();
        MerchantStore storage userInfo = ds.merchantStore[_msgSender()];
        (bool resolving, bool Lck) = getP2Pdetails(_msgSender());
        if(resolving) revert isResolving();       
        if(Lck) revert isOnLocked();
        if(userInfo.TokenID == 0) revert Invalid_ID();
        if (userInfo.TokenID == 0) revert Invalid_ID();
        if (!(IERC1155(userInfo.NFT).isApprovedForAll(userInfo.NFT, address(this)))) {
            IERC1155(userInfo.NFT).setApprovalForAll(userInfo.NFT, true);
        }
        userInfo.Rank = "";
        userInfo.voteRank = "";
        userInfo.time = block.timestamp;
        userInfo.maxAmountToJoin = 0;
        IERC1155(userInfo.NFT).safeTransferFrom(address(this), _msgSender(), userInfo.TokenID, 1, "");
        userInfo.NFT = address(0);
        userInfo.TokenID = 0;
        emit looseBadge(userInfo.Rank, _msgSender(), block.timestamp);
        return userInfo.Rank;
    }
    
    function getP2Pdetails(address account) public view returns(bool, bool ) {
        RigelMappedStake.libStorage storage ds = RigelMappedStake.diamondStorage();
        (
            bool resolving,
            bool isLocked
        ) = IRigelDecentralizedP2PSystem(ds.P2PAddress).getTotalUserLock(account);
        return (resolving, isLocked);
    }

    function getLockPeriodData() external view returns(uint256, uint256) {
        RigelMappedStake.libStorage storage ds = RigelMappedStake.diamondStorage();
        return (ds.totalVotes, ds.wrongLock);
    }

    function isQualifiedWithNFTs(bytes calldata _rank, address account, uint256 tokenID) public view returns(bool whatIhave, address iHave) {
        RigelMappedStake.libStorage storage ds = RigelMappedStake.diamondStorage();
        MerchantsBadge memory tradeMine = ds.merchantsBadge[_rank]; 
        uint256 len = tradeMine.tokenAddresses.length; 
        for(uint256 j; j < len; j++) {
            uint256 bal = IERC1155(tradeMine.tokenAddresses[j]).balanceOf(account, tokenID);
            if (bal != 0) {
                string memory set = IERC1155(tradeMine.tokenAddresses[j]).uri(tokenID);
                string memory setURI = IERC1155(tradeMine.tokenAddresses[j]).setUri(tradeMine.requireURI[j]);
                if (_internalCheck(set, setURI )) {
                    whatIhave = true;
                    iHave = tradeMine.tokenAddresses[j];
                    break;
                } else {
                    whatIhave = false;
                    iHave = address(0);
                }
            } else {
                whatIhave = false;
                iHave = address(0);
            }
        }
    }

    function _internalCheck(string memory token1, string memory token2) internal pure returns(bool status) {
        if (keccak256(abi.encodePacked(token1)) == keccak256(abi.encodePacked(token2))) {
            status = true;
        } else {
            status =false;
        }
    }

    function getCouncilMemberStore(address account) public view returns(CouncilMembersStore memory trade) {
        RigelMappedStake.libStorage storage ds = RigelMappedStake.diamondStorage();
        trade = ds.councilStore[account];
    }

    function getMerchantStore(address account) external view returns(MerchantStore memory trade) {
        RigelMappedStake.libStorage storage ds = RigelMappedStake.diamondStorage();
        trade = ds.merchantStore[account];
    }

    function getMyRank(address account) external view returns(uint256) {        
        RigelMappedStake.libStorage storage ds = RigelMappedStake.diamondStorage();
        MerchantStore memory merchantTradeStor = ds.merchantStore[account];
        CouncilMembersStore memory counsilTradeStore = ds.councilStore[account];
        if(counsilTradeStore.amount != 0 ) {
            return(counsilTradeStore.maxAmountToJoin);
        } else {
            return(merchantTradeStor.maxAmountToJoin);
        }
    }

        
    function rigelToken() external view returns(address) {        
        RigelMappedStake.libStorage storage ds = RigelMappedStake.diamondStorage();
        return ds.RGP;
    }

    function devAddress() external view returns(address) {
        RigelMappedStake.libStorage storage ds = RigelMappedStake.diamondStorage();
        return ds.devAddress;
    }

    function p2pContractAddress() external view returns(address) {
        RigelMappedStake.libStorage storage ds = RigelMappedStake.diamondStorage();
        return ds.P2PAddress;
    }

    receive() external payable{}

    function emmergencyWithdrawalOfETH(uint256 amount) external onlyOwner{
        payable(owner()).transfer(amount);
    }

    function withdrawTokenFromContract(address tokenAddress, uint256 _amount, address _receiver) external onlyOwner {
        IERC20(tokenAddress).transferFrom(address(this),_receiver, _amount);
    }

}