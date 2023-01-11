//SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

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

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

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
    function getApproved(
        uint256 tokenId
    ) external view returns (address operator);

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
    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool);

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
}

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }
}

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

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
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

contract Ownable {
    address private owner;

    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    // modifier to check if caller is owner
    modifier onlyOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public onlyOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}

contract FleaNFT is Context, ERC165, IERC721, IERC721Metadata, Ownable {
    using Address for address;

    // Token name
    string private constant _name = "Flea Mint NFT";

    // Token symbol
    string private constant _symbol = "FLEAM";

    // total number of NFTs Minted
    uint256 private _totalSupply;

    // Number of common tokens minted
    uint16 private _totalCommonMinted = 0;

    // Number of rare tokens minted
    uint16 private _totalRareMinted = 0;

    // Next common number
    uint16 private _nextCommonNumber = 0;

    // Number of legendary tokens minting
    uint16 private _totalLegendaryMinted = 0;

    // max supply cap
    uint256 public constant MAX_SUPPLY = 2001;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // base URI
    string private baseURI = "url";
    string private ending = ".json";

    // Rare Numbers
    uint[] private _rareNumbers = [
        1,
        2,
        3,
        4,
        5,
        6,
        8,
        9,
        99,
        100,
        101,
        102,
        103,
        104,
        105,
        106,
        107,
        108,
        109,
        141,
        110,
        112,
        113,
        114,
        115,
        116,
        117,
        118,
        119,
        122,
        133,
        144,
        155,
        166,
        177,
        199,
        200,
        211,
        220,
        221,
        223,
        224,
        225,
        226,
        227,
        228,
        229,
        233,
        244,
        255,
        277,
        322,
        332,
        334,
        335,
        336,
        337,
        338,
        339,
        344,
        355,
        366,
        363,
        377,
        399,
        400,
        434,
        440,
        441,
        442,
        443,
        445,
        446,
        447,
        448,
        449,
        466,
        422,
        411,
        477,
        499,
        500,
        511,
        522,
        533,
        544,
        550,
        551,
        552,
        553,
        554,
        556,
        557,
        558,
        559,
        566,
        577,
        588,
        599,
        600,
        611,
        622,
        633,
        644,
        655,
        660,
        661,
        662,
        663,
        664,
        665,
        667,
        668,
        669,
        677,
        688,
        699,
        700,
        711,
        722,
        733,
        744,
        766,
        770,
        771,
        772,
        773,
        774,
        775,
        776,
        778,
        779,
        788,
        799,
        800,
        811,
        822,
        833,
        844,
        855,
        877,
        880,
        881,
        882,
        883,
        884,
        885,
        886,
        887,
        889,
        899,
        900,
        911,
        922,
        933,
        944,
        955,
        966,
        977,
        988,
        990,
        991,
        992,
        993,
        994,
        995,
        996,
        997,
        998,
        1000,
        1001,
        1002,
        1003,
        1004,
        1005,
        1006,
        1007,
        1008,
        1009,
        1011,
        1022,
        1033,
        1044,
        1055,
        1066,
        1077,
        1088,
        1099,
        1101,
        1110,
        1112,
        1113,
        1114,
        1115,
        1116,
        1117,
        1118,
        1119,
        1120,
        1233,
        1244,
        1255,
        1266,
        1277,
        1288,
        1300,
        1330,
        1331,
        1332,
        1334,
        1335,
        1336,
        1337,
        1338,
        1339,
        1344,
        1355,
        1366,
        1377,
        1388,
        1399,
        1400,
        1422,
        1433,
        1440,
        1442,
        1443,
        1444,
        1445,
        1446,
        1447,
        1448,
        1449,
        1455,
        1466,
        1477,
        1488,
        1499,
        1500,
        1522,
        1533,
        1544,
        1550,
        1555,
        1566,
        1577,
        1588,
        1599,
        1600,
        1611,
        1622,
        1633,
        1644,
        1655,
        1660,
        1666,
        1677,
        1688,
        1699,
        1700,
        1711,
        1722,
        1733,
        1744,
        1755,
        1766,
        1770,
        1771,
        1777,
        1800,
        1822,
        1833,
        1844,
        1855,
        1866,
        1877,
        1899,
        1900,
        1911,
        1922,
        1933,
        1944,
        1955,
        1966,
        1977,
        1988,
        1940,
        1941,
        1942,
        1943,
        1945,
        1946,
        1947,
        1948,
        1950,
        1951,
        1952,
        1953,
        1954,
        1956,
        1957,
        1958,
        1959,
        1960,
        1961,
        1962,
        1963,
        1964,
        1965,
        1967,
        1968,
        1969,
        1970,
        1971,
        1972,
        1973,
        1974,
        1975,
        1976,
        1978,
        1980,
        1981,
        1982,
        1983,
        1984,
        1985,
        1986,
        1987,
        1989,
        1990,
        1992,
        1993,
        1994,
        1995,
        1996,
        1997,
        1998
    ];

    // Legendary Numbers
    uint[] private _legendaryNumbers = [
        0,
        7,
        33,
        40,
        44,
        50,
        55,
        60,
        66,
        70,
        77,
        80,
        88,
        90,
        111,
        121,
        131,
        188,
        202,
        222,
        252,
        262,
        288,
        292,
        299,
        300,
        313,
        323,
        333,
        373,
        383,
        388,
        393,
        404,
        414,
        420,
        424,
        433,
        444,
        454,
        455,
        464,
        474,
        484,
        488,
        494,
        505,
        515,
        525,
        545,
        555,
        565,
        585,
        595,
        606,
        616,
        626,
        636,
        656,
        666,
        686,
        696,
        707,
        717,
        727,
        737,
        747,
        757,
        767,
        777,
        787,
        797,
        808,
        818,
        828,
        838,
        848,
        858,
        868,
        878,
        888,
        898,
        909,
        939,
        969,
        979,
        989,
        999,
        1010,
        1020,
        1030,
        1040,
        1050,
        1060,
        1070,
        1080,
        1090,
        1100,
        1111,
        1121,
        1122,
        1131,
        1133,
        1141,
        1144,
        1151,
        1155,
        1161,
        1166,
        1171,
        1177,
        1181,
        1188,
        1191,
        1199,
        1202,
        1211,
        1212,
        1221,
        1222,
        1311,
        1313,
        1333,
        1404,
        1411,
        1414,
        1441,
        1464,
        1494,
        1505,
        1511,
        1515,
        1551,
        1565,
        1585,
        1606,
        1616,
        1626,
        1646,
        1661,
        1696,
        1707,
        1717,
        1737,
        1747,
        1757,
        1767,
        1787,
        1797,
        1808,
        1811,
        1818,
        1828,
        1838,
        1848,
        1858,
        1868,
        1880,
        1881,
        1882,
        1883,
        1884,
        1885,
        1886,
        1887,
        1888,
        1889,
        1898,
        1909,
        1919,
        1929,
        1939,
        1949,
        1979,
        1991,
        1999,
        2000
    ];

    // Enum representing Rarity
    enum Rarity {
        Common,
        Rare,
        Legendary
    }

    // Mapping to check if token id number is has type "Common or Rare or Legendary" Rarity Enum
    mapping(uint256 => Rarity) public tokenIdRarity;

    // ERC-20 Token Address to be accepted
    IERC20 public ERC20TokenToBeAccepted;

    // ERC-20 Rates to purchase NFT
    uint256 public commonRate = 500e18;
    uint256 public rareRate = 2500e18;
    uint256 public legendaryRate = 5000e18;

    ////////////////////////////////////////////////
    ///////////   CONSTRUCTOR            ///////////
    ////////////////////////////////////////////////

    constructor(address _ERC20TokenToBeAccepted) {
        ERC20TokenToBeAccepted = IERC20(_ERC20TokenToBeAccepted);

        // Adding the rare and legendary numbers to the mapping
        for (uint i = 0; i < _rareNumbers.length; i++) {
            tokenIdRarity[_rareNumbers[i]] = Rarity.Rare;
        }
        for (uint i = 0; i < _legendaryNumbers.length; i++) {
            tokenIdRarity[_legendaryNumbers[i]] = Rarity.Legendary;
        }
    }

    ////////////////////////////////////////////////
    ///////////   RESTRICTED FUNCTIONS   ///////////
    ////////////////////////////////////////////////

    function withdraw() external onlyOwner {
        (bool s, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }

    function withdrawERC20Token(address token_) external onlyOwner {
        require(token_ != address(0), "Zero Address");
        IERC20(token_).transfer(
            msg.sender,
            IERC20(token_).balanceOf(address(this))
        );
    }

    function withdrawERC721Token(
        address token_,
        uint256 tokenId
    ) external onlyOwner {
        require(token_ != address(0), "Zero Address");
        IERC721(token_).safeTransferFrom(address(this), msg.sender, tokenId);
    }

    function setNewERC20TokenToBeAccepted(
        address newERC20TokenToBeAccepted
    ) external onlyOwner {
        ERC20TokenToBeAccepted = IERC20(newERC20TokenToBeAccepted);
    }

    function setNewCommonRate(uint256 newRate) external onlyOwner {
        commonRate = newRate;
    }

    function setNewRareRate(uint256 newRate) external onlyOwner {
        rareRate = newRate;
    }

    function setNewLegendaryRate(uint256 newRate) external onlyOwner {
        legendaryRate = newRate;
    }

    function setBaseURI(string calldata newURI) external onlyOwner {
        require(
            bytes(newURI)[bytes(newURI).length - 1] == bytes1("/"),
            "Must set trailing slash"
        );
        baseURI = newURI;
    }

    function setURIExtention(string calldata newExtention) external onlyOwner {
        ending = newExtention;
    }

    function userMint(uint256 qty, uint256 amount, Rarity rarity) external {
        // This is where the user mints the NFT
        // Note: We will accept is the BUSD Token

        require(_totalSupply < MAX_SUPPLY, "All NFTs Have Been Minted");
        require(qty > 0, "Qty must be greater than 0.");
        require(uint8(rarity) <= 3, "Please enter a valid Rarity Enum");

        uint256 finalRate;

        if (Rarity.Common == rarity) {
            require(
                _totalCommonMinted <
                    MAX_SUPPLY -
                        (_rareNumbers.length + _legendaryNumbers.length),
                "All Common Rarity has been minted"
            );
            finalRate = commonRate * qty;
        } else if (Rarity.Rare == rarity) {
            require(
                _totalRareMinted < _rareNumbers.length,
                "All Rare Rarity has been minted"
            );
            finalRate = rareRate * qty;
        } else if (Rarity.Legendary == rarity) {
            require(
                _totalLegendaryMinted < _legendaryNumbers.length,
                "All Legendary Rarity has been minted"
            );
            finalRate = legendaryRate * qty;
        }

        require(
            amount * qty == finalRate,
            "Not enough amount to purchase NFTs."
        );

        ERC20TokenToBeAccepted.transferFrom(msg.sender, address(this), amount);

        for (uint i = 0; i < qty; i++) {
            _safeMint(msg.sender, rarity);
        }
    }

    function ownerMint(
        address[] calldata to,
        uint256[] calldata qty,
        Rarity[] calldata rarity
    ) external onlyOwner {
        // mint NFTs (only the owner of the contract can call this function)
        uint nUsers = to.length;
        for (uint j = 0; j < nUsers; j++) {
            for (uint i = 0; i < qty[j]; i++) {
                _safeMint(to[j], rarity[j]);
            }
        }
    }

    ////////////////////////////////////////////////
    ///////////     PUBLIC FUNCTIONS     ///////////
    ////////////////////////////////////////////////

    receive() external payable {}

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public override {
        address wpowner = ownerOf(tokenId);
        require(to != wpowner, "ERC721: approval to current owner");

        require(
            _msgSender() == wpowner || isApprovedForAll(wpowner, _msgSender()),
            "ERC721: not approved or owner"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(
        address _operator,
        bool approved
    ) public override {
        _setApprovalForAll(_msgSender(), _operator, approved);
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "caller not owner nor approved"
        );
        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "caller not owner nor approved"
        );
        _safeTransfer(from, to, tokenId, _data);
    }

    ////////////////////////////////////////////////
    ///////////     READ FUNCTIONS       ///////////
    ////////////////////////////////////////////////

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function totalCommonMinted() external view returns (uint16) {
        return _totalCommonMinted;
    }

    function totalRareMinted() external view returns (uint16) {
        return _totalRareMinted;
    }

    function totalLegendaryMinted() external view returns (uint16) {
        return _totalLegendaryMinted;
    }

    function getIDsByOwner(
        address owner
    ) external view returns (uint256[] memory) {
        uint256[] memory ids = new uint256[](balanceOf(owner));
        if (balanceOf(owner) == 0) return ids;
        uint256 count = 0;
        for (uint i = 0; i < _totalSupply; i++) {
            if (_owners[i] == owner) {
                ids[count] = i;
                count++;
            }
        }
        return ids;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address wpowner) public view override returns (uint256) {
        require(wpowner != address(0), "query for the zero address");
        return _balances[wpowner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view override returns (address) {
        address wpowner = _owners[tokenId];
        require(wpowner != address(0), "query for nonexistent token");
        return wpowner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public pure override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public pure override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(_exists(tokenId), "nonexistent token");

        string memory fHalf = string.concat(baseURI, uint2str(tokenId));
        return string.concat(fHalf, ending);
    }

    /**
        Converts A Uint Into a String
    */
    function uint2str(
        uint _i
    ) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(
        uint256 tokenId
    ) public view override returns (address) {
        require(_exists(tokenId), "ERC721: query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(
        address wpowner,
        address _operator
    ) public view override returns (bool) {
        return _operatorApprovals[wpowner][_operator];
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(
        address spender,
        uint256 tokenId
    ) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: nonexistent token");
        address wpowner = ownerOf(tokenId);
        return (spender == wpowner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(wpowner, spender));
    }

    ////////////////////////////////////////////////
    ///////////    INTERNAL FUNCTIONS    ///////////
    ////////////////////////////////////////////////

    function _getMintTokenId(Rarity rarity) internal returns (uint) {
        if (rarity == Rarity.Common) {
            while (tokenIdRarity[_nextCommonNumber] != Rarity.Common) {
                _nextCommonNumber++;
            }
            return _nextCommonNumber;
        } else if (rarity == Rarity.Rare) {
            return _rareNumbers[_totalRareMinted];
        } else if (rarity == Rarity.Legendary) {
            return _legendaryNumbers[_totalLegendaryMinted];
        }
        revert("Invalid value");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(address to, Rarity rarity) internal {
        uint getUpcomingMintTokenId = _getMintTokenId(rarity);
        _mint(to, getUpcomingMintTokenId, rarity);

        require(
            _checkOnERC721Received(address(0), to, getUpcomingMintTokenId, ""),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId, Rarity rarity) internal {
        require(!_exists(tokenId), "ERC721: token already minted");
        require(_totalSupply < MAX_SUPPLY, "All NFTs Have Been Minted");

        _balances[to] += 1;
        _owners[tokenId] = to;

        if (rarity == Rarity.Common) {
            _nextCommonNumber++;
            _totalCommonMinted++;
        } else if (rarity == Rarity.Rare) {
            _totalRareMinted++;
        } else if (rarity == Rarity.Legendary) {
            _totalLegendaryMinted++;
        }

        _totalSupply =
            _totalCommonMinted +
            _totalRareMinted +
            _totalLegendaryMinted;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal {
        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "ERC721: non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, "Incorrect owner");
        require(to != address(0), "zero address");
        require(balanceOf(from) > 0, "Zero Balance");

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        // Allocate balances
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        // emit transfer
        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address wpowner,
        address _operator,
        bool approved
    ) internal {
        require(wpowner != _operator, "ERC721: approve to caller");
        _operatorApprovals[wpowner][_operator] = approved;
        emit ApprovalForAll(wpowner, _operator, approved);
    }

    function onReceivedRetval() public pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try
                IERC721Receiver(to).onERC721Received(
                    _msgSender(),
                    from,
                    tokenId,
                    _data
                )
            returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
}