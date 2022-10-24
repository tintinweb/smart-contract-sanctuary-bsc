// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

interface IERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface ERC721Metadata  {

    function name() external view returns (string memory _name);

    function symbol() external view returns (string memory _symbol);

    function tokenURI(uint256 _tokenId) external view returns (string memory);
}

interface IERC721 is IERC165 {
    function balanceOf(address owner) external view returns (uint balance);

    function ownerOf(uint tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint tokenId
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes calldata data
    ) external;

    function transferFrom(
        address from,
        address to,
        uint tokenId
    ) external;

    function approve(address to, uint tokenId) external;

    function getApproved(uint tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);
}


contract ERC721 is IERC721 {
    event Transfer(address indexed from, address indexed to, uint indexed id);
    event Approval(address indexed owner, address indexed spender, uint indexed id);
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    // Mapping from token ID to owner address
    mapping(uint => address) internal _ownerOf;

    // Mapping owner address to token count
    mapping(address => uint) internal _balanceOf;

    // Mapping from token ID to approved address
    mapping(uint => address) internal _approvals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    mapping (uint256 => string) internal tokenURIs;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    function ownerOf(uint id) external view returns (address owner) {
        owner = _ownerOf[id];
        require(owner != address(0), "token doesn't exist");
    }

    function balanceOf(address owner) external view returns (uint) {
        require(owner != address(0), "owner = zero address");
        return _balanceOf[owner];
    }

    function setApprovalForAll(address operator, bool approved) external {
        isApprovedForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function approve(address spender, uint id) external {
        address owner = _ownerOf[id];
        require(
            msg.sender == owner || isApprovedForAll[owner][msg.sender],
            "not authorized"
        );

        _approvals[id] = spender;

        emit Approval(owner, spender, id);
    }

    function getApproved(uint id) external view returns (address) {
        require(_ownerOf[id] != address(0), "token doesn't exist");
        return _approvals[id];
    }

    function _isApprovedOrOwner(
        address owner,
        address spender,
        uint id
    ) internal view returns (bool) {
        return (spender == owner ||
            isApprovedForAll[owner][spender] ||
            spender == _approvals[id]);
    }

    function transferFrom(
        address from,
        address to,
        uint id
    ) public {
        require(from == _ownerOf[id], "from != owner");
        require(to != address(0), "transfer to zero address");

        require(_isApprovedOrOwner(from, msg.sender, id), "not authorized");

        _balanceOf[from]--;
        _balanceOf[to]++;
        _ownerOf[id] = to;

        delete _approvals[id];

        emit Transfer(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint id
    ) external {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                IERC721Receiver(to).onERC721Received(msg.sender, from, id, "") ==
                IERC721Receiver.onERC721Received.selector,
            "unsafe recipient"
        );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint id,
        bytes calldata data
    ) external {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                IERC721Receiver(to).onERC721Received(msg.sender, from, id, data) ==
                IERC721Receiver.onERC721Received.selector,
            "unsafe recipient"
        );
    }

    function _mint(address to, uint id) internal {
        require(to != address(0), "mint to zero address");
        require(_ownerOf[id] == address(0), "already minted");

        _balanceOf[to]++;
        _ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }

    function _safeMint(address to, uint tokenId, string memory uri) internal{
        _mint(to, tokenId);
        tokenURIs[tokenId] = uri;
    }

    function tokenURI(uint _tokenId) external view returns (string memory){
        return tokenURIs[_tokenId];
    }

    function name() external view returns (string memory){
        return _name;
    }

    function symbol() external view returns (string memory){
        return _symbol;
    }
    
    function _burn(uint id) internal {
        address owner = _ownerOf[id];
        require(owner != address(0), "not minted");

        _balanceOf[owner] -= 1;

        delete _ownerOf[id];
        delete _approvals[id];

        emit Transfer(owner, address(0), id);
    }
}

contract MyNFT is ERC721{
    constructor() ERC721("ZIA" , "ZIU"){}

    string[] arr = ["https://gateway.pinata.cloud/ipfs/QmPzMFcWCvGyghFZdnR8XkyKS1kRMCodE9aj7VMccDXHA4" , 
    "https://gateway.pinata.cloud/ipfs/QmSYfwK3vswqm3nVR5KDAK8JK2nvkJ7QtBp4SiVu8hqXaS/1.json",
    "https://gateway.pinata.cloud/ipfs/QmSYfwK3vswqm3nVR5KDAK8JK2nvkJ7QtBp4SiVu8hqXaS/2.json",
    "https://gateway.pinata.cloud/ipfs/QmSYfwK3vswqm3nVR5KDAK8JK2nvkJ7QtBp4SiVu8hqXaS/3.json",
    "https://gateway.pinata.cloud/ipfs/QmSYfwK3vswqm3nVR5KDAK8JK2nvkJ7QtBp4SiVu8hqXaS/4.json",
    "https://gateway.pinata.cloud/ipfs/QmSYfwK3vswqm3nVR5KDAK8JK2nvkJ7QtBp4SiVu8hqXaS/5.json",
    "https://gateway.pinata.cloud/ipfs/QmSYfwK3vswqm3nVR5KDAK8JK2nvkJ7QtBp4SiVu8hqXaS/6.json",
    "https://gateway.pinata.cloud/ipfs/QmSYfwK3vswqm3nVR5KDAK8JK2nvkJ7QtBp4SiVu8hqXaS/7.json",
    "https://gateway.pinata.cloud/ipfs/QmSYfwK3vswqm3nVR5KDAK8JK2nvkJ7QtBp4SiVu8hqXaS/8.json",
    "https://gateway.pinata.cloud/ipfs/QmSYfwK3vswqm3nVR5KDAK8JK2nvkJ7QtBp4SiVu8hqXaS/9.json"];
    uint increment = 0;
    // uint a = 0;
    // string private uri1 = "";
    // string private uri2 = "https://gateway.pinata.cloud/ipfs/QmSYfwK3vswqm3nVR5KDAK8JK2nvkJ7QtBp4SiVu8hqXaS/1.json";
    // string private uri3 = "https://gateway.pinata.cloud/ipfs/QmSYfwK3vswqm3nVR5KDAK8JK2nvkJ7QtBp4SiVu8hqXaS/4.json";
    // arr.push(uri1);
    function mint(address to) external {
        increment++;
        uint a = random()% arr.length;
        _safeMint(to, increment, arr[a]);
    }
    // function safeMint(address to,string memory _authentication) public  {
    //     authentication = _authentication;
    //     if((keccak256(abi.encodePacked(authentication)) == keccak256(abi.encodePacked(VerificationKey)))){
    //     verified = true;
    //     require(verified == true,"keys doesn't match");
    //     uint256 tokenId = _tokenIdCounter.current();
    //     _tokenIdCounter.increment();
    //     _safeMint(to, tokenId);
    // }
    
	// 	}
    function random() public view returns (uint256) {
        // increment++;
        // sha3 and now have been deprecated
        return uint(keccak256(abi.encode(block.timestamp, block.difficulty, arr.length)))%arr.length;
        
        // convert hash to integer
        // players is an array of entrants
        
    }

    // function burn(uint id) external {
    //     require(msg.sender == _ownerOf[id], "not owner");
    //     _burn(id);
    // }
}