/**
 *Submitted for verification at BscScan.com on 2022-09-18
*/

//SPDX-License-Identifier: Unlicensed
pragma solidity >=0.6.8;
pragma experimental ABIEncoderV2;

interface IBEP20 {
    
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}

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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol

pragma solidity >=0.6.2 <0.8.0;

interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}

pragma solidity >=0.6.2 <0.8.0;

interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);

}

pragma solidity >=0.6.2 <0.8.0;

interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);

}

pragma solidity >=0.6.0 <0.8.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}

interface NOriginNFT {

    function NIds(uint256 _tokenId) external view returns (uint256);

    function mint(address _to, uint256 _NId) external returns (uint256);

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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                // solhint-disable-next-line no-inline-assembly
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = now + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(now > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

contract CommonFunc is Ownable {

    address public tokenHoldNeedAddr;
 
    address public baseAccount;

    uint256 public tokenHoldNeed;

    uint256 public accountSum;

    bool public isOpen;

    mapping(address => bool) public approveToken;

    mapping(address => uint256) public blackList;

    function setIsOpen(bool open)
        external
    {
        require(msg.sender == owner());
        isOpen = open;
    }

    function setBlackList(address account, uint256 NId)
        external
    {
        require(msg.sender == owner());
        blackList[account] = NId;
    }

    function setBaseAccount(address account)
        external
    {
        require(msg.sender == owner());
        baseAccount = account;
    }

    function setTokenHoldInfo(address tokenAddr, uint256 amount)
        external
    {
        require(msg.sender == owner());
        tokenHoldNeedAddr = tokenAddr;
        tokenHoldNeed = amount;
    }

    function setApproveToken(address tokenAddr, bool approve)
        external
    {
        require(msg.sender == owner());
        approveToken[tokenAddr] = approve;
    }

    function getTokenBack(address tokenAddr)
        external
    {
        require(msg.sender == owner());

        if(tokenAddr == address(0)) {
            (bool sent,) = msg.sender.call{value : address(this).balance}("");
            require(sent);
        }else {
            IBEP20(tokenAddr).transfer(baseAccount, IBEP20(tokenAddr).balanceOf(address(this)));  
        }
    }

    function getTokenHoldInfo()
        external
        view
        returns (address, uint256)
    {
        return (tokenHoldNeedAddr, tokenHoldNeed);
    }

}

library NCommon {
    using SafeMath for uint256;

    function random(uint256 from, uint256 to, uint256 salty) internal view returns (uint256) {
        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp + block.difficulty +
                    ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
                    block.gaslimit +
                    ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
                    block.number +
                    salty
                )
            )
        );
        return seed.mod(to - from) + from;
    }
}

contract NoboNFTMarket is CommonFunc {
    using SafeMath for uint256;
    using Address for address;
    
    struct TradeEntity {
        address seller;
        address buyer;
        address tokenAddr;
        address nftAddr;
        uint256 NId;
        uint256 tokenId;
        uint256 tokenAmount;
        bool tradeIsClosed;
    }

    uint256[] public contractAddrArray;

    uint256[] public contractAddrHistoryArray;

    mapping(uint256 => uint256) public activeContractEnumList;

    mapping(address => uint256[]) public userActiveContractsList;

    mapping(address => mapping(uint256 => uint256)) public userActiveContractEnumList;

    mapping(address => uint256[]) public userCanceledContractsList;

    mapping(address => uint256[]) public userHistoryContractsList;

    mapping(uint256 => TradeEntity) private tradeList;

    //mapping(address => uint256) public accountSetDayState;

    //mapping(address => uint256) public accountSetNumState;

    //uint256 public setLimitPerDay;

    uint256 public serviceFee;

    uint256 public serviceRatio;

    uint256 public tradeCodeCounter;

    TradeEntity private instance;

    event NTradeBegin(uint256 indexed tradeCode, address indexed from);

    event NTradeEnd(uint256 indexed tradeCode, address indexed from, address indexed to);

    function setServiceFee(uint256 value)
        public
    {
        require(msg.sender == owner());

        serviceFee = value;
    }

    function setServiceRatio(uint256 value)
        public
    {
        require(msg.sender == owner());

        serviceRatio = value;
    }

    function createTradeList
    (
        address _seller,
        address _nftAddr,
        uint256 _tokenId,
        address _tokenAddr,
        uint256 _tokenAmount
    )
        public
        payable
    {
        require(isOpen);
        require(approveToken[_tokenAddr]);
        require(blackList[msg.sender] != NOriginNFT(_nftAddr).NIds(_tokenId));

        tradeList[tradeCodeCounter].seller = _seller;
        tradeList[tradeCodeCounter].nftAddr = _nftAddr;
        tradeList[tradeCodeCounter].tokenId = _tokenId;
        tradeList[tradeCodeCounter].tokenAddr = _tokenAddr;
        tradeList[tradeCodeCounter].tokenAmount = _tokenAmount;
        tradeList[tradeCodeCounter].NId = NOriginNFT(_nftAddr).NIds(_tokenId);

        IERC721(_nftAddr).transferFrom(msg.sender, address(this), _tokenId);

        addressArrayPush(tradeCodeCounter);
        addressUserArrayPush(msg.sender, tradeCodeCounter);

        (bool sent,) = baseAccount.call{value : serviceFee}("");
        require(sent);

        emit NTradeBegin(tradeCodeCounter, msg.sender);

        tradeCodeCounter += 1;
    }

    function transferAsset(uint256 _tradeCode, address _buyer)
        internal
    {
        require(!tradeList[_tradeCode].tradeIsClosed);

        tradeList[_tradeCode].buyer = _buyer;
        tradeList[_tradeCode].tradeIsClosed = true;
        IERC721(tradeList[_tradeCode].nftAddr).transferFrom(address(this), _buyer, tradeList[_tradeCode].tokenId);
    }

    function tradeCancel(uint256 _tradeCode)
        internal
    {
        require(!tradeList[_tradeCode].tradeIsClosed);

        tradeList[_tradeCode].tradeIsClosed = true;
        IERC721(tradeList[_tradeCode].nftAddr).transferFrom(address(this), 
        tradeList[_tradeCode].seller, tradeList[_tradeCode].tokenId);
    }

    function getTradeListInfo(uint256 _tradeCode)
        public
        view
        returns (
            address seller,
            address buyer,
            uint256 NId,
            uint256 tokenId,
            uint256 tokenAmount,
            bool tradeIsClosed
        )
    {
        seller = tradeList[_tradeCode].seller;
        buyer = tradeList[_tradeCode].buyer;
        NId = tradeList[_tradeCode].NId;
        tokenId = tradeList[_tradeCode].tokenId;
        tokenAmount = tradeList[_tradeCode].tokenAmount;
        tradeIsClosed = tradeList[_tradeCode].tradeIsClosed;
    }

    function buytTradeList(uint256 _tradeCode)
        public
    {
        require(isOpen);
        require(!tradeList[_tradeCode].tradeIsClosed);

        uint256 realPrice = tradeList[_tradeCode].tokenAmount.sub(
            tradeList[_tradeCode].tokenAmount.mul(serviceRatio)/100);

        IBEP20(tradeList[_tradeCode].tokenAddr).transferFrom(
            msg.sender,
            baseAccount,
            tradeList[_tradeCode].tokenAmount.mul(serviceRatio)/100);

        IBEP20(tradeList[_tradeCode].tokenAddr).transferFrom(
            msg.sender,
            tradeList[_tradeCode].seller,
            realPrice);
        
        transferAsset(_tradeCode, msg.sender);

        addressArrayPop(_tradeCode);
        addressUserArrayPop(tradeList[_tradeCode].seller, _tradeCode, true);

        emit NTradeEnd(_tradeCode, tradeList[_tradeCode].seller, msg.sender);
    }

    function cancelTradeList(uint256 _tradeCode)
        public
    {
        require(isOpen);
        require(!tradeList[_tradeCode].tradeIsClosed);
        require(msg.sender == tradeList[_tradeCode].seller);

        tradeCancel(_tradeCode);

        addressArrayPop(_tradeCode);
        addressUserArrayPop(tradeList[_tradeCode].seller, _tradeCode, false);

        emit NTradeEnd(_tradeCode, tradeList[_tradeCode].seller, msg.sender);
    }

    function addressArrayPush(uint256 _tradeCode)
        internal
    {
        require(activeContractEnumList[_tradeCode] == 0);
        contractAddrArray.push(_tradeCode);
        activeContractEnumList[_tradeCode] = contractAddrArray.length;
    }

    function addressUserArrayPush(address user, uint256 _tradeCode)
        internal
    {
        require(userActiveContractEnumList[user][_tradeCode] == 0);
        userActiveContractsList[user].push(_tradeCode);
        userActiveContractEnumList[user][_tradeCode] = userActiveContractsList[user].length;
    }

    function addressArrayPop(uint256 _tradeCode)
        internal
    {
        require(activeContractEnumList[_tradeCode] != 0);
        uint256 lastAddr = contractAddrArray[contractAddrArray.length-1];
        uint256 popAddrIndex = activeContractEnumList[_tradeCode];
        contractAddrArray[popAddrIndex-1] = lastAddr;
        activeContractEnumList[lastAddr] = popAddrIndex;
        contractAddrArray.pop();
        activeContractEnumList[_tradeCode] = 0;
        contractAddrHistoryArray.push(_tradeCode);
    }

    function addressUserArrayPop(address user, uint256 _tradeCode, bool isSold)
        internal
    {
        require(userActiveContractEnumList[user][_tradeCode] != 0);
        uint256 lastAddr = userActiveContractsList[user][userActiveContractsList[user].length-1];
        uint256 popAddrIndex = userActiveContractEnumList[user][_tradeCode];
        userActiveContractsList[user][popAddrIndex-1] = lastAddr;
        userActiveContractEnumList[user][lastAddr] = popAddrIndex;
        userActiveContractsList[user].pop();
        userActiveContractEnumList[user][_tradeCode] = 0;
        if(isSold) {
            userHistoryContractsList[user].push(_tradeCode);
        }else {
            userCanceledContractsList[user].push(_tradeCode);
        }
    }

    function getContractAddrArray()
        external
        view
        returns (uint256[] memory)
    {
        return contractAddrArray;
    }

    function getContractHistoryAddrArray()
        external
        view
        returns (uint256[] memory)
    {
        return contractAddrHistoryArray;
    }

    function getUserContractAddrArray(address user)
        external
        view
        returns (uint256[] memory)
    {
        return userActiveContractsList[user];
    }

    function getUserContractHistoryAddrArray(address user)
        external
        view
        returns (uint256[] memory)
    {
        return userHistoryContractsList[user];
    }

    function getUserContractCanceledAddrArray(address user)
        external
        view
        returns (uint256[] memory)
    {
        return userCanceledContractsList[user];
    }
}