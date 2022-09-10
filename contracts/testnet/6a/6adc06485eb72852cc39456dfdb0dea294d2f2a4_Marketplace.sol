/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
  

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    function decimals() external view returns (uint256);
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

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

    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
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
    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory)
    {
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
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}




//   __  __            _        _         _                
//  |  \/  |          | |      | |       | |               
//  | \  / | __ _ _ __| | _____| |_ _ __ | | __ _  ___ ___ 
//  | |\/| |/ _` | '__| |/ / _ \ __| '_ \| |/ _` |/ __/ _ \
//  | |  | | (_| | |  |   <  __/ |_| |_) | | (_| | (_|  __/
//  |_|  |_|\__,_|_|  |_|\_\___|\__| .__/|_|\__,_|\___\___|
//                                 | |                     
//                                 |_|                     


contract Marketplace is Ownable{
    using SafeMath for uint256;

    AggregatorV3Interface internal priceFeed;
    address private priceAddress = 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526; // BNB/USD Testnet
    address pairAddress = 0x851f9b33d9fea4042550Bb351D70264F9008E9e7; 

    /**
     * @dev 
     * BSC Mainnet
     * BNB/USD: 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
     * BTC/USD: 0x264990fbd0A4796A3E3d8E37C4d5F87a3aCa5Ebf
     * ETH/USD: 0x9ef1B8c0E4F7dc8bF5719Ea496883DC6401d5b2e
     * WBNB: 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
     * PancakePair: * 0x00407C0A9869A81Af09C45Fe04eE16F2359aB1C3

     *
     * BSC Testnet
     * BNB/USD: 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
     * BTC/USD: 0x5741306c21795FdCBb9b265Ea0255F499DFe515C
     * ETH/USD: 0x143db3CEEfbdfe5631aDD3E50f7614B6ba708BA7
     * WBNB: 0x15C9e651b5971FeB66E19Fe9E897be6BdC3e841A
     * PancakePair: 0x851f9b33d9fea4042550Bb351D70264F9008E9e7
     */


   

    IERC20 public HGB;
    uint256 public nftId;
    uint256 auctionId = 0;
    uint256 percentage;
    uint256 delayTime;
    


    address payable private sender;

    // constructor
    constructor(
        address _HGB
    ) {
        priceFeed = AggregatorV3Interface(priceAddress);
        HGB = IERC20(_HGB);
        percentage = 0;
        delayTime = 180 seconds;
        sender = payable(msg.sender);
    }

    function getDelaySellTime() public view returns (uint256) {
        return delayTime;
    }

    function setDelayTime(uint256 secs) public onlyOwner{
        delayTime =  secs * 1 seconds;
    }


    function toString(uint256 i) public pure returns (string memory a) {
        a = Strings.toString(i);
        return string(abi.encodePacked("You not own token", " ", a));
    }

    // calculate price based on pair reserves
   function getTokenPrice() public view returns(uint)
   {
    IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
    (uint Res0, uint Res1,) = pair.getReserves();

    
    return(Res1.mul(priceOfBNB()).div(Res0)); // return price of token 0
   }
  
    function priceOfBNB() view public returns (uint) {
        (, int _price, , ,) = priceFeed.latestRoundData();
        return uint(_price).mul(1e10);
    }

    function convertUSDtoToken(uint256 amount) view public returns (uint256) {
        uint256 price = amount * 10 ** 18/getTokenPrice();
        return price;
    }

    
    mapping(address => bool) isWhiteList;
    address[] whiteList;
    function addWhitelist(address[] memory nftContracts) public onlyOwner {
        for(uint i = 0; i < nftContracts.length; i++) {
            if(!isWhiteList[nftContracts[i]]) {
                whiteList.push(nftContracts[i]);
                isWhiteList[nftContracts[i]] = true;
            }
        }
    }

    function removeWhitelist(address nftContract) public onlyOwner {
        require(isWhiteList[nftContract], "Not in whitelist yet");
        for(uint i = 0; i < whiteList.length; i++) {
           if (nftContract == whiteList[i]) {
               delete whiteList[i];
           }
        }
    }

    function getWhiteList() public view returns (address[] memory ) {
        return whiteList;
    }
    

    // BUY-SELL ALL NFT >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    struct NFTAsset {
        uint256 tokenID;
        uint256 price;
        bool onSell;
        address owner;
        uint256 blockTime;
    }

    
    mapping(address=> mapping(uint256 => NFTAsset)) public NFTAssets;

    // Events
    event OnSell(uint256 TokenID, uint256 price);
    event OnCancelSale(uint256 TokenID);
    event OnBuy(address indexed sender, uint256 price);

    function sell(uint256 TokenID, uint256 price, address NFTAddress) public {
        require(isWhiteList[NFTAddress], "NFT not verified by market owner");
        require(
            IERC721(NFTAddress).ownerOf(TokenID) == msg.sender,
            "You do not own this token"
        );
        NFTAsset storage nft = NFTAssets[NFTAddress][TokenID];
        require(block.timestamp > nft.blockTime, "Please wait a few minutes to make the next action");
        (
            nft.tokenID = TokenID,
            nft.price = price,
            nft.onSell = true,
            nft.owner = msg.sender
        );

        IERC721(NFTAddress).transferFrom(msg.sender, address(this), TokenID);
        emit OnSell(TokenID, price);
    }

    function cancelSale(uint256 TokenID, address NFTAddress) public {
        NFTAsset storage nft = NFTAssets[NFTAddress][TokenID];
        require(nft.onSell, "Can not cancel - have not on sale yet");
        require(nft.owner == msg.sender, "You do not own this token");
        nft.price = 0;
        nft.onSell = false;
        nft.blockTime = block.timestamp + delayTime;
        IERC721(NFTAddress).transferFrom(address(this), nft.owner, TokenID);
        emit OnCancelSale(TokenID);
    }

    function forceCancelSale(uint256[] memory TokenIDs, address NFTAddress) public onlyOwner {
        for(uint i = 0; i < TokenIDs.length; i++) {
            NFTAsset storage nft = NFTAssets[NFTAddress][TokenIDs[i]];
          
            require(nft.onSell, "Can not cancel - have not on sale yet");
            nft.price = 0;
            nft.onSell = false;
            IERC721(NFTAddress).transferFrom(address(this), nft.owner, TokenIDs[i]);
        }
    }

    function buy(uint256 TokenID, address NFTAddress, uint256 amount) public {
        uint payment = convertUSDtoToken(amount);

        NFTAsset storage nft = NFTAssets[NFTAddress][TokenID];

        require(block.timestamp > nft.blockTime, "Please wait a few minutes to make the next action");
        require(nft.onSell, "Can not buy - Sale is end");
        require(amount == nft.price, "Can not buy - Price uneven error");
        require(HGB.balanceOf(msg.sender) >= payment, "Don't have enough HBG");

        // Buyer send percentage
         if(percentage > 0) {
            HGB.transferFrom(
                msg.sender,
                address(this),
                payment
            );
             // Buyer pay seller the price - percentage
            HGB.transfer(nft.owner, getAfterCommissionPrice(payment));
        } else {
            HGB.transferFrom(msg.sender,nft.owner, payment);
        }

        IERC721(NFTAddress).transferFrom(address(this), msg.sender, TokenID);
        nft.onSell = false;
        nft.blockTime = block.timestamp + delayTime;

        emit OnBuy(msg.sender, nft.price);
    }

    
    function getCommissionPrice(uint256 price) public view returns (uint256) {
        return price.mul(percentage).div(100);
    }

    function getAfterCommissionPrice(uint256 price)
        public
        view
        returns (uint256)
    {
        return price.mul(100-percentage).div(100);
    }

    function withdrawAssetFromContract(address tokenContract) public onlyOwner {
        IERC20(tokenContract).transfer(owner(), IERC20(tokenContract).balanceOf(address(this)));
    }

    receive() external payable{}
    function withdrawBNB(uint256 amount, address to) external onlyOwner{
        payable(to).transfer(amount);
    }

    function changeToken(
        address newHGB
    ) public onlyOwner {
        HGB = IERC20(newHGB);
    }

    function changePairPancake(address _address) public onlyOwner {
        pairAddress = _address;
    }

    function changePriceFeed(address _priceAddress) public onlyOwner {
        priceAddress = _priceAddress;
        priceFeed = AggregatorV3Interface(priceAddress);
    }

    
}