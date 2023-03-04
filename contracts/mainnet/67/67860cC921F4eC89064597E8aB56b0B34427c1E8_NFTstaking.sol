/**
 *Submitted for verification at BscScan.com on 2023-03-04
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


interface IERC20 {
    function totalSupply() external view returns(uint256);

    function balanceOf(address account) external view returns(uint256);

    function transfer(address recipient, uint256 amount)
    external
    returns(bool);

    function allowance(address owner, address spender)
    external
    view
    returns(uint256);

    function approve(address spender, uint256 amount) external returns(bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns(bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function burnFrom(address user, uint256 amount) external;

    function mint(address user, uint256 amount) external;
}

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns(bool);
}

interface Ireciept is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns(uint256);

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
    external
    view
    returns(uint256[] memory);

    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address account, address operator) external view returns(bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

    function mint(address _to, uint _id, uint _amount) external;

    function mintBatch(address _to, uint[] memory _ids, uint[] memory _amounts) external;

    function burn(uint _id, uint _amount) external;

    function burnFrom(address user, uint _id, uint _amount) external;

    function burnBatch(uint[] memory _ids, uint[] memory _amounts) external;

    function burnFromBatch(address user, uint[] memory _ids, uint[] memory _amounts) external;

    function burnForMint(address _from, uint[] memory _burnIds, uint[] memory _burnAmounts, uint[] memory _mintIds, uint[] memory _mintAmounts) external;

    function setURI(uint _id, string memory _uri) external;
}

interface nftBase is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns(uint256 balance);

    function ownerOf(uint256 tokenId) external view returns(address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns(address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns(bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function mint(
        address _to,
        string memory tokenURI_
    ) external;

    function burn(uint256 ID) external;
    function totalSupply() external view returns (uint256);
    function tokenURI(uint256 tokenId) external view returns(string memory);
}


abstract contract Context {
    function _msgSender() internal view virtual returns(address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns(bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns(address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract NFTstaking is Ownable, ReentrancyGuard {


    address public payoutTokenAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public nftsAddress = 0xb42AEDdE71787C4269fEC06e53Ebc62Ea9149733;
    address public receiptAddress = 0xe8b425587C5E959E70Dfa04d33e09e5561422c84;

    uint256 public monthlyPayout = 3250000000000000000;
    uint256 private stamp = 60 * 60 * 24 * 30;
    
    bool stakingOnline = true;
    bool pauseWithdrawals = false;

    struct NFT {
        address staker;
        uint256 id;
        uint256 time;
    }
    mapping(uint256 => NFT) nfts;


    function stakeNft(uint256 ID) public nonReentrant() {
        require(stakingOnline == true);
        nftBase nb = nftBase(nftsAddress);
        Ireciept rec = Ireciept(receiptAddress);
        require(nb.ownerOf(ID) == msg.sender);
        pushNft(msg.sender, ID, block.timestamp);
         nb.transferFrom(msg.sender, address(this), ID);
        rec.mint(msg.sender, ID, 1);
    }

    function unstakeNft(uint256 ID) public nonReentrant() {
        require(pauseWithdrawals == false);
        nftBase nb = nftBase(nftsAddress);
        Ireciept rec = Ireciept(receiptAddress);
        IERC20 payToken = IERC20(payoutTokenAddress);
        uint256 pay = calculatePay(ID);
        require(rec.balanceOf(msg.sender, ID) >= 1);
       require(nfts[ID].staker == msg.sender);
        pushNft(0x0000000000000000000000000000000000000000, ID, 0);
        rec.burnFrom(msg.sender, ID, 1);
        nb.transferFrom(address(this), msg.sender, ID);
        payToken.approve(address(this), pay);
        payToken.transferFrom(address(this), msg.sender, pay);

    }


    function bulkStake( uint256[] memory IDS) external nonReentrant() {
        require(stakingOnline == true);
        for(uint256 i = 0; i < IDS.length; i++ ) {
        nftBase nb = nftBase(nftsAddress);
        Ireciept rec = Ireciept(receiptAddress);
        require(nb.ownerOf(IDS[i]) == msg.sender);
        pushNft(msg.sender, IDS[i], block.timestamp);
        nb.transferFrom(msg.sender, address(this), IDS[i]);
        rec.mint(msg.sender, IDS[i], 1);
        }
    }


    function bulkUnstake(uint256[] memory IDS) external nonReentrant() {
        require(pauseWithdrawals == false);
        for(uint256 i = 0; i < IDS.length; i++ ) {
        nftBase nb = nftBase(nftsAddress);
        Ireciept rec = Ireciept(receiptAddress);
        IERC20 payToken = IERC20(payoutTokenAddress);
        uint256 pay = calculatePay(IDS[i]);
        require(rec.balanceOf(msg.sender, IDS[i]) >= 1);
        require(nfts[IDS[i]].staker == msg.sender);
        pushNft(0x0000000000000000000000000000000000000000, IDS[i], 0);
        rec.burnFrom(msg.sender, IDS[i], 1);
        nb.transferFrom(address(this), msg.sender, IDS[i]);
        payToken.approve(address(this), pay);
        payToken.transferFrom(address(this), msg.sender, pay);
        }
    }

    function getReward(uint256 ID) external nonReentrant() {
        Ireciept rec = Ireciept(receiptAddress);
        require(rec.balanceOf(msg.sender, ID) >=1);
        require(nfts[ID].staker == msg.sender);
        IERC20 payToken = IERC20(payoutTokenAddress);
        uint256 reward = calculatePay(ID);
        pushNft(msg.sender, ID, block.timestamp);
        payToken.approve(address(this), reward);
        payToken.transferFrom(address(this), msg.sender, reward);
    }

    function getRewards(uint256[] memory ids) external nonReentrant() {
        Ireciept rec = Ireciept(receiptAddress);
        IERC20 payToken = IERC20(payoutTokenAddress);
        for(uint256 i=0; i < ids.length; i++) {
        uint256 reward = calculatePay(ids[i]);
        require(rec.balanceOf(msg.sender, ids[i]) >=1);
        require(nfts[ids[i]].staker == msg.sender);
        pushNft(msg.sender, ids[i], block.timestamp);
        payToken.approve(address(this),reward);
        payToken.transferFrom(address(this), msg.sender, reward);
        }
    }

    function pushNft(address setstaker, uint256 setID, uint256 settime) internal {
        nfts[setID].staker = setstaker;
        nfts[setID].id = setID;
        nfts[setID].time = settime;
    }

    function calculatePay(uint256 ID) public view returns(uint256) {
        return (monthlyPayout * (block.timestamp - nfts[ID].time)) / stamp;
    }

    function bulkCalculatePay(uint256[] memory IDS) external view returns(uint256) {
    uint256 total = 0;
        for(uint256 i = 0; i < IDS.length; i++ ) {
        total += calculatePay(IDS[i]);
    }
    return total;
}

    function getNftTime(uint256 ID) public view returns(uint256) {
        return nfts[ID].time;
    }

    function depositTokens(uint256 amount) external onlyOwner {
        IERC20 payToken = IERC20(payoutTokenAddress);
        payToken.transferFrom(msg.sender, address(this), amount);
    }

    function withdrawFunds(uint256 amount) external onlyOwner {
        IERC20 payToken = IERC20(payoutTokenAddress);
        payToken.approve(address(this), amount);
        payToken.transferFrom(address(this), owner(),  amount);
    }

    function setPayoutTokenAddress(address newPayout) external onlyOwner {
        payoutTokenAddress = newPayout;
    }

    function setNftAddress(address newNftAddress) external onlyOwner {
        nftsAddress = newNftAddress;
    }


    function setReceiptAddress(address newNftReceiptAddress) external onlyOwner {
        receiptAddress = newNftReceiptAddress;
    }

    function setDailyPay(uint256 value) external onlyOwner {
        monthlyPayout = value;
    }
    
    function emergencyWithdrawWithoutFunds(uint256 ID) public {
        nftBase nb = nftBase(nftsAddress);
        Ireciept rec = Ireciept(receiptAddress);
        rec.burnFrom(msg.sender, ID, 1);
        nb.transferFrom(address(this), msg.sender, ID);
    }

    function setStakingOnline(bool isOn) external onlyOwner {
        stakingOnline = isOn;
    }
    function setPauseWithdrawls(bool isPaused) external onlyOwner {
        pauseWithdrawals = isPaused;
    }
    function setTimeStamp(uint256 tStamp) external onlyOwner {
        stamp = tStamp;
    }

    function payoutTokenAmount() public view returns (uint256) {
        IERC20 payToken = IERC20(payoutTokenAddress);
        return payToken.balanceOf(address(this)); 
    }
}