/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

// Sources flattened with hardhat v2.5.0 https://hardhat.org

// File @openzeppelin/contracts/utils/introspection/[email protected]

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// File @openzeppelin/contracts/token/ERC721/[email protected]

// MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}


// File contracts/libs/TransferHelper.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value,gas:5000}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


// File contracts/interfaces/INestNFTAuction.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

/// @dev Defines methods for Auction of NFT
interface INestNFTAuction {

    /// @dev Start an auction event
    /// @param owner Owner of auction
    /// @param tokenId tokenId of target NFT
    /// @param price Starting price, 4 decimals
    /// @param index Index of auction
    event StartAuction(address owner, uint tokenId, uint price, uint index);

    /// @dev Bid for the auction event
    /// @param index Index of target auction
    /// @param bidder Address of bidder
    /// @param price Bid price, 4 decimals
    event Bid(uint index, address bidder, uint price);

    /// @dev End the auction and get NFT event
    /// @param index Index of target auction
    /// @param sender Address of sender
    event EndAuction(uint index, address sender);

    // Auction view
    struct AuctionView {
        // Address of bidder
        address bidder;
        // Price of last bidder, by nest, 0 decimal
        uint32 price;
        // Total bidder reward, by nest, 0 decimal
        uint32 reward;
        // The timestamp of uint32 can be expressed to 2106
        uint32 endTime;

        // Address index of owner
        address owner;
        // Token id of target nft
        uint32 tokenId;
        // Block number of start auction
        uint32 startBlock;
        uint32 index;
    }

    /// @dev List auctions
    /// @param offset Skip previous (offset) records
    /// @param count Return (count) records
    /// @param order Order. 0 reverse order, non-0 positive order
    /// @return auctionArray List of auctions
    function list(uint offset, uint count, uint order) external view returns (AuctionView[] memory auctionArray);

    /// @dev Start an NFT auction
    /// @param tokenId tokenId of target NFT
    /// @param price Starting price, 0 decimals
    /// @param cycle Cycle of auction, by seconds
    function startAuction(uint tokenId, uint price, uint cycle) external;

    /// @dev Bid for the auction
    /// @param index Index of target auction
    /// @param price Bid price, 0 decimals
    function bid(uint index, uint price) external;

    /// @dev End the auction and get NFT
    /// @param index Index of target auction
    function endAuction(uint index) external;
}


// File contracts/interfaces/INestMapping.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

/// @dev The interface defines methods for nest builtin contract address mapping
interface INestMapping {

    /// @dev Set the built-in contract address of the system
    /// @param nestTokenAddress Address of nest token contract
    /// @param nestNodeAddress Address of nest node contract
    /// @param nestLedgerAddress INestLedger implementation contract address
    /// @param nestMiningAddress INestMining implementation contract address for nest
    /// @param ntokenMiningAddress INestMining implementation contract address for ntoken
    /// @param nestPriceFacadeAddress INestPriceFacade implementation contract address
    /// @param nestVoteAddress INestVote implementation contract address
    /// @param nestQueryAddress INestQuery implementation contract address
    /// @param nnIncomeAddress NNIncome contract address
    /// @param nTokenControllerAddress INTokenController implementation contract address
    function setBuiltinAddress(
        address nestTokenAddress,
        address nestNodeAddress,
        address nestLedgerAddress,
        address nestMiningAddress,
        address ntokenMiningAddress,
        address nestPriceFacadeAddress,
        address nestVoteAddress,
        address nestQueryAddress,
        address nnIncomeAddress,
        address nTokenControllerAddress
    ) external;

    /// @dev Get the built-in contract address of the system
    /// @return nestTokenAddress Address of nest token contract
    /// @return nestNodeAddress Address of nest node contract
    /// @return nestLedgerAddress INestLedger implementation contract address
    /// @return nestMiningAddress INestMining implementation contract address for nest
    /// @return ntokenMiningAddress INestMining implementation contract address for ntoken
    /// @return nestPriceFacadeAddress INestPriceFacade implementation contract address
    /// @return nestVoteAddress INestVote implementation contract address
    /// @return nestQueryAddress INestQuery implementation contract address
    /// @return nnIncomeAddress NNIncome contract address
    /// @return nTokenControllerAddress INTokenController implementation contract address
    function getBuiltinAddress() external view returns (
        address nestTokenAddress,
        address nestNodeAddress,
        address nestLedgerAddress,
        address nestMiningAddress,
        address ntokenMiningAddress,
        address nestPriceFacadeAddress,
        address nestVoteAddress,
        address nestQueryAddress,
        address nnIncomeAddress,
        address nTokenControllerAddress
    );

    /// @dev Get address of nest token contract
    /// @return Address of nest token contract
    function getNestTokenAddress() external view returns (address);

    /// @dev Get address of nest node contract
    /// @return Address of nest node contract
    function getNestNodeAddress() external view returns (address);

    /// @dev Get INestLedger implementation contract address
    /// @return INestLedger implementation contract address
    function getNestLedgerAddress() external view returns (address);

    /// @dev Get INestMining implementation contract address for nest
    /// @return INestMining implementation contract address for nest
    function getNestMiningAddress() external view returns (address);

    /// @dev Get INestMining implementation contract address for ntoken
    /// @return INestMining implementation contract address for ntoken
    function getNTokenMiningAddress() external view returns (address);

    /// @dev Get INestPriceFacade implementation contract address
    /// @return INestPriceFacade implementation contract address
    function getNestPriceFacadeAddress() external view returns (address);

    /// @dev Get INestVote implementation contract address
    /// @return INestVote implementation contract address
    function getNestVoteAddress() external view returns (address);

    /// @dev Get INestQuery implementation contract address
    /// @return INestQuery implementation contract address
    function getNestQueryAddress() external view returns (address);

    /// @dev Get NNIncome contract address
    /// @return NNIncome contract address
    function getNnIncomeAddress() external view returns (address);

    /// @dev Get INTokenController implementation contract address
    /// @return INTokenController implementation contract address
    function getNTokenControllerAddress() external view returns (address);

    /// @dev Registered address. The address registered here is the address accepted by nest system
    /// @param key The key
    /// @param addr Destination address. 0 means to delete the registration information
    function registerAddress(string memory key, address addr) external;

    /// @dev Get registered address
    /// @param key The key
    /// @return Destination address. 0 means empty
    function checkAddress(string memory key) external view returns (address);
}


// File contracts/interfaces/INestGovernance.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev This interface defines the governance methods
interface INestGovernance is INestMapping {

    /// @dev Set governance authority
    /// @param addr Destination address
    /// @param flag Weight. 0 means to delete the governance permission of the target address. Weight is not 
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function setGovernance(address addr, uint flag) external;

    /// @dev Get governance rights
    /// @param addr Destination address
    /// @return Weight. 0 means to delete the governance permission of the target address. Weight is not 
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function getGovernance(address addr) external view returns (uint);

    /// @dev Check whether the target address has governance rights for the given target
    /// @param addr Destination address
    /// @param flag Permission weight. The permission of the target address must be greater than this weight 
    /// to pass the check
    /// @return True indicates permission
    function checkGovernance(address addr, uint flag) external view returns (bool);
}


// File contracts/NestBase.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev Base contract of nest
contract NestBase {

    /// @dev INestGovernance implementation contract address
    address public _governance;

    /// @dev To support open-zeppelin/upgrades
    /// @param governance INestGovernance implementation contract address
    function initialize(address governance) public virtual {
        require(_governance == address(0), "NEST:!initialize");
        _governance = governance;
    }

    /// @dev Rewritten in the implementation contract, for load other contract addresses. Call 
    ///      super.update(newGovernance) when overriding, and override method without onlyGovernance
    /// @param newGovernance INestGovernance implementation contract address
    function update(address newGovernance) public virtual {

        address governance = _governance;
        require(governance == msg.sender || INestGovernance(governance).checkGovernance(msg.sender, 0), "NEST:!gov");
        _governance = newGovernance;
    }

    //---------modifier------------

    modifier onlyGovernance() {
        require(INestGovernance(_governance).checkGovernance(msg.sender, 0), "NEST:!gov");
        _;
    }

    modifier noContract() {
        require(msg.sender == tx.origin, "NEST:!contract");
        _;
    }
}


// File contracts/custom/NestFrequentlyUsed.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev This contract include frequently used data
contract NestFrequentlyUsed is NestBase {

    // // ETH:
    // // Address of nest token
    // address constant NEST_TOKEN_ADDRESS = 0x04abEdA201850aC0124161F037Efd70c74ddC74C;
    // // Address of NestOpenPrice contract
    // address constant NEST_OPEN_PRICE = 0xE544cF993C7d477C7ef8E91D28aCA250D135aa03;
    // // Address of nest vault
    // address constant NEST_VAULT_ADDRESS;

    // BSC:
    // Address of nest token
    address constant NEST_TOKEN_ADDRESS = 0x98f8669F6481EbB341B522fCD3663f79A3d1A6A7;
    // Address of NestOpenPrice contract
    address constant NEST_OPEN_PRICE = 0x09CE0e021195BA2c1CDE62A8B187abf810951540;
    // Address of nest vault
    address constant NEST_VAULT_ADDRESS = 0x65e7506244CDdeFc56cD43dC711470F8B0C43beE;
    // Address of direct poster
    address constant DIRECT_POSTER = 0x06Ca5C8eFf273009C94D963e0AB8A8B9b09082eF;
    // Address of CyberInk
    address constant CYBER_INK_ADDRESS = 0xCBB79049675F06AFF618CFEB74c2B0Bf411E064a;

    // // Polygon:
    // // Address of nest token
    // address constant NEST_TOKEN_ADDRESS = 0x98f8669F6481EbB341B522fCD3663f79A3d1A6A7;
    // // Address of NestOpenPrice contract
    // address constant NEST_OPEN_PRICE = 0x09CE0e021195BA2c1CDE62A8B187abf810951540;
    // // Address of nest vault
    // address constant NEST_VAULT_ADDRESS;

    // // KCC:
    // // Address of nest token
    // address constant NEST_TOKEN_ADDRESS = 0x98f8669F6481EbB341B522fCD3663f79A3d1A6A7;
    // // Address of NestOpenPrice contract
    // address constant NEST_OPEN_PRICE = 0x7DBe94A4D6530F411A1E7337c7eb84185c4396e6;
    // // Address of nest vault
    // address constant NEST_VAULT_ADDRESS;

    // USDT base
    uint constant USDT_BASE = 1 ether;
}

// import "../interfaces/INestGovernance.sol";

// /// @dev This contract include frequently used data
// contract NestFrequentlyUsed is NestBase {

//     // Address of nest token
//     address NEST_TOKEN_ADDRESS;
//     // Address of NestOpenPrice contract
//     address NEST_OPEN_PRICE;
//     // Address of nest vault
//     address NEST_VAULT_ADDRESS;
//     // Address of CyberInk
//     address CYBER_INK_ADDRESS;
//     // Address of direct poster
//     address DIRECT_POSTER;  // 0x06Ca5C8eFf273009C94D963e0AB8A8B9b09082eF;

//     // USDT base
//     uint constant USDT_BASE = 1 ether;

//     /// @dev Rewritten in the implementation contract, for load other contract addresses. Call 
//     ///      super.update(newGovernance) when overriding, and override method without onlyGovernance
//     /// @param newGovernance INestGovernance implementation contract address
//     function update(address newGovernance) public virtual override {
//         super.update(newGovernance);
//         NEST_TOKEN_ADDRESS = INestGovernance(newGovernance).getNestTokenAddress();
//         NEST_OPEN_PRICE = INestGovernance(newGovernance).checkAddress("nest.v4.openPrice");
//         NEST_VAULT_ADDRESS = INestGovernance(newGovernance).checkAddress("nest.app.vault");
//         DIRECT_POSTER = INestGovernance(newGovernance).checkAddress("nest.app.directPoster");
//         CYBER_INK_ADDRESS = INestGovernance(newGovernance).checkAddress("nest.app.cyberink");
//     }
// }


// File contracts/NestNFTAuction.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev Auction for NFT
contract NestNFTAuction is NestFrequentlyUsed, INestNFTAuction {

    // Auction information structure
    struct Auction {
        // Bid information: bidder(160)|price(32)|reward(32)|endTime(32)
        uint bade;

        // Address index of owner
        address owner;
        // Token id of target nft
        uint32 tokenId;
        // Block number of start auction
        uint32 startBlock;
    }

    // Price unit
    uint constant PRICE_UNIT = 0.01 ether;

    // Collect to PVM vault threshold (by PRICE_UNIT)
    uint constant COLLECT_THRESHOLD = 1000000;

    // All auctions
    Auction[] _auctions;

    // PVM vault temp
    uint _vault;

    constructor() {
    }

    /// @dev In order to reduce gas cost for bid() method, 
    function collect() public {
        TransferHelper.safeTransfer(NEST_TOKEN_ADDRESS, NEST_VAULT_ADDRESS, _vault * PRICE_UNIT);
        _vault = 0;
    }

    /// @dev List auctions
    /// @param offset Skip previous (offset) records
    /// @param count Return (count) records
    /// @param order Order. 0 reverse order, non-0 positive order
    /// @return auctionArray List of auctions
    function list(uint offset, uint count, uint order) 
        external view override returns (AuctionView[] memory auctionArray) {
        // Load auctions
        Auction[] storage auctions = _auctions;
        // Create result array
        auctionArray = new AuctionView[](count);
        uint length = auctions.length;
        uint i = 0;

        // Reverse order
        if (order == 0) {
            uint index = length - offset;
            uint end = index > count ? index - count : 0;
            while (index > end) {
                --index;
                auctionArray[i++] = _toAuctionView(auctions[index], index);
            }
        } 
        // Positive order
        else {
            uint index = offset;
            uint end = index + count;
            if (end > length) {
                end = length;
            }
            while (index < end) {
                auctionArray[i++] = _toAuctionView(auctions[index], index);
                ++index;
            }
        }
    }

    /// @dev Start an NFT auction
    /// @param tokenId tokenId of target NFT
    /// @param price Starting price, 0 decimals
    /// @param cycle Cycle of auction, by seconds
    function startAuction(uint tokenId, uint price, uint cycle) external override {
        require(tokenId < 0x100000000, "AUCTION:tokenId to large");
        require(price >= 990 && price < 0x100000000, "AUCTION:price too low");
        require(cycle >= 1 hours && cycle <= 1 weeks, "AUCTION:cycle not valid");
        
        emit StartAuction(msg.sender, tokenId, uint(price), _auctions.length);

        // Push auction information to the array
        _auctions.push(Auction(
            // Bid information: bidder(160)|price(32)|reward(32)|endTime(32)
            // After 2106, block.timestamp + cycle will > 0xFFFFFFFF, 
            // This is very far away, and there will be other alternatives
            (price << 64) | (block.timestamp + cycle),

            // owner
            msg.sender,
            // tokenId
            uint32(tokenId),
            // startBlock
            uint32(block.number)
        ));

        // Transfer the target NFT to this contract
        IERC721(CYBER_INK_ADDRESS).transferFrom(msg.sender, address(this), tokenId);
    }

    /// @dev Bid for the auction
    /// @param index Index of target auction
    /// @param price Bid price, 0 decimals
    function bid(uint index, uint price) external override {
        // Load target auction
        Auction storage auction = _auctions[index];

        // Bid information: bidder(160)|price(32)|reward(32)|endTime(32)
        uint bade = auction.bade;
        uint endTime = bade & 0xFFFFFFFF;
        uint reward = (bade >> 32) & 0xFFFFFFFF;
        uint lastPrice = (bade >> 64) & 0xFFFFFFFF;
        address bidder = address(uint160(bade >> 96));

        // Must auctioning
        require(block.timestamp <= endTime, "AUCTION:ended");
        // Price must gt last price
        require(price >= lastPrice + 1 ether / PRICE_UNIT && price < 0x100000000, "AUCTION:price too low");
        
        // Only transfer NEST, no Reentry problem
        TransferHelper.safeTransferFrom(NEST_TOKEN_ADDRESS, msg.sender, address(this), price * PRICE_UNIT);
        // Owner has no reward, bidder is 0 means no bidder
        if (bidder != address(0)) {
            uint halfGap = (price - lastPrice) >> 1;
            
            if ((_vault += halfGap / 5) >= COLLECT_THRESHOLD) {
                collect();
            }

            TransferHelper.safeTransfer(NEST_TOKEN_ADDRESS, bidder, (lastPrice + (halfGap << 2) / 5) * PRICE_UNIT);
            
            // price + lastPrice and price - lastPrice is always the same parity, 
            // So it's no need to consider the problem of dividing losses
            reward += halfGap;
        }

        // Update bid information: new bidder, new price, total reward
        // Bid information: bidder(160)|price(32)|reward(32)|endTime(32)
        // reward is impossible > 0xFFFFFFFF
        auction.bade = (uint(uint160(msg.sender)) << 96) | (price << 64) | (reward << 32) | endTime;

        emit Bid(index, msg.sender, uint(price));
    }

    /// @dev End the auction and get NFT
    /// @param index Index of target auction
    function endAuction(uint index) external override {
        Auction memory auction = _auctions[index];
        address owner = auction.owner;
        // owner is 0 means ended
        require(owner != address(0), "AUCTION:ended");

        // Bid information: bidder(160)|price(32)|reward(32)|endTime(32)
        uint bade = auction.bade;
        require(block.timestamp > (bade & 0xFFFFFFFF), "AUCTION:not end");
        address bidder = address(uint160(bade >> 96));
        // No bidder, auction failed, transfer nft to owner
        if (bidder == address(0)) {
            bidder = owner;
        } 
        // Auction success, transfer nft to bidder and transfer nest to owner
        else {
            TransferHelper.safeTransfer(
                NEST_TOKEN_ADDRESS, 
                owner, 
                (((bade >> 64) & 0xFFFFFFFF) - ((bade >> 32) & 0xFFFFFFFF)) * PRICE_UNIT
            );
        }

        // Mark as ended
        _auctions[index].owner = address(0);

        IERC721(CYBER_INK_ADDRESS).transferFrom(address(this), bidder, uint(auction.tokenId));
        emit EndAuction(index, msg.sender);
    }

    // Convert Auction to AuctionView
    function _toAuctionView(Auction memory auction, uint index) private pure returns (AuctionView memory auctionView) {
        // Bid information: bidder(160)|price(32)|reward(32)|endTime(32)
        uint bade = auction.bade;
        auctionView = AuctionView(
            address(uint160(bade >> 96)),
            uint32(bade >> 64),
            uint32(bade >> 32),
            uint32(bade),

            auction.owner,
            auction.tokenId,
            auction.startBlock,
            uint32(index)
        );
    }
}