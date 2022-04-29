// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC165.sol";

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
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

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
    function transferFrom(address from, address to, uint256 tokenId) external;

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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.6;
pragma abicoder v2;

struct NFTItem {
    uint256 tokenId;
    string class;
    uint256 rare;
    uint256 bornTime;
    uint256 gender;
}

struct User {
    NFTItem[] nfts;
    address owner;
}

interface INFTCore {

    function changeClass(
        uint256 _tokenId,
        string memory _class
    ) external;

    function changeRare(
        uint256 _tokenId,
        uint256 _rare
    ) external;

    function getNFT(uint256 _tokenId) external view returns (NFTItem memory);

    function setNFTFactory(NFTItem memory _nft, uint256 _tokenId) external;

    function safeMintNFT(address _addr, uint256 tokenId) external;

    function getNextNFTId() external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <=0.8.0;
pragma abicoder v2;

import "./Context.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./RandInterface.sol";
import "./INFTCore.sol";
import "./IERC20.sol";
import "./ReentrancyGuard.sol";
import "./Pausable.sol";
import "./IERC721.sol";

contract NFTClaimBox is Ownable, Pausable, ReentrancyGuard {
    using SafeMath for uint256;
    INFTCore public nftCore;
    IERC721 public nft;
    IERC20 public nftToken;
    RandInterface public randManager;
    uint256 public PERCENTS_DIVIDER = 100;
    uint256 public TOTAL_BOX = 100000;
    uint256 public CURRENT_BOX = 0;
    uint256 public LIMIT_ADDRESS_BOX = 100;
    uint256 public TIME_STEP = 1 days;

    struct SaleBox {
        uint256 typeBox;
        uint256 price;
        uint256 startSale;
        uint256 endSale;
        uint256 fourRarePercent;
        uint256 thirdRarePercent;
        uint256 secondRarePercent;
    }

    mapping(uint256 => SaleBox) public saleBoxs;
    struct UserInfo {
        uint256 lastClaim;
        uint256 totalClaim;
    }

    event FeeSale(uint256 indexed tokenId, address buyer, uint256 fee);
    event Sale(
        uint256 indexed tokenId,
        address buyer,
        uint256 price,
        uint256 typeBox
    );
    event OpenBox(
        uint256 indexed tokenId,
        address buyer,
        uint256 boxId,
        uint256 typeBox
    );

    uint256 public feeSale = 0.001 ether;
    address payable public feeWallet;
    address payable public saleWallet;
    mapping(address => UserInfo) public userInfos;
    mapping(address => bool) public claimNormals;
    mapping(uint256 => bool) public openBoxs;

    constructor(
        address payable _feeWallet,
        address payable _saleWallet,
        address _nft,
        IERC20 _nftToken,
        address _randManager
    ) {
        nftCore = INFTCore(_nft);
        feeWallet = _feeWallet;
        saleWallet = _saleWallet;
        nftToken = _nftToken;
        nft = IERC721(_nft);
        randManager = RandInterface(_randManager);
        saleBoxs[0] = SaleBox(0, 0, 1636386254, 1670744879, 0, 0, 0);
        saleBoxs[1] = SaleBox(
            1,
            160 * 10**18,
            1636386254,
            1670744879,
            3,
            11,
            35
        );
        saleBoxs[2] = SaleBox(2, 0, 1636386254, 1670744879, 1, 11, 51);
    }

    function setFeeSale(uint256 _fee) public onlyOwner {
        feeSale = _fee;
    }

    function setNFTToken(IERC20 _address) public onlyOwner {
        nftToken = _address;
    }

    function setFeeWallet(address payable _wallet) public onlyOwner {
        feeWallet = _wallet;
    }

    function setTotalBox(uint256 _box) public onlyOwner {
        TOTAL_BOX = _box;
    }

    function setLimitBox(uint256 _box) public onlyOwner {
        LIMIT_ADDRESS_BOX = _box;
    }

    function setTimeStep(uint256 _time) public onlyOwner {
        TIME_STEP = _time;
    }

    function setSaleWallet(address payable _wallet) public onlyOwner {
        saleWallet = _wallet;
    }

    function setStartSale(uint256 typeBox, uint256 time) public onlyOwner {
        saleBoxs[typeBox].startSale = time;
    }

    function setEndSale(uint256 typeBox, uint256 time) public onlyOwner {
        saleBoxs[typeBox].endSale = time;
    }

    function setPriceBox(uint256 typeBox, uint256 price) public onlyOwner {
        saleBoxs[typeBox].price = price;
    }

    function setUserInfo(UserInfo memory userInfo, address userAddress) external onlyOwner {
        userInfos[userAddress] = userInfo;
    }

    function setPercentBox(
        uint256 typeBox,
        uint256 fourRarePercent,
        uint256 thirdRarePercent,
        uint256 secondRarePercent
    ) public onlyOwner {
        saleBoxs[typeBox].fourRarePercent = fourRarePercent;
        saleBoxs[typeBox].thirdRarePercent = thirdRarePercent;
        saleBoxs[typeBox].secondRarePercent = secondRarePercent;
    }

    /**
     * @dev Gets current Box price.
     */
    function getNFTPrice(uint256 _typeBox)
        public
        view
        returns (uint256 priceSale)
    {
        return saleBoxs[_typeBox].price;
    }

    /**
     * @dev Claim Normal
     */
    function claimNormal(uint256 _amount)
        public
        payable
        nonReentrant
        whenNotPaused
    {
        require(CURRENT_BOX.add(1) <= TOTAL_BOX, "box already sold out");
        uint256 typeBox = 0;
        _claimNormal(typeBox, _amount);
        CURRENT_BOX = CURRENT_BOX.add(1);
    }

    /**
     * @dev claimWithFee
     */
    function claimWithFee(uint256 _amount)
        public
        payable
        nonReentrant
        whenNotPaused
    {
        require(CURRENT_BOX.add(1) <= TOTAL_BOX, "box already sold out");
        uint256 typeBox = 1;
        _claimWithFee(typeBox, _amount);
        CURRENT_BOX = CURRENT_BOX.add(1);
    }

    /**
     * @dev claimWithFee
     */
    function claimWithoutFee(uint256 _amount)
        public
        payable
        nonReentrant
        whenNotPaused
    {
        require(CURRENT_BOX.add(1) <= TOTAL_BOX, "box already sold out");
        uint256 typeBox = 2;
        _claimWithoutFee(typeBox, _amount);
        CURRENT_BOX = CURRENT_BOX.add(1);
    }

    /**
     * @dev Sale NFT
     */
    function _claimNormal(uint256 _typeBox, uint256 _amount) internal {
        require(
            block.timestamp >= saleBoxs[_typeBox].startSale,
            "Sale has not started yet."
        );
        require(
            block.timestamp <= saleBoxs[_typeBox].endSale,
            "Sale already ended"
        );
        require(msg.value == feeSale, "Amount of BNB sent is not correct.");
        require(!claimNormals[_msgSender()], "already claim normal box");
        if (feeSale > 0) {
            feeWallet.transfer(feeSale);
        }
        claimNormals[_msgSender()] = true;
        uint256 tokenId = nftCore.getNextNFTId();
        nftCore.safeMintNFT(_msgSender(), tokenId);
        NFTItem memory nftItem = NFTItem(
            tokenId,
            "Uka Doge",
            0,
            block.timestamp,
            0
        );
        nftCore.setNFTFactory(nftItem, tokenId);
        emit Sale(tokenId, _msgSender(), _amount, _typeBox);
    }

    /**
     * @dev _claimWithoutFee
     */
    function _claimWithoutFee(uint256 _typeBox, uint256 _amount) internal {
        require(
            block.timestamp >= saleBoxs[_typeBox].startSale,
            "Sale has not started yet."
        );
        require(
            block.timestamp <= saleBoxs[_typeBox].endSale,
            "Sale already ended"
        );
        require(msg.value == feeSale, "Amount of BNB sent is not correct.");
        UserInfo storage user = userInfos[_msgSender()];
        if (user.lastClaim == 0) {
            user.lastClaim = block.timestamp;
        }
        if (user.lastClaim.add(TIME_STEP) < block.timestamp) {
            user.lastClaim = block.timestamp;
            user.totalClaim = 0;
        }
        require(
            user.totalClaim.add(1) <= LIMIT_ADDRESS_BOX &&
                user.lastClaim.add(TIME_STEP) > block.timestamp,
            "not valid rule claim"
        );
        user.totalClaim = user.totalClaim.add(1);
        if (feeSale > 0) {
            feeWallet.transfer(feeSale);
        }
        randManager.randMod(_msgSender(), PERCENTS_DIVIDER);
        uint256 rareRand = randManager.currentRandMod();
        uint256 rare;
        if (rareRand <= saleBoxs[_typeBox].fourRarePercent) {
            rare = 3;
        }
        if (
            rareRand > saleBoxs[_typeBox].fourRarePercent &&
            rareRand <= saleBoxs[_typeBox].thirdRarePercent
        ) {
            rare = 2;
        }

        if (
            rareRand > saleBoxs[_typeBox].thirdRarePercent &&
            rareRand <= saleBoxs[_typeBox].secondRarePercent
        ) {
            rare = 1;
        }

        uint256 tokenId;
        if (rare == 3) {
            tokenId = nftCore.getNextNFTId();
            nftCore.safeMintNFT(_msgSender(), tokenId);
            NFTItem memory nftItem = NFTItem(
                tokenId,
                "Uka Doge Box",
                3,
                block.timestamp,
                0
            );
            nftCore.setNFTFactory(nftItem, tokenId);
        }
        if (rare == 2) {
            tokenId = nftCore.getNextNFTId();
            nftCore.safeMintNFT(_msgSender(), tokenId);
            NFTItem memory nftItem = NFTItem(
                tokenId,
                "Uka Doge Box",
                2,
                block.timestamp,
                0
            );
            nftCore.setNFTFactory(nftItem, tokenId);
        }
        if (rare == 1) {
            tokenId = nftCore.getNextNFTId();
            nftCore.safeMintNFT(_msgSender(), tokenId);
            NFTItem memory nftItem = NFTItem(
                tokenId,
                "Uka Doge Box",
                1,
                block.timestamp,
                0
            );
            nftCore.setNFTFactory(nftItem, tokenId);
        }

        emit Sale(tokenId, _msgSender(), _amount, _typeBox);
    }

    /**
     * @dev _claimWithoutFee
     */
    function _claimWithFee(uint256 _typeBox, uint256 _amount) internal {
        require(
            block.timestamp >= saleBoxs[_typeBox].startSale,
            "Sale has not started yet."
        );
        require(
            block.timestamp <= saleBoxs[_typeBox].endSale,
            "Sale already ended"
        );
        require(
            getNFTPrice(_typeBox) == _amount,
            "Amount of token sent is not correct."
        );
        require(
            nftToken.allowance(msg.sender, address(this)) >= _amount,
            "Token allowance too low"
        );
        require(msg.value == feeSale, "Amount of BNB sent is not correct.");
        UserInfo storage user = userInfos[_msgSender()];
        if (user.lastClaim == 0) {
            user.lastClaim = block.timestamp;
        }
        if (user.lastClaim.add(TIME_STEP) < block.timestamp) {
            user.lastClaim = block.timestamp;
            user.totalClaim = 0;
        }
        require(
            user.totalClaim.add(1) <= LIMIT_ADDRESS_BOX &&
                user.lastClaim.add(TIME_STEP) > block.timestamp,
            "not valid rule claim"
        );
        user.totalClaim = user.totalClaim.add(1);
        nftToken.transferFrom(msg.sender, saleWallet, _amount);
        if (feeSale > 0) {
            feeWallet.transfer(feeSale);
        }
        randManager.randMod(_msgSender(), PERCENTS_DIVIDER);
        uint256 rareRand = randManager.currentRandMod();
        uint256 rare;
        if (rareRand <= saleBoxs[_typeBox].fourRarePercent) {
            rare = 3;
        }
        if (
            rareRand > saleBoxs[_typeBox].fourRarePercent &&
            rareRand <= saleBoxs[_typeBox].thirdRarePercent
        ) {
            rare = 2;
        }

        if (
            rareRand > saleBoxs[_typeBox].thirdRarePercent &&
            rareRand <= saleBoxs[_typeBox].secondRarePercent
        ) {
            rare = 1;
        }

        if (rareRand > saleBoxs[_typeBox].secondRarePercent) {
            rare = 0;
        }
        uint256 tokenId;
        if (rare == 3) {
            tokenId = nftCore.getNextNFTId();
            nftCore.safeMintNFT(_msgSender(), tokenId);
            NFTItem memory nftItem = NFTItem(
                tokenId,
                "Uka Doge Box",
                4,
                block.timestamp,
                1
            );
            nftCore.setNFTFactory(nftItem, tokenId);
        }
        if (rare == 2) {
            tokenId = nftCore.getNextNFTId();
            nftCore.safeMintNFT(_msgSender(), tokenId);
            NFTItem memory nftItem = NFTItem(
                tokenId,
                "Uka Doge Box",
                3,
                block.timestamp,
                1
            );
            nftCore.setNFTFactory(nftItem, tokenId);
        }
        if (rare == 1) {
            tokenId = nftCore.getNextNFTId();
            nftCore.safeMintNFT(_msgSender(), tokenId);
            NFTItem memory nftItem = NFTItem(
                tokenId,
                "Uka Doge Box",
                2,
                block.timestamp,
                1
            );
            nftCore.setNFTFactory(nftItem, tokenId);
        }
        if (rare == 0) {
            tokenId = nftCore.getNextNFTId();
            nftCore.safeMintNFT(_msgSender(), tokenId);
            NFTItem memory nftItem = NFTItem(
                tokenId,
                "Uka Doge Box",
                1,
                block.timestamp,
                1
            );
            nftCore.setNFTFactory(nftItem, tokenId);
        }

        emit Sale(tokenId, _msgSender(), _amount, _typeBox);
    }

    function openBox(uint256 boxId) public whenNotPaused nonReentrant {
        require(nft.ownerOf(boxId) == _msgSender(), "not own");
        require(!openBoxs[boxId], "already open");
        require(
            keccak256(abi.encodePacked(nftCore.getNFT(boxId).class)) ==
                keccak256(abi.encodePacked("Uka Doge Box")),
            "not a box"
        );
        uint256 rare = nftCore.getNFT(boxId).rare;
        uint256 typeBox = nftCore.getNFT(boxId).gender;
        randManager.randMod(_msgSender(), PERCENTS_DIVIDER);
        uint256 rareRand = randManager.currentRandMod();
        uint256 tokenId;
        openBoxs[boxId] = true;
        if (typeBox == 0) {
            if (rare == 3) {
                if (rareRand <= 10) {
                    tokenId = nftCore.getNextNFTId();
                    nftCore.safeMintNFT(_msgSender(), tokenId);
                    NFTItem memory nftItem = NFTItem(
                        tokenId,
                        "Uka Doge",
                        3,
                        block.timestamp,
                        0
                    );
                    nftCore.setNFTFactory(nftItem, tokenId);
                }
                if (rareRand > 10) {
                    tokenId = nftCore.getNextNFTId();
                    nftCore.safeMintNFT(_msgSender(), tokenId);
                    NFTItem memory nftItem = NFTItem(
                        tokenId,
                        "Uka Doge",
                        2,
                        block.timestamp,
                        0
                    );
                    nftCore.setNFTFactory(nftItem, tokenId);
                }
            }
            if (rare == 2) {
                if (rareRand <= 10) {
                    tokenId = nftCore.getNextNFTId();
                    nftCore.safeMintNFT(_msgSender(), tokenId);
                    NFTItem memory nftItem = NFTItem(
                        tokenId,
                        "Uka Doge",
                        2,
                        block.timestamp,
                        0
                    );
                    nftCore.setNFTFactory(nftItem, tokenId);
                }
                if (rareRand > 10) {
                    tokenId = nftCore.getNextNFTId();
                    nftCore.safeMintNFT(_msgSender(), tokenId);
                    NFTItem memory nftItem = NFTItem(
                        tokenId,
                        "Uka Doge",
                        1,
                        block.timestamp,
                        0
                    );
                    nftCore.setNFTFactory(nftItem, tokenId);
                }
            }
            if (rare == 1) {
                if (rareRand <= 10) {
                    tokenId = nftCore.getNextNFTId();
                    nftCore.safeMintNFT(_msgSender(), tokenId);
                    NFTItem memory nftItem = NFTItem(
                        tokenId,
                        "Uka Doge",
                        1,
                        block.timestamp,
                        0
                    );
                    nftCore.setNFTFactory(nftItem, tokenId);
                }
                if (rareRand > 10) {
                    tokenId = nftCore.getNextNFTId();
                    nftCore.safeMintNFT(_msgSender(), tokenId);
                    NFTItem memory nftItem = NFTItem(
                        tokenId,
                        "Uka Doge",
                        0,
                        block.timestamp,
                        0
                    );
                    nftCore.setNFTFactory(nftItem, tokenId);
                }
            }
        }

        if (typeBox == 1) {
            if (rare == 4) {
                if (rareRand <= 10) {
                    tokenId = nftCore.getNextNFTId();
                    nftCore.safeMintNFT(_msgSender(), tokenId);
                    NFTItem memory nftItem = NFTItem(
                        tokenId,
                        "Uka Doge",
                        4,
                        block.timestamp,
                        0
                    );
                    nftCore.setNFTFactory(nftItem, tokenId);
                }
                if (rareRand > 10) {
                    tokenId = nftCore.getNextNFTId();
                    nftCore.safeMintNFT(_msgSender(), tokenId);
                    NFTItem memory nftItem = NFTItem(
                        tokenId,
                        "Uka Doge",
                        3,
                        block.timestamp,
                        0
                    );
                    nftCore.setNFTFactory(nftItem, tokenId);
                }
            }
            if (rare == 3) {
                if (rareRand <= 10) {
                    tokenId = nftCore.getNextNFTId();
                    nftCore.safeMintNFT(_msgSender(), tokenId);
                    NFTItem memory nftItem = NFTItem(
                        tokenId,
                        "Uka Doge",
                        3,
                        block.timestamp,
                        0
                    );
                    nftCore.setNFTFactory(nftItem, tokenId);
                }
                if (rareRand > 10) {
                    tokenId = nftCore.getNextNFTId();
                    nftCore.safeMintNFT(_msgSender(), tokenId);
                    NFTItem memory nftItem = NFTItem(
                        tokenId,
                        "Uka Doge",
                        2,
                        block.timestamp,
                        0
                    );
                    nftCore.setNFTFactory(nftItem, tokenId);
                }
            }
            if (rare == 2) {
                if (rareRand <= 10) {
                    tokenId = nftCore.getNextNFTId();
                    nftCore.safeMintNFT(_msgSender(), tokenId);
                    NFTItem memory nftItem = NFTItem(
                        tokenId,
                        "Uka Doge",
                        2,
                        block.timestamp,
                        0
                    );
                    nftCore.setNFTFactory(nftItem, tokenId);
                }
                if (rareRand > 10) {
                    tokenId = nftCore.getNextNFTId();
                    nftCore.safeMintNFT(_msgSender(), tokenId);
                    NFTItem memory nftItem = NFTItem(
                        tokenId,
                        "Uka Doge",
                        1,
                        block.timestamp,
                        0
                    );
                    nftCore.setNFTFactory(nftItem, tokenId);
                }
            }
            if (rare == 1) {
                if (rareRand <= 10) {
                    tokenId = nftCore.getNextNFTId();
                    nftCore.safeMintNFT(_msgSender(), tokenId);
                    NFTItem memory nftItem = NFTItem(
                        tokenId,
                        "Uka Doge",
                        1,
                        block.timestamp,
                        0
                    );
                    nftCore.setNFTFactory(nftItem, tokenId);
                }
                if (rareRand > 10) {
                    tokenId = nftCore.getNextNFTId();
                    nftCore.safeMintNFT(_msgSender(), tokenId);
                    NFTItem memory nftItem = NFTItem(
                        tokenId,
                        "Uka Doge",
                        0,
                        block.timestamp,
                        0
                    );
                    nftCore.setNFTFactory(nftItem, tokenId);
                }
            }
        }
        emit OpenBox(tokenId, _msgSender(), boxId, typeBox);
    }

    /**
     * @dev Withdraw bnb from this contract (Callable by owner only)
     */
    function handleForfeitedBalance(
        address coinAddress,
        uint256 value,
        address payable to
    ) public onlyOwner {
        if (coinAddress == address(0)) {
            return to.transfer(value);
        }
        IERC20(coinAddress).transfer(to, value);
    }

    function getSaleStore(uint256 _typeBox)
        public
        view
        returns (SaleBox memory _saleStore)
    {
        return saleBoxs[_typeBox];
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "./Context.sol";
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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }    
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "./Ownable.sol";

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() external onlyOwner whenNotPaused returns (bool) {
    paused = true;
    emit Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() external onlyOwner whenPaused returns (bool) {
    paused = false;
    emit Unpause();
    return true;
  }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.6;

interface RandInterface {
    function currentRandMod() external view returns(uint);
    function randMod(address userAddress, uint256 modulus) external returns(uint);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}