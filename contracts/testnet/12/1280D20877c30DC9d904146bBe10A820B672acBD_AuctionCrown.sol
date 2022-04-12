/**
 *Submitted for verification at BscScan.com on 2022-04-12
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ICrownNFT {
    struct CrownTraits {
        uint256 reduce;
        uint256 aprBonus;
        uint256 lockDeadline;
        bytes32 source;
        bool staked;
    }

    function crowns(uint256)
        external
        view
        returns (
            uint256,
            string memory,
            string memory
        );

    function totalCrowns() external view returns (uint256);

    function ownerOf(uint256) external view returns (address);

    function transfer(uint256, address) external;

    function transferFrom(
        address, // from
        address, // to,
        uint256 // token id
    ) external;

    function getTraits(uint256) external view returns (CrownTraits memory);
}

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract AuctionCrown is Ownable {
    address wdaToken;
    address daoTreasuryAddress; // Dao Treasury address

    struct Auction {
        uint256 highestBid;
        uint256 withBnb;
        uint256 closingTime;
        address highestBidder;
        address originalOwner;
        bool isActive;
    }

    // NFT id => Auction data
    mapping(uint256 => Auction) public auctions;

    // CrownNFT contract interface
    ICrownNFT private sNft_;

    // BNB balance
    uint256 public balances;
    uint256 public gasPrice;

    /**
     * @dev New Auction Opened Event
     * @param nftId Auction NFT Id
     * @param startingBid NFT starting bid price
     * @param withBnb Bnb with bid price
     * @param closingTime Auction close time
     * @param originalOwner Auction creator address
     */
    event NewAuctionOpened(
        uint256 nftId,
        uint256 startingBid,
        uint256 withBnb,
        uint256 closingTime,
        address originalOwner
    );

    /**
     * @dev Auction Closed Event
     * @param nftId Auction NFT id
     * @param highestBid Auction highest bid
     * @param withBnb Bnb with bid price
     * @param highestBidder Auction highest bidder
     */
    event AuctionClosed(
        uint256 nftId,
        uint256 highestBid,
        uint256 withBnb,
        address highestBidder
    );

    /**
     * @dev Bid Placed Event
     * @param nftId Auction NFT id
     * @param bidPrice Bid price
     * @param withBnb with Bnb price
     * @param bidder Bidder address
     */
    event BidPlaced(
        uint256 nftId,
        uint256 bidPrice,
        uint256 withBnb,
        address bidder
    );

    /**
     * @dev Receive BNB. msg.data is empty
     */
    receive() external payable {
        balances += msg.value;
    }

    /**
     * @dev Receive BNB. msg.data is not empty
     */
    fallback() external payable {
        balances += msg.value;
    }

    /**
     * @dev Contructor Smart contract
     * @param token_ address token
     */
    constructor(address token_, address daoTreasuryAddress_) {
        wdaToken = token_;
        daoTreasuryAddress = daoTreasuryAddress_;
    }

    /**
     * @dev Initialize states
     * @param _sNft CrownNFT contract address
     */
    function initialize(address _sNft) external onlyOwner {
        require(_sNft != address(0), "Invalid address");

        sNft_ = ICrownNFT(_sNft);

        balances = 0;
        gasPrice = 10**18;
    }

    /**
     * @dev Set gas price
     * @param _gasPrice gas price
     */
    function setGasPrice(uint256 _gasPrice) external onlyOwner {
        gasPrice = _gasPrice;
    }

    /**
     * @dev Open Auction
     * @param _nftId NFT id
     * @param _sBid Starting bid price
     * @param _withBnb With BNB price
     * @param _duration Auction opening duration time
     */
    function openAuction(
        uint256 _nftId,
        uint256 _sBid,
        uint256 _withBnb,
        uint256 _duration
    ) external {
        require(auctions[_nftId].isActive == false, "Ongoing auction detected");
        require(_duration > 0 && _sBid > 0, "Invalid input");
        require(_withBnb >= 1, "Invalid Bnb Price");
        require(sNft_.ownerOf(_nftId) == msg.sender, "Not NFT owner");

        // NFT Transfer to contract
        sNft_.transfer(_nftId, address(this));

        // Opening new auction
        auctions[_nftId].highestBid = _sBid;
        auctions[_nftId].withBnb = _withBnb;
        auctions[_nftId].closingTime = block.timestamp + _duration;
        auctions[_nftId].highestBidder = msg.sender;
        auctions[_nftId].originalOwner = msg.sender;
        auctions[_nftId].isActive = true;

        emit NewAuctionOpened(
            _nftId,
            auctions[_nftId].highestBid,
            auctions[_nftId].withBnb,
            auctions[_nftId].closingTime,
            auctions[_nftId].highestBidder
        );
    }

    /**
     * @dev Place Bid
     * @param _nftId NFT id
     */
    function placeBid(uint256 _nftId, uint256 _priceBid) external payable {
        require(auctions[_nftId].isActive == true, "Not active auction");
        require(
            auctions[_nftId].closingTime > block.timestamp,
            "Auction is closed"
        );
        require(msg.value >= auctions[_nftId].withBnb, "With Bnb not enought");

        require(_priceBid > auctions[_nftId].highestBid, "Bid is too low");

        // check allowance of msg.sender
        uint256 allowance = IERC20(wdaToken).allowance(
            msg.sender,
            address(this)
        );
        require(allowance >= _priceBid, "Over allowance");
        // Holding : Transfer Amount of price Bid to SM Wallet
        bool holding = IERC20(wdaToken).transferFrom(
            msg.sender,
            address(this),
            _priceBid
        );
        require(holding, "Token can't hold");

        if (auctions[_nftId].originalOwner != auctions[_nftId].highestBidder) {
            //Transfer WDA token to Previous Highest Bidder
            bool backWDA = IERC20(wdaToken).transferFrom(
                address(this),
                auctions[_nftId].highestBidder,
                auctions[_nftId].highestBid
            );
            require(backWDA, "transfer WDA Token failed");

            // Transfer BNB to Previous Highest Bidder
            (bool sent, ) = payable(auctions[_nftId].highestBidder).call{
                value: auctions[_nftId].withBnb
            }("");

            require(sent, "Transfer BNB failed");
        }

        auctions[_nftId].highestBid = _priceBid;
        auctions[_nftId].withBnb = msg.value;
        auctions[_nftId].highestBidder = msg.sender;

        emit BidPlaced(
            _nftId,
            auctions[_nftId].highestBid,
            auctions[_nftId].withBnb,
            auctions[_nftId].highestBidder
        );
    }

    /**
     * @dev Close Auction
     * @param _nftId NFT id
     */
    function closeAuction(uint256 _nftId) external {
        require(auctions[_nftId].isActive == true, "Not active auction");
        require(
            auctions[_nftId].closingTime <= block.timestamp,
            "Auction is not closed"
        );

        // Transfer BNB to Dao Treasury
        if (auctions[_nftId].originalOwner != auctions[_nftId].highestBidder) {
            (bool sent, ) = payable(auctions[_nftId].originalOwner).call{
                value: auctions[_nftId].withBnb
            }("");

            require(sent, "Transfer BNB failed");
        }

        // Transfer NFT to Highest Bidder
        sNft_.transfer(_nftId, auctions[_nftId].highestBidder);

        // Close Auction
        auctions[_nftId].isActive = false;

        emit AuctionClosed(
            _nftId,
            auctions[_nftId].highestBid,
            auctions[_nftId].withBnb,
            auctions[_nftId].highestBidder
        );
    }

    /**
     * @dev Withdraw BNB
     * @param _target Spender address
     * @param _amount Transfer amount
     */
    function withdraw(address _target, uint256 _amount) external onlyOwner {
        require(_target != address(0), "Invalid address");
        require(_amount > 0 && _amount < balances, "Invalid amount");

        payable(_target).transfer(_amount);

        balances = balances - _amount;
    }

    /**
     * @dev Withdraw WDA token
     * @param _target Spender address
     * @param _amount Transfer amount
     */
    function withdrawWDA(address _target, uint256 _amount) external onlyOwner {
        require(_target != address(0), "Invalid address");
        require(
            _amount > 0 && _amount < IERC20(wdaToken).balanceOf(address(this)),
            "Invalid amount"
        );
        IERC20(wdaToken).transferFrom(address(this), _target, _amount);
    }

    /*
     * @dev Set Dao Treasury Address
     * @param daoTreasuryAdress_ address
     */
    function setDaoTreasuryAddress(address daoTreasuryAddress_)
        external
        onlyOwner
    {
        daoTreasuryAddress = daoTreasuryAddress_;
    }
}