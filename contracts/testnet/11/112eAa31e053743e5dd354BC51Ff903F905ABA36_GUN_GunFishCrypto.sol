/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

   
    function allowance(address owner, address spender) external view returns (uint256);

   
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

  
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.8.0;


library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}


pragma solidity ^0.8.0;


library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}



pragma solidity ^0.8.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}



pragma solidity ^0.8.0;


library Address {
    
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

   
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }


    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }


    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }


    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}


pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol



pragma solidity ^0.8.0;
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}



pragma solidity ^0.8.0;



interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);


    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function getBoxInfo(uint boxTokenId) external view returns(uint __boxTokenId, uint __boxType, uint __gunAmount);
    function getBoxInfo2(uint boxTokenId) external view returns(uint __gunAmount);

   
    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

   
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

pragma solidity ^0.8.0;

interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}


pragma solidity ^0.8.0;

contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function getBoxInfo(uint boxTokenId) external view virtual override returns(uint __boxTokenId, uint __boxType, uint __gunAmount){

    }

    function getBoxInfo2(uint boxTokenId) external view virtual override returns(uint __gunAmount){

    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

 
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

   
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

   
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

   
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

   
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

   
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

   
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

   
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

 
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

pragma solidity ^0.8.1;


contract GUN_GunFishCrypto is ERC721{

    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint public price_token_per_gun=1000*10*18;

    address public owner;
    string public domain;
    address public boxAddress;
    IERC721 public boxNFT;

    IERC20 public TokenFGC;

    
    address public gameMaster;

    struct GunInfo{
        address gunOwner;
        uint gunTokenId;
        uint level; //1,2,3,4,5
    }
    GunInfo[] Guns;

    constructor(string memory _name, string memory _symbol, string memory _domain, address _tokenFGC) ERC721(_name, _symbol){
        domain = _domain;
        owner = msg.sender;
        TokenFGC = IERC20(_tokenFGC);
    }

    modifier checkOwner(){
        require(msg.sender==owner, "[0] Your are not allowed to process");
        _;
    }

    modifier checkGameMaster(){
        require(msg.sender == gameMaster, "You are not game master");
        _;
    }
    
    function getCurrentTokenId() public view returns(uint){
        return _tokenIds.current();
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory){
        require(!_exists(tokenId), "[-1] Sorry, tokenid is not availble");
        if(bytes(domain).length>0){
            return string(abi.encodePacked(domain, tokenId.toString()));
        }else{
            return "";
        }
    }

    function updateBoxAddress(address _boxNFT) public checkOwner{
        boxAddress = _boxNFT;
        boxNFT = IERC721(_boxNFT);
    }
    
    // update Domain
    function update_Domain(string memory _newDomain) public checkOwner{
        domain = _newDomain;
    }

    function update_FGC_per_gun(uint _newPrice) public checkOwner{
        price_token_per_gun =  _newPrice;
    }
    
    function update_FGC_Address(address _newAddress) public checkOwner{
        TokenFGC = IERC20(_newAddress);
    }

    function withdrawFGC() public checkOwner{
        require(TokenFGC.balanceOf(address(this))>0, "Sorry, we do not have FGC now.");
        TokenFGC.transfer(owner, TokenFGC.balanceOf(address(this)));
    }

    event Player_buy_gun(uint[] gunIds);

    function buyGun_By_Token(uint amount) public{
        require(amount>=1, "Wrong gun amount.");
        uint totalFGC = price_token_per_gun * amount;
        require(TokenFGC.allowance(msg.sender, address(this))>=totalFGC, "Please approve FGC before buy guns.");
        require(TokenFGC.balanceOf(msg.sender)>=totalFGC, "Sorry, you do not have FGC enough to buy guns.");
        TokenFGC.transferFrom(msg.sender, address(this), totalFGC);
        uint[] memory arrayGunIds = new uint[](amount);
        for(uint count=1; count<=amount; count++){
            _tokenIds.increment();
            uint256 newItemId = _tokenIds.current();
            _mint(msg.sender, newItemId);
            arrayGunIds[count-1] = newItemId;
            Guns.push(GunInfo(msg.sender, newItemId, 1));
        }
        emit Player_buy_gun(arrayGunIds);
    }

    
    // upgrade level gun
    uint[] price_upgrade_gun_type0 = [100*10**18,200*10**18,400*10**18,700*10**18];
    uint[] price_upgrade_gun_type1 = [200*10**18,400*10**18,500*10**18,900*10**18];
    uint[] price_upgrade_gun_type2 = [200*10**18,400*10**18,500*10**18,1000*10**18];
    uint[] price_upgrade_gun_type3 = [700*10**18,1800*10**18,4000*10**18,14600*10**18];
    uint[] price_upgrade_gun_type4 = [900*10**18,2500*10**18,5600*10**18,19900*10**18];

    function update_price_upgrade_gun(uint256 typeGun, uint256 price1, uint256 price2, uint256 price3, uint256 price4) public checkOwner(){
        if(typeGun==0){ price_upgrade_gun_type0 = [price1, price2, price3, price4];}
        if(typeGun==1){ price_upgrade_gun_type1 = [price1, price2, price3, price4];}
        if(typeGun==2){ price_upgrade_gun_type2 = [price1, price2, price3, price4];}
        if(typeGun==3){ price_upgrade_gun_type3 = [price1, price2, price3, price4];}
        if(typeGun==4){ price_upgrade_gun_type4 = [price1, price2, price3, price4];}
    }

    // type: loai sung: 0,1,2,3
    // tokenAmountPos: position in price_upgrade_gun_type0  0-3, lv2 to 5
    function client_upgradeGun2(uint tokenIdGun_1, uint tokenIdGun_2, uint _type, uint tokenAmountPos) public returns(address, uint, uint, uint, uint, uint){
        require(_type<=4, "Wrong Type"); // 0 to 4
        
        if(_type==0){
            require(tokenAmountPos<=price_upgrade_gun_type0.length, "[-3]Wrong token amount position");
            require(TokenFGC.balanceOf(msg.sender)>=price_upgrade_gun_type0[tokenAmountPos], "[-2] Not enough Zombie");
            require(TokenFGC.allowance(msg.sender, address(this))>=price_upgrade_gun_type0[tokenAmountPos], "[0] Token has not been approved.");
            TokenFGC.transferFrom(msg.sender, address(this), price_upgrade_gun_type0[tokenAmountPos]);
            return(msg.sender, tokenIdGun_1, tokenIdGun_2, _type, tokenAmountPos, price_upgrade_gun_type0[tokenAmountPos] );
        }
        
        if(_type==1){
            require(tokenAmountPos<=price_upgrade_gun_type1.length, "[-3]Wrong token amount position");
            require(TokenFGC.balanceOf(msg.sender)>=price_upgrade_gun_type1[tokenAmountPos], "[-2] Not enough Zombie");
            require(TokenFGC.allowance(msg.sender, address(this))>=price_upgrade_gun_type1[tokenAmountPos], "[0] Token has not been approved.");
            TokenFGC.transferFrom(msg.sender, address(this), price_upgrade_gun_type1[tokenAmountPos]);
            return(msg.sender, tokenIdGun_1, tokenIdGun_2, _type, tokenAmountPos, price_upgrade_gun_type1[tokenAmountPos] );
        }

        if(_type==2){
            require(tokenAmountPos<=price_upgrade_gun_type2.length, "[-3]Wrong token amount position");
            require(TokenFGC.balanceOf(msg.sender)>=price_upgrade_gun_type2[tokenAmountPos], "[-2] Not enough Zombie");
            require(TokenFGC.allowance(msg.sender, address(this))>=price_upgrade_gun_type2[tokenAmountPos], "[0] Token has not been approved.");
            TokenFGC.transferFrom(msg.sender, address(this), price_upgrade_gun_type2[tokenAmountPos]);
            return(msg.sender, tokenIdGun_1, tokenIdGun_2, _type, tokenAmountPos, price_upgrade_gun_type2[tokenAmountPos] );
        }

        if(_type==3){
            require(tokenAmountPos<=price_upgrade_gun_type3.length, "[-3]Wrong token amount position");
            require(TokenFGC.balanceOf(msg.sender)>=price_upgrade_gun_type3[tokenAmountPos], "[-2] Not enough Zombie");
            require(TokenFGC.allowance(msg.sender, address(this))>=price_upgrade_gun_type3[tokenAmountPos], "[0] Token has not been approved.");
            TokenFGC.transferFrom(msg.sender, address(this), price_upgrade_gun_type3[tokenAmountPos]);
            return(msg.sender, tokenIdGun_1, tokenIdGun_2, _type, tokenAmountPos, price_upgrade_gun_type3[tokenAmountPos] );
        }

        if(_type==4){
            require(tokenAmountPos<=price_upgrade_gun_type4.length, "[-3]Wrong token amount position");
            require(TokenFGC.balanceOf(msg.sender)>=price_upgrade_gun_type4[tokenAmountPos], "[-2] Not enough Zombie");
            require(TokenFGC.allowance(msg.sender, address(this))>=price_upgrade_gun_type4[tokenAmountPos], "[0] Token has not been approved.");
            TokenFGC.transferFrom(msg.sender, address(this), price_upgrade_gun_type4[tokenAmountPos]);
            return(msg.sender, tokenIdGun_1, tokenIdGun_2,  _type, tokenAmountPos, price_upgrade_gun_type4[tokenAmountPos] );
        }

        return(address(0), 0, 0, 0, 0, 0 );
    }

    event Player_upgrade_gun2(uint tokenIdGun_1, uint tokenIdGun_2, address gunOwner, string _id);
    function gameMaster_upgradeGun2(string memory _id, uint tokenIdGun_1, uint tokenIdGun_2, address gunOwner) public checkGameMaster(){
        // check owner
        require(gunOwner!=address(0), "Wrong owner address");
        require(ownerOf(tokenIdGun_1)==gunOwner && ownerOf(tokenIdGun_2)==gunOwner , "[-4] Wrong gun owner" );
        _burn(tokenIdGun_2);
        emit Player_upgrade_gun2(tokenIdGun_1, tokenIdGun_2, gunOwner, _id);
    }

    // update gamemaster address, price_upgrade_gun
    function update_gameMasterAddress(address _newAddress) public checkOwner{
        require(_newAddress!=address(0), "Wrong address 0");
        gameMaster = _newAddress;
    }


    // upgrade 3 gun old
    function update_gun_fusion(uint lv1, uint lv2, uint lv3, uint lv4) public checkOwner(){
        price_upgrade_gun_old_type0[0] = lv1;
        price_upgrade_gun_old_type1[0] = lv2;
        price_upgrade_gun_old_type2[0] = lv3;
        price_upgrade_gun_old_type3[0] = lv4;
    }
    uint[] price_upgrade_gun_old_type0 = [500*10**18];
    uint[] price_upgrade_gun_old_type1 = [1000*10**18];
    uint[] price_upgrade_gun_old_type2 = [1500*10**18];
    uint[] price_upgrade_gun_old_type3 = [2000*10**18];

    function client_upgradeGun(uint tokenIdGun_1, uint tokenIdGun_2, uint tokenIdGun_3, uint _type, uint tokenAmountPos) public returns(address, uint, uint, uint, uint, uint, uint){
        // tokenAmountPos = 0; waste nha
        require(_type<=4, "Wrong Type"); // 0 to 4
        
        if(_type==0){
            require(tokenAmountPos<price_upgrade_gun_old_type0.length, "[-3]Wrong token amount");
            require(TokenFGC.balanceOf(msg.sender)>=price_upgrade_gun_old_type0[tokenAmountPos], "[-2] Not enough Zombie");
            require(TokenFGC.allowance(msg.sender, address(this))>=price_upgrade_gun_old_type0[tokenAmountPos], "[0] Token has not been approved.");
            TokenFGC.transferFrom(msg.sender, address(this), price_upgrade_gun_old_type0[tokenAmountPos]);
            return(msg.sender, tokenIdGun_1, tokenIdGun_2, tokenIdGun_3, _type, tokenAmountPos, price_upgrade_gun_old_type0[tokenAmountPos] );
        }
        
        if(_type==1){
            require(tokenAmountPos<price_upgrade_gun_old_type1.length, "[-3]Wrong token amount");
            require(TokenFGC.balanceOf(msg.sender)>=price_upgrade_gun_old_type1[tokenAmountPos], "[-2] Not enough Zombie");
            require(TokenFGC.allowance(msg.sender, address(this))>=price_upgrade_gun_old_type1[tokenAmountPos], "[0] Token has not been approved.");
            TokenFGC.transferFrom(msg.sender, address(this), price_upgrade_gun_old_type1[tokenAmountPos]);
            return(msg.sender, tokenIdGun_1, tokenIdGun_2, tokenIdGun_3, _type, tokenAmountPos, price_upgrade_gun_old_type1[tokenAmountPos] );
        }

        if(_type==2){
            require(tokenAmountPos<price_upgrade_gun_old_type2.length, "[-3]Wrong token amount");
            require(TokenFGC.balanceOf(msg.sender)>=price_upgrade_gun_old_type2[tokenAmountPos], "[-2] Not enough Zombie");
            require(TokenFGC.allowance(msg.sender, address(this))>=price_upgrade_gun_old_type2[tokenAmountPos], "[0] Token has not been approved.");
            TokenFGC.transferFrom(msg.sender, address(this), price_upgrade_gun_old_type2[tokenAmountPos]);
            return(msg.sender, tokenIdGun_1, tokenIdGun_2, tokenIdGun_3, _type, tokenAmountPos, price_upgrade_gun_old_type2[tokenAmountPos] );
        }

        if(_type==3){
            require(tokenAmountPos<price_upgrade_gun_old_type3.length, "[-3]Wrong token amount");
            require(TokenFGC.balanceOf(msg.sender)>=price_upgrade_gun_old_type3[tokenAmountPos], "[-2] Not enough Zombie");
            require(TokenFGC.allowance(msg.sender, address(this))>=price_upgrade_gun_old_type3[tokenAmountPos], "[0] Token has not been approved.");
            TokenFGC.transferFrom(msg.sender, address(this), price_upgrade_gun_old_type3[tokenAmountPos]);
            return(msg.sender, tokenIdGun_1, tokenIdGun_2, tokenIdGun_3, _type, tokenAmountPos, price_upgrade_gun_old_type3[tokenAmountPos] );
        }

        return(address(0), 0, 0, 0, 0, 0, 0 );
    }

    event Player_upgrade_gun(uint tokenIdGun_1, uint tokenIdGun_2, uint tokenIdGun_3, uint tokenIdGun_new, address gunOwner, string _id);
    function gameMaster_upgradeGun(string memory _id, uint tokenIdGun_1, uint tokenIdGun_2, uint tokenIdGun_3, address gunOwner) public checkGameMaster(){
        // check owner
        require(gunOwner!=address(0), "Wrong owner address");
        require(ownerOf(tokenIdGun_1)==gunOwner && ownerOf(tokenIdGun_2)==gunOwner && ownerOf(tokenIdGun_3)==gunOwner, "[-4] Wrong gun owner" );
        _burn(tokenIdGun_1);
        _burn(tokenIdGun_2);
        _burn(tokenIdGun_3);
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(gunOwner, newItemId);
        emit Player_upgrade_gun(tokenIdGun_1, tokenIdGun_2, tokenIdGun_3, newItemId, gunOwner, _id);
    }

    // admin mint gun
    event Admin_mint_gun(string _id, address gunOwner, uint256 idGun);
    function gameMaster_mintGun(string memory _id, address gunOwner, int amount) public checkGameMaster(){
        // check owner
        require(gunOwner!=address(0), "Wrong owner address");
        require(amount >0 , "[-4] Wrong amount" );

        for(int count=1; count<=amount; count++){
             _tokenIds.increment();
            uint256 newItemId = _tokenIds.current();
            _mint(gunOwner, newItemId);
            emit Admin_mint_gun(_id, gunOwner, newItemId);
        }
       
    }

}