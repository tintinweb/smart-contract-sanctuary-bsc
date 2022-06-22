// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721Enumerable.sol";
import "./Ownable.sol";
import "./Ownable2.sol";
import "./Counters.sol";

interface IMintNFT {
    function ownerOf(uint256 tokenId) external view returns (address);

    function getTokenType(uint256 tokenId) external view returns (uint8);
}

/**
 * @title ERC721Mock
 * This mock just provides a public safeMint, mint, and burn functions for testing purposes
 */
contract NFT421 is ERC721Enumerable, Ownable, Adminable {
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
    address public tokenAddress;
    IMintNFT public nftContract;
    mapping(uint256 => bool) tokenUsed;

    event Mint(
        address indexed account,
        uint256 indexed newId,
        uint256 indexed amount,
        uint256 id1,
        uint256 id2,
        uint256 id3,
        uint256 id4
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
        tokenAddress = _token;
        recipientAddress = _rec;
        nftContract = IMintNFT(_nftContract);
        tokenAmount = _amount;
        startTime = _start;
        endTime = _end;
    }

    //todo test
    function setConfigs(address _nft, address _token) external {
        tokenAddress = _token;
        nftContract = IMintNFT(_nft);
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

    function checkNft(
        address _addr,
        uint256 _id1,
        uint256 _id2,
        uint256 _id3,
        uint256 _id4
    ) internal view returns (bool) {
        address o1 = nftContract.ownerOf(_id1);
        uint8 t1 = nftContract.getTokenType(_id1);

        address o2 = nftContract.ownerOf(_id2);
        uint8 t2 = nftContract.getTokenType(_id2);

        if (_addr != o1 || o1 != o2 || t1 != t2) {
            return false;
        }
        o2 = nftContract.ownerOf(_id3);
        t2 = nftContract.getTokenType(_id3);
        if (_addr != o2 || t1 != t2) {
            return false;
        }
        o2 = nftContract.ownerOf(_id4);
        t2 = nftContract.getTokenType(_id4);
        if (_addr != o2 || t1 != t2) {
            return false;
        }

        return true;
    }

    function _checkValid(
        uint256 _id1,
        uint256 _id2,
        uint256 _id3,
        uint256 _id4
    ) internal view returns (bool) {
        bool usd = tokenUsed[_id1] ||
            tokenUsed[_id2] ||
            tokenUsed[_id3] ||
            tokenUsed[_id4];
        return !usd;
    }

    function mint(
        uint256 _id1,
        uint256 _id2,
        uint256 _id3,
        uint256 _id4
    ) external checkTime {
        require(totalSupply() < mintMax, "mint max");
        require(_checkValid(_id1, _id2, _id3, _id4), "used");
        require(
            checkNft(msg.sender, _id1, _id2, _id3, _id4),
            "not owner,or same type"
        );
        tokenUsed[_id1] = true;
        tokenUsed[_id2] = true;
        tokenUsed[_id3] = true;
        tokenUsed[_id4] = true;
        safeTransferFrom(
            tokenAddress,
            msg.sender,
            recipientAddress,
            tokenAmount
        );
        uint256 tokenId = idCounter.current();
        idCounter.increment();
        //
        _mint(msg.sender, tokenId);
        emit Mint(msg.sender, tokenId, tokenAmount, _id1, _id2, _id3, _id4);
    }

    function checkNFTValid(
        address _addr,
        uint256 _id1,
        uint256 _id2,
        uint256 _id3,
        uint256 _id4
    ) external view returns (bool) {
        return
            checkNft(_addr, _id1, _id2, _id3, _id4) &&
            _checkValid(_id1, _id2, _id3, _id4);
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