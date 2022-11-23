/**
 *Submitted for verification at BscScan.com on 2022-11-23
*/

// SPDX-License-Identifier: Unlicensed
// File @openzeppelin/contracts/introspection/[email protected]

pragma solidity ^0.8.10;



/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// File @openzeppelin/contracts/token/ERC721/[email protected]





/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transfered from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
      * @dev Safely transfers `tokenId` token from `from` to `to`.
      *
      * Requirements:
      *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
      * - `tokenId` token must exist and be owned by `from`.
      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
      *
      * Emits a {Transfer} event.
      */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}


// File @openzeppelin/contracts/token/ERC721/[email protected]





/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
    external returns (bytes4);
}


// File @openzeppelin/contracts/GSN/[email protected]





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

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File @openzeppelin/contracts/access/[email protected]





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
    constructor () {
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

// File contracts/staking.sol

interface DOGToken{
    function getlevel(uint256 id) external view returns(uint256);

     function breed(address _receiver, uint256 _type) external payable ;
}

interface IBEP20 {
	function totalSupply() external view returns(uint256);

	function decimals() external view returns(uint8);

	function symbol() external view returns(string memory);

	function name() external view returns(string memory);

	function getOwner() external view returns(address);

	function balanceOf(address account) external view returns(uint256);

	function transfer(address recipient, uint256 amount) external returns(bool);

	function allowance(address _owner, address spender) external view returns(uint256);

	function approve(address spender, uint256 amount) external returns(bool);

	function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);

	event Transfer(address indexed from, address indexed to, uint256 value);

	event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract MDOGBreedPool is Ownable ,IERC721Receiver{

    struct DepositDoginfo{
        uint256 ID;
        uint256 dogtype;
        uint256 fristDog;
        uint256 secondDog;
        uint256 breedTime;
        uint256 depositedtime;
    }

    mapping(address=>uint256) depositedid;
    mapping(address=>uint256) depositcount;
    mapping(address=>DepositDoginfo[]) dogpairarr;
    mapping(address=>mapping(uint256=>DepositDoginfo)) deposited_doginfo;
    mapping(address => bool) private has_deposited;
    mapping(address => uint256) private depositdogtype;

    uint256[] private MAX_AMOUNT_BY_TYPE = [180,360,180,400,600,
                                            280,500,600,300,500,
                                            500,120,300,500,500,
                                            600,400,500,400,600,
                                            500,400,300,180,300];

    uint256[] private BREEDTIME_BY_TYPE = [ 30 days,25 days,35 days,25 days,25 days,30 days,
                                            25 days,25 days,25 days,25 days,30 days,60 days,
                                            25 days,25 days,25 days,35 days,25 days,25 days,
                                            25 days,25 days,30 days,30 days,25 days,30 days,60 days];

    uint256[] private BREEDTAX_BY_TYPE = [  6000000 ether,5000000 ether,10000000 ether,5000000 ether,5000000 ether,
                                            5000000 ether,5000000 ether,5000000 ether,5000000 ether,5000000 ether,
                                            5000000 ether,10000000 ether,5000000 ether,5000000 ether,5000000 ether,
                                            5000000 ether,5000000 ether,5000000 ether,6000000 ether,5000000 ether,
                                            6000000 ether,7000000 ether,6000000 ether,7000000 ether,5000000 ether];

    uint256[] private BREEDBOOST_BY_TYPE = [1000000 ether,500000 ether,1000000 ether,1000000 ether,500000 ether,
                                            500000 ether,500000 ether,500000 ether,500000 ether,500000 ether,
                                            500000 ether,3000000 ether,500000 ether,500000 ether,500000 ether,
                                            500000 ether,500000 ether,500000 ether,500000 ether,500000 ether,
                                            500000 ether,500000 ether,500000 ether,500000 ether,500000 ether];

   uint256[] private START_ID_BY_TYPE = [   0,180,540,720,1120,
                                            1720,2000,2500,3100,3400,
                                            3900,4400,4520,4820,5320,
                                            5820,6420,6820,7320,7720,
                                            8320,8820,9220,9520,9700 ];

    address private MdogNFTcontract = 0x287F88576816C8faBC463Bdd1F469503A08B611A;
    address private MdogTokenAddress = 0x9f606eBD5587f9829b942d71D44ca39d44F734aE;
    bytes data1;

    function onERC721Received(
        address operator, 
        address from, 
        uint256 tokenId, 
        bytes calldata data) external override returns (bytes4) {   
            require(operator!=from,'haha');
            require(tokenId>0,"good");
            data1 = data;
        return IERC721Receiver.onERC721Received.selector;
    } 

    constructor() {}
    

    function deposit(uint256 tokenId1, uint256 tokenId2) external {
        require (msg.sender == IERC721(MdogNFTcontract).ownerOf(tokenId1), 'Sender must be owner');
        require (msg.sender == IERC721(MdogNFTcontract).ownerOf(tokenId2), 'Sender must be owner');
        uint256 firstdogtype;
        uint256 seconddogtype;
        for(uint256 i = 0 ;i < START_ID_BY_TYPE.length; i++){
            if(tokenId1 >= START_ID_BY_TYPE[i] && tokenId1 < START_ID_BY_TYPE[i+1]){firstdogtype = i;}
            if(tokenId2 >= START_ID_BY_TYPE[i] && tokenId2 < START_ID_BY_TYPE[i+1]){seconddogtype = i;}
        }

        require(firstdogtype == seconddogtype ,"Must select same type of dogs");
        require(IBEP20(MdogTokenAddress).balanceOf(msg.sender) >= BREEDTAX_BY_TYPE[firstdogtype], "Invalid Amount");
        IERC721(MdogNFTcontract).transferFrom(msg.sender, address(this), tokenId1);
        IERC721(MdogNFTcontract).transferFrom(msg.sender, address(this), tokenId2);

        DepositDoginfo memory dog;
        depositedid[msg.sender] += 1; 
        depositcount[msg.sender] += 1;
        dog.ID = depositedid[msg.sender];
        dog.fristDog = tokenId1;
        dog.secondDog = tokenId2;
        dog.dogtype = firstdogtype;

        uint256 firstnftlevel = DOGToken(MdogNFTcontract).getlevel(tokenId1);
        uint256 secondnftlevel = DOGToken(MdogNFTcontract).getlevel(tokenId2);
        dog.breedTime = BREEDTIME_BY_TYPE[firstdogtype] - (firstnftlevel + secondnftlevel) * 1 days;    
        dog.depositedtime = block.timestamp;
        deposited_doginfo[msg.sender][ depositedid[msg.sender]] = dog;
        dogpairarr[msg.sender].push(dog);
        IBEP20(MdogTokenAddress).transferFrom(address(this), 0x000000000000000000000000000000000000dEaD, BREEDTAX_BY_TYPE[firstdogtype]);
   }

   function getdogs()external view returns(DepositDoginfo[] memory){
       return dogpairarr[msg.sender];
   }

    function getremaintime(uint256 pairid) view public returns(uint256) {
        require(depositcount[msg.sender] > 0 , 'Diposit No tokens for breed');
        uint256  breedtime = deposited_doginfo[msg.sender][pairid].breedTime;
        uint256 depositime = deposited_doginfo[msg.sender][pairid].depositedtime;
        uint256 spenttime = block.timestamp - depositime;
        if(breedtime < spenttime) return 0;
        else return breedtime - spenttime;
    }

    function getbreedtime( uint256 pairid )view public returns(uint256){
        require(depositcount[msg.sender] > 0, 'Diposit No tokens for breed');
        return  deposited_doginfo[msg.sender][pairid].breedTime;
    }

    function boostbreed(uint256 time, uint256 pairid) external {
        require(depositcount[msg.sender] > 0, 'No tokens to boost');
        require( deposited_doginfo[msg.sender][pairid].breedTime >= time * 1 days,"Invalid time");  
        require(IBEP20(MdogTokenAddress).balanceOf(msg.sender) >= BREEDBOOST_BY_TYPE[depositdogtype[msg.sender]] * time,"Invalid Amount");
        IBEP20(MdogTokenAddress).transferFrom(msg.sender, 0x000000000000000000000000000000000000dEaD,  BREEDBOOST_BY_TYPE[depositdogtype[msg.sender]] * time);
        deposited_doginfo[msg.sender][pairid].breedTime = deposited_doginfo[msg.sender][pairid].breedTime - time * 1 days;
    }

    function getnewnft(uint256 pairid) external{
        require(depositcount[msg.sender] > 0, 'No tokens to breed');
        require(block.timestamp  - deposited_doginfo[msg.sender][pairid].depositedtime >deposited_doginfo[msg.sender][pairid].breedTime,"Wait more for breed");
        IERC721(MdogNFTcontract).transferFrom(address(this), msg.sender, deposited_doginfo[msg.sender][pairid].fristDog);
        IERC721(MdogNFTcontract).transferFrom(address(this), msg.sender, deposited_doginfo[msg.sender][pairid].secondDog);
        depositcount[msg.sender] -= 1;
        uint id;
        for(uint i =0;i<dogpairarr[msg.sender].length;i++)
        {
            if(dogpairarr[msg.sender][i].ID==pairid){
                id=i;
            }
        }
        while (id<dogpairarr[msg.sender].length-1) {
            dogpairarr[msg.sender][id] = dogpairarr[msg.sender][id+1];
            id++;
        }
        dogpairarr[msg.sender].pop();
        DOGToken(MdogNFTcontract).breed(msg.sender, deposited_doginfo[msg.sender][pairid].dogtype);
    }


    function getdipositid() view external returns(DepositDoginfo[] memory){
        return dogpairarr[msg.sender];
    }

    function setnftcontract(address newadd) public onlyOwner{
        MdogNFTcontract = newadd;
    }

    function setmdogcontract(address newadd) public onlyOwner{
        MdogTokenAddress = newadd;
    }
}