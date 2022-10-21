// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.6.0;

import "./BaseLib.sol";
import "./VRFConsumerBase.sol";

interface IToken {
    function transfer(address _to, uint256 _value) external;
    function transferFrom(address sender, address recipient, uint256 amount) external;
}

contract RandomDistribution is Ownable, VRFConsumerBase {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;


    bytes32 internal keyHash;
    uint256 internal fee;

    IToken public ticket721;
    uint256 public randomResult;
    event InitRandom(uint256 indexed startId, uint256 indexed endId, bytes32 requestId,uint256 randomV);
    mapping(address => bool) public minters;

    struct HolderStruct {
        uint256 startId;
        uint256 endId;
        bytes32 requestId;
        uint256 randomV;
    }
    mapping(bytes32 => HolderStruct) public requestIds;

    constructor(address _ticketToken,address _vrfCoordinator, address _link,bytes32 _keyHash, uint256 _fee) VRFConsumerBase(
        _vrfCoordinator, // VRF Coordinator
        _link  // LINK Token
    ) public {
        require(_ticketToken != address(0), "The token's address cannot be 0");
        ticket721 = IToken(_ticketToken);

        keyHash = _keyHash;
        fee = _fee * 10 ** 16; // 0.1 LINK (Varies by network)
    }

    modifier onlyMint() {
        require(_msgSender() == owner() || minters[msg.sender], "nft: not minter");
        _;
    }

    function setChainLinkHash(bytes32 _keyHash, uint256 _fee) public onlyOwner {
        keyHash = _keyHash;
        fee = _fee * 10 ** 16; // 0.2 LINK (Varies by network)
    }

    function setMinters(address _address, bool _allow) public onlyOwner {
        require(_address != address(0), "nft: zero_address");
        require(minters[_address] != _allow, "nft: no edit");
        minters[_address] = _allow;
    }

    function setTicket(address _ticketToken) external onlyOwner() {
        require(_ticketToken != address(0), "The token's address cannot be 0");
        ticket721 = IToken(_ticketToken);
    }

    /**
     * Requests randomness
     */
    function getRandomNumber() internal returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }

    function initRandom(uint256 start,uint256 end) public onlyMint() returns (bytes32) {
        bytes32 requestId = getRandomNumber();
        requestIds[requestId] = HolderStruct(start,end,requestId,0) ;
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        requestIds[requestId].randomV = randomness ;
        emit InitRandom(requestIds[requestId].startId,requestIds[requestId].endId,requestId,randomness);

    }

    // withdraw token for rollback
    function withdrawToken(address token, address payable dest, uint amount) public onlyOwner{
        if (token == address(0x0))
            dest.transfer(amount);
        else
            IToken(token).transfer(dest, amount);
    }

    function withdrawTokenFrom(address token, address payable dest, uint amount) public onlyOwner{
        require(dest != address(0), "ERC721: can not for the zero address");
        if (token == address(0x0))
            dest.transfer(amount);
        else
            IToken(token).transferFrom(address(this),dest, amount);
    }

receive() external payable {}/* can accept ether */
}