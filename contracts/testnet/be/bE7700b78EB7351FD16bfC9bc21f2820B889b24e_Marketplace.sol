/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-02
 */

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IBEP165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IBEP721 is IBEP165 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

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

    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

//   __  __            _        _         _
//  |  \/  |          | |      | |       | |
//  | \  / | __ _ _ __| | _____| |_ _ __ | | __ _  ___ ___
//  | |\/| |/ _` | '__| |/ / _ \ __| '_ \| |/ _` |/ __/ _ \
//  | |  | | (_| | |  |   <  __/ |_| |_) | | (_| | (_|  __/
//  |_|  |_|\__,_|_|  |_|\_\___|\__| .__/|_|\__,_|\___\___|
//                                 | |
//                                 |_|

contract Marketplace is Ownable {
    IBEP20 public JOG;
    IBEP721 public SneakerNFT;
    uint256 delaySellTime;
    uint256 delayBuyTime;

    constructor(address _JOG, address _SneakerNFT) {
        JOG = IBEP20(_JOG);
        SneakerNFT = IBEP721(_SneakerNFT);
        delaySellTime = 180 seconds;
        delayBuyTime = 60 seconds;
    }

    function setDelaySellTime(uint256 num) public onlyOwner {
        delaySellTime = num * 1 seconds;
    }

    function setDelayBuyTime(uint256 num) public onlyOwner {
        delayBuyTime = num * 1 seconds;
    }

    struct Sneaker {
        uint256 tokenID;
        uint256 price;
        bool onSell;
        address owner;
        uint256 blockTime;
    }

    // TokenId =>
    mapping(uint256 => Sneaker) public Sneakers;

    // Events
    event OnSellSneaker(uint256 TokenID, uint256 price);
    event OnCancelSneakerSale(uint256 TokenID);
    event BuySneaker(address indexed sender, uint256 price);

    function sell(uint256 TokenID, uint256 price) public {
        require(
            SneakerNFT.ownerOf(TokenID) == msg.sender,
            "You do not own this token"
        );
        Sneaker storage s = Sneakers[TokenID];
        require(block.timestamp > s.blockTime, "Not avaiable, try again later");
        (
            s.tokenID = TokenID,
            s.price = price,
            s.onSell = true,
            s.owner = msg.sender,
            s.blockTime = block.timestamp + delayBuyTime
        );

        SneakerNFT.transferFrom(msg.sender, address(this), TokenID);
        emit OnSellSneaker(TokenID, price);
    }

    function cancelSale(uint256 TokenID) public {
        Sneaker storage s = Sneakers[TokenID];
        require(s.onSell, "Can not cancel - have not on sale yet");
        require(s.owner == msg.sender, "You do not own this token");
        s.price = 0;
        s.onSell = false;
        SneakerNFT.transferFrom(address(this), msg.sender, TokenID);
        emit OnCancelSneakerSale(TokenID);
    }

    function buy(uint256 TokenID) public {
        Sneaker storage s = Sneakers[TokenID];
        require(block.timestamp > s.blockTime, "Not avaiable, try again later");

        require(JOG.balanceOf(msg.sender) >= s.price, "Don't have enough JOG");
        require(s.onSell, "Can not buy - Sale is end");

        // Buyer pay seller the price
        JOG.approve(address(this), s.price);
        JOG.transferFrom(msg.sender, s.owner, s.price);

        SneakerNFT.transferFrom(address(this), msg.sender, TokenID);
        s.onSell = false;
        s.blockTime = block.timestamp + delaySellTime;

        emit BuySneaker(msg.sender, s.price);
    }

    function forceCancelSale(uint256 TokenID) public onlyOwner {
        Sneaker storage s = Sneakers[TokenID];
        SneakerNFT.transferFrom(address(this), s.owner, TokenID);
        s.onSell = false;
    }

    function forceCancelHeroSale(uint256[] memory TokenIDs) public onlyOwner {
        for (uint256 i = 0; i < TokenIDs.length; i++) {
            Sneaker storage s = Sneakers[TokenIDs[i]];
            require(s.onSell, "Can not cancel - have not on sale yet");

            SneakerNFT.transferFrom(address(this), s.owner, TokenIDs[i]);
            s.price = 0;
            s.onSell = false;
        }
    }

    function changeToken(address _newJOG, address _newSneakerNFT)
        public
        onlyOwner
    {
        JOG = IBEP20(_newJOG);
        SneakerNFT = IBEP721(_newSneakerNFT);
    }

    function withdrawAsset(address tokenContract) public onlyOwner {
        IBEP20(tokenContract).transfer(
            owner(),
            IBEP20(tokenContract).balanceOf(address(this))
        );
    }

    receive() external payable {}

    function withdrawBNB() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function getAddressOwner(uint256 TokenId) public view returns (address) {
        return SneakerNFT.ownerOf(TokenId);
    }
}