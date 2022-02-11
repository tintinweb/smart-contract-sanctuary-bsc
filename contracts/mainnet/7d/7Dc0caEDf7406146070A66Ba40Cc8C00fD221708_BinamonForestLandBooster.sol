/**
 *Submitted for verification at BscScan.com on 2022-02-03
*/

pragma solidity >=0.7.0 <0.9.0;
pragma abicoder v2;

// SPDX-License-Identifier: MIT

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC721 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function totalSupply() external view returns (uint256);
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

interface BinamonCollectionV2 is IERC721 {
    function mint(uint256 type_, uint256[] memory values) external;
}

contract Trustable {
    address private _owner;
    mapping (address => bool) private _isTrusted;
    address[] private delegates;

    constructor () {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner {
        require(_owner == msg.sender, "Caller is not the owner");
        _;
    }

    modifier onlyTrusted {
        require(_isTrusted[msg.sender] == true || _owner == msg.sender, "Caller is not trusted");
        _;
    }
    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        _owner = newOwner;
    }
    
    function addTrusted(address user) public onlyOwner {
        _isTrusted[user] = true;
        delegates.push(user);
    }

    function removeTrusted(address user) public onlyOwner {
        _isTrusted[user] = false;
    }
    
    function isTrusted(address user) public view returns (bool) {
        return _isTrusted[user];
    }
    
    function getDelegates() public view returns (address[] memory) {
        return delegates;
    }
}

contract Pausable is Trustable {
    bool public paused = false;

    modifier whenNotPaused() {
        require(!paused || msg.sender == owner());
        _;
    }

    modifier whenPaused() {
        require(paused || msg.sender == owner());
        _;
    }

    function pause() onlyOwner whenNotPaused public {
        paused = true;
    }

    function unpause() onlyOwner whenPaused public {
        paused = false;
    }
}

contract BinamonForestLandBooster is Pausable {
    
    using SafeMath for uint256;
    
    address internal ticketCollection;
    address internal landCollection;
    mapping (uint256 => bool) internal usedIds;
    uint256[2][9] internal ranges;
    uint256 internal seed;
    uint256[5] internal levelFreqs;
    uint256[4] internal typeFreqs;
    uint256 internal cutoffTime;
    uint256 internal ticketsUsed;
      
    constructor(address ticketCollection_, address landCollection_) {
        ticketCollection = ticketCollection_;
        landCollection = landCollection_;

        ranges[0][0] = 100300355126;
        ranges[0][1] = 100300356125;
        ranges[1][0] = 100300356127;
        ranges[1][1] = 100300357126;
        ranges[2][0] = 100300357128;
        ranges[2][1] = 100300358127;
        ranges[3][0] = 100300358129;
        ranges[3][1] = 100300359128;
        ranges[4][0] = 100300359130;
        ranges[4][1] = 100300360129;
        ranges[5][0] = 100300360131;
        ranges[5][1] = 100300361130;
        ranges[6][0] = 100300361132;
        ranges[6][1] = 100300362131;
        ranges[7][0] = 100300362134;
        ranges[7][1] = 100300363133;
        ranges[8][0] = 100300363136;
        ranges[8][1] = 100300364135;

        levelFreqs = [uint(7813), uint(15625), uint(31250), uint(62500), uint(125000)];
        typeFreqs = [uint(50), uint(100), uint(100), uint(250)];
    }
    
    // These are emergency withdrawal methods, normally don't use
    function withdrawBnb(uint256 amount) external onlyOwner {
        payable(msg.sender).transfer(amount);
    }
    
    function withdrawBEP20(address bep20, uint256 amount) external onlyOwner {
        IERC20 token = IERC20(bep20);
        token.transfer(msg.sender, amount);
    }
    
    function withdrawBEP721(address bep721, uint256 tokenId) external onlyOwner {
        IERC721 nft = IERC721(bep721);
        nft.transferFrom(address(this), msg.sender, tokenId);
    }
    ///////

    
    // RNG, on-chain
    function random(uint256 modulo, uint256 salt) private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp, msg.sender, seed, salt))) % modulo;
    }
    
    function randomLevel() private view returns (uint256) {
        if (cutoffTime != 0 && block.timestamp > cutoffTime) return 1;

        uint256 number = random(1000000, 2);
        
        uint256 border = 0;
        for (uint256 i = 0; i < levelFreqs.length - 1; i++) {
            border += levelFreqs[i];
            if (number < border) return 6 - i;
        }
        
        return 1;
    }
    
    function randomType() private view returns (uint256) {
        uint256 number = random(1000, 3);
        
        uint256 border = 0;
        for (uint256 i = 0; i < typeFreqs.length - 1; i++) {
            border += typeFreqs[i];
            if (number < border) return 5 - i;
        }
        
        return 1;
    }

    function isTickedIdValid(uint256 landTicketId) public view returns (bool) {
        bool valid = false;
        for (uint256 i = 0; i < 9; i++) {
            if (ranges[i][0] <= landTicketId && ranges[i][1] >= landTicketId) valid = true;
        }
        return valid;
    }

    function setCutoffTime(uint256 time) public onlyTrusted whenNotPaused {
        cutoffTime = time;
    }

    function getCutoffTime() public view returns (uint256) {
        return cutoffTime;
    }

    function openBooster(uint256 landTicketId) public whenNotPaused {
        require(usedIds[landTicketId] == false, "Ticket already used");
        require(isTickedIdValid(landTicketId) == true, "Invalid ticket ID");
        require(ticketsUsed <= 2900, "Too many tickets");
        require(tx.origin == msg.sender); // Anti-bot

        usedIds[landTicketId] = true;
        ticketsUsed += 1;

        seed = random(ticketsUsed + 1000, 1);

        IERC721 ticket = IERC721(ticketCollection);
        ticket.transferFrom(msg.sender, address(this), landTicketId);

        uint256[] memory params = new uint[](9);
        params[0] = randomLevel(); // Level
        params[1] = 1; // Forest
        params[2] = 1000; // leave X undefined for now (not 0 because (0,0) are valid coordinates)
        params[3] = 1000; // leave Y undefined for now (not 0 because (0,0) are valid coordinates)
        params[4] = 0; // 5 perks
        params[5] = 0;
        params[6] = 0;
        params[7] = 0;
        params[8] = 0;

        BinamonCollectionV2 land = BinamonCollectionV2(landCollection);
        uint256 typeId = randomType();
        land.mint(typeId, params); // typeId can be 1...5
        land.transferFrom(address(this), msg.sender, land.totalSupply());
    }
}

library SafeMath { 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
}