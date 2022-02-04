//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.0;

interface IERC721 {
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );

    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );

    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    function balanceOf(address _owner) external view returns (uint256);

    function ownerOf(uint256 _tokenId) external view returns (address);

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata data
    ) external payable;

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable;

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata tokenIds
    ) external;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata tokenIds,
        bytes calldata data
    ) external;

    function batchTransferFrom(
        address from,
        address to,
        uint256[] calldata tokenIds
    ) external;

    function approve(address _approved, uint256 _tokenId) external payable;

    function setApprovalForAll(address _operator, bool _approved) external;

    function getApproved(uint256 _tokenId) external view returns (address);

    function isApprovedForAll(address _owner, address _operator)
        external
        view
        returns (bool);
}

interface IAgoraAsset is IERC721 {
    function mint(
        address to_,
        uint256 id_,
        uint256 tax_
    ) external;

    function getTaxAndOriginal(uint256 id_)
        external
        view
        returns (uint256, address);

    function getMnftAddressFromId(uint256 id_) external view returns (address);
}

contract Context {
    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Manager is Ownable {
    /// Oracle=>"Oracle"

    mapping(string => address) public members;

    mapping(address => mapping(string => bool)) public permits; //地址是否有某个权限

    function setMember(string memory name, address member) external onlyOwner {
        members[name] = member;
    }

    function getUserPermit(address user, string memory permit)
        public
        view
        returns (bool)
    {
        return permits[user][permit];
    }

    function setUserPermit(
        address user,
        string calldata permit,
        bool enable
    ) external onlyOwner {
        permits[user][permit] = enable;
    }

    function getTimestamp() external view returns (uint256) {
        return block.timestamp;
    }
}

abstract contract Member is Ownable {
    //检查权限
    modifier CheckPermit(string memory permit) {
        require(manager.getUserPermit(msg.sender, permit), "no permit");
        _;
    }

    Manager public manager;

    function getMember(string memory _name) public view returns (address) {
        return manager.members(_name);
    }

    function setManager(address addr) external onlyOwner {
        manager = Manager(addr);
    }
}

abstract contract IERC165 {
    function supportsInterface(bytes4 interfaceID)
        external
        view
        virtual
        returns (bool);
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);
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

library Roles {
    struct Role {
        mapping(address => bool) bearer;
    }

    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles:account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account)
        internal
        view
        returns (bool)
    {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

contract OperatorRole is Context {
    using Roles for Roles.Role;

    event OperatorAdded(address indexed account);
    event OperatorRemoved(address indexed account);

    Roles.Role private _operators;

    modifier onlyOperator() {
        require(
            isOperator(_msgSender()),
            "OperatorRole: caller does not have the operator role"
        );
        _;
    }

    function isOperator(address account) public view returns (bool) {
        return _operators.has(account);
    }

    function _addOperator(address account) internal {
        _operators.add(account);
        emit OperatorAdded(account);
    }

    function _removeOperator(address account) internal {
        _operators.remove(account);
        emit OperatorRemoved(account);
    }
}

contract OwnableOperatorRole is Ownable, OperatorRole {
    function addOperator(address account) public onlyOwner {
        _addOperator(account);
    }

    function removeOperator(address account) public onlyOwner {
        _removeOperator(account);
    }
}

contract Trade is OwnableOperatorRole, Member {
    using SafeMath for uint256;

    address public communityAddress;
    address public roylitiesAddress;

    event Putaway(
        address owner,
        address nftAdress,
        address erc20Address,
        uint256 nftId,
        uint256 startPrice,
        uint256 maxPrice,
        uint256 startTime,
        uint256 endTime,
        bytes32 key
    );
    event Cancel(
        address owner,
        address cancelBidder,
        uint256 cancelBidPrice,
        bytes32 key
    );
    event BuyNowPrice(
        address seller,
        address buyer,
        address nftAddress,
        address erc20Address,
        uint256 nftId,
        uint256 price,
        address cancelBidder,
        uint256 cancelBidPrice,
        bytes32 key
    );

    event RecieveFromBid(
        address seller,
        address buyer,
        address nftAddress,
        address erc20Address,
        uint256 nftId,
        uint256 price,
        bytes32 key
    );

    event RecieveWhenAbortive(
        address seller,
        address nftAddress,
        uint256 nftId,
        bytes32 key
    );

    event NewBid(address bidder, uint256 bidPrice, bytes32 key);

    constructor(address communityAddress_, address roylitiesAddress_) {
        communityAddress = communityAddress_;
        roylitiesAddress = roylitiesAddress_;
    }

    enum OrderState {
        Inexistence,
        Open,
        Begin,
        Finish,
        Abortive,
        Close,
        Cancel
    }

    struct Order {
        OrderState state;
        uint256 nftId;
        uint256 startPrice;
        uint256 maxPrice;
        address nftAddress;
        address erc20Address;
        address ownerAddress;
        uint256 startTime;
        uint256 endTime;
        uint256 bidPrice;
        address bidder;
    }

    mapping(bytes32 => Order) public orderStore;

    function changeCommunityAddress(address communityAddress_)
        public
        CheckPermit("Config")
    {
        communityAddress = communityAddress_;
    }

    function changeRoylitiesAddress(address roylitiesAddress_)
        public
        CheckPermit("Config")
    {
        roylitiesAddress = roylitiesAddress_;
    }

    function stateOfOrder(bytes32 key) public view returns (OrderState) {
        Order memory order = orderStore[key];

        if (
            order.state == OrderState.Open && (order.endTime < block.timestamp)
        ) {
            if (order.bidder == address(0)) {
                return OrderState.Abortive;
            }
            return OrderState.Finish;
        }

        if (
            order.state == OrderState.Open &&
            order.startTime < block.timestamp &&
            order.endTime > block.timestamp
        ) {
            return OrderState.Begin;
        }

        return order.state;
    }

    function _addOrder(
        uint256 nftId,
        uint256 startPrice,
        uint256 maxPrice,
        uint256 startTime,
        uint256 endTime,
        address nftAddress,
        address ownerAddress,
        address erc20Address,
        bytes32 key
    ) internal {
        require(maxPrice == 0 || maxPrice > startPrice, "wrong max price");
        require(nftAddress != address(0), "wrong nft address");

        Order memory order = Order(
            OrderState.Open,
            nftId,
            startPrice,
            maxPrice,
            nftAddress,
            erc20Address,
            ownerAddress,
            startTime,
            endTime,
            0,
            address(0)
        );
        orderStore[key] = order;
    }

    function prepareKey(
        uint256 nftId,
        uint256 startPrice,
        uint256 maxPrice,
        uint256 startTime,
        uint256 endTime,
        address _nftAddress,
        address _erc20Address,
        address ownerAddress
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    nftId,
                    startPrice,
                    maxPrice,
                    startTime,
                    endTime,
                    _nftAddress,
                    _erc20Address,
                    ownerAddress
                )
            );
    }

    //##################################################################################
    // transfer相关方法
    //##################################################################################

    function erc20safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        if (from == address(this)) {
            require(token.transfer(to, value), "failure while transferring");
        } else {
            require(
                token.transferFrom(from, to, value),
                "failure while transferring"
            );
        }
    }

    function nftSafeTransferFrom(
        address token,
        address from,
        address to,
        uint256 tokenId
    ) internal {
        IAgoraAsset(token).safeTransferFrom(from, to, tokenId);
    }

    function putaway(
        uint256 nftId,
        uint256 startPrice,
        uint256 maxPrice,
        uint256 startTime,
        uint256 endTime,
        address nftAddress,
        address erc20Address
    ) public returns (bytes32) {
        bytes32 key = prepareKey(
            nftId,
            startPrice,
            maxPrice,
            startTime,
            endTime,
            nftAddress,
            erc20Address,
            msg.sender
        );

        _addOrder(
            nftId,
            startPrice,
            maxPrice,
            startTime,
            endTime,
            nftAddress,
            msg.sender,
            erc20Address,
            key
        );

        nftSafeTransferFrom(nftAddress, msg.sender, address(this), nftId);

        emit Putaway(
            msg.sender,
            nftAddress,
            erc20Address,
            nftId,
            startPrice,
            maxPrice,
            startTime,
            endTime,
            key
        );

        return key;
    }

    function recieveAssetWhenClose(bytes32 key) public {
        Order storage order = orderStore[key];
        require(
            order.ownerAddress == msg.sender,
            "Trade:sender not the order owner"
        );
        require(
            stateOfOrder(key) == OrderState.Abortive,
            "order must be abortive"
        );
        order.state = OrderState.Close;

        nftSafeTransferFrom(
            order.nftAddress,
            address(this),
            order.ownerAddress,
            order.nftId
        );

        emit RecieveWhenAbortive(
            order.ownerAddress,
            order.nftAddress,
            order.nftId,
            key
        );
    }

    function cancel(bytes32 key) public {
        Order storage order = orderStore[key];

        require(
            order.ownerAddress == msg.sender,
            "Trade:sender not the order owner"
        );

        require(
            stateOfOrder(key) == OrderState.Open ||
                stateOfOrder(key) == OrderState.Begin,
            "order can not begin"
        );

        if (order.bidder != address(0)) {
            erc20safeTransferFrom(
                IERC20(order.erc20Address),
                address(this),
                order.bidder,
                order.bidPrice
            );
        }

        // change state
        order.state = OrderState.Cancel;

        emit Cancel(order.ownerAddress, order.bidder, order.bidPrice, key);
    }

    function transferTokenWhenRecieve(bytes32 key, uint256 amount) internal {
        Order storage order = orderStore[key];

        // 转移资产
        // 销毁 2%
        uint256 remainAmount = amount;
        uint256 burnAmount = (remainAmount * 200) / 10000;
        // 社区 2%
        uint256 communityAmount = (remainAmount * 200) / 10000;
        // master 1%
        uint256 MnftAmount = remainAmount / 100;
        // 平台 9.5%
        uint256 roylitiesAmount = (remainAmount * 950) / 10000;

        IAgoraAsset asset = IAgoraAsset(order.nftAddress);
        (uint256 tax, address taxReceiver) = asset.getTaxAndOriginal(
            order.nftId
        );
        address mnftAddress = asset.getMnftAddressFromId(order.nftId);

        uint256 taxAmount = (remainAmount * tax) / 10000;

        remainAmount =
            remainAmount -
            burnAmount -
            communityAmount -
            MnftAmount -
            roylitiesAmount -
            taxAmount;

        erc20safeTransferFrom(
            IERC20(order.erc20Address),
            address(this),
            address(0x01),
            burnAmount
        );
        erc20safeTransferFrom(
            IERC20(order.erc20Address),
            address(this),
            communityAddress,
            communityAmount
        );
        erc20safeTransferFrom(
            IERC20(order.erc20Address),
            address(this),
            mnftAddress,
            MnftAmount
        );

        erc20safeTransferFrom(
            IERC20(order.erc20Address),
            address(this),
            roylitiesAddress,
            roylitiesAmount
        );
        erc20safeTransferFrom(
            IERC20(order.erc20Address),
            address(this),
            taxReceiver,
            taxAmount
        );

        erc20safeTransferFrom(
            IERC20(order.erc20Address),
            address(this),
            order.ownerAddress,
            remainAmount
        );
    }

    function recieve(bytes32 key) public {
        Order storage order = orderStore[key];
        require(stateOfOrder(key) == OrderState.Finish, "order state is wrong");
        require(msg.sender == order.bidder, "you have not qualification");

        order.state = OrderState.Close;
        transferTokenWhenRecieve(key, order.bidPrice);
        nftSafeTransferFrom(
            order.nftAddress,
            address(this),
            order.bidder,
            order.nftId
        );

        emit RecieveFromBid(
            order.ownerAddress,
            order.bidder,
            order.nftAddress,
            order.erc20Address,
            order.nftId,
            order.bidPrice,
            key
        );
    }

    function takeBid(bytes32 key, uint256 bidPrice) public {
        Order storage order = orderStore[key];

        require(stateOfOrder(key) == OrderState.Begin, "Auction not begin");
        require(bidPrice > order.bidPrice, "new bid have ot higher");

        if (order.bidder != address(0)) {
            erc20safeTransferFrom(
                IERC20(order.erc20Address),
                address(this),
                order.bidder,
                order.bidPrice
            );
        }

        erc20safeTransferFrom(
            IERC20(order.erc20Address),
            msg.sender,
            address(this),
            bidPrice
        );

        order.bidder = msg.sender;
        order.bidPrice = bidPrice;

        emit NewBid(order.bidder, order.bidPrice, key);
    }

    // 一口价购买
    function buyNowPrice(bytes32 key) public {
        Order storage order = orderStore[key];

        // 必须设置一口价
        IERC20 token = IERC20(order.erc20Address);
        require(
            token.allowance(msg.sender, address(this)) >= order.maxPrice,
            "token approve not enough"
        );
        require(order.maxPrice != 0, "not set buy now price");

        require(stateOfOrder(key) == OrderState.Begin, "wrong time");

        // 退还bidder金额
        if (order.bidder != address(0)) {
            erc20safeTransferFrom(
                IERC20(order.erc20Address),
                address(this),
                order.bidder,
                order.bidPrice
            );
        }

        erc20safeTransferFrom(
            IERC20(order.erc20Address),
            msg.sender,
            address(this),
            order.maxPrice
        );

        transferTokenWhenRecieve(key, order.maxPrice);

        nftSafeTransferFrom(
            order.nftAddress,
            address(this),
            msg.sender,
            order.nftId
        );

        order.state = OrderState.Close;

        emit BuyNowPrice(
            order.ownerAddress,
            msg.sender,
            order.nftAddress,
            order.erc20Address,
            order.nftId,
            order.maxPrice,
            order.bidder,
            order.bidPrice,
            key
        );
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) external virtual returns (bytes4) {
        return 0x150b7a02;
    }

    // bytes4(keccak256("onERC721ExReceived(address,address,uint256[],bytes)")) = 0x0f7b88e3
    function onERC721ExReceived(
        address,
        address,
        uint256[] memory,
        bytes memory
    ) external virtual returns (bytes4) {
        return 0x0f7b88e3;
    }
}