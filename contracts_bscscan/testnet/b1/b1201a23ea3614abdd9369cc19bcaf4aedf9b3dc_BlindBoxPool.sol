// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.6.0;

import "./BlindBoxPoolBase.sol";
import "./VRFConsumerBase.sol";

interface IBBT721 is IERC721 {
    function getCategory(uint256 tokenId) external view returns (uint8);
}

contract BlindBoxPool is Ownable, VRFConsumerBase {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;

    IBBT721 public ticket721;
    IBBT721 public blindBox;

    bytes32 internal keyHash;
    uint256 internal fee;

    uint256 public randomResult;

    mapping(uint8 => EnumerableSet.UintSet) private boxes;
    //    uint256[] private boxes;
    //    uint256[] private legendaries;
    //    uint256[] private mystices;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4){
        if(_msgSender() == address(blindBox)){
            uint8 category = blindBox.getCategory(tokenId);
            boxes[category].add(tokenId);
        }
        return _ERC721_RECEIVED;
    }

    mapping(address => bool) public minters;

    constructor(address _ticketToken, address _boxToken) VRFConsumerBase(
        0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9, // VRF Coordinator
        0xa36085F69e2889c224210F603D836748e7dC0088  // LINK Token
    ) public {
        require(_ticketToken != address(0), "The token's address cannot be 0");
        require(_boxToken != address(0), "The token's address cannot be 0");
        ticket721 = IBBT721(_ticketToken);
        blindBox = IBBT721(_boxToken);

        keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
        fee = 0.1 * 10 ** 18; // 0.1 LINK (Varies by network)
    }

    modifier onlyMint() {
        require(_msgSender() == owner() || minters[msg.sender], "nft: not minter");
        _;
    }

    function setMinters(address _address, bool _allow) public onlyOwner {
        require(_address != address(0), "nft: zero_address");
        require(minters[_address] != _allow, "nft: no edit");
        minters[_address] = _allow;
    }

    function setBlindBox721(address _boxToken) external onlyOwner() {
        require(_boxToken != address(0), "The token's address cannot be 0");
        blindBox = IBBT721(_boxToken);
    }

    function setBlindBoxTicket721(address _ticketToken) external onlyOwner() {
        require(_ticketToken != address(0), "The token's address cannot be 0");
        ticket721 = IBBT721(_ticketToken);
    }

    function isContainsIn(uint8 category, uint256 tokenId) public view returns (bool) {
        return boxes[category].contains(tokenId);
    }

    function getCategoryLength(uint8 category) public view returns (uint256) {
        return boxes[category].length();
    }

    function getTokenIdByIndex(uint8 category, uint256 index) public view returns (uint256) {
        return boxes[category].at(index);
    }

    function addBoxToken(uint8 category, uint256[] calldata tokenIds) public onlyMint() {
        for (uint256 index = 0; index < tokenIds.length; index++) {
            boxes[category].add(tokenIds[index]);
        }
    }

    function removeBoxToken(uint8 category, uint256 tokenId) public onlyMint() {
        boxes[category].remove(tokenId);
    }

    /**
     * Requests randomness
     */
    function getRandomNumber() public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness;
    }

    function exchangeBlindBox(uint256 tokenId) public returns (uint256) {
        uint8 category = ticket721.getCategory(tokenId);
        require(boxes[category].length() > 0, "blind boxes is not enough");
        ticket721.safeTransferFrom(_msgSender(),address(this),tokenId);
        //get random
        getRandomNumber();
        uint256 randomIndex = randomResult % boxes[category].length();
        uint256 boxId = boxes[category].at(randomIndex);
        boxes[category].remove(boxId);
        blindBox.safeTransferFrom(address(this),_msgSender(),boxId);
        return boxId;
    }
}