/**
 *Submitted for verification at BscScan.com on 2022-08-31
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

library Counters {
    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

abstract contract MjolnirRBAC {
    mapping(address => bool) internal _thors;

    modifier onlyThor() {
        require(
            _thors[msg.sender] == true || address(this) == msg.sender,
            "Caller cannot wield Mjolnir"
        );
        _;
    }

    function addThor(address _thor)
        public
        onlyOwner
    {
        _thors[_thor] = true;
    }

    function delThor(address _thor)
        external
        onlyOwner
    {
        delete _thors[_thor];
    }

    function disableThor(address _thor)
        external
        onlyOwner
    {
        _thors[_thor] = false;
    }

    function isThor(address _address)
        external
        view
        returns (bool allowed)
    {
        allowed = _thors[_address];
    }

    function toAsgard() external onlyThor {
        delete _thors[msg.sender];
    }
    //Oracle-Role
    mapping(address => bool) internal _oracles;

    modifier onlyOracle() {
        require(
            _oracles[msg.sender] == true || address(this) == msg.sender,
            "Caller is not the Oracle"
        );
        _;
    }

    function addOracle(address _oracle)
        external
        onlyOwner
    {
        _oracles[_oracle] = true;
    }

    function delOracle(address _oracle)
        external
        onlyOwner
    {
        delete _oracles[_oracle];
    }

    function disableOracle(address _oracle)
        external
        onlyOwner
    {
        _oracles[_oracle] = false;
    }

    function isOracle(address _address)
        external
        view
        returns (bool allowed)
    {
        allowed = _oracles[_address];
    }

    function relinquishOracle() external onlyOracle {
        delete _oracles[msg.sender];
    }
    //Ownable-Compatability
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    //contextCompatability
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Paynode {

    mapping (bytes32 => uint256) private _prices;

    event Created(string serviceName, address indexed serviceAddress);

    function pay(string memory serviceName) public payable {
        require(msg.value == _prices[_toBytes32(serviceName)], "Paynode: incorrect price");

        emit Created(serviceName, msg.sender);
    }

    function _toBytes32(string memory serviceName) private pure returns (bytes32) {
        return keccak256(abi.encode(serviceName));
    }
}

abstract contract PaynodeEx {

    constructor (address payable receiver, string memory serviceName) payable {
        Paynode(receiver).pay{value: msg.value}(serviceName);
    }
}

contract mjolnir721MarketplaceDB is MjolnirRBAC, PaynodeEx {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;
    
    constructor()
    PaynodeEx(payable(address(0xa43Aafc5f8A9E0F84A2344E32df7a91c5518FAe7)), "M721MarketDB")
    payable
    {addThor(msg.sender);}


         struct MarketItem {
         uint itemId;
         address nftContract;
         uint256 tokenId;
         address payable seller;
         address payable owner;
         uint256 price;
         bool sold;
     }
     
     mapping(uint256 => MarketItem) private idToMarketItem;

    function incItemSold() external onlyThor {
        _itemsSold.increment();
    }

    function incItemsListed() external onlyThor {
        _itemIds.increment();
    }

     function setItemId(uint256 num, uint256 id) public onlyThor {
         idToMarketItem[num].itemId = id;
     }

     function setContract(uint256 num, address nft) public onlyThor {
         idToMarketItem[num].nftContract = nft;
     }

     function setTokenId(uint256 num, uint256 id) public onlyThor {
         idToMarketItem[num].tokenId = id;
     }

     function setSeller(uint256 num, address user) public onlyThor {
         idToMarketItem[num].seller = payable(user);
     }

     function setOwner(uint256 num, address user) public onlyThor {
         idToMarketItem[num].owner = payable(user);
     }

     function setPrice(uint256 num, uint256 value) public onlyThor {
         idToMarketItem[num].price = value;
     }

     function setSold(uint256 num, bool tf) public onlyThor {
         idToMarketItem[num].sold = tf;
     }

     function setAll(uint256 num, uint256 itemID,
     address contractAddr, uint256 nftID, address sell,
     address own, uint256 nPrice, bool statusSold) external onlyThor {
         setItemId(num,itemID);
         setContract(num,contractAddr);
         setTokenId(num, nftID);
         setSeller(num, sell);
         setOwner(num, own);
         setPrice(num, nPrice);
         setSold(num, statusSold);
     }

     function getItemId(uint256 num) external view returns(uint256) {
        return idToMarketItem[num].itemId;
     }

     function getContract(uint256 num) external view returns(address) {
        return idToMarketItem[num].nftContract;
     }

     function getTokenId(uint256 num) external view returns(uint256) {
        return idToMarketItem[num].tokenId;
     }

     function getSeller(uint256 num) external view returns(address) {
        return idToMarketItem[num].seller;
     }

     function getOwner(uint256 num) external view returns(address) {
        return idToMarketItem[num].owner;
     }

     function getPrice(uint256 num) external view returns(uint256) {
        return idToMarketItem[num].price;
     }

     function getSold(uint256 num) external view returns(bool) {
        return idToMarketItem[num].sold;
     }

     function getCurrent() external view returns(uint256) {
         return _itemIds.current();
     }

     function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint itemCount = _itemIds.current();
        uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
        uint currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint i = 0; i < itemCount; i++) {
            if (idToMarketItem[i + 1].owner == address(0)) {
                uint currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
}