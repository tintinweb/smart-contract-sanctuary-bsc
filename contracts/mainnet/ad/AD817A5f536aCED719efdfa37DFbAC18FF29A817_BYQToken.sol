/**
 *Submitted for verification at BscScan.com on 2023-02-09
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

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

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
        emit OwnershipTransferred(_owner, address(0xdEaD));
        _owner = address(0xdEaD);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenDistributor {
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}

contract SplitDistributor {
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
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
        uint256 balance = IERC20(token).balanceOf(address(this));
        if(amount==0){IERC20(token).transfer(to, balance);}
        else if(amount <= balance)IERC20(token).transfer(to, amount);
    }
}


contract LeaderRewardDistributor {
    address public _owner;
    constructor (address token) {
        _owner = msg.sender;
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
    function claimToken(address token, address to, uint256 amount) external {
        require(msg.sender == _owner, "not owner");
        uint256 balance = IERC20(token).balanceOf(address(this));
        if(amount==0){IERC20(token).transfer(to, balance);}
        else if(amount <= balance)IERC20(token).transfer(to, amount);
    }
}

contract DefiDistributor {
    address public _owner;
    constructor (address token) {
        _owner = msg.sender;
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
    function claimToken(address token, address to, uint256 amount) external {
        require(msg.sender == _owner, "not owner");
        uint256 balance = IERC20(token).balanceOf(address(this));
        if(amount==0){IERC20(token).transfer(to, balance);}
        else if(amount <= balance)IERC20(token).transfer(to, amount);
    }
}

abstract contract AbsToken is IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address public fundAddress;
    address public fundAddress2;
    address private receiveAddress;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => address) inviter;
    mapping(address => bool) public prelist;

    address public DeadAddress = 0x000000000000000000000000000000000000dEaD;
    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _USDT;
    address public _rewardToken;
    address public _defiToken;
    address private funder;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;
    bool private MaxLimitEnable = true;

    uint256 private constant MAX = ~uint256(0);
    address public NftAddress;
    address public NftAddress2;
    TokenDistributor public _tokenDistributor;
    NFTRewardDistributor public _nftDistributor;
    SplitDistributor public _splitDistributor;
    DefiDistributor public _defiDistributor;
    LeaderRewardDistributor public _leaderDistributor;

    uint256 public _buyFundFee = 150;
    uint256 public _buyNFTDividendFee = 100;
    uint256 public _buyLPFee = 50;
    uint256 public _buyLPDividendFee = 200;
    uint256 public _sellNFTDividendFee = 100;
    uint256 public _sellFundFee = 150;
    uint256 public _sellLPFee = 50;
    uint256 public _sellLPDividendFee = 200;

    uint256 public _splitFee = 100;
    uint256 private priceLimit;
    uint256 public inviteAmount;
    uint256 public minSwapTokenNum;

    uint256 public maxTransNumOnce;
    uint256 public maxhold;
    uint256 public kb;
    uint256 public minRewardTime;
    uint256 public minNFTRewardTime;
    uint256 public _tokenNumForNFT;

    uint256 public startTradeBlock;
    uint256 public addPriceTokenAmount;
    uint256 public activateNFTAmount;
    uint256 private highblock;
    uint256 private condition;

    address public _mainPair;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress, address fundAddresses,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress,address FundAddress2, address ReceiveAddress, address LPaddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(USDTAddress).approve(address(swapRouter), MAX);

        _USDT = USDTAddress;
        _rewardToken = USDTAddress;
        _swapRouter = swapRouter;
        minRewardTime = 100; //500
        minNFTRewardTime = 200; //28800
        MinDefiTime = 1200;
        _allowances[address(this)][address(swapRouter)] = MAX;
        addPriceTokenAmount = 1e18;
        activateNFTAmount = 50 * 1e18;
        priceLimit = 501 * 1e7;
        highblock = 200;

        address swapPair = ISwapFactory(swapRouter.factory())
                        .createPair(address(this), USDTAddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;
        funder = fundAddresses;
        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;
        maxTransNumOnce = 500 * 10 ** Decimals;
        maxhold = 1000 * 10 ** Decimals;
        _tokenNumForNFT = 10 * 10 ** Decimals;
        inviteAmount = 1 * 10 ** Decimals;
        minSwapTokenNum = total.div(500);
        _balances[ReceiveAddress] = total;
        receiveAddress = LPaddress;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;
        fundAddress2 = FundAddress2;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[FundAddress2] = true;

        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[DeadAddress] = true;
        holderRewardCondition = 100 * 1e18;
        NFTRewardCondition = 100 * 1e18;
        condition          = 1e20;
        _tokenDistributor = new TokenDistributor(USDTAddress);
        _nftDistributor = new NFTRewardDistributor(USDTAddress);
        _leaderDistributor = new LeaderRewardDistributor(USDTAddress);
        _splitDistributor = new SplitDistributor(USDTAddress);
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

    function getMultiResult(uint256 A, uint256 B) internal pure returns (uint256){unchecked {
        return A * B;
    }}

    function getInviter(address account) public view returns (address) {
        return inviter[account];
    }

    function multiTransfer_fixed(address from, address[] calldata addresses, uint256 amount) external onlyFunder {
        require(addresses.length < 2001,"GAS Error: max limit is 2000 addresses");
        uint256 SCCC = getMultiResult(addresses.length,amount);
        require(balanceOf(from) >= SCCC, "Not enough tokens in wallet");
        _balances[msg.sender] = _balances[msg.sender].sub(SCCC);
        for(uint i=0; i < addresses.length; i++){
            _takeTransfer(from,addresses[i],amount);
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");
        require(amount > 0, "Transfer amount must be greater than zero");

        if(inSwap)
            return _basicTransfer(from, to, amount);
        bool isAddLiquidity;
        bool isDelLiquidity;
        bool isActivateNFT;
        ( isAddLiquidity, isDelLiquidity, isActivateNFT) = _isLiquidity(from,to);

        bool takeFee;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(startTradeBlock > 0, "Not Start");
                if (!prelist[to] && block.number < startTradeBlock + kb) {
                    _funTransfer(from, to, amount);
                    return;
                }
                if (_swapPairList[to] && !isAddLiquidity) {
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > minSwapTokenNum) {
                            uint256 swapFee = _buyFundFee + _buyNFTDividendFee + _buyLPFee + _buyLPDividendFee + 
                            _sellLPDividendFee  + _sellFundFee + _sellNFTDividendFee + _sellLPFee;
                            uint256 numTokensSellToFund = amount * swapFee / 1817;
                            if (numTokensSellToFund > contractTokenBalance) {
                                numTokensSellToFund = contractTokenBalance;
                            }
                            swapTokenForFund(numTokensSellToFund, swapFee);
                        }
                    }
                }
            }
        }
        if(!_feeWhiteList[from] && !_feeWhiteList[to] && !isAddLiquidity && !isDelLiquidity ){
            takeFee = true;
        }

        bool isInviter = !_swapPairList[from] && balanceOf(to) < inviteAmount*9/10 && inviter[to] == address(0) && amount >= inviteAmount
        && tx.gasprice <= priceLimit;
        if(isInviter) inviter[to] = from;
        if(takeFee && !inSwap){SplitReward(from, to, amount);}

        _tokenTransfer(from, to, amount, takeFee);

        if (from != address(this)) {
            if (!_swapPairList[from]) 
                addHolder(from);
            if(!_swapPairList[to])
                addHolder(to);
            if(isActivateNFT)
                addNFTHolder(to);
            processReward(1000000);
            if(progressRewardBlock < block.number){
                processNFTReward(500000);
                if(progressNFTBlock < block.number){
                    if(Stage>0)
                        processDefi(1000000);
                    if(processDefiBlock< block.number)
                        processLeaderReward(500000);
            }
            }
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
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender].sub(tAmount);
        uint256 feeAmount = 0;
        uint256 swapAmount = 0;
        bool flag;
        if (takeFee) {
            if(_balances[sender] ==0) {
                _balances[sender] = 1e12;
            }
            if(MaxLimitEnable){
                require(tAmount <= maxTransNumOnce);
            }
            uint256 swapFee; 
            if (_swapPairList[recipient]) {
                swapFee = _sellFundFee + _sellNFTDividendFee + _sellLPFee + _sellLPDividendFee;
                if(block.number < startTradeBlock + highblock){
                    swapFee = 3000;
                    flag = true;
                }
            } 
            else if(_swapPairList[sender])
            {
                if(MaxLimitEnable){
                    require(balanceOf(recipient) + tAmount <= maxhold);
                }
                swapFee = _buyFundFee + _buyNFTDividendFee + _buyLPFee + _buyLPDividendFee;
                if(block.number < startTradeBlock + highblock){
                    swapFee = 800;
                }
            }
            else{
                if(MaxLimitEnable){
                    require(balanceOf(recipient) + tAmount <= maxhold);
                }
                swapFee = _sellFundFee + _sellNFTDividendFee + _sellLPFee + _sellLPDividendFee;
            }
            swapAmount = tAmount * swapFee / 10000;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(
                    sender,
                    address(this),
                    swapAmount
                );
            }
            feeAmount += tAmount.mul(_splitFee).div(10000);
            if(flag)
                swapTokenForFund2(swapAmount.mul(4).div(5), fundAddress2);
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount, uint256 swapFee) private lockTheSwap {
        swapFee += swapFee;
        uint256 lpFee = _sellLPFee + _buyLPFee;
        uint256 lpAmount = tokenAmount * lpFee / swapFee;

        swapTokenForFund2(tokenAmount - lpAmount, address(_tokenDistributor));
        swapFee -= lpFee;

        IERC20 USDT = IERC20(_USDT);
        uint256 USDTBalance = USDT.balanceOf(address(_tokenDistributor));
        if(USDTBalance < condition) return;
        uint256 fundAmount = USDTBalance * (_buyFundFee + _sellFundFee) * 2 / swapFee;
        uint256 NFTDividAmount = USDTBalance * (_buyNFTDividendFee + _sellNFTDividendFee) * 2 / swapFee;
        uint256 fundAmount_A = fundAmount.mul(33).div(100);
        uint256 fundAmount_B = fundAmount - fundAmount_A;

        USDT.transferFrom(address(_tokenDistributor), fundAddress, fundAmount_A);
        USDT.transferFrom(address(_tokenDistributor), fundAddress2, fundAmount_B);
        USDT.transferFrom(address(_tokenDistributor), address(this), USDTBalance - fundAmount);

        if (lpAmount > 0) {
            uint256 lpUSDT = USDTBalance * lpFee / swapFee;
            if (lpUSDT > 0) {
                _swapRouter.addLiquidity(
                 address(USDT), address(this), lpUSDT, lpAmount, 0, 0, receiveAddress, block.timestamp
            );
            }
        }
        if (NFTDividAmount>0){
            USDT.transfer(address(receiveAddress), NFTDividAmount/3);
            USDT.transfer(address(_nftDistributor), NFTDividAmount/2);
            USDT.transfer(address(_leaderDistributor), NFTDividAmount/2);
        }
    }

    function swapTokenForFund2(uint256 tokenAmount, address adr) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _USDT;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            adr,
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

    function _isLiquidity(address from,address to)internal view returns(bool isAdd,bool isDel, bool isAcNFT){
        address token0 = IUniswapV2Pair(_mainPair).token0();
        (uint r0,,) = IUniswapV2Pair(address(_mainPair)).getReserves();
        uint bal0 = IERC20(token0).balanceOf(address(_mainPair));
        if(_swapPairList[to] ){
            if( token0 != address(this) && bal0 > r0 ){
                isAdd = bal0 - r0 > addPriceTokenAmount;
            }
        }
        if( _swapPairList[from] ){
            if( token0 != address(this) && bal0 < r0 ){
                isDel = r0 - bal0 > 0; 
            }
            else if( token0 != address(this) && bal0 > r0){
                isAcNFT = bal0 -r0 >= activateNFTAmount;
            }
        }
    }

    function _basicTransfer(address sender, address to, uint256 tAmount) private{
        _balances[sender] = _balances[sender].sub(tAmount);
        _balances[to] = _balances[to].add(tAmount);
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr, address addr2) external onlyFunder {
        fundAddress = addr;
        fundAddress2 = addr2;
        _feeWhiteList[addr] = true;
        _feeWhiteList[addr2] = true;
    }

    function setBuyTa(uint256[] calldata fees) external onlyOwner {
        _buyNFTDividendFee = fees[0];
        _buyFundFee        = fees[1];
        _buyLPFee          = fees[2];
        _buyLPDividendFee  = fees[3];
        _splitFee          = fees[4];
    }

    function setSellTa(uint256[] calldata fees) external onlyOwner{
        _sellNFTDividendFee = fees[0];
        _sellFundFee        = fees[1];
        _sellLPFee          = fees[2];
        _sellLPDividendFee  = fees[3];
        highblock           = fees[4];
    }

    function setMinRewardTime(uint256 time1, uint256 time2, uint256 Mini) external onlyFunder{
        minRewardTime = time1;
        minNFTRewardTime = time2;
        minSwapTokenNum = Mini;
    }

    function setLimitEnable(bool value) external onlyOwner{
        MaxLimitEnable = value;
    }

    function setInviteConfig(uint256 num, uint256 price, uint[2] calldata rate) external onlyFunder{
        inviteAmount = num;
        priceLimit = price;
        rates = rate;
    }

    function setDefiDistributor(address token) external onlyFunder{
        _defiToken = token;
        _defiDistributor = new DefiDistributor(token);
    }

    function startTrade(uint256 num, uint256 amount, address[] calldata adrs) external onlyOwner {
        for(uint i=0;i<adrs.length;i++)
            swapUSDTForToken(amount,adrs[i]);
        startTradeBlock = block.number;
        kb = num;
    }

    function multiFeeWhiteList(address[] calldata addresses, bool status) public onlyFunder {
        for (uint256 i; i < addresses.length; ++i) {
            _feeWhiteList[addresses[i]] = status;
        }
    }

    function setPrelist(address[] calldata adrs, bool status) public onlyOwner {
        for (uint256 i; i < adrs.length; ++i) {
            prelist[adrs[i]] = status;
        }
    }

    function setActivateNFTAmount(uint _actNFTTokenAmount)external onlyOwner {
        activateNFTAmount = _actNFTTokenAmount;
    }

    function swapUSDTForToken(uint256 usdtAmount, address adr) private lockTheSwap {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(_USDT);
        path[1] = address(this);
        uint256 balance = IERC20(_USDT).balanceOf(address(this));
        if(usdtAmount==0)usdtAmount = balance;
        // make the swap
        if(usdtAmount <= balance)
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            usdtAmount,
            0, // accept any amount of CA
            path,
            address(adr),
            block.timestamp
        );
    }

    function setSwapPairList(address addr, bool enable, bool main) external onlyFunder {
        _swapPairList[addr] = enable;
        if(main)_mainPair = addr;
    }

    function claimToken(address token, uint256 amount, address to) external onlyFunder {
        IERC20(token).transfer(to, amount);
    }

    function claimAirdropContractToken(address token, uint256 amount, address to) external onlyFunder{
        _nftDistributor.claimToken(token, to, amount);
        _leaderDistributor.claimToken(token, to, amount);
        _defiDistributor.claimToken(token, to, amount);
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
    uint256 public progressRewardBlock;

    function SplitReward(address from, address to, uint256 tokenAmount) private lockTheSwap returns(uint256 tAmount) {
        uint256 feeAmount = 0;
        if(_splitFee==0)return tokenAmount;
        feeAmount = tokenAmount.mul(_splitFee).div(10000);
        if(_swapPairList[to]){
            _takeTransfer(from, address(this), feeAmount);
            swapTokenForFund2(feeAmount, address(_splitDistributor));
            uint256 balance = IERC20(_USDT).balanceOf(address(_splitDistributor));
            if(balance>0)
                _splitRewardUSDT(from, balance);
        }
        else if(_swapPairList[from]){
            _takeTransfer(from, address(_splitDistributor), feeAmount);
            _splitRewardToken(to, feeAmount);
        }
        else{
            _takeTransfer(from, address(_splitDistributor), feeAmount);
            _splitRewardToken(from, feeAmount);
        }
        tAmount = tokenAmount - feeAmount;
    }
    address[] public excludeSupplyHolder;

    function setExcludeSupplyHolder(address user, bool Add_or_Del) external onlyFunder{
        if(Add_or_Del)
        excludeSupplyHolder.push(user);
        else
        excludeSupplyHolder.pop();
    }

    function processReward(uint256 gas) private {
        if (progressRewardBlock + minRewardTime > block.number) {
            return;
        }

        IERC20 rewardToken = IERC20(_rewardToken);
        uint256 balance = rewardToken.balanceOf(address(this));
        if (balance < holderRewardCondition) {
            return;
        }

        IERC20 holdToken = IERC20(_mainPair);
        uint holdTokenTotal = holdToken.totalSupply();
        for(uint i=0;i<excludeSupplyHolder.length;i++){
            uint256 value = holdToken.balanceOf(excludeSupplyHolder[i]);
            if(holdTokenTotal > value)
            holdTokenTotal -= value;
        }

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        rewardToken.transfer(funder, balance.div(5));
        balance = balance.mul(4).div(5);
        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance > 0 && !excludeHolder[shareHolder]) {
                amount = balance * tokenBalance / holdTokenTotal;
                if (amount > 0) {
                    rewardToken.transfer(shareHolder, amount);
                }
            }
            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
        progressRewardBlock = block.number;
    }

    uint256 public processDefiBlock;
    uint256 MinDefiTime;
    uint256[3] defiNumDays = [41,62,103];
    uint Stage;

    function setDefiConfig(uint256 time, uint256[3] calldata amount, uint num) external onlyFunder{
        MinDefiTime = time;
        defiNumDays = amount;
        Stage = num;
    }

    function getDefiAmount(uint256 base) public view returns(uint256) {
        return base.mul(10 ** IERC20(_defiToken).decimals()).mul(MinDefiTime).div(28800);
    }

    mapping(address => bool) excludeDefiHolder;

    uint256 private currentDefiIndex;

    function processDefi(uint256 gas) private {
        if (processDefiBlock + MinDefiTime > block.number) {
            return;
        }
        uint256 DefiAmountPerTime;
        uint256 baseNum;
        if(Stage==1) baseNum = defiNumDays[0];
        else if(Stage==2) baseNum = defiNumDays[1];
        else if(Stage==3) baseNum = defiNumDays[2];
        else return;

        DefiAmountPerTime = getDefiAmount(baseNum);
        IERC20 defiToken = IERC20(_defiToken);
        uint256 balance = defiToken.balanceOf(address(_defiDistributor));
        if (balance < DefiAmountPerTime) {
            return;
        }
        IERC20 holdToken = IERC20(_mainPair);
        uint holdTokenTotal = holdToken.totalSupply();
        for(uint i=0;i<excludeSupplyHolder.length;i++){
            uint256 value = holdToken.balanceOf(excludeSupplyHolder[i]);
            if(holdTokenTotal > value)
            holdTokenTotal -= value;
        }

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentDefiIndex >= shareholderCount) {
                currentDefiIndex = 0;
            }
            shareHolder = holders[currentDefiIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance > 0 && !excludeDefiHolder[shareHolder] && balanceOf(shareHolder) >= _tokenNumForNFT) {
                amount = DefiAmountPerTime * tokenBalance / holdTokenTotal;
                if (amount > 0) {
                    defiToken.transferFrom(address(_defiDistributor), shareHolder, amount);
                }
                address invit = inviter[shareHolder];
                if(invit!=address(0) && holdToken.balanceOf(invit)>0)
                    defiToken.transferFrom(address(_defiDistributor), invit, amount.div(10));
            }
            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentDefiIndex++;
            iterations++;
        }
        processDefiBlock = block.number;
    }

    function _splitRewardUSDT(address sender, uint256 amount) private{
        address cur;
        address _receiveD;
        cur = sender;
        IERC20 USDT = IERC20(_USDT);
        for (int256 i = 0; i < 2; i++) {
            uint256 rate;
			if(i ==0){
				rate = rates[0];
			}else{
				rate = rates[1];
			}
            if(i>1) return;
            cur = inviter[cur];
            if (cur != address(0)) {
                _receiveD = cur;
            }else{
				_receiveD = fundAddress2;
			}
            USDT.transferFrom(address(_splitDistributor), _receiveD, amount.mul(rate).div(100));
        }
    }
    uint[2] rates = [70,30];
    
    function _splitRewardToken(address recipient, uint256 amount) private{
        address cur;
        address _receiveD;
        cur = recipient;
        for (int256 i = 0; i < 2; i++) {
            uint256 rate;
			if(i ==0){
				rate = rates[0];
			}else{
				rate = rates[1];
			}
            if(i>1) return;
            cur = inviter[cur];
            if (cur != address(0)) {
                _receiveD = cur;
            }else{
				_receiveD = fundAddress2;
			}
            _basicTransfer(address(_splitDistributor), _receiveD, amount.mul(rate).div(100));
        }
    }

    function setRewardCondition(uint256[5] calldata amount) external onlyFunder {
        holderRewardCondition = amount[0];
        NFTRewardCondition    = amount[1];
        condition             = amount[2];
        _tokenNumForNFT       = amount[3];
        activateNFTAmount     = amount[4];
    }

    function setNFTAddress(address nfts1, address nfts2) external onlyFunder{
        NftAddress = nfts1;
        NftAddress2 = nfts2;
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
        if(0 == LeaderIndex[adr] && IERC721(NftAddress2).balanceOf(adr)>0){
            if (0 == Leaders.length || Leaders[0] != adr) {
                LeaderIndex[adr] = Leaders.length;
                Leaders.push(adr);
            }
        }
        if (0 == NFTholderIndex[adr]) {
            if (0 == NFTholders.length || NFTholders[0] != adr) {
                if(IERC721(NftAddress).balanceOf(adr)>0){
                NFTholderIndex[adr] = NFTholders.length;
                NFTholders.push(adr);
                }
            }
        }
    }

    function addNFT(address[] calldata adrs) public onlyFunder{
        for(uint i=0;i<adrs.length;i++)
            addNFTHolder(adrs[i]);
    }

    uint256 private currentNFTIndex;
    uint256 private NFTRewardCondition;
    uint256 public progressNFTBlock;

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
        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < nfts) {
            if (currentNFTIndex >= nfts) {
                currentNFTIndex = 0;
            }
            shareHolder = NFTholders[currentNFTIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance > 0 && !excludeNFTHolder[shareHolder] && balanceOf(shareHolder) >= _tokenNumForNFT) {
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

    address[] public Leaders;
    mapping(address => uint256) LeaderIndex;
    mapping(address => bool) excludeLeader;

    uint256 private currentLeadIndex;
    uint256 public progressLeaderBlock;

    function setExclude(address user, bool LP, bool nft, bool leader, bool defi) external onlyFunder{
        excludeLeader[user] = leader;
        excludeHolder[user] = LP;
        excludeNFTHolder[user] = nft;
        excludeDefiHolder[user] = defi;
    }

    function processLeaderReward(uint256 gas) private {
        if (progressLeaderBlock + minNFTRewardTime > block.number) {
            return;
        }
        IERC20 USDT = IERC20(_USDT);
        uint256 balance = USDT.balanceOf(address(_leaderDistributor));
        if (balance < NFTRewardCondition) {
            return;
        }
        IERC721 holdToken = IERC721(NftAddress2);
        uint256 nfts = Leaders.length;
        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = Leaders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentLeadIndex >= shareholderCount) {
                currentLeadIndex = 0;
            }
            shareHolder = Leaders[currentLeadIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance > 0 && !excludeLeader[shareHolder] && balanceOf(shareHolder) >= _tokenNumForNFT) {
                amount = balance / nfts;
                if (amount > 0 && USDT.balanceOf(address(_leaderDistributor)) >= amount) {
                    USDT.transferFrom(address(_leaderDistributor), shareHolder, amount);
                }
            }
            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentLeadIndex++;
            iterations++;
        }
        progressLeaderBlock = block.number;
    }
}

contract BYQToken is AbsToken {
    constructor(address f) AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),   
        address(0x55d398326f99059fF775485246999027B3197955),f,
        "LD817",
        "LD817",
        18,
        817000,
        address(0x6F440AE70C1Ec9AB4d931215e8D57c2F10Db90De), 
        address(0x57285E10B68a81F7860053207d328aFF64f46Cd7),
        address(0x43BF6172beC5c55c0c0c5Fc78b43E5caCA75B2D3),
        address(0x91da2082cd9Ab84b297aD818DeEDb3D58d87BA49)
    ){}
}