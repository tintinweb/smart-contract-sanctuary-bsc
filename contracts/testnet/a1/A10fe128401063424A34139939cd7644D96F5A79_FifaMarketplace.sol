pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );
        (bool success,) = recipient.call{value : amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
    internal
    returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
        functionCallWithValue(
            target,
            data,
            value,
            "Address: low-level call with value failed"
        );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value : value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
    internal
    view
    returns (bytes memory)
    {
        return
        functionStaticCall(
            target,
            data,
            "Address: low-level static call failed"
        );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
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
}

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeBEP20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeBEP20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeBEP20: BEP20 operation did not succeed"
            );
        }
    }
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function initOwner() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function owner() external view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() external onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused, "paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() external onlyOwner whenNotPaused {
        paused = true;
        Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() external onlyOwner whenPaused {
        paused = false;
        Unpause();
    }
}

library EnumerableSet {
    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;

            set._indexes[lastvalue] = toDeleteIndex + 1;

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value)
    private
    view
    returns (bool)
    {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index)
    private
    view
    returns (bytes32)
    {
        require(
            set._values.length > index,
            "EnumerableSet: index out of bounds"
        );
        return set._values[index];
    }

    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value)
    internal
    returns (bool)
    {
        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value)
    internal
    returns (bool)
    {
        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value)
    internal
    view
    returns (bool)
    {
        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index)
    internal
    view
    returns (address)
    {
        return address(uint256(_at(set._inner, index)));
    }

    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value)
    internal
    returns (bool)
    {
        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value)
    internal
    view
    returns (bool)
    {
        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index)
    internal
    view
    returns (uint256)
    {
        return uint256(_at(set._inner, index));
    }
}

interface IERC721 {
    function invalidNFT(uint256 tokenId) external view returns (bool);

    function ownerOf(uint256 tokenId) external view returns (address owner);

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

    function balanceOf(address owner) external view returns (uint256 balance);
}

contract FifaMarketplace is Pausable {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    enum Status {
        AUCTION,
        CLOSE,
        CANCEL
    }

    struct Auction {
        address erc721;
        address seller;
        uint256[] erc721TokenIds;
        uint128 startingPrice;
        uint128 endingPrice;
        uint64 duration;
        uint64 startedAt;
        Status status;
    }

    struct AuctionCreate {
        address erc721;
        uint256[] _erc721TokenIds;
        uint256 _startingPrice;
        uint256 _endingPrice;
        uint256 _duration;
    }

    // Cut owner takes on each auction, measured in basis points (1/100 of a percent).
    // Values 0-10,000 map to 0%-100%
    uint256 public ownerCut;
    //auction id
    uint256 public auctionId;

    IBEP20 public bep20Token;
    bool public initialized;

    mapping(uint256 => Auction) public auctions;

    //How many auctionid created by 1 address
    mapping(address => EnumerableSet.UintSet) private _auctionIdWithAddress;

    event AuctionCreated(
        address indexed erc721,
        uint256[] _erc721TokenIds,
        uint256 indexed _auctionIndex,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller
    );
    event AuctionSuccessful(
        uint256 indexed _auctionId,
        uint256 _totalPrice,
        address _winner
    );
    event AuctionCancelled(uint256 indexed auctionId, address indexed seller);
    event ChangeOwnerCut(uint256 ownerCut);
    modifier canBeStoredWith64Bits(uint256 _value) {
        require(_value <= 18446744073709551615);
        _;
    }

    modifier canBeStoredWith128Bits(uint256 _value) {
        require(_value < 340282366920938463463374607431768211455);
        _;
    }


    function init(uint256 _ownerCut, IBEP20 _bep20Token) public {
        require(initialized == false);
        initOwner();
        require(_ownerCut <= 10000);
        ownerCut = _ownerCut;
        bep20Token = _bep20Token;
        initialized = true;
    }

    function changeOwnerCut(uint256 _ownerCut) external onlyOwner {
        ownerCut = _ownerCut;
        emit ChangeOwnerCut(_ownerCut);
    }

    function changeBEP20Token(IBEP20 _bep20Token) external onlyOwner {
        bep20Token = _bep20Token;
    }

    function getAuction(uint256 _auctionId)
    external
    view
    returns (
        address erc721,
        address seller,
        uint256[] memory erc721TokenIds,
        Status status,
        uint256 startingPrice,
        uint256 endingPrice,
        uint256 duration,
        uint256 startedAt
    )
    {
        Auction memory _auction = auctions[_auctionId];
        return (
        _auction.erc721,
        _auction.seller,
        _auction.erc721TokenIds,
        _auction.status,
        _auction.startingPrice,
        _auction.endingPrice,
        _auction.duration,
        _auction.startedAt
        );
    }

    function getAuctionByAddress(address seller)
    public
    view
    returns (Auction[] memory)
    {
        uint256 length = _auctionIdWithAddress[seller].length();
        Auction[] memory auctionsArr = new Auction[](length);
        for (uint256 i = 0; i < length; i++) {
            Auction memory auction = auctions[
            _auctionIdWithAddress[seller].at(i)
            ];
            auctionsArr[i] = auction;
        }
        return auctionsArr;
    }

    function getCurrentPrice(uint256 _auctionId)
    external
    view
    returns (uint256)
    {
        Auction memory _auction = auctions[_auctionId];
        require(_isOnAuction(_auction));
        return _getCurrentPrice(_auction);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        return
        bytes4(
            keccak256("onERC721Received(address,address,uint256,bytes)")
        );
    }

    function createAuction(AuctionCreate calldata auction)
    external
    whenNotPaused
    canBeStoredWith128Bits(auction._startingPrice)
    canBeStoredWith128Bits(auction._endingPrice)
    canBeStoredWith64Bits(auction._duration)
    {

        for (uint256 i = 0; i < auction._erc721TokenIds.length; i++) {
            require(IERC721(auction.erc721).isApprovedForAll(msg.sender, address(this)), "Account not approve this contract");
            require(IERC721(auction.erc721).ownerOf(auction._erc721TokenIds[i]) == msg.sender, "Must is owner");
        }

        Auction memory _auction = Auction(
            auction.erc721,
            msg.sender,
            auction._erc721TokenIds,
            uint128(auction._startingPrice),
            uint128(auction._endingPrice),
            uint64(auction._duration),
            uint64(now),
            Status.AUCTION
        );
        _addAuction(_auction, msg.sender);
    }

    function bid(
        uint256 _auctionId,
        uint256 _amount
    ) external whenNotPaused {
        _bid(_auctionId, _amount, msg.sender);
        _transfer(_auctionId, msg.sender);
    }

    function cancelAuction(
        uint256 _auctionId
    ) external {
        Auction memory _auction = auctions[_auctionId];
        require(_isOnAuction(_auction));
        require(msg.sender == _auction.seller);
        _cancelAuction(_auctionId, msg.sender);
    }

    function _isOnAuction(Auction memory _auction)
    internal
    pure
    returns (bool)
    {
        return (_auction.startedAt > 0 && _auction.status == Status.AUCTION);
    }

    function _getCurrentPrice(Auction memory _auction)
    internal
    view
    returns (uint256)
    {
        uint256 _secondsPassed = 0;
        if (now > _auction.startedAt) {
            _secondsPassed = now - _auction.startedAt;
        }

        if (_secondsPassed >= _auction.duration) {
            return _auction.endingPrice;
        } else {
            int256 _totalPriceChange = int256(_auction.endingPrice) -
            int256(_auction.startingPrice);
            int256 _currentPriceChange = (_totalPriceChange *
            int256(_secondsPassed)) / int256(_auction.duration);
            int256 _currentPrice = int256(_auction.startingPrice) +
            _currentPriceChange;
            return uint256(_currentPrice);
        }
    }

    function _addAuction(Auction memory _auction, address _seller) internal {
        require(_auction.duration >= 1 minutes, "must duration > 1 minutes");
        auctions[auctionId] = _auction;
        _auctionIdWithAddress[_seller].add(auctionId);

        AuctionCreated(
            _auction.erc721,
            _auction.erc721TokenIds,
            auctionId,
            uint256(_auction.startingPrice),
            uint256(_auction.endingPrice),
            uint256(_auction.duration),
            _seller
        );

        auctionId = auctionId.add(1);
    }

    function _cancelAuction(uint256 _auctionId, address sender) internal {
        auctions[_auctionId].status = Status.CANCEL;
        AuctionCancelled(_auctionId, sender);
    }

    function _transfer(uint256 _auctionId, address _receiver) internal {
        address erc721 = auctions[_auctionId].erc721;
        address seller = auctions[_auctionId].seller;
        uint256[] memory erc721TokenIds = auctions[_auctionId].erc721TokenIds;

        for (uint256 i = 0; i < erc721TokenIds.length; i++) {
            IERC721(erc721).safeTransferFrom(
                auctions[_auctionId].seller,
                _receiver,
                erc721TokenIds[i],
                ""
            );
        }
    }

    function _bid(
        uint256 _auctionId,
        uint256 _bidAmount,
        address sender
    ) internal returns (uint256) {
        Auction memory _auction = auctions[_auctionId];
        require(_isOnAuction(_auction), "Auction is closed");
        uint256 _price = _getCurrentPrice(_auction);
        require(_bidAmount >= _price, "Invalid price");
        address _seller = _auction.seller;
        auctions[_auctionId].status = Status.CLOSE;
        if (_price > 0) {
            uint256 _auctioneerCut = (_price * ownerCut) / 10000;
            uint256 _sellerProceeds = _price - _auctioneerCut;
            bep20Token.safeTransferFrom(sender, _seller, _sellerProceeds);
            bep20Token.safeTransferFrom(sender, address(this), _auctioneerCut);
        }
        AuctionSuccessful(_auctionId, _price, sender);
        return _price;
    }

    function _encodedData(uint256[] memory _array)
    internal
    pure
    returns (bytes32)
    {
        bytes memory encodeData;
        for (uint256 i = 0; i < _array.length; i++) {
            encodeData = abi.encodePacked(encodeData, _array[i]);
        }
        return keccak256(encodeData);
    }

    function claim(
        IBEP20 token,
        address to,
        uint256 amount
    ) external onlyOwner {
        token.safeTransfer(to, amount);
    }
}