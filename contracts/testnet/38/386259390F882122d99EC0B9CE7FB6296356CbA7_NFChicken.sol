// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./ERC165.sol";
import "./IERC721.sol";
import "./IERC721Enumerable.sol";
import "./IERC721Receiver.sol";
import "./IERC721Metadata.sol";

contract NFChicken is ERC165, IERC721Enumerable, IERC721Metadata {
    uint private constant MASS_MINT_CALL_LIMIT = 500;
    /**
     * Token storage
     */
    mapping(uint => address) private _owners;
    mapping(address => uint) private _balances;
    mapping(uint => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * Metadata
     */
    string private _baseURL;

    /**
     * Token counter
     */
    uint private _nextTokenId;

    /**
     * User management
     */
    struct MinterCreationRequest {
        mapping(address => bool) accounts;
        uint approveCounter;
        uint mintingLimit;
    }
    mapping(address => MinterCreationRequest) private _minterCreationRequests;
    mapping(uint => mapping(address => address[])) private _userDeleteRequests;
    uint private _minApprovalsRequired;

    /**
     * Enumerable
     */
    uint[] private _allTokens;
    mapping(address => uint[]) private _ownedTokens;
    mapping(uint => uint) private _allTokensIndex;
    mapping(uint => uint) private _ownedTokensIndex;

    /**
     * Minting limit
     */
    mapping(address => uint) private _lastMintedDay;
    mapping(address => uint) private _mintedToday;
    mapping(address => uint) private _minterLimits;

    /**
     * Roles
     */
    mapping(uint => mapping(address => bool)) private _roles;
    uint private constant ROLE_ADMIN = 0;
    uint private constant ROLE_MINTER = 1;

    /**
     * Pausable
     */
    bool private _paused;
    address[] private _unpauseRequests;

    event AddingMinterRequest(address indexed account, address indexed requester, uint mintintLimit);
    event AddingMinterApprove(address indexed account, address indexed requester);
    event AddingMinterRevocation(address indexed account, address indexed requester);
    event AddingMinter(address indexed account, address indexed requester);
    event DeletingUserRequest(uint role, address indexed account, address indexed requester);
    event DeletingUserRevocation(uint role, address indexed account, address indexed requester);
    event DeletingUser(uint role, address indexed account, address indexed requester);
    event Pause(address indexed requester);
    event UnpauseRequest(address indexed requester);
    event UnpauseRevocation(address indexed requester);
    event Unpause(address indexed requester);

    modifier tokenExists(uint tokenId) {
        require(_exists(tokenId), "NFChicken: Token does not exist.");
        _;
    }

    modifier onlyAdmin() {
        require(hasRole(ROLE_ADMIN, msg.sender), "NFChicken: You are not an admin.");
        _;
    }

    modifier onlyMinter() {
        require(hasRole(ROLE_MINTER, msg.sender), "NFChicken: You are not a minter.");
        _;
    }

    modifier unpaused() {
        require(!_paused, "NFChicken: Paused.");
        _;
    }

    constructor(address[] memory admins, uint minApprovalsRequired, string memory baseURL) {
        require(admins.length > 0, "HENVesting: Admins are required.");
        require(bytes(baseURL).length > 0, "HENVesting: baseURL is empty.");
        require(
            minApprovalsRequired > 0 &&
            minApprovalsRequired <= admins.length,
            "NFChicken: Invalid number of minimum votes."
        );

        for (uint i=0; i<admins.length; i++) {
            require(admins[i] != address(0), "NFChicken: Zero address.");
            require(!_roles[ROLE_ADMIN][admins[i]], "NFChicken: Admins are not unique.");

            _roles[ROLE_ADMIN][admins[i]] = true;
        }

        _minApprovalsRequired = minApprovalsRequired;
        _baseURL = baseURL;
    }

    // ---------------------------------------------------------------------------------------------------------------
    // Token storage
    // ---------------------------------------------------------------------------------------------------------------
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721Enumerable).interfaceId ||
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function name() public pure returns (string memory) {
        return 'NFChicken';
    }

    function symbol() public pure returns (string memory) {
        return 'HEN';
    }

    function tokenURI(uint tokenId) external view tokenExists(tokenId) returns (string memory) {
        return string(abi.encodePacked(_baseURL, uint2str(tokenId)));
    }

    function ownerOf(uint tokenId) public view tokenExists(tokenId) returns (address) {
        return _owners[tokenId];
    }

    function balanceOf(address owner) public view returns (uint) {
        require(owner != address(0), "NFChicken: Address zero is not a valid owner.");

        return _balances[owner];
    }

    function getApproved(uint tokenId) public view tokenExists(tokenId) returns (address) {
        return _tokenApprovals[tokenId];
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function approve(address to, uint tokenId) external {
        address _owner = ownerOf(tokenId);

        require(to != _owner, "NFChicken: Approval to current owner");

        require(
            _owner == msg.sender || isApprovedForAll(_owner, msg.sender),
            "NFChicken: Approve caller is not token owner or approved for all."
        );

        _tokenApprovals[tokenId] = to;

        emit Approval(_owner, to, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) external {
        require(msg.sender != operator, "NFChicken: Approve to caller.");

        _operatorApprovals[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(address from, address to, uint tokenId) external {
        require(_isApprovedOrOwner(msg.sender, tokenId), "NFChicken: Caller is not token owner or approved.");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint tokenId, bytes memory data) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "NFChicken: Caller is not token owner or approved.");

        _safeTransfer(from, to, tokenId, data);
    }

    function safeTransferFrom(address from, address to, uint tokenId) external {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * Mints one NFT
     *
     * @param to - address to send minted NFT
     *
     * @return NFT ID
     */
    function safeMint(address to) public onlyMinter returns (uint) {
        require(_checkOnERC721Received(address(0), to, _nextTokenId, ""), "NFChicken: Transfer to non ERC721Receiver implementer.");

        _mint(to);

        return _nextTokenId - 1;
    }

    /**
     * Mints many NFT
     *
     * @param to - address to send minted NFT
     * @param amount - amount NFT to mint
     *
     * @return last created NFT ID
     */
    function safeMassMint(address to, uint amount) public onlyMinter returns (uint) {
        require(_checkOnERC721Received(address(0), to, _nextTokenId, ""), "NFChicken: Transfer to non ERC721Receiver implementer.");

        _massMint(to, amount);

        return _nextTokenId - 1;
    }

    function getNextTokenId() external view returns (uint) {
        return _nextTokenId;
    }

    function _exists(uint tokenId) internal view returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);

        return (
            spender == owner ||
            isApprovedForAll(owner, spender) ||
            getApproved(tokenId) == spender
        );
    }

    function _transfer(address from, address to, uint tokenId) internal unpaused {
        require(ownerOf(tokenId) == from, "NFChicken: Transfer from incorrect owner.");
        //require(to != address(0), "NFChicken: Transfer to the zero address.");

        _beforeTokenTransfer(from, to, tokenId);

        delete _tokenApprovals[tokenId];

        _balances[from]--;
        _balances[to]++;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _safeTransfer(address from, address to, uint tokenId, bytes memory data) internal {
        _transfer(from, to, tokenId);

        require(_checkOnERC721Received(from, to, tokenId, data), "NFChicken: Transfer to non ERC721Receiver implementer.");
    }

    function _mint(address to) internal unpaused {
        require(to != address(0), "NFChicken: Mint to the zero address.");
        require(!_isMintingLimited(msg.sender, 1), "NFChicken: Minting limit.");

        _beforeTokenTransfer(address(0), to, _nextTokenId);

        _owners[_nextTokenId] = to;

        _balances[to]++;

        emit Transfer(address(0), to, _nextTokenId++);
    }

    function _massMint(address to, uint amount) internal unpaused {
        require(to != address(0), "NFChicken: Mint to the zero address.");
        require(!_isMintingLimited(msg.sender, amount), "NFChicken: Minting limit.");
        require(amount > 0, "NFChicken: Nothing to mint.");
        require(amount <= MASS_MINT_CALL_LIMIT, "NFChicken: Minting limit per call.");

        for (uint i=0; i<amount; i++) {
            _beforeTokenTransfer(address(0), to, _nextTokenId);

            _owners[_nextTokenId] = to;

            emit Transfer(address(0), to, _nextTokenId++);
        }

        _balances[to] += amount;
    }

    function _beforeTokenTransfer(address from, address to, uint tokenId) internal {
        if(from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if(from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }

        if(to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if(to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    function _isMintingLimited(address account, uint amount) internal returns (bool) {
        uint dayNumber = getCurrentTime() / 86400;

        if (_lastMintedDay[account] != dayNumber) {
            _mintedToday[account] = 0;
            _lastMintedDay[account] = dayNumber;
        }

        if (_minterLimits[account] == 0 || _mintedToday[account] + amount <= _minterLimits[account]) {
            _mintedToday[account] += amount;
            return false;
        }

        return true;
    }

    function _checkOnERC721Received(address from, address to, uint tokenId, bytes memory data) private returns (bool) {
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 ret) {
                return ret == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("NFChicken: Transfer to non ERC721Receiver implementer.");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }


    // ---------------------------------------------------------------------------------------------------------------
    // Enumerable interface
    // ---------------------------------------------------------------------------------------------------------------
    function totalSupply() public view returns (uint) {
        return _allTokens.length;
    }

    function tokenByIndex(uint index) external view returns (uint) {
        require(index < totalSupply(), "NFChicken: Out of bonds.");

        return _allTokens[index];
    }

    function tokenOfOwnerByIndex(address owner, uint index) external view returns (uint) {
        require(index < balanceOf(owner), "NFChicken: Out of bonds.");

        return _ownedTokens[owner][index];
    }

    /**
     * Returns all tokens for the owner
     */
    function tokensByOwner(address owner) external view returns (uint[] memory) {
        return _ownedTokens[owner];
    }

    function _addTokenToAllTokensEnumeration(uint tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromAllTokensEnumeration(uint tokenId) private {
        uint lastTokenIndex = _allTokens.length - 1;
        uint tokenIndex = _allTokensIndex[tokenId];

        uint lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId;
        _allTokensIndex[lastTokenId] = tokenIndex;

        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }

    function _addTokenToOwnerEnumeration(address to, uint tokenId) private {
        uint _length = balanceOf(to);

        _ownedTokensIndex[tokenId] = _length;
        _ownedTokens[to].push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint tokenId) private {
        uint lastTokenIndex = balanceOf(from) - 1;
        uint tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint lastTokenId = _ownedTokens[from][lastTokenIndex];
            _ownedTokens[from][tokenIndex] = lastTokenId;
            _ownedTokensIndex[lastTokenId] = tokenIndex;
        }

        delete _ownedTokensIndex[tokenId];
        _ownedTokens[from].pop();
    }


    // ---------------------------------------------------------------------------------------------------------------
    // Pausable interface
    // ---------------------------------------------------------------------------------------------------------------
    /**
     * Pauses all transactions
     */
    function pause() external onlyAdmin {
        require(!_paused, "NFChicken: Already paused.");

        _paused = true;

        emit Pause(msg.sender);
    }

    /**
     * Requests unpause
     */
    function requestUnpause() external onlyAdmin {
        require(_paused, "NFChicken: Not paused.");
        require(!_addressInArray(_unpauseRequests, msg.sender), "NFChicken: Request already exists.");

        _unpauseRequests.push(msg.sender);

        emit UnpauseRequest(msg.sender);
    }

    /**
     * Revokes previous unpause request
     */
    function revokeUnpauseRequest() external onlyAdmin {
        require(_addressInArray(_unpauseRequests, msg.sender), "NFChicken: Request does not exist.");

        _deleteAddressInArray(_unpauseRequests, msg.sender);

        emit UnpauseRevocation(msg.sender);
    }

    /**
     * Unpauses.
     * It's needed _minApprovalsRequired requests to unpause the contract.
     */
    function unpause() external onlyAdmin {
        require(_paused, "NFChicken: Not unpaused.");
        require(_unpauseRequests.length >= _minApprovalsRequired, "NFChicken: Not enough requests.");

        _paused = false;
        delete _unpauseRequests;

        emit Unpause(msg.sender);
    }


    // ---------------------------------------------------------------------------------------------------------------
    // User management
    // ---------------------------------------------------------------------------------------------------------------
    /**
     * Checks if the user exists
     */
    function hasRole(uint role, address account) public view returns (bool) {
        return _roles[role][account];
    }

    /**
     * Requests to add a minter user.
     *
     * @param account - the minter user account
     * @param mintingLimit - how many NFT cat mint the minter per day (0 - no limit)
     */
    function requestAddingMinter(address account, uint mintingLimit) external onlyAdmin {
        require(!hasRole(ROLE_MINTER, account), "NFChicken: User already exists.");
        require(_minterCreationRequests[account].approveCounter == 0, "NFChicken: Approve already exists.");

        _minterCreationRequests[account].accounts[msg.sender] = true;
        _minterCreationRequests[account].approveCounter = 1;
        _minterCreationRequests[account].mintingLimit = mintingLimit;

        emit AddingMinterRequest(account, msg.sender, mintingLimit);
    }

    /**
     * Approves of the minter adding request
     *
     * @param account - the minter user account from requestAddingMinter() request
     */
    function approveAddingMinterRequest(address account) external onlyAdmin {
        require(_minterCreationRequests[account].approveCounter > 0, "NFChicken: Request does not exist.");
        require(!_minterCreationRequests[account].accounts[msg.sender], "NFChicken: Approve already exists.");

        _minterCreationRequests[account].accounts[msg.sender] = true;
        _minterCreationRequests[account].approveCounter++;

        emit AddingMinterApprove(account, msg.sender);
    }

    /**
     * Revokes the previous request of adding a minter.
     *
     * @param account - the minter user account from requestAddingMinter()/approveAddingMinterRequest()
     */
    function revokeAddingMinterRequest(address account) external onlyAdmin {
        require(_minterCreationRequests[account].accounts[msg.sender], "NFChicken: Approve does not exist.");

        _minterCreationRequests[account].accounts[msg.sender] = false;
        _minterCreationRequests[account].approveCounter--;

        if (_minterCreationRequests[account].approveCounter == 0) {
            delete _minterCreationRequests[account];
        }

        emit AddingMinterRevocation(account, msg.sender);
    }

    /**
     * Adds the minter from the minter adding request.
     * It's needed _minApprovalsRequired confirms to allow it.
     *
     * @param account - a minter user account from requestAddingMinter()/approveAddingMinterRequest()
     */
    function addMinter(address account) external onlyAdmin {
        require(!hasRole(ROLE_MINTER, account), "NFChicken: User already exists.");
        require(_minterCreationRequests[account].approveCounter >= _minApprovalsRequired, "NFChicken: Not enough approvals.");

        _roles[ROLE_MINTER][account] = true;
        _minterLimits[account] = _minterCreationRequests[account].mintingLimit;
        delete _minterCreationRequests[account];

        emit AddingMinter(account, msg.sender);
    }

    /**
     * Requests/Approves a user deleting.
     *
     * @param role - the user role
     * @param account - the minter user account
     */
    function requestDeletingUser(uint role, address account) external onlyAdmin {
        require(role == ROLE_ADMIN || role == ROLE_MINTER, "NFChicken: Role does not exist.");
        require(hasRole(role, account), "NFChicken: User does not exist.");
        require(!(role == ROLE_ADMIN && account == msg.sender), "NFChicken: It is forbidden to ban yourself.");
        require(!_addressInArray(_userDeleteRequests[role][account], msg.sender), "NFChicken: Request already exists.");

        _userDeleteRequests[role][account].push(msg.sender);

        emit DeletingUserRequest(role, account, msg.sender);
    }

    /**
     * Revokes the previous request of deleting a user.
     *
     * @param role - the user role
     * @param account - the minter user account
     */
    function revokeDeletingUserRequest(uint role, address account) external onlyAdmin {
        require(_addressInArray(_userDeleteRequests[role][account], msg.sender), "NFChicken: Request doesn't exist.");

        _deleteAddressInArray(_userDeleteRequests[role][account], msg.sender);

        emit DeletingUserRevocation(role, account, msg.sender);
    }

    /**
     * Deletes a minter from the minter deleting request.
     * It's needed _minApprovalsRequired confirms to allow it.
     *
     * @param role - the user role
     * @param account - the minter user account
     */
    function deleteUser(uint role, address account) external onlyAdmin {
        require(hasRole(role, account), "NFChicken: User does not exist.");
        require(_userDeleteRequests[role][account].length >= _minApprovalsRequired, "NFChicken: Not enough requests.");

       _roles[role][account] = false;
       delete _userDeleteRequests[role][account];

       delete _minterLimits[account];
       delete _mintedToday[account];

       emit DeletingUser(role, account, msg.sender);
    }


    // ---------------------------------------------------------------------------------------------------------------
    // Payable functions
    // ---------------------------------------------------------------------------------------------------------------
    fallback() external payable { }

    receive() external payable { }

    function withdraw(uint amount) external onlyAdmin {
        address payable _to = payable(msg.sender);
        _to.transfer(amount);
    }


    // ---------------------------------------------------------------------------------------------------------------
    // Helpers
    // ---------------------------------------------------------------------------------------------------------------
    /**
     * @dev Returns time of the current block. (for using in mock)
     */
    function getCurrentTime() public virtual view returns(uint) {
        return block.timestamp;
    }

    function _addressInArray(address[] storage arr, address account) internal view returns (bool) {
       for (uint i=0; i<arr.length; i++) {
            if (arr[i] == account) {
               return true;
            }
       }

       return false;
    }

    function _deleteAddressInArray(address[] storage arr, address account) internal {
        bool found = false;

        for (uint i=0; i<arr.length-1; i++) {
            if (arr[i] == account) {
                found = true;
            }
            if (found) {
                arr[i] = arr[i+1];
            }
        }
        if (found || arr[arr.length-1] == account) {
            arr.pop();
        }
    }

    /**
     * Converts a `uint256` to its ASCII `string` decimal representation.
     */
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

}