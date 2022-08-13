/**
 *Submitted for verification at BscScan.com on 2022-08-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-27
*/
// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;






interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}   

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}





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


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}


contract NftStaking is  Ownable {
  
  IERC721Enumerable public nft;
  uint256 public depositFee;
  struct NFTInfo {
        address owner;
        uint256 stakingTime;
        uint256 tokenId;
        uint256 weightage;
        bool isStaked;
    }
    uint256[] public listNfts=new uint256[](0);
     mapping(uint256 => NFTInfo)  public NftInfos;
  bool public paused = false;
  IBEP20 public currencyToken;
  uint256 public rewardPerDay;
  constructor(address _addr,address _nftAddress,uint256 _rewardPerDay) {
    currencyToken= IBEP20(_addr);
    nft=IERC721Enumerable(_nftAddress);
    rewardPerDay=_rewardPerDay;
    depositFee=10000000000000000;
  }



    function stake(uint256 _tokenId) public payable {
    require(msg.value>=depositFee);
    require(msg.sender==nft.ownerOf(_tokenId));
    if(!isInList(_tokenId))
    {
        listNfts.push(_tokenId);
    }
    
     nft.transferFrom(address(msg.sender),address(this),_tokenId);
    
    NftInfos[_tokenId]=NFTInfo({
        owner:address(msg.sender),
        tokenId:_tokenId,
        stakingTime:block.timestamp,
        weightage:1,
        isStaked:true
    });
  }
    function unstake(uint256 _tokenId) public {
    require(!paused);
    address owneraddress=NftInfos[_tokenId].owner;
    require(address(msg.sender)==owneraddress);
    
    harvest(_tokenId);

    nft.transferFrom(address(this),owneraddress,_tokenId);
    NftInfos[_tokenId]=NFTInfo({
        owner:address(msg.sender),
        tokenId:_tokenId,
        stakingTime:99999999999999999999999999999,
        weightage:0,
        isStaked:false
    });
  }

  function harvest(uint256 _tokenId) public {
    require(!paused);
    require(NftInfos[_tokenId].isStaked);
    address owneraddress=NftInfos[_tokenId].owner;
    require(address(msg.sender)==owneraddress);
    uint256 stakingTime=NftInfos[_tokenId].stakingTime;
    uint256 weightage=NftInfos[_tokenId].weightage;
    uint256 diff=block.timestamp-stakingTime;
    uint256 share=rewardPerDay/86400;
    uint256 amount= share* diff*weightage;
    currencyToken.transfer(owneraddress,amount);
    
    NftInfos[_tokenId]=NFTInfo({
        owner:address(msg.sender),
        tokenId:_tokenId,
        stakingTime:block.timestamp,
        weightage:1,
        isStaked:true
    });
  }

   function getList(address _addr) public view returns(NFTInfo[] memory)
    {
        
        uint stakedLen=0;
        for(uint i=0;i<listNfts.length;i++)
        {
            if(NftInfos[listNfts[i]].isStaked&&NftInfos[listNfts[i]].owner==_addr)
            stakedLen++;
        }
        NFTInfo[] memory arr=new NFTInfo[](stakedLen);
        uint len=0;
        for(uint i=0;i<listNfts.length;i++)
        {
           if(NftInfos[listNfts[i]].isStaked&&NftInfos[listNfts[i]].owner==_addr)
           {
                arr[len]=NFTInfo({
        weightage:NftInfos[listNfts[i]].weightage,
        isStaked:NftInfos[listNfts[i]].isStaked,
        owner:NftInfos[listNfts[i]].owner,
        tokenId:NftInfos[listNfts[i]].tokenId,
        stakingTime:NftInfos[listNfts[i]].stakingTime
    });
    len++;
           }
        }
        return arr;
    }

    
 function isInList(uint256 _addr) public view returns (bool) {
        for (uint i=0; i < listNfts.length; i++) {
        if(listNfts[i]==_addr)
            return true;
        
    }
    return false;
  }

  function pause(bool _state) public onlyOwner {
    paused = _state;
  }
  function setDepositFee(uint256 _fee) public onlyOwner {
    depositFee = _fee;
  }
  function updateRewardPerDay(uint256 _amount) public onlyOwner {
    rewardPerDay = _amount;
  }


function withdrawRemainingToken(IBEP20 token,address _recipient) public onlyOwner {
    
    uint256 balance=token.balanceOf(address(this));
    token.transfer(_recipient , balance);
  }


  function withdraw() public payable onlyOwner {
    (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(success);
  }
}

contract NftBook is Ownable {
    mapping(address => mapping(uint256=>address)) public deployedPools;
    mapping(address => uint256) public counter;
    uint256 public creationFee = 1 ether;
    event PoolRegistered(address _nftAddress,
        address _earningTokenAddress,
        uint256 _rewardPerDay,string _tokenlogo,string _nftlogo,string _gatewayurl);

    function setCreationFee(uint256 _fee) public onlyOwner{
        creationFee=_fee;
    }

    function withdraw() public payable onlyOwner {
    (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(success);
  }
  function withdrawRemainingToken(IBEP20 token,address _recipient) public onlyOwner {
    
    uint256 balance=token.balanceOf(address(this));
    token.transfer(_recipient , balance);
  }

    function deployNewPool(
        address _nftAddress,
        address _earningTokenAddress,
        uint256 _rewardPerDay,
        string memory _tokenlogo,
        string memory _nftlogo,string memory _gatewayurl
    ) external payable  {
        require(msg.value>=creationFee);
        NftStaking newpool=new NftStaking(_earningTokenAddress,_nftAddress,_rewardPerDay);
        deployedPools[msg.sender][counter[msg.sender]]=address(newpool);
        counter[msg.sender]=counter[msg.sender]+1;
        emit PoolRegistered(_nftAddress,_earningTokenAddress,_rewardPerDay,_tokenlogo,_nftlogo,_gatewayurl);

        
    }

    function addDeployedPool(address _owner,address _poolAddress) public onlyOwner
    {
        
        deployedPools[_owner][counter[_owner]]=_poolAddress;
        counter[_owner]=counter[_owner]+1;
    }
    function updateDeployedPool(address _owner,uint256 _counter,address _poolAddress) public onlyOwner
    {
        
        deployedPools[_owner][_counter]=_poolAddress;
    }
}