/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8;
pragma experimental ABIEncoderV2;

// File: @openzeppelin/contracts/utils/Context.sol

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
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol

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
    constructor ()  {
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

contract ShowNFT is Ownable {
    mapping(string=>uint) public vals;
    mapping(string=>address) public adds;

    struct Item {
        uint256 price;
        uint    startTime;
        uint    endTime;
        address buyer;
    }
    mapping(address => mapping(uint => mapping(address => Item))) public itemMap;
    event CraeateItem(address indexed seller_, uint tokenId_, uint price_, uint strTime,uint endTime);
    event BuyItem(address indexed buyer_, uint indexed tokenId_, uint price_);
   

    constructor()  {
        vals["switch"]  = 1;
        vals["minPrice"]  =  1e16;
        vals["maxPrice"]  =  10000 * 1e18;
        vals["baseTimePeriod"]  = 86400;
        vals["basePirice"]  = 1e16;
        adds["platAddress"]  = 0x010b653E70b98142CEBD31Db6d4704E87fb8c9D1; //平台地址
    }


    function editItem(address token_,uint tokenId_, address add_,uint256 price_,uint startTime_,uint endTime_,address buyer_) external onlyOwner {
        price_ = price_== 0 ? price_ : 0;
        startTime_ = startTime_== 0 ? startTime_ : 0;
        endTime_ = endTime_== 0 ? endTime_ : 0;
        buyer_  = buyer_ == address(0) ? buyer_ : address(0);
        itemMap[token_][tokenId_][add_]= Item({
            price: price_,
            startTime:startTime_,
            endTime: endTime_,
            buyer:buyer_
        });
    }


    //创建拍卖
    function createItem(address token_,uint tokenId_, uint256 price_,uint startTime_,uint endTime_) external {
        require(vals["switch"] == 1, "not allowed");
        require(price_ >= vals["minPrice"] && price_ <= vals["maxPrice"], "Price fail!");
        require(endTime_  > startTime_ + vals["baseTimePeriod"],"Auction range error!");
        require(block.timestamp >= startTime_,"Bidding is over!");
        if(itemMap[token_][tokenId_][_msgSender()].endTime > 0){
            require(block.timestamp > itemMap[token_][tokenId_][_msgSender()].endTime,"Don't repeat the auction!");
        }
        itemMap[token_][tokenId_][_msgSender()]= Item({
            price: price_,
            startTime:startTime_,
            endTime: endTime_,
            buyer:address(0)
        });
        emit CraeateItem(_msgSender(), tokenId_, price_,startTime_,endTime_);
    }


    //竞拍
    function buyItem(address token_,address add_,uint256 tokenId_,uint _price) external payable {
        require(_msgSender() != add_,"Can't self!");
        require(block.timestamp <= itemMap[token_][tokenId_][add_].endTime ,"Bidding is over!");
        require(_price >= (itemMap[token_][tokenId_][add_].price + vals["basePirice"]),"Bidding price is too low!");
        payable(adds["platAddress"]).transfer(_price);
        itemMap[token_][tokenId_][add_].buyer = _msgSender();
        emit BuyItem(_msgSender(), tokenId_, _price);
    }


}