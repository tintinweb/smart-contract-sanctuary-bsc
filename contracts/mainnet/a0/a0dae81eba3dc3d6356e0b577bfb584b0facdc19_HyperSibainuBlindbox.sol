/**
 *Submitted for verification at BscScan.com on 2022-05-03
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

    int256 constant private INT256_MIN = -2**255;

    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Multiplies two signed integers, reverts on overflow.
    */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == INT256_MIN)); // This is the only case of overflow not detected by the check below

        int256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Integer division of two signed integers truncating the quotient, reverts on division by zero.
    */
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0); // Solidity only automatically asserts when dividing by 0
        require(!(b == -1 && a == INT256_MIN)); // This is the only case of overflow

        int256 c = a / b;

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Subtracts two signed integers, reverts on overflow.
    */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Adds two signed integers, reverts on overflow.
    */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) external payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}
interface IERC721Metadata {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface IERC721Enumerable {
    function totalSupply() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function tokenByIndex(uint256 index) external view returns (uint256);
}

interface IERC721Receiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory _data) external returns(bytes4);
}

interface IERC721Mintable is IERC721, IERC721Enumerable, IERC721Metadata {
    function autoMint(string memory tokenURI, address to) external returns (uint256);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}

contract HyperSibainuBlindbox
{
    using SafeMath for uint256;

    address public owner;
    address public nftContractAddress;
    address payable public wallet;
    bool public enabled;

    IERC721Mintable private NFT_MINTABLE;

    uint256 public totalCreated;
    mapping(uint256 => uint256) private boxIndexes;
    mapping(address => uint256[]) private ownerBoxes;

    Tier[4] public tiers;
    Blindbox[] private soldBoxes;

    uint private nonce = 0;

    struct Tier {
        uint256 cost;
        uint256 total;
        uint256 remaining;
        mapping (uint256 => bool) issued;
    }

    struct TierStatus {
        uint256 cost;
        uint256 remaining;
    }

    struct PossibleNft {
        bool issued;
        string uri;
    }

    struct Blindbox {
        uint256 tier;
        uint256 id;
        address purchaser;
        uint256 tokenID;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "can only be called by the contract owner");
        _;
    }

    modifier isEnabled() {
        require(enabled, "Contract is currently disabled");
        _;
    }

    constructor() {
        owner = msg.sender;
        wallet = payable(0x24BEfE13C8A4CaB0F1Fe4Be51D9fF6dbF97aBF59);

        // Nft Contract
        nftContractAddress = 0xa850C097a855601dfe04331Ec83E3d828bb15995;
        NFT_MINTABLE = IERC721Mintable(nftContractAddress);

        // tiers
        tiers[0].cost = 25 * 10 ** 16;
        tiers[1].cost = 5 * 10 ** 17;
        tiers[2].cost = 1 * 10 ** 18;
        tiers[3].cost = 10 * 10 ** 18;

        tiers[0].total = 600;
        tiers[1].total = 300;
        tiers[2].total = 30;
        tiers[3].total = 3;

        tiers[0].remaining = 600;
        tiers[1].remaining = 300;
        tiers[2].remaining = 30;
        tiers[3].remaining = 3;
    }

    function status() public view returns (bool canPurchase, TierStatus[] memory availableTiers) {
        canPurchase = enabled;
        availableTiers = new TierStatus[](tiers.length);
        for (uint256 i = 0; i < tiers.length; i++) {
            availableTiers[i].cost = tiers[i].cost;
            availableTiers[i].remaining = tiers[i].remaining;
        }
    }

    function purchaseBlindbox(uint256 tier) public payable isEnabled {
        require (tiers[tier].remaining > 0, "No more blindboxes available");
        require (msg.value == tiers[tier].cost, "Incorrect BNB value.");
        wallet.transfer(tiers[tier].cost);

        uint256 request = requestRandomWords();
        soldBoxes.push(Blindbox(
            tier,
            request,
            msg.sender,
            0
        ));

        uint256 index = soldBoxes.length - 1;
        boxIndexes[request] = index;
        ownerBoxes[msg.sender].push(index);

        uint256 roll = soldBoxes[boxIndexes[index]].id.mod(tiers[tier].remaining).add(1);
        uint256 current;
        string memory uri;
        for (uint256 i = 1; i <= tiers[tier].total; i++) {
            if (tiers[tier].issued[i] == false) {
                current += 1;
            }
            if (roll <= current) {
                uri = string(abi.encodePacked("https://bafybeiex2h6cgkxuy5tmi5jo2z37ajjjhdw73wnmae3iumco4pemsgm5la.ipfs.nftstorage.link/", uint2str(tiers[tier].total), "/", uint2str(i), ".json"));
                tiers[tier].issued[i] = true;
                break;
            }
        }
        tiers[tier].remaining--;

        uint256 tokenID = NFT_MINTABLE.autoMint(uri, msg.sender);
        soldBoxes[boxIndexes[index]].tokenID = tokenID;
    }

    function balanceOf(address who) public view returns (Blindbox[] memory) {
        Blindbox[] memory boxes = new Blindbox[](ownerBoxes[who].length);

        for (uint256 i = 0; i < ownerBoxes[who].length; i++) {
            boxes[i] = soldBoxes[ownerBoxes[who][i]];
        }

        return boxes;
    }


    // Private methods

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }


    // Admin Only

    function setOwner(address who) external onlyOwner {
        require(who != address(0), "Cannot be zero address");
        owner = who;
    }

    function setWallet(address payable who) external onlyOwner {
        require(who != address(0), "Cannot be zero address");
        wallet = who;
    }

    function setPrice(uint256 tier, uint256 price) external onlyOwner {
        tiers[tier].cost = price;
    }

    function setEnabled(bool canPurchase) external onlyOwner {
        enabled = canPurchase;
    }

    function requestRandomWords() private returns (uint256) {
        nonce += 1;
        return uint(keccak256(abi.encodePacked(nonce, msg.sender, blockhash(block.number - 1))));
    }


}