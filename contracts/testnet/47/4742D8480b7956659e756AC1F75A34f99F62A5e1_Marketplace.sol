/**
 *Submitted for verification at BscScan.com on 2022-06-25
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory)
    {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

contract Marketplace is Ownable{
    using SafeMath for uint256;

    IERC721 public LandNFT;
    IERC721 public HeroNFT;

    IERC20 public HGB;
    uint256 public nftId;
    uint256 auctionId = 0;
    uint256 percentage;
    uint256 delaySellTime;
    uint256 delayBuyTime;

    // Struct
    struct Auction {
        uint256 bigLandId;
        uint256 endAt;
        bool started;
        bool ended;
        uint256 startPrice;
        uint256 priceStep;
        uint256 highestBid; //highestPrice
        address bidders;
        uint256[] smallLandId;
    }

    // Mapping
    mapping(uint256 => Auction) auctionHistory;
    // BigLandID => Auction Id
    mapping(uint256 => uint256) public AuctionByTokenId;

    // Event
    event NewAuctionCreated(
        uint256 dayAfter,
        uint256 startPrice,
        uint256 bigLandId
    );
    event Bid(address indexed sender, uint256 amount);
    event WithdrawReward(address indexed sender);

    // constructor
    constructor(
        address _HGB,
        address _LandNFTAddress,
        address _HeroNFTAddress
    ) {
        HGB = IERC20(_HGB);
        LandNFT = IERC721(_LandNFTAddress);
        HeroNFT = IERC721(_HeroNFTAddress);
        percentage = 0;
        delaySellTime = 3 minutes;
        delayBuyTime = 1 minutes;
    }

    function getDelaySellTime() public view returns (uint256) {
        return delaySellTime;
    }

    function setDelaySellTime(uint256 num) public onlyOwner{
        delaySellTime =  num * 1 minutes;
    }

    function getDelayBuyTime() public view returns (uint256) {
        return delayBuyTime;
    }

    function setDelayBuyTime(uint256 num) public onlyOwner{
        delayBuyTime =  num * 1 minutes;
    }


    function toString(uint256 i) public pure returns (string memory a) {
        a = Strings.toString(i);
        return string(abi.encodePacked("You not own token", " ", a));
    }

    function checkOwnerBigLand(uint256[] memory arr)
        public
        view
        returns (bool)
    {
        for (uint256 i = 0; i < arr.length; i++) {
            require(LandNFT.ownerOf(arr[i]) == msg.sender, toString(arr[i]));
        }
        return true;
    }

    function createBigLandAuction(
        uint256 _dayAfter,
        uint256 _startPrice,
        uint256 _bigLandID,
        uint256 _priceStep,
        uint256[] memory smallIdTokens
    ) public onlyOwner returns (bool) {
        require(checkOwnerBigLand(smallIdTokens));
        require(
            AuctionByTokenId[_bigLandID] == 0,
            "This Land is being auctioned"
        );
        auctionId += 1;
        Auction storage a = auctionHistory[auctionId];
        (
            a.bigLandId = _bigLandID,
            a.endAt = (_dayAfter * 1 days + block.timestamp),
            a.started = true,
            a.ended = false,
            a.startPrice = _startPrice,
            a.priceStep = _priceStep,
            a.highestBid = _startPrice,
            a.bidders = address(0),
            a.smallLandId = smallIdTokens
        );
        // Send token from owner to contract
        for (uint256 i = 0; i < smallIdTokens.length; i++) {
            // Send reward for winner
            LandNFT.transferFrom(owner(), address(this), smallIdTokens[i]);
        }
        AuctionByTokenId[_bigLandID] = auctionId;
        emit NewAuctionCreated(_dayAfter, _startPrice, _bigLandID);
        return true;
    }

    function bid(uint256 amount, uint256 _auctionId) external {
        Auction storage a = auctionHistory[_auctionId];

        require(msg.sender != owner(), "Owner can not bid");
        require(a.started == true, "Auction is not started yet");
        if (block.timestamp > a.endAt) {
            a.ended = true;
        }
        require(block.timestamp < a.endAt, "Auction is already Ended!");
        require(HGB.balanceOf(msg.sender) >= amount, "You must have HGB ");
        require(
            amount >= a.highestBid + a.priceStep,
            "please enter amount higher than previous bid"
        );

        if (a.bidders != address(0)) {
            // return HBG to previous bidder
            HGB.transferFrom(owner(), a.bidders, a.highestBid);
        }

        a.highestBid = amount;
        a.bidders = msg.sender;
        HGB.transferFrom(msg.sender, owner(), amount);
        emit Bid(msg.sender, amount);
    }

    function withdrawReward(uint256 _auctionId) public {
        Auction storage a = auctionHistory[_auctionId];
        uint256[] storage arr = a.smallLandId;

        require(
            block.timestamp > a.endAt,
            "Time is not up yet to claim or withdraw!"
        );
        require(a.ended == true, "Auction is Not Ended yet !");
        require(msg.sender == a.bidders, "Not the winner");
        for (uint256 i = 0; i < arr.length; i++) {
            // Send reward for winner
            LandNFT.transferFrom(address(this), msg.sender, arr[i]);
        }

        emit WithdrawReward(msg.sender);
    }

    function cancelAuction(uint256 _auctionId) public onlyOwner {
        Auction storage a = auctionHistory[_auctionId];
        uint256[] storage arr = a.smallLandId;
        forceEnd(_auctionId);
        for (uint256 i = 0; i < arr.length; i++) {
            // Send land token back to owner
            LandNFT.transferFrom(address(this), owner(), arr[i]);
        }
        delete AuctionByTokenId[a.bigLandId];
        delete auctionHistory[_auctionId];
    }

    function forceEnd(uint256 _auctionId) public onlyOwner {
        Auction storage a = auctionHistory[_auctionId];
        a.endAt = block.timestamp;
        a.ended = true;
    }

    function getAuctionById(uint256 _auctionId)
        public
        view
        returns (Auction memory)
    {
        return auctionHistory[_auctionId];
    }

    function changePercentage(uint256 newPer) public onlyOwner {
        percentage = newPer;
    }

    // BUY-SELL LandNFT >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    struct LandAsset {
        uint256 tokenID;
        uint256 price;
        bool onSell;
        address owner;
        uint256 blockTime;
    }

    // TokenId =>
    mapping(uint256 => LandAsset) public LandAssets;

    // Events
    event OnSellLand(uint256 TokenID, uint256 price);
    event OnCancelLandSale(uint256 TokenID);
    event BuyLand(address indexed sender, uint256 price);

    function sellLand(uint256 TokenID, uint256 price) public {
        require(
            LandNFT.ownerOf(TokenID) == msg.sender,
            "You do not own this token"
        );
        LandAsset storage l = LandAssets[TokenID];
        require(block.timestamp > l.blockTime, "Not avaiable, try again later");
        (
            l.tokenID = TokenID,
            l.price = price,
            l.onSell = true,
            l.owner = msg.sender,
            l.blockTime = block.timestamp + delayBuyTime
        );

        LandNFT.transferFrom(msg.sender, address(this), TokenID);
        emit OnSellLand(TokenID, price);
    }

    function cancelLandSale(uint256 TokenID) public {
        LandAsset storage l = LandAssets[TokenID];
        require(l.onSell, "Can not cancel - have not on sale yet");
        require(l.owner == msg.sender, "You do not own this token");
        l.price = 0;
        l.onSell = false;
        LandNFT.transferFrom(address(this), l.owner, TokenID);
        emit OnCancelLandSale(TokenID);
    }

    function forceCancelLandSale(uint256[] memory TokenIDs) public onlyOwner {
        for(uint i = 0; i < TokenIDs.length; i++) {
            LandAsset storage l = LandAssets[TokenIDs[i]];
            require(l.onSell, "Can not cancel - have not on sale yet");
            l.price = 0;
            l.onSell = false;
            LandNFT.transferFrom(address(this), l.owner, TokenIDs[i]);
        }
        
    }

    function buyLand(uint256 TokenID, uint256 amount) public {
        LandAsset storage l = LandAssets[TokenID];
        require(block.timestamp > l.blockTime, "Not avaiable, try again later");
        require(HGB.balanceOf(msg.sender) >= l.price, "Don't have enough HBG");
        require(l.onSell, "Can not buy - Sale is end");
        require(amount == l.price, "Can not buy - Price uneven error");

        // Buyer send percentage
         if(percentage > 0) {
            HGB.transferFrom(
                msg.sender,
                owner(),
                getCommissionPrice(l.price)
            );
             // Buyer pay seller the price - percentage
            HGB.transferFrom(msg.sender, l.owner, getAfterCommissionPrice(l.price));
        } else {
            HGB.transferFrom(msg.sender,l.owner, l.price);
        }


        LandNFT.transferFrom(address(this), msg.sender, TokenID);
        l.onSell = false;
        l.blockTime = block.timestamp + delaySellTime;

        emit BuyLand(msg.sender, l.price);
    }

    function getCommissionPrice(uint256 price) public view returns (uint256) {
        return price.mul(percentage).div(100);
    }

    function getAfterCommissionPrice(uint256 price)
        public
        view
        returns (uint256)
    {
        return price.sub(getCommissionPrice(price));
    }

    // BUY-SELL HeroNFT >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    struct HeroAsset {
        uint256 tokenID;
        uint256 price;
        bool onSell;
        address owner;
        uint256 blockTime;
    }

    // TokenId =>
    mapping(uint256 => HeroAsset) public HeroAssets;

    // Events
    event OnSellHero(uint256 TokenID, uint256 price);
    event OnCancelHeroSale(uint256 TokenID);
    event BuyHero(address indexed sender, uint256 price);

    function sellHero(uint256 TokenID, uint256 price) public {
        require(
            HeroNFT.ownerOf(TokenID) == msg.sender,
            "You do not own this token"
        );
        HeroAsset storage h = HeroAssets[TokenID];
        require(block.timestamp > h.blockTime, "Not avaiable, try again later");

        (
            h.tokenID = TokenID,
            h.price = price,
            h.onSell = true,
            h.owner = msg.sender,
            h.blockTime = block.timestamp + delayBuyTime

        );

        HeroNFT.transferFrom(msg.sender, address(this), TokenID);
        emit OnSellHero(TokenID, price);
    }

    function cancelHeroSale(uint256 TokenID) public {
        HeroAsset storage h = HeroAssets[TokenID];
        require(h.onSell, "Can not cancel - have not on sale yet");
        require(h.owner == msg.sender, "You do not own this token");
        h.price = 0;
        h.onSell = false;
        HeroNFT.transferFrom(address(this), h.owner, TokenID);
        emit OnCancelHeroSale(TokenID);
    }

    function forceCancelHeroSale(uint256[] memory TokenIDs) public onlyOwner {
        for(uint i = 0; i < TokenIDs.length; i++) {
            HeroAsset storage h = HeroAssets[TokenIDs[i]];
            require(h.onSell, "Can not cancel - have not on sale yet");
            h.price = 0;
            h.onSell = false;
            HeroNFT.transferFrom(address(this), h.owner, TokenIDs[i]);
        }
        
    }

    function buyHero(uint256 TokenID, uint256 amount) public {
        HeroAsset storage h = HeroAssets[TokenID];
        require(block.timestamp > h.blockTime, "Not avaiable, try again later");
        require(HGB.balanceOf(msg.sender) >= h.price, "Don't have enough HBG");
        require(h.onSell, "Can not buy - Sale is end");
        require(amount == h.price, "Can not buy - Price uneven error");

        // Buyer send percentage
        if(percentage > 0) {
            HGB.transferFrom(
                msg.sender,
                owner(),
                getCommissionPrice(h.price)
            );
             // Buyer pay seller the price - percentage
            HGB.transferFrom(msg.sender, h.owner, getAfterCommissionPrice(h.price));
        } else {
            HGB.transferFrom(msg.sender,h.owner, h.price);
            
        }
        HeroNFT.transferFrom(address(this), msg.sender, TokenID);
        h.onSell = false;
        h.blockTime = block.timestamp + delaySellTime;

        emit BuyHero(msg.sender, h.price);
    }

    function withdrawAssetFromContract(address tokenContract) public onlyOwner {
        IERC20(tokenContract).transfer(owner(), IERC20(tokenContract).balanceOf(address(this)));
    }

    receive() external payable{}
    function withdrawBNB(uint256 amount) external onlyOwner{
        payable(msg.sender).transfer(amount);
    }

    function getAddressOwner(uint256 tokenId) public view returns (address) {
        return HeroNFT.ownerOf(tokenId);
    }

    function changeToken(
        address newHGB,
        address newLand,
        address newHero
    ) public onlyOwner {
        HGB = IERC20(newHGB);
        LandNFT = IERC721(newLand);
        HeroNFT = IERC721(newHero);
    }

}