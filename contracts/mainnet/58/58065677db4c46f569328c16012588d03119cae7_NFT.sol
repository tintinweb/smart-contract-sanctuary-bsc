// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721Enumerable.sol";
import "./Ownable.sol";
import "./Ownable2.sol";
import "./Counters.sol";


interface IStakePool {
    function userValid(address _addr) external view returns (bool);

    function getTeamLength(address _addr) external view returns (uint256);
}


/**
 * @title ERC721Mock
 * This mock just provides a public safeMint, mint, and burn functions for testing purposes
 */
contract NFT is ERC721Enumerable, Ownable, Adminable {
    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }
    using Counters for Counters.Counter;
    string private _baseTokenURI;
    uint256 constant oneToken = 1e18;
    //
    uint8[] typeArr = [1, 2, 3, 4];
    uint8 typeMin = 1;
    uint8 typeMax = 4;

    uint256[] typeCountArr = [1200, 2800, 3800, 5000];
    uint256[] typePriceArr = [2 * oneToken, 2 * oneToken, 1 * oneToken, 1 * oneToken];
    uint256 totalLimit = typeCountArr[0] + typeCountArr[1] + typeCountArr[2] + typeCountArr[3];
    uint256 public startTime;
    uint256 public addressLimit = 5;
    mapping(uint8=>uint256) public addressTypeLimit;
    uint256 onceMax = 5;
    Counters.Counter public idCounter;
    address tokenAddress;
    address recipientAddress;
    //
    mapping(uint8 => uint256) mintedCounts;
    mapping(uint256 => uint8) tokenTypeMap;
    mapping(address => uint256) public addressLimitMap;
    mapping(address => mapping(uint256 => uint256)) public addressTypeLimitMap;//user=>type=>num
    //
    uint256 whiteMax = 100;
    uint256 whiteMinted;
    mapping(address => bool)public whiteList;

    //Rush SALE
    uint256 rushSaleFlag;
    uint256 rushSaleStartTime;
    uint256 rushSaleEndTime;
    IStakePool poolContract;

    event Mint(address indexed account, uint8 indexed tp, uint256 num);
    event UpdateStartTime(uint256 oldTime, uint256 newTime);
    event UpdateWhiteList(address indexed account, bool enable);
    event WhiteUsed(address indexed account);
    event UpdateSaleFlag(uint256 oldFlag, uint256 flag);
    event UpdateSaleTime(uint256 startTime, uint256 endTime);
    event UpdateWhiteMax(uint256 oldNum, uint256 newNum);
    constructor(string memory name, string memory symbol, address _token, address _rec, address _poolContract) ERC721(name, symbol) {
        tokenAddress = _token;
        recipientAddress = _rec;

        startTime = block.timestamp;
        idCounter.reset(10001);
        poolContract = IStakePool(_poolContract);
        //first
    }

    modifier onlyMaster() {
        require(adminaaa() == _msgSender() || owner() == _msgSender(), "Ownable: caller is not the owner");
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
        if (rushSaleFlag == 1) {
            //check sale time
            require(block.timestamp >= rushSaleStartTime && block.timestamp <= rushSaleEndTime, "saleTime:not start");
            //check pool condition
            require(poolContract.userValid(msg.sender) && poolContract.getTeamLength(msg.sender) >= 5, "Insufficient pool conditions");
        } else {
            require(block.timestamp >= startTime, "time:not start");
        }
        _;
    }
    modifier checkType(uint8 _type) {
        require(_type >= 1 && _type <= 4, "invalid type");
        _;
    }

    function getIndex(uint8 _type) internal pure returns (uint256){
        return uint(_type) - 1;
    }
    //owner
    function setTypeCount(uint8 _type, uint256 _max) external onlyMaster checkType(_type) {
        typeCountArr[getIndex(_type)] = _max;
        totalLimit = typeCountArr[0] + typeCountArr[1] + typeCountArr[2] + typeCountArr[3];
    }

    function setAddressLimit(uint _addressMax) external onlyMaster {
        addressLimit = _addressMax;
    }
    function setAddressTypeLimit(uint8 _type, uint _addressMax) external onlyMaster checkType(_type) {
        addressTypeLimit[_type] = _addressMax;
    }

    function setOnceMax(uint _onceMax) external onlyMaster {
        require(_onceMax > 0, "min1");
        onceMax = _onceMax;
    }

    function setStartTime(uint _start) external onlyMaster {
        emit UpdateStartTime(startTime, _start);
        startTime = _start;
    }

    function setWhiteMax(uint256 _max) external onlyMaster {
        emit UpdateWhiteMax(whiteMax, _max);
        whiteMax = _max;
    }

    function setWhiteList(address[]memory addressList) external onlyMaster {
        for (uint i = 0; i < addressList.length; i++) {
            whiteList[addressList[i]] = true;
            emit UpdateWhiteList(addressList[i], true);
        }
    }

    function cancelWhiteList(address[]memory addressList) external onlyMaster {
        for (uint i = 0; i < addressList.length; i++) {
            whiteList[addressList[i]] = false;
            emit UpdateWhiteList(addressList[i], false);
        }
    }

    //
    function setRushSaleFlag(uint256 _flag) external onlyMaster {
        emit UpdateSaleFlag(rushSaleFlag, _flag);
        rushSaleFlag = _flag;

    }

    function updateRushSaleTime(uint256 _start, uint _end) external onlyMaster {
        rushSaleStartTime = _start;
        rushSaleEndTime = _end;
        emit UpdateSaleTime(_start, _end);
    }

    function setRecipientAddress(address _addr) external onlyMaster {
        recipientAddress = _addr;
    }


    function mint(uint8 _type, uint256 num) external checkTime checkType(_type) {
        require(num <= onceMax, "onceMax");
        uint index = getIndex(_type);
        require(mintedCounts[_type] + num <= typeCountArr[index], "typeMax");
        require(addressLimitMap[msg.sender] + num <= addressLimit, "addressLimit");
        require(addressTypeLimitMap[msg.sender][_type] + num <= addressTypeLimit[_type], "addressTypeLimit");
        //        unchecked {
        mintedCounts[_type] += num;
        addressLimitMap[msg.sender] += num;
        addressTypeLimitMap[msg.sender][_type] += num;
        //        }
        uint amount = typePriceArr[index] * num;
        safeTransferFrom(tokenAddress, msg.sender, recipientAddress, amount);
        //
        for (uint i = 0; i < num; i++) {
            uint tokenId = idCounter.current();
            idCounter.increment();
            tokenTypeMap[tokenId] = _type;
            _mint(msg.sender, tokenId);
        }
        emit Mint(msg.sender, _type, num);
    }

    function mintWhite() external {
        require(whiteList[msg.sender], "whitelist");
        require(whiteMinted < whiteMax, "max");
        whiteList[msg.sender] = false;
        whiteMinted += 1;
        uint8 _type = 1;
        uint256 num = 1;
        uint index = getIndex(_type);
        uint amount = typePriceArr[index] * num;
        safeTransferFrom(tokenAddress, msg.sender, recipientAddress, amount);

        //
        for (uint i = 0; i < num; i++) {
            uint tokenId = idCounter.current();
            idCounter.increment();
            tokenTypeMap[tokenId] = _type;
            _mint(msg.sender, tokenId);
        }
        emit Mint(msg.sender, _type, num);
        emit WhiteUsed(msg.sender);
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
        for (uint i = 0; i < froms.length; i++) {
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
        for (uint i = 0; i < froms.length; i++) {
            safeTransferFrom(froms[i], tos[i], ids[i]);
        }
    }

    function getTokenAmount(uint8 _type, uint num) public view returns (uint256){
        return typePriceArr[getIndex(_type)] * num;
    }

    function getMintStatus() external view returns (uint256, uint256, uint256, uint256){
        return (mintedCounts[typeArr[0]], mintedCounts[typeArr[1]], mintedCounts[typeArr[2]], mintedCounts[typeArr[3]]);
    }

    function getConfig() external view returns (uint256, uint256, uint256, uint256){
        return (startTime, totalLimit, addressLimit, onceMax);
    }

    function getTokenType(uint256 tokenId) public view returns (uint8){
        return tokenTypeMap[tokenId];
    }

    function getMintTotalConfig() external view returns (uint256[] memory){
        return typeCountArr;
    }

    function getWhiteConfig() external view returns (uint256, uint256){
        return (whiteMax, whiteMinted);
    }

    function getRushSaleTime() external view returns (uint256, uint256){
        return (rushSaleStartTime, rushSaleEndTime);
    }

    function getRushSaleFlag() external view returns (uint256){
        return rushSaleFlag;
    }


    function getList(address _addr, uint256 pageNo, uint256 pageSize) external view returns (uint256[]memory ids, uint8[]memory types){
        uint256 nftBalance = balanceOf(_addr);
        if (nftBalance == 0 || pageSize == 0) {
            return (new uint256[](0), new uint8[](0));
        }
        uint start = 0;
        uint end = 0;
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
        types = new uint8[](end - start);
        uint index;
        for (; start < end; start++) {
            ids[index] = tokenOfOwnerByIndex(_addr, start);
            types[index] = getTokenType(ids[index]);
            index++;
        }

    }
}