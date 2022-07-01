// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721Enumerable.sol";
import "./Ownable.sol";
import "./Ownable2.sol";
import "./Counters.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// import "hardhat/console.sol";
interface IMintNFT {
    function ownerOf(uint256 tokenId) external view returns (address);

    function getTokenType(uint256 tokenId) external view returns (uint8);
}

/**
 * @title ERC721Mock
 * This mock just provides a public safeMint, mint, and burn functions for testing purposes
 */
contract NFT421Multi is ERC721Enumerable, Ownable, Adminable, ReentrancyGuard {
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }

    using Counters for Counters.Counter;

    Counters.Counter public idCounter;
    string private _baseTokenURI;
    uint256 constant oneToken = 1e18;
    uint256 public mintMax = 10000;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public tokenAmount;
    address public recipientAddress;
    address public recipientAddressB;
    address public tokenAddress;
    IMintNFT public nftContract;
    mapping(uint256 => bool) public tokenUsed;
    //s
    uint256 public amountA;
    address public tokenB;
    uint256 public amountB;
    bool public type2flag = true;

    event Mint(
        address indexed account,
        uint256 indexed newId,
        uint256 indexed amount,
        uint256 id1,
        uint256 id2,
        uint256 id3,
        uint256 id4
    );

    event Mint2(
        address indexed account,
        uint256 indexed newId,
        uint256 indexed amount,
        uint256 id1,
        uint256 id2,
        uint256 id3,
        uint256 id4,
        uint256 amountB
    );
    event UpdateTime(uint256 indexed startTime, uint256 indexed endTime);

    constructor(
        string memory name,
        string memory symbol,
        address _token,
        address _rec,
        address _nftContract,
        uint256 _amount,
        uint256 _start,
        uint256 _end
    ) ERC721(name, symbol) {
        idCounter.reset(10001);
        tokenAddress = _token;
        recipientAddress = _rec;
        nftContract = IMintNFT(_nftContract);
        tokenAmount = _amount;
        startTime = _start;
        endTime = _end;
    }

    modifier onlyMaster() {
        require(
            adminaaa() == _msgSender() || owner() == _msgSender(),
            "Ownable: caller is not the owner"
        );
        _;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string calldata newBaseTokenURI) external onlyMaster {
        _baseTokenURI = newBaseTokenURI;
    }

    function baseURI() public view returns (string memory) {
        return _baseURI();
    }

    function exists(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }

    //
    modifier checkTime() {
        //
        require(
            block.timestamp >= startTime && block.timestamp <= endTime,
            "time:not start or already end"
        );
        _;
    }
    modifier checkType(uint8 _type) {
        require(_type >= 1 && _type <= 4, "invalid type");
        _;
    }

    function setStartTime(uint256 _start, uint256 _end) external onlyMaster {
        emit UpdateTime(_start, _end);
        startTime = _start;
        endTime = _end;
    }

    function setRecipientAddress(address _addr) external onlyMaster {
        recipientAddress = _addr;
    }


    function setTokenAmount(uint256 _amount) external onlyMaster {
        tokenAmount = _amount;
    }

    function setMintMax(uint256 _mintMax) external onlyMaster {
        mintMax = _mintMax;
    }

    function setType2status(bool _isOpen) external onlyMaster {
        type2flag = _isOpen;
    }

    function setType2Info(address _recAddr,address _tokenB,uint256 _amountA, uint256 _amountB)
        external
        onlyMaster
    {
        recipientAddressB = _recAddr;
        tokenB = _tokenB;
        amountA = _amountA;
        amountB = _amountB;
    }

    function checkNftTypeOwner(
        address _addr,
        uint256 _id1,
        uint256 _id2,
        uint256 _id3,
        uint256 _id4
    ) internal view returns (uint8) {
        address o1 = nftContract.ownerOf(_id1);
        address o2 = nftContract.ownerOf(_id2);
        address o3 = nftContract.ownerOf(_id3);
        address o4 = nftContract.ownerOf(_id4);
        if (_addr != o1 || _addr != o2 || _addr != o3 || _addr != o4) {
            return 0;
        }

        uint8 t1 = nftContract.getTokenType(_id1);
        uint8 t2 = nftContract.getTokenType(_id2);
        uint8 t3 = nftContract.getTokenType(_id3);
        uint8 t4 = nftContract.getTokenType(_id4);

        if (
           _checkIdDiff(t1,t2,t3,t4)
        ) {
            return 1;
        }

        if (!type2flag) {
            return 0;
        }
        return _checkType2(t1, t2, t3, t4);
    }

    function _checkIdDiff(
        uint8 t1,
        uint8 t2,
        uint8 t3,
        uint8 t4
    ) internal pure returns (bool) {
        if (
            t1 != t2 && t1 != t3 && t1 != t4 && t2 != t3 && t2 != t4 && t3 != t4
        ) {
            return true;
        }
        return false;
    }

    function _checkType2(
        uint8 t1,
        uint8 t2,
        uint8 t3,
        uint8 t4
    ) internal pure returns (uint8) {
        if (t1 % 2 != 0 || t2 % 2 != 0 || t3 % 2 != 0 || t4 % 2 != 0) {
            return 0;
        }
        //
        if (t1 == t2 && t3 == t4) {
            return 2;
        } else if (t1 == t3 && t2 == t4) {
            return 2;
        } else if (t1 == t4 && t2 == t3) {
            return 2;
        }
        return 0;
    }

    function _checkUsed(
        uint256 _id1,
        uint256 _id2,
        uint256 _id3,
        uint256 _id4
    ) internal view returns (bool) {
        bool usd = tokenUsed[_id1] ||
            tokenUsed[_id2] ||
            tokenUsed[_id3] ||
            tokenUsed[_id4];
        return usd;
    }

    function mint(
        uint256 _id1,
        uint256 _id2,
        uint256 _id3,
        uint256 _id4
    ) external checkTime nonReentrant {
        require(totalSupply() < mintMax, "mint max");
        require(!_checkUsed(_id1, _id2, _id3, _id4), "used");

        uint8 mintType = checkNftTypeOwner(msg.sender, _id1, _id2, _id3, _id4);
        require(mintType > 0, "not owner,or invalid types");
        tokenUsed[_id1] = true;
        tokenUsed[_id2] = true;
        tokenUsed[_id3] = true;
        tokenUsed[_id4] = true;

        uint256 tokenId = idCounter.current();
        idCounter.increment();
        //
        _mint(msg.sender, tokenId);
        if (mintType == 1) {
            safeTransferFrom(
                tokenAddress,
                msg.sender,
                recipientAddress,
                tokenAmount
            );
            emit Mint(msg.sender, tokenId, tokenAmount, _id1, _id2, _id3, _id4);
        } else {
            safeTransferFrom(
                tokenAddress,
                msg.sender,
                recipientAddress,
                amountA
            );
            safeTransferFrom(tokenB, msg.sender, recipientAddressB, amountB);
            emit Mint2(
                msg.sender,
                tokenId,
                amountA,
                _id1,
                _id2,
                _id3,
                _id4,
                amountB
            );
        }
    }

    function checkNFTValid(
        address _addr,
        uint256 _id1,
        uint256 _id2,
        uint256 _id3,
        uint256 _id4
    ) external view returns (bool) {
        return
            checkNftTypeOwner(_addr, _id1, _id2, _id3, _id4) > 0 &&
            !_checkUsed(_id1, _id2, _id3, _id4);
    }

    function safeBatchTransferFrom(
        address[] memory froms,
        address[] memory tos,
        uint256[] memory ids,
        bytes[] memory datas
    ) external {
        require(froms.length == tos.length, "s1");
        require(froms.length == ids.length, "s2");
        require(froms.length == datas.length, "s3");
        for (uint256 i = 0; i < froms.length; i++) {
            safeTransferFrom(froms[i], tos[i], ids[i], datas[i]);
        }
    }

    function safeBatchTransferFrom(
        address[] memory froms,
        address[] memory tos,
        uint256[] memory ids
    ) external {
        require(froms.length == tos.length, "s1");
        require(froms.length == ids.length, "s2");
        for (uint256 i = 0; i < froms.length; i++) {
            safeTransferFrom(froms[i], tos[i], ids[i]);
        }
    }

    function getList(
        address _addr,
        uint256 pageNo,
        uint256 pageSize
    ) external view returns (uint256[] memory ids) {
        uint256 nftBalance = balanceOf(_addr);
        if (nftBalance == 0 || pageSize == 0) {
            return new uint256[](0);
        }
        uint256 start = 0;
        uint256 end = 0;
        if (nftBalance <= pageSize) {
            end = nftBalance;
        } else {
            start = pageNo * pageSize;
            end = start + pageSize;
            if (end >= nftBalance) {
                end = nftBalance;
            }
        }
        ids = new uint256[](end - start);
        uint256 index;
        for (; start < end; start++) {
            ids[index] = tokenOfOwnerByIndex(_addr, start);
            index++;
        }
    }
}