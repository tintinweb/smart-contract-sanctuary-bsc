/**
 *Submitted for verification at BscScan.com on 2022-02-19
*/

/**
 *Submitted for verification at BscScan.com on 2021-12-10
*/

/**
 *Submitted for verification at BscScan.com on 2021-12-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface BurningMoon is IBEP20{
    function Compound() external;
    function getDividents(address addr) external view returns (uint256);
    function ClaimAnyToken(address token) external payable;
    function ClaimBNB() external;
    function TransferSacrifice(address target, uint256 amount) external;
    function addFunds(bool boost, bool stake)external payable;
}
interface IPancakeRouter01 {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getamountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getamountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getamountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getamountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

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


abstract contract ERC165 is IERC165 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See {IERC165-supportsInterface}.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}
library Strings {
    /**
     * @dev Converts a `uint256` to its ASCII `string` representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

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
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}




interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}



library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

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
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
interface IERC721Enumerable
{

  /**
   * @dev Returns a count of valid NFTs tracked by this contract, where each one of them has an
   * assigned and queryable owner not equal to the zero address.
   * @return Total supply of NFTs.
   */
  function totalSupply()
    external
    view
    returns (uint256);

  /**
   * @dev Returns the token identifier for the `_index`th NFT. Sort order is not specified.
   * @param _index A counter less than `totalSupply()`.
   * @return Token id.
   */
  function tokenByIndex(
    uint256 _index
  )
    external
    view
    returns (uint256);

  /**
   * @dev Returns the token identifier for the `_index`th NFT assigned to `_owner`. Sort order is
   * not specified. It throws if `_index` >= `balanceOf(_owner)` or if `_owner` is the zero address,
   * representing invalid NFTs.
   * @param _owner An address where we are interested in NFTs owned by them.
   * @param _index A counter less than `balanceOf(_owner)`.
   * @return Token id.
   */
  function tokenOfOwnerByIndex(
    address _owner,
    uint256 _index
  )
    external
    view
    returns (uint256);

}
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = msg.sender;
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
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract NFTDeployer is Ownable{
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet RegisteredNFTs;
    address public NFTPrototype;
    constructor(){
    }
    mapping(address=>bool) public isNFT;
    event OnAddNFT(address indexed NFTAddress);
        //TestNet
    address BMaddress=0x1Fd93329706579516e18ef2B51890F7a146B5b14;
    address  PCSaddress=0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    //address public BMaddress=0x97c6825e6911578A515B11e25B552Ecd5fE58dbA;
    //address public PCSaddress=0x10ED43C718714eb63d5aA57B78B54704E256024E;
    function getNFT(uint ID) external view returns(address){
        return RegisteredNFTs.at(ID);
    }
    function isRegistred(address NFTcontract) external view returns(bool){
        return RegisteredNFTs.contains(NFTcontract);
    }




    BurningMoon public BM=BurningMoon(BMaddress);
    IPancakeRouter02 public PCS=IPancakeRouter02(PCSaddress);
    function SetBM(address token, address router) public onlyOwner{
        BMaddress=token;
        PCSaddress=router;
        BM=BurningMoon(BMaddress);
        PCS=IPancakeRouter02(PCSaddress);
    }

    function DeployNFT(string memory name,string memory symbol) external returns(address NFTContract){
        DividentNFTs NFT=new DividentNFTs(name,symbol);
        NFTContract= address(NFT);
        isNFT[NFTContract]=true;
        NFT.transferOwnership(msg.sender);
    }

    function RegisterNFT() external{
        require(isNFT[msg.sender],"Can only be called from NFT");
        if(RegisteredNFTs.contains(msg.sender))return;
        RegisteredNFTs.add(msg.sender);
        emit OnAddNFT(msg.sender);

    }



}



contract DividentNFTs is ERC165, IERC721, IERC721Metadata ,IERC721Enumerable,Ownable {
    // Token name
    string private _name;
    // Token symbol
    string private _symbol;
    
    string public _baseURI;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    using Strings for uint256;


    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    
    //Mapping of the tokenIDs of an owner
    mapping(address => uint256[]) private _tokenOfOwner;
    
    //Mapping of the shares of each account based on the rarity of the NFTs they hold
    mapping(address => uint256) public shares;
    mapping(address => uint256) private paidOutShares;


    struct NFTData{
        uint amount;
        uint shares;
        string URI;
    }
    address[] NFTHolders;
    uint256[] ownerID;
    uint256[] public NFTs;
    uint maxNFTTypes=100;
    NFTData[] NFTPrototypes;


    
    function OwnerSetValue(uint256 value) external onlyOwner{
        currentValue=value;
    }

    uint256 constant dividentMagnifier=10**32;
    uint256 profitPerShare;
    uint256 public totalShares;

    function getDividents(address account) public view returns (uint256){
        uint256 fullPayout = profitPerShare * shares[account];
        //if excluded from staking or some error return 0
        if(fullPayout<=paidOutShares[account]) return 0;
        return ((fullPayout - paidOutShares[account]) / dividentMagnifier);
    }
    //Set of the token that are curently for sale
    
    address public  TokenAddress;
    IBEP20 private Token;
    IPancakeRouter02 private TokenPCS;


    //Mainnet





    uint LaunchTimestamp=type(uint).max;
    uint WLTime;

    uint256 public MaxNFTCount=0;
    uint256 VarietyCount=0;
    uint256 public currentValue=10**17/2; //0.05BNB per NFT
    uint[] public Minted;




    uint FeeDenominator=10000;
    uint public DirectRewardsFee=3000;
    uint public LongTermRewardsFee=5000;
    uint public DevFee=2000;
    NFTDeployer deployer;

    constructor(string memory Name, string memory Symbol) {
        _name=Name;
        _symbol=Symbol;
        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(type(IERC721).interfaceId);
        _registerInterface(type(IERC721Metadata).interfaceId);
        _registerInterface(type(IERC721Enumerable).interfaceId);
        
        deployer=NFTDeployer(msg.sender);
        TokenPCS=deployer.PCS();

    }
    function OwnerSetTokenRouter(address Router) public onlyOwner{
        TokenPCS=IPancakeRouter02(Router);
    }
    function AddNFTs(uint[] memory amounts, uint[] memory NFTshares, string[] memory URIs) external onlyOwner{
        require(amounts.length==NFTshares.length&&amounts.length==URIs.length);
        for(uint i=0;i<amounts.length;i++){
            AddNFT(amounts[i],NFTshares[i],URIs[i]);
        }
    }

    function SetFees(uint DirectRewards, uint LongTermRewards, uint Dev) public onlyOwner{
        require(DirectRewards+LongTermRewards+Dev==FeeDenominator,"Fees don't add up to denominator");
        require(LongTermRewardsFee>=3000);
        DevFee=Dev;
        DirectRewardsFee=DirectRewards;
        LongTermRewardsFee=LongTermRewards;
    }
    
    function AddNFT(uint amount, uint NFTshares, string memory URI) public onlyOwner{
        require(NFTPrototypes.length<maxNFTTypes);
        require(LaunchTimestamp<block.timestamp);
        MaxNFTCount+=amount;
        VarietyCount+=amount;
        NFTPrototypes.push(NFTData(amount,NFTshares, URI));
        Minted.push(0);
    }
    
    function AddNFTAfterLaunch(uint amount,uint NFTshares, string memory URI) public onlyOwner{
        require(LaunchTimestamp>block.timestamp);
            uint RemainingMinted=MaxNFTCount-NFTHolders.length;
            require(RemainingMinted>=amount);
            if(RemainingMinted==amount){
                amount=VarietyCount*999;//99,9% chance to mint the newly added.
                        //can't be 100% as that would result in divBy0
            }else{
                //adapts the chance to mint the newly added to the remaining NFTs
                amount=(amount*VarietyCount)/(RemainingMinted-amount);
            }
            VarietyCount+=amount;
            NFTPrototypes.push(NFTData(amount,NFTshares, URI));
            Minted.push(0);
    }
    
    function IncreaseNFTCount(uint newMints) public onlyOwner{
        require(block.timestamp>LaunchTimestamp);
        MaxNFTCount+=newMints;
    }


    function ChangeNFT(uint ID,uint amount, uint NFTshares, string memory URI) public onlyOwner{
        require(LaunchTimestamp<block.timestamp);
        NFTData storage data=NFTPrototypes[ID];
        MaxNFTCount-=data.amount;
        VarietyCount-=data.amount;
        data.amount=amount;
        data.shares=NFTshares;
        data.URI=URI;
        MaxNFTCount+=amount;
        VarietyCount+=amount;
    }
    
    function ClearNFTs() external onlyOwner{
        require(LaunchTimestamp==type(uint).max);
        MaxNFTCount=0;
        VarietyCount=0;
        delete NFTPrototypes;
        delete Minted;
        
    }
    function SetLaunchIn(uint TimeToLaunch,uint WLduration, address tokenAddress) public onlyOwner{
        SetLaunch(block.timestamp+TimeToLaunch,WLduration,tokenAddress);
    }
    function SetLaunch(uint Timestamp, uint WLduration, address tokenAddress) public onlyOwner{
        require(LaunchTimestamp<block.timestamp);
        require(Timestamp-block.timestamp<=7 days);
        require(NFTPrototypes.length>0);
        LaunchTimestamp=Timestamp;
        WLTime=WLduration;
        TokenAddress=tokenAddress;
        Token=IBEP20(tokenAddress);
        deployer.RegisterNFT();
    }
    //Changes the BaseURI 
    function OwnerSetBaseURI(string memory newBaseURI) external onlyOwner{
        _baseURI=newBaseURI;
    }
    function OwnerSetURI(string memory newURI, uint ID) external onlyOwner{
        NFTData storage data=NFTPrototypes[ID];
        data.URI=newURI;
    }





    bool TradingHalted;
    uint migrationAirdropCount;
    uint LastMigration;
    //Migrates token to a new address, needs to be called multiple times if there are a lot of holders,
    //returns true if complete and then fails for a day
    function MigrateToken(uint oldTokenAirdropCount, address newToken) public  returns(bool MigrationComplete){
        require(msg.sender==owner()||msg.sender==deployer.owner());
        require(block.timestamp>LastMigration+1 days);
        if(!TradingHalted){
            TradingHalted=true;
            migrationAirdropCount=0;
        }

        for(uint i=0;i<oldTokenAirdropCount&&migrationAirdropCount<holders.length();i++){
            forcedPayout(holders.at(i));
            migrationAirdropCount++;
            if(migrationAirdropCount>=holders.length())
                break;
        }

        if(migrationAirdropCount>=holders.length()){
            TradingHalted=false;
            TokenAddress=newToken;
            Token=IBEP20(newToken);
            LastMigration=block.timestamp;
            return true;
        }
        return false;
    }
    //Resets the payout counter of the account even if payout fails, so migration can happen
    function forcedPayout(address account) private{
        uint256 amount=getDividents(account);
        if(amount==0)return;
        paidOutShares[account]=shares[account]*profitPerShare;
        try Token.transfer(account, amount){}catch{}
    }

    bool _isInFunction;
    modifier isInFunction{
        require(!_isInFunction);
        _isInFunction=true;
        _;
        _isInFunction=false;
    }
    bool _isInPayout;
    modifier isInPayout{
        require(!_isInPayout);
        _isInPayout=true;
        _;
        _isInPayout=false;
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //BM Dividents////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
    bool isPaying;
    uint256 CurrentAirdropID;

    
    function Airdrop(uint256 count) public{
        _distributeToken();
        uint256 holderLength=holders.length();
        if(count>holderLength)count=holderLength;
        if(CurrentAirdropID>=holderLength) CurrentAirdropID=0;
        for(uint i=0;i<count;i++)
        {
           try this.Payout(holders.at(CurrentAirdropID)){}
           catch{}
            CurrentAirdropID++;
            if(CurrentAirdropID>=holderLength)
                CurrentAirdropID=0;  
        }
    }
    uint8 airdropsPerClaim=5;
    bool airdropsEnabled=true;
    function OwnerSetAirdropsPerClaim(uint8 airdrops, bool Enabled) public onlyOwner{
        require(airdrops<=10);
        airdropsPerClaim=airdrops;
        airdropsEnabled=Enabled;
    }
    
    function AccountClaimDividents() external{
        _distributeToken();
        uint256 amount=getDividents(msg.sender);
        require(amount>0,"No payout");
        Payout(msg.sender);
        if(airdropsEnabled) Airdrop(airdropsPerClaim);
        
    }
    
    function Payout(address account) public isInPayout{
        uint256 amount=getDividents(account);
        if(amount==0)return;
        paidOutShares[account]=shares[account]*profitPerShare;
        Token.transfer(account, amount);
    }
    function _distributeBNB(uint amount) private{
        if(amount>address(this).balance)amount=address(this).balance;
        if(amount<=0) return;
        uint256 BMAmount=amount*LongTermRewardsFee/FeeDenominator;
        uint RewardsAmount=amount*DirectRewardsFee/FeeDenominator;
        _buyAndSacrificeBM(BMAmount);
        _distributeToken(RewardsAmount);

        (bool sent,)=owner().call{value:address(this).balance}("");
        sent=true;
        
    }
    function _buyAndSacrificeBM(uint256 amount)private{
        if(amount==0) return;

        uint SwapBM=SwapForBM(amount);
        if(SwapBM==0) return;
        try deployer.BM().transfer(address(0xdead),SwapBM){}catch{}
    }
    function SwapForBM(uint BNBAmount) private returns(uint256){
        address[] memory path = new address[](2);
        BurningMoon BM=deployer.BM();
        IPancakeRouter02 BMPCS=deployer.PCS();
        path[1] = address(BM);
        path[0] = BMPCS.WETH();
        uint256 initialBalance=BM.balanceOf(address(this));

        BMPCS.swapExactETHForTokensSupportingFeeOnTransferTokens{value:BNBAmount}(
            0,
            path,
            address(this),
            block.timestamp);
        return BM.balanceOf(address(this))-initialBalance;
    }
    function SwapForToken(uint BNBAmount) private returns(uint256){
        address[] memory path = new address[](2);
        path[1] = address(Token);
        path[0] = TokenPCS.WETH();
        uint256 initialBalance=Token.balanceOf(address(this));

        TokenPCS.swapExactETHForTokensSupportingFeeOnTransferTokens{value:BNBAmount}(
            0,
            path,
            address(this),
            block.timestamp);
        return Token.balanceOf(address(this))-initialBalance;
    }
    
    function _distributeToken() private{
        //If total shares is 0, ignore compound
        if(totalShares==0) return;
        BurningMoon BM=deployer.BM();
        if(BM.getDividents(address(this))<=0) return;

        BM.ClaimBNB();
        uint newToken=SwapForToken(address(this).balance);

        profitPerShare += ((newToken * dividentMagnifier) / totalShares);
    }
    function  DistributeBNBAsToken() public payable isInFunction{
        _distributeToken(msg.value);
    }
    function DistributeToken(uint amount) public  isInFunction{
        uint oldBalance=Token.balanceOf(address(this));
        Token.transferFrom(msg.sender,address(this),amount);
        uint newBalance=Token.balanceOf(address(this))-oldBalance;
        profitPerShare += ((newBalance * dividentMagnifier) / totalShares);
    }
    function _distributeToken(uint BNBAmount) private{
        //If total shares is 0, ignore compound
        if(totalShares==0) return;   
        uint newToken=SwapForToken(BNBAmount);

        profitPerShare += ((newToken * dividentMagnifier) / totalShares);
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //NFTPresale//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
 

    mapping(address=>bool) Whitelist;

    function OwnerSetWhitelist(address[] memory WL,bool add) external onlyOwner{
        for(uint i=0;i<WL.length;i++){
            Whitelist[WL[i]]=add;
        }
    }


    event BatchMint(uint Count, uint StartIndex, uint[] PrototypeIDs, address to);
    function PresalePurchase() public payable isInFunction{
        require(msg.sender==tx.origin);
        require(block.timestamp>LaunchTimestamp);
        uint256 presalePurchases=msg.value/currentValue;
        require(presalePurchases>0);
        if(block.timestamp<LaunchTimestamp+WLTime){
            require(Whitelist[msg.sender]);
            require(balanceOf(msg.sender)+presalePurchases<=5);
        }
        require(NFTHolders.length+presalePurchases<=MaxNFTCount);
        uint[] memory MintedIDs=new uint[](presalePurchases);
        uint seed= address(TokenPCS.WETH()).balance+block.timestamp+block.difficulty+block.gaslimit; 
        for(uint i=0;i<presalePurchases;i++){
            MintedIDs[i]=_mint(msg.sender,seed+i);
        }
        uint256 remainder=msg.value%presalePurchases;
        if(remainder>0){
            (bool sent,)=msg.sender.call{value:remainder}("");
            require(sent );
        }
        _distributeBNB(msg.value-remainder);
        if(presalePurchases>1)
            emit BatchMint(presalePurchases,NFTs.length-presalePurchases,MintedIDs,msg.sender);
            
        if(airdropsEnabled) Airdrop(airdropsPerClaim);
    }
    function AddDTToWL() external onlyOwner{
        address DiamondTicket=0x9FED68Db3e56164fE7842F7a387B881867eee11C;
        uint supply=IERC721Enumerable(DiamondTicket).totalSupply();
        for(uint i=0;i<supply;i++){
            Whitelist[IERC721(DiamondTicket).ownerOf(i)]=true;
        }
    }




    receive() external payable {
        if(msg.sender==address(deployer.PCS())||msg.sender==address(deployer.BM()))
            return;
        PresalePurchase();
    }

    function _prng(uint256 modulo,uint256 seed) private pure returns(uint256 randomResult) {        
        randomResult = uint256(keccak256(abi.encodePacked(seed))) % modulo; 
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Public View//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////     
    function getSharesOfNFTType(uint256 ID) public view returns(uint256){
        return NFTPrototypes[ID].shares;
    }
    function getSharesOfNFT(uint256 ID) public view returns(uint256){
        uint Type=NFTs[ID];
        return getSharesOfNFTType(Type);

    }
    function getNFTInfo(uint256 ID) public view returns(uint NFTshares,uint amount, string memory uri_, address holder_, uint NFTType){
        NFTData memory data=NFTPrototypes[NFTs[ID]];
        return(data.shares,data.amount, data.URI, NFTHolders[ID], NFTs[ID]);
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //ERC721//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function transferFrom(address from, address to, uint256 tokenId) external override{
        require(_isApprovedOrOwner(msg.sender, tokenId));
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external override{
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public override{
        require(_isApprovedOrOwner(msg.sender, tokenId));
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) private {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data));
        if(airdropsEnabled) Airdrop(airdropsPerClaim);
    }
    

    function getCountOfType(uint8 ID, address account) public view returns(uint){
        
        return NFTHold[account][ID];
    }
    function getUniqueCount(address account) public view returns(uint){
        uint[] memory counts=NFTHold[account];
        uint count;
        for(uint i=0;i<counts.length;i++){
            if(counts[i]>0)count++;
        }
        return count; 
    }

    event Mint(address to, uint ID, uint PrototypeID);
    mapping (address=>uint[]) NFTHold;
    function _setNFTHold(address account, uint ID, bool Add) private{
        uint[] memory AccountNFTs=NFTHold[account];
        if(AccountNFTs.length==0) AccountNFTs=new uint[](NFTPrototypes.length);

        if(Add) AccountNFTs[ID]++;
        else AccountNFTs[ID]--;

        NFTHold[account]=AccountNFTs;
    }


    function _mint(address to, uint seed) private returns (uint){
        uint ID;
        uint value=_prng(VarietyCount,seed);
        uint counter;
        for(uint i=0;i<NFTPrototypes.length;i++){
            counter+=NFTPrototypes[i].amount;
            if(value<counter){
                ID=i;
                break;
            } 
        }
        Minted[ID]++;
        uint256 Number=NFTHolders.length;
        NFTs.push(ID);
        ownerID.push(0);
        NFTHolders.push(to);
        _AddNFT(to,Number);
        emit Transfer(address(0),to,Number);
        emit Mint(to, Number, ID);
        return ID;
    }
    
    function _transfer(address from, address to, uint256 tokenId) private {
        require(block.timestamp>=LaunchTimestamp+WLTime);
        require(ownerOf(tokenId) == from);
        require(to != address(0));
        // Clear approvals from the previous owner
        _approve(address(0), tokenId);
        _RemoveNFT(from, tokenId);
        _AddNFT(to,tokenId);
        emit Transfer(from, to, tokenId);
    }
    EnumerableSet.AddressSet holders;
        //Adds NFT during transfer
    function _AddNFT(address account, uint256 ID) private{
        require(!TradingHalted);
        //the holderID of the NFT will be the last index of the ownerIDs
        ownerID[ID]=balanceOf(account);
        //the new NFT will be added as the last NFT of the holder
        _tokenOfOwner[account].push(ID);
        if(_tokenOfOwner[account].length==1)
            holders.add(account);
        NFTHolders[ID]=account;
        //pays out dividents and sets new shares
        if(getDividents(account)>0) Payout(account);
        _setNFTHold(account,NFTs[ID],true);
        uint Shares=getSharesOfNFT(ID);
        totalShares+=Shares;
        shares[account]+=Shares;
        paidOutShares[account]=shares[account]*profitPerShare;
    }
    //Removes NFT during transfer
    function _RemoveNFT(address account, uint256 ID) private{
        //the token the holder holds
        uint256[] memory IDs=_tokenOfOwner[account];
        //the Index of the token to be removed
        uint256 TokenIndex=ownerID[ID];
        //If token isn't the last token, reorder token
        if(TokenIndex<IDs.length-1){
            uint256 lastID=IDs[IDs.length-1];
            _tokenOfOwner[account][TokenIndex]=lastID;
        }
        //Remove the Last token ID
        _tokenOfOwner[account].pop();
        if(_tokenOfOwner[account].length==0)
            holders.remove(account);
        //pays out dividents and sets new shares
        if(getDividents(account)>0) Payout(account);
        _setNFTHold(account,NFTs[ID],false);
        uint Shares=getSharesOfNFT(ID);
        totalShares-=Shares;
        shares[account]-=Shares;
        paidOutShares[account]=shares[account]*profitPerShare;
        //doesn't remove token, token gets transfered by Add token and therefore removed
    }
    
    
    //the total Supply is the same as the Length of holders
    function totalSupply() external override view returns (uint256){
        return NFTHolders.length;
    }
    //Index is always = token ID
    function tokenByIndex(uint256 _index) external override view returns (uint256){
        require(_exists(_index));
        return _index;
    }
    
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = NFTHolders[tokenId];
        require(owner != address(0));
        return owner;
    }
    //returns the NFT ID of the owner at position
    function tokenOfOwnerByIndex(address _owner, uint256 _index) public override view returns (uint256){
        return _tokenOfOwner[_owner][_index];
    }
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return NFTHolders.length>tokenId;
    }
    
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data) private returns (bool) {
        if (msg.sender!=tx.origin) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert();
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
    
    
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId));
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    } 
    
    
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
        require(owner != address(0));
        return _tokenOfOwner[owner].length;
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
  //  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    //    require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
  //      string memory currentURI=NFTs[tokenId].URI;
  //      if(keccak256(abi.encodePacked((currentURI))) == keccak256(abi.encodePacked(("")))) return baseURI;
  //      return NFTs[tokenId].URI;
  //  }

    function tokenURIOfPrototype(uint8 rarity) public view returns (string memory){
        string memory _tokenURI = NFTPrototypes[rarity].URI;
        string memory base = baseURI();
        return string(abi.encodePacked(base, _tokenURI));
    }
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId));

        string memory _tokenURI = NFTPrototypes[NFTs[tokenId]].URI;
        string memory base = baseURI();
        return string(abi.encodePacked(base, _tokenURI));

    }




    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */

    function baseURI() public view virtual returns (string memory) {
        return _baseURI;
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
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
        require(operator != msg.sender, "ERC721: approve to caller");

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }
}