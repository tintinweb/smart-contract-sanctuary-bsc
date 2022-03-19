// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./Address.sol";
import "./Auth.sol";
import "./EnumerableSet.sol";
import "./EnumerableMap.sol";
import "./ERC165.sol";
import "./IBEP20.sol";
import "./IERC721Enumerable.sol";
import "./IERC721Metadata.sol";
import "./IERC721Receiver.sol";

contract LucidsNft is Auth, ERC165, IERC721Metadata, IERC721Enumerable {
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;

    address immutable DEAD = 0x000000000000000000000000000000000000dEaD;
	address payToken = 0x82A479264B36104be4FDb91618a59A4fC0F50650;

    mapping (address => EnumerableSet.UintSet) private _holderTokens;
    EnumerableMap.UintToAddressMap private _tokenOwners;
    mapping (uint256 => address) private _tokenApprovals;
    mapping (address => mapping (address => bool)) private _operatorApprovals;
    mapping (address => bool) private _canBurn;

    string private _name;
    string private _symbol;

	uint256 private currentId = 0;
	uint256 public max = 4200;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x93254542;
    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    string private _baseUri;
	string private _fileExtension = ".json";

	address private _tokenReceiver = 0xf3Ea7CA781ac32960E528cc288effF64C279d678;
	address private _devPaymentReceiver = 0xf3Ea7CA781ac32960E528cc288effF64C279d678;
	uint256 public mintTokenPrice = 1250 ether;
	uint256 public mintPrice = 0.1 ether;
	bool public onlyWhiteListMint = true;
	bool public onlyPrivateMint = true;
	mapping (address => bool) public isPrivateSale;
	mapping (address => bool) public isWhitelisted;
	uint256 private multisigGas = 34000;
	uint8 public mintsAtOnce = 2;
	uint256 public maxCards = 2;
	uint16 private devCut = 100; // Out of 1000

    constructor() Auth(msg.sender) {
        _name = "Lucids";
        _symbol = "LUCIDS";

        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

	function setTokenReceiver(address addy) external authorized {
		_tokenReceiver = addy;
	}

	function setDevReceiver(address addy) external authorized {
		_devPaymentReceiver = addy;
	}

	function setDevCut(uint16 cut) external authorized {
		devCut = cut;
	}

	function setMintPriceTokens(uint256 price) external authorized {
		mintTokenPrice = price;
	}

	function setMintPrice(uint256 price) external authorized {
		mintPrice = price;
	}

	function setWhiteListMint(bool status) external authorized {
		onlyWhiteListMint = status;
	}

	function setMintsAtOnce(uint8 once) external authorized {
		mintsAtOnce = once;
	}

	function setMaxCards(uint256 m) external authorized {
		maxCards = m;
	}

    function setEnchantAddress(address stats) external authorized {
        _canBurn[stats] = true;
    }

    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");

        return _holderTokens[owner].length();
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function setBaseUri(string memory uri) public authorized {
        _baseUri = uri;
    }

	function setFileExtension(string memory ext) public authorized {
        _fileExtension = ext;
    }

	function setIsWhitelisted(address addy, bool state) external authorized {
		isWhitelisted[addy] = state;
	}

	function setAreWhitelisted(address[] calldata addies, bool state) external authorized {
		for (uint256 i = 0; i < addies.length; i++) {
			isWhitelisted[addies[i]] = state;
		}
	}

	function setIsPrivate(address addy, bool state) external authorized {
		isPrivateSale[addy] = state;
	}

	function setArePrivate(address[] calldata addies, bool state) external authorized {
		for (uint256 i = 0; i < addies.length; i++) {
			isPrivateSale[addies[i]] = state;
		}
	}

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

    function tokenURI(uint256 tokenId) external view override returns (string memory) {
        return string(abi.encodePacked(_baseUri, uint2str(tokenId), _fileExtension));
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view override returns (uint256) {
        return _holderTokens[owner].at(index);
    }

	function getTokensOfOwner(address owner) external view returns (uint256[] memory) {
		uint256 owned = balanceOf(owner);
		uint256[] memory tokens = new uint256[](owned);
		for (uint256 i = 0; i < owned; i++) {
			tokens[i] = tokenOfOwnerByIndex(owner, i);
		}

		return tokens;
	}

    function totalSupply() public view override returns (uint256) {
        return _tokenOwners.length();
    }

    function tokenByIndex(uint256 index) public view override returns (uint256) {
        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

	function setMaxMints(uint16 m) external authorized {
		max = m;
	}

    function mintNFT(uint8 mints) external payable {
		require(isPrivateSale[msg.sender] || msg.value == getPrice() * mints, "Wrong price sent.");
		if (isPrivateSale[msg.sender] && msg.value > 0) {
			(bool sent, bytes memory data) = msg.sender.call{value: msg.value, gas: multisigGas}("");
		} else {
			processPayment(msg.value);
		}
		_tryMint(mints);
    }

	function processPayment(uint256 amount) internal {
		uint256 devPart = amount * devCut / 1000;
		(bool sent, bytes memory data) = _devPaymentReceiver.call{value: devPart, gas: multisigGas}("");
		if (sent) {
			(sent, data) = _tokenReceiver.call{value: amount - devPart, gas: multisigGas}("");
			require(sent, "Error processing payment");
		}
	}

	/*function mintNFTTokens(uint8 mints) external {
		require(sendTokens(msg.sender, _tokenReceiver, getTokenPrice() * mints), "Could not receive tokens!");
		_tryMint(mints);
	}*/

	function sendTokens(address minter, address receiver, uint256 amount) internal returns(bool) {
		return IBEP20(payToken).transferFrom(minter, receiver, amount);
	}

	function _tryMint(uint8 mints) internal {
		if (onlyPrivateMint) {
			require(isPrivateSale[msg.sender], "Only private sale mints right now.");
		}
		if (onlyWhiteListMint) {
			require(isWhitelisted[msg.sender], "Only whitelisted mints right now.");
		}
		require(mints <= mintsAtOnce || msg.sender == owner, "Cannot mint so many at once!");
		require(balanceOf(msg.sender) + mints <= maxCards || msg.sender == owner, "You have reached the mint limit.");
		for (uint256 i = 0; i < mints; i++) {
			uint mintIndex = currentId;
			require(mintIndex <= max, "There are no more available NFTs. Sorry.");
			_safeMint(msg.sender, mintIndex);
			currentId++;
		}
	}

	function getCurrentPrice() external view returns (uint256) {
		return getPrice();
	}

	function getCurrentTokenPrice() external view returns (uint256) {
		return getTokenPrice();
	}

	function getPrice() internal view returns (uint256) {
		return mintPrice;
	}

	function getTokenPrice() internal view returns (uint256) {
		return mintTokenPrice;
	}

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != msg.sender, "ERC721: approve to caller");

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return _tokenOwners.contains(tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _holderTokens[to].add(tokenId);
        _tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

    function burnFromEnchant(uint256 id) external {
        require(_canBurn[msg.sender], "Only enchant contract can use this.");
        _burn(id);
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            msg.sender,
            from,
            tokenId,
            _data
        ), "ERC721: transfer to non ERC721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    function _approve(address to, uint256 tokenId) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual {}

	function setPayToken(address addy) external authorized {
		payToken = addy;
	}

	function recover() external authorized {
		payable(owner).transfer(address(this).balance);
	}
}