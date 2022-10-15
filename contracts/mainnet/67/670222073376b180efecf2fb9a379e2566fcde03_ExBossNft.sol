// SPDX-License-Identifier: UNLICENSED


pragma solidity ^0.6.0;
import './SafeMath.sol';
import './IERC20.sol';
import './ERC20.sol';
import './SafeERC20.sol';
import './Address.sol';
import './Context.sol';
interface IBOSSNFT {
    function mint(address recipient, string memory uri) external returns (uint256);
}
interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private initializing;

    /**
     * @dev Modifier to use in the initializer function of a contract.
     */
    modifier initializer() {
        require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            initialized = true;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        assembly {cs := extcodesize(self)}
        return cs == 0;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;
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
contract ContextUpgradeSafe is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.

    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {


    }


    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
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
contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {


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

    uint256[49] private __gap;
}
import "./IERC20.sol";
import "./SafeMath.sol";
import "./Address.sol";
import "./SafeERC20.sol";
import "./IERC721.sol";
import "./IERC721Receiver.sol";

interface IRunDao{
    function getRelations(address _address) external view returns(address[] memory);
    function payToken() external view returns(address);
    function setDaoReward(uint256 _amount) external;
}
interface Itoken{
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external  returns (bool);
    function transfer(address to, uint256 value) external  returns (bool);
    function idoTransfer(address to, uint256 value) external  returns (bool);
}
interface IWBNB is IERC20 {
    function deposit() external payable;

    function withdraw(uint256 wad) external;
}
contract ExBossNft is  OwnableUpgradeSafe,IERC721Receiver {
    using SafeMath for *;
    using SafeERC20 for IERC20;


    uint256 private _status;
    //uint256  public IDONum;
    uint256  public NFTValue;

    uint256  public lpRatio;
    uint256  public buybackRatio;
    address public  WBNB ;
    address public addrPayToken;

    address public SECDaoAddress;
    address public FreeAddress;
    address public token1Address;
    address public BossNft;


    mapping(address => uint256) public upperRefNum;
    mapping(address => bool) public bIdoed;
    uint256 public startTime ;
    uint256 public NFTId ;
    uint256 public NFT2Id ;
    uint256 public NFT3Id ;
    uint256 public NFT4Id ;
    address[] public freeTotoken1;
    address[] public token1Tofree;
    address public uniRouterAddress;
    address public fundAddress;
    uint256 public slippageFactor;
    mapping(address => bool) public whiteList;

    uint256[32] public __idogap;


    event NftReceived(address operator, address from, uint256 tokenId, bytes data);

    function initialize(


       address _BossNft




    ) public initializer {
        OwnableUpgradeSafe.__Ownable_init();

        BossNft = _BossNft;

        WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        token1Address = WBNB;
        fundAddress = 0xa1E5404ad64FF3CAce400a9C9bce19c24443e8b3;
        NFTId = 1;

        slippageFactor= 970;
        NFTValue = 10**18 *1900;


    }



    function getNFTId() external view  returns (uint256) {
        return NFTId;
    }

    function getNFT2Id() external view  returns (uint256) {
        return NFT2Id;
    }
     function getNFT3Id() external view  returns (uint256) {
        return NFT3Id;
    }

    function getNFT4Id() external view  returns (uint256) {
        return NFT4Id;
    }
     function setNFTId(uint256 _id) external  onlyOwner
      {
       NFTId = _id;
    }

    function setNFT2Id(uint256 _id) external  onlyOwner  {
       NFT2Id = _id;
    }
    function setNFT3Id(uint256 _id) external   onlyOwner {
       NFT3Id = _id;
    }
    function setNFT4Id(uint256 _id) external  onlyOwner  {
       NFT4Id = _id;
    }


    /// @dev encrypt token data
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    )
        public
        override
        returns (bytes4)
    {
        //only receive the _nft staff
        if (address(this) != operator) {
            //invalid from nft
            //return 0;
        }
        if( msg.sender == BossNft)
        {
             if( from != owner() ) {
                IERC20(FreeAddress).safeTransfer(from, NFTValue);
             }
        }

        //success
        emit NftReceived(operator, from, tokenId, data);
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }



    function recover( address _token,uint256 _amount,address _to)  external onlyOwner {


        IERC20(_token).safeTransfer(_to, _amount);
    }

    function recoverNFT( address _to,address _runNft,uint256 id)  external onlyOwner {

         IERC721 nft = IERC721(_runNft);
         nft.safeTransferFrom(address(this),_to, id);

    }





      function setFreeAddress(address _FreeAddress) external onlyOwner  returns (bool) {


        FreeAddress = _FreeAddress;
        return true;

    }
     function settoken1Address(address _token1Address) external onlyOwner  returns (bool) {


        token1Address = _token1Address;
        return true;

    }
      function getStartSellingTime() external   returns (uint256) {



        return startTime;

    }
    function setStartSellingTime(uint256 _time ) external    onlyOwner{


        startTime =_time;


    }


    function recoverB(
        address payable to,
        uint value
    ) external onlyOwner   {

            to.transfer(value);

    }
    function setfreeTotoken1(address _FreeAddress,address token1) external onlyOwner
    {
       freeTotoken1 = [_FreeAddress,token1];
    }
     function settoken1Tofree(address _FreeAddress,address token1) external onlyOwner
    {
       token1Tofree = [token1,_FreeAddress];
    }
     function setSECDaoAddress(address _SECDaoAddress) external onlyOwner
    {
       SECDaoAddress = _SECDaoAddress;
    }
       function setfundAddress(address _fundAddress) external onlyOwner
    {
       fundAddress = _fundAddress;
    }
      function getRelAddress(address _walAddress) external view returns (address[] memory)
    {
         address[] memory _parents = IRunDao(SECDaoAddress).getRelations(_walAddress);
         for (uint8 i=0;i<_parents.length;i++){
                if(_parents[i] == address(0))
                {
                    _parents[i] = fundAddress;
                }
          }
          return _parents;
    }

   function setNFTValue(uint256 _NFTValue ) external    onlyOwner{


        NFTValue =_NFTValue;


    }


     function  getnft(uint256 token0Amt , address wal) external   returns (uint256){

       require(msg.sender == FreeAddress, "Not Whitelist");
       uint256 nftnum = token0Amt.div(NFTValue);
       uint256 returnback = token0Amt.mod(NFTValue);
       IBOSSNFT nft1 = IBOSSNFT(BossNft);


       for (uint256 i=0; i<nftnum; i++) {
          // nft1.safeTransferFrom(address(this), msgsender, NFTId);
           nft1.mint(wal,'BOSSNFT2000');
           NFTId = NFTId.add(1);
       }
       if(returnback>0)
       {
            IERC20(FreeAddress).safeTransfer(wal, returnback);
       }





    }






}