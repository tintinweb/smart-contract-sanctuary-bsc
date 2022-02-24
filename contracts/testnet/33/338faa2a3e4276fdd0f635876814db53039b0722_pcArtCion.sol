/**
 *Submitted for verification at BscScan.com on 2022-02-24
*/

// SPDX-License-Identifier: GPL-3.0
//改一下 每个方法名传入的参数名称
pragma solidity ^0.6.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

abstract contract ERC165 is IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {

        _registerInterface(_INTERFACE_ID_ERC165);
    }

 
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

   
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

interface IERC721  {
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
        byte  data
    ) external;
}
//uint对应地址地址无法对NFT艺术品进行解释将uint=>struct(结构体)
contract pcArtCion is ERC165,IERC721{
    address public issuer;//资产发行人
    
    
    //地址所拥有的NFT数量
   mapping (address=>uint256) balances;
   uint256 public totalSupply;//toekn数量
   string public name="wyl-5G";
   string public symbol="wangyunlong";
   struct assct{
       uint256 _tokenId;
       address owner;
       address approver;
       byte  data;
       uint256 timestamp;
   }
   mapping(bytes4=>bool) public  _interfaceID;
   //每个nft对应的地址
   mapping(uint256=>assct) tokens;
   //A=>(B=>U) 将B地址里的U授权给A使用
  // mapping(address=>mapping(address=>uint256))approved;
  // mapping(uint256=>address) apsyproves;//nft授权给那个地址转移到结构体了

   mapping(address=>mapping(address=>bool)) isAllpproved;//查看全部授权情况


     event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

   modifier onlyfun(){
       require(msg.sender==issuer);
       _;
   }

  function setAsset(address owner,byte date)public{
    require(owner!=address(0));   
    totalSupply++;  
  //  uint256 tokenId=uint256(keccak256(abi.encodePacked(number,msg.sender,now,date)));
    //生成了一个新的tokenId但是需要检测是否已经存在过了 ,当tokens[tokenId]._tokenId==0说明之前未被赋值过 
    //while(tokens[tokenId]._tokenId==0)
    //{
     //   tokenId=uint256(keccak256(abi.encodePacked(number,msg.sender,now)));
   // }
    assct memory Assct=assct(totalSupply,owner,address(0),date,now);
    tokens[totalSupply]=Assct;
    balances[owner]+=1;
     emit Transfer(address(0),owner,totalSupply);
  }
  //查询_owner所拥有的具体NFT数量
 function balanceOf(address owner) external override view returns (uint256 balance){
      return balances[owner];
  } 
  //查询NFT所属地址
  function ownerOf(uint256 tokenId) external override view returns (address owner){
      return tokens[tokenId].owner;
  }

  //转账操作
   function transferFrom( address from,address to,uint256 tokenId) external override{
     
      require(tokens[tokenId].owner==from);//第一步确认_tokens是否属于_from
      ////第二步 _from_from的_tokens是否授权给msg.sender||_from是否全部授权给msg.sender
      require(msg.sender==from||tokens[tokenId].approver==msg.sender||isAllpproved[from][msg.sender]);
      require(from!=address(0)&&to!=address(0)&&tokenId!=0);
      tokens[tokenId].owner=to;
      tokens[tokenId].approver=address(0);
      tokens[tokenId].timestamp=now;
      tokens[tokenId].data=byte("");
      balances[to]+=1;
      balances[from]+=1;
      
     emit Transfer(from,to,tokenId);
     
  }
  //安全的转账方式检测   _to为非合约地址
   function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    )  override external{
      require(tokens[tokenId].owner==from);//第一步确认_tokens是否属于_from
      ////第二步 _from_from的_tokens是否授权给msg.sender||_from是否全部授权给msg.sender
      require(msg.sender==from||tokens[tokenId].approver==msg.sender||isAllpproved[from][msg.sender]);
      require(addrCheck(to));//检测转过去的地址为普通地址
      require(from!=address(0)&&to!=address(0)&&tokenId!=0);
      tokens[tokenId].owner=to;
      tokens[tokenId].approver=address(0);
      tokens[tokenId].timestamp=now;
      tokens[tokenId].data=byte("");
      balances[to]+=1;
      balances[from]+=1;
     emit Transfer(from,to,tokenId);

  }
  //带转账信息的安全转账方式
    function safeTransferFrom(address from,address to,uint256 tokenId,byte data) override external{
    require(tokens[tokenId].owner==from);//第一步确认_tokens是否属于_from
      ////第二步 _from_from的_tokens是否授权给msg.sender||_from是否全部授权给msg.sender
      require(msg.sender==from||tokens[tokenId].approver==msg.sender||isAllpproved[from][msg.sender]);
      require(addrCheck(to));//检测转过去的地址为普通地址
      require(from!=address(0)&&to!=address(0)&&tokenId!=0);
      tokens[tokenId].data=data;
      tokens[tokenId].owner=to;
      tokens[tokenId].approver=address(0);
      tokens[tokenId].timestamp=now;
      balances[to]+=1;
      balances[from]+=1;
      emit Transfer(from,to,tokenId);
  }



 //msg.sender将自身拥有的_tokenId授权给_to
 function approve(address to, uint256 tokenId)override  external{
      //approved[_to][msg.sender]=_tokenId;
      require(tokens[tokenId].owner==msg.sender);
      require(tokenId!=0);
      tokens[tokenId].approver=to;
        emit Approval(msg.sender, to, tokenId);
  }
  //查询_to授权的address是那个
function getApproved(uint256 _tokenId) external override view returns (address){
      require(_tokenId!=0);
      return  tokens[_tokenId].approver;
  }
  //全部授权操作
   function setApprovalForAll(address operator, bool _approved) override external{
  //将msg.sender里面的NFT授权给_operator
  require(operator!=address(0));
  require(isAllpproved[msg.sender][operator]!=_approved);
  isAllpproved[msg.sender][operator]=_approved;
  emit ApprovalForAll(msg.sender,operator,_approved);
  }
  //查询全部授权
  function isApprovedForAll(address _formoperator,address _tooperator)external override view returns(bool){
    //查询_formoperator是否全部授权给_tooperator了
       require(_formoperator!=address(0)||_tooperator!=(address(0)));
       return isAllpproved[_formoperator][_tooperator];
  }


//检测_addr是否是合约地址
  function addrCheck(address _addr)private view returns(bool){
     uint256 size;
     //检测_addr字节码是否为空为空返回true
    assembly { size := extcodesize(_addr) 
    }
    require(size==0);
    return true;
  }







}