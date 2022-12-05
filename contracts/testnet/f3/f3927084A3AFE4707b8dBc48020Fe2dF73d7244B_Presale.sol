/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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


    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }


    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface INFT {
    function mint(address to, uint256 _level,uint256 tokenId) external;
    function mint(address to) external;
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

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
}

contract Presale is Ownable {
    using SafeMath for uint256;
   
    bool public _pauseBuy;

    //普通盲盒
    uint256 public primary = 2000;
    //高级盲盒
    uint256 public senior = 2800;
    //终极盲盒
    uint256 public  ultimate = 3000;

    //普通盲盒
    uint256 public primaryId = 0;
    //高级盲盒
    uint256 public seniorId = 2000;
    //终极盲盒
    uint256 public  ultimateId = 2800;

    //小屋NFT
    uint256 public houseCount = 500;
    //小屋NFT
    uint256 public  houseId =0;

    INFT public _nft;
    INFT public _honseNFT;

    address public _router;
    address public _token;


    constructor(address NFTAddress,address houseNFT,address router,address token){
        _nft = INFT(NFTAddress);
        _honseNFT = INFT(houseNFT);
        _router = router;
        _token = token;
    }

    function buyFirst(uint256 count) external payable {

        uint256 amount = count.mul(1e17);
        require(msg.value == amount, "buy amount error");
        require(primaryId < primary, "sell over");
        //已经停止预售
        require(!_pauseBuy, "endSale");
        for (uint256 i = 0; i < count; i++) {
            _nft.mint(msg.sender,1,primaryId);
            primaryId += 1;  
        }
    
    }


    function buySecond(uint256 count) external payable {

        uint256 amount = count.mul(2*1e17);
        require(msg.value == amount, "buy amount error");
        require(seniorId < senior, "sell over");
        //已经停止预售
        require(!_pauseBuy, "endSale");
        for (uint256 i = 0; i < count; i++) {
            _nft.mint(msg.sender,2,seniorId);
            seniorId += 1;  
        }
    
    }


    function buyThird(uint256 count) external payable {

        uint256 amount = count.mul(1e18);
        require(msg.value == amount, "buy amount error");
        require(ultimateId < ultimate, "sell over");
        //已经停止预售
        require(!_pauseBuy, "endSale");
        for (uint256 i = 0; i < count; i++) {
            _nft.mint(msg.sender,3,ultimateId);
            ultimateId += 1;  
        }
    
    }

    function buyHouse(uint256 count) external payable {

        uint256 amount = count.mul(5e17);
        require(msg.value == amount, "buy amount error");
        require(houseId < houseCount, "sell over");
        //已经停止预售
        require(!_pauseBuy, "endSale");
        for (uint256 i = 0; i < count; i++) {
            _honseNFT.mint(msg.sender);
            houseId += 1;  
        }
    
    }


    function buyToken(uint256 count) external payable {
        uint256 amount = count.mul(625000000000000);
        uint256 tokenAmount = count.mul(10**18);
        require(msg.value == amount, "buy amount error");
        //已经停止预售
        require(!_pauseBuy, "endSale");
        IERC20(_token).transfer(msg.sender,tokenAmount);
    }


    function setPaseBuy(bool flag) external onlyOwner{
        _pauseBuy = flag;
    }


 
   


   
}