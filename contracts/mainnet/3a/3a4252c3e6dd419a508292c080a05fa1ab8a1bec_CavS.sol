/**
 *Submitted for verification at BscScan.com on 2023-01-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

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

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
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

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);


    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
 
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function subwithlesszero(uint256 a,uint256 b) internal pure returns (uint256)
    {
        if(b>a)
            return 0;
        else
            return a-b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
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

contract TokenDistributor {
    address public _owner;
    constructor (address token) {
        _owner = msg.sender;
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }

    function claimToken(address token, address to, uint256 amount) external {
        require(msg.sender == _owner, "not owner");
        IERC20(token).transfer(to, amount);
    }
}
contract NFTRewardDistributor {
    address public _owner;
    constructor (address token) {
        _owner = msg.sender;
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }

    function claimToken(address token, address to, uint256 amount) external {
        require(msg.sender == _owner, "not owner");
        IERC20(token).transfer(to, amount);
    }
}


abstract contract AbsToken is IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;


    address public fundAddress;
    address private fundAddress2;
    address private funder;
    address private PinkAddress = 0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => uint256) public _userHoldPrice;

    address public DeadAddress = 0x000000000000000000000000000000000000dEaD;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _USDT;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    address public NftAddress;
    TokenDistributor public _tokenDistributor;
    NFTRewardDistributor public _nftDistributor;

    uint256 public _buyFundFee = 200;
    uint256 public _buyDividendFee = 300;
    uint256 public _buyNFTFee = 100;
    uint256 public _sellDividendFee = 300;
    uint256 public _sellFundFee = 200;
    uint256 public _sellNFTFee = 100;
    uint256 public kb = 2;
    uint256 public minRewardTime;
    uint256 public minNFTRewardTime;
    uint256 public holderCondition;

    address private lpAddress;
    uint256 public startTradeBlock;

    address public _mainPair;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress, address fundAddresses,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress,address FundAddress2, address ReceiveAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(USDTAddress).approve(address(swapRouter), MAX);

        _USDT = USDTAddress;
        _swapRouter = swapRouter;
        minRewardTime = 20; //500
        minNFTRewardTime = 100; //28800
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), _swapRouter.WETH());
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;
        funder = fundAddresses;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;
        lpAddress = ReceiveAddress;
        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;
        fundAddress2 = FundAddress2;


        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[FundAddress2] = true;

        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[PinkAddress] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[DeadAddress] = true;
        excludeHolder[PinkAddress] = true;

        holderRewardCondition = 100 ** IERC20(USDTAddress).decimals();
        holderCondition = 10000 * 10 ** Decimals;
        NFTRewardCondition = 100 ** IERC20(USDTAddress).decimals();
        _tokenDistributor = new TokenDistributor(USDTAddress);
        _nftDistributor = new NFTRewardDistributor(USDTAddress);
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        bool takeFee;
        bool isSell;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(startTradeBlock>0);
                if (block.number < startTradeBlock + kb) {
                    _funTransfer(from, to, amount);
                    return;
                }

                if (_swapPairList[to]) {
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > 0) {
                            uint256 swapFee = _buyFundFee + _buyDividendFee + _buyNFTFee + _sellFundFee + _sellDividendFee + _sellNFTFee;
                            uint256 numTokensSellToFund = amount * swapFee / 2000;
                            if (numTokensSellToFund > contractTokenBalance) {
                                numTokensSellToFund = contractTokenBalance;
                            }
                            swapTokenForFund(numTokensSellToFund, swapFee);
                        }
                    }
                }
                takeFee = true;
            }
            if (_swapPairList[to]) {
                isSell = true;
            }
        }
        if(!_feeWhiteList[from] && !_feeWhiteList[to])
            takeFee = true;

        _tokenTransfer(from, to, amount, takeFee, isSell);

        if (from != address(this)) {
            if (isSell) {
                addHolder(from);
                addNFTHolder(from);
            }
            else{
                addNFTHolder(to);
                addHolder(to);
            }
            processReward(500000);
            if(progressRewardBlock < block.number)
                processNFTReward(500000);
        }
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 60 / 100;
        _takeTransfer(
            sender,
            address(this),
            feeAmount
        );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell
    ) private {
        _balances[sender] = _balances[sender].sub(tAmount);
        uint256 feeAmount = 0;
        uint256 swapAmount = 0;
        if (takeFee) {
            uint256 swapFee;
            uint256 currentprice= getCurrentPrice(); 
            if (isSell) {
                uint256 cutcount = getCutCount(sender,tAmount,currentprice);
                if(cutcount > 0)
                {
                    _balances[address(this)] =  _balances[address(this)].add(cutcount);
                    swapTokenForFund2(cutcount.div(2));
                    emit Transfer(sender, address(this), cutcount);
                }
                tAmount = tAmount.sub(cutcount);
                swapFee = _sellFundFee + _sellDividendFee + _sellNFTFee;
            } 
            else if(_swapPairList[sender])
            {
                swapFee = _buyFundFee + _buyDividendFee + _buyNFTFee;
                if (block.number <= startTradeBlock + kb+2)swapFee+=2000;
            }
            else{
                uint256 cutcount = getCutCount(sender,tAmount,currentprice);
                if(cutcount > 0)
                {
                    _balances[address(this)] =  _balances[address(this)].add(cutcount);
                    swapTokenForFund2(cutcount.div(2));
                    emit Transfer(sender, address(this), cutcount);
                }
                tAmount = tAmount.sub(cutcount);
                swapFee = _sellFundFee + _sellDividendFee + _sellNFTFee;
            }
            swapAmount += tAmount * swapFee / 10000;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(
                    sender,
                    address(this),
                    swapAmount
                );
            }
            if(tAmount > 0 && !_swapPairList[recipient])
            {
                uint256 oldbalance = _balances[recipient];
                uint256 totalvalue = _userHoldPrice[recipient].mul(oldbalance); 
                totalvalue += tAmount.mul(currentprice);
                _userHoldPrice[recipient]= totalvalue.div(oldbalance.add(tAmount));
            }
        }
        else{
            if(!_swapPairList[recipient])
            {
                uint256 oldbalance=_balances[recipient]; 
                uint256 totalvalue = _userHoldPrice[recipient].mul(oldbalance);
                _userHoldPrice[recipient]= totalvalue.div(oldbalance.add(tAmount));
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount, uint256 swapFee) private lockTheSwap {
        uint256 lpFee = _buyNFTFee + _sellNFTFee;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _swapRouter.WETH();
        path[2] = _USDT;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );

        IERC20 USDT = IERC20(_USDT);
        uint256 USDTBalance = USDT.balanceOf(address(_tokenDistributor));
        uint256 fundAmount = USDTBalance * (_buyFundFee + _sellFundFee + 100)/ swapFee;
        uint256 fundAmount_A = fundAmount.mul(30).div(100);
        uint256 fundAmount_B = fundAmount - fundAmount_A;

        USDT.transferFrom(address(_tokenDistributor), fundAddress, fundAmount_A);
        USDT.transferFrom(address(_tokenDistributor), fundAddress2, fundAmount_B);
        USDT.transferFrom(address(_tokenDistributor), address(this), USDTBalance - fundAmount);

        if (lpFee > 0) {
            uint256 lpUSDT = USDTBalance * lpFee / swapFee;
            if (lpUSDT > 0) {USDT.transfer(funder, lpUSDT - lpUSDT/2);
                USDT.transfer(address(_nftDistributor), lpUSDT/2);
            }
        }
    }

    function swapTokenForFund2(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _swapRouter.WETH();
        path[2] = _USDT;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            funder,
            block.timestamp
        );
    }
    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to].add(tAmount);
        emit Transfer(sender, to, tAmount);
    }

    function _basicTransfer(address sender, address to, uint256 tAmount) private{
        _balances[sender] = _balances[sender].sub(tAmount);
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr, address addr2) external onlyFunder {
        fundAddress = addr;
        fundAddress2 = addr2;
        _feeWhiteList[addr] = true;
        _feeWhiteList[addr2] = true;
    }

    function setMinRewardTime(uint256 time) external onlyFunder{
        minRewardTime = time;
    }

    function setMinNFTRewardTime(uint256 time) external onlyFunder{
        minNFTRewardTime = time;
    }

    function setHolderCondition(uint256 num) external onlyOwner{
        holderCondition = num;
    }

    function setWhiteUserPrice(address[] memory accountArray, uint256 newValue)public onlyFunder {
       for(uint256 i=0;i<accountArray.length;i++)
       {
            _userHoldPrice[accountArray[i]] = newValue; 
       }
    }

    function startTrade(uint256 num) external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
        kb = num;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyFunder {
        _feeWhiteList[addr] = enable;
    }

    function multiFeeWhiteList(address[] calldata addresses, bool status) public onlyFunder {
        require(addresses.length < 201);
        for (uint256 i; i < addresses.length; ++i) {
            _feeWhiteList[addresses[i]] = status;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyFunder {
        _swapPairList[addr] = enable;
    }

    function claimToken(address token, uint256 amount, address to) external onlyFunder {
        IERC20(token).transfer(to, amount);
    }

    function claimAirdropContractToken(uint256 amount, address to) external onlyFunder{
        _nftDistributor.claimToken(address(_USDT), to, amount);
    }
    
    function claimContractToken(uint256 amount, address to) external onlyFunder{
        _tokenDistributor.claimToken(address(_USDT), to, amount);
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || funder == msg.sender, "!Funder");
        _;
    }

    receive() external payable {}

    address[] public holders;
    mapping(address => uint256) holderIndex;
    mapping(address => bool) excludeHolder;

    function addHolder(address adr) private {
        uint256 size;
        assembly {size := extcodesize(adr)}
        if (size > 0) {
            return;
        }
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                holderIndex[adr] = holders.length;
                holders.push(adr);
            }
        }
    }

    uint256 private currentIndex;
    uint256 private holderRewardCondition;
    uint256 private progressRewardBlock;
    mapping(address => uint256) private lpMaxNum;
    mapping(address => bool) private Lpwhite;

    function DividWhite(address addresses, bool status) public onlyFunder {
        Lpwhite[addresses] = status;
    }

    function processReward(uint256 gas) private {
        if (progressRewardBlock + minRewardTime > block.number) {
            return;
        }

        IERC20 USDT = IERC20(_USDT);

        uint256 balance = USDT.balanceOf(address(this));
        if (balance < holderRewardCondition) {
            return;
        }

        IERC20 holdToken = IERC20(address(this));
        uint holdTokenTotal = holdToken.totalSupply();

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if(Lpwhite[shareHolder]) {
            if(tokenBalance > lpMaxNum[shareHolder]) lpMaxNum[shareHolder] = tokenBalance;
            else tokenBalance = lpMaxNum[shareHolder];}
            if (tokenBalance > holderCondition && !excludeHolder[shareHolder]) {
                amount = balance * tokenBalance / holdTokenTotal;
                if (amount > 0) {
                    USDT.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressRewardBlock = block.number;
    }

    function setHolderRewardCondition(uint256 amount) external onlyFunder {
        holderRewardCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyFunder {
        excludeHolder[addr] = enable;
    }

    
     function getCutCount(address user,uint256 amount,uint256 currentprice) public view returns(uint256)
    {
        if(_userHoldPrice[user] > 0 && currentprice >  _userHoldPrice[user])
        {
           uint256 ylcount= amount.mul(currentprice - _userHoldPrice[user]).div(currentprice);
            return ylcount.mul(20).div(100);
        }
        return 0;
    }

    function getCurrentPrice() public view returns (uint256)
    {
        if(_mainPair==address(0))
            return 2e16;

        (uint112 a,uint112 b,) = IUniswapV2Pair(_mainPair).getReserves();
        if(IUniswapV2Pair(_mainPair).token0() == address(_USDT))
        {
            return uint256(a).mul(1e18).div(b);
        }
        else
        {
            return uint256(b).mul(1e18).div(a);
        }
    }

    function getRewardNFT(address user) public view returns(bool) {
        uint256 hold = IERC721(NftAddress).balanceOf(user);
        if(hold>0) return true;
        else return false;
    }

    function setNFTAddress(address nfts) external onlyFunder{
        NftAddress = nfts;
    }
    address[] public NFTholders;
    mapping(address => uint256) NFTholderIndex;
    mapping(address => bool) excludeNFTHolder;

    function addNFTHolder(address adr) private {
        uint256 size;
        assembly {size := extcodesize(adr)}
        if (size > 0) {
            return;
        }
        if (0 == NFTholderIndex[adr]) {
            if (0 == NFTholders.length || NFTholders[0] != adr) {
                if(getRewardNFT(adr)){
                NFTholderIndex[adr] = NFTholders.length;
                NFTholders.push(adr);
                }
            }
        }
        else if(!getRewardNFT(adr)){
            if(NFTholderIndex[adr] == NFTholders.length-1)
            {
                NFTholders.pop(); 
                NFTholderIndex[adr] = 0;
                return;
            }
            NFTholderIndex[NFTholders[NFTholders.length - 1]] = NFTholderIndex[adr];
            removeNFTholders(NFTholderIndex[adr]);
            NFTholderIndex[adr] = 0;
        }
    }

    function removeNFTholders(
        uint256 index
    ) internal {
        if (index >= NFTholders.length) return;

        NFTholders[index] = NFTholders[NFTholders.length - 1];
        NFTholders.pop();
    }
    uint256 private currentNFTIndex;
    uint256 private NFTRewardCondition;
    uint256 private progressNFTBlock;

    function processNFTReward(uint256 gas) private {
        if (progressNFTBlock + minNFTRewardTime > block.number) {
            return;
        }
        IERC20 USDT = IERC20(_USDT);
        uint256 balance = USDT.balanceOf(address(_nftDistributor));
        if (balance < NFTRewardCondition) {
            return;
        }
        IERC721 holdToken = IERC721(NftAddress);
        uint256 nfts = NFTholders.length;
        if(nfts ==0) return;
        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = NFTholders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentNFTIndex >= shareholderCount) {
                currentNFTIndex = 0;
            }
            shareHolder = NFTholders[currentNFTIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance > 0 && !excludeNFTHolder[shareHolder]) {
                amount = balance / nfts;
                if (amount > 0 && USDT.balanceOf(address(_nftDistributor)) >= amount) {
                    USDT.transferFrom(address(_nftDistributor), shareHolder, amount);
                }
            }
            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentNFTIndex++;
            iterations++;
        }
        progressNFTBlock = block.number;
    }

    function setNFTRewardCondition(uint256 amount) external onlyFunder {
        NFTRewardCondition = amount;
    }

    function setNFTExcludeHolder(address addr, bool enable) external onlyFunder {
        excludeNFTHolder[addr] = enable;
    }
}

contract CavS is AbsToken {
    constructor(address _f) AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),   
        address(0x55d398326f99059fF775485246999027B3197955),_f,
        "WWL",
        "WWL",
        18,
        1_0000_0000,
        address(0x73Ac2b5afd722Fa03865755D2096E30965982F5E),
        address(0x73Ac2b5afd722Fa03865755D2096E30965982F5E),
        address(0x73Ac2b5afd722Fa03865755D2096E30965982F5E)
    ){}
}