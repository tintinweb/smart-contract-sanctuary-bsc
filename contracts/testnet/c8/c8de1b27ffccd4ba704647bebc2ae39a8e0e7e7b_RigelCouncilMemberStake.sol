/**
 *Submitted for verification at BscScan.com on 2022-05-26
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

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

/**
 * @dev silently declare mapping for the products on Rigel's Protocol Decentralized P2P network
 */
interface events {
   /**
     * @dev Emitted when the Buyer makes a call to Lock Merchant Funds, is set by
     * a call to {makeBuyPurchase}. `value` is the new allowance.
     */
    event Buy(address indexed merchant, address indexed buyer, address token, uint256 amount, uint256 ID, uint256 time);

    /**
     * @dev Emitted when the Merchant Comfirmed that they have recieved their Funds, is set by
     * a call to {makeSellPurchase}. `value` is the new allowance.
     */
    event Sell(address indexed buyer, address indexed merchant, address token, uint256 amount, uint256 ID, uint256 time);

    /**
     * @dev Emitted when Dispute is raise.
     */
    event dispute(address indexed who, address indexed against, address token, uint256 amount, uint256 ID, uint256 time);  

    /**
     * @dev Emitted when a vote has been raise.
     */
    event councilVote(address indexed councilMember, address indexed who, bytes rank, uint256 productID, uint256 indexedOfID, uint256 time);  

    event EarnBadge(bytes badge, address indexed user, uint256 amount, uint256 time);
    
    event EarnNFTBadge(bytes badge, address indexed user, uint256 amount, uint256 time);
}

struct CouncilsBadge {
    bytes   Rank;
    bytes   otherRank;
    uint256 minAmount;
    uint256 buyersFee;
    uint256 sellersFee;
    uint256 numbersOfCouncilMembers;
    uint256 beforeVote;
    uint256 votesPeriod;
    uint256 WrongVotesFee;
}

struct MerchantsBadge {
    bytes     Rank;
    bytes     otherRank;
    address[] tokenAddresses;
    uint256[] requireURI;
    uint256 sellerFee;
    uint256 buyerFee;
    uint256 numbersOfCouncilMembers;
    uint256 beforeVote;
    uint256 votesPeriod;
    uint256 wrongVotesFees;
}

struct MerchantStore {
    address user;
    address NFT;
    bytes   Rank;
    bytes   voteRank;
    uint256 TokenID;
    uint256 locking;
    uint256 time;
}

struct CouncilMembersStore {
    address user;
    bytes Rank;
    bytes voteRank;
    uint256 amount;
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
        uint256 beforeLock;
        address RGP;
        address P2PAddress;
        address  devAddress;
    }

    function diamondStorage() internal pure returns(libStorage storage ds) {
        bytes32 storagePosition = keccak256("Rigel Decentralized P2P System.");
        assembly {ds.slot := storagePosition}
    }

    function _council(
        bytes calldata _rank, 
        bytes calldata _rankForM,
        uint256 min, 
        uint256 bFee, 
        uint256 sFee, 
        uint256 minCouncilMembers, 
        uint256 timeBeforVote,
        uint256 voteTimeOut,
        uint256 wrongVoteFee
    ) internal {
        libStorage storage ds = diamondStorage();
        CouncilsBadge memory createDispute = CouncilsBadge(
            _rank, 
            _rankForM,
            min, 
            bFee, 
            sFee, 
            minCouncilMembers,
            timeBeforVote,
            voteTimeOut,
            wrongVoteFee
        );
        ds.councilMembersBadge.push(createDispute);
       
    }

    function _merchant(
        bytes calldata _rank, 
        bytes calldata _rankForCM, 
        address[] memory contractAddr,
        uint256[] memory _uri, 
        uint256 bFee, 
        uint256 sFee, 
        uint256 minCouncilMembers, 
        uint256 timeBeforVote,
        uint256 voteTimeOut,
        uint256 wrongVotesFees
    ) internal {
        libStorage storage ds = diamondStorage();
        MerchantsBadge memory m = MerchantsBadge(
            _rank, 
            _rankForCM,
            contractAddr,
            _uri,
            bFee, 
            sFee, 
            minCouncilMembers,
            timeBeforVote,
            voteTimeOut,
            wrongVotesFees
        );
        ds.merchantsBadge[_rank] = m;
        ds.merchantsBadge[_rankForCM] = m;
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
}

interface IERC20 {
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

abstract contract Ownable {

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
}
        
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.13;

interface IRigelDecentralizedP2PSystem {
    
    function getTotalUserLock(address account) external view returns(bool, bool);
}

// add votes counts
contract RigelCouncilMemberStake is Ownable, ERC1155Holder, events {
    
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
    }

    function setLockFunds(uint256 lockInterval, uint256 volume) external onlyOwner {
        RigelMappedStake.libStorage storage ds = RigelMappedStake.diamondStorage();
        ds.beforeLock = lockInterval;
        ds.wrongLock = volume;
    }

    function setCouncilBadge(
        bytes calldata _rank,
        bytes calldata _rankForM,
        uint256 min, 
        uint256 bFee, 
        uint256 sFee, 
        uint256 minCouncilMembers, 
        uint256 timeBeforVote,
        uint256 voteTimeOut,
        uint256 wrongVotesFees
    ) external onlyOwner  { 
        RigelMappedStake._council(
            _rank, 
            _rankForM,
            min, 
            bFee, 
            sFee, 
            minCouncilMembers,
            timeBeforVote,
            voteTimeOut,
            wrongVotesFees
        );
    }

    function setMerchantBadge(
        bytes calldata _rank, 
        bytes calldata _rankForCM, 
        address[] memory contractAddr,
        uint256[] memory _uri, 
        uint256 bFee, 
        uint256 sFee, 
        uint256 minCouncilMembers, 
        uint256 timeBeforVote,
        uint256 voteTimeOut,        
        uint256 wrongVotesFees
    ) external onlyOwner {
        RigelMappedStake._merchant(
            _rank, 
            _rankForCM,
            contractAddr,
            _uri,
            bFee, 
            sFee, 
            minCouncilMembers,
            timeBeforVote,
            voteTimeOut,
            wrongVotesFees
        );
    }

    function earnRGPBadge(uint256 badgeID, uint256 amount) external {
        RigelMappedStake.libStorage storage ds = RigelMappedStake.diamondStorage();
        CouncilsBadge memory readDispute = ds.councilMembersBadge[badgeID];
        // require(amount >= readDispute.minAmount, "Rigel's Protocol: Amount too Low to Earn Badge.");
        if (amount < readDispute.minAmount)  revert Insufficient_Amount();
        IERC20(ds.RGP).transferFrom(_msgSender(), address(this), amount);
        CouncilMembersStore memory userInfo = CouncilMembersStore(_msgSender(), readDispute.Rank, readDispute.otherRank, amount, block.timestamp);
        ds.councilStore[_msgSender()] = userInfo;
        emit EarnBadge(readDispute.Rank, _msgSender(), amount, block.timestamp);
    }

    function looseRGPBadge(uint256 amount) external {
        RigelMappedStake.libStorage storage ds = RigelMappedStake.diamondStorage();
        CouncilMembersStore storage userInfo = ds.councilStore[_msgSender()];
        // require(amount <= userInfo.amount, "Rigel's Protocol: Input Amount greater than output Amount");
        if (amount > userInfo.amount) revert higher_input();
        // (bool resolving, bool Lck) = getP2Pdetails(_msgSender());
        // require(!resolving, "Rigel's Protocol: Kindly ensure that you are not on any dispute");        
        // require(!Lck, "Rigel's Protocol: Kindly Ensure You'r not on debt");
        userInfo.amount = userInfo.amount - amount;
        uint256 lent = ds.councilMembersBadge.length;
        for (uint256 i; i < lent; i++) {
            uint256 reqAmount = ds.councilMembersBadge[i].minAmount;
            if (userInfo.amount >= reqAmount) {
                userInfo.Rank = ds.councilMembersBadge[i].Rank;
                userInfo.time = block.timestamp;
                break;
            } else {
                userInfo.Rank = "";
                userInfo.time = block.timestamp;
            }
        }
        IERC20(ds.RGP).transfer(_msgSender(), amount);     
        emit EarnBadge(userInfo.Rank, _msgSender(), userInfo.amount, userInfo.time);
    }

    function earnNFTBadge(bytes calldata _rank, uint256 tokenID) external {
        RigelMappedStake.libStorage storage ds = RigelMappedStake.diamondStorage();
        MerchantsBadge memory tradeMine = ds.merchantsBadge[_rank]; 
        (bool wiH, address tokenAddr) = isQualifiedWithNFTs(_rank, _msgSender(), tokenID);
        // require(wiH == true, "Rigel's Protocol: Can't stake token with Zero Balance.");
        if (wiH != true) revert Zero_balance();
        // require(tokenAddr != address(0), "Rigel's Protocol: Invalid own token.");
        if (tokenAddr == address(0))  revert Invalid_Token();
        IERC1155(tokenAddr).safeTransferFrom(_msgSender(), address(this), tokenID, 1, "");
        MerchantStore memory store = MerchantStore(_msgSender(), tokenAddr, _rank, tradeMine.otherRank, tokenID, 0, block.timestamp);
        ds.merchantStore[_msgSender()] = store;
        emit EarnNFTBadge(_rank, _msgSender(), tokenID, block.timestamp);
    }
    
    function looseNFTBadge() external lock{
        RigelMappedStake.libStorage storage ds = RigelMappedStake.diamondStorage();
        MerchantStore storage userInfo = ds.merchantStore[_msgSender()];
        // (bool resolving, bool Lck) = getP2Pdetails(_msgSender());
        // require(!resolving, "Rigel's Protocol: Kindly ensure that you are not on any dispute");
        // require(!lck, "Rigel's Protocol: Kindly Ensure You'r not on debt");
        // require(userInfo.TokenID != 0, "Rigel's Protocol: Invalid tokenID.");
        if (userInfo.TokenID == 0) revert Invalid_ID();
        if (!(IERC1155(userInfo.NFT).isApprovedForAll(userInfo.NFT, address(this)))) {
            IERC1155(userInfo.NFT).setApprovalForAll(userInfo.NFT, true);
        }
        IERC1155(userInfo.NFT).safeTransferFrom(address(this), _msgSender(), userInfo.TokenID, 1, "");
        userInfo.NFT = address(0);
        userInfo.TokenID = 0;
        userInfo.Rank = "";
        userInfo.voteRank = "";
        userInfo.time = block.timestamp;
    }
    
    function getP2Pdetails(address account) internal view returns(bool, bool ) {
        RigelMappedStake.libStorage storage ds = RigelMappedStake.diamondStorage();
        (
            bool resolving,
            bool isLocked
        ) = IRigelDecentralizedP2PSystem(ds.P2PAddress).getTotalUserLock(account);
        return (resolving, isLocked);
    }

    
    function getLockPeriodData() external view returns(uint256, uint256) {
        RigelMappedStake.libStorage storage ds = RigelMappedStake.diamondStorage();
        return (ds.beforeLock, ds.wrongLock);
    }

    function isQualifiedWithNFTs(bytes calldata _rank, address account, uint256 tokenID) public view returns(bool whatIhave, address iHave) {
        RigelMappedStake.libStorage storage ds = RigelMappedStake.diamondStorage();
        MerchantsBadge memory tradeMine = ds.merchantsBadge[_rank]; 
        uint256 len = tradeMine.tokenAddresses.length; 
        uint256 lenID = tradeMine.requireURI.length;
        uint256 myID;
        for(uint256 i; i < lenID; i++) {
            if (tradeMine.requireURI[i] == tokenID) {
                myID = tradeMine.requireURI[i];
                break;
            } else {
                if(i == lenID - 1) {
                    return (false, address(0));
                }
            }
        }
        for(uint256 j; j < len; j++) {
            uint256 bal = IERC1155(tradeMine.tokenAddresses[j]).balanceOf(account, myID);
            if (bal != 0) {
                string memory set = IERC1155(tradeMine.tokenAddresses[j]).setUri(myID);
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

    function getMyRank(address account) external view returns(bytes memory, bytes memory) {        
        RigelMappedStake.libStorage storage ds = RigelMappedStake.diamondStorage();
        MerchantStore memory merchantTradeStor = ds.merchantStore[account];
        CouncilMembersStore memory counsilTradeStore = ds.councilStore[account];
        if(counsilTradeStore.amount != 0 ) {
            return(counsilTradeStore.Rank, counsilTradeStore.voteRank);
        } else {
            return(merchantTradeStor.Rank, merchantTradeStor.voteRank);
        }
    }
    
    function getSetsBadgeForCouncilMembers(uint256 indexedOfID) external view returns(CouncilsBadge memory storeCM) {
        RigelMappedStake.libStorage storage ds = RigelMappedStake.diamondStorage();
        storeCM = ds.councilMembersBadge[indexedOfID];
    }

    function getSetsBadgeForMerchants(bytes memory _badge) external view returns(
        bytes  memory   Rank,
        bytes  memory   otherRank,
        address[] memory tokenAddresses,
        uint256[] memory requireURI,
        uint256 sellerFee,
        uint256 buyerFee,
        uint256 numbersOfCouncilMembers,
        uint256 beforeVote,
        uint256 votesPeriod,
        uint256 wrongVotesFees
    ) {
        RigelMappedStake.libStorage storage ds = RigelMappedStake.diamondStorage();
        MerchantsBadge memory storeMerchant = ds.merchantsBadge[_badge];
        return (
            storeMerchant.Rank,
            storeMerchant.otherRank,
            storeMerchant.tokenAddresses,
            storeMerchant.requireURI,
            storeMerchant.sellerFee,
            storeMerchant.buyerFee,
            storeMerchant.numbersOfCouncilMembers,
            storeMerchant.beforeVote,
            storeMerchant.votesPeriod,
            storeMerchant.wrongVotesFees
        );
    }


}