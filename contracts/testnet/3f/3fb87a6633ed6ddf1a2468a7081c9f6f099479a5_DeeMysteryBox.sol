/**
 *Submitted for verification at BscScan.com on 2022-04-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

library Address {
    function isContract(address account) internal view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}

interface DeeNFTMinter {
    function mintNFT(uint character, uint level, uint amount,address toAddress) external;
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
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

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor (){
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Minters is Ownable{

    mapping(address => bool) private _minters;

    event MinterAdded(address indexed minter);

    event MinterRemoved(address indexed minter);

    modifier onlyMinter() {
        require(_minters[_msgSender()], "Minters: caller is not the minter");
        _;
    }


    function addMinter(address minter) external onlyOwner {
        _minters[minter] = true;
        emit MinterAdded(minter);
    }

    function removeMinter(address minter) external onlyOwner {
        _minters[minter] = false;
        emit MinterRemoved(minter);
    }

    function isMinter(address minter) external view returns(bool) {
        return _minters[minter];
    }
}

contract ERC721 is IERC721,Minters {
    using Address for address;

    string public name;

    string public symbol;

    uint public nftTokenId = 0;

    uint public totalSupply = 0;

    event Transfer(address indexed from, address indexed to, uint indexed tokenId);
    event Approval(
        address indexed owner,
        address indexed approved,
        uint indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    // Mapping from token ID to owner address
    mapping(uint => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint) private _balances;

    // Mapping from token ID to approved address
    mapping(uint => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor (string memory _name, string memory _symbol){
        name = _name;
        symbol = _symbol;
    }

    function supportsInterface(bytes4 interfaceId)
        external
        pure
        override
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    function balanceOf(address owner) external view override returns (uint) {
        require(owner != address(0), "owner = zero address");
        return _balances[owner];
    }

    function ownerOf(uint tokenId) public view override returns (address owner) {
        owner = _owners[tokenId];
        require(owner != address(0), "token doesn't exist");
    }

    function isApprovedForAll(address owner, address operator)
        external
        view
        override
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    function setApprovalForAll(address operator, bool approved) external override {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function getApproved(uint tokenId) external view override returns (address) {
        require(_owners[tokenId] != address(0), "token doesn't exist");
        return _tokenApprovals[tokenId];
    }

    function _approve(
        address owner,
        address to,
        uint tokenId
    ) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function approve(address to, uint tokenId) external override {
        address owner = _owners[tokenId];
        require(
            msg.sender == owner || _operatorApprovals[owner][msg.sender],
            "not owner nor approved for all"
        );
        _approve(owner, to, tokenId);
    }

    function _isApprovedOrOwner(
        address owner,
        address spender,
        uint tokenId
    ) private view returns (bool) {
        return (spender == owner ||
            _tokenApprovals[tokenId] == spender ||
            _operatorApprovals[owner][spender]);
    }

    function _transfer(
        address owner,
        address from,
        address to,
        uint tokenId
    ) private {
        require(from == owner, "not owner");
        require(to != address(0), "transfer to the zero address");

        _approve(owner, address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function transferFrom(
        address from,
        address to,
        uint tokenId
    ) external override {
        address owner = ownerOf(tokenId);
        require(
            _isApprovedOrOwner(owner, msg.sender, tokenId),
            "not owner nor approved"
        );
        _transfer(owner, from, to, tokenId);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            return
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    tokenId,
                    _data
                ) == IERC721Receiver.onERC721Received.selector;
        } else {
            return true;
        }
    }

    function _safeTransfer(
        address owner,
        address from,
        address to,
        uint tokenId,
        bytes memory _data
    ) private {
        _transfer(owner, from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "not ERC721Receiver");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes memory _data
    ) public override {
        address owner = ownerOf(tokenId);
        require(
            _isApprovedOrOwner(owner, msg.sender, tokenId),
            "not owner nor approved"
        );
        _safeTransfer(owner, from, to, tokenId, _data);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint tokenId
    ) external override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function mint(address to) external onlyMinter{
        
        require(to != address(0), "mint to zero address");

        _balances[to] += 1;
        _owners[nftTokenId] = to;

        emit Transfer(address(0), to, nftTokenId);

        totalSupply ++;
        nftTokenId ++;
    }

    function burn(uint tokenId) public {

        address owner = ownerOf(tokenId);
        require(
            _isApprovedOrOwner(owner, msg.sender, tokenId),
            "not owner nor approved"
        );

        _approve(owner, address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        totalSupply --;

        emit Transfer(owner, address(0), tokenId);
    }
}

contract DeeMysteryBox is ERC721 {

    address public deesseNftMinter;

    mapping (uint=>uint) public nftPool;

    uint[] public validNftKey;

    uint public boxAmount;

    constructor(address _deesseNftMinter) ERC721("ChainboostDeesseCard", "MysteryBox") {
        deesseNftMinter = _deesseNftMinter;
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    //Open Box
    event OpenBox (address _from, uint _character , uint _level);

    /*
    first 
        [34,2,4,8,9,10,13,14,15,19]
        [3,5,7,9]
        [216,300,72,12]

        for example ： 13403=>216 ,means the amout of nft for the sequence 01 and 03 level is 4
    */ 
    function addMysteryBoxs(uint[] memory _characterIds , uint[] memory _levels, uint[] memory _amounts) public onlyOwner{ 

        for(uint j=0;j<_characterIds.length;j++){

            uint ch = _characterIds[j];
            for(uint i=0;i<_levels.length;i++){

                uint level = _levels[i];
                uint key = 10000 + ch * 100 + level;
                uint amount = _amounts[i];

                uint existAmount = nftPool[key];
                if(existAmount == 0){
                    validNftKey.push(key);
                }

                nftPool[key] = existAmount + amount;

                boxAmount += amount;
            }
        }
    }



    function generalRdBoxToken() private returns(uint,uint){
      
        // check nft stock
        require(validNftKey.length > 0);

        uint totalAmount = 0;
        for(uint i=0;i<validNftKey.length;i++){
            uint existAmount = nftPool[validNftKey[i]];
            totalAmount += existAmount;
        }
      
        uint256 rdIdx = uint256(keccak256(abi.encodePacked(block.timestamp,msg.sender,boxAmount * 777)));
        rdIdx%=totalAmount;

        uint key = 0;
        uint cAmount = 0;
        for(uint i=0;i<validNftKey.length;i++){
            cAmount += nftPool[validNftKey[i]];
            if(cAmount > rdIdx){
                key = validNftKey[i];
                break;
            }
        }

        uint ch = key / 100 % 100;
        uint level = key % 100;

        //update pool info
        nftPool[key] = nftPool[key] - 1;
        if(nftPool[key] == 0){ 
            //update vliad key arr
            for(uint i=0;i<validNftKey.length;i++){
                if(validNftKey[i] == key){
                    validNftKey[i] = validNftKey[validNftKey.length - 1];
                    break;
                }
            }
            validNftKey.pop();
        }

        boxAmount --;

        return (ch,level);
    }

    /*
    * open box
    */
    function openBox(uint256 tokenId) public returns (uint256){

        require(ownerOf(tokenId) == msg.sender,"not owner");

        uint ch;
        uint level;

        (ch,level) = generalRdBoxToken();

        //生成
        DeeNFTMinter(deesseNftMinter).mintNFT(ch,level,1,msg.sender);

        burn(tokenId);

        emit OpenBox(msg.sender,ch,level);

        return  10000 + ch * 100 + level;
    }

    /*
    * open boxs
    */
    function openBoxs(uint256[] memory tokenIds) public {

        for(uint i=0;i<tokenIds.length;i++){
            openBox(tokenIds[i]);
        }
    }
}