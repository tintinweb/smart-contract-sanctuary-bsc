pragma solidity ^0.8.9;

import "./IERC20.sol";
import "./Ownable.sol";
import "./IERC721.sol";
import "./Context.sol";
import "./Pausable.sol";

struct CarProps {
    uint8 model;
    uint16 speed;
    uint16 drift;
    uint16 acceleration;
    uint16 power;
}

interface IERC721Meta is IERC721 {
    function props(uint256 _id) external view returns (CarProps memory);
}

contract MarketPlace is Context, Ownable, Pausable, IERC721Receiver {
    uint256 public MAX_PRICE = 200000000000000; /// 2m VRIL
    Item[] public items;
    IERC20 nativeToken;
    IERC721Meta nftContract;
    address public _benf = address(0x569DFCa53FeC8D6b1f59fE5288532259C4a76157);

    struct Item {
        uint256 id;
        bool available;
        address owner;
        uint256 price;
    }

    constructor() public {
        nftContract = IERC721Meta(0x15aDb4BD4716DA3c21Fb64841672136240C2F64E);
        nativeToken = IERC20(0x62b811f5A3866Fe98A031c50Dd221eFA7BdcF851);
    }

    event ItemUpdated(uint256 _index, Item _item);
    event ItemAttached(uint256 _index, Item _item);
    event ItemDetached(uint256 _index, Item _item);
    event ItemSold(uint256 _index, Item _item);

    modifier ItemAccess(uint256 id) {
        uint256 _index = indexOfItem(id);
        require(_msgSender() == items[_index].owner, "FORBIDDEN");
        _;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    function setNftContract(address _contract) external onlyOwner {
        nftContract = IERC721Meta(_contract);
    }

    function setMaxPrice(uint256 _price) external onlyOwner {
        MAX_PRICE = _price;
    }

    function indexOfItem(uint256 id) public view returns (uint256) {
        for (uint256 i = 0; i < items.length; i++) {
            if (id == items[i].id) {
                return i;
            }
        }
        revert("Item not found");
    }

    function attach(uint256 id, uint256 price)
        external
        whenNotPaused
        returns (uint256 _index, Item memory _item)
    {
        require(price <= MAX_PRICE, "Price is very high");
        address nftOwner = nftContract.ownerOf(id);
        require(nftOwner == _msgSender(), "You are not the owner");
        nftContract.safeTransferFrom(nftOwner, address(this), id);
        _item = Item(id, true, nftOwner, price);
        try this.indexOfItem(id) returns (uint256 _i) {
            _index = _i;
            items[_index] = _item;
        } catch {
            items.push(_item);
            _index = items.length - 1;
        }
        emit ItemAttached(_index, _item);
    }

    function detach(uint256 id) external ItemAccess(id) whenNotPaused {
        uint256 _index = indexOfItem(id);
        Item memory _item = items[_index];
        require(_item.available, "Item is not available");
        items[_index].available = false;
        nftContract.safeTransferFrom(address(this), _item.owner, id);
    }

    function updateItemPrice(uint256 id, uint256 price)
        external
        ItemAccess(id)
        whenNotPaused
    {
        require(price <= MAX_PRICE, "Price is very high");
        uint256 _index = indexOfItem(id);
        items[_index].price = price;
        emit ItemUpdated(_index, items[_index]);
    }

    function getAvailableItems(address _account)
        public
        view
        returns (
            uint256[] memory ids,
            uint256[] memory prices,
            CarProps[] memory props
        )
    {
        uint256[] memory _ids = new uint256[](items.length);
        uint256[] memory _prices = new uint256[](items.length);
        CarProps[] memory _props = new CarProps[](items.length);
        address _addrZero = address(0);
        uint64 counter = 0;
        for (uint64 i = 0; i < items.length; i++) {
            Item memory _item = items[i];
            if (
                _item.available &&
                (_account == _addrZero || _account == _item.owner)
            ) {
                _ids[counter] = _item.id;
                _prices[counter] = _item.price;
                _props[counter] = nftContract.props(_item.id);
                counter++;
            }
        }

        ids = new uint256[](counter);
        prices = new uint256[](counter);
        props = new CarProps[](counter);
        for (uint64 i = 0; i < counter; i++) {
            ids[i] = _ids[i];
            prices[i] = _prices[i];
            props[i] = _props[i];
        }
    }

    function buyItem(uint256 id, uint256 price) external whenNotPaused {
        uint256 itemIndex = indexOfItem(id);
        Item memory item = items[itemIndex];
        require(price == item.price, "Mismatch price");
        require(item.available, "Item is not available");
        items[itemIndex].available = false;
        address buyer = _msgSender();
        uint256 fee = item.price / 100; // 1%
        require(nativeToken.transferFrom(buyer, item.owner, item.price - fee));
        require(nativeToken.transferFrom(buyer, _benf, fee));
        nftContract.safeTransferFrom(address(this), buyer, item.id);
        emit ItemSold(itemIndex, item);
    }
}