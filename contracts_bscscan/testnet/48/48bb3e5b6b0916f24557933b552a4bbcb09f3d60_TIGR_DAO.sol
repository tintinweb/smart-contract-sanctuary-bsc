// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "./IBEP20.sol";
import "./SafeMath.sol";
import "./Address.sol";
import "./Ownable.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Router02.sol";

contract TIGR_DAO is Context, IBEP20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public automatedMarketMakerPairs;
    mapping(address => bool) private _isExcludedFromFee;

    mapping(address => bool) private _isExcluded;
    address[] private _excluded;

    uint256 private _Supply = 10**17 * 10**18; // 100 Quadrillion "10**17"

    string private constant _name = "TTGGKKSNHGDG";
    string private constant _symbol = "TTGT";
    uint8 private constant _decimals = 18;

    uint256 private B_Marketing = 1; // Buy Marketing Fee
    uint256 private S_Marketing = 1; // Sell Marketing Fee
    uint256 private W_Marketing = 1; // Normal W2W Marketing Fee
    uint256 private _Marketing; //main Marketing & Development
    uint256 private _previousMarketingFee = _Marketing;

    uint256 private B_Foundation_Fee = 1; // Buy Modicoin Foundation Fee
    uint256 private S_Foundation_Fee = 2; // Sell Modicoin Foundation Fee
    uint256 private W_Foundation_Fee = 0; // Normal W2W Modicoin Foundation Fee
    uint256 private _Foundation_Fee; //main
    uint256 private _previousFoundation_Fee = _Foundation_Fee;

    uint256 private B_SRAFee = 2; // Buy Liquidity Fee
    uint256 private S_SRAFee = 2; // Sell Liquidity Fee
    uint256 private W_SRAFee = 0; // Normal W2W Liquidity Fee
    uint256 private _SRAFee; //main
    uint256 private _previousSRAFee = _SRAFee;

    uint256 private B_BurnFee = 2; // Buy Burn Fee
    uint256 private S_BurnFee = 2; // Sell Burn Fee
    uint256 private W_BurnFee = 0; // Normal W2W Burn Fee
    uint256 private _BurnFee; //main
    uint256 private _previousBurnFee = _BurnFee;
    bool private takeFee;

    address public MarketingAdd = 0xADF3D8579360D6A0c0dC7954991724FA3A1ed009; // Marketing & Development Wallet
    address public FoundationAdd = 0x32419707e0CDe2476DE7Ca0A6Db60656620626A4; // TIGR Foundation Wallet
    address public SRA_Add = 0x32419707e0CDe2476DE7Ca0A6Db60656620626A4; // Staking, Rewards, Assets wallet
    IBEP20 BUSD = IBEP20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7); //******************************************************************************************************************************************************* */
    address private Dead = 0x000000000000000000000000000000000000dEaD;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    uint256 public _maxTxAmount = 10**14 * 10**18; // 0.1%

    // tracking Bought fees
    uint256 bMarketing;
    uint256 bFound;
    uint256 bSRA;

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event Normal_feesUpdated(
        uint256 Liquidity,
        uint256 foundation,
        uint256 Marketing,
        uint256 Burn
    );
    event Buy_feesUpdated(
        uint256 Liquidity,
        uint256 foundation,
        uint256 Marketing,
        uint256 Burn
    );
    event Sell_feesUpdated(
        uint256 Liquidity,
        uint256 foundation,
        uint256 Marketing,
        uint256 Burn
    );

    constructor() {
        _balances[owner()] = _Supply;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        );
        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), address(BUSD));
        _setAutomatedMarketMakerPair(uniswapV2Pair, true);
        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcluded[uniswapV2Pair] = true; // Excluded From Rewards

        emit Transfer(address(0), owner(), _Supply);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _Supply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "BEP20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "BEP20: decreased allowance below zero"
            )
        );
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    // function excludeFromReward(address account) public onlyOwner {
    //     // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap router.');
    //     require(!_isExcluded[account], "Account is already excluded");
    //     if (_rOwned[account] > 0) {
    //         _tOwned[account] = tokenFromReflection(_rOwned[account]);
    //     }
    //     _isExcluded[account] = true;
    //     _excluded.push(account);
    // }

    // function includeInReward(address account) external onlyOwner {
    //     require(_isExcluded[account], "Account is not excluded");
    //     for (uint256 i = 0; i < _excluded.length; i++) {
    //         if (_excluded[i] == account) {
    //             _excluded[i] = _excluded[_excluded.length - 1];
    //             _tOwned[account] = 0;
    //             _isExcluded[account] = false;
    //             _excluded.pop();
    //             break;
    //         }
    //     }
    // }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setMarketingAdd(address addr) external onlyOwner {
        MarketingAdd = addr;
    }

    function setFoundationAddress(address addr) external onlyOwner {
        FoundationAdd = addr;
    }

    /**
     * @dev Set All Fees That Work On Buy
     */
    function setBuyFees(
        uint256 SRAFee,
        uint256 foundation,
        uint256 Marketing,
        uint256 burnFee
    ) external onlyOwner {
        B_SRAFee = SRAFee;
        B_Foundation_Fee = foundation;
        B_Marketing = Marketing;
        B_BurnFee = burnFee;

        emit Buy_feesUpdated(
            B_SRAFee,
            B_Foundation_Fee,
            B_Marketing,
            B_BurnFee
        );
    }

    /**
     * @dev Set All Fees That Work On Sell
     */
    function setSellFees(
        uint256 SRAFee,
        uint256 foundation,
        uint256 Marketing,
        uint256 burnFee
    ) external onlyOwner {
        S_SRAFee = SRAFee;
        S_Foundation_Fee = foundation;
        S_Marketing = Marketing;
        S_BurnFee = burnFee;

        emit Sell_feesUpdated(
            S_SRAFee,
            S_Foundation_Fee,
            S_Marketing,
            S_BurnFee
        );
    }

    /**
     * @dev Set All Fees That Work On Wallet to Wallet Transfers
     */
    function setNormalFees(
        uint256 SRAFee,
        uint256 foundation,
        uint256 Marketing,
        uint256 burnFee
    ) external onlyOwner {
        W_SRAFee = SRAFee;
        W_Foundation_Fee = foundation;
        W_Marketing = Marketing;
        W_BurnFee = burnFee;

        emit Normal_feesUpdated(
            W_SRAFee,
            W_Foundation_Fee,
            W_Marketing,
            W_BurnFee
        );
    }

    /**
     * @dev Set The Router Address .
     * IMPORTANT: You Shouldn't Change This Router Address Unless Pancakeswap Upgraded to V3 Router or So ,
     * Do Some Research Before .
     */

    function setRouter(address router) public onlyOwner {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), address(BUSD));
        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(
            automatedMarketMakerPairs[pair] != value,
            "Brain: Automated market maker pair is already set to that value"
        );
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    /**
     * @dev You Should Set All Liquidity Pair Addresses To True , So The Fees Works on It .
     * Currently BNB/TKN Pair is Set To True ,  Where TKN = This Token Symbol .
     */

    function setAutomatedMarketMakerPair(address pair, bool value)
        public
        onlyOwner
    {
        require(
            pair != uniswapV2Pair,
            "Brain: The PancakeSwap pair cannot be removed from automatedMarketMakerPairs"
        );
        _setAutomatedMarketMakerPair(pair, value);
    }

    /**
     * @dev Max Transaction Limit
     */

    function setMaxTx(uint256 maxTx) external onlyOwner {
        _maxTxAmount = maxTx;
    }

    receive() external payable {}

    struct Values {
        uint256 Mar;
        uint256 Burn;
        uint256 Foundation;
        uint256 SRA;
        uint256 fAmount;
    }

    Values private TV;

    function _getValues(uint256 tAmount)
        private
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        Values memory m = Values(
            calculateMarketingFee(tAmount),
            calculateBurnFee(tAmount),
            calculateFoundation_Fee(tAmount),
            calculateSRAFee(tAmount),
            0
        );
        m.fAmount = tAmount.sub(m.Mar).sub(m.Burn).sub(m.Foundation).sub(m.SRA);

        TV = m;
        return (m.Mar, m.Burn, m.Foundation, m.SRA, m.fAmount);
    }

    function calculateMarketingFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.mul(_Marketing).div(10**2);
    }

    function calculateFoundation_Fee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.mul(_Foundation_Fee).div(10**2);
    }

    function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_BurnFee).div(10**2);
    }

    function calculateSRAFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_SRAFee).div(10**2);
    }

    /**
     * @dev Rescue The Locked BNB in The Contract .
     * The BNB Remains From The Liquidation Process And Stored in The Contract
     */
    function RescueBNB() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    /**
     * @dev Rescue Wrong Sent Tokens .
     */

    function RescueTokens(address _tokenContract, uint256 _amount)
        public
        onlyOwner
    {
        IBEP20 tokenContract = IBEP20(_tokenContract);
        tokenContract.transfer(owner(), _amount);
    }

    function removeAllFee() private {
        if (
            _Marketing == 0 &&
            _SRAFee == 0 &&
            _Foundation_Fee == 0 &&
            _BurnFee == 0
        ) return;

        _previousMarketingFee = _Marketing;
        _previousFoundation_Fee = _Foundation_Fee;
        _previousSRAFee = _SRAFee;
        _previousBurnFee = _BurnFee;

        _Marketing = 0;
        _Foundation_Fee = 0;
        _SRAFee = 0;
        _BurnFee = 0;
    }

    function restoreAllFee() private {
        _Marketing = _previousMarketingFee;
        _Foundation_Fee = _previousFoundation_Fee;
        _SRAFee = _previousSRAFee;
        _BurnFee = _previousBurnFee;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (from != owner() && to != owner())
            require(
                amount <= _maxTxAmount,
                "Transfer amount exceeds the maxTxAmount."
            );

        if (automatedMarketMakerPairs[to]) {
            //on sell
            _BurnFee = S_BurnFee;
            _Marketing = S_Marketing;
            _Foundation_Fee = S_Foundation_Fee;
            _SRAFee = S_SRAFee;
        } else if (automatedMarketMakerPairs[from]) {
            //on buy
            _BurnFee = B_BurnFee;
            _Marketing = B_Marketing;
            _Foundation_Fee = B_Foundation_Fee;
            _SRAFee = B_SRAFee;
        } else {
            _BurnFee = W_BurnFee;
            _Marketing = W_Marketing;
            _Foundation_Fee = W_Foundation_Fee;
            _SRAFee = W_SRAFee;
        }

        //indicates if fee should be deducted from transfer
        takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);
    }

    function _setAndSwap(
        address from,
        uint256 Mar,
        uint256 Found,
        uint256 sra
    ) private {
        uint256 Fees = Mar.add(Found).add(sra);

        _balances[address(this)] = _balances[address(this)].add(Fees);
        uint256 tokenBalance = balanceOf(address(this));

        bMarketing += Mar;
        bFound += Found;
        bSRA += sra;

        if (tokenBalance > 0 && !automatedMarketMakerPairs[from]) {
            uint256 Marketing = tokenBalance.sub(bFound).sub(bSRA);
            uint256 Founda = tokenBalance.sub(bMarketing).sub(bSRA);
            uint256 SRAW = tokenBalance.sub(bMarketing).sub(bFound);

            if (Marketing > 0) {
                swapTokensForEth(Marketing, MarketingAdd);
                bMarketing = 0;
            }
            if (Founda > 0) {
                swapTokensForEth(Founda, FoundationAdd);
                bFound = 0;
            }
            if (SRAW > 0) {
                swapTokensForEth(SRAW, SRA_Add);
                bSRA = 0;
            }
        }
    }

    function swapTokensForEth(uint256 tokenAmount, address _to) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(BUSD);

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BUSD
            path,
            _to,
            block.timestamp
        );
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFees
    ) private {
        if (!takeFees) removeAllFee();
        _transferStandard(sender, recipient, amount);
        if (!takeFees) restoreAllFee();
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 MarDev,
            uint256 burn,
            uint256 foundation,
            uint256 sra,
            uint256 fAmount
        ) = _getValues(tAmount);
        _balances[sender] = _balances[sender].sub(tAmount);
        _balances[recipient] = _balances[recipient].add(fAmount);
        _setAndSwap(sender, MarDev, foundation, sra);
        if (burn > 0) emit Transfer(sender, Dead, burn);
        emit Transfer(sender, recipient, fAmount);
    }
}