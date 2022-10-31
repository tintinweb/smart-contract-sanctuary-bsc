// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./Ownable.sol";
import "./IERC721.sol";
import "./IERC721Metadata.sol";
import "./Address.sol";
import "./Context.sol";
import "./Strings.sol";
import "./ERC165.sol";



contract TestNFT is ERC721Enumerable, Ownable {
    using Strings for uint256;
    using Address for address;

    uint256 private _currentTokenId = 0;

    string private _uri;

    uint256 public _price;

    address private ERC20Contract;

    address private _verifier;

    mapping(address => uint256[]) private lastCreate;

    mapping(uint256 => bool) private lockedToken;

    // Mapping set ids to tokens list
    mapping(uint256 => uint256[]) private _sets;

    mapping(uint256 => bool) private usedNonces;

	event Create(address indexed creator, uint256 _tokenId, string args);
    event ChangeStateToken(address indexed owner, uint256 _tokenId, bool _state);

    uint256 public intervalMint = 0;
    uint256 public intervalCount = 5;

   constructor(string memory _name, string memory _symbol, address cOwner, string memory uri_, address verifier) Ownable(cOwner) ERC721(_name, _symbol) {
        _uri = uri_;
        _verifier = verifier;
    }

    modifier isCanCreate(address _wallet) {
        if (intervalMint != 0) {
            uint256 count = 0;
            uint256 curTime = block.timestamp;
            uint256 len = lastCreate[_msgSender()].length;

            if (len > 0) {

                while(len != 0) {
                    len--;
                    if (curTime - lastCreate[_msgSender()][len] < intervalMint)
                        count++;
                    else
                        break;
                }

            }

            require(intervalCount > count, "Limit mint NFT");
        }
        
        _;
    }
 
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        require(!lockedToken[tokenId], "Token locked");
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function setIntervalMint(uint256 _intervalMint, uint256 _intervalCount) external onlyOwner {
        intervalMint = _intervalMint;
        intervalCount = _intervalCount;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        return bytes(_uri).length > 0 ? string(abi.encodePacked(_uri, tokenId.toString())) : "";
    }


    function setBaseURI(string memory _newuri) public onlyOwner {
        _uri = _newuri;

    }

    function setERC20Contract(address _account) public onlyOwner {
        ERC20Contract = _account;
    }

    function setMintPrice(uint256 _newprice) public onlyOwner {
        _price = _newprice;
    }


    function withdrawOwner() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(_msgSender()).transfer(balance);
    }


    function _getNextTokenId() private view returns (uint256) {
        return _currentTokenId + 1;
    }

    function _incrementTokenId() private {
        _currentTokenId++;
    }

    function create(bool _free, string memory _args, uint256 nonce, bytes memory sig) public payable isCanCreate(_msgSender()) {
        require(!usedNonces[nonce]);
        bytes32 message = prefixed(keccak256(abi.encodePacked(_free, nonce, address(this), _args)));
        address signer = recoverSigner(message, sig);
        require(signer ==_verifier, "Unauthorized transaction");

        usedNonces[nonce] = true;
        
        if (!_free) {
            require(_price > 0, "Price is not set");
            require(msg.value >= _price, "Insufficient BNB to mint token");
            uint256 change = msg.value - _price;
            if (change > 0) {
                payable(_msgSender()).transfer(change);
            }
        }
        

        uint256 newTokenId = _getNextTokenId();
        _safeMint(_msgSender(), newTokenId);
        _incrementTokenId();
        setLastCreate(_msgSender());
        emit Create(_msgSender(), newTokenId, _args);

    }

    function multiCreate(uint count, string memory _args) external {
        uint i = 0;
        for(i; i < count; i++){
            uint256 newTokenId = _getNextTokenId();
            _safeMint(_msgSender(), newTokenId);
            _incrementTokenId();
            emit Create(_msgSender(), newTokenId, _args);
        }
    }

    function changeStateToken(bool _state, uint256 _tokenId, uint256 nonce, bytes memory sig, string memory _args) external {
        require(!usedNonces[nonce]);
        bytes32 message = prefixed(keccak256(abi.encodePacked(_state, _tokenId, nonce, address(this), _args)));
        address signer = recoverSigner(message, sig);
        require(signer ==_verifier, "Unauthorized transaction");

        require(ownerOf(_tokenId) == _msgSender(), "Caller is not token owner");
        
        lockedToken[_tokenId] = _state;

        emit ChangeStateToken(_msgSender(), _tokenId, _state);

    }

    function createFromERC20(address _sender) public isCanCreate(_sender) returns (uint256) {
        require(_msgSender() == ERC20Contract, "Caller is not authorized to use this function");
        require(_sender != address(0), "Cannot mint to zero address");
        uint256 newTokenId = _getNextTokenId();
        _safeMint(_sender, newTokenId);
        _incrementTokenId();
        setLastCreate(_sender);
        return newTokenId;
    }

    function setLastCreate(address _wallet) private {
        lastCreate[_wallet].push( block.timestamp);
    }

    function getAllTokensByOwner(address account) public view returns (uint256[] memory) {
        uint256 length = balanceOf(account);
        uint256[] memory result = new uint256[](length);
        for (uint i = 0; i < length; i++)
            result[i] = tokenOfOwnerByIndex(account, i);
        return result;
    }

    function recoverSigner(bytes32 message, bytes memory sig) public pure
    returns (address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = splitSignature(sig);

        return ecrecover(message, v, r, s);
    }

    function splitSignature(bytes memory sig)
    public
    pure
    returns (uint8, bytes32, bytes32)
    {
        require(sig.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    // Builds a prefixed hash to mimic the behavior of eth_sign.
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }





}