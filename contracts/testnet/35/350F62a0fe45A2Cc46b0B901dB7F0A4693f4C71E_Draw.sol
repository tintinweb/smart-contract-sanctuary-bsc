/**
 *Submitted for verification at BscScan.com on 2022-05-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract Ownable {
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    address private _owner;

    constructor() {
        _transferOwnership(msg.sender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: newOwner is zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract BusinessRole is Ownable {
    address[] private _businesses;

    modifier onlyManager() {
        require(
            isOwner() || isBusiness(),
            "BusinessRole: caller is not business"
        );
        _;
    }

    function isBusiness() public view returns (bool) {
        for (uint256 i = 0; i < _businesses.length; i++) {
            if (_businesses[i] == msg.sender) {
                return true;
            }
        }
        return false;
    }

    function getBusinessAddresses() public view returns (address[] memory) {
        return _businesses;
    }

    function setBusinessAddress(address[] memory businessAddresses)
        public
        onlyOwner
    {
        _businesses = businessAddresses;
    }
}

interface IERC721 {
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

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    function approvedFor(uint256 _tokenId) external view returns (address);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    function transfer(address to, uint256 tokenId) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) external;

    function safeMint(address user) external;

    function create(address to) external returns (uint256);

    function burn(uint256 tokenId) external;

    function _burnItem(address owner, uint256 tokenId) external;
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);
}

contract Signer {
    address public signer;
    mapping(address => uint256) public currentSignedTime;

    modifier onlySigner() {
        require(signer == msg.sender, "Signer: caller is not the signer");
        _;
    }

    function _setSigner(address _signer) internal {
        signer = _signer;
    }

    function setSigner(address _signer) public onlySigner {
        _setSigner(_signer);
    }

    function getSignedMessageHash(bytes32 messageHash)
        pure
        internal
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    messageHash
                )
            );
    }

    function permit(
        bytes32 messageHash,
        uint256 timestamp,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public view returns (bool) {
        require(
            currentSignedTime[msg.sender] < timestamp,
            "Signer: Invalid timestamp"
        );
        return ecrecover(getSignedMessageHash(messageHash), v, r, s) == signer;
    }

    function setCurrentSignedTime (uint256 timestamp) internal {
        currentSignedTime[msg.sender] = timestamp;
    }
}

contract Draw is Signer, BusinessRole {
    event _getTicket(address _from, uint256 ticket, uint256 tiketPrice);
    event _setAwardMainCoin(address _to, uint256 amount);
    event _setAwardERC20(address _to, IERC20 erc20, uint256 amount);
    event _setAwardERC721(address _to, IERC721 _game, uint256 tokenId);
    event _getAwardERC721(
        address _from,
        IERC721 _game,
        uint256 tokenId,
        uint256 _type
    );
    struct item {
        uint256[] tokenIds;
    }
    struct items {
        mapping(address => item) items;
        uint8 totalItem;
    }
    struct ticket {
        address user;
        bool isUsed;
    }

    mapping(address => items) public awardDatas;
    mapping(uint256 => ticket) public tickets;
    IERC20 public OwaDrawErc20;
    IERC721 public OwaDrawErc721;
    uint256[] public ticketPrice;

    constructor() {
        OwaDrawErc20 = IERC20(0xc111cb11E22B622fb66083777A2BBf52665a611d);
        OwaDrawErc721 = IERC721(0x0d13c60d120d1F23517D244945e4a49468ca881c);
        ticketPrice = [1 ether];
        _setSigner(msg.sender);
    }

    function validTicket(uint256 _ticket) public view returns (bool) {
        return (tickets[_ticket].user != address(0) &&
            !tickets[_ticket].isUsed);
    }

    function getTicket(uint256 _ticket) public view returns (ticket memory) {
        return tickets[_ticket];
    }

    function isApprovedForAll(address _game, uint256 _tokenId)
        public
        view
        returns (bool)
    {
        IERC721 erc721 = IERC721(_game);

        return (erc721.getApproved(_tokenId) == address(this) ||
            erc721.isApprovedForAll(erc721.ownerOf(_tokenId), address(this)));
    }

    function getTokenIdByIndex(address _game, uint8 _index)
        public
        view
        returns (uint256)
    {
        return awardDatas[msg.sender].items[_game].tokenIds[_index];
    }

    function getGameBalance(address _game) public view returns (uint256) {
        return awardDatas[msg.sender].items[_game].tokenIds.length;
    }

    function setAwardPrice(IERC20 _erc20, uint256[] memory _ticketPrice)
        public
        onlyOwner
    {
        OwaDrawErc20 = _erc20;
        ticketPrice = _ticketPrice;
    }

    function setERC721(IERC721 _erc721) public onlyOwner {
        OwaDrawErc721 = _erc721;
    }

    function setERC20(IERC20 _erc20) public onlyOwner {
        OwaDrawErc20 = _erc20;
    }

    function getMessageHash(
        uint256 _ticket,
        uint256 typeticket,
        uint256 timestamp
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_ticket, typeticket, timestamp));
    }

    function buyTicket(
        uint256 _ticket,
        uint256 typeticket,
        uint256 timestamp,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(
            permit(
                getMessageHash(_ticket, typeticket, timestamp),
                timestamp,
                v,
                r,
                s
            ),
            "Draw: Invalid signal"
        );
        require(
            tickets[_ticket].user == address(0),
            "Draw: ticket has been purchased"
        );
        require(
            OwaDrawErc20.transferFrom(
                msg.sender,
                address(this),
                ticketPrice[typeticket]
            ),
            "Draw: transfer fail"
        );
        tickets[_ticket] = ticket(msg.sender, false);
        setCurrentSignedTime(timestamp);
        emit _getTicket(msg.sender, _ticket, ticketPrice[typeticket]);
    }

    function setAwardMainCoin(
        uint256 _ticket,
        address _user,
        uint256 _amount
    ) public payable onlyManager {
        require(validTicket(_ticket), "Draw: ticket is not valid");
        payable(_user).transfer(_amount);
        tickets[_ticket].isUsed = true;
        emit _setAwardMainCoin(_user, _amount);
    }

    function setAwardERC20(
        uint256 _ticket,
        address _user,
        IERC20 _erc20,
        uint256 _amount
    ) public onlyManager {
        require(validTicket(_ticket), "Draw: ticket is not valid");
        _erc20.transferFrom(msg.sender, _user, _amount);
        tickets[_ticket].isUsed = true;
        emit _setAwardERC20(_user, _erc20, _amount);
    }

    function setAwardERC721(uint256 _ticket, address _user) public onlyManager {
        require(validTicket(_ticket), "Draw: ticket is not valid");
        uint256 _tokenId = OwaDrawErc721.create(_user);
        awardDatas[_user].items[address(OwaDrawErc721)].tokenIds.push(_tokenId);
        awardDatas[_user].totalItem += 1;
        tickets[_ticket].isUsed = true;
        emit _setAwardERC721(_user, OwaDrawErc721, _tokenId);
    }

    function getAwardERC721(
        address _game,
        uint256 _tokenId,
        uint256 _type
    ) public {
        IERC721 erc721 = IERC721(_game);
        erc721.transferFrom(msg.sender, address(this), _tokenId);
        erc721._burnItem(address(this), _tokenId);
        // erc721.burn(_tokenId);
        emit _getAwardERC721(msg.sender, erc721, _tokenId, _type);
    }
}