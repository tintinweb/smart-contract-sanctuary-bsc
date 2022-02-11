/**
 *Submitted for verification at BscScan.com on 2022-02-09
*/

/**
MrGreenCryptoSwap
 */
pragma solidity 0.8.11;

// SPDX-License-Identifier: None
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {return msg.sender;}
    function _msgData() internal view virtual returns (bytes calldata) {return msg.data;}
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {_setOwner(_msgSender());}
    function owner() public view virtual returns (address) {return _owner;}
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0),"Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }
    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor() {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

interface IDexRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
    function removeLiquidityETHSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountETH);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
}

interface IERC721 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function tokenByIndex(uint256 index) external view returns (uint256);
}

contract MrGreenCryptoSwap is Ownable, ReentrancyGuard {
    IDexRouter public router;
    address payable private _mrGreen = payable(0xe6497e1F2C5418978D5fC2cD32AA23315E7a41Fb);
    IERC721Enumerable internal NFTcontract = IERC721Enumerable(0x5994881999800871310E45E1D592420789750b79);
    address public constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    event TokensBoughtOnWebsite(address buyer, uint256 bnbSpent, address tokenAddress);
    event TokensSoldOnWebsite(address seller, uint256 TokensSold, address tokenAddress);
    
    mapping (address => bool) public listed;
    mapping (address => uint256) public buyFee;
    mapping (address => uint256) public sellFee;
    mapping (address => address) public marketingWallet;
    mapping (address => uint256) public feeDenominator;

    constructor() {}

    function calculateTaxRate(address account) public view returns (uint256) {
        uint256 amountOfToken = NFTcontract.balanceOf(account);
        if(amountOfToken > 0) {
            return 50;
        } else {
            return 100;
        }    
    }

    function getDecimals(address _tokenAddress) public view returns (uint8){
        return IERC20Metadata(_tokenAddress).decimals();
    }

    function addListedToken(address _token, uint256 _buyTax, uint256 _sellTax, uint256 _feeDenominator, address _marketingWallet) external onlyOwner {
        listed[_token] = true;
        buyFee[_token] = _buyTax;
        sellFee[_token] = _sellTax;
        marketingWallet[_token] = _marketingWallet;
        feeDenominator[_token] = _feeDenominator;
    }

    function websiteSwapTokensForBnb(uint256 _tokenAmount, address _tokenAddress) public { 
        uint8 _decimals = getDecimals(_tokenAddress);     
        _tokenAmount = _tokenAmount * 10**(_decimals);
        uint256 initialBalance = address(this).balance;
        require(IERC20(_tokenAddress).balanceOf(msg.sender) >= _tokenAmount,"Cannot sell more than you own");
        if(IERC20(_tokenAddress).allowance(address(this), address(router)) < _tokenAmount) {
            IERC20(_tokenAddress).approve(address(router), ~uint256(0));
        }
        IERC20(_tokenAddress).transferFrom(msg.sender, address(this), _tokenAmount);
        address[] memory path = new address[](2);
        path[0] = _tokenAddress;
        path[1] = WBNB;
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(_tokenAmount, 0, path, address(this), block.timestamp);
        uint256 bnbFromSell = address(this).balance - initialBalance;
        if(listed[_tokenAddress]){
            uint256 taxesForTokenOwner = sellFee[_tokenAddress] * bnbFromSell / feeDenominator[_tokenAddress];
            uint256 taxes = bnbFromSell * calculateTaxRate(msg.sender) / 10000;
            bnbFromSell = bnbFromSell - taxes - taxesForTokenOwner;
            payable(msg.sender).transfer(bnbFromSell);
            payable(marketingWallet[_tokenAddress]).transfer(taxesForTokenOwner);
            payable(_mrGreen).transfer(address(this).balance);
            emit TokensSoldOnWebsite(msg.sender, _tokenAmount, _tokenAddress);
        } else {
            uint256 taxes = bnbFromSell * calculateTaxRate(msg.sender) / 10000;
            bnbFromSell -= taxes;
            payable(msg.sender).transfer(bnbFromSell);
            payable(_mrGreen).transfer(address(this).balance);
            emit TokensSoldOnWebsite(msg.sender, _tokenAmount, _tokenAddress);            
        }
    }

    function websiteSwapBnbForTokens(address _tokenAddress) public payable nonReentrant{
        uint256 bnbAmount = msg.value;
        if(listed[_tokenAddress]) {
            uint256 taxesForTokenOwner = buyFee[_tokenAddress] * bnbAmount / feeDenominator[_tokenAddress];
            uint256 taxes = bnbAmount * calculateTaxRate(msg.sender) / 10000;
            payable(marketingWallet[_tokenAddress]).transfer(taxesForTokenOwner);
            bnbAmount = bnbAmount - taxes - taxesForTokenOwner;
        } else {
        uint256 taxes = msg.value * calculateTaxRate(msg.sender)  / 10000;
        bnbAmount -= taxes;
        }
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = _tokenAddress;
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: bnbAmount}(0, path, address(this), block.timestamp);
        uint256 tokensReceived = IERC20(_tokenAddress).balanceOf(address(this));
        IERC20(_tokenAddress).transfer(msg.sender, tokensReceived);
        payable(_mrGreen).transfer(address(this).balance);
        emit TokensBoughtOnWebsite(msg.sender, msg.value, _tokenAddress);
    }
}