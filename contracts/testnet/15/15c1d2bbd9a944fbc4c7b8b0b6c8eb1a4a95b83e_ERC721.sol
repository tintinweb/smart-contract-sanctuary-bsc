pragma solidity ^0.6.0;
 
import "./IERC721.sol";
import "./ERC165.sol";
import "./SafeMath.sol";
 
interface IERC721TokenReceiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4);
}
 
contract ERC721 is ERC165, IERC721 {
    address public owner;
    //状态变量 - 记录owner拥有多少个token
    mapping(address => uint256) private _ownerTokensCount;

    mapping(uint256 => string) private _tokenValues;
 
    //状态变量 - 记录tokenId的所有者
    mapping(uint256 => address) private _tokenOwner;
 
    //状态变量 - 记录tokenId授权给外部账户
    mapping(uint256 => address) private _tokenApproval;
 
    //状态变量 - 记录用户全部授权
    mapping(address => mapping(address => bool)) private _operatorApprovals;
 
    //使用库作用于uint256类型
    using SafeMath for uint256;
 
    //常量 - ERC721接囗ID
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
 
    //常量 - IERC721TokenReceiver接囗ID
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;
 
    //构造函数 - 初始化ERC721接囗已实现
    constructor() public {
        registerInterface(_INTERFACE_ID_ERC721);
         owner = msg.sender;
    }
 
    modifier ownerIsNotZeroAddress(address _owner) {
        require(address(0) != _owner, "addr not zero");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner,"send is not owner");
        _;
    }
 
    /// 获取所有者拥有多少个Token
    function balanceOf(address _owner) ownerIsNotZeroAddress(_owner) public override view returns (uint256) {
        return _ownerTokensCount[_owner];
    }
 
    /// 获取tokenId的所有者
    function ownerOf(uint256 _tokenId) external override view returns (address) {
        return _ownerOf(_tokenId);
    }
 
    function _ownerOf(uint256 _tokenId) internal view returns (address) {
        //查询出tokenId的所有者
        address _owner = _tokenOwner[_tokenId];
        //判断所有者是否为零地址
        require(address(0) != _owner, "addr not zero");
 
        return _owner;
    }
 
    //公用内部函数 - NFT转移，将tokenId由所有者_from转给_to
    function _transferFrom(address _from, address _to, uint256 _tokenId) internal virtual {    
        //判断tokenId的当前所有者是否为_from
        require(_ownerOf(_tokenId) == _from, "not transfer token");
        //判断接收者地址为不零地址
        require(address(0) != _to, "receive addr not zero");  
        //判断用户是否有权转移token
        require(_isApprovedOrOwner(msg.sender, _tokenId), "not transfer token");

        _beforeTokenTransfer(address(0), _to, _tokenId);
 
        //清除tokenId的授权者
        _approve(address(0), _tokenId);
 
        //原所有者拥有的token数量减一
        _ownerTokensCount[_from] = _ownerTokensCount[_from].sub(1);
 
        //新接收者拥有的token数量加一
        _ownerTokensCount[_to] = _ownerTokensCount[_to].add(1);
 
        //记录token所有者为新接收者
        _tokenOwner[_tokenId] = _to; 
 
        //调用事件
        emit Transfer(_from, _to, _tokenId);

        _afterTokenTransfer(address(0), _to, _tokenId);
    }
 
    //判断tokenId是否存在，若获取不到用户的所有者，则视为不存在
    function _isExistTokenId(uint256 _tokenId) internal view returns (bool) {
       //查询出tokenId的所有者
        address owner = _tokenOwner[_tokenId];
        if (address(0) != owner) {
            return true;
        }
        return false;
    }
 
    //判断转账方是否有权转出token
    function _isApprovedOrOwner(address _spender, uint256 _tokenId) internal view returns (bool) {
        //判断tokenId的所有者是否存在
        require(_isExistTokenId(_tokenId), "tokenId not exists");
        //查询出tokenId的所有者
        address _owner = _ownerOf(_tokenId);
        //所有者可能是调用合约的地址spender，可能是tokenId被授权的地址spender，还有可能是所有者的token都被授权给地址spender
        return (_owner == _spender || _getApproved(_tokenId) == _spender || _isApprovedForAll(_owner, _spender));
    }
 
    //判断是否为合约地址
    function _isContract(address addr) internal view returns (bool) {
        uint256 _size;
 
        //若为外部账户_size = 0，若为合约账户 _size > 0
        assembly { _size := extcodesize(addr) }
        return _size > 0;
    }
 
    //校验接收地址是否有效
    function _checkOnERC721Received(address _from, address _to, uint256 _tokenId, bytes memory _data) private returns (bool) {
        //判断是否为合约地址，若为外部账户直接返回true，若为合约账户则校验是否实现了ERC721Receiver接囗方法
        if (!_isContract(_to)) { //外部账户
            return true;
        }
 
        //合约账户：校验是否实现了IERC721Receiver接囗方法，只有实现了IERC721Receiver接囗，才能接收ERC-721标准的token
        (bool success, bytes memory returndata) = _to.call(abi.encodeWithSelector(
            IERC721TokenReceiver(_to).onERC721Received.selector,
            msg.sender,
            _from,
            _tokenId,
            _data
        ));
 
        //判断返回结果
        if (!success) {
            revert("contract not impl erc721 receive");
        } else {
            bytes4 retval = abi.decode(returndata, (bytes4));
            return (retval == _ERC721_RECEIVED);
        }
    }
 
    // 安全转移token - 公用内部函数
    function _safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) internal virtual {
        _transferFrom(_from, _to, _tokenId);
        require(_checkOnERC721Received(_from, _to, _tokenId, _data), "contract not impl erc721 receive");
    }
 
    /// 安装转移token，包含data
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external override payable {
        _safeTransferFrom(_from, _to, _tokenId, data);
    }
 
    /// 安装转移token
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external override payable {
        _safeTransferFrom(_from, _to, _tokenId, "");
    }
 
    /// 转移token
    function transferFrom(address _from, address _to, uint256 _tokenId) external override payable {
        //转移token
        _transferFrom(_from, _to, _tokenId);
    }
 
    /// 授权token
    function _approve(address _approved, uint256 _tokenId)  internal  {
        require(_approved != msg.sender, "not approva me");
        _tokenApproval[_tokenId] = _approved;
        emit Approval(_tokenOwner[_tokenId],_approved,_tokenId);
    }
 
    /// 授权token
    function approve(address _approved, uint256 _tokenId) ownerIsNotZeroAddress(_approved) external override payable {
        _approve(_approved, _tokenId);
    }
 
    /// 全部授权
    function setApprovalForAll(address _operator, bool _approved) external override {
        require(_operator != msg.sender, "not approva me");
        //修改状态变量 - 全部授权
        _operatorApprovals[msg.sender][_operator] = _approved;
 
        //事件
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }
 
    
    /// 获取tokenId的被授权者
    function _getApproved(uint256 _tokenId) internal view returns (address) {
        //判断tokenId的所有者是否存在
        require(_isExistTokenId(_tokenId), "tokenId not exits");
        return _tokenApproval[_tokenId];
    }

    function getTokenAttr(uint256 tokenId) external view returns(string memory){
        return _tokenValues[tokenId];
    }
 
    /// 获取tokenId的被授权者
    function getApproved(uint256 _tokenId) external override view returns (address) {
        return _getApproved(_tokenId);
    }
 
    /// 是否全部授权，即_owner将自己所有的tokenId全部授权给_operator
    function _isApprovedForAll(address _owner, address _operator) internal view returns (bool) {
        return _operatorApprovals[_owner][_operator];
    }
 
    /// 是否全部授权，即_owner将自己所有的tokenId全部授权给_operator
    function isApprovedForAll(address _owner, address _operator) external override view returns (bool) {
        return _isApprovedForAll(_owner, _operator);
    }
 
    //生成tokenId - 公用函数
    function _mint(address _to, uint256 _tokenId, string memory value) ownerIsNotZeroAddress(_to) internal virtual {
        require(!_isExistTokenId(_tokenId), "token exits");

        _beforeTokenTransfer(address(0), _to, _tokenId);

        //设置token的所有者
        _tokenOwner[_tokenId] = _to;
        _tokenValues[_tokenId] = value;
 
        //所有者拥有的token数量累加
        _ownerTokensCount[_to] = _ownerTokensCount[_to].add(1);
 
        //事件
        emit Transfer(address(0), _to, _tokenId);

        _afterTokenTransfer(address(0), _to, _tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
 
    // 生成tokenId
    function mint(address _to, uint256 _tokenId, string memory value) ownerIsNotZeroAddress(_to) onlyOwner external {
        _mint(_to, _tokenId,value);
    }
    
    // 生成tokenId - （安全）
    function safeMint(address _to, uint256 _tokenId, string memory value,bytes calldata _data) ownerIsNotZeroAddress(_to) external {
        _mint(_to, _tokenId,value);
        require(_checkOnERC721Received(address(0), _to, _tokenId, _data), "contract not impl erc721 receive");
    }
 
}